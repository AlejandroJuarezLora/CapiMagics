#!/bin/bash
# Barrido denso de Iex (via Vin): freq + Vth + Iex medido, multi-ciclo
cd /foss/repo/sch/lif/tb
mkdir -p raws_iexr
rm -f raws_iexr/index.csv raws_iexr/*.raw
i=0
for vin in 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.10 2.20 2.30 2.40 2.50; do
  sed -e "s/^V2 Vin 0 1.0985/V2 Vin 0 $vin/"       -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'       -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_iexr/iex_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|"       tb_charac.spice > /tmp/tbi.spice
  ngspice -b /tmp/tbi.spice >/dev/null 2>&1
  echo "$i,$vin" >> raws_iexr/index.csv
  i=$((i+1))
done
echo DONE
