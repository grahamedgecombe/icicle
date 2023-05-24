#!/usr/bin/env python3

from argparse import ArgumentParser

from amaranth_boards.ecp5_5g_evn import ECP55GEVNPlatform

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

    platform = ECP55GEVNPlatform()
    platform.build(SystemOnChip(), do_program=args.flash)


if __name__ == "__main__":
    main()
