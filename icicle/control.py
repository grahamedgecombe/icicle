from functools import reduce
from operator import or_

from nmigen import *

from icicle.riscv import Format, Opcode


class Control(Elaboratable):
    def __init__(self):
        self.insn = Signal(32)
        self.rd = Signal(5)
        self.rd_wen = Signal()
        self.rs1 = Signal(5)
        self.rs1_ren = Signal()
        self.rs2 = Signal(5)
        self.rs2_ren = Signal()
        self.fmt = Signal(Format)

    def elaborate(self, platform):
        m = Module()

        opcode = Signal(7)
        funct3 = Signal(3)
        funct7 = Signal(7)
        m.d.comb += Cat(opcode, self.rd, funct3, self.rs1, self.rs2, funct7).eq(self.insn)

        with m.Switch(opcode):
            with m.Case(Opcode.LUI):
                m.d.comb += self.fmt.eq(Format.U)
            with m.Case(Opcode.AUIPC):
                m.d.comb += self.fmt.eq(Format.U)
            with m.Case(Opcode.JAL):
                m.d.comb += self.fmt.eq(Format.J)
            with m.Case(Opcode.JALR):
                m.d.comb += self.fmt.eq(Format.I)
            with m.Case(Opcode.BRANCH):
                m.d.comb += self.fmt.eq(Format.B)
            with m.Case(Opcode.LOAD):
                m.d.comb += self.fmt.eq(Format.I)
            with m.Case(Opcode.STORE):
                m.d.comb += self.fmt.eq(Format.S)
            with m.Case(Opcode.OP_IMM):
                m.d.comb += self.fmt.eq(Format.I)
            with m.Case(Opcode.OP):
                m.d.comb += self.fmt.eq(Format.R)
            with m.Case(Opcode.MISC_MEM):
                m.d.comb += self.fmt.eq(Format.I)
            with m.Case(Opcode.SYSTEM):
                # TODO(gpe): the CSRR[WSC]I instructions are a special case:
                # the rs1 bits can be non-zero (they are used as zimm) but we
                # still enable rs1_ren, so we'll needlessly bypass or interlock
                # in the future - should we add a special Format.Z type?
                m.d.comb += self.fmt.eq(Format.I)

        def format_in(*list):
            return reduce(or_, (self.fmt == f for f in list), 0)

        m.d.comb += [
            self.rd_wen.eq((self.rd != 0) & format_in(Format.R, Format.I, Format.U, Format.J)),
            self.rs1_ren.eq((self.rs1 != 0) & format_in(Format.R, Format.I, Format.S, Format.B)),
            self.rs2_ren.eq((self.rs2 != 0) & format_in(Format.R, Format.S, Format.B))
        ]

        return m
