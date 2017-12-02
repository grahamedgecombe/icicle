QUIET    = -q
SRC      = $(wildcard *.sv)
TOP      = top
YS       = $(TOP).ys
BLIF     = $(TOP).blif
ASC_SYN  = $(TOP)_syn.asc
ASC      = $(TOP).asc
BIN      = $(TOP).bin
SPEED    = hx
DEVICE   = 8k
PACKAGE  = ct256
PCF      = ice40hx8k-b-evn.pcf
FREQ_OSC = 12
TARGET   = riscv64-unknown-elf
AS       = $(TARGET)-as
ASFLAGS  = -march=rv32i -mabi=ilp32
OBJCOPY  = $(TARGET)-objcopy

.PHONY: all clean time stat flash

all: $(TOP).bin

clean:
	$(RM) $(BLIF) $(ASC_SYN) $(ASC) $(BIN) progmem_syn.hex progmem.hex progmem.o

progmem.hex: progmem.o
	$(OBJCOPY) -O srec $< /dev/stdout \
		| srec_cat - -byte-swap 4 -output - -binary \
		| xxd -p -c 4 > $@

progmem_syn.hex:
	icebram -g 32 256 > $@

$(BLIF): $(YS) $(SRC) progmem_syn.hex
	yosys $(QUIET) -s $<

$(ASC_SYN): $(BLIF) $(PCF)
	arachne-pnr $(QUIET) -d $(DEVICE) -P $(PACKAGE) -o $@ -p $(PCF) $<

$(ASC): $(ASC_SYN) progmem_syn.hex progmem.hex
	icebram progmem_syn.hex progmem.hex < $< > $@

$(BIN): $(ASC)
	icepack $< $@

time: $(ASC_SYN) $(PCF)
	icetime -t -m -d $(SPEED)$(DEVICE) -P $(PACKAGE) -p $(PCF) -c $(FREQ_OSC) $<

stat: $(ASC_SYN)
	icebox_stat $<

flash: $(BIN)
	iceprog -S $<
