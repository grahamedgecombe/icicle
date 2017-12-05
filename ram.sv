`ifndef RAM
`define RAM

module ram (
    input clk,

    /* control in */
    input [3:0] write_mask_in,

    /* data in */
    input [31:0] address_in,
    input [31:0] write_value_in,

    /* data out */
    output [31:0] read_value_out
);
    logic [31:0] mem [2047:0];

    always_ff @(negedge clk) begin
        read_value_out <= mem[address_in[31:2]];

        if (write_mask_in[3])
            mem[address_in[31:2]][31:24] <= write_value_in[31:24];

        if (write_mask_in[2])
            mem[address_in[31:2]][23:16] <= write_value_in[23:16];

        if (write_mask_in[1])
            mem[address_in[31:2]][15:8] <= write_value_in[15:8];

        if (write_mask_in[0])
            mem[address_in[31:2]][7:0] <= write_value_in[7:0];
    end
endmodule

`endif
