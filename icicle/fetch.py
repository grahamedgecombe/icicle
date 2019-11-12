from icicle.pipeline import Stage
from icicle.pipeline_regs import PF_LAYOUT, FD_LAYOUT


class Fetch(Stage):
    def __init__(self):
        super().__init__(rdata_layout=PF_LAYOUT, wdata_layout=FD_LAYOUT)
