from icicle.alu import ResultMux
from icicle.pipeline import Stage
from icicle.pipeline_regs import XM_LAYOUT, MW_LAYOUT


class MemoryAccess(Stage):
    def __init__(self):
        super().__init__(rdata_layout=XM_LAYOUT, wdata_layout=MW_LAYOUT)

    def elaborate(self, platform):
        m = super().elaborate(platform)

        result_mux = m.submodules.result_mux = ResultMux()
        m.d.comb += [
            result_mux.src.eq(self.rdata.result_src),
            result_mux.add_result.eq(self.rdata.add_result),
            result_mux.add_carry.eq(self.rdata.add_carry),
            result_mux.logic_result.eq(self.rdata.logic_result),
            result_mux.shift_result.eq(self.rdata.shift_result)
        ]

        with m.If(~self.stall):
            m.d.sync += self.wdata.rd_wdata.eq(result_mux.result)

        return m
