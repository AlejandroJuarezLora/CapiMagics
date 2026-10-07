v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {w/l = 173} 530 -130 0 0 0.4 0.4 {}
N -0 -0 0 30 {lab=#net1}
N 0 30 230 30 {lab=#net1}
N 230 0 230 30 {lab=#net1}
N 120 30 120 80 {lab=#net1}
N 120 140 120 210 {lab=avss}
N 120 210 430 210 {lab=avss}
N 440 140 440 200 {lab=avss}
N -210 210 120 210 {lab=avss}
N -210 140 -210 210 {lab=avss}
N -210 -150 -210 80 {lab=vb}
N -170 -180 -140 -180 {lab=vb}
N -140 -180 -140 -100 {lab=vb}
N -210 -100 -140 -100 {lab=vb}
N -210 -290 -210 -210 {lab=avdd}
N -210 -290 440 -290 {lab=avdd}
N 440 -290 440 -250 {lab=avdd}
N 230 -290 230 -180 {lab=avdd}
N 0 -290 -0 -180 {lab=avdd}
N 0 -180 0 -150 {lab=avdd}
N 230 -180 230 -150 {lab=avdd}
N 440 -250 440 -220 {lab=avdd}
N -210 -210 -210 -180 {lab=avdd}
N 440 200 440 210 {lab=avss}
N 430 210 440 210 {lab=avss}
N 440 110 440 140 {lab=avss}
N 120 110 120 140 {lab=avss}
N -210 110 -210 140 {lab=avss}
N 0 -30 230 -30 {lab=avss}
N 230 -120 230 -70 {lab=x}
N 230 -70 230 -60 {lab=x}
N -0 -120 -0 -60 {lab=y}
N 40 -150 180 -150 {lab=y}
N 180 -150 190 -150 {lab=y}
N 120 -150 120 -90 {lab=y}
N 0 -90 120 -90 {lab=y}
N 230 -110 400 -110 {lab=x}
N 440 -220 440 -140 {lab=avdd}
N 440 -80 440 80 {lab=vout}
N 440 -140 440 -110 {lab=avdd}
N 330 -110 330 -80 {lab=x}
N 330 -20 440 -20 {lab=vout}
N -170 110 80 110 {lab=vb}
N -210 30 -110 30 {lab=vb}
N -110 30 -110 110 {lab=vb}
N 230 110 400 110 {lab=vb}
N 230 110 230 160 {lab=vb}
N 20 160 230 160 {lab=vb}
N 20 110 20 160 {lab=vb}
C {symbols/nfet_03v3.sym} -20 -30 0 0 {name=M1
L=1u
W=5u
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
C {symbols/nfet_03v3.sym} 250 -30 0 1 {name=M2
L=1u
W=5u
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
C {symbols/pfet_03v3.sym} 20 -150 0 1 {name=M3
L=1u
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
C {symbols/pfet_03v3.sym} 210 -150 0 0 {name=M4
L=1u
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
C {symbols/nfet_03v3.sym} 100 110 0 0 {name=M5
L=1u
W=8u
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
C {symbols/pfet_03v3.sym} 420 -110 0 0 {name=M6
L=1u
W=28.8u
nf=6
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
C {symbols/nfet_03v3.sym} 420 110 0 0 {name=M7
L=1u
W=7u
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
C {symbols/nfet_03v3.sym} -190 110 0 1 {name=M8
L=1u
W=8u
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
C {symbols/pfet_03v3.sym} -190 -180 0 1 {name=M9
L=1u
W=1u
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
C {iopin.sym} 60 -290 3 0 {name=p1 lab=avdd}
C {iopin.sym} 120 210 1 0 {name=p2 lab=avss}
C {ipin.sym} -40 -30 3 0 {name=p3 lab=vin1}
C {ipin.sym} 270 -30 3 0 {name=p4 lab=vin2}
C {lab_pin.sym} 230 -100 0 0 {name=p5 sig_type=std_logic lab=x}
C {lab_pin.sym} 0 -90 0 0 {name=p6 sig_type=std_logic lab=y}
C {lab_pin.sym} -210 0 0 0 {name=p7 sig_type=std_logic lab=vb}
C {lab_pin.sym} 120 -30 1 0 {name=p8 sig_type=std_logic lab=avss}
C {opin.sym} 440 -10 0 0 {name=p9 lab=vout}
C {symbols/cap_mim_2f0fF.sym} 330 -50 0 0 {name=C1
W=30e-6
L=30e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
