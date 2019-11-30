from nmigen.back.pysim import Simulator, Delay
from nmigen.test.utils import FHDLTestCase

from icicle.branch import BranchTargetMux, BranchTargetSel, Branch, BranchOp


class BranchTargetMuxTestCase(FHDLTestCase):
    def test_basic(self):
        m = BranchTargetMux()
        sim = Simulator(m)
        def process():
            yield m.pc_rdata.eq(0x10000000)
            yield m.rs1_rdata.eq(0x20000000)

            # check expected input
            yield m.sel.eq(BranchTargetSel.PC)
            yield m.imm.eq(4)
            yield Delay()
            self.assertEqual((yield m.target), 0x10000004)
            self.assertEqual((yield m.misaligned), 0)

            yield m.sel.eq(BranchTargetSel.RS1)
            yield m.imm.eq(4)
            yield Delay()
            self.assertEqual((yield m.target), 0x20000004)
            self.assertEqual((yield m.misaligned), 0)

            # check LSB is cleared
            yield m.sel.eq(BranchTargetSel.PC)
            yield m.imm.eq(5)
            yield Delay()
            self.assertEqual((yield m.target), 0x10000004)
            self.assertEqual((yield m.misaligned), 0)

            yield m.sel.eq(BranchTargetSel.RS1)
            yield m.imm.eq(5)
            yield Delay()
            self.assertEqual((yield m.target), 0x20000004)
            self.assertEqual((yield m.misaligned), 0)

            # check misaligned target
            yield m.sel.eq(BranchTargetSel.PC)
            yield m.imm.eq(6)
            yield Delay()
            self.assertEqual((yield m.misaligned), 1)

            yield m.sel.eq(BranchTargetSel.RS1)
            yield m.imm.eq(6)
            yield Delay()
            self.assertEqual((yield m.misaligned), 1)
        sim.add_process(process)
        sim.run()


class BranchTestCase(FHDLTestCase):
    def test_basic(self):
        m = Branch()
        sim = Simulator(m)
        def process():
            # never
            yield m.op.eq(BranchOp.NEVER)
            yield Delay()
            self.assertEqual((yield m.taken), 0)

            # always
            yield m.op.eq(BranchOp.ALWAYS)
            yield Delay()
            self.assertEqual((yield m.taken), 1)

            # equal
            yield m.op.eq(BranchOp.EQ)
            yield m.add_result.eq(0)
            yield Delay()
            self.assertEqual((yield m.taken), 1)

            yield m.add_result.eq(1)
            yield Delay()
            self.assertEqual((yield m.taken), 0)

            # not equal
            yield m.op.eq(BranchOp.NE)
            yield m.add_result.eq(0)
            yield Delay()
            self.assertEqual((yield m.taken), 0)

            yield m.add_result.eq(1)
            yield Delay()
            self.assertEqual((yield m.taken), 1)

            # less than
            yield m.op.eq(BranchOp.LT)
            yield m.add_carry.eq(0)
            yield Delay()
            self.assertEqual((yield m.taken), 0)

            yield m.add_carry.eq(1)
            yield Delay()
            self.assertEqual((yield m.taken), 1)

            # greater or equal
            yield m.op.eq(BranchOp.GE)
            yield m.add_carry.eq(0)
            yield Delay()
            self.assertEqual((yield m.taken), 1)

            yield m.add_carry.eq(1)
            yield Delay()
            self.assertEqual((yield m.taken), 0)
        sim.add_process(process)
        sim.run()
