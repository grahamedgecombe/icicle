from amaranth import *
from amaranth.lib.fifo import SyncFIFOBuffered
from amaranth_soc.csr import Element, Multiplexer
from amaranth_stdio.serial import AsyncSerial


class UART(Elaboratable):
    def __init__(self, number=0, fifo_depth=513, default_baud=9600):
        self._clk_div_csr = Element(width=16, access="rw")
        self._status_csr = Element(width=2, access="r")
        self._data_csr = Element(width=8, access="rw")

        self._mux = Multiplexer(addr_width=2, data_width=8)
        self._mux.add(self._clk_div_csr)
        self._mux.add(self._status_csr)
        self._mux.add(self._data_csr)

        self.bus = self._mux.bus
        self.number = number
        self.fifo_depth = fifo_depth
        self.default_baud = default_baud

    def elaborate(self, platform):
        m = Module()
        m.submodules.mux = self._mux

        serial = m.submodules.serial = AsyncSerial(
            divisor=int(platform.default_clk_frequency // self.default_baud),
            divisor_bits=self._clk_div_csr.width,
            data_bits=self._data_csr.width,
            pins=platform.request("uart", self.number),
        )
        rx_fifo = m.submodules.rx_fifo = SyncFIFOBuffered(width=self._data_csr.width, depth=self.fifo_depth)
        tx_fifo = m.submodules.tx_fifo = SyncFIFOBuffered(width=self._data_csr.width, depth=self.fifo_depth)

        # serial <-> RX FIFO
        m.d.comb += [
            rx_fifo.w_data.eq(serial.rx.data),
            rx_fifo.w_en.eq(serial.rx.rdy & serial.rx.ack),
            serial.rx.ack.eq(rx_fifo.w_rdy),
        ]

        # serial <-> TX FIFO
        m.d.comb += [
            serial.tx.data.eq(tx_fifo.r_data),
            tx_fifo.r_en.eq(serial.tx.rdy & serial.tx.ack),
            serial.tx.ack.eq(tx_fifo.r_rdy),
        ]

        # clock divisor
        m.d.comb += self._clk_div_csr.r_data.eq(serial.divisor)

        with m.If(self._clk_div_csr.w_stb):
            m.d.sync += serial.divisor.eq(self._clk_div_csr.w_data)

        # status
        m.d.comb += self._status_csr.r_data.eq(Cat(rx_fifo.r_rdy, tx_fifo.w_rdy))

        # RX FIFO <-> data
        m.d.comb += [
            self._data_csr.r_data.eq(rx_fifo.r_data),
            rx_fifo.r_en.eq(self._data_csr.r_stb),
        ]

        # TX FIFO <-> data
        m.d.comb += [
            tx_fifo.w_data.eq(self._data_csr.w_data),
            tx_fifo.w_en.eq(self._data_csr.w_stb),
        ]

        return m
