#!/usr/bin/env python3

from nmigen.cli import main as nmigen_main

from icicle.cpu import CPU


def main():
    cpu = CPU()
    ports = []
    for (name, shape, dir) in cpu.rvfi.layout:
        ports.append(cpu.rvfi[name])
    nmigen_main(cpu, name="icicle", ports=ports)


if __name__ == "__main__":
    main()
