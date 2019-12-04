from nmigen import *

from icicle.alu import ResultMux, BlackBoxResultMux
from icicle.branch import Branch
from icicle.loadstore import LoadStore
from icicle.pipeline import Stage
from icicle.pipeline_regs import XM_LAYOUT, MW_LAYOUT
from icicle.wishbone import WISHBONE_LAYOUT


class MemoryAccess(Stage):
    def __init__(self, rvfi_blackbox_alu=False):
        super().__init__(rdata_layout=XM_LAYOUT, wdata_layout=MW_LAYOUT)
        self.rvfi_blackbox_alu = rvfi_blackbox_alu
        self.branch_taken = Signal()
        self.branch_target = Signal(32)
        self.dbus = Record(WISHBONE_LAYOUT)

    def elaborate_stage(self, m, platform):
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
        self.trap_on(branch.taken & self.rdata.branch_misaligned)

        load_store = m.submodules.load_store = LoadStore()
        m.d.comb += [
            load_store.bus.connect(self.dbus),
            load_store.valid.eq(self.valid),
            load_store.load.eq(self.rdata.mem_load),
            load_store.store.eq(self.rdata.mem_store),
            load_store.width.eq(self.rdata.mem_width),
            load_store.unsigned.eq(self.rdata.mem_unsigned),
            load_store.addr.eq(self.rdata.add_result),
            load_store.wdata.eq(self.rdata.rs2_rdata)
        ]
        self.stall_on(load_store.busy)
        self.trap_on(load_store.trap)

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.result.eq(result_mux.result),
                self.wdata.mem_rdata.eq(load_store.rdata),
                self.wdata.mem_addr_aligned.eq(load_store.addr_aligned),
                self.wdata.mem_mask.eq(load_store.mask),
                self.wdata.mem_rdata_aligned.eq(load_store.rdata_aligned),
                self.wdata.mem_wdata_aligned.eq(load_store.wdata_aligned)
            ]

            with m.If(self.valid & branch.taken):
                m.d.sync += self.wdata.pc_wdata.eq(self.rdata.branch_target)
            with m.Else():
                m.d.sync += self.wdata.pc_wdata.eq(self.rdata.pc_wdata)
