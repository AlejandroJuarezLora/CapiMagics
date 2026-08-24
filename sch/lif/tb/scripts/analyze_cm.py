# Analiza freq (multi-ciclo) + Vth vs Cm, y contrasta con la teoria f ~ 1/Cm
import numpy as np, csv, os
base='/foss/repo/sch/lif/tb'
def analyze(path):
    c=open(path,'rb').read(); m=b'Binary:\n'; i=c.find(m)
    h=c[:i].decode('ascii',errors='ignore')
    npts=int([l for l in h.split(chr(10)) if 'No. Points' in l][0].split(':')[1])
    nv=int([l for l in h.split(chr(10)) if 'No. Variables' in l][0].split(':')[1])
    d=np.frombuffer(c[i+len(m):],dtype='<f8',count=npts*nv).reshape(npts,nv)
    t=d[:,0]; spike=d[:,1]; vm=d[:,2]
    edges=np.where(np.diff((spike>1.65).astype(int))==1)[0]
    per=np.diff(t[edges]); st=per[per>0.2e-6]
    if len(st)>1: st=st[1:]
    if len(st)<1: return None,0,0,None
    mask=t>20e-6
    return (1/st.mean())/1e3, st.std()/st.mean()*100, len(st), vm[mask].max()
rows=[]; cms=[]; fs=[]
print('Cm_f,freq_kHz,jitter_pct,n_cyc,Vth_V')
for r in csv.reader(open(f'{base}/raws_cmr/index.csv')):
    ii,cm=r[0],r[1]
    rp=f'{base}/raws_cmr/cm_{ii}.raw'
    if os.path.exists(rp):
        f,j,n,vth=analyze(rp)
        if f:
            cmv=float(cm.replace('f',''))
            print(f'{cmv:.0f},{f:.1f},{j:.1f},{n},{vth:.3f}')
            rows.append(f'{cmv:.0f},{f:.1f},{j:.1f},{n},{vth:.3f}'); cms.append(cmv); fs.append(f)
print()
print('=== TEST TEORIA: f ~ 1/Cm  =>  f*Cm constante? ===')
cms=np.array(cms); fs=np.array(fs); prod=fs*cms
for c,f,p in zip(cms,fs,prod): print(f'  Cm={c:>4.0f}f  f={f:>7.1f}kHz   f*Cm={p:>8.0f}')
print(f'  -> spread de f*Cm: {100*(prod.max()-prod.min())/prod.mean():.0f}%')
open(f'{base}/../results/sweep_cm_robust.csv','w').write('Cm_f,freq_kHz,jitter_pct,n_cyc,Vth_V\n'+'\n'.join(rows))
