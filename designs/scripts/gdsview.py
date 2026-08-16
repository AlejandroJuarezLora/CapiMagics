"""Visor de GDS con zoom zonal y filtro de capas.

La regla de trabajo es mirar el layout antes de tocarlo, y para que eso sirva la
imagen tiene que estar recortada a la zona y sin las capas que estorban. Un
volcado de todas las capas de la celda entera no ense~na nada.

Ejemplos:

    # la zona del mimcap, solo las capas que importan
    python gdsview.py opamp.gds --alrededor fusetop --solo met2,via2,met3,via3,met4 -o cap.png

    # una ventana concreta, escondiendo los metales altos
    python gdsview.py lif.gds --zona 20,10,40,30 --ocultar met4,met5 -o zoom.png

    # el orden de dibujo se puede forzar; por defecto va de abajo a arriba
    python gdsview.py lif.gds --solo met2,met3 --orden met3,met2 -o o.png

La leyenda lleva el numero de poligonos de cada capa dentro de la ventana. Ese
contador es la mitad del diagnostico: una capa de vias con 0 donde deberia haber
conexion explica el fallo sin mirar nada mas.
"""
from __future__ import annotations

import argparse
import sys
from collections import Counter

import gdstk
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon as MplPoly

# gf180. nombre -> (capa, datatype, color, alpha)
CAPAS = {
    # Un metal por familia de color, bien separadas: met1 y met2 compartian dos
    # azules y en pantalla eran el mismo. Las vias van todas en negro -- son
    # cuadraditos y lo unico que importa de ellas es donde estan.
    "nwell":   ((21, 0),  "#94a3b8", 0.20),
    "diff":    ((22, 0),  "#a16207", 0.35),
    "poly2":   ((30, 0),  "#be123c", 0.35),
    "nplus":   ((32, 0),  "#4ade80", 0.15),
    "pplus":   ((31, 0),  "#f472b6", 0.15),
    "contact": ((33, 0),  "#111827", 0.85),
    "met1":    ((34, 0),  "#a855f7", 0.45),   # morado
    "via1":    ((35, 0),  "#111827", 0.85),
    "met2":    ((36, 0),  "#2563eb", 0.45),   # azul
    "via2":    ((38, 0),  "#111827", 0.85),
    "met3":    ((42, 0),  "#16a34a", 0.40),   # verde
    "via3":    ((40, 0),  "#111827", 0.90),
    "met4":    ((46, 0),  "#ea580c", 0.35),   # naranja
    "via4":    ((41, 0),  "#111827", 0.90),
    "met5":    ((81, 0),  "#dc2626", 0.30),   # rojo
    "fusetop": ((75, 0),  "#c026d3", 0.00),   # solo contorno
    "cap_mk":  ((117, 5), "#f59e0b", 0.12),
    "mim_l_mk":((117, 10),"#eab308", 0.12),
}

# de abajo a arriba: lo de encima se dibuja despues
ORDEN = ["nwell", "diff", "nplus", "pplus", "poly2", "contact", "met1", "via1",
         "met2", "via2", "fusetop", "met3", "via3", "met4", "via4", "met5",
         "cap_mk", "mim_l_mk"]

SOLO_CONTORNO = {"fusetop"}


def _lista(txt):
    return [x.strip() for x in txt.split(",") if x.strip()] if txt else []


# capas conductoras y que via une a que par de metales
PILA = [("met1", "via1", "met2"), ("met2", "via2", "met3"),
        ("met3", "via3", "met4"), ("met4", "via4", "met5")]


