from amaranth.back.pysim import Simulator, Delay
from amaranth.test.utils import FHDLTestCase

from icicle.alu import OperandMux, ASel, BSel, ResultMux, ResultSel


class OperandMuxTestCase(FHDLTestCase):
    def test_a(self):
        m = OperandMux()
        sim = Simulator(m)
        def process():
            yield m.rs1_rdata.eq(1)
            yield m.pc_rdata.eq(2)

            yield m.a_sel.eq(ASel.RS1)
            yield Delay()
            self.assertEqual((yield m.a), 1)

            yield m.a_sel.eq(ASel.PC)
            yield Delay()
            self.assertEqual((yield m.a), 2)

            yield m.a_sel.eq(ASel.ZERO)
            yield Delay()
            self.assertEqual((yield m.a), 0)
        sim.add_process(process)
        sim.run()

    def test_b(self):
        m = OperandMux()
        sim = Simulator(m)
        def process():
            yield m.rs2_rdata.eq(1)
            yield m.imm.eq(2)

            yield m.b_sel.eq(BSel.RS2)
            yield Delay()
            self.assertEqual((yield m.b), 1)

            yield m.b_sel.eq(BSel.IMM)
            yield Delay()
            self.assertEqual((yield m.b), 2)

            yield m.b_sel.eq(BSel.FOUR)
            yield Delay()
            self.assertEqual((yield m.b), 4)
        sim.add_process(process)
        sim.run()


class ResultMuxTestCase(FHDLTestCase):
    def test_basic(self):
        m = ResultMux()
        sim = Simulator(m)
        def process():
            yield m.add_result.eq(2)
            yield m.add_carry.eq(1)
            yield m.logic_result.eq(3)
            yield m.shift_result.eq(4)

            yield m.sel.eq(ResultSel.ADDER)
            yield Delay()
            self.assertEqual((yield m.result), 2)

            yield m.sel.eq(ResultSel.SLT)
            yield Delay()
            self.assertEqual((yield m.result), 1)

            yield m.sel.eq(ResultSel.LOGIC)
            yield Delay()
            self.assertEqual((yield m.result), 3)

            yield m.sel.eq(ResultSel.SHIFT)
            yield Delay()
            self.assertEqual((yield m.result), 4)
        sim.add_process(process)
        sim.run()
