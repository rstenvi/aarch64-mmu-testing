
// Disable FP and SIMD traps
.equ CPACR_EL1_FPEN, 0b11 << 20

.equ UART, 0x9000000
.equ mask4kb, 0x1ff

.equ FLAG_ACCESS, (1 << 10)
.equ FLAG_ONE,    1
.equ FLAG_NEXT_TABLE, (1 << 1)

.equ FLAG_IPS_48BITS,    5
.equ FLAG_TG1_4KB,       2
.equ FLAG_TG0_4KB,       0
.equ FLAG_TSZ_FULL,      16

.equ OPT_TTBR1_DISABLE, 1
.equ OPT_TTBR1_ENABLE,  0

.macro ADDR2IDX rootreg reg bits addrbits
	mov \reg, \rootreg
	and \reg, \reg, ((1 << \addrbits)-1)
	lsr \reg, \reg, \bits
	and \reg, \reg, mask4kb
	lsl \reg, \reg, 3
.endm


.macro ENABLE_MMU
	isb
	/* Enable MMU */
	mrs x0, sctlr_el1
	orr x0, x0, 1
	msr sctlr_el1, x0
	isb
.endm


.macro PRINT char uart
	mov x8, UART
	mov x9, \char
	str x9, [x8]
.endm

.macro SANE_SETUP
	mov x0, #CPACR_EL1_FPEN
	msr cpacr_el1, x0
.endm

.macro CLEAR_TCR
	msr tcr_el1, xzr
.endm

.macro SETUP_TCR TSSZ TG0GRAN TG1GRAN IPS TTBR1_ENABLE 
	/*
	* Update TCR
	* Get original and set TSnSZ to 16 (6 bits) at offset 0 and 16
	* We also set IPS (3 bits) at offset 32 to 0b101 which is 48 bits addresses
	* TODO: We don't need to and values now that we start with 0
	*/

	/* mrs x0, tcr_el1 */
	/* Start of with all bits set to 0 */
	mov x0, xzr

	/* Clear TS0SZ and TS1SZ and then set values */

	and x0, x0, ~((1<<6)-1)
	orr x0, x0, \TSSZ	/* TS0SZ*/

	and x0, x0, ~(((1<<6)-1) << 16)
	orr x0, x0, (\TSSZ << 16)	/* TS1SZ */

	/** Set TG0 and TG1 register which controls granularity 00 = 4KB */
	and x0, x0, ~(3 << 14)
.if \TG0GRAN
	orr x0, x0, (\TG0GRAN << 14)
.endif

	and x0, x0, ~(3 << 30)
.if \TG1GRAN
	orr x0, x0, (\TG1GRAN << 30)	/* TG1 = 4KB */
.endif

	/* Can disable table walk of TTBR 1 */
	and x0, x0, ~(1 << 23)
.if \TTBR1_ENABLE
	orr x0, x0, (1 << 23)
.endif

	/* IPS */
	/* Must use a remporary register here because of the restrictions in arm. */
	mov x1, (\IPS << 32)
	and x0, x0, ~(7 << 32)
	orr x0, x0, x1

	/* Store again */
	msr tcr_el1, x0
.endm

