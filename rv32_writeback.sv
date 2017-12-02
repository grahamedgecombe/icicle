`ifndef RV32_WRITEBACK
`define RV32_WRITEBACK

module rv32_writeback (
    input clk,

    /* control in */
    input mem_read_en_in,
    input [4:0] rd_in,
    input rd_writeback_in,

    /* data in */
    input [31:0] result_in,
    input [31:0] mem_read_value_in,

    /* control out */
    output [4:0] rd_out,
    output rd_writeback_out,

    /* data out */
    output [31:0] rd_value_out
);
    assign rd_out = rd_in;
    assign rd_writeback_out = rd_writeback_in;
    assign rd_value_out = mem_read_en_in ? mem_read_value_in : result_in;
endmodule

`endif
