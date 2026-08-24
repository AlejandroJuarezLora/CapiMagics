#!/bin/bash
# GANANCIA DE MODULACION k(W,L,Cm):  f = k*Iex + f0
#
# ENTRADA DE CORRIENTE: la celda de Abrahan no lleva M6 (el espejo Vin->Iex),
# la corriente entra directo al nodo de membrana porque "se conectara a
# distintas etapas". Se barre IEX, no Vin.
#
# Motivacion: el usuario de la celda no pide una frecuencia fija, pide un RANGO
# de salida para un RANGO de entrada. Necesita la pendiente de la curva de
# transferencia, no un punto.
#
# 9 configuraciones x 5 corrientes = 45 puntos. En serie, .tran 1n 30u.
cd /foss/repo/sch/lif/tb
mkdir -p raws_gain; rm -f raws_gain/*.raw
OUT=../results/sweep_gain_isrc.csv
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
[ -f $OUT ] || echo 'W_M5,L_M5,Cm_f,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT

run() {  # $1=W $2=L $3=Cm $4=Iex(nA)
  local w=$1 l=$2 cm=$3 ix=$4
  local id="g_${w}_${l}_${cm}_${ix}"
  grep -q "^$w,$l,$cm,$ix," $OUT 2>/dev/null && return 0
  sed -e "s/^IEX 0 iin DC 100n/IEX 0 iin DC ${ix}n/" \
      -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
      -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
      -e "s|tb_charac_isrc.raw|raws_gain/${id}.raw|" \
      tb_charac_isrc.spice > /tmp/${id}.spice
  ngspice -b /tmp/${id}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_gain/${id}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
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
    print(f'$w,$l,$cm,$ix,{f:.1f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vmn:.3f},{sw:.3f},{est}')
except Exception as ex: print(f'$w,$l,$cm,$ix,ERR,,,,,,ERR')
" >> $OUT
  sync
}

IEXS="25 60 100 200 400"

for v in $IEXS; do run 0.5 25  60 $v; done   # rapida, Cm bajo
for v in $IEXS; do run 0.5 41 150 $v; done
for v in $IEXS; do run 0.5 50 200 $v; done
for v in $IEXS; do run 1.0 25 100 $v; done
for v in $IEXS; do run 1.0 41 200 $v; done   # centro del espacio
for v in $IEXS; do run 1.0 50 300 $v; done
for v in $IEXS; do run 2.0 25 200 $v; done
for v in $IEXS; do run 2.0 41 350 $v; done
for v in $IEXS; do run 2.0 50 500 $v; done   # lenta, Cm alto
echo DONE
