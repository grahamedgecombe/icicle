`ifndef RV32_MEM
`define RV32_MEM

`include "rv32_branch.sv"

`define RV32_MEM_WIDTH_WORD 2'b00
`define RV32_MEM_WIDTH_HALF 2'b01
`define RV32_MEM_WIDTH_BYTE 2'b10

module rv32_mem (
    input clk,

    /* control in (from hazard) */
    input stall_in,
    input flush_in,

    /* control in */
    input valid_in,
    input read_in,
    input write_in,
    input [1:0] width_in,
    input zero_extend_in,
    input csr_read_in,
    input csr_write_in,
    input [1:0] csr_write_op_in,
    input [1:0] branch_op_in,
    input [4:0] rd_in,
    input rd_write_in,

    /* data in */
    input [31:0] result_in,
    input [31:0] rs2_value_in,
    input [11:0] csr_in,
    input [31:0] branch_pc_in,

    /* data in (from data memory bus) */
    input [31:0] data_read_value_in,

    /* control out */
    output logic valid_out,
    output logic branch_taken_out,
    output logic [4:0] rd_out,
    output logic rd_write_out,

    /* control out (to data memory bus) */
    output logic data_read_out,
    output logic data_write_out,
    output logic [3:0] data_write_mask_out,

    /* data out */
    output logic [31:0] rd_value_out,
    output logic [31:0] branch_pc_out,

    /* data out (to data memory bus) */
    output logic [31:0] data_address_out,
    output logic [31:0] data_write_value_out
);
    /* branch unit */
    rv32_branch_unit branch_unit (
        /* control in */
        .op_in(branch_op_in),

        /* data in */
        .result_in(result_in),

        /* control out */
        .taken_out(branch_taken_out)
    );

    assign branch_pc_out = branch_pc_in;

    /* csr file */
    logic [31:0] csr_read_value;

    rv32_csrs csrs (
        .clk(clk),

        /* control in */
        .read_in(csr_read_in),
        .write_in(csr_write_in),
        .write_op_in(csr_write_op_in),

        /* control in (from writeback) */
        .instr_retired_in(valid_out),

        /* data in */
        .result_in(result_in),
        .csr_in(csr_in),

        /* data out */
        .read_value_out(csr_read_value)
    );

    logic [31:0] mem_read_value;

    /* memory access unit */
    assign data_read_out = read_in;
    assign data_write_out = write_in;
    assign data_address_out = result_in;

    always_comb begin
        /* write port */
        if (write_in) begin
            case (width_in)
                `RV32_MEM_WIDTH_WORD: begin
                    data_write_value_out = rs2_value_in;
                    data_write_mask_out = 4'b1111;
                end
                `RV32_MEM_WIDTH_HALF: begin
                    case (result_in[0])
                        2'b0: begin
                            data_write_value_out = {16'bx, rs2_value_in[15:0]};
                            data_write_mask_out = 4'b0011;
                        end
                        2'b1: begin
                            data_write_value_out = {rs2_value_in[15:0], 16'bx};
                            data_write_mask_out = 4'b1100;
                        end
                    endcase
                end
                `RV32_MEM_WIDTH_BYTE: begin
                    case (result_in[1:0])
                        2'b00: begin
                            data_write_value_out = {24'bx, rs2_value_in[7:0]};
                            data_write_mask_out = 4'b0001;
                        end
                        2'b01: begin
                            data_write_value_out = {16'bx, rs2_value_in[7:0], 8'bx};
                            data_write_mask_out = 4'b0010;
                        end
                        2'b10: begin
                            data_write_value_out = {8'bx, rs2_value_in[7:0], 16'bx};
                            data_write_mask_out = 4'b0100;
                        end
                        2'b11: begin
                            data_write_value_out = {rs2_value_in[7:0], 24'bx};
                            data_write_mask_out = 4'b1000;
                        end
                    endcase
                end
                default: begin
                    data_write_value_out = 32'bx;
                    data_write_mask_out = 4'bx;
                end
            endcase
        end else begin
            data_write_value_out = 32'bx;
            data_write_mask_out = 4'b0;
        end

        /* read port */
        if (read_in) begin
            case (width_in)
                `RV32_MEM_WIDTH_WORD: begin
                    mem_read_value = data_read_value_in;
                end
                `RV32_MEM_WIDTH_HALF: begin
                    case (result_in[0])
                        1'b0: mem_read_value = {{16{zero_extend_in ? 1'b0 : data_read_value_in[15]}}, data_read_value_in[15:0]};
                        1'b1: mem_read_value = {{16{zero_extend_in ? 1'b0 : data_read_value_in[31]}}, data_read_value_in[31:16]};
                    endcase
                end
                `RV32_MEM_WIDTH_BYTE: begin
                    case (result_in[1:0])
                        2'b00: mem_read_value = {{24{zero_extend_in ? 1'b0 : data_read_value_in[7]}},  data_read_value_in[7:0]};
                        2'b01: mem_read_value = {{24{zero_extend_in ? 1'b0 : data_read_value_in[15]}}, data_read_value_in[15:8]};
                        2'b10: mem_read_value = {{24{zero_extend_in ? 1'b0 : data_read_value_in[23]}}, data_read_value_in[23:16]};
                        2'b11: mem_read_value = {{24{zero_extend_in ? 1'b0 : data_read_value_in[31]}}, data_read_value_in[31:24]};
                    endcase
                end
                default: begin
                    mem_read_value = 32'bx;
                end
            endcase
        end else begin
            mem_read_value = 32'bx;
        end
    end

    always_ff @(posedge clk) begin
        if (!stall_in) begin
            valid_out <= valid_in;
            rd_out <= rd_in;
            rd_write_out <= rd_write_in;

            if (csr_read_in)
                rd_value_out <= csr_read_value;
            else if (read_in)
                rd_value_out <= mem_read_value;
            else
                rd_value_out <= result_in;

            if (flush_in) begin
                valid_out <= 0;
                rd_write_out <= 0;
            end
        end
    end
endmodule

`endif
