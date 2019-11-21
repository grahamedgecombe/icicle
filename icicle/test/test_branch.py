from nmigen.back.pysim import Simulator
from nmigen.hdl.ast import Delay
from nmigen.test.utils import FHDLTestCase

from icicle.branch import BranchTarget, BranchTargetSrc


class BranchTargetTestCase(FHDLTestCase):
    def test_basic(self):
        m = BranchTarget()
        with Simulator(m) as sim:
            def process():
                yield m.pc.eq(0x10000000)
                yield m.rs1_rdata.eq(0x20000000)

                # check expected input
                yield m.src.eq(BranchTargetSrc.PC)
                yield m.imm.eq(4)
                yield Delay()
                self.assertEqual((yield m.target), 0x10000004)
                self.assertEqual((yield m.misaligned), 0)

                yield m.src.eq(BranchTargetSrc.RS1)
                yield m.imm.eq(4)
                yield Delay()
                self.assertEqual((yield m.target), 0x20000004)
                self.assertEqual((yield m.misaligned), 0)

                # check LSB is cleared
                yield m.src.eq(BranchTargetSrc.PC)
                yield m.imm.eq(5)
                yield Delay()
                self.assertEqual((yield m.target), 0x10000004)
                self.assertEqual((yield m.misaligned), 0)

                yield m.src.eq(BranchTargetSrc.RS1)
                yield m.imm.eq(5)
                yield Delay()
                self.assertEqual((yield m.target), 0x20000004)
                self.assertEqual((yield m.misaligned), 0)

                # check misaligned target
                yield m.src.eq(BranchTargetSrc.PC)
                yield m.imm.eq(6)
                yield Delay()
                self.assertEqual((yield m.target), 0x10000006)
                self.assertEqual((yield m.misaligned), 1)

                yield m.src.eq(BranchTargetSrc.RS1)
                yield m.imm.eq(6)
                yield Delay()
                self.assertEqual((yield m.target), 0x20000006)
                self.assertEqual((yield m.misaligned), 1)
            sim.add_process(process)
            sim.run()
