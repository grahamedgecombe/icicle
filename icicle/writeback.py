from icicle.pipeline import Stage
from icicle.pipeline_regs import MW_LAYOUT


class Writeback(Stage):
    def __init__(self, regs):
        super().__init__(rdata_layout=MW_LAYOUT)
        self.regs = regs

    def elaborate(self, platform):
        m = super().elaborate(platform)

        rd_port = m.submodules.rd_port = self.regs.write_port()

        m.d.comb += [
            rd_port.en.eq(~self.stall & self.valid & self.rdata.rd_wen),
            rd_port.addr.eq(self.rdata.rd),
            rd_port.data.eq(self.rdata.rd_wdata)
        ]

        return m
