ENTRY(start)

MEMORY {
    bram (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00002000
}

SECTIONS {
    .bram : {
        start.o(.text);
        *(.text);
        *(.data);
        *(.rodata);

        . = ALIGN(4);
        bss_start = .;

        *(.bss);

        . = ALIGN(4);
        bss_end = .;
    } > bram
}
