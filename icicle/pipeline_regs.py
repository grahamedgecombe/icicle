PF_LAYOUT = [
    ("pc", 32)
]

FD_LAYOUT = [
    ("pc",   32),
    ("insn", 32)
]

DX_LAYOUT = [
    ("pc",        32),
    ("rd",         5),
    ("rd_wen",     1),
    ("rs1",        5),
    ("rs1_ren",    1),
    ("rs1_rdata", 32),
    ("rs2",        5),
    ("rs2_ren",    1),
    ("rs2_rdata", 32),
    ("imm",       32)
]

XM_LAYOUT = [
    ("rd",      5),
    ("rd_wen",  1),
    ("rs1",     5),
    ("rs1_ren", 1),
    ("rs2",     5),
    ("rs2_ren", 1)
]

MW_LAYOUT = [
    ("rd",        5),
    ("rd_wen",    1),
    ("rd_wdata", 32),
    ("rs1",       5),
    ("rs1_ren",   1),
    ("rs2",       5),
    ("rs2_ren",   1)
]
