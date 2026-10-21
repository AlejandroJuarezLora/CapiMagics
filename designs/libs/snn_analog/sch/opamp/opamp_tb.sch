v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -220 20 -220 50 {lab=VDD}
N -220 110 -220 140 {lab=GND}
N 30 120 30 170 {lab=GND}
N -100 90 -100 100 {lab=vin}
N -100 90 -30 90 {lab=vin}
N -100 160 -100 180 {lab=GND}
N -100 50 -30 50 {lab=vout}
N -100 -50 -100 50 {lab=vout}
N -100 -50 160 -50 {lab=vout}
N 160 -50 160 70 {lab=vout}
N 100 70 160 70 {lab=vout}
N 30 0 30 20 {lab=VDD}
C {vdd.sym} -220 20 0 0 {name=l1 lab=VDD}
C {gnd.sym} -220 140 0 0 {name=l2 lab=GND}
C {gnd.sym} 30 170 0 0 {name=l3 lab=GND}
C {gnd.sym} -100 180 0 0 {name=l4 lab=GND}
C {vsource.sym} -220 80 0 0 {name=V1 value=3.3 savecurrent=false}
C {code_shown.sym} 90 -240 0 0 {name=spice only_toplevel=false value=".include /foss/designs/libs/snn_analog/sch/opamp/PEX/opamp_pex.spice
.dc V2 0 3.3 0.01
.control
 run

 plot v(vin) v(vout)
 write opamp_tb.raw
.endc"}
C {vsource.sym} -100 130 0 0 {name=V2 value=1.6 savecurrent=false}
C {vdd.sym} 30 0 0 0 {name=l5 lab=VDD}
C {lab_pin.sym} 160 70 0 1 {name=p1 sig_type=std_logic lab=vout}
C {lab_pin.sym} -100 90 0 0 {name=p2 sig_type=std_logic lab=vin}
C {code.sym} -170 -240 0 0 {name=MODELS_GF only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
* .lib $::180MCU_MODELS/sm141064.ngspice res_statistical
"
}
C {libs/snn_analog/sch/opamp/opamp.sym} 460 190 0 0 {name=x1
spice_ignore=true}
C {libs/snn_analog/sch/opamp/opamp_pex.sym} 80 140 0 0 {name=x2
}
