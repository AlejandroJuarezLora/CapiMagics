#!/bin/bash
# Mide el escalado real: hilos por proceso vs procesos en paralelo.
# Motivacion: OMP_NUM_THREADS=1 NO tuvo efecto (los procesos seguian con 8
# hilos), y 8 procesos x 8 hilos = 64 hilos en 8 nucleos -> thrashing, 23 min
# sin completar nada. Aqui se mide en vez de suponer.
#
# ngspice-46 compilado con KLU (solver directo secuencial). Los hilos que
# aparecen no son del solve.
cd /foss/repo/sch/lif/tb
mkdir -p raws_bench netlists_bench
rm -f raws_bench/*.raw netlists_bench/*.spice

mknet() {   # $1=idx  $2=num_threads (0 = no poner la opcion)
  local opt=""
  [ "$2" != "0" ] && opt="s/^.tran 1n/.option num_threads=$2\n.tran 1n/"
  sed -e 's/^V2 Vin 0 1.0985/V2 Vin 0 1.8/' \
      -e 's/L=50u W=1.25u/L=33u W=1.4u/' \
      -e 's/^C1 integration Vss 150f/C1 integration Vss 200f/' \
      -e 's/^.tran 20n 100u/.tran 1n 30u/' \
      -e 's/save v(spike) @m/save v(spike) v(x1.integration) @m/' \
      -e "s|tb_charac.raw v(spike) @m.x1.xm6.m0\[id\]|raws_bench/b_$1.raw v(spike) v(x1.integration) @m.x1.xm6.m0[id]|" \
      tb_charac.spice > netlists_bench/b_$1.spice
  [ "$2" != "0" ] && sed -i "s/^\.tran 1n 30u/.option num_threads=$2\n.tran 1n 30u/" netlists_bench/b_$1.spice
  return 0
}

echo "=== A) UNA simulacion, variando num_threads ==="
for nt in 0 1 2 4 8; do
  mknet 0 $nt
  rm -f raws_bench/b_0.raw
  T0=$(date +%s)
  ngspice -b netlists_bench/b_0.spice >/dev/null 2>&1
  T1=$(date +%s)
  SZ=$(ls -la raws_bench/b_0.raw 2>/dev/null | awk '{print $5}')
  lbl=$nt; [ "$nt" = "0" ] && lbl="(sin opcion)"
  echo "  num_threads=$lbl  ->  $((T1-T0)) s   raw=${SZ:-FALLO} bytes"
done

echo
echo "=== B) N procesos en paralelo, num_threads=1 cada uno ==="
for NP in 1 2 4 8; do
  for i in $(seq 0 $((NP-1))); do mknet $i 1; done
  rm -f raws_bench/*.raw
  T0=$(date +%s)
  seq 0 $((NP-1)) | xargs -P $NP -I{} ngspice -b netlists_bench/b_{}.spice >/dev/null 2>&1
  T1=$(date +%s)
  OK=$(ls raws_bench/*.raw 2>/dev/null | wc -l)
  DT=$((T1-T0))
  echo "  $NP procesos -> $DT s total, $OK/$NP raws, $(echo "scale=1; $DT/$NP" | bc) s/punto efectivo"
done
echo DONE
