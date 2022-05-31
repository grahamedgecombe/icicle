from amaranth import *
from amaranth.hdl.ast import AnySeq


class Adder(Elaboratable):
    def __init__(self):
        self.sub = Signal()
        self.signed_compare = Signal()
        self.a = Signal(32)
        self.b = Signal(32)
        self.result = Signal(32)
        self.carry = Signal()

    def elaborate(self, platform):
        m = Module()

        # invert MSB to perform a signed comparison
        # (see https://twitter.com/brouhaha/status/1058381092481159169)
        a = Signal(32)
        b = Signal(32)
        m.d.comb += [
            a.eq(Cat(self.a[0:31], self.signed_compare ^ self.a[31])),
            b.eq(Cat(self.b[0:31], self.signed_compare ^ self.b[31]))
        ]

        m.d.comb += Cat(self.result, self.carry).eq(Mux(self.sub, a - b, a + b))

        return m


class BlackBoxAdder(Elaboratable):
    def __init__(self):
        self.sub = Signal()
        self.signed_compare = Signal()
        self.a = Signal(32)
        self.b = Signal(32)
        self.result = Signal(32)
        self.carry = Signal()

    def elaborate(self, platform):
        m = Module()

        m.d.comb += [
            self.result.eq(AnySeq(32)),
            self.carry.eq(AnySeq(1))
        ]

        return m
