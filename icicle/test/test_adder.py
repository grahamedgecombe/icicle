from unittest import TestCase

from amaranth.sim import Simulator, Delay

from icicle.adder import Adder


class AdderTestCase(TestCase):
    def test_add(self):
        m = Adder()
        sim = Simulator(m)
        def process():
            yield m.sub.eq(0)
            yield m.signed_compare.eq(0)
            yield m.a.eq(1)
            yield m.b.eq(2)
            yield Delay()
            self.assertEqual((yield m.result), 3)
            self.assertEqual((yield m.carry), 0)

            yield m.a.eq(0x80000000)
            yield m.b.eq(0x7FFFFFFF)
            yield Delay()
            self.assertEqual((yield m.result), 0xFFFFFFFF)
            self.assertEqual((yield m.carry), 0)

            yield m.a.eq(0x80000000)
            yield m.b.eq(0x80000000)
            yield Delay()
            self.assertEqual((yield m.result), 0)
            self.assertEqual((yield m.carry), 1)

            yield m.a.eq(0x80000001)
            yield m.b.eq(0x80000002)
            yield Delay()
            self.assertEqual((yield m.result), 3)
            self.assertEqual((yield m.carry), 1)
        sim.add_process(process)
        sim.run()

    def test_sub(self):
        m = Adder()
        sim = Simulator(m)
        def process():
            yield m.sub.eq(1)
            yield m.signed_compare.eq(0)
            yield m.a.eq(2)
            yield m.b.eq(1)
            yield Delay()
            self.assertEqual((yield m.result), 1)
            self.assertEqual((yield m.carry), 0)

            yield m.a.eq(1)
            yield m.b.eq(1)
            yield Delay()
            self.assertEqual((yield m.result), 0)
            self.assertEqual((yield m.carry), 0)

            yield m.a.eq(1)
            yield m.b.eq(2)
            yield Delay()
            self.assertEqual((yield m.result), 4294967295)
            self.assertEqual((yield m.carry), 1)
        sim.add_process(process)
        sim.run()

    def test_signed_compare(self):
        m = Adder()
        sim = Simulator(m)
        def process():
            yield m.sub.eq(1)
            yield m.signed_compare.eq(1)
            yield m.a.eq(-2)
            yield m.b.eq(0)
            yield Delay()
            self.assertEqual((yield m.carry), 1)

            yield m.a.eq(-2)
            yield m.b.eq(-1)
            yield Delay()
            self.assertEqual((yield m.carry), 1)

            yield m.a.eq(-2)
            yield m.b.eq(-2)
            yield Delay()
            self.assertEqual((yield m.carry), 0)

            yield m.a.eq(-2)
            yield m.b.eq(-3)
            yield Delay()
            self.assertEqual((yield m.carry), 0)

            yield m.a.eq(-3)
            yield m.b.eq(-2)
            yield Delay()
            self.assertEqual((yield m.carry), 1)

            yield m.a.eq(-2)
            yield m.b.eq(-2)
            yield Delay()
            self.assertEqual((yield m.carry), 0)

            yield m.a.eq(-1)
            yield m.b.eq(-2)
            yield Delay()
            self.assertEqual((yield m.carry), 0)

            yield m.a.eq(0)
            yield m.b.eq(-2)
            yield Delay()
            self.assertEqual((yield m.carry), 0)
        sim.add_process(process)
        sim.run()
