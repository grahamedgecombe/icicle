`ifndef RV32_BRANCH
`define RV32_BRANCH

`include "rv32_branch_ops.sv"

module rv32_branch_pc_mux (
    input clk,

    /* control in */
    input pc_src_in,

    /* data in */
    input [31:0] pc_in,
    input [31:0] rs1_value_in,
    input [31:0] imm_in,

    /* data out */
    output [31:0] pc_out
);
    always_ff @(posedge clk)
        pc_out <= (pc_src_in ? rs1_value_in : pc_in) + imm_in;
endmodule

module rv32_branch (
    /* control in */
    input [1:0] op_in,

    /* data in */
    input [31:0] result_in,

    /* control out */
    output taken_out
);
    wire non_zero = |result_in;

    always_ff begin
        case (op_in)
            RV32_BRANCH_OP_NEVER:    taken_out = 0;
            RV32_BRANCH_OP_ZERO:     taken_out = ~non_zero;
            RV32_BRANCH_OP_NON_ZERO: taken_out = non_zero;
            RV32_BRANCH_OP_ALWAYS:   taken_out = 1;
        endcase
    end
endmodule

`endif
