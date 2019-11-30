#!/usr/bin/env python3

from nmigen_boards.icebreaker import ICEBreakerPlatform

from icicle.soc import SystemOnChip


def main():
    platform = ICEBreakerPlatform()
    platform.build(SystemOnChip(), do_program=True)


if __name__ == "__main__":
    main()
