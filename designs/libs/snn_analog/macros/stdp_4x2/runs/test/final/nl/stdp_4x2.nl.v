module stdp_4x2 (A,
    B,
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

 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_1 (.I(nvpre2));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_2 (.I(nvpre2));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_3 (.I(nvpre2));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_4 (.I(nvpre2));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_5 (.I(nvpre2));
 gf180mcu_fd_sc_mcu7t5v0__antenna ANTENNA_6 (.I(nvpre2));
 stdp x1 (.nvpost(nvpost1),
    .nvpre(nvpre1),
    .vpost(vpost1),
    .vpre(vpre1),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .Iout(net7),
    .vw(vw11));
 Current_limit x10 (.i_SUM(net8),
    .ifwd(ifwd2));
 stdp x2 (.nvpost(nvpost1),
    .nvpre(nvpre2),
    .vpost(vpost1),
    .vpre(vpre2),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .Iout(net7),
    .vw(net3));
 stdp x3 (.nvpost(nvpost1),
    .nvpre(nvpre3),
    .vpost(vpost1),
    .vpre(vpre3),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .Iout(net7),
    .vw(net2));
 stdp x4 (.nvpost(nvpost1),
    .nvpre(nvpre4),
    .vpost(vpost1),
    .vpre(vpre4),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .Iout(net7),
    .vw(net1));
 stdp x5 (.nvpost(nvpost2),
    .nvpre(nvpre1),
    .vpost(vpost2),
    .vpre(vpre1),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .Iout(net8),
    .vw(net4));
 stdp x6 (.nvpost(nvpost2),
    .nvpre(nvpre2),
    .vpost(vpost2),
    .vpre(vpre2),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .Iout(net8),
    .vw(net6));
 stdp x7 (.nvpost(nvpost2),
    .nvpre(nvpre3),
    .vpost(vpost2),
    .vpre(vpre3),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .Iout(net8),
    .vw(net5));
 stdp x8 (.nvpost(nvpost2),
    .nvpre(nvpre4),
    .vpost(vpost2),
    .vpre(vpre4),
    .vb_idep(B),
    .vb_itd(A),
    .vb_itp(B),
    .vb_pot(A),
    .Iout(net8),
    .vw(vw42));
 Current_limit x9 (.i_SUM(net7),
    .ifwd(ifwd1));
endmodule
