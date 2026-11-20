module D14 (Vin,
    Vin_neg,
    vout_1,
    vout_2,
    vpost1,
    vpost2,
    vpre1,
    vpre2);
 inout Vin;
 inout Vin_neg;
 inout vout_1;
 inout vout_2;
 inout vpost1;
 inout vpost2;
 inout vpre1;
 inout vpre2;


 D14_topcell D14_topcell_u (.Vin(Vin),
    .Vin_neg(Vin_neg),
    .vout_1(vout_1),
    .vout_2(vout_2),
    .vpost1(vpost1),
    .vpost2(vpost2),
    .vpre1(vpre1),
    .vpre2(vpre2));
 avdd_conn u_avdd_conn ();
 avss_conn u_avss_conn ();
endmodule
