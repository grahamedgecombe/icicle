from amaranth import *
from amaranth_soc.csr.bus import Decoder as CSRDecoder
from amaranth_soc.csr.wishbone import WishboneCSRBridge
from amaranth_soc.wishbone import Arbiter as WishboneArbiter, Decoder as WishboneDecoder

from icicle.cpu import CPU
from icicle.soc.flash import Flash
from icicle.soc.gpio import GPIO
from icicle.soc.ice40_spram import ICE40SPRAM
from icicle.soc.uart import UART


class SystemOnChip(Elaboratable):
    def elaborate(self, platform):
        m = Module()

        cpu = m.submodules.cpu = CPU(reset_vector=0x00100000, trap_vector=0x00100000)

        flash = m.submodules.flash = Flash(addr_width=22)
        ram = m.submodules.ram = ICE40SPRAM()

        gpio = m.submodules.gpio = GPIO(numbers=range(3))
        uart = m.submodules.uart = UART()

        csr_decoder = m.submodules.csr_decoder = CSRDecoder(addr_width=16, data_width=8)
        csr_decoder.add(gpio.bus, addr=0x0000)
        csr_decoder.add(uart.bus, addr=0x0004)
        csr_bridge = m.submodules.csr_bridge = WishboneCSRBridge(csr_decoder.bus, data_width=32)

        decoder = m.submodules.decoder = WishboneDecoder(addr_width=30, data_width=32, granularity=8, features=["err"])
        decoder.add(flash.bus,         addr=0x00000000)
        decoder.add(ram.bus,           addr=0x40000000)
        decoder.add(csr_bridge.wb_bus, addr=0x80000000)

        arbiter = m.submodules.arbiter = WishboneArbiter(addr_width=30, data_width=32, granularity=8, features=["err"])
        arbiter.add(cpu.ibus)
        arbiter.add(cpu.dbus)
        m.d.comb += arbiter.bus.connect(decoder.bus)

        return m
