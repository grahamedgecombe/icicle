`ifndef RV32
`define RV32

`include "rv32_decode.sv"
`include "rv32_execute.sv"
`include "rv32_fetch.sv"
`include "rv32_mem.sv"

module rv32 (
    input clk
);
    rv32_fetch fetch (
        .clk(clk),
        
        /* data out */
        .pc_out(fetch_pc),
        .instr_out(fetch_instr)
    );

    /* fetch -> decode data */
    logic [31:0] fetch_pc;
    logic [31:0] fetch_instr;

    rv32_decode decode (
        .clk(clk),

        /* data in */
        .pc_in(fetch_pc),
        .instr_in(fetch_instr),

        /* control out */
        .alu_op_out(decode_alu_op),
        .alu_sub_sra_out(decode_alu_sub_sra),
        .alu_src1_out(decode_alu_src1),
        .alu_src2_out(decode_alu_src2),
        .mem_read_en_out(decode_mem_read_en),
        .mem_write_en_out(decode_mem_write_en),

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

        /* data in */
        .pc_in(decode_pc),
        .rs1_value_in(decode_rs1_value),
        .rs2_value_in(decode_rs2_value),
        .imm_in(decode_imm),

        /* control out */
        .mem_read_en_out(execute_mem_read_en),
        .mem_write_en_out(execute_mem_write_en),

        /* data out */
        .result_out(execute_result),
        .rs2_value_out(execute_rs2_value)
    );

    /* execute -> mem control */
    logic execute_mem_read_en;
    logic execute_mem_write_en;

    /* execute -> mem data */
    logic [31:0] execute_result;
    logic [31:0] execute_rs2_value;

    rv32_mem mem (
        .clk(clk),

        /* control in */
        .read_en_in(execute_mem_read_en),
        .write_en_in(execute_mem_write_en),

        /* data in */
        .result_in(execute_result),
        .rs2_value_in(execute_rs2_value)
    );
endmodule

`endif
