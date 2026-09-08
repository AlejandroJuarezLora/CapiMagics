v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {Mthr} -230 30 0 0 0.4 0.4 {}
T {Mw} -170 250 0 0 0.4 0.4 {}
T {Mpre} -190 430 0 0 0.4 0.4 {}
T {Min} 70 90 0 0 0.4 0.4 {}
T {Mtau} 60 -130 0 0 0.4 0.4 {}
T {Msyn} 430 0 0 0 0.4 0.4 {}
N -410 60 -410 90 {lab=VDD}
N -410 150 -410 170 {lab=0}
N 50 -210 50 -190 {lab=VDD}
N 50 -210 200 -210 {lab=VDD}
N 310 -210 310 -160 {lab=VDD}
N 200 -210 380 -210 {lab=VDD}
N 310 -100 310 -30 {lab=vsyn}
N -110 450 -110 500 {lab=0}
N -80 -160 10 -160 {lab=vtau}
N -240 230 -150 230 {lab=vw}
N -250 0 -250 30 {lab=VDD
}
N -240 290 -240 320 {lab=0}
N 50 -190 50 -160 {lab=VDD}
N -240 420 -150 420 {lab=spk1}
N -300 480 -300 520 {lab=0}
N -300 420 -240 420 {lab=spk1}
N -110 420 -110 450 {lab=0}
N 380 -210 420 -210 {lab=VDD}
N 420 -210 420 -60 {lab=VDD}
N 420 -60 420 -30 {lab=VDD}
N -320 80 -290 80 {lab=vthr}
N -250 30 -250 50 {lab=VDD}
N 300 -30 380 -30 {lab=vsyn}
N 90 -30 110 -30 {lab=vsyn}
N -250 80 50 80 {lab=0}
N -320 140 -320 170 {lab=0
}
N -110 130 -80 130 {lab=#net1}
N -20 130 50 130 {lab=#net1}
N 50 110 50 130 {lab=#net1}
N -110 260 -110 300 {lab=#net2}
N -110 360 -110 390 {lab=#net3}
N -80 130 -20 130 {lab=#net1}
N -110 230 -30 230 {lab=0}
N -30 230 -30 480 {lab=0}
N -110 480 -30 480 {lab=0}
N 110 -30 300 -30 {lab=vsyn}
N -250 130 -110 130 {lab=#net1}
N -250 110 -250 130 {lab=#net1}
N -110 130 -110 200 {lab=#net1}
N 420 0 420 50 {lab=#net4}
N 50 -30 90 -30 {lab=vsyn}
N 90 80 160 80 {lab=vsyn}
N 160 -30 160 80 {lab=vsyn}
N 50 -130 50 -110 {lab=#net5}
N 50 -50 50 -20 {lab=vsyn}
N 50 40 50 50 {lab=#net6}
C {symbols/pfet_03v3.sym} 30 -160 0 0 {name=Mtau
L=0.28u
W=0.62u
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
C {vsource.sym} -410 120 0 0 {name=V1 value=3.3 savecurrent=false}
C {vdd.sym} -410 60 0 0 {name=l2 lab=VDD}
C {gnd.sym} -410 170 0 0 {name=l6 lab=0}
C {capa-2.sym} 310 -130 0 0 {name=C1
m=1
value=1p
footprint=1206
device=polarized_capacitor}
C {vdd.sym} 200 -210 0 0 {name=l1 lab=VDD}
C {gnd.sym} -110 500 0 0 {name=l4 lab=0}
C {vsource.sym} -80 -130 0 0 {name=V2 value=1.64 savecurrent=false
}
C {vsource.sym} -240 260 0 0 {name=V3 value=0.24 savecurrent=false}
C {gnd.sym} -80 -100 0 0 {name=l5 lab=0
}
C {gnd.sym} -240 320 0 0 {name=l7 lab=0}
C {vsource.sym} -300 450 0 1 {name=V4 value="PULSE(0 3.3 0 20n 20n 0.001 0.02)" savecurrent=false}
C {gnd.sym} -300 520 0 0 {name=l8 lab=0}
C {lab_pin.sym} -40 -160 1 0 {name=p1 sig_type=std_logic lab=vtau
}
C {lab_pin.sym} -190 230 1 0 {name=p2 sig_type=std_logic lab=vw}
C {lab_pin.sym} -190 420 1 0 {name=p3 sig_type=std_logic lab=spk1}
C {lab_pin.sym} 300 -30 3 0 {name=p4 sig_type=std_logic lab=vsyn
}
C {launcher.sym} 540 210 0 0 {name=h5
descr="load waves"
tclcommand="xschem raw_read $netlist_dir/integrator_stage.raw tran"
}
C {symbols/nfet_03v3.sym} -270 80 0 0 {name=Mthr
L=0.28u
W=0.62u
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
C {symbols/nfet_03v3.sym} 70 80 0 1 {name=Min
L=0.28u
W=0.62u
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
C {vdd.sym} -250 30 0 0 {name=l9 lab=VDD}
C {code_shown.sym} 480 470 0 0 {name=s1 only_toplevel=false value="
.tran 20u 1
.save all
.control
	run
	plot v(vsyn) v(spk1)
	plot i(vIsyn) 
	write diff-pair-1.raw
.endc 

"}
C {devices/code_shown.sym} 470 300 0 0 {name=MODELS only_toplevel=true
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
C {gnd.sym} -120 80 0 0 {name=l10 lab=0
}
C {vsource.sym} -320 110 0 0 {name=V5 value=0.3 savecurrent=false
}
C {gnd.sym} -320 170 0 0 {name=l11 lab=0
}
C {symbols/pfet_03v3.sym} 400 -30 0 0 {name=MSyn
L=0.28u
W=0.62u
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
C {symbols/nfet_03v3.sym} -130 230 0 0 {name=Mw
L=0.28u
W=0.62u
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
C {symbols/nfet_03v3.sym} -130 420 0 0 {name=Mpre
L=0.28u
W=0.62u
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
C {ammeter.sym} 420 80 0 0 {name=vIsyn savecurrent=true spice_ignore=0}
C {gnd.sym} 420 110 0 0 {name=l3 lab=0}
C {lab_pin.sym} -310 80 1 0 {name=p5 sig_type=std_logic lab=vthr
}
C {ammeter.sym} 50 -80 0 0 {name=vItau savecurrent=true spice_ignore=0}
C {ammeter.sym} 50 10 0 1 {name=vIin savecurrent=true spice_ignore=0}
C {ammeter.sym} -110 330 0 1 {name=vIw savecurrent=true spice_ignore=0}
