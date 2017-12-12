`include "clk_div.sv"
`include "pll.sv"
`include "ram.sv"
`include "rv32.sv"
`include "sync.sv"
`include "uart.sv"

module top (
    input clk,

    /* serial flash */
    output logic flash_clk,
    output logic flash_csn,
    inout flash_io0,
    inout flash_io1,

    /* LEDs */
    output logic [7:0] leds,

    /* UART */
    input uart_rx,
    output logic uart_tx
);
    logic flash_io0_en;
    logic flash_io0_in;
    logic flash_io0_out;

    logic flash_io1_en;
    logic flash_io1_in;
    logic flash_io1_out;

    SB_IO #(
        .PIN_TYPE(6'b1010_01)
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
    logic reset;

    assign reset = ~pll_locked;

    sync sync (
        .clk(pll_clk),
        .in(pll_locked_async),
        .out(pll_locked)
    );

    /* memory bus */
    logic [31:0] mem_address;
    logic mem_read;
    logic [31:0] mem_read_value;
    logic [3:0] mem_write_mask;
    logic [31:0] mem_write_value;

    assign mem_read_value = ram_read_value | leds_read_value | uart_read_value;

    rv32 rv32 (
        .clk(pll_clk),

        /* memory bus */
        .address_out(mem_address),
        .read_out(mem_read),
        .read_value_in(mem_read_value),
        .write_mask_out(mem_write_mask),
        .write_value_out(mem_write_value)
    );

    always_comb begin
        ram_sel = 0;
        leds_sel = 0;
        uart_sel = 0;

        casez (mem_address)
            32'b00000000_00000000_????????_????????: ram_sel = 1;
            32'b00000000_00000001_00000000_000000??: leds_sel = 1;
            32'b00000000_00000010_00000000_0000????: uart_sel = 1;
        endcase
    end

    logic ram_sel;
    logic [31:0] ram_read_value;

    ram ram (
        .clk(pll_clk),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(ram_sel),
        .read_value_out(ram_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value)
    );

    logic leds_sel;
    logic [31:0] leds_read_value;

    assign leds_read_value = {24'b0, leds_sel ? leds : 8'b0};

    always_ff @(posedge pll_clk) begin
        if (leds_sel && mem_write_mask[0])
            leds <= mem_write_value[7:0];
    end

    logic uart_sel;
    logic [31:0] uart_read_value;

    uart uart (
        .clk(pll_clk),
        .reset(reset),

        /* serial port */
        .rx_in(uart_rx),
        .tx_out(uart_tx),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(uart_sel),
        .read_in(mem_read),
        .read_value_out(uart_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value)
    );
endmodule
