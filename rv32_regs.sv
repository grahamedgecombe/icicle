`ifndef RV32_REGS
`define RV32_REGS

module rv32_regs (
    input clk,
    input stall_in,

    /* control in */
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,
    input rd_write_in,

    /* data in */
    input [31:0] rd_value_in,

    /* data out */
    output [31:0] rs1_value_out,
    output [31:0] rs2_value_out
);
    logic [31:0] regs [31:0];

    always_ff @(posedge clk) begin
        if (!stall_in) begin
            rs1_value_out <= regs[rs1_in];
            rs2_value_out <= regs[rs2_in];
        end

        if (rd_write_in && |rd_in)
            regs[rd_in] <= rd_value_in;
    end
endmodule

`endif
