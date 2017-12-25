`ifndef RV32_FETCH
`define RV32_FETCH

`include "rv32_opcodes.sv"

module rv32_fetch (
    input clk,

    /* control in (from hazard) */
    input stall_in,
    input flush_in,

    /* control in (from mem) */
    input branch_taken_in,

    /* data in (from mem) */
    input [31:0] branch_pc_in,

    /* data in (from memory bus) */
    input [31:0] instr_read_value_in,

    /* control out */
    output logic instr_read_out,

    /* data out */
    output logic [31:0] pc_out,
    output logic [31:0] instr_out,

    /* data out (to memory bus) */
    output logic [31:0] instr_address_out
);
    logic [31:0] next_pc;
    logic [31:0] pc;

    assign pc = branch_taken_in ? branch_pc_in : next_pc;
    assign instr_read_out = 1;
    assign instr_address_out = pc;

    always_ff @(posedge clk) begin
        if (!stall_in) begin
            instr_out <= instr_read_value_in;
            next_pc <= pc + 4;
            pc_out <= pc;

            if (flush_in)
                instr_out <= `RV32_INSTR_NOP;
        end
    end
endmodule

`endif
