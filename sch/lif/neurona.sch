v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
F {}
E {}
L 4 320 -460 900 -460 {}
L 4 320 -270 900 -270 {}
L 4 900 -460 900 -270 {}
L 4 320 -460 320 -270 {}
L 4 640 -630 640 -460 {}
L 4 640 -630 900 -630 {}
L 4 900 -630 900 -460 {}
B 2 20 -260 1460 -20 {flags=graph
y1=-0.00078
y2=3.4
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-4.0099038e-06
x2=0.00019599009
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
hilight_wave=0
color=5
node=spike}
T {LIF Neuron} 610 -690 0 0 0.6 0.6 {}
T {LIF neuron} 840 -290 0 0 0.2 0.2 {}
T {Output (spikes)} 820 -630 0 0 0.2 0.2 {}
T {-The maximum frequency achieved is 1 MHz at 200 nA.

-The transistor M5 behaves like a resistor when it is off
 and leaks current when it is on.

-When the voltage in the transistor exceeds the threshold
 voltage (the inverter’s switching voltage), a spike is
 generated.

-The output is obtained from the spike_neg node by inserting
 an additional inverter, so as not to disturb the neuron’s
 spike/reset signal.

-A transient analysis was performed by varying the current
 source from 0 A to 200 nA and from 200 nA to 0 A.} 930 -620 0 0 0.3 0.3 {}
N 710 -420 710 -360 {lab=spike_neg}
N 520 -420 520 -360 {lab=Iex}
N 560 -390 710 -390 {lab=spike_neg}
N 710 -570 710 -510 {lab=spike_neg}
N 650 -540 710 -540 {lab=spike_neg}
N 560 -450 560 -420 {lab=Vdd}
N 560 -360 560 -330 {lab=GND}
N 750 -450 750 -420 {lab=Vdd}
N 750 -360 750 -330 {lab=GND}
N 390 -330 750 -330 {lab=GND}
N 390 -360 390 -330 {lab=GND}
N 750 -390 860 -390 {lab=spike/reset}
N 340 -360 350 -360 {lab=spike/reset}
N 390 -390 520 -390 {lab=Iex}
N 650 -540 650 -390 {lab=spike_neg}
N 750 -510 750 -480 {lab=GND}
N 750 -600 750 -570 {lab=Vdd}
N 340 -360 340 -290 {lab=spike/reset}
N 860 -390 870 -390 {lab=spike/reset}
N 340 -290 460 -290 {lab=spike/reset}
N 750 -540 840 -540 {lab=spike}
N 870 -390 870 -310 {lab=spike/reset}
N 690 -310 870 -310 {lab=spike/reset}
N 690 -310 690 -290 {lab=spike/reset}
N 460 -290 690 -290 {lab=spike/reset}
C {symbols/pfet_03v3.sym} 540 -420 0 0 {name=M1
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
C {symbols/nfet_03v3.sym} 540 -360 0 0 {name=M2
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
C {symbols/pfet_03v3.sym} 730 -420 0 0 {name=M3
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
C {symbols/nfet_03v3.sym} 730 -360 0 0 {name=M4
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
C {symbols/pfet_03v3.sym} 730 -570 0 0 {name=M7
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
C {symbols/nfet_03v3.sym} 730 -510 0 0 {name=M8
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
C {symbols/nfet_03v3.sym} 370 -360 0 0 {name=M5
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
C {lab_pin.sym} 560 -450 2 0 {name=p1 sig_type=std_logic lab=Vdd}
C {lab_pin.sym} 750 -450 2 0 {name=p2 sig_type=std_logic lab=Vdd}
C {lab_pin.sym} 750 -600 2 0 {name=p3 sig_type=std_logic lab=Vdd}
C {gnd.sym} 560 -330 0 0 {name=l1 lab=GND}
C {lab_pin.sym} 840 -540 2 0 {name=p4 sig_type=std_logic lab=spike}
C {vsource.sym} 330 -550 0 0 {name=V1 value=3.3 savecurrent=false}
C {gnd.sym} 330 -520 0 0 {name=l2 lab=GND}
C {lab_pin.sym} 330 -580 2 0 {name=p5 sig_type=std_logic lab=Vdd}
C {isource.sym} 400 -550 0 0 {name=I0 value="pwl(0 0 95u 200n 105u 200n 200u 0)"}
C {lab_pin.sym} 400 -580 2 0 {name=p6 sig_type=std_logic lab=Vdd}
C {devices/code.sym} 50 -600 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
"}
C {capa-2.sym} 460 -360 0 0 {name=C1
m=1
value=150f
footprint=1206
device=polarized_capacitor}
C {code_shown.sym} 60 -420 0 0 {name=spice only_toplevel=false value=".tran 0.1n 200u
.control
 save all
 run
 write neurona.raw
.endc"}
C {lab_pin.sym} 690 -300 0 1 {name=p9 sig_type=std_logic lab=spike/reset}
C {gnd.sym} 750 -480 0 0 {name=l3 lab=GND}
C {lab_pin.sym} 680 -390 1 0 {name=p8 sig_type=std_logic lab=spike_neg}
C {lab_pin.sym} 400 -520 0 1 {name=p10 sig_type=std_logic lab=Iex}
C {lab_pin.sym} 390 -390 3 1 {name=p7 sig_type=std_logic lab=Iex}
C {lab_pin.sym} 520 -410 2 1 {name=p11 sig_type=std_logic lab=integration}
