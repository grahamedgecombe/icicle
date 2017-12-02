`ifndef RV32_BRANCH_OPS
`define RV32_BRANCH_OPS

localparam RV32_BRANCH_OP_NEVER    = 3'b00;
localparam RV32_BRANCH_OP_ZERO     = 3'b01;
localparam RV32_BRANCH_OP_NON_ZERO = 3'b10;
localparam RV32_BRANCH_OP_ALWAYS   = 3'b11;

localparam RV32_BRANCH_PC_SRC_IMM = 1'b0;
localparam RV32_BRANCH_PC_SRC_REG = 1'b1;

`endif
