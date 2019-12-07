from nmigen import *

from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT


class PCGen(Stage):
    def __init__(self, reset_vector=0, trap_vector=0):
        super().__init__(wdata_layout=PF_LAYOUT)
        self.wdata.pc_rdata.reset = reset_vector - 4
        self.trap_vector = trap_vector
        self.branch_taken = Signal()
        self.branch_target = Signal(32)
        self.trap_raised = Signal()

    def elaborate_stage(self, m, platform):
        # XXX(gpe): it's impossible for stall to be set at the same time as
        # branch_taken or trap_raised. The PC generation stage never stalls
        # itself. The fetch stage is always flushed when branch_taken or
        # trap_raised is set. Flushes take precedence over stalls, so this
        # stage can't be stalled due to the next stage being stalled, provided
        # branch_taken or trap_raised is set.
        #
        # This allows us to optimise branches/traps slightly: we can write
        # directly to wdata.pc_rdata, instead of writing to a separate register
        # and then copying to wdata.pc_rdata in the ~self.stall case.
        with m.If(self.branch_taken):
            m.d.sync += [
                self.wdata.pc_rdata.eq(self.branch_target),
                self.wdata.intr.eq(0)
            ]
        with m.Elif(self.trap_raised):
            m.d.sync += [
                self.wdata.pc_rdata.eq(self.trap_vector),
                self.wdata.intr.eq(1)
            ]
        with m.Elif(~self.stall):
            m.d.sync += [
                self.wdata.pc_rdata.eq(self.wdata.pc_rdata + 4),
                self.wdata.intr.eq(0)
            ]
