# Icicle

## Introduction

Icicle is a 32-bit [RISC-V][riscv] system on chip for [iCE40 HX8K][ice40] and
[iCE40 UP5K][ice40-up5k] FPGAs. It can be built with the open-source
[Project IceStorm][icestorm] toolchain and currently targets the
[iCE40-HX8K breakout board][ice40-hx8k-breakout], the
[BlackIce-II board][blackice-ii-board], with experimental support for
the [UPduino][upduino] board.

## Current features

* RV32I core with a [classic 5-stage RISC pipeline][classic-risc], static branch
  prediction, bypassing and interlocking. It currently implements the entire
  [user ISA][riscv-user] (except `ECALL` and `EBREAK`) and parts of the
  [privileged ISA][riscv-priv].
* Shared instruction and data memory (8 KiB, implemented with FPGA block RAM).
* Memory-mapped UART and LEDs.

## Dependencies

* [arachne-pnr][arachne-pnr]
* [GNU RISC-V toolchain][riscv-gnu]
* [GNU Make][make]
* [Icarus Verilog][iverilog]
* [Project IceStorm][icestorm]
* [vim][vim] (for `xxd`)
* [Yosys][yosys]

## Building and testing

1. Run `make syntax` to check the syntax with [Icarus][iverilog], which has a
   stricter parser than [Yosys][yosys].
2. Run `make` to synthesize the design, place and route, compile the demo
   program in `progmem.c` and create the bitstream.
3. Connect the [iCE40-HX8K breakout board][ice40-hx8k-breakout] and configure
   the jumpers for direct SRAM programming.
4. Run `make flash` to program the bitstream. `icetime` is used to check that
   the design meets timing closure. The target fails if it does not.
5. 4 of the 8 LEDs should turn on (with an on, off, on, off pattern). Run
   `picocom /dev/ttyUSBN` (replacing `ttyUSBN` with the name of the serial port)
   to connect to the serial port. `Hello, world!` should be printed once per
   second.

## Building and testing (BlackIceII board)

1. Run `make BOARD=blackice-ii` to synthesize the design, place and route,
   compile the demo program in `progmem.c` and create the bitstream.
2. Configure jumper on board for [DFU Mode][dfu-mode] and connect both USB1
   and USB2 on the board to host USB ports.
3. Run `make BOARD=blackice-ii dfu-flash` to program the bitstream to the
   board. (Most likely you'll need to do this as root)
4. In a separate terminal run
   `sudo stty -F /dev/ttyUSBN 9600`
   `sudo cat /dev/ttyUSBN`  (to connect to the serial port)
   (replacing `ttyUSBN` with the name of the serial port - most likely ttyUSB0)
   `Hello, world!` should be printed once per second.

The `make stat` target runs `icebox_stat` and the `make time` target prints the
`icetime` report.

The `Makefile` runs the [IceStorm][icestorm] toolchain in quiet mode. Unset the
`QUIET` variable to run the toolchain in verbose mode - e.g. `make QUIET=`.

Set the `BOARD` variable to target a different board - e.g. `make BOARD=upduino`
for the [UPduino][upduino].

## Planned features

* Use remaining block RAM tiles to eke out as much memory as possible.
* Use the SPRAM tiles on UP5K devices.
* Implement remaining bits of the user ISA.
* Implement machine mode from the privileged ISA.
* Interrupts/exceptions.
* Unaligned memory access support.
* Memory-mapped GPIOs.
* Memory-mapped XIP/SPI flash.
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
[classic-risc]: https://en.wikipedia.org/wiki/Classic_RISC_pipeline
[ice40-hx8k-breakout]: http://www.latticesemi.com/Products/DevelopmentBoardsAndKits/iCE40HX8KBreakoutBoard.aspx
[blackice-ii-board]: https://github.com/mystorm-org/BlackIce-II
[upduino]: http://gnarlygrey.atspace.cc/development-platform.html#upduino
[ice40]: http://www.latticesemi.com/Products/FPGAandCPLD/iCE40.aspx
[ice40-up5k]: http://www.latticesemi.com/Products/FPGAandCPLD/iCE40Ultra.aspx
[icestorm]: http://www.clifford.at/icestorm/
[iverilog]: http://iverilog.icarus.com/
[make]: https://www.gnu.org/software/make/
[riscv-gnu]: https://github.com/riscv/riscv-gnu-toolchain
[riscv-priv]: https://riscv.org/specifications/privileged-isa/
[riscv-user]: https://riscv.org/specifications/
[riscv]: https://riscv.org/risc-v-isa/
[vim]: http://www.vim.org/
[yosys]: http://www.clifford.at/yosys/
[dfu-mode]: https://github.com/mystorm-org/BlackIce-II/wiki/DFU-operations-on-the-BlackIce-II
