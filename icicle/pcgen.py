from nmigen import *

from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT


class PCGen(Stage):
    def __init__(self, reset_vector=0, trap_vector=0):
        super().__init__(wdata_layout=PF_LAYOUT)
        self.reset_vector = reset_vector
        self.trap_vector = trap_vector
        self.branch_taken = Signal()
        self.branch_target = Signal(32)
        self.trap_raised = Signal()

    def elaborate_stage(self, m, platform):
        pc = Signal(32, reset=self.reset_vector)
        intr = Signal()

        pc_rdata = Signal(32)
        intr_rdata = Signal()
        with m.If(self.branch_taken):
            m.d.comb += [
                pc_rdata.eq(self.branch_target),
                intr_rdata.eq(0)
            ]
        with m.Elif(self.trap_raised):
            m.d.comb += [
                pc_rdata.eq(self.trap_vector),
                intr_rdata.eq(1)
            ]
        with m.Else():
            m.d.comb += [
                pc_rdata.eq(pc),
                intr_rdata.eq(intr)
            ]

        pc_wdata = Signal(32)
        intr_wdata = Signal()
        m.d.comb += [
            pc_wdata.eq(Mux(self.stall, pc_rdata, pc_rdata + 4)),
            intr_wdata.eq(Mux(self.stall, intr_rdata, 0))
        ]
        m.d.sync += [
            pc.eq(pc_wdata),
            intr.eq(intr_wdata)
        ]

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.pc_rdata.eq(pc_rdata),
                self.wdata.pc_wdata.eq(pc_wdata),
                self.wdata.intr.eq(intr_rdata)
            ]
