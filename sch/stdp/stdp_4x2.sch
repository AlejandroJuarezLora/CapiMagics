v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {Here, the schematic for a fully connected 
4 presynaptic neuronsand 2 postsynaptic neurons 
is presented. 

Notice that the column-row distribution allows 
take control into which signal goes to which synapse

The nodes A and B are used to provide the bias voltages
for transistors inside of the STDP synapse


ifwd1,2 node collects all the current that each synapse 
shall provide for each postsynaptic neuron, given its 
current synaptic weight value and the spikes of the previous layer


This is where glayout and librelane can be helpful, 
what about using more neurons=more synapses!} 1080 -230 0 0 0.4 0.4 {}
N 310 -110 420 -110 {lab=ifwd1}
N 310 150 420 150 {lab=ifwd1}
N 310 -360 420 -360 {lab=ifwd1}
N 310 400 420 400 {lab=ifwd1}
N 420 -360 420 700 {lab=ifwd1}
N 870 -110 980 -110 {lab=ifwd2}
N 870 150 980 150 {lab=ifwd2}
N 870 -360 980 -360 {lab=ifwd2}
N 870 400 980 400 {lab=ifwd2}
N 980 -360 980 700 {lab=ifwd2}
C {stdp.sym} 160 -310 0 0 {name=x1}
C {stdp.sym} 720 -310 0 0 {name=x2}
C {stdp.sym} 160 -60 0 0 {name=x3}
C {stdp.sym} 720 -60 0 0 {name=x4}
C {stdp.sym} 160 200 0 0 {name=x5}
C {stdp.sym} 720 200 0 0 {name=x6}
C {stdp.sym} 160 450 0 0 {name=x7}
C {stdp.sym} 720 450 0 0 {name=x8}
C {lab_pin.sym} 10 -340 0 0 {name=p1 sig_type=std_logic lab=vpre1}
C {lab_pin.sym} 10 -320 0 0 {name=p2 sig_type=std_logic lab=nvpre1}
C {lab_pin.sym} 570 -340 0 0 {name=p3 sig_type=std_logic lab=vpre1}
C {lab_pin.sym} 570 -320 0 0 {name=p4 sig_type=std_logic lab=nvpre1}
C {lab_pin.sym} 310 -340 0 1 {name=p5 sig_type=std_logic lab=vpost1}
C {lab_pin.sym} 310 -320 0 1 {name=p6 sig_type=std_logic lab=nvpost1}
C {lab_pin.sym} 870 -340 0 1 {name=p7 sig_type=std_logic lab=vpost2}
C {lab_pin.sym} 870 -320 0 1 {name=p8 sig_type=std_logic lab=nvpost2}
C {lab_pin.sym} 310 -90 0 1 {name=p9 sig_type=std_logic lab=vpost1}
C {lab_pin.sym} 310 -70 0 1 {name=p10 sig_type=std_logic lab=nvpost1}
C {lab_pin.sym} 870 -90 0 1 {name=p11 sig_type=std_logic lab=vpost2}
C {lab_pin.sym} 870 -70 0 1 {name=p12 sig_type=std_logic lab=nvpost2}
C {lab_pin.sym} 310 170 0 1 {name=p13 sig_type=std_logic lab=vpost1}
C {lab_pin.sym} 310 190 0 1 {name=p14 sig_type=std_logic lab=nvpost1}
C {lab_pin.sym} 870 170 0 1 {name=p15 sig_type=std_logic lab=vpost2}
C {lab_pin.sym} 870 190 0 1 {name=p16 sig_type=std_logic lab=nvpost2}
C {lab_pin.sym} 10 -90 0 0 {name=p17 sig_type=std_logic lab=vpre2}
C {lab_pin.sym} 10 -70 0 0 {name=p18 sig_type=std_logic lab=nvpre2}
C {lab_pin.sym} 570 -90 0 0 {name=p19 sig_type=std_logic lab=vpre2}
C {lab_pin.sym} 570 -70 0 0 {name=p20 sig_type=std_logic lab=nvpre2}
C {lab_pin.sym} 10 170 0 0 {name=p21 sig_type=std_logic lab=vpre3}
C {lab_pin.sym} 10 190 0 0 {name=p22 sig_type=std_logic lab=nvpre3}
C {lab_pin.sym} 570 170 0 0 {name=p23 sig_type=std_logic lab=vpre3}
C {lab_pin.sym} 570 190 0 0 {name=p24 sig_type=std_logic lab=nvpre3}
C {lab_pin.sym} 10 420 0 0 {name=p25 sig_type=std_logic lab=vpre4}
C {lab_pin.sym} 10 440 0 0 {name=p26 sig_type=std_logic lab=nvpre4}
C {lab_pin.sym} 570 420 0 0 {name=p27 sig_type=std_logic lab=vpre4}
C {lab_pin.sym} 570 440 0 0 {name=p28 sig_type=std_logic lab=nvpre4}
C {lab_pin.sym} 310 420 0 1 {name=p29 sig_type=std_logic lab=vpost1}
C {lab_pin.sym} 310 440 0 1 {name=p30 sig_type=std_logic lab=nvpost1}
C {lab_pin.sym} 870 420 0 1 {name=p31 sig_type=std_logic lab=vpost2}
C {lab_pin.sym} 870 440 0 1 {name=p32 sig_type=std_logic lab=nvpost2}
C {iopin.sym} 420 700 0 0 {name=p33 lab=ifwd1}
C {iopin.sym} 980 700 0 0 {name=p34 lab=ifwd2}
C {ipin.sym} -360 -390 0 0 {name=p35 lab=vpre1}
C {ipin.sym} -360 -360 0 0 {name=p36 lab=nvpre1}
C {ipin.sym} -360 -310 0 0 {name=p37 lab=vpre2}
C {ipin.sym} -360 -280 0 0 {name=p38 lab=nvpre2}
C {ipin.sym} -360 -230 0 0 {name=p39 lab=vpre3}
C {ipin.sym} -360 -200 0 0 {name=p40 lab=nvpre3}
C {ipin.sym} -360 -160 0 0 {name=p41 lab=vpre4}
C {ipin.sym} -360 -130 0 0 {name=p42 lab=nvpre4}
C {opin.sym} -280 -390 0 0 {name=p43 lab=vpost1}
C {opin.sym} -280 -360 0 0 {name=p44 lab=nvpost1}
C {opin.sym} -280 -310 0 0 {name=p45 lab=vpost2}
C {opin.sym} -280 -280 0 0 {name=p46 lab=nvpost2}
C {iopin.sym} -270 -230 0 0 {name=p47 lab=avdd}
C {iopin.sym} -270 -200 0 0 {name=p48 lab=avss}
C {lab_pin.sym} 160 -390 0 0 {name=p49 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 160 -230 0 0 {name=p50 sig_type=std_logic lab=avss}
C {lab_pin.sym} 720 -390 0 0 {name=p51 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 720 -230 0 0 {name=p52 sig_type=std_logic lab=avss}
C {lab_pin.sym} 720 -140 0 0 {name=p53 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 720 20 0 0 {name=p54 sig_type=std_logic lab=avss}
C {lab_pin.sym} 160 -140 0 0 {name=p55 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 160 20 0 0 {name=p56 sig_type=std_logic lab=avss}
C {lab_pin.sym} 720 120 0 0 {name=p57 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 720 280 0 0 {name=p58 sig_type=std_logic lab=avss}
C {lab_pin.sym} 160 120 0 0 {name=p59 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 160 280 0 0 {name=p60 sig_type=std_logic lab=avss}
C {lab_pin.sym} 720 370 0 0 {name=p61 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 720 530 0 0 {name=p62 sig_type=std_logic lab=avss}
C {lab_pin.sym} 160 370 0 0 {name=p63 sig_type=std_logic lab=avdd}
C {lab_pin.sym} 160 530 0 0 {name=p64 sig_type=std_logic lab=avss}
C {iopin.sym} -270 -160 0 0 {name=p65 lab=A}
C {iopin.sym} -270 -130 0 0 {name=p66 lab=B}
C {lab_pin.sym} 10 -270 0 0 {name=p67 sig_type=std_logic lab=A}
C {lab_pin.sym} 10 -290 0 0 {name=p68 sig_type=std_logic lab=B}
C {lab_pin.sym} 10 -20 0 0 {name=p69 sig_type=std_logic lab=A}
C {lab_pin.sym} 10 -40 0 0 {name=p70 sig_type=std_logic lab=B}
C {lab_pin.sym} 10 240 0 0 {name=p71 sig_type=std_logic lab=A}
C {lab_pin.sym} 10 220 0 0 {name=p72 sig_type=std_logic lab=B}
C {lab_pin.sym} 10 490 0 0 {name=p73 sig_type=std_logic lab=A}
C {lab_pin.sym} 10 470 0 0 {name=p74 sig_type=std_logic lab=B}
C {lab_pin.sym} 570 -270 0 0 {name=p75 sig_type=std_logic lab=A}
C {lab_pin.sym} 570 -290 0 0 {name=p76 sig_type=std_logic lab=B}
C {lab_pin.sym} 570 -20 0 0 {name=p77 sig_type=std_logic lab=A}
C {lab_pin.sym} 570 -40 0 0 {name=p78 sig_type=std_logic lab=B}
C {lab_pin.sym} 570 240 0 0 {name=p79 sig_type=std_logic lab=A}
C {lab_pin.sym} 570 220 0 0 {name=p80 sig_type=std_logic lab=B}
C {lab_pin.sym} 570 490 0 0 {name=p81 sig_type=std_logic lab=A}
C {lab_pin.sym} 570 470 0 0 {name=p82 sig_type=std_logic lab=B}
C {lab_pin.sym} 310 -290 0 1 {name=p83 sig_type=std_logic lab=A}
C {lab_pin.sym} 310 -270 0 1 {name=p84 sig_type=std_logic lab=B}
C {lab_pin.sym} 870 -290 0 1 {name=p85 sig_type=std_logic lab=A}
C {lab_pin.sym} 870 -270 0 1 {name=p86 sig_type=std_logic lab=B}
C {lab_pin.sym} 870 -40 0 1 {name=p87 sig_type=std_logic lab=A}
C {lab_pin.sym} 870 -20 0 1 {name=p88 sig_type=std_logic lab=B}
C {lab_pin.sym} 310 -40 0 1 {name=p89 sig_type=std_logic lab=A}
C {lab_pin.sym} 310 -20 0 1 {name=p90 sig_type=std_logic lab=B}
C {lab_pin.sym} 310 220 0 1 {name=p91 sig_type=std_logic lab=A}
C {lab_pin.sym} 310 240 0 1 {name=p92 sig_type=std_logic lab=B}
C {lab_pin.sym} 870 220 0 1 {name=p93 sig_type=std_logic lab=A}
C {lab_pin.sym} 870 240 0 1 {name=p94 sig_type=std_logic lab=B}
C {lab_pin.sym} 870 470 0 1 {name=p95 sig_type=std_logic lab=A}
C {lab_pin.sym} 870 490 0 1 {name=p96 sig_type=std_logic lab=B}
C {lab_pin.sym} 310 470 0 1 {name=p97 sig_type=std_logic lab=A}
C {lab_pin.sym} 310 490 0 1 {name=p98 sig_type=std_logic lab=B}
