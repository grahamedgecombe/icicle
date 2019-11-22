from nmigen.back.pysim import Simulator
from nmigen.hdl.ast import Delay
from nmigen.test.utils import FHDLTestCase

from icicle.pc import PCMux


class PCMuxTestCase(FHDLTestCase):
    def test_basic(self):
        m = PCMux()
        with Simulator(m) as sim:
            def process():
                yield m.pc_rdata.eq(0x10000000)
                yield m.branch_target.eq(0x20000000)

                yield m.branch_taken.eq(0)
                yield Delay()
                self.assertEqual((yield m.pc), 0x10000004)

                yield m.branch_taken.eq(1)
                yield Delay()
                self.assertEqual((yield m.pc), 0x20000000)
            sim.add_process(process)
            sim.run()
