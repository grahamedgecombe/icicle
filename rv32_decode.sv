`ifndef RV32_DECODE
`define RV32_DECODE

`include "rv32_alu.sv"
`include "rv32_branch.sv"
`include "rv32_mem.sv"
`include "rv32_opcodes.sv"
`include "rv32_regs.sv"

module rv32_decode (
    input clk,

    /* control in (from hazard) */
    input stall_in,
    input flush_in,

    /* control in (from writeback) */
    input [4:0] rd_in,
    input rd_write_in,

    /* data in */
    input [31:0] pc_in,
    input [31:0] instr_in,

    /* data in (from writeback) */
    input [31:0] rd_value_in,

    /* control out (to hazard) */
    output logic [4:0] rs1_unreg_out,
    output logic [4:0] rs2_unreg_out,

    /* control out */
    output logic valid_out,
    output logic [4:0] rs1_out,
    output logic [4:0] rs2_out,
    output logic [2:0] alu_op_out,
    output logic alu_sub_sra_out,
    output logic [1:0] alu_src1_out,
    output logic [1:0] alu_src2_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic [1:0] mem_width_out,
    output logic mem_zero_extend_out,
    output logic mem_fence_out,
    output logic [1:0] branch_op_out,
    output logic branch_pc_src_out,
    output logic [4:0] rd_out,
    output logic rd_write_out,

    /* data out */
    output logic [31:0] pc_out,
    output logic [31:0] rs1_value_out,
    output logic [31:0] rs2_value_out,
    output logic [31:0] imm_out
);
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;

    logic sign;

    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_b;
    logic [31:0] imm_u;
    logic [31:0] imm_j;

    logic [31:0] shamt;
    logic [31:0] zimm;

    assign funct7 = instr_in[31:25];
    assign rs2    = instr_in[24:20];
    assign rs1    = instr_in[19:15];
    assign funct3 = instr_in[14:12];
    assign rd     = instr_in[11:7];
    assign opcode = instr_in[6:0];

    assign sign = instr_in[31];

    assign imm_i = {{21{sign}}, instr_in[30:25], instr_in[24:21], instr_in[20]};
    assign imm_s = {{21{sign}}, instr_in[30:25], instr_in[11:8],  instr_in[7]};
    assign imm_b = {{20{sign}}, instr_in[7],     instr_in[30:25], instr_in[11:8],  1'b0};
    assign imm_u = {sign,       instr_in[30:20], instr_in[19:12], 12'b0};
    assign imm_j = {{12{sign}}, instr_in[19:12], instr_in[20],    instr_in[30:25], instr_in[24:21], 1'b0};

    assign shamt = {27'bx, rs2};
    assign zimm  = {27'b0, rs1};

    assign rs1_unreg_out = rs1;
    assign rs2_unreg_out = rs2;

    rv32_regs regs (
        .clk(clk),
        .stall_in(stall_in),

        /* control in */
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd_in),
        .rd_write_in(rd_write_in),

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
            alu_op_out <= 3'bx;
            alu_sub_sra_out <= 1'bx;
            alu_src1_out <= 2'bx;
            alu_src2_out <= 2'bx;
            mem_read_out <= 0;
            mem_write_out <= 0;
            mem_width_out <= 2'bx;
            mem_zero_extend_out <= 1'bx;
            mem_fence_out <= 0;
            branch_op_out <= `RV32_BRANCH_OP_NEVER;
            branch_pc_src_out <= 1'bx;
            rd_out <= rd;
            rd_write_out <= 0;

            pc_out <= pc_in;
            imm_out <= 32'bx;

            casez (instr_in)
                `RV32_INSTR_LUI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_ZERO;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_u;
                end
                `RV32_INSTR_AUIPC: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_PC;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_u;
                end
                `RV32_INSTR_JAL: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_PC;
                    alu_src2_out <= `RV32_ALU_SRC2_FOUR;
                    branch_op_out <= `RV32_BRANCH_OP_ALWAYS;
                    branch_pc_src_out <= `RV32_BRANCH_PC_SRC_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_j;
                end
                `RV32_INSTR_JALR: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_PC;
                    alu_src2_out <= `RV32_ALU_SRC2_FOUR;
                    branch_op_out <= `RV32_BRANCH_OP_ALWAYS;
                    branch_pc_src_out <= `RV32_BRANCH_PC_SRC_REG;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_BEQ: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    branch_op_out <= `RV32_BRANCH_OP_ZERO;
                    branch_pc_src_out <= `RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                `RV32_INSTR_BNE: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    branch_op_out <= `RV32_BRANCH_OP_NON_ZERO;
                    branch_pc_src_out <= `RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                `RV32_INSTR_BLT: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLT;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    branch_op_out <= `RV32_BRANCH_OP_NON_ZERO;
                    branch_pc_src_out <= `RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                `RV32_INSTR_BGE: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLT;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    branch_op_out <= `RV32_BRANCH_OP_ZERO;
                    branch_pc_src_out <= `RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                `RV32_INSTR_BLTU: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLTU;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    branch_op_out <= `RV32_BRANCH_OP_NON_ZERO;
                    branch_pc_src_out <= `RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                `RV32_INSTR_BGEU: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLTU;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    branch_op_out <= `RV32_BRANCH_OP_ZERO;
                    branch_pc_src_out <= `RV32_BRANCH_PC_SRC_IMM;
                    imm_out <= imm_b;
                end
                `RV32_INSTR_LB: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    mem_read_out <= 1;
                    mem_width_out <= `RV32_MEM_WIDTH_BYTE;
                    mem_zero_extend_out <= 0;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_LH: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    mem_read_out <= 1;
                    mem_width_out <= `RV32_MEM_WIDTH_HALF;
                    mem_zero_extend_out <= 0;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_LW: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    mem_read_out <= 1;
                    mem_width_out <= `RV32_MEM_WIDTH_WORD;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_LBU: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    mem_read_out <= 1;
                    mem_width_out <= `RV32_MEM_WIDTH_BYTE;
                    mem_zero_extend_out <= 1;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_LHU: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    mem_read_out <= 1;
                    mem_width_out <= `RV32_MEM_WIDTH_HALF;
                    mem_zero_extend_out <= 1;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_SB: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    mem_write_out <= 1;
                    mem_width_out <= `RV32_MEM_WIDTH_BYTE;
                    imm_out <= imm_s;
                end
                `RV32_INSTR_SH: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    mem_write_out <= 1;
                    mem_width_out <= `RV32_MEM_WIDTH_HALF;
                    imm_out <= imm_s;
                end
                `RV32_INSTR_SW: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    mem_write_out <= 1;
                    mem_width_out <= `RV32_MEM_WIDTH_WORD;
                    imm_out <= imm_s;
                end
                `RV32_INSTR_ADDI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_SLTI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLT;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_SLTIU: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLTU;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_XORI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_XOR;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_ORI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_OR;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_ANDI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_AND;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= imm_i;
                end
                `RV32_INSTR_SLLI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLL;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= shamt;
                end
                `RV32_INSTR_SRLI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SRL_SRA;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= shamt;
                end
                `RV32_INSTR_SRAI: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SRL_SRA;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_IMM;
                    rd_write_out <= 1;
                    imm_out <= shamt;
                end
                `RV32_INSTR_ADD: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_SUB: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_ADD_SUB;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_SLL: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLL;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_SLT: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLT;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_SLTU: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SLTU;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_XOR: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_XOR;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_SRL: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SRL_SRA;
                    alu_sub_sra_out <= 0;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_SRA: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_SRL_SRA;
                    alu_sub_sra_out <= 1;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_OR: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_OR;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_AND: begin
                    valid_out <= 1;
                    alu_op_out <= `RV32_ALU_OP_AND;
                    alu_src1_out <= `RV32_ALU_SRC1_REG;
                    alu_src2_out <= `RV32_ALU_SRC2_REG;
                    rd_write_out <= 1;
                end
                `RV32_INSTR_FENCE: begin
                    valid_out <= 1;
                end
                `RV32_INSTR_FENCE_I: begin
                    valid_out <= 1;
                    mem_fence_out <= 1;
                end
                `RV32_INSTR_ECALL: begin
                    valid_out <= 1;
                    // TODO
                end
                `RV32_INSTR_EBREAK: begin
                    valid_out <= 1;
                    // TODO
                end
                `RV32_INSTR_MRET: begin
                    valid_out <= 1;
                    // TODO
                end
                `RV32_INSTR_WFI: begin
                    valid_out <= 1;
                end
                `RV32_INSTR_CSRRW: begin
                    valid_out <= 1;
                    // TODO
                end
                `RV32_INSTR_CSRRS: begin
                    valid_out <= 1;
                    // TODO
                end
                `RV32_INSTR_CSRRC: begin
                    valid_out <= 1;
                    // TODO
                end
                `RV32_INSTR_CSRRWI: begin
                    valid_out <= 1;
                    // TODO
                end
                `RV32_INSTR_CSRRSI: begin
                    valid_out <= 1;
                    // TODO
                end
                `RV32_INSTR_CSRRCI: begin
                    valid_out <= 1;
                    // TODO
                end
            endcase

            if (flush_in) begin
                mem_read_out <= 0;
                mem_write_out <= 0;
                branch_op_out <= `RV32_BRANCH_OP_NEVER;
                rd_write_out <= 0;
            end
        end
    end
endmodule

`endif
