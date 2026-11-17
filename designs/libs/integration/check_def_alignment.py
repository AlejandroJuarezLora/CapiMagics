"""Check that a GDS matches the organizers' DEF the way the integrator needs it.

    python3 check_def_alignment.py D14_D.official.def runs/<tag>/final/gds/D14_D.gds

  1. top cell bbox == DEF DIEAREA, at the origin, and PR boundary (0/0) == DIEAREA;
  2. every official Metal2 pin rectangle is fully covered by top-level Metal2 of the
     same net (checked by a same-name Metal2 label inside that covered region);
  3. no layout outside the die.
Exits 1 on any failure.
"""
import re, sys
import pya

def_path, gds_path = sys.argv[1], sys.argv[2]
d = open(def_path).read()
units = int(re.search(r"UNITS DISTANCE MICRONS (\d+)", d).group(1))
die = [int(v) / units for v in re.search(r"DIEAREA \( (\d+) (\d+) \) \( (\d+) (\d+) \)", d).groups()]
pins = {}
for blk in re.split(r"(?m)^(?=- )", d.split("PINS", 1)[1].split("END PINS")[0]):
    m = re.match(r"- (\S+)", blk)
    if m:
        pins[m.group(1)] = [tuple(int(v) / units for v in r) for r in
                            re.findall(r"LAYER Metal2 \( (\d+) (\d+) \) \( (\d+) (\d+) \)", blk)]

ly = pya.Layout(); ly.read(gds_path); top = ly.top_cell(); dbu = ly.dbu
ok = True
def fail(msg):
    global ok; ok = False; print("FAIL", msg)

bb = top.dbbox()
print(f"top {top.name}: bbox {bb}, DEF die {die}")
if [round(v, 3) for v in (bb.left, bb.bottom, bb.right, bb.top)] != die:
    fail("layout bbox differs from DIEAREA")
pr = [s.dbbox() for s in top.shapes(ly.layer(0, 0)).each()]
if [ (round(b.left,3),round(b.bottom,3),round(b.right,3),round(b.top,3)) for b in pr] != [tuple(die)]:
    fail(f"PR boundary {pr} differs from DIEAREA")

m2 = pya.Region(top.begin_shapes_rec(ly.layer(36, 0))).merged()
labels = [(s.text_string, s.dbbox().center()) for s in top.shapes(ly.layer(36, 10)).each() if s.is_text()]
for name, rects in pins.items():
    for r in rects:
        box = pya.Region(pya.DBox(*r).to_itype(dbu))
        if not (box - m2).is_empty():
            fail(f"{name}: official rectangle {r} not fully covered by Metal2")
            continue
        # the covering Metal2 island must carry a label with this pin's name
        island = m2.interacting(box)
        named = {t for t, c in labels if island.interacting(pya.Region(pya.DBox(c.x - 0.001, c.y - 0.001, c.x + 0.001, c.y + 0.001).to_itype(dbu))).count()}
        if name not in named:
            fail(f"{name}: Metal2 over {r} has labels {sorted(named) or 'none'}")
    print(f"  {name:8s} {len(rects)} official rectangles checked")
print("PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
