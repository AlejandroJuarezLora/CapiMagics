#!/bin/bash
# PISO DE Iex:  Iex_min(W,L,Cm)  -- version con transitorio LARGO
#
# El intento anterior (sweep_iexwindow.sh, tstop=30u) dio NO_OSCILA falsos: a
# 30 nA la celda daba 89.9 kHz con 1 solo ciclo en la ventana, y el criterio
# exigia >=3. La frecuencia escalaba perfectamente lineal (30/40/50 nA ->
# 89.9/119.6/149.3 kHz, k=3.00 constante), asi que SI oscilaba. Lo que se
# encontro fue el limite de la ventana, no del circuito.
#
# Aqui tstop=200u: a 30 kHz da ~6 ciclos. Y el criterio de "no oscila" pasa a
# ser el COLAPSO DEL SWING (la membrana no llega al umbral), no el conteo de
# ciclos: cuando falla de verdad, swing cae de ~1.0V a 0.2-0.4V.
#
# En serie. ~25 min.
cd /foss/repo/sch/lif/tb
mkdir -p raws_imin
OUT=../results/sweep_iexmin.csv
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
[ -f $OUT ] || echo 'W_M5,L_M5,Cm_f,WL_um2,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT

run() {  # $1=W $2=L $3=Cm $4=Iex(nA)
  local w=$1 l=$2 cm=$3 ix=$4
  local id="im_${w}_${l}_${cm}_${ix}"
  grep -q ",$w,$l,$cm,.*,$ix," $OUT 2>/dev/null && return 0
  sed -e "s/^IEX 0 iin DC 100n/IEX 0 iin DC ${ix}n/" \
      -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
      -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
      -e "s/^.tran 1n 30u/.tran 1n 200u/" \
      -e "s|tb_charac_isrc.raw|raws_imin/${id}.raw|" \
      tb_charac_isrc.spice > /tmp/${id}.spice
  ngspice -b /tmp/${id}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_imin/${id}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];mk=t>40e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    jit=100*st.std()/st.mean() if len(st)>1 else 0
    vmn=vm[mk].min(); sw=vm[mk].max()-vm[mk].min()
    # criterio por SWING, no por numero de ciclos: si la membrana no recorre
    # al menos 0.6V no esta disparando de verdad.
    est='OK'
    if sw<0.6:        est='NO_OSCILA'
    elif len(st)<2:   est='NO_OSCILA'
    elif vmn<-0.05:   est='ANOMALO'
    elif jit>2.0:     est='NOCONV'
    W=float('$w'); L=float('$l')
    print(f'$w,$l,$cm,{W*L:.1f},$ix,{f:.1f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vmn:.3f},{sw:.3f},{est}')
except Exception as ex: print(f'$w,$l,$cm,,$ix,ERR,,,,,,ERR')
" >> $OUT
  sync
}

# Configuraciones ordenadas por W*L (la hipotesis es que la fuga de M5 escala
# con el area, asi que el piso deberia subir con W*L).
# W*L = 100
for ix in 5 8 12 16 20 25 30; do run 2.0 50 500 $ix; done
# W*L = 82
for ix in 4 7 10 14 18 22 26; do run 2.0 41 350 $ix; done
# W*L = 62.5  <- la celda modelo actual
for ix in 3 5 8 11 14 18 22; do run 1.25 50 200 $ix; done
# W*L = 50
for ix in 2 4 6 9 12 16 20; do run 2.0 25 200 $ix; done
# W*L = 41
for ix in 2 3 5 7 10 14 18; do run 1.0 41 200 $ix; done
# W*L = 20.5
for ix in 1 2 3 5 7 10 14; do run 0.5 41 150 $ix; done
echo DONE
