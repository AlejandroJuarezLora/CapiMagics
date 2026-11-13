`default_nettype none

//MUCHAS DUDAS AL CREAR TU VERILOG. EN TU PROYECTO DIGITAL, TIENES OTROS puertos distintos. 

module D14 (`ifdef USE_POWER_PINS
        inout VSS,
        inout VDD,
    `endif
    inout Vin,
    inout Vin_neg,
    inout vout_1,
    inout vout_2,
    inout vpre1,
    inout vpre2,
    inout vpost1,
    inout vpost2
);

    

      //LA INSTANCIA DE NUESTRA CELDA DEBERIA IR EN D14_D_padring.v? o a que lo conecto aqui?
     D14_topcell D14_topcell_u (
        `ifdef USE_POWER_PINS
            .avdd  (VDD),
            .avss (VSS),
        `endif
        .Vin(Vin),
        .Vin_neg(Vin_neg),
        .vout_1(vout_1),
        .vout_2(vout_2),
        .vpre1(vpre1),
        .vpre2(vpre2),
        .vpost1(vpost1),
        .vpost2(vpost2)
    );

endmodule

`default_nettype wire

