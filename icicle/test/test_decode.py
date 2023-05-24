from unittest import TestCase

from amaranth import *
from amaranth.sim import Simulator, Settle

from icicle.decode import Decode
from icicle.pipeline import State


class DecodeTestCase(TestCase):
    def _create_decode(self, regs_init):
        m = Module()

        regs = Memory(width=32, depth=32, init=regs_init)
        rs1_port = m.submodules.rs1_port = regs.read_port(transparent=False)
        rs2_port = m.submodules.rs2_port = regs.read_port(transparent=False)

        decode = m.submodules.decode = Decode()
        m.d.comb += [
            rs1_port.en.eq(decode.rs1_port.en),
            rs1_port.addr.eq(decode.rs1_port.addr),
            decode.rs1_port.data.eq(rs1_port.data),

            rs2_port.en.eq(decode.rs2_port.en),
            rs2_port.addr.eq(decode.rs2_port.addr),
            decode.rs2_port.data.eq(rs2_port.data)
        ]

        return m, decode

    def test_basic(self):
        m, decode = self._create_decode(regs_init=[
            0x00000000,
            0x00112233,
            0x44556677,
            0x8899AABB,
            0xCCDDEEFF
        ])
        sim = Simulator(m)
        def process():
            yield decode.i.state.eq(State.VALID)
            yield decode.i.insn.eq(Cat(C(0, 7), C(0, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
            yield
            yield Settle()
            self.assertEqual((yield decode.o.rs1), 1)
            self.assertEqual((yield decode.o.rs1_rdata), 0x00112233)
            self.assertEqual((yield decode.o.rs2), 2)
            self.assertEqual((yield decode.o.rs2_rdata), 0x44556677)
            yield decode.i.insn.eq(Cat(C(0, 7), C(0, 5), C(0, 3), C(3, 5), C(4, 5), C(0, 7)))
            yield
            yield Settle()
            self.assertEqual((yield decode.o.rs1), 3)
            self.assertEqual((yield decode.o.rs1_rdata), 0x8899AABB)
            self.assertEqual((yield decode.o.rs2), 4)
            self.assertEqual((yield decode.o.rs2_rdata), 0xCCDDEEFF)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_stall(self):
        m, decode = self._create_decode(regs_init=[
            0x00000000,
            0x00112233,
            0x44556677,
            0x8899AABB,
            0xCCDDEEFF
        ])

        stall = Signal()
        decode.stall_on(stall)

        sim = Simulator(m)
        def process():
            yield decode.i.state.eq(State.VALID)
            yield decode.i.insn.eq(Cat(C(0, 7), C(0, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
            yield
            yield Settle()
            self.assertEqual((yield decode.o.rs1), 1)
            self.assertEqual((yield decode.o.rs1_rdata), 0x00112233)
            self.assertEqual((yield decode.o.rs2), 2)
            self.assertEqual((yield decode.o.rs2_rdata), 0x44556677)
            yield decode.i.insn.eq(Cat(C(0, 7), C(0, 5), C(0, 3), C(3, 5), C(4, 5), C(0, 7)))
            yield stall.eq(1)
            yield
            yield Settle()
            self.assertEqual((yield decode.o.rs1), 1)
            self.assertEqual((yield decode.o.rs1_rdata), 0x00112233)
            self.assertEqual((yield decode.o.rs2), 2)
            self.assertEqual((yield decode.o.rs2_rdata), 0x44556677)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()
