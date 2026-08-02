#!/bin/bash
# Validacion cruzada: f = 5.215*Iex + 11.7 se sostiene fuera del nominal?
cd /foss/repo/sch/lif/tb
mkdir -p raws_cv
rm -f raws_cv/*.raw
OUT=../results/crossval_freq.csv
echo 'config,L_M5,Cm,Vin,Iex_nA,freq_kHz,Vth_V' > $OUT
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
i=0
# config: L_M5 Cm  (respetando Cm >= 2.166*L_M5+52)
for cfg in 'A 25u 150f' 'B 50u 150f' 'C 35u 200f'; do
  set -- $cfg; name=$1; lm5=$2; cmv=$3
  for vin in 1.5 1.7 1.9 2.1; do
    sed -e "s/^V2 Vin 0 1.0985/V2 Vin 0 $vin/"         -e "s/L=50u W=1.25u/L=$lm5 W=1.25u/"         -e "s/^C1 integration Vss 150f/C1 integration Vss $cmv/"         -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'         -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_cv/cv_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|"         tb_charac.spice > /tmp/tbcv.spice
    ngspice -b /tmp/tbcv.spice >/dev/null 2>&1
    PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_cv/cv_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([l for l in h.split(chr(10)) if 'No. Points' in l][0].split(':')[1])
    nv=int([l for l in h.split(chr(10)) if 'No. Variables' in l][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];ie=d[:,3];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    print(f'$name,$lm5,$cmv,$vin,{np.abs(ie[mk]).mean()*1e9:.1f},{f:.1f},{vm[mk].max():.3f}')
except Exception as ex: print(f'$name,$lm5,$cmv,$vin,ERR,,')
" | tee -a $OUT
    i=$((i+1))
  done
done
echo DONE
