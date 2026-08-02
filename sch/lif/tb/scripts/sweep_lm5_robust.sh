#!/bin/bash
# Barrido robusto L_M5: 6 puntos, guarda .raw con spike + Vm (x1.integration)
cd /foss/repo/sch/lif/tb
mkdir -p raws_lm5r
rm -f raws_lm5r/index.csv raws_lm5r/*.raw
i=0
for lm5 in 25u 30u 35u 40u 45u 50u; do
  sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/'       -e "s/L=50u W=1.25u/L=$lm5 W=1.25u/"       -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'       -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_lm5r/lm5_${i}.raw v(spike) v(x1.integration)|"       tb_charac.spice > /tmp/tbl.spice
  ngspice -b /tmp/tbl.spice >/dev/null 2>&1
  echo "$i,$lm5" >> raws_lm5r/index.csv
  i=$((i+1))
done
echo DONE
