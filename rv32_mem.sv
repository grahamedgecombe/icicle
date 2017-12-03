`ifndef RV32_MEM
`define RV32_MEM

`include "rv32_branch.sv"
`include "rv32_mem_ops.sv"

module rv32_mem (
    input clk,
    input stall,
    input flush,

    /* control in */
    input read_en_in,
    input write_en_in,
    input [1:0] width_in,
    input zero_extend_in,
    input [1:0] branch_op_in,
    input [4:0] rd_in,
    input rd_writeback_in,

    /* data in */
    input [31:0] result_in,
    input [31:0] rs2_value_in,
    input [31:0] branch_pc_in,

    /* control out */
    output branch_taken_out,
    output [4:0] rd_out,
    output rd_writeback_out,

    /* data out */
    output [31:0] rd_value_out,
    output [31:0] branch_pc_out
);
    logic [31:0] data_mem [255:0];

    rv32_branch branch (
        /* control in */
        .op_in(branch_op_in),

        /* data in */
        .result_in(result_in),

        /* control out */
        .taken_out(branch_taken_out)
    );

    assign branch_pc_out = branch_pc_in;

    logic [31:0] read_value;
    logic [31:0] write_value;
    logic [3:0] write_mask;

    always_comb begin
        case (width_in)
            RV32_MEM_WIDTH_WORD: begin
                write_value = rs2_value_in;
                write_mask = 4'b1111;
            end
            RV32_MEM_WIDTH_HALF: begin
                case (result_in[0])
                    2'b0: begin
                        write_value = {rs2_value_in[15:0], 16'bx};
                        write_mask = 4'b1100;
                    end
                    2'b1: begin
                        write_value = {16'bx, rs2_value_in[15:0]};
                        write_mask = 4'b0011;
                    end
                endcase
            end
            RV32_MEM_WIDTH_BYTE: begin
                case (result_in[1:0])
                    2'b00: begin
                        write_value = {rs2_value_in[7:0], 24'bx};
                        write_mask = 4'b1000;
                    end
                    2'b01: begin
                        write_value = {8'bx, rs2_value_in[7:0], 16'bx};
                        write_mask = 4'b0100;
                    end
                    2'b10: begin
                        write_value = {16'bx, rs2_value_in[7:0], 8'bx};
                        write_mask = 4'b0010;
                    end
                    2'b11: begin
                        write_value = {24'bx, rs2_value_in[7:0]};
                        write_mask = 4'b0001;
                    end
                endcase
            end
            default: begin
                write_value = 32'bx;
                write_mask = 4'bx;
            end
        endcase
    end

    always_ff @(negedge clk) begin
        read_value <= data_mem[result_in[31:2]];

        if (write_en_in) begin
            if (write_mask[3])
                data_mem[result_in[31:2]][31:24] <= write_value[31:24];
            if (write_mask[2])
                data_mem[result_in[31:2]][23:16] <= write_value[23:16];
            if (write_mask[1])
                data_mem[result_in[31:2]][15:8] <= write_value[15:8];
            if (write_mask[0])
                data_mem[result_in[31:2]][7:0] <= write_value[7:0];
        end
    end

    always_ff @(posedge clk) begin
        if (!stall) begin
            rd_out <= rd_in;
            rd_writeback_out <= rd_writeback_in;

            if (read_en_in) begin
                case (width_in)
                    RV32_MEM_WIDTH_WORD: begin
                        rd_value_out <= read_value;
                    end
                    RV32_MEM_WIDTH_HALF: begin
                        case (result_in[0])
                            1'b0: rd_value_out <= {{16{zero_extend_in ? 1'b0 : read_value[31]}}, read_value[31:16]};
                            1'b1: rd_value_out <= {{16{zero_extend_in ? 1'b0 : read_value[15]}}, read_value[15:0]};
                        endcase
                    end
                    RV32_MEM_WIDTH_BYTE: begin
                        case (result_in[1:0])
                            2'b00: rd_value_out <= {{24{zero_extend_in ? 1'b0 : read_value[31]}}, read_value[31:24]};
                            2'b01: rd_value_out <= {{24{zero_extend_in ? 1'b0 : read_value[23]}}, read_value[23:16]};
                            2'b10: rd_value_out <= {{24{zero_extend_in ? 1'b0 : read_value[15]}}, read_value[15:8]};
                            2'b11: rd_value_out <= {{24{zero_extend_in ? 1'b0 : read_value[7]}},  read_value[7:0]};
                        endcase
                    end
                    default: begin
                        rd_value_out <= 32'bx;
                    end
                endcase
            end else begin
                rd_value_out <= result_in;
            end

            if (flush)
                rd_writeback_out <= 0;
        end
    end
endmodule

`endif
