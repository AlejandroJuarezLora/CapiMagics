fvf_code_string = """
from glayout import MappedPDK, sky130 , gf180
# from gdsfactory.cell import cell
from gdsfactory import Component
from gdsfactory.components import text_freetype, rectangle

from glayout import nmos, pmos
from glayout import via_stack
from glayout import rename_ports_by_orientation
from glayout import tapring

from glayout.util.comp_utils import evaluate_bbox, prec_center, prec_ref_center, align_comp_to_port
from glayout.util.port_utils import add_ports_perimeter,print_ports
from glayout.util.snap_to_grid import component_snap_to_grid
from glayout.spice.netlist import Netlist

from glayout.routing.straight_route import straight_route
from glayout.routing.c_route import c_route
from glayout.routing.L_route import L_route


# Environment bootstrap — both iic-osic-tools and bare-venv. See HOW_TO_RUN.md.
import os
import subprocess
try:
    _printenv = subprocess.run(
        ['bash', '-c', 'source ~/.bashrc 2>/dev/null && printenv'],
        text=True, capture_output=True, timeout=10,
    ).stdout
    for _line in _printenv.splitlines():
        if '=' in _line:
            _k, _v = _line.split('=', 1)
            os.environ.setdefault(_k, _v)
except Exception:
    pass
if 'PDK_ROOT' in os.environ and 'PDK' in os.environ:
    os.environ.setdefault('PDKPATH', os.path.join(os.environ['PDK_ROOT'], os.environ['PDK']))

def 
def add_stdp_cell_labels(
    stdp_in: Component,
    pdk: MappedPDK,
    ) -> Component:
    stdp_in.unlock()

    psize=(0.5,0.5)
    # list that will contain all port/comp info
    move_info = list()
    # create labels and append to info list

    # gnd
    gndlabel = rectangle(layer=pdk.get_glayer("met2_pin"),size=psize,centered=True).copy()
    gndlabel.add_label(text="VBULK",layer=pdk.get_glayer("met2_label"))
    move_info.append((gndlabel,fvf_in.ports["B_tie_N_top_met_N"],None))
    #gnd_ref = top_level << gndlabel;
    
    
    
    #currentbias
    ibiaslabel = rectangle(layer=pdk.get_glayer("met3_pin"),size=psize,centered=True).copy()
    ibiaslabel.add_label(text="Ib",layer=pdk.get_glayer("met3_pin"))
    move_info.append((ibiaslabel,fvf_in.ports["A_drain_top_met_N"],None))
    #ib_ref = top_level << ibiaslabel;
    
    
    # output
    outputlabel = rectangle(layer=pdk.get_glayer("met3_pin"),size=psize,centered=True).copy()
    outputlabel.add_label(text="VOUT",layer=pdk.get_glayer("met3_pin"))
    move_info.append((outputlabel,fvf_in.ports["A_source_top_met_N"],None))
    #op_ref = top_level << outputlabel;
    
    
    # input
    inputlabel = rectangle(layer=pdk.get_glayer("met2_pin"),size=psize,centered=True).copy()
    inputlabel.add_label(text="VIN",layer=pdk.get_glayer("met2_pin"))
    move_info.append((inputlabel,fvf_in.ports["A_gate_top_met_N"], None))
    #ip_ref = top_level << inputlabel;
    
    
    # move everything to position
    for comp, prt, alignment in move_info:
        alignment = ('c','b') if alignment is None else alignment
        compref = align_comp_to_port(comp, prt, alignment=alignment)
        fvf_in.add(compref)
        
    return fvf_in.flatten() 

if __name__ == "__main__":
\tcomp = flipped_voltage_follower(gf180, device_type='nmos')\n
\t# comp.pprint_ports()\n
\tcomp = add_fvf_labels(comp, gf180)\n
\tcomp.name = "FVF"\n
\tcomp.write_gds('out_FVF.gds')\n
\tcomp.show()\n
\tprint("...Running DRC...")\n
\tdrc_result = gf180.drc_magic(comp, "FVF")\n
\t#drc_result = gf180.drc(comp)\n

"""

fvf_init_string = """
###Glayout STDP Cell.


from .my_FVF import flipped_voltage_follower,add_fvf_labels

__all__ = [
    'stdp_cell',
    'add_stdp_cell_labels',
] 
"""

directory = "./FVF/"
os.makedirs(directory, exist_ok=True)

# Save to a .py file
with open(directory + "my_FVF.py", "w") as file:
    file.write(fvf_code_string)

with open(directory + "__init__.py", "w") as file:
    file.write(fvf_init_string)