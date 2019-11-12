from nmigen import *


class Control(Elaboratable):
    def __init__(self):
        self.insn = Signal(32)
        self.rd = Signal(5)
        self.rd_wen = Signal()
        self.rs1 = Signal(5)
        self.rs1_ren = Signal()
        self.rs2 = Signal(5)
        self.rs2_ren = Signal()

    def elaborate(self, platform):
        m = Module()

        opcode = Signal(7)
        funct3 = Signal(3)
        funct7 = Signal(7)
        m.d.comb += Cat(opcode, self.rd, funct3, self.rs1, self.rs2, funct7).eq(self.insn)

        return m
