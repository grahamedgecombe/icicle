`ifndef RV32_ALU
`define RV32_ALU

`define RV32_ALU_OP_ADD_SUB 4'b0000
`define RV32_ALU_OP_XOR     4'b0001
`define RV32_ALU_OP_OR      4'b0010
`define RV32_ALU_OP_AND     4'b0011
`define RV32_ALU_OP_SLL     4'b0100
`define RV32_ALU_OP_SRL_SRA 4'b0101
`define RV32_ALU_OP_SLT     4'b0110
`define RV32_ALU_OP_SLTU    4'b0111
`define RV32_ALU_OP_SRC1P4  4'b1000
`define RV32_ALU_OP_SRC2    4'b1001

`define RV32_ALU_SRC1_REG 1'b0
`define RV32_ALU_SRC1_PC  1'b1

`define RV32_ALU_SRC2_REG 1'b0
`define RV32_ALU_SRC2_IMM 1'b1

module rv32_alu (
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
    output logic [31:0] result_out
);
    logic [31:0] src1;
    logic [31:0] src2;

    logic src1_sign;
    logic src2_sign;

    logic [4:0] shamt;

    logic [32:0] add_sub;
    logic [31:0] srl_sra;

    logic carry;
    logic sign;
    logic ovf;

    logic lt;
    logic ltu;

    assign src1 = src1_in ? pc_in : rs1_value_in;
    assign src2 = src2_in ? imm_in : rs2_value_in;

    assign src1_sign = src1[31];
    assign src2_sign = src2[31];

    assign shamt = src2[4:0];

    assign add_sub = sub_sra_in ? src1 - src2 : src1 + src2;
    assign srl_sra = $signed({sub_sra_in ? src1_sign : 1'b0, src1}) >>> shamt;

    assign carry = add_sub[32];
    assign sign  = add_sub[31];
    assign ovf   = (!src1_sign && src2_sign && sign) || (src1_sign && !src2_sign && !sign);

    assign lt  = sign != ovf;
    assign ltu = carry;

    always_comb begin
        case (op_in)
            `RV32_ALU_OP_ADD_SUB: result_out = add_sub[31:0];
            `RV32_ALU_OP_XOR:     result_out = src1 ^ src2;
            `RV32_ALU_OP_OR:      result_out = src1 | src2;
            `RV32_ALU_OP_AND:     result_out = src1 & src2;
            `RV32_ALU_OP_SLL:     result_out = src1 << shamt;
            `RV32_ALU_OP_SRL_SRA: result_out = srl_sra;
            `RV32_ALU_OP_SLT:     result_out = {31'b0, lt};
            `RV32_ALU_OP_SLTU:    result_out = {31'b0, ltu};
            `RV32_ALU_OP_SRC1P4:  result_out = src1 + 4;
            `RV32_ALU_OP_SRC2:    result_out = src2;
            default:              result_out = 32'bx;
        endcase
    end
endmodule

`endif
