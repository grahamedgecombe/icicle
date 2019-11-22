from enum import Enum

from nmigen import *


class BranchTargetSel(Enum):
    PC  = 0
    RS1 = 1


class BranchTargetMux(Elaboratable):
    def __init__(self):
        self.sel = Signal(BranchTargetSel)
        self.pc = Signal(32)
        self.rs1_rdata = Signal(32)
        self.imm = Signal(32)
        self.target = Signal(32)
        self.misaligned = Signal()

    def elaborate(self, platform):
        m = Module()

        target = Signal(32)
        m.d.comb += target.eq(Mux(self.sel == BranchTargetSel.PC, self.pc, self.rs1_rdata) + self.imm)

        m.d.comb += [
            self.target.eq(Cat(C(0, 1), target[1:32])),
            self.misaligned.eq(target[1])
        ]

        return m


class BranchOp(Enum):
    NEVER  = 0
    ALWAYS = 1
    EQ     = 2
    NE     = 3
    LT     = 4
    GE     = 5


class Branch(Elaboratable):
    def __init__(self):
        self.op = Signal(BranchOp)
        self.add_result = Signal(32)
        self.add_carry = Signal()
        self.taken = Signal()

    def elaborate(self, platform):
        m = Module()

        zero = Signal()
        m.d.comb += zero.eq(self.add_result == 0)

        with m.Switch(self.op):
            with m.Case(BranchOp.NEVER):
                m.d.comb += self.taken.eq(0)
            with m.Case(BranchOp.ALWAYS):
                m.d.comb += self.taken.eq(1)
            with m.Case(BranchOp.EQ):
                m.d.comb += self.taken.eq(zero)
            with m.Case(BranchOp.NE):
                m.d.comb += self.taken.eq(~zero)
            with m.Case(BranchOp.LT):
                m.d.comb += self.taken.eq(self.add_carry)
            with m.Case(BranchOp.GE):
                m.d.comb += self.taken.eq(~self.add_carry)

        return m
