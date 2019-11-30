from nmigen import *

from icicle.wishbone import WISHBONE_LAYOUT


class GPIO(Elaboratable):
    def __init__(self):
        self.bus = Record(WISHBONE_LAYOUT)

    def elaborate(self, platform):
        m = Module()

        led = platform.request("led", 0)

        with m.If(self.bus.cyc & self.bus.stb):
            with m.If(self.bus.we):
                m.d.sync += led.o.eq(self.bus.dat_w[0])
            with m.Else():
                m.d.comb += self.bus.dat_r.eq(led.o)

            m.d.comb += self.bus.ack.eq(1)

        return m
