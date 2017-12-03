`ifndef RV32
`define RV32

`include "rv32_decode.sv"
`include "rv32_execute.sv"
`include "rv32_fetch.sv"
`include "rv32_mem.sv"

module rv32 (
    input clk,
    output [7:0] leds
);
    always_ff @(posedge clk) begin
        if (mem_rd_writeback && mem_rd == 31)
            leds <= mem_rd_value[7:0];
    end

    rv32_fetch fetch (
        .clk(clk),
        .stall(0),
        .flush(0),

        /* control in (from mem) */
        .branch_taken_in(mem_branch_taken),

        /* data in (from mem) */
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
        .stall(0),
        .flush(0),

        /* control in (from writeback) */
        .rd_in(mem_rd),
        .rd_writeback_in(mem_rd_writeback),

        /* data in */
        .pc_in(fetch_pc),
        .instr_in(fetch_instr),

        /* data in (from writeback) */
        .rd_value_in(mem_rd_value),

        /* control out */
        .rs1_out(decode_rs1),
        .rs2_out(decode_rs2),
        .alu_op_out(decode_alu_op),
        .alu_sub_sra_out(decode_alu_sub_sra),
        .alu_src1_out(decode_alu_src1),
        .alu_src2_out(decode_alu_src2),
        .mem_read_en_out(decode_mem_read_en),
        .mem_write_en_out(decode_mem_write_en),
        .mem_width_out(decode_mem_width),
        .mem_zero_extend_out(decode_mem_zero_extend),
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
    logic [4:0] decode_rs1;
    logic [4:0] decode_rs2;
    logic [3:0] decode_alu_op;
    logic decode_alu_sub_sra;
    logic decode_alu_src1;
    logic decode_alu_src2;
    logic decode_mem_read_en;
    logic decode_mem_write_en;
    logic [1:0] decode_mem_width;
    logic decode_mem_zero_extend;
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
        .stall(0),
        .flush(0),

        /* control in */
        .rs1_in(decode_rs1),
        .rs2_in(decode_rs2),
        .alu_op_in(decode_alu_op),
        .alu_sub_sra_in(decode_alu_sub_sra),
        .alu_src1_in(decode_alu_src1),
        .alu_src2_in(decode_alu_src2),
        .mem_read_en_in(decode_mem_read_en),
        .mem_write_en_in(decode_mem_write_en),
        .mem_width_in(decode_mem_width),
        .mem_zero_extend_in(decode_mem_zero_extend),
        .branch_op_in(decode_branch_op),
        .branch_pc_src_in(decode_branch_pc_src),
        .rd_in(decode_rd),
        .rd_writeback_in(decode_rd_writeback),

        /* control in (from writeback) */
        .writeback_rd_in(mem_rd),
        .writeback_rd_writeback_in(mem_rd_writeback),

        /* data in */
        .pc_in(decode_pc),
        .rs1_value_in(decode_rs1_value),
        .rs2_value_in(decode_rs2_value),
        .imm_in(decode_imm),

        /* data in (from writeback) */
        .writeback_rd_value_in(mem_rd_value),

        /* control out */
        .mem_read_en_out(execute_mem_read_en),
        .mem_write_en_out(execute_mem_write_en),
        .mem_width_out(execute_mem_width),
        .mem_zero_extend_out(execute_mem_zero_extend),
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
    logic [1:0] execute_mem_width;
    logic execute_mem_zero_extend;
    logic [1:0] execute_branch_op;
    logic [4:0] execute_rd;
    logic execute_rd_writeback;

    /* execute -> mem data */
    logic [31:0] execute_result;
    logic [31:0] execute_rs2_value;
    logic [31:0] execute_branch_pc;

    rv32_mem mem (
        .clk(clk),
        .stall(0),
        .flush(0),

        /* control in */
        .read_en_in(execute_mem_read_en),
        .write_en_in(execute_mem_write_en),
        .width_in(execute_mem_width),
        .zero_extend_in(execute_mem_zero_extend),
        .branch_op_in(execute_branch_op),
        .rd_in(execute_rd),
        .rd_writeback_in(execute_rd_writeback),

        /* data in */
        .result_in(execute_result),
        .rs2_value_in(execute_rs2_value),
        .branch_pc_in(execute_branch_pc),

        /* control out */
        .branch_taken_out(mem_branch_taken),
        .rd_out(mem_rd),
        .rd_writeback_out(mem_rd_writeback),

        /* data out */
        .rd_value_out(mem_rd_value),
        .branch_pc_out(mem_branch_pc)
    );

    /* mem -> writeback control */
    logic [4:0] mem_rd;
    logic mem_rd_writeback;

    /* mem -> fetch control */
    logic mem_branch_taken;

    /* mem -> writeback data */
    logic [31:0] mem_rd_value;

    /* mem -> fetch data */
    logic [31:0] mem_branch_pc;
endmodule

`endif
