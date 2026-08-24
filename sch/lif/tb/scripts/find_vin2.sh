#!/bin/bash
cd /foss/repo/sch/lif/tb
echo 'Vin,Iex_nA'
for vin in 1.2 1.4 1.6 1.8 2.0 2.2 2.4; do
  sed "s/^V2 Vin 0 1.0985/V2 Vin 0 $vin/" tb_charac.spice > /tmp/tb_v2.spice
  out=$(ngspice -b /tmp/tb_v2.spice 2>/dev/null)
  iex=$(echo "$out" | grep -iE 'iex_avg *=' | grep -oE '[0-9.]+e[-+][0-9]+' | head -1)
  [ -n "$iex" ] && echo "$vin,$(python3 -c "print(round($iex*1e9,1))")"
done
echo DONE
