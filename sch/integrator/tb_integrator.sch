v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
<<<<<<< HEAD
B 2 70 430 870 830 {flags=graph
y1=3.2
=======
L 4 670 -220 670 330 {}
L 4 670 -220 1100 -220 {}
L 4 1100 -220 1100 320 {}
L 4 670 320 1100 320 {}
L 4 -440 -240 340 -240 {}
L 4 -440 -240 -440 330 {}
L 4 -440 330 320 330 {}
L 4 320 -250 320 330 {}
B 2 450 420 1250 820 {flags=graph
y1=-0.014
>>>>>>> 8659f55 (subiendo actualizaciones al tb del integrador)
y2=3.3
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
<<<<<<< HEAD
x2=0.005
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node=v(vout)
color=4
dataset=-1
unitx=1
logx=0
logy=0
rawfile=$netlist_dir/tb_integrator.raw}
B 2 -840 390 -40 790 {flags=graph
y1=-0.32
y2=2.9
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=0.005
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node=spk1
color=4
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 530 -140 1330 260 {flags=graph
y1=2.2
y2=2.3
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=0.005
=======
x2=1e-05
>>>>>>> 8659f55 (subiendo actualizaciones al tb del integrador)
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
rawfile=$netlist_dir/tb_integrator.raw
color=4
<<<<<<< HEAD
node=vsyn}
N -350 0 -350 20 {lab=VDD}
N 260 -50 260 30 {lab=vsyn}
N 260 30 320 30 {lab=vsyn}
N 360 -170 360 -0 {lab=VDD}
N 210 -170 360 -170 {lab=VDD}
=======
node=vout}
B 2 -540 360 260 760 {flags=graph
y1=2.1844139
y2=2.876474
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=1e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="vsyn
vspk"
color="1 4"
dataset=-1
unitx=1
logx=0
logy=0
}
T {output stage} 810 340 0 0 0.4 0.4 {}
T {vcap (vgs6) should be between 2.5V and 2.8V)} 1150 50 0 0 0.4 0.4 {}
T {vgs7 controls the inversion stage from left to right} 1140 150 0 0 0.4 0.4 {}
T {setting vgs1 at 0.7 and sweeping vx, we found that 1.8V set vsyn is between 2.5V and 3.3V} -770 830 0 0 0.4 0.4 {}
T {integrator stage} -350 -210 0 0 0.4 0.4 {}
N -350 0 -350 20 {lab=VDD}
N 260 -50 260 30 {lab=vsyn}
>>>>>>> 8659f55 (subiendo actualizaciones al tb del integrador)
N 260 -170 260 -110 {lab=VDD}
N 80 -170 80 -120 {lab=VDD}
N 80 -170 210 -170 {lab=VDD}
N 80 -60 80 20 {lab=vsyn}
N 80 -120 80 -90 {lab=VDD}
N 80 50 160 50 {lab=VDD}
N 160 30 160 50 {lab=VDD}
<<<<<<< HEAD
N 0 -90 40 -90 {lab=VDD}
N 0 -170 0 -90 {lab=VDD}
N 360 60 360 160 {lab=vout}
N 80 80 80 170 {lab=#net1}
N 360 220 360 260 {lab=0}
N 80 230 80 260 {lab=0}
N 80 260 360 260 {lab=0}
N 360 190 360 220 {lab=0}
N 80 200 80 230 {lab=0}
N 360 0 360 30 {lab=VDD}
N 80 -20 260 -20 {lab=vsyn}
N -350 80 -350 110 {lab=0}
N -120 230 20 230 {lab=spk1}
N 20 200 20 230 {lab=spk1}
N 20 200 40 200 {lab=spk1}
N -120 250 -90 250 {lab=0}
N -90 250 -90 270 {lab=0}
N -120 210 -110 210 {lab=VDD}
N -110 160 -110 210 {lab=VDD}
N -570 210 -570 230 {lab=#net2}
N -570 210 -420 210 {lab=#net2}
N -570 290 -570 320 {lab=0}
N 360 110 470 110 {lab=vout}
N 0 -170 80 -170 {lab=VDD}
N 0 50 40 50 {lab=#net3}
N -70 -40 -70 -0 {lab=#net3}
N -70 -40 -0 -40 {lab=#net3}
N -0 -40 0 50 {lab=#net3}
N -70 60 -70 90 {lab=0}
N 210 190 210 280 {lab=#net4}
N 210 190 320 190 {lab=#net4}
N 210 340 210 360 {lab=0}
C {symbols/nfet_03v3.sym} 60 200 0 0 {name=M1
L=0.28u
W=9u
=======
N 80 260 80 290 {lab=0}
N 80 230 80 260 {lab=0}
N 80 -20 260 -20 {lab=vsyn}
N -350 80 -350 110 {lab=0}
N -120 230 20 230 {lab=vspk}
N -270 230 -270 250 {lab=vspk
spice_ignore=short}
N -270 230 -120 230 {lab=vspk
spice_ignore=short}
N -270 310 -270 340 {lab=0}
N 0 -170 80 -170 {lab=VDD}
N 810 30 870 30 {lab=vsyn}
N 910 -170 910 0 {lab=VDD}
N 910 60 910 160 {lab=vout}
N 910 220 910 260 {lab=0}
N 910 190 910 220 {lab=0}
N 910 0 910 30 {lab=VDD}
N 910 110 1020 110 {lab=vout}
N 760 190 870 190 {lab=#net1}
N 760 250 760 270 {lab=0
}
N 210 -170 260 -170 {lab=VDD}
N 760 30 810 30 {lab=vsyn}
N 710 30 760 30 {lab=vsyn}
N 260 30 710 30 {lab=vsyn}
N 80 80 80 90 {lab=#net2}
N 80 180 80 200 {lab=#net3}
N 40 -90 40 -20 {lab=vsyn}
N 40 -20 80 -20 {lab=vsyn}
N 20 230 40 230 {lab=vspk}
N 80 90 80 120 {lab=#net2}
N 40 50 40 100 {lab=#net2}
N 40 100 80 100 {lab=#net2}
C {symbols/nfet_03v3.sym} 60 230 0 0 {name=M1
L=0.28u
W=1u
>>>>>>> 8659f55 (subiendo actualizaciones al tb del integrador)
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
C {symbols/pfet_03v3.sym} 60 -90 0 0 {name=M2
L=0.28u
<<<<<<< HEAD
W=94u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {symbols/pfet_03v3.sym} 340 30 0 0 {name=M3
L=0.28u
W=94u
=======
W=10u
>>>>>>> 8659f55 (subiendo actualizaciones al tb del integrador)
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {symbols/pfet_03v3.sym} 60 50 0 0 {name=M4
<<<<<<< HEAD
=======
L=2.24u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {capa-2.sym} 260 -80 0 0 {name=C1
m=1
value=1p
footprint=1206
device=polarized_capacitor
}
C {vdd.sym} 210 -170 0 0 {name=l1 lab=VDD}
C {vsource.sym} -350 50 0 0 {name=V1 value=3.3 savecurrent=false}
C {gnd.sym} -350 110 0 0 {name=l2 lab=0}
C {vdd.sym} -350 0 0 0 {name=l3 lab=VDD}
C {vdd.sym} 160 30 0 0 {name=l4 lab=VDD}
C {vsource.sym} -230 150 0 0 {name=V2 value="PWL(0 3.3 200u 1.3)" savecurrent=false
spice_ignore=true}
C {gnd.sym} -270 340 0 0 {name=l9 lab=0}
C {lab_pin.sym} 1020 110 2 0 {name=p1 sig_type=std_logic lab=vout}
C {lab_pin.sym} 260 30 0 0 {name=p3 sig_type=std_logic lab=vsyn}
C {lab_pin.sym} 0 230 1 0 {name=p4 sig_type=std_logic lab=vspk}
C {code_shown.sym} -470 -500 0 0 {name=MODELS only_toplevel=true
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
C {launcher.sym} 640 -390 0 0 {name=h1
descr="load waves tran"
tclcommand="xschem raw_read /headless/.xschem/simulations/tb_integrator.raw tran"}
C {code_shown.sym} 170 -480 0 0 {name=s1 only_toplevel=false value="
.tran 10n 10u
.save all
.control
	run
	write tb_integrator.raw
.endc 
"
}
C {symbols/pfet_03v3.sym} 890 30 0 0 {name=M6
>>>>>>> 8659f55 (subiendo actualizaciones al tb del integrador)
L=0.28u
W=9u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
<<<<<<< HEAD
C {symbols/nfet_03v3.sym} 340 190 0 0 {name=M5
L=0.28u
W=0.9u
=======
C {symbols/nfet_03v3.sym} 890 190 0 0 {name=M7
L=0.28u
W=9u
>>>>>>> 8659f55 (subiendo actualizaciones al tb del integrador)
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
<<<<<<< HEAD
C {capa-2.sym} 260 -80 0 0 {name=C1
m=1
value=1p
footprint=1206
device=polarized_capacitor}
C {vdd.sym} 210 -170 0 0 {name=l1 lab=VDD}
C {vsource.sym} -350 50 0 0 {name=V1 value=3.3 savecurrent=false}
C {gnd.sym} -350 110 0 0 {name=l2 lab=0}
C {vdd.sym} -350 0 0 0 {name=l3 lab=VDD}
C {vdd.sym} 160 30 0 0 {name=l4 lab=VDD}
C {gnd.sym} -70 90 0 0 {name=l5 lab=0}
C {gnd.sym} 360 260 0 0 {name=l6 lab=0}
C {vco.sym} -270 230 0 0 {name=x1}
C {gnd.sym} -90 270 0 0 {name=l7 lab=0}
C {vdd.sym} -110 160 0 0 {name=l8 lab=VDD}
C {vsource.sym} -570 260 0 0 {name=V2 value=2.5 savecurrent=false}
C {gnd.sym} -570 320 0 0 {name=l9 lab=0}
C {lab_pin.sym} 470 110 2 0 {name=p1 sig_type=std_logic lab=vout}
C {lab_pin.sym} 260 30 0 0 {name=p3 sig_type=std_logic lab=vsyn}
C {lab_pin.sym} -20 230 1 0 {name=p4 sig_type=std_logic lab=spk1}
C {code_shown.sym} -740 -270 0 0 {name=MODELS only_toplevel=true
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
C {launcher.sym} 130 -280 0 0 {name=h1
descr="load waves"
tclcommand="xschem raw_read /headless/.xschem/simulations/tb_integrator.raw tran"}
C {code_shown.sym} -760 -10 0 0 {name=s1 only_toplevel=false value="
.tran 100n 5m
.save all
.control
	write tb_integrator.raw
.endc 
"}
C {vsource.sym} -70 30 0 0 {name=V3 value=1.8 savecurrent=false}
C {vsource.sym} 210 310 0 0 {name=V4 value=1 savecurrent=false}
C {gnd.sym} 210 360 0 0 {name=l10 lab=0}
=======
C {gnd.sym} 910 260 0 0 {name=l7 lab=0}
C {vsource.sym} 760 220 0 0 {name=V5 value=0.5 savecurrent=false
}
C {gnd.sym} 760 270 0 0 {name=l8 lab=0
}
C {vdd.sym} 910 -170 0 0 {name=l11 lab=VDD}
C {vsource.sym} 710 80 0 1 {name=V4 value="PWL(0 3.3 200u 2.3)" savecurrent=false
spice_ignore=true}
C {gnd.sym} 710 110 0 1 {name=l6 lab=0
spice_ignore=true}
C {vsource.sym} -270 280 0 1 {name=V6 value="PULSE(0 3.3 0 5n 5n 5u 10u)" savecurrent=false
}
C {gnd.sym} 80 290 0 0 {name=l10 lab=0}
C {ammeter.sym} 80 150 0 0 {name=vid savecurrent=true spice_ignore=0}
>>>>>>> 8659f55 (subiendo actualizaciones al tb del integrador)
