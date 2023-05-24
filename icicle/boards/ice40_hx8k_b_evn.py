#!/usr/bin/env python3

from argparse import ArgumentParser

from amaranth_boards.ice40_hx8k_b_evn import ICE40HX8KBEVNPlatform

from icicle.soc.soc import SystemOnChip


def main():
    parser = ArgumentParser()
    parser.add_argument(
        "--flash",
        default=False,
        action="store_true",
        help="flash the bitstream to the board after building"
    )
    args = parser.parse_args()

    platform = ICE40HX8KBEVNPlatform()
    platform.build(SystemOnChip(), do_program=args.flash)


if __name__ == "__main__":
    main()
