#!/bin/bash
# Full-chip LVS: final GDS against the hierarchical schematic.
#
#   source : sch/full_4x2_lvs.sch -> xschem -> full_4x2_lvs.spice (this dir)
#   layout : runs/test/final/gds/D14_topcell.gds -> magic -> extracted netlist
#   compare: netgen with the PDK setup -> D14_topcell_lvs.rpt (this dir)
#
# Run inside the iic-osic-tools container: bash run_lvs.sh
# Exits 0 only if the topology matches AND there are no property errors
# (FET W/L, MIM c_width/c_length).
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
SNN=$(dirname "$HERE")
PDK_ROOT=${PDK_ROOT:-/foss/pdks}
PDK=${PDK:-gf180mcuD}
TECH=$PDK_ROOT/$PDK/libs.tech
GDS=$SNN/runs/test/final/gds/D14_topcell.gds
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# 1. Source: netlist generated from the schematic, never edited by hand.
cat > "$TMP/xschemrc" <<EOF
source $TECH/xschem/xschemrc
append XSCHEM_LIBRARY_PATH :$SNN/sch
set top_is_subckt 1
EOF
(cd "$SNN/sch" && xschem --rcfile "$TMP/xschemrc" -n -s -q -x \
    -o "$HERE" -N full_4x2_lvs.spice full_4x2_lvs.sch)

# 2. Layout: hierarchical extraction of the final GDS.
cat > "$TMP/ext.tcl" <<EOF
gds read $GDS
load D14_topcell
select top cell
extract path $TMP
extract all
ext2spice lvs
ext2spice -p $TMP -o $TMP/D14_topcell.spice
quit -noprompt
EOF
magic -dnull -noconsole -rcfile "$TECH/magic/$PDK.magicrc" "$TMP/ext.tcl" > "$TMP/magic.log" 2>&1

# 3. Comparison.
RPT=$HERE/D14_topcell_lvs.rpt
netgen -batch lvs "$TMP/D14_topcell.spice D14_topcell" \
    "$HERE/full_4x2_lvs.spice full_4x2_lvs" \
    "$TECH/netgen/${PDK}_setup.tcl" "$RPT" > "$TMP/netgen.log" 2>&1

# 4. Verdict. "Circuits match uniquely" is not enough: netgen still prints it
#    when W or c_width differ, and only adds "match uniquely with property
#    errors" plus "delta=" lines. Checked by setting M17 W=0.3 on purpose.
if grep -q "Final result: Circuits match uniquely" "$RPT" \
   && ! grep -qiE "property errors|delta=" "$RPT"; then
    echo "LVS PASS: topology and properties match ($RPT)"
else
    echo "LVS FAIL: see $RPT"
    grep -E "Final result|property errors|delta=" "$RPT" | head -20
    exit 1
fi
