# Detecta overshoot: Vm fuera de rieles (0..Vdd=3.3) -> regimen anomalo
import numpy as np, csv, os
base='/foss/repo/sch/lif/tb'; VDD=3.3
def analyze(p):
    c=open(p,'rb').read(); m=b'Binary:\n'; i=c.find(m)
    h=c[:i].decode('ascii',errors='ignore')
    n=int([l for l in h.split(chr(10)) if 'No. Points' in l][0].split(':')[1])
    nv=int([l for l in h.split(chr(10)) if 'No. Variables' in l][0].split(':')[1])
    d=np.frombuffer(c[i+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0]; sp=d[:,1]; vm=d[:,2]; ie=d[:,3] if nv>3 else None
    mask=t>20e-6
    vmin,vmax=vm[mask].min(),vm[mask].max()
    ed=np.where(np.diff((sp>1.65).astype(int))==1)[0]
    per=np.diff(t[ed]); st=per[per>0.2e-6]
    if len(st)>1: st=st[1:]
    f=(1/st.mean())/1e3 if len(st)>=1 else None
    iex=np.abs(ie[mask]).mean()*1e9 if ie is not None else 0
    # margen fuera de rieles
    over=max(vmax-VDD,0); under=max(-vmin,0)
    return f,iex,vmin,vmax,over+under
print('Vin,Iex_nA,Cm_f,freq_kHz,Vm_min,Vm_max,fuera_rieles_V,estado')
rows=[]
for r in csv.reader(open(f'{base}/raws_lim/index.csv')):
    ii,vin,cm=r[0],r[1],r[2]
    p=f'{base}/raws_lim/p_{ii}.raw'
    if os.path.exists(p):
        f,ie,vmn,vmx,ex=analyze(p)
        est='ANOMALO' if ex>0.05 else 'OK'
        fs=f'{f:.1f}' if f else 'NO_OSC'
        line=f'{vin},{ie:.1f},{cm.replace("f","")},{fs},{vmn:.3f},{vmx:.3f},{ex:.3f},{est}'
        print(line); rows.append(line)
open(f'{base}/../results/cm_limit_map.csv','w').write('Vin,Iex_nA,Cm_f,freq_kHz,Vm_min,Vm_max,fuera_rieles_V,estado\n'+'\n'.join(rows))
