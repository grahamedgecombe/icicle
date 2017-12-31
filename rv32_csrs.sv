`ifndef RV32_CSRS
`define RV32_CSRS

`define RV32_CSR_MISA      12'h301
`define RV32_CSR_CYCLE     12'hC00
`define RV32_CSR_TIME      12'hC01
`define RV32_CSR_INSTRET   12'hC02
`define RV32_CSR_CYCLEH    12'hC80
`define RV32_CSR_TIMEH     12'hC81
`define RV32_CSR_INSTRETH  12'hC82
`define RV32_CSR_MVENDORID 12'hF11
`define RV32_CSR_MARCHID   12'hF12
`define RV32_CSR_MIMPID    12'hF13
`define RV32_CSR_MHARTID   12'hF14

`define RV32_CSR_WRITE_OP_RW 2'b00
`define RV32_CSR_WRITE_OP_RS 2'b01
`define RV32_CSR_WRITE_OP_RC 2'b10

`define RV32_CSR_SRC_IMM 1'b0
`define RV32_CSR_SRC_REG 1'b1

                       /* XLEN|    |ABCDEFGHIJKLMNOPQRSTUVWXYZ */
`define RV32_MISA_VALUE 32'b01_0000_00000000100000000000000000

module rv32_csrs (
    input clk,

    /* control in */
    input read_in,
    input write_in,
    input [1:0] write_op_in,
    input src_in,

    /* control in (from writeback) */
    input instr_retired_in,

    /* data in */
    input [11:0] csr_in,
    input [31:0] rs1_value_in,
    input [31:0] imm_value_in,

    /* data out */
    output logic [31:0] read_value_out
);
    logic [31:0] write_value;
    logic [31:0] new_value;

    logic [63:0] cycle;
    logic [63:0] instret;

    assign write_value = src_in ? rs1_value_in : imm_value_in;

    always_comb begin
        case (csr_in)
            `RV32_CSR_MISA:      read_value_out = `RV32_MISA_VALUE;
            `RV32_CSR_CYCLE:     read_value_out = cycle[31:0];
            `RV32_CSR_TIME:      read_value_out = cycle[31:0];
            `RV32_CSR_INSTRET:   read_value_out = instret[31:0];
            `RV32_CSR_CYCLEH:    read_value_out = cycle[63:32];
            `RV32_CSR_TIMEH:     read_value_out = cycle[63:32];
            `RV32_CSR_INSTRETH:  read_value_out = instret[63:32];
            `RV32_CSR_MVENDORID: read_value_out = 32'b0;
            `RV32_CSR_MARCHID:   read_value_out = 32'b0;
            `RV32_CSR_MIMPID:    read_value_out = 32'b0;
            `RV32_CSR_MHARTID:   read_value_out = 32'b0;
            default:             read_value_out = 32'bx;
        endcase

        case (write_op_in)
            `RV32_CSR_WRITE_OP_RW: new_value = write_value;
            `RV32_CSR_WRITE_OP_RS: new_value = read_value_out |  write_value;
            `RV32_CSR_WRITE_OP_RC: new_value = read_value_out & ~write_value;
            default:               new_value = 32'bx;
        endcase
    end

    always_ff @(posedge clk) begin
        cycle <= cycle + 1;
        instret <= instret + instr_retired_in;
    end
endmodule

`endif
