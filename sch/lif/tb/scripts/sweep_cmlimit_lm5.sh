#!/bin/bash
# Cm x L_M5: analiza CADA punto al vuelo y lo imprime (resultados incrementales)
cd /foss/repo/sch/lif/tb
mkdir -p raws_lim5
rm -f raws_lim5/*.raw raws_lim5/index.csv
OUT=../results/cm_limit_lm5.csv
echo 'L_M5_um,Cm_f,freq_kHz,Vm_min,Vm_max,estado' > $OUT
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
i=0
for lm5 in 25u 35u 50u; do
  for cm in 75f 100f 125f 150f 200f; do
    sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/'         -e "s/L=50u W=1.25u/L=$lm5 W=1.25u/"         -e "s/^C1 integration Vss 150f/C1 integration Vss $cm/"         -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'         -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_lim5/q_${i}.raw v(spike) v(x1.integration)|"         tb_charac.spice > /tmp/tbl5.spice
    ngspice -b /tmp/tbl5.spice >/dev/null 2>&1
    # analizar AL VUELO
    PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np,sys
try:
    c=open('raws_lim5/q_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([l for l in h.split(chr(10)) if 'No. Points' in l][0].split(':')[1])
    nv=int([l for l in h.split(chr(10)) if 'No. Variables' in l][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];vm=d[:,2];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st) else 0
    vmn,vmx=vm[mk].min(),vm[mk].max()
    est='ANOMALO' if (vmn<-0.05 or vmx>3.35) else 'OK'
    print(f'$lm5,${cm},{f:.1f},{vmn:.3f},{vmx:.3f},{est}')
except Exception as ex: print(f'$lm5,${cm},ERROR,,,')
" | tee -a $OUT
    i=$((i+1))
  done
done
echo DONE
