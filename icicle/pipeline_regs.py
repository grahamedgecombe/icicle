from icicle.alu import ASel, BSel, ResultSel
from icicle.branch import BranchTargetSel, BranchOp
from icicle.loadstore import MemWidth
from icicle.logic import LogicOp
from icicle.wdata import WDataSel

PF_LAYOUT = [
    ("pc_rdata", 32),
]

FD_LAYOUT = [
    ("pc_rdata", 32),
    ("insn",     32),
    ("mem_fault", 1)
]

DX_LAYOUT = [
    ("pc_rdata",                       32),
    ("insn",                           32),
    ("rd",                              5),
    ("rd_wen",                          1),
    ("rs1",                             5),
    ("rs1_ren",                         1),
    ("rs1_rdata",                      32),
    ("rs2",                             5),
    ("rs2_ren",                         1),
    ("rs2_rdata",                      32),
    ("imm",                            32),
    ("a_sel",                        ASel),
    ("b_sel",                        BSel),
    ("add_sub",                         1),
    ("add_signed_compare",              1),
    ("logic_op",                  LogicOp),
    ("shift_direction",                 1),
    ("shift_arithmetic",                1),
    ("result_sel",              ResultSel),
    ("branch_target_sel", BranchTargetSel),
    ("branch_op",                BranchOp),
    ("mem_load",                        1),
    ("mem_store",                       1),
    ("mem_width",                MemWidth),
    ("mem_unsigned",                    1),
    ("mem_fault",                       1),
    ("wdata_sel",                WDataSel)
]

XM_LAYOUT = [
    ("pc_rdata",          32),
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
    ("result_sel", ResultSel),
    ("branch_target",     32),
    ("branch_misaligned",  1),
    ("branch_op",   BranchOp),
    ("mem_load",           1),
    ("mem_store",          1),
    ("mem_width",   MemWidth),
    ("mem_unsigned",       1),
    ("mem_fault",          1),
    ("wdata_sel",   WDataSel)
]

MW_LAYOUT = [
    ("pc_rdata",          32),
    ("pc_wdata",          32),
    ("insn",              32),
    ("rd",                 5),
    ("rd_wen",             1),
    ("rs1",                5),
    ("rs1_ren",            1),
    ("rs1_rdata",         32),
    ("rs2",                5),
    ("rs2_ren",            1),
    ("rs2_rdata",         32),
    ("result",            32),
    ("mem_load",           1),
    ("mem_store",          1),
    ("mem_rdata",         32),
    ("mem_addr_aligned",  32),
    ("mem_mask",           4),
    ("mem_rdata_aligned", 32),
    ("mem_wdata_aligned", 32),
    ("mem_fault",          1),
    ("wdata_sel",   WDataSel)
]
