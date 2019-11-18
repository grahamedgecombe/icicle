from nmigen import *

from icicle.decode import Decode
from icicle.execute import Execute
from icicle.fetch import Fetch
from icicle.mem import MemoryAccess
from icicle.pcgen import PCGen
from icicle.pipeline import Pipeline
from icicle.regs import RegisterFile
from icicle.rvfi import RVFI_LAYOUT
from icicle.writeback import Writeback


class CPU(Elaboratable):
    def __init__(self, reset_vector):
        self.reset_vector = reset_vector
        self.rvfi = Record(RVFI_LAYOUT)

    def elaborate(self, platform):
        m = Module()

        regs = m.submodules.regs = RegisterFile()

        decode = Decode()
        m.d.comb += [
            decode.rs1_port.connect(regs.rs1_port),
            decode.rs2_port.connect(regs.rs2_port)
        ]

        writeback = Writeback()
        m.d.comb += writeback.rd_port.connect(regs.rd_port)

        m.submodules.pipeline = Pipeline(
            pcgen=PCGen(self.reset_vector),
            fetch=Fetch(),
            decode=decode,
            execute=Execute(),
            mem=MemoryAccess(),
            writeback=writeback
        )

        return m
