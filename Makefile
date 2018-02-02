QUIET    = -q
PLL      = pll.sv
SRC      = $(sort $(wildcard *.sv) $(PLL))
TOP      = top
SV       = $(TOP).sv
TCL      = $(TOP).tcl
YS_ICE40 = `yosys-config --datdir/ice40/cells_sim.v`
BLIF     = $(TOP).blif
ASC_SYN  = $(TOP)_syn.asc
ASC      = $(TOP).asc
BIN      = $(TOP).bin
TIME_RPT = $(TOP).rpt
STAT     = $(TOP).stat
SPEED    = hx
DEVICE   = 8k
PACKAGE  = ct256
PCF      = ice40hx8k-b-evn.pcf
FREQ_OSC = 12
FREQ_PLL = 24
TARGET   = riscv64-unknown-elf
AS       = $(TARGET)-as
ASFLAGS  = -march=rv32i -mabi=ilp32
LD       = $(TARGET)-gcc
LDFLAGS  = -march=rv32i -mabi=ilp32 -Wl,-Tprogmem.lds -ffreestanding -nostartfiles
CC       = $(TARGET)-gcc
CFLAGS   = -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=$(FREQ_PLL)000000 -O2
OBJCOPY  = $(TARGET)-objcopy

.PHONY: all clean syntax time stat flash

all: $(BIN)

upduino:	SPEED=up
upduino:	DEVICE=5k
upduino:	PACKAGE=sg48
upduino:	PCF=ice40up5k-upduino.pcf
upduino:	FREQ_OSC=48
upduino: clean all

clean:
	$(RM) $(BLIF) $(ASC_SYN) $(ASC) $(BIN) $(PLL) $(TIME_RPT) $(STAT) progmem_syn.hex progmem.hex progmem.o start.o progmem

progmem.hex: progmem
	$(OBJCOPY) -O binary $< /dev/stdout \
		| xxd -p -c 4 > $@

progmem: progmem.o start.o progmem.lds
	$(LD) $(LDFLAGS) -o $@ progmem.o start.o

progmem_syn.hex:
	icebram -g 32 2048 > $@

$(PLL):
	icepll $(QUIET) -i $(FREQ_OSC) -o $(FREQ_PLL) -m -f $@

$(BLIF): $(TCL) $(SRC) progmem_syn.hex
	IC=$(SPEED)$(DEVICE) yosys $(QUIET) $<

syntax: $(SRC) progmem_syn.hex
	iverilog -Wall -t null -g2012 $(YS_ICE40) $(SV)

$(ASC_SYN): $(BLIF) $(PCF)
	arachne-pnr $(QUIET) -d $(DEVICE) -P $(PACKAGE) -o $@ -p $(PCF) $<

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
