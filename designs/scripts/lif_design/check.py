"""Build the LIF cell at several sizes and check each one is really a LIF.

Run inside the container:

    GLAYOUT_BACKEND=gdstk python check.py

The dimensions come from the characterisation layer, so the generator has to
hold up across the range those laws produce, not just at one point. For every
size this runs DRC *with the MIM rules enabled* -- the gf180 deck defaults
mim_option to "Nan" and silently skips the whole MIM section otherwise -- and
then checks the six nets of the LIF topology by walking the metal.

What is being asserted, per the netlist:

    integration  M5 drain, inv0 gate, the cap top plates
    spike_neg    inv0 drain, inv1 gate, inv2 gate
    spike/reset  inv1 drain, M5 gate            <- the reset feedback
    spike        inv2 drain                     <- the cell output
    VDD          pfet sources, the top rail
    VSS          nfet sources, M5 source, the cap bottom plates, bottom rail

A net coming out merged with another is a short; one splitting in two is an
open. Both show up here as a set that does not match.
"""
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, "/tmp")

from glayout import gf180                                       # noqa: E402

from engine.build import lif_cell                               # noqa: E402

DECK = "/tmp/ci102/src/glayout/pdk/gf180_mapped/gf180mcu.drc"
NETCHECK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "netcheck.py")
FET = dict(multipliers=1, fingers=1, with_substrate_tap=False,
           with_dummy=False, tie_layers=("met2", "met1"), sd_rmult=1)

CASOS = [
    ("base",        dict(w_inv=0.22, l_inv=0.28, w_m5=1.25, l_m5=50.0, cap=5.0)),
    ("inv anchos",  dict(w_inv=1.00, l_inv=0.28, w_m5=1.25, l_m5=50.0, cap=5.0)),
    ("M5 corto",    dict(w_inv=0.22, l_inv=0.28, w_m5=1.25, l_m5=25.0, cap=5.0)),
    ("M5 ancho",    dict(w_inv=0.22, l_inv=0.28, w_m5=3.50, l_m5=50.0, cap=5.0)),
    ("cap grande",  dict(w_inv=0.22, l_inv=0.28, w_m5=1.25, l_m5=50.0, cap=8.0)),
    ("todo grande", dict(w_inv=1.00, l_inv=0.50, w_m5=3.50, l_m5=50.0, cap=8.0)),
]

ESPERADO = {
    "membrana":     {"M5_drain", "nfet0_gate", "pfet0_gate",
                     "cap0_arriba", "cap1_arriba", "cap2_arriba"},
    "spike_neg":    {"nfet0_drain", "pfet0_drain",
                     "nfet1_gate", "pfet1_gate", "nfet2_gate", "pfet2_gate"},
    "realimenta":   {"nfet1_drain", "pfet1_drain", "M5_gate"},
    "salida":       {"nfet2_drain", "pfet2_drain"},
    "VDD":          {"riel_VDD", "pfet0_source", "pfet1_source", "pfet2_source"},
    "VSS":          {"riel_VSS", "M5_source", "nfet0_source", "nfet1_source",
                     "nfet2_source", "cap0_abajo", "cap1_abajo", "cap2_abajo"},
}

MET = {"met1": 34, "met2": 36, "met3": 42, "met4": 46}


def sondas(handles, bbox):
    r = handles["rails"]
    L = MET[r["glayer"]]
    mid = float(bbox[0][0] + bbox[1][0]) / 2
    pr = {"riel_VDD": [L, 0, mid, r["vdd"]], "riel_VSS": [L, 0, mid, r["vss"]]}
    for i, c in enumerate(handles["caps"]):
        q = c.ports["top_met_S"]
        pr["cap%d_arriba" % i] = [42, 0, float(q.center[0]), float(q.center[1]) + 0.25]
        b = c.ports["bottom_met_S"]
        pr["cap%d_abajo" % i] = [36, 0, float(b.center[0]), float(b.center[1]) + 0.25]
    for tag, lst in (("nfet", handles["nfets"]), ("pfet", handles["pfets"])):
        for i, ref in enumerate(lst):
            for nombre, puerto in (("source", "multiplier_0_source_W"),
                                   ("drain", "multiplier_0_drain_W")):
                p = ref.ports[puerto]
                pr["%s%d_%s" % (tag, i, nombre)] = [
                    36, 0, float(p.center[0]) + 0.2, float(p.center[1])]
            g = ref.ports["multiplier_0_gate_S"]
            pr["%s%d_gate" % (tag, i)] = [
                36, 0, float(g.center[0]), float(g.center[1]) + 0.15]
    for nombre, puerto in (("source", "multiplier_0_source_W"),
                           ("drain", "multiplier_0_drain_W"),
                           ("gate", "multiplier_0_gate_W")):
        p = handles["m5"].ports[puerto]
        pr["M5_%s" % nombre] = [36, 0, float(p.center[0]) + 0.2, float(p.center[1])]
    return pr


def drc(gds, tag):
    rep = "/tmp/%s.lyrdb" % tag
    subprocess.run(["klayout", "-b", "-r", DECK, "-rd", "input=" + gds,
                    "-rd", "report=" + rep, "-rd", "mim_option=A"],
                   capture_output=True)
    texto = open(rep).read()
    cuenta = {}
    for cat in re.findall(r"<category>'([^']+)'", texto):
        cuenta[cat] = cuenta.get(cat, 0) + 1
    return texto.count("<item>"), cuenta


def redes(gds, probes):
    salida = subprocess.run(["klayout", "-b", "-r", NETCHECK, "-rd", "gds=" + gds,
                             "-rd", "probes=" + probes],
                            capture_output=True, text=True).stdout
    grupos = []
    for linea in salida.splitlines():
        m = re.match(r"\s+(\S+)\s+(.+)$", linea)
        if m and "#" in m.group(1):
            grupos.append(set(m.group(2).split()))
    return grupos


def main():
    fallos = 0
    print("%-12s %-16s %5s  %s" % ("caso", "caja um", "DRC", "topologia"))
    print("-" * 74)
    for nombre, kw in CASOS:
        tag = "chk_" + re.sub(r"\W+", "_", nombre)
        try:
            top, h = lif_cell(
                gf180,
                inverter=dict(width=kw["w_inv"], length=kw["l_inv"], **FET),
                m5=dict(width=kw["w_m5"], length=kw["l_m5"], **FET),
                cap_size=kw["cap"], name=tag)
        except Exception as exc:
            print("%-12s no genera: %s" % (nombre, str(exc)[:52]))
            fallos += 1
            continue

        gds = "/tmp/%s.gds" % tag
        top.write_gds(gds)
        bb = top.bbox
        n, cats = drc(gds, tag)
        pr = sondas(h, bb)
        json.dump(pr, open("/tmp/%s.json" % tag, "w"))
        grupos = redes(gds, "/tmp/%s.json" % tag)

        malas = []
        for red, quiero in ESPERADO.items():
            if not any(g == quiero for g in grupos):
                encontrado = next((g for g in grupos if g & quiero), set())
                malas.append("%s(%s)" % (
                    red, "+".join(sorted(encontrado - quiero)) or "partida"))
        estado = "ok" if not malas and n == 0 else " ".join(malas) or "DRC"
        if malas or n:
            fallos += 1
        print("%-12s %6.2f x %6.2f  %5s  %s"
              % (nombre, bb[1][0] - bb[0][0], bb[1][1] - bb[0][1],
                 n if not n else "%d %s" % (n, cats), estado))
    print("\n%s" % ("todos los casos pasan" if not fallos
                    else "%d caso(s) con problemas" % fallos))
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
