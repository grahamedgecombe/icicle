# Icicle

## Introduction

Icicle is a 32-bit [RISC-V][riscv] system on chip for [iCE40 HX8K][ice40] and
[iCE40 UP5K][ice40-up5k] FPGAs. It can be built with the open-source
[Project IceStorm][icestorm] toolchain and currently targets several development
boards.

## Current features

* RV32I core with a [classic 5-stage RISC pipeline][classic-risc], static branch
  prediction, bypassing and interlocking. It currently implements the entire
  [user ISA][riscv-user] (except `ECALL` and `EBREAK`) and parts of the
  [privileged ISA][riscv-priv].
* Shared instruction and data memory (8 KiB, implemented with FPGA block RAM).
* Memory-mapped UART and LEDs.
* Memory-mapped XIP/SPI flash.

## Dependencies

* [GNU Make][make]
* [GNU RISC-V toolchain][riscv-gnu]
* [Icarus Verilog][iverilog] (`master` branch)
* [nextpnr][nextpnr] or [arachne-pnr][arachne-pnr]
* [Project IceStorm][icestorm]
* [vim][vim] (for `xxd`)
* [Yosys][yosys]

## Building and testing

### Supported boards

Icicle supports several development boards:

* `ice40hx8k-b-evn`: [iCE40-HX8K breakout board][ice40-hx8k-breakout]
* `blackice-ii`: [BlackIce II][blackice-ii-board]
* `upduino`: [UPduino][upduino]

`<board>` should be replaced with the internal name of your development board in
the rest of the instructions (e.g. `ice40hx8k-b-evn` for the iCE40-HX8K breakout
board).

### Building

* Run `make BOARD=<board> syntax` to check the syntax with [Icarus][iverilog],
  which has a stricter parser than [Yosys][yosys]. At the time of writing the
  `master` branch of Icarus is required as there isn't a stable release with
  `always_comb`/`always_ff` support yet.
* Run `make BOARD=<board>` to synthesize the design, place and route, compile
  the demo program in `progmem.c` and create the bitstream.

### Programming

#### iCE40-HX8K breakout board

* Configure the jumpers for flash programming.
* Run `make BOARD=ice40hx8k-b-evn flash` to flash the bitstream.

#### BlackIce II

* Configure jumper on board for [DFU Mode][dfu-mode] and connect both USB1 and
  USB2 on the board to host USB ports.
* Run `make BOARD=blackice-ii dfu-flash` to flash the bitstream.

### Testing

* If your chosen board has built-in LEDs, some of the LEDs should turn on.
* Run `picocom -b 9600 /dev/ttyUSBn` (replacing `ttyUSBn` with the name of the
  serial port) to connect to the serial port. `Hello, world!` should be printed
  once per second.

### Other targets

The `make BOARD=<board> stat` target runs `icebox_stat` and the
`make BOARD=<board> time` target prints the `icetime` report.

The `Makefile` runs the [IceStorm][icestorm] toolchain in quiet mode. Unset the
`QUIET` variable to run the toolchain in verbose mode - e.g.
`make BOARD=<board> QUIET= ...`.

Set the `PNR` variable to `arachne-pnr` to use [arachne-pnr][arachne-pnr]
instead of [nextpnr][nextpnr] (the default) - e.g. `make PNR=arachne-pnr`.

## Planned features

* Use remaining block RAM tiles to eke out as much memory as possible.
* Use the SPRAM tiles on UP5K devices.
* Implement remaining bits of the user ISA.
* Implement machine mode from the privileged ISA.
* Interrupts/exceptions.
* Unaligned memory access support.
* Memory-mapped GPIOs.
* Improved reset support (a reset signal + boot ROM to zero all the registers).
* Automated tests.
* Multiply/divide support.
* Compressed instruction support.
* Add flags to disable certain features (e.g. privileged mode) to save LUTs on
  smaller devices (e.g. the UP5K).
* Investigate using DSP tiles on the UP5K.

## Size and performance

The entire system on chip currently occupies around 2,500 LUTs on an iCE40 when
synthesized with [Yosys][yosys].

It's currently clocked at 24 MHz but `icetime` estimates it could be clocked at
~30-35 MHz (depending on how lucky [arachne-pnr][arachne-pnr] is).

The core is capable of issuing and retiring one instruction per clock cycle,
although the actual number of instructions per cycle will be slightly less than
this in practice due to interlocking, branch mispredictions and the shared
memory bus.

## License

This project is available under the terms of the ISC license, which is similar
to the 2-clause BSD license. See the `LICENSE` file for the copyright
information and licensing terms.

[arachne-pnr]: https://github.com/cseed/arachne-pnr
[blackice-ii-board]: https://github.com/mystorm-org/BlackIce-II
[classic-risc]: https://en.wikipedia.org/wiki/Classic_RISC_pipeline
[dfu-mode]: https://github.com/mystorm-org/BlackIce-II/wiki/DFU-operations-on-the-BlackIce-II
[ice40-hx8k-breakout]: http://www.latticesemi.com/Products/DevelopmentBoardsAndKits/iCE40HX8KBreakoutBoard.aspx
[ice40-up5k]: http://www.latticesemi.com/Products/FPGAandCPLD/iCE40Ultra.aspx
[ice40]: http://www.latticesemi.com/Products/FPGAandCPLD/iCE40.aspx
[icestorm]: http://www.clifford.at/icestorm/
[iverilog]: http://iverilog.icarus.com/
[make]: https://www.gnu.org/software/make/
[nextpnr]: https://github.com/YosysHQ/nextpnr
[riscv-gnu]: https://github.com/riscv/riscv-gnu-toolchain
[riscv-priv]: https://riscv.org/specifications/privileged-isa/
[riscv-user]: https://riscv.org/specifications/
[riscv]: https://riscv.org/risc-v-isa/
[upduino]: http://gnarlygrey.atspace.cc/development-platform.html#upduino
[vim]: http://www.vim.org/
[yosys]: http://www.clifford.at/yosys/
