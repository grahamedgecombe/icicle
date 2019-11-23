from nmigen import *
from nmigen.back.pysim import Simulator
from nmigen.test.utils import FHDLTestCase

from icicle.pcgen import PCGen


class PCGenTestCase(FHDLTestCase):
    def test_basic(self):
        m = PCGen(reset_vector=0x00100000)
        with Simulator(m) as sim:
            def process():
                self.assertEqual((yield m.wdata.valid), 0)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100004)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100008)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_stall(self):
        m = PCGen(reset_vector=0x00100000)

        stall = Signal()
        m.stall_on(stall)

        with Simulator(m) as sim:
            def process():
                self.assertEqual((yield m.wdata.valid), 0)
                yield stall.eq(1)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
                yield stall.eq(0)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100004)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_branch(self):
        m = PCGen(reset_vector=0x00100000)
        with Simulator(m) as sim:
            def process():
                self.assertEqual((yield m.wdata.valid), 0)
                yield m.branch_taken.eq(1)
                yield m.branch_target.eq(0x00200000)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
                yield m.branch_taken.eq(0)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00200000)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00200004)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_branch_during_stall(self):
        m = PCGen(reset_vector=0x00100000)

        stall = Signal()
        m.stall_on(stall)

        with Simulator(m) as sim:
            def process():
                self.assertEqual((yield m.wdata.valid), 0)
                yield stall.eq(1)
                yield m.branch_taken.eq(1)
                yield m.branch_target.eq(0x00200000)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
                yield stall.eq(0)
                yield m.branch_taken.eq(0)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00200000)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc_rdata), 0x00200004)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()
