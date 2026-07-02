v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
L 4 170 -270 830 -270 {}
L 4 170 190 830 190 {}
L 4 170 -270 170 190 {}
L 4 830 -270 830 190 {}
L 4 -770 210 -110 210 {}
L 4 -770 790 -110 790 {}
L 4 -770 210 -770 790 {}
L 4 -110 210 -110 790 {}
T {potentiation unit} 260 160 0 0 0.4 0.4 {}
T {depression unit} -380 220 0 0 0.4 0.4 {}
N 30 -20 30 40 {lab=#net1}
N 30 340 30 390 {lab=#net2}
N 610 -230 610 -200 {lab=avdd}
N 200 -230 610 -230 {lab=avdd}
N 200 -230 200 -170 {lab=avdd}
N 410 -230 410 -200 {lab=avdd}
N 410 -200 410 -170 {lab=avdd}
N 610 -200 610 -170 {lab=avdd}
N 450 -170 570 -170 {lab=#net3}
N 610 -140 610 -90 {lab=#net3}
N 30 -80 30 -50 {lab=avdd}
N -70 70 30 70 {lab=avdd}
N -70 -80 -70 70 {lab=avdd}
N -70 -80 30 -80 {lab=avdd}
N 520 -120 610 -120 {lab=#net3}
N 520 -170 520 -120 {lab=#net3}
N 200 -110 200 -50 {lab=vpot}
N 140 -50 200 -50 {lab=vpot}
N 410 -140 410 -50 {lab=vpot}
N 200 30 410 30 {lab=vpot}
N 740 -230 740 -0 {lab=avdd}
N 610 -230 740 -230 {lab=avdd}
N 740 60 740 90 {lab=#net4}
N 740 150 740 170 {lab=avss}
N 610 -30 610 -10 {lab=avss}
N 550 30 700 30 {lab=#net5}
N 410 30 490 30 {lab=vpot}
N 410 -50 410 30 {lab=vpot}
N 200 -50 200 30 {lab=vpot}
N 70 -50 140 -50 {lab=vpot}
N 30 100 30 290 {lab=vw}
N 30 200 60 200 {lab=vw}
N -410 610 -300 610 {lab=#net6}
N -450 550 -450 580 {lab=#net6}
N -450 560 -360 560 {lab=#net6}
N -360 560 -360 610 {lab=#net6}
N -280 420 -150 420 {lab=vdep}
N -150 420 -150 490 {lab=vdep}
N -150 420 -100 420 {lab=vdep}
N -150 550 -150 670 {lab=avss}
N -570 670 -150 670 {lab=avss}
N -570 450 -570 670 {lab=avss}
N -450 640 -450 670 {lab=avss}
N -260 640 -260 670 {lab=avss}
N -260 420 -260 580 {lab=vdep}
N -530 420 -340 420 {lab=#net7}
N -570 350 -570 390 {lab=#net7}
N -570 270 -570 290 {lab=avdd}
N -570 370 -470 370 {lab=#net7}
N -470 370 -470 420 {lab=#net7}
N -150 670 -60 670 {lab=avss}
N 30 450 30 670 {lab=avss}
N -0 670 30 670 {lab=avss}
N -40 420 -10 420 {lab=vdep}
N -450 610 -450 640 {lab=avss}
N -260 610 -260 640 {lab=avss}
N -570 420 -570 450 {lab=avss}
N -320 670 -320 720 {lab=avss}
N 520 30 520 110 {lab=avdd}
N -60 670 0 670 {lab=avss}
N -100 420 -40 420 {lab=vdep}
N -310 420 -310 500 {lab=avss}
N 740 0 740 30 {lab=avdd}
N 30 420 30 450 {lab=avss}
N 30 310 140 310 {lab=avss}
N 140 310 140 510 {lab=avss}
N 30 510 140 510 {lab=avss}
N 30 -230 200 -230 {lab=avdd}
N 30 -230 30 -80 {lab=avdd}
C {symbols/pfet_03v3.sym} 50 -50 0 1 {name=M1
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
C {symbols/pfet_03v3.sym} 50 70 0 1 {name=M2
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
C {symbols/nfet_03v3.sym} 10 310 0 0 {name=M3
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
model=nfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} 10 420 0 0 {name=M4
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
model=nfet_03v3
spiceprefix=X
}
C {devices/code_shown.sym} 310 600 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
"}
C {symbols/pfet_03v3.sym} 430 -170 0 1 {name=M5
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
C {symbols/pfet_03v3.sym} 590 -170 0 0 {name=M6
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
C {symbols/pfet_03v3.sym} 720 30 0 0 {name=M7
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
C {symbols/cap_mim_2f0fF.sym} 200 -140 0 0 {name=C1
W=1e-6
L=1e-6
model=cap_mim_2f0fF
spiceprefix=X
m=50}
C {iopin.sym} -560 -10 0 0 {name=p1 lab=avss}
C {cccs.sym} 610 -60 0 0 {name=Itp vnam=v1 value=1n}
C {iopin.sym} -570 -40 0 0 {name=p2 lab=avdd}
C {lab_pin.sym} 410 -230 1 0 {name=p3 sig_type=std_logic lab=avdd}
C {symbols/pfet_03v3.sym} 520 10 3 1 {name=M8
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
C {cccs.sym} 740 120 0 0 {name=F2 vnam=v1 value=220n}
C {lab_pin.sym} 610 -10 2 0 {name=p6 sig_type=std_logic lab=avss}
C {lab_pin.sym} 740 170 2 0 {name=p5 sig_type=std_logic lab=avss}
C {symbols/cap_mim_2f0fF.sym} 90 200 3 0 {name=CW
W=1e-6
L=1e-6
model=cap_mim_2f0fF
spiceprefix=X
m=250}
C {lab_pin.sym} 120 200 2 0 {name=p7 sig_type=std_logic lab=avss}
C {iopin.sym} 70 70 0 0 {name=p8 lab=nvpost}
C {iopin.sym} 520 -10 3 0 {name=p9 lab=nvpre}
C {symbols/nfet_03v3.sym} -550 420 0 1 {name=M9
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
model=nfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} -280 610 0 0 {name=M10
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
model=nfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} -430 610 0 1 {name=M11
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
model=nfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} -310 400 3 1 {name=M12
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
model=nfet_03v3
spiceprefix=X
}
C {cccs.sym} -450 520 0 0 {name=Itd vnam=v1 value=1n}
C {lab_pin.sym} -450 490 1 0 {name=p10 sig_type=std_logic lab=avdd}
C {symbols/cap_mim_2f0fF.sym} -150 520 0 1 {name=C3
W=1e-6
L=1e-6
model=cap_mim_2f0fF
spiceprefix=X
m=50}
C {cccs.sym} -570 320 0 0 {name=Idep vnam=v1 value=250n}
C {lab_pin.sym} -570 270 1 0 {name=p11 sig_type=std_logic lab=avdd}
C {iopin.sym} -310 380 3 0 {name=p12 lab=vpost}
C {lab_pin.sym} -320 720 3 0 {name=p13 sig_type=std_logic lab=avss}
C {lab_pin.sym} -310 500 3 0 {name=p14 sig_type=std_logic lab=avss}
C {lab_pin.sym} 520 110 3 0 {name=p15 sig_type=std_logic lab=avdd}
C {iopin.sym} -10 310 2 0 {name=p16 lab=vpre}
C {lab_pin.sym} 30 200 0 0 {name=p17 sig_type=std_logic lab=vw}
C {lab_pin.sym} -70 420 1 0 {name=p4 sig_type=std_logic lab=vdep}
C {lab_pin.sym} 200 -50 2 0 {name=p18 sig_type=std_logic lab=vpot}
