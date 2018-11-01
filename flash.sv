`ifndef FLASH
`define FLASH

`define FLASH_CMD_READ 8'h03

`define FLASH_STATE_IDLE      2'b00
`define FLASH_STATE_WRITE_CMD 2'b01
`define FLASH_STATE_READ_DATA 2'b10
`define FLASH_STATE_DONE      2'b11

module flash (
    input clk,
    input reset,

    /* SPI bus */
    output logic clk_out,
    output logic csn_out,
    input io0_in,
    input io1_in,
    output logic io0_en,
    output logic io1_en,
    output logic io0_out,
    output logic io1_out,

    /* memory bus */
    input [31:0] address_in,
    input sel_in,
    input read_in,
    output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out
);
    initial
        state <= `FLASH_STATE_IDLE;

    assign clk_out = clk;
    assign csn_out = state != `FLASH_STATE_WRITE_CMD && state != `FLASH_STATE_READ_DATA;
    assign io0_en = 1;
    assign io1_en = 0;

    logic [31:0] read_value;

    assign read_value_out = sel_in ? read_value : 0;
    assign ready_out = state == `FLASH_STATE_DONE;

    logic [31:0] read_cmd;

    assign read_cmd = {`FLASH_CMD_READ, address_in[23:0]};

    logic [1:0] state;
    logic [4:0] bits;

    always_ff @(posedge clk) begin
        case (state)
            `FLASH_STATE_IDLE: begin
                if (sel_in && read_in) begin
                    io0_out <= read_cmd[31];
                    read_value <= {read_cmd[30:0], 1'bx};
                    state <= `FLASH_STATE_WRITE_CMD;
                    bits <= 31;
                end else begin
                    io0_out <= 1'bx;
                    bits <= 5'bx;
                end
            end
            `FLASH_STATE_WRITE_CMD: begin
                if (|bits) begin
                    io0_out <= read_value[31];
                    read_value <= {read_value[30:0], 1'bx};
                    bits <= bits - 1;
                end else begin
                    io0_out <= 1'bx;
                    read_value <= {31'bx, io1_in};
                    state <= `FLASH_STATE_READ_DATA;
                    bits <= 31;
                end
            end
            `FLASH_STATE_READ_DATA: begin
                if (|bits) begin
                    io0_out <= 1'bx;
                    read_value <= {read_value[30:0], io1_in};
                    bits <= bits - 1;
                end else begin
                    read_value <= {read_value[30:0], io1_in};
                    state <= `FLASH_STATE_DONE;
                    io0_out <= 1'bx;
                    bits <= 5'bx;
                end
            end
            `FLASH_STATE_DONE: begin
                state <= `FLASH_STATE_IDLE;
                io0_out <= 1'bx;
                bits <= 5'bx;
            end
        endcase

        if (reset)
            state <= `FLASH_STATE_IDLE;
    end
endmodule

`endif
