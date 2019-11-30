from nmigen import *
from nmigen.back.pysim import Simulator, Delay
from nmigen.test.utils import FHDLTestCase

from icicle.imm import ImmediateDecoder
from icicle.riscv import Format, Opcode


class ImmediateDecoderTestCase(FHDLTestCase):
    def test_basic(self):
        m = ImmediateDecoder()
        sim = Simulator(m)
        def process():
            # I
            yield m.insn.eq(Cat(C(Opcode.OP_IMM, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b0, 1)))
            yield m.fmt.eq(Format.I)
            yield Delay()
            self.assertEqual((yield m.imm), 0b000000000000000000000_111110_11110)

            yield m.insn.eq(Cat(C(Opcode.OP_IMM, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b1, 1)))
            yield m.fmt.eq(Format.I)
            yield Delay()
            self.assertEqual((yield m.imm), 0b111111111111111111111_111110_11110)

            # S
            yield m.insn.eq(Cat(C(Opcode.STORE, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b0, 1)))
            yield m.fmt.eq(Format.S)
            yield Delay()
            self.assertEqual((yield m.imm), 0b000000000000000000000_111110_11000)

            yield m.insn.eq(Cat(C(Opcode.STORE, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b1, 1)))
            yield m.fmt.eq(Format.S)
            yield Delay()
            self.assertEqual((yield m.imm), 0b111111111111111111111_111110_11000)

            # B
            yield m.insn.eq(Cat(C(Opcode.BRANCH, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b0, 1)))
            yield m.fmt.eq(Format.B)
            yield Delay()
            self.assertEqual((yield m.imm), 0b00000000000000000000_0_111110_1100_0)

            yield m.insn.eq(Cat(C(Opcode.BRANCH, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b1, 1)))
            yield m.fmt.eq(Format.B)
            yield Delay()
            self.assertEqual((yield m.imm), 0b11111111111111111111_0_111110_1100_0)

            yield m.insn.eq(Cat(C(Opcode.BRANCH, 7), C(0b11001, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b0, 1)))
            yield m.fmt.eq(Format.B)
            yield Delay()
            self.assertEqual((yield m.imm), 0b00000000000000000000_1_111110_1100_0)

            yield m.insn.eq(Cat(C(Opcode.BRANCH, 7), C(0b11001, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b1, 1)))
            yield m.fmt.eq(Format.B)
            yield Delay()
            self.assertEqual((yield m.imm), 0b11111111111111111111_1_111110_1100_0)

            # U
            yield m.insn.eq(Cat(C(Opcode.LUI, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b0, 1)))
            yield m.fmt.eq(Format.U)
            yield Delay()
            self.assertEqual((yield m.imm), 0b01111101111011100100_000000000000)

            yield m.insn.eq(Cat(C(Opcode.LUI, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b1, 1)))
            yield m.fmt.eq(Format.U)
            yield Delay()
            self.assertEqual((yield m.imm), 0b11111101111011100100_000000000000)

            # J
            yield m.insn.eq(Cat(C(Opcode.JAL, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b0, 1)))
            yield m.fmt.eq(Format.J)
            yield Delay()
            self.assertEqual((yield m.imm), 0b000000000000_11100_100_0_111110_1111_0)

            yield m.insn.eq(Cat(C(Opcode.JAL, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11110, 5), C(0b111110, 6), C(0b1, 1)))
            yield m.fmt.eq(Format.J)
            yield Delay()
            self.assertEqual((yield m.imm), 0b111111111111_11100_100_0_111110_1111_0)

            yield m.insn.eq(Cat(C(Opcode.JAL, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11111, 5), C(0b111110, 6), C(0b0, 1)))
            yield m.fmt.eq(Format.J)
            yield Delay()
            self.assertEqual((yield m.imm), 0b000000000000_11100_100_1_111110_1111_0)

            yield m.insn.eq(Cat(C(Opcode.JAL, 7), C(0b11000, 5), C(0b100, 3), C(0b11100, 5), C(0b11111, 5), C(0b111110, 6), C(0b1, 1)))
            yield m.fmt.eq(Format.J)
            yield Delay()
            self.assertEqual((yield m.imm), 0b111111111111_11100_100_1_111110_1111_0)
        sim.add_process(process)
        sim.run()
