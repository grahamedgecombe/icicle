from nmigen import *

from icicle.decode import Decode
from icicle.execute import Execute
from icicle.fetch import Fetch
from icicle.mem import MemoryAccess
from icicle.pcgen import PCGen
from icicle.pipeline import Pipeline
from icicle.regs import RegisterFile, BlackBoxRegisterFile
from icicle.rvfi import RVFI
from icicle.writeback import Writeback


class CPU(Elaboratable):
    def __init__(self, reset_vector=0, rvfi_blackbox_alu=False, rvfi_blackbox_regs=False):
        self.reset_vector = reset_vector
        self.rvfi_blackbox_alu = rvfi_blackbox_alu
        self.rvfi_blackbox_regs = rvfi_blackbox_regs
        self.rvfi = RVFI()

    def elaborate(self, platform):
        m = Module()

        regs = m.submodules.regs = BlackBoxRegisterFile() if self.rvfi_blackbox_regs else RegisterFile()

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
