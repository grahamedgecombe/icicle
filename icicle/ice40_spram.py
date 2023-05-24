from amaranth import *
from amaranth_soc.memory import MemoryMap
from amaranth_soc.wishbone import Interface


class ICE40SPRAM(Elaboratable):
    def __init__(self):
        self.bus = Interface(addr_width=15, data_width=32, granularity=8)
        memory_map = MemoryMap(addr_width=17, data_width=8)
        memory_map.add_resource(self, name="spram", size=2 ** memory_map.addr_width)
        self.bus.memory_map = memory_map

    def elaborate(self, platform):
        m = Module()

        for i in range(2):  # depth cascade
            cs = Signal()
            m.d.comb += cs.eq(self.bus.adr[14] == i)

            for j in range(2):  # width cascade
                dat_slice = slice(j * 16, (j + 1) * 16)

                dat_r = Signal(16)
                with m.If(cs):
                    m.d.comb += self.bus.dat_r[dat_slice].eq(dat_r)

                m.submodules += Instance("SB_SPRAM256KA",
                    i_ADDRESS=self.bus.adr[0:14],
                    i_DATAIN=self.bus.dat_w[dat_slice],
                    i_MASKWREN=Cat(Repl(self.bus.sel[j * 2], 2), Repl(self.bus.sel[j * 2 + 1], 2)),
                    i_WREN=self.bus.cyc & self.bus.stb & ~self.bus.ack & self.bus.we,
                    i_CHIPSELECT=cs,
                    i_CLOCK=ClockSignal(),
                    i_STANDBY=0,
                    i_SLEEP=0,
                    i_POWEROFF=1,
                    o_DATAOUT=dat_r,
                )

        m.d.sync += self.bus.ack.eq(self.bus.cyc & self.bus.stb & ~self.bus.ack)

        return m
