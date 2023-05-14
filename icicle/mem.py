from amaranth import *
from amaranth_soc.wishbone import Interface

from icicle.alu import ResultMux, BlackBoxResultMux
from icicle.branch import Branch
from icicle.loadstore import LoadStore
from icicle.pipeline import Stage, State
from icicle.pipeline_regs import XM_LAYOUT, MW_LAYOUT


class MemoryAccess(Stage):
    def __init__(self, trap_vector=0, rvfi_blackbox_alu=False):
        super().__init__(i_layout=XM_LAYOUT, o_layout=MW_LAYOUT)
        self.trap_vector = trap_vector
        self.rvfi_blackbox_alu = rvfi_blackbox_alu
        self.branch_taken = Signal()
        self.branch_target = Signal(32)
        self.trap_raised = Signal()
        self.dbus = Interface(addr_width=30, data_width=32, granularity=8, features=["err"])

    def elaborate_stage(self, m, platform):
        result_mux = m.submodules.result_mux = BlackBoxResultMux() if self.rvfi_blackbox_alu else ResultMux()
        m.d.comb += [
            result_mux.sel.eq(self.i.result_sel),
            result_mux.add_result.eq(self.i.add_result),
            result_mux.add_carry.eq(self.i.add_carry),
            result_mux.logic_result.eq(self.i.logic_result),
            result_mux.shift_result.eq(self.i.shift_result)
        ]

        branch = m.submodules.branch = Branch()
        m.d.comb += [
            branch.op.eq(self.i.branch_op),
            branch.add_result.eq(self.i.add_result),
            branch.add_carry.eq(self.i.add_carry),
            branch.misaligned.eq(self.i.branch_misaligned)
        ]
        self.trap_on(branch.trap)

        m.d.comb += [
            self.branch_taken.eq(~self.stall & (self.i.state == State.VALID) & branch.taken),
            self.branch_target.eq(self.i.branch_target)
        ]

        load_store = m.submodules.load_store = LoadStore()
        m.d.comb += [
            load_store.bus.connect(self.dbus),
            load_store.valid.eq(self.i.state == State.VALID),
            load_store.load.eq(self.i.mem_load),
            load_store.store.eq(self.i.mem_store),
            load_store.width.eq(self.i.mem_width),
            load_store.unsigned.eq(self.i.mem_unsigned),
            load_store.addr.eq(self.i.add_result),
            load_store.wdata.eq(self.i.rs2_rdata)
        ]
        self.stall_on(load_store.busy)
        self.trap_on(load_store.trap)

        m.d.comb += self.trap_raised.eq(~self.stall & self.trap)

        with m.If(~self.stall):
            m.d.sync += [
                self.o.result.eq(result_mux.result),
                self.o.mem_rdata.eq(load_store.rdata),
                self.o.mem_addr_aligned.eq(load_store.addr_aligned),
                self.o.mem_mask.eq(load_store.mask),
                self.o.mem_rdata_aligned.eq(load_store.rdata_aligned),
                self.o.mem_wdata_aligned.eq(load_store.wdata_aligned),
                self.o.mem_fault.eq(self.i.mem_fault | load_store.trap)
            ]

            with m.If((self.i.state == State.VALID) & branch.taken):
                m.d.sync += self.o.pc_wdata.eq(self.i.branch_target)
            with m.Elif(self.trap):
                m.d.sync += self.o.pc_wdata.eq(self.trap_vector)
            with m.Else():
                m.d.sync += self.o.pc_wdata.eq(self.i.pc_rdata + 4)
