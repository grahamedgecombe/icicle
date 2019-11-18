from nmigen import *

from icicle.control import Control
from icicle.imm import ImmediateDecoder
from icicle.pipeline import Stage
from icicle.pipeline_regs import FD_LAYOUT, DX_LAYOUT
from icicle.regs import RS_PORT_LAYOUT


class Decode(Stage):
    def __init__(self):
        super().__init__(rdata_layout=FD_LAYOUT, wdata_layout=DX_LAYOUT)
        self.rs1_port = Record(RS_PORT_LAYOUT)
        self.rs2_port = Record(RS_PORT_LAYOUT)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        control = m.submodules.control = Control()
        m.d.comb += control.insn.eq(self.rdata.insn)

        imm_decoder = m.submodules.imm_decoder = ImmediateDecoder()
        m.d.comb += [
            imm_decoder.insn.eq(self.rdata.insn),
            imm_decoder.fmt.eq(control.fmt)
        ]

        m.d.comb += [
            self.rs1_port.en.eq(~self.stall),
            self.rs1_port.addr.eq(control.rs1),
            self.wdata.rs1_rdata.eq(self.rs1_port.data),

            self.rs2_port.en.eq(~self.stall),
            self.rs2_port.addr.eq(control.rs2),
            self.wdata.rs2_rdata.eq(self.rs2_port.data)
        ]

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.rd.eq(control.rd),
                self.wdata.rd_wen.eq(control.rd_wen),
                self.wdata.rs1.eq(control.rs1),
                self.wdata.rs1_ren.eq(control.rs1_ren),
                self.wdata.rs2.eq(control.rs2),
                self.wdata.rs2_ren.eq(control.rs2_ren),
                self.wdata.imm.eq(imm_decoder.imm)
            ]

        return m
