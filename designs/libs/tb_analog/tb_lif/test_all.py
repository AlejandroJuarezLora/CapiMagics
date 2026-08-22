"""pytest entry point for the LIF neuron testbench.

Mirrors tb_ota_5t's shape: compose a netlist, run ngspice, assert on what
comes back. The reference values are the characterisation laws in
designs/scripts/lif_design, so a failure means the cell no longer behaves
like the model its dimensions were picked from.

    cd designs/libs/tb_analog/tb_lif && pytest -v
"""
import sys
from pathlib import Path

import pytest

from fixture import L, verify

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "scripts"))
from lif_design.solver import design  # noqa: E402
from lif_design.spec import NeuronSpec  # noqa: E402


TB_DIR = Path(__file__).resolve().parent

# Nominal design point — see designs/scripts/lif_design/README.md.
F_TARGET_KHZ = 500.0
IEX_NA = 100.0

# The laws fit the measured sweep to ~2% RMS. 10% leaves room for simulator
# spread without letting a real regression through.
TOL_PCT = 10.0


def _spec():
    """Single operating point: a degenerate freq_range pins one frequency.

    iex_range is left out on purpose -- giving both as zero-width ranges asks
    the solver for a gain of 0/0.
    """
    return NeuronSpec(freq_range=(F_TARGET_KHZ, F_TARGET_KHZ))


@pytest.fixture(scope="module")
def result():
    """Dimension the neuron for F_TARGET_KHZ, then simulate it once."""
    return verify(design(_spec()), iex_na=IEX_NA, workdir=TB_DIR)


def test_oscillates(result):
    """Fewer than three cycles means the membrane never really fires."""
    assert result.measured.get("n_cyc", 0) >= 3, result.status


def test_frequency(result):
    """Spike rate tracks f[kHz] = 24837 * W^-1.076 * L^-0.940 * (Iex/100nA)."""
    err = abs(result.errors_pct.get("f", 100.0))
    assert err < TOL_PCT, (
        f"freq off by {err:.1f}%: measured {result.measured.get('f')} kHz, "
        f"predicted {result.predicted.get('f')} kHz")


def test_swing(result):
    """Membrane swing tracks swing = 4.114 * W^0.951 * L^1.065 * Cm^-1.006."""
    err = abs(result.errors_pct.get("swing", 100.0))
    assert err < TOL_PCT, (
        f"swing off by {err:.1f}%: measured {result.measured.get('swing')} V, "
        f"predicted {result.predicted.get('swing')} V")


def test_membrane_stays_positive(result):
    """Vm dipping below ground means the integrator is being over-driven."""
    vmin = result.measured.get("Vm_min", 0.0)
    assert vmin > -0.05, f"membrane reaches {vmin:.3f} V"


def test_cm_above_floor():
    """Cm must clear the oscillation floor Cm_min = 8.94 * W^1.038 * L^0.700."""
    p = design(_spec()).params
    floor = L.Cm_min(p["W_M5"], p["L_M5"])
    assert p["Cm"] > floor, f"Cm {p['Cm']:.1f} fF is under the {floor:.1f} fF floor"
