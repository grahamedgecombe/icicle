from nmigen.back.pysim import Simulator
from nmigen.hdl.ast import Delay
from nmigen.test.utils import FHDLTestCase

from icicle.alu import SrcMux, ASrc, BSrc, ResultMux, ResultSrc


class SrcMuxTestCase(FHDLTestCase):
    def test_a(self):
        m = SrcMux()
        with Simulator(m) as sim:
            def process():
                yield m.rs1_rdata.eq(1)
                yield m.pc.eq(2)

                yield m.a_src.eq(ASrc.RS1)
                yield Delay()
                self.assertEqual((yield m.a), 1)

                yield m.a_src.eq(ASrc.PC)
                yield Delay()
                self.assertEqual((yield m.a), 2)
            sim.add_process(process)
            sim.run()

    def test_b(self):
        m = SrcMux()
        with Simulator(m) as sim:
            def process():
                yield m.rs2_rdata.eq(1)
                yield m.imm.eq(2)

                yield m.b_src.eq(BSrc.RS2)
                yield Delay()
                self.assertEqual((yield m.b), 1)

                yield m.b_src.eq(BSrc.IMM)
                yield Delay()
                self.assertEqual((yield m.b), 2)
            sim.add_process(process)
            sim.run()


class ResultMuxTestCase(FHDLTestCase):
    def test_basic(self):
        m = ResultMux()
        with Simulator(m) as sim:
            def process():
                yield m.add_result.eq(2)
                yield m.add_carry.eq(1)
                yield m.logic_result.eq(3)
                yield m.shift_result.eq(4)

                yield m.src.eq(ResultSrc.ADDER)
                yield Delay()
                self.assertEqual((yield m.result), 2)

                yield m.src.eq(ResultSrc.SLT)
                yield Delay()
                self.assertEqual((yield m.result), 1)

                yield m.src.eq(ResultSrc.LOGIC)
                yield Delay()
                self.assertEqual((yield m.result), 3)

                yield m.src.eq(ResultSrc.SHIFT)
                yield Delay()
                self.assertEqual((yield m.result), 4)
            sim.add_process(process)
            sim.run()
