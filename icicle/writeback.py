from nmigen import *

from icicle.pipeline import Stage
from icicle.pipeline_regs import MW_LAYOUT
from icicle.regs import REG_FILE_PORT_LAYOUT
from icicle.rvfi import RVFI_LAYOUT


class Writeback(Stage):
    def __init__(self):
        super().__init__(rdata_layout=MW_LAYOUT)
        self.rd_port = Record(REG_FILE_PORT_LAYOUT)
        self.rvfi = Record(RVFI_LAYOUT)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        m.d.comb += [
            self.rd_port.en.eq(~self.stall & self.valid & self.rdata.rd_wen),
            self.rd_port.addr.eq(self.rdata.rd),
            self.rd_port.data.eq(self.rdata.rd_wdata)
        ]

        with m.If(~self.stall & self.valid):
            m.d.sync += [
                self.rvfi.valid.eq(1),
                self.rvfi.order.eq(self.rvfi.order + 1),
                self.rvfi.insn.eq(self.rdata.insn),
                self.rvfi.trap.eq(0),
                self.rvfi.halt.eq(0),
                self.rvfi.intr.eq(0),
                self.rvfi.mode.eq(3),
                self.rvfi.ixl.eq(1),
                self.rvfi.rs1_addr.eq(Mux(self.rdata.rs1_ren, self.rdata.rs1, 0)),
                self.rvfi.rs2_addr.eq(Mux(self.rdata.rs2_ren, self.rdata.rs2, 0)),
                self.rvfi.rs1_rdata.eq(Mux(self.rdata.rs1_ren, self.rdata.rs1_rdata, 0)),
                self.rvfi.rs2_rdata.eq(Mux(self.rdata.rs2_ren, self.rdata.rs2_rdata, 0)),
                self.rvfi.rd_addr.eq(Mux(self.rdata.rd_wen, self.rdata.rd, 0)),
                self.rvfi.rd_wdata.eq(Mux(self.rdata.rd_wen, self.rdata.rd_wdata, 0)),
                self.rvfi.pc_rdata.eq(self.rdata.pc),
                self.rvfi.pc_wdata.eq(0),
                self.rvfi.mem_addr.eq(0),
                self.rvfi.mem_rmask.eq(0),
                self.rvfi.mem_wmask.eq(0),
                self.rvfi.mem_rdata.eq(0),
                self.rvfi.mem_wdata.eq(0)
            ]
        with m.Else():
            m.d.sync += self.rvfi.valid.eq(0)

        return m
