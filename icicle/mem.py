from nmigen import *

from icicle.alu import ResultMux, BlackBoxResultMux
from icicle.branch import Branch
from icicle.pipeline import Stage
from icicle.pipeline_regs import XM_LAYOUT, MW_LAYOUT


class MemoryAccess(Stage):
    def __init__(self, rvfi_blackbox_alu=False):
        super().__init__(rdata_layout=XM_LAYOUT, wdata_layout=MW_LAYOUT)
        self.rvfi_blackbox_alu = rvfi_blackbox_alu
        self.branch_taken = Signal()
        self.branch_target = Signal(32)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        result_mux = m.submodules.result_mux = BlackBoxResultMux() if self.rvfi_blackbox_alu else ResultMux()
        m.d.comb += [
            result_mux.sel.eq(self.rdata.result_sel),
            result_mux.add_result.eq(self.rdata.add_result),
            result_mux.add_carry.eq(self.rdata.add_carry),
            result_mux.logic_result.eq(self.rdata.logic_result),
            result_mux.shift_result.eq(self.rdata.shift_result)
        ]

        branch = m.submodules.branch = Branch()
        m.d.comb += [
            branch.op.eq(self.rdata.branch_op),
            branch.add_result.eq(self.rdata.add_result),
            branch.add_carry.eq(self.rdata.add_carry)
        ]

        m.d.comb += [
            self.branch_taken.eq(~self.stall & self.valid & branch.taken),
            self.branch_target.eq(self.rdata.branch_target)
        ]

        with m.If(~self.stall):
            m.d.sync += self.wdata.rd_wdata.eq(result_mux.result)

            with m.If(branch.taken):
                m.d.sync += [
                    self.wdata.trap.eq(self.rdata.branch_misaligned),
                    self.wdata.pc_wdata.eq(self.rdata.branch_target)
                ]
            with m.Else():
                m.d.sync += [
                    self.wdata.trap.eq(0),
                    self.wdata.pc_wdata.eq(self.rdata.pc_wdata)
                ]

        return m
