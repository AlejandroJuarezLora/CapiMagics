#!/bin/bash
# Validacion cruzada de Iex = 169.1*(2.571-Vin)^2 en 3 configuraciones
cd /foss/repo/sch/lif/tb
mkdir -p raws_cv2; rm -f raws_cv2/*.raw
OUT=../results/crossval_iexvin.csv
echo 'config,L_M5,Cm,Vin,Iex_nA' > $OUT
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
i=0
for cfg in 'A 25u 150f' 'B 50u 150f' 'C 35u 200f'; do
  set -- $cfg; name=$1; lm5=$2; cmv=$3
  for vin in 1.5 1.7 1.9 2.1 2.3; do
    sed -e "s/^V2 Vin 0 1.0985/V2 Vin 0 $vin/"         -e "s/L=50u W=1.25u/L=$lm5 W=1.25u/"         -e "s/^C1 integration Vss 150f/C1 integration Vss $cmv/"         -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_cv2/i_${i}.raw @m.x1.xm6.m0[id]|"         tb_charac.spice > /tmp/tbi2.spice
    ngspice -b /tmp/tbi2.spice >/dev/null 2>&1
    PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_cv2/i_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([l for l in h.split(chr(10)) if 'No. Points' in l][0].split(':')[1])
    nv=int([l for l in h.split(chr(10)) if 'No. Variables' in l][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0]; ie=d[:,1]; mk=t>20e-6
    print(f'$name,$lm5,$cmv,$vin,{np.abs(ie[mk]).mean()*1e9:.2f}')
except Exception as e: print(f'$name,$lm5,$cmv,$vin,ERR')
" | tee -a $OUT
    i=$((i+1))
  done
done
echo DONE
