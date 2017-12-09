`ifndef RV32_BRANCH
`define RV32_BRANCH

`define RV32_BRANCH_OP_NEVER    2'b00
`define RV32_BRANCH_OP_ZERO     2'b01
`define RV32_BRANCH_OP_NON_ZERO 2'b10
`define RV32_BRANCH_OP_ALWAYS   2'b11

`define RV32_BRANCH_PC_SRC_IMM 1'b0
`define RV32_BRANCH_PC_SRC_REG 1'b1

module rv32_branch_pc_mux (
    /* control in */
    input pc_src_in,

    /* data in */
    input [31:0] pc_in,
    input [31:0] rs1_value_in,
    input [31:0] imm_in,

    /* data out */
    output [31:0] pc_out
);
    logic [31:0] pc = (pc_src_in ? rs1_value_in : pc_in) + imm_in;

    assign pc_out = {pc[31:1], 1'b0};
endmodule

module rv32_branch (
    /* control in */
    input [1:0] op_in,

    /* data in */
    input [31:0] result_in,

    /* control out */
    output taken_out
);
    logic non_zero = |result_in;

    always_comb begin
        case (op_in)
            `RV32_BRANCH_OP_NEVER:    taken_out = 0;
            `RV32_BRANCH_OP_ZERO:     taken_out = ~non_zero;
            `RV32_BRANCH_OP_NON_ZERO: taken_out = non_zero;
            `RV32_BRANCH_OP_ALWAYS:   taken_out = 1;
        endcase
    end
endmodule

`endif
