from nmigen.back.pysim import Simulator
from nmigen.test.utils import FHDLTestCase

from icicle.pcgen import PCGen


class PCGenTestCase(FHDLTestCase):
    def test_basic(self):
        m = PCGen(reset_vector=0x00100000)
        with Simulator(m) as sim:
            def process():
                self.assertEqual((yield m.wdata.valid), 0)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc), 0x00100000)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc), 0x00100004)
                yield
                self.assertEqual((yield m.wdata.valid), 1)
                self.assertEqual((yield m.wdata.pc), 0x00100008)
            sim.add_clock(period=1e-6)
            sim.add_sync_process(process)
            sim.run()
