v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -250 -150 -130 -150 {lab=avss}
N -130 -210 -130 -150 {lab=avss}
N -250 -120 -250 -110 {lab=vm}
N -250 -110 -80 -110 {lab=vm}
N -80 -150 -80 -110 {lab=vm}
N -20 -150 80 -150 {lab=vm}
N 80 -150 80 -80 {lab=vm}
N 220 -150 220 -120 {lab=vm}
N 80 -150 220 -150 {lab=vm}
N 160 -90 180 -90 {lab=vg}
N 160 -90 160 -20 {lab=vg}
N 160 -20 220 -20 {lab=vg}
N 220 -60 220 -20 {lab=vg}
N 220 -20 220 30 {lab=vg}
N 160 60 180 60 {lab=I_50n}
N 160 60 160 190 {lab=I_50n}
N 130 190 160 190 {lab=I_50n}
N 220 90 220 160 {lab=avss}
N 90 110 90 160 {lab=I_50n}
N 140 140 140 190 {lab=I_50n}
N 90 140 140 140 {lab=I_50n}
N 90 220 90 250 {lab=avss}
N 90 190 90 220 {lab=avss}
N -250 -220 -250 -180 {lab=avdd}
N 220 -90 290 -90 {lab=avdd}
N -30 -20 80 -20 {lab=avss}
N 220 60 220 90 {lab=avss}
N -440 -150 -400 -150 {lab=Vext_pin}
N -340 -150 -290 -150 {lab=Vext_pin}
N -400 -150 -340 -150 {lab=Vext_pin}
N -460 -150 -440 -150 {lab=Vext_pin}
N -80 -150 -20 -150 {lab=vm}
N 220 160 220 250 {lab=avss}
N 90 250 220 250 {lab=avss}
C {symbols/pfet_03v3.sym} 200 -90 0 0 {name=M1
L=.28u
W=1u
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
C {symbols/nfet_03v3.sym} -270 -150 2 1 {name=M6
L=0.28u
W=1u
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} 200 60 2 1 {name=M2
L=0.28u
W=1u
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} 110 190 0 1 {name=M3
L=0.28u
W=1u
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
C {lab_pin.sym} -250 -220 0 0 {name=p1 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 290 -90 2 0 {name=p2 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 130 -150 1 0 {name=p4 sig_type=std_logic lab=vm}
C {lab_pin.sym} 220 -30 2 0 {name=p6 sig_type=std_logic lab=vg}
C {symbols/cap_mim_2p0fF.sym} 80 -50 0 0 {name=C3
W=17.68e-6
L=17.68e-6
model=cap_mim_2f0fF
spiceprefix=X
m=8
}
C {ipin.sym} -460 -150 0 0 {name=p5 lab=Vext_pin}
C {iopin.sym} -520 -280 0 0 {name=p7 lab=avdd}
C {iopin.sym} -520 -230 0 0 {name=p8 lab=avss}
C {lab_pin.sym} -130 -210 0 0 {name=p9 sig_type=std_logic lab=avss}
C {lab_pin.sym} 90 250 0 0 {name=p10 sig_type=std_logic lab=avss}
C {ipin.sym} 90 110 0 0 {name=p11 lab=I_50n}
C {lab_pin.sym} -30 -20 0 0 {name=p3 sig_type=std_logic lab=avss}
