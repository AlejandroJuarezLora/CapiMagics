"""Power bridge cells for D14_D (approach taken from team D10, chipathon 2026).

The padframe brings avss/avdd as Metal2 pin columns at the block edge (D14_D.def):
  avss: west edge, x 0..1 um, six stripes between y = 1.36 and 73.64 um
  avdd: north edge, y 604..605 um, six stripes between x = 331.36 and 403.64 um
Nothing in a default LibreLane flow connects Metal2 pins to the Metal4/Metal5 grid.
Each cell repeats the official stripes, extends them 30 um into the block, and stacks
Via2 up to an identical Metal3 plate. The wrapper's vertical Metal4 straps run over the
plate and pdn_cfg.tcl drops the Metal3-Metal4 vias.

Cell origins sit on the 0.56 um site grid so placement does not move the stripes
(avdd_conn starts at y = 575.12, so its plate is 29.88 um deep).
    klayout -b -r build_conn.py
"""
import pya

VIA, INSET, PITCH = 0.26, 0.42, 0.62          # Via2 size, inset, pitch (um)
DEPTH = 30.0                                    # how far the plate reaches into the block
LYR = {"Metal2": (36, 0), "Via2": (38, 0), "Metal3": (42, 0)}

# Official stripes in block coordinates (um), from D14_D.official.def (UNITS 200).
AVSS_Y = [(1.36, 10.86), (13.76, 24.01), (25.61, 35.86), (39.14, 49.39), (50.99, 61.24), (64.14, 73.64)]
AVDD_X = [(331.36, 340.86), (343.76, 354.01), (355.61, 365.86), (369.14, 379.39), (380.99, 391.24), (394.14, 403.64)]
DIE = 605.0

# name, net, cell origin in the block, stripes as boxes in block coordinates
CELLS = {
    "avss_conn": ("avss", (0.0, 0.0), [(0.0, y1, DEPTH, y2) for y1, y2 in AVSS_Y], (DEPTH, 73.64)),
    "avdd_conn": ("avdd", (330.96, 575.12), [(x1, 575.12, x2, DIE) for x1, x2 in AVDD_X], (403.64 - 330.96, DIE - 575.12)),
}


def vias(shapes, x1, y1, x2, y2):
    n, y = 0, y1 + INSET
    while y + VIA <= y2 - INSET + 1e-6:
        x = x1 + INSET
        while x + VIA <= x2 - INSET + 1e-6:
            shapes.insert(pya.DBox(x, y, x + VIA, y + VIA)); x += PITCH; n += 1
        y += PITCH
    return n


lef = []
for name, (net, (ox, oy), boxes, (w, h)) in CELLS.items():
    ly = pya.Layout(); ly.dbu = 0.001
    c = ly.create_cell(name); L = {k: ly.layer(*v) for k, v in LYR.items()}
    # PR boundary (layer 0/0) = LEF SIZE: LibreLane reads the macro outline from it.
    c.shapes(ly.layer(0, 0)).insert(pya.DBox(0, 0, w, h))
    rects, nv = [], 0
    for bx1, by1, bx2, by2 in boxes:
        r = (round(bx1 - ox, 3), round(by1 - oy, 3), round(bx2 - ox, 3), round(by2 - oy, 3))
        rects.append(r)
        for m in ("Metal2", "Metal3"):
            c.shapes(L[m]).insert(pya.DBox(*r))
        nv += vias(c.shapes(L["Via2"]), *r)
    ly.write(f"{name}.gds")
    use = "GROUND" if net == "avss" else "POWER"
    ports = "".join(f"        RECT {r[0]:.3f} {r[1]:.3f} {r[2]:.3f} {r[3]:.3f} ;\n" for r in rects)
    lef.append(f"""MACRO {name}
  CLASS BLOCK ;
  FOREIGN {name} ;
  ORIGIN 0.000 0.000 ;
  SIZE {w:.3f} BY {h:.3f} ;
  PIN {net}
    DIRECTION INOUT ;
    USE {use} ;
    PORT
      LAYER Metal2 ;
{ports}      LAYER Metal3 ;
{ports}    END
  END {net}
END {name}
""")
    with open(f"{name}.v", "w") as f:
        f.write(f"(* blackbox *)\nmodule {name} (inout {net});\nendmodule\n")
    print(f"{name}: origin {ox},{oy}  size {w:.3f} x {h:.3f} um  {nv} vias")
    with open(f"{name}.lef", "w") as f:
        f.write('VERSION 5.7 ;\n  NOWIREEXTENSIONATPIN ON ;\n  DIVIDERCHAR "/" ;\n  BUSBITCHARS "[]" ;\n'
                + lef[-1] + "END LIBRARY\n")
