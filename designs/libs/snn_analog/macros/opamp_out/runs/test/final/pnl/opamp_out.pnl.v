module opamp_out (avdd,
    avss,
    vin2_1,
    vin2_2,
    vout_1,
    vout_2);
 inout avdd;
 inout avss;
 input vin2_1;
 input vin2_2;
 output vout_1;
 output vout_2;


 opamp x1 (.avdd(avdd),
    .avss(avss),
    .vout(vout_1),
    .vin1(vout_1),
    .vin2(vin2_1));
 opamp x2 (.avdd(avdd),
    .avss(avss),
    .vout(vout_2),
    .vin1(vout_2),
    .vin2(vin2_2));
endmodule
