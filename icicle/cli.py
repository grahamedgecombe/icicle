#!/usr/bin/env python3

from argparse import ArgumentParser

from nmigen.cli import main_parser, main_runner

from icicle.cpu import CPU


def main():
    parser = ArgumentParser()
    parser.add_argument(
        "--reset-vector",
        type=lambda s: int(s, 16),
        metavar="ADDRESS",
        default="0x00000000",
        help="set program counter to ADDRESS at reset (default: %(default)s)"
    )
    parser.add_argument("--rvfi",
        default=False,
        action="store_true",
        help="enable RISC-V Formal Interface"
    )
    parser.add_argument("--rvfi-blackbox-alu",
        default=False,
        action="store_true",
        help="replace the ALU with a black box"
    )
    parser.add_argument("--rvfi-blackbox-regs",
        default=False,
        action="store_true",
        help="replace the register file with a black box"
    )
    main_parser(parser)

    args = parser.parse_args()

    cpu = CPU(
        reset_vector=args.reset_vector,
        rvfi_blackbox_alu=args.rvfi_blackbox_alu,
        rvfi_blackbox_regs=args.rvfi_blackbox_regs
    )

    ports = []
    if args.rvfi:
        for (name, shape, dir) in cpu.rvfi.layout:
            ports.append(cpu.rvfi[name])

    main_runner(parser, args, cpu, name="icicle", ports=ports)


if __name__ == "__main__":
    main()
