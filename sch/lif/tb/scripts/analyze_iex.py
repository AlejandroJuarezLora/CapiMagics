# freq + Vth + Iex vs Vin (12 puntos). Prueba modelos lineal vs exponencial para Vin->Iex
import numpy as np, csv, os
base='/foss/repo/sch/lif/tb'
def analyze(path):
    c=open(path,'rb').read(); m=b'Binary:\n'; i=c.find(m)
    h=c[:i].decode('ascii',errors='ignore')
    npts=int([l for l in h.split(chr(10)) if 'No. Points' in l][0].split(':')[1])
    nv=int([l for l in h.split(chr(10)) if 'No. Variables' in l][0].split(':')[1])
    d=np.frombuffer(c[i+len(m):],dtype='<f8',count=npts*nv).reshape(npts,nv)
    t=d[:,0]; spike=d[:,1]; vm=d[:,2]; iex=d[:,3] if nv>3 else None
    edges=np.where(np.diff((spike>1.65).astype(int))==1)[0]
    per=np.diff(t[edges]); st=per[per>0.2e-6]
    if len(st)>1: st=st[1:]
    mask=t>20e-6
    freq=(1/st.mean())/1e3 if len(st)>=1 else None
    jit=st.std()/st.mean()*100 if len(st)>=2 else 0
    ie=np.abs(iex[mask]).mean()*1e9 if iex is not None else None
    return freq,jit,len(st),vm[mask].max(),ie
rows=[]
print('Vin_V,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V')
for r in csv.reader(open(f'{base}/raws_iexr/index.csv')):
    ii,vin=r[0],float(r[1])
    rp=f'{base}/raws_iexr/iex_{ii}.raw'
    if os.path.exists(rp):
        f,j,n,vth,ie=analyze(rp)
        if f and ie:
            print(f'{vin:.2f},{ie:.1f},{f:.1f},{j:.1f},{n},{vth:.3f}')
            rows.append(f'{vin:.2f},{ie:.1f},{f:.1f},{j:.1f},{n},{vth:.3f}')
        elif ie:
            print(f'{vin:.2f},{ie:.1f},NO_OSCILA,,,')
open(f'{base}/../results/sweep_iex_robust.csv','w').write('Vin_V,Iex_nA,freq_kHz,jitter_pct,n_cyc,Vth_V\n'+'\n'.join(rows))
