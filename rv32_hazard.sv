`ifndef RV32_HAZARD
`define RV32_HAZARD

module rv32_hazard (
    /* control in */
    input [4:0] decode_rs1_in,
    input [4:0] decode_rs2_in,

    input decode_mem_read_in,
    input [4:0] decode_rd_in,
    input decode_rd_write_in,

    input mem_branch_taken_in,

    /* control out */
    output logic fetch_stall_out,
    output logic fetch_flush_out,

    output logic decode_stall_out,
    output logic decode_flush_out,

    output logic execute_stall_out,
    output logic execute_flush_out,

    output logic mem_stall_out,
    output logic mem_flush_out
);
    logic fetch_wait_for_mem_read;

    assign fetch_wait_for_mem_read = (decode_rs1_in == decode_rd_in || decode_rs2_in == decode_rd_in) && |decode_rd_in && decode_mem_read_in && decode_rd_write_in;

    assign fetch_stall_out = decode_stall_out || fetch_wait_for_mem_read;
    assign fetch_flush_out = 0;

    assign decode_stall_out = execute_stall_out;
    assign decode_flush_out = fetch_stall_out || mem_branch_taken_in;

    assign execute_stall_out = mem_stall_out;
    assign execute_flush_out = decode_stall_out || mem_branch_taken_in;

    assign mem_stall_out = 0;
    assign mem_flush_out = execute_stall_out;
endmodule

`endif
