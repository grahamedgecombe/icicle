from icicle.pipeline import Stage
from icicle.pipeline_regs import MW_LAYOUT


class Writeback(Stage):
    def __init__(self):
        super().__init__(rdata_layout=MW_LAYOUT)
