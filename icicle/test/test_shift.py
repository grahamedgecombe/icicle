from nmigen.back.pysim import Simulator
from nmigen.hdl.ast import Delay
from nmigen.test.utils import FHDLTestCase

from icicle.shift import BarrelShifter


class BarrelShifterTestCase(FHDLTestCase):
    def test_basic(self):
        m = BarrelShifter()
        with Simulator(m) as sim:
            def process():
                yield m.left.eq(0)
                yield m.sign_extend.eq(0)
                yield m.a.eq(123)
                yield m.shamt.eq(1)
                yield Delay()
                self.assertEqual((yield m.result), 61)

                yield m.left.eq(0)
                yield m.sign_extend.eq(1)
                yield m.a.eq(123)
                yield m.shamt.eq(1)
                yield Delay()
                self.assertEqual((yield m.result), 61)

                yield m.left.eq(0)
                yield m.sign_extend.eq(0)
                yield m.a.eq(256)
                yield m.shamt.eq(8)
                yield Delay()
                self.assertEqual((yield m.result), 1)

                yield m.left.eq(0)
                yield m.sign_extend.eq(1)
                yield m.a.eq(256)
                yield m.shamt.eq(8)
                yield Delay()
                self.assertEqual((yield m.result), 1)

                yield m.left.eq(0)
                yield m.sign_extend.eq(0)
                yield m.a.eq(0xF0000000)
                yield m.shamt.eq(1)
                yield Delay()
                self.assertEqual((yield m.result), 0x78000000)

                yield m.left.eq(0)
                yield m.sign_extend.eq(1)
                yield m.a.eq(0xF0000000)
                yield m.shamt.eq(1)
                yield Delay()
                self.assertEqual((yield m.result), 0xF8000000)

                yield m.left.eq(1)
                yield m.sign_extend.eq(0)
                yield m.a.eq(123)
                yield m.shamt.eq(1)
                yield Delay()
                self.assertEqual((yield m.result), 246)

                yield m.left.eq(1)
                yield m.sign_extend.eq(0)
                yield m.a.eq(1)
                yield m.shamt.eq(8)
                yield Delay()
                self.assertEqual((yield m.result), 256)
            sim.add_process(process)
            sim.run()
