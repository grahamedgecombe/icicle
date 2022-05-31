from amaranth.back.pysim import Simulator, Delay
from amaranth.test.utils import FHDLTestCase

from icicle.logic import Logic, LogicOp


class LogicTestCase(FHDLTestCase):
    def test_basic(self):
        m = Logic()
        sim = Simulator(m)
        def process():
            yield m.op.eq(LogicOp.XOR)
            yield m.a.eq(0xEC761967)
            yield m.b.eq(0x02E23AE0)
            yield Delay()
            self.assertEqual((yield m.result), 0xEE942387)

            yield m.op.eq(LogicOp.OR)
            yield m.a.eq(0xEC761967)
            yield m.b.eq(0x02E23AE0)
            yield Delay()
            self.assertEqual((yield m.result), 0xEEF63BE7)

            yield m.op.eq(LogicOp.AND)
            yield m.a.eq(0xEC761967)
            yield m.b.eq(0x02E23AE0)
            yield Delay()
            self.assertEqual((yield m.result), 0x00621860)
        sim.add_process(process)
        sim.run()
