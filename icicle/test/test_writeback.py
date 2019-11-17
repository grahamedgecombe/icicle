from nmigen import *
from nmigen.back.pysim import Simulator
from nmigen.test.utils import FHDLTestCase

from icicle.writeback import Writeback


class WritebackTestCase(FHDLTestCase):
    def _create_writeback(self):
        m = Module()

        regs = Memory(width=32, depth=32)
        rd_port = m.submodules.rd_port = regs.write_port()

        writeback = m.submodules.writeback = Writeback()
        m.d.comb += [
            rd_port.en.eq(writeback.rd_port.en),
            rd_port.addr.eq(writeback.rd_port.addr),
            rd_port.data.eq(writeback.rd_port.data)
        ]

        return m, writeback, regs

    def test_basic(self):
        m, writeback, regs = self._create_writeback()
        with Simulator(m) as sim:
            def process():
                yield writeback.rdata.valid.eq(1)
                yield writeback.rdata.rd.eq(1)
                yield writeback.rdata.rd_wen.eq(1)
                yield writeback.rdata.rd_wdata.eq(0xDEADBEEF)
                yield
                yield
                self.assertEqual((yield regs[1]), 0xDEADBEEF)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_stall(self):
        m, writeback, regs = self._create_writeback()

        stall = Signal()
        writeback.stall_on(stall)

        with Simulator(m) as sim:
            def process():
                yield stall.eq(1)
                yield writeback.rdata.valid.eq(1)
                yield writeback.rdata.rd.eq(1)
                yield writeback.rdata.rd_wen.eq(1)
                yield writeback.rdata.rd_wdata.eq(0xDEADBEEF)
                yield
                yield
                self.assertEqual((yield regs[1]), 0)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_invalid(self):
        m, writeback, regs = self._create_writeback()
        with Simulator(m) as sim:
            def process():
                yield writeback.rdata.valid.eq(0)
                yield writeback.rdata.rd.eq(1)
                yield writeback.rdata.rd_wen.eq(1)
                yield writeback.rdata.rd_wdata.eq(0xDEADBEEF)
                yield
                yield
                self.assertEqual((yield regs[1]), 0)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_wen_low(self):
        m, writeback, regs = self._create_writeback()
        with Simulator(m) as sim:
            def process():
                yield writeback.rdata.valid.eq(1)
                yield writeback.rdata.rd.eq(1)
                yield writeback.rdata.rd_wen.eq(0)
                yield writeback.rdata.rd_wdata.eq(0xDEADBEEF)
                yield
                yield
                self.assertEqual((yield regs[1]), 0)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()
