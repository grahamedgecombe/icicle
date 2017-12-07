`ifndef UART
`define UART

localparam UART_REG_CLK_DIV = 2'b00;
localparam UART_REG_STATUS  = 2'b01;
localparam UART_REG_DATA    = 2'b10;

module uart (
    input clk,
    input reset,

    /* serial port */
    input rx_in,
    output tx_out,

    /* control in */
    input sel_in,
    input read_in,
    input [3:0] write_mask_in,

    /* data in */
    input [31:0] address_in,
    input [31:0] write_value_in,

    /* data out */
    output [31:0] read_value_out
);
    logic [15:0] clk_div;

    logic [15:0] tx_clks;
    logic [3:0] tx_bits;
    logic [9:0] tx_buf;

    initial
        tx_buf[0] = 1;

    assign tx_out = tx_buf[0];

    always_comb begin
        if (sel_in) begin
            case (address_in[3:2])
                UART_REG_CLK_DIV: begin
                    read_value_out = {16'b0, clk_div};
                end
                UART_REG_STATUS: begin
                    read_value_out = {31'b0, ~|tx_bits};
                end
                UART_REG_DATA: begin
                    read_value_out = 0;
                end
                default: begin
                    read_value_out = 32'bx;
                end
            endcase
        end else begin
            read_value_out = 0;
        end
    end

    always_ff @(posedge clk) begin
        if (sel_in) begin
            case (address_in[3:2])
                UART_REG_CLK_DIV: begin
                    if (write_mask_in[1])
                        clk_div[15:8] <= write_value_in[15:8];

                    if (write_mask_in[0])
                        clk_div[7:0] <= write_value_in[7:0];
                end
                UART_REG_DATA: begin
                    if (write_mask_in[0] && !tx_bits) begin
                        tx_clks <= clk_div;
                        tx_bits <= 10;
                        tx_buf <= {1'b1, write_value_in[7:0], 1'b0};
                    end
                end
            endcase
        end

        if (tx_bits) begin
            if (tx_clks) begin
                tx_clks <= tx_clks - 1;
            end else begin
                tx_clks <= clk_div;
                tx_bits <= tx_bits - 1;
                tx_buf <= {1'b1, tx_buf[9:1]};
            end
        end

        if (reset) begin
            tx_bits <= 0;
            tx_buf[0] <= 1;
        end
    end
endmodule

`endif
