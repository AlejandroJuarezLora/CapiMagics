module D14_topcell (
    inout avdd,
    inout avss,
    input Vin,
    input Vin_neg,
    output vpre1,
    output vpre2,
    output vpost1,
    output vpost2,
    output vw11,
    output vw42
);

    // Declaración de los nets internos interconectados
    wire nvpost1;
    wire nvpre1;
    wire nvpost2;
    wire nvpre2;
    wire vpre3;
    wire nvpre3;
    wire vpre4;
    wire nvpre4;
    wire A;
    wire B;
    wire net1;
    wire net2;
    wire net3;
    wire net4;
    wire net5;
    wire net6;

    // // Instancia x1: stdp_4x2_lvs
    // stdp_4x2_lvs x1 (
    //     .vpre1(vpre1),
    //     .vpost1(vpost1),
    //     .nvpost1(nvpost1),
    //     .nvpre1(nvpre1),
    //     .vpost2(vpost2),
    //     .vpre2(vpre2),
    //     .nvpre2(nvpre2),
    //     .nvpost2(nvpost2),
    //     .avdd(avdd),
    //     .vpre3(vpre3),
    //     .avss(avss),
    //     .nvpre3(nvpre3),
    //     .vpre4(vpre4),
    //     .A(A),
    //     .nvpre4(nvpre4),
    //     .B(B),
    //     .net1(net1),
    //     .net2(net2),
    //     .vw11(vw11),
    //     .vw42(vw42)
    // );

    // Instancia x8: encoder
    encoder x8 (
        .avdd(avdd),
        .avss(avss),
        .Vin(Vin),
        .Vin_neg(Vin_neg),
        .net3(net3),
        .net4(net4),
        .net5(net5),
        .net6(net6)
    );

    // Instancia x9: current_mirror
    current_mirror x9 (
        .avdd(avdd),
        .B(B),
        .A(A),
        .avss(avss)
    );

    // Instancia x10: layer_input
    layer_input x10 (
        .avdd(avdd),
        .avss(avss),
        .net3(net3),
        .vpre1(vpre1),
        .nvpre1(nvpre1),
        .net4(net4),
        .vpre2(vpre2),
        .nvpre2(nvpre2),
        .net5(net5),
        .vpre3(vpre3),
        .nvpre3(nvpre3),
        .vpre4(vpre4),
        .net6(net6),
        .nvpre4(nvpre4)
    );

    // Instancia x2: layer_output
    layer_output x2 (
        .avdd(avdd),
        .avss(avss),
        .net2(net2),
        .vpost1(vpost1),
        .nvpost1(nvpost1),
        .vpost2(vpost2),
        .net1(net1),
        .nvpost2(nvpost2)
    );

endmodule