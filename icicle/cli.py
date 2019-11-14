#!/usr/bin/env python3

from nmigen.cli import main as nmigen_main

from icicle.cpu import CPU


def main():
    nmigen_main(CPU())


if __name__ == "__main__":
    main()
