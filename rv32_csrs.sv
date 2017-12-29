`ifndef RV32_CSRS
`define RV32_CSRS

/*                           |rw|pl| id    | */
`define RV32_CSR_CYCLE    12'b11_00_00000000
`define RV32_CSR_TIME     12'b11_00_00000001
`define RV32_CSR_INSTRET  12'b11_00_00000010
`define RV32_CSR_CYCLEH   12'b11_00_10000000
`define RV32_CSR_TIMEH    12'b11_00_10000001
`define RV32_CSR_INSTRETH 12'b11_00_10000010

`define RV32_CSR_WRITE_OP_RW 2'b00
`define RV32_CSR_WRITE_OP_RS 2'b01
`define RV32_CSR_WRITE_OP_RC 2'b10

module rv32_csrs (
    input clk,

    /* control in */
    input read_in,
    input write_in,
    input [1:0] write_op_in,

    /* control in (from writeback) */
    input instr_retired_in,

    /* data in */
    input [31:0] result_in,
    input [11:0] csr_in,

    /* data out */
    output logic [31:0] read_value_out
);
    logic [31:0] write_value;

    logic [31:0] cycleh;
    logic [31:0] cycle;

    logic [31:0] instreth;
    logic [31:0] instret;

    always_comb begin
        case (csr_in)
            `RV32_CSR_CYCLE:    read_value_out = cycle;
            `RV32_CSR_TIME:     read_value_out = cycle;
            `RV32_CSR_INSTRET:  read_value_out = instret;
            `RV32_CSR_CYCLEH:   read_value_out = cycleh;
            `RV32_CSR_TIMEH:    read_value_out = cycleh;
            `RV32_CSR_INSTRETH: read_value_out = instreth;
            default:            read_value_out = 32'bx;
        endcase

        case (write_op_in)
            `RV32_CSR_WRITE_OP_RW: write_value = result_in;
            `RV32_CSR_WRITE_OP_RS: write_value = read_value_out |  result_in;
            `RV32_CSR_WRITE_OP_RC: write_value = read_value_out & ~result_in;
            default:               write_value = 32'bx;
        endcase
    end

    always_ff @(posedge clk) begin
        cycleh <= cycleh + &cycle;
        cycle <= cycle + 1;

        instreth <= instreth + (&instret && instr_retired_in);
        instret <= instret + instr_retired_in;
    end
endmodule

`endif
