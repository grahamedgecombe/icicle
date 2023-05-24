from unittest import TestCase

from amaranth import *
from amaranth.sim import Simulator, Settle

from icicle.pipeline import Pipeline, Stage

LAYOUT = [
    ("counter", 32)
]


class FirstStage(Stage):
    def __init__(self):
        super().__init__(o_layout=LAYOUT)

    def elaborate_stage(self, m, platform):
        with m.If(~self.stall):
            m.d.sync += self.o.counter.eq(self.o.counter + 1)


class MiddleStage(Stage):
    def __init__(self):
        super().__init__(i_layout=LAYOUT, o_layout=LAYOUT)


class LastStage(Stage):
    def __init__(self):
        super().__init__(i_layout=LAYOUT)
        self.counter_valid = Signal()
        self.counter = Signal(32)

    def elaborate_stage(self, m, platform):
        with m.If(~self.stall):
            m.d.sync += [
                self.counter_valid.eq(self.insn_valid),
                self.counter.eq(self.i.counter)
            ]


class PipelineTestCase(TestCase):
    def test_basic(self):
        s1 = FirstStage()
        s2 = MiddleStage()
        s3 = LastStage()
        m = Pipeline(s1=s1, s2=s2, s3=s3)
        sim = Simulator(m)
        def process():
            self.assertEqual((yield s1.o.insn_valid), 0)
            self.assertEqual((yield s2.o.insn_valid), 0)
            self.assertEqual((yield s3.counter_valid), 0)
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 1)
            self.assertEqual((yield s2.o.insn_valid), 0)
            self.assertEqual((yield s3.counter_valid), 0)
            yield
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 2)
            self.assertEqual((yield s2.o.insn_valid), 1)
            self.assertEqual((yield s2.o.counter), 1)
            self.assertEqual((yield s3.counter_valid), 0)
            yield
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 3)
            self.assertEqual((yield s2.o.insn_valid), 1)
            self.assertEqual((yield s2.o.counter), 2)
            self.assertEqual((yield s3.counter_valid), 1)
            self.assertEqual((yield s3.counter), 1)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_stall(self):
        s1 = FirstStage()
        s2 = MiddleStage()
        s3 = LastStage()

        s2_stall = Signal()
        s2.stall_on(s2_stall)

        m = Pipeline(s1=s1, s2=s2, s3=s3)
        sim = Simulator(m)
        def process():
            yield
            yield
            yield s2_stall.eq(1)
            yield
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 3)
            self.assertEqual((yield s2.o.insn_valid), 0)
            self.assertEqual((yield s3.counter_valid), 1)
            self.assertEqual((yield s3.counter), 2)
            yield s2_stall.eq(0)
            yield
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 4)
            self.assertEqual((yield s2.o.insn_valid), 1)
            self.assertEqual((yield s2.o.counter), 3)
            self.assertEqual((yield s3.counter_valid), 0)
            yield
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 5)
            self.assertEqual((yield s2.o.insn_valid), 1)
            self.assertEqual((yield s2.o.counter), 4)
            self.assertEqual((yield s3.counter_valid), 1)
            self.assertEqual((yield s3.counter), 3)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_flush(self):
        s1 = FirstStage()
        s2 = MiddleStage()
        s3 = LastStage()

        s2_flush = Signal()
        s2.flush_on(s2_flush)

        m = Pipeline(s1=s1, s2=s2, s3=s3)
        sim = Simulator(m)
        def process():
            yield
            yield
            yield s2_flush.eq(1)
            yield
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 4)
            self.assertEqual((yield s2.o.insn_valid), 0)
            self.assertEqual((yield s3.counter_valid), 1)
            self.assertEqual((yield s3.counter), 2)
            yield s2_flush.eq(0)
            yield
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 5)
            self.assertEqual((yield s2.o.insn_valid), 1)
            self.assertEqual((yield s2.o.counter), 4)
            self.assertEqual((yield s3.counter_valid), 0)
            yield
            yield Settle()
            self.assertEqual((yield s1.o.insn_valid), 1)
            self.assertEqual((yield s1.o.counter), 6)
            self.assertEqual((yield s2.o.insn_valid), 1)
            self.assertEqual((yield s2.o.counter), 5)
            self.assertEqual((yield s3.counter_valid), 1)
            self.assertEqual((yield s3.counter), 4)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()
