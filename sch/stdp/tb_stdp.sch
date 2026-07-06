v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 -1020 -580 -220 -180 {flags=graph
y1=-0.24
y2=2.9
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node=vpre
color=4
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 590 -560 1390 -160 {flags=graph
y1=-0.16
y2=2.9
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node=vpost
color=7
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 -210 -580 590 -180 {flags=graph
y1=1.04804
y2=1.0508548
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node=x1.vw
color=12
dataset=-1
unitx=1
logx=0
logy=0
}
N -320 -80 -320 0 {lab=vpre}
N -320 -80 -300 -80 {lab=vpre}
N -130 -80 -90 -80 {lab=nvpre}
N -90 -80 -90 -20 {lab=nvpre}
N -90 -20 -70 -20 {lab=nvpre}
N -360 60 -320 60 {lab=vpre}
N -320 0 -320 60 {lab=vpre}
N -320 60 -180 60 {lab=vpre}
N -180 0 -180 60 {lab=vpre}
N -180 0 -70 0 {lab=vpre}
N -680 40 -680 120 {lab=v1}
N -680 40 -660 40 {lab=v1}
N 480 -80 480 0 {lab=vpost}
N 460 -80 480 -80 {lab=vpost}
N 250 -80 290 -80 {lab=nvpost}
N 250 -80 250 -20 {lab=nvpost}
N 230 -20 250 -20 {lab=nvpost}
N 480 60 520 60 {lab=vpost}
N 480 0 480 60 {lab=vpost}
N 340 60 480 60 {lab=vpost}
N 340 0 340 60 {lab=vpost}
N 230 0 340 0 {lab=vpost}
N 840 40 840 120 {lab=v2}
N 820 40 840 40 {lab=v2}
C {stdp.sym} 80 -10 0 0 {name=x1}
C {vsource.sym} 840 150 0 0 {name=V1 value="PWL(0 2.4 20u 2.9)" savecurrent=false}
C {not.sym} -280 -80 0 0 {name=x2}
C {gnd.sym} -130 -60 0 0 {name=l3 lab=0}
C {gnd.sym} 80 70 0 0 {name=l4 lab=0}
C {vdd.sym} -130 -100 0 0 {name=l6 lab=VDD}
C {vdd.sym} 80 -90 0 0 {name=l8 lab=VDD}
C {gnd.sym} -680 180 0 0 {name=l9 lab=0}
C {vco.sym} -510 60 0 0 {name=x4}
C {vsource.sym} 70 220 0 0 {name=V4 value=3.3 savecurrent=false}
C {vdd.sym} 70 190 0 0 {name=l11 lab=VDD}
C {gnd.sym} 70 250 0 0 {name=l12 lab=0}
C {vdd.sym} -360 40 0 0 {name=l13 lab=VDD}
C {gnd.sym} -360 80 0 0 {name=l14 lab=0}
C {not.sym} 440 -80 0 1 {name=x3}
C {gnd.sym} 290 -60 0 1 {name=l1 lab=0}
C {vdd.sym} 290 -100 0 1 {name=l2 lab=VDD}
C {gnd.sym} 840 180 0 1 {name=l5 lab=0}
C {vco.sym} 670 60 0 1 {name=x5}
C {vdd.sym} 520 40 0 1 {name=l7 lab=VDD}
C {gnd.sym} 520 80 0 1 {name=l10 lab=0}
C {vsource.sym} -680 150 0 1 {name=V2 value="PWL(0 2.9 20u 2.4)" savecurrent=false}
C {lab_pin.sym} -100 0 3 0 {name=p2 sig_type=std_logic lab=vpre}
C {lab_pin.sym} -90 -80 1 0 {name=p1 sig_type=std_logic lab=nvpre}
C {lab_pin.sym} 250 0 3 0 {name=p3 sig_type=std_logic lab=vpost}
C {lab_pin.sym} 250 -80 1 0 {name=p4 sig_type=std_logic lab=nvpost}
C {code_shown.sym} 230 220 0 0 {name=s1 only_toplevel=false value="
.tran 1n 20u
.save all
.control
	write tb_stdp.raw
.endc 

"}
C {devices/code_shown.sym} -470 340 0 0 {name=MODELS only_toplevel=true
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
C {lab_pin.sym} -680 40 1 0 {name=p5 sig_type=std_logic lab=v1}
C {lab_pin.sym} 840 40 1 0 {name=p6 sig_type=std_logic lab=v2}
C {launcher.sym} 270 400 0 0 {name=h5
descr="load waves"
tclcommand="xschem raw_read $netlist_dir/tb_stdp.raw tran"
}
