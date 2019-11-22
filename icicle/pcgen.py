from nmigen import *

from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT


class PCGen(Stage):
    def __init__(self, reset_vector):
        super().__init__(wdata_layout=PF_LAYOUT)
        self.wdata.pc_rdata.reset = reset_vector - 4

    def elaborate(self, platform):
        m = super().elaborate(platform)

        pc = Signal(32)
        m.d.comb += pc.eq(self.wdata.pc_rdata + 4)

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.pc_rdata.eq(pc),
                self.wdata.pc_wdata.eq(pc + 4)
            ]

        return m
