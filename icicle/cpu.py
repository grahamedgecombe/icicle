from amaranth import *
from amaranth_soc.wishbone import Interface

from icicle.decode import Decode
from icicle.execute import Execute
from icicle.fetch import Fetch
from icicle.mem import MemoryAccess
from icicle.pcgen import PCGen
from icicle.pipeline import Pipeline, State
from icicle.regs import RegisterFile, BlackBoxRegisterFile
from icicle.rvfi import RVFI
from icicle.writeback import Writeback


class CPU(Elaboratable):
    def __init__(self, reset_vector=0, trap_vector=0, rvfi=False, rvfi_blackbox_alu=False, rvfi_blackbox_regs=False):
        self.reset_vector = reset_vector
        self.trap_vector = trap_vector
        self.rvfi_blackbox_alu = rvfi_blackbox_alu
        self.rvfi_blackbox_regs = rvfi_blackbox_regs
        self.ibus = Interface(addr_width=30, data_width=32, granularity=8, features=["err"])
        self.dbus = Interface(addr_width=30, data_width=32, granularity=8, features=["err"])
        if rvfi:
            self.rvfi = RVFI()

    def elaborate(self, platform):
        m = Module()

        regs = m.submodules.regs = BlackBoxRegisterFile() if self.rvfi_blackbox_regs else RegisterFile()

        pcgen = PCGen(self.reset_vector, self.trap_vector)

        fetch = Fetch()
        m.d.comb += fetch.ibus.connect(self.ibus)

        decode = Decode()
        m.d.comb += [
            decode.rs1_port.connect(regs.rs1_port),
            decode.rs2_port.connect(regs.rs2_port)
        ]

        execute = Execute(self.rvfi_blackbox_alu)

        mem = MemoryAccess(self.trap_vector, self.rvfi_blackbox_alu)
        m.d.comb += [
            mem.dbus.connect(self.dbus),
            pcgen.branch_taken.eq(mem.branch_taken),
            pcgen.branch_target.eq(mem.branch_target),
            pcgen.trap_raised.eq(mem.trap_raised)
        ]
        fetch.flush_on(mem.branch_taken | mem.trap_raised)
        decode.flush_on(mem.branch_taken | mem.trap_raised)
        execute.flush_on(mem.branch_taken | mem.trap_raised)

        writeback = Writeback()
        m.d.comb += writeback.rd_port.connect(regs.rd_port)

        fetch.stall_on((decode.i.state == State.VALID) & decode.fence_i)
        fetch.stall_on((execute.i.state == State.VALID) & execute.i.fence_i)

        def data_hazard(stage):
            rs1_matches = decode.rs1_ren & (decode.rs1_port.addr == stage.i.rd)
            rs2_matches = decode.rs2_ren & (decode.rs2_port.addr == stage.i.rd)
            return (stage.i.state == State.VALID) & stage.i.rd_wen & (rs1_matches | rs2_matches)

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
