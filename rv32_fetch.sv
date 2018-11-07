`ifndef RV32_FETCH
`define RV32_FETCH

`include "rv32_opcodes.sv"

module rv32_fetch (
    input clk,
    input reset,

    /* control in (from hazard) */
    input pcgen_stall_in,
    input stall_in,
    input flush_in,

    /* control in (from mem) */
    input branch_mispredicted_in,

    /* data in (from mem) */
    input [31:0] branch_pc_in,

    /* data in (from memory bus) */
    input [31:0] instr_read_value_in,

    /* control out (to memory bus) */
    output logic instr_read_out,

    /* control out */
    output logic valid_out,
    output logic branch_predicted_taken_out,

    /* data out */
    output logic [31:0] pc_out,
    output logic [31:0] instr_out,

    /* data out (to memory bus) */
    output logic [31:0] instr_address_out
);
    logic [31:0] pc;
    logic [31:0] next_pc;

    logic branch_mispredicted;
    logic [31:0] branch_pc;

    logic sign;
    logic [31:0] imm_j;
    logic [31:0] imm_b;
    logic [6:0] opcode;

    logic branch_predicted_taken;
    logic [31:0] branch_offset;

    assign instr_read_out = 1;
    assign instr_address_out = pc;

    assign sign = instr_read_value_in[31];
    assign imm_j = {{12{sign}}, instr_read_value_in[19:12], instr_read_value_in[20],    instr_read_value_in[30:25], instr_read_value_in[24:21], 1'b0};
    assign imm_b = {{20{sign}}, instr_read_value_in[7],     instr_read_value_in[30:25], instr_read_value_in[11:8],  1'b0};
    assign opcode = instr_read_value_in[6:0];

    always_comb begin
        casez ({opcode, sign})
            {`RV32_OPCODE_JAL, 1'b?}: begin
                branch_predicted_taken = 1;
                branch_offset = imm_j;
            end
            {`RV32_OPCODE_BRANCH, 1'b1}: begin
                branch_predicted_taken = 1;
                branch_offset = imm_b;
            end
            default: begin
                branch_predicted_taken = 0;
                branch_offset = 32'd4;
            end
        endcase

        if (branch_mispredicted)
            next_pc = branch_pc;
        else if (branch_mispredicted_in)
            next_pc = branch_pc_in;
        else
            next_pc = pc + branch_offset;
    end

    initial
        instr_out <= `RV32_INSTR_NOP;

    always_ff @(posedge clk) begin
        if (pcgen_stall_in) begin
            if (!branch_mispredicted && branch_mispredicted_in) begin
                branch_mispredicted <= 1;
                branch_pc <= branch_pc_in;
            end
        end else begin
            branch_mispredicted <= 0;
            pc <= next_pc;
        end

        if (!stall_in) begin
            valid_out <= 1;
            branch_predicted_taken_out <= branch_predicted_taken;
            instr_out <= instr_read_value_in;
            pc_out <= pc;

            if (flush_in || branch_mispredicted) begin
                valid_out <= 0;
                branch_predicted_taken_out <= 0;
                instr_out <= `RV32_INSTR_NOP;
                pc_out <= 0;
            end
        end

        if (reset) begin
            branch_mispredicted <= 0;
            valid_out <= 0;
            branch_predicted_taken_out <= 0;
            instr_out <= `RV32_INSTR_NOP;
            pc <= 0;
            pc_out <= 0;
        end
    end
endmodule

`endif
