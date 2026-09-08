v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -120 0 -0 -0 {lab=0}
N -0 -60 0 -0 {lab=0}
N -120 30 -120 40 {lab=#net1}
N -120 40 50 40 {lab=#net1}
N 50 0 50 40 {lab=#net1}
N 110 -0 210 0 {lab=vm}
N 210 0 210 70 {lab=vm}
N 350 0 350 30 {lab=vm}
N 210 -0 350 0 {lab=vm}
N 290 60 310 60 {lab=vg}
N 290 60 290 130 {lab=vg}
N 290 130 350 130 {lab=vg}
N 350 90 350 130 {lab=vg}
N 350 130 350 180 {lab=vg}
N 290 210 310 210 {lab=#net2}
N 290 210 290 340 {lab=#net2}
N 260 340 290 340 {lab=#net2}
N 350 240 350 310 {lab=0}
N 220 260 220 310 {lab=#net2}
N 270 290 270 340 {lab=#net2}
N 220 290 270 290 {lab=#net2}
N 220 370 220 400 {lab=0}
N 220 340 220 370 {lab=0}
N 220 180 220 200 {lab=VDD}
N -120 -70 -120 -30 {lab=VDD}
N 350 60 420 60 {lab=VDD}
N 100 130 210 130 {lab=0}
N -530 70 -530 100 {lab=VDD}
N -530 160 -530 190 {lab=0}
N -470 -90 -470 -60 {lab=VDD
}
N 350 210 350 240 {lab=0}
N -470 -0 -440 -0 {lab=iext}
N -310 -0 -270 -0 {lab=iext}
N -210 -0 -160 -0 {lab=iext}
N -270 0 -210 0 {lab=iext}
N -440 -0 -440 90 {lab=iext}
N -440 90 -400 90 {lab=iext}
N -340 90 -330 90 {lab=iext}
N -330 0 -330 90 {lab=iext}
N -330 -0 -310 0 {lab=iext}
N -190 190 -190 240 {lab=vlk
spice_ignore=true}
N -190 300 -190 320 {lab=0
spice_ignore=true}
N -370 50 -370 90 {lab=0
spice_ignore=true}
N -400 90 -340 90 {lab=iext}
N -770 -20 -680 -20 {lab=0
spice_ignore=true}
N -680 -20 -680 10 {lab=0
spice_ignore=true}
C {capa-2.sym} 440 470 0 0 {name=C1
m=1
value=10p
footprint=1206
device=polarized_capacitor
spice_ignore=true}
C {symbols/pfet_03v3.sym} 330 60 0 0 {name=M1
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
C {symbols/nfet_03v3.sym} -140 0 2 1 {name=M6
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
C {symbols/nfet_03v3.sym} 330 210 2 1 {name=M2
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
C {gnd.sym} 0 -60 2 0 {name=l1 lab=0}
C {isource.sym} 220 230 0 0 {name=Iks value=50n}
C {vsource.sym} 80 0 3 0 {name=V1 value=0 savecurrent=false}
C {symbols/nfet_03v3.sym} 240 340 0 1 {name=M3
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
C {gnd.sym} 350 310 0 0 {name=l2 lab=0}
C {gnd.sym} 220 400 0 0 {name=l3 lab=0}
C {vdd.sym} 220 180 0 0 {name=l4 lab=VDD}
C {lab_pin.sym} -120 -70 0 0 {name=p1 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 420 60 2 0 {name=p2 sig_type=std_logic lab=VDD}
C {gnd.sym} 100 130 0 0 {name=l5 lab=0}
C {isource.sym} -470 -30 0 0 {name=Viext value="PULSE(0 100n 0 5n 5n 2u 10u)"
}
C {vsource.sym} -530 130 0 0 {name=V2 value=3.3 savecurrent=false}
C {vdd.sym} -530 70 0 0 {name=l6 lab=VDD}
C {gnd.sym} -530 190 0 0 {name=l7 lab=0}
C {vdd.sym} -470 -90 0 0 {name=l8 lab=VDD
}
C {lab_pin.sym} -190 0 3 0 {name=p3 sig_type=std_logic lab=iext}
C {lab_pin.sym} 260 0 1 0 {name=p4 sig_type=std_logic lab=vm}
C {lab_pin.sym} -190 210 2 0 {name=p5 sig_type=std_logic lab=vlk
spice_ignore=true}
C {lab_pin.sym} 350 120 2 0 {name=p6 sig_type=std_logic lab=vg}
C {ammeter.sym} -640 -120 3 0 {name=viext1 savecurrent=true spice_ignore=true}
C {code_shown.sym} -800 370 0 0 {name=s1 only_toplevel=false value="
.tran 50n 200u
.save all
.control
	run
	write integrator-3.raw
	plot v(vm)
	plot v(vg)
	plot v(vlk)
	plot v(iext)
.endc 

"}
C {devices/code_shown.sym} -480 380 0 0 {name=MODELS only_toplevel=true
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
C {code_shown.sym} -870 150 0 0 {name=s2 only_toplevel=false value="
.save v(iext) v(vg) v(vm)
"}
C {symbols/nfet_03v3.sym} -190 170 1 1 {name=M4
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
spice_ignore=true}
C {gnd.sym} -190 320 0 0 {name=l9 lab=0
spice_ignore=true}
C {vsource.sym} -190 270 0 0 {name=V3 value="PWL(0 3 200n 3 200.1n 0)" savecurrent=false
spice_ignore=true}
C {gnd.sym} -370 50 2 0 {name=l10 lab=0
spice_ignore=true}
C {vsource.sym} -680 40 2 0 {name=V4 value="PULSE(0 3.3 0 5n 5n 2u 10u 10)" savecurrent=false
spice_ignore=true}
C {gnd.sym} -770 -20 0 0 {name=l11 lab=0
spice_ignore=true}
C {symbols/cap_mim_2p0fF.sym} 210 100 0 0 {name=C3
W=17.68e-6
L=17.68e-6
model=cap_mim_2f0fF
spiceprefix=X
m=8
}
C {symbols/cap_mim_1f5fF.sym} 560 460 0 0 {name=C2
W=10e-6
L=10e-6
model=cap_mim_1f5fF
spiceprefix=X
m=10
spice_ignore=true}
C {symbols/cap_mim_1f0fF.sym} 510 160 0 0 {name=C4
W=10e-6
L=10e-6
model=cap_mim_1f0fF
spiceprefix=X
m=10
spice_ignore=true}
