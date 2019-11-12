from icicle.pipeline import Stage
from icicle.pipeline_regs import XM_LAYOUT, MW_LAYOUT


class MemoryAccess(Stage):
    def __init__(self):
        super().__init__(rdata_layout=XM_LAYOUT, wdata_layout=MW_LAYOUT)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.rd.eq(self.rdata.rd),
                self.wdata.rd_wen.eq(self.rdata.rd_wen),
                self.wdata.rs1.eq(self.rdata.rs1),
                self.wdata.rs1_ren.eq(self.rdata.rs1_ren),
                self.wdata.rs2.eq(self.rdata.rs2),
                self.wdata.rs2_ren.eq(self.rdata.rs2_ren)
            ]

        return m
