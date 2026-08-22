"""Verificacion por simulacion: cierra el lazo diseño -> netlist -> medida.

En primera instancia el "return" del sistema es un netlist SPICE que se simula
para comprobar que el diseño cumple lo que las leyes predicen. Cuando gLayout
avance, el return sera el layout y esto quedara como verificacion previa.

Genera el netlist a partir de tb_charac_isrc.spice (entrada de corriente, sin
M6) sustituyendo W_M5, L_M5, Cm y W_M7M8.
"""
from __future__ import annotations

import re
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

# lif_design lives in designs/scripts/; add it to the path so this fixture
# can be run straight from the testbench directory, like tb_ota_5t's.
import sys as _sys
from pathlib import Path as _Path
_sys.path.insert(0, str(_Path(__file__).resolve().parents[3] / "scripts"))

from lif_design import laws as L
from lif_design.spec import NeuronDesign

# .tran 1n es obligatorio: con 20n la frecuencia se infla +41% de media y hasta
# +193% (el integrador salta ciclos y los cuenta como disparos).
TSTEP_NS = 1

# El transitorio debe dar >= 5 ciclos. A frecuencias bajas 30u no basta: una
# neurona a 15 kHz tiene periodo 67us y no completa ni un ciclo.
SKIP_US = 20.0   # arranque que se descarta al medir


def _tstop_for(freq_khz: float, min_cycles: int = 8) -> float:
    """Transitorio [us] que deja min_cycles DESPUES del arranque.

    Los primeros SKIP_US no cuentan (transitorio de encendido) y measure()
    ademas descarta el primer periodo, asi que se piden 2 ciclos de mas.
    """
    if freq_khz <= 0:
        return 200.0
    return max(30.0, SKIP_US + (min_cycles + 2) * 1000.0 / freq_khz)


@dataclass
class VerifyResult:
    """Lo medido en la simulacion, frente a lo predicho."""
    ok: bool
    measured: dict[str, float] = field(default_factory=dict)
    predicted: dict[str, float] = field(default_factory=dict)
    errors_pct: dict[str, float] = field(default_factory=dict)
    status: str = ""
    netlist: str = ""
    raw_path: str = ""

    def report(self) -> str:
        lines = ["=" * 58,
                 f"VERIFICACION: {self.status}",
                 "=" * 58,
                 f"{'magnitud':<16}{'predicho':>11}{'medido':>11}{'error':>9}"]
        for k in self.predicted:
            p = self.predicted[k]
            m = self.measured.get(k)
            if m is None:
                lines.append(f"{k:<16}{p:>11.3f}{'--':>11}{'--':>9}")
                continue
            e = self.errors_pct.get(k, 0.0)
            lines.append(f"{k:<16}{p:>11.3f}{m:>11.3f}{e:>8.1f}%")
        return "\n".join(lines)


def build_netlist(params: dict[str, float], iex_na: float,
                  template: str | Path, tstop_us: float | None = None,
                  freq_hint_khz: float = 0.0) -> str:
    """Netlist SPICE del diseño, listo para ngspice -b."""
    text = Path(template).read_text(encoding="utf-8", errors="ignore")
    W = params["W_M5"]
    Lg = params["L_M5"]
    Cm = params["Cm"]
    w78 = params.get("W_M7M8", 0.22)

    if tstop_us is None:
        tstop_us = _tstop_for(freq_hint_khz)

    text = re.sub(r"^IEX 0 iin DC [\d.]+n", f"IEX 0 iin DC {iex_na:g}n",
                  text, flags=re.M)
    text = text.replace("L=50u W=1.25u", f"L={Lg:g}u W={W:g}u")
    text = re.sub(r"^C1 integration Vss [\d.]+f",
                  f"C1 integration Vss {Cm:g}f", text, flags=re.M)
    # buffer de salida (M7/M8), solo si se pidio distinto del minimo
    if abs(w78 - 0.22) > 1e-9:
        text = text.replace(
            "XM7 spike spike_neg Vdd Vdd pfet_03v3 L=0.28u W=0.22u",
            f"XM7 spike spike_neg Vdd Vdd pfet_03v3 L=0.28u W={w78:g}u")
        text = text.replace(
            "XM8 spike spike_neg GND GND nfet_03v3 L=0.28u W=0.22u",
            f"XM8 spike spike_neg GND GND nfet_03v3 L=0.28u W={w78:g}u")
    text = re.sub(r"^\.tran [\d.]+n [\d.]+u",
                  f".tran {TSTEP_NS}n {tstop_us:g}u", text, flags=re.M)
    return text


# --- medida sobre el .raw --------------------------------------------------
def _read_raw(path: str | Path) -> tuple[list[float], list[float], list[float]]:
    """(t, v_spike, v_membrana) de un .raw binario de ngspice.

    Sin numpy a proposito: son ~3 columnas y struct.unpack basta. El paquete
    de diseño no arrastra dependencias.
    """
    import struct

    data = Path(path).read_bytes()
    marker = b"Binary:\n"
    k = data.find(marker)
    if k < 0:
        raise ValueError("el .raw no tiene seccion Binary")
    header = data[:k].decode("ascii", "ignore")
    npts = int([x for x in header.splitlines()
                if "No. Points" in x][0].split(":")[1])
    nvar = int([x for x in header.splitlines()
                if "No. Variables" in x][0].split(":")[1])
    body = data[k + len(marker):]
    vals = struct.unpack(f"<{npts * nvar}d", body[:npts * nvar * 8])
    t = list(vals[0::nvar])
    sp = list(vals[1::nvar])
    vm = list(vals[2::nvar]) if nvar > 2 else []
    return t, sp, vm


