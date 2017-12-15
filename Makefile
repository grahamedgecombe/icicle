QUIET    = -q
PLL      = pll.sv
SRC      = $(sort $(wildcard *.sv) $(PLL))
TOP      = top
SV       = $(TOP).sv
YS       = $(TOP).ys
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
FREQ_PLL = 36
TARGET   = riscv64-unknown-elf
AS       = $(TARGET)-as
ASFLAGS  = -march=rv32i -mabi=ilp32
LD       = $(TARGET)-ld
LDFLAGS  = -Tprogmem.lds -melf32lriscv
CC       = $(TARGET)-gcc
CFLAGS   = -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=$(FREQ_PLL)000000
OBJCOPY  = $(TARGET)-objcopy

.PHONY: all clean syntax time stat flash

all: $(BIN)

clean:
	$(RM) $(BLIF) $(ASC_SYN) $(ASC) $(BIN) $(PLL) progmem_syn.hex progmem.hex progmem.o start.o progmem

progmem.hex: progmem
	$(OBJCOPY) -O srec $< /dev/stdout \
		| srec_cat - -byte-swap 4 -output - -binary \
		| xxd -p -c 4 > $@

progmem: progmem.o start.o progmem.lds
	$(LD) $(LDFLAGS) -o $@ progmem.o start.o

progmem_syn.hex:
	icebram -g 32 256 > $@

$(PLL):
	icepll $(QUIET) -i $(FREQ_OSC) -o $(FREQ_PLL) -m -f $@

$(BLIF): $(YS) $(SRC) progmem_syn.hex
	yosys $(QUIET) -s $<

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
