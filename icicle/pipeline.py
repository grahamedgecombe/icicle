from functools import reduce
from itertools import tee
from operator import or_

from amaranth import *

VALID_LAYOUT = [
    ("insn_valid", 1),
    ("trapped",    1)
]


class Pipeline(Elaboratable):
    def __init__(self, **stages):
        self.stages = stages

    def elaborate(self, platform):
        m = Module()

        for name, stage in self.stages.items():
            m.submodules[name] = stage

        it1, it2 = tee(self.stages.values())
        next(it2)
        for s1, s2 in zip(it1, it2):
            m.d.comb += [
                s2.i.eq(s1.o),
                s1.next_stall.eq(s2.stall)
            ]

        return m


class Stage(Elaboratable):
    def __init__(self, i_layout=None, o_layout=None):
        if i_layout:
            self.i = Record(i_layout + VALID_LAYOUT)
        if o_layout:
            self.o = Record(o_layout + VALID_LAYOUT)
        self.stall = Signal()
        self.next_stall = Signal()
        self.flush = Signal()
        self.insn_valid_before = Signal()
        self.insn_valid = Signal()
        self.trap = Signal()
        self.trapped = Signal()
        self._stall_sources = []
        self._flush_sources = []
        self._trap_sources = []

    def stall_on(self, source):
        self._stall_sources.append(source)

    def flush_on(self, source):
        self._flush_sources.append(source)

    def trap_on(self, source):
        self._trap_sources.append(source)

    def elaborate(self, platform):
        m = Module()

        i_insn_valid = self.i.insn_valid if hasattr(self, "i") else 1
        m.d.comb += [
            self.insn_valid_before.eq(i_insn_valid & ~self.flush),
            self.insn_valid.eq(self.insn_valid_before & ~self.trap)
        ]

        i_trapped = self.i.trapped if hasattr(self, "i") else 0
        m.d.comb += self.trapped.eq((i_trapped | self.trap) & ~self.flush)

        if hasattr(self, "o"):
            with m.If(~self.stall):
                m.d.sync += [
                    self.o.insn_valid.eq(self.insn_valid),
                    self.o.trapped.eq(self.trapped)
                ]
            with m.Elif(~self.next_stall):
                m.d.sync += [
                    self.o.insn_valid.eq(0),
                    self.o.trapped.eq(0)
                ]

        if hasattr(self, "i") and hasattr(self, "o"):
            with m.If(~self.stall):
                for (name, shape, dir) in self.o.layout:
                    if name not in ("valid", "trapped") and name in self.i.layout.fields:
                        m.d.sync += self.o[name].eq(self.i[name])

        self.elaborate_stage(m, platform)

        m.d.comb += [
            self.stall.eq(((i_insn_valid & reduce(or_, self._stall_sources, 0)) | self.next_stall) & ~self.flush),
            self.flush.eq(reduce(or_, self._flush_sources, 0)),
            self.trap.eq(i_insn_valid & reduce(or_, self._trap_sources, 0))
        ]

        return m

    def elaborate_stage(self, m: Module, platform):
        pass
