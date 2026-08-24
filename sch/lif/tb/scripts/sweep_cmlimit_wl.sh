#!/bin/bash
# Cm_min(W_M5, L_M5): para cada (W,L) barre Cm y detecta donde Vm_min cruza cero
cd /foss/repo/sch/lif/tb
mkdir -p raws_cmwl; rm -f raws_cmwl/*.raw
OUT=../results/cm_limit_wl.csv
echo 'W_M5,L_M5,Cm_f,Vm_min,estado' > $OUT
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
i=0
for wl in '0.5 25u' '0.5 50u' '1.25 50u' '1.75 33u' '1.75 41u' '2.5 25u'; do
  set -- $wl; w=$1; l=$2
  for cm in 100f 150f 200f 300f 400f; do
    sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/'         -e "s/L=50u W=1.25u/L=$l W=${w}u/"         -e "s/^C1 integration Vss 150f/C1 integration Vss $cm/"         -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'         -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_cmwl/c_${i}.raw v(spike) v(x1.integration)|"         tb_charac.spice > /tmp/tbcw.spice
    ngspice -b /tmp/tbcw.spice >/dev/null 2>&1
    PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_cmwl/c_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];vm=d[:,2];mk=t>20e-6
    vmn=vm[mk].min()
    print(f'$w,$l,${cm},{vmn:.3f},{\"OK\" if vmn>=-0.05 else \"ANOMALO\"}')
except Exception as ex: print(f'$w,$l,${cm},ERR,')
" | tee -a $OUT
    i=$((i+1))
  done
done
echo DONE
