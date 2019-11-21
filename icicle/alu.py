from enum import Enum

from nmigen import *
from nmigen.hdl.ast import AnySeq


class ASrc(Enum):
    RS1 = 0
    PC  = 1


class BSrc(Enum):
    RS2 = 0
    IMM = 1


class SrcMux(Elaboratable):
    def __init__(self):
        self.a_src = Signal(ASrc)
        self.b_src = Signal(BSrc)
        self.pc = Signal(32)
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
            with m.Case(ASrc.PC):
                m.d.comb += self.a.eq(self.pc)

        with m.Switch(self.b_src):
            with m.Case(BSrc.RS2):
                m.d.comb += self.b.eq(self.rs2_rdata)
            with m.Case(BSrc.IMM):
                m.d.comb += self.b.eq(self.imm)

        return m


class ResultSrc(Enum):
    ADDER = 0
    SLT   = 1
    LOGIC = 2
    SHIFT = 3


class ResultMux(Elaboratable):
    def __init__(self):
        self.src = Signal(ResultSrc)
        self.add_result = Signal(32)
        self.add_carry = Signal()
        self.logic_result = Signal(32)
        self.shift_result = Signal(32)
        self.result = Signal(32)

    def elaborate(self, platform):
        m = Module()

        with m.Switch(self.src):
            with m.Case(ResultSrc.ADDER):
                m.d.comb += self.result.eq(self.add_result)
            with m.Case(ResultSrc.SLT):
                m.d.comb += self.result.eq(self.add_carry)
            with m.Case(ResultSrc.LOGIC):
                m.d.comb += self.result.eq(self.logic_result)
            with m.Case(ResultSrc.SHIFT):
                m.d.comb += self.result.eq(self.shift_result)

        return m


class BlackBoxResultMux(Elaboratable):
    def __init__(self):
        self.src = Signal(ResultSrc)
        self.add_result = Signal(32)
        self.add_carry = Signal()
        self.logic_result = Signal(32)
        self.shift_result = Signal(32)
        self.result = Signal(32)

    def elaborate(self, platform):
        m = Module()

        m.d.comb += self.result.eq(AnySeq(32))

        return m
