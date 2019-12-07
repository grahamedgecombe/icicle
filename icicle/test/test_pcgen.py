from nmigen import *
from nmigen.back.pysim import Simulator
from nmigen.test.utils import FHDLTestCase

from icicle.pcgen import PCGen


class PCGenTestCase(FHDLTestCase):
    def test_basic(self):
        m = PCGen(reset_vector=0x00100000)
        sim = Simulator(m)
        def process():
            self.assertEqual((yield m.wdata.valid), 0)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
            self.assertEqual((yield m.wdata.intr), 0)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00100004)
            self.assertEqual((yield m.wdata.intr), 0)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00100008)
            self.assertEqual((yield m.wdata.intr), 0)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_stall(self):
        m = PCGen(reset_vector=0x00100000)

        stall = Signal()
        m.stall_on(stall)

        sim = Simulator(m)
        def process():
            self.assertEqual((yield m.wdata.valid), 0)
            yield stall.eq(1)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
            self.assertEqual((yield m.wdata.intr), 0)
            yield stall.eq(0)
            yield
            self.assertEqual((yield m.wdata.valid), 0)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
            self.assertEqual((yield m.wdata.intr), 0)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00100004)
            self.assertEqual((yield m.wdata.intr), 0)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_branch(self):
        m = PCGen(reset_vector=0x00100000)
        sim = Simulator(m)
        def process():
            self.assertEqual((yield m.wdata.valid), 0)
            yield m.branch_taken.eq(1)
            yield m.branch_target.eq(0x00200000)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
            self.assertEqual((yield m.wdata.intr), 0)
            yield m.branch_taken.eq(0)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00200000)
            self.assertEqual((yield m.wdata.intr), 0)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00200004)
            self.assertEqual((yield m.wdata.intr), 0)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_trap(self):
        m = PCGen(reset_vector=0x00100000, trap_vector=0x00200000)
        sim = Simulator(m)
        def process():
            self.assertEqual((yield m.wdata.valid), 0)
            yield m.trap_raised.eq(1)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00100000)
            self.assertEqual((yield m.wdata.intr), 0)
            yield m.trap_raised.eq(0)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00200000)
            self.assertEqual((yield m.wdata.intr), 1)
            yield
            self.assertEqual((yield m.wdata.valid), 1)
            self.assertEqual((yield m.wdata.pc_rdata), 0x00200004)
            self.assertEqual((yield m.wdata.intr), 0)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()
