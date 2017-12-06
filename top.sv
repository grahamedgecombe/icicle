`include "clk_div.sv"
`include "pll.sv"
`include "ram.sv"
`include "rv32.sv"
`include "sync.sv"
`include "uart.sv"

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

    logic pll_clk;
    logic pll_locked_async;

    pll pll (
        .clock_in(clk),
        .clock_out(pll_clk),
        .locked(pll_locked_async)
    );

    logic pll_locked;
    logic reset = ~pll_locked;

    sync sync (
        .clk(pll_clk),
        .in(pll_locked_async),
        .out(pll_locked)
    );

    rv32 rv32 (
        .clk(pll_clk),

        /* control out */
        .read_out(mem_read),
        .write_mask_out(mem_write_mask),

        /* data in */
        .read_value_in(mem_read_value),

        /* data out */
        .address_out(mem_address),
        .write_value_out(mem_write_value)
    );

    /* memory bus control */
    logic mem_read;
    logic [3:0] mem_write_mask;

    /* memory bus data */
    logic [31:0] mem_address;
    logic [31:0] mem_read_value = ram_read_value | leds_read_value;
    logic [31:0] mem_write_value;

    always_comb begin
        ram_sel = 0;
        leds_sel = 0;

        casez (mem_address)
            32'b00000000_00000000_????????_????????: ram_sel = 1;
            32'b00000000_00000001_00000000_000000??: leds_sel = 1;
        endcase
    end

    logic ram_sel;
    logic [31:0] ram_read_value;

    ram ram (
        .clk(pll_clk),

        /* control in */
        .sel_in(ram_sel),
        .write_mask_in(mem_write_mask),

        /* data in */
        .address_in(mem_address),
        .write_value_in(mem_write_value),

        /* data out */
        .read_value_out(ram_read_value)
    );

    logic leds_sel;
    logic [31:0] leds_read_value = {24'b0, leds_sel ? leds : 8'b0};

    always_ff @(posedge pll_clk) begin
        if (leds_sel && mem_write_mask[0])
            leds <= mem_write_value[7:0];
    end

    logic uart_rx_received;
    logic uart_tx_ready;
    logic [7:0] uart_rx_byte;

    uart uart (
        .clk(pll_clk),
        .reset(reset),

        /* serial port */
        .rx_in(uart_rx),
        .tx_out(uart_tx),

        /* control in */
        .tx_transmit_in(uart_rx_received),

        /* data in */
        .tx_byte_in(uart_rx_byte),

        /* control out */
        .rx_received_out(uart_rx_received),
        .tx_ready_out(uart_tx_ready),

        /* data out */
        .rx_byte_out(uart_rx_byte)
    );
endmodule
