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
    input [31:0] imm_value_in,

    /* data out */
    output logic [31:0] pc_out
);
    logic [31:0] pc;

    assign pc = (pc_src_in ? rs1_value_in : pc_in) + imm_value_in;
    assign pc_out = {pc[31:1], 1'b0};
endmodule

module rv32_branch_unit (
    /* control in */
    input predicted_taken_in,
    input alu_non_zero_in,
    input [1:0] op_in,

    /* control out */
    output logic mispredicted_out
);
    logic taken;

    always_comb begin
        case (op_in)
            `RV32_BRANCH_OP_NEVER:    taken = 0;
            `RV32_BRANCH_OP_ZERO:     taken = ~alu_non_zero_in;
            `RV32_BRANCH_OP_NON_ZERO: taken = alu_non_zero_in;
            `RV32_BRANCH_OP_ALWAYS:   taken = 1;
        endcase
    end

    assign mispredicted_out = taken != predicted_taken_in;
endmodule

`endif
