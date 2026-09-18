module D14_topcell (Vin,
    Vin_neg,
    avdd,
    avss,
    vw11,
    vw42);
 input Vin;
 input Vin_neg;
 inout avdd;
 inout avss;
 output vw11;
 output vw42;

 wire A_wire;
 wire B_wire;
 wire ifwd1_net;
 wire ifwd2_net;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire nvpost1_net;
 wire nvpost2_net;
 wire nvpre1_int;
 wire nvpre2_int;
 wire nvpre3_int;
 wire nvpre4_int;
 wire vpost1_net;
 wire vpost2_net;
 wire vpre1_int;
 wire vpre2_int;
 wire vpre3_int;
 wire vpre4_int;
 wire vdd;
 wire vss;

 current_mirror u_current_mirror (.avss(avss),
    .avdd(avdd));
 encoder u_encoder (.vss(avss),
    .vdd(avdd),
    .Vin(Vin),
    .Vin_neg(Vin_neg),
    .Iex_1_i(net3),
    .Iex_2_i(net4),
    .Iex_3_i(net5),
    .Iex_4_i(net6));
 layer_input u_layer_input (.Iext1(net3),
    .Iext2(net4),
    .Iext3(net5),
    .Iext4(net6),
    .nvout_1(nvpre1_int),
    .nvout_2(nvpre2_int),
    .nvout_3(nvpre3_int),
    .nvout_4(nvpre4_int),
    .vdd(avdd),
    .vout_1(vpre1_int),
    .vout_2(vpre2_int),
    .vout_3(vpre3_int),
    .vout_4(vpre4_int),
    .vss(avss));
 layer_output u_layer_output (.Iext1(ifwd1_net),
    .Iext2(ifwd2_net),
    .nvout_1(nvpost1_net),
    .nvout_2(nvpost2_net),
    .vdd(vdd),
    .vout_1(vpost1_net),
    .vout_2(vpost2_net),
    .vss(vss));
 stdp_4x2 u_stdp_4x2 (.A(A_wire),
    .B(B_wire),
    .avdd(avdd),
    .avss(avss),
    .ifwd1(ifwd1_net),
    .ifwd2(ifwd2_net),
    .nvpost1(nvpost1_net),
    .nvpost2(nvpost2_net),
    .nvpre1(nvpre1_int),
    .nvpre2(nvpre2_int),
    .nvpre3(nvpre3_int),
    .nvpre4(nvpre4_int),
    .vpost1(vpost1_net),
    .vpost2(vpost2_net),
    .vpre1(vpre1_int),
    .vpre2(vpre2_int),
    .vpre3(vpre3_int),
    .vpre4(vpre4_int),
    .vw11(vw11),
    .vw42(vw42));
endmodule
