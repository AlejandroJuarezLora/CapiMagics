module opamp_out (vin2_1,
    vin2_2,
    vout_1,
    vout_2);
 input vin2_1;
 input vin2_2;
 output vout_1;
 output vout_2;


 opamp x1 (.vout(vout_1),
    .vin1(vout_1),
    .vin2(vin2_1));
 opamp x2 (.vout(vout_2),
    .vin1(vout_2),
    .vin2(vin2_2));
endmodule
