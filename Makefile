QUIET    = -q
SRC      = $(wildcard *.sv)
TOP      = top
YS       = $(TOP).ys
BLIF     = $(TOP).blif
ASC      = $(TOP).asc
BIN      = $(TOP).bin
SPEED    = hx
DEVICE   = 8k
PACKAGE  = ct256
PCF      = ice40hx8k-b-evn.pcf
FREQ_OSC = 12

.PHONY: all clean time stat flash

all: $(TOP).bin

clean:
	$(RM) $(BLIF) $(ASC) $(BIN)

$(BLIF): $(YS) $(SRC)
	yosys $(QUIET) -s $<

$(ASC): $(BLIF) $(PCF)
	arachne-pnr $(QUIET) -d $(DEVICE) -P $(PACKAGE) -o $@ -p $(PCF) $<

$(BIN): $(ASC)
	icepack $< $@

time: $(ASC) $(PCF)
	icetime -t -m -d $(SPEED)$(DEVICE) -P $(PACKAGE) -p $(PCF) -c $(FREQ_OSC) $<

stat: $(ASC)
	icebox_stat $<

flash: $(BIN)
	iceprog -S $<
