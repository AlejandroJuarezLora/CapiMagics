"""Which net is each probe point on? Run under `klayout -b -r`.

    klayout -b -r netcheck.py -rd gds=cell.gds -rd probes=probes.json

probes.json maps a name to [layer, datatype, x, y]. Probes that come out with
the same net id are electrically one node; the report groups them.

Why not an extractor. This was written when our stack had the MIM at
met2/met3 while magic's gf180 techfile puts it at metal4/metal5, so `ext2spice`
could not see the capacitors and reported plates on nets that made no geometric
sense. On MIM option B the two agree again, but this stays: it is fast, needs
no magic, and answers the question that matters here -- what is welded to what.
Devices and their parameters are the LVS's job.
KLayout's LayoutToNetlist is honest about geometry but prunes nets that hold
no device or pin, which is most of a supply grid. So this walks the metal
itself: merge each layer, then let every via weld the shapes it lands on.
"""
import json

import pya

# metal, the via above it, metal, ... The order is what makes a via adjacent
# to the two layers it connects.
STACK = [("met1", 34, 0), ("via1", 35, 0), ("met2", 36, 0), ("via2", 38, 0),
         ("met3", 42, 0), ("via3", 40, 0), ("met4", 46, 0), ("via4", 41, 0),
         ("met5", 81, 0)]
METAL = STACK[0::2]
VIA = STACK[1::2]

ly = pya.Layout()
ly.read(gds)                                                   # noqa: F821
top = ly.top_cell()


def polys(num, dt):
    return list(pya.Region(top.begin_shapes_rec(ly.layer(num, dt)))
                .merged().each())


shapes = {name: polys(num, dt) for name, num, dt in STACK}

# The MIM top plate is FuseTop, and the via that lands on it contacts *that*,
# not the bottom plate underneath. Treating capmet as invisible welds the two
# plates together and reports every capacitor as a dead short. Split that via
# into the part over FuseTop and the rest, and give capmet its own nodes.
#
# WHICH via depends on where the PDK puts the MIM: via2 with the plates on
# met2/met3 (option A), via4 with them on met4/met5 (option B). gf180 offers
# both and they are exclusive at the process level, so this looks at the
# layout instead of assuming: the via layer that actually overlaps FuseTop is
# the one to split. Splitting the wrong one leaves the plates welded, and the
# real connections -- which live on the metals the split via reaches -- come
# out invisible.
CAPMET = ("capmet", 75, 0)
shapes[CAPMET[0]] = polys(CAPMET[1], CAPMET[2])
_capmet = pya.Region([p for p in shapes[CAPMET[0]]])
_cap_via = next((n for n, _, _ in VIA
                 if pya.Region([p for p in shapes[n]]).interacting(_capmet).count()),
                "via2")
_v = pya.Region([p for p in shapes[_cap_via]])
shapes[_cap_via] = list(_v.not_(_capmet).each())
shapes[_cap_via + "_cap"] = list(_v.and_(_capmet).each())

# every merged metal polygon is one node; vias only join them
CONDUCTOR = [m[0] for m in METAL] + [CAPMET[0]]
nodes = [(name, i) for name in CONDUCTOR for i in range(len(shapes[name]))]
parent = {n: n for n in nodes}


def find(a):
    while parent[a] != a:
        parent[a] = parent[parent[a]]
        a = parent[a]
    return a


def union(a, b):
    ra, rb = find(a), find(b)
    if ra != rb:
        parent[ra] = rb


def hits(poly, layer):
    """Indices of merged shapes on `layer` that this polygon overlaps."""
    box = poly.bbox()
    out = []
    for i, other in enumerate(shapes[layer]):
        if box.overlaps(other.bbox()) or box.touches(other.bbox()):
            if not pya.Region(poly).and_(pya.Region(other)).is_empty():
                out.append(i)
    return out


welds = [(vname, METAL[k][0], METAL[k + 1][0])
         for k, (vname, _, _) in enumerate(VIA)]
# La via sobre el FuseTop une la placa superior con el metal de ARRIBA, no con
# el de abajo: ese es el sandwich. Cual sea ese metal depende de la opcion, y
# sale de la misma pila que la via detectada.
_k = [n for n, _, _ in VIA].index(_cap_via)
welds.append((_cap_via + "_cap", CAPMET[0], METAL[_k + 1][0]))

for vname, below, above in welds:
    for via in shapes[vname]:
        joined = ([(below, i) for i in hits(via, below)]
                  + [(above, i) for i in hits(via, above)])
        for other in joined[1:]:
            union(joined[0], other)

out = {}
by_num = {(num, dt): name for name, num, dt in list(METAL) + [CAPMET]}
for name, (num, dt, x, y) in json.load(open(probes)).items():   # noqa: F821
    layer = by_num.get((num, dt))
    pt = pya.Point(int(round(x / ly.dbu)), int(round(y / ly.dbu)))
    idx = next((i for i, p in enumerate(shapes.get(layer, []))
                if p.inside(pt)), None)
    if layer is None:
        estado, out[name] = "capa no es de metal", None
    elif idx is None:
        # missing the metal and standing on floating metal are different
        # findings; do not report them as the same thing
        estado, out[name] = "PUNTO FUERA DE LA CAPA", None
    else:
        root = find((layer, idx))
        out[name] = "%s#%d" % root
        estado = out[name]
    print("%-22s %-6s (%8.3f,%8.3f)  ->  %s" % (name, layer, x, y, estado))

groups = {}
for name, net in out.items():
    groups.setdefault(net, []).append(name)
print("\n--- redes ---")
for net, names in sorted(groups.items(), key=lambda kv: str(kv[0])):
    print("  %-14s %s" % (net or "SIN RED", " ".join(sorted(names))))
