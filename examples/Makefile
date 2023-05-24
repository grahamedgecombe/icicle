.DELETE_ON_ERROR:
.PHONY: all clean

PROGRAMS := blinky echo hello
PLATFORM ?= icebreaker

TARGET ?= riscv32-none-elf-

CC = $(TARGET)cc

CFLAGS ?= -Wall -Wextra -pedantic -Os
CFLAGS := $(CFLAGS) -march=rv32i -mabi=ilp32 -ffreestanding -nostartfiles

LDFLAGS ?=
LDFLAGS := $(LDFLAGS) -Wl,-T$(PLATFORM).lds

AS = $(TARGET)as
ASFLAGS := $(ASFLAGS) -march=rv32i -mabi=ilp32

OBJCOPY = $(TARGET)objcopy

all: $(addsuffix .bin, $(PROGRAMS))

clean:
	$(RM) $(PROGRAMS) $(addsuffix .bin, $(PROGRAMS)) $(addsuffix .o, $(PROGRAMS)) start.o

%.bin: %
	$(OBJCOPY) -O binary $< $@

$(PROGRAMS): %: start.o %.o
	$(LINK.c) -o $@ $^
