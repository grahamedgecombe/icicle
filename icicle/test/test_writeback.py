from nmigen import *
from nmigen.back.pysim import Simulator
from nmigen.test.utils import FHDLTestCase

from icicle.writeback import Writeback


class WritebackTestCase(FHDLTestCase):
    def test_basic(self):
        regs = Memory(width=32, depth=32)
        m = Writeback(regs)
        with Simulator(m) as sim:
            def process():
                yield m.rdata.valid.eq(1)
                yield m.rdata.rd.eq(1)
                yield m.rdata.rd_wen.eq(1)
                yield m.rdata.rd_wdata.eq(0xDEADBEEF)
                yield
                yield
                self.assertEqual((yield regs[1]), 0xDEADBEEF)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_stall(self):
        regs = Memory(width=32, depth=32)
        m = Writeback(regs)

        stall = Signal()
        m.stall_on(stall)

        with Simulator(m) as sim:
            def process():
                yield stall.eq(1)
                yield m.rdata.valid.eq(1)
                yield m.rdata.rd.eq(1)
                yield m.rdata.rd_wen.eq(1)
                yield m.rdata.rd_wdata.eq(0xDEADBEEF)
                yield
                yield
                self.assertEqual((yield regs[1]), 0)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_invalid(self):
        regs = Memory(width=32, depth=32)
        m = Writeback(regs)
        with Simulator(m) as sim:
            def process():
                yield m.rdata.valid.eq(0)
                yield m.rdata.rd.eq(1)
                yield m.rdata.rd_wen.eq(1)
                yield m.rdata.rd_wdata.eq(0xDEADBEEF)
                yield
                yield
                self.assertEqual((yield regs[1]), 0)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_wen_low(self):
        regs = Memory(width=32, depth=32)
        m = Writeback(regs)
        with Simulator(m) as sim:
            def process():
                yield m.rdata.valid.eq(1)
                yield m.rdata.rd.eq(1)
                yield m.rdata.rd_wen.eq(0)
                yield m.rdata.rd_wdata.eq(0xDEADBEEF)
                yield
                yield
                self.assertEqual((yield regs[1]), 0)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()
