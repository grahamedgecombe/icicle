from enum import Enum
from functools import reduce
from itertools import tee
from operator import or_

from amaranth import *


class State(Enum):
    BUBBLE = 0
    VALID  = 1
    TRAP   = 2


STATE_LAYOUT = [
    ("state", State),
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
            self.i = Record(i_layout + STATE_LAYOUT)
        if o_layout:
            self.o = Record(o_layout + STATE_LAYOUT)
        self.stall = Signal()
        self.next_stall = Signal()
        self.flush = Signal()
        self.trap = Signal()
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

        i_state = self.i.state if hasattr(self, "i") else State.VALID

        if hasattr(self, "o"):
            with m.If(~self.stall):
                with m.If(self.flush):
                    m.d.sync += self.o.state.eq(State.BUBBLE)
                with m.Elif(self.trap):
                    m.d.sync += self.o.state.eq(State.TRAP)
                with m.Else():
                    m.d.sync += self.o.state.eq(i_state)
            with m.Elif(~self.next_stall):
                m.d.sync += self.o.state.eq(State.BUBBLE)

        if hasattr(self, "i") and hasattr(self, "o"):
            with m.If(~self.stall):
                for (name, shape, dir) in self.o.layout:
                    if name != "state" and name in self.i.layout.fields:
                        m.d.sync += self.o[name].eq(self.i[name])

        self.elaborate_stage(m, platform)

        m.d.comb += [
            self.stall.eq((((i_state == State.VALID) & reduce(or_, self._stall_sources, 0)) | self.next_stall) & ~self.flush),
            self.flush.eq(reduce(or_, self._flush_sources, 0)),
            self.trap.eq((i_state == State.TRAP) | ((i_state == State.VALID) & reduce(or_, self._trap_sources, 0)))
        ]

        return m

    def elaborate_stage(self, m: Module, platform):
        pass
