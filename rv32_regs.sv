module rv32_regs (
    input logic clk,

    /* control in */
    input logic [4:0] rs1_in,
    input logic [4:0] rs2_in,
    input logic [4:0] rd_in,
    input logic rd_writeback_in,

    /* data in */
    input logic [31:0] rd_value_in,

    /* data out */
    output logic [31:0] rs1_value_out,
    output logic [31:0] rs2_value_out
);
    logic [31:0] regs [31:0];

    always_ff @(posedge clk) begin
        rs1_value_out <= regs[rs1_in];
        rs2_value_out <= regs[rs2_in];

        if (rd_writeback_in && |rd_in)
            regs[rd_in] <= rd_value_in;
    end
endmodule
