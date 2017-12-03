`ifndef RV32_FETCH
`define RV32_FETCH

`include "rv32_opcodes.sv"

module rv32_fetch (
    input clk,
    input stall,
    input flush,

    /* control in (from mem) */
    input branch_taken_in,

    /* data in (from mem) */
    input [31:0] branch_pc_in,

    /* data out */
    output [31:0] pc_out,
    output [31:0] instr_out
);
    logic [31:0] instr_mem [255:0];
    logic [31:0] next_pc;

    logic [31:0] pc = branch_taken_in ? branch_pc_in : next_pc;

    initial
        $readmemh("progmem_syn.hex", instr_mem);

    always_ff @(posedge clk) begin
        if (!stall) begin
            instr_out <= instr_mem[pc[31:2]];
            next_pc <= pc + 4;
            pc_out <= pc;

            if (flush)
                instr_out <= RV32_INSTR_NOP;
        end
    end
endmodule

`endif
