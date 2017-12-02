`ifndef RV32_FETCH
`define RV32_FETCH

module rv32_fetch (
    input clk,

    /* control in */
    input branch_taken_in,

    /* data in */
    input [31:0] branch_pc_in,

    /* data out */
    output [31:0] pc_out,
    output [31:0] instr_out
);
    logic [31:0] instr_mem [255:0];
    logic [31:0] next_pc;

    logic [31:0] pc = branch_taken_in ? branch_pc_in : next_pc;

    initial
        $readmemh("progmem_syn.hex", instr_mem);

    always_ff @(posedge clk) begin
        instr_out <= instr_mem[pc[31:2]];
        next_pc <= pc + 4;
        pc_out <= pc;
    end
endmodule

`endif
