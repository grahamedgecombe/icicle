from nmigen import *
from nmigen.hdl.rec import *

WISHBONE_LAYOUT = [
    ("adr",   30, DIR_FANOUT),
    ("dat_w", 32, DIR_FANOUT),
    ("dat_r", 32, DIR_FANIN),
    ("sel",    4, DIR_FANOUT),
    ("cyc",    1, DIR_FANOUT),
    ("stb",    1, DIR_FANOUT),
    ("we",     1, DIR_FANOUT),
    ("ack",    1, DIR_FANIN),
    ("err",    1, DIR_FANIN)
]


class AddrDecoder(Elaboratable):
    def __init__(self, slaves):
        self.master = Record(WISHBONE_LAYOUT)
        self.slaves = slaves

    def elaborate(self, platform):
        m = Module()

        # fault if none of the slaves are selected below
        m.d.comb += self.master.err.eq(1)

        for (addr, slave) in self.slaves:
            select = self.master.adr.matches(addr)

            # fan-in
            with m.If(select):
                m.d.comb += [
                    self.master.dat_r.eq(slave.dat_r),
                    self.master.ack.eq(slave.ack),
                    self.master.err.eq(slave.err)
                ]

            # fan-out
            m.d.comb += [
                slave.adr.eq(self.master.adr),
                slave.dat_w.eq(self.master.dat_w),
                slave.sel.eq(self.master.sel),
                slave.cyc.eq(self.master.cyc & select),
                slave.stb.eq(self.master.stb & select),
                slave.we.eq(self.master.we)
            ]

        return m
