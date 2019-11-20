from nmigen.hdl.ast import AnySeq

from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT, FD_LAYOUT


class Fetch(Stage):
    def __init__(self):
        super().__init__(rdata_layout=PF_LAYOUT, wdata_layout=FD_LAYOUT)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.pc.eq(self.rdata.pc),
                self.wdata.insn.eq(AnySeq(32))
            ]

        return m
