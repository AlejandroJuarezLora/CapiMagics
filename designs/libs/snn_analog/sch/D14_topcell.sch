v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
T {D14_topcell: LVS top. Same circuit as full_4x2_lvs, named like the GDS top cell.} -150 -150 0 0 0.3 0.3 {}
C {full_4x2_lvs.sym} 0 0 0 0 {name=x1}
C {iopin.sym} 150 -70 0 0 {name=p1 lab=avdd}
C {iopin.sym} 150 -50 0 0 {name=p2 lab=avss}
C {ipin.sym} -150 -70 0 0 {name=p3 lab=Vin}
C {ipin.sym} -150 -50 0 0 {name=p4 lab=Vin_neg}
C {opin.sym} 150 -30 0 0 {name=p5 lab=vpre1}
C {opin.sym} 150 -10 0 0 {name=p6 lab=vpre2}
C {opin.sym} 150 10 0 0 {name=p7 lab=vw11}
C {opin.sym} 150 30 0 0 {name=p8 lab=vw42}
C {opin.sym} 150 50 0 0 {name=p9 lab=vpost1}
C {opin.sym} 150 70 0 0 {name=p10 lab=vpost2}
