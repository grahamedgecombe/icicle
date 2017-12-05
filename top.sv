`include "clk_div.sv"
`include "ram.sv"
`include "rv32.sv"

module top (
    input clk,

    /* serial flash */
    output flash_clk,
    output flash_csn,
    inout flash_io0,
    inout flash_io1,

    /* LEDs */
    output [7:0] leds,

    /* UART */
    input uart_rx,
    output uart_tx
);
    logic flash_io0_en;
    logic flash_io0_in;
    logic flash_io0_out;

    logic flash_io1_en;
    logic flash_io1_in;
    logic flash_io1_out;

    SB_IO #(
        .PIN_TYPE(6'b1010_01),
    ) flash_io [1:0] (
        .PACKAGE_PIN({flash_io1, flash_io0}),
        .OUTPUT_ENABLE({flash_io1_en, flash_io0_en}),
        .D_IN_0({flash_io1_in, flash_io0_in}),
        .D_OUT_0({flash_io1_out, flash_io0_out})
    );

    logic clk_slow;

    clk_div #(
        .LOG_DIVISOR(18)
    ) clk_div (
        .clk_in(clk),
        .clk_out(clk_slow)
    );

    rv32 rv32 (
        .clk(clk_slow),
        .leds(leds),

        /* control out */
        .write_mask_out(mem_write_mask),

        /* data in */
        .read_value_in(mem_read_value),

        /* data out */
        .address_out(mem_address),
        .write_value_out(mem_write_value)
    );

    /* memory bus control */
    logic [3:0] mem_write_mask;

    /* memory bus data */
    logic [31:0] mem_address;
    logic [31:0] mem_read_value;
    logic [31:0] mem_write_value;

    ram ram (
        .clk(clk_slow),

        /* control in */
        .write_mask_in(mem_write_mask),

        /* data in */
        .address_in(mem_address),
        .write_value_in(mem_write_value),

        /* data out */
        .read_value_out(mem_read_value)
    );
endmodule
