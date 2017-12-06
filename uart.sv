`ifndef UART
`define UART

localparam UART_STATE_IDLE  = 2'b00;
localparam UART_STATE_START = 2'b01;
localparam UART_STATE_DATA  = 2'b10;
localparam UART_STATE_STOP  = 2'b11;

module uart #(
    parameter CLK_FREQ = 36000000,
    parameter BAUD_RATE = 9600
) (
    input clk,
    input reset,

    /* serial port */
    input rx_in,
    output tx_out,

    /* control in */
    input tx_transmit_in,

    /* data in */
    input [7:0] tx_byte_in,

    /* control out */
    output rx_received_out,
    output tx_ready_out,

    /* data out */
    output [7:0] rx_byte_out
);
    localparam CLK_DIV = CLK_FREQ / BAUD_RATE;

    logic [11:0] rx_clk_div;
    logic [11:0] tx_clk_div;

    logic [1:0] rx_state;
    logic [1:0] tx_state;

    logic [2:0] rx_bit;
    logic [2:0] tx_bit;

    logic [7:0] rx_pending_byte;
    logic [7:0] tx_byte;

    initial begin
        rx_state <= UART_STATE_IDLE;
        tx_state <= UART_STATE_IDLE;
        rx_received_out <= 0;
        tx_out <= 1;
        tx_ready_out <= 1;
    end

    always @(posedge clk) begin
        rx_received_out <= 0;

        if (rx_clk_div)
            rx_clk_div <= rx_clk_div - 1;

        if (tx_clk_div)
            tx_clk_div <= tx_clk_div - 1;

        case (rx_state)
            UART_STATE_IDLE: begin
                if (!rx_in) begin
                    rx_state <= UART_STATE_START;
                    rx_clk_div <= CLK_DIV / 2;
                end
            end
            UART_STATE_START: begin
                if (!rx_clk_div) begin
                    if (!rx_in) begin
                        rx_state <= UART_STATE_DATA;
                        rx_clk_div <= CLK_DIV;
                        rx_bit <= 7;
                    end else begin
                        rx_state <= UART_STATE_IDLE;
                    end
                end
            end
            UART_STATE_DATA: begin
                if (!rx_clk_div) begin
                    rx_state <= rx_bit ? UART_STATE_DATA : UART_STATE_STOP;
                    rx_clk_div <= CLK_DIV;
                    rx_bit <= rx_bit - 1;
                    rx_pending_byte <= {rx_in, rx_pending_byte[7:1]};
                end
            end
            UART_STATE_STOP: begin
                if (!rx_clk_div) begin
                    rx_state <= UART_STATE_IDLE;
                    if (rx_in) begin
                        rx_received_out <= 1;
                        rx_byte_out <= rx_pending_byte;
                    end
                end
            end
        endcase

        case (tx_state)
            UART_STATE_IDLE: begin
                if (tx_transmit_in) begin
                    tx_state <= UART_STATE_START;
                    tx_clk_div <= CLK_DIV;
                    tx_byte <= tx_byte_in;
                    tx_out <= 0;
                    tx_ready_out <= 0;
                end
            end
            UART_STATE_START: begin
                if (!tx_clk_div) begin
                    tx_state <= UART_STATE_DATA;
                    tx_clk_div <= CLK_DIV;
                    tx_bit <= 7;
                    tx_byte <= {1'b0, tx_byte[7:1]};
                    tx_out <= tx_byte[0];
                end
            end
            UART_STATE_DATA: begin
                if (!tx_clk_div) begin
                    tx_state <= tx_bit ? UART_STATE_DATA : UART_STATE_STOP;
                    tx_clk_div <= CLK_DIV;
                    tx_bit <= tx_bit - 1;
                    tx_byte <= {1'b0, tx_byte[7:1]};
                    tx_out <= tx_bit ? tx_byte[0] : 1;
                end
            end
            UART_STATE_STOP: begin
                if (!tx_clk_div) begin
                    tx_state <= UART_STATE_IDLE;
                    tx_ready_out <= 1;
                end
            end
        endcase

        if (reset) begin
            rx_state <= UART_STATE_IDLE;
            tx_state <= UART_STATE_IDLE;
            rx_received_out <= 0;
            tx_out <= 1;
            tx_ready_out <= 1;
        end
    end
endmodule

`endif
