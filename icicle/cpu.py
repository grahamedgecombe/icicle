from nmigen import *

from icicle.decode import Decode
from icicle.execute import Execute
from icicle.fetch import Fetch
from icicle.mem import MemoryAccess
from icicle.pcgen import PCGen
from icicle.pipeline import Pipeline
from icicle.writeback import Writeback


class CPU(Elaboratable):
    def elaborate(self, platform):
        m = Module()

        m.submodules.pipeline = Pipeline(
            pcgen=PCGen(),
            fetch=Fetch(),
            decode=Decode(),
            execute=Execute(),
            mem=MemoryAccess(),
            writeback=Writeback()
        )

        return m