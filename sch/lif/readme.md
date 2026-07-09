\# Dual-Mode CMOS LIF Neuron



Based on \[1], here is the dual-mode leaky integrate-and-fire (LIF) neuron, implemented in the gf180mcuD pdk.



!\[Fig5](fig05-topology-sky130.png)



\## How it works

The membrane node integrates an excitation current  $I\_{ex}$  on capacitance $C\_m$ and continuously leaks through $R\_{leak}$:



```math

\\tau = R\_{leak} \\cdot C\_m

```



```math

V\_m(t) \\rightarrow R\_{leak} \\cdot I\_{ex} \\quad \\text{(as } t \\rightarrow \\infty \\text{, until threshold crossing)}

```



When `V\_m` crosses the firing threshold `V\_th(lif)`, the neuron spikes and resets. Firing rate encodes input current.



One transistor (M1) is left in subthreshold — not truly off, just conducting a small diffusion current that grows exponentially with `V\_gs`:



```math

I\_d \\approx I\_0 \\cdot \\exp\\left(\\frac{V\_{gs}}{n \\cdot V\_t}\\right) \\cdot \\left(1 - \\exp\\left(-\\frac{V\_{ds}}{V\_t}\\right)\\right)

```



At nanoamp-scale `I\_d` and volt-scale `V\_ds`, `R\_leak = V\_ds/I\_d` lands naturally in the MΩ–GΩ range. The rest of the circuit (M2–M5, two inverter stages) stays in saturation, giving full-swing output with no extra amplifier.



Since `V\_ds = V\_m` in this topology, the leak resistance at the drain of M1 is:



```math

R\_{leak} = \\left| \\frac{V\_m}{I\_0 \\exp\\left(-\\dfrac{V\_{th}}{n V\_t}\\right)\\left(1 - e^{-V\_m/V\_t}\\right)} \\right|

```



`R\_leak` is therefore not constant — it depends on `V\_m` and is only piecewise-linear over the integration range, which justifies linearizing it as an average around the midpoint between reset and threshold:



```math

\\bar{R}\_{leak} \\approx \\frac{V\_{th(lif)} + V\_{reset}}{2 I\_0 \\exp\\left(-\\dfrac{V\_{th}}{n V\_t}\\right)\\left(1 - \\exp\\left(-\\dfrac{V\_{th(lif)} + V\_{reset}}{2 V\_t}\\right)\\right)}

```



This average feeds the closed-form firing-frequency model:



```math

f = \\frac{1}{\\bar{R}\_{leak} \\cdot C\_m \\cdot \\ln\\left(\\dfrac{-\\bar{R}\_{leak} I\_{ex}}{V\_{th(lif)} - \\bar{R}\_{leak} I\_{ex}}\\right)}

```



\### The three stages



!\[Fig6](fig06-stages-sky130.png)



| Stage | Devices | Function |

|---|---|---|

| (a) Integrate \& reset | M5 (subthreshold) | Charges `C\_m` via `I\_ex`; leaks via `R\_leak`; dumps charge on reset |

| (b) Threshold \& spike | M1–M2 (inverter) | Trip point = `V\_th(lif)`, the firing threshold |

| (c) Gain \& feedback reset | M3–M4 (inverter) | Full-swing spike out; feeds a reset pulse back into M1 |

| (d) Output |M6–M7 (inverter)|Spikes|



\## Schematic

`nfet\_03v3` / `pfet\_03v3` devices, `V\_dd = 3.3V`. Captured in xschem, no simulation or layout yet.



| Device | Role | Notes |

|---|---|---|

| M5 |leakage resistance (subthreshold) and reset | `𝑉\_gs` is low ⇒ `R\_leak` ; `V\_gs` is high ⇒ `reset`|

| C1 = 150 fF | `C\_m` | carried over roughly, not re-derived |

| M1–M2 inverter | LIF threshold | Inverted output signal |

| M3–M4 inverter | Spike/Reset | Reset signal |

| M6–M7 inverter | Spike | Output signal (spike) |

| I0  | `I\_ex` | max 200 nA |





\## Sizing

| Parameter | Value |

|---|---|

| `V\_dd` | 3.3 V (`\*\_03v3` devices) |

| Devices | `nfet\_03v3` / `pfet\_03v3` |

| `C\_m` | 150 fF |

| `V\_th(lif)` | 1.3 V |

| Transistor count | 7T|

| `I\_ex` | max 200 nA |

| Firing frequency range | up to 1 mHz  |

| Average `R\_leak` | 495 GOhms |

| W/L sizing (all devices) | M5=0.025, M1-M4 and M5-M7 = 0.78|





\## How to test

1\. Constant `I\_ex` → steady spike train at expected frequency

2\. Ramp/step `I\_ex` → frequency tracks input monotonically





\## 📚 References

&#x20;   - A. A. Salazar-Hernandez, V. H. Ponce-Ponce, H. Molina-Lozano, J. H. Sossa-Azuela, J. J. Ocampo-Hidalgo, Dual-Mode CMOS LIF Neuron With Subthreshold Efficiency and Saturation-Driven Robustness, IEEE Access, 2026, Volume 14, Pages 27290-27302, doi: 10.1109/ACCESS.2026.3663914

