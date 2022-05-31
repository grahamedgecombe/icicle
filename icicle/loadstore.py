from enum import Enum

from amaranth import *
from amaranth_soc import wishbone


class MemWidth(Enum):
    BYTE = 0
    HALF = 1
    WORD = 2


class WordAlign(Elaboratable):
    def __init__(self):
        self.width = Signal(MemWidth)
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
            with m.Case(MemWidth.BYTE):
                m.d.comb += [
                    self.mask.eq(0b1 << offset),
                    self.wdata_aligned.eq(self.wdata << (offset * 8)),
                    self.rdata.eq(Cat(byte, Repl(Mux(self.unsigned, 0, byte[7]), 24)))
                ]
            with m.Case(MemWidth.HALF):
                m.d.comb += [
                    self.misaligned.eq(offset[0]),
                    self.mask.eq(0b11 << offset),
                    self.wdata_aligned.eq(self.wdata << (offset[1] * 16)),
                    self.rdata.eq(Cat(half, Repl(Mux(self.unsigned, 0, half[15]), 16)))
                ]
            with m.Case(MemWidth.WORD):
                m.d.comb += [
                    self.misaligned.eq(offset.bool()),
                    self.mask.eq(0b1111),
                    self.wdata_aligned.eq(self.wdata),
                    self.rdata.eq(self.rdata_aligned)
                ]

        return m


class LoadStore(Elaboratable):
    def __init__(self):
        self.bus = wishbone.Interface(addr_width=30, data_width=32, granularity=8, features=["err"])
        self.valid = Signal()
        self.busy = Signal()
        self.trap = Signal()
        self.load = Signal()
        self.store = Signal()
        self.width = Signal(MemWidth)
        self.unsigned = Signal()
        self.addr = Signal(32)
        self.rdata = Signal(32)
        self.wdata = Signal(32)
        self.addr_aligned = Signal(32)
        self.rdata_aligned = Signal(32)
        self.wdata_aligned = Signal(32)
        self.mask = Signal(4)
        self.misaligned = Signal()
        self.fault = Signal()

    def elaborate(self, platform):
        m = Module()

        # mask, shift and optionally sign-extend bytes and half-words, as the
        # wishbone bus is only capable of loading or storing a single word at a
        # time
        word_align = m.submodules.word_align = WordAlign()
        m.d.comb += [
            word_align.width.eq(self.width),
            word_align.unsigned.eq(self.unsigned),
            word_align.addr.eq(self.addr),
            self.rdata.eq(word_align.rdata),
            word_align.wdata.eq(self.wdata),
            self.misaligned.eq(word_align.misaligned),

            # RVFI expects the word-aligned address and data
            self.addr_aligned.eq(word_align.addr_aligned),
            self.rdata_aligned.eq(word_align.rdata_aligned),
            self.wdata_aligned.eq(word_align.wdata_aligned),
            self.mask.eq(word_align.mask)
        ]

        # wishbone outputs
        m.d.comb += [
            self.bus.adr.eq(word_align.addr_aligned[2:32]),
            self.bus.dat_w.eq(word_align.wdata_aligned),
            self.bus.sel.eq(word_align.mask),
            self.bus.cyc.eq(self.valid & (self.load | self.store) & ~self.misaligned),
            self.bus.stb.eq(self.bus.cyc),
            self.bus.we.eq(self.store)
        ]

        # wishbone inputs
        m.d.comb += [
            self.busy.eq(self.bus.cyc & self.bus.stb & ~(self.bus.ack | self.bus.err)),
            self.fault.eq(self.bus.cyc & self.bus.stb & self.bus.err),
            word_align.rdata_aligned.eq(self.bus.dat_r)
        ]

        m.d.comb += self.trap.eq((self.load | self.store) & (self.misaligned | self.fault))

        return m
