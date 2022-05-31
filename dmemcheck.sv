`include "defines.sv"

module testbench (
    input clock
);
    logic reset = 1;

    always_ff @(posedge clock) begin
        reset <= 0;
    end

    `RVFI_WIRES

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

    (* keep *) logic [31:0] dmem_addr;
    (* keep *) logic [31:0] dmem_data;

    rvfi_dmem_check checker_inst (
        .clock(clock),
        .reset(reset),
        .enable(1),
        .dmem_addr(dmem_addr),
        `RVFI_CONN
    );

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

    always_ff @(posedge clock) begin
        if (reset) begin
            dmem_data <= 0;
        end else begin
            if (dbus_cyc && dbus_stb && dbus_ack && dbus_we && dbus_adr == dmem_addr[31:2]) begin
                if (dbus_sel[3]) dmem_data[31:24] <= dbus_dat_w[31:24];
                if (dbus_sel[2]) dmem_data[23:16] <= dbus_dat_w[23:16];
                if (dbus_sel[1]) dmem_data[15: 8] <= dbus_dat_w[15: 8];
                if (dbus_sel[0]) dmem_data[ 7: 0] <= dbus_dat_w[ 7: 0];
            end
        end
    end

    always_comb begin
        if (~reset && dbus_cyc && dbus_stb && dbus_ack && ~dbus_we && dbus_adr == dmem_addr[31:2]) begin
            assume (dmem_data == dbus_dat_r);
        end
    end
endmodule
