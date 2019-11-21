from nmigen import *


class BarrelShifter(Elaboratable):
    def __init__(self):
        self.left = Signal()
        self.sign_extend = Signal()
        self.a = Signal(32)
        self.shamt = Signal(5)
        self.result = Signal(32)

    def elaborate(self, platform):
        m = Module()

        # reverse input of left shifts
        a_reverse = Signal(32)
        m.d.comb += a_reverse.eq(Mux(self.left, self.a[::-1], self.a))

        # shift right
        result_reverse = Signal(32)
        m.d.comb += result_reverse.eq(Cat(a_reverse, Mux(self.sign_extend, a_reverse[31], 0)) >> self.shamt)

        # reverse output of left shifts
        m.d.comb += self.result.eq(Mux(self.left, result_reverse[::-1], result_reverse))

        return m
