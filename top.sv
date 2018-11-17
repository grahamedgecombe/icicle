`include "defines.sv"
`include "bus_arbiter.sv"
`include "flash.sv"
`include "pll.sv"
`include "ram.sv"
`include "rv32.sv"
`include "sync.sv"
`include "timer.sv"
`include "uart.sv"

`ifdef SPI_FLASH
`define RESET_VECTOR 32'h01100000
`else
`define RESET_VECTOR 32'h00000000
`endif

module top (
`ifndef INTERNAL_OSC
    input clk,
`endif

`ifdef SPI_FLASH
    /* serial flash */
    output logic flash_clk,
    output logic flash_csn,
    inout flash_io0,
    inout flash_io1,
`endif

    /* LEDs */
    output logic [7:0] leds,

    /* UART */
    input uart_rx,
    output logic uart_tx
);

`ifdef SPI_FLASH
    logic flash_io0_en;
    logic flash_io0_in;
    logic flash_io0_out;

    logic flash_io1_en;
    logic flash_io1_in;
    logic flash_io1_out;
`endif

`ifdef INTERNAL_OSC
    logic clk;
    SB_HFOSC inthosc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );
`endif

`ifdef SPI_FLASH
    SB_IO #(
        .PIN_TYPE(6'b1010_01)
    ) flash_io [1:0] (
        .PACKAGE_PIN({flash_io1, flash_io0}),
        .OUTPUT_ENABLE({flash_io1_en, flash_io0_en}),
        .D_IN_0({flash_io1_in, flash_io0_in}),
        .D_OUT_0({flash_io1_out, flash_io0_out})
    );
`endif

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

    /* instruction memory bus */
    logic [31:0] instr_address;
    logic instr_read;
    logic [31:0] instr_read_value;
    logic instr_ready;
    logic instr_fault;

    /* data memory bus */
    logic [31:0] data_address;
    logic data_read;
    logic data_write;
    logic [31:0] data_read_value;
    logic [3:0] data_write_mask;
    logic [31:0] data_write_value;
    logic data_ready;
    logic data_fault;

    /* memory bus */
    logic [31:0] mem_address;
    logic mem_read;
    logic mem_write;
    logic [31:0] mem_read_value;
    logic [3:0] mem_write_mask;
    logic [31:0] mem_write_value;
    logic mem_ready;
    logic mem_fault;

    assign mem_read_value = ram_read_value | leds_read_value | uart_read_value | timer_read_value | flash_read_value;
    assign mem_ready = ram_ready | leds_ready | uart_ready | timer_ready | flash_ready | mem_fault;

    bus_arbiter bus_arbiter (
        .clk(pll_clk),
        .reset(reset),

        /* instruction memory bus */
        .instr_address_in(instr_address),
        .instr_read_in(instr_read),
        .instr_read_value_out(instr_read_value),
        .instr_ready_out(instr_ready),
        .instr_fault_out(instr_fault),

        /* data memory bus */
        .data_address_in(data_address),
        .data_read_in(data_read),
        .data_write_in(data_write),
        .data_read_value_out(data_read_value),
        .data_write_mask_in(data_write_mask),
        .data_write_value_in(data_write_value),
        .data_ready_out(data_ready),
        .data_fault_out(data_fault),

        /* common memory bus */
        .address_out(mem_address),
        .read_out(mem_read),
        .write_out(mem_write),
        .read_value_in(mem_read_value),
        .write_mask_out(mem_write_mask),
        .write_value_out(mem_write_value),
        .ready_in(mem_ready),
        .fault_in(mem_fault)
    );

    logic [63:0] cycle;

    rv32 #(
        .RESET_VECTOR(`RESET_VECTOR)
    ) rv32 (
        .clk(pll_clk),
        .reset(reset),

        /* instruction memory bus */
        .instr_address_out(instr_address),
        .instr_read_out(instr_read),
        .instr_read_value_in(instr_read_value),
        .instr_ready_in(instr_ready),
        .instr_fault_in(instr_fault),

        /* data memory bus */
        .data_address_out(data_address),
        .data_read_out(data_read),
        .data_write_out(data_write),
        .data_read_value_in(data_read_value),
        .data_write_mask_out(data_write_mask),
        .data_write_value_out(data_write_value),
        .data_ready_in(data_ready),
        .data_fault_in(data_fault),

        /* timer */
        .cycle_out(cycle)
    );

    logic ram_sel;
    logic leds_sel;
    logic uart_sel;
    logic timer_sel;
    logic flash_sel;

    always_comb begin
        ram_sel = 0;
        leds_sel = 0;
        uart_sel = 0;
        timer_sel = 0;
        flash_sel = 0;
        mem_fault = 0;

        casez (mem_address)
            32'b00000000_00000000_????????_????????: ram_sel = 1;
            32'b00000000_00000001_00000000_000000??: leds_sel = 1;
            32'b00000000_00000010_00000000_0000????: uart_sel = 1;
            32'b00000000_00000011_00000000_0000????: timer_sel = 1;
            32'b00000001_????????_????????_????????: flash_sel = 1;
            default:                                 mem_fault = 1;
        endcase
    end

    logic [31:0] ram_read_value;
    logic ram_ready;

    ram ram (
        .clk(pll_clk),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(ram_sel),
        .read_value_out(ram_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(ram_ready)
    );

    logic [31:0] leds_read_value;
    logic leds_ready;

    assign leds_read_value = {24'b0, leds_sel ? leds : 8'b0};
    assign leds_ready = leds_sel;

    always_ff @(posedge pll_clk) begin
        if (leds_sel && mem_write_mask[0])
            leds <= mem_write_value[7:0];
    end

    logic [31:0] uart_read_value;
    logic uart_ready;

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
        .write_value_in(mem_write_value),
        .ready_out(uart_ready)
    );

    logic [31:0] timer_read_value;
    logic timer_ready;

    timer timer (
        .clk(pll_clk),
        .reset(reset),

        /* cycle count (from the CPU core) */
        .cycle_in(cycle),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(timer_sel),
        .read_in(mem_read),
        .read_value_out(timer_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(timer_ready)
    );

    logic [31:0] flash_read_value;
    logic flash_ready;

`ifdef SPI_FLASH
    flash flash (
        .clk(pll_clk),
        .reset(reset),

        /* SPI bus */
        .clk_out(flash_clk),
        .csn_out(flash_csn),
        .io0_in(flash_io0_in),
        .io1_in(flash_io1_in),
        .io0_en(flash_io0_en),
        .io1_en(flash_io1_en),
        .io0_out(flash_io0_out),
        .io1_out(flash_io1_out),

        /* memory bus */
        .address_in(mem_address),
        .sel_in(flash_sel),
        .read_in(mem_read),
        .read_value_out(flash_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value),
        .ready_out(flash_ready)
    );
`else
    assign flash_read_value = 0;
    assign flash_ready = 1;
`endif
endmodule
