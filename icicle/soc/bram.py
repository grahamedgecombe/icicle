from amaranth import *
from amaranth_soc.memory import MemoryMap
from amaranth_soc.wishbone import Interface


class BlockRAM(Elaboratable):
    def __init__(self, addr_width, init=None, read_only=False):
        self.depth = 2**addr_width
        self.init = init
        self.read_only = read_only

        features = ["err"] if read_only else []

        self.bus = Interface(addr_width=addr_width, data_width=32, granularity=8, features=features)
        memory_map = MemoryMap(addr_width=addr_width + 2, data_width=8)
        memory_map.add_resource(self, name="bram", size=2 ** memory_map.addr_width)
        self.bus.memory_map = memory_map

    def elaborate(self, platform):
        m = Module()

        mem = Memory(width=32, depth=self.depth, init=self.init)

        read_port = m.submodules.read_port = mem.read_port(transparent=False)
        m.d.comb += [
            read_port.en.eq(1),
            read_port.addr.eq(self.bus.adr),
            self.bus.dat_r.eq(read_port.data)
        ]

        valid = Signal()
        m.d.comb += valid.eq(self.bus.cyc & self.bus.stb & ~(self.bus.ack | self.bus.err))

        if self.read_only:
            m.d.sync += [
                self.bus.ack.eq(valid & ~self.bus.we),
                self.bus.err.eq(valid & self.bus.we),
            ]
        else:
            write_port = m.submodules.write_port = mem.write_port(granularity=8)
            m.d.comb += [
                write_port.en.eq(self.bus.sel & Repl(valid & self.bus.we, 4)),
                write_port.addr.eq(self.bus.adr),
                write_port.data.eq(self.bus.dat_w)
            ]

            m.d.sync += self.bus.ack.eq(valid)

        return m
