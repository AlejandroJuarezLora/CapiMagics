#!/bin/bash
# VENTANA DE OPERACION DE Iex:  Iex_min(W,L,Cm) e Iex_max(W,L,Cm)
#
# Del barrido de ganancia salieron 4 puntos frontera, suficientes para ver el
# patron pero no para ajustar una ley:
#   Iex_max: falla con W pequeno. 0.5/25/60 y 0.5/41/150 mueren a 400 nA
#            (ultimo OK ~3000-4800 kHz) -> es un techo de FRECUENCIA: cuando el
#            periodo se acerca al retardo de la cadena de inversores, el reset
#            no completa.
#   Iex_min: falla con W*L grande. 2.0/41/350 (W*L=82) y 2.0/50/500 (W*L=100)
#            mueren a 25 nA -> la fuga de M5 compite con la corriente de
#            entrada; si Iex no la supera, la membrana no llega al umbral.
#
# Aqui se acotan ambas fronteras por busqueda en 9 configuraciones que barren
# W*L de 12.5 a 100 um2 y Cm de 60 a 500 fF.
#
# En serie, .tran 1n 30u.
cd /foss/repo/sch/lif/tb
mkdir -p raws_iw
OUT=../results/sweep_iexwindow.csv
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
[ -f $OUT ] || echo 'tipo,W_M5,L_M5,Cm_f,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT

run() {  # $1=tipo $2=W $3=L $4=Cm $5=Iex(nA)
  local tp=$1 w=$2 l=$3 cm=$4 ix=$5
  local id="iw_${w}_${l}_${cm}_${ix}"
  grep -q ",$w,$l,$cm,$ix," $OUT 2>/dev/null && return 0
  sed -e "s/^IEX 0 iin DC 100n/IEX 0 iin DC ${ix}n/" \
      -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
      -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
      -e "s|tb_charac_isrc.raw|raws_iw/${id}.raw|" \
      tb_charac_isrc.spice > /tmp/${id}.spice
  ngspice -b /tmp/${id}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_iw/${id}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    jit=100*st.std()/st.mean() if len(st)>1 else 0
    vmn=vm[mk].min(); sw=vm[mk].max()-vm[mk].min()
    est='OK'
    if len(st)<3:   est='NO_OSCILA'
    elif vmn<-0.05: est='ANOMALO'
    elif jit>2.0:   est='NOCONV'
    print(f'$tp,$w,$l,$cm,$ix,{f:.1f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vmn:.3f},{sw:.3f},{est}')
except Exception as ex: print(f'$tp,$w,$l,$cm,$ix,ERR,,,,,,ERR')
" >> $OUT
  sync
}

# =====================================================================
# TECHO: Iex_max. Se sube la corriente hasta que deja de oscilar.
# Configuraciones con W pequeno (las que fallan antes).
# =====================================================================
for ix in 250 300 350 400 500 700; do run MAX 0.5 25  60 $ix; done
for ix in 250 300 350 400 500 700; do run MAX 0.5 41 150 $ix; done
for ix in 400 500 600 800 1000;    do run MAX 0.5 50 200 $ix; done
for ix in 400 600 800 1000 1400;   do run MAX 1.0 25 100 $ix; done
for ix in 400 600 800 1200 1600;   do run MAX 1.0 41 200 $ix; done

# =====================================================================
# PISO: Iex_min. Se baja la corriente hasta que la fuga de M5 gana.
# Configuraciones con W*L grande (las que fallan antes).
# =====================================================================
for ix in 10 15 20 25 30 40 50; do run MIN 2.0 50 500 $ix; done
for ix in 10 15 20 25 30 40 50; do run MIN 2.0 41 350 $ix; done
for ix in 5 8 12 16 20 25;      do run MIN 2.0 25 200 $ix; done
for ix in 3 5 8 12 16 20;       do run MIN 1.0 41 200 $ix; done
for ix in 2 4 6 10 15;          do run MIN 0.5 41 150 $ix; done

# =====================================================================
# Cm: influye en el techo? (mismo W,L con Cm distinto)
# =====================================================================
for ix in 400 600 800; do run MAXCM 0.5 41  80 $ix; done
for ix in 400 600 800; do run MAXCM 0.5 41 300 $ix; done
echo DONE
