from amaranth import *
from amaranth_soc.wishbone import Interface

from icicle.loadstore import LoadStore, MemWidth
from icicle.pipeline import Stage, State
from icicle.pipeline_regs import PF_LAYOUT, FD_LAYOUT


class Fetch(Stage):
    def __init__(self):
        super().__init__(i_layout=PF_LAYOUT, o_layout=FD_LAYOUT)
        self.ibus = Interface(addr_width=30, data_width=32, granularity=8, features=["err"])

    def elaborate_stage(self, m, platform):
        load_store = m.submodules.load_store = LoadStore()
        m.d.comb += [
            load_store.bus.connect(self.ibus),
            load_store.valid.eq((self.i.state == State.VALID) & ~self.flush),
            load_store.load.eq(1),
            load_store.width.eq(MemWidth.WORD),
            load_store.addr.eq(self.i.pc_rdata)
        ]
        self.stall_on(load_store.busy)
        self.trap_on(load_store.trap)

        with m.If(~self.stall):
            m.d.sync += [
                self.o.insn.eq(Mux(load_store.trap, 0, load_store.rdata)),
                self.o.mem_fault.eq(load_store.trap)
            ]
