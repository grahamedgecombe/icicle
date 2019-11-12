from icicle.pipeline import Stage
from icicle.pipeline_regs import FD_LAYOUT, DX_LAYOUT


class Decode(Stage):
    def __init__(self):
        super().__init__(rdata_layout=FD_LAYOUT, wdata_layout=DX_LAYOUT)
