`ifndef RV32_CSRS
`define RV32_CSRS

`define RV32_CSR_MSTATUS        12'h300
`define RV32_CSR_MISA           12'h301
`define RV32_CSR_MIE            12'h304
`define RV32_CSR_MTVEC          12'h305
`define RV32_CSR_MHPMEVENT3     12'h323
`define RV32_CSR_MHPMEVENT4     12'h324
`define RV32_CSR_MHPMEVENT5     12'h325
`define RV32_CSR_MHPMEVENT6     12'h326
`define RV32_CSR_MHPMEVENT7     12'h327
`define RV32_CSR_MHPMEVENT8     12'h328
`define RV32_CSR_MHPMEVENT9     12'h329
`define RV32_CSR_MHPMEVENT10    12'h32A
`define RV32_CSR_MHPMEVENT11    12'h32B
`define RV32_CSR_MHPMEVENT12    12'h32C
`define RV32_CSR_MHPMEVENT13    12'h32D
`define RV32_CSR_MHPMEVENT14    12'h32E
`define RV32_CSR_MHPMEVENT15    12'h32F
`define RV32_CSR_MHPMEVENT16    12'h330
`define RV32_CSR_MHPMEVENT17    12'h331
`define RV32_CSR_MHPMEVENT18    12'h332
`define RV32_CSR_MHPMEVENT19    12'h333
`define RV32_CSR_MHPMEVENT20    12'h334
`define RV32_CSR_MHPMEVENT21    12'h335
`define RV32_CSR_MHPMEVENT22    12'h336
`define RV32_CSR_MHPMEVENT23    12'h337
`define RV32_CSR_MHPMEVENT24    12'h338
`define RV32_CSR_MHPMEVENT25    12'h339
`define RV32_CSR_MHPMEVENT26    12'h33A
`define RV32_CSR_MHPMEVENT27    12'h33B
`define RV32_CSR_MHPMEVENT28    12'h33C
`define RV32_CSR_MHPMEVENT29    12'h33D
`define RV32_CSR_MHPMEVENT30    12'h33E
`define RV32_CSR_MHPMEVENT31    12'h33F
`define RV32_CSR_MSCRATCH       12'h340
`define RV32_CSR_MEPC           12'h341
`define RV32_CSR_MCAUSE         12'h342
`define RV32_CSR_MTVAL          12'h343
`define RV32_CSR_MIP            12'h344
`define RV32_CSR_PMPCFG0        12'h3A0
`define RV32_CSR_PMPCFG1        12'h3A1
`define RV32_CSR_PMPCFG2        12'h3A2
`define RV32_CSR_PMPCFG3        12'h3A3
`define RV32_CSR_PMPADDR0       12'h3B0
`define RV32_CSR_PMPADDR1       12'h3B1
`define RV32_CSR_PMPADDR2       12'h3B2
`define RV32_CSR_PMPADDR3       12'h3B3
`define RV32_CSR_PMPADDR4       12'h3B4
`define RV32_CSR_PMPADDR5       12'h3B5
`define RV32_CSR_PMPADDR6       12'h3B6
`define RV32_CSR_PMPADDR7       12'h3B7
`define RV32_CSR_PMPADDR8       12'h3B8
`define RV32_CSR_PMPADDR9       12'h3B9
`define RV32_CSR_PMPADDR10      12'h3BA
`define RV32_CSR_PMPADDR11      12'h3BB
`define RV32_CSR_PMPADDR12      12'h3BC
`define RV32_CSR_PMPADDR13      12'h3BD
`define RV32_CSR_PMPADDR14      12'h3BE
`define RV32_CSR_PMPADDR15      12'h3BF
`define RV32_CSR_MCYCLE         12'hB00
`define RV32_CSR_MINSTRET       12'hB02
`define RV32_CSR_MHPMCOUNTER3   12'hB03
`define RV32_CSR_MHPMCOUNTER4   12'hB04
`define RV32_CSR_MHPMCOUNTER5   12'hB05
`define RV32_CSR_MHPMCOUNTER6   12'hB06
`define RV32_CSR_MHPMCOUNTER7   12'hB07
`define RV32_CSR_MHPMCOUNTER8   12'hB08
`define RV32_CSR_MHPMCOUNTER9   12'hB09
`define RV32_CSR_MHPMCOUNTER10  12'hB0A
`define RV32_CSR_MHPMCOUNTER11  12'hB0B
`define RV32_CSR_MHPMCOUNTER12  12'hB0C
`define RV32_CSR_MHPMCOUNTER13  12'hB0D
`define RV32_CSR_MHPMCOUNTER14  12'hB0E
`define RV32_CSR_MHPMCOUNTER15  12'hB0F
`define RV32_CSR_MHPMCOUNTER16  12'hB10
`define RV32_CSR_MHPMCOUNTER17  12'hB11
`define RV32_CSR_MHPMCOUNTER18  12'hB12
`define RV32_CSR_MHPMCOUNTER19  12'hB13
`define RV32_CSR_MHPMCOUNTER20  12'hB14
`define RV32_CSR_MHPMCOUNTER21  12'hB15
`define RV32_CSR_MHPMCOUNTER22  12'hB16
`define RV32_CSR_MHPMCOUNTER23  12'hB17
`define RV32_CSR_MHPMCOUNTER24  12'hB18
`define RV32_CSR_MHPMCOUNTER25  12'hB19
`define RV32_CSR_MHPMCOUNTER26  12'hB1A
`define RV32_CSR_MHPMCOUNTER27  12'hB1B
`define RV32_CSR_MHPMCOUNTER28  12'hB1C
`define RV32_CSR_MHPMCOUNTER29  12'hB1D
`define RV32_CSR_MHPMCOUNTER30  12'hB1E
`define RV32_CSR_MHPMCOUNTER31  12'hB1F
`define RV32_CSR_MCYCLEH        12'hB80
`define RV32_CSR_MINSTRETH      12'hB82
`define RV32_CSR_MHPMCOUNTER3H  12'hB83
`define RV32_CSR_MHPMCOUNTER4H  12'hB84
`define RV32_CSR_MHPMCOUNTER5H  12'hB85
`define RV32_CSR_MHPMCOUNTER6H  12'hB86
`define RV32_CSR_MHPMCOUNTER7H  12'hB87
`define RV32_CSR_MHPMCOUNTER8H  12'hB88
`define RV32_CSR_MHPMCOUNTER9H  12'hB89
`define RV32_CSR_MHPMCOUNTER10H 12'hB8A
`define RV32_CSR_MHPMCOUNTER11H 12'hB8B
`define RV32_CSR_MHPMCOUNTER12H 12'hB8C
`define RV32_CSR_MHPMCOUNTER13H 12'hB8D
`define RV32_CSR_MHPMCOUNTER14H 12'hB8E
`define RV32_CSR_MHPMCOUNTER15H 12'hB8F
`define RV32_CSR_MHPMCOUNTER16H 12'hB90
`define RV32_CSR_MHPMCOUNTER17H 12'hB91
`define RV32_CSR_MHPMCOUNTER18H 12'hB92
`define RV32_CSR_MHPMCOUNTER19H 12'hB93
`define RV32_CSR_MHPMCOUNTER20H 12'hB94
`define RV32_CSR_MHPMCOUNTER21H 12'hB95
`define RV32_CSR_MHPMCOUNTER22H 12'hB96
`define RV32_CSR_MHPMCOUNTER23H 12'hB97
`define RV32_CSR_MHPMCOUNTER24H 12'hB98
`define RV32_CSR_MHPMCOUNTER25H 12'hB99
`define RV32_CSR_MHPMCOUNTER26H 12'hB9A
`define RV32_CSR_MHPMCOUNTER27H 12'hB9B
`define RV32_CSR_MHPMCOUNTER28H 12'hB9C
`define RV32_CSR_MHPMCOUNTER29H 12'hB9D
`define RV32_CSR_MHPMCOUNTER30H 12'hB9E
`define RV32_CSR_MHPMCOUNTER31H 12'hB9F
`define RV32_CSR_CYCLE          12'hC00
`define RV32_CSR_TIME           12'hC01
`define RV32_CSR_INSTRET        12'hC02
`define RV32_CSR_CYCLEH         12'hC80
`define RV32_CSR_TIMEH          12'hC81
`define RV32_CSR_INSTRETH       12'hC82
`define RV32_CSR_MVENDORID      12'hF11
`define RV32_CSR_MARCHID        12'hF12
`define RV32_CSR_MIMPID         12'hF13
`define RV32_CSR_MHARTID        12'hF14

