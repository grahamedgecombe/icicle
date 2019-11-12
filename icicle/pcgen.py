from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT


class PCGen(Stage):
    def __init__(self):
        super().__init__(wdata_layout=PF_LAYOUT)
