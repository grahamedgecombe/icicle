from enum import Enum

from nmigen import *


class Width(Enum):
    BYTE = 0
    HALF = 1
    WORD = 2


class WordAlign(Elaboratable):
    def __init__(self):
        self.width = Signal(Width)
        self.unsigned = Signal()
        self.addr = Signal(32)
        self.rdata = Signal(32)
        self.wdata = Signal(32)
        self.addr_aligned = Signal(32)
        self.rdata_aligned = Signal(32)
        self.wdata_aligned = Signal(32)
        self.mask = Signal(4)
        self.misaligned = Signal()

    def elaborate(self, platform):
        m = Module()

        offset = Signal(2)
        m.d.comb += [
            offset.eq(self.addr[0:2]),
            self.addr_aligned.eq(Cat(C(0, 2), self.addr[2:32]))
        ]

        byte = Signal(8)
        half = Signal(16)
        m.d.comb += [
            byte.eq(self.rdata_aligned >> (offset * 8)),
            half.eq(self.rdata_aligned >> (offset[1] * 16))
        ]

        with m.Switch(self.width):
            with m.Case(Width.BYTE):
                m.d.comb += [
                    self.mask.eq(0b1 << offset),
                    self.wdata_aligned.eq(self.wdata << (offset * 8)),
                    self.rdata.eq(Cat(byte, Repl(Mux(self.unsigned, 0, byte[7]), 24)))
                ]
            with m.Case(Width.HALF):
                m.d.comb += [
                    self.misaligned.eq(offset[0]),
                    self.mask.eq(0b11 << offset),
                    self.wdata_aligned.eq(self.wdata << (offset[1] * 16)),
                    self.rdata.eq(Cat(half, Repl(Mux(self.unsigned, 0, half[15]), 16)))
                ]
            with m.Case(Width.WORD):
                m.d.comb += [
                    self.misaligned.eq(offset != 0),
                    self.mask.eq(0b1111),
                    self.wdata_aligned.eq(self.wdata),
                    self.rdata.eq(self.rdata_aligned)
                ]

        return m
