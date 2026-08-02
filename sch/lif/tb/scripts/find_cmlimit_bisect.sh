#!/bin/bash
# Busqueda binaria del Cm_min para cada (W,L): ~5 sims por punto en vez de 5 fijas
# Rango de busqueda 30-500 fF, tolerancia 10 fF
cd /foss/repo/sch/lif/tb
mkdir -p raws_bis; rm -f raws_bis/*.raw
OUT=../results/cm_limit_bisect.csv
echo 'W_M5,L_M5,area,Cm_min_fF' > $OUT
PY=/headless/.pyenv/versions/3.10.20/bin/python3.10

test_cm() {  # $1=W $2=L $3=Cm -> imprime Vm_min
  sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/'       -e "s/L=50u W=1.25u/L=$2 W=${1}u/"       -e "s/^C1 integration Vss 150f/C1 integration Vss ${3}f/"       -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/'       -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_bis/b.raw v(spike) v(x1.integration)|"       tb_charac.spice > /tmp/tbb.spice
  ngspice -b /tmp/tbb.spice >/dev/null 2>&1
  PYTHONPATH= LD_LIBRARY_PATH= $PY -c "
import numpy as np
try:
    c=open('raws_bis/b.raw','rb').read(); m=b'Binary:\n'; k=c.find(m)
    h=c[:k].decode('ascii','ignore')
    n=int([x for x in h.split(chr(10)) if 'No. Points' in x][0].split(':')[1])
    nv=int([x for x in h.split(chr(10)) if 'No. Variables' in x][0].split(':')[1])
    d=np.frombuffer(c[k+len(m):],dtype='<f8',count=n*nv).reshape(n,nv)
    t=d[:,0];vm=d[:,2];print(f'{vm[t>20e-6].min():.4f}')
except: print('nan')
"
}

for wl in '0.5 25u' '0.5 41u' '0.75 33u' '1.0 25u' '1.0 41u' '1.0 50u' '1.25 33u' '1.5 25u' '1.5 41u' '1.75 50u' '2.0 33u' '2.5 41u'; do
  set -- $wl; w=$1; l=$2
  lo=30; hi=500
  # verificar que hay frontera en el rango
  vlo=$(test_cm $w $l $lo); vhi=$(test_cm $w $l $hi)
  if [ "$(echo "$vlo >= -0.05" | bc -l 2>/dev/null)" = "1" ]; then
    echo "$w,$l,$($PY -c "print($w*float('$l'.replace('u','')))"),<30" | tee -a $OUT; continue
  fi
  if [ "$(echo "$vhi < -0.05" | bc -l 2>/dev/null)" = "1" ]; then
    echo "$w,$l,$($PY -c "print($w*float('$l'.replace('u','')))"),>500" | tee -a $OUT; continue
  fi
  # bisecar
  for it in 1 2 3 4 5; do
    mid=$($PY -c "print(int(($lo+$hi)/2))")
    v=$(test_cm $w $l $mid)
    if [ "$(echo "$v >= -0.05" | bc -l 2>/dev/null)" = "1" ]; then hi=$mid; else lo=$mid; fi
  done
  echo "$w,$l,$($PY -c "print($w*float('$l'.replace('u','')))"),$hi" | tee -a $OUT
done
echo DONE
