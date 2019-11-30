from nmigen import *

from icicle.alu import ASel, BSel, ResultSel
from icicle.branch import BranchTargetSel, BranchOp
from icicle.loadstore import MemWidth
from icicle.logic import LogicOp
from icicle.riscv import Format, Opcode, Funct3, Funct7
from icicle.wdata import WDataSel


class Control(Elaboratable):
    def __init__(self):
        self.insn = Signal(32)
        self.rd = Signal(5)
        self.rd_wen = Signal()
        self.rs1 = Signal(5)
        self.rs1_ren = Signal()
        self.rs2 = Signal(5)
        self.rs2_ren = Signal()
        self.fmt = Signal(Format)
        self.a_sel = Signal(ASel)
        self.b_sel = Signal(BSel)
        self.add_sub = Signal()
        self.add_signed_compare = Signal()
        self.logic_op = Signal(LogicOp)
        self.shift_right = Signal()
        self.shift_arithmetic = Signal()
        self.result_sel = Signal(ResultSel)
        self.branch_target_sel = Signal(BranchTargetSel)
        self.branch_op = Signal(BranchOp)
        self.mem_load = Signal()
        self.mem_store = Signal()
        self.mem_width = Signal(MemWidth)
        self.mem_unsigned = Signal()
        self.wdata_sel = Signal(WDataSel)
        self.illegal = Signal()

    def elaborate(self, platform):
        m = Module()

        opcode = Signal(7)
        funct3 = Signal(3)
        funct7 = Signal(7)
        m.d.comb += Cat(opcode, self.rd, funct3, self.rs1, self.rs2, funct7).eq(self.insn)

        funct12 = Signal(12)
        m.d.comb += funct12.eq(Cat(self.rs2, funct7))

        with m.Switch(opcode):
            with m.Case(Opcode.LUI):
                m.d.comb += self.fmt.eq(Format.U)
            with m.Case(Opcode.AUIPC):
                m.d.comb += self.fmt.eq(Format.U)
            with m.Case(Opcode.JAL):
                m.d.comb += self.fmt.eq(Format.J)
            with m.Case(Opcode.JALR):
                m.d.comb += self.fmt.eq(Format.I)
            with m.Case(Opcode.BRANCH):
                m.d.comb += self.fmt.eq(Format.B)
            with m.Case(Opcode.LOAD):
                m.d.comb += self.fmt.eq(Format.I)
            with m.Case(Opcode.STORE):
                m.d.comb += self.fmt.eq(Format.S)
            with m.Case(Opcode.OP_IMM):
                m.d.comb += self.fmt.eq(Format.I)
            with m.Case(Opcode.OP):
                m.d.comb += self.fmt.eq(Format.R)
            with m.Case(Opcode.MISC_MEM):
                m.d.comb += self.fmt.eq(Format.I)
            with m.Case(Opcode.SYSTEM):
                m.d.comb += self.fmt.eq(Format.I)

        # XXX(gpe): if more MISC-MEM functions are added in the future,
        # might need to restrict this to only FENCE and FENCE_I.
        fence = Signal()
        m.d.comb += fence.eq(opcode == Opcode.MISC_MEM)

        zimm = Signal()
        m.d.comb += zimm.eq((opcode == Opcode.SYSTEM) & funct3.matches(Funct3.CSRRWI, Funct3.CSRRSI, Funct3.CSRRCI))

        m.d.comb += [
            self.rd_wen.eq(self.rd.bool() & self.fmt.matches(Format.R, Format.I, Format.U, Format.J) & ~fence),
            self.rs1_ren.eq(self.rs1.bool() & self.fmt.matches(Format.R, Format.I, Format.S, Format.B) & ~(fence | zimm)),
            self.rs2_ren.eq(self.rs2.bool() & self.fmt.matches(Format.R, Format.S, Format.B))
        ]

        with m.Switch(opcode):
            with m.Case(Opcode.LUI):
                m.d.comb += [
                    self.a_sel.eq(ASel.ZERO),
                    self.b_sel.eq(BSel.IMM),
                    self.result_sel.eq(ResultSel.ADDER)
                ]

            with m.Case(Opcode.AUIPC):
                m.d.comb += [
                    self.a_sel.eq(ASel.PC),
                    self.b_sel.eq(BSel.IMM),
                    self.result_sel.eq(ResultSel.ADDER)
                ]

            with m.Case(Opcode.JAL):
                m.d.comb += [
                    self.a_sel.eq(ASel.PC),
                    self.b_sel.eq(BSel.FOUR),
                    self.result_sel.eq(ResultSel.ADDER),
                    self.branch_target_sel.eq(BranchTargetSel.PC),
                    self.branch_op.eq(BranchOp.ALWAYS)
                ]

            with m.Case(Opcode.JALR):
                m.d.comb += [
                    self.a_sel.eq(ASel.PC),
                    self.b_sel.eq(BSel.FOUR),
                    self.result_sel.eq(ResultSel.ADDER),
                    self.branch_target_sel.eq(BranchTargetSel.RS1),
                    self.branch_op.eq(BranchOp.ALWAYS)
                ]

                with m.If(funct3 != Funct3.ZERO):
                    m.d.comb += self.illegal.eq(1)

            with m.Case(Opcode.BRANCH):
                m.d.comb += [
                    self.a_sel.eq(ASel.RS1),
                    self.b_sel.eq(BSel.RS2),
                    self.result_sel.eq(ResultSel.ADDER),
                    self.add_sub.eq(1),
                    self.add_signed_compare.eq(~funct3[1]),
                    self.branch_target_sel.eq(BranchTargetSel.PC)
                ]

                with m.Switch(funct3):
                    with m.Case(Funct3.BEQ):
                        m.d.comb += self.branch_op.eq(BranchOp.EQ)
                    with m.Case(Funct3.BNE):
                        m.d.comb += self.branch_op.eq(BranchOp.NE)
                    with m.Case(Funct3.BLT, Funct3.BLTU):
                        m.d.comb += self.branch_op.eq(BranchOp.LT)
                    with m.Case(Funct3.BGE, Funct3.BGEU):
                        m.d.comb += self.branch_op.eq(BranchOp.GE)
                    with m.Default():
                        m.d.comb += self.illegal.eq(1)

            with m.Case(Opcode.LOAD):
                m.d.comb += [
                    self.a_sel.eq(ASel.RS1),
                    self.b_sel.eq(BSel.IMM),
                    self.mem_load.eq(1),
                    self.wdata_sel.eq(WDataSel.MEM_RDATA)
                ]
                # XXX(gpe): we set mem_width and mem_unsigned below as their
                # encoding was chosen to match funct3 exactly.

                with m.If(~funct3.matches(Funct3.LB, Funct3.LH, Funct3.LW, Funct3.LBU, Funct3.LHU)):
                    m.d.comb += self.illegal.eq(1)

            with m.Case(Opcode.STORE):
                m.d.comb += [
                    self.a_sel.eq(ASel.RS1),
                    self.b_sel.eq(BSel.IMM),
                    self.mem_store.eq(1)
                ]
                # XXX(gpe): we set mem_width and mem_unsigned below as its
                # encoding was chosen to match funct3 exactly.

                with m.If(~funct3.matches(Funct3.SB, Funct3.SH, Funct3.SW)):
                    m.d.comb += self.illegal.eq(1)

            with m.Case(Opcode.OP_IMM, Opcode.OP):
                m.d.comb += [
                    self.a_sel.eq(ASel.RS1),
                    self.b_sel.eq(Mux(opcode == Opcode.OP, BSel.RS2, BSel.IMM))
                ]

                with m.Switch(funct3):
                    with m.Case(Funct3.ADD_SUB):
                        m.d.comb += [
                            self.result_sel.eq(ResultSel.ADDER),
                            self.add_sub.eq(Mux(opcode == Opcode.OP, funct7[5], 0)),
                            self.illegal.eq((opcode == Opcode.OP) & ~funct7.matches(Funct7.ZERO, Funct7.SUB_SRA))
                        ]
                    with m.Case(Funct3.SLT, Funct3.SLTU):
                        m.d.comb += [
                            self.result_sel.eq(ResultSel.SLT),
                            self.add_sub.eq(1),
                            self.add_signed_compare.eq(funct3 == Funct3.SLT),
                            self.illegal.eq((opcode == Opcode.OP) & (funct7 != Funct7.ZERO))
                        ]
                    with m.Case(Funct3.XOR, Funct3.OR, Funct3.AND):
                        m.d.comb += [
                            self.result_sel.eq(ResultSel.LOGIC),
                            self.illegal.eq((opcode == Opcode.OP) & (funct7 != Funct7.ZERO))
                        ]
                        # XXX(gpe): we set logic_op unconditionally below, as
                        # its encoding was chosen to always match funct3[0:2].
                        # If nMigen adds support for "don't care" bits we could
                        # tidy this up.
                    with m.Case(Funct3.SLL, Funct3.SRL_SRA):
                        m.d.comb += [
                            self.result_sel.eq(ResultSel.SHIFT),
                            self.illegal.eq(~funct7.matches(Funct7.ZERO, Funct7.SUB_SRA))
                        ]
                        # XXX(gpe): we set shift_right and shift_arithmetic
                        # below as they always occupy the same bits in funct3
                        # and funct7. As above, this could be tidied up with
                        # "don't care" bits.

            with m.Default():
                m.d.comb += self.illegal.eq(1)

        m.d.comb += [
            self.logic_op.eq(funct3[0:2]),
            self.shift_right.eq(funct3[2]),
            self.shift_arithmetic.eq(funct7[5]),
            self.mem_width.eq(funct3[0:2]),
            self.mem_unsigned.eq(funct3[2])
        ]

        return m
