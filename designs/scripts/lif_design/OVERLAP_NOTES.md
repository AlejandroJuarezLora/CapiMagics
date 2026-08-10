# How far two glayout blocks can overlap

Notes from measuring, not from the manual. Every number here came from
generating the cells and checking the result.

Reference block: `nmos(pdk, width=1.08, length=35.42, with_substrate_tap=False,
with_dummy=False, with_tie=False)` on GF180MCU — 42.32 × 9.21 µm.

## The bbox is mostly empty

```
bbox      -21.160 … 21.160
nplus     -18.540 … 18.540   <- outermost layer
poly2     -17.710 … 17.710
comp      -18.310 … 18.310
                              margin: 2.62 µm per side
```

A glayout FET carries ~2.6 µm of empty bbox on each side. Two blocks placed
edge to edge therefore waste ~5.2 µm of channel that is already there, which
is why overlapping the bboxes is not automatically wrong.

The neuron in `layout/lif/neurona.ipynb` overlaps its blocks by 3.22 µm — well
inside the padding — but still reports 31 DRC violations: CO.2a x14 and V1.2a
x14 (contact and via spacing), NW.3 x2, DN.3. Overlapping the padding is fine;
what it costs is the clearance around contacts and vias near the edges.

## What actually limits the overlap

Two blocks were placed at overlaps from 0 to 8 µm and the DRC run on each.

**Use the deck glayout ships**, `src/glayout/pdk/gf180_mapped/gf180mcu.drc`,
not the one under `$PDK_ROOT/libs.tech/klayout/tech/drc/`. The latter returns
an empty report for these layouts — zero items even for a GDS with six known
violations — so it reads as "clean" when it has evaluated nothing.

```
overlap   DRC items   rules                            comp regions
 0.00 µm      5       DN.3, DF.8_3.3V x4                    2
 5.00 µm      4       DN.3, DF.8 x2, NP.2                   2
 5.50 µm      4       DN.3, DF.8 x2, DF.3a_3.3V             2
 5.80 µm     19       + M1.2a x11, M2.2a x5                 1
 8.00 µm      6       + CO.10                               1
```

Two things to read here:

**The bare block already violates five rules at zero overlap.** `DN.3` and
`DF.8_3.3V` come from placing an `nmos` with no tap ring and no substrate
contact — they are not caused by the overlap and do not move with it.

**The overlap limit is 5.5 µm.** That is where `DF.3a_3.3V` appears, the
minimum comp-to-comp spacing (0.28 µm): the two diffusions have closed to
0.20 µm. Just past it, at 5.8 µm, metal1 and metal2 start colliding (11 + 5
violations) and the two comp regions merge into one — the devices stop being
two transistors.

This matches the geometric prediction: 2 × 2.62 µm of bbox padding = 5.24 µm
before the active layers meet.

## Practical rule

```
max_overlap = 2 × (bbox padding of the layer that reaches furthest out)
```

Measure the padding per block rather than assuming it: it changes with the
parameters below.

## Block width is not W

`multiplier()` builds the finger pitch from the PDK rules:

```python
poly_spacing = 2·rule("poly","mcon").min_separation + rule("mcon").width
poly_spacing = max(sd_via_x_dim, poly_spacing)     # sd_via_x_dim scales with rmult
poly_spacing += met1_min_separation  if length < met1_min_separation
```

so the same W lands at very different widths:

| variant | X | Y |
|---|---|---|
| nominal | 42.32 | 9.21 |
| fingers=2 | 78.30 | 9.21 |
| fingers=4 | 150.26 | 9.21 |
| with_dummy=True | 117.20 | 9.21 |
| with_tie=True | 44.28 | 11.18 |
| sd_rmult=2 | 42.32 | 10.21 |

Fingers **expand** in X, they do not compact. `with_dummy` nearly triples the
width. This is the flip side of the electrical result: fingers move frequency
by ≤0.40% (inside simulation noise) but move area by +85% to +255%, so the
choice belongs entirely to the layout — and the floorplanner must take the
measured bbox as input rather than deriving it from W.

## Parameters worth knowing

From `multiplier()`'s signature, these change the outline:

```
sd_route_extension    extends the source/drain connections outward
gate_route_extension  extends the gate connection outward
sd_rmult              thickens s/d metal (grew Y from 9.21 to 10.21)
dummy                 adds dummy active regions on both sides
```

`sd_route_extension` and `gate_route_extension` are the interesting pair for
a floorplanner: instead of leaving a gap and routing across it afterwards, the
FET itself can be asked to reach into the channel.
