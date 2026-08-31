module stdp_4x2 (A,
    B,
    avdd,
    avss,
    ifwd1,
    ifwd2,
    nvpost1,
    nvpost2,
    nvpre1,
    nvpre2,
    nvpre3,
    nvpre4,
    vpost1,
    vpost2,
    vpre1,
    vpre2,
    vpre3,
    vpre4,
    vw11,
    vw42);
 inout A;
 inout B;
 inout avdd;
 inout avss;
 output ifwd1;
 output ifwd2;
 input nvpost1;
 input nvpost2;
 input nvpre1;
 input nvpre2;
 input nvpre3;
 input nvpre4;
 input vpost1;
 input vpost2;
 input vpre1;
 input vpre2;
 input vpre3;
 input vpre4;
 inout vw11;
 inout vw42;

 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;

 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_1 (.I(nvpre1),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_10 (.I(nvpre1),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_11 (.I(nvpre1),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_12 (.I(nvpre1),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_2 (.I(nvpre1),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_3 (.I(nvpre3),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_4 (.I(nvpre4),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_5 (.I(nvpre4),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_6 (.I(vpre1),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_7 (.I(vpre2),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_8 (.I(vpre3),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_9 (.I(vpre4),
    .VDD(avdd),
    .VNW(avdd),
    .VPW(avss),
    .VSS(avss));
 stdp x1 (.avdd(avdd),
    .avss(avss),
    .nvpost(nvpost1),
    .nvpre(nvpre1),
    .vpost(vpost1),
    .vpre(vpre1),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .vw(vw11),
    .Iout(net7));
 Current_limit x10 (.i_SUM(net8),
    .ifwd(ifwd2),
    .avdd(avdd),
    .avss(avss));
 stdp x2 (.avdd(avdd),
    .avss(avss),
    .nvpost(nvpost1),
    .nvpre(nvpre2),
    .vpost(vpost1),
    .vpre(vpre2),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .vw(net3),
    .Iout(net7));
 stdp x3 (.avdd(avdd),
    .avss(avss),
    .nvpost(nvpost1),
    .nvpre(nvpre3),
    .vpost(vpost1),
    .vpre(vpre3),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .vw(net2),
    .Iout(net7));
 stdp x4 (.avdd(avdd),
    .avss(avss),
    .nvpost(nvpost1),
    .nvpre(nvpre4),
    .vpost(vpost1),
    .vpre(vpre4),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .vw(net1),
    .Iout(net7));
 stdp x5 (.avdd(avdd),
    .avss(avss),
    .nvpost(nvpost2),
    .nvpre(nvpre1),
    .vpost(vpost2),
    .vpre(vpre1),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .vw(net4),
    .Iout(net8));
 stdp x6 (.avdd(avdd),
    .avss(avss),
    .nvpost(nvpost2),
    .nvpre(nvpre2),
    .vpost(vpost2),
    .vpre(vpre2),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .vw(net6),
    .Iout(net8));
 stdp x7 (.avdd(avdd),
    .avss(avss),
    .nvpost(nvpost2),
    .nvpre(nvpre3),
    .vpost(vpost2),
    .vpre(vpre3),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .vw(net5),
    .Iout(net8));
 stdp x8 (.avdd(avdd),
    .avss(avss),
    .nvpost(nvpost2),
    .nvpre(nvpre4),
    .vpost(vpost2),
    .vpre(vpre4),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .vw(vw42),
    .Iout(net8));
 Current_limit x9 (.i_SUM(net7),
    .ifwd(ifwd1),
    .avdd(avdd),
    .avss(avss));
endmodule
