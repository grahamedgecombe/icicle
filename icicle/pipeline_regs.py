from icicle.alu import ASrc, BSrc, ResultSrc
from icicle.logic import LogicOp

PF_LAYOUT = [
    ("pc", 32)
]

FD_LAYOUT = [
    ("pc",   32),
    ("insn", 32)
]

DX_LAYOUT = [
    ("pc",                32),
    ("insn",              32),
    ("rd",                 5),
    ("rd_wen",             1),
    ("rs1",                5),
    ("rs1_ren",            1),
    ("rs1_rdata",         32),
    ("rs2",                5),
    ("rs2_ren",            1),
    ("rs2_rdata",         32),
    ("imm",               32),
    ("a_src",           ASrc),
    ("b_src",           BSrc),
    ("add_sub",            1),
    ("add_signed_compare", 1),
    ("logic_op",     LogicOp),
    ("shift_right",        1),
    ("shift_arithmetic",   1),
    ("result_src", ResultSrc)
]

XM_LAYOUT = [
    ("pc",                32),
    ("insn",              32),
    ("rd",                 5),
    ("rd_wen",             1),
    ("rs1",                5),
    ("rs1_ren",            1),
    ("rs1_rdata",         32),
    ("rs2",                5),
    ("rs2_ren",            1),
    ("rs2_rdata",         32),
    ("add_result",        32),
    ("add_carry",          1),
    ("logic_result",      32),
    ("shift_result",      32),
    ("result_src", ResultSrc)
]

MW_LAYOUT = [
    ("pc",        32),
    ("insn",      32),
    ("rd",         5),
    ("rd_wen",     1),
    ("rd_wdata",  32),
    ("rs1",        5),
    ("rs1_ren",    1),
    ("rs1_rdata", 32),
    ("rs2",        5),
    ("rs2_ren",    1),
    ("rs2_rdata", 32)
]
