"""Recaracterizacion con M5 como interruptor.

Las leyes actuales se ajustaron con M5 largo (L=50um), donde la carga que el
interruptor inyecta al abrirse domina el umbral: Vth = 1.2792 + Q/Cm con
Q proporcional a W*L. Eso convierte a M5 en el mando de frecuencia y obliga a
canales de 20-50um, que en layout son una barra de 24-54um de ancho.

Con M5 al minimo la carga inyectada cae de ~114 fC a ~0.4 fC, el umbral
colapsa al punto de conmutacion del inversor y la frecuencia deberia quedar

    f = Iex / (Cm * dV)      con dV fijo

o sea proporcional a Iex e inversa a Cm, sin que W ni L intervengan. Este
barrido comprueba exactamente eso, y de paso mide cuanta frecuencia mueve M5
todavia -- si mueve poco, deja de ser variable de diseño.

Uso:  python sweep_m5_switch.py [salida.csv]
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

import fixture as fx

AQUI = Path(__file__).resolve().parent
PLANTILLA = AQUI / "tb_lif.spice"

# dV esperado si la inyeccion es despreciable: el punto de conmutacion del
# inversor, que ya sale como termino independiente de la ley de Vth.
DV_ESPERADO = 1.2792

M5_MIN = (0.22, 0.28)      # W, L en um -- minimo construible (dogbone)
M5_ABE = (10.0, 0.28)      # lo que puso Abrahan
M5_VIEJO = (1.25, 50.0)    # el del barrido original

# Malla principal: M5 minimo, se mueven Cm e Iex. La corriente sube con Cm
# para que el periodo no se dispare y el transitorio quede acotado.
MALLA = [(M5_MIN, cm, iex)
         for cm in (50.0, 100.0, 150.0, 300.0)
         for iex in (100.0, 200.0, 400.0)]

# Control del mecanismo: mismo Cm e Iex, tres tamaños de M5. Si la frecuencia
# apenas se mueve entre el minimo y el de Abrahan, la inyeccion ya no manda.
CONTROL = [(m5, 150.0, 100.0) for m5 in (M5_MIN, M5_ABE, M5_VIEJO)]


def periodo_esperado_us(cm_ff: float, iex_na: float) -> float:
    """T = Cm*dV/Iex, en microsegundos."""
    return cm_ff * 1e-15 * DV_ESPERADO / (iex_na * 1e-9) * 1e6


def corre(m5, cm, iex, etiqueta):
    w, l = m5
    t_per = periodo_esperado_us(cm, iex)
    # 6 periodos utiles mas el arranque que measure() descarta
    tstop = max(8.0, fx.SKIP_US + 8 * t_per)
    params = {"W_M5": w, "L_M5": l, "Cm": cm}
    netlist = fx.build_netlist(params, iex, PLANTILLA, tstop_us=tstop)

    with tempfile.TemporaryDirectory() as d:
        deck = Path(d) / "tb.spice"
        raw = Path(d) / "tb_charac_isrc.raw"
        deck.write_text(netlist, encoding="utf-8")
        proc = subprocess.run(["ngspice", "-b", str(deck)], cwd=d,
                              capture_output=True, text=True, timeout=7200)
        if not raw.exists():
            cola = (proc.stderr or proc.stdout or "").strip().splitlines()[-1:]
            return {"error": " ".join(cola) or "sin raw"}
        m = fx.measure(str(raw))

    f_ideal = iex / (cm * DV_ESPERADO) * 1e3      # kHz
    m.update({"W_M5": w, "L_M5": l, "Cm": cm, "iex": iex,
              "tstop_us": tstop, "f_ideal": f_ideal, "etiqueta": etiqueta})
    return m


def linea(r):
    if "error" in r:
        return ("%-9s W=%-5s L=%-5s Cm=%-6s Iex=%-5s  FALLO: %s"
                % (r.get("etiqueta", ""), r.get("W_M5"), r.get("L_M5"),
                   r.get("Cm"), r.get("iex"), r["error"][:60]))
    f = r.get("f", 0.0)
    err = 100 * (f - r["f_ideal"]) / r["f_ideal"] if r["f_ideal"] else 0.0
    return ("%-9s W=%-5.2f L=%-5.2f Cm=%-6.0f Iex=%-5.0f  f=%8.1f "
            "(ideal %8.1f, %+6.1f%%)  Vth=%5.2f  swing=%5.2f  ciclos=%2.0f"
            % (r["etiqueta"], r["W_M5"], r["L_M5"], r["Cm"], r["iex"],
               f, r["f_ideal"], err, r.get("Vth", 0.0), r.get("swing", 0.0),
               r.get("n_cyc", 0)))


def main(destino=None):
    filas = []
    print("CONTROL DEL MECANISMO -- mismo Cm e Iex, distinto M5")
    for m5, cm, iex in CONTROL:
        r = corre(m5, cm, iex, "control")
        filas.append(r)
        print("  " + linea(r), flush=True)

    print("\nMALLA -- M5 minimo, se mueven Cm e Iex")
    for m5, cm, iex in MALLA:
        r = corre(m5, cm, iex, "malla")
        filas.append(r)
        print("  " + linea(r), flush=True)

    if destino:
        campos = ["etiqueta", "W_M5", "L_M5", "Cm", "iex", "f", "f_ideal",
                  "Vth", "Vm_min", "swing", "jitter_pct", "n_cyc", "tstop_us"]
        with open(destino, "w", encoding="utf-8") as fh:
            fh.write(",".join(campos) + "\n")
            for r in filas:
                fh.write(",".join(str(r.get(c, "")) for c in campos) + "\n")
        print(f"\nescrito {destino}")
    return filas


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else None)
