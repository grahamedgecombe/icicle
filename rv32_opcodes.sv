`ifndef RV32_OPCODES
`define RV32_OPCODES

localparam RV32_OPCODE_LOAD     = 7'b0000011;
localparam RV32_OPCODE_MISC_MEM = 7'b0001111;
localparam RV32_OPCODE_OP_IMM   = 7'b0010011;
localparam RV32_OPCODE_AUIPC    = 7'b0010111;
localparam RV32_OPCODE_STORE    = 7'b0100011;
localparam RV32_OPCODE_OP       = 7'b0110011;
localparam RV32_OPCODE_LUI      = 7'b0110111;
localparam RV32_OPCODE_BRANCH   = 7'b1100011;
localparam RV32_OPCODE_JALR     = 7'b1100111;
localparam RV32_OPCODE_JAL      = 7'b1101111;
localparam RV32_OPCODE_SYSTEM   = 7'b1110011;

localparam RV32_FUNCT3_ANY  = 3'b???;
localparam RV32_FUNCT3_ZERO = 3'b000;

localparam RV32_FUNCT3_BRANCH_BEQ  = 3'b000;
localparam RV32_FUNCT3_BRANCH_BNE  = 3'b001;
localparam RV32_FUNCT3_BRANCH_BLT  = 3'b100;
localparam RV32_FUNCT3_BRANCH_BGE  = 3'b101;
localparam RV32_FUNCT3_BRANCH_BLTU = 3'b110;
localparam RV32_FUNCT3_BRANCH_BGEU = 3'b111;

localparam RV32_FUNCT3_LOAD_LB  = 3'b000;
localparam RV32_FUNCT3_LOAD_LH  = 3'b001;
localparam RV32_FUNCT3_LOAD_LW  = 3'b010;
localparam RV32_FUNCT3_LOAD_LBU = 3'b100;
localparam RV32_FUNCT3_LOAD_LHU = 3'b101;

localparam RV32_FUNCT3_STORE_SB = 3'b000;
localparam RV32_FUNCT3_STORE_SH = 3'b001;
localparam RV32_FUNCT3_STORE_SW = 3'b010;

localparam RV32_FUNCT3_OP_ADD_SUB = 3'b000;
localparam RV32_FUNCT3_OP_SLL     = 3'b001;
localparam RV32_FUNCT3_OP_SLT     = 3'b010;
localparam RV32_FUNCT3_OP_SLTU    = 3'b011;
localparam RV32_FUNCT3_OP_XOR     = 3'b100;
localparam RV32_FUNCT3_OP_SRL_SRA = 3'b101;
localparam RV32_FUNCT3_OP_OR      = 3'b110;
localparam RV32_FUNCT3_OP_AND     = 3'b111;

localparam RV32_FUNCT3_MISC_MEM_FENCE   = 3'b000;
localparam RV32_FUNCT3_MISC_MEM_FENCE_I = 3'b001;

localparam RV32_FUNCT7_ANY  = 7'b???????;
localparam RV32_FUNCT7_ZERO = 7'b0000000;

localparam RV32_FUNCT7_OP_SRA = 7'b0100000;
localparam RV32_FUNCT7_OP_SUB = 7'b0100000;

`endif
