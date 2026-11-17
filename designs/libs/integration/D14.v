`default_nettype none

// D14: CapiMagics block for the Chipathon 2026 GF padframe (block type D, 605 x 605 um).
// Pin names and locations come from the organizers' D14_D.def.
// The organizers connect this block to the padring (D14_D_padring.v); this file only
// wires the finished D14_topcell macro to the block pins.
module D14 (
`ifdef USE_POWER_PINS
    inout avss,
    inout avdd,
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

    D14_topcell D14_topcell_u (
`ifdef USE_POWER_PINS
        .avdd(avdd),
        .avss(avss),
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

    // Passive Metal2-Metal3 bridges over the avss / avdd DEF pins. They tie the
    // padframe power stripes to the Metal4/Metal5 grid (see connectors/ and pdn_cfg.tcl).
    (* keep *) avss_conn u_avss_conn ();
    (* keep *) avdd_conn u_avdd_conn ();

endmodule

`default_nettype wire
