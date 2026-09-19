v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 -320 120 480 520 {flags=graph
y1=-0.036
y2=6.7
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-8e-05
x2=0.00012
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"N1pre; vpre1\\"
\\"N2pre; vpre2 3.3 +\\""
color="4 7"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 480 120 1280 520 {flags=graph
y1=-0.13
y2=6.7
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-8e-05
x2=0.00012
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"N1post; vpost1\\"
\\"N2post; vpost2 3.3 +\\""
color="4 7"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 -320 520 480 920 {flags=graph
y1=9e-11
y2=3.3
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-8e-05
x2=0.00012
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"vin; vin\\"
\\"vin_neg; vin_neg\\""
color="4 7"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 480 520 1280 920 {flags=graph
y1=2.2217121
y2=2.2351338
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-8e-05
x2=0.00012
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"vw11; vw11\\"
\\"vw42; vw42\\""
color="4 7"
dataset=-1
unitx=1
logx=0
logy=0
}
C {full_4x2_lvs.sym} 250 -10 0 0 {name=x1
spice_ignore=true}
C {vsource.sym} -190 20 0 0 {name=V2 value="SINE(1.65 1.65 5000 0 0 0)" savecurrent=false}
C {vsource.sym} -50 20 0 0 {name=V3 value="SINE(1.65 1.65 5000 0 0 180)" savecurrent=false}
C {gnd.sym} -50 50 0 0 {name=l21 lab=GND}
C {gnd.sym} -190 50 0 0 {name=l22 lab=GND}
C {lab_pin.sym} -190 -10 0 0 {name=p13 sig_type=std_logic lab=Vin}
C {lab_pin.sym} -50 -10 0 0 {name=p14 sig_type=std_logic lab=Vin_neg}
C {lab_pin.sym} 100 -80 0 0 {name=p15 sig_type=std_logic lab=Vin
spice_ignore=true}
C {lab_pin.sym} 100 -60 0 0 {name=p16 sig_type=std_logic lab=Vin_neg
spice_ignore=true}
C {vsource.sym} -290 30 0 0 {name=V4 value=3.3 savecurrent=false}
C {vdd.sym} -290 0 0 0 {name=l17 lab=VDD}
C {gnd.sym} -290 60 0 0 {name=l18 lab=0}
C {vdd.sym} 400 -80 1 0 {name=l1 lab=VDD
spice_ignore=true}
C {gnd.sym} 400 -60 3 0 {name=l2 lab=0
spice_ignore=true}
C {lab_pin.sym} 400 -40 0 1 {name=p3 sig_type=std_logic lab=vpre1
spice_ignore=true}
C {lab_pin.sym} 400 -20 0 1 {name=p5 sig_type=std_logic lab=vpre2
spice_ignore=true}
C {lab_pin.sym} 400 40 0 1 {name=p17 sig_type=std_logic lab=vpost1
spice_ignore=true}
C {lab_pin.sym} 400 60 0 1 {name=p19 sig_type=std_logic lab=vpost2
spice_ignore=true}
C {lab_pin.sym} 400 0 0 1 {name=p1 sig_type=std_logic lab=vw11
spice_ignore=true}
C {lab_pin.sym} 400 20 0 1 {name=p2 sig_type=std_logic lab=vw42
spice_ignore=true}
C {code_shown.sym} -520 -310 0 0 {name=s1 only_toplevel=false value=".include /foss/designs/libs/snn_analog/sch/full_4x2_pex.spice
.tran 1n 200u
.save all
.control
	run
	write tb_full_4x2_pl.raw
.endc 

"}
C {devices/code_shown.sym} 30 -310 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
* .lib $::180MCU_MODELS/sm141064.ngspice res_statistical
"}
C {launcher.sym} 260 -140 0 0 {name=h5
descr="load waves"
tclcommand="xschem raw_read $netlist_dir/tb_full_4x2_pl.raw tran"
}
C {full_4x2_pex.sym} 830 0 0 0 {name=x2
}
C {vdd.sym} 980 -70 1 0 {name=l3 lab=VDD
}
C {gnd.sym} 980 -50 3 0 {name=l4 lab=0
}
C {lab_pin.sym} 980 -30 0 1 {name=p7 sig_type=std_logic lab=vpre1_pex
}
C {lab_pin.sym} 980 -10 0 1 {name=p8 sig_type=std_logic lab=vpre2_pex
}
C {lab_pin.sym} 980 50 0 1 {name=p9 sig_type=std_logic lab=vpost1_pex
}
C {lab_pin.sym} 980 70 0 1 {name=p10 sig_type=std_logic lab=vpost2_pex
}
C {lab_pin.sym} 980 10 0 1 {name=p11 sig_type=std_logic lab=vw11_pex
}
C {lab_pin.sym} 980 30 0 1 {name=p12 sig_type=std_logic lab=vw42_pex
}
C {lab_pin.sym} 680 -70 0 0 {name=p4 sig_type=std_logic lab=Vin
}
C {lab_pin.sym} 680 -50 0 0 {name=p6 sig_type=std_logic lab=Vin_neg
}
