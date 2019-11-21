from nmigen import *
from nmigen.hdl.ast import AnySeq
from nmigen.hdl.rec import *

RS_PORT_LAYOUT = [
    ("en",    1, DIR_FANOUT),
    ("addr",  5, DIR_FANOUT),
    ("data", 32, DIR_FANIN)
]

RD_PORT_LAYOUT = [
    ("en",    1, DIR_FANOUT),
    ("addr",  5, DIR_FANOUT),
    ("data", 32, DIR_FANOUT)
]


class RegisterFile(Elaboratable):
    def __init__(self):
        self.rs1_port = Record(RS_PORT_LAYOUT)
        self.rs2_port = Record(RS_PORT_LAYOUT)
        self.rd_port = Record(RD_PORT_LAYOUT)

    def elaborate(self, platform):
        m = Module()

        regs = Memory(width=32, depth=32)
        rs1_port = m.submodules.rs1_port = regs.read_port(transparent=False)
        rs2_port = m.submodules.rs2_port = regs.read_port(transparent=False)
        rd_port = m.submodules.rd_port = regs.write_port()

        m.d.comb += [
            rs1_port.en.eq(self.rs1_port.en),
            rs1_port.addr.eq(self.rs1_port.addr),
            self.rs1_port.data.eq(rs1_port.data),

            rs2_port.en.eq(self.rs2_port.en),
            rs2_port.addr.eq(self.rs2_port.addr),
            self.rs2_port.data.eq(rs2_port.data),

            rd_port.en.eq(self.rd_port.en),
            rd_port.addr.eq(self.rd_port.addr),
            rd_port.data.eq(self.rd_port.data)
        ]

        return m


class BlackBoxRegisterFile(Elaboratable):
    def __init__(self):
        self.rs1_port = Record(RS_PORT_LAYOUT)
        self.rs2_port = Record(RS_PORT_LAYOUT)
        self.rd_port = Record(RD_PORT_LAYOUT)

    def elaborate(self, platform):
        m = Module()

        with m.If(self.rs1_port.en):
            m.d.sync += self.rs1_port.data.eq(Mux(self.rs1_port.addr != 0, AnySeq(32), 0))

        with m.If(self.rs2_port.en):
            m.d.sync += self.rs2_port.data.eq(Mux(self.rs2_port.addr != 0, AnySeq(32), 0))

        return m
