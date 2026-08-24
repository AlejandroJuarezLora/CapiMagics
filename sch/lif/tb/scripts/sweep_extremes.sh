#!/bin/bash
# Barrido de PUNTOS EXTREMOS aun no caracterizados, ordenado por criticidad.
#
# EJECUCION EN SERIE: bench_par.sh midio que ngspice ya usa 7.3 de 8 nucleos con
# un solo proceso. Con 2 procesos en paralelo cada simulacion pasa de ~100s a
# >660s por contencion de cache. El paralelismo de tareas NO aplica aqui.
#
# Cada punto se escribe al CSV apenas termina -> se puede interrumpir sin perder
# nada. Los bloques van de mas a menos critico, asi que cortar por la mitad deja
# lo importante hecho.
#
# .tran 1n 30u  (test_tstop.sh: identico a 100u con 4 cifras, 3.3x mas rapido)
cd /foss/repo/sch/lif/tb
mkdir -p raws_ext
OUT=../results/sweep_extremes.csv
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
[ -f $OUT ] || echo 'bloque,prioridad,W_M5,L_M5,Cm_f,Vin,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT

run() {  # $1=bloque $2=prio $3=W $4=L $5=Cm $6=Vin
  local b=$1 pr=$2 w=$3 l=$4 cm=$5 vin=$6
  local id="${b}_${w}_${l}_${cm}_${vin}"
  grep -q ",$w,$l,$cm,$vin," $OUT 2>/dev/null && return 0   # ya medido, saltar
  sed -e "s/^V2 Vin 0 1.0985/V2 Vin 0 ${vin}/" \
      -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
      -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
      -e 's/^.tran 20n 100u/.tran 1n 30u/' \
      -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
      -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_ext/${id}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
      tb_charac.spice > /tmp/ext_${id}.spice
  ngspice -b /tmp/ext_${id}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_ext/${id}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
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
    if len(st)<3:      est='NO_OSCILA'
    elif vmn<-0.05:    est='ANOMALO'
    elif jit>2.0:      est='NOCONV'
    elif len(st)<5:    est='POCOS_CIC'
    print(f'$b,$pr,$w,$l,$cm,$vin,{np.abs(ie[mk]).mean()*1e9:.2f},{f:.1f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vmn:.3f},{sw:.3f},{est}')
except Exception as ex: print(f'$b,$pr,$w,$l,$cm,$vin,ERR,,,,,,,ERR')
" >> $OUT
  sync
}

# =====================================================================
# P1 - LA MAS CRITICA: L_M5 solo tiene 2 niveles en el ajuste (25 y 41).
# El exponente -0.940 se apoya en 2 puntos. Aqui se anaden 5 niveles mas
# a W fijo=1.0 para medir la curvatura real en L.
# =====================================================================
for l in 20 25 30 35 41 45 50 60; do run P1_L 1 1.0 $l 200 1.8; done

# =====================================================================
# P2 - LIMITE SUPERIOR DE W: la ley falla a W=5u (-60%). Donde empieza a
# saturar exactamente? Barrido fino entre 2.5 y 5.0.
# =====================================================================
for w in 2.5 3.0 3.5 4.0 5.0; do run P2_Wsat 2 $w 41 400 1.8; done

# =====================================================================
# P3 - LIMITE INFERIOR DE Cm: a 25f la ley de Vth predice 5.83V (imposible).
# Donde empieza a divergir? Y cual es el Cm minimo que aun oscila?
# =====================================================================
for cm in 30 40 50 60 80 100; do run P3_Cmin 3 1.0 41 $cm 1.8; done

# =====================================================================
# P4 - Iex EXTREMOS: la recta f(Iex) falla a 23nA (+7.4%). Y por arriba?
# Vin bajo = Iex alto. Se busca donde deja de ser lineal en ambos extremos.
# =====================================================================
for vin in 0.8 1.0 1.1 2.3 2.4 2.5; do run P4_Iex 4 1.25 50 150 $vin; done

# =====================================================================
# P5 - ESQUINAS DEL ESPACIO: combinaciones extremas nunca probadas
# (W min con L max, W max con L min, etc.) para ver si las leyes se
# sostienen en las esquinas y no solo en el centro.
# =====================================================================
run P5_esq 5 0.5  60 300 1.8
run P5_esq 5 0.5  20  60 1.8
run P5_esq 5 2.5  20 200 1.8
run P5_esq 5 3.0  60 800 1.8
run P5_esq 5 0.22 41 100 1.8
run P5_esq 5 0.22 25  60 1.8

# =====================================================================
# P6 - W MINIMO DEL PDK: 0.22u es el minimo de GF180. La ley se ajusto
# desde 0.5. Extrapolar hacia abajo es tan riesgoso como hacia arriba.
# =====================================================================
for w in 0.22 0.3 0.4 0.5 0.6; do run P6_Wmin 6 $w 33 150 1.8; done

echo DONE
