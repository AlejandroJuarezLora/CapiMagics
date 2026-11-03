module opamp_out (
    avdd,
    avss,
    vin2_1,
    vout_1,
    vin2_2,
    vout_2
);

    // --- Alimentacion ---
    inout avdd;
    inout avss;

    // --- Amplificador operacional 1 ---
    input  vin2_1;
    output vout_1;

    // --- Amplificador operacional 2 ---
    input  vin2_2;
    output vout_2;


    // --- Instancia 1 ---
    opamp x1 (
        .avdd (avdd),
        .avss (avss),
        .vin1 (vout_1),
        .vin2 (vin2_1),
        .vout (vout_1)
    );


    // --- Instancia 2 ---
    opamp x2 (
        .avdd (avdd),
        .avss (avss),
        .vin1 (vout_2),
        .vin2 (vin2_2),
        .vout (vout_2)
    );

endmodule
