#!/usr/bin/env python3

from argparse import ArgumentParser

from amaranth.build import Resource, Pins, Attrs
from amaranth_boards.icebreaker import ICEBreakerPlatform

from icicle.soc import SystemOnChip


def main():
    parser = ArgumentParser()
    parser.add_argument(
        "--flash",
        default=False,
        action="store_true",
        help="flash the bitstream to the board after building"
    )
    args = parser.parse_args()

    platform = ICEBreakerPlatform()
    platform.add_resources([
        Resource("gpio", 0, Pins("11"), Attrs(IO_STANDARD="SB_LVCMOS")),
        Resource("gpio", 1, Pins("37"), Attrs(IO_STANDARD="SB_LVCMOS")),
        Resource("gpio", 2, Pins("10"), Attrs(IO_STANDARD="SB_LVCMOS")),
    ])
    platform.build(SystemOnChip(), do_program=args.flash)


if __name__ == "__main__":
    main()
