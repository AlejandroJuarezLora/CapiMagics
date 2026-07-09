# Dual-Mode CMOS LIF Neuron

Based on [1], here is the dual-mode leaky integrate-and-fire (LIF) neuron, implemented in the gf180mcuD pdk.

![Fig5](fig05-topology-sky130.png)

## How it works
The membrane node integrates an excitation current `I_ex` on capacitance `C_m` and continuously leaks through `R_leak`:

```math
\tau = R_{leak} \cdot C_m
```

```math
V_m(t) \rightarrow R_{leak} \cdot I_{ex} \quad \text{(as } t \rightarrow \infty \text{, until threshold crossing)}
```

When `V_m` crosses the firing threshold `V_th(lif)`, the neuron spikes and resets. Firing rate encodes input current.

One transistor (M1) is left in subthreshold — not truly off, just conducting a small diffusion current that grows exponentially with `V_gs`:

```math
I_d \approx I_0 \cdot \exp\left(\frac{V_{gs}}{n \cdot V_t}\right) \cdot \left(1 - \exp\left(-\frac{V_{ds}}{V_t}\right)\right)
```

At nanoamp-scale `I_d` and volt-scale `V_ds`, `R_leak = V_ds/I_d` lands naturally in the MΩ–GΩ range. The rest of the circuit (M2–M5, two inverter stages) stays in saturation, giving full-swing output with no extra amplifier.

Since `V_ds = V_m` in this topology, the leak resistance at the drain of M1 is:

```math
R_{leak} = \left| \frac{V_m}{I_0 \exp\left(-\dfrac{V_{th}}{n V_t}\right)\left(1 - e^{-V_m/V_t}\right)} \right|
```

`R_leak` is therefore not constant — it depends on `V_m` and is only piecewise-linear over the integration range, which justifies linearizing it as an average around the midpoint between reset and threshold:

```math
\bar{R}_{leak} \approx \frac{V_{th(lif)} + V_{reset}}{2 I_0 \exp\left(-\dfrac{V_{th}}{n V_t}\right)\left(1 - \exp\left(-\dfrac{V_{th(lif)} + V_{reset}}{2 V_t}\right)\right)}
```

This average feeds the closed-form firing-frequency model:

```math
f = \frac{1}{\bar{R}_{leak} \cdot C_m \cdot \ln\left(\dfrac{-\bar{R}_{leak} I_{ex}}{V_{th(lif)} - \bar{R}_{leak} I_{ex}}\right)}
```

### The three stages

![Fig6](fig06-stages-sky130.png)

| Stage | Devices | Function |
|---|---|---|
| (a) Integrate & reset | M1 (subthreshold) | Charges `C_m` via `I_ex`; leaks via `R_leak`; dumps charge on reset |
| (b) Threshold & spike | M2–M3 (inverter) | Trip point = `V_th(lif)`, the firing threshold |
| (c) Gain & feedback reset | M4–M5 (inverter) | Full-swing spike out; feeds a reset pulse back into M1 |

A 6th transistor M6 isolates the current source and doubles as a tuning knob — sweeping its gate voltage sweeps `I_ex`, which is how firing frequency is characterized across a range without an external variable source.

## Schematic
`nfet_03v3` / `pfet_03v3` devices, `V_dd = 3.3V`. Captured in xschem, no simulation or layout yet.

| Device | Role | Notes |
|---|---|---|
| M5, gate→GND | M1-equivalent (subthreshold leak) | `V_gs≈0` → subthreshold by construction |
| C1 = 150 fF | `C_m` | carried over roughly, not re-derived |
| M1–M2 inverter | M2–M3-equivalent (threshold/spike) | trip point not characterized yet |
| M3–M4 inverter | M4–M5-equivalent (gain/reset) | — |
| I0 = 200 nA fixed | `I_ex` | no tuning transistor yet |

- [ ] Insert exported schematic once stable
- [ ] Add a tuning transistor for `I_ex`, or keep it fixed

## Sizing
| Parameter | Value |
|---|---|
| `V_dd` | 3.3 V (`*_03v3` devices) |
| Devices | `nfet_03v3` / `pfet_03v3` |
| `C_m` | 150 fF, not re-derived |
| `V_th(lif)` | not characterized |
| Transistor count | 5T, no tuning transistor yet |
| `I_ex` | fixed 200 nA |
| Firing frequency range | not simulated |
| Average `R_leak` | not characterized |
| W/L sizing (all devices) | not derived |

- [ ] Extract `nfet_03v3` subthreshold params (`I_0`, `n`, `V_t`) from
      `sm141064.ngspice` in the PDK
- [ ] Derive M1-equivalent W/L and inverter trip point from the firing-frequency model above
- [ ] Target frequency range

## Layout & results
| Metric | Value |
|---|---|
| Active area | not laid out |
| DRC | not run |
| LVS | not run — use magic, not KLayout (unreliable for this team's 2025 SpikCore run) |
| Schematic vs. post-layout frequency | not simulated |
| Energy per spike | not simulated |
| Average power | not simulated |
| Frequency vs. theoretical model | not simulated |
| Ramp-input response | not simulated |

- [ ] KLayout, GF180MCU design rules, DRC clean
- [ ] Transient waveform (`V_m`, `R_leak(t)`, `V_out`)
- [ ] Ramp-input response
- [ ] Firing frequency vs. `I_ex`, simulated vs. theoretical model
- [ ] Energy and power vs. frequency
- [ ] PEX and post-layout re-simulation

## Known limitations
- [ ] Charge injection from M1's gate-drain parasitic during reset pulls `V_m` negative,
      clamped around −0.7V by the drain-substrate junction. An explicit `C_m` mitigates
      this — not yet re-verified for this layout.

## How to test
1. Constant `I_ex` → steady spike train at expected frequency
2. Ramp/step `I_ex` → frequency tracks input monotonically
3. Sweep `I_ex` → compare against the theoretical model

## 📚 References
    - A. A. Salazar-Hernandez, V. H. Ponce-Ponce, H. Molina-Lozano, J. H. Sossa-Azuela, J. J. Ocampo-Hidalgo, Dual-Mode CMOS LIF Neuron With Subthreshold Efficiency and Saturation-Driven Robustness, IEEE Access, 2026, Volume 14, Pages 27290-27302, doi: 10.1109/ACCESS.2026.3663914
