from icicle.pipeline import Stage
from icicle.pipeline_regs import XM_LAYOUT, MW_LAYOUT


class MemoryAccess(Stage):
    def __init__(self):
        super().__init__(rdata_layout=XM_LAYOUT, wdata_layout=MW_LAYOUT)
