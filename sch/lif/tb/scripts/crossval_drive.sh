#!/bin/bash
# Validacion cruzada de I_drive ~ 85*W en 2 configuraciones distintas
cd /foss/repo/sch/lif/tb
OUT=../results/crossval_drive.csv
echo 'config,L_M5,Cm,W_out,i_pullup_uA,i_pulldown_uA' > $OUT
for cfg in 'A 25u 150f' 'B 50u 150f'; do
  set -- $cfg; name=$1; lm5=$2; cmv=$3
  for w in 0.22 1.0 4.0; do
    sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/'         -e "s/L=50u W=1.25u/L=$lm5 W=1.25u/"         -e "s/^C1 integration Vss 150f/C1 integration Vss $cmv/"         -e "/^XM7/s/W=0.22u/W=${w}u/"         -e "/^XM8/s/W=0.22u/W=${w}u/"         -e 's/save v(spike) @m.x1.xm6.m0\[id\]/save @m.x1.xm7.m0[id] @m.x1.xm8.m0[id]/'         -e 's|meas tran period.*|meas tran ipu MAX @m.x1.xm7.m0[id] FROM=20u TO=50u|'         -e '/meas tran iex_avg/a meas tran ipd MAX @m.x1.xm8.m0[id] FROM=20u TO=50u'         -e '/meas tran iex_avg/d'         -e 's|write tb_charac.raw.*|write /tmp/dv.raw @m.x1.xm7.m0[id]|'         tb_charac.spice > /tmp/tbdv.spice
    out=$(ngspice -b /tmp/tbdv.spice 2>&1)
    pu=$(echo "$out" | grep -iE 'ipu *=' | grep -oE '[-0-9.]+e[-+][0-9]+' | head -1)
    pd=$(echo "$out" | grep -iE 'ipd *=' | grep -oE '[-0-9.]+e[-+][0-9]+' | head -1)
    if [ -n "$pu" ]; then
      echo "$name,$lm5,$cmv,$w,$(python3 -c "print(round(abs($pu)*1e6,2))"),$(python3 -c "print(round(abs($pd)*1e6,2))" 2>/dev/null || echo '')" | tee -a $OUT
    else
      echo "$name,$lm5,$cmv,$w,ERR," | tee -a $OUT
    fi
  done
done
echo DONE
