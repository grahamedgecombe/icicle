`ifndef RV32_EXECUTE
`define RV32_EXECUTE

`include "rv32_alu.sv"
`include "rv32_branch.sv"
`include "rv32_csrs.sv"

module rv32_execute (
    input clk,

    /* control in (from hazard) */
    input stall_in,
    input flush_in,

    /* control in */
    input branch_predicted_taken_in,
    input valid_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [2:0] alu_op_in,
    input alu_sub_sra_in,
    input [1:0] alu_src1_in,
    input [1:0] alu_src2_in,
    input mem_read_in,
    input mem_write_in,
    input [1:0] mem_width_in,
    input mem_zero_extend_in,
    input mem_fence_in,
    input csr_read_in,
    input csr_write_in,
    input [1:0] csr_write_op_in,
    input csr_src_in,
    input [1:0] branch_op_in,
    input branch_pc_src_in,
    input [4:0] rd_in,
    input rd_write_in,

    /* control in (from writeback) */
    input writeback_valid_in,
    input [4:0] writeback_rd_in,
    input writeback_rd_write_in,

    /* data in */
    input [31:0] pc_in,
    input [31:0] rs1_value_in,
    input [31:0] rs2_value_in,
    input [31:0] imm_value_in,
    input [11:0] csr_in,

    /* data in (from writeback) */
    input [31:0] writeback_rd_value_in,

    /* control out */
    output logic branch_predicted_taken_out,
    output logic valid_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic [1:0] mem_width_out,
    output logic mem_zero_extend_out,
    output logic mem_fence_out,
    output logic [1:0] branch_op_out,
    output logic [4:0] rd_out,
    output logic rd_write_out,

    /* data out */
    output logic [31:0] result_out,
    output logic [31:0] rs2_value_out,
    output logic [31:0] branch_pc_out
);
    /* bypassing */
    logic [31:0] rs1_value;
    logic [31:0] rs2_value;

    always_comb begin
        if (rd_write_out && rd_out == rs1_in && |rs1_in)
            rs1_value = result_out;
        else if (writeback_rd_write_in && writeback_rd_in == rs1_in && |rs1_in)
            rs1_value = writeback_rd_value_in;
        else
            rs1_value = rs1_value_in;

        if (rd_write_out && rd_out == rs2_in && |rs2_in)
            rs2_value = result_out;
        else if (writeback_rd_write_in && writeback_rd_in == rs2_in && |rs2_in)
            rs2_value = writeback_rd_value_in;
        else
            rs2_value = rs2_value_in;
    end

    /* ALU */
    logic [31:0] alu_result;

    rv32_alu alu (
        /* control in */
        .op_in(alu_op_in),
        .sub_sra_in(alu_sub_sra_in),
        .src1_in(alu_src1_in),
        .src2_in(alu_src2_in),

        /* data in */
        .pc_in(pc_in),
        .rs1_value_in(rs1_value),
        .rs2_value_in(rs2_value),
        .imm_value_in(imm_value_in),

        /* data out */
        .result_out(alu_result)
    );

    /* csr file */
    logic [31:0] csr_read_value;

    rv32_csrs csrs (
        .clk(clk),

        /* control in */
        .read_in(csr_read_in),
        .write_in(csr_write_in),
        .write_op_in(csr_write_op_in),
        .src_in(csr_src_in),

        /* control in (from writeback) */
        .instr_retired_in(writeback_valid_in),

        /* data in */
        .rs1_value_in(rs1_value),
        .imm_value_in(imm_value_in),
        .csr_in(csr_in),

        /* data out */
        .read_value_out(csr_read_value)
    );

    /* branch target calculation */
    logic [31:0] branch_pc;

    rv32_branch_pc_mux branch_pc_mux (
        /* control in */
        .pc_src_in(branch_pc_src_in),

        /* data in */
        .pc_in(pc_in),
        .rs1_value_in(rs1_value),
        .imm_value_in(imm_value_in),

        /* data out */
        .pc_out(branch_pc)
    );

    always_ff @(posedge clk) begin
        if (!stall_in) begin
            branch_predicted_taken_out <= branch_predicted_taken_in;
            valid_out <= valid_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_width_out <= mem_width_in;
            mem_zero_extend_out <= mem_zero_extend_in;
            mem_fence_out <= mem_fence_in;
            branch_op_out <= branch_op_in;
            rd_out <= rd_in;
            rd_write_out <= rd_write_in;
            rs2_value_out <= rs2_value;
            branch_pc_out <= branch_pc;

            if (csr_read_in)
                result_out <= csr_read_value;
            else
                result_out <= alu_result;

            if (flush_in) begin
                valid_out <= 0;
                mem_read_out <= 0;
                mem_write_out <= 0;
                branch_op_out <= `RV32_BRANCH_OP_NEVER;
                rd_write_out <= 0;
            end
        end
    end
endmodule

`endif
