from nmigen import *
from nmigen.back.pysim import Simulator
from nmigen.test.utils import FHDLTestCase

from icicle.pipeline import Pipeline, Stage

LAYOUT = [
    ("counter", 32)
]


class FirstStage(Stage):
    def __init__(self):
        super().__init__(wdata_layout=LAYOUT)

    def elaborate(self, platform):
        m = super().elaborate(platform)
        with m.If(~self.stall):
            m.d.sync += self.wdata.counter.eq(self.wdata.counter + 1)
        return m


class MiddleStage(Stage):
    def __init__(self):
        super().__init__(rdata_layout=LAYOUT, wdata_layout=LAYOUT)


class LastStage(Stage):
    def __init__(self):
        super().__init__(rdata_layout=LAYOUT)
        self.counter_valid = Signal()
        self.counter = Signal(32)

    def elaborate(self, platform):
        m = super().elaborate(platform)
        with m.If(~self.stall):
            m.d.sync += [
                self.counter_valid.eq(self.valid),
                self.counter.eq(self.rdata.counter)
            ]
        return m


class PipelineTestCase(FHDLTestCase):
    def test_basic(self):
        s1 = FirstStage()
        s2 = MiddleStage()
        s3 = LastStage()
        m = Pipeline(s1=s1, s2=s2, s3=s3)
        with Simulator(m) as sim:
            def process():
                self.assertEqual((yield s1.wdata.valid), 0)
                self.assertEqual((yield s2.wdata.valid), 0)
                self.assertEqual((yield s3.counter_valid), 0)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 1)
                self.assertEqual((yield s2.wdata.valid), 0)
                self.assertEqual((yield s3.counter_valid), 0)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 2)
                self.assertEqual((yield s2.wdata.valid), 1)
                self.assertEqual((yield s2.wdata.counter), 1)
                self.assertEqual((yield s3.counter_valid), 0)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 3)
                self.assertEqual((yield s2.wdata.valid), 1)
                self.assertEqual((yield s2.wdata.counter), 2)
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
        with Simulator(m) as sim:
            def process():
                yield
                yield
                yield s2_stall.eq(1)
                yield
                yield s2_stall.eq(0)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 3)
                self.assertEqual((yield s2.wdata.valid), 0)
                self.assertEqual((yield s3.counter_valid), 1)
                self.assertEqual((yield s3.counter), 2)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 4)
                self.assertEqual((yield s2.wdata.valid), 1)
                self.assertEqual((yield s2.wdata.counter), 3)
                self.assertEqual((yield s3.counter_valid), 0)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 5)
                self.assertEqual((yield s2.wdata.valid), 1)
                self.assertEqual((yield s2.wdata.counter), 4)
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
        with Simulator(m) as sim:
            def process():
                yield
                yield
                yield s2_flush.eq(1)
                yield
                yield s2_flush.eq(0)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 4)
                self.assertEqual((yield s2.wdata.valid), 0)
                self.assertEqual((yield s3.counter_valid), 1)
                self.assertEqual((yield s3.counter), 2)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 5)
                self.assertEqual((yield s2.wdata.valid), 1)
                self.assertEqual((yield s2.wdata.counter), 4)
                self.assertEqual((yield s3.counter_valid), 0)
                yield
                self.assertEqual((yield s1.wdata.valid), 1)
                self.assertEqual((yield s1.wdata.counter), 6)
                self.assertEqual((yield s2.wdata.valid), 1)
                self.assertEqual((yield s2.wdata.counter), 5)
                self.assertEqual((yield s3.counter_valid), 1)
                self.assertEqual((yield s3.counter), 4)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()
