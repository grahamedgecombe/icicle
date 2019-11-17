from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT


class PCGen(Stage):
    def __init__(self, reset_vector):
        super().__init__(wdata_layout=PF_LAYOUT)
        self.wdata.pc.reset = reset_vector - 4

    def elaborate(self, platform):
        m = super().elaborate(platform)

        with m.If(~self.stall):
            m.d.sync += self.wdata.pc.eq(self.wdata.pc + 4)

        return m
