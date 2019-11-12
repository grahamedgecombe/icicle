from icicle.control import Control
from icicle.pipeline import Stage
from icicle.pipeline_regs import FD_LAYOUT, DX_LAYOUT


class Decode(Stage):
    def __init__(self, regs):
        super().__init__(rdata_layout=FD_LAYOUT, wdata_layout=DX_LAYOUT)
        self.regs = regs

    def elaborate(self, platform):
        m = super().elaborate(platform)

        control = m.submodules.control = Control()

        m.d.comb += control.insn.eq(self.rdata.insn)

        rs1_port = m.submodules.rs1_port = self.regs.read_port(transparent=False)
        rs2_port = m.submodules.rs2_port = self.regs.read_port(transparent=False)

        m.d.comb += [
            rs1_port.en.eq(~self.stall),
            rs1_port.addr.eq(control.rs1),
            self.wdata.rs1_rdata.eq(rs1_port.data),

            rs2_port.en.eq(~self.stall),
            rs2_port.addr.eq(control.rs2),
            self.wdata.rs2_rdata.eq(rs2_port.data)
        ]

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.rd.eq(control.rd),
                self.wdata.rd_wen.eq(control.rd_wen),
                self.wdata.rs1.eq(control.rs1),
                self.wdata.rs1_ren.eq(control.rs1_ren),
                self.wdata.rs2.eq(control.rs2),
                self.wdata.rs2_ren.eq(control.rs2_ren)
            ]

        return m
