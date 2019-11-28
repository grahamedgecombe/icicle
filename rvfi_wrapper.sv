module rvfi_wrapper (
    input clock,
    input reset,
    `RVFI_OUTPUTS
);
    (* keep *) logic [31:2] dbus_adr;
    (* keep *) logic [31:0] dbus_dat_w;
    (* keep *) `rvformal_rand_reg [31:0] dbus_dat_r;
    (* keep *) logic [3:0] dbus_sel;
    (* keep *) logic dbus_cyc;
    (* keep *) logic dbus_stb;
    (* keep *) logic dbus_we;
    (* keep *) `rvformal_rand_reg dbus_ack;

    \icicle.cpu.CPU #(
        .rvfi(1),
`ifdef RISCV_FORMAL_BLACKBOX_ALU
        .rvfi_blackbox_alu(1),
`endif
`ifdef RISCV_FORMAL_BLACKBOX_REGS
        .rvfi_blackbox_regs(1),
`endif
    ) uut (
        .clk(clock),
        .rst(reset),

        .dbus__adr(dbus_adr),
        .dbus__dat_w(dbus_dat_w),
        .dbus__dat_r(dbus_dat_r),
        .dbus__sel(dbus_sel),
        .dbus__cyc(dbus_cyc),
        .dbus__stb(dbus_stb),
        .dbus__we(dbus_we),
        .dbus__ack(dbus_ack),
        .dbus__err(0),

        `RVFI_CONN
    );

`ifdef RISCV_FORMAL_FAIRNESS
    logic [7:0] dbus_wait = 0;

    always_ff @(posedge clock) begin
        dbus_wait <= {dbus_wait, dbus_cyc && dbus_stb && ~dbus_ack};
        assume (!dbus_wait);
    end
`endif
endmodule
