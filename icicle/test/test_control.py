from nmigen import *
from nmigen.back.pysim import Delay, Simulator
from nmigen.test.utils import FHDLTestCase

from icicle.control import Control
from icicle.riscv import Format, Opcode


class ControlTestCase(FHDLTestCase):
    def test_fmt(self):
        m = Control()
        with Simulator(m) as sim:
            def process():
                # R
                yield m.insn.eq(Cat(C(Opcode.OP, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.fmt), Format.R.value)

                # I
                yield m.insn.eq(Cat(C(Opcode.OP_IMM, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.fmt), Format.I.value)

                # S
                yield m.insn.eq(Cat(C(Opcode.STORE, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.fmt), Format.S.value)

                # B
                yield m.insn.eq(Cat(C(Opcode.BRANCH, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.fmt), Format.B.value)

                # U
                yield m.insn.eq(Cat(C(Opcode.LUI, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.fmt), Format.U.value)

                # J
                yield m.insn.eq(Cat(C(Opcode.JAL, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.fmt), Format.J.value)
            sim.add_process(process)
            sim.run()

    def test_regs(self):
        m = Control()
        with Simulator(m) as sim:
            def process():
                # R
                yield m.insn.eq(Cat(C(Opcode.OP, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd), 3)
                self.assertEqual((yield m.rd_wen), 1)
                self.assertEqual((yield m.rs1), 1)
                self.assertEqual((yield m.rs1_ren), 1)
                self.assertEqual((yield m.rs2), 2)
                self.assertEqual((yield m.rs2_ren), 1)

                # I
                yield m.insn.eq(Cat(C(Opcode.OP_IMM, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd), 3)
                self.assertEqual((yield m.rd_wen), 1)
                self.assertEqual((yield m.rs1), 1)
                self.assertEqual((yield m.rs1_ren), 1)
                self.assertEqual((yield m.rs2_ren), 0)

                # S
                yield m.insn.eq(Cat(C(Opcode.STORE, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd_wen), 0)
                self.assertEqual((yield m.rs1), 1)
                self.assertEqual((yield m.rs1_ren), 1)
                self.assertEqual((yield m.rs2), 2)
                self.assertEqual((yield m.rs2_ren), 1)

                # B
                yield m.insn.eq(Cat(C(Opcode.BRANCH, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd_wen), 0)
                self.assertEqual((yield m.rs1), 1)
                self.assertEqual((yield m.rs1_ren), 1)
                self.assertEqual((yield m.rs2), 2)
                self.assertEqual((yield m.rs2_ren), 1)

                # U
                yield m.insn.eq(Cat(C(Opcode.LUI, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd), 3)
                self.assertEqual((yield m.rd_wen), 1)
                self.assertEqual((yield m.rs1_ren), 0)
                self.assertEqual((yield m.rs2_ren), 0)

                # J
                yield m.insn.eq(Cat(C(Opcode.JAL, 7), C(3, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd), 3)
                self.assertEqual((yield m.rd_wen), 1)
                self.assertEqual((yield m.rs1_ren), 0)
                self.assertEqual((yield m.rs2_ren), 0)

                # rd zero
                yield m.insn.eq(Cat(C(Opcode.OP, 7), C(0, 5), C(0, 3), C(1, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd), 0)
                self.assertEqual((yield m.rd_wen), 0)
                self.assertEqual((yield m.rs1), 1)
                self.assertEqual((yield m.rs1_ren), 1)
                self.assertEqual((yield m.rs2), 2)
                self.assertEqual((yield m.rs2_ren), 1)

                # rs1 zero
                yield m.insn.eq(Cat(C(Opcode.OP, 7), C(3, 5), C(0, 3), C(0, 5), C(2, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd), 3)
                self.assertEqual((yield m.rd_wen), 1)
                self.assertEqual((yield m.rs1), 0)
                self.assertEqual((yield m.rs1_ren), 0)
                self.assertEqual((yield m.rs2), 2)
                self.assertEqual((yield m.rs2_ren), 1)

                # rs2 zero
                yield m.insn.eq(Cat(C(Opcode.OP, 7), C(3, 5), C(0, 3), C(1, 5), C(0, 5), C(0, 7)))
                yield Delay()
                self.assertEqual((yield m.rd), 3)
                self.assertEqual((yield m.rd_wen), 1)
                self.assertEqual((yield m.rs1), 1)
                self.assertEqual((yield m.rs1_ren), 1)
                self.assertEqual((yield m.rs2), 0)
                self.assertEqual((yield m.rs2_ren), 0)
            sim.add_process(process)
            sim.run()
