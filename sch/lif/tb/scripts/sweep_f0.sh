#!/bin/bash
# TERMINO INDEPENDIENTE f0 de la recta  f = k*Iex + f0
#
# Del barrido de ganancia salio f0 por configuracion (14-144 kHz) pero sin ley.
# El sistema lo esquiva anclando en freq_at_iex_ref, pero eso mete un error del
# orden de f0/f (1-5%). Con una ley de f0 el modelo queda exacto.
#
# Para ajustar bien el intercepto hacen falta puntos a corriente BAJA, donde f0
# pesa: a 400 nA, f0=40 kHz es el 2% de la lectura; a 10 nA es el 40%.
# Por eso aqui se barre 5-80 nA (el de ganancia usaba 25-400).
#
# tstop=100u: a 15 kHz da ~1.5 ciclos... no basta. Se usa 150u para tener >=3
# ciclos en el peor caso (5 nA con la config mas lenta ~15 kHz).
#
# En serie. ~50 min.
cd /foss/repo/sch/lif/tb
mkdir -p raws_f0
OUT=../results/sweep_f0.csv
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
[ -f $OUT ] || echo 'W_M5,L_M5,Cm_f,WL_um2,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT

run() {  # $1=W $2=L $3=Cm $4=Iex(nA)
  local w=$1 l=$2 cm=$3 ix=$4
  local id="f0_${w}_${l}_${cm}_${ix}"
  grep -q ",$w,$l,$cm,.*,$ix," $OUT 2>/dev/null && return 0
  sed -e "s/^IEX 0 iin DC 100n/IEX 0 iin DC ${ix}n/" \
      -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
      -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
      -e "s/^.tran 1n 30u/.tran 1n 150u/" \
      -e "s|tb_charac_isrc.raw|raws_f0/${id}.raw|" \
      tb_charac_isrc.spice > /tmp/${id}.spice
  ngspice -b /tmp/${id}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_f0/${id}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];mk=t>30e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    jit=100*st.std()/st.mean() if len(st)>1 else 0
    vmn=vm[mk].min(); sw=vm[mk].max()-vm[mk].min()
    est='OK'
    if sw<0.6:      est='NO_OSCILA'
    elif len(st)<2: est='POCOS_CIC'
    elif vmn<-0.05: est='ANOMALO'
    elif jit>2.0:   est='NOCONV'
    W=float('$w'); L=float('$l')
    print(f'$w,$l,$cm,{W*L:.1f},$ix,{f:.2f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vmn:.3f},{sw:.3f},{est}')
except Exception as ex: print(f'$w,$l,$cm,,$ix,ERR,,,,,,ERR')
" >> $OUT
  sync
}

# 6 configuraciones x 6 corrientes bajas. Se cubre W*L de 20 a 100 y Cm de
# 150 a 500 para ver si f0 depende de la geometria o del capacitor.
for ix in 5 10 20 35 55 80; do run 0.5  41 150 $ix; done   # W*L=20.5
for ix in 5 10 20 35 55 80; do run 1.0  41 200 $ix; done   # W*L=41
for ix in 5 10 20 35 55 80; do run 1.25 50 200 $ix; done   # W*L=62.5 (celda actual)
for ix in 5 10 20 35 55 80; do run 2.0  25 200 $ix; done   # W*L=50
for ix in 5 10 20 35 55 80; do run 2.0  50 500 $ix; done   # W*L=100
for ix in 5 10 20 35 55 80; do run 0.5  25  60 $ix; done   # Cm bajo
echo DONE
