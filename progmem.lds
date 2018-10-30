ENTRY(start)

MEMORY {
    bram (rwx) : ORIGIN = 0x00000000, LENGTH = 8K
}

SECTIONS {
    .text : {
        start.o(.text);
        *(.text);
        *(.text.*);
    } > bram

    .data : {
        *(.data);
        *(.data.*);
    } > bram

    .rodata : {
        *(.rodata);
        *(.rodata.*);
    } > bram

    .bss : {
        . = ALIGN(4);
        bss_start = .;

        *(.bss);
        *(.bss.*);

        . = ALIGN(4);
        bss_end = .;
    } > bram

    stack_top = ORIGIN(bram) + LENGTH(bram);
}
