v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 -310 250 490 650 {flags=graph
y1=-0.036
y2=6.7
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
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
B 2 490 250 1290 650 {flags=graph
y1=-0.13
y2=6.7
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
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
B 2 -320 740 480 1140 {flags=graph
y1=9e-11
y2=3.3
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
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
B 2 480 740 1280 1140 {flags=graph
y1=2.2180652
y2=2.2314869
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
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
B 2 1510 250 2310 650 {flags=graph
y1=-0.2
y2=6.9
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"N1pre; vpre1_pex\\"
\\"N2pre; vpre2_pex 3.3 +\\""
color="4 7"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 2360 250 3160 650 {flags=graph
y1=-0.17
y2=6.9
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"N1post; vpost1_pex\\"
\\"N2post; vpost2_pex 3.3 +\\""
color="4 7"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 2350 760 3150 1160 {flags=graph
y1=0.53807212
y2=0.56638367
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"vw11; vw11_pex\\"
\\"vw42; vw42_pex\\""
color="4 5"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 1500 750 2300 1150 {flags=graph
y1=0.68
y2=2.7
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
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
B 2 1950 1310 2750 1710 {flags=graph
y1=2.2420033
y2=2.2556833
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
color="4 5 8 9 12 16"
node="x2.stdp_4x2_0.stdp_0.vw
x2.stdp_4x2_0.stdp_2.vw
x2.stdp_4x2_0.stdp_3.vw
x2.stdp_4x2_0.stdp_4.vw
x2.stdp_4x2_0.stdp_5.vw
x2.stdp_4x2_0.stdp_6.vw"}
T {The voltage level of un-probed synaptic weights
(capacitance's value of each cell) goes up to 2.25,
as in pre-layout simulation} 2080 1730 0 0 0.4 0.4 {}
T {two of four spikes of the input layer} -100 650 0 0 0.4 0.4 {}
T {same input signal than prelayout} -100 1140 0 0 0.4 0.4 {}
T {spikes at the output layer} 750 650 0 0 0.4 0.4 {}
T {evolution of the two probed 
synaptic weights. Nominal voltage 
of 2.25V} 750 1150 0 0 0.4 0.4 {}
T {Pre-layout} 390 160 0 0 0.8 0.8 {}
T {Post-layout} 2210 170 0 0 0.8 0.8 {}
T {two of four spikes of the input layer, postlayout.
It works fine, but a bit slower than prelayout} 1670 650 0 0 0.4 0.4 {}
T {spikes at the output layer.
Also, they work properly, but slower rate} 2680 650 0 0 0.4 0.4 {}
T {input signal, sinusoidal
and its complementary signal} 1740 1160 0 0 0.4 0.4 {}
T {synaptic weight values evolve nicely
but there is a drop in voltage. These are 
the only two synaptic weights that are being probed} 2500 1170 0 0 0.4 0.4 {}
C {full_4x2_lvs.sym} 250 -10 0 0 {name=x1
}
C {vsource.sym} -190 20 0 0 {name=V2 value="SINE(1.65 1.65 5000 0 0 0)" savecurrent=false}
C {vsource.sym} -50 20 0 0 {name=V3 value="SINE(1.65 1.65 5000 0 0 180)" savecurrent=false}
C {gnd.sym} -50 50 0 0 {name=l21 lab=GND}
C {gnd.sym} -190 50 0 0 {name=l22 lab=GND}
C {lab_pin.sym} -190 -10 0 0 {name=p13 sig_type=std_logic lab=Vin}
C {lab_pin.sym} -50 -10 0 0 {name=p14 sig_type=std_logic lab=Vin_neg}
C {lab_pin.sym} 100 -80 0 0 {name=p15 sig_type=std_logic lab=Vin
}
C {lab_pin.sym} 100 -60 0 0 {name=p16 sig_type=std_logic lab=Vin_neg
}
C {vsource.sym} -290 30 0 0 {name=V4 value=3.3 savecurrent=false}
C {vdd.sym} -290 0 0 0 {name=l17 lab=VDD}
C {gnd.sym} -290 60 0 0 {name=l18 lab=0}
C {vdd.sym} 400 -80 1 0 {name=l1 lab=VDD
}
C {gnd.sym} 400 -60 3 0 {name=l2 lab=0
}
C {lab_pin.sym} 400 -40 0 1 {name=p3 sig_type=std_logic lab=vpre1
}
C {lab_pin.sym} 400 -20 0 1 {name=p5 sig_type=std_logic lab=vpre2
}
C {lab_pin.sym} 400 40 0 1 {name=p17 sig_type=std_logic lab=vpost1
}
C {lab_pin.sym} 400 60 0 1 {name=p19 sig_type=std_logic lab=vpost2
}
C {lab_pin.sym} 400 0 0 1 {name=p1 sig_type=std_logic lab=vw11
}
C {lab_pin.sym} 400 20 0 1 {name=p2 sig_type=std_logic lab=vw42
}
C {code_shown.sym} -500 -480 0 0 {name=s1 only_toplevel=false value=".include /foss/designs/libs/snn_analog/sch/D14_topcell_flat.spice
.tran 10n 20u
.save Vin vin_neg vpre1_pex vpre2_pex vw11_pex vw42_pex vpost1_pex vpost2_pex
.save x2.stdp_4x2_0.stdp_0.vw x2.stdp_4x2_0.stdp_1.vw x2.stdp_4x2_0.stdp_2.vw x2.stdp_4x2_0.stdp_3.vw x2.stdp_4x2_0.stdp_4.vw x2.stdp_4x2_0.stdp_5.vw x2.stdp_4x2_0.stdp_6.vw x2.stdp_4x2_0.stdp_7.vw 
.save vpre1 vpre2 vw11 vw42 vpost1 vpost2
.control
	set num_threads = 8
	option klu
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
