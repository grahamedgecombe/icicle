module rvfi_wrapper (
    input clock,
    input reset,
    `RVFI_OUTPUTS
    `RVFI_BUS_OUTPUTS
);
    (* keep *) logic [31:2] ibus_adr;
    (* keep *) logic [31:0] ibus_dat_w;
    (* keep *) `rvformal_rand_reg [31:0] ibus_dat_r;
    (* keep *) logic [3:0] ibus_sel;
    (* keep *) logic ibus_cyc;
    (* keep *) logic ibus_stb;
    (* keep *) logic ibus_we;
    (* keep *) `rvformal_rand_reg ibus_ack;

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

        .ibus__adr(ibus_adr),
        .ibus__dat_w(ibus_dat_w),
        .ibus__dat_r(ibus_dat_r),
        .ibus__sel(ibus_sel),
        .ibus__cyc(ibus_cyc),
        .ibus__stb(ibus_stb),
        .ibus__we(ibus_we),
        .ibus__ack(ibus_ack),
        .ibus__err(1'b0),

        .dbus__adr(dbus_adr),
        .dbus__dat_w(dbus_dat_w),
        .dbus__dat_r(dbus_dat_r),
        .dbus__sel(dbus_sel),
        .dbus__cyc(dbus_cyc),
        .dbus__stb(dbus_stb),
        .dbus__we(dbus_we),
        .dbus__ack(dbus_ack),
        .dbus__err(1'b0),

        `RVFI_CONN
    );

`ifdef RISCV_FORMAL_BUS
    assign rvfi_bus_valid = {ibus_cyc & ibus_stb, dbus_cyc & dbus_stb};
    assign rvfi_bus_insn  = 2'b10;
    assign rvfi_bus_data  = 2'b01;
    assign rvfi_bus_fault = 2'b00;
    assign rvfi_bus_addr  = {ibus_adr, 2'b0, dbus_adr, 2'b0};
    assign rvfi_bus_rmask = {ibus_sel & {4{~ibus_we}}, dbus_sel & {4{~dbus_we}}};
    assign rvfi_bus_wmask = {ibus_sel & {4{ibus_we}}, dbus_sel & {4{dbus_we}}};
    assign rvfi_bus_rdata = {ibus_dat_r, dbus_dat_r};
    assign rvfi_bus_wdata = {ibus_dat_w, dbus_dat_w};
`endif

`ifdef RISCV_FORMAL_FAIRNESS
    logic [7:0] ibus_wait;
    logic [7:0] dbus_wait;

    always_ff @(posedge clock) begin
        if (reset) begin
            ibus_wait <= 0;
            dbus_wait <= 0;
        end else begin
            ibus_wait <= {ibus_wait, ibus_cyc && ibus_stb && ~ibus_ack};
            dbus_wait <= {dbus_wait, dbus_cyc && dbus_stb && ~dbus_ack};
        end

        assume (~&ibus_wait && ~&dbus_wait);
    end
`endif
endmodule
