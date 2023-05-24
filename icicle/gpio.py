from amaranth import *
from amaranth.utils import bits_for
from amaranth_soc.csr import Element, Multiplexer


class GPIO(Elaboratable):
    def __init__(self, numbers, addr_width=None):
        self._oe_csr = Element(width=len(numbers), access="rw")
        self._i_csr = Element(width=len(numbers), access="r")
        self._o_csr = Element(width=len(numbers), access="rw")

        if addr_width is None:
            addr_width = bits_for(((len(numbers) + 7) // 8) * 3)

        self._mux = Multiplexer(addr_width=addr_width, data_width=8)
        self._mux.add(self._oe_csr)
        self._mux.add(self._i_csr)
        self._mux.add(self._o_csr)

        self.bus = self._mux.bus
        self.numbers = numbers

    def elaborate(self, platform):
        m = Module()
        m.submodules.mux = self._mux

        for i, number in enumerate(self.numbers):
            gpio = platform.request("gpio", number)

            m.d.comb += [
                self._oe_csr.r_data[i].eq(gpio.oe),
                self._i_csr.r_data[i].eq(gpio.i),
                self._o_csr.r_data[i].eq(gpio.o),
            ]

            with m.If(self._oe_csr.w_stb):
                m.d.sync += gpio.oe.eq(self._oe_csr.w_data[i])

            with m.If(self._o_csr.w_stb):
                m.d.sync += gpio.o.eq(self._o_csr.w_data[i])

        return m
