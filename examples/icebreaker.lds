ENTRY(start)

MEMORY {
    flash (rx) : ORIGIN = 0x00100000, LENGTH = 15M
    ram  (rwx) : ORIGIN = 0x40000000, LENGTH = 128K
}

SECTIONS {
    .text : {
        start.o(.text);
        *(.text);
        *(.text.*);
    } > flash

    .data : ALIGN(4) {
        *(.data);
        *(.data.*);

        . = ALIGN(4);
    } > ram AT> flash

    .rodata : {
        *(.rodata);
        *(.rodata.*);
    } > flash

    .bss : ALIGN(4) {
        *(.bss);
        *(.bss.*);

        . = ALIGN(4);
    } > ram

    bss_start = ADDR(.bss);
    bss_end = bss_start + SIZEOF(.bss);

    data_flash_start = LOADADDR(.data);
    data_start = ADDR(.data);
    data_end = data_start + SIZEOF(.data);

    stack_top = ORIGIN(ram) + LENGTH(ram);
}
