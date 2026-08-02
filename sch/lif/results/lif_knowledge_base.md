# LIF Neuron — Tabla de conocimiento (parámetros → comportamiento)

Caracterización empírica de la neurona LIF (GF180, 7T) para alimentar el sistema
de diseño por capas. Todos los datos por **simulación ngspice** con medición
robusta (promedio multi-ciclo, método del PR #10), no `.meas` de un solo ciclo.

Neurona base: `sch/lif/neurona.sch`. Nominal: Cm=150fF, L_M5=50µ, L_M6=17µ,
inversores W/L = 0.22µ/0.28µ (mínimos GF180).

## Los 3 parámetros dominantes y su efecto

### 1. Iex (corriente de excitación) — LA PALANCA PRINCIPAL

Caracterizado con 12 puntos, multi-ciclo, midiendo freq **y** Vth simultáneamente
(Cm=150f, L_M5=50µ):

| Vin (V) | Iex (nA) | freq (kHz) | jitter (%) | Vth (V) |
|---|---|---|---|---|
| 1.40 | 232.0 | 1204 | 5.3 | 2.106 |
| 1.50 | 194.0 | 1022 | 5.1 | 2.091 |
| 1.60 | 159.5 | 857  | 5.6 | 2.092 |
| 1.70 | 128.3 | 681  | 4.6 | 2.090 |
| 1.80 | 100.5 | 545  | 6.8 | 2.088 |
| 1.90 | 76.1  | 427  | 9.1 | 2.085 |
| 2.00 | 55.1  | 304  | 7.4 | 2.077 |
| 2.10 | 37.5  | 208  | 7.6 | 2.083 |
| 2.20 | 23.3  | 127  | 7.9 | 2.073 |
| 2.30 | 12.5  | 66   | 1.7 | 2.078 |
| 2.40 | 5.2   | 29   | —   | 2.063 |
| 2.50 | 1.4   | NO OSCILA | — | — |

**Ecuación 1 — Iex vs freq (lineal, R² = 0.99925):**

```math
f[\text{kHz}] = 5.215 \cdot I_{ex}[\text{nA}] + 11.7 \qquad \text{(solo para } L_{M5}=50\mu m\text{)}
```

Residuos ±18 kHz sin tendencia sistemática.

⚠️ **Esta es la curva del punto nominal, NO una ley universal.** La validación
cruzada (ver sección propia) mostró que la ganancia depende de L_M5. La forma
general está más abajo.

**Ecuación 2 — Vin vs Iex (ley de saturación del MOSFET, R² = 1.00000):**

```math
I_{ex}[\text{nA}] = 169.1 \cdot (2.571 - V_{in})^2
```

Error máximo **0.06 nA** en 11 puntos. No es solo un ajuste: es la ley cuadrática
`I ∝ (Vgs−Vt)²` del pfet M6 en **saturación** (no subumbral, como supusimos).
El parámetro 2.571 V es el voltaje de corte — **validado independientemente**: a
Vin=2.5 V medimos Iex=1.4 nA y la neurona ya no oscila.

✅ **VALIDADA CRUZADAMENTE — la única ecuación totalmente robusta.** Re-ajustada
en 3 configuraciones distintas (15 puntos):

| Config | L_M5 | Cm | ecuación ajustada | R² |
|---|---|---|---|---|
| A | 25 µm | 150 fF | `Iex = 169.06·(2.5711 − Vin)²` | 1.000000 |
| B | 50 µm | 150 fF | `Iex = 169.09·(2.5712 − Vin)²` | 1.000000 |
| C | 35 µm | 200 fF | `Iex = 169.06·(2.5711 − Vin)²` | 1.000000 |
| original | 50 µm | 150 fF | `Iex = 169.10·(2.5710 − Vin)²` | 1.000000 |

Los coeficientes coinciden hasta la **cuarta cifra** y la dispersión de corriente
entre configuraciones es **< 0.03%** a igual Vin.

**Por qué es robusta:** M6 es un transistor aislado — su corriente la determinan
su geometría (L=17µ, W=0.22µ) y su Vgs. Ni L_M5 ni Cm están en ese camino, y M6
se mantiene en saturación pese a que el swing del nodo de membrana cambie.

⚠️ Un ajuste lineal a estos datos da R²=0.958 y uno exponencial R²=0.773 — ambos
inadecuados. La relación es **cuadrática**.

**Iex es la única perilla ortogonal al threshold:** Iex varía **45×** (232→5 nA) y
Vth solo se mueve **2.06%** (2.106→2.063 V). Comparar con L_M5 (mueve Vth 26%) y
Cm (76%). Por eso **frecuencia→Iex es la palanca limpia**.

Rango de diseño: Iex ≤ 200 nA (Vin ≥ ~1.45 V). Corte total en Vin ≈ 2.571 V.

### 2. Cm (capacitor de membrana) — DOS REGÍMENES + afecta el threshold

Re-caracterizado con 7 puntos, multi-ciclo, a Iex≈100nA (Vin=1.8), L_M5=50µ:

| Cm (fF) | freq (kHz) | jitter (%) | ciclos | **Vth_lif (V)** |
|---|---|---|---|---|
| 25  | 1302 | 3.2  | 126 | 3.771 |
| 50  | 832  | 2.8  | 80  | 3.555 |
| 75  | 599  | 4.0  | 58  | 2.890 |
| 100 | 524  | 7.6  | 50  | 2.488 |
| 150 | 545  | 6.8  | 53  | 2.088 (nominal) |
| 200 | 555  | 9.2  | 54  | 1.882 |
| 300 | 565  | 10.6 | 54  | 1.686 |

**NO existe una ecuación `f(Cm)` — y la razón es física, no falta de datos.**

Se probaron varios modelos contra los 7 puntos y **todos fallan**:

| Modelo | R² |
|---|---|
| `T = a·Cm + b` (carga + delay fijo) | 0.40 |
| `f = 1/(a·Cm + b)` | 0.66 |
| `T = a·(Cm·Vth) + b` (carga hasta Vth) | 0.51 |

La causa: **el período es no-monótono**. Tiene un máximo en Cm=100f y luego decrece:

| Cm (fF) | 25 | 50 | 75 | **100** | 150 | 200 | 300 |
|---|---|---|---|---|---|---|---|
| T (µs) | 0.77 | 1.20 | 1.67 | **1.91** | 1.83 | 1.80 | 1.77 |

Ningún modelo monótono puede ajustar eso.

**La explicación (inspección de la forma de onda del nodo de membrana):**

| Cm | Vm mínimo | Vm máximo | swing |
|---|---|---|---|
| 25f  | **−0.797 V** | **3.765 V** | 4.56 V |
| 100f | −0.585 V | 2.457 V | 3.04 V |
| 300f | +0.664 V | 1.682 V | 1.02 V |

A Cm bajo, el nodo de membrana **oscila muy fuera de los rieles** (−0.8 V a
+3.77 V, con Vdd=3.3 V). Es **overshoot capacitivo**: el pulso de reset acopla al
nodo y lo patea fuera del rango válido. El circuito **no opera en su régimen de
diseño**.

Esto confirma que el `Vth = 3.771 V > Vdd` medido a 25f es overshoot real, no un
artefacto de medición.

**Los datos mezclan dos físicas distintas:**
- **Cm < 100f — RÉGIMEN ANÓMALO.** Overshoot capacitivo, el circuito opera fuera
  de especificación. Los números de frecuencia ahí no son confiables para diseño.
- **Cm ≥ 100f — RÉGIMEN NORMAL.** Frecuencia plana: Cm varía **3×** (100→300f) y
  f solo cambia **7.4%** (524→565 kHz), dentro del jitter.

Por eso no hay fórmula única: sería como buscar una ecuación que describa un
circuito funcionando y otro mal-operando a la vez.

⚠️ **Cm es la perilla más acoplada al threshold**: mueve Vth un **76%**
(2.49 V @100f → 1.69 V @300f). Comparar con L_M5 (26%) e Iex (2%).

**Regla de diseño: Cm ≥ 150f, y no usarlo como perilla.** En esa zona la
frecuencia es insensible a Cm (usa Iex para eso) y el circuito opera bien.
Default 150f. **Cm < 150f está fuera del rango válido de operación.**

#### El límite de Cm NO depende de la corriente (verificado)

Mapa del undershoot (Vm mínimo) a 4 corrientes distintas — criterio: Vm debe
mantenerse dentro de los rieles (0 a Vdd=3.3 V):

| Cm (fF) | @194 nA | @100 nA | @37 nA | @12 nA | estado |
|---|---|---|---|---|---|
| 50  | −0.810 | −0.809 | −0.810 | −0.808 | ❌ anómalo |
| 75  | −0.772 | −0.776 | −0.769 | −0.739 | ❌ anómalo |
| 100 | −0.619 | −0.638 | −0.640 | −0.653 | ❌ anómalo |
| 125 | −0.374 | −0.395 | −0.294 | −0.258 | ❌ anómalo |
| **150** | −0.031 | −0.050 | −0.013 | +0.007 | ✅ límite |
| 200 | +0.327 | +0.319 | +0.306 | +0.342 | ✅ OK |

**La frontera está en el mismo lugar (entre 125f y 150f) para las 4 corrientes**,
con Iex variando **16×** (12→194 nA). El undershoot depende **solo de Cm**, no de
la corriente — confirma que es acoplamiento capacitivo del pulso de reset, un
mecanismo independiente de la señal de entrada.

**Ecuación del undershoot** (zona de transición 75–200 fF, R² = 0.982):

```math
V_{m,min}[V] = 0.00919 \cdot C_m[fF] - 1.4813
```

Extrapolando a `Vm_min = 0` da Cm ≈ 161 fF, pero a 150 fF el undershoot medido es
de solo −22 mV (despreciable). **Cm ≥ 150 fF es el límite práctico.**

⚠️ Un modelo de acoplamiento puro `Vm_min = A − Q/Cm` **no ajusta** (R²=0.71) y
predice 195 fF, inconsistente con lo medido. La dependencia es lineal en Cm, no
inversa — el mecanismo no es carga inyectada constante.

#### El límite SÍ depende de L_M5 (ley del límite)

Barrido Cm × L_M5 (15 puntos, Iex≈100 nA). El `Cm_min` se obtiene de dónde
`Vm_min` cruza cero en cada bloque:

| L_M5 (µm) | recta del undershoot | **Cm_min (fF)** |
|---|---|---|
| 25 | `Vm_min = 0.00823·Cm − 0.8833` | **107** |
| 35 | `Vm_min = 0.01008·Cm − 1.2698` | **126** |
| 50 | `Vm_min = 0.00919·Cm − 1.4813` | **161** |

**Ley del límite (R² = 0.996):**

```math
C_{m,min}[fF] = 2.166 \cdot L_{M5}[\mu m] + 52.06
```

Los tres puntos ajustan con error < 2 fF.

**Interpretación física de los dos términos:**
- `2.166·L_M5` → capacitancia parásita del transistor de reset M5, que crece con
  su longitud (es quien inyecta la carga al conmutar).
- `52.06 fF` → parásitos fijos del nodo (otros transistores, ruteo), independientes
  de M5.

⚠️ **Cm y L_M5 están acoplados por esta restricción.** Al elegir L_M5 para fijar el
threshold, quedas obligado a un Cm mínimo:

| Si eliges... | Vth resultante | Cm mínimo obligado |
|---|---|---|
| L_M5 = 25 µm | 1.61 V | ≥ 107 fF |
| L_M5 = 35 µm | 1.79 V | ≥ 126 fF |
| L_M5 = 50 µm | 2.09 V | ≥ 161 fF |

**Reproducibilidad verificada:** el bloque de L_M5=50µ de este barrido reprodujo
los valores del barrido Cm×Iex (medido con otro script) **con coincidencia exacta
hasta el tercer decimal** en los 5 puntos — validación cruzada no planificada que
confirma que toda la caracterización es reproducible.

### 3. L_M5 (longitud del transistor de fuga → R_leak) — CONTROLA EL THRESHOLD

Re-caracterizado con 6 puntos y medición multi-ciclo (antes solo 2 puntos con
`.meas` de un ciclo). Medido a Iex≈100nA (Vin=1.8), Cm=150f:

| L_M5 (µm) | freq (kHz) | jitter (%) | ciclos | **Vth_lif (V)** |
|---|---|---|---|---|
| 25 | 1280 | 20.9 | 126 | 1.608 |
| 30 | 965  | 12.6 | 95  | 1.695 |
| 35 | 863  | 8.2  | 84  | 1.791 |
| 40 | 808  | 23.4 | 79  | 1.884 |
| 45 | 522  | 19.8 | 50  | 1.988 |
| 50 | 545  | 6.8  | 53  | 2.088 (nominal) |
| ≥55 | —   | —    | —   | NO OSCILA (límite duro) |

**Hallazgo principal — L_M5 fija el threshold:**

```math
V_{th(lif)} = 0.01927 \cdot L_{M5}[\mu m] + 1.1198   \qquad (R^2 = 0.9992,\ \text{solo a } C_m=150\,fF)
```

⚠️ **Esta recta es la sección a Cm=150 fF, NO una ley de una variable.** La
validación cruzada mostró que Cm también mueve el threshold. Ver la superficie
validada abajo.

**Sobre la frecuencia — NO es una ley inversa limpia:** si `f ∝ 1/L_M5` fuera
cierto, `f·L` sería constante; en los datos varía **31%** (23,477 a 32,336), con
jitter alto (7–23%) y no-monotonía entre 45µ y 50µ. La frecuencia sí decrece con
L_M5, pero de forma **indirecta** (L_M5 sube Vth_lif, y Vth_lif entra en la
ecuación de frecuencia), no por una relación directa.

#### Threshold como superficie Vth(L_M5, Cm) — versión validada

Ajustada sobre los **9 puntos válidos** (zona OK, sin overshoot) del barrido
Cm × L_M5. Se compararon 4 modelos con **leave-one-out cross-validation** para
descartar sobreajuste:

| Modelo | R² | RMSE_LOO | params |
|---|---|---|---|
| plano `(L, Cm)` | 0.97911 | 0.0430 V | 3 |
| `L/Cm` | 0.96229 | 0.0411 V | 2 |
| `L/Cm + L + 1/Cm` | 0.99869 | 0.0116 V | 4 |
| **`L/Cm + 1/Cm`** | **0.99868** | **0.0087 V** | **3** ← mejor |

El modelo de 3 parámetros gana: mismo R² que el de 4 pero **mejor generalización**
(LOO más bajo). El término `·L_M5` suelto era despreciable (coef. 0.00032).

```math
V_{th(lif)}[V] = 2.893 \cdot \frac{L_{M5}[\mu m]}{C_m[fF]} - \frac{21.28}{C_m[fF]} + 1.2606
```

**R² = 0.99868**, todos los puntos con error < 0.8%.

**Forma física** — reagrupando:

```math
V_{th} = 1.2606 + \frac{2.893 \cdot L_{M5} - 21.28}{C_m}
```

Es un **threshold base de 1.26 V más un término `Q/C`**: la carga que el reset
inyecta al nodo, dividida por el capacitor. La carga `Q = 2.893·L_M5 − 21.28`
crece con el tamaño de M5 — consistente con el mecanismo de acoplamiento
capacitivo que ya identificamos en el análisis del límite de Cm.

Verificación contra la ley antigua: a L_M5=35µ y Cm=200f, la recta de una variable
predecía 1.795 V y se midió **1.663 V** (7% de error). La superficie predice
**1.661 V** — error de 0.1%.

Regla: **L_M5 es la perilla del THRESHOLD, no de la frecuencia.** Para fijar
frecuencia usar Iex. El límite duro sigue: >55µ el circuito deja de disparar.
Nominal 50µ opera en el borde (Vth≈2.09V); para margen usar ~40µ (Vth≈1.88V).

### 3b. W de M5 — PARÁMETRO DE PRIMER ORDEN (era el hueco de la caracterización)

Nunca se había variado (nominal W=1.25 µm). Resulta tener un efecto **comparable
o mayor que L_M5**. Medido a Iex≈100 nA, Cm=150 fF, L_M5=50 µm:

| W_M5 (µm) | freq (kHz) | Vth (V) | Vm_min (V) | estado |
|---|---|---|---|---|
| 0.5 | 1358.8 | 1.680 | +0.781 | ✅ holgado |
| **1.25** | **545.3** | **2.088** | **−0.050** | ✅ nominal (en el borde) |
| 2.5 | 307.5 | 2.560 | −0.745 | ❌ anómalo |
| 5.0 | 278.4 | **3.251** | −0.789 | ❌ crítico (Vth≈Vdd) |

**Relaciones:**

```math
V_{th} \approx 0.3387 \cdot W_{M5}[\mu m] + 1.6114 \qquad (R^2 = 0.981,\ L_{M5}=50\mu m)
```

`f ∝ 1/W_M5` ajusta con R²=0.972, pero **satura arriba de 2.5 µm**: de W=2.5 a
5.0 µm (el doble) la frecuencia solo baja 10% (307→278 kHz), cuando debería
partirse a la mitad.

⚠️ **A W=5 µm el threshold llega a 3.251 V con Vdd=3.3 V** — prácticamente en el
riel. El circuito está al borde de no poder dispararse; de ahí la saturación.

⚠️ **W_M5 también mueve el límite de Cm.** A W=2.5 µm el circuito ya es anómalo
con Cm=150 fF (que es válido en el nominal). La ley `Cm_min = 2.166·L_M5 + 52.06`
está **incompleta**: le falta el término de W.

**Rango útil: W_M5 ≤ ~1.25 µm.** El nominal está en el borde; W=0.5 µm opera
holgado (Vth=1.68 V, sin overshoot).

#### El parámetro NO es W/L — L y W actúan por separado

Test directo: dos configuraciones con **el mismo ratio W/L = 0.025**:

| W_M5 | L_M5 | W/L | freq | Vth |
|---|---|---|---|---|
| 1.25 µm | 50 µm | 0.025 | 545.3 kHz | 2.088 V |
| 0.625 µm | 25 µm | 0.025 | **2530.9 kHz** | 1.485 V |

**4.6× de diferencia en frecuencia con idéntico ratio.** El comportamiento no
depende de W/L.

**Implicación:** las leyes en función de L_M5 (threshold, límite de Cm, ganancia)
**están bien parametrizadas** — no eran una simplificación del ratio. Pero les
falta la dimensión W.

**Interpretación física:** si el mecanismo dominante fuera la resistencia de fuga,
mandaría W/L (la ley del MOSFET). Que no sea así confirma que **domina el
acoplamiento capacitivo** — los parásitos escalan con el **área** W×L, no con el
cociente. Consistente con todo lo encontrado sobre el overshoot del reset.

**Límite de simulación:** con L_M5 ≥ 55 µm ngspice falla (`incomplete or empty
netlist`) independientemente de W — verificado con W=1.25/L=100 y W=2.5/L=60
(fallan) vs W=2.5/L=50 (funciona). Es un límite en L, no en la combinación.

### 3c. Superficies 2D W_M5 × L_M5 (barrido de 16 puntos)

Grilla 4×4 (W = 0.5/1.0/1.75/2.5 µm × L = 25/33/41/50 µm), a Iex≈100 nA y
**Cm=200 fF**. Solo **11 de 16** puntos quedaron en régimen válido — con W y L
grandes, 200 fF ya no basta para evitar el overshoot.

| freq (kHz) | L=25µ | L=33µ | L=41µ | L=50µ |
|---|---|---|---|---|
| **W=0.5µ** | 3038 | 2022 | 1889 | 1257 |
| **W=1.0µ** | 1609 | 972 | 958 | 695 |
| **W=1.75µ** | 907 | 623 | 390 ⚠️ | 384 ⚠️ |
| **W=2.5µ** | 714 | 479 ⚠️ | 274 ⚠️ | 259 ⚠️ |

| Vth (V) | L=25µ | L=33µ | L=41µ | L=50µ |
|---|---|---|---|---|
| **W=0.5µ** | 1.413 | 1.467 | 1.520 | 1.583 |
| **W=1.0µ** | 1.491 | 1.585 | 1.683 | 1.793 |
| **W=1.75µ** | 1.577 | 1.722 | 1.875 ⚠️ | 2.055 ⚠️ |
| **W=2.5µ** | 1.638 | 1.832 ⚠️ | 2.016 ⚠️ | 2.260 ⚠️ |

⚠️ = régimen anómalo (Vm sale de los rieles con Cm=200 fF)

#### Frecuencia: ley inversa del área (R² = 0.978)

```math
f \propto \frac{1}{W_{M5} \cdot L_{M5}}
```

Ajuste de potencia (R² = 0.981):

```math
f[\text{kHz}] = 105183 \cdot W_{M5}^{-1.008} \cdot L_{M5}^{-1.304}
```

Los exponentes son casi −1 para W y −1.3 para L: **el área manda, con L pesando
algo más**. Error típico ±10%, con desviaciones hasta 20% en la zona anómala.

⚠️ **Modelos lineales en (W, L) fallan** para la frecuencia (R² ≤ 0.83, LOO > 420
kHz). La relación es **inversa**, no lineal — probar la forma funcional correcta
fue clave.

#### Threshold: superficie con término de interacción (R² = 0.9937)

```math
V_{th}[V] = -0.11481 \cdot W + 0.00280 \cdot L + 0.008966 \cdot W \cdot L + 1.3001
```

*(a Cm=200 fF; W en µm, L en µm)*

Comparación de modelos con leave-one-out:

| Modelo | R² | LOO |
|---|---|---|
| área `W·L` | 0.920 | 0.073 V |
| `W` y `L` separados | 0.919 | 0.089 V |
| **`W`, `L`, `W·L`** | **0.9937** | **0.025 V** |
| `√(W·L)` | 0.890 | 0.089 V |

**El término de interacción `W·L` es imprescindible** — sin él, ningún modelo pasa
de R²=0.92. Ni el área sola ni los efectos separados bastan.

#### El área NO predice el overshoot

Test directo: puntos de área comparable con resultados opuestos:

| W | L | área (µm²) | Vm_min | estado |
|---|---|---|---|---|
| 2.5 µm | 25 µm | 62.5 | **+0.142** | ✅ OK |
| 1.75 µm | 41 µm | 71.8 | −0.248 | ❌ anómalo |

Un punto de **menor** área falla mientras uno de mayor área funciona. Para el
overshoot, **L pesa más que W** (al revés que para la frecuencia).

Superficie del undershoot a Cm=200 fF (R² = 0.969):

```math
V_{m,min}[V] = -0.1607 \cdot W - 0.00107 \cdot L - 0.01341 \cdot W \cdot L + 1.3207
```

**Consecuencia para el límite de Cm:** la ley `Cm_min = 2.166·L_M5 + 52.06`
(medida solo a W=1.25 µm) **subestima** el límite para W mayores. Con W=1.75 µm y
L=41 µm, ni siquiera 200 fF alcanza, cuando esa ley predice ~141 fF.

#### Cm_min(W, L) — barrido dedicado (30 puntos)

Para cada combinación (W, L) se barrió Cm ∈ {100, 150, 200, 300, 400} fF y se
interpoló dónde `Vm_min` cruza cero:

| W_M5 | L_M5 | área (µm²) | **Cm_min** | ley vieja (solo L) | error de la vieja |
|---|---|---|---|---|---|
| 0.5 µm | 25 µm | 12.5 | **< 100 fF** | 106 fF | (fuera de grilla) |
| 0.5 µm | 50 µm | 25.0 | **< 100 fF** | 160 fF | (fuera de grilla) |
| 1.25 µm | 50 µm | 62.5 | **157 fF** | 160 fF | −3 fF ✓ |
| 1.75 µm | 33 µm | 57.8 | **166 fF** | 124 fF | **+42 fF** |
| 1.75 µm | 41 µm | 71.8 | **246 fF** | 141 fF | **+105 fF** |
| 2.5 µm | 25 µm | 62.5 | **182 fF** | 106 fF | **+76 fF** |

**La ley anterior solo acierta en W=1.25 µm** (su punto de medición). Fuera de ahí
subestima hasta 105 fF — un error que llevaría a diseños en régimen anómalo.

**Modelo preliminar (4 puntos, superado):** `Cm_min ≈ 6.230·(W·L) − 208.7`
(R²=0.826, LOO=42 fF). Ver la versión definitiva abajo.

#### Cm_min(W, L) — ley definitiva (12 puntos, búsqueda binaria)

Se repitió el barrido con **búsqueda binaria** del límite (rango 30–500 fF,
tolerancia ~10 fF) sobre 12 combinaciones, cubriendo el rango que antes se
escapaba por debajo de 100 fF:

| W_M5 (µm) | L_M5 (µm) | **Cm_min (fF)** | predicho | error |
|---|---|---|---|---|
| 0.5 | 25 | 44 | 41 | +5.8% |
| 0.5 | 41 | 59 | 59 | +0.6% |
| 0.75 | 33 | 73 | 77 | −5.1% |
| 1.0 | 25 | 88 | 85 | +3.3% |
| 1.0 | 41 | 117 | 120 | −2.9% |
| 1.0 | 50 | 132 | 138 | −4.8% |
| 1.25 | 33 | 132 | 130 | +1.3% |
| 1.5 | 25 | 117 | 130 | −10.8% |
| 1.5 | 41 | 206 | 183 | +11.0% |
| 1.75 | 50 | 235 | 247 | −5.2% |
| 2.0 | 33 | 206 | 212 | −3.0% |
| 2.5 | 41 | 337 | 311 | +7.6% |

**Ley (R² = 0.980, LOO = 15.4 fF):**

```math
C_{m,min}[fF] = 8.94 \cdot W_{M5}^{1.038} \cdot L_{M5}^{0.700}
```

Exponentes ≈ **1.04 para W** y **0.70 para L**: W pesa más que L, pero ninguno es
cuadrático. Errores dentro de ±11%, la mayoría bajo 5%.

**Validada por extrapolación** — dos puntos predichos antes de medirse:

| Punto | predicho | medido | error |
|---|---|---|---|
| W=2.0 µm, L=33 µm | 207 fF | 206 fF | **0.6%** |
| W=2.5 µm, L=41 µm | 301 fF | 337 fF | 10.7% |

⚠️ **Advertencia metodológica — un LOO bajo no protege contra extrapolación.**
Con los primeros 9 puntos (todos W ≤ 1.5 µm), el modelo `Cm_min ∝ W²·L` parecía
el mejor (LOO = 10.3 fF, mejor que el área con 16.0). Al añadir el punto de
W=1.75 µm, ese modelo **falló por 31%** y su LOO se disparó a 28.3 fF. El
cuadrático en W era un artefacto del rango limitado de datos. La ley de potencia
libre, en cambio, extrapoló correctamente.

**Comparación con las leyes previas** (a los puntos donde discrepan):

| W, L | medido | ley definitiva | `2.166·L + 52` | `6.23·(W·L) − 209` |
|---|---|---|---|---|
| 0.5, 25 | 44 | 41 | 106 | (negativo) |
| 1.5, 41 | 206 | 183 | 141 | 174 |
| 2.5, 41 | 337 | 311 | 141 | 431 |

La ley que solo usaba L subestima gravemente para W grande (141 vs 337 fF), y la
del área sobreestima en el extremo. **Usar la ley de potencia.**

### 4. W de M7-M8 (inversor de salida) — CORRIENTE DE DRIVE DEL SPIKE

No afecta la frecuencia; controla cuánta corriente puede entregar el nodo `spike`
(su capacidad de manejar carga / fan-out). Escala **lineal** con W: ~85 µA/µm.

| W M7-M8 (µm) | pull-up (µA) | pull-down (µA) |
|---|---|---|
| 0.22 (nominal) | 23.7 | 23.3 |
| 1.0  | 84   | ~84  |
| 2.0  | 170  | ~170 |
| 4.0  | 344  | 354  |
| 8.0  | 687  | ~690 |

Hallazgos:
- Drive proporcional a W (~85 µA/µm). Duplicar W duplica la corriente.
- **Inversor balanceado**: pull-up (pfet M7) ≈ pull-down (nfet M8) al mismo W →
  spike simétrico (sube y baja igual de rápido). Dato específico de GF180 a L=0.28µ.
- Actual W=0.22µ da ~23.5 µA: la entrada de una neurona es ~100-200 nA, así que
  la salida entrega ~100-200× esa corriente (no es cuello de botella para fan-out
  moderado).

Regla: **para el arreglo, si el spike alimenta muchas cargas/rutas largas, subir W
de M7-M8 proporcional al fan-out** (~85 µA/µm disponibles). Default 0.22µ sirve para
cargas ligeras.

✅ **VALIDADA CRUZADAMENTE.** Re-medida con L_M5=25µ (mitad del nominal):

| W (µm) | @L_M5=25µ | @L_M5=50µ | diferencia |
|---|---|---|---|
| 0.22 | 23.92 µA | 23.70 µA | +0.93% |
| 1.0 | 84.27 µA | 84.20 µA | +0.08% |
| 4.0 | 342.66 µA | 343.75 µA | −0.32% |

Ganancia: **84.97 vs 85.07 µA/µm** — diferencia < 1%. El drive es **independiente
del resto del circuito**: M7-M8 forman la etapa de salida, aislada del lazo de
integración.

## Jerarquía de control (para el sistema por capas)

```
FRECUENCIA:
  Iex   : ████████████  palanca principal (monótona, amplio rango)
  Cm    : ██████        solo por debajo de 100f; ≥100f es plano (saturado)
  L_M5  : ▒▒            efecto indirecto y sucio (via Vth) — NO usar como perilla

THRESHOLD (Vth_lif):
  L_M5+Cm: ██████████   Vth = 2.893·L_M5/Cm − 21.28/Cm + 1.2606  (R²=0.999, superficie)
  Cm    : ████████      también lo mueve fuerte (3.77V @25f → 1.69V @300f)

DRIVE DE SALIDA:
  W M7-M8 : ██████████  I_drive ≈ 85·W  (lineal, ortogonal a todo lo demás)
```

Matriz de acoplamiento (medida, no supuesta):

| Perilla | frecuencia | threshold | notas |
|---|---|---|---|
| **Iex** (via Vin) | ✅ principal, lineal | **solo 2%** (45× de Iex) | **ortogonal** ✓ |
| **L_M5** | indirecto/sucio | ✅ principal, 26% | R²=0.999 |
| **W_M5** | fuerte (`∝1/W`, satura >2.5µ) | fuerte, **94%** (0.5→5µ) | **primer orden** |
| **Cm** | sí, si <100f | sí, **76%** | muy acoplado |
| **W M7-M8** | no | no | ortogonal ✓ |

⚠️ **W_M5 y L_M5 actúan por separado, no como W/L** (verificado: mismo ratio da
4.6× de diferencia en frecuencia).

Solo **Iex** y **W** son perillas limpias. Cm es la más acoplada (mueve Vth 76%).

Orden de ajuste **correcto** (el acoplamiento Cm↔L_M5 lo determina):

⚠️ **Hay circularidad**: Vth depende de (L_M5, Cm); el límite de Cm depende de
L_M5. Se resuelve con una iteración corta (converge en 2–3 pasos):

```python
# 1. semilla: elegir L_M5 con la recta a Cm=150f
L_M5 = (Vth_obj - 1.1198)/0.01927
for _ in range(3):
    # 2. Cm minimo que admite ese (W_M5, L_M5), con margen del 20%
    Cm = 1.2 * 8.94 * W_M5**1.038 * L_M5**0.700
    # 3. corregir L_M5 con la SUPERFICIE, ahora que se conoce Cm
    #    Vth = 2.893*L/Cm - 21.28/Cm + 1.2606  ->  despejar L
    L_M5 = (Cm*(Vth_obj - 1.2606) + 21.28)/2.893
# 4. Iex desde la frecuencia (ecuacion general, cualquier L_M5)
Iex = f_obj / (363.6/L_M5 - 2.08)
Vin = 2.571 - sqrt(Iex/169.1)
# 5. W de M7-M8 segun fan-out
W = I_drive/85
```

**L_M5 aparece en los pasos 1, 2, 3 y 4** — es el parámetro más transversal del
diseño. Por eso conviene fijarlo primero y dejar que el resto se derive.

⚠️ El paso 2 **debe ir después del 1**: no se puede fijar Cm sin conocer L_M5,
porque el límite de validez de Cm depende de él. (Una versión anterior de esta
tabla decía "fijar Cm primero" — era incorrecto.)

## Reglas para defaults y ajuste (lógica del sistema)

```python
# DEFAULTS (si el usuario no especifica)
DEFAULT_CM   = "150f"   # zona plana, predecible
DEFAULT_LM5  = "40u"    # con margen del limite (~50u)
DEFAULT_IEX  = 100      # nA, mitad del rango

# AJUSTE (dado un target de frecuencia)
def design_for_freq(f_target_kHz):
    # 1. Iex es la palanca: interpolar del mapa
    #    ~55nA→300, ~100nA→545, ~160nA→857, ~212nA→1113 kHz  (a Cm=150f)
    iex = interpolar_iex(f_target_kHz)
    if iex > 200: raise "frecuencia fuera de rango con Cm=150f"
    # 2. si se necesita mas rango, bajar Cm a 50f (modo rapido, ~2x)
    # 3. L_M5 como ajuste fino inverso (solo dentro de 25-50u)
    return {"iex": iex, "cm": DEFAULT_CM, "lm5": DEFAULT_LM5}

# LIMITES DUROS (validacion)
#   Iex   : 5 - 200 nA
#   L_M5  : 25 - 50 um  (fuera -> no oscila)
#   Cm    : 50f - 200f+ (>150f no aporta)
```

## Validación cruzada — la ganancia de modulación depende de L_M5

Todas las ecuaciones anteriores se midieron variando **una** cosa con el resto en
nominal. Para verificar si se sostienen fuera de ese punto, se barrió Iex en tres
configuraciones distintas (12 puntos), respetando la restricción `Cm ≥ 2.166·L_M5+52`:

| Config | L_M5 | Cm | Vth medido | curva de modulación | R² |
|---|---|---|---|---|---|
| A | 25 µm | 150 fF | 1.607 V | `f = 12.436·Iex − 11.9` | 0.99996 |
| C | 35 µm | 200 fF | 1.663 V | `f = 8.361·Iex + 12.4` | 0.99987 |
| B | 50 µm | 150 fF | 2.087 V | `f = 5.157·Iex + 21.6` | 0.99930 |

**Lo que se sostiene:** la **linealidad** `f ∝ Iex` es estructural — R² ≈ 0.999 en
las tres configuraciones. La neurona **siempre modula** correctamente (más
corriente → más frecuencia, monótono y lineal). Esa es su función esencial y se
mantiene en todo el espacio de diseño explorado.

**Lo que cambia:** la **ganancia de modulación** varía 2.4× entre configuraciones
(12.44 vs 5.16 kHz/nA).

### Qué determina la ganancia (se probaron 5 modelos)

| Modelo | R² |
|---|---|
| `k ∝ 1/(Cm·Vth)` (física de carga del capacitor) | 0.52 |
| `k ∝ 1/Vth` | 0.48 |
| `k ∝ 1/Cm` | **−0.09** |
| `k ∝ 1/(L_M5·Cm)` | 0.85 |
| **`k ∝ 1/L_M5`** | **0.965** |

**Ecuación unificada (R² = 0.99982):**

```math
f[\text{kHz}] = \left(\frac{363.6}{L_{M5}[\mu m]} - 2.08\right) \cdot I_{ex}[\text{nA}]
```

Las tres configuraciones ajustan con error < 0.7%.

**Hallazgos contraintuitivos:**

1. **`k ∝ 1/Cm` da R² negativo** — Cm prácticamente no influye en la ganancia,
   pese a que la física de carga del capacitor sugeriría `f = Iex/(Cm·Vth)`.
   Coherente con que en la zona válida (Cm ≥ límite) la frecuencia es insensible a Cm.

2. **El modelo físico ingenuo `f ∝ Iex/(Cm·Vth)` falla** (R²=0.52). La ganancia la
   domina L_M5 directamente, no a través del threshold ni del capacitor.

3. **Vth depende de L_M5 *y* de Cm.** La config C (L_M5=35µ) dio Vth=1.663 V,
   pero la ley `Vth = 0.0193·L_M5 + 1.1198` (medida a Cm=150f) predice 1.795 V.
   La diferencia viene de usar Cm=200f. **Esa ley es la sección a Cm=150 fF**, no
   una relación de dos variables.

### Reproducibilidad (validación no planificada)

El bloque B de este barrido reprodujo el barrido de Iex original (script distinto,
12 puntos): **3 de 4 puntos exactos hasta el primer decimal**, el cuarto con 0.5%
de diferencia (dentro del jitter del circuito). Junto con los 5/5 exactos del
barrido Cm×L_M5, confirma que la caracterización completa es reproducible.

## Modelo teórico calibrado (cierre del sesgo +6.8% del PR #10)

El modelo closed-form del paper, con los parámetros de diseño, tenía un sesgo
sistemático de **+6.8%** (todos los puntos por encima de la teoría). Calibrado
contra los 10 puntos del PR #10:

```math
f = \frac{1}{\bar{R}_{leak} \cdot C_m \cdot \left| \ln\left(\frac{-\bar{R}_{leak} I_{ex}}{V_{th} - \bar{R}_{leak} I_{ex}}\right) \right|}
```

| Parámetro | Valor de diseño | **Calibrado** | Efecto en el error |
|---|---|---|---|
| R̄_leak | 495.3 GΩ | 495.3 GΩ (sin cambio) | — |
| V_th | 1.305 V | **1.2396 V** | +6.8% → **+1.46%** |
| Cm | 150 fF | 150 fF | — |

**Hallazgos de la calibración:**

1. **El culpable es Vth, no R_leak.** Ajustar solo Vth (1.305→1.2396 V, apenas
   65 mV) baja el error de +6.8% a +1.46%. Ajustar solo R_leak (495→990 GΩ) **no
   mejora nada** (+6.81%).

2. **El modelo es insensible a R̄_leak.** R aparece multiplicando y dentro del
   logaritmo; los efectos se compensan. Un ajuste sin restricciones llega a dar
   R negativa (−4692 GΩ) con el mismo error — matemáticamente válido, físicamente
   absurdo. **Mantener R en su valor de diseño y no intentar ajustarlo.**

3. **El Vth medido (pico de Vm) ≠ el Vth del modelo.** Usar el Vth que medimos
   empíricamente (2.088 V a L_M5=50µ) empeora el error a **+70.9%**. Son cantidades
   distintas: el modelo usa el trip point efectivo del inversor, no el pico del
   nodo de membrana.

**Error residual:** +1.46% medio, pero no uniforme — va de +5.1% (a 10 nA) a −1.1%
(a 200 nA). Queda una tendencia sistemática en los extremos: el modelo calibrado
es bueno en el centro del rango, algo optimista a corriente baja.

## Resumen: estado de validación de cada ecuación

Todas las ecuaciones fueron probadas en configuraciones distintas a las de su
medición original. Resultado:

| Ecuación | Validación cruzada | Veredicto |
|---|---|---|
| `Iex = 169.1·(2.571 − Vin)²` | 3 configs, 15 pts | ✅ **robusta** — coef. idénticos (<0.03%) |
| `I_drive ≈ 85·W` | 2 configs, 6 pts | ✅ **robusta** — ganancia 84.97 vs 85.07 |
| `f = (363.6/L_M5 − 2.08)·Iex` | 3 configs, 12 pts | ✅ **general** (reemplaza la del nominal) |
| `Vth = 2.893·L_M5/Cm − 21.28/Cm + 1.2606` | 9 pts + LOO | ✅ **superficie** (reemplaza la recta) |
| `Cm_min = 2.166·L_M5 + 52.06` | 2 ejes (Iex, L_M5) | ✅ validada |
| ~~`f = 5.215·Iex + 11.7`~~ | — | ⚠️ solo vale a L_M5=50µ |
| ~~`Vth = 0.0193·L_M5 + 1.1198`~~ | — | ⚠️ solo vale a Cm=150f |
| ~~`f ∝ 1/L_M5`~~ | — | ❌ descartada |

**Patrón que emerge:** las ecuaciones de los **bloques periféricos** (espejo M6,
buffer de salida M7-M8) son robustas porque están aislados del lazo. Las del
**núcleo de integración** (frecuencia, threshold, límite de Cm) están acopladas
entre sí y requieren la forma multivariable.

**Reproducibilidad global:** entre barridos independientes (distintos scripts,
distintos momentos) se obtuvieron **más de 20 puntos coincidentes** hasta el
primer decimal, con desviaciones solo dentro del jitter propio del circuito.

## Rango de operación validado

- Frecuencia alcanzable: ~300 kHz (55nA) a ~1.6 MHz (212nA/50f).
- Jitter ciclo-a-ciclo real: 2–9% (comportamiento del circuito, no ruido de sim).

## Pendiente / a extender

- Caracterizar W/L de los inversores (afectan Vth_lif y velocidad) — Abraham dijo
  que son fijos, pero mapearlos daria otro grado de libertad.
- **Re-ajustar las leyes incluyendo W_M5**: threshold, limite de Cm y ganancia de
  frecuencia estan parametrizadas solo en L_M5, pero W_M5 tiene efecto de primer
  orden. Haria falta un barrido 2D (W_M5 x L_M5) para las superficies completas.
- Consumo de potencia vs parametros (para el trade-off frecuencia/energia).
- ~~Calibrar el +6.8% del PR #10~~ ✅ hecho (Vth = 1.2396 V, error → +1.46%).
- Entender la tendencia residual del modelo calibrado (+5% a 10nA, −1% a 200nA).
- Iex vs threshold: no medimos si Iex mueve Vth (las otras perillas sí lo hacen).
- Efecto de temperatura y corners del PDK (todo esto es typical @ nominal).
