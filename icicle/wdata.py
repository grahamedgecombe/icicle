from enum import Enum

from nmigen import *


class WDataSel(Enum):
    ALU_RESULT = 0
    MEM_RDATA  = 1


class WDataMux(Elaboratable):
    def __init__(self):
        self.sel = Signal(WDataSel)
        self.result = Signal(32)
        self.mem_rdata = Signal(32)
        self.rd_wdata = Signal(32)

    def elaborate(self, platform):
        m = Module()

        with m.Switch(self.sel):
            with m.Case(WDataSel.ALU_RESULT):
                m.d.comb += self.rd_wdata.eq(self.result)
            with m.Case(WDataSel.MEM_RDATA):
                m.d.comb += self.rd_wdata.eq(self.mem_rdata)

        return m
