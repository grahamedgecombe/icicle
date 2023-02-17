from amaranth import *
from amaranth.back.pysim import Simulator, Settle
from amaranth.test.utils import FHDLTestCase

from icicle.writeback import Writeback


class WritebackTestCase(FHDLTestCase):
    def _create_writeback(self):
        m = Module()

        regs = Memory(width=32, depth=32)
        rd_port = m.submodules.rd_port = regs.write_port()

        writeback = m.submodules.writeback = Writeback()
        m.d.comb += [
            rd_port.insn_valid.eq(writeback.rd_port.insn_valid),
            rd_port.addr.eq(writeback.rd_port.addr),
            rd_port.data.eq(writeback.rd_port.data)
        ]

        return m, writeback, regs

    def test_basic(self):
        m, writeback, regs = self._create_writeback()
        sim = Simulator(m)
        def process():
            yield writeback.i.insn_valid.eq(1)
            yield writeback.i.rd.eq(1)
            yield writeback.i.rd_wen.eq(1)
            yield writeback.i.result.eq(0xDEADBEEF)
            yield
            yield Settle()
            self.assertEqual((yield regs[1]), 0xDEADBEEF)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_stall(self):
        m, writeback, regs = self._create_writeback()

        stall = Signal()
        writeback.stall_on(stall)

        sim = Simulator(m)
        def process():
            yield stall.eq(1)
            yield writeback.i.insn_valid.eq(1)
            yield writeback.i.rd.eq(1)
            yield writeback.i.rd_wen.eq(1)
            yield writeback.i.result.eq(0xDEADBEEF)
            yield
            yield Settle()
            self.assertEqual((yield regs[1]), 0)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_invalid(self):
        m, writeback, regs = self._create_writeback()
        sim = Simulator(m)
        def process():
            yield writeback.i.insn_valid.eq(0)
            yield writeback.i.rd.eq(1)
            yield writeback.i.rd_wen.eq(1)
            yield writeback.i.result.eq(0xDEADBEEF)
            yield
            yield Settle()
            self.assertEqual((yield regs[1]), 0)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_wen_low(self):
        m, writeback, regs = self._create_writeback()
        sim = Simulator(m)
        def process():
            yield writeback.i.insn_valid.eq(1)
            yield writeback.i.rd.eq(1)
            yield writeback.i.rd_wen.eq(0)
            yield writeback.i.result.eq(0xDEADBEEF)
            yield
            yield Settle()
            self.assertEqual((yield regs[1]), 0)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()
