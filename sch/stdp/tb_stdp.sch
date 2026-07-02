v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -320 -80 -320 0 {lab=#net1}
N -320 -80 -300 -80 {lab=#net1}
N -130 -80 -90 -80 {lab=#net2}
N -90 -80 -90 -20 {lab=#net2}
N -90 -20 -70 -20 {lab=#net2}
N 280 -70 330 -70 {lab=#net3}
N 280 -70 280 -20 {lab=#net3}
N 230 -20 280 -20 {lab=#net3}
N 560 -70 560 10 {lab=#net4}
N 500 -70 560 -70 {lab=#net4}
N -180 0 -70 -0 {lab=#net1}
N -180 -30 -180 -0 {lab=#net1}
N -320 -30 -180 -30 {lab=#net1}
N 230 -0 420 0 {lab=#net4}
N 420 -20 420 0 {lab=#net4}
N 420 -20 560 -20 {lab=#net4}
C {stdp.sym} 80 -10 0 0 {name=x1}
C {vsource.sym} -320 30 0 0 {name=V1 value=3.3 savecurrent=false}
C {not.sym} -280 -80 0 0 {name=x2}
C {vsource.sym} 560 40 0 0 {name=V2 value=3.3 savecurrent=false}
C {not.sym} 480 -70 0 1 {name=x3}
C {vsource.sym} -410 30 0 0 {name=V3 value=3.3 savecurrent=false}
C {vdd.sym} -410 0 0 0 {name=l1 lab=VDD}
C {gnd.sym} -410 60 0 0 {name=l2 lab=0}
C {gnd.sym} -130 -60 0 0 {name=l3 lab=0}
C {gnd.sym} 80 70 0 0 {name=l4 lab=0}
C {gnd.sym} 330 -50 0 0 {name=l5 lab=0}
C {vdd.sym} -130 -100 0 0 {name=l6 lab=VDD}
C {vdd.sym} 330 -90 0 0 {name=l7 lab=VDD}
C {vdd.sym} 80 -90 0 0 {name=l8 lab=VDD}
C {gnd.sym} -320 60 0 0 {name=l9 lab=0}
C {gnd.sym} 560 70 0 0 {name=l10 lab=0}