def red_en(gds, celda, punto):
    """Devuelve los poligonos de la red que toca `punto`, por capa.

    Recorre la pila de metales y vias uniendo lo que se solapa. Sirve para
    contestar la unica pregunta que el DRC no contesta: *estas dos cosas estan
    en la misma red o no*. Un corto se ve al instante -- la red se come medio
    circuito -- y una conexion que falta tambien: la red se queda coja.
    """
    import klayout.db as kdb

    ly = kdb.Layout()
    ly.read(gds)
    top = ly.cell(celda) if celda else ly.top_cell()

    def region(nombre):
        capa, dt = CAPAS[nombre][0]
        idx = ly.find_layer(capa, dt)
        if idx is None:
            return kdb.Region()
        r = kdb.Region(top.begin_shapes_rec(idx))
        r.merge()
        return r

    metales = {m: region(m) for m in ("met1", "met2", "met3", "met4", "met5")}
    vias = {v: region(v) for _, v, _ in PILA}

    # Las vias que caen sobre el FuseTop son el dielectrico del MIM, no un
    # contacto: unen el plato de abajo con el de arriba solo en apariencia. El
    # deck del PDK las saca de la conectividad (`via2_n_cap = via2.not(fusetop)`)
    # y aqui hay que hacer lo mismo, o el condensador sale en cortocircuito.
    capmet = region("fusetop")
    if not capmet.is_empty():
        for v in list(vias):
            vias[v] = vias[v] - capmet

    # semilla: el poligono de metal que contiene el punto
    px, py = punto
    dbu = ly.dbu
    caja = kdb.Region(kdb.Box(int((px - 0.02) / dbu), int((py - 0.02) / dbu),
                              int((px + 0.02) / dbu), int((py + 0.02) / dbu)))
    neta = {m: kdb.Region() for m in metales}
    for m, r in metales.items():
        sel = r.interacting(caja)
        if not sel.is_empty():
            neta[m] = sel
            break
    else:
        return None

    # crece hasta que deje de crecer: metal -> via -> metal, en los dos sentidos
    for _ in range(40):
        antes = sum(neta[m].count() for m in neta)
        for abajo, via, arriba in PILA:
            if vias[via].is_empty():
                continue
            v_ab = vias[via].interacting(neta[abajo])
            if not v_ab.is_empty():
                neta[arriba] = (neta[arriba] + metales[arriba].interacting(v_ab)).merged()
            v_ar = vias[via].interacting(neta[arriba])
            if not v_ar.is_empty():
                neta[abajo] = (neta[abajo] + metales[abajo].interacting(v_ar)).merged()
        if sum(neta[m].count() for m in neta) == antes:
            break

    salida = {}
    for m, r in neta.items():
        polys = [[(p.x * dbu, p.y * dbu) for p in poly.each_point_hull()]
                 for poly in r.each()]
        if polys:
            salida[m] = polys
    return salida


