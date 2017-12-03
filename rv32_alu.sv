`ifndef RV32_ALU
`define RV32_ALU

`include "rv32_alu_ops.sv"

module rv32_alu (
    input clk,

    /* control in */
    input [3:0] op_in,
    input sub_sra_in,
    input src1_in,
    input src2_in,

    /* data in */
    input [31:0] pc_in,
    input [31:0] rs1_value_in,
    input [31:0] rs2_value_in,
    input [31:0] imm_in,

    /* data out */
    output [31:0] result_out
);
    logic [31:0] src1 = src1_in ? pc_in : rs1_value_in;
    logic [31:0] src2 = src2_in ? imm_in : rs2_value_in;

    logic src1_sign = src1[31];
    logic src2_sign = src2[31];

    logic [4:0] shamt = src2[4:0];

    logic [32:0] add_sub = sub_sra_in ? src1 - src2 : src1 + src2;
    logic [31:0] srl_sra = $signed({sub_sra_in ? src1_sign : 1'b0, src1}) >>> shamt;

    logic carry = add_sub[32];
    logic sign  = add_sub[31];
    logic ovf   = (!src1_sign && src2_sign && sign) || (src1_sign && !src2_sign && !sign);

    logic lt  = sign != ovf;
    logic ltu = carry;

    always_ff @(posedge clk) begin
        case (op_in)
            RV32_ALU_OP_ADD_SUB: result_out <= add_sub[31:0];
            RV32_ALU_OP_XOR:     result_out <= src1 ^ src2;
            RV32_ALU_OP_OR:      result_out <= src1 | src2;
            RV32_ALU_OP_AND:     result_out <= src1 & src2;
            RV32_ALU_OP_SLL:     result_out <= src1 << shamt;
            RV32_ALU_OP_SRL_SRA: result_out <= srl_sra;
            RV32_ALU_OP_SLT:     result_out <= {31'b0, lt};
            RV32_ALU_OP_SLTU:    result_out <= {31'b0, ltu};
            RV32_ALU_OP_SRC1P4:  result_out <= src1 + 4;
            RV32_ALU_OP_SRC2:    result_out <= src2;
            default:             result_out <= 32'bx;
        endcase
    end
endmodule

`endif
