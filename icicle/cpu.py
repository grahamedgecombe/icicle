from nmigen import *

from icicle.decode import Decode
from icicle.execute import Execute
from icicle.fetch import Fetch
from icicle.mem import MemoryAccess
from icicle.pcgen import PCGen
from icicle.pipeline import Pipeline
from icicle.rvfi import RVFI_LAYOUT
from icicle.writeback import Writeback


class CPU(Elaboratable):
    def __init__(self, reset_vector=0):
        self.reset_vector = reset_vector
        self.rvfi = Record(RVFI_LAYOUT)

    def elaborate(self, platform):
        m = Module()

        regs = Memory(width=32, depth=32)
        rs1_port = m.submodules.rs1_port = regs.read_port(transparent=False)
        rs2_port = m.submodules.rs2_port = regs.read_port(transparent=False)
        rd_port = m.submodules.rd_port = regs.write_port()

        decode = Decode()
        m.d.comb += [
            rs1_port.en.eq(decode.rs1_port.en),
            rs1_port.addr.eq(decode.rs1_port.addr),
            decode.rs1_port.data.eq(rs1_port.data),

            rs2_port.en.eq(decode.rs2_port.en),
            rs2_port.addr.eq(decode.rs2_port.addr),
            decode.rs2_port.data.eq(rs2_port.data)
        ]

        writeback = Writeback()
        m.d.comb += [
            rd_port.en.eq(writeback.rd_port.en),
            rd_port.addr.eq(writeback.rd_port.addr),
            rd_port.data.eq(writeback.rd_port.data),

            writeback.rvfi.connect(self.rvfi)
        ]

        m.submodules.pipeline = Pipeline(
            pcgen=PCGen(self.reset_vector),
            fetch=Fetch(),
            decode=decode,
            execute=Execute(),
            mem=MemoryAccess(),
            writeback=writeback
        )

        return m
