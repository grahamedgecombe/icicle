`include "rv32.sv"

module top (
    input clk
);
    rv32 rv32 (
        .clk(clk)
    );
endmodule
