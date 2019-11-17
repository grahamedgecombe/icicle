from nmigen import *

from icicle.riscv import Format


class ImmediateDecoder(Elaboratable):
    def __init__(self):
        self.insn = Signal(32)
        self.fmt = Signal(Format)
        self.imm = Signal(32)

    def elaborate(self, platform):
        m = Module()

        sign = Signal()
        imm_i = Signal(32)
        imm_s = Signal(32)
        imm_b = Signal(32)
        imm_u = Signal(32)
        imm_j = Signal(32)
        m.d.comb += [
            sign.eq(self.insn[31]),
            imm_i.eq(Cat(self.insn[20], self.insn[21:25], self.insn[25:31], Repl(sign, 21))),
            imm_s.eq(Cat(self.insn[7], self.insn[8:12], self.insn[25:31], Repl(sign, 21))),
            imm_b.eq(Cat(C(0, 1), self.insn[8:12], self.insn[25:31], self.insn[7], Repl(sign, 20))),
            imm_u.eq(Cat(C(0, 12), self.insn[12:20], self.insn[20:31], sign)),
            imm_j.eq(Cat(C(0, 1), self.insn[21:25], self.insn[25:31], self.insn[20], self.insn[12:20], Repl(sign, 12)))
        ]

        with m.Switch(self.fmt):
            with m.Case(Format.I, Format.Z):
                m.d.comb += self.imm.eq(imm_i)
            with m.Case(Format.S):
                m.d.comb += self.imm.eq(imm_s)
            with m.Case(Format.B):
                m.d.comb += self.imm.eq(imm_b)
            with m.Case(Format.U):
                m.d.comb += self.imm.eq(imm_u)
            with m.Case(Format.J):
                m.d.comb += self.imm.eq(imm_j)

        return m
