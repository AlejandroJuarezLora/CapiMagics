"""Which net is each probe point on? Run under `klayout -b -r`.

    klayout -b -r netcheck.py -rd gds=cell.gds -rd probes=probes.json

probes.json maps a name to [layer, datatype, x, y]. Probes that come out with
the same net id are electrically one node; the report groups them.

Why not an extractor. magic's gf180 techfile puts the MIM at metal4/metal5
while our stack is 3LM with the MIM at met2/met3, so `ext2spice` cannot see
the capacitors and reports plates on nets that make no geometric sense.
KLayout's LayoutToNetlist is honest about geometry but prunes nets that hold
no device or pin, which is most of a supply grid. So this walks the metal
itself: merge each layer, then let every via weld the shapes it lands on.
"""
import json

import pya

# metal, the via above it, metal, ... The order is what makes a via adjacent
# to the two layers it connects.
STACK = [("met1", 34, 0), ("via1", 35, 0), ("met2", 36, 0), ("via2", 38, 0),
         ("met3", 42, 0), ("via3", 40, 0), ("met4", 46, 0)]
METAL = STACK[0::2]
VIA = STACK[1::2]

ly = pya.Layout()
ly.read(gds)                                                   # noqa: F821
top = ly.top_cell()


def polys(num, dt):
    return list(pya.Region(top.begin_shapes_rec(ly.layer(num, dt)))
                .merged().each())


shapes = {name: polys(num, dt) for name, num, dt in STACK}

# The MIM top plate is FuseTop, and the via2 that lands on it contacts *that*,
# not the met2 bottom plate underneath. Treating capmet as invisible welds the
# two plates together and reports every capacitor as a dead short. Split via2
# into the part over FuseTop and the rest, and give capmet its own nodes.
CAPMET = ("capmet", 75, 0)
shapes[CAPMET[0]] = polys(CAPMET[1], CAPMET[2])
_capmet = pya.Region([p for p in shapes[CAPMET[0]]])
_via2 = pya.Region([p for p in shapes["via2"]])
shapes["via2"] = list(_via2.not_(_capmet).each())
shapes["via2_cap"] = list(_via2.and_(_capmet).each())

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
welds.append(("via2_cap", CAPMET[0], "met3"))

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
