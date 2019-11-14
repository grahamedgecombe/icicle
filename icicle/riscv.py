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


class Format(Enum):
    R = 0
    I = 1
    S = 2
    B = 3
    U = 4
    J = 5
