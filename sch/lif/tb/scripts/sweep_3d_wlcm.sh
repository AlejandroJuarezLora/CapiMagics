#!/bin/bash
# Barrido 3D W_M5 x L_M5 x Cm para reajustar f(W,L,Cm,Iex) y Vth(W,L,Cm)
# incorporando W_M5, que las leyes previas fijaban en 1.25u.
#
# La grilla de Cm se escoge por encima de Cm_min = 8.94*W^1.038*L^0.700 en cada
# (W,L) para que ningun punto caiga en el regimen anomalo (Vm fuera de rieles).
# Iex fija (Vin=1.8) por ser ortogonal al threshold.
cd /foss/repo/sch/lif/tb
mkdir -p raws_3d; rm -f raws_3d/*.raw
OUT=../results/sweep_3d_wlcm.csv
echo 'W_M5,L_M5,Cm_f,Cm_min_pred,Iex_nA,freq_kHz,Vth_V,Vm_min,estado' > $OUT
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
i=0
for w in 0.5 1.0 1.75 2.5; do
  for l in 25 41; do
    # Cm_min predicho por la ley, redondeado hacia arriba
    CMIN=$(PYTHONPATH= LD_LIBRARY_PATH= $PY -c "print(int(8.94*($w**1.038)*($l**0.700))+1)")
    # 4 valores de Cm: 1.3x, 1.8x, 2.6x, 4.0x el limite
    for mult in 1.3 1.8 2.6 4.0; do
      CM=$(PYTHONPATH= LD_LIBRARY_PATH= $PY -c "print(int($CMIN*$mult))")
      sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/' \
          -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
          -e "s/^C1 integration Vss 150f/C1 integration Vss ${CM}f/" \
          -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
          -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_3d/p_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
          tb_charac.spice > /tmp/tb3d_${i}.spice
      ngspice -b /tmp/tb3d_${i}.spice >/dev/null 2>&1
      PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_3d/p_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];ie=d[:,3];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    vmn=vm[mk].min(); est='ANOMALO' if vmn<-0.05 else 'OK'
    print(f'$w,$l,$CM,$CMIN,{np.abs(ie[mk]).mean()*1e9:.1f},{f:.1f},{vm[mk].max():.3f},{vmn:.3f},{est}')
except Exception as ex: print(f'$w,$l,$CM,$CMIN,ERR,,,,')
" | tee -a $OUT
      i=$((i+1))
    done
  done
done
echo DONE
