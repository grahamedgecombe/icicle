`ifndef RV32_HAZARD
`define RV32_HAZARD

module rv32_hazard (
    input branch_taken_in,

    output fetch_stall_out,
    output fetch_flush_out,

    output decode_stall_out,
    output decode_flush_out,

    output execute_stall_out,
    output execute_flush_out,

    output mem_stall_out,
    output mem_flush_out
);
    assign fetch_stall_out = decode_stall_out;
    assign fetch_flush_out = 0;

    assign decode_stall_out = execute_stall_out;
    assign decode_flush_out = fetch_stall_out || branch_taken_in;

    assign execute_stall_out = mem_stall_out;
    assign execute_flush_out = decode_stall_out || branch_taken_in;

    assign mem_stall_out = 0;
    assign mem_flush_out = execute_stall_out;
endmodule

`endif
