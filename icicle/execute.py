from icicle.pipeline import Stage
from icicle.pipeline_regs import DX_LAYOUT, XM_LAYOUT


class Execute(Stage):
    def __init__(self):
        super().__init__(rdata_layout=DX_LAYOUT, wdata_layout=XM_LAYOUT)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.pc.eq(self.rdata.pc),
                self.wdata.insn.eq(self.rdata.insn),
                self.wdata.rd.eq(self.rdata.rd),
                self.wdata.rd_wen.eq(self.rdata.rd_wen),
                self.wdata.rs1.eq(self.rdata.rs1),
                self.wdata.rs1_ren.eq(self.rdata.rs1_ren),
                self.wdata.rs1_rdata.eq(self.rdata.rs1_rdata),
                self.wdata.rs2.eq(self.rdata.rs2),
                self.wdata.rs2_ren.eq(self.rdata.rs2_ren),
                self.wdata.rs2_rdata.eq(self.rdata.rs2_rdata)
            ]

        return m
