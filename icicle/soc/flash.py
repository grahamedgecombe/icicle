from math import ceil

from amaranth import *
from amaranth_soc.memory import MemoryMap
from amaranth_soc.wishbone import Interface


class Flash(Elaboratable):
    def __init__(self, addr_width, number=0):
        self.addr_width = addr_width
        self.number = number

        self.bus = Interface(addr_width=addr_width, data_width=32, granularity=8, features=["err"])
        memory_map = MemoryMap(addr_width=addr_width + 2, data_width=8)
        memory_map.add_resource(self, name="flash", size=2 ** memory_map.addr_width)
        self.bus.memory_map = memory_map

    def elaborate(self, platform):
        m = Module()

        flash = platform.request("spi_flash_1x", self.number, xdr={"clk": 2, "cs": 1, "copi": 1, "cipo": 2})
        m.d.comb += [
            flash.clk.o_clk.eq(ClockSignal()),
            flash.clk.o0.eq(0),
            flash.clk.o1.eq(1),

            flash.cs.o_clk.eq(ClockSignal()),
            flash.copi.o_clk.eq(ClockSignal()),
            flash.cipo.i_clk.eq(ClockSignal()),
        ]

        buffer = Signal(31)
        n = Signal(range(32))
        power_up_timer = Signal(range(int(ceil(platform.default_clk_frequency * 3e-6))))

        m.d.sync += [
            self.bus.ack.eq(0),
            self.bus.err.eq(0),
        ]

        with m.FSM():
            with m.State("START"):
                m.next = "POWER_UP_FIRST"

            with m.State("POWER_UP_FIRST"):
                m.d.comb += [
                    flash.cs.o.eq(1),
                    flash.copi.o.eq(1),
                ]
                m.d.sync += [
                    buffer.eq(Cat(C(0, 24), C(0x2B, 7))),
                    n.eq(7),
                ]
                m.next = "POWER_UP"

            with m.State("POWER_UP"):
                with m.If(n.bool()):
                    m.d.comb += [
                        flash.cs.o.eq(1),
                        flash.copi.o.eq(buffer[30]),
                    ]
                    m.d.sync += [
                        buffer.eq(buffer << 1),
                        n.eq(n - 1),
                    ]
                with m.Else():
                    m.d.sync += power_up_timer.eq(-1)
                    m.next = "WAIT_FOR_POWER_UP"

            with m.State("WAIT_FOR_POWER_UP"):
                with m.If(power_up_timer.bool()):
                    m.d.sync += power_up_timer.eq(power_up_timer - 1)
                with m.Else():
                    m.next = "IDLE"

            with m.State("IDLE"):
                with m.If(self.bus.cyc & self.bus.stb & ~(self.bus.ack | self.bus.err)):
                    with m.If(self.bus.we):
                        m.d.sync += self.bus.err.eq(1)
                    with m.Else():
                        m.d.comb += [
                            flash.cs.o.eq(1),
                            flash.copi.o.eq(0),
                        ]
                        m.d.sync += [
                            buffer.eq(Cat(C(0, 2), self.bus.adr, C(0x03, 7))),
                            n.eq(31),
                        ]
                        m.next = "COMMAND"

            with m.State("COMMAND"):
                with m.If(self.bus.cyc & self.bus.stb):
                    m.d.comb += flash.cs.o.eq(1)

                    with m.If(n.bool()):
                        m.d.comb += flash.copi.o.eq(buffer[30]),
                        m.d.sync += [
                            buffer.eq(buffer << 1),
                            n.eq(n - 1),
                        ]
                    with m.Else():
                        m.d.sync += n.eq(31)
                        m.next = "DATA_FIRST"
                with m.Else():
                    m.next = "IDLE"

            with m.State("DATA_FIRST"):
                with m.If(self.bus.cyc & self.bus.stb):
                    m.d.comb += flash.cs.o.eq(1)
                    m.next = "DATA"
                with m.Else():
                    m.next = "IDLE"

            with m.State("DATA"):
                with m.If(self.bus.cyc & self.bus.stb):
                    with m.If(n.bool()):
                        m.d.comb += flash.cs.o.eq(n != 1)
                        m.d.sync += [
                            buffer.eq(Cat(flash.cipo.i1, buffer[0:31])),
                            n.eq(n - 1),
                        ]
                    with m.Else():
                        m.d.sync += [
                            self.bus.ack.eq(1),
                            self.bus.dat_r.eq(Cat(buffer[23:31], buffer[15:23], buffer[7:15], flash.cipo.i1, buffer[0:7]))
                        ]
                        m.next = "IDLE"
                with m.Else():
                    m.next = "IDLE"

        return m
