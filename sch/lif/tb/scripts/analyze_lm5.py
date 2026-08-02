# Analiza freq (multi-ciclo) Y threshold (Vm pico) vs L_M5
import numpy as np, csv, os
base='/foss/repo/sch/lif/tb'
def analyze(path):
    c=open(path,'rb').read(); m=b'Binary:\n'; i=c.find(m)
    h=c[:i].decode('ascii',errors='ignore')
    npts=int([l for l in h.split(chr(10)) if 'No. Points' in l][0].split(':')[1])
    nv=int([l for l in h.split(chr(10)) if 'No. Variables' in l][0].split(':')[1])
    d=np.frombuffer(c[i+len(m):],dtype='<f8',count=npts*nv).reshape(npts,nv)
    t=d[:,0]; spike=d[:,1]; integ=d[:,2]   # tiempo, v(spike), v(integration)=Vm
    # frecuencia multi-ciclo
    edges=np.where(np.diff((spike>1.65).astype(int))==1)[0]
    per=np.diff(t[edges]); st=per[per>0.2e-6]
    if len(st)>1: st=st[1:]
    freq=(1/st.mean())/1e3 if len(st)>=1 else None
    jit=st.std()/st.mean()*100 if len(st)>=2 else 0
    # threshold: Vm pico (el nodo integration justo antes de disparar), post-settling
    mask=t>20e-6
    vth=integ[mask].max() if mask.any() else None
    return freq, jit, len(st), vth
print('L_M5_um,freq_kHz,jitter_pct,n_cyc,Vth_lif_V')
rows=[]
for r in csv.reader(open(f'{base}/raws_lm5r/index.csv')):
    ii,lm5=r[0],r[1]
    rp=f'{base}/raws_lm5r/lm5_{ii}.raw'
    if os.path.exists(rp):
        f,j,n,vth=analyze(rp)
        if f:
            line=f'{lm5.replace("u","")},{f:.1f},{j:.1f},{n},{vth:.3f}'
            print(line); rows.append(line)
open(f'{base}/../results/sweep_lm5_robust.csv','w').write('L_M5_um,freq_kHz,jitter_pct,n_cyc,Vth_lif_V\n'+'\n'.join(rows))
