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
        .ibus__err(0),

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

    (* keep *) logic spec_valid;
    (* keep *) logic spec_trap;
    (* keep *) logic [4:0] spec_rs1_addr;
    (* keep *) logic [4:0] spec_rs2_addr;
    (* keep *) logic [4:0] spec_rd_addr;
    (* keep *) logic [`RISCV_FORMAL_XLEN-1:0] spec_rd_wdata;
    (* keep *) logic [`RISCV_FORMAL_XLEN-1:0] spec_pc_wdata;
    (* keep *) logic [`RISCV_FORMAL_XLEN-1:0] spec_mem_addr;
    (* keep *) logic [`RISCV_FORMAL_XLEN/8-1:0] spec_mem_rmask;
    (* keep *) logic [`RISCV_FORMAL_XLEN/8-1:0] spec_mem_wmask;
    (* keep *) logic [`RISCV_FORMAL_XLEN-1:0] spec_mem_wdata;

    rvfi_isa_rv32i isa_spec (
        .rvfi_valid(rvfi_valid),
        .rvfi_insn(rvfi_insn),
        .rvfi_pc_rdata(rvfi_pc_rdata),
        .rvfi_rs1_rdata(rvfi_rs1_rdata),
        .rvfi_rs2_rdata(rvfi_rs2_rdata),
        .rvfi_mem_rdata(rvfi_mem_rdata),

        .spec_valid(spec_valid),
        .spec_trap(spec_trap),
        .spec_rs1_addr(spec_rs1_addr),
        .spec_rs2_addr(spec_rs2_addr),
        .spec_rd_addr(spec_rd_addr),
        .spec_rd_wdata(spec_rd_wdata),
        .spec_pc_wdata(spec_pc_wdata),
        .spec_mem_addr(spec_mem_addr),
        .spec_mem_rmask(spec_mem_rmask),
        .spec_mem_wmask(spec_mem_wmask),
        .spec_mem_wdata(spec_mem_wdata)
    );

    always_comb begin
        if (~reset && rvfi_valid && ~rvfi_trap) begin
            assert (spec_valid && ~spec_trap);
        end
    end
endmodule
