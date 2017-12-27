`ifndef RV32_DECODE
`define RV32_DECODE

`include "rv32_control.sv"
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
    output logic [31:0] imm_value_out
);
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [4:0] rd;

    assign rs2 = instr_in[24:20];
    assign rs1 = instr_in[19:15];
    assign rd  = instr_in[11:7];

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

    logic valid;
    logic [2:0] imm;
    logic [2:0] alu_op;
    logic alu_sub_sra;
    logic [1:0] alu_src1;
    logic [1:0] alu_src2;
    logic mem_read;
    logic mem_write;
    logic [1:0] mem_width;
    logic mem_zero_extend;
    logic mem_fence;
    logic [1:0] branch_op;
    logic branch_pc_src;
    logic rd_write;

    rv32_control_unit control_unit (
        /* data in */
        .instr_in(instr_in),

        /* control out */
        .valid_out(valid),
        .imm_out(imm),
        .alu_op_out(alu_op),
        .alu_sub_sra_out(alu_sub_sra),
        .alu_src1_out(alu_src1),
        .alu_src2_out(alu_src2),
        .mem_read_out(mem_read),
        .mem_write_out(mem_write),
        .mem_width_out(mem_width),
        .mem_zero_extend_out(mem_zero_extend),
        .mem_fence_out(mem_fence),
        .branch_op_out(branch_op),
        .branch_pc_src_out(branch_pc_src),
        .rd_write_out(rd_write)
    );

    logic [31:0] imm_value;

    rv32_imm_mux imm_mux (
        /* control in */
        .imm_in(imm),

        /* data in */
        .instr_in(instr_in),

        /* data out */
        .imm_value_out(imm_value)
    );

    always_ff @(posedge clk) begin
        if (!stall_in) begin
            rs1_out <= rs1;
            rs2_out <= rs2;
            alu_op_out <= alu_op;
            alu_sub_sra_out <= alu_sub_sra;
            alu_src1_out <= alu_src1;
            alu_src2_out <= alu_src2;
            mem_read_out <= mem_read;
            mem_write_out <= mem_write;
            mem_width_out <= mem_width;
            mem_zero_extend_out <= mem_zero_extend;
            mem_fence_out <= mem_fence;
            branch_op_out <= branch_op;
            branch_pc_src_out <= branch_pc_src;
            rd_out <= rd;
            rd_write_out <= rd_write;

            pc_out <= pc_in;
            imm_value_out <= imm_value;

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
