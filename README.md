# Icicle 2

## Introduction

Icicle is a 32-bit [RISC-V][riscv] soft processor and system-on-chip, primarily
designed for [iCE40][ice40] (including the [UltraPlus][ice40up] series) FPGAs.
It can be built with open-source tools.

The [original version of Icicle][icicle1] was written in SystemVerilog. This
version is written in [Amaranth][amaranth], making the code cleaner and more
flexible. Changes to the microarchitecture have made the core significantly
smaller and faster.

The `Pipeline` and `Stage` classes are inspired by [Minerva][minerva]'s pipeline
system, though there are some significant differences.

## Features

* RV32I instruction set
* Separate [Wishbone][wishbone] instruction and data memory buses

## Microarchitecture

Icicle uses a 6-stage pipeline, similar to a
[classic RISC pipeline][classic-risc]. The main differences are summarized
below:

* The addition of a PC generation stage, instead of generating the PC during
  the fetch stage. PC generation in the fetch stage was often on the critical
  path in the previous version of Icicle.
* The ALU result multiplexer has been moved to the memory stage. The execute
  stage was often on the critical path in previous versions of Icicle. The
  multiplexing can proceed in parallel with memory access, as the load-store
  unit can be hard-wired to the adder's output - it never uses the output from
  the logic unit or barrel shifter. Despite more registers being required to
  retain the adder, logic and shifter outputs between stages, the size of the
  core is not significantly increased, as the registers can be packed in the
  same logic cell as the prior LUT.
* Similar to above, the register write data multiplexer has been moved to the
  writeback stage. The memory stage was often on the critical patch in previous
  versions of Icicle, and there is plenty of slack in the writeback stage: it
  has very little logic and the register file inputs are only required at the
  end of the clock cycle.

The pipeline is fully interlocked. Adding bypassing support would be
complicated by the multiplexer changes described above. Furthermore, enabling
bypassing in the previous version of Icicle increased the size of the core and
reduced the clock frequency by a relatively significant amount on iCE40 FPGAs,
which are the primary target.

Icicle is theoretically capable of issuing and retiring one instruction per
cycle, if the memory bus can keep up. In reality, the IPC will be slightly
lower than this due to stalls and flushes caused by data hazards and branch
mispredictions.

The system-on-chip examples distributed with Icicle are currently only capable
of issuing one instruction every two cycles, as:

* FPGA block RAMs are synchronous.
* Additional multiplexing logic needs to be added after the read port.
* Only a single memory bus transaction may be in flight at once.

This could be improved with:

* Negative-edge block RAMs, which Amaranth does not yet support.
* Using a pipelined memory bus that makes requests during one cycle and does
  not expect the response until the following cycle.
* Adding instruction and data caches and burst support.

## Dependencies

* [Amaranth][amaranth]
* [Yosys][yosys]
* [nextpnr][nextpnr]
* [Project IceStorm][icestorm]
* [SymbiYosys][symbiyosys] (for formal verification only)

## Building

Run the following command to install Icicle locally, including its dependencies:

    pip install -e .

The `icicle` command is a thin wrapper around `amaranth.cli`. Run the following
command to compile the Icicle processor core to Verilog:

    icicle generate -t v > icicle.v

The `icicle` command has some flags for customizing the generated core. Run
`icicle --help` for full usage information.

### System-on-chip examples

Icicle ships with example system-on-chip designs for several development
boards. A single command will build and flash the system-on-chip to your FPGA.
Simply connect the development board to your computer and run the appropriate
command from the table below, appending the `--flash` flag:

| Board                                         | Command                   | Notes                                   |
|-----------------------------------------------|---------------------------|-----------------------------------------|
| [iCEBreaker][icebreaker]                      | `icicle-icebreaker`       |                                         |
| [iCE40-HX8K Breakout Board][ice40-hx8k-b-evn] | `icicle-ice40-hx8k-b-evn` | Configure jumpers for SRAM programming. |
| [ECP5 Evaluation Board][ecp5-5g-evn]          | `icicle-ecp5-5g-evn`      |                                         |

For example, run the following command to build and flash to the iCEBreaker
board:

    icicle-icebreaker --flash

The [iCEBreaker][icebreaker] board is Icicle's primary target. It is
inexpensive, beginner-friendly and fully compatible with the open-source
toolchain.

### Example programs

Icicle also ships with some example programs to demonstrate the system-on-chip.
Run the following commands to build them and flash the blinky example to the
iCEBreaker board:

    make -C examples PLATFORM=icebreaker
    iceprog -o 1M examples/blinky.bin

## Testing

There are a small number of non-exhaustive tests that simulate portions of the
processor core. These were primarily used to test standalone modules during
development before the full formal verification infrastructure was ready.

They are still useful as they are significantly quicker than verifying the
entire core - providing a quicker feedback cycle during development. Use the
following command to run them:

    python -m unittest

However, despite the existence of the unit tests, formally verifying the core
after a change is completed is still strongly recommended.

## Formal verification

Icicle supports the RISC-V Formal Interface (RVFI), allowing it to be formally
verified with [riscv-formal][riscv-formal].

Clone the riscv-formal repository:

    git clone https://github.com/SymbioticEDA/riscv-formal.git

Clone Icicle in the `cores` subdirectory:

    cd riscv-formal/cores && git clone https://github.com/grahamedgecombe/icicle2.git

Run the following commands to verify the processor core:

    cd icicle2
    ../../checks/genchecks.py
    make -C checks -j $(nproc)
    sby complete.sby
    ./equiv.sh

## Size and performance

| FPGA family | Logic cells | Frequency |
|-------------|-------------|-----------|
| iCE40 HX    | ~1,000      | ~75 MHz   |
| iCE40 UP    | ~1,000      | ~30 MHz   |
| ECP5 8\_5G  | ~900        | ~140 MHz  |

The numbers in the table above refer to the processor core in its default
configuration only. The rest of the system-on-chip is not included.

## License

This project is available under the terms of the ISC license, which is similar
to the 2-clause BSD license. See the `LICENSE` file for the copyright
information and licensing terms.

[amaranth]: https://github.com/amaranth-lang/amaranth
[classic-risc]: https://en.wikipedia.org/wiki/Classic_RISC_pipeline
[ecp5-5g-evn]: https://www.latticesemi.com/en/Products/DevelopmentBoardsAndKits/ECP5EvaluationBoard
[ice40-hx8k-b-evn]: https://www.latticesemi.com/en/Products/DevelopmentBoardsAndKits/iCE40HX8KBreakoutBoard.aspx
[ice40]: https://www.latticesemi.com/en/Products/FPGAandCPLD/iCE40.aspx
[ice40up]: https://www.latticesemi.com/en/Products/FPGAandCPLD/iCE40UltraPlus.aspx
[icebreaker]: https://www.crowdsupply.com/1bitsquared/icebreaker-fpga
[icestorm]: http://www.clifford.at/icestorm/
[icicle1]: https://github.com/grahamedgecombe/icicle
[minerva]: https://github.com/lambdaconcept/minerva
[nextpnr]: https://github.com/YosysHQ/nextpnr
[riscv-formal]: https://github.com/YosysHQ/riscv-formal
[riscv]: https://riscv.org/
[symbiyosys]: https://symbiyosys.readthedocs.io/en/latest/
[wishbone]: https://wishbone-interconnect.readthedocs.io/en/latest/
[yosys]: https://yosyshq.net/yosys/
