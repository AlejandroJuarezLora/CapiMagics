#!/bin/bash
# VALIDACION EXTERNA de las leyes ajustadas en sweep_3d_fine.csv.
#
# Puntos DELIBERADAMENTE fuera de la grilla de ajuste:
#   grilla de ajuste:  W in {0.5, 1.0, 1.75, 2.5}   L in {25, 41}
#   aqui:              W in {0.75, 1.4, 2.1}        L in {33, 50}
# Ninguna combinacion (W,L) coincide, asi que ninguna ley "conoce" estos puntos.
#
# Incluye ademas:
#   - L=50 (fuera del rango de ajuste 25-41) -> prueba de extrapolacion
#   - re-medicion de Iex vs Vin a paso 1n    -> cierra el hueco de "es DC, no afecta"
cd /foss/repo/sch/lif/tb
mkdir -p raws_verify; rm -f raws_verify/*.raw
OUT=../results/verify_laws.csv
echo 'W_M5,L_M5,Cm_f,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
i=0
for w in 0.75 1.4 2.1; do
  for l in 33 50; do
    CMIN=$(PYTHONPATH= LD_LIBRARY_PATH= $PY -c "print(int(8.94*($w**1.038)*($l**0.700))+1)")
    for mult in 1.5 2.5 3.5; do
      CM=$(PYTHONPATH= LD_LIBRARY_PATH= $PY -c "print(int($CMIN*$mult))")
      sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/' \
          -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
          -e "s/^C1 integration Vss 150f/C1 integration Vss ${CM}f/" \
          -e 's/^.tran 20n 100u/.tran 1n 30u/' \
          -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
          -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_verify/p_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
          tb_charac.spice > /tmp/tbv_${i}.spice
      ngspice -b /tmp/tbv_${i}.spice >/dev/null 2>&1
      PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_verify/p_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];ie=d[:,3];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    jit=100*st.std()/st.mean() if len(st)>1 else 0
    vmn=vm[mk].min(); sw=vm[mk].max()-vm[mk].min()
    est='OK'
    if vmn<-0.05: est='ANOMALO'
    elif jit>2.0: est='NOCONV'
    elif len(st)<5: est='POCOS_CIC'
    print(f'$w,$l,$CM,{np.abs(ie[mk]).mean()*1e9:.1f},{f:.1f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vmn:.3f},{sw:.3f},{est}')
except Exception as ex: print(f'$w,$l,$CM,ERR,,,,,,,')
" >> $OUT
      i=$((i+1))
    done
  done
done

# --- re-medicion de Iex(Vin) a paso 1n: cierra el hueco "es DC, no afecta" ---
OUT2=../results/verify_iexvin.csv
echo 'Vin,Iex_nA,freq_kHz,jitter_pct,estado' > $OUT2
for vin in 1.2 1.5 1.8 2.0 2.2; do
  sed -e "s/^V2 Vin 0 1.0985/V2 Vin 0 ${vin}/" \
      -e 's/^.tran 20n 100u/.tran 1n 30u/' \
      -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
      -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_verify/iv_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
      tb_charac.spice > /tmp/tbiv_${i}.spice
  ngspice -b /tmp/tbiv_${i}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_verify/iv_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];ie=d[:,3];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    jit=100*st.std()/st.mean() if len(st)>1 else 0
    print(f'${vin},{np.abs(ie[mk]).mean()*1e9:.2f},{f:.1f},{jit:.2f},{\"OK\" if jit<2 else \"NOCONV\"}')
except Exception as ex: print(f'${vin},ERR,,,')
" >> $OUT2
  i=$((i+1))
done
echo DONE
