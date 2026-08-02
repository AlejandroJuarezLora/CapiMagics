#!/bin/bash
# W de M5: variar W con L fijo, + puntos de W/L constante para distinguir hipotesis
cd /foss/repo/sch/lif/tb
mkdir -p raws_wm5; rm -f raws_wm5/*.raw
OUT=../results/sweep_wm5.csv
echo 'W_M5,L_M5,ratio_WL,Iex_nA,freq_kHz,Vm_min,Vth_V,estado' > $OUT
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
i=0
# bloque 1: L=50u fijo, variar W   |  bloque 2: W/L constante (0.025)
for par in '0.5 50u' '1.25 50u' '2.5 50u' '5.0 50u' '0.625 25u' '2.5 100u'; do
  set -- $par; w=$1; lm5=$2
  sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/'       -e "s/L=50u W=1.25u/L=$lm5 W=${w}u/"       -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'       -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_wm5/w_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|"       tb_charac.spice > /tmp/tbw.spice
  ngspice -b /tmp/tbw.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_wm5/w_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([l for l in h.split(chr(10)) if 'No. Points' in l][0].split(':')[1])
    nv=int([l for l in h.split(chr(10)) if 'No. Variables' in l][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];ie=d[:,3];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    vmn=vm[mk].min(); est='ANOMALO' if vmn<-0.05 else 'OK'
    L=float('$lm5'.replace('u','')); W=float('$w')
    print(f'$w,$lm5,{W/L:.4f},{np.abs(ie[mk]).mean()*1e9:.1f},{f:.1f},{vmn:.3f},{vm[mk].max():.3f},{est}')
except Exception as ex: print(f'$w,$lm5,,ERR,,,,')
" | tee -a $OUT
  i=$((i+1))
done
echo DONE
