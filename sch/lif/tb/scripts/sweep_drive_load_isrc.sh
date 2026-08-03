#!/bin/bash
# CAPACIDAD DE DRIVE bajo carga: cuanta C_load aguanta la salida sin degradarse.
#
# Motivacion: teniamos I_drive ~= 85*W_M7M8 (corriente), pero eso no dice cuanta
# carga puede manejar la celda. La capa que instancie la neurona necesita saber
# "con W_M7M8 = X puedes colgar hasta Y fF sin degradar el flanco".
#
# Se anade C_load del nodo spike a Vss y se miden los tiempos de flanco (10-90%)
# ademas de la frecuencia, para ver si la carga realimenta al lazo.
#
# ENTRADA DE CORRIENTE (tb_charac_isrc.spice, sin M6). En serie, .tran 1n 30u.
cd /foss/repo/sch/lif/tb
mkdir -p raws_load; rm -f raws_load/*.raw
OUT=../results/sweep_drive_load_isrc.csv
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
[ -f $OUT ] || echo 'W_M7M8,C_load_f,freq_kHz,jitter_pct,tr_ns,tf_ns,vhigh,vlow,swing_out,estado' > $OUT

run() {  # $1=W_M7M8  $2=C_load(fF)
  local w=$1 cl=$2
  local id="ld_${w}_${cl}"
  grep -q "^$w,$cl," $OUT 2>/dev/null && return 0
  # W de M7 y M8 (los dos del inversor de salida) + carga en spike
  sed -e "s|^XM7 spike spike_neg Vdd Vdd pfet_03v3 L=0.28u W=0.22u|XM7 spike spike_neg Vdd Vdd pfet_03v3 L=0.28u W=${w}u|" \
      -e "s|^XM8 spike spike_neg GND GND nfet_03v3 L=0.28u W=0.22u|XM8 spike spike_neg GND GND nfet_03v3 L=0.28u W=${w}u|" \
      -e "s|^X1 Vdd Vss iin spike spike_neg neurona|X1 Vdd Vss iin spike spike_neg neurona\nCLOAD spike Vss ${cl}f|" \
      -e "s|tb_charac_isrc.raw|raws_load/${id}.raw|" \
      tb_charac_isrc.spice > /tmp/${id}.spice
  ngspice -b /tmp/${id}.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_load/${id}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];mk=t>20e-6
    tt=t[mk]; ss=sp[mk]
    # duty cycle ~3%: un percentil 95 cae dentro del nivel BAJO y da un swing
    # falso de ~70mV. Hay que usar min/max reales.
    hi=ss.max(); lo=ss.min()
    th=lo+0.9*(hi-lo); tl=lo+0.1*(hi-lo)
    e=np.where(np.diff((ss>(hi+lo)/2).astype(int))==1)[0]
    p=np.diff(tt[e]); st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    jit=100*st.std()/st.mean() if len(st)>1 else 0
    # Tiempos de flanco 10-90%. El cruce del 50% ya paso el 10%, asi que hay
    # que retroceder para hallar el 10% y avanzar para el 90%.
    trs=[];tfs=[]
    for i in e[:20]:
        a=i
        while a>0 and ss[a]>tl: a-=1          # retroceder al 10%
        b=i
        while b<len(ss)-1 and ss[b]<th: b+=1  # avanzar al 90%
        if b>a and (b-a)<5000: trs.append(tt[b]-tt[a])
    fall=np.where(np.diff((ss>(hi+lo)/2).astype(int))==-1)[0]
    for i in fall[:20]:
        a=i
        while a>0 and ss[a]<th: a-=1          # retroceder al 90%
        b=i
        while b<len(ss)-1 and ss[b]>tl: b+=1  # avanzar al 10%
        if b>a and (b-a)<5000: tfs.append(tt[b]-tt[a])
    tr=np.median(trs)*1e9 if trs else -1
    tf=np.median(tfs)*1e9 if tfs else -1
    est='OK' if len(st)>=3 and jit<2.0 else ('NO_OSCILA' if len(st)<3 else 'NOCONV')
    print(f'$w,$cl,{f:.1f},{jit:.2f},{tr:.2f},{tf:.2f},{hi:.3f},{lo:.3f},{hi-lo:.3f},{est}')
except Exception as ex: print(f'$w,$cl,ERR,,,,,,,ERR')
" >> $OUT
  sync
}

# W_M7M8 minimo (0.22u, el del diseno actual): donde se rompe?
for cl in 0 10 25 50 100 200 400; do run 0.22 $cl; done
# W = 0.5u
for cl in 0 25 100 200 400 800; do run 0.5 $cl; done
# W = 1.0u
for cl in 0 50 200 400 800 1600; do run 1.0 $cl; done
# W = 2.0u  (drive alto)
for cl in 0 100 400 800 1600; do run 2.0 $cl; done
echo DONE
