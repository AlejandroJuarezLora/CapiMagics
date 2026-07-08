v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 70 430 870 830 {flags=graph
y1=3.2
y2=3.3
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
node=vsyn}
N -350 0 -350 20 {lab=VDD}
N 260 -50 260 30 {lab=vsyn}
N 260 30 320 30 {lab=vsyn}
N 360 -170 360 -0 {lab=VDD}
N 210 -170 360 -170 {lab=VDD}
N 260 -170 260 -110 {lab=VDD}
N 80 -170 80 -120 {lab=VDD}
N 80 -170 210 -170 {lab=VDD}
N 80 -60 80 20 {lab=vsyn}
N 80 -120 80 -90 {lab=VDD}
N 80 50 160 50 {lab=VDD}
N 160 30 160 50 {lab=VDD}
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
C {symbols/nfet_03v3.sym} 340 190 0 0 {name=M5
L=0.28u
W=0.9u
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
