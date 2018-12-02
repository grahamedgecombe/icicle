.DEFAULT_GOAL = all

QUIET    = -q
PLL      = pll.sv
SRC      = $(sort $(wildcard *.sv) $(PLL))
TOP      = top
SV       = $(TOP).sv
YS       = $(ARCH).ys
YS_ICE40 = `yosys-config --datdir/$(ARCH)/cells_sim.v`
BLIF     = $(TOP).blif
JSON     = $(TOP).json
ASC_SYN  = $(TOP)_syn.asc
ASC      = $(TOP).asc
BIN      = $(TOP).bin
SVF      = $(TOP).svf
TIME_RPT = $(TOP).rpt
STAT     = $(TOP).stat
BOARD   ?= ice40hx8k-b-evn
TARGET   = riscv64-unknown-elf
AS       = $(TARGET)-as
ASFLAGS  = -march=rv32i -mabi=ilp32
LD       = $(TARGET)-gcc
LDFLAGS  = $(CFLAGS) -Wl,-Tprogmem.lds
CC       = $(TARGET)-gcc
CFLAGS   = -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=$(FREQ_PLL)000000 -Os -ffreestanding -nostartfiles -g
OBJCOPY  = $(TARGET)-objcopy

include boards/$(BOARD).mk
include arch/$(ARCH).mk

.PHONY: all clean syntax time stat flash

all: $(BIN)

clean:
	$(RM) $(BLIF) $(JSON) $(ASC_SYN) $(ASC) $(BIN) $(SVF) $(PLL) $(TIME_RPT) $(STAT) progmem_syn.hex progmem.hex progmem.bin progmem.o start.o start.s progmem progmem.lds defines.sv

progmem.bin: progmem
	$(OBJCOPY) -O binary $< $@

progmem.hex: progmem.bin
	xxd -p -c 4 < $< > $@

progmem: progmem.o start.o progmem.lds
	$(LD) $(LDFLAGS) -o $@ progmem.o start.o

$(BLIF) $(JSON): $(YS) $(SRC) progmem_syn.hex progmem.hex defines.sv
	yosys $(QUIET) $<

syntax: $(SRC) progmem_syn.hex defines.sv
	iverilog -D$(shell echo $(ARCH) | tr 'a-z' 'A-Z') -Wall -t null -g2012 $(YS_ICE40) $(SV)

defines.sv: boards/$(BOARD)-defines.sv
	cp boards/$(BOARD)-defines.sv defines.sv

start.s: start-$(PROGMEM).s
	cp $< $@

progmem.lds: progmem-$(PROGMEM).lds
	cp $< $@

time: $(TIME_RPT)
	cat $<

stat: $(STAT)
	cat $<

# Flash to BlackIce-II board
dfu-flash: $(BIN) $(TIME_RPT)
	dfu-util -d 0483:df11 --alt 0 --dfuse-address 0x0801F000 -D $(BIN)
