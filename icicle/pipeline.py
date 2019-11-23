from functools import reduce
from itertools import tee
from operator import or_

from nmigen import *

VALID_LAYOUT = [
    ("valid", 1)
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
            s1.stall_on(s2.stall)
            s2.flush_on(s1.stall & ~s2.stall)
            m.d.comb += s2.rdata.eq(s1.wdata)

        return m


class Stage(Elaboratable):
    def __init__(self, rdata_layout=None, wdata_layout=None):
        self.rdata = Record(rdata_layout + VALID_LAYOUT) if rdata_layout is not None else None
        self.wdata = Record(wdata_layout + VALID_LAYOUT) if wdata_layout is not None else None
        self.stall = Signal()
        self.flush = Signal()
        self.valid = Signal()
        self._stall_sources = []
        self._flush_sources = []

    def stall_on(self, source):
        self._stall_sources.append(source)

    def flush_on(self, source):
        self._flush_sources.append(source)

    def elaborate(self, platform):
        m = Module()

        m.d.comb += [
            self.stall.eq(reduce(or_, self._stall_sources, 0)),
            self.flush.eq(reduce(or_, self._flush_sources, 0))
        ]

        if self.rdata is not None:
            m.d.comb += self.valid.eq(self.rdata.valid)
        else:
            m.d.comb += self.valid.eq(1)

        if self.wdata is not None:
            with m.If(~self.stall):
                m.d.sync += self.wdata.valid.eq(self.valid)
            with m.If(self.flush):
                m.d.sync += self.wdata.valid.eq(0)

        if self.rdata is not None and self.wdata is not None:
            with m.If(~self.stall):
                for (name, shape, dir) in self.wdata.layout:
                    if name != "valid" and name in self.rdata.layout.fields:
                        m.d.sync += self.wdata[name].eq(self.rdata[name])

        return m
