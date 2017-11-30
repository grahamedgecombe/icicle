`include "rv32_decode.sv"
`include "rv32_fetch.sv"

module rv32 (
    input logic clk
);
    rv32_fetch fetch (
        .clk(clk),
        
        /* data out */
        .pc_out(fetch_pc),
        .instr_out(fetch_instr)
    );

    logic [31:0] fetch_pc;
    logic [31:0] fetch_instr;

    rv32_decode decode (
        .clk(clk),

        /* data in */
        .pc_in(fetch_pc),
        .instr_in(fetch_instr)
    );
endmodule
