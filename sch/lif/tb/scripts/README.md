# Scripts de caracterización de la neurona LIF

Todos operan sobre `../tb_charac.spice` (el testbench parametrizable, autocontenido)
generando variantes con `sed` y midiendo con **promedio multi-ciclo** sobre el `.raw`
(no `.meas` de un solo ciclo, que da errores de hasta 30% por el jitter real).

## Cómo correrlos

Dentro del contenedor, con el repo montado en `/foss/repo`:

```bash
cd /foss/repo/sch/lif/tb
bash scripts/<script>.sh
```

Los resultados van a `../results/*.csv`. Los `.raw` intermedios quedan en
`raws_*/` (gitignoreados; se pueden borrar y regenerar).

## Barridos (generan datos)

| Script | Qué mide | Salida |
|---|---|---|
| `find_vin2.sh` | mapeo Vin → Iex (calibración de la entrada) | stdout |
| `sweep_iex_robust.sh` | 12 puntos de Iex: freq + Vth + Iex | `sweep_iex_robust.csv` |
| `sweep_cm_robust.sh` | 7 puntos de Cm: freq + Vth | `sweep_cm_robust.csv` |
| `sweep_lm5_robust.sh` | 6 puntos de L_M5: freq + Vth | `sweep_lm5_robust.csv` |
| `sweep_drive.sh` | 6 anchos de M7-M8: corriente de drive | `sweep_drive.csv` |
| `sweep_cmlimit.sh` | Cm × Iex: ¿el límite depende de la corriente? | `cm_limit_map.csv` |
| `sweep_cmlimit_lm5.sh` | Cm × L_M5: ¿el límite depende de M5? | `cm_limit_lm5.csv` |

## Validaciones cruzadas (verifican ecuaciones fuera del nominal)

| Script | Qué valida | Salida |
|---|---|---|
| `crossval_freq.sh` | `f = k·Iex` en 3 configs de (L_M5, Cm) | `crossval_freq.csv` |
| `crossval_iexvin.sh` | `Iex = 169.1·(2.571−Vin)²` en 3 configs | `crossval_iexvin.csv` |
| `crossval_drive.sh` | `I_drive ≈ 85·W` en 2 configs | `crossval_drive.csv` |

## Analizadores (procesan los `.raw`)

| Script | Para qué |
|---|---|
| `analyze_robust.py` | frecuencia multi-ciclo genérica |
| `analyze_iex.py` | freq + Vth + Iex del barrido de corriente |
| `analyze_cm.py` | freq + Vth vs Cm, con test de la teoría `f ∝ 1/Cm` |
| `analyze_lm5.py` | freq + Vth vs L_M5 |
| `analyze_cmlimit.py` | detecta overshoot (Vm fuera de los rieles 0–3.3 V) |

## Notas de uso

- **`bash -lc`, no `bash -c`**: ngspice solo está en el PATH del login shell.
- El nodo de membrana se llama **`x1.integration`** en ngspice (está dentro del
  subcircuito), no `integration`.
- La corriente del espejo se lee como `@m.x1.xm6.m0[id]` (el sufijo `.m0` es
  necesario para el modelo BSIM4).
- No correr desde `/tmp` (hay un `bisect.py` residual que tapa el stdlib).

Los resultados consolidados y las ecuaciones están en
[`../../results/lif_knowledge_base.md`](../../results/lif_knowledge_base.md).
