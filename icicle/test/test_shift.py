from unittest import TestCase

from amaranth.sim import Simulator, Delay

from icicle.shift import BarrelShifter


class BarrelShifterTestCase(TestCase):
    def test_basic(self):
        m = BarrelShifter()
        sim = Simulator(m)
        def process():
            yield m.right.eq(0)
            yield m.arithmetic.eq(0)
            yield m.a.eq(123)
            yield m.shamt.eq(1)
            yield Delay()
            self.assertEqual((yield m.result), 246)

            yield m.right.eq(0)
            yield m.arithmetic.eq(0)
            yield m.a.eq(1)
            yield m.shamt.eq(8)
            yield Delay()
            self.assertEqual((yield m.result), 256)

            yield m.right.eq(1)
            yield m.arithmetic.eq(0)
            yield m.a.eq(123)
            yield m.shamt.eq(1)
            yield Delay()
            self.assertEqual((yield m.result), 61)

            yield m.right.eq(1)
            yield m.arithmetic.eq(1)
            yield m.a.eq(123)
            yield m.shamt.eq(1)
            yield Delay()
            self.assertEqual((yield m.result), 61)

            yield m.right.eq(1)
            yield m.arithmetic.eq(1)
            yield m.a.eq(123)
            yield m.shamt.eq(2)
            yield Delay()
            self.assertEqual((yield m.result), 30)

            yield m.right.eq(1)
            yield m.arithmetic.eq(0)
            yield m.a.eq(256)
            yield m.shamt.eq(8)
            yield Delay()
            self.assertEqual((yield m.result), 1)

            yield m.right.eq(1)
            yield m.arithmetic.eq(1)
            yield m.a.eq(256)
            yield m.shamt.eq(8)
            yield Delay()
            self.assertEqual((yield m.result), 1)

            yield m.right.eq(1)
            yield m.arithmetic.eq(0)
            yield m.a.eq(0xF0000000)
            yield m.shamt.eq(1)
            yield Delay()
            self.assertEqual((yield m.result), 0x78000000)

            yield m.right.eq(1)
            yield m.arithmetic.eq(1)
            yield m.a.eq(0xF0000000)
            yield m.shamt.eq(1)
            yield Delay()
            self.assertEqual((yield m.result), 0xF8000000)

            yield m.right.eq(1)
            yield m.arithmetic.eq(1)
            yield m.a.eq(0xF0000000)
            yield m.shamt.eq(2)
            yield Delay()
            self.assertEqual((yield m.result), 0xFC000000)
        sim.add_process(process)
        sim.run()
