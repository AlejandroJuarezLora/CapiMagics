# Analisis robusto de frecuencia: promedio multi-ciclo (metodo parte 1)
# Lee cada .raw, extrae flancos de spike, descarta arranque, promedia ciclos estables.
import numpy as np, csv, os

base = '/foss/repo/sch/lif/tb'
idx = list(csv.reader(open(f'{base}/raws/index.csv')))

def freq_from_raw(path):
    with open(path,'rb') as f: content=f.read()
    marker=b'Binary:\n'; i=content.find(marker)
    header=content[:i].decode('ascii',errors='ignore')
    npts=int([l for l in header.split('\n') if 'No. Points' in l][0].split(':')[1])
    nvars=int([l for l in header.split('\n') if 'No. Variables' in l][0].split(':')[1])
    data=np.frombuffer(content[i+len(marker):],dtype='<f8',count=npts*nvars).reshape(npts,nvars)
    t=data[:,0]           # tiempo
    spike=data[:,1]       # v(spike) es la 2a var guardada
    above=spike>1.65
    edges=np.where(np.diff(above.astype(int))==1)[0]
    st=t[edges]
    periods=np.diff(st)
    stable=periods[periods>0.2e-6]        # descartar glitches de arranque
    if len(stable)>1: stable=stable[1:]   # descartar primer ciclo post-settling
    if len(stable)<1: return None,0,0
    mean_p=stable.mean(); std=stable.std()
    return (1/mean_p)/1e3, std/mean_p*100, len(stable)   # freq kHz, jitter%, n

print('index,vin,cm_f,iex_nA,freq_kHz,jitter_pct,n_cycles')
rows=[]
for r in idx:
    ii,vin,cm,iex=r[0],r[1],r[2],float(r[3]) if r[3] else 0
    rawp=f'{base}/raws/pt_{ii}.raw'
    if not os.path.exists(rawp): continue
    freq,jit,n=freq_from_raw(rawp)
    if freq:
        line=f'{ii},{vin},{cm.replace("f","")},{iex*1e9:.1f},{freq:.1f},{jit:.1f},{n}'
        print(line); rows.append(line)
open(f'{base}/map2d_robust.csv','w').write('index,vin,cm_f,iex_nA,freq_kHz,jitter_pct,n_cycles\n'+'\n'.join(rows))
