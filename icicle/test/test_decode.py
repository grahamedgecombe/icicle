from nmigen import *
from nmigen.back.pysim import Simulator
from nmigen.test.utils import FHDLTestCase

from icicle.decode import Decode


class DecodeTestCase(FHDLTestCase):
    def test_basic(self):
        regs = Memory(width=32, depth=32, init=[
            0x00000000,
            0x00112233,
            0x44556677,
            0x8899AABB,
            0xCCDDEEFF
        ])
        m = Decode(regs)
        with Simulator(m) as sim:
            def process():
                yield m.rdata.insn.eq(Cat(C(0, 7), C(0, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield
                yield m.rdata.insn.eq(Cat(C(0, 7), C(0, 5), C(0, 3), C(3, 5), C(4, 5), C(0, 7)))
                yield
                self.assertEqual((yield m.wdata.rs1), 1)
                self.assertEqual((yield m.wdata.rs1_rdata), 0x00112233)
                self.assertEqual((yield m.wdata.rs2), 2)
                self.assertEqual((yield m.wdata.rs2_rdata), 0x44556677)
                yield
                self.assertEqual((yield m.wdata.rs1), 3)
                self.assertEqual((yield m.wdata.rs1_rdata), 0x8899AABB)
                self.assertEqual((yield m.wdata.rs2), 4)
                self.assertEqual((yield m.wdata.rs2_rdata), 0xCCDDEEFF)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()

    def test_stall(self):
        regs = Memory(width=32, depth=32, init=[
            0x00000000,
            0x00112233,
            0x44556677,
            0x8899AABB,
            0xCCDDEEFF
        ])
        m = Decode(regs)

        stall = Signal()
        m.stall_on(stall)

        with Simulator(m) as sim:
            def process():
                yield m.rdata.insn.eq(Cat(C(0, 7), C(0, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield
                yield m.rdata.insn.eq(Cat(C(0, 7), C(0, 5), C(0, 3), C(3, 5), C(4, 5), C(0, 7)))
                yield stall.eq(1)
                yield
                self.assertEqual((yield m.wdata.rs1), 1)
                self.assertEqual((yield m.wdata.rs1_rdata), 0x00112233)
                self.assertEqual((yield m.wdata.rs2), 2)
                self.assertEqual((yield m.wdata.rs2_rdata), 0x44556677)
                yield
                self.assertEqual((yield m.wdata.rs1), 1)
                self.assertEqual((yield m.wdata.rs1_rdata), 0x00112233)
                self.assertEqual((yield m.wdata.rs2), 2)
                self.assertEqual((yield m.wdata.rs2_rdata), 0x44556677)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()
