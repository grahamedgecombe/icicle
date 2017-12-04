`ifndef RV32_DECODE
`define RV32_DECODE

`include "rv32_alu_ops.sv"
`include "rv32_branch_ops.sv"
`include "rv32_mem_ops.sv"
`include "rv32_opcodes.sv"
`include "rv32_regs.sv"

module rv32_decode (
    input clk,

    /* control in (from hazard) */
    input stall_in,
    input flush_in,

    /* control in (from writeback) */
    input [4:0] rd_in,
    input rd_writeback_in,

    /* data in */
    input [31:0] pc_in,
    input [31:0] instr_in,

    /* data in (from writeback) */
    input [31:0] rd_value_in,

    /* control out */
    output valid_out,
    output [4:0] rs1_out,
    output [4:0] rs2_out,
    output [3:0] alu_op_out,
    output alu_sub_sra_out,
    output alu_src1_out,
    output alu_src2_out,
    output mem_read_en_out,
    output mem_write_en_out,
    output [1:0] mem_width_out,
    output mem_zero_extend_out,
    output [1:0] branch_op_out,
    output branch_pc_src_out,
    output [4:0] rd_out,
    output rd_writeback_out,

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
    logic [31:0] imm_j = {{12{sign}}, instr_in[19:12], instr_in[20],    instr_in[30:25], instr_in[24:21], 1'b0};

    logic [31:0] shamt = {27'bx, rs2};

    rv32_regs regs (
        .clk(clk),
        .stall_in(stall_in),

        /* control in */
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd_in),
        .rd_writeback_in(rd_writeback_in),

        /* data in */
        .rd_value_in(rd_value_in),

        /* data out */
        .rs1_value_out(rs1_value_out),
        .rs2_value_out(rs2_value_out)
    );

    always_ff @(posedge clk) begin
        if (!stall_in) begin
            valid_out <= 0;
            rs1_out <= rs1;
            rs2_out <= rs2;
            alu_op_out <= 4'bx;
            alu_sub_sra_out <= 1'bx;
            alu_src1_out <= 1'bx;
            alu_src2_out <= 1'bx;
            mem_read_en_out <= 0;
            mem_write_en_out <= 0;
            mem_width_out <= 2'bx;
            mem_zero_extend_out <= 1'bx;
            branch_op_out <= RV32_BRANCH_OP_NEVER;
            branch_pc_src_out <= 1'bx;
            rd_out <= rd;
            rd_writeback_out <= 0;

            pc_out <= pc_in;
            imm_out <= 32'bx;

            casez ({opcode, funct3, funct7})
                {RV32_OPCODE_LUI, RV32_FUNCT3_ANY, RV32_FUNCT7_ANY}: begin
                    /* LUI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SRC2;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_u;
                end
                {RV32_OPCODE_AUIPC, RV32_FUNCT3_ANY, RV32_FUNCT7_ANY}: begin
                    /* AUIPC */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_PC;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_u;
                end
                {RV32_OPCODE_JAL, RV32_FUNCT3_ANY, RV32_FUNCT7_ANY}: begin
                    /* JAL */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SRC1P4;
                    alu_src1_out <= RV32_ALU_SRC1_PC;
                    branch_op_out <= RV32_BRANCH_OP_ALWAYS;
                    branch_pc_src_out <= RV32_BRANCH_PC_SRC_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_j;
                end
                {RV32_OPCODE_JALR, RV32_FUNCT3_ZERO, RV32_FUNCT7_ANY}: begin
                    /* JALR */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SRC1P4;
                    alu_src1_out <= RV32_ALU_SRC1_PC;
                    branch_op_out <= RV32_BRANCH_OP_ALWAYS;
                    branch_pc_src_out <= RV32_BRANCH_PC_SRC_REG;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BEQ, RV32_FUNCT7_ANY}: begin
                    /* BEQ */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    branch_op_out <= RV32_BRANCH_OP_ZERO;
                    branch_pc_src_out <= RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BNE, RV32_FUNCT7_ANY}: begin
                    /* BNE */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    branch_op_out <= RV32_BRANCH_OP_NON_ZERO;
                    branch_pc_src_out <= RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BLT, RV32_FUNCT7_ANY}: begin
                    /* BLT */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLT;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    branch_op_out <= RV32_BRANCH_OP_NON_ZERO;
                    branch_pc_src_out <= RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BGE, RV32_FUNCT7_ANY}: begin
                    /* BGE */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLT;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    branch_op_out <= RV32_BRANCH_OP_ZERO;
                    branch_pc_src_out <= RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BLTU, RV32_FUNCT7_ANY}: begin
                    /* BLTU */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLTU;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    branch_op_out <= RV32_BRANCH_OP_NON_ZERO;
                    branch_pc_src_out <= RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                {RV32_OPCODE_BRANCH, RV32_FUNCT3_BRANCH_BGEU, RV32_FUNCT7_ANY}: begin
                    /* BGEU */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLTU;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    branch_op_out <= RV32_BRANCH_OP_ZERO;
                    branch_pc_src_out <= RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LB, RV32_FUNCT7_ANY}: begin
                    /* LB */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    mem_read_en_out <= 1;
                    mem_width_out <= RV32_MEM_WIDTH_BYTE;
                    mem_zero_extend_out <= 0;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LH, RV32_FUNCT7_ANY}: begin
                    /* LH */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    mem_read_en_out <= 1;
                    mem_width_out <= RV32_MEM_WIDTH_HALF;
                    mem_zero_extend_out <= 0;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LW, RV32_FUNCT7_ANY}: begin
                    /* LW */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    mem_read_en_out <= 1;
                    mem_width_out <= RV32_MEM_WIDTH_WORD;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LBU, RV32_FUNCT7_ANY}: begin
                    /* LBU */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    mem_read_en_out <= 1;
                    mem_width_out <= RV32_MEM_WIDTH_BYTE;
                    mem_zero_extend_out <= 1;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_LOAD, RV32_FUNCT3_LOAD_LHU, RV32_FUNCT7_ANY}: begin
                    /* LHU */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    mem_read_en_out <= 1;
                    mem_width_out <= RV32_MEM_WIDTH_HALF;
                    mem_zero_extend_out <= 1;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_STORE, RV32_FUNCT3_STORE_SB, RV32_FUNCT7_ANY}: begin
                    /* SB */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    mem_write_en_out <= 1;
                    mem_width_out <= RV32_MEM_WIDTH_BYTE;
                    imm_out <= imm_s;
                end
                {RV32_OPCODE_STORE, RV32_FUNCT3_STORE_SH, RV32_FUNCT7_ANY}: begin
                    /* SH */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    mem_write_en_out <= 1;
                    mem_width_out <= RV32_MEM_WIDTH_HALF;
                    imm_out <= imm_s;
                end
                {RV32_OPCODE_STORE, RV32_FUNCT3_STORE_SW, RV32_FUNCT7_ANY}: begin
                    /* SW */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    mem_write_en_out <= 1;
                    mem_width_out <= RV32_MEM_WIDTH_WORD;
                    imm_out <= imm_s;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_ADD_SUB, RV32_FUNCT7_ANY}: begin
                    /* ADDI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SLT, RV32_FUNCT7_ANY}: begin
                    /* SLTI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLT;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SLTU, RV32_FUNCT7_ANY}: begin
                    /* SLTIU */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLTU;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_XOR, RV32_FUNCT7_ANY}: begin
                    /* XORI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_XOR;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_OR, RV32_FUNCT7_ANY}: begin
                    /* ORI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_OR;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_AND, RV32_FUNCT7_ANY}: begin
                    /* ANDI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_AND;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= imm_i;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SLL, RV32_FUNCT7_ZERO}: begin
                    /* SLLI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLL;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= shamt;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SRL_SRA, RV32_FUNCT7_ZERO}: begin
                    /* SRLI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SRL_SRA;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= shamt;
                end
                {RV32_OPCODE_OP_IMM, RV32_FUNCT3_OP_SRL_SRA, RV32_FUNCT7_OP_SRA}: begin
                    /* SRAI */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SRL_SRA;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_IMM;
                    rd_writeback_out <= 1;
                    imm_out <= shamt;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_ADD_SUB, RV32_FUNCT7_ZERO}: begin
                    /* ADD */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_ADD_SUB, RV32_FUNCT7_OP_SUB}: begin
                    /* SUB */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_SLL, RV32_FUNCT7_ZERO}: begin
                    /* SLL */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLL;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_SLT, RV32_FUNCT7_ZERO}: begin
                    /* SLT */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLT;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_SLTU, RV32_FUNCT7_ZERO}: begin
                    /* SLTU */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SLTU;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_XOR, RV32_FUNCT7_ZERO}: begin
                    /* XOR */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_XOR;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_SRL_SRA, RV32_FUNCT7_ZERO}: begin
                    /* SRL */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SRL_SRA;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_SRL_SRA, RV32_FUNCT7_OP_SRA}: begin
                    /* SRA */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_SRL_SRA;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_OR, RV32_FUNCT7_ZERO}: begin
                    /* OR */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_OR;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_OP, RV32_FUNCT3_OP_AND, RV32_FUNCT7_ZERO}: begin
                    /* AND */
                    valid_out <= 1;
                    alu_op_out <= RV32_ALU_OP_AND;
                    alu_src1_out <= RV32_ALU_SRC1_REG;
                    alu_src2_out <= RV32_ALU_SRC2_REG;
                    rd_writeback_out <= 1;
                end
                {RV32_OPCODE_MISC_MEM, RV32_FUNCT3_MISC_MEM_FENCE, RV32_FUNCT7_ANY}: begin
                    /* FENCE */
                    valid_out <= 1;
                end
                {RV32_OPCODE_MISC_MEM, RV32_FUNCT3_MISC_MEM_FENCE_I, RV32_FUNCT7_ANY}: begin
                    /* FENCE.I */
                    valid_out <= 1;
                end
            endcase

            if (flush_in) begin
                rs1_out <= 0;
                rs2_out <= 0;
                mem_read_en_out <= 0;
                mem_write_en_out <= 0;
                branch_op_out <= RV32_BRANCH_OP_NEVER;
                rd_writeback_out <= 0;
            end
        end
    end
endmodule

`endif
