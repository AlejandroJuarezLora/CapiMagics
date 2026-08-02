#!/bin/bash
# Barrido robusto de Cm: 7 puntos, multi-ciclo, dentro de rango de corriente
cd /foss/repo/sch/lif/tb
mkdir -p raws_cmr
rm -f raws_cmr/index.csv raws_cmr/*.raw
i=0
for cm in 25f 50f 75f 100f 150f 200f 300f; do
  sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/'       -e "s/^C1 integration Vss 150f/C1 integration Vss $cm/"       -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'       -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_cmr/cm_${i}.raw v(spike) v(x1.integration)|"       tb_charac.spice > /tmp/tbcm.spice
  ngspice -b /tmp/tbcm.spice >/dev/null 2>&1
  echo "$i,$cm" >> raws_cmr/index.csv
  i=$((i+1))
done
echo DONE