def measure(raw_path: str | Path, skip_us: float = SKIP_US) -> dict[str, float]:
    """Frecuencia, Vth, swing y jitter desde el .raw."""
    t, sp, vm = _read_raw(raw_path)
    i0 = next((i for i, x in enumerate(t) if x > skip_us * 1e-6), 0)
    t, sp = t[i0:], sp[i0:]
    vm = vm[i0:] if vm else []
    if len(t) < 10:
        return {"n_cyc": 0}

    # flancos de subida del spike, con umbral a media escala
    hi, lo = max(sp), min(sp)
    mid = (hi + lo) / 2.0
    edges = [i for i in range(1, len(sp))
             if sp[i - 1] <= mid < sp[i]]
    periods = [t[edges[i + 1]] - t[edges[i]] for i in range(len(edges) - 1)]
    periods = [p for p in periods if p > 0.2e-6]
    if len(periods) > 1:
        periods = periods[1:]          # descartar el primero, aun transitorio
    out: dict[str, float] = {"n_cyc": float(len(periods))}
    if periods:
        mean = sum(periods) / len(periods)
        out["f"] = 1.0 / mean / 1e3     # kHz
        if len(periods) > 1:
            var = sum((p - mean) ** 2 for p in periods) / len(periods)
            out["jitter_pct"] = 100.0 * (var ** 0.5) / mean
        else:
            out["jitter_pct"] = 0.0
    if vm:
        out["Vth"] = max(vm)
        out["Vm_min"] = min(vm)
        out["swing"] = max(vm) - min(vm)
    out["v_out_swing"] = hi - lo
    return out


# --- verificacion completa -------------------------------------------------
def verify(design_result: NeuronDesign, iex_na: float = L.IEX_REF,
           workdir: str | Path = ".", template: str | Path | None = None,
           ngspice: str = "ngspice", timeout_s: int = 900,
           keep_files: bool = True) -> VerifyResult:
    """Simula el diseño y compara lo medido con lo predicho.

    workdir debe ser la carpeta del testbench (tb/), porque el netlist usa
    rutas relativas para el .raw.
    """
    workdir = Path(workdir)
    if template is None:
        template = workdir / "tb_lif.spice"

    p = design_result.params
    W, Lg, Cm = p["W_M5"], p["L_M5"], p["Cm"]
    f_pred = L.freq(W, Lg, iex_na)

    tag = f"verify_{W:g}_{Lg:g}_{Cm:g}_{iex_na:g}".replace(".", "p")
    raw_rel = f"{tag}.raw"
    netlist = build_netlist(p, iex_na, template, freq_hint_khz=f_pred)
    netlist = netlist.replace("tb_charac_isrc.raw", raw_rel)

    spice_path = workdir / f"{tag}.spice"
    spice_path.write_text(netlist, encoding="utf-8", newline="\n")

    res = VerifyResult(ok=False, netlist=netlist,
                       raw_path=str(workdir / raw_rel))
    res.predicted = {
        "f": round(f_pred, 1),
        "Vth": round(L.vth(W, Lg, Cm), 3),
        "swing": round(L.swing(W, Lg, Cm), 3),
    }

    try:
        subprocess.run([ngspice, "-b", spice_path.name], cwd=str(workdir),
                       capture_output=True, timeout=timeout_s, check=False)
    except FileNotFoundError:
        res.status = f"ngspice no encontrado ({ngspice})"
        return res
    except subprocess.TimeoutExpired:
        res.status = f"la simulacion supero {timeout_s} s"
        return res

    raw_file = workdir / raw_rel
    if not raw_file.exists():
        res.status = "la simulacion no genero .raw"
        return res

    res.measured = measure(raw_file)
    if not keep_files:
        spice_path.unlink(missing_ok=True)
        raw_file.unlink(missing_ok=True)

    if res.measured.get("n_cyc", 0) < 3:
        res.status = "NO OSCILA (menos de 3 ciclos)"
        return res

    for k, pv in res.predicted.items():
        mv = res.measured.get(k)
        if mv:
            res.errors_pct[k] = 100.0 * (pv - mv) / mv

    worst = max((abs(v) for v in res.errors_pct.values()), default=0.0)
    vmin = res.measured.get("Vm_min", 0.0)
    if vmin < -0.05:
        res.status = f"ANOMALO: la membrana baja a {vmin:.3f} V"
    elif res.measured.get("jitter_pct", 0) > 2.0:
        res.status = f"NO CONVERGIO (jitter {res.measured['jitter_pct']:.1f}%)"
    elif worst <= 10.0:
        res.ok = True
        res.status = f"OK (peor error {worst:.1f}%)"
    else:
        res.status = f"DESVIACION ALTA (peor error {worst:.1f}%)"
    return res
