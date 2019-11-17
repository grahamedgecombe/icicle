from nmigen.back.pysim import Simulator
from nmigen.hdl.ast import Delay
from nmigen.test.utils import FHDLTestCase

from icicle.alu import SrcMux, ASrc, BSrc


class SrcMuxTestCase(FHDLTestCase):
    def test_a(self):
        m = SrcMux()
        with Simulator(m) as sim:
            def process():
                yield m.rs1_rdata.eq(1)

                yield m.a_src.eq(ASrc.RS1)
                yield Delay()
                self.assertEqual((yield m.a), 1)
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
