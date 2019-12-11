from functools import reduce
from itertools import tee
from operator import or_

from nmigen import *

VALID_LAYOUT = [
    ("valid",   1),
    ("trapped", 1)
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
                s2.rdata.eq(s1.wdata),
                s1.next_stall.eq(s2.stall)
            ]

        return m


class Stage(Elaboratable):
    def __init__(self, rdata_layout=None, wdata_layout=None):
        if rdata_layout:
            self.rdata = Record(rdata_layout + VALID_LAYOUT)
        if wdata_layout:
            self.wdata = Record(wdata_layout + VALID_LAYOUT)
        self.stall = Signal()
        self.next_stall = Signal()
        self.flush = Signal()
        self.valid_before = Signal()
        self.valid = Signal()
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

        rdata_valid = self.rdata.valid if hasattr(self, "rdata") else 1
        m.d.comb += [
            self.valid_before.eq(rdata_valid & ~self.flush),
            self.valid.eq(self.valid_before & ~self.trap)
        ]

        rdata_trapped = self.rdata.trapped if hasattr(self, "rdata") else 0
        m.d.comb += self.trapped.eq((rdata_trapped | self.trap) & ~self.flush)

        if hasattr(self, "wdata"):
            with m.If(~self.stall):
                m.d.sync += [
                    self.wdata.valid.eq(self.valid),
                    self.wdata.trapped.eq(self.trapped)
                ]
            with m.Elif(~self.next_stall):
                m.d.sync += [
                    self.wdata.valid.eq(0),
                    self.wdata.trapped.eq(0)
                ]

        if hasattr(self, "rdata") and hasattr(self, "wdata"):
            with m.If(~self.stall):
                for (name, shape, dir) in self.wdata.layout:
                    if name not in ("valid", "trapped") and name in self.rdata.layout.fields:
                        m.d.sync += self.wdata[name].eq(self.rdata[name])

        self.elaborate_stage(m, platform)

        m.d.comb += [
            self.stall.eq(((rdata_valid & reduce(or_, self._stall_sources, 0)) | self.next_stall) & ~self.flush),
            self.flush.eq(reduce(or_, self._flush_sources, 0)),
            self.trap.eq(rdata_valid & reduce(or_, self._trap_sources, 0))
        ]

        return m

    def elaborate_stage(self, m: Module, platform):
        pass
