#!/bin/bash
# Valida por simulacion el MAPA DE FACTIBILIDAD (f, Vth) calculado con las leyes.
#
# Dos supuestos que hay que comprobar, no dar por buenos:
#  1. que Cm = 1.05*Cm_min realmente oscile (la ley Cm_min es conservadora ~34%,
#     asi que el borde real podria estar mas abajo -> mas Vth alcanzable)
#  2. que el Vth predicho se cumpla justo en el borde, donde nunca se midio
#
# Cada bloque cubre una frecuencia objetivo, con Cm bajando hacia el limite.
# Escribe cada punto al terminar; se puede cortar sin perder nada.
cd /foss/repo/sch/lif/tb
mkdir -p raws_feas
OUT=../results/validate_feasibility.csv
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
[ -f $OUT ] || echo 'f_obj,W_M5,L_M5,Cm_f,mult_cmmin,f_pred,Vth_pred,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V,Vm_min,swing_V,estado' > $OUT

run() {  # $1=f_obj $2=W $3=L $4=Cm $5=mult $6=f_pred $7=vth_pred
  local fo=$1 w=$2 l=$3 cm=$4 mu=$5 fp=$6 vp=$7
  local id="f${fo}_${w}_${l}_${cm}"
  grep -q ",$w,$l,$cm," $OUT 2>/dev/null && return 0
  sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/' \
      -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
      -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
      -e 's/^.tran 20n 100u/.tran 1n 30u/' \
      -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
      -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_feas/${id}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
      tb_charac.spice > /tmp/feas_${id}.spice
  ngspice -b /tmp/feas_${id}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_feas/${id}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
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
    if len(st)<3:   est='NO_OSCILA'
    elif vmn<-0.05: est='ANOMALO'
    elif jit>2.0:   est='NOCONV'
    print(f'$fo,$w,$l,$cm,$mu,$fp,$vp,{np.abs(ie[mk]).mean()*1e9:.2f},{f:.1f},{jit:.2f},{len(st)},{vm[mk].max():.3f},{vmn:.3f},{sw:.3f},{est}')
except Exception as ex: print(f'$fo,$w,$l,$cm,$mu,$fp,$vp,ERR,,,,,,,ERR')
" >> $OUT
  sync
}

# ---- f=300 kHz: W=1.97 L=50, Cm_min(ley)=279f ----
run 300 1.97 50 293 1.05 300 1.842
run 300 1.97 50 251 0.90 300 1.900
run 300 1.97 50 223 0.80 300 1.955
run 300 1.97 50 195 0.70 300 2.036
run 300 1.97 50 419 1.50 300 1.665

# ---- f=1000 kHz: W=0.65 L=50, Cm_min(ley)=88f ----
run 1000 0.65 50 93 1.05 1000 2.043
run 1000 0.65 50 79 0.90 1000 2.126
run 1000 0.65 50 70 0.80 1000 2.204
run 1000 0.65 50 62 0.70 1000 2.298
run 1000 0.65 50 132 1.50 1000 1.789

# ---- f=3000 kHz: W=0.24 L=48, Cm_min(ley)=31f ----
run 3000 0.24 48 32 1.05 3000 2.521
run 3000 0.24 48 28 0.90 3000 2.652
run 3000 0.24 48 25 0.80 3000 2.784
run 3000 0.24 48 22 0.70 3000 2.976
run 3000 0.24 48 46 1.50 3000 2.096

# ---- caso extremo: Vth alto con f baja (el "imposible" identificado) ----
run 200 2.86 50 432 1.05 200 1.809
run 200 2.86 50 329 0.80 200 1.930

echo DONE
