from nmigen import *


class PCMux(Elaboratable):
    def __init__(self):
        self.pc_rdata = Signal(32)
        self.branch_taken = Signal()
        self.branch_target = Signal(32)
        self.pc = Signal(32)

    def elaborate(self, platform):
        m = Module()

        with m.If(self.branch_taken):
            m.d.comb += self.pc.eq(self.branch_target)
        with m.Else():
            m.d.comb += self.pc.eq(self.pc_rdata + 4)

        return m
