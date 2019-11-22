from enum import Enum

from nmigen import *
from nmigen.hdl.ast import AnySeq


class ASel(Enum):
    RS1  = 0
    PC   = 1
    ZERO = 2


class BSel(Enum):
    RS2  = 0
    IMM  = 1
    FOUR = 2


class OperandMux(Elaboratable):
    def __init__(self):
        self.a_sel = Signal(ASel)
        self.b_sel = Signal(BSel)
        self.pc = Signal(32)
        self.rs1_rdata = Signal(32)
        self.rs2_rdata = Signal(32)
        self.imm = Signal(32)
        self.a = Signal(32)
        self.b = Signal(32)

    def elaborate(self, platform):
        m = Module()

        with m.Switch(self.a_sel):
            with m.Case(ASel.RS1):
                m.d.comb += self.a.eq(self.rs1_rdata)
            with m.Case(ASel.PC):
                m.d.comb += self.a.eq(self.pc)
            with m.Case(ASel.ZERO):
                m.d.comb += self.a.eq(0)

        with m.Switch(self.b_sel):
            with m.Case(BSel.RS2):
                m.d.comb += self.b.eq(self.rs2_rdata)
            with m.Case(BSel.IMM):
                m.d.comb += self.b.eq(self.imm)
            with m.Case(BSel.FOUR):
                m.d.comb += self.b.eq(4)

        return m


class ResultSel(Enum):
    ADDER = 0
    SLT   = 1
    LOGIC = 2
    SHIFT = 3


class ResultMux(Elaboratable):
    def __init__(self):
        self.sel = Signal(ResultSel)
        self.add_result = Signal(32)
        self.add_carry = Signal()
        self.logic_result = Signal(32)
        self.shift_result = Signal(32)
        self.result = Signal(32)

    def elaborate(self, platform):
        m = Module()

        with m.Switch(self.sel):
            with m.Case(ResultSel.ADDER):
                m.d.comb += self.result.eq(self.add_result)
            with m.Case(ResultSel.SLT):
                m.d.comb += self.result.eq(self.add_carry)
            with m.Case(ResultSel.LOGIC):
                m.d.comb += self.result.eq(self.logic_result)
            with m.Case(ResultSel.SHIFT):
                m.d.comb += self.result.eq(self.shift_result)

        return m


class BlackBoxResultMux(Elaboratable):
    def __init__(self):
        self.sel = Signal(ResultSel)
        self.add_result = Signal(32)
        self.add_carry = Signal()
        self.logic_result = Signal(32)
        self.shift_result = Signal(32)
        self.result = Signal(32)

    def elaborate(self, platform):
        m = Module()

        m.d.comb += self.result.eq(AnySeq(32))

        return m
