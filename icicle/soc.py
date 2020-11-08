from nmigen import *

from icicle.cpu import CPU
from icicle.bram import BlockRAM
from icicle.gpio import GPIO


class SystemOnChip(Elaboratable):
    def elaborate(self, platform):
        m = Module()

        cpu = m.submodules.cpu = CPU()

        bram = m.submodules.bram = BlockRAM(addr_width=8, init=[
            # start:
            #   li t0, 1000000
            0x000f42b7,
            0x24028293,
            #   li t1, 0
            0x00000313,
            # dec:
            #   addi t0, t0, -1
            0xfff28293,
            #   bnez t0, dec
            0xfe029ee3,
            #   lw t1, 0(t1)
            0x00032383,
            #   xori t2, t2, 1
            0x0013c393,
            #   sw t1, 0(t1)
            0x00732023,
            #   j start
            0xfe1ff06f
        ])
        m.d.comb += cpu.ibus.connect(bram.bus)

        gpio = m.submodules.gpio = GPIO()
        m.d.comb += cpu.dbus.connect(gpio.bus)

        return m
