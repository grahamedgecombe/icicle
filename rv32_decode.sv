`include "rv32_opcodes.sv"
`include "rv32_regs.sv"

module rv32_decode (
    input clk,

    /* data in */
    input [31:0] pc_in,
    input [31:0] instr_in,

    /* control out */
    output valid,

    /* data out */
    output [31:0] pc_out,
    output [31:0] rs1_value_out,
    output [31:0] rs2_value_out,
    output [31:0] imm_out
);
    logic [6:0] funct7 = instr_in[31:25];
    logic [4:0] rs2    = instr_in[24:20];
    logic [4:0] rs1    = instr_in[19:15];
    logic [2:0] funct3 = instr_in[14:12];
    logic [4:0] rd     = instr_in[11:7];
    logic [6:0] opcode = instr_in[6:0];

    logic sign = instr_in[31];

    logic [31:0] imm_i = {{21{sign}}, instr_in[30:25], instr_in[24:21], instr_in[20]};
    logic [31:0] imm_s = {{21{sign}}, instr_in[30:25], instr_in[11:8],  instr_in[7]};
    logic [31:0] imm_b = {{20{sign}}, instr_in[7],     instr_in[30:25], instr_in[11:8],  1'b0};
    logic [31:0] imm_u = {sign,       instr_in[30:20], instr_in[19:12], 12'b0};
    logic [31:0] imm_j = {{12{sign}}, instr_in[19:12], instr_in[20],    instr_in[30:25], instr_in[24:1], 1'b0};

    rv32_regs regs (
        .clk(clk),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rs1_value_out(rs1_value_out),
        .rs2_value_out(rs2_value_out)
    );

    always_ff @(posedge clk) begin
        pc_out <= pc_in;

        valid <= 0;
        imm_out <= 32'bx;

        casez ({opcode, funct3, funct7})
            {RV32_OPCODE_LUI, RV32_FUNCT3_ANY, RV32_FUNCT7_ANY}: begin
                /* LUI */
                valid <= 1;
                imm_out <= imm_u;
            end
            {RV32_OPCODE_AUIPC, RV32_FUNCT3_ANY, RV32_FUNCT7_ANY}: begin
                /* AUIPC */
                valid <= 1;
                imm_out <= imm_u;
            end
            {RV32_OPCODE_JAL, RV32_FUNCT3_ANY, RV32_FUNCT7_ANY}: begin
                /* JAL */
                valid <= 1;
                imm_out <= imm_j;
            end
            {RV32_OPCODE_JALR, RV32_FUNCT3_ZERO, RV32_FUNCT7_ANY}: begin
                /* JALR */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BEQ, RV32_FUNCT7_ANY}: begin
                /* BEQ */
                valid <= 1;
                imm_out <= imm_b;
            end
            {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BNE, RV32_FUNCT7_ANY}: begin
                /* BNE */
                valid <= 1;
                imm_out <= imm_b;
            end
            {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BLT, RV32_FUNCT7_ANY}: begin
                /* BLT */
                valid <= 1;
                imm_out <= imm_b;
            end
            {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BGE, RV32_FUNCT7_ANY}: begin
                /* BGE */
                valid <= 1;
                imm_out <= imm_b;
            end
            {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BLTU, RV32_FUNCT7_ANY}: begin
                /* BLTU */
                valid <= 1;
                imm_out <= imm_b;
            end
            {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BGEU, RV32_FUNCT7_ANY}: begin
                /* BGEU */
                valid <= 1;
                imm_out <= imm_b;
            end
            {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LB, RV32_FUNCT7_ANY}: begin
                /* LB */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LH, RV32_FUNCT7_ANY}: begin
                /* LH */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LW, RV32_FUNCT7_ANY}: begin
                /* LW */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LBU, RV32_FUNCT7_ANY}: begin
                /* LBU */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LHU, RV32_FUNCT7_ANY}: begin
                /* LHU */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_STORE, RV32_FUNCT3_STORE_SB, RV32_FUNCT7_ANY}: begin
                /* SB */
                valid <= 1;
                imm_out <= imm_s;
            end
            {RV32_OPCODE_STORE, RV32_FUNCT3_STORE_SH, RV32_FUNCT7_ANY}: begin
                /* SH */
                valid <= 1;
                imm_out <= imm_s;
            end
            {RV32_OPCODE_STORE, RV32_FUNCT3_STORE_SW, RV32_FUNCT7_ANY}: begin
                /* SW */
                valid <= 1;
                imm_out <= imm_s;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_ADD_SUB, RV32_FUNCT7_ANY}: begin
                /* ADDI */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SLT, RV32_FUNCT7_ANY}: begin
                /* SLTI */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SLTU, RV32_FUNCT7_ANY}: begin
                /* SLTIU */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_XOR, RV32_FUNCT7_ANY}: begin
                /* XORI */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_OR, RV32_FUNCT7_ANY}: begin
                /* ORI */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_AND, RV32_FUNCT7_ANY}: begin
                /* ANDI */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SLL, RV32_FUNCT7_ZERO}: begin
                /* SLLI */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SRL_SRA, RV32_FUNCT7_ZERO}: begin
                /* SRLI */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SRL_SRA, RV32_FUNCT7_OP_SRA}: begin
                /* SRAI */
                valid <= 1;
                imm_out <= imm_i;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_ADD_SUB, RV32_FUNCT7_ZERO}: begin
                /* ADD */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_ADD_SUB, RV32_FUNCT7_OP_SUB}: begin
                /* SUB */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_SLL, RV32_FUNCT7_ZERO}: begin
                /* SLL */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_SLT, RV32_FUNCT7_ZERO}: begin
                /* SLT */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_SLTU, RV32_FUNCT7_ZERO}: begin
                /* SLTU */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_XOR, RV32_FUNCT7_ZERO}: begin
                /* XOR */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_SRL_SRA, RV32_FUNCT7_ZERO}: begin
                /* SRL */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_SRL_SRA, RV32_FUNCT7_OP_SRA}: begin
                /* SRA */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_OR, RV32_FUNCT7_ZERO}: begin
                /* OR */
                valid <= 1;
            end
            {RV32_OPCODE_OP, RV32_FUNCT3_OP_AND, RV32_FUNCT7_ZERO}: begin
                /* AND */
                valid <= 1;
            end
        endcase
    end
endmodule
