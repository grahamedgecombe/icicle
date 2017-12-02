`ifndef RV32
`define RV32

`include "rv32_decode.sv"
`include "rv32_execute.sv"
`include "rv32_fetch.sv"
`include "rv32_mem.sv"
`include "rv32_writeback.sv"

module rv32 (
    input clk,
    output [7:0] leds
);
    always_ff @(posedge clk) begin
        if (writeback_rd_writeback && writeback_rd == 31)
            leds <= writeback_rd_value[7:0];
    end

    rv32_fetch fetch (
        .clk(clk),

        /* control in */
        .branch_taken_in(mem_branch_taken),

        /* data in */
        .branch_pc_in(mem_branch_pc),

        /* data out */
        .pc_out(fetch_pc),
        .instr_out(fetch_instr)
    );

    /* fetch -> decode data */
    logic [31:0] fetch_pc;
    logic [31:0] fetch_instr;

    rv32_decode decode (
        .clk(clk),

        /* control in */
        .rd_in(writeback_rd),
        .rd_writeback_in(writeback_rd_writeback),

        /* data in */
        .pc_in(fetch_pc),
        .instr_in(fetch_instr),
        .rd_value_in(writeback_rd_value),

        /* control out */
        .alu_op_out(decode_alu_op),
        .alu_sub_sra_out(decode_alu_sub_sra),
        .alu_src1_out(decode_alu_src1),
        .alu_src2_out(decode_alu_src2),
        .mem_read_en_out(decode_mem_read_en),
        .mem_write_en_out(decode_mem_write_en),
        .branch_op_out(decode_branch_op),
        .branch_pc_src_out(decode_branch_pc_src),
        .rd_out(decode_rd),
        .rd_writeback_out(decode_rd_writeback),

        /* data out */
        .pc_out(decode_pc),
        .rs1_value_out(decode_rs1_value),
        .rs2_value_out(decode_rs2_value),
        .imm_out(decode_imm)
    );

    /* decode -> execute control */
    logic [3:0] decode_alu_op;
    logic decode_alu_sub_sra;
    logic decode_alu_src1;
    logic decode_alu_src2;
    logic decode_mem_read_en;
    logic decode_mem_write_en;
    logic [1:0] decode_branch_op;
    logic decode_branch_pc_src;
    logic [4:0] decode_rd;
    logic decode_rd_writeback;

    /* decode -> execute data */
    logic [31:0] decode_pc;
    logic [31:0] decode_rs1_value;
    logic [31:0] decode_rs2_value;
    logic [31:0] decode_imm;

    rv32_execute execute (
        .clk(clk),

        /* control in */
        .alu_op_in(decode_alu_op),
        .alu_sub_sra_in(decode_alu_sub_sra),
        .alu_src1_in(decode_alu_src1),
        .alu_src2_in(decode_alu_src2),
        .mem_read_en_in(decode_mem_read_en),
        .mem_write_en_in(decode_mem_write_en),
        .branch_op_in(decode_branch_op),
        .branch_pc_src_in(decode_branch_pc_src),
        .rd_in(decode_rd),
        .rd_writeback_in(decode_rd_writeback),

        /* data in */
        .pc_in(decode_pc),
        .rs1_value_in(decode_rs1_value),
        .rs2_value_in(decode_rs2_value),
        .imm_in(decode_imm),

        /* control out */
        .mem_read_en_out(execute_mem_read_en),
        .mem_write_en_out(execute_mem_write_en),
        .branch_op_out(execute_branch_op),
        .rd_out(execute_rd),
        .rd_writeback_out(execute_rd_writeback),

        /* data out */
        .result_out(execute_result),
        .rs2_value_out(execute_rs2_value),
        .branch_pc_out(execute_branch_pc)
    );

    /* execute -> mem control */
    logic execute_mem_read_en;
    logic execute_mem_write_en;
    logic [1:0] execute_branch_op;
    logic [4:0] execute_rd;
    logic execute_rd_writeback;

    /* execute -> mem data */
    logic [31:0] execute_result;
    logic [31:0] execute_rs2_value;
    logic [31:0] execute_branch_pc;

    rv32_mem mem (
        .clk(clk),

        /* control in */
        .read_en_in(execute_mem_read_en),
        .write_en_in(execute_mem_write_en),
        .branch_op_in(execute_branch_op),
        .rd_in(execute_rd),
        .rd_writeback_in(execute_rd_writeback),

        /* data in */
        .result_in(execute_result),
        .rs2_value_in(execute_rs2_value),
        .branch_pc_in(execute_branch_pc),

        /* control out */
        .read_en_out(mem_read_en),
        .branch_taken_out(mem_branch_taken),
        .rd_out(mem_rd),
        .rd_writeback_out(mem_rd_writeback),

        /* data out */
        .result_out(mem_result),
        .read_value_out(mem_read_value),
        .branch_pc_out(mem_branch_pc)
    );

    /* mem -> writeback control */
    logic mem_read_en;
    logic [4:0] mem_rd;
    logic mem_rd_writeback;

    /* mem -> fetch control */
    logic mem_branch_taken;

    /* mem -> writeback data */
    logic [31:0] mem_result;
    logic [31:0] mem_read_value;

    /* mem -> fetch data */
    logic [31:0] mem_branch_pc;

    rv32_writeback writeback (
        .clk(clk),

        /* control in */
        .mem_read_en_in(mem_read_en),
        .rd_in(mem_rd),
        .rd_writeback_in(mem_rd_writeback),

        /* data in */
        .result_in(mem_result),
        .mem_read_value_in(mem_read_value),

        /* control out */
        .rd_out(writeback_rd),
        .rd_writeback_out(writeback_rd_writeback),

        /* data out */
        .rd_value_out(writeback_rd_value)
    );

    /* writeback -> decode control */
    logic [4:0] writeback_rd;
    logic writeback_rd_writeback;

    /* writeback -> decode data */
    logic [31:0] writeback_rd_value;
endmodule

`endif
