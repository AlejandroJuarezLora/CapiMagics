# LIF characterization scripts

Each script patches a testbench with `sed` and measures the resulting `.raw`
using **multi-cycle period averaging** — not a single-cycle `.meas`.

Scripts named `*_isrc` use `../tb_charac_isrc.spice` (current input, the current
topology); the rest use `../tb_charac.spice` (voltage input through M6,
historical).

> ## ⚠️ Use a 1 ns timestep, not 20 ns
>
> Scripts predating `sweep_3d_fine.sh` use `.tran 20n`, which **overestimates
> frequency by +41% on average and up to +193%**: the integrator skips cycles
> and counts them as spikes. It also fabricates jitter of up to 55%.
>
> `test_tstep.sh` demonstrates the effect (same circuit at 20/5/1 ns). New
> sweeps must use `.tran 1n` and flag any point with jitter > 2% as `NOCONV`.
>
> Cost: `.tran 1n` produces 100k points per simulation (~3.2 MB per `.raw`,
> ~20× slower). Worth it — fits go from LOO 8.5% to 3.1%.

## Running them

Inside the container, with the repo mounted at `/foss/repo`:

```bash
cd /foss/repo/sch/lif/tb
bash scripts/<script>.sh
```

Results go to `../results/*.csv`. Intermediate `.raw` files land in `raws_*/`
(gitignored — delete and regenerate freely). Most sweeps are **resumable**: they
skip points already present in the CSV.

## Sweeps — voltage input (historical)

| Script | Measures | Output |
|---|---|---|
| `find_vin2.sh` | Vin → Iex mapping | stdout |
| `sweep_iex_robust.sh` | 12 Iex points: freq + Vth + Iex | `sweep_iex_robust.csv` |
| `sweep_cm_robust.sh` | 7 Cm points: freq + Vth | `sweep_cm_robust.csv` |
| `sweep_lm5_robust.sh` | 6 L_M5 points | `sweep_lm5_robust.csv` |
| `sweep_drive.sh` | 6 M7-M8 widths: drive current | `sweep_drive.csv` |
| `sweep_cmlimit.sh` | Cm × Iex: does the limit depend on current? | `cm_limit_map.csv` |
| `sweep_cmlimit_lm5.sh` | Cm × L_M5 | `cm_limit_lm5.csv` |
| `sweep_3d_wlcm.sh` | W × L × Cm at 20 ns — ⚠️ biased data | `sweep_3d_wlcm.csv` |
| **`sweep_3d_fine.sh`** | **W × L × Cm at 1 ns — the good one** | `sweep_3d_fine.csv` |
| `sweep_extremes.sh` | operating boundaries at the edges | `sweep_extremes.csv` |
| `verify_laws.sh` | 18 points outside the fitting grid | `verify_laws.csv` |
| `validate_feasibility.sh` | the (f, Vth) map against simulation | `validate_feasibility.csv` |

## Sweeps — current input (`tb_charac_isrc.spice`)

The cell takes a current input, so these do not depend on `Vin` or M6. They
define the current contract.

| Script | Measures | Output |
|---|---|---|
| `sweep_gain_isrc.sh` | modulation gain `k(W,L)` of `f = k·Iex` | `sweep_gain_isrc.csv` |
| `sweep_drive_load_isrc.sh` | load the output stage can drive | `sweep_drive_load_isrc.csv` |
| `sweep_zsource.sh` | sensitivity to source impedance | `sweep_zsource.csv` |
| `sweep_iexwindow.sh` | `Iex` ceiling (turns out to be a period limit) | `sweep_iexwindow.csv` |
| `sweep_iexmin.sh` | `Iex` floor — turned out not to exist | `sweep_iexmin.csv` |
| `sweep_f0.sh` | line intercept — turned out to be zero | `sweep_f0.csv` |

## Cross-validation

| Script | Validates | Output |
|---|---|---|
| `crossval_freq.sh` | `f = k·Iex` across 3 (L_M5, Cm) configs | `crossval_freq.csv` |
| `crossval_iexvin.sh` | `Iex = 169.1·(2.571−Vin)²` across 3 configs | `crossval_iexvin.csv` |
| `crossval_drive.sh` | `I_drive ≈ 85·W` across 2 configs | `crossval_drive.csv` |

## Numerical checks

| Script | Checks |
|---|---|
| `test_tstep.sh` | jitter and `f` at 20/5/1 ns across 5 configs |
| `test_tstop.sh` | whether shortening the transient changes the result |
| `bench_par.sh` | thread vs process scaling |
| `refit_3d.py` | refits f/Vth/swing including W_M5, with LOO |

**Do not parallelize.** `bench_par.sh` measured that ngspice already uses 7.3 of
8 cores with a single process. Two in parallel push each simulation from ~100 s
to >660 s through cache contention. Run sweeps serially.

## Analyzers

| Script | Purpose |
|---|---|
| `analyze_robust.py` | generic multi-cycle frequency |
| `analyze_iex.py` | freq + Vth + Iex from the current sweep |
| `analyze_cm.py` | freq + Vth vs Cm |
| `analyze_lm5.py` | freq + Vth vs L_M5 |
| `analyze_cmlimit.py` | detects overshoot (Vm outside 0–3.3 V) |

## Gotchas

- **Use `bash -lc`, not `bash -c`**: ngspice is only on the login shell's PATH.
  Without it, sweeps silently produce zero `.raw` files.
- The membrane node is **`x1.integration`** in ngspice (it is inside the
  subcircuit), not `integration`.
- Mirror current reads as `@m.x1.xm6.m0[id]` — the `.m0` suffix is required for
  the BSIM4 model.
- Do not run from `/tmp` (a stray `bisect.py` shadows the stdlib).

Consolidated results and equations:
[`../../results/lif_knowledge_base.md`](../../results/lif_knowledge_base.md).
