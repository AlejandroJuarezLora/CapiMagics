cd /foss/repo/sch/lif/tb
mkdir -p raws_tstep; rm -f raws_tstep/*.raw
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10
echo "W,L,Cm,tstep_ns,freq_kHz,jitter_pct,n_cyc"
i=0
for cfg in "2.5 25 884" "1.75 25 612" "2.5 25 287" "1.0 25 344" "0.5 41 106"; do
  set -- $cfg; w=$1; l=$2; cm=$3
  for ts in 20n 5n 1n; do
    sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/' \
        -e "s/L=50u W=1.25u/L=${l}u W=${w}u/" \
        -e "s/^C1 integration Vss 150f/C1 integration Vss ${cm}f/" \
        -e "s/^.tran 20n 100u/.tran ${ts} 100u/" \
        -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
        -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_tstep/p_${i}.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
        tb_charac.spice > /tmp/tbts_${i}.spice
    ngspice -b /tmp/tbts_${i}.spice >/dev/null 2>&1
    PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_tstep/p_${i}.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];sp=d[:,1];mk=t>20e-6
    e=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    p=np.diff(t[e]);st=p[p>0.2e-6]
    if len(st)>1: st=st[1:]
    print(f'$w,$l,$cm,${ts},{(1/st.mean())/1e3:.1f},{100*st.std()/st.mean():.1f},{len(st)}')
except Exception as ex: print(f'$w,$l,$cm,${ts},ERR,,')
"
    i=$((i+1))
  done
done
echo DONE
