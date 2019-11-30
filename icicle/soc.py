from nmigen import *

from icicle.cpu import CPU
from icicle.bram import BlockRAM
from icicle.gpio import GPIO


class SystemOnChip(Elaboratable):
    def elaborate(self, platform):
        m = Module()

        cpu = m.submodules.cpu = CPU()

        bram = m.submodules.bram = BlockRAM(depth=256, init=[
            # start:
            #   li t0, 1000000
            0x000f42b7,
            0x24028293,
            # dec:
            #   addi t0, t0, -1
            0xfff28293,
            #   bne t0, zero, dec
            0xfe029ee3,
            #   lw t1, 0(zero)
            0x00002303,
            #   xori t1, t1, 1
            0x00134313,
            #   sw t1, 0(zero)
            0x00602023,
            #   j start
            0xfe5ff06f
        ])
        m.d.comb += cpu.ibus.connect(bram.bus)

        gpio = m.submodules.gpio = GPIO()
        m.d.comb += cpu.dbus.connect(gpio.bus)

        return m
