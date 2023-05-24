from unittest import TestCase

from amaranth.sim import Simulator, Settle

from icicle.regs import RegisterFile


class RegisterFileTestCase(TestCase):
    def test_basic(self):
        m = RegisterFile()
        sim = Simulator(m)
        def process():
            # write initial data to regs 1 and 2
            yield m.rd_port.en.eq(1)
            yield m.rd_port.addr.eq(1)
            yield m.rd_port.data.eq(0x01234567)
            yield
            yield m.rd_port.en.eq(1)
            yield m.rd_port.addr.eq(2)
            yield m.rd_port.data.eq(0x89ABCDEF)
            yield

            # read regs 1 and 2 while simultaneously writing to reg 3
            yield m.rd_port.en.eq(1)
            yield m.rd_port.addr.eq(3)
            yield m.rd_port.data.eq(0xAA55AA55)
            yield m.rs1_port.en.eq(1)
            yield m.rs1_port.addr.eq(1)
            yield m.rs2_port.en.eq(1)
            yield m.rs2_port.addr.eq(2)
            yield
            yield Settle()
            self.assertEqual((yield m.rs1_port.data), 0x01234567)
            self.assertEqual((yield m.rs2_port.data), 0x89ABCDEF)

            # check the new value of reg 3
            yield m.rd_port.en.eq(0)
            yield m.rs1_port.addr.eq(3)
            yield
            yield Settle()
            self.assertEqual((yield m.rs1_port.data), 0xAA55AA55)

            # check that data is retained while the ports are disabled
            yield m.rs1_port.en.eq(0)
            yield m.rs2_port.en.eq(0)
            yield m.rs1_port.addr.eq(2)
            yield m.rs2_port.addr.eq(1)
            yield
            yield Settle()
            self.assertEqual((yield m.rs1_port.data), 0xAA55AA55)
            self.assertEqual((yield m.rs2_port.data), 0x89ABCDEF)

            # check that data is not changed if the rd port is disabled
            yield m.rs1_port.en.eq(1)
            yield m.rs1_port.addr.eq(2)
            yield m.rs2_port.en.eq(1)
            yield m.rs2_port.addr.eq(2)
            yield m.rd_port.addr.eq(2)
            yield m.rd_port.data.eq(0x55AA55AA)
            yield
            yield
            yield Settle()
            self.assertEqual((yield m.rs1_port.data), 0x89ABCDEF)
            self.assertEqual((yield m.rs2_port.data), 0x89ABCDEF)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()
