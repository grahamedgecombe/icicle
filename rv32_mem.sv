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
    input read_in,
    input write_in,
    input [1:0] width_in,
    input zero_extend_in,
    input [1:0] branch_op_in,
    input [4:0] rd_in,
    input rd_write_in,

    /* data in */
    input [31:0] result_in,
    input [31:0] rs2_value_in,
    input [31:0] branch_pc_in,

    /* data in (from memory bus) */
    input [31:0] read_value_in,

    /* control out */
    output logic branch_taken_out,
    output logic [4:0] rd_out,
    output logic rd_write_out,

    /* control out (to memory bus) */
    output logic read_out,
    output logic [3:0] write_mask_out,

    /* data out */
    output logic [31:0] rd_value_out,
    output logic [31:0] branch_pc_out,

    /* data out (to memory bus) */
    output logic [31:0] address_out,
    output logic [31:0] write_value_out
);
    rv32_branch branch (
        /* control in */
        .op_in(branch_op_in),

        /* data in */
        .result_in(result_in),

        /* control out */
        .taken_out(branch_taken_out)
    );

    assign branch_pc_out = branch_pc_in;

    assign read_out = read_in;
    assign address_out = result_in;

    always_comb begin
        if (write_in) begin
            case (width_in)
                `RV32_MEM_WIDTH_WORD: begin
                    write_value_out = rs2_value_in;
                    write_mask_out = 4'b1111;
                end
                `RV32_MEM_WIDTH_HALF: begin
                    case (result_in[0])
                        2'b0: begin
                            write_value_out = {rs2_value_in[15:0], 16'bx};
                            write_mask_out = 4'b1100;
                        end
                        2'b1: begin
                            write_value_out = {16'bx, rs2_value_in[15:0]};
                            write_mask_out = 4'b0011;
                        end
                    endcase
                end
                `RV32_MEM_WIDTH_BYTE: begin
                    case (result_in[1:0])
                        2'b00: begin
                            write_value_out = {rs2_value_in[7:0], 24'bx};
                            write_mask_out = 4'b1000;
                        end
                        2'b01: begin
                            write_value_out = {8'bx, rs2_value_in[7:0], 16'bx};
                            write_mask_out = 4'b0100;
                        end
                        2'b10: begin
                            write_value_out = {16'bx, rs2_value_in[7:0], 8'bx};
                            write_mask_out = 4'b0010;
                        end
                        2'b11: begin
                            write_value_out = {24'bx, rs2_value_in[7:0]};
                            write_mask_out = 4'b0001;
                        end
                    endcase
                end
                default: begin
                    write_value_out = 32'bx;
                    write_mask_out = 4'bx;
                end
            endcase
        end else begin
            write_value_out = 32'bx;
            write_mask_out = 4'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (!stall_in) begin
            rd_out <= rd_in;
            rd_write_out <= rd_write_in;

            if (read_in) begin
                case (width_in)
                    `RV32_MEM_WIDTH_WORD: begin
                        rd_value_out <= read_value_in;
                    end
                    `RV32_MEM_WIDTH_HALF: begin
                        case (result_in[0])
                            1'b0: rd_value_out <= {{16{zero_extend_in ? 1'b0 : read_value_in[31]}}, read_value_in[31:16]};
                            1'b1: rd_value_out <= {{16{zero_extend_in ? 1'b0 : read_value_in[15]}}, read_value_in[15:0]};
                        endcase
                    end
                    `RV32_MEM_WIDTH_BYTE: begin
                        case (result_in[1:0])
                            2'b00: rd_value_out <= {{24{zero_extend_in ? 1'b0 : read_value_in[31]}}, read_value_in[31:24]};
                            2'b01: rd_value_out <= {{24{zero_extend_in ? 1'b0 : read_value_in[23]}}, read_value_in[23:16]};
                            2'b10: rd_value_out <= {{24{zero_extend_in ? 1'b0 : read_value_in[15]}}, read_value_in[15:8]};
                            2'b11: rd_value_out <= {{24{zero_extend_in ? 1'b0 : read_value_in[7]}},  read_value_in[7:0]};
                        endcase
                    end
                    default: begin
                        rd_value_out <= 32'bx;
                    end
                endcase
            end else begin
                rd_value_out <= result_in;
            end

            if (flush_in)
                rd_write_out <= 0;
        end
    end
endmodule

`endif
