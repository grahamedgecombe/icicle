from amaranth import *
from amaranth_soc.csr.bus import Decoder as CSRDecoder
from amaranth_soc.csr.wishbone import WishboneCSRBridge
from amaranth_soc.wishbone import Arbiter as WishboneArbiter, Decoder as WishboneDecoder

from icicle.cpu import CPU
from icicle.bram import BlockRAM
from icicle.gpio import GPIO
from icicle.uart import UART


class SystemOnChip(Elaboratable):
    def elaborate(self, platform):
        m = Module()

        cpu = m.submodules.cpu = CPU()

        init = [
            # start:
            #   li t0, 1000000
            0x000f42b7,
            0x24028293,
            #   li t1, 0x80000000
            0x80000337,
            # dec:
            #   addi t0, t0, -1
            0xfff28293,
            #   bnez t0, dec
            0xfe029ee3,
            #   lb t1, 0(t1)
            0x00030383,
            #   xori t2, t2, 1
            0x0013c393,
            #   sb t1, 0(t1)
            0x00730023,
            #   j start
            0xfe1ff06f
        ]

        bram = m.submodules.bram = BlockRAM(addr_width=11, init=init)

        gpio = m.submodules.gpio = GPIO(numbers=range(3))
        uart = m.submodules.uart = UART()

        csr_decoder = m.submodules.csr_decoder = CSRDecoder(addr_width=16, data_width=8)
        csr_decoder.add(gpio.bus)
        csr_decoder.add(uart.bus)
        csr_bridge = m.submodules.csr_bridge = WishboneCSRBridge(csr_decoder.bus, data_width=32)

        decoder = m.submodules.decoder = WishboneDecoder(addr_width=30, data_width=32, granularity=8, features=["err"])
        decoder.add(bram.bus)
        decoder.add(csr_bridge.wb_bus, addr=0x80000000)

        arbiter = m.submodules.arbiter = WishboneArbiter(addr_width=30, data_width=32, granularity=8, features=["err"])
        arbiter.add(cpu.ibus)
        arbiter.add(cpu.dbus)
        m.d.comb += arbiter.bus.connect(decoder.bus)

        return m
