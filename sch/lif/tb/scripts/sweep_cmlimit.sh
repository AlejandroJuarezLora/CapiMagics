#!/bin/bash
# Mapa del limite: Cm x Iex, guardando Vm para detectar overshoot fuera de rieles
cd /foss/repo/sch/lif/tb
mkdir -p raws_lim
rm -f raws_lim/index.csv raws_lim/*.raw
i=0
for vin in 1.5 1.8 2.1 2.3; do
  for cm in 50f 75f 100f 125f 150f 200f; do
    sed -e "s/^V2 Vin 0 1.0985/V2 Vin 0 $vin/"         -e "s/^C1 integration Vss 150f/C1 integration Vss $cm/"         -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'         -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_lim/p_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|"         tb_charac.spice > /tmp/tbl2.spice
    ngspice -b /tmp/tbl2.spice >/dev/null 2>&1
    echo "$i,$vin,$cm" >> raws_lim/index.csv
    i=$((i+1))
  done
done
echo DONE
