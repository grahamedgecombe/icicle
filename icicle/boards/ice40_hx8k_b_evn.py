#!/usr/bin/env python3

from nmigen_boards.ice40_hx8k_b_evn import ICE40HX8KBEVNPlatform

from icicle.soc import SystemOnChip


def main():
    platform = ICE40HX8KBEVNPlatform()
    platform.build(SystemOnChip(), do_program=True)


if __name__ == "__main__":
    main()
