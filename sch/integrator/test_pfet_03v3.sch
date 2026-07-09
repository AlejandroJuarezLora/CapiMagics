v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 1110 -90 1700 370 {flags=graph
y1=-1.3e-15
y2=0.0007
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=u
x1=0.165
x2=3.465
divx=5
subdivx=1
node="\\"current; 0 i(vsd) -\\""
color=4

unitx=1
dataset=-1}
B 2 1110 -560 1700 -100 {flags=graph
y1=1.4389901e-05
y2=6.8506491e-05
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=u
x1=0.165
x2=3.465
divx=5
subdivx=1
node="\\"current; 0 i(vsd) - deriv()\\""
color=4

unitx=1
dataset=-1}
N 250 50 290 50 {
lab=G}
N 330 -30 330 20 {
lab=S}
N 330 50 430 50 {
lab=S}
N 330 80 330 150 {
lab=#net1}
N 220 50 250 50 {lab=G}
N 330 150 330 200 {lab=#net1}
N 610 -40 610 10 {lab=S}
N 330 -40 510 -40 {lab=S}
N 330 -40 330 -30 {lab=S}
N 330 200 510 200 {lab=#net1}
N 430 50 440 50 {lab=S}
N 510 -40 610 -40 {lab=S}
N 550 -40 550 40 {lab=S}
N 550 100 550 200 {lab=#net1}
N 510 200 550 200 {lab=#net1}
N 440 -40 440 50 {lab=S}
N 220 30 220 50 {lab=G}
N 220 -40 330 -40 {lab=S}
N 220 -40 220 -30 {lab=S}
C {devices/lab_pin.sym} 250 50 1 0 {name=l1 sig_type=std_logic lab=G}
C {devices/lab_pin.sym} 330 -30 0 0 {name=l2 sig_type=std_logic lab=S}
C {devices/code_shown.sym} 770 20 0 0 {name=NGSPICE only_toplevel=true
value="
*obtainng lambda1
.save all

.control
	dc vsd 0 3.3 0.01 vsg 0 3.3 0.3
	write test_pfet_03v3.raw
	
.endc
"}
C {devices/launcher.sym} 385 -175 0 0 {name=h1
descr="Click left mouse button here with control key
pressed to load/unload waveforms in graph."
tclcommand="
xschem raw_read $netlist_dir/[file tail [file rootname [xschem get current_name]]].raw
"
}
C {symbols/pfet_03v3.sym} 310 50 0 0 {name=M1
L=0.28u
W=2.8u
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {devices/code_shown.sym} 190 280 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
"}
C {vsource.sym} 220 0 0 0 {name=vsg value=0 savecurrent=false}
C {vsource.sym} 610 40 0 0 {name=vdd value=3.3 savecurrent=false}
C {gnd.sym} 610 70 0 0 {name=l5 lab=0}
C {vsource.sym} 550 70 0 0 {name=vsd value=0 savecurrent=false}
