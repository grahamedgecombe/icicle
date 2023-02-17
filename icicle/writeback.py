from amaranth import *

from icicle.pipeline import Stage
from icicle.pipeline_regs import MW_LAYOUT
from icicle.regs import RD_PORT_LAYOUT
from icicle.rvfi import RVFI_LAYOUT
from icicle.wdata import WDataMux


class Writeback(Stage):
    def __init__(self):
        super().__init__(i_layout=MW_LAYOUT)
        self.rd_port = Record(RD_PORT_LAYOUT)
        self.rvfi = Record(RVFI_LAYOUT)

    def elaborate_stage(self, m, platform):
        wdata_mux = m.submodules.wdata_mux = WDataMux()
        m.d.comb += [
            wdata_mux.sel.eq(self.i.wdata_sel),
            wdata_mux.result.eq(self.i.result),
            wdata_mux.mem_rdata.eq(self.i.mem_rdata)
        ]

        m.d.comb += [
            self.rd_port.en.eq(~self.stall & self.insn_valid & self.i.rd_wen),
            self.rd_port.addr.eq(self.i.rd),
            self.rd_port.data.eq(wdata_mux.rd_wdata)
        ]

        with m.If(~self.stall & (self.insn_valid | self.trapped)):
            m.d.sync += [
                self.rvfi.valid.eq(1),
                self.rvfi.order.eq(self.rvfi.order + 1),
                self.rvfi.insn.eq(self.i.insn),
                self.rvfi.trap.eq(self.trapped),
                self.rvfi.halt.eq(0),
                self.rvfi.intr.eq(0),
                self.rvfi.mode.eq(3),
                self.rvfi.ixl.eq(1),
                self.rvfi.rs1_addr.eq(Mux(self.i.rs1_ren, self.i.rs1, 0)),
                self.rvfi.rs2_addr.eq(Mux(self.i.rs2_ren, self.i.rs2, 0)),
                self.rvfi.rs1_rdata.eq(Mux(self.i.rs1_ren, self.i.rs1_rdata, 0)),
                self.rvfi.rs2_rdata.eq(Mux(self.i.rs2_ren, self.i.rs2_rdata, 0)),
                self.rvfi.rd_addr.eq(Mux(self.insn_valid & self.i.rd_wen, self.i.rd, 0)),
                self.rvfi.rd_wdata.eq(Mux(self.insn_valid & self.i.rd_wen, wdata_mux.rd_wdata, 0)),
                self.rvfi.pc_rdata.eq(self.i.pc_rdata),
                self.rvfi.pc_wdata.eq(self.i.pc_wdata),
                self.rvfi.mem_addr.eq(Mux(self.insn_valid & (self.i.mem_load | self.i.mem_store), self.i.mem_addr_aligned, 0)),
                self.rvfi.mem_rmask.eq(Mux(self.insn_valid & self.i.mem_load, self.i.mem_mask, 0)),
                self.rvfi.mem_wmask.eq(Mux(self.insn_valid & self.i.mem_store, self.i.mem_mask, 0)),
                self.rvfi.mem_rdata.eq(Mux(self.insn_valid & self.i.mem_load, self.i.mem_rdata_aligned, 0)),
                self.rvfi.mem_wdata.eq(Mux(self.insn_valid & self.i.mem_store, self.i.mem_wdata_aligned, 0))
            ]
        with m.Else():
            m.d.sync += self.rvfi.valid.eq(0)
