v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 780 -80 1370 380 {flags=graph
y1=-1.6e-17
y2=6.6e-05
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=u
x1=0
x2=3.3
divx=5
subdivx=1
node=i(vd)
color=4

unitx=1
dataset=-1}
N 250 50 290 50 {
lab=G}
N 330 -30 330 20 {
lab=S}
N 330 50 430 50 {
lab=B}
N 330 80 330 150 {
lab=D}
C {devices/lab_pin.sym} 250 50 0 0 {name=l1 sig_type=std_logic lab=G}
C {devices/lab_pin.sym} 330 -30 0 0 {name=l2 sig_type=std_logic lab=S}
C {devices/lab_pin.sym} 330 150 0 0 {name=l3 sig_type=std_logic lab=D}
C {devices/lab_pin.sym} 430 50 0 1 {name=l4 sig_type=std_logic lab=B}
C {devices/code_shown.sym} 500 10 0 0 {name=NGSPICE only_toplevel=true
value="
vg g 0 0
vd d 0 0
vs s 0 3.3
vb b 0 3.3
.control
save all
dc vd 0 3.3 0.01 vg 0 3.3 0.3
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
W=0.22u
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
C {devices/code_shown.sym} 260 290 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
"}
