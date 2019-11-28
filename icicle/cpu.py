from nmigen import *

from icicle.decode import Decode
from icicle.execute import Execute
from icicle.fetch import Fetch
from icicle.mem import MemoryAccess
from icicle.pcgen import PCGen
from icicle.pipeline import Pipeline
from icicle.regs import RegisterFile, BlackBoxRegisterFile
from icicle.rvfi import RVFI
from icicle.wishbone import WISHBONE_LAYOUT
from icicle.writeback import Writeback


class CPU(Elaboratable):
    def __init__(self, reset_vector=0, rvfi=False, rvfi_blackbox_alu=False, rvfi_blackbox_regs=False):
        self.reset_vector = reset_vector
        self.rvfi_blackbox_alu = rvfi_blackbox_alu
        self.rvfi_blackbox_regs = rvfi_blackbox_regs
        self.dbus = Record(WISHBONE_LAYOUT)
        if rvfi:
            self.rvfi = RVFI()

    def elaborate(self, platform):
        m = Module()

        regs = m.submodules.regs = BlackBoxRegisterFile() if self.rvfi_blackbox_regs else RegisterFile()

        pcgen = PCGen(self.reset_vector)

        fetch = Fetch()

        decode = Decode()
        m.d.comb += [
            decode.rs1_port.connect(regs.rs1_port),
            decode.rs2_port.connect(regs.rs2_port)
        ]

        execute = Execute(self.rvfi_blackbox_alu)

        mem = MemoryAccess(self.rvfi_blackbox_alu)
        m.d.comb += [
            mem.dbus.connect(self.dbus),
            pcgen.branch_taken.eq(mem.branch_taken),
            pcgen.branch_target.eq(mem.branch_target)
        ]
        fetch.flush_on(mem.branch_taken)
        decode.flush_on(mem.branch_taken)
        execute.flush_on(mem.branch_taken)
        mem.stall_on(mem.valid & mem.busy)

        writeback = Writeback()
        m.d.comb += writeback.rd_port.connect(regs.rd_port)

        def data_hazard(stage):
            rs1_matches = decode.rs1_ren & (decode.rs1_port.addr == stage.rdata.rd)
            rs2_matches = decode.rs2_ren & (decode.rs2_port.addr == stage.rdata.rd)
            return stage.valid & stage.rdata.rd_wen & (rs1_matches | rs2_matches)

        decode.stall_on(data_hazard(execute))
        decode.stall_on(data_hazard(mem))
        decode.stall_on(data_hazard(writeback))

        if hasattr(self, "rvfi"):
            m.d.comb += self.rvfi.eq(writeback.rvfi)

        m.submodules.pipeline = Pipeline(
            pcgen=pcgen,
            fetch=fetch,
            decode=decode,
            execute=execute,
            mem=mem,
            writeback=writeback
        )

        return m
