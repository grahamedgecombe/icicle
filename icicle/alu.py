from enum import Enum

from nmigen import *


class ASrc(Enum):
    RS1 = 0


class BSrc(Enum):
    RS2 = 0
    IMM = 1


class SrcMux(Elaboratable):
    def __init__(self):
        self.a_src = Signal(ASrc)
        self.b_src = Signal(BSrc)
        self.rs1_rdata = Signal(32)
        self.rs2_rdata = Signal(32)
        self.imm = Signal(32)
        self.a = Signal(32)
        self.b = Signal(32)

    def elaborate(self, platform):
        m = Module()

        with m.Switch(self.a_src):
            with m.Case(ASrc.RS1):
                m.d.comb += self.a.eq(self.rs1_rdata)

        with m.Switch(self.b_src):
            with m.Case(BSrc.RS2):
                m.d.comb += self.b.eq(self.rs2_rdata)
            with m.Case(BSrc.IMM):
                m.d.comb += self.b.eq(self.imm)

        return m
