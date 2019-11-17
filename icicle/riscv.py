from enum import Enum


class Opcode:
    LUI      = 0b0110111
    AUIPC    = 0b0010111
    JAL      = 0b1101111
    JALR     = 0b1100111
    BRANCH   = 0b1100011
    LOAD     = 0b0000011
    STORE    = 0b0100011
    OP_IMM   = 0b0010011
    OP       = 0b0110011
    MISC_MEM = 0b0001111
    SYSTEM   = 0b1110011


class Funct3:
    ZERO    = 0b000
    # BRANCH
    BEQ     = 0b000
    BNE     = 0b001
    BLT     = 0b100
    BGE     = 0b101
    BLTU    = 0b110
    BGEU    = 0b111
    # LOAD
    LB      = 0b000
    LH      = 0b001
    LW      = 0b010
    LBU     = 0b100
    LHU     = 0b101
    # STORE
    SB      = 0b000
    SH      = 0b001
    SW      = 0b010
    # OP-IMM/OP
    ADD_SUB = 0b000
    SLL     = 0b001
    SLT     = 0b010
    SLTU    = 0b011
    XOR     = 0b100
    SRL_SRA = 0b101
    OR      = 0b110
    AND     = 0b111
    # MISC-MEM
    FENCE   = 0b000
    FENCE_I = 0b001
    # SYSTEM
    PRIV    = 0b000
    CSRRW   = 0b001
    CSRRS   = 0b010
    CSRRC   = 0b011
    CSRRWI  = 0b101
    CSRRSI  = 0b110
    CSRRCI  = 0b111


class Funct7:
    ZERO    = 0b0000000
    # OP-IMM/OP
    SUB_SRA = 0b0100000


class Funct12:
    ZERO   = 0b000000000000
    # SYSTEM
    ECALL  = 0b000000000000
    EBREAK = 0b000000000001


class Format(Enum):
    R = 0
    I = 1
    S = 2
    B = 3
    U = 4
    J = 5
