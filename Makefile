QUIET    = -q
PLL      = pll.sv
SRC      = $(sort $(wildcard *.sv) $(PLL))
TOP      = top
SV       = $(TOP).sv
YS       = $(TOP).ys
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
OBJCOPY  = $(TARGET)-objcopy

.PHONY: all clean check time stat flash

all: $(TOP).bin

clean:
	$(RM) $(BLIF) $(ASC_SYN) $(ASC) $(BIN) $(PLL) progmem_syn.hex progmem.hex progmem.o

progmem.hex: progmem.o
	$(OBJCOPY) -O srec $< /dev/stdout \
		| srec_cat - -byte-swap 4 -output - -binary \
		| xxd -p -c 4 > $@

progmem_syn.hex:
	icebram -g 32 256 > $@

$(PLL):
	icepll $(QUIET) -i $(FREQ_OSC) -o $(FREQ_PLL) -m -f $@

$(BLIF): $(YS) $(SRC) progmem_syn.hex
	yosys $(QUIET) -s $<

check: $(SRC) progmem_syn.hex
	iverilog -Wall -t null -g2012 `yosys-config --datdir/ice40/cells_sim.v` $(SV)

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
