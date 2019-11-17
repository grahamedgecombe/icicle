from enum import Enum

from nmigen import *


class LogicOp(Enum):
    XOR = 0
    OR  = 2 # skip 1 so these correspond with the lower two bits of funct3
    AND = 3


class Logic(Elaboratable):
    def __init__(self):
        self.op = Signal(LogicOp)
        self.a = Signal(32)
        self.b = Signal(32)
        self.result = Signal(32)

    def elaborate(self, platform):
        m = Module()

        with m.Switch(self.op):
            with m.Case(LogicOp.XOR):
                m.d.comb += self.result.eq(self.a ^ self.b)
            with m.Case(LogicOp.OR):
                m.d.comb += self.result.eq(self.a | self.b)
            with m.Case(LogicOp.AND):
                m.d.comb += self.result.eq(self.a & self.b)

        return m
