module rv32_fetch (
    input clk,

    /* data out */
    output [31:0] pc_out,
    output [31:0] instr_out
);
    logic [31:0] instr_mem [255:0];
    logic [31:0] pc;

    always_ff @(posedge clk) begin
        instr_out <= instr_mem[pc[31:2]];
        pc <= pc + 4;
        pc_out <= pc;
    end
endmodule
