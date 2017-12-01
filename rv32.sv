`ifndef RV32
`define RV32

`include "rv32_decode.sv"
`include "rv32_execute.sv"
`include "rv32_fetch.sv"

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

        /* data in */
        .pc_in(decode_pc),
        .rs1_value_in(decode_rs1_value),
        .rs2_value_in(decode_rs2_value),
        .imm_in(decode_imm),

        /* data out */
        .result_out(execute_result)
    );

    /* execute -> mem data */
    logic [31:0] execute_result;
endmodule

`endif
