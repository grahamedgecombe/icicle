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

    rv32 rv32 (
        .clk(clk)
    );
endmodule
