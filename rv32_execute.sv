`ifndef RV32_EXECUTE
`define RV32_EXECUTE

`include "rv32_alu.sv"
`include "rv32_branch.sv"

module rv32_execute (
    input clk,

    /* control in */
    input [3:0] alu_op_in,
    input alu_sub_sra_in,
    input alu_src1_in,
    input alu_src2_in,
    input mem_read_en_in,
    input mem_write_en_in,
    input [1:0] mem_width_in,
    input mem_zero_extend_in,
    input [1:0] branch_op_in,
    input branch_pc_src_in,
    input [4:0] rd_in,
    input rd_writeback_in,

    /* data in */
    input [31:0] pc_in,
    input [31:0] rs1_value_in,
    input [31:0] rs2_value_in,
    input [31:0] imm_in,

    /* control out */
    output mem_read_en_out,
    output mem_write_en_out,
    output [1:0] mem_width_out,
    output mem_zero_extend_out,
    output [1:0] branch_op_out,
    output [4:0] rd_out,
    output rd_writeback_out,

    /* data out */
    output [31:0] result_out,
    output [31:0] rs2_value_out,
    output [31:0] branch_pc_out
);
    rv32_alu alu (
        .clk(clk),

        /* control in */
        .op_in(alu_op_in),
        .sub_sra_in(alu_sub_sra_in),
        .src1_in(alu_src1_in),
        .src2_in(alu_src2_in),

        /* data in */
        .pc_in(pc_in),
        .rs1_value_in(rs1_value_in),
        .rs2_value_in(rs2_value_in),
        .imm_in(imm_in),

        /* data out */
        .result_out(result_out)
    );

    rv32_branch_pc_mux branch_pc_mux (
        .clk(clk),

        /* control in */
        .pc_src_in(branch_pc_src_in),

        /* data in */
        .pc_in(pc_in),
        .rs1_value_in(rs1_value_in),
        .imm_in(imm_in),

        /* data out */
        .pc_out(branch_pc_out)
    );

    always_ff @(posedge clk) begin
        mem_read_en_out <= mem_read_en_in;
        mem_write_en_out <= mem_write_en_in;
        mem_width_out <= mem_width_in;
        mem_zero_extend_out <= mem_zero_extend_in;
        branch_op_out <= branch_op_in;
        rd_out <= rd_in;
        rd_writeback_out <= rd_writeback_in;
        rs2_value_out <= rs2_value_in;
    end
endmodule

`endif
