#!/bin/bash
# SENSIBILIDAD A LA IMPEDANCIA DE FUENTE
#
# Los tb usan una fuente de corriente IDEAL (impedancia infinita). En el chip la
# corriente vendra de un espejo con ro finita, y como el nodo de membrana oscila
# 1-2 V, una ro baja hace que la corriente inyectada VARIE durante el ciclo:
#
#     ideal:  Iex constante
#     real:   Iex = I0 + (V_integration - V_ref)/ro
#
# En vez de fijar un espejo concreto (seria suponer sobre el diseno ajeno), se
# mide cuanta desviacion produce cada ro. El contrato resultante es reutilizable:
# "la celda tolera impedancia de fuente >= X MOhm con menos del N% de error".
#
# Se modela con una resistencia en paralelo a la fuente, del nodo iin a Vdd
# (el espejo PMOS descarga desde Vdd).
#
# En serie, .tran 1n 30u.
cd /foss/repo/sch/lif/tb
mkdir -p raws_zs
OUT=../results/sweep_zsource.csv
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
[ -f $OUT ] || echo 'W_M5,L_M5,Cm_f,Iex_nA,ro_ohm,ro_label,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT

run() {  # $1=W $2=L $3=Cm $4=Iex(nA) $5=ro $6=label
  local w=$1 l=$2 cm=$3 ix=$4 ro=$5 lb=$6
  local id="z_${w}_${l}_${cm}_${ix}_${lb}"
  grep -q "^$w,$l,$cm,$ix,$ro," $OUT 2>/dev/null && return 0
  # RO en paralelo: del nodo de entrada a Vdd (fuente PMOS). "inf" = sin R.
  local roline=""
  [ "$lb" != "inf" ] && roline="RO iin Vdd ${ro}"
  sed -e "s/^IEX 0 iin DC 100n/IEX 0 iin DC ${ix}n/" \
      -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
      -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
      -e "s|^X1 Vdd Vss iin spike spike_neg neurona|${roline}\nX1 Vdd Vss iin spike spike_neg neurona|" \
      -e "s|tb_charac_isrc.raw|raws_zs/${id}.raw|" \
      tb_charac_isrc.spice > /tmp/${id}.spice
  ngspice -b /tmp/${id}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_zs/${id}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
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
    print(f'$w,$l,$cm,$ix,$ro,$lb,{f:.1f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vmn:.3f},{sw:.3f},{est}')
except Exception as ex: print(f'$w,$l,$cm,$ix,$ro,$lb,ERR,,,,,,ERR')
" >> $OUT
  sync
}

# ro de referencia: un PMOS largo en saturacion da ~100M-1G; uno corto ~1-10M.
# Se barre desde ideal hasta 1M para encontrar el umbral de tolerancia.
ROS="1e12:inf 1e9:1G 1e8:100M 3e7:30M 1e7:10M 3e6:3M 1e6:1M"

# --- config central: W=1.0 L=41 Cm=200f ---
for r in $ROS; do run 1.0 41 200 100 ${r%%:*} ${r##*:}; done
# --- config rapida (mas sensible: swing grande, ciclo corto) ---
for r in $ROS; do run 0.5 25  60 100 ${r%%:*} ${r##*:}; done
# --- config lenta (Cm alto) ---
for r in $ROS; do run 2.0 50 500 100 ${r%%:*} ${r##*:}; done
# --- efecto a corriente baja (donde la perturbacion relativa es mayor) ---
for r in $ROS; do run 1.0 41 200  25 ${r%%:*} ${r##*:}; done
echo DONE
