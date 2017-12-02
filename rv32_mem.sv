`ifndef RV32_MEM
`define RV32_MEM

module rv32_mem (
    input clk,

    /* control in */
    input read_en_in,
    input write_en_in,

    /* data in */
    input [31:0] result_in,
    input [31:0] rs2_value_in,

    /* data out */
    output [31:0] result_out,
    output [31:0] read_value_out
);
    logic [31:0] data_mem [255:0];

    always @(posedge clk) begin
        result_out <= result_in;

        if (read_en_in)
            read_value_out <= data_mem[result_in[31:2]];

        if (write_en_in)
            data_mem[result_in[31:2]] <= rs2_value_in;
    end
endmodule

`endif
