from nmigen import *

from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT


class PCGen(Stage):
    def __init__(self, reset_vector):
        super().__init__(wdata_layout=PF_LAYOUT)
        self.reset_vector = reset_vector
        self.branch_taken = Signal()
        self.branch_target = Signal(32)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        pc = Signal(32, reset=self.reset_vector)

        pc_rdata = Signal(32)
        with m.If(self.branch_taken):
            m.d.comb += pc_rdata.eq(self.branch_target)
        with m.Else():
            m.d.comb += pc_rdata.eq(pc)

        pc_wdata = Signal(32)
        m.d.comb += pc_wdata.eq(Mux(self.stall, pc_rdata, pc_rdata + 4))
        m.d.sync += pc.eq(pc_wdata)

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.pc_rdata.eq(pc_rdata),
                self.wdata.pc_wdata.eq(pc_wdata)
            ]

        return m
