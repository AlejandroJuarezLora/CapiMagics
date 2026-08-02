#!/bin/bash
# VALIDACION EXTERNA de las leyes ajustadas en sweep_3d_fine.csv.
# Version PARALELA: paralelismo de TAREAS (N procesos x 1 hilo), no de hilos.
#
# Por que asi: un barrido parametrico es embarrassingly parallel -- los puntos
# son independientes, sin comunicacion ni sincronizacion, asi que escala casi
# lineal. El paralelismo interno de ngspice (OpenMP sobre el solver disperso)
# escala mal en circuitos de 8 transistores: la matriz es pequena y el costo de
# sincronizar hilos se come la ganancia (~1.5-2x con 4 hilos, no 4x).
#
# OMP_NUM_THREADS=1 es OBLIGATORIO: sin el, 8 procesos x 4 hilos = 32 hilos en
# 8 nucleos -> thrashing, mas lento que correr en serie.
#
# Puntos DELIBERADAMENTE fuera de la grilla de ajuste:
#   ajuste:       W in {0.5, 1.0, 1.75, 2.5}   L in {25, 41}
#   verificacion: W in {0.75, 1.4, 2.1}        L in {33, 50}
# Ninguna combinacion (W,L) coincide. L=50 esta fuera del rango ajustado (25-41),
# asi que ademas prueba extrapolacion.
cd /foss/repo/sch/lif/tb
NJOBS=${NJOBS:-8}
TSTOP=${TSTOP:-100u}
mkdir -p raws_verify netlists_verify
rm -f raws_verify/*.raw netlists_verify/*.spice netlists_verify/*.done
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10

# ---------- fase 1: generar todos los netlists ----------
i=0
: > netlists_verify/index.txt
for w in 0.75 1.4 2.1; do
  for l in 33 50; do
    CMIN=$(PYTHONPATH= LD_LIBRARY_PATH= $PY -c "print(int(8.94*($w**1.038)*($l**0.700))+1)")
    for mult in 1.5 2.5 3.5; do
      CM=$(PYTHONPATH= LD_LIBRARY_PATH= $PY -c "print(int($CMIN*$mult))")
      sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/' \
          -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
          -e "s/^C1 integration Vss 150f/C1 integration Vss ${CM}f/" \
          -e "s/^.tran 20n 100u/.tran 1n ${TSTOP}/" \
          -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
          -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_verify/p_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
          tb_charac.spice > netlists_verify/p_${i}.spice
      echo "$i freq $w $l $CM" >> netlists_verify/index.txt
      i=$((i+1))
    done
  done
done
# Iex vs Vin a paso fino (cierra el hueco de haberla declarado "intacta" sin medir)
for vin in 1.2 1.5 1.8 2.0 2.2; do
  sed -e "s/^V2 Vin 0 1.0985/V2 Vin 0 ${vin}/" \
      -e "s/^.tran 20n 100u/.tran 1n ${TSTOP}/" \
      -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
      -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_verify/p_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
      tb_charac.spice > netlists_verify/p_${i}.spice
  echo "$i iex $vin 50 150" >> netlists_verify/index.txt
  i=$((i+1))
done
TOTAL=$i
echo "generados $TOTAL netlists, lanzando con $NJOBS procesos (1 hilo c/u)"

# ---------- fase 2: ejecutar en paralelo ----------
seq 0 $((TOTAL-1)) | OMP_NUM_THREADS=1 xargs -P $NJOBS -I{} sh -c \
  'OMP_NUM_THREADS=1 ngspice -b netlists_verify/p_{}.spice >/dev/null 2>&1; touch netlists_verify/{}.done'
echo "simulaciones terminadas"

# ---------- fase 3: extraer resultados en orden ----------
OUT=../results/verify_laws.csv
OUT2=../results/verify_iexvin.csv
echo 'W_M5,L_M5,Cm_f,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT
echo 'Vin,Iex_nA,freq_kHz,jitter_pct,estado' > $OUT2
while read idx kind a b c; do
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    f=open('raws_verify/p_${idx}.raw','rb').read(); m=b'Binary:\n'; k=f.find(m)
    h=f[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(f[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];ie=d[:,3];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    fr=(1/st.mean())/1e3 if len(st) else 0
    jit=100*st.std()/st.mean() if len(st)>1 else 0
    est='OK'
    if vm[mk].min()<-0.05: est='ANOMALO'
    elif jit>2.0: est='NOCONV'
    elif len(st)<5: est='POCOS_CIC'
    if '${kind}'=='freq':
        print(f'${a},${b},${c},{np.abs(ie[mk]).mean()*1e9:.1f},{fr:.1f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vm[mk].min():.3f},{vm[mk].max()-vm[mk].min():.3f},{est}')
    else:
        print(f'${a},{np.abs(ie[mk]).mean()*1e9:.2f},{fr:.1f},{jit:.2f},{est}')
except Exception as ex:
    print(f'${a},${b},${c},ERR,,,,,,,' if '${kind}'=='freq' else f'${a},ERR,,,')
" >> $([ "$kind" = "freq" ] && echo $OUT || echo $OUT2)
done < netlists_verify/index.txt
echo DONE
