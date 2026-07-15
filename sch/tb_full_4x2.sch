v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 -660 610 140 1010 {flags=graph
y1=-0.032
y2=14
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=0.0002
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node="\\"N1; vpre1\\"
\\"N2; vpre2 3.3 +\\"
\\"N3; vpre3 6.6 +\\"
\\"Spikes N4; vpre4 9.9 +\\""
color="4 5 8 12"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 160 610 960 1010 {flags=graph
y1=-0.04
y2=6.8
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=0.0002
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node="\\"N1; vpost1\\"
\\"N2; vpost2 3.3 +\\""
color="4 5"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 -670 1210 130 1610 {flags=graph
y1=2.2712363
y2=2.3055961
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=0.0002
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
color="12 1 8 9 7 16 17 19"
node="x1.vw11
x1.vw12
x1.vw21
x1.vw22
x1.vw31
x1.vw32
x1.vw41
x1.vw42"}
B 2 150 1210 950 1610 {flags=graph
y1=1.913324
y2=1.9476838
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=0.0002
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
color="12 1 8 9 7 16 17 19"
node="x1.vw11
x1.vw12
x1.vw21
x1.vw22
x1.vw31
x1.vw32
x1.vw41
x1.vw42"}
T {A current mirror is added to provide the voltage biases 
needed for internal nodes in  the stdp array. 

} 370 530 0 0 0.2 0.2 {}
T {4 presynaptic neurons} -290 -460 0 0 0.4 0.4 {}
T {two post synaptic neurons} 520 -270 0 0 0.4 0.4 {}
T {An input signal for testing purposes 
and its complement signal, to be processed 
by the encoder, providing exitation current 
for the input neurons} -840 -220 0 0 0.4 0.4 {}
T {The spikes of the first layer and 
the second layer are processed by
a 4x2 matrix with stdp synapses} 50 -210 0 0 0.4 0.4 {}
T {The spikes of each of the neurons
at the first layer. The encoder is set 
to use population encoding, which is
that not all the neurons respond equally 
to the same input stimuli} -460 1010 0 0 0.4 0.4 {}
T {The spikes of each of the neurons
at the output layer. The synapses 
provide enough input current for 
each of the postsynaptic neurons} 410 1010 0 0 0.4 0.4 {}
T {The synaptic weights connected to the
first postsynaptic neuron. } -460 1630 0 0 0.4 0.4 {}
T {The synaptic weights connected to the
second postsynaptic neuron. } 320 1620 0 0 0.4 0.4 {}
N -20 40 -20 130 {lab=vpre3}
N -20 40 90 40 {lab=vpre3}
N -10 60 90 60 {lab=nvpre3}
N -10 60 -10 160 {lab=nvpre3}
N 0 80 90 80 {lab=vpre4}
N 0 80 0 350 {lab=vpre4}
N 10 100 90 100 {lab=nvpre4}
N 10 100 10 380 {lab=nvpre4}
N -20 20 90 20 {lab=nvpre2}
N -10 -0 90 -0 {lab=vpre2}
N 0 -20 90 -20 {lab=nvpre1}
N 0 -270 0 -20 {lab=nvpre1}
N -100 -270 0 -270 {lab=nvpre1}
N 10 -40 90 -40 {lab=vpre1}
N 10 -300 10 -40 {lab=vpre1}
N -100 -300 10 -300 {lab=vpre1}
N 530 20 570 -50 {lab=#net1}
N 520 120 570 170 {lab=#net2}
N 740 -70 810 -70 {lab=vpost1}
N 810 -190 810 -70 {lab=vpost1}
N 420 -170 420 -20 {lab=vpost1}
N 390 -20 420 -20 {lab=vpost1}
N 390 0 440 0 {lab=nvpost1}
N 440 -160 440 0 {lab=nvpost1}
N 820 -180 820 -40 {lab=nvpost1}
N 740 -40 820 -40 {lab=nvpost1}
N 390 100 440 100 {lab=nvpost2}
N 440 50 440 100 {lab=nvpost2}
N 440 50 830 50 {lab=nvpost2}
N 850 50 850 200 {lab=nvpost2}
N -10 160 -10 210 {lab=nvpre3}
N -100 210 -10 210 {lab=nvpre3}
N -100 180 -20 180 {lab=vpre3}
N -20 130 -20 180 {lab=vpre3}
N -100 -20 -20 -20 {lab=nvpre2}
N -20 -20 -20 20 {lab=nvpre2}
N -100 -50 -10 -50 {lab=vpre2}
N -10 -50 -10 -0 {lab=vpre2}
N 10 380 10 450 {lab=nvpre4}
N -100 450 10 450 {lab=nvpre4}
N -100 420 -0 420 {lab=vpre4}
N 0 350 0 420 {lab=vpre4}
N -380 90 -260 420 {lab=#net3}
N -300 60 -260 180 {lab=#net4}
N -380 60 -300 60 {lab=#net4}
N -300 30 -260 -50 {lab=#net5}
N -380 30 -300 30 {lab=#net5}
N -380 0 -260 -300 {lab=#net6}
N 570 -50 580 -70 {lab=#net1}
N 440 -200 440 -160 {lab=nvpost1}
N 440 -200 820 -200 {lab=nvpost1}
N 820 -200 820 -180 {lab=nvpost1}
N 810 -210 810 -190 {lab=vpost1}
N 420 -210 810 -210 {lab=vpost1}
N 420 -210 420 -170 {lab=vpost1}
N 570 170 580 180 {lab=#net2}
N 430 60 430 80 {lab=vpost2}
N 390 80 430 80 {lab=vpost2}
N 330 390 330 440 {lab=B}
N 330 310 330 330 {lab=VDD}
N 180 310 330 310 {lab=VDD}
N 230 470 290 470 {lab=A}
N 260 420 260 470 {lab=A}
N 190 420 260 420 {lab=A}
N 190 420 190 440 {lab=A}
N 190 310 190 350 {lab=VDD}
N 190 410 190 420 {lab=A}
N 190 500 190 520 {lab=0}
N 190 520 330 520 {lab=0}
N 330 500 330 520 {lab=0}
N 270 520 270 540 {lab=0}
N 190 470 190 500 {lab=0}
N 330 470 330 500 {lab=0}
N 330 330 330 360 {lab=VDD}
N 370 360 410 360 {lab=B}
N 410 360 410 410 {lab=B}
N 330 410 410 410 {lab=B}
N 410 360 450 360 {lab=B
spice_ignore=true}
N 290 470 430 470 {lab=0
spice_ignore=true}
N 430 470 550 470 {lab=0
spice_ignore=true}
N 450 360 580 360 {lab=B
spice_ignore=true}
N -640 20 -620 20 {lab=Vin}
N -640 70 -620 70 {lab=Vin_neg}
N 430 40 430 60 {lab=vpost2}
N 430 40 840 40 {lab=vpost2}
N 840 40 840 180 {lab=vpost2}
N 740 180 840 180 {lab=vpost2}
N 740 210 850 210 {lab=nvpost2}
N 850 200 850 210 {lab=nvpost2}
N 830 50 850 50 {lab=nvpost2}
N 390 120 460 120 {lab=#net7}
N 390 20 470 20 {lab=#net8}
C {stdp/stdp_4x2.sym} 240 50 0 0 {name=x1}
C {lif/neurona_input_current.sym} -180 -300 0 0 {name=x2}
C {lif/neurona_input_current.sym} -180 -50 0 0 {name=x3}
C {lif/neurona_input_current.sym} -180 180 0 0 {name=x4}
C {lif/neurona_input_current.sym} -180 420 0 0 {name=x5}
C {lif/neurona_input_current.sym} 660 -70 0 0 {name=x6}
C {lif/neurona_input_current.sym} 660 180 0 0 {name=x7}
C {encoder/encoder.sym} -500 40 0 0 {name=x8}
C {vdd.sym} -500 -30 0 0 {name=l1 lab=VDD}
C {vdd.sym} -180 -130 0 0 {name=l2 lab=VDD}
C {vdd.sym} -180 -380 0 0 {name=l3 lab=VDD}
C {vdd.sym} -180 100 0 0 {name=l4 lab=VDD}
C {vdd.sym} -180 340 0 0 {name=l5 lab=VDD}
C {vdd.sym} 240 -70 0 0 {name=l6 lab=VDD}
C {vdd.sym} 660 -150 0 0 {name=l7 lab=VDD}
C {vdd.sym} 660 100 0 0 {name=l8 lab=VDD}
C {gnd.sym} 240 170 0 0 {name=l9 lab=0}
C {gnd.sym} -180 -220 0 0 {name=l10 lab=0}
C {gnd.sym} -180 30 0 0 {name=l11 lab=0}
C {gnd.sym} -180 260 0 0 {name=l12 lab=0}
C {gnd.sym} -180 500 0 0 {name=l13 lab=0}
C {gnd.sym} 660 10 0 0 {name=l14 lab=0}
C {gnd.sym} 660 260 0 0 {name=l15 lab=0}
C {gnd.sym} -500 120 0 0 {name=l16 lab=0}
C {vsource.sym} -440 280 0 0 {name=V4 value=3.3 savecurrent=false}
C {vdd.sym} -440 250 0 0 {name=l17 lab=VDD}
C {gnd.sym} -440 310 0 0 {name=l18 lab=0}
C {symbols/nfet_03v3.sym} 210 470 0 1 {name=M1
L=0.28u
W=4u
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
C {symbols/nfet_03v3.sym} 310 470 0 0 {name=M2
L=4u
W=4u
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
C {symbols/pfet_03v3.sym} 350 360 0 1 {name=M3
L=0.5u
W=8u
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
C {isource.sym} 190 380 0 1 {name=Iglb value=1u}
C {vdd.sym} 290 310 0 0 {name=l19 lab=VDD}
C {gnd.sym} 270 540 0 0 {name=l20 lab=0}
C {lab_pin.sym} 410 410 0 1 {name=p6 sig_type=std_logic lab=B}
C {lab_pin.sym} 260 420 0 1 {name=p7 sig_type=std_logic lab=A}
C {symbols/nfet_03v3.sym} 450 470 0 0 {name=M4
L=4u
W=4u
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
spice_ignore=true}
C {symbols/nfet_03v3.sym} 570 470 0 0 {name=M5
L=4u
W=4u
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
spice_ignore=true}
C {symbols/pfet_03v3.sym} 470 360 0 0 {name=M6
L=0.5u
W=8u
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
spice_ignore=true}
C {symbols/pfet_03v3.sym} 600 360 0 0 {name=M7
L=0.5u
W=8u
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
spice_ignore=true}
C {lab_pin.sym} 90 120 0 0 {name=p1 sig_type=std_logic lab=A}
C {lab_pin.sym} 90 140 0 0 {name=p2 sig_type=std_logic lab=B}
C {lab_pin.sym} 10 -290 0 1 {name=p3 sig_type=std_logic lab=vpre1}
C {lab_pin.sym} 0 -170 0 0 {name=p4 sig_type=std_logic lab=nvpre1}
C {lab_pin.sym} -30 -50 3 1 {name=p5 sig_type=std_logic lab=vpre2}
C {lab_pin.sym} -50 -20 1 1 {name=p8 sig_type=std_logic lab=nvpre2}
C {lab_pin.sym} -40 180 3 1 {name=p9 sig_type=std_logic lab=vpre3}
C {lab_pin.sym} -40 210 1 1 {name=p10 sig_type=std_logic lab=nvpre3}
C {lab_pin.sym} -30 420 3 1 {name=p11 sig_type=std_logic lab=vpre4}
C {lab_pin.sym} -30 450 1 1 {name=p12 sig_type=std_logic lab=nvpre4}
C {vsource.sym} -720 270 0 0 {name=V2 value="pwl(0 0 200u 3.3)" savecurrent=false}
C {vsource.sym} -580 270 0 0 {name=V3 value="pwl(0 3.3 200u 0)" savecurrent=false}
C {gnd.sym} -580 300 0 0 {name=l21 lab=GND}
C {gnd.sym} -720 300 0 0 {name=l22 lab=GND}
C {lab_pin.sym} -720 240 0 0 {name=p13 sig_type=std_logic lab=Vin}
C {lab_pin.sym} -580 240 0 0 {name=p14 sig_type=std_logic lab=Vin_neg}
C {lab_pin.sym} -640 20 0 0 {name=p15 sig_type=std_logic lab=Vin}
C {lab_pin.sym} -640 70 0 0 {name=p16 sig_type=std_logic lab=Vin_neg}
C {lab_pin.sym} 810 -150 0 0 {name=p17 sig_type=std_logic lab=vpost1}
C {lab_pin.sym} 820 -140 0 1 {name=p18 sig_type=std_logic lab=nvpost1}
C {lab_pin.sym} 840 100 0 0 {name=p19 sig_type=std_logic lab=vpost2}
C {lab_pin.sym} 850 110 0 1 {name=p20 sig_type=std_logic lab=nvpost2}
C {code_shown.sym} 100 -500 0 0 {name=s1 only_toplevel=false value="
.tran 1n 200u
.save all
.control
	run
	write tb_full_4x2.raw
.endc 

"}
C {devices/code_shown.sym} 450 -500 0 0 {name=MODELS only_toplevel=true
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
C {launcher.sym} 200 -320 0 0 {name=h5
descr="load waves"
tclcommand="xschem raw_read $netlist_dir/tb_full_4x2.raw tran"
}
C {ammeter.sym} 490 120 3 0 {name=V_Ij2 savecurrent=true spice_ignore=0}
C {ammeter.sym} 500 20 3 0 {name=V_Ij1 savecurrent=true spice_ignore=0}