def _bbox(polys):
    xs = [p[0] for poly in polys for p in poly.points]
    ys = [p[1] for poly in polys for p in poly.points]
    return min(xs), min(ys), max(xs), max(ys)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("gds")
    ap.add_argument("-o", "--salida", default="vista.png")
    ap.add_argument("--celda", help="nombre de celda; por defecto la primera")
    ap.add_argument("--zona", help="x0,y0,x1,y1 en um")
    ap.add_argument("--alrededor", help="recorta a la bbox de esta capa")
    ap.add_argument("--margen", type=float, default=8.0)
    ap.add_argument("--solo", help="dibuja unicamente estas capas")
    ap.add_argument("--ocultar", help="quita estas capas")
    ap.add_argument("--orden", help="fuerza el orden de dibujo")
    ap.add_argument("--etiquetas", action="store_true", help="pinta los labels")
    ap.add_argument("--red", help="x,y: resalta la red conductora que toca ese punto")
    ap.add_argument("--titulo", default="")
    ap.add_argument("--dpi", type=int, default=115)
    a = ap.parse_args(argv)

    lib = gdstk.read_gds(a.gds)
    celdas = {c.name: c for c in lib.cells}
    if a.celda:
        if a.celda not in celdas:
            sys.exit(f"celda '{a.celda}' no esta. hay: {', '.join(sorted(celdas))}")
        cell = celdas[a.celda]
    else:
        # la de nivel superior, no la primera de la lista: en un GDS jerarquico
        # `cells[0]` suele ser una subcelda y la vista sale de unas micras
        superiores = lib.top_level()
        cell = superiores[0] if superiores else lib.cells[0]
    polys = cell.get_polygons()

    visibles = [n for n in (a.orden and _lista(a.orden) or ORDEN) if n in CAPAS]
    if a.solo:
        pedidas = _lista(a.solo)
        desconocidas = [n for n in pedidas if n not in CAPAS]
        if desconocidas:
            sys.exit(f"capa(s) desconocida(s): {', '.join(desconocidas)}")
        visibles = [n for n in visibles if n in pedidas]
        # respeta el orden pedido si se uso --orden
        if a.orden:
            visibles = [n for n in _lista(a.orden) if n in pedidas]
    for n in _lista(a.ocultar):
        if n in visibles:
            visibles.remove(n)

    # ventana
    if a.zona:
        x0, y0, x1, y1 = (float(v) for v in a.zona.split(","))
    elif a.alrededor:
        ld = CAPAS[a.alrededor][0]
        sel = [p for p in polys if (p.layer, p.datatype) == ld]
        if not sel:
            sys.exit(f"no hay poligonos de '{a.alrededor}' en {cell.name}")
        bx0, by0, bx1, by1 = _bbox(sel)
        x0, y0, x1, y1 = bx0 - a.margen, by0 - a.margen, bx1 + a.margen, by1 + a.margen
    else:
        x0, y0, x1, y1 = _bbox(polys)

    ancho = max(x1 - x0, 1e-6)
    alto = max(y1 - y0, 1e-6)
    fig, ax = plt.subplots(figsize=(13, min(13 * alto / ancho + 1.0, 16)))

    cuenta = Counter()
    for nombre in visibles:
        ld, color, alpha = CAPAS[nombre][0], CAPAS[nombre][1], CAPAS[nombre][2]
        for p in polys:
            if (p.layer, p.datatype) != ld:
                continue
            pts = p.points
            if max(q[0] for q in pts) < x0 or min(q[0] for q in pts) > x1:
                continue
            if max(q[1] for q in pts) < y0 or min(q[1] for q in pts) > y1:
                continue
            cuenta[nombre] += 1
            if nombre in SOLO_CONTORNO:
                ax.add_patch(MplPoly(pts, closed=True, facecolor="none",
                                     edgecolor=color, lw=1.8, zorder=9))
            else:
                ax.add_patch(MplPoly(pts, closed=True, facecolor=color,
                                     edgecolor=color, alpha=alpha, lw=0.3))
        ax.plot([], [], color=color, lw=6,
                alpha=max(alpha, 0.5), label=f"{nombre} ({cuenta[nombre]})")

    if a.red:
        px, py = (float(v) for v in a.red.split(","))
        neta = red_en(a.gds, a.celda, (px, py))
        if neta is None:
            print(f"  no hay metal en ({px}, {py})")
        else:
            total = 0
            for nombre, polys in neta.items():
                for pts in polys:
                    total += 1
                    ax.add_patch(MplPoly(pts, closed=True, facecolor="#facc15",
                                         edgecolor="#a16207", alpha=0.55, lw=0.6,
                                         zorder=11))
            ax.plot([], [], color="#facc15", lw=6,
                    label="red en (%.1f,%.1f): %d" % (px, py, total))
            print("  red en (%.1f,%.1f): " % (px, py)
                  + "  ".join(f"{k}={len(v)}" for k, v in neta.items()))
        ax.plot([px], [py], marker="x", color="#111827", ms=12, mew=2.5, zorder=13)

    if a.etiquetas:
        for lab in cell.labels:
            lx, ly = lab.origin
            if x0 <= lx <= x1 and y0 <= ly <= y1:
                ax.text(lx, ly, lab.text, fontsize=7, color="#111827", zorder=12,
                        ha="center", va="center",
                        bbox=dict(fc="white", ec="none", alpha=0.65, pad=0.8))

    ax.set_xlim(x0, x1)
    ax.set_ylim(y0, y1)
    ax.set_aspect("equal")
    ax.legend(loc="upper left", fontsize=8, ncol=2)
    ax.set_title(a.titulo or f"{cell.name}  [{x0:.1f},{y0:.1f}] - [{x1:.1f},{y1:.1f}] um")
    plt.tight_layout()
    plt.savefig(a.salida, dpi=a.dpi)

    vacias = [n for n in visibles if cuenta[n] == 0]
    print(f"{a.salida}  ventana {x1-x0:.1f} x {y1-y0:.1f} um")
    print("  " + "  ".join(f"{n}={cuenta[n]}" for n in visibles))
    if vacias:
        print("  sin poligonos en la ventana: " + ", ".join(vacias))


if __name__ == "__main__":
    main()
