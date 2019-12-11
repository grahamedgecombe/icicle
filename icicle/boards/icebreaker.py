#!/usr/bin/env python3

from argparse import ArgumentParser

from nmigen_boards.icebreaker import ICEBreakerPlatform

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
    platform.build(SystemOnChip(), do_program=args.flash)


if __name__ == "__main__":
    main()
