module rvfi_wrapper (
    input clock,
    input reset,
    `RVFI_OUTPUTS
);
    \icicle.cpu.CPU #(
`ifdef `RISCV_FORMAL_BLACKBOX_ALU
        .rvfi_blackbox_alu(1),
`endif
`ifdef `RISCV_FORMAL_BLACKBOX_REGS
        .rvfi_blackbox_regs(1),
`endif
    ) uut (
        .clk(clock),
        .rst(reset),
        `RVFI_CONN
    );
endmodule
