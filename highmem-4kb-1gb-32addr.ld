ENTRY(_start)

SECTIONS {
REAL_LOAD = 0x40100000;
. = 0xffffffff40100000;
.text   : AT (ADDR (.text) - 0xffffffff00000000) { *(.text) }
.rodata : AT (ADDR (.rodata) - 0xffffffff00000000) { *(.rodata) }
.data   : AT (ADDR (.data) - 0xffffffff00000000) { *(.data) }
.bss	: AT (ADDR (.bss) - 0xffffffff00000000) { *(.bss COMMON) }
}
