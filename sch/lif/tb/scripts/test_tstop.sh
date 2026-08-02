cd /foss/repo/sch/lif/tb
mkdir -p raws_ttest; rm -f raws_ttest/*.raw
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
echo "W,L,Cm,tstop_us,freq_kHz,jitter_pct,n_cyc,Vth_V,swing_V"
i=0
# el caso mas lento (menos ciclos) y uno rapido
for cfg in "2.5 41 1248" "0.5 25 54"; do
  set -- $cfg; w=$1; l=$2; cm=$3
  for ts in 100u 50u 30u; do
    sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/' \
        -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
        -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
        -e "s/^.tran 20n 100u/.tran 1n ${ts}/" \
        -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
        -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_ttest/p_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
        tb_charac.spice > /tmp/tbtt_${i}.spice
    ngspice -b /tmp/tbtt_${i}.spice >/dev/null 2>&1
    PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
c=open('raws_ttest/p_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
h=c[:k].decode('ascii','ignore')
n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
t=d[:,0];sp=d[:,1];vm=d[:,2];mk=t>20e-6
e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
p=np.diff(t[e]);st=p[p>0.2e-6]
if len(st)>1: st=st[1:]
print(f'$w,$l,$cm,${ts},{(1/st.mean())/1e3:.1f},{100*st.std()/st.mean():.2f},{len(st)},{vm[mk].max():.3f},{vm[mk].max()-vm[mk].min():.3f}')
"
    i=$((i+1))
  done
done
