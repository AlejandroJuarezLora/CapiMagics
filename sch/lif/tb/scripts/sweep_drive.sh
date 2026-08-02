#!/bin/bash
cd /foss/repo/sch/lif/tb
echo 'W_out_um,i_pullup_uA,i_pulldown_uA' > sweep_drive.csv
# barrer W de M7(pfet) y M8(nfet) juntos. Nominal 0.22u
for w in 0.22 0.5 1.0 2.0 4.0 8.0; do
  # cambiar W SOLO en M7 y M8 (lineas XM7 y XM8)
  sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/'       -e "/^XM7/s/W=0.22u/W=${w}u/"       -e "/^XM8/s/W=0.22u/W=${w}u/"       -e 's|save v(spike) @m.x1.xm6.m0\[id\]|save @m.x1.xm7.m0[id] @m.x1.xm8.m0[id]|'       -e 's|meas tran period.*|meas tran i_pu MAX @m.x1.xm7.m0[id] FROM=20u TO=50u|'       -e '/meas tran iex_avg/a meas tran i_pd MIN @m.x1.xm8.m0[id] FROM=20u TO=50u'       -e '/meas tran iex_avg/d'       -e 's|write tb_charac.raw.*|write /tmp/d.raw @m.x1.xm7.m0[id]|'       tb_charac.spice > /tmp/tbd.spice
  out=$(ngspice -b /tmp/tbd.spice 2>&1)
  ipu=$(echo "$out" | grep -iE 'i_pu *=' | grep -oE '[-0-9.]+e[-+][0-9]+' | head -1)
  ipd=$(echo "$out" | grep -iE 'i_pd *=' | grep -oE '[-0-9.]+e[-+][0-9]+' | head -1)
  if [ -n "$ipu" ]; then
    puA=$(python3 -c "print(round(abs($ipu)*1e6,2))")
    pdA=$(python3 -c "print(round(abs($ipd)*1e6,2))" 2>/dev/null || echo '?')
    echo "$w,$puA,$pdA" >> sweep_drive.csv
    echo "W=${w}u -> pull-up=${puA}uA pull-down=${pdA}uA"
  else
    echo "$w,FAIL," >> sweep_drive.csv
    echo "W=${w}u -> FALLO"
  fi
done
echo DONE
