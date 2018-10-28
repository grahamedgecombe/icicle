`ifndef FLASH
`define FLASH

`define FLASH_CMD_READ 8'h03

`define FLASH_STATE_IDLE      2'b00
`define FLASH_STATE_WRITE_CMD 2'b01
`define FLASH_STATE_READ_DATA 2'b10

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
    initial begin
        csn_out <= 1;
        state <= `FLASH_STATE_IDLE;
    end

    assign clk_out = clk;
    assign io0_en = 1;
    assign io1_en = 0;

    logic [31:0] read_value;
    logic ready;

    assign read_value_out = sel_in ? read_value : 0;
    assign ready_out = ready;

    logic [31:0] read_cmd;

    assign read_cmd = {`FLASH_CMD_READ, address_in[23:0]};

    logic [30:0] shift_reg;
    logic [1:0] state;
    logic [4:0] bits;

    always_ff @(negedge clk) begin
        ready <= 0;

        case (state)
            `FLASH_STATE_IDLE: begin
                if (sel_in) begin
                    if (read_in) begin
                        csn_out <= 0;
                        io0_out <= read_cmd[31];
                        shift_reg <= read_cmd[30:0];
                        state <= `FLASH_STATE_WRITE_CMD;
                        bits <= 31;
                    end else begin
                        /* ignore writes */
                        ready <= 1;
                    end
                end
            end
            `FLASH_STATE_WRITE_CMD: begin
                if (|bits) begin
                    io0_out <= shift_reg[30];
                    shift_reg <= {shift_reg[29:0], 1'bx};
                    bits <= bits - 1;
                end else begin
                    shift_reg <= {30'bx, io1_in};
                    state <= `FLASH_STATE_READ_DATA;
                    bits <= 31;
                end
            end
            `FLASH_STATE_READ_DATA: begin
                if (|bits) begin
                    shift_reg <= {shift_reg[29:0], io1_in};
                    bits <= bits - 1;
                end else begin
                    csn_out <= 1;
                    read_value <= {shift_reg, io1_in};
                    state <= `FLASH_STATE_IDLE;
                    ready <= 1;
                end
            end
        endcase

        if (reset) begin
            csn_out <= 1;
            state <= `FLASH_STATE_IDLE;
            ready <= 0;
        end
    end
endmodule

`endif
