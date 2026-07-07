v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 640 -410 1440 -10 {flags=graph
y1=-0.0011
y2=3.3
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=0.0001
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
hilight_wave=0
color="8 7"
node="i(v1)
spike"}
N 380 -280 380 -220 {lab=fire}
N 190 -280 190 -220 {lab=integrate}
N 230 -250 380 -250 {lab=fire}
N 380 -430 380 -370 {lab=fire}
N 320 -400 380 -400 {lab=fire}
N 230 -310 230 -280 {lab=Vdd}
N 230 -220 230 -190 {lab=GND}
N 420 -310 420 -280 {lab=Vdd}
N 420 -220 420 -190 {lab=GND}
N 60 -190 420 -190 {lab=GND}
N 60 -220 60 -190 {lab=GND}
N 420 -250 530 -250 {lab=reset}
N 10 -220 20 -220 {lab=reset}
N 60 -250 190 -250 {lab=integrate}
N 320 -400 320 -250 {lab=fire}
N 420 -370 420 -340 {lab=GND}
N 420 -460 420 -430 {lab=Vdd}
N 420 -400 560 -400 {lab=spike}
N 10 -220 10 -150 {lab=reset}
N 540 -250 540 -150 {lab=reset}
N 530 -250 540 -250 {lab=reset}
N 540 -150 540 -130 {lab=reset}
N 390 -130 540 -130 {lab=reset}
N 130 -130 390 -130 {lab=reset}
N 130 -140 130 -130 {lab=reset}
N 130 -150 130 -140 {lab=reset}
N 10 -150 130 -150 {lab=reset}
C {symbols/pfet_03v3.sym} 210 -280 0 0 {name=M1
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 210 -220 0 0 {name=M2
L=0.28u
W=0.22u
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
C {symbols/pfet_03v3.sym} 400 -280 0 0 {name=M3
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 400 -220 0 0 {name=M4
L=0.28u
W=0.22u
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
C {symbols/pfet_03v3.sym} 400 -430 0 0 {name=M7
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 400 -370 0 0 {name=M8
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 40 -220 0 0 {name=M5
L=50u
W=1.25u
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
C {lab_pin.sym} 230 -310 2 0 {name=p1 sig_type=std_logic lab=Vdd}
C {lab_pin.sym} 420 -310 2 0 {name=p2 sig_type=std_logic lab=Vdd}
C {lab_pin.sym} 420 -460 2 0 {name=p3 sig_type=std_logic lab=Vdd}
C {gnd.sym} 230 -190 0 0 {name=l1 lab=GND}
C {lab_pin.sym} 560 -400 2 0 {name=p4 sig_type=std_logic lab=spike}
C {vsource.sym} 120 -410 0 0 {name=V1 value=3.3 savecurrent=false}
C {gnd.sym} 120 -380 0 0 {name=l2 lab=GND}
C {lab_pin.sym} 120 -440 2 0 {name=p5 sig_type=std_logic lab=Vdd}
C {isource.sym} 60 -280 0 0 {name=I0 value=100n}
C {lab_pin.sym} 60 -310 2 0 {name=p6 sig_type=std_logic lab=Vdd}
C {devices/code.sym} 0 -110 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
"}
C {capa-2.sym} 130 -220 0 0 {name=C1
m=1
value=150f
footprint=1206
device=polarized_capacitor}
C {code_shown.sym} 150 -100 0 0 {name=spice only_toplevel=false value=".tran 0.1n 100u
.control
 save all
 run
 write neurona.raw
.endc"}
C {lab_pin.sym} 160 -250 1 0 {name=p7 sig_type=std_logic lab=integrate}
C {lab_pin.sym} 350 -250 1 0 {name=p8 sig_type=std_logic lab=fire}
C {lab_pin.sym} 540 -250 1 0 {name=p9 sig_type=std_logic lab=reset}
C {gnd.sym} 420 -340 0 0 {name=l3 lab=GND}
