from icicle.pipeline import Stage
from icicle.pipeline_regs import DX_LAYOUT, XM_LAYOUT


class Execute(Stage):
    def __init__(self):
        super().__init__(rdata_layout=DX_LAYOUT, wdata_layout=XM_LAYOUT)