`define RV32_CSR_WRITE_OP_RW 2'b00
`define RV32_CSR_WRITE_OP_RS 2'b01
`define RV32_CSR_WRITE_OP_RC 2'b10

`define RV32_CSR_SRC_IMM 1'b0
`define RV32_CSR_SRC_REG 1'b1

                     /* | XLEN|    |ABCDEFGHIJKLMNOPQRSTUVWXYZ | */
`define RV32_MISA_VALUE 32'b01_0000_00000000100000000000000000

module rv32_csrs (
    input clk,
    input stall_in,

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

    logic [31:0] mscratch;
    logic [63:0] cycle;
    logic [63:0] instret;

    assign write_value = src_in ? rs1_value_in : imm_value_in;

    always_comb begin
        case (csr_in)
            `RV32_CSR_MISA:           read_value_out = `RV32_MISA_VALUE;
            `RV32_CSR_MHPMEVENT3:     read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT4:     read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT5:     read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT6:     read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT7:     read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT7:     read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT9:     read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT10:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT11:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT12:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT13:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT14:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT15:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT16:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT17:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT18:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT19:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT20:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT21:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT22:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT23:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT24:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT25:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT26:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT27:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT28:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT29:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT30:    read_value_out = 32'b0;
            `RV32_CSR_MHPMEVENT31:    read_value_out = 32'b0;
            `RV32_CSR_MSCRATCH:       read_value_out = mscratch;
            `RV32_CSR_PMPCFG0:        read_value_out = 32'b0;
            `RV32_CSR_PMPCFG1:        read_value_out = 32'b0;
            `RV32_CSR_PMPCFG2:        read_value_out = 32'b0;
            `RV32_CSR_PMPCFG3:        read_value_out = 32'b0;
            `RV32_CSR_PMPADDR0:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR1:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR2:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR3:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR4:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR5:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR6:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR7:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR8:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR9:       read_value_out = 32'b0;
            `RV32_CSR_PMPADDR10:      read_value_out = 32'b0;
            `RV32_CSR_PMPADDR11:      read_value_out = 32'b0;
            `RV32_CSR_PMPADDR12:      read_value_out = 32'b0;
            `RV32_CSR_PMPADDR13:      read_value_out = 32'b0;
            `RV32_CSR_PMPADDR14:      read_value_out = 32'b0;
            `RV32_CSR_PMPADDR15:      read_value_out = 32'b0;
            `RV32_CSR_MCYCLE:         read_value_out = cycle[31:0];
            `RV32_CSR_MINSTRET:       read_value_out = instret[31:0];
            `RV32_CSR_MHPMCOUNTER3:   read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER4:   read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER5:   read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER6:   read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER7:   read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER8:   read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER9:   read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER10:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER11:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER12:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER13:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER14:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER15:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER16:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER17:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER18:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER19:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER20:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER21:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER22:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER23:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER24:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER25:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER26:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER27:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER28:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER29:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER30:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER31:  read_value_out = 32'b0;
            `RV32_CSR_MCYCLEH:        read_value_out = cycle[63:32];
            `RV32_CSR_MINSTRETH:      read_value_out = instret[63:32];
            `RV32_CSR_MHPMCOUNTER3H:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER4H:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER5H:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER6H:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER7H:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER8H:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER9H:  read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER10H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER11H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER12H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER13H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER14H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER15H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER16H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER17H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER18H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER19H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER20H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER21H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER22H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER23H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER24H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER25H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER26H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER27H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER28H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER29H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER30H: read_value_out = 32'b0;
            `RV32_CSR_MHPMCOUNTER31H: read_value_out = 32'b0;
            `RV32_CSR_CYCLE:          read_value_out = cycle[31:0];
            `RV32_CSR_TIME:           read_value_out = cycle[31:0];
            `RV32_CSR_INSTRET:        read_value_out = instret[31:0];
            `RV32_CSR_CYCLEH:         read_value_out = cycle[63:32];
            `RV32_CSR_TIMEH:          read_value_out = cycle[63:32];
            `RV32_CSR_INSTRETH:       read_value_out = instret[63:32];
            `RV32_CSR_MVENDORID:      read_value_out = 32'b0;
            `RV32_CSR_MARCHID:        read_value_out = 32'b0;
            `RV32_CSR_MIMPID:         read_value_out = 32'b0;
            `RV32_CSR_MHARTID:        read_value_out = 32'b0;
            default:                  read_value_out = 32'bx;
        endcase

        case (write_op_in)
            `RV32_CSR_WRITE_OP_RW: new_value = write_value;
            `RV32_CSR_WRITE_OP_RS: new_value = read_value_out |  write_value;
            `RV32_CSR_WRITE_OP_RC: new_value = read_value_out & ~write_value;
            default:               new_value = 32'bx;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!stall_in && write_in) begin
            case (csr_in)
                `RV32_CSR_MSCRATCH: mscratch <= new_value;
            endcase
        end

        cycle <= cycle + 1;
        instret <= instret + instr_retired_in;
    end
endmodule

`endif
