ENTRY(start)

MEMORY {
    bram (rwx) : ORIGIN = 0x00000000, LENGTH = 8K
}

SECTIONS {
    .bram : {
        start.o(.text);
        *(.text);
        *(.text.*);
        *(.data);
        *(.data.*);
        *(.rodata);
        *(.rodata.*);

        . = ALIGN(4);
        bss_start = .;

        *(.bss);
        *(.bss.*);

        . = ALIGN(4);
        bss_end = .;
    } > bram

    stack_top = ORIGIN(bram) + LENGTH(bram);
}
