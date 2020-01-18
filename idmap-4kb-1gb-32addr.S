.global _start
.include "helpers.S"
.extern kstart

// Pre-allocate some pages
.section .bss
.align 12
tbl0:
	/* We can get away with less space (at least in qemu) */
	.space 4096

.section .text
_start:
.sane_setup:
	SANE_SETUP

.debugprint1:
	/* Print 'A' to check if we have got to this point */
	PRINT 0x41 UART


.setup_tbl0:
	ldr x0, =tbl0

	/* Map in first 2GB */
	mov x1, xzr
	orr x1, x1, FLAG_ONE
	orr x1, x1, FLAG_ACCESS
	str x1, [x0]

	mov x1, (1<<30)
	orr x1, x1, FLAG_ONE
	orr x1, x1, FLAG_ACCESS
	add x3, x0, 8
	str x1, [x3]


.setup_ttbr:
	/* Load table 0 in x0 and set in ttbr0_el1 */
	ldr x0, =tbl0
	and x0, x0, 0xffffffff
	msr ttbr0_el1, x0

.setup_tcr:
	/*
	* Set up TCR
	* - Restrict T0SZ and T1SZ to 64-32=32 bits (i.e. 4GB of available addresses)
	* - Use 4KB pages
	* - Set address size to 48 bits
	*/
	SETUP_TCR 32 FLAG_TG0_4KB FLAG_TG1_4KB FLAG_IPS_48BITS OPT_TTBR1_DISABLE

.debug_print2:
	PRINT 0x42 UART

.enable_mmu:
	ENABLE_MMU

.debug_print3:
	PRINT 0x43 UART

	/* endless loop here */

1:
	b 1b

	/* If we jump to C we must first map in UART at the expected location */
.jump:
	ldr x1, =kstart
	br x1

