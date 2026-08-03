# LIF characterization testbenches

Two testbenches, differing in how the cell is excited. **The current one is
`tb_charac_isrc.spice`**, since the cell takes a current input.

| file | input | status |
|---|---|---|
| `tb_charac_isrc.spice` | `IEX` straight into the membrane node | **current** |
| `tb_charac.spice` | `Vin` driving M6 (PMOS mirror) | historical |

Both are self-contained: the `neurona` subcircuit is embedded, so they do not
depend on the `.sch` files. Every script in `scripts/` patches them with `sed`.

## Why two

The cell connects to different stages, so it receives current rather than
voltage. `tb_charac_isrc.spice` reflects that and carries no M6.

The switch was checked against the earlier characterization and **does not
invalidate it**: the same operating point gives 494 kHz with M6 and 501 kHz with
an ideal source (1.4% apart). M6's output impedance was high enough — it is a
PMOS with `L = 17 µm` — to behave nearly ideally.

The law `Iex = 169.1·(2.571 − Vin)²` (RMS 0.07%) is still valid, but it now
describes a block that lives **outside** the cell. Kept as a reference for
whoever designs the input stage.

## Two things to respect when simulating

**Use `.tran 1n`, not 20n.** With a coarse step the frequency is overestimated
by **+41% on average and up to +193%**: the integrator skips cycles and counts
them as spikes. It also fabricates jitter of up to 55%.
`scripts/test_tstep.sh` demonstrates this by re-simulating at 20/5/1 ns.

**Size the transient for ≥5 cycles.** With a fixed `tstop`, a neuron at 15 kHz
(67 µs period) completes no full cycle in 30 µs and appears not to oscillate.
That produced a "current floor" that turned out not to exist.
`scripts/test_tstop.sh` verified that shortening 100 µs → 30 µs gives identical
results to 4 significant figures **when the frequency allows it**.

## Useful nodes in the `.raw`

| signal | ngspice name |
|---|---|
| membrane | `v(x1.integration)` — it lives inside the subcircuit |
| spike | `v(spike)` |
| mirror current (`tb_charac` only) | `@m.x1.xm6.m0[id]` — the `.m0` suffix is BSIM4 |

## Results

CSV files live in [`../results/`](../results/); the consolidated equations are in
[`../results/lif_knowledge_base.md`](../results/lif_knowledge_base.md).

The `raws_*/` directories are regenerable and gitignored (~376 MB total).
