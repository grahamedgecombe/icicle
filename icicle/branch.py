from enum import Enum

from nmigen import *


class BranchTargetSrc(Enum):
    PC  = 0
    RS1 = 1


class BranchTarget(Elaboratable):
    def __init__(self):
        self.src = Signal(BranchTargetSrc)
        self.pc = Signal(32)
        self.rs1_rdata = Signal(32)
        self.imm = Signal(32)
        self.target = Signal(32)
        self.misaligned = Signal()

    def elaborate(self, platform):
        m = Module()

        target = Signal(32)
        m.d.comb += target.eq(Mux(self.src == BranchTargetSrc.PC, self.pc, self.rs1_rdata) + self.imm)

        m.d.comb += [
            self.target.eq(Cat(C(0, 1), target[1:32])),
            self.misaligned.eq(target[1])
        ]

        return m
