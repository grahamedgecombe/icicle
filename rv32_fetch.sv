`ifndef RV32_FETCH
`define RV32_FETCH

`include "rv32_opcodes.sv"

module rv32_fetch (
    input clk,

    /* control in (from hazard) */
    input stall_in,

    /* control in (from mem) */
    input branch_mispredicted_in,

    /* data in (from mem) */
    input [31:0] branch_pc_in,

    /* data in (from memory bus) */
    input [31:0] instr_read_value_in,

    /* control out (to memory bus) */
    output logic instr_read_out,

    /* control out */
    output logic branch_predicted_taken_out,

    /* data out */
    output logic [31:0] pc_out,
    output logic [31:0] instr_out,

    /* data out (to memory bus) */
    output logic [31:0] instr_address_out
);
    logic [31:0] next_pc;
    logic [31:0] pc;

    logic sign;
    logic [31:0] imm_j;
    logic [31:0] imm_b;
    logic [6:0] opcode;

    logic branch_predicted_taken;
    logic [31:0] branch_offset;

    assign pc = branch_mispredicted_in ? branch_pc_in : next_pc;
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
    end

    always_ff @(posedge clk) begin
        if (stall_in) begin
            next_pc <= pc;
        end else begin
            branch_predicted_taken_out <= branch_predicted_taken;
            instr_out <= instr_read_value_in;
            next_pc <= pc + branch_offset;
            pc_out <= pc;
        end
    end
endmodule

`endif
