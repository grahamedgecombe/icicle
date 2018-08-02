QUIET    = -q
PLL      = pll.sv
SRC      = $(sort $(wildcard *.sv) $(PLL))
TOP      = top
SV       = $(TOP).sv
YS       = $(TOP).ys
YS_ICE40 = `yosys-config --datdir/ice40/cells_sim.v`
BLIF     = $(TOP).blif
JSON     = $(TOP).json
ASC_SYN  = $(TOP)_syn.asc
ASC      = $(TOP).asc
BIN      = $(TOP).bin
TIME_RPT = $(TOP).rpt
STAT     = $(TOP).stat
BOARD   ?= ice40hx8k-b-evn
PNR     ?= arachne-pnr
PCF      = boards/$(BOARD).pcf
FREQ_PLL = 24
TARGET   = riscv64-unknown-elf
AS       = $(TARGET)-as
ASFLAGS  = -march=rv32i -mabi=ilp32
LD       = $(TARGET)-gcc
LDFLAGS  = -march=rv32i -mabi=ilp32 -Wl,-Tprogmem.lds -ffreestanding -nostartfiles
CC       = $(TARGET)-gcc
CFLAGS   = -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=$(FREQ_PLL)000000 -O2
OBJCOPY  = $(TARGET)-objcopy

include boards/$(BOARD).mk

.PHONY: all clean syntax time stat flash

all: $(BIN)

clean:
	$(RM) $(BLIF) $(JSON) $(ASC_SYN) $(ASC) $(BIN) $(PLL) $(TIME_RPT) $(STAT) progmem_syn.hex progmem.hex progmem.o start.o progmem defines.sv

progmem.hex: progmem
	$(OBJCOPY) -O binary $< /dev/stdout \
		| xxd -p -c 4 > $@

progmem: progmem.o start.o progmem.lds
	$(LD) $(LDFLAGS) -o $@ progmem.o start.o

progmem_syn.hex:
	icebram -g 32 2048 > $@

$(PLL):
	icepll $(QUIET) -i $(FREQ_OSC) -o $(FREQ_PLL) -m -f $@

$(BLIF) $(JSON): $(YS) $(SRC) progmem_syn.hex defines.sv
	yosys $(QUIET) $<

syntax: $(SRC) progmem_syn.hex defines.sv
	iverilog -Wall -t null -g2012 $(YS_ICE40) $(SV)

defines.sv: boards/$(BOARD)-defines.sv
	cp boards/$(BOARD)-defines.sv defines.sv

ifeq ($(PNR),nextpnr)
$(ASC_SYN): $(JSON) $(PCF)
	nextpnr-ice40 --$(SPEED)$(DEVICE) --package $(PACKAGE) --json $< --pcf $(PCF) --freq $(FREQ_PLL) --asc $@
else
$(ASC_SYN): $(BLIF) $(PCF)
	arachne-pnr $(QUIET) -d $(DEVICE) -P $(PACKAGE) -o $@ -p $(PCF) $<
endif

$(TIME_RPT): $(ASC_SYN) $(PCF)
	icetime -t -m -d $(SPEED)$(DEVICE) -P $(PACKAGE) -p $(PCF) -c $(FREQ_PLL) -r $@ $<

$(ASC): $(ASC_SYN) progmem_syn.hex progmem.hex
	icebram progmem_syn.hex progmem.hex < $< > $@

$(BIN): $(ASC)
	icepack $< $@

time: $(TIME_RPT)
	cat $<

$(STAT): $(ASC_SYN)
	icebox_stat $< > $@

stat: $(STAT)
	cat $<

flash: $(BIN) $(TIME_RPT)
	iceprog -S $<

# Flash to BlackIce-II board
dfu-flash: $(BIN) $(TIME_RPT)
	dfu-util -d 0483:df11 --alt 0 --dfuse-address 0x0801F000 -D $(BIN)

