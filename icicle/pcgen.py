from nmigen import *

from icicle.pc import PCMux
from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT


class PCGen(Stage):
    def __init__(self, reset_vector):
        super().__init__(wdata_layout=PF_LAYOUT)
        self.wdata.pc_rdata.reset = reset_vector - 4
        self.branch_taken = Signal()
        self.branch_target = Signal(32)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        pc_mux = m.submodules.pc_mux = PCMux()
        m.d.comb += [
            pc_mux.pc_rdata.eq(self.wdata.pc_rdata),
            pc_mux.branch_taken.eq(self.branch_taken),
            pc_mux.branch_target.eq(self.branch_target)
        ]

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.pc_rdata.eq(pc_mux.pc),
                self.wdata.pc_wdata.eq(pc_mux.pc + 4)
            ]

        return m
