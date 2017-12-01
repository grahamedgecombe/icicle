localparam RV32_ALU_OP_ADD_SUB = 4'b0000;
localparam RV32_ALU_OP_XOR     = 4'b0001;
localparam RV32_ALU_OP_OR      = 4'b0010;
localparam RV32_ALU_OP_AND     = 4'b0011;
localparam RV32_ALU_OP_SLL     = 4'b0100;
localparam RV32_ALU_OP_SRL_SRA = 4'b0101;
localparam RV32_ALU_OP_SLT     = 4'b0110;
localparam RV32_ALU_OP_SLTU    = 4'b0111;
localparam RV32_ALU_OP_SRC2    = 4'b1000;

localparam RV32_ALU_SRC1_REG = 1'b0;
localparam RV32_ALU_SRC1_PC  = 1'b1;

localparam RV32_ALU_SRC2_REG = 1'b0;
localparam RV32_ALU_SRC2_IMM = 1'b1;
