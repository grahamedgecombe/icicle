from amaranth import *
from amaranth_soc.csr import Element, Multiplexer


class GPIO(Elaboratable):
    def __init__(self):
        self._led_csr = Element(width=1, access="rw")
        self._mux = Multiplexer(addr_width=1, data_width=32)
        self._mux.add(self._led_csr)
        self.bus = self._mux.bus

    def elaborate(self, platform):
        m = Module()
        m.submodules.mux = self._mux

        led = platform.request("led", 0)

        m.d.comb += self._led_csr.r_data.eq(led.o)

        with m.If(self._led_csr.w_stb):
            m.d.sync += led.o.eq(self._led_csr.w_data)

        return m
