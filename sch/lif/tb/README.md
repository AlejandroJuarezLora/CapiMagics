# Testbenches de caracterización del LIF

Dos testbenches, según cómo entra la excitación. **El vigente es
`tb_charac_isrc.spice`**, porque la celda usa entrada de corriente.

| archivo | entrada | estado |
|---|---|---|
| `tb_charac_isrc.spice` | `IEX` directo al nodo de membrana | **vigente** |
| `tb_charac.spice` | `Vin` sobre M6 (espejo PMOS) | histórico |

Ambos son autocontenidos: llevan el subcircuito `neurona` embebido, así que no
dependen de los `.sch`. Modificarlos con `sed` es lo que hacen todos los
scripts de `scripts/`.

## Por qué hay dos

La celda se conectará a distintas etapas, así que recibe corriente, no tensión.
`tb_charac_isrc.spice` refleja eso: no lleva M6.

Se comprobó que el cambio **no invalida la caracterización previa**: el mismo
punto da 494 kHz con M6 y 501 kHz con fuente ideal (1.4%). La `ro` de M6 era lo
bastante alta (es un PMOS de `L=17 µm`) como para comportarse casi ideal.

La ley `Iex = 169.1·(2.571 − Vin)²` (RMS 0.07%) sigue siendo válida, pero
describe un bloque que ahora vive **fuera** de la celda. Queda como referencia
para quien diseñe la etapa de entrada.

## Dos cosas que hay que respetar al simular

**Paso `.tran 1n`, no 20n.** Con paso grueso la frecuencia se sobreestima
**+41% de media y hasta +193%**: el integrador salta ciclos y los cuenta como
disparos. También genera jitter aparente de hasta 55% que no existe.
`scripts/test_tstep.sh` lo demuestra re-simulando a 20/5/1 ns.

**Transitorio suficiente para ≥5 ciclos.** Con `tstop` fijo, una neurona a
15 kHz (periodo 67 µs) no completa ni un ciclo en 30 µs y parece que no oscila.
De ahí salió un "piso de corriente" que resultó inexistente.
`scripts/test_tstop.sh` verificó que acortar de 100 a 30 µs da resultados
idénticos a 4 cifras **cuando la frecuencia lo permite**.

## Nodos útiles en el `.raw`

| señal | nombre en ngspice |
|---|---|
| membrana | `v(x1.integration)` — está dentro del subcircuito |
| spike | `v(spike)` |
| corriente del espejo (solo `tb_charac`) | `@m.x1.xm6.m0[id]` — el sufijo `.m0` es de BSIM4 |

## Resultados

Los CSV están en [`../results/`](../results/) y las ecuaciones consolidadas en
[`../results/lif_knowledge_base.md`](../results/lif_knowledge_base.md).

Los `raws_*/` son regenerables y están gitignoreados (~376 MB en total).
