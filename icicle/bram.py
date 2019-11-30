from nmigen import *

from icicle.wishbone import WISHBONE_LAYOUT


class BlockRAM(Elaboratable):
    def __init__(self, depth, init=None):
        self.depth = depth
        self.init = init
        self.bus = Record(WISHBONE_LAYOUT)

    def elaborate(self, platform):
        m = Module()

        mem = Memory(width=32, depth=self.depth, init=self.init)

        read_port = m.submodules.read_port = mem.read_port(transparent=False)
        m.d.comb += [
            read_port.en.eq(1),
            read_port.addr.eq(self.bus.adr),
            self.bus.dat_r.eq(read_port.data)
        ]

        write_port = m.submodules.write_port = mem.write_port(granularity=8)
        m.d.comb += [
            write_port.en.eq(self.bus.sel & Repl(self.bus.cyc & self.bus.stb & ~self.bus.ack & self.bus.we, 4)),
            write_port.addr.eq(self.bus.adr),
            write_port.data.eq(self.bus.dat_w)
        ]

        m.d.sync += self.bus.ack.eq(self.bus.cyc & self.bus.stb & ~self.bus.ack)

        return m
