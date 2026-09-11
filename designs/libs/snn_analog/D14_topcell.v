// celda con encoder y layer_input
module D14_topcell (
    // Entradas del encoder
    input Vin,
    input Vin_neg,
   

    //salidas de stdp_4x2
    output vw11,
    output vw42,
    // input A,
    // input B,


    inout avdd,
    inout avss
);

    // Nets internos entre encoder y layer_input
    wire net3;
    wire net4;
    wire net5;
    wire net6;

    // Nets internos entre layer_input y stdp_4x2
    wire vpre1_int, nvpre1_int;
    wire vpre2_int, nvpre2_int;
    wire vpre3_int, nvpre3_int;
    wire vpre4_int, nvpre4_int;
    
    //Nets entre layer_output y stdp
    wire vpost1_net;
    wire nvpost1_net;
    wire vpost2_net;
    wire nvpost2_net;
    wire ifwd1_net;
    wire ifwd2_net;

    //Nets entre stdp y current mirror
    wire A_wire;
    wire B_wire;



    // Instancia del encoder
    encoder u_encoder (
        .vdd(avdd),
        .vss(avss),
        .Vin(Vin),
        .Vin_neg(Vin_neg),
        .Iex_1_i(net3),
        .Iex_2_i(net4),
        .Iex_3_i(net5),
        .Iex_4_i(net6)
    );

    // Instancia del layer_input
    layer_input u_layer_input (
        .vdd(avdd),
        .vss(avss),
        .Iext1(net3),
        .vout_1(vpre1_int),
        .nvout_1(nvpre1_int),
        .Iext2(net4),
        .vout_2(vpre2_int),
        .nvout_2(nvpre2_int),
        .Iext3(net5),
        .vout_3(vpre3_int),
        .nvout_3(nvpre3_int),
        .vout_4(vpre4_int),
        .Iext4(net6),
        .nvout_4(nvpre4_int)
    );
    // Instancia de la matriz sináptica stdp_4x2
    stdp_4x2 u_stdp_4x2 (
        .vpre1(vpre1_int),
        .vpost1(vpost1_net),
        .nvpost1(nvpost1_net),
        .nvpre1(nvpre1_int),
        .vpost2(vpost2_net),
        .vpre2(vpre2_int),
        .nvpre2(nvpre2_int),
        .nvpost2(nvpost2_net),
        .avdd(avdd),
        .vpre3(vpre3_int),
        .avss(avss),
        .nvpre3(nvpre3_int),
        .vpre4(vpre4_int),
        .A(A_wire),
        .nvpre4(nvpre4_int),
        .B(B_wire),
        .ifwd2(ifwd2_net),
        .ifwd1(ifwd1_net),
        .vw11(vw11),
        .vw42(vw42)
    );

    //instancia de layer_output
    layer_output u_layer_output(
        .Iext1(ifwd1_net),
        .vout_1(vpost1_net),
        .nvout_1(nvpost1_net),
        .Iext2(ifwd2_net),
        .vout_2(vpost2_net),
        .nvout_2(nvpost2_net)
    );


    //instancia del current mirror
    current_mirror u_current_mirror(
        .A(A_wire),
        .B(B_wire)
    );

    

endmodule