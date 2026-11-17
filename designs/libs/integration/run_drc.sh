#!/bin/bash
# Sign-off DRC of the D14 block with the PDK's KLayout rule deck.
#
#   usage (inside the iic-osic-tools container):
#       bash signoff/run_drc.sh [gds]
#
# Variant D = 11K top metal, MIM option B, 5 metal levels (the Chipathon
# integration process). Deep mode, FEOL + BEOL + connectivity + off-grid, plus
# the antenna checks. Density is left to the integrator's fill.
#
# Raw results land in signoff/drc/ as KLayout marker databases (*.lyrdb); the
# summary below counts the <item> entries of every database.
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)

GDS=${1:-$HERE/runs/padfix_m2/final/gds/D14.gds}
OUT=$HERE/drc
DECK=${PDK_ROOT:-/foss/pdks}/${PDK:-gf180mcuD}/libs.tech/klayout/tech/drc/run_drc.py

rm -rf "$OUT"
mkdir -p "$OUT"
python3 "$DECK" --path="$GDS" --topcell=D14 --variant=D \
    --run_mode=deep --antenna --mp=4 --thr=2 --run_dir="$OUT" > "$OUT/run_drc.out" 2>&1

# The deck copies run_drc.py materializes are not results.
rm -f "$OUT"/*.drc
echo "gds: $(sha256sum "$GDS" | cut -c1-64)"
total=0
for db in "$OUT"/*.lyrdb; do
    n=$(grep -c '<item>' "$db" || true)
    total=$((total + n))
    printf '%6d  %s\n' "$n" "$(basename "$db")"
done
echo "DRC violations (all databases): $total"
# Rules that fired, if any:
grep -h -o '<category>[^<]*</category>' "$OUT"/*.lyrdb | sort | uniq -c | sort -rn | head -20 || true
# A rule table that crashed produced no database: that is not a clean result.
crashed=$(grep -c 'generated an exception' "$OUT/run_drc.out" || true)
echo "DRC rule tables that crashed (not evaluated): $crashed"
grep -o '^[^|]*| ERROR *| [a-z0-9_]* generated an exception' "$OUT/run_drc.out" | sed 's/.*| //' || true
[ "$total" -eq 0 ] && [ "$crashed" -eq 0 ]
