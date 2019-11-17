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
        a = Signal(32)
        m.d.comb += a.eq(Mux(self.left, self.a[::-1], self.a))

        # shift right
        result = Signal(32)
        m.d.comb += result.eq(Cat(a, Mux(self.sign_extend, a[31], 0)) >> self.shamt)

        # reverse output of left shifts
        m.d.comb += self.result.eq(Mux(self.left, result[::-1], result))

        return m
