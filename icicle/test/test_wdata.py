from amaranth.back.pysim import Simulator, Delay
from amaranth.test.utils import FHDLTestCase

from icicle.wdata import WDataMux, WDataSel


class WDataMuxTestCase(FHDLTestCase):
    def test_basic(self):
        m = WDataMux()
        sim = Simulator(m)
        def process():
            yield m.result.eq(0x00000001)
            yield m.mem_rdata.eq(0x00000002)

            yield m.sel.eq(WDataSel.ALU_RESULT)
            yield Delay()
            self.assertEqual((yield m.rd_wdata), 0x00000001)

            yield m.sel.eq(WDataSel.MEM_RDATA)
            yield Delay()
            self.assertEqual((yield m.rd_wdata), 0x00000002)
        sim.add_process(process)
        sim.run()
