
/home/daniel/workspace/osyxtech/bao-benchmarks/src/irq-lat-wce/irq-lat-wce-guest1/build/irq-lat-wce-guest1/irq-lat-wce-guest1.elf:     file format elf32-littlearm


Disassembly of section .start:

32200000 <_start>:

.section .start, "ax"
.global _start
_start:

    mrs r0, cpsr
32200000:	e10f0000 	mrs	r0, CPSR
    and r1, r0, #CPSR_M_MSK
32200004:	e200100f 	and	r1, r0, #15
    cmp r1, #CPSR_M_HYP
32200008:	e351000a 	cmp	r1, #10
    beq 1f
3220000c:	0a000001 	beq	32200018 <_start+0x18>
    cps #MODE_SVC
32200010:	f1020013 	cps	#19
    b entry_el1
32200014:	ea000018 	b	3220007c <entry_el1>
1:
#if GIC_VERSION == GICV3
    mrc p15, 4, r0, c12, c9, 5 // icc_hsre
32200018:	ee9c0fb9 	mrc	15, 4, r0, cr12, cr9, {5}
    orr r0, r0, #0x9
3220001c:	e3800009 	orr	r0, r0, #9
    mcr p15, 4, r0, c12, c9, 5 // icc_hsre
32200020:	ee8c0fb9 	mcr	15, 4, r0, cr12, cr9, {5}
#endif

###
    /* --- Read/modify/write HACTLR (ACTLR_EL2 equivalent) --- */
    mrc     p15, 4, r0, c1, c0, 1        /* r0 = HACTLR */
32200024:	ee910f30 	mrc	15, 4, r0, cr1, cr0, {1}
    orr     r0, r0, #ACTLR_PERIPHPREGIONR
32200028:	e3800c01 	orr	r0, r0, #256	@ 0x100
    mcr     p15, 4, r0, c1, c0, 1        /* HACTLR = r0 */
3220002c:	ee810f30 	mcr	15, 4, r0, cr1, cr0, {1}

    /* --- Read/modify/write IMP_PERIPHPREGIONR (IMPLEMENTATION-DEFINED) --- */
    /* Replace the following MRC/MCR with the encoding from your TRM. */
    mrc     p15, 0, r1, c15, c0, 0       /* r1 = IMP_PERIPHPREGIONR (PLACEHOLDER) */
32200030:	ee1f1f10 	mrc	15, 0, r1, cr15, cr0, {0}
    orr     r1, r1, #(IMP_PERIPHPREGIONR_ENABLEEL10 | IMP_PERIPHPREGIONR_ENABLEEL2)
32200034:	e3811003 	orr	r1, r1, #3
    mcr     p15, 0, r1, c15, c0, 0       /* IMP_PERIPHPREGIONR = r1 (PLACEHOLDER) */
32200038:	ee0f1f10 	mcr	15, 0, r1, cr15, cr0, {0}

    isb
3220003c:	f57ff06f 	isb	sy
###



#if defined(MPU)
    ldr r0, =0x76120010
32200040:	e59f0188 	ldr	r0, [pc, #392]	@ 322001d0 <clear+0x1c>
    ldr r1, [r0]
32200044:	e5901000 	ldr	r1, [r0]
    and r1, r1, #0x0
32200048:	e2011000 	and	r1, r1, #0
    str r1, [r0]
3220004c:	e5801000 	str	r1, [r0]
    ldr r0, =FREQ
32200050:	e59f017c 	ldr	r0, [pc, #380]	@ 322001d4 <clear+0x20>
    mcr p15, 0, r0, c14, c0, 0 // cntfrq
32200054:	ee0e0f10 	mcr	15, 0, r0, cr14, cr0, {0}
#endif

    mrs r0, cpsr
32200058:	e10f0000 	mrs	r0, CPSR
    mov r1, #MODE_SVC
3220005c:	e3a01013 	mov	r1, #19
    bfi r0, r1, #0, #5
32200060:	e7c40011 	bfi	r0, r1, #0, #5
    msr spsr_hyp, r0
32200064:	e16ef300 	msr	SPSR_hyp, r0
    ldr r0, =entry_el1
32200068:	e59f0168 	ldr	r0, [pc, #360]	@ 322001d8 <clear+0x24>
    msr elr_hyp, r0
3220006c:	e12ef300 	msr	ELR_hyp, r0
    dsb
32200070:	f57ff04f 	dsb	sy
    isb
32200074:	f57ff06f 	isb	sy
    eret
32200078:	e160006e 	eret

3220007c <entry_el1>:

entry_el1:
    mrc p15, 0, r0, c0, c0, 5 // mpidr
3220007c:	ee100fb0 	mrc	15, 0, r0, cr0, cr0, {5}
    and r0, r0, #MPIDR_CPU_MASK
32200080:	e20000ff 	and	r0, r0, #255	@ 0xff

    ldr r1, =_exception_vector
32200084:	e59f1150 	ldr	r1, [pc, #336]	@ 322001dc <clear+0x28>
    mcr	p15, 0, r1, c12, c0, 0 // vbar
32200088:	ee0c1f10 	mcr	15, 0, r1, cr12, cr0, {0}

    // Enable floating point
    mov r1, #(0xf << 20)
3220008c:	e3a0160f 	mov	r1, #15728640	@ 0xf00000
    mcr p15, 0, r1, c1, c0, 2 // cpacr
32200090:	ee011f50 	mcr	15, 0, r1, cr1, cr0, {2}
    isb
32200094:	f57ff06f 	isb	sy
    mov r1, #(0x1 << 30)
32200098:	e3a01101 	mov	r1, #1073741824	@ 0x40000000
    vmsr fpexc, r1
3220009c:	eee81a10 	vmsr	fpexc, r1

    // TODO: invalidate caches, bp, etc...

    ldr r4, =MAIR_EL1_DFLT
322000a0:	e59f4138 	ldr	r4, [pc, #312]	@ 322001e0 <clear+0x2c>
    mcr p15, 0, r4, c10, c2, 0 // mair
322000a4:	ee0a4f12 	mcr	15, 0, r4, cr10, cr2, {0}

#ifdef MPU

    // Set MPU region for cacheability and shareability
    mov r4, #0
322000a8:	e3a04000 	mov	r4, #0
    mcr p15, 0, r4, c6, c2, 1  // prselr
322000ac:	ee064f32 	mcr	15, 0, r4, cr6, cr2, {1}
    ldr r4, =(MEM_BASE)
322000b0:	e59f412c 	ldr	r4, [pc, #300]	@ 322001e4 <clear+0x30>
    and r4, r4, #PRBAR_BASE_MSK
322000b4:	e3c4403f 	bic	r4, r4, #63	@ 0x3f
    orr r4, r4, #(PRBAR_SH_IS | PRBAR_AP_RW_ALL)
322000b8:	e384401a 	orr	r4, r4, #26
    mcr p15, 0, r4, c6, c3, 0  // prbar
322000bc:	ee064f13 	mcr	15, 0, r4, cr6, cr3, {0}
    ldr r4, =(MEM_BASE + MEM_SIZE - 1)
322000c0:	e59f4120 	ldr	r4, [pc, #288]	@ 322001e8 <clear+0x34>
    and r4, r4, #PRLAR_LIMIT_MSK
322000c4:	e3c4403f 	bic	r4, r4, #63	@ 0x3f
    orr r4, r4, #(PRLAR_ATTR(1) | PRLAR_EN)
322000c8:	e3844003 	orr	r4, r4, #3
    mcr p15, 0, r4, c6, c3, 1  // prlar
322000cc:	ee064f33 	mcr	15, 0, r4, cr6, cr3, {1}

    ldr r4, =(MEM_BASE)
322000d0:	e59f410c 	ldr	r4, [pc, #268]	@ 322001e4 <clear+0x30>
    cmp r4, #0
322000d4:	e3540000 	cmp	r4, #0
    blne devices_low
322000d8:	1b000003 	blne	322000ec <devices_low>
    ldr r5, =(MEM_BASE + MEM_SIZE)
322000dc:	e59f5108 	ldr	r5, [pc, #264]	@ 322001ec <clear+0x38>
    cmp r5, #0xffffffff
322000e0:	e3750001 	cmn	r5, #1
    bne devices_high
322000e4:	1a00000a 	bne	32200114 <devices_high>
    b 1f
322000e8:	ea000011 	b	32200134 <devices_high+0x20>

322000ec <devices_low>:

    devices_low:
    mov r4, #1
322000ec:	e3a04001 	mov	r4, #1
    mcr p15, 0, r4, c6, c2, 1  // prselr
322000f0:	ee064f32 	mcr	15, 0, r4, cr6, cr2, {1}
    mov r4, #(PRBAR_BASE(0) | PRBAR_SH_IS | PRBAR_AP_RW_ALL)
322000f4:	e3a0401a 	mov	r4, #26
    mcr p15, 0, r4, c6, c3, 0  // prbar
322000f8:	ee064f13 	mcr	15, 0, r4, cr6, cr3, {0}
    ldr r4, =(MEM_BASE - 1)
322000fc:	e59f40ec 	ldr	r4, [pc, #236]	@ 322001f0 <clear+0x3c>
    and r4, r4, #PRLAR_LIMIT_MSK
32200100:	e3c4403f 	bic	r4, r4, #63	@ 0x3f
    orr r4, r4, #(PRLAR_ATTR(2) | PRLAR_EN)
32200104:	e3844005 	orr	r4, r4, #5
    mcr p15, 0, r4, c6, c3, 1  // prlar
32200108:	ee064f33 	mcr	15, 0, r4, cr6, cr3, {1}
    mov r4, #1
3220010c:	e3a04001 	mov	r4, #1
    bx lr
32200110:	e12fff1e 	bx	lr

32200114 <devices_high>:

    devices_high:
    add r4, r4, #1
32200114:	e2844001 	add	r4, r4, #1
    mcr p15, 0, r4, c6, c2, 1  // prselr
32200118:	ee064f32 	mcr	15, 0, r4, cr6, cr2, {1}
    ldr r4, =(MEM_BASE + MEM_SIZE)
3220011c:	e59f40c8 	ldr	r4, [pc, #200]	@ 322001ec <clear+0x38>
    and r4, r4, #PRBAR_BASE_MSK
32200120:	e3c4403f 	bic	r4, r4, #63	@ 0x3f
    orr r4, r4, #(PRBAR_SH_IS | PRBAR_AP_RW_ALL)
32200124:	e384401a 	orr	r4, r4, #26
    mcr p15, 0, r4, c6, c3, 0  // prbar
32200128:	ee064f13 	mcr	15, 0, r4, cr6, cr3, {0}
    mov r4, #(PRLAR_LIMIT(0xffffffffUL) | PRLAR_ATTR(2) | PRLAR_EN)
3220012c:	e3e0403a 	mvn	r4, #58	@ 0x3a
    mcr p15, 0, r4, c6, c3, 1  // prlar
32200130:	ee064f33 	mcr	15, 0, r4, cr6, cr3, {1}

    1:
    dsb
32200134:	f57ff04f 	dsb	sy
    isb
32200138:	f57ff06f 	isb	sy

    ldr r1, =(SCTLR_RES1 | SCTLR_C | SCTLR_I | SCTLR_BR   | SCTLR_M)
3220013c:	e59f10b0 	ldr	r1, [pc, #176]	@ 322001f4 <clear+0x40>
    mcr p15, 0, r1, c1, c0, 0 // sctlr
32200140:	ee011f10 	mcr	15, 0, r1, cr1, cr0, {0}
    dsb
    isb

#endif

	dsb	nsh
32200144:	f57ff047 	dsb	un
	isb
32200148:	f57ff06f 	isb	sy

    cmp r0, #0
3220014c:	e3500000 	cmp	r0, #0
    bne 1f
32200150:	1a000005 	bne	3220016c <devices_high+0x58>

    ldr r11, =__bss_start 
32200154:	e59fb09c 	ldr	fp, [pc, #156]	@ 322001f8 <clear+0x44>
    ldr r12, =__bss_end
32200158:	e59fc09c 	ldr	ip, [pc, #156]	@ 322001fc <clear+0x48>
    bl  clear
3220015c:	eb000014 	bl	322001b4 <clear>
    .balign 4
wait_flag:
    .word 0x0
    .popsection

    ldr r1, =wait_flag
32200160:	e59f1098 	ldr	r1, [pc, #152]	@ 32200200 <clear+0x4c>
    mov r2, #1
32200164:	e3a02001 	mov	r2, #1
    str r2, [r1]
32200168:	e5812000 	str	r2, [r1]
1:
    ldr r1, =wait_flag
3220016c:	e59f108c 	ldr	r1, [pc, #140]	@ 32200200 <clear+0x4c>
    ldr r2, [r1]
32200170:	e5912000 	ldr	r2, [r1]
    cmp r2, #0
32200174:	e3520000 	cmp	r2, #0
    beq 1b
32200178:	0afffffb 	beq	3220016c <devices_high+0x58>

    ldr r1, =_stack_base
3220017c:	e59f1080 	ldr	r1, [pc, #128]	@ 32200204 <clear+0x50>
    ldr r2, =STACK_SIZE
32200180:	e3a02901 	mov	r2, #16384	@ 0x4000
    add r3, r2, r2 // r3 = 2 * STACK_SIZE
32200184:	e0823002 	add	r3, r2, r2
#ifndef SINGLE_CORE
    mul r4, r3, r0 // r4 = cpuid * (2*STACK_SIZE)
32200188:	e0040093 	mul	r4, r3, r0
    add r1, r1, r4
3220018c:	e0811004 	add	r1, r1, r4
#endif
    add sp, r1, r2
32200190:	e081d002 	add	sp, r1, r2
    cps #MODE_IRQ
32200194:	f1020012 	cps	#18
    isb
32200198:	f57ff06f 	isb	sy
    add sp, r1, r3
3220019c:	e081d003 	add	sp, r1, r3
    cps #MODE_SVC
322001a0:	f1020013 	cps	#19
    isb
322001a4:	f57ff06f 	isb	sy

    // TODO: other c runtime init (eg ctors)

    bl _init
322001a8:	eb0000c6 	bl	322004c8 <_init>
    b _exit
322001ac:	ea0000b9 	b	32200498 <_exit>

322001b0 <psci_wake_up>:

.global psci_wake_up
psci_wake_up:
    b .
322001b0:	eafffffe 	b	322001b0 <psci_wake_up>

322001b4 <clear>:

 .func clear
clear:
    mov r10, #0
322001b4:	e3a0a000 	mov	sl, #0
2:
	cmp	r11, r12			
322001b8:	e15b000c 	cmp	fp, ip
	bge 1f				
322001bc:	aa000002 	bge	322001cc <clear+0x18>
	str	r10, [r11]
322001c0:	e58ba000 	str	sl, [fp]
    add r11, r11, #4
322001c4:	e28bb004 	add	fp, fp, #4
	b	2b				
322001c8:	eafffffa 	b	322001b8 <clear+0x4>
1:
	bx lr
322001cc:	e12fff1e 	bx	lr
    ldr r0, =0x76120010
322001d0:	76120010 	.word	0x76120010
    ldr r0, =FREQ
322001d4:	02625a00 	.word	0x02625a00
    ldr r0, =entry_el1
322001d8:	3220007c 	.word	0x3220007c
    ldr r1, =_exception_vector
322001dc:	32202180 	.word	0x32202180
    ldr r4, =MAIR_EL1_DFLT
322001e0:	0004ff00 	.word	0x0004ff00
    ldr r4, =(MEM_BASE)
322001e4:	32200000 	.word	0x32200000
    ldr r4, =(MEM_BASE + MEM_SIZE - 1)
322001e8:	322fffff 	.word	0x322fffff
    ldr r5, =(MEM_BASE + MEM_SIZE)
322001ec:	32300000 	.word	0x32300000
    ldr r4, =(MEM_BASE - 1)
322001f0:	321fffff 	.word	0x321fffff
    ldr r1, =(SCTLR_RES1 | SCTLR_C | SCTLR_I | SCTLR_BR   | SCTLR_M)
322001f4:	30c71835 	.word	0x30c71835
    ldr r11, =__bss_start 
322001f8:	32214000 	.word	0x32214000
    ldr r12, =__bss_end
322001fc:	322153a0 	.word	0x322153a0
    ldr r1, =wait_flag
32200200:	3220c144 	.word	0x3220c144
    ldr r1, =_stack_base
32200204:	322153a0 	.word	0x322153a0

Disassembly of section .text:

32200240 <timer_handler>:
#define SMCC32_FID_VND_HYP_SRVC (0x86000000)
#define SMCC64_FID_VND_HYP_SRVC (SMCC32_FID_VND_HYP_SRVC | SMCC64_BIT)

volatile unsigned c = 1000;
volatile unsigned long irq_lat = 0;
void timer_handler(unsigned int id){
32200240:	e92d0030 	push	{r4, r5}
SYSREG_GEN_ACCESSORS(mair1, 4, c10, c2, 1);
SYSREG_GEN_ACCESSORS_MERGE(mair_el1, mair0, mair1);

SYSREG_GEN_ACCESSORS(cntfrq_el0, 0, c14, c0, 0);
SYSREG_GEN_ACCESSORS(cntv_ctl_el0, 0, c14, c3, 1);
SYSREG_GEN_ACCESSORS_64(cntvct_el0, 1, c14);
32200244:	ec502f1e 	mrrc	15, 1, r2, r0, cr14
}

static inline uint64_t timer_get()
{
    uint64_t time = sysreg_cntvct_el0_read();
    return time - last_set_cnt;
32200248:	e3040000 	movw	r0, #16384	@ 0x4000
3220024c:	e3430221 	movt	r0, #12833	@ 0x3221
    char str[50];
    unsigned long latency = timer_get() - TIMER_INTERVAL;
    if(c < 800){
32200250:	e30c1130 	movw	r1, #49456	@ 0xc130
32200254:	e3431220 	movt	r1, #12832	@ 0x3220
32200258:	e1c040d0 	ldrd	r4, [r0]
3220025c:	e5911000 	ldr	r1, [r1]
32200260:	e3510e32 	cmp	r1, #800	@ 0x320
32200264:	2a000004 	bcs	3220027c <timer_handler+0x3c>
        if(latency > irq_lat) {
32200268:	e5901008 	ldr	r1, [r0, #8]
3220026c:	e0522004 	subs	r2, r2, r4
    unsigned long latency = timer_get() - TIMER_INTERVAL;
32200270:	e2422001 	sub	r2, r2, #1
        if(latency > irq_lat) {
32200274:	e1510002 	cmp	r1, r2
            irq_lat = latency;
32200278:	35802008 	strcc	r2, [r0, #8]
        }
    }
}
3220027c:	e8bd0030 	pop	{r4, r5}
32200280:	e12fff1e 	bx	lr

32200284 <main>:

void main(void){
32200284:	e92d4890 	push	{r4, r7, fp, lr}

    printf("Bao bare-metal irq-lat WCE 1\n");
32200288:	e30b06d0 	movw	r0, #46800	@ 0xb6d0
3220028c:	e3430220 	movt	r0, #12832	@ 0x3220
32200290:	fa000f10 	blx	32203ed8 <puts>
SYSREG_GEN_ACCESSORS_64(cntv_cval_el0, 3, c14);
32200294:	e3e02000 	mvn	r2, #0
32200298:	e3e03000 	mvn	r3, #0
3220029c:	e3e00000 	mvn	r0, #0
322002a0:	e3a01000 	mov	r1, #0
322002a4:	ec402f3e 	mcrr	15, 3, r2, r0, cr14
SYSREG_GEN_ACCESSORS(cntv_ctl_el0, 0, c14, c3, 1);
322002a8:	e3a03001 	mov	r3, #1
322002ac:	ee0e3f33 	mcr	15, 0, r3, cr14, cr3, {1}
SYSREG_GEN_ACCESSORS_64(cntvct_el0, 1, c14);
322002b0:	ec5a0f1e 	mrrc	15, 1, r0, sl, cr14
static inline void timer_enable(void)
{
    sysreg_cntv_cval_el0_write(~0ULL);
    sysreg_cntv_ctl_el0_write(1);
    /* Initialize reference point so timer_get() is defined. */
    last_set_cnt = sysreg_cntvct_el0_read();
322002b4:	e3048000 	movw	r8, #16384	@ 0x4000
322002b8:	e3438221 	movt	r8, #12833	@ 0x3221
322002bc:	e1a02000 	mov	r2, r0

    timer_enable();
    irq_set_handler(TIMER_IRQ_ID, timer_handler);
322002c0:	e3001240 	movw	r1, #576	@ 0x240
322002c4:	e3431220 	movt	r1, #12832	@ 0x3220
322002c8:	e3a0001b 	mov	r0, #27
322002cc:	e1a0300a 	mov	r3, sl
322002d0:	e1c820f0 	strd	r2, [r8]
322002d4:	eb000028 	bl	3220037c <irq_set_handler>
    irq_set_prio(TIMER_IRQ_ID, IRQ_MAX_PRIO);
322002d8:	e3a01000 	mov	r1, #0
322002dc:	e3a0001b 	mov	r0, #27
322002e0:	eb000433 	bl	322013b4 <irq_set_prio>
    irq_enable(TIMER_IRQ_ID);
322002e4:	e3a0001b 	mov	r0, #27
322002e8:	eb000428 	bl	32201390 <irq_enable>

    while(c--){
322002ec:	e30cc130 	movw	ip, #49456	@ 0xc130
322002f0:	e343c220 	movt	ip, #12832	@ 0x3220
322002f4:	e59c3000 	ldr	r3, [ip]
322002f8:	e2432001 	sub	r2, r3, #1
322002fc:	e3530000 	cmp	r3, #0
32200300:	e58c2000 	str	r2, [ip]
32200304:	0a000013 	beq	32200358 <main+0xd4>
#ifndef __ARCH_BAO_H__
#define __ARCH_BAO_H__

static inline void bao_hypercall(unsigned long fid)
{
    asm volatile(
32200308:	e3a0e003 	mov	lr, #3
3220030c:	e34ce600 	movt	lr, #50688	@ 0xc600
32200310:	e3a09000 	mov	r9, #0
32200314:	ec520f1e 	mrrc	15, 1, r0, r2, cr14
32200318:	e1a06000 	mov	r6, r0
3220031c:	e1a07002 	mov	r7, r2
    last_set_cnt = sysreg_cntvct_el0_read();
32200320:	e1c860f0 	strd	r6, [r8]
SYSREG_GEN_ACCESSORS_64(cntv_cval_el0, 3, c14);
32200324:	e1a01009 	mov	r1, r9
    sysreg_cntv_cval_el0_write(n+last_set_cnt);
32200328:	e1c820d0 	ldrd	r2, [r8]
3220032c:	e2924001 	adds	r4, r2, #1
32200330:	e2a35000 	adc	r5, r3, #0
32200334:	e1a00005 	mov	r0, r5
32200338:	ec404f3e 	mcrr	15, 3, r4, r0, cr14
3220033c:	e1a0000e 	mov	r0, lr
32200340:	e140ea71 	hvc	3745	@ 0xea1
32200344:	e59c3000 	ldr	r3, [ip]
32200348:	e2432001 	sub	r2, r3, #1
3220034c:	e3530000 	cmp	r3, #0
32200350:	e58c2000 	str	r2, [ip]
32200354:	1affffee 	bne	32200314 <main+0x90>
        timer_set(TIMER_INTERVAL);
        bao_hypercall(BAO_YIELD_HYPCALL_ID | SMCC64_FID_VND_HYP_SRVC);
    }

    printf("IRQ Latency WCE:\t%u\n", irq_lat);
32200358:	e5981008 	ldr	r1, [r8, #8]
3220035c:	e30b06f0 	movw	r0, #46832	@ 0xb6f0
32200360:	e3430220 	movt	r0, #12832	@ 0x3220
32200364:	fa000ea1 	blx	32203df0 <printf>
    printf("finished\n");
32200368:	e30b0708 	movw	r0, #46856	@ 0xb708
3220036c:	e3430220 	movt	r0, #12832	@ 0x3220
32200370:	fa000ed8 	blx	32203ed8 <puts>
#ifndef WFI_H
#define WFI_H

static inline void wfi(){
    asm volatile("wfi\n\t" ::: "memory");
32200374:	e320f003 	wfi
    while(1)
32200378:	eafffffd 	b	32200374 <main+0xf0>

3220037c <irq_set_handler>:
#include <irq.h>

irq_handler_t irq_handlers[IRQ_NUM]; 

void irq_set_handler(unsigned id, irq_handler_t handler){
    if(id < IRQ_NUM)
3220037c:	e3500b01 	cmp	r0, #1024	@ 0x400
        irq_handlers[id] = handler;
32200380:	3304300c 	movwcc	r3, #16396	@ 0x400c
32200384:	33433221 	movtcc	r3, #12833	@ 0x3221
32200388:	37831100 	strcc	r1, [r3, r0, lsl #2]
}
3220038c:	e12fff1e 	bx	lr

32200390 <irq_handle>:

void irq_handle(unsigned id){
    if(id < IRQ_NUM && irq_handlers[id] != NULL)
32200390:	e3500b01 	cmp	r0, #1024	@ 0x400
32200394:	212fff1e 	bxcs	lr
32200398:	e304200c 	movw	r2, #16396	@ 0x400c
3220039c:	e3432221 	movt	r2, #12833	@ 0x3221
322003a0:	e7923100 	ldr	r3, [r2, r0, lsl #2]
322003a4:	e3530000 	cmp	r3, #0
322003a8:	012fff1e 	bxeq	lr
        irq_handlers[id](id);
322003ac:	e12fff13 	bx	r3

322003b0 <_read>:
#include <fences.h>
#include <wfi.h>
#include <plat.h>

int _read(int file, char *ptr, int len)
{
322003b0:	e92d4070 	push	{r4, r5, r6, lr}
    int i;
    for (i = 0; i < len; ++i)
322003b4:	e2526000 	subs	r6, r2, #0
322003b8:	da000005 	ble	322003d4 <_read+0x24>
322003bc:	e2414001 	sub	r4, r1, #1
322003c0:	e0845006 	add	r5, r4, r6
    {
        ptr[i] = uart_getchar();
322003c4:	eb00035e 	bl	32201144 <uart_getchar>
322003c8:	e5e40001 	strb	r0, [r4, #1]!
    for (i = 0; i < len; ++i)
322003cc:	e1540005 	cmp	r4, r5
322003d0:	1afffffb 	bne	322003c4 <_read+0x14>
    }

    return len;
}
322003d4:	e1a00006 	mov	r0, r6
322003d8:	e8bd8070 	pop	{r4, r5, r6, pc}

322003dc <_write>:

int _write(int file, char *ptr, int len)
{
322003dc:	e92d4070 	push	{r4, r5, r6, lr}
    int i;
    for (i = 0; i < len; ++i)
322003e0:	e2526000 	subs	r6, r2, #0
322003e4:	da00000e 	ble	32200424 <_write+0x48>
322003e8:	e2414001 	sub	r4, r1, #1
322003ec:	e0845006 	add	r5, r4, r6
322003f0:	ea000002 	b	32200400 <_write+0x24>
    {
        if (ptr[i] == '\n')
        {
            uart_putc('\r');
        }
        uart_putc(ptr[i]);
322003f4:	eb00034c 	bl	3220112c <uart_putc>
    for (i = 0; i < len; ++i)
322003f8:	e1540005 	cmp	r4, r5
322003fc:	0a000008 	beq	32200424 <_write+0x48>
        if (ptr[i] == '\n')
32200400:	e5f40001 	ldrb	r0, [r4, #1]!
32200404:	e350000a 	cmp	r0, #10
32200408:	1afffff9 	bne	322003f4 <_write+0x18>
            uart_putc('\r');
3220040c:	e3a0000d 	mov	r0, #13
32200410:	eb000345 	bl	3220112c <uart_putc>
        uart_putc(ptr[i]);
32200414:	e5d40000 	ldrb	r0, [r4]
32200418:	eb000343 	bl	3220112c <uart_putc>
    for (i = 0; i < len; ++i)
3220041c:	e1540005 	cmp	r4, r5
32200420:	1afffff6 	bne	32200400 <_write+0x24>
    }

    return len;
}
32200424:	e1a00006 	mov	r0, r6
32200428:	e8bd8070 	pop	{r4, r5, r6, pc}

3220042c <_lseek>:

int _lseek(int file, int ptr, int dir)
{
3220042c:	e92d4010 	push	{r4, lr}
    errno = ESPIPE;
32200430:	fa001240 	blx	32204d38 <__errno>
32200434:	e1a03000 	mov	r3, r0
32200438:	e3a0201d 	mov	r2, #29
    return -1;
}
3220043c:	e3e00000 	mvn	r0, #0
    errno = ESPIPE;
32200440:	e5832000 	str	r2, [r3]
}
32200444:	e8bd8010 	pop	{r4, pc}

32200448 <_close>:

int _close(int file)
{
    return -1;
}
32200448:	e3e00000 	mvn	r0, #0
3220044c:	e12fff1e 	bx	lr

32200450 <_fstat>:

int _fstat(int file, struct stat *st)
{
    st->st_mode = S_IFCHR;
32200450:	e3a03a02 	mov	r3, #8192	@ 0x2000
    return 0;
}
32200454:	e3a00000 	mov	r0, #0
    st->st_mode = S_IFCHR;
32200458:	e5813004 	str	r3, [r1, #4]
}
3220045c:	e12fff1e 	bx	lr

32200460 <_isatty>:

int _isatty(int fd)
{
32200460:	e92d4010 	push	{r4, lr}
    errno = ENOTTY;
32200464:	fa001233 	blx	32204d38 <__errno>
32200468:	e1a03000 	mov	r3, r0
3220046c:	e3a02019 	mov	r2, #25
    return 0;
}
32200470:	e3a00000 	mov	r0, #0
    errno = ENOTTY;
32200474:	e5832000 	str	r2, [r3]
}
32200478:	e8bd8010 	pop	{r4, pc}

3220047c <_sbrk>:

void* _sbrk(int increment)
{
    extern char _heap_base;
    static char* heap_end = &_heap_base;
    char* current_heap_end = heap_end;
3220047c:	e30c3134 	movw	r3, #49460	@ 0xc134
32200480:	e3433220 	movt	r3, #12832	@ 0x3220
{
32200484:	e1a02000 	mov	r2, r0
    char* current_heap_end = heap_end;
32200488:	e5930000 	ldr	r0, [r3]
    heap_end += increment;
3220048c:	e0802002 	add	r2, r0, r2
32200490:	e5832000 	str	r2, [r3]
    return current_heap_end;
}
32200494:	e12fff1e 	bx	lr

32200498 <_exit>:
    DMB(ishld);
}

static inline void fence_ord()
{
    DMB(ish);
32200498:	f57ff05b 	dmb	ish
3220049c:	e320f003 	wfi

void _exit(int return_value)
{
    fence_ord();
    while (1) {
322004a0:	eafffffd 	b	3220049c <_exit+0x4>

322004a4 <_getpid>:
}

int _getpid(void)
{
  return 1;
}
322004a4:	e3a00001 	mov	r0, #1
322004a8:	e12fff1e 	bx	lr

322004ac <_kill>:

int _kill(int pid, int sig)
{
322004ac:	e92d4010 	push	{r4, lr}
    errno = EINVAL;
322004b0:	fa001220 	blx	32204d38 <__errno>
322004b4:	e1a03000 	mov	r3, r0
322004b8:	e3a02016 	mov	r2, #22
    return -1;
}
322004bc:	e3e00000 	mvn	r0, #0
    errno = EINVAL;
322004c0:	e5832000 	str	r2, [r3]
}
322004c4:	e8bd8010 	pop	{r4, pc}

322004c8 <_init>:

static bool init_done = false;
static spinlock_t init_lock = SPINLOCK_INITVAL;

__attribute__((weak))
void _init(){
322004c8:	e92d4010 	push	{r4, lr}
    uint32_t ticket;
    uint32_t next;
    uint32_t temp;

    (void)lock;
    __asm__ volatile(
322004cc:	e305400c 	movw	r4, #20492	@ 0x500c
322004d0:	e3434221 	movt	r4, #12833	@ 0x3221
322004d4:	e2840004 	add	r0, r4, #4
322004d8:	e1943e9f 	ldaex	r3, [r4]
322004dc:	e2832001 	add	r2, r3, #1
322004e0:	e1841f92 	strex	r1, r2, [r4]
322004e4:	e3510000 	cmp	r1, #0
322004e8:	1afffffa 	bne	322004d8 <_init+0x10>
322004ec:	e5902000 	ldr	r2, [r0]
322004f0:	e1530002 	cmp	r3, r2
322004f4:	0a000001 	beq	32200500 <_init+0x38>
322004f8:	e320f002 	wfe
322004fc:	eafffffa 	b	322004ec <_init+0x24>

    spin_lock(&init_lock);
    if(!init_done) {
32200500:	e5d43008 	ldrb	r3, [r4, #8]
32200504:	e3530000 	cmp	r3, #0
32200508:	0a000008 	beq	32200530 <_init+0x68>

static inline void spin_unlock(spinlock_t* lock)
{
    uint32_t temp;

    __asm__ volatile(
3220050c:	e2842004 	add	r2, r4, #4
32200510:	e5923000 	ldr	r3, [r2]
32200514:	e2833001 	add	r3, r3, #1
32200518:	e182fc93 	stl	r3, [r2]
3220051c:	f57ff04b 	dsb	ish
32200520:	e320f004 	sev
        plat_init();
        uart_init();
    }
    spin_unlock(&init_lock);

    arch_init();
32200524:	eb000363 	bl	322012b8 <arch_init>

    int ret = main();
32200528:	ebffff55 	bl	32200284 <main>
    _exit(ret);
3220052c:	ebffffd9 	bl	32200498 <_exit>
        init_done = true;
32200530:	e3a03001 	mov	r3, #1
32200534:	e5c43008 	strb	r3, [r4, #8]
        plat_init();
32200538:	eb00030d 	bl	32201174 <plat_init>
        uart_init();
3220053c:	eb0002f2 	bl	3220110c <uart_init>
32200540:	eafffff1 	b	3220050c <_init+0x44>

32200544 <virtio_console_mmio_init>:
    return ret;
}

bool virtio_console_mmio_init(struct virtio_console *console)
{
    if (console->mmio->MagicValue != VIRTIO_MAGIC_VALUE)
32200544:	e5903048 	ldr	r3, [r0, #72]	@ 0x48
32200548:	e3062976 	movw	r2, #26998	@ 0x6976
3220054c:	e3472472 	movt	r2, #29810	@ 0x7472
{
32200550:	e92d4010 	push	{r4, lr}
    if (console->mmio->MagicValue != VIRTIO_MAGIC_VALUE)
32200554:	e5931000 	ldr	r1, [r3]
32200558:	e1510002 	cmp	r1, r2
3220055c:	1a000056 	bne	322006bc <virtio_console_mmio_init+0x178>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register magic value mismatch\n");
        return false;
    }

    if (console->mmio->Version != VIRTIO_VERSION_NO_LEGACY)
32200560:	e5932004 	ldr	r2, [r3, #4]
32200564:	e3520002 	cmp	r2, #2
32200568:	1a00004b 	bne	3220069c <virtio_console_mmio_init+0x158>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register version mismatch\n");
        return false;
    }

    if (console->mmio->DeviceID != console->device_id)
3220056c:	e2802f5b 	add	r2, r0, #364	@ 0x16c
32200570:	e5931008 	ldr	r1, [r3, #8]
32200574:	e1d220b0 	ldrh	r2, [r2]
32200578:	e1510002 	cmp	r1, r2
3220057c:	1a00005e 	bne	322006fc <virtio_console_mmio_init+0x1b8>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register device ID mismatch\n");
        return false;
    }

    console->mmio->Status = RESET;
32200580:	e3a02000 	mov	r2, #0
32200584:	e5832070 	str	r2, [r3, #112]	@ 0x70
    console->mmio->Status |= ACKNOWLEDGE;
32200588:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
3220058c:	e3811001 	orr	r1, r1, #1
32200590:	e5831070 	str	r1, [r3, #112]	@ 0x70
    console->mmio->Status |= DRIVER;
32200594:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
32200598:	e3811002 	orr	r1, r1, #2
3220059c:	e5831070 	str	r1, [r3, #112]	@ 0x70

    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER))
322005a0:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
322005a4:	e3510003 	cmp	r1, #3
322005a8:	1a00004b 	bne	322006dc <virtio_console_mmio_init+0x198>
        return false;
    }

    for (int i = 0; i < VIRTIO_MMIO_FEATURE_SEL_SIZE; i++)
    {
        console->mmio->DeviceFeaturesSel = i;
322005ac:	e5832014 	str	r2, [r3, #20]
322005b0:	e3a0c001 	mov	ip, #1
        console->mmio->DriverFeaturesSel = i;
322005b4:	e5832024 	str	r2, [r3, #36]	@ 0x24
        uint64_t acked_features = console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
        console->mmio->DriverFeatures = acked_features;
        console->negotiated_feature_bits |= (acked_features << (i * 32));
    }

    if (console->negotiated_feature_bits != VIRTIO_CONSOLE_FEATURES)
322005b8:	e5901170 	ldr	r1, [r0, #368]	@ 0x170
        uint64_t acked_features = console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
322005bc:	e593e010 	ldr	lr, [r3, #16]
        console->mmio->DriverFeatures = acked_features;
322005c0:	e5832020 	str	r2, [r3, #32]
        console->mmio->DeviceFeaturesSel = i;
322005c4:	e583c014 	str	ip, [r3, #20]
        console->mmio->DriverFeaturesSel = i;
322005c8:	e583c024 	str	ip, [r3, #36]	@ 0x24
        uint64_t acked_features = console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
322005cc:	e593e010 	ldr	lr, [r3, #16]
    if (console->negotiated_feature_bits != VIRTIO_CONSOLE_FEATURES)
322005d0:	e590e174 	ldr	lr, [r0, #372]	@ 0x174
        console->mmio->DriverFeatures = acked_features;
322005d4:	e5832020 	str	r2, [r3, #32]
    if (console->negotiated_feature_bits != VIRTIO_CONSOLE_FEATURES)
322005d8:	e191100e 	orrs	r1, r1, lr
322005dc:	1a00004e 	bne	3220071c <virtio_console_mmio_init+0x1d8>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register feature mismatch\n");
        return false;
    }

    console->config_space.cols = console->mmio->Config & 0xFFFF;
322005e0:	e5931100 	ldr	r1, [r3, #256]	@ 0x100
322005e4:	e1c014bc 	strh	r1, [r0, #76]	@ 0x4c
    console->config_space.rows = (console->mmio->Config >> 16) & 0xFFFF;
322005e8:	e5931100 	ldr	r1, [r3, #256]	@ 0x100
322005ec:	e1a01821 	lsr	r1, r1, #16
322005f0:	e1c014be 	strh	r1, [r0, #78]	@ 0x4e
    console->config_space.max_nr_ports = *((volatile uint32_t *)((uintptr_t)&console->mmio->Config + 0x4));
322005f4:	e5931104 	ldr	r1, [r3, #260]	@ 0x104
322005f8:	e5801050 	str	r1, [r0, #80]	@ 0x50
    console->config_space.emerg_wr = *((volatile uint32_t *)((uintptr_t)&console->mmio->Config + 0x8));
322005fc:	e5931108 	ldr	r1, [r3, #264]	@ 0x108
32200600:	e5801054 	str	r1, [r0, #84]	@ 0x54

    console->mmio->Status |= FEATURES_OK;
32200604:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
32200608:	e3811008 	orr	r1, r1, #8
3220060c:	e5831070 	str	r1, [r3, #112]	@ 0x70

    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER | FEATURES_OK))
32200610:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
32200614:	e351000b 	cmp	r1, #11
32200618:	1a00002f 	bne	322006dc <virtio_console_mmio_init+0x198>
        return false;
    }

    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
    {
        console->mmio->QueueSel = vq_id;
3220061c:	e5832030 	str	r2, [r3, #48]	@ 0x30
        if (console->mmio->QueueReady != 0)
32200620:	e2822001 	add	r2, r2, #1
32200624:	e5931044 	ldr	r1, [r3, #68]	@ 0x44
32200628:	e3510000 	cmp	r1, #0
3220062c:	1a000041 	bne	32200738 <virtio_console_mmio_init+0x1f4>
            console->mmio->Status |= FAILED;
            printf("VirtIO MMIO register queue ready mismatch\n");
            return false;
        }

        int queue_num_max = console->mmio->QueueNumMax;
32200630:	e5931034 	ldr	r1, [r3, #52]	@ 0x34

        if (queue_num_max == 0)
32200634:	e3510000 	cmp	r1, #0
32200638:	0a000045 	beq	32200754 <virtio_console_mmio_init+0x210>
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
3220063c:	e3520002 	cmp	r2, #2
            return false;
        }

        console->mmio->QueueDescLow = (uint32_t)((uint64_t)console->vqs[vq_id].desc & 0xFFFFFFFF);
        console->mmio->QueueDescHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].desc >> 32) & 0xFFFFFFFF);
        console->mmio->QueueDriverLow = (uint32_t)((uint64_t)console->vqs[vq_id].avail & 0xFFFFFFFF);
32200640:	e8900006 	ldm	r0, {r1, r2}
        console->mmio->QueueDescLow = (uint32_t)((uint64_t)console->vqs[vq_id].desc & 0xFFFFFFFF);
32200644:	e5831080 	str	r1, [r3, #128]	@ 0x80
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
32200648:	e2800024 	add	r0, r0, #36	@ 0x24
        console->mmio->QueueDescHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].desc >> 32) & 0xFFFFFFFF);
3220064c:	e1a01fc1 	asr	r1, r1, #31
32200650:	e5831084 	str	r1, [r3, #132]	@ 0x84
        console->mmio->QueueDriverHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].avail >> 32) & 0xFFFFFFFF);
        console->mmio->QueueDeviceLow= (uint32_t)((uint64_t)console->vqs[vq_id].used & 0xFFFFFFFF);
32200654:	e510101c 	ldr	r1, [r0, #-28]	@ 0xffffffe4
        console->mmio->QueueDriverLow = (uint32_t)((uint64_t)console->vqs[vq_id].avail & 0xFFFFFFFF);
32200658:	e5832090 	str	r2, [r3, #144]	@ 0x90
        console->mmio->QueueDriverHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].avail >> 32) & 0xFFFFFFFF);
3220065c:	e1a02fc2 	asr	r2, r2, #31
32200660:	e5832094 	str	r2, [r3, #148]	@ 0x94
        console->mmio->QueueDeviceLow= (uint32_t)((uint64_t)console->vqs[vq_id].used & 0xFFFFFFFF);
32200664:	e3a02001 	mov	r2, #1
32200668:	e58310a0 	str	r1, [r3, #160]	@ 0xa0
        console->mmio->QueueDeviceHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].used >> 32) & 0xFFFFFFFF);
3220066c:	e1a01fc1 	asr	r1, r1, #31
32200670:	e58310a4 	str	r1, [r3, #164]	@ 0xa4

        console->mmio->QueueReady = 1;
32200674:	e583c044 	str	ip, [r3, #68]	@ 0x44
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
32200678:	1affffe7 	bne	3220061c <virtio_console_mmio_init+0xd8>
    }

    console->mmio->Status |= DRIVER_OK;
3220067c:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
32200680:	e3811004 	orr	r1, r1, #4
32200684:	e5831070 	str	r1, [r3, #112]	@ 0x70
    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER | FEATURES_OK | DRIVER_OK))
32200688:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
3220068c:	e351000f 	cmp	r1, #15
32200690:	1a000011 	bne	322006dc <virtio_console_mmio_init+0x198>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register status mismatch\n");
        return false;
    }

    return true;
32200694:	e1a00002 	mov	r0, r2
}
32200698:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
3220069c:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register version mismatch\n");
322006a0:	e30b0740 	movw	r0, #46912	@ 0xb740
322006a4:	e3430220 	movt	r0, #12832	@ 0x3220
        console->mmio->Status |= FAILED;
322006a8:	e3822080 	orr	r2, r2, #128	@ 0x80
322006ac:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register version mismatch\n");
322006b0:	fa000e08 	blx	32203ed8 <puts>
        return false;
322006b4:	e3a00000 	mov	r0, #0
322006b8:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
322006bc:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register magic value mismatch\n");
322006c0:	e30b0714 	movw	r0, #46868	@ 0xb714
322006c4:	e3430220 	movt	r0, #12832	@ 0x3220
        console->mmio->Status |= FAILED;
322006c8:	e3822080 	orr	r2, r2, #128	@ 0x80
322006cc:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register magic value mismatch\n");
322006d0:	fa000e00 	blx	32203ed8 <puts>
        return false;
322006d4:	e3a00000 	mov	r0, #0
322006d8:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
322006dc:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register status mismatch\n");
322006e0:	e30b0790 	movw	r0, #46992	@ 0xb790
322006e4:	e3430220 	movt	r0, #12832	@ 0x3220
        console->mmio->Status |= FAILED;
322006e8:	e3822080 	orr	r2, r2, #128	@ 0x80
322006ec:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register status mismatch\n");
322006f0:	fa000df8 	blx	32203ed8 <puts>
        return false;
322006f4:	e3a00000 	mov	r0, #0
322006f8:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
322006fc:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register device ID mismatch\n");
32200700:	e30b0768 	movw	r0, #46952	@ 0xb768
32200704:	e3430220 	movt	r0, #12832	@ 0x3220
        console->mmio->Status |= FAILED;
32200708:	e3822080 	orr	r2, r2, #128	@ 0x80
3220070c:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register device ID mismatch\n");
32200710:	fa000df0 	blx	32203ed8 <puts>
        return false;
32200714:	e3a00000 	mov	r0, #0
32200718:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
3220071c:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register feature mismatch\n");
32200720:	e30b07b8 	movw	r0, #47032	@ 0xb7b8
32200724:	e3430220 	movt	r0, #12832	@ 0x3220
        console->mmio->Status |= FAILED;
32200728:	e3822080 	orr	r2, r2, #128	@ 0x80
3220072c:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register feature mismatch\n");
32200730:	fa000de8 	blx	32203ed8 <puts>
        return false;
32200734:	eaffffde 	b	322006b4 <virtio_console_mmio_init+0x170>
            console->mmio->Status |= FAILED;
32200738:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
            printf("VirtIO MMIO register queue ready mismatch\n");
3220073c:	e30b07e0 	movw	r0, #47072	@ 0xb7e0
32200740:	e3430220 	movt	r0, #12832	@ 0x3220
            console->mmio->Status |= FAILED;
32200744:	e3822080 	orr	r2, r2, #128	@ 0x80
32200748:	e5832070 	str	r2, [r3, #112]	@ 0x70
            printf("VirtIO MMIO register queue ready mismatch\n");
3220074c:	fa000de1 	blx	32203ed8 <puts>
            return false;
32200750:	eaffffd7 	b	322006b4 <virtio_console_mmio_init+0x170>
            console->mmio->Status |= FAILED;
32200754:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
            printf("VirtIO MMIO register queue number max mismatch\n");
32200758:	e30b080c 	movw	r0, #47116	@ 0xb80c
3220075c:	e3430220 	movt	r0, #12832	@ 0x3220
            console->mmio->Status |= FAILED;
32200760:	e3822080 	orr	r2, r2, #128	@ 0x80
32200764:	e5832070 	str	r2, [r3, #112]	@ 0x70
            printf("VirtIO MMIO register queue number max mismatch\n");
32200768:	fa000dda 	blx	32203ed8 <puts>
            return false;
3220076c:	eaffffd0 	b	322006b4 <virtio_console_mmio_init+0x170>

32200770 <virtio_console_init>:
{
32200770:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
32200774:	e1a04000 	mov	r4, r0
    console->device_id = VIRTIO_CONSOLE_DEVICE_ID;
32200778:	e280ef5b 	add	lr, r0, #364	@ 0x16c
    console->negotiated_feature_bits = 0;
3220077c:	e284ce17 	add	ip, r4, #368	@ 0x170
32200780:	e1a03001 	mov	r3, r1
{
32200784:	e24dd014 	sub	sp, sp, #20
    console->ready = false;
32200788:	e3a00000 	mov	r0, #0
    console->device_id = VIRTIO_CONSOLE_DEVICE_ID;
3220078c:	e3a05003 	mov	r5, #3
    console->ready = false;
32200790:	e5c40178 	strb	r0, [r4, #376]	@ 0x178
    console->negotiated_feature_bits = 0;
32200794:	e3a06000 	mov	r6, #0
    console->device_id = VIRTIO_CONSOLE_DEVICE_ID;
32200798:	e1ce50b0 	strh	r5, [lr]
    console->negotiated_feature_bits = 0;
3220079c:	e3a07000 	mov	r7, #0
    console->mmio = (volatile struct virtio_mmio_reg *)mmio_base;
322007a0:	e5842048 	str	r2, [r4, #72]	@ 0x48
 */
static inline void virtq_init(struct virtq *vq, uint16_t queue_index, char* vq_base_addr)
{
    /* Initialize the descriptor ring */
    vq->desc = (volatile struct virtq_desc *)VIRTQ_DESC_ADDR(vq_base_addr);
    for (int i = 0; i < VIRTQ_SIZE; i++)
322007a4:	e300e401 	movw	lr, #1025	@ 0x401
    console->negotiated_feature_bits = 0;
322007a8:	e1cc60f0 	strd	r6, [ip]
    vq->desc = (volatile struct virtq_desc *)VIRTQ_DESC_ADDR(vq_base_addr);
322007ac:	e3a02001 	mov	r2, #1
    console->rx_buffer[0] = '\0';
322007b0:	e5c40058 	strb	r0, [r4, #88]	@ 0x58
    console->rx_buffer_pos = 0;
322007b4:	e5840158 	str	r0, [r4, #344]	@ 0x158
    console->rx_lock = SPINLOCK_INITVAL;
322007b8:	e584015c 	str	r0, [r4, #348]	@ 0x15c
322007bc:	e5840160 	str	r0, [r4, #352]	@ 0x160
    console->tx_lock = SPINLOCK_INITVAL;
322007c0:	e5840164 	str	r0, [r4, #356]	@ 0x164
322007c4:	e5840168 	str	r0, [r4, #360]	@ 0x168
322007c8:	e5841000 	str	r1, [r4]
    {
        vq->desc[i].addr = 0;
322007cc:	e6ffc072 	uxth	ip, r2
    for (int i = 0; i < VIRTQ_SIZE; i++)
322007d0:	e2822001 	add	r2, r2, #1
        vq->desc[i].addr = 0;
322007d4:	e1c360f0 	strd	r6, [r3]
    for (int i = 0; i < VIRTQ_SIZE; i++)
322007d8:	e152000e 	cmp	r2, lr
        vq->desc[i].len = 0;
322007dc:	e5830008 	str	r0, [r3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++)
322007e0:	e2833010 	add	r3, r3, #16
        vq->desc[i].flags = 0;
322007e4:	e14300b4 	strh	r0, [r3, #-4]
        vq->desc[i].next = i + 1;
322007e8:	e143c0b2 	strh	ip, [r3, #-2]
    for (int i = 0; i < VIRTQ_SIZE; i++)
322007ec:	1afffff6 	bne	322007cc <virtio_console_init+0x5c>
    vq->desc[VIRTQ_SIZE - 1].next = 0;
    vq->desc_next_free = 0;
    vq->desc_num_free = VIRTQ_SIZE;

    /* Initialize the available ring */
    vq->avail = (volatile struct virtq_avail *)VIRTQ_AVAIL_ADDR(vq_base_addr);
322007f0:	e281c901 	add	ip, r1, #16384	@ 0x4000
    vq->desc[VIRTQ_SIZE - 1].next = 0;
322007f4:	e2813dff 	add	r3, r1, #16320	@ 0x3fc0
    vq->desc_next_free = 0;
322007f8:	e3a02301 	mov	r2, #67108864	@ 0x4000000
    vq->desc[VIRTQ_SIZE - 1].next = 0;
322007fc:	e1c303be 	strh	r0, [r3, #62]	@ 0x3e
    vq->avail->flags = 0;
    vq->avail->idx = 0;
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200800:	e3a03000 	mov	r3, #0
    vq->desc_next_free = 0;
32200804:	e584200e 	str	r2, [r4, #14]
    vq->avail = (volatile struct virtq_avail *)VIRTQ_AVAIL_ADDR(vq_base_addr);
32200808:	e584c004 	str	ip, [r4, #4]
    vq->avail->flags = 0;
3220080c:	e1cc00b0 	strh	r0, [ip]
    vq->avail->idx = 0;
32200810:	e1cc00b2 	strh	r0, [ip, #2]
    {
        vq->avail->ring[i] = 0;
32200814:	e1a00003 	mov	r0, r3
32200818:	e08c2083 	add	r2, ip, r3, lsl #1
    for (int i = 0; i < VIRTQ_SIZE; i++)
3220081c:	e2833001 	add	r3, r3, #1
32200820:	e3530b01 	cmp	r3, #1024	@ 0x400
        vq->avail->ring[i] = 0;
32200824:	e1c200b4 	strh	r0, [r2, #4]
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200828:	1afffffa 	bne	32200818 <virtio_console_init+0xa8>
    }
    vq->avail_last_idx = 0;

    /* Initialize the used ring */
    vq->used = (volatile struct virtq_used *)VIRTQ_USED_ADDR(vq_base_addr);
3220082c:	e2813a05 	add	r3, r1, #20480	@ 0x5000
    vq->avail_last_idx = 0;
32200830:	e1c401b2 	strh	r0, [r4, #18]
    vq->used = (volatile struct virtq_used *)VIRTQ_USED_ADDR(vq_base_addr);
32200834:	e5843008 	str	r3, [r4, #8]
    vq->used->flags = 0;
    vq->used->idx = 0;
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200838:	e3a02000 	mov	r2, #0
    vq->used->flags = 0;
3220083c:	e1c300b0 	strh	r0, [r3]
    vq->used->idx = 0;
32200840:	e1c300b2 	strh	r0, [r3, #2]
    {
        vq->used->ring[i].id = 0;
32200844:	e1a00002 	mov	r0, r2
32200848:	e0813182 	add	r3, r1, r2, lsl #3
    for (int i = 0; i < VIRTQ_SIZE; i++)
3220084c:	e2822001 	add	r2, r2, #1
        vq->used->ring[i].id = 0;
32200850:	e2833a05 	add	r3, r3, #20480	@ 0x5000
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200854:	e3520b01 	cmp	r2, #1024	@ 0x400
        vq->used->ring[i].id = 0;
32200858:	e5830004 	str	r0, [r3, #4]
        vq->used->ring[i].len = 0;
3220085c:	e5830008 	str	r0, [r3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200860:	1afffff8 	bne	32200848 <virtio_console_init+0xd8>
    vq->last_used_idx = 0;

    vq->queue_index = queue_index;

    /* Initialize the memory pool */
    virtio_memory_pool_init(&vq->pool, (char *)VIRTQ_MEMORY_POOL_ADDR(vq_base_addr), VIRTQ_MEMORY_POOL_SIZE);
32200864:	e2812902 	add	r2, r1, #32768	@ 0x8000
    vq->last_used_idx = 0;
32200868:	e1c401b4 	strh	r0, [r4, #20]
    vq->queue_index = queue_index;
3220086c:	e1c400bc 	strh	r0, [r4, #12]
 * @param size Length of the memory to allocate
 */
static inline void virtio_memory_pool_init(struct virtio_memory_pool* pool, char* base, unsigned long size)
{
    pool->base = base;
    pool->size = size;
32200870:	e3a03801 	mov	r3, #65536	@ 0x10000
    pool->offset = 0;
32200874:	e5840020 	str	r0, [r4, #32]
    pool->size = size;
32200878:	e584301c 	str	r3, [r4, #28]

    /* Mark all memory as free */
    for (unsigned long i = 0; i < size; i++) {
3220087c:	e3a03001 	mov	r3, #1
    pool->base = base;
32200880:	e5842018 	str	r2, [r4, #24]
        pool->base[i] = 0;
32200884:	e5c20000 	strb	r0, [r2]
32200888:	e3a00000 	mov	r0, #0
3220088c:	e5942018 	ldr	r2, [r4, #24]
32200890:	e7c20003 	strb	r0, [r2, r3]
    for (unsigned long i = 0; i < size; i++) {
32200894:	e2833001 	add	r3, r3, #1
32200898:	e3530801 	cmp	r3, #65536	@ 0x10000
3220089c:	1afffffa 	bne	3220088c <virtio_console_init+0x11c>
    virtq_init(&console->vqs[VIRTIO_CONSOLE_TX_VQ_IDX], VIRTIO_CONSOLE_TX_VQ_IDX, shmem_base + VIRTQ_SIZE_TOTAL);
322008a0:	e2810906 	add	r0, r1, #98304	@ 0x18000
    vq->desc = (volatile struct virtq_desc *)VIRTQ_DESC_ADDR(vq_base_addr);
322008a4:	e3a02001 	mov	r2, #1
322008a8:	e1a03000 	mov	r3, r0
322008ac:	e5840024 	str	r0, [r4, #36]	@ 0x24
        vq->desc[i].addr = 0;
322008b0:	e3a06000 	mov	r6, #0
322008b4:	e3a07000 	mov	r7, #0
        vq->desc[i].len = 0;
322008b8:	e3a00000 	mov	r0, #0
    for (int i = 0; i < VIRTQ_SIZE; i++)
322008bc:	e300e401 	movw	lr, #1025	@ 0x401
        vq->desc[i].addr = 0;
322008c0:	e6ffc072 	uxth	ip, r2
    for (int i = 0; i < VIRTQ_SIZE; i++)
322008c4:	e2822001 	add	r2, r2, #1
        vq->desc[i].addr = 0;
322008c8:	e1c360f0 	strd	r6, [r3]
    for (int i = 0; i < VIRTQ_SIZE; i++)
322008cc:	e152000e 	cmp	r2, lr
        vq->desc[i].len = 0;
322008d0:	e5830008 	str	r0, [r3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++)
322008d4:	e2833010 	add	r3, r3, #16
        vq->desc[i].flags = 0;
322008d8:	e14300b4 	strh	r0, [r3, #-4]
        vq->desc[i].next = i + 1;
322008dc:	e143c0b2 	strh	ip, [r3, #-2]
    for (int i = 0; i < VIRTQ_SIZE; i++)
322008e0:	1afffff6 	bne	322008c0 <virtio_console_init+0x150>
    vq->desc[VIRTQ_SIZE - 1].next = 0;
322008e4:	e2813b6f 	add	r3, r1, #113664	@ 0x1bc00
    vq->avail = (volatile struct virtq_avail *)VIRTQ_AVAIL_ADDR(vq_base_addr);
322008e8:	e281c907 	add	ip, r1, #114688	@ 0x1c000
    vq->desc[VIRTQ_SIZE - 1].next = 0;
322008ec:	e2833e3f 	add	r3, r3, #1008	@ 0x3f0
    vq->desc_next_free = 0;
322008f0:	e3a02301 	mov	r2, #67108864	@ 0x4000000
    vq->desc[VIRTQ_SIZE - 1].next = 0;
322008f4:	e1c300be 	strh	r0, [r3, #14]
    for (int i = 0; i < VIRTQ_SIZE; i++)
322008f8:	e3a03000 	mov	r3, #0
    vq->desc_next_free = 0;
322008fc:	e5842032 	str	r2, [r4, #50]	@ 0x32
    vq->avail = (volatile struct virtq_avail *)VIRTQ_AVAIL_ADDR(vq_base_addr);
32200900:	e584c028 	str	ip, [r4, #40]	@ 0x28
    vq->avail->flags = 0;
32200904:	e1cc00b0 	strh	r0, [ip]
    vq->avail->idx = 0;
32200908:	e1cc00b2 	strh	r0, [ip, #2]
        vq->avail->ring[i] = 0;
3220090c:	e1a00003 	mov	r0, r3
32200910:	e08c2083 	add	r2, ip, r3, lsl #1
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200914:	e2833001 	add	r3, r3, #1
32200918:	e3530b01 	cmp	r3, #1024	@ 0x400
        vq->avail->ring[i] = 0;
3220091c:	e1c200b4 	strh	r0, [r2, #4]
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200920:	1afffffa 	bne	32200910 <virtio_console_init+0x1a0>
    vq->used = (volatile struct virtq_used *)VIRTQ_USED_ADDR(vq_base_addr);
32200924:	e2813a1d 	add	r3, r1, #118784	@ 0x1d000
    vq->avail_last_idx = 0;
32200928:	e1c403b6 	strh	r0, [r4, #54]	@ 0x36
    vq->used = (volatile struct virtq_used *)VIRTQ_USED_ADDR(vq_base_addr);
3220092c:	e584302c 	str	r3, [r4, #44]	@ 0x2c
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200930:	e3a02000 	mov	r2, #0
    vq->used->flags = 0;
32200934:	e1c300b0 	strh	r0, [r3]
    vq->used->idx = 0;
32200938:	e1c300b2 	strh	r0, [r3, #2]
        vq->used->ring[i].id = 0;
3220093c:	e1a00002 	mov	r0, r2
32200940:	e0813182 	add	r3, r1, r2, lsl #3
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200944:	e2822001 	add	r2, r2, #1
        vq->used->ring[i].id = 0;
32200948:	e2833a1d 	add	r3, r3, #118784	@ 0x1d000
    for (int i = 0; i < VIRTQ_SIZE; i++)
3220094c:	e3520b01 	cmp	r2, #1024	@ 0x400
        vq->used->ring[i].id = 0;
32200950:	e5830004 	str	r0, [r3, #4]
        vq->used->ring[i].len = 0;
32200954:	e5830008 	str	r0, [r3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++)
32200958:	1afffff8 	bne	32200940 <virtio_console_init+0x1d0>
    virtio_memory_pool_init(&vq->pool, (char *)VIRTQ_MEMORY_POOL_ADDR(vq_base_addr), VIRTQ_MEMORY_POOL_SIZE);
3220095c:	e2811802 	add	r1, r1, #131072	@ 0x20000
    vq->queue_index = queue_index;
32200960:	e3a03001 	mov	r3, #1
    vq->last_used_idx = 0;
32200964:	e1c403b8 	strh	r0, [r4, #56]	@ 0x38
    pool->size = size;
32200968:	e3a02801 	mov	r2, #65536	@ 0x10000
    vq->queue_index = queue_index;
3220096c:	e1c433b0 	strh	r3, [r4, #48]	@ 0x30
        pool->base[i] = 0;
32200970:	e3a0c000 	mov	ip, #0
    pool->base = base;
32200974:	e584103c 	str	r1, [r4, #60]	@ 0x3c
    pool->offset = 0;
32200978:	e5840044 	str	r0, [r4, #68]	@ 0x44
    pool->size = size;
3220097c:	e5842040 	str	r2, [r4, #64]	@ 0x40
        pool->base[i] = 0;
32200980:	e5c10000 	strb	r0, [r1]
32200984:	e594203c 	ldr	r2, [r4, #60]	@ 0x3c
32200988:	e7c2c003 	strb	ip, [r2, r3]
    for (unsigned long i = 0; i < size; i++) {
3220098c:	e2833001 	add	r3, r3, #1
32200990:	e3530801 	cmp	r3, #65536	@ 0x10000
32200994:	1afffffa 	bne	32200984 <virtio_console_init+0x214>
 * @param vq VirtIO virtqueue
 * @return true if there are free slots, false otherwise
 */
static inline bool virtq_has_free_slots(struct virtq *vq)
{
    return vq->desc_num_free != 0;
32200998:	e1d431b0 	ldrh	r3, [r4, #16]
    while (virtq_has_free_slots(&console->vqs[VIRTIO_CONSOLE_RX_VQ_IDX]))
3220099c:	e3530000 	cmp	r3, #0
322009a0:	0a00004e 	beq	32200ae0 <virtio_console_init+0x370>
 * @return Returns the next free descriptor index
 */
static inline uint16_t virtq_get_free_desc_id(struct virtq *vq)
{
    assert(virtq_has_free_slots(vq));
    uint16_t idx = vq->desc_next_free;
322009a4:	e1d480be 	ldrh	r8, [r4, #14]
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
    vq->desc_num_free--;
322009a8:	e2433001 	sub	r3, r3, #1
 * @param alloc_size Size of the memory to allocate
 * @return Returns a pointer to the allocated memory, or NULL if the allocation failed
 */
static inline char* virtio_memory_pool_alloc(struct virtio_memory_pool* pool, unsigned long alloc_size) {
    /** Check if the requested allocation size is larger than the pool size */
    if (alloc_size > pool->size) {
322009ac:	e594201c 	ldr	r2, [r4, #28]
    return &vq->desc[id % VIRTQ_SIZE];
322009b0:	e5940000 	ldr	r0, [r4]
    vq->desc_num_free--;
322009b4:	e6ffc073 	uxth	ip, r3
322009b8:	e352003f 	cmp	r2, #63	@ 0x3f
322009bc:	e58d2004 	str	r2, [sp, #4]
    return &vq->desc[id % VIRTQ_SIZE];
322009c0:	e7e92058 	ubfx	r2, r8, #0, #10
 */
static inline void virtq_desc_init(volatile struct virtq_desc *desc, uint64_t addr, uint32_t len)
{
    desc->addr = addr;
    desc->len = len;
    desc->flags = 0;
322009c4:	83a09000 	movhi	r9, #0
    return &vq->desc[id % VIRTQ_SIZE];
322009c8:	e0802202 	add	r2, r0, r2, lsl #4
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
322009cc:	e1d210be 	ldrh	r1, [r2, #14]
    vq->desc_num_free--;
322009d0:	e1c4c1b0 	strh	ip, [r4, #16]
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
322009d4:	e6ff1071 	uxth	r1, r1
322009d8:	e1c410be 	strh	r1, [r4, #14]
322009dc:	9a00003c 	bls	32200ad4 <virtio_console_init+0x364>
        return NULL;
    }

    /** Check if there is enough space from the current offset to the end of the pool */
    if (pool->offset + alloc_size <= pool->size) {
322009e0:	e5946020 	ldr	r6, [r4, #32]
322009e4:	e59d3004 	ldr	r3, [sp, #4]
322009e8:	e2867040 	add	r7, r6, #64	@ 0x40
322009ec:	e1530007 	cmp	r3, r7
322009f0:	3a000040 	bcc	32200af8 <virtio_console_init+0x388>
        /* Get the pointer to the possible allocated memory */
        char *ptr = pool->base + pool->offset;
322009f4:	e594e018 	ldr	lr, [r4, #24]

        /* Check if the memory is already allocated */
        for (unsigned long i = 0; i < alloc_size; i++) {
322009f8:	e286503f 	add	r5, r6, #63	@ 0x3f
322009fc:	e2463001 	sub	r3, r6, #1
32200a00:	e1cda0f8 	strd	sl, [sp, #8]
32200a04:	e08e5005 	add	r5, lr, r5
32200a08:	e1a0b004 	mov	fp, r4
32200a0c:	e08e3003 	add	r3, lr, r3
32200a10:	e1a04008 	mov	r4, r8
32200a14:	e1a08001 	mov	r8, r1
32200a18:	e1a01002 	mov	r1, r2
32200a1c:	e1a02005 	mov	r2, r5
            if (pool->base[pool->offset + i] != 0) {
32200a20:	e5f35001 	ldrb	r5, [r3, #1]!
32200a24:	e3550000 	cmp	r5, #0
32200a28:	1a000028 	bne	32200ad0 <virtio_console_init+0x360>
        for (unsigned long i = 0; i < alloc_size; i++) {
32200a2c:	e1530002 	cmp	r3, r2
32200a30:	1afffffa 	bne	32200a20 <virtio_console_init+0x2b0>
        char *ptr = pool->base + pool->offset;
32200a34:	e1a02001 	mov	r2, r1
32200a38:	e08ee006 	add	lr, lr, r6
32200a3c:	e1a01008 	mov	r1, r8
32200a40:	e1a08004 	mov	r8, r4
32200a44:	e1a0400b 	mov	r4, fp
        if(io_buffer == NULL) {
32200a48:	e35e0000 	cmp	lr, #0
                return NULL;
            }
        }

        /* Increment the offset for the next allocation */
        pool->offset += alloc_size;
32200a4c:	e5847020 	str	r7, [r4, #32]
32200a50:	0a00001f 	beq	32200ad4 <virtio_console_init+0x364>
        virtq_desc_init(desc, (uint64_t)io_buffer, VIRTIO_CONSOLE_RX_BUFFER_SIZE);
32200a54:	e1a0a00e 	mov	sl, lr
32200a58:	e1a0bfce 	asr	fp, lr, #31
    desc->len = len;
32200a5c:	e3a03040 	mov	r3, #64	@ 0x40
    desc->addr = addr;
32200a60:	e1c2a0f0 	strd	sl, [r2]
    desc->len = len;
32200a64:	e5823008 	str	r3, [r2, #8]
    while (virtq_has_free_slots(&console->vqs[VIRTIO_CONSOLE_RX_VQ_IDX]))
32200a68:	e35c0000 	cmp	ip, #0
    desc->flags = 0;
32200a6c:	e1c290bc 	strh	r9, [r2, #12]
    desc->next = 0;
32200a70:	e1c290be 	strh	r9, [r2, #14]
 * @param vq VirtIO virtqueue
 * @param id Descriptor index
 */
static inline void virtq_add_avail_buf(struct virtq *vq, uint16_t id)
{
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
32200a74:	e594e004 	ldr	lr, [r4, #4]
    desc->flags |= VIRTQ_DESC_F_WRITE;
32200a78:	e1d230bc 	ldrh	r3, [r2, #12]
32200a7c:	e3833002 	orr	r3, r3, #2
32200a80:	e1c230bc 	strh	r3, [r2, #12]
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
32200a84:	e1de30b2 	ldrh	r3, [lr, #2]
32200a88:	e7e93053 	ubfx	r3, r3, #0, #10
32200a8c:	e08e3083 	add	r3, lr, r3, lsl #1
32200a90:	e1c380b4 	strh	r8, [r3, #4]
    vq->avail->idx++;
32200a94:	e1de30b2 	ldrh	r3, [lr, #2]
32200a98:	e2833001 	add	r3, r3, #1
32200a9c:	e6ff3073 	uxth	r3, r3
32200aa0:	e1ce30b2 	strh	r3, [lr, #2]
32200aa4:	0a00000d 	beq	32200ae0 <virtio_console_init+0x370>
    return &vq->desc[id % VIRTQ_SIZE];
32200aa8:	e7e92051 	ubfx	r2, r1, #0, #10
    vq->desc_num_free--;
32200aac:	e1a08001 	mov	r8, r1
32200ab0:	e24cc001 	sub	ip, ip, #1
    return &vq->desc[id % VIRTQ_SIZE];
32200ab4:	e0802202 	add	r2, r0, r2, lsl #4
    vq->desc_num_free--;
32200ab8:	e6ffc07c 	uxth	ip, ip
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
32200abc:	e1d210be 	ldrh	r1, [r2, #14]
    vq->desc_num_free--;
32200ac0:	e1c4c1b0 	strh	ip, [r4, #16]
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
32200ac4:	e6ff1071 	uxth	r1, r1
32200ac8:	e1c410be 	strh	r1, [r4, #14]
    if (alloc_size > pool->size) {
32200acc:	eaffffc3 	b	322009e0 <virtio_console_init+0x270>
32200ad0:	e1a0400b 	mov	r4, fp
            printf("Failed to allocate memory for I/O buffer\n");
32200ad4:	e30b083c 	movw	r0, #47164	@ 0xb83c
32200ad8:	e3430220 	movt	r0, #12832	@ 0x3220
32200adc:	fa000cfd 	blx	32203ed8 <puts>
    ret = virtio_console_mmio_init(console);
32200ae0:	e1a00004 	mov	r0, r4
32200ae4:	ebfffe96 	bl	32200544 <virtio_console_mmio_init>
    console->ready = true;
32200ae8:	e3a03001 	mov	r3, #1
32200aec:	e5c43178 	strb	r3, [r4, #376]	@ 0x178
}
32200af0:	e28dd014 	add	sp, sp, #20
32200af4:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
        /* Return the pointer to the allocated memory */
        return ptr;
    }

    /** If we reached the end of the pool, wrap around (circular buffer behavior) */
    if (alloc_size <= pool->offset) {
32200af8:	e356003f 	cmp	r6, #63	@ 0x3f
32200afc:	9afffff4 	bls	32200ad4 <virtio_console_init+0x364>
        /* Get the pointer to the possible allocated memory */
        char *ptr = pool->base;
32200b00:	e594e018 	ldr	lr, [r4, #24]

        /* Check if the memory is already allocated */
        for (unsigned long i = 0; i < alloc_size; i++) {
32200b04:	e24e3001 	sub	r3, lr, #1
32200b08:	e28e603f 	add	r6, lr, #63	@ 0x3f
            if (pool->base[i] != 0) {
32200b0c:	e5f35001 	ldrb	r5, [r3, #1]!
32200b10:	e3550000 	cmp	r5, #0
32200b14:	1affffee 	bne	32200ad4 <virtio_console_init+0x364>
        for (unsigned long i = 0; i < alloc_size; i++) {
32200b18:	e1530006 	cmp	r3, r6
32200b1c:	1afffffa 	bne	32200b0c <virtio_console_init+0x39c>
32200b20:	e3a07040 	mov	r7, #64	@ 0x40
32200b24:	eaffffc7 	b	32200a48 <virtio_console_init+0x2d8>

32200b28 <virtio_console_transmit>:
{
    return console->rx_buffer_pos > 1;
}

void virtio_console_transmit(struct virtio_console *console, char *const data)
{
32200b28:	e92d4ff8 	push	{r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
    int data_len = strlen(data);

    if (!console->ready) {
32200b2c:	e5d03178 	ldrb	r3, [r0, #376]	@ 0x178
32200b30:	e3530000 	cmp	r3, #0
32200b34:	0a000060 	beq	32200cbc <virtio_console_transmit+0x194>
32200b38:	e1a04000 	mov	r4, r0
    int data_len = strlen(data);
32200b3c:	e1a00001 	mov	r0, r1
32200b40:	e1a0b001 	mov	fp, r1
32200b44:	fa0012fd 	blx	32205740 <strlen>
        printf("VirtIO console device is not ready\n");
        return;
    }

    if (data == NULL || data_len == 0) {
32200b48:	e2505000 	subs	r5, r0, #0
32200b4c:	0a00004a 	beq	32200c7c <virtio_console_transmit+0x154>
        printf("No data to transmit\n");
        return;
    }

    spin_lock(&console->tx_lock);
32200b50:	e2846f59 	add	r6, r4, #356	@ 0x164
    __asm__ volatile(
32200b54:	e2860004 	add	r0, r6, #4
32200b58:	e1963e9f 	ldaex	r3, [r6]
32200b5c:	e2832001 	add	r2, r3, #1
32200b60:	e1861f92 	strex	r1, r2, [r6]
32200b64:	e3510000 	cmp	r1, #0
32200b68:	1afffffa 	bne	32200b58 <virtio_console_transmit+0x30>
32200b6c:	e5902000 	ldr	r2, [r0]
32200b70:	e1530002 	cmp	r3, r2
32200b74:	0a000001 	beq	32200b80 <virtio_console_transmit+0x58>
32200b78:	e320f002 	wfe
32200b7c:	eafffffa 	b	32200b6c <virtio_console_transmit+0x44>
    return vq->desc_num_free != 0;
32200b80:	e1d433b4 	ldrh	r3, [r4, #52]	@ 0x34
    assert(virtq_has_free_slots(vq));
32200b84:	e3530000 	cmp	r3, #0
32200b88:	0a000059 	beq	32200cf4 <virtio_console_transmit+0x1cc>
    uint16_t idx = vq->desc_next_free;
32200b8c:	e1d493b2 	ldrh	r9, [r4, #50]	@ 0x32
    vq->desc_num_free--;
32200b90:	e2433001 	sub	r3, r3, #1
    return &vq->desc[id % VIRTQ_SIZE];
32200b94:	e594a024 	ldr	sl, [r4, #36]	@ 0x24
    if (alloc_size > pool->size) {
32200b98:	e5942040 	ldr	r2, [r4, #64]	@ 0x40
32200b9c:	e7e98059 	ubfx	r8, r9, #0, #10
32200ba0:	e1550002 	cmp	r5, r2
32200ba4:	e1a08208 	lsl	r8, r8, #4
32200ba8:	e08a7008 	add	r7, sl, r8
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
32200bac:	e1d710be 	ldrh	r1, [r7, #14]
32200bb0:	e1c413b2 	strh	r1, [r4, #50]	@ 0x32
    vq->desc_num_free--;
32200bb4:	e1c433b4 	strh	r3, [r4, #52]	@ 0x34
32200bb8:	8a000043 	bhi	32200ccc <virtio_console_transmit+0x1a4>
    if (pool->offset + alloc_size <= pool->size) {
32200bbc:	e5943044 	ldr	r3, [r4, #68]	@ 0x44
32200bc0:	e085c003 	add	ip, r5, r3
32200bc4:	e152000c 	cmp	r2, ip
32200bc8:	3a00002f 	bcc	32200c8c <virtio_console_transmit+0x164>
        for (unsigned long i = 0; i < alloc_size; i++) {
32200bcc:	e594203c 	ldr	r2, [r4, #60]	@ 0x3c
32200bd0:	e0822003 	add	r2, r2, r3
32200bd4:	e1a03002 	mov	r3, r2
32200bd8:	e0850002 	add	r0, r5, r2
            if (pool->base[pool->offset + i] != 0) {
32200bdc:	e4d31001 	ldrb	r1, [r3], #1
32200be0:	e3510000 	cmp	r1, #0
32200be4:	1a000038 	bne	32200ccc <virtio_console_transmit+0x1a4>
        for (unsigned long i = 0; i < alloc_size; i++) {
32200be8:	e1530000 	cmp	r3, r0
32200bec:	1afffffa 	bne	32200bdc <virtio_console_transmit+0xb4>
    /* Get the descriptor */
    volatile struct virtq_desc *desc = virtq_get_desc_by_id(vq, desc_id);

    /* Allocate memory for the I/O buffer from the memory pool */
    char *const io_buffer = virtio_memory_pool_alloc(&vq->pool, data_len);
    if(io_buffer == NULL) {
32200bf0:	e3520000 	cmp	r2, #0

        /* Reset the offset */
        pool->offset = 0;

        /* Increment the offset for the next allocation */
        pool->offset += alloc_size;
32200bf4:	e584c044 	str	ip, [r4, #68]	@ 0x44
32200bf8:	0a000033 	beq	32200ccc <virtio_console_transmit+0x1a4>
        spin_unlock(&console->tx_lock);
        return;
    }

    /* Copy the data to the I/O buffer */
    strcpy(io_buffer, data);
32200bfc:	e1a0100b 	mov	r1, fp
32200c00:	e1a00002 	mov	r0, r2
32200c04:	fa001115 	blx	32205060 <strcpy>
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
32200c08:	e5943028 	ldr	r3, [r4, #40]	@ 0x28

    /* Add the buffer to the available ring */
    virtq_add_avail_buf(vq, desc_id);

    /* Notify the backend device */
    virtio_mmio_queue_notify(console->mmio, vq->queue_index);
32200c0c:	e594b048 	ldr	fp, [r4, #72]	@ 0x48
    desc->flags = 0;
32200c10:	e3a0e000 	mov	lr, #0
32200c14:	e1d443b0 	ldrh	r4, [r4, #48]	@ 0x30
    virtq_desc_init(desc, (uint64_t)io_buffer, data_len);
32200c18:	e1a01fc0 	asr	r1, r0, #31
    desc->addr = addr;
32200c1c:	e18a00f8 	strd	r0, [sl, r8]
    desc->flags &= ~VIRTQ_DESC_F_WRITE;
32200c20:	e30fcffd 	movw	ip, #65533	@ 0xfffd
    desc->len = len;
32200c24:	e5875008 	str	r5, [r7, #8]
    desc->flags = 0;
32200c28:	e1c7e0bc 	strh	lr, [r7, #12]
    desc->next = 0;
32200c2c:	e1c7e0be 	strh	lr, [r7, #14]
    desc->flags &= ~VIRTQ_DESC_F_WRITE;
32200c30:	e1d720bc 	ldrh	r2, [r7, #12]
32200c34:	e00cc002 	and	ip, ip, r2
32200c38:	e1c7c0bc 	strh	ip, [r7, #12]
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
32200c3c:	e1d320b2 	ldrh	r2, [r3, #2]
32200c40:	e7e92052 	ubfx	r2, r2, #0, #10
32200c44:	e0832082 	add	r2, r3, r2, lsl #1
32200c48:	e1c290b4 	strh	r9, [r2, #4]
    vq->avail->idx++;
32200c4c:	e1d320b2 	ldrh	r2, [r3, #2]
32200c50:	e2822001 	add	r2, r2, #1
32200c54:	e6ff2072 	uxth	r2, r2
32200c58:	e1c320b2 	strh	r2, [r3, #2]
    __asm__ volatile(
32200c5c:	e2862004 	add	r2, r6, #4
    uint32_t Config;            // offset 0x100
} __attribute__((__packed__, aligned(0x1000)));

static inline void virtio_mmio_queue_notify(volatile struct virtio_mmio_reg *mmio, uint32_t queue_id)
{
    mmio->QueueNotify = queue_id;
32200c60:	e58b4050 	str	r4, [fp, #80]	@ 0x50
32200c64:	e5923000 	ldr	r3, [r2]
32200c68:	e2833001 	add	r3, r3, #1
32200c6c:	e182fc93 	stl	r3, [r2]
32200c70:	f57ff04b 	dsb	ish
32200c74:	e320f004 	sev

    spin_unlock(&console->tx_lock);
}
32200c78:	e8bd8ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, pc}
        printf("No data to transmit\n");
32200c7c:	e30b088c 	movw	r0, #47244	@ 0xb88c
32200c80:	e3430220 	movt	r0, #12832	@ 0x3220
}
32200c84:	e8bd4ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
        printf("No data to transmit\n");
32200c88:	ea002a8c 	b	3220b6c0 <__puts_from_arm>
    if (alloc_size <= pool->offset) {
32200c8c:	e1550003 	cmp	r5, r3
32200c90:	8a00000d 	bhi	32200ccc <virtio_console_transmit+0x1a4>
        char *ptr = pool->base;
32200c94:	e594203c 	ldr	r2, [r4, #60]	@ 0x3c
        for (unsigned long i = 0; i < alloc_size; i++) {
32200c98:	e2423001 	sub	r3, r2, #1
32200c9c:	e0830005 	add	r0, r3, r5
            if (pool->base[i] != 0) {
32200ca0:	e5f31001 	ldrb	r1, [r3, #1]!
32200ca4:	e3510000 	cmp	r1, #0
32200ca8:	1a000007 	bne	32200ccc <virtio_console_transmit+0x1a4>
        for (unsigned long i = 0; i < alloc_size; i++) {
32200cac:	e1500003 	cmp	r0, r3
32200cb0:	1afffffa 	bne	32200ca0 <virtio_console_transmit+0x178>
32200cb4:	e1a0c005 	mov	ip, r5
32200cb8:	eaffffcc 	b	32200bf0 <virtio_console_transmit+0xc8>
        printf("VirtIO console device is not ready\n");
32200cbc:	e30b0868 	movw	r0, #47208	@ 0xb868
32200cc0:	e3430220 	movt	r0, #12832	@ 0x3220
}
32200cc4:	e8bd4ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
        printf("VirtIO console device is not ready\n");
32200cc8:	ea002a7c 	b	3220b6c0 <__puts_from_arm>
        printf("Failed to allocate memory for I/O buffer\n");
32200ccc:	e30b083c 	movw	r0, #47164	@ 0xb83c
32200cd0:	e3430220 	movt	r0, #12832	@ 0x3220
32200cd4:	fa000c7f 	blx	32203ed8 <puts>
32200cd8:	e2862004 	add	r2, r6, #4
32200cdc:	e5923000 	ldr	r3, [r2]
32200ce0:	e2833001 	add	r3, r3, #1
32200ce4:	e182fc93 	stl	r3, [r2]
32200ce8:	f57ff04b 	dsb	ish
32200cec:	e320f004 	sev
        return;
32200cf0:	e8bd8ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, pc}
    assert(virtq_has_free_slots(vq));
32200cf4:	e30b38a0 	movw	r3, #47264	@ 0xb8a0
32200cf8:	e3433220 	movt	r3, #12832	@ 0x3220
32200cfc:	e30b2c50 	movw	r2, #48208	@ 0xbc50
32200d00:	e3432220 	movt	r2, #12832	@ 0x3220
32200d04:	e30b08bc 	movw	r0, #47292	@ 0xb8bc
32200d08:	e3430220 	movt	r0, #12832	@ 0x3220
32200d0c:	e3a010c1 	mov	r1, #193	@ 0xc1
32200d10:	fa000525 	blx	322021ac <__assert_func>

32200d14 <virtio_console_receive>:

bool virtio_console_receive(struct virtio_console *console)
{
    uint32_t interrupt_status = 0;

    if (!console->ready) {
32200d14:	e5d03178 	ldrb	r3, [r0, #376]	@ 0x178
32200d18:	e3530000 	cmp	r3, #0
32200d1c:	0a000004 	beq	32200d34 <virtio_console_receive+0x20>
        return false;
    }

    /* Read and acknowledge interrupts */
    interrupt_status = console->mmio->InterruptStatus;
32200d20:	e5902048 	ldr	r2, [r0, #72]	@ 0x48
32200d24:	e5923060 	ldr	r3, [r2, #96]	@ 0x60
    console->mmio->InterruptACK = interrupt_status;
32200d28:	e5823064 	str	r3, [r2, #100]	@ 0x64

    if (interrupt_status & VIRTIO_MMIO_INT_CONFIG) {
32200d2c:	e2133002 	ands	r3, r3, #2
32200d30:	0a000001 	beq	32200d3c <virtio_console_receive+0x28>
        return false;
32200d34:	e3a00000 	mov	r0, #0
        return false;
    }

    /* Return true if there are receive buffers available */
    return virtio_console_rx_has_buffers(console);
}
32200d38:	e12fff1e 	bx	lr
{
32200d3c:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
    spin_lock(&console->rx_lock);
32200d40:	e280ef57 	add	lr, r0, #348	@ 0x15c
    __asm__ volatile(
32200d44:	e28e4004 	add	r4, lr, #4
{
32200d48:	e24dd01c 	sub	sp, sp, #28
32200d4c:	e19e2e9f 	ldaex	r2, [lr]
32200d50:	e2821001 	add	r1, r2, #1
32200d54:	e18ecf91 	strex	ip, r1, [lr]
32200d58:	e35c0000 	cmp	ip, #0
32200d5c:	1afffffa 	bne	32200d4c <virtio_console_receive+0x38>
32200d60:	e5941000 	ldr	r1, [r4]
32200d64:	e1520001 	cmp	r2, r1
32200d68:	0a000001 	beq	32200d74 <virtio_console_receive+0x60>
32200d6c:	e320f002 	wfe
32200d70:	eafffffa 	b	32200d60 <virtio_console_receive+0x4c>
    console->rx_buffer[0] = '\0';
32200d74:	e5c03058 	strb	r3, [r0, #88]	@ 0x58
    console->rx_buffer_pos = 0;
32200d78:	e5803158 	str	r3, [r0, #344]	@ 0x158
    __asm__ volatile(
32200d7c:	e5942000 	ldr	r2, [r4]
32200d80:	e2822001 	add	r2, r2, #1
32200d84:	e184fc92 	stl	r2, [r4]
32200d88:	f57ff04b 	dsb	ish
32200d8c:	e320f004 	sev
    return vq->used->idx != vq->last_used_idx;
32200d90:	e5902008 	ldr	r2, [r0, #8]
32200d94:	e1d041b4 	ldrh	r4, [r0, #20]
32200d98:	e1d210b2 	ldrh	r1, [r2, #2]
        if (!virtq_used_has_buf(vq)) {
32200d9c:	e1510004 	cmp	r1, r4
32200da0:	01a01000 	moveq	r1, r0
32200da4:	0a000052 	beq	32200ef4 <virtio_console_receive+0x1e0>
32200da8:	e58d3010 	str	r3, [sp, #16]
32200dac:	e1a01000 	mov	r1, r0
32200db0:	e1a03000 	mov	r3, r0
32200db4:	e1d2c0b2 	ldrh	ip, [r2, #2]
        while (virtq_used_has_buf(vq))
32200db8:	e15c0004 	cmp	ip, r4
32200dbc:	0a000049 	beq	32200ee8 <virtio_console_receive+0x1d4>
32200dc0:	e30f7fa9 	movw	r7, #65449	@ 0xffa9
32200dc4:	e34f7fff 	movt	r7, #65535	@ 0xffff
32200dc8:	e0477000 	sub	r7, r7, r0
32200dcc:	e2808096 	add	r8, r0, #150	@ 0x96
32200dd0:	e58d0004 	str	r0, [sp, #4]
        return false;
    }

    /** Free the memory */
    for (unsigned long i = 0; i < size; i++) {
        pool->base[offset + i] = 0;
32200dd4:	e3a09000 	mov	r9, #0
32200dd8:	e59d0010 	ldr	r0, [sp, #16]
32200ddc:	e58d1014 	str	r1, [sp, #20]
32200de0:	e1d210b2 	ldrh	r1, [r2, #2]
    return vq->avail->ring[vq->avail_last_idx++ % VIRTQ_SIZE];
}

static inline uint16_t virtq_get_used_buf_id(struct virtq *vq)
{
    assert(virtq_used_has_buf(vq));
32200de4:	e1540001 	cmp	r4, r1
32200de8:	0a00009c 	beq	32201060 <virtio_console_receive+0x34c>
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
32200dec:	e7e91054 	ubfx	r1, r4, #0, #10
    return &vq->desc[id % VIRTQ_SIZE];
32200df0:	e593a000 	ldr	sl, [r3]
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
32200df4:	e2844001 	add	r4, r4, #1
32200df8:	e1c341b4 	strh	r4, [r3, #20]
32200dfc:	e0822181 	add	r2, r2, r1, lsl #3
32200e00:	e5921004 	ldr	r1, [r2, #4]
    assert(vq->desc_num_free < VIRTQ_SIZE);
32200e04:	e1d321b0 	ldrh	r2, [r3, #16]
    return &vq->desc[id % VIRTQ_SIZE];
32200e08:	e7e9c051 	ubfx	ip, r1, #0, #10
    assert(vq->desc_num_free < VIRTQ_SIZE);
32200e0c:	e3520b01 	cmp	r2, #1024	@ 0x400
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
32200e10:	e6ff1071 	uxth	r1, r1
    return &vq->desc[id % VIRTQ_SIZE];
32200e14:	e1a0c20c 	lsl	ip, ip, #4
32200e18:	e08a600c 	add	r6, sl, ip
    assert(vq->desc_num_free < VIRTQ_SIZE);
32200e1c:	2a000096 	bcs	3220107c <virtio_console_receive+0x368>
    virtq_get_desc_by_id(vq, id)->next = vq->desc_next_free;
32200e20:	e1d340be 	ldrh	r4, [r3, #14]
    vq->desc_num_free++;
32200e24:	e2822001 	add	r2, r2, #1
    virtq_get_desc_by_id(vq, id)->next = vq->desc_next_free;
32200e28:	e1c640be 	strh	r4, [r6, #14]
            if (vq_id == VIRTIO_CONSOLE_RX_VQ_IDX) {
32200e2c:	e3500000 	cmp	r0, #0
    vq->desc_next_free = id;
32200e30:	e1c310be 	strh	r1, [r3, #14]
    vq->desc_num_free++;
32200e34:	e1c321b0 	strh	r2, [r3, #16]
32200e38:	0a00004b 	beq	32200f6c <virtio_console_receive+0x258>
            if(!virtio_memory_pool_free(&vq->pool, (char*)desc->addr, desc->len)) {
32200e3c:	e18a40dc 	ldrd	r4, [sl, ip]
    if (ptr < pool->base || ptr >= pool->base + pool->size) {
32200e40:	e5931018 	ldr	r1, [r3, #24]
32200e44:	e5962008 	ldr	r2, [r6, #8]
32200e48:	e1a0b004 	mov	fp, r4
32200e4c:	e1540001 	cmp	r4, r1
32200e50:	3a000008 	bcc	32200e78 <virtio_console_receive+0x164>
32200e54:	e593601c 	ldr	r6, [r3, #28]
    if (size > pool->size) {
32200e58:	e1520006 	cmp	r2, r6
    if (ptr < pool->base || ptr >= pool->base + pool->size) {
32200e5c:	e081a006 	add	sl, r1, r6
    if (size > pool->size) {
32200e60:	93a0c000 	movls	ip, #0
32200e64:	83a0c001 	movhi	ip, #1
32200e68:	e15a0004 	cmp	sl, r4
32200e6c:	938cc001 	orrls	ip, ip, #1
32200e70:	e35c0000 	cmp	ip, #0
32200e74:	0a000005 	beq	32200e90 <virtio_console_receive+0x17c>
                printf("Failed to free memory from the memory pool\n");
32200e78:	e30b0958 	movw	r0, #47448	@ 0xb958
32200e7c:	e3430220 	movt	r0, #12832	@ 0x3220
32200e80:	fa000c14 	blx	32203ed8 <puts>
        return false;
32200e84:	e3a00000 	mov	r0, #0
}
32200e88:	e28dd01c 	add	sp, sp, #28
32200e8c:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
    unsigned long offset = ptr - pool->base;
32200e90:	e0444001 	sub	r4, r4, r1
    if (offset < 0 || offset >= pool->size) {
32200e94:	e1560004 	cmp	r6, r4
32200e98:	9afffff6 	bls	32200e78 <virtio_console_receive+0x164>
    for (unsigned long i = 0; i < size; i++) {
32200e9c:	e3520000 	cmp	r2, #0
32200ea0:	0a000009 	beq	32200ecc <virtio_console_receive+0x1b8>
32200ea4:	e3520001 	cmp	r2, #1
        pool->base[offset + i] = 0;
32200ea8:	e5cbc000 	strb	ip, [fp]
    for (unsigned long i = 0; i < size; i++) {
32200eac:	0a000006 	beq	32200ecc <virtio_console_receive+0x1b8>
32200eb0:	e0822004 	add	r2, r2, r4
32200eb4:	e2844001 	add	r4, r4, #1
        pool->base[offset + i] = 0;
32200eb8:	e5931018 	ldr	r1, [r3, #24]
32200ebc:	e7c19004 	strb	r9, [r1, r4]
    for (unsigned long i = 0; i < size; i++) {
32200ec0:	e2844001 	add	r4, r4, #1
32200ec4:	e1540002 	cmp	r4, r2
32200ec8:	1afffffa 	bne	32200eb8 <virtio_console_receive+0x1a4>
    return vq->used->idx != vq->last_used_idx;
32200ecc:	e5932008 	ldr	r2, [r3, #8]
32200ed0:	e1d341b4 	ldrh	r4, [r3, #20]
32200ed4:	e1d210b2 	ldrh	r1, [r2, #2]
        while (virtq_used_has_buf(vq))
32200ed8:	e1510004 	cmp	r1, r4
32200edc:	1affffbf 	bne	32200de0 <virtio_console_receive+0xcc>
32200ee0:	e59d1014 	ldr	r1, [sp, #20]
32200ee4:	e59d0004 	ldr	r0, [sp, #4]
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
32200ee8:	e59d3010 	ldr	r3, [sp, #16]
32200eec:	e3530001 	cmp	r3, #1
32200ef0:	0a000008 	beq	32200f18 <virtio_console_receive+0x204>
32200ef4:	e591202c 	ldr	r2, [r1, #44]	@ 0x2c
32200ef8:	e2811024 	add	r1, r1, #36	@ 0x24
32200efc:	e1a03001 	mov	r3, r1
32200f00:	e1d2c0b2 	ldrh	ip, [r2, #2]
32200f04:	e1d141b4 	ldrh	r4, [r1, #20]
        if (!virtq_used_has_buf(vq)) {
32200f08:	e154000c 	cmp	r4, ip
32200f0c:	13a0c001 	movne	ip, #1
32200f10:	158dc010 	strne	ip, [sp, #16]
32200f14:	1affffa6 	bne	32200db4 <virtio_console_receive+0xa0>
    __asm__ volatile(
32200f18:	e28ec004 	add	ip, lr, #4
32200f1c:	e19e3e9f 	ldaex	r3, [lr]
32200f20:	e2832001 	add	r2, r3, #1
32200f24:	e18e1f92 	strex	r1, r2, [lr]
32200f28:	e3510000 	cmp	r1, #0
32200f2c:	1afffffa 	bne	32200f1c <virtio_console_receive+0x208>
32200f30:	e59c2000 	ldr	r2, [ip]
32200f34:	e1530002 	cmp	r3, r2
32200f38:	0a000001 	beq	32200f44 <virtio_console_receive+0x230>
32200f3c:	e320f002 	wfe
32200f40:	eafffffa 	b	32200f30 <virtio_console_receive+0x21c>
    if (console->rx_buffer_pos < VIRTIO_CONSOLE_RX_CONSOLE_SIZE - 1) {
32200f44:	e5903158 	ldr	r3, [r0, #344]	@ 0x158
32200f48:	e35300fe 	cmp	r3, #254	@ 0xfe
32200f4c:	9a000033 	bls	32201020 <virtio_console_receive+0x30c>
    __asm__ volatile(
32200f50:	e28e2004 	add	r2, lr, #4
32200f54:	e5923000 	ldr	r3, [r2]
32200f58:	e2833001 	add	r3, r3, #1
32200f5c:	e182fc93 	stl	r3, [r2]
32200f60:	f57ff04b 	dsb	ish
32200f64:	e320f004 	sev
    return success;
32200f68:	eaffffc5 	b	32200e84 <virtio_console_receive+0x170>
                char* msg = (char*)desc->addr;
32200f6c:	e18a40dc 	ldrd	r4, [sl, ip]
32200f70:	e1cd40f8 	strd	r4, [sp, #8]
    __asm__ volatile(
32200f74:	e28e4004 	add	r4, lr, #4
32200f78:	e19e2e9f 	ldaex	r2, [lr]
32200f7c:	e2821001 	add	r1, r2, #1
32200f80:	e18ebf91 	strex	fp, r1, [lr]
32200f84:	e35b0000 	cmp	fp, #0
32200f88:	1afffffa 	bne	32200f78 <virtio_console_receive+0x264>
32200f8c:	e5941000 	ldr	r1, [r4]
32200f90:	e1520001 	cmp	r2, r1
32200f94:	0a000001 	beq	32200fa0 <virtio_console_receive+0x28c>
32200f98:	e320f002 	wfe
32200f9c:	eafffffa 	b	32200f8c <virtio_console_receive+0x278>
    if (console->rx_buffer_pos >= VIRTIO_CONSOLE_RX_CONSOLE_SIZE - VIRTIO_CONSOLE_RX_BUFFER_SIZE) {
32200fa0:	e59d2004 	ldr	r2, [sp, #4]
32200fa4:	e592b158 	ldr	fp, [r2, #344]	@ 0x158
32200fa8:	e35b00bf 	cmp	fp, #191	@ 0xbf
32200fac:	9a000005 	bls	32200fc8 <virtio_console_receive+0x2b4>
    __asm__ volatile(
32200fb0:	e5943000 	ldr	r3, [r4]
32200fb4:	e2833001 	add	r3, r3, #1
32200fb8:	e184fc93 	stl	r3, [r4]
32200fbc:	f57ff04b 	dsb	ish
32200fc0:	e320f004 	sev
    return success;
32200fc4:	eaffffae 	b	32200e84 <virtio_console_receive+0x170>
        for (int i = console->rx_buffer_pos; i < VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1 && console->rx_buffer_pos < VIRTIO_CONSOLE_RX_CONSOLE_SIZE; i++) {
32200fc8:	e35b003e 	cmp	fp, #62	@ 0x3e
32200fcc:	ca000009 	bgt	32200ff8 <virtio_console_receive+0x2e4>
32200fd0:	e59d1004 	ldr	r1, [sp, #4]
32200fd4:	e28b2057 	add	r2, fp, #87	@ 0x57
32200fd8:	e1cd40d8 	ldrd	r4, [sp, #8]
32200fdc:	e0812002 	add	r2, r1, r2
            console->rx_buffer[i] = data[i];
32200fe0:	e0821007 	add	r1, r2, r7
32200fe4:	e0811004 	add	r1, r1, r4
32200fe8:	e5d11000 	ldrb	r1, [r1]
32200fec:	e5e21001 	strb	r1, [r2, #1]!
        for (int i = console->rx_buffer_pos; i < VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1 && console->rx_buffer_pos < VIRTIO_CONSOLE_RX_CONSOLE_SIZE; i++) {
32200ff0:	e1520008 	cmp	r2, r8
32200ff4:	1afffff9 	bne	32200fe0 <virtio_console_receive+0x2cc>
        console->rx_buffer_pos += VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1;
32200ff8:	e59d2004 	ldr	r2, [sp, #4]
32200ffc:	e28bb03f 	add	fp, fp, #63	@ 0x3f
32201000:	e28e1004 	add	r1, lr, #4
32201004:	e582b158 	str	fp, [r2, #344]	@ 0x158
32201008:	e5912000 	ldr	r2, [r1]
3220100c:	e2822001 	add	r2, r2, #1
32201010:	e181fc92 	stl	r2, [r1]
32201014:	f57ff04b 	dsb	ish
32201018:	e320f004 	sev
    return success;
3220101c:	eaffff86 	b	32200e3c <virtio_console_receive+0x128>
        console->rx_buffer[console->rx_buffer_pos] = '\0';
32201020:	e0802003 	add	r2, r0, r3
32201024:	e3a01000 	mov	r1, #0
        console->rx_buffer_pos++;
32201028:	e2833001 	add	r3, r3, #1
        console->rx_buffer[console->rx_buffer_pos] = '\0';
3220102c:	e5c21058 	strb	r1, [r2, #88]	@ 0x58
        console->rx_buffer_pos++;
32201030:	e5803158 	str	r3, [r0, #344]	@ 0x158
32201034:	e59c3000 	ldr	r3, [ip]
32201038:	e2833001 	add	r3, r3, #1
3220103c:	e18cfc93 	stl	r3, [ip]
32201040:	f57ff04b 	dsb	ish
32201044:	e320f004 	sev
    return console->rx_buffer_pos > 1;
32201048:	e5900158 	ldr	r0, [r0, #344]	@ 0x158
3220104c:	e3500001 	cmp	r0, #1
32201050:	93a00000 	movls	r0, #0
32201054:	83a00001 	movhi	r0, #1
}
32201058:	e28dd01c 	add	sp, sp, #28
3220105c:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
    assert(virtq_used_has_buf(vq));
32201060:	e30b3920 	movw	r3, #47392	@ 0xb920
32201064:	e3433220 	movt	r3, #12832	@ 0x3220
32201068:	e30b08bc 	movw	r0, #47292	@ 0xb8bc
3220106c:	e3430220 	movt	r0, #12832	@ 0x3220
32201070:	e59f2020 	ldr	r2, [pc, #32]	@ 32201098 <virtio_console_receive+0x384>
32201074:	e3a01f56 	mov	r1, #344	@ 0x158
32201078:	fa00044b 	blx	322021ac <__assert_func>
    assert(vq->desc_num_free < VIRTQ_SIZE);
3220107c:	e30b3938 	movw	r3, #47416	@ 0xb938
32201080:	e3433220 	movt	r3, #12832	@ 0x3220
32201084:	e30b08bc 	movw	r0, #47292	@ 0xb8bc
32201088:	e3430220 	movt	r0, #12832	@ 0x3220
3220108c:	e59f2008 	ldr	r2, [pc, #8]	@ 3220109c <virtio_console_receive+0x388>
32201090:	e3a010cf 	mov	r1, #207	@ 0xcf
32201094:	fa000444 	blx	322021ac <__assert_func>
32201098:	3220bc68 	.word	0x3220bc68
3220109c:	3220bc80 	.word	0x3220bc80

322010a0 <virtio_console_rx_get_buffer>:

char* virtio_console_rx_get_buffer(struct virtio_console *console)
{
    return console->rx_buffer;
}
322010a0:	e2800058 	add	r0, r0, #88	@ 0x58
322010a4:	e12fff1e 	bx	lr

322010a8 <virtio_console_rx_print_buffer>:

void virtio_console_rx_print_buffer(struct virtio_console *console)
{
322010a8:	e92d4010 	push	{r4, lr}
    spin_lock(&console->rx_lock);
322010ac:	e2804f57 	add	r4, r0, #348	@ 0x15c
{
322010b0:	e1a01000 	mov	r1, r0
    __asm__ volatile(
322010b4:	e284c004 	add	ip, r4, #4
322010b8:	e1943e9f 	ldaex	r3, [r4]
322010bc:	e2832001 	add	r2, r3, #1
322010c0:	e1840f92 	strex	r0, r2, [r4]
322010c4:	e3500000 	cmp	r0, #0
322010c8:	1afffffa 	bne	322010b8 <virtio_console_rx_print_buffer+0x10>
322010cc:	e59c2000 	ldr	r2, [ip]
322010d0:	e1530002 	cmp	r3, r2
322010d4:	0a000001 	beq	322010e0 <virtio_console_rx_print_buffer+0x38>
322010d8:	e320f002 	wfe
322010dc:	eafffffa 	b	322010cc <virtio_console_rx_print_buffer+0x24>
    printf("Received message on the VirtIO console: %s\n", console->rx_buffer);
322010e0:	e30b0984 	movw	r0, #47492	@ 0xb984
322010e4:	e3430220 	movt	r0, #12832	@ 0x3220
322010e8:	e2811058 	add	r1, r1, #88	@ 0x58
322010ec:	fa000b3f 	blx	32203df0 <printf>
    __asm__ volatile(
322010f0:	e2842004 	add	r2, r4, #4
322010f4:	e5923000 	ldr	r3, [r2]
322010f8:	e2833001 	add	r3, r3, #1
322010fc:	e182fc93 	stl	r3, [r2]
32201100:	f57ff04b 	dsb	ish
32201104:	e320f004 	sev
    spin_unlock(&console->rx_lock);
32201108:	e8bd8010 	pop	{r4, pc}

3220110c <uart_init>:
#include <linflexd_uart.h>

volatile struct linflexd *uart  =  (volatile struct linflexd *)PLAT_UART_ADDR;

void uart_init(void)
{
3220110c:	e92d4010 	push	{r4, lr}
    linflexd_uart_init(uart);
32201110:	e30c4138 	movw	r4, #49464	@ 0xc138
32201114:	e3434220 	movt	r4, #12832	@ 0x3220
32201118:	e5940000 	ldr	r0, [r4]
3220111c:	eb00002f 	bl	322011e0 <linflexd_uart_init>
    linflexd_uart_enable(uart);
32201120:	e5940000 	ldr	r0, [r4]
}
32201124:	e8bd4010 	pop	{r4, lr}
    linflexd_uart_enable(uart);
32201128:	ea000028 	b	322011d0 <linflexd_uart_enable>

3220112c <uart_putc>:

void uart_putc(char c)
{
    linflexd_uart_putc(uart, c);
3220112c:	e30c3138 	movw	r3, #49464	@ 0xc138
32201130:	e3433220 	movt	r3, #12832	@ 0x3220
{
32201134:	e1a01000 	mov	r1, r0
    linflexd_uart_putc(uart, c);
32201138:	e5930000 	ldr	r0, [r3]
3220113c:	e6af1071 	sxtb	r1, r1
32201140:	ea000047 	b	32201264 <linflexd_uart_putc>

32201144 <uart_getchar>:
}

char uart_getchar(void)
{
    return linflexd_uart_getc(uart);
32201144:	e30c3138 	movw	r3, #49464	@ 0xc138
32201148:	e3433220 	movt	r3, #12832	@ 0x3220
3220114c:	e5930000 	ldr	r0, [r3]
32201150:	ea00003b 	b	32201244 <linflexd_uart_getc>

32201154 <uart_enable_rxirq>:
}

void uart_enable_rxirq(void)
{
    linflexd_uart_rxirq(uart);
32201154:	e30c3138 	movw	r3, #49464	@ 0xc138
32201158:	e3433220 	movt	r3, #12832	@ 0x3220
3220115c:	e5930000 	ldr	r0, [r3]
32201160:	ea000030 	b	32201228 <linflexd_uart_rxirq>

32201164 <uart_clear_rxirq>:
}

void uart_clear_rxirq(void)
{
    linflexd_uart_clear_rxirq(uart);
32201164:	e30c3138 	movw	r3, #49464	@ 0xc138
32201168:	e3433220 	movt	r3, #12832	@ 0x3220
3220116c:	e5930000 	ldr	r0, [r3]
32201170:	ea000030 	b	32201238 <linflexd_uart_clear_rxirq>

32201174 <plat_init>:
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
32201174:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
#include <core.h>
#include <sysregs.h>

static inline unsigned long get_cpuid(){
    unsigned long cpuid = sysreg_mpidr_el1_read();
    return cpuid & MPIDR_CPU_MASK;
32201178:	e6ef3073 	uxtb	r3, r3
    mmio_write(SIUL2_IMCR_OFF(47), SIUL2_IMCR_RX);
}

void plat_init(void)
{
    if(cpu_is_master()){
3220117c:	e3530000 	cmp	r3, #0
32201180:	112fff1e 	bxne	lr
        return (*(volatile TYPE*)(addr));                    \
    }

MMIO_OPS_GEN(mmio32, uint32_t)
MMIO_OPS_GEN(mmio64, uint64_t)
MMIO_OPS_GEN(mmio, unsigned long)
32201184:	e3a02000 	mov	r2, #0
32201188:	e3442003 	movt	r2, #16387	@ 0x4003
3220118c:	e3a03008 	mov	r3, #8
32201190:	e5823400 	str	r3, [r2, #1024]	@ 0x400
32201194:	e5923404 	ldr	r3, [r2, #1028]	@ 0x404
    } while ((reg_val & MC_CGM_0_MUX_4_CSS_SWIP) != 0);
32201198:	e3130801 	tst	r3, #65536	@ 0x10000
3220119c:	1afffffc 	bne	32201194 <plat_init+0x20>
322011a0:	e3a03000 	mov	r3, #0
322011a4:	e3443052 	movt	r3, #16466	@ 0x4052
322011a8:	e3a00102 	mov	r0, #-2147483648	@ 0x80000000
322011ac:	e3a01001 	mov	r1, #1
322011b0:	e3401021 	movt	r1, #33	@ 0x21
322011b4:	e5820408 	str	r0, [r2, #1032]	@ 0x408
322011b8:	e5831240 	str	r1, [r3, #576]	@ 0x240
322011bc:	e3a00809 	mov	r0, #589824	@ 0x90000
322011c0:	e3a02002 	mov	r2, #2
322011c4:	e5830244 	str	r0, [r3, #580]	@ 0x244
322011c8:	e5832afc 	str	r2, [r3, #2812]	@ 0xafc
        plat_clock();
        plat_iomux();
    }
322011cc:	e12fff1e 	bx	lr

322011d0 <linflexd_uart_enable>:
#include <linflexd_uart.h>

void linflexd_uart_enable(volatile struct linflexd * uart)
{
    /* Request normal mode */
    uart->lincr1 &= ~(LINFLEXD_LINCR1_SLEEP | LINFLEXD_LINCR1_INIT);
322011d0:	e5903000 	ldr	r3, [r0]
322011d4:	e3c33003 	bic	r3, r3, #3
322011d8:	e5803000 	str	r3, [r0]
}
322011dc:	e12fff1e 	bx	lr

322011e0 <linflexd_uart_init>:
}

void linflexd_uart_init(volatile struct linflexd * uart)
{
    /* Request init mode */
    uart->lincr1 = (uart->lincr1 & ~(LINFLEXD_LINCR1_SLEEP)) | LINFLEXD_LINCR1_INIT;
322011e0:	e5903000 	ldr	r3, [r0]

    /* Setup UART mode */
    uart->uartcr = (LINFLEXD_UARTCR_UART);
322011e4:	e3a01001 	mov	r1, #1
    uart->linibrr = ibr;
322011e8:	e3a0201a 	mov	r2, #26
    uart->lincr1 = (uart->lincr1 & ~(LINFLEXD_LINCR1_SLEEP)) | LINFLEXD_LINCR1_INIT;
322011ec:	e3c33003 	bic	r3, r3, #3
322011f0:	e1833001 	orr	r3, r3, r1
322011f4:	e5803000 	str	r3, [r0]
    uart->uartcr = (LINFLEXD_UARTCR_UART);
322011f8:	e5801010 	str	r1, [r0, #16]
     * no parity
     * buffer mode
     * 115200
     * Tx and Rx mode
     */
    uart->uartcr &= ~(1<<2);
322011fc:	e5903010 	ldr	r3, [r0, #16]
32201200:	e3c33004 	bic	r3, r3, #4
32201204:	e5803010 	str	r3, [r0, #16]
    uart->uartcr |= LINFLEXD_UARTCR_WL0 | LINFLEXD_UARTCR_TXEN | LINFLEXD_UARTCR_RXEN;
32201208:	e5903010 	ldr	r3, [r0, #16]
3220120c:	e3833032 	orr	r3, r3, #50	@ 0x32
32201210:	e5803010 	str	r3, [r0, #16]
    uart->linibrr = ibr;
32201214:	e5802028 	str	r2, [r0, #40]	@ 0x28

    /* Set the baud rate */
    uart_set_baudrate(uart);

    /* Sanitize tx empty flag */
    uart->uartsr |= LINFLEXD_UARTSR_DTFTFF;
32201218:	e5903014 	ldr	r3, [r0, #20]
3220121c:	e3833002 	orr	r3, r3, #2
32201220:	e5803014 	str	r3, [r0, #20]
}
32201224:	e12fff1e 	bx	lr

32201228 <linflexd_uart_rxirq>:

void linflexd_uart_rxirq(volatile struct linflexd * uart)
{
    /* Enable data transmitted interrupt */
    uart->linier |= LINFLEXD_LINIER_DRIE;
32201228:	e5903004 	ldr	r3, [r0, #4]
3220122c:	e3833004 	orr	r3, r3, #4
32201230:	e5803004 	str	r3, [r0, #4]
}
32201234:	e12fff1e 	bx	lr

32201238 <linflexd_uart_clear_rxirq>:

void linflexd_uart_clear_rxirq(volatile struct linflexd * uart)
{
    /* Clear the receive buffer full flag */
    //uart->uartsr |= LINFLEXD_UARTSR_DRFRFE;
    uart->uartsr = LINFLEXD_UARTSR_RMB;
32201238:	e3a03c02 	mov	r3, #512	@ 0x200
3220123c:	e5803014 	str	r3, [r0, #20]
}
32201240:	e12fff1e 	bx	lr

32201244 <linflexd_uart_getc>:

uint8_t linflexd_uart_getc(volatile struct linflexd * uart){

    uint8_t data = 0;

    while ((uart->uartsr & LINFLEXD_UARTSR_RMB) == 0u) {
32201244:	e5903014 	ldr	r3, [r0, #20]
32201248:	e3130c02 	tst	r3, #512	@ 0x200
3220124c:	0afffffc 	beq	32201244 <linflexd_uart_getc>
    /* wait for receive buffer full */
    }

    data = uart->bdrm & (0xFF);
32201250:	e590303c 	ldr	r3, [r0, #60]	@ 0x3c
    uart->uartsr = LINFLEXD_UARTSR_RMB;
32201254:	e3a02c02 	mov	r2, #512	@ 0x200
32201258:	e5802014 	str	r2, [r0, #20]

    linflexd_uart_clear_rxirq(uart);

    return data;
}
3220125c:	e6ef0073 	uxtb	r0, r3
32201260:	e12fff1e 	bx	lr

32201264 <linflexd_uart_putc>:
void linflexd_uart_putc(volatile struct linflexd * uart, int8_t c)
{
    uint32_t reg_val;

    do {
        reg_val = (uart->linsr & LINFLEXD_LINSR_LINS_MASK) >> LINFLEXD_LINSR_LINS_SHIFT;
32201264:	e5903008 	ldr	r3, [r0, #8]
32201268:	e7e33653 	ubfx	r3, r3, #12, #4
    } while (reg_val == LINFLEXD_LINSR_LINS_DRDT || reg_val == LINFLEXD_LINSR_LINS_HRT);
3220126c:	e2433007 	sub	r3, r3, #7
32201270:	e3530001 	cmp	r3, #1
32201274:	9afffffa 	bls	32201264 <linflexd_uart_putc>

    uart->bdrl = (uint32_t)c;
32201278:	e5801038 	str	r1, [r0, #56]	@ 0x38

}
3220127c:	e12fff1e 	bx	lr

32201280 <linflexd_uart_puts>:

void linflexd_uart_puts(volatile struct linflexd * uart, const char *s)
{
    while (*s)
32201280:	e5d13000 	ldrb	r3, [r1]
32201284:	e3530000 	cmp	r3, #0
32201288:	012fff1e 	bxeq	lr
    {
        linflexd_uart_putc(uart,*s++);
3220128c:	e6af2073 	sxtb	r2, r3
        reg_val = (uart->linsr & LINFLEXD_LINSR_LINS_MASK) >> LINFLEXD_LINSR_LINS_SHIFT;
32201290:	e5903008 	ldr	r3, [r0, #8]
32201294:	e7e33653 	ubfx	r3, r3, #12, #4
    } while (reg_val == LINFLEXD_LINSR_LINS_DRDT || reg_val == LINFLEXD_LINSR_LINS_HRT);
32201298:	e2433007 	sub	r3, r3, #7
3220129c:	e3530001 	cmp	r3, #1
322012a0:	9afffffa 	bls	32201290 <linflexd_uart_puts+0x10>
    uart->bdrl = (uint32_t)c;
322012a4:	e5802038 	str	r2, [r0, #56]	@ 0x38
    while (*s)
322012a8:	e5f13001 	ldrb	r3, [r1, #1]!
322012ac:	e3530000 	cmp	r3, #0
322012b0:	1afffff5 	bne	3220128c <linflexd_uart_puts+0xc>
322012b4:	e12fff1e 	bx	lr

322012b8 <arch_init>:
#include <sysregs.h>

void _start();

__attribute__((weak))
void arch_init(){
322012b8:	e92d4070 	push	{r4, r5, r6, lr}
322012bc:	ee104fb0 	mrc	15, 0, r4, cr0, cr0, {5}
    unsigned long cpuid = get_cpuid();
    gic_init();
322012c0:	eb000114 	bl	32201718 <gic_init>
322012c4:	e6ef4074 	uxtb	r4, r4
SYSREG_GEN_ACCESSORS(cntfrq_el0, 0, c14, c0, 0);
322012c8:	ee1e2f10 	mrc	15, 0, r2, cr14, cr0, {0}
    TIMER_FREQ = sysreg_cntfrq_el0_read();
322012cc:	e3053020 	movw	r3, #20512	@ 0x5020
322012d0:	e3433221 	movt	r3, #12833	@ 0x3221
    //sysreg_cntv_ctl_el0_write(3);

#if !(defined(SINGLE_CORE) || defined(NO_FIRMWARE))
    if(cpuid == 0){
322012d4:	e3540000 	cmp	r4, #0
    TIMER_FREQ = sysreg_cntfrq_el0_read();
322012d8:	e5832000 	str	r2, [r3]
    if(cpuid == 0){
322012dc:	1a00000a 	bne	3220130c <arch_init+0x54>
        size_t i = 0;
        int ret = PSCI_E_SUCCESS;
        do {
            if(i == cpuid) continue;
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
322012e0:	e3005000 	movw	r5, #0
322012e4:	e3435220 	movt	r5, #12832	@ 0x3220
            if(i == cpuid) continue;
322012e8:	e3540001 	cmp	r4, #1
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
322012ec:	e1a01005 	mov	r1, r5
322012f0:	e3a02000 	mov	r2, #0
            if(i == cpuid) continue;
322012f4:	33a04001 	movcc	r4, #1
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
322012f8:	e1a00004 	mov	r0, r4
322012fc:	eb000016 	bl	3220135c <psci_cpu_on>
        } while(i++, ret == PSCI_E_SUCCESS);
32201300:	e2844001 	add	r4, r4, #1
32201304:	e3500000 	cmp	r0, #0
32201308:	0afffff6 	beq	322012e8 <arch_init+0x30>
static inline void arm_dc_civac(uintptr_t cache_addr) {
    sysreg_dccivac_write(cache_addr);
}

static inline void arm_unmask_irq() {
    asm volatile("cpsie i");
3220130c:	f1080080 	cpsie	i
    }
#endif
    arm_unmask_irq();
}
32201310:	e8bd8070 	pop	{r4, r5, r6, pc}

32201314 <smc_call>:
	register unsigned long r0 asm("r0") = x0;
	register unsigned long r1 asm("r1") = x1;
	register unsigned long r2 asm("r2") = x2;
	register unsigned long r3 asm("r3") = x3;

    asm volatile(
32201314:	e1400070 	hvc	0
			: "=r" (r0)
			: "r" (r0), "r" (r1), "r" (r2)
			: "r3");

	return r0;
}
32201318:	e12fff1e 	bx	lr

3220131c <psci_version>:
	register unsigned long r1 asm("r1") = x1;
3220131c:	e3a01000 	mov	r1, #0
	register unsigned long r0 asm("r0") = x0;
32201320:	e3a00321 	mov	r0, #-2080374784	@ 0x84000000
	register unsigned long r2 asm("r2") = x2;
32201324:	e1a02001 	mov	r2, r1
    asm volatile(
32201328:	e1400070 	hvc	0
--------------------------------- */

int32_t psci_version(void)
{
    return smc_call(PSCI_VERSION, 0, 0, 0);
}
3220132c:	e12fff1e 	bx	lr

32201330 <psci_cpu_suspend>:


int32_t psci_cpu_suspend(uint32_t power_state, uintptr_t entrypoint, 
                    unsigned long context_id)
{
32201330:	e1a03000 	mov	r3, r0
32201334:	e1a02001 	mov	r2, r1
	register unsigned long r0 asm("r0") = x0;
32201338:	e3a00361 	mov	r0, #-2080374783	@ 0x84000001
	register unsigned long r1 asm("r1") = x1;
3220133c:	e1a01003 	mov	r1, r3
    asm volatile(
32201340:	e1400070 	hvc	0
    return smc_call(PSCI_CPU_SUSPEND, power_state, entrypoint, context_id);
}
32201344:	e12fff1e 	bx	lr

32201348 <psci_cpu_off>:
	register unsigned long r1 asm("r1") = x1;
32201348:	e3a01000 	mov	r1, #0
	register unsigned long r0 asm("r0") = x0;
3220134c:	e3a003a1 	mov	r0, #-2080374782	@ 0x84000002
	register unsigned long r2 asm("r2") = x2;
32201350:	e1a02001 	mov	r2, r1
    asm volatile(
32201354:	e1400070 	hvc	0

int32_t psci_cpu_off(void)
{
    return smc_call(PSCI_CPU_OFF, 0, 0, 0);
}
32201358:	e12fff1e 	bx	lr

3220135c <psci_cpu_on>:

int32_t psci_cpu_on(unsigned long target_cpu, uintptr_t entrypoint, 
                    unsigned long context_id)
{
3220135c:	e1a03000 	mov	r3, r0
32201360:	e1a02001 	mov	r2, r1
	register unsigned long r0 asm("r0") = x0;
32201364:	e3a003e1 	mov	r0, #-2080374781	@ 0x84000003
	register unsigned long r1 asm("r1") = x1;
32201368:	e1a01003 	mov	r1, r3
    asm volatile(
3220136c:	e1400070 	hvc	0
    return smc_call(PSCI_CPU_ON, target_cpu, entrypoint, context_id);
}
32201370:	e12fff1e 	bx	lr

32201374 <psci_affinity_info>:

int32_t psci_affinity_info(unsigned long target_affinity, 
                            uint32_t lowest_affinity_level)
{
32201374:	e1a03000 	mov	r3, r0
32201378:	e1a02001 	mov	r2, r1
	register unsigned long r0 asm("r0") = x0;
3220137c:	e3a00004 	mov	r0, #4
32201380:	e3480400 	movt	r0, #33792	@ 0x8400
	register unsigned long r1 asm("r1") = x1;
32201384:	e1a01003 	mov	r1, r3
    asm volatile(
32201388:	e1400070 	hvc	0
    return smc_call(PSCI_AFFINITY_INFO, target_affinity, 
                    lowest_affinity_level, 0);
}
3220138c:	e12fff1e 	bx	lr

32201390 <irq_enable>:

#ifndef GIC_VERSION
#error "GIC_VERSION not defined for this platform"
#endif

void irq_enable(unsigned id) {
32201390:	e92d4010 	push	{r4, lr}
   gic_set_enable(id, true); 
32201394:	e3a01001 	mov	r1, #1
void irq_enable(unsigned id) {
32201398:	e1a04000 	mov	r4, r0
   gic_set_enable(id, true); 
3220139c:	eb00036f 	bl	32202160 <gic_set_enable>
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
322013a0:	ee101fb0 	mrc	15, 0, r1, cr0, cr0, {5}
   if(GIC_VERSION == GICV2) {
       gic_set_trgt(id, gic_get_trgt(id) | (1 << get_cpuid()));
   } else {
       gic_set_route(id, get_cpuid());
322013a4:	e1a00004 	mov	r0, r4
322013a8:	e6ef1071 	uxtb	r1, r1
   }
}
322013ac:	e8bd4010 	pop	{r4, lr}
       gic_set_route(id, get_cpuid());
322013b0:	ea00035f 	b	32202134 <gic_set_route>

322013b4 <irq_set_prio>:

void irq_set_prio(unsigned id, unsigned prio){
    gic_set_prio(id, (uint8_t) prio);
322013b4:	e6ef1071 	uxtb	r1, r1
322013b8:	ea000306 	b	32201fd8 <gic_set_prio>

322013bc <irq_send_ipi>:
}

void irq_send_ipi(unsigned long target_cpu_mask) {
322013bc:	e92d4070 	push	{r4, r5, r6, lr}
    for(int i = 0; i < sizeof(target_cpu_mask)*8; i++) {
        if(target_cpu_mask & (1ull << i)) {
322013c0:	e3a05000 	mov	r5, #0
void irq_send_ipi(unsigned long target_cpu_mask) {
322013c4:	e1a06000 	mov	r6, r0
    for(int i = 0; i < sizeof(target_cpu_mask)*8; i++) {
322013c8:	e1a04005 	mov	r4, r5
322013cc:	ea000002 	b	322013dc <irq_send_ipi+0x20>
322013d0:	e2844001 	add	r4, r4, #1
322013d4:	e3540020 	cmp	r4, #32
322013d8:	08bd8070 	popeq	{r4, r5, r6, pc}
        if(target_cpu_mask & (1ull << i)) {
322013dc:	e2641020 	rsb	r1, r4, #32
322013e0:	e2442020 	sub	r2, r4, #32
322013e4:	e1a03436 	lsr	r3, r6, r4
322013e8:	e1833115 	orr	r3, r3, r5, lsl r1
322013ec:	e1833235 	orr	r3, r3, r5, lsr r2
322013f0:	e3130001 	tst	r3, #1
322013f4:	0afffff5 	beq	322013d0 <irq_send_ipi+0x14>
            gic_send_sgi(i, IPI_IRQ_ID);
322013f8:	e1a00004 	mov	r0, r4
322013fc:	e3a01000 	mov	r1, #0
32201400:	eb0002e9 	bl	32201fac <gic_send_sgi>
32201404:	eafffff1 	b	322013d0 <irq_send_ipi+0x14>

32201408 <irq_disable>:
        }
    }
}

void irq_disable(unsigned id) {
   gic_set_enable(id, false);
32201408:	e3a01000 	mov	r1, #0
3220140c:	ea000353 	b	32202160 <gic_set_enable>

32201410 <irq_clear_pend>:
}

void irq_clear_pend(unsigned id) {
   gic_set_pend(id, false);
32201410:	e3a01000 	mov	r1, #0
32201414:	ea00030b 	b	32202048 <gic_set_pend>

32201418 <gicr_set_pend>:
    __asm__ volatile(
32201418:	e3053030 	movw	r3, #20528	@ 0x5030
3220141c:	e3433221 	movt	r3, #12833	@ 0x3221

    return pend | act;
}

static void gicr_set_pend(unsigned long int_id, bool pend, uint32_t gicr_id)
{
32201420:	e92d4030 	push	{r4, r5, lr}
32201424:	e2835004 	add	r5, r3, #4
32201428:	e193ce9f 	ldaex	ip, [r3]
3220142c:	e28ce001 	add	lr, ip, #1
32201430:	e1834f9e 	strex	r4, lr, [r3]
32201434:	e3540000 	cmp	r4, #0
32201438:	1afffffa 	bne	32201428 <gicr_set_pend+0x10>
3220143c:	e595e000 	ldr	lr, [r5]
32201440:	e15c000e 	cmp	ip, lr
32201444:	0a000001 	beq	32201450 <gicr_set_pend+0x38>
32201448:	e320f002 	wfe
3220144c:	eafffffa 	b	3220143c <gicr_set_pend+0x24>
    spin_lock(&gicr_lock);
    if (pend) {
        gicr[gicr_id].ISPENDR0 = (1U) << (int_id);
32201450:	e30cc13c 	movw	ip, #49468	@ 0xc13c
32201454:	e343c220 	movt	ip, #12832	@ 0x3220
    if (pend) {
32201458:	e3510000 	cmp	r1, #0
        gicr[gicr_id].ISPENDR0 = (1U) << (int_id);
3220145c:	e59c1000 	ldr	r1, [ip]
32201460:	e0812882 	add	r2, r1, r2, lsl #17
32201464:	e3a01001 	mov	r1, #1
32201468:	e2822801 	add	r2, r2, #65536	@ 0x10000
3220146c:	e1a00011 	lsl	r0, r1, r0
32201470:	15820200 	strne	r0, [r2, #512]	@ 0x200
    } else {
        gicr[gicr_id].ICPENDR0 = (1U) << (int_id);
32201474:	05820280 	streq	r0, [r2, #640]	@ 0x280
    __asm__ volatile(
32201478:	e2832004 	add	r2, r3, #4
3220147c:	e5923000 	ldr	r3, [r2]
32201480:	e2833001 	add	r3, r3, #1
32201484:	e182fc93 	stl	r3, [r2]
32201488:	f57ff04b 	dsb	ish
3220148c:	e320f004 	sev
    }
    spin_unlock(&gicr_lock);
}
32201490:	e8bd8030 	pop	{r4, r5, pc}

32201494 <gicd_set_pend>:
    __asm__ volatile(
32201494:	e3053030 	movw	r3, #20528	@ 0x5030
32201498:	e3433221 	movt	r3, #12833	@ 0x3221
{
3220149c:	e92d4030 	push	{r4, r5, lr}
322014a0:	e2834008 	add	r4, r3, #8
322014a4:	e283500c 	add	r5, r3, #12
322014a8:	e1942e9f 	ldaex	r2, [r4]
322014ac:	e282c001 	add	ip, r2, #1
322014b0:	e184ef9c 	strex	lr, ip, [r4]
322014b4:	e35e0000 	cmp	lr, #0
322014b8:	1afffffa 	bne	322014a8 <gicd_set_pend+0x14>
322014bc:	e595c000 	ldr	ip, [r5]
322014c0:	e152000c 	cmp	r2, ip
322014c4:	0a000001 	beq	322014d0 <gicd_set_pend+0x3c>
322014c8:	e320f002 	wfe
322014cc:	eafffffa 	b	322014bc <gicd_set_pend+0x28>
            gicd->SPENDSGIR[reg_ind] = (1U) << (off + get_cpuid());
322014d0:	e30c213c 	movw	r2, #49468	@ 0xc13c
322014d4:	e3432220 	movt	r2, #12832	@ 0x3220
    if (gic_is_sgi(int_id)) {
322014d8:	e350000f 	cmp	r0, #15
            gicd->SPENDSGIR[reg_ind] = (1U) << (off + get_cpuid());
322014dc:	e5922004 	ldr	r2, [r2, #4]
    if (gic_is_sgi(int_id)) {
322014e0:	8a00000b 	bhi	32201514 <gicd_set_pend+0x80>
        if (pend) {
322014e4:	e3510000 	cmp	r1, #0
        unsigned long reg_ind = GICD_SGI_REG(int_id);
322014e8:	e1a01120 	lsr	r1, r0, #2
        unsigned long off = GICD_SGI_OFF(int_id);
322014ec:	e2000003 	and	r0, r0, #3
322014f0:	e1a00180 	lsl	r0, r0, #3
        if (pend) {
322014f4:	0a000015 	beq	32201550 <gicd_set_pend+0xbc>
322014f8:	ee10cfb0 	mrc	15, 0, ip, cr0, cr0, {5}
            gicd->SPENDSGIR[reg_ind] = (1U) << (off + get_cpuid());
322014fc:	e0822101 	add	r2, r2, r1, lsl #2
32201500:	e6e0007c 	uxtab	r0, r0, ip
32201504:	e3a01001 	mov	r1, #1
32201508:	e1a01011 	lsl	r1, r1, r0
3220150c:	e5821f20 	str	r1, [r2, #3872]	@ 0xf20
32201510:	ea000007 	b	32201534 <gicd_set_pend+0xa0>
        unsigned long reg_ind = GIC_INT_REG(int_id);
32201514:	e1a0c2a0 	lsr	ip, r0, #5
            gicd->ISPENDR[reg_ind] = GIC_INT_MASK(int_id);
32201518:	e200001f 	and	r0, r0, #31
        if (pend) {
3220151c:	e3510000 	cmp	r1, #0
            gicd->ISPENDR[reg_ind] = GIC_INT_MASK(int_id);
32201520:	e3a01001 	mov	r1, #1
32201524:	e082210c 	add	r2, r2, ip, lsl #2
32201528:	e1a01011 	lsl	r1, r1, r0
3220152c:	15821200 	strne	r1, [r2, #512]	@ 0x200
            gicd->ICPENDR[reg_ind] = GIC_INT_MASK(int_id);
32201530:	05821280 	streq	r1, [r2, #640]	@ 0x280
    __asm__ volatile(
32201534:	e283200c 	add	r2, r3, #12
32201538:	e5923000 	ldr	r3, [r2]
3220153c:	e2833001 	add	r3, r3, #1
32201540:	e182fc93 	stl	r3, [r2]
32201544:	f57ff04b 	dsb	ish
32201548:	e320f004 	sev
}
3220154c:	e8bd8030 	pop	{r4, r5, pc}
            gicd->CPENDSGIR[reg_ind] = BIT_MASK(off, 8);
32201550:	e0822101 	add	r2, r2, r1, lsl #2
32201554:	e3e0e000 	mvn	lr, #0
32201558:	e280c008 	add	ip, r0, #8
3220155c:	e1a0101e 	lsl	r1, lr, r0
32201560:	e1c11c1e 	bic	r1, r1, lr, lsl ip
32201564:	e5821f10 	str	r1, [r2, #3856]	@ 0xf10
32201568:	eafffff1 	b	32201534 <gicd_set_pend+0xa0>

3220156c <gic_num_irqs>:
        bit_extract(gicd->TYPER, GICD_TYPER_ITLN_OFF, GICD_TYPER_ITLN_LEN);
3220156c:	e30c313c 	movw	r3, #49468	@ 0xc13c
32201570:	e3433220 	movt	r3, #12832	@ 0x3220
32201574:	e5933004 	ldr	r3, [r3, #4]
32201578:	e5930004 	ldr	r0, [r3, #4]
    return word &= ~(1UL << off);
}

static inline unsigned long bit_extract(unsigned long word, unsigned long off, unsigned long len)
{
    return (word >> off) & BIT_MASK(0, len);
3220157c:	e200001f 	and	r0, r0, #31
    return 32 * itlinenumber + 1;
32201580:	e1a00280 	lsl	r0, r0, #5
}
32201584:	e2800001 	add	r0, r0, #1
32201588:	e12fff1e 	bx	lr

3220158c <gic_cpu_init>:
{
3220158c:	e52de004 	push	{lr}		@ (str lr, [sp, #-4]!)
SYSREG_GEN_ACCESSORS(icc_sre_el1, 0, c12, c12, 5);
32201590:	ee1c3fbc 	mrc	15, 0, r3, cr12, cr12, {5}
    sysreg_icc_sre_el1_write(sysreg_icc_sre_el1_read() | ICC_SRE_SRE_BIT);
32201594:	e3833001 	orr	r3, r3, #1
32201598:	ee0c3fbc 	mcr	15, 0, r3, cr12, cr12, {5}
    ISB();
3220159c:	f57ff06f 	isb	sy
    gicd->CTLR |= (1ull << 6);
322015a0:	e30c313c 	movw	r3, #49468	@ 0xc13c
322015a4:	e3433220 	movt	r3, #12832	@ 0x3220
    gicr[get_cpuid()].WAKER &= ~GICR_ProcessorSleep_BIT;
322015a8:	e8930006 	ldm	r3, {r1, r2}
    gicd->CTLR |= (1ull << 6);
322015ac:	e5923000 	ldr	r3, [r2]
322015b0:	e3833040 	orr	r3, r3, #64	@ 0x40
322015b4:	e5823000 	str	r3, [r2]
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
322015b8:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
322015bc:	e6ef3073 	uxtb	r3, r3
    gicr[get_cpuid()].WAKER &= ~GICR_ProcessorSleep_BIT;
322015c0:	e0813883 	add	r3, r1, r3, lsl #17
322015c4:	e5932014 	ldr	r2, [r3, #20]
322015c8:	e3c22002 	bic	r2, r2, #2
322015cc:	e5832014 	str	r2, [r3, #20]
322015d0:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
322015d4:	e6ef3073 	uxtb	r3, r3
    while(gicr[get_cpuid()].WAKER & GICR_ChildrenASleep_BIT) { }
322015d8:	e0813883 	add	r3, r1, r3, lsl #17
322015dc:	e5932014 	ldr	r2, [r3, #20]
322015e0:	e2122004 	ands	r2, r2, #4
322015e4:	1afffff9 	bne	322015d0 <gic_cpu_init+0x44>
322015e8:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
322015ec:	e6ef3073 	uxtb	r3, r3
    gicr[get_cpuid()].IGROUPR0 = -1;
322015f0:	e3e0c000 	mvn	ip, #0
322015f4:	e0813883 	add	r3, r1, r3, lsl #17
322015f8:	e2833801 	add	r3, r3, #65536	@ 0x10000
322015fc:	e583c080 	str	ip, [r3, #128]	@ 0x80
32201600:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
32201604:	e6ef3073 	uxtb	r3, r3
    gicr[get_cpuid()].ICENABLER0 = -1;
32201608:	e0813883 	add	r3, r1, r3, lsl #17
3220160c:	e2833801 	add	r3, r3, #65536	@ 0x10000
32201610:	e583c180 	str	ip, [r3, #384]	@ 0x180
32201614:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
32201618:	e6ef3073 	uxtb	r3, r3
    gicr[get_cpuid()].ICPENDR0 = -1;
3220161c:	e0813883 	add	r3, r1, r3, lsl #17
32201620:	e2833801 	add	r3, r3, #65536	@ 0x10000
32201624:	e583c280 	str	ip, [r3, #640]	@ 0x280
32201628:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
3220162c:	e6ef3073 	uxtb	r3, r3
        gicr[get_cpuid()].IPRIORITYR[i] = -1;
32201630:	e1a0e00c 	mov	lr, ip
    gicr[get_cpuid()].ICACTIVER0 = -1;
32201634:	e0813883 	add	r3, r1, r3, lsl #17
32201638:	e2833801 	add	r3, r3, #65536	@ 0x10000
3220163c:	e583c380 	str	ip, [r3, #896]	@ 0x380
32201640:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
32201644:	e6ef3073 	uxtb	r3, r3
        gicr[get_cpuid()].IPRIORITYR[i] = -1;
32201648:	e2820901 	add	r0, r2, #16384	@ 0x4000
    for (int i = 0; i < GIC_NUM_PRIO_REGS(GIC_CPU_PRIV); i++) {
3220164c:	e2822001 	add	r2, r2, #1
        gicr[get_cpuid()].IPRIORITYR[i] = -1;
32201650:	e0813883 	add	r3, r1, r3, lsl #17
    for (int i = 0; i < GIC_NUM_PRIO_REGS(GIC_CPU_PRIV); i++) {
32201654:	e3520008 	cmp	r2, #8
        gicr[get_cpuid()].IPRIORITYR[i] = -1;
32201658:	e0833100 	add	r3, r3, r0, lsl #2
3220165c:	e583c400 	str	ip, [r3, #1024]	@ 0x400
    for (int i = 0; i < GIC_NUM_PRIO_REGS(GIC_CPU_PRIV); i++) {
32201660:	1afffff6 	bne	32201640 <gic_cpu_init+0xb4>
SYSREG_GEN_ACCESSORS(icc_pmr_el1, 0, c4, c6, 0);
32201664:	ee04ef16 	mcr	15, 0, lr, cr4, cr6, {0}
SYSREG_GEN_ACCESSORS(icc_ctlr_el1, 0, c12, c12, 4);
32201668:	e3a03001 	mov	r3, #1
3220166c:	ee0c3f9c 	mcr	15, 0, r3, cr12, cr12, {4}
SYSREG_GEN_ACCESSORS(icc_igrpen1_el1, 0, c12, c12, 7);
32201670:	ee0c3ffc 	mcr	15, 0, r3, cr12, cr12, {7}
}
32201674:	e49df004 	pop	{pc}		@ (ldr pc, [sp], #4)

32201678 <gicd_init>:
        bit_extract(gicd->TYPER, GICD_TYPER_ITLN_OFF, GICD_TYPER_ITLN_LEN);
32201678:	e30c313c 	movw	r3, #49468	@ 0xc13c
3220167c:	e3433220 	movt	r3, #12832	@ 0x3220
{
32201680:	e52de004 	push	{lr}		@ (str lr, [sp, #-4]!)
        bit_extract(gicd->TYPER, GICD_TYPER_ITLN_OFF, GICD_TYPER_ITLN_LEN);
32201684:	e5930004 	ldr	r0, [r3, #4]
32201688:	e5903004 	ldr	r3, [r0, #4]
3220168c:	e203c01f 	and	ip, r3, #31
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
32201690:	e313001e 	tst	r3, #30
32201694:	0a000009 	beq	322016c0 <gicd_init+0x48>
32201698:	e3a01001 	mov	r1, #1
        gicd->IGROUPR[i] = -1;
3220169c:	e3e02000 	mvn	r2, #0
322016a0:	e0803101 	add	r3, r0, r1, lsl #2
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
322016a4:	e2811001 	add	r1, r1, #1
322016a8:	e15c0001 	cmp	ip, r1
        gicd->IGROUPR[i] = -1;
322016ac:	e5832080 	str	r2, [r3, #128]	@ 0x80
        gicd->ICENABLER[i] = -1;
322016b0:	e5832180 	str	r2, [r3, #384]	@ 0x180
        gicd->ICPENDR[i] = -1;
322016b4:	e5832280 	str	r2, [r3, #640]	@ 0x280
        gicd->ICACTIVER[i] = -1;
322016b8:	e5832380 	str	r2, [r3, #896]	@ 0x380
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
322016bc:	8afffff7 	bhi	322016a0 <gicd_init+0x28>
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_PRIO_REGS(int_num); i++)
322016c0:	e1a0e18c 	lsl	lr, ip, #3
322016c4:	e35c0004 	cmp	ip, #4
322016c8:	9a00000e 	bls	32201708 <gicd_init+0x90>
322016cc:	e3a03020 	mov	r3, #32
        gicd->IPRIORITYR[i] = -1;
322016d0:	e3e0c000 	mvn	ip, #0
322016d4:	e0802103 	add	r2, r0, r3, lsl #2
322016d8:	e1a01003 	mov	r1, r3
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_PRIO_REGS(int_num); i++)
322016dc:	e2833001 	add	r3, r3, #1
322016e0:	e15e0003 	cmp	lr, r3
        gicd->IPRIORITYR[i] = -1;
322016e4:	e582c400 	str	ip, [r2, #1024]	@ 0x400
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_PRIO_REGS(int_num); i++)
322016e8:	1afffff9 	bne	322016d4 <gicd_init+0x5c>
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_TARGET_REGS(int_num); i++)
322016ec:	e3a03020 	mov	r3, #32
        gicd->ITARGETSR[i] = 0;
322016f0:	e3a0e000 	mov	lr, #0
322016f4:	e0802103 	add	r2, r0, r3, lsl #2
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_TARGET_REGS(int_num); i++)
322016f8:	e1510003 	cmp	r1, r3
        gicd->ITARGETSR[i] = 0;
322016fc:	e2833001 	add	r3, r3, #1
32201700:	e582e800 	str	lr, [r2, #2048]	@ 0x800
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_TARGET_REGS(int_num); i++)
32201704:	1afffffa 	bne	322016f4 <gicd_init+0x7c>
    gicd->CTLR |= GICD_CTLR_ARE_NS_BIT | GICD_CTLR_ENA_BIT;
32201708:	e5903000 	ldr	r3, [r0]
3220170c:	e3833012 	orr	r3, r3, #18
32201710:	e5803000 	str	r3, [r0]
}
32201714:	e49df004 	pop	{pc}		@ (ldr pc, [sp], #4)

32201718 <gic_init>:
{
32201718:	e92d4010 	push	{r4, lr}
    gic_cpu_init();
3220171c:	ebffff9a 	bl	3220158c <gic_cpu_init>
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
32201720:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
32201724:	e6ef3073 	uxtb	r3, r3
    if (get_cpuid() == 0) {
32201728:	e3530000 	cmp	r3, #0
3220172c:	18bd8010 	popne	{r4, pc}
}
32201730:	e8bd4010 	pop	{r4, lr}
        gicd_init();
32201734:	eaffffcf 	b	32201678 <gicd_init>

32201738 <gic_handle>:
{
32201738:	e92d4010 	push	{r4, lr}
SYSREG_GEN_ACCESSORS(icc_iar1_el1, 0, c12, c12, 0);
3220173c:	ee1c4f1c 	mrc	15, 0, r4, cr12, cr12, {0}
    unsigned long id = ack & ((1UL << 24) -1);
32201740:	e3c404ff 	bic	r0, r4, #-16777216	@ 0xff000000
    if (id >= 1022) return;
32201744:	e30033fd 	movw	r3, #1021	@ 0x3fd
32201748:	e1500003 	cmp	r0, r3
3220174c:	88bd8010 	pophi	{r4, pc}
    irq_handle(id);
32201750:	ebfffb0e 	bl	32200390 <irq_handle>
SYSREG_GEN_ACCESSORS(icc_eoir1_el1, 0, c12, c12, 1);
32201754:	ee0c4f3c 	mcr	15, 0, r4, cr12, cr12, {1}
}
32201758:	e8bd8010 	pop	{r4, pc}

3220175c <gicd_get_prio>:
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
3220175c:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32201760:	e3053030 	movw	r3, #20528	@ 0x5030
32201764:	e3433221 	movt	r3, #12833	@ 0x3221
{
32201768:	e92d4030 	push	{r4, r5, lr}
    unsigned long off = GIC_PRIO_OFF(int_id);
3220176c:	e2002018 	and	r2, r0, #24
32201770:	e2834008 	add	r4, r3, #8
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32201774:	e1a002a0 	lsr	r0, r0, #5
32201778:	e283500c 	add	r5, r3, #12
3220177c:	e1941e9f 	ldaex	r1, [r4]
32201780:	e281c001 	add	ip, r1, #1
32201784:	e184ef9c 	strex	lr, ip, [r4]
32201788:	e35e0000 	cmp	lr, #0
3220178c:	1afffffa 	bne	3220177c <gicd_get_prio+0x20>
32201790:	e595c000 	ldr	ip, [r5]
32201794:	e151000c 	cmp	r1, ip
32201798:	0a000001 	beq	322017a4 <gicd_get_prio+0x48>
3220179c:	e320f002 	wfe
322017a0:	eafffffa 	b	32201790 <gicd_get_prio+0x34>
        gicd->IPRIORITYR[reg_ind] >> off & BIT_MASK(off, GIC_PRIO_BITS);
322017a4:	e30c113c 	movw	r1, #49468	@ 0xc13c
322017a8:	e3431220 	movt	r1, #12832	@ 0x3220
322017ac:	e5911004 	ldr	r1, [r1, #4]
322017b0:	e0811100 	add	r1, r1, r0, lsl #2
322017b4:	e5910400 	ldr	r0, [r1, #1024]	@ 0x400
    __asm__ volatile(
322017b8:	e5953000 	ldr	r3, [r5]
322017bc:	e2833001 	add	r3, r3, #1
322017c0:	e185fc93 	stl	r3, [r5]
322017c4:	f57ff04b 	dsb	ish
322017c8:	e320f004 	sev
322017cc:	e3e0c000 	mvn	ip, #0
322017d0:	e1a03230 	lsr	r3, r0, r2
322017d4:	e2821008 	add	r1, r2, #8
    unsigned long prio =
322017d8:	e003321c 	and	r3, r3, ip, lsl r2
}
322017dc:	e1c3011c 	bic	r0, r3, ip, lsl r1
322017e0:	e8bd8030 	pop	{r4, r5, pc}

322017e4 <gicd_set_icfgr>:
    __asm__ volatile(
322017e4:	e3053030 	movw	r3, #20528	@ 0x5030
322017e8:	e3433221 	movt	r3, #12833	@ 0x3221
{
322017ec:	e92d4030 	push	{r4, r5, lr}
322017f0:	e2834008 	add	r4, r3, #8
322017f4:	e283500c 	add	r5, r3, #12
322017f8:	e1942e9f 	ldaex	r2, [r4]
322017fc:	e282c001 	add	ip, r2, #1
32201800:	e184ef9c 	strex	lr, ip, [r4]
32201804:	e35e0000 	cmp	lr, #0
32201808:	1afffffa 	bne	322017f8 <gicd_set_icfgr+0x14>
3220180c:	e595c000 	ldr	ip, [r5]
32201810:	e152000c 	cmp	r2, ip
32201814:	0a000001 	beq	32201820 <gicd_set_icfgr+0x3c>
32201818:	e320f002 	wfe
3220181c:	eafffffa 	b	3220180c <gicd_set_icfgr+0x28>
    gicd->ICFGR[reg_ind] = (gicd->ICFGR[reg_ind] & ~mask) | ((cfg << off) & mask);
32201820:	e30c213c 	movw	r2, #49468	@ 0xc13c
32201824:	e3432220 	movt	r2, #12832	@ 0x3220
    unsigned long reg_ind = (int_id * GIC_CONFIG_BITS) / (sizeof(uint32_t) * 8);
32201828:	e1a00080 	lsl	r0, r0, #1
    unsigned long mask = ((1U << GIC_CONFIG_BITS) - 1) << off;
3220182c:	e3a0e003 	mov	lr, #3
    unsigned long off = (int_id * GIC_CONFIG_BITS) % (sizeof(uint32_t) * 8);
32201830:	e200c01e 	and	ip, r0, #30
    gicd->ICFGR[reg_ind] = (gicd->ICFGR[reg_ind] & ~mask) | ((cfg << off) & mask);
32201834:	e5922004 	ldr	r2, [r2, #4]
    unsigned long reg_ind = (int_id * GIC_CONFIG_BITS) / (sizeof(uint32_t) * 8);
32201838:	e1a002a0 	lsr	r0, r0, #5
3220183c:	e0822100 	add	r2, r2, r0, lsl #2
    gicd->ICFGR[reg_ind] = (gicd->ICFGR[reg_ind] & ~mask) | ((cfg << off) & mask);
32201840:	e5920c00 	ldr	r0, [r2, #3072]	@ 0xc00
32201844:	e0201c11 	eor	r1, r0, r1, lsl ip
32201848:	e0011c1e 	and	r1, r1, lr, lsl ip
3220184c:	e0211000 	eor	r1, r1, r0
32201850:	e5821c00 	str	r1, [r2, #3072]	@ 0xc00
    __asm__ volatile(
32201854:	e5953000 	ldr	r3, [r5]
32201858:	e2833001 	add	r3, r3, #1
3220185c:	e185fc93 	stl	r3, [r5]
32201860:	f57ff04b 	dsb	ish
32201864:	e320f004 	sev
}
32201868:	e8bd8030 	pop	{r4, r5, pc}

3220186c <gicd_set_prio>:
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
3220186c:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32201870:	e3052030 	movw	r2, #20528	@ 0x5030
32201874:	e3432221 	movt	r2, #12833	@ 0x3221
{
32201878:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long off = GIC_PRIO_OFF(int_id);
3220187c:	e200c018 	and	ip, r0, #24
32201880:	e2825008 	add	r5, r2, #8
32201884:	e282600c 	add	r6, r2, #12
32201888:	e1953e9f 	ldaex	r3, [r5]
3220188c:	e283e001 	add	lr, r3, #1
32201890:	e1854f9e 	strex	r4, lr, [r5]
32201894:	e3540000 	cmp	r4, #0
32201898:	1afffffa 	bne	32201888 <gicd_set_prio+0x1c>
3220189c:	e596e000 	ldr	lr, [r6]
322018a0:	e153000e 	cmp	r3, lr
322018a4:	0a000001 	beq	322018b0 <gicd_set_prio+0x44>
322018a8:	e320f002 	wfe
322018ac:	eafffffa 	b	3220189c <gicd_set_prio+0x30>
        (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
322018b0:	e30c313c 	movw	r3, #49468	@ 0xc13c
322018b4:	e3433220 	movt	r3, #12832	@ 0x3220
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
322018b8:	e1a002a0 	lsr	r0, r0, #5
    unsigned long mask = BIT_MASK(off, GIC_PRIO_BITS);
322018bc:	e3e04000 	mvn	r4, #0
322018c0:	e5933004 	ldr	r3, [r3, #4]
322018c4:	e0830100 	add	r0, r3, r0, lsl #2
        (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
322018c8:	e590e400 	ldr	lr, [r0, #1024]	@ 0x400
322018cc:	e02e3c11 	eor	r3, lr, r1, lsl ip
    unsigned long mask = BIT_MASK(off, GIC_PRIO_BITS);
322018d0:	e28c1008 	add	r1, ip, #8
        (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
322018d4:	e1c33114 	bic	r3, r3, r4, lsl r1
322018d8:	e0033c14 	and	r3, r3, r4, lsl ip
322018dc:	e023300e 	eor	r3, r3, lr
    gicd->IPRIORITYR[reg_ind] =
322018e0:	e5803400 	str	r3, [r0, #1024]	@ 0x400
    __asm__ volatile(
322018e4:	e5963000 	ldr	r3, [r6]
322018e8:	e2833001 	add	r3, r3, #1
322018ec:	e186fc93 	stl	r3, [r6]
322018f0:	f57ff04b 	dsb	ish
322018f4:	e320f004 	sev
}
322018f8:	e8bd8070 	pop	{r4, r5, r6, pc}

322018fc <gicd_get_state>:
    unsigned long mask = GIC_INT_MASK(int_id);
322018fc:	e200101f 	and	r1, r0, #31
32201900:	e3a02001 	mov	r2, #1
    __asm__ volatile(
32201904:	e3053030 	movw	r3, #20528	@ 0x5030
32201908:	e3433221 	movt	r3, #12833	@ 0x3221
{
3220190c:	e92d4030 	push	{r4, r5, lr}
    unsigned long mask = GIC_INT_MASK(int_id);
32201910:	e1a02112 	lsl	r2, r2, r1
32201914:	e2834008 	add	r4, r3, #8
32201918:	e283500c 	add	r5, r3, #12
3220191c:	e1941e9f 	ldaex	r1, [r4]
32201920:	e281c001 	add	ip, r1, #1
32201924:	e184ef9c 	strex	lr, ip, [r4]
32201928:	e35e0000 	cmp	lr, #0
3220192c:	1afffffa 	bne	3220191c <gicd_get_state+0x20>
32201930:	e595c000 	ldr	ip, [r5]
32201934:	e151000c 	cmp	r1, ip
32201938:	0a000001 	beq	32201944 <gicd_get_state+0x48>
3220193c:	e320f002 	wfe
32201940:	eafffffa 	b	32201930 <gicd_get_state+0x34>
    enum int_state pend = (gicd->ISPENDR[reg_ind] & mask) ? PEND : 0;
32201944:	e30c113c 	movw	r1, #49468	@ 0xc13c
32201948:	e3431220 	movt	r1, #12832	@ 0x3220
    unsigned long reg_ind = GIC_INT_REG(int_id);
3220194c:	e1a002a0 	lsr	r0, r0, #5
32201950:	e5911004 	ldr	r1, [r1, #4]
32201954:	e0811100 	add	r1, r1, r0, lsl #2
    __asm__ volatile(
32201958:	e1a00005 	mov	r0, r5
    enum int_state pend = (gicd->ISPENDR[reg_ind] & mask) ? PEND : 0;
3220195c:	e591c200 	ldr	ip, [r1, #512]	@ 0x200
    enum int_state act = (gicd->ISACTIVER[reg_ind] & mask) ? ACT : 0;
32201960:	e5911300 	ldr	r1, [r1, #768]	@ 0x300
32201964:	e5953000 	ldr	r3, [r5]
32201968:	e2833001 	add	r3, r3, #1
3220196c:	e185fc93 	stl	r3, [r5]
32201970:	f57ff04b 	dsb	ish
32201974:	e320f004 	sev
32201978:	e1110002 	tst	r1, r2
3220197c:	13a00001 	movne	r0, #1
32201980:	03a00000 	moveq	r0, #0
    enum int_state pend = (gicd->ISPENDR[reg_ind] & mask) ? PEND : 0;
32201984:	e11c0002 	tst	ip, r2
32201988:	13a03001 	movne	r3, #1
3220198c:	03a03000 	moveq	r3, #0
}
32201990:	e1830080 	orr	r0, r3, r0, lsl #1
32201994:	e8bd8030 	pop	{r4, r5, pc}

32201998 <gicd_set_act>:
    __asm__ volatile(
32201998:	e3053030 	movw	r3, #20528	@ 0x5030
3220199c:	e3433221 	movt	r3, #12833	@ 0x3221
{
322019a0:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long reg_ind = GIC_INT_REG(int_id);
322019a4:	e1a0c2a0 	lsr	ip, r0, #5
322019a8:	e2835008 	add	r5, r3, #8
322019ac:	e283600c 	add	r6, r3, #12
322019b0:	e1952e9f 	ldaex	r2, [r5]
322019b4:	e282e001 	add	lr, r2, #1
322019b8:	e1854f9e 	strex	r4, lr, [r5]
322019bc:	e3540000 	cmp	r4, #0
322019c0:	1afffffa 	bne	322019b0 <gicd_set_act+0x18>
322019c4:	e596e000 	ldr	lr, [r6]
322019c8:	e152000e 	cmp	r2, lr
322019cc:	0a000001 	beq	322019d8 <gicd_set_act+0x40>
322019d0:	e320f002 	wfe
322019d4:	eafffffa 	b	322019c4 <gicd_set_act+0x2c>
        gicd->ISACTIVER[reg_ind] = GIC_INT_MASK(int_id);
322019d8:	e30c213c 	movw	r2, #49468	@ 0xc13c
322019dc:	e3432220 	movt	r2, #12832	@ 0x3220
322019e0:	e200001f 	and	r0, r0, #31
    if (act) {
322019e4:	e3510000 	cmp	r1, #0
        gicd->ISACTIVER[reg_ind] = GIC_INT_MASK(int_id);
322019e8:	e3a01001 	mov	r1, #1
322019ec:	e5922004 	ldr	r2, [r2, #4]
322019f0:	e1a01011 	lsl	r1, r1, r0
322019f4:	e082210c 	add	r2, r2, ip, lsl #2
322019f8:	15821300 	strne	r1, [r2, #768]	@ 0x300
        gicd->ICACTIVER[reg_ind] = GIC_INT_MASK(int_id);
322019fc:	05821380 	streq	r1, [r2, #896]	@ 0x380
    __asm__ volatile(
32201a00:	e283200c 	add	r2, r3, #12
32201a04:	e5923000 	ldr	r3, [r2]
32201a08:	e2833001 	add	r3, r3, #1
32201a0c:	e182fc93 	stl	r3, [r2]
32201a10:	f57ff04b 	dsb	ish
32201a14:	e320f004 	sev
}
32201a18:	e8bd8070 	pop	{r4, r5, r6, pc}

32201a1c <gicd_set_state>:
{
32201a1c:	e92d4070 	push	{r4, r5, r6, lr}
32201a20:	e1a04001 	mov	r4, r1
32201a24:	e1a05000 	mov	r5, r0
    gicd_set_act(int_id, state & ACT);
32201a28:	e7e010d1 	ubfx	r1, r1, #1, #1
32201a2c:	ebffffd9 	bl	32201998 <gicd_set_act>
    gicd_set_pend(int_id, state & PEND);
32201a30:	e2041001 	and	r1, r4, #1
32201a34:	e1a00005 	mov	r0, r5
}
32201a38:	e8bd4070 	pop	{r4, r5, r6, lr}
    gicd_set_pend(int_id, state & PEND);
32201a3c:	eafffe94 	b	32201494 <gicd_set_pend>

32201a40 <gicd_set_trgt>:
    unsigned long reg_ind = GIC_TARGET_REG(int_id);
32201a40:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32201a44:	e3052030 	movw	r2, #20528	@ 0x5030
32201a48:	e3432221 	movt	r2, #12833	@ 0x3221
{
32201a4c:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long off = GIC_TARGET_OFF(int_id);
32201a50:	e200c018 	and	ip, r0, #24
32201a54:	e2825008 	add	r5, r2, #8
32201a58:	e282600c 	add	r6, r2, #12
32201a5c:	e1953e9f 	ldaex	r3, [r5]
32201a60:	e283e001 	add	lr, r3, #1
32201a64:	e1854f9e 	strex	r4, lr, [r5]
32201a68:	e3540000 	cmp	r4, #0
32201a6c:	1afffffa 	bne	32201a5c <gicd_set_trgt+0x1c>
32201a70:	e596e000 	ldr	lr, [r6]
32201a74:	e153000e 	cmp	r3, lr
32201a78:	0a000001 	beq	32201a84 <gicd_set_trgt+0x44>
32201a7c:	e320f002 	wfe
32201a80:	eafffffa 	b	32201a70 <gicd_set_trgt+0x30>
        (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
32201a84:	e30c313c 	movw	r3, #49468	@ 0xc13c
32201a88:	e3433220 	movt	r3, #12832	@ 0x3220
    unsigned long reg_ind = GIC_TARGET_REG(int_id);
32201a8c:	e1a002a0 	lsr	r0, r0, #5
    uint32_t mask = BIT_MASK(off, GIC_TARGET_BITS);
32201a90:	e3e04000 	mvn	r4, #0
32201a94:	e5933004 	ldr	r3, [r3, #4]
32201a98:	e0830100 	add	r0, r3, r0, lsl #2
        (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
32201a9c:	e590e800 	ldr	lr, [r0, #2048]	@ 0x800
32201aa0:	e02e3c11 	eor	r3, lr, r1, lsl ip
    uint32_t mask = BIT_MASK(off, GIC_TARGET_BITS);
32201aa4:	e28c1008 	add	r1, ip, #8
        (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
32201aa8:	e1c33114 	bic	r3, r3, r4, lsl r1
32201aac:	e0033c14 	and	r3, r3, r4, lsl ip
32201ab0:	e023300e 	eor	r3, r3, lr
    gicd->ITARGETSR[reg_ind] =
32201ab4:	e5803800 	str	r3, [r0, #2048]	@ 0x800
    __asm__ volatile(
32201ab8:	e5963000 	ldr	r3, [r6]
32201abc:	e2833001 	add	r3, r3, #1
32201ac0:	e186fc93 	stl	r3, [r6]
32201ac4:	f57ff04b 	dsb	ish
32201ac8:	e320f004 	sev
}
32201acc:	e8bd8070 	pop	{r4, r5, r6, pc}

32201ad0 <gicd_set_route>:
void gicd_set_route(unsigned long int_id, unsigned long trgt)
32201ad0:	e350001f 	cmp	r0, #31
32201ad4:	912fff1e 	bxls	lr
32201ad8:	e30c313c 	movw	r3, #49468	@ 0xc13c
32201adc:	e3433220 	movt	r3, #12832	@ 0x3220
32201ae0:	e2800b03 	add	r0, r0, #3072	@ 0xc00
32201ae4:	e3a0c000 	mov	ip, #0
32201ae8:	e5933004 	ldr	r3, [r3, #4]
32201aec:	e0832180 	add	r2, r3, r0, lsl #3
32201af0:	e7831180 	str	r1, [r3, r0, lsl #3]
32201af4:	e582c004 	str	ip, [r2, #4]
32201af8:	e12fff1e 	bx	lr

32201afc <gicd_set_enable>:
    unsigned long bit = GIC_INT_MASK(int_id);
32201afc:	e200c01f 	and	ip, r0, #31
32201b00:	e3a02001 	mov	r2, #1
    __asm__ volatile(
32201b04:	e3053030 	movw	r3, #20528	@ 0x5030
32201b08:	e3433221 	movt	r3, #12833	@ 0x3221
{
32201b0c:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long reg_ind = GIC_INT_REG(int_id);
32201b10:	e1a002a0 	lsr	r0, r0, #5
    unsigned long bit = GIC_INT_MASK(int_id);
32201b14:	e1a0cc12 	lsl	ip, r2, ip
32201b18:	e2835008 	add	r5, r3, #8
32201b1c:	e283600c 	add	r6, r3, #12
32201b20:	e1952e9f 	ldaex	r2, [r5]
32201b24:	e282e001 	add	lr, r2, #1
32201b28:	e1854f9e 	strex	r4, lr, [r5]
32201b2c:	e3540000 	cmp	r4, #0
32201b30:	1afffffa 	bne	32201b20 <gicd_set_enable+0x24>
32201b34:	e596e000 	ldr	lr, [r6]
32201b38:	e152000e 	cmp	r2, lr
32201b3c:	0a000001 	beq	32201b48 <gicd_set_enable+0x4c>
32201b40:	e320f002 	wfe
32201b44:	eafffffa 	b	32201b34 <gicd_set_enable+0x38>
        gicd->ISENABLER[reg_ind] = bit;
32201b48:	e30c213c 	movw	r2, #49468	@ 0xc13c
32201b4c:	e3432220 	movt	r2, #12832	@ 0x3220
    if (en)
32201b50:	e3510000 	cmp	r1, #0
        gicd->ISENABLER[reg_ind] = bit;
32201b54:	e5922004 	ldr	r2, [r2, #4]
32201b58:	e0822100 	add	r2, r2, r0, lsl #2
32201b5c:	1582c100 	strne	ip, [r2, #256]	@ 0x100
        gicd->ICENABLER[reg_ind] = bit;
32201b60:	0582c180 	streq	ip, [r2, #384]	@ 0x180
    __asm__ volatile(
32201b64:	e283200c 	add	r2, r3, #12
32201b68:	e5923000 	ldr	r3, [r2]
32201b6c:	e2833001 	add	r3, r3, #1
32201b70:	e182fc93 	stl	r3, [r2]
32201b74:	f57ff04b 	dsb	ish
32201b78:	e320f004 	sev
}
32201b7c:	e8bd8070 	pop	{r4, r5, r6, pc}

32201b80 <gicr_set_prio>:
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32201b80:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32201b84:	e3053030 	movw	r3, #20528	@ 0x5030
32201b88:	e3433221 	movt	r3, #12833	@ 0x3221
{
32201b8c:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long off = GIC_PRIO_OFF(int_id);
32201b90:	e200c018 	and	ip, r0, #24
32201b94:	e2836004 	add	r6, r3, #4
32201b98:	e193ee9f 	ldaex	lr, [r3]
32201b9c:	e28e4001 	add	r4, lr, #1
32201ba0:	e1835f94 	strex	r5, r4, [r3]
32201ba4:	e3550000 	cmp	r5, #0
32201ba8:	1afffffa 	bne	32201b98 <gicr_set_prio+0x18>
32201bac:	e5964000 	ldr	r4, [r6]
32201bb0:	e15e0004 	cmp	lr, r4
32201bb4:	0a000001 	beq	32201bc0 <gicr_set_prio+0x40>
32201bb8:	e320f002 	wfe
32201bbc:	eafffffa 	b	32201bac <gicr_set_prio+0x2c>
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32201bc0:	e1a002a0 	lsr	r0, r0, #5
        (gicr[gicr_id].IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
32201bc4:	e1a02882 	lsl	r2, r2, #17
    unsigned long mask = BIT_MASK(off, GIC_PRIO_BITS);
32201bc8:	e28ce008 	add	lr, ip, #8
32201bcc:	e3e04000 	mvn	r4, #0
32201bd0:	e0822100 	add	r2, r2, r0, lsl #2
        (gicr[gicr_id].IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
32201bd4:	e30c013c 	movw	r0, #49468	@ 0xc13c
32201bd8:	e3430220 	movt	r0, #12832	@ 0x3220
32201bdc:	e5900000 	ldr	r0, [r0]
32201be0:	e0802002 	add	r2, r0, r2
32201be4:	e2822801 	add	r2, r2, #65536	@ 0x10000
32201be8:	e5920400 	ldr	r0, [r2, #1024]	@ 0x400
32201bec:	e0201c11 	eor	r1, r0, r1, lsl ip
32201bf0:	e1c11e14 	bic	r1, r1, r4, lsl lr
    unsigned long mask = BIT_MASK(off, GIC_PRIO_BITS);
32201bf4:	e1a0e004 	mov	lr, r4
        (gicr[gicr_id].IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
32201bf8:	e0011c14 	and	r1, r1, r4, lsl ip
32201bfc:	e0211000 	eor	r1, r1, r0
    gicr[gicr_id].IPRIORITYR[reg_ind] =
32201c00:	e5821400 	str	r1, [r2, #1024]	@ 0x400
    __asm__ volatile(
32201c04:	e5963000 	ldr	r3, [r6]
32201c08:	e2833001 	add	r3, r3, #1
32201c0c:	e186fc93 	stl	r3, [r6]
32201c10:	f57ff04b 	dsb	ish
32201c14:	e320f004 	sev
}
32201c18:	e8bd8070 	pop	{r4, r5, r6, pc}

32201c1c <gicr_get_prio>:
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32201c1c:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32201c20:	e3053030 	movw	r3, #20528	@ 0x5030
32201c24:	e3433221 	movt	r3, #12833	@ 0x3221
{
32201c28:	e92d4030 	push	{r4, r5, lr}
    unsigned long off = GIC_PRIO_OFF(int_id);
32201c2c:	e200c018 	and	ip, r0, #24
32201c30:	e2835004 	add	r5, r3, #4
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32201c34:	e1a002a0 	lsr	r0, r0, #5
32201c38:	e1932e9f 	ldaex	r2, [r3]
32201c3c:	e282e001 	add	lr, r2, #1
32201c40:	e1834f9e 	strex	r4, lr, [r3]
32201c44:	e3540000 	cmp	r4, #0
32201c48:	1afffffa 	bne	32201c38 <gicr_get_prio+0x1c>
32201c4c:	e595e000 	ldr	lr, [r5]
32201c50:	e152000e 	cmp	r2, lr
32201c54:	0a000001 	beq	32201c60 <gicr_get_prio+0x44>
32201c58:	e320f002 	wfe
32201c5c:	eafffffa 	b	32201c4c <gicr_get_prio+0x30>
        gicr[gicr_id].IPRIORITYR[reg_ind] >> off & BIT_MASK(off, GIC_PRIO_BITS);
32201c60:	e30c213c 	movw	r2, #49468	@ 0xc13c
32201c64:	e3432220 	movt	r2, #12832	@ 0x3220
32201c68:	e2800901 	add	r0, r0, #16384	@ 0x4000
32201c6c:	e5922000 	ldr	r2, [r2]
32201c70:	e0821881 	add	r1, r2, r1, lsl #17
32201c74:	e0811100 	add	r1, r1, r0, lsl #2
32201c78:	e5910400 	ldr	r0, [r1, #1024]	@ 0x400
    __asm__ volatile(
32201c7c:	e5953000 	ldr	r3, [r5]
32201c80:	e2833001 	add	r3, r3, #1
32201c84:	e185fc93 	stl	r3, [r5]
32201c88:	f57ff04b 	dsb	ish
32201c8c:	e320f004 	sev
32201c90:	e3e01000 	mvn	r1, #0
32201c94:	e1a03c30 	lsr	r3, r0, ip
32201c98:	e28c2008 	add	r2, ip, #8
    unsigned long prio =
32201c9c:	e0033c11 	and	r3, r3, r1, lsl ip
}
32201ca0:	e1c30211 	bic	r0, r3, r1, lsl r2
32201ca4:	e8bd8030 	pop	{r4, r5, pc}

32201ca8 <gicr_set_icfgr>:
    __asm__ volatile(
32201ca8:	e3053030 	movw	r3, #20528	@ 0x5030
32201cac:	e3433221 	movt	r3, #12833	@ 0x3221
{
32201cb0:	e92d4030 	push	{r4, r5, lr}
32201cb4:	e2835004 	add	r5, r3, #4
32201cb8:	e193ce9f 	ldaex	ip, [r3]
32201cbc:	e28ce001 	add	lr, ip, #1
32201cc0:	e1834f9e 	strex	r4, lr, [r3]
32201cc4:	e3540000 	cmp	r4, #0
32201cc8:	1afffffa 	bne	32201cb8 <gicr_set_icfgr+0x10>
32201ccc:	e595e000 	ldr	lr, [r5]
32201cd0:	e15c000e 	cmp	ip, lr
32201cd4:	0a000001 	beq	32201ce0 <gicr_set_icfgr+0x38>
32201cd8:	e320f002 	wfe
32201cdc:	eafffffa 	b	32201ccc <gicr_set_icfgr+0x24>
    unsigned long reg_ind = (int_id * GIC_CONFIG_BITS) / (sizeof(uint32_t) * 8);
32201ce0:	e1a00080 	lsl	r0, r0, #1
    if (reg_ind == 0) {
32201ce4:	e350001f 	cmp	r0, #31
    unsigned long off = (int_id * GIC_CONFIG_BITS) % (sizeof(uint32_t) * 8);
32201ce8:	e200c01e 	and	ip, r0, #30
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32201cec:	e30c013c 	movw	r0, #49468	@ 0xc13c
32201cf0:	e3430220 	movt	r0, #12832	@ 0x3220
32201cf4:	e1a01c11 	lsl	r1, r1, ip
32201cf8:	e5900000 	ldr	r0, [r0]
32201cfc:	e0802882 	add	r2, r0, r2, lsl #17
    unsigned long mask = ((1U << GIC_CONFIG_BITS) - 1) << off;
32201d00:	e3a00003 	mov	r0, #3
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32201d04:	e2822801 	add	r2, r2, #65536	@ 0x10000
    unsigned long mask = ((1U << GIC_CONFIG_BITS) - 1) << off;
32201d08:	e1a00c10 	lsl	r0, r0, ip
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32201d0c:	9592cc00 	ldrls	ip, [r2, #3072]	@ 0xc00
            (gicr[gicr_id].ICFGR1 & ~mask) | ((cfg << off) & mask);
32201d10:	8592cc04 	ldrhi	ip, [r2, #3076]	@ 0xc04
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32201d14:	9021100c 	eorls	r1, r1, ip
            (gicr[gicr_id].ICFGR1 & ~mask) | ((cfg << off) & mask);
32201d18:	8021100c 	eorhi	r1, r1, ip
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32201d1c:	90011000 	andls	r1, r1, r0
            (gicr[gicr_id].ICFGR1 & ~mask) | ((cfg << off) & mask);
32201d20:	80011000 	andhi	r1, r1, r0
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32201d24:	9021100c 	eorls	r1, r1, ip
            (gicr[gicr_id].ICFGR1 & ~mask) | ((cfg << off) & mask);
32201d28:	8021100c 	eorhi	r1, r1, ip
        gicr[gicr_id].ICFGR0 =
32201d2c:	95821c00 	strls	r1, [r2, #3072]	@ 0xc00
        gicr[gicr_id].ICFGR1 =
32201d30:	85821c04 	strhi	r1, [r2, #3076]	@ 0xc04
    __asm__ volatile(
32201d34:	e2832004 	add	r2, r3, #4
32201d38:	e5923000 	ldr	r3, [r2]
32201d3c:	e2833001 	add	r3, r3, #1
32201d40:	e182fc93 	stl	r3, [r2]
32201d44:	f57ff04b 	dsb	ish
32201d48:	e320f004 	sev
}
32201d4c:	e8bd8030 	pop	{r4, r5, pc}

32201d50 <gicr_get_state>:
    unsigned long mask = GIC_INT_MASK(int_id);
32201d50:	e200001f 	and	r0, r0, #31
32201d54:	e3a0c001 	mov	ip, #1
    __asm__ volatile(
32201d58:	e3053030 	movw	r3, #20528	@ 0x5030
32201d5c:	e3433221 	movt	r3, #12833	@ 0x3221
{
32201d60:	e92d4010 	push	{r4, lr}
    unsigned long mask = GIC_INT_MASK(int_id);
32201d64:	e1a0c01c 	lsl	ip, ip, r0
32201d68:	e2834004 	add	r4, r3, #4
32201d6c:	e1932e9f 	ldaex	r2, [r3]
32201d70:	e2820001 	add	r0, r2, #1
32201d74:	e183ef90 	strex	lr, r0, [r3]
32201d78:	e35e0000 	cmp	lr, #0
32201d7c:	1afffffa 	bne	32201d6c <gicr_get_state+0x1c>
32201d80:	e5940000 	ldr	r0, [r4]
32201d84:	e1520000 	cmp	r2, r0
32201d88:	0a000001 	beq	32201d94 <gicr_get_state+0x44>
32201d8c:	e320f002 	wfe
32201d90:	eafffffa 	b	32201d80 <gicr_get_state+0x30>
    enum int_state pend = (gicr[gicr_id].ISPENDR0 & mask) ? PEND : 0;
32201d94:	e30c213c 	movw	r2, #49468	@ 0xc13c
32201d98:	e3432220 	movt	r2, #12832	@ 0x3220
    __asm__ volatile(
32201d9c:	e1a00004 	mov	r0, r4
32201da0:	e5922000 	ldr	r2, [r2]
32201da4:	e0821881 	add	r1, r2, r1, lsl #17
32201da8:	e2811801 	add	r1, r1, #65536	@ 0x10000
32201dac:	e5912200 	ldr	r2, [r1, #512]	@ 0x200
    enum int_state act = (gicr[gicr_id].ISACTIVER0 & mask) ? ACT : 0;
32201db0:	e5911300 	ldr	r1, [r1, #768]	@ 0x300
32201db4:	e5943000 	ldr	r3, [r4]
32201db8:	e2833001 	add	r3, r3, #1
32201dbc:	e184fc93 	stl	r3, [r4]
32201dc0:	f57ff04b 	dsb	ish
32201dc4:	e320f004 	sev
32201dc8:	e111000c 	tst	r1, ip
32201dcc:	13a00001 	movne	r0, #1
32201dd0:	03a00000 	moveq	r0, #0
    enum int_state pend = (gicr[gicr_id].ISPENDR0 & mask) ? PEND : 0;
32201dd4:	e112000c 	tst	r2, ip
32201dd8:	13a03001 	movne	r3, #1
32201ddc:	03a03000 	moveq	r3, #0
}
32201de0:	e1830080 	orr	r0, r3, r0, lsl #1
32201de4:	e8bd8010 	pop	{r4, pc}

32201de8 <gicr_set_act>:
    __asm__ volatile(
32201de8:	e3053030 	movw	r3, #20528	@ 0x5030
32201dec:	e3433221 	movt	r3, #12833	@ 0x3221

void gicr_set_act(unsigned long int_id, bool act, uint32_t gicr_id)
{
32201df0:	e92d4030 	push	{r4, r5, lr}
32201df4:	e2835004 	add	r5, r3, #4
32201df8:	e193ce9f 	ldaex	ip, [r3]
32201dfc:	e28ce001 	add	lr, ip, #1
32201e00:	e1834f9e 	strex	r4, lr, [r3]
32201e04:	e3540000 	cmp	r4, #0
32201e08:	1afffffa 	bne	32201df8 <gicr_set_act+0x10>
32201e0c:	e595e000 	ldr	lr, [r5]
32201e10:	e15c000e 	cmp	ip, lr
32201e14:	0a000001 	beq	32201e20 <gicr_set_act+0x38>
32201e18:	e320f002 	wfe
32201e1c:	eafffffa 	b	32201e0c <gicr_set_act+0x24>
    spin_lock(&gicr_lock);

    if (act) {
        gicr[gicr_id].ISACTIVER0 = GIC_INT_MASK(int_id);
32201e20:	e30cc13c 	movw	ip, #49468	@ 0xc13c
32201e24:	e343c220 	movt	ip, #12832	@ 0x3220
    if (act) {
32201e28:	e3510000 	cmp	r1, #0
        gicr[gicr_id].ISACTIVER0 = GIC_INT_MASK(int_id);
32201e2c:	e200001f 	and	r0, r0, #31
32201e30:	e59c1000 	ldr	r1, [ip]
32201e34:	e0812882 	add	r2, r1, r2, lsl #17
32201e38:	e3a01001 	mov	r1, #1
32201e3c:	e2822801 	add	r2, r2, #65536	@ 0x10000
32201e40:	e1a01011 	lsl	r1, r1, r0
32201e44:	15821300 	strne	r1, [r2, #768]	@ 0x300
    } else {
        gicr[gicr_id].ICACTIVER0 = GIC_INT_MASK(int_id);
32201e48:	05821380 	streq	r1, [r2, #896]	@ 0x380
    __asm__ volatile(
32201e4c:	e2832004 	add	r2, r3, #4
32201e50:	e5923000 	ldr	r3, [r2]
32201e54:	e2833001 	add	r3, r3, #1
32201e58:	e182fc93 	stl	r3, [r2]
32201e5c:	f57ff04b 	dsb	ish
32201e60:	e320f004 	sev
    }

    spin_unlock(&gicr_lock);
}
32201e64:	e8bd8030 	pop	{r4, r5, pc}

32201e68 <gicr_set_state>:

void gicr_set_state(unsigned long int_id, enum int_state state, uint32_t gicr_id)
{
32201e68:	e92d4070 	push	{r4, r5, r6, lr}
32201e6c:	e1a04001 	mov	r4, r1
32201e70:	e1a05000 	mov	r5, r0
32201e74:	e1a06002 	mov	r6, r2
    gicr_set_act(int_id, state & ACT, gicr_id);
32201e78:	e7e010d1 	ubfx	r1, r1, #1, #1
32201e7c:	ebffffd9 	bl	32201de8 <gicr_set_act>
    gicr_set_pend(int_id, state & PEND, gicr_id);
32201e80:	e1a02006 	mov	r2, r6
32201e84:	e2041001 	and	r1, r4, #1
32201e88:	e1a00005 	mov	r0, r5
}
32201e8c:	e8bd4070 	pop	{r4, r5, r6, lr}
    gicr_set_pend(int_id, state & PEND, gicr_id);
32201e90:	eafffd60 	b	32201418 <gicr_set_pend>

32201e94 <gicr_set_trgt>:
    __asm__ volatile(
32201e94:	e3053030 	movw	r3, #20528	@ 0x5030
32201e98:	e3433221 	movt	r3, #12833	@ 0x3221
32201e9c:	e283c004 	add	ip, r3, #4
32201ea0:	e1932e9f 	ldaex	r2, [r3]
32201ea4:	e2821001 	add	r1, r2, #1
32201ea8:	e1830f91 	strex	r0, r1, [r3]
32201eac:	e3500000 	cmp	r0, #0
32201eb0:	1afffffa 	bne	32201ea0 <gicr_set_trgt+0xc>
32201eb4:	e59c1000 	ldr	r1, [ip]
32201eb8:	e1520001 	cmp	r2, r1
32201ebc:	0a000001 	beq	32201ec8 <gicr_set_trgt+0x34>
32201ec0:	e320f002 	wfe
32201ec4:	eafffffa 	b	32201eb4 <gicr_set_trgt+0x20>
    __asm__ volatile(
32201ec8:	e59c3000 	ldr	r3, [ip]
32201ecc:	e2833001 	add	r3, r3, #1
32201ed0:	e18cfc93 	stl	r3, [ip]
32201ed4:	f57ff04b 	dsb	ish
32201ed8:	e320f004 	sev
void gicr_set_trgt(unsigned long int_id, uint8_t trgt, uint32_t gicr_id)
{
    spin_lock(&gicr_lock);

    spin_unlock(&gicr_lock);
}
32201edc:	e12fff1e 	bx	lr

32201ee0 <gicr_set_route>:
    __asm__ volatile(
32201ee0:	e3053030 	movw	r3, #20528	@ 0x5030
32201ee4:	e3433221 	movt	r3, #12833	@ 0x3221
32201ee8:	e283c004 	add	ip, r3, #4
32201eec:	e1932e9f 	ldaex	r2, [r3]
32201ef0:	e2821001 	add	r1, r2, #1
32201ef4:	e1830f91 	strex	r0, r1, [r3]
32201ef8:	e3500000 	cmp	r0, #0
32201efc:	1afffffa 	bne	32201eec <gicr_set_route+0xc>
32201f00:	e59c1000 	ldr	r1, [ip]
32201f04:	e1520001 	cmp	r2, r1
32201f08:	0a000001 	beq	32201f14 <gicr_set_route+0x34>
32201f0c:	e320f002 	wfe
32201f10:	eafffffa 	b	32201f00 <gicr_set_route+0x20>
    __asm__ volatile(
32201f14:	e59c3000 	ldr	r3, [ip]
32201f18:	e2833001 	add	r3, r3, #1
32201f1c:	e18cfc93 	stl	r3, [ip]
32201f20:	f57ff04b 	dsb	ish
32201f24:	e320f004 	sev

void gicr_set_route(unsigned long int_id, uint8_t trgt, uint32_t gicr_id)
{
    gicr_set_trgt(int_id, trgt, gicr_id);
}
32201f28:	e12fff1e 	bx	lr

32201f2c <gicr_set_enable>:

void gicr_set_enable(unsigned long int_id, bool en, uint32_t gicr_id)
{
    unsigned long bit = GIC_INT_MASK(int_id);
32201f2c:	e200001f 	and	r0, r0, #31
32201f30:	e3a03001 	mov	r3, #1
{
32201f34:	e92d4030 	push	{r4, r5, lr}
    unsigned long bit = GIC_INT_MASK(int_id);
32201f38:	e1a00013 	lsl	r0, r3, r0
    __asm__ volatile(
32201f3c:	e3053030 	movw	r3, #20528	@ 0x5030
32201f40:	e3433221 	movt	r3, #12833	@ 0x3221
32201f44:	e2835004 	add	r5, r3, #4
32201f48:	e193ce9f 	ldaex	ip, [r3]
32201f4c:	e28ce001 	add	lr, ip, #1
32201f50:	e1834f9e 	strex	r4, lr, [r3]
32201f54:	e3540000 	cmp	r4, #0
32201f58:	1afffffa 	bne	32201f48 <gicr_set_enable+0x1c>
32201f5c:	e595e000 	ldr	lr, [r5]
32201f60:	e15c000e 	cmp	ip, lr
32201f64:	0a000001 	beq	32201f70 <gicr_set_enable+0x44>
32201f68:	e320f002 	wfe
32201f6c:	eafffffa 	b	32201f5c <gicr_set_enable+0x30>

    spin_lock(&gicr_lock);
    if (en)
        gicr[gicr_id].ISENABLER0 = bit;
32201f70:	e30cc13c 	movw	ip, #49468	@ 0xc13c
32201f74:	e343c220 	movt	ip, #12832	@ 0x3220
    if (en)
32201f78:	e3510000 	cmp	r1, #0
        gicr[gicr_id].ISENABLER0 = bit;
32201f7c:	e59c1000 	ldr	r1, [ip]
32201f80:	e0812882 	add	r2, r1, r2, lsl #17
32201f84:	e2822801 	add	r2, r2, #65536	@ 0x10000
32201f88:	15820100 	strne	r0, [r2, #256]	@ 0x100
    else
        gicr[gicr_id].ICENABLER0 = bit;
32201f8c:	05820180 	streq	r0, [r2, #384]	@ 0x180
    __asm__ volatile(
32201f90:	e2832004 	add	r2, r3, #4
32201f94:	e5923000 	ldr	r3, [r2]
32201f98:	e2833001 	add	r3, r3, #1
32201f9c:	e182fc93 	stl	r3, [r2]
32201fa0:	f57ff04b 	dsb	ish
32201fa4:	e320f004 	sev
    spin_unlock(&gicr_lock);
}
32201fa8:	e8bd8030 	pop	{r4, r5, pc}

32201fac <gic_send_sgi>:
    else return false;
}

void gic_send_sgi(unsigned long cpu_target, unsigned long sgi_num)
{
    if (sgi_num >= GIC_MAX_SGIS) return;
32201fac:	e351000f 	cmp	r1, #15
32201fb0:	812fff1e 	bxhi	lr
    
    unsigned long sgi = (1UL << (cpu_target & 0xffull)) | (sgi_num << 24);
32201fb4:	e6ef0070 	uxtb	r0, r0
32201fb8:	e1a01c01 	lsl	r1, r1, #24
32201fbc:	e3a0c001 	mov	ip, #1
    sysreg_icc_sgi1r_el1_write(sgi); 
32201fc0:	e3a03000 	mov	r3, #0
32201fc4:	e181201c 	orr	r2, r1, ip, lsl r0
SYSREG_GEN_ACCESSORS_64(icc_sgi1r_el1, 0, c12);
32201fc8:	e3a00000 	mov	r0, #0
32201fcc:	e3a01000 	mov	r1, #0
32201fd0:	ec402f0c 	mcrr	15, 0, r2, r0, cr12
}
32201fd4:	e12fff1e 	bx	lr

32201fd8 <gic_set_prio>:
    if (int_id > 32 && int_id < 1025) return true;
32201fd8:	e2403021 	sub	r3, r0, #33	@ 0x21
32201fdc:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32201fe0:	2a000000 	bcs	32201fe8 <gic_set_prio+0x10>

void gic_set_prio(unsigned long int_id, uint8_t prio)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_prio(int_id, prio);
32201fe4:	eafffe20 	b	3220186c <gicd_set_prio>
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
32201fe8:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_prio(int_id, prio, get_cpuid());
32201fec:	e6ef2072 	uxtb	r2, r2
32201ff0:	eafffee2 	b	32201b80 <gicr_set_prio>

32201ff4 <gic_get_prio>:
    if (int_id > 32 && int_id < 1025) return true;
32201ff4:	e2403021 	sub	r3, r0, #33	@ 0x21
32201ff8:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32201ffc:	2a000000 	bcs	32202004 <gic_get_prio+0x10>
}

unsigned long gic_get_prio(unsigned long int_id)
{
    if (irq_in_gicd(int_id)) {
        return gicd_get_prio(int_id);
32202000:	eafffdd5 	b	3220175c <gicd_get_prio>
32202004:	ee101fb0 	mrc	15, 0, r1, cr0, cr0, {5}
    } else {
        return gicr_get_prio(int_id, get_cpuid());
32202008:	e6ef1071 	uxtb	r1, r1
3220200c:	eaffff02 	b	32201c1c <gicr_get_prio>

32202010 <gic_set_icfgr>:
    if (int_id > 32 && int_id < 1025) return true;
32202010:	e2403021 	sub	r3, r0, #33	@ 0x21
32202014:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32202018:	2a000000 	bcs	32202020 <gic_set_icfgr+0x10>
}

void gic_set_icfgr(unsigned long int_id, uint8_t cfg)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_icfgr(int_id, cfg);
3220201c:	eafffdf0 	b	322017e4 <gicd_set_icfgr>
32202020:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_icfgr(int_id, cfg, get_cpuid());
32202024:	e6ef2072 	uxtb	r2, r2
32202028:	eaffff1e 	b	32201ca8 <gicr_set_icfgr>

3220202c <gic_get_state>:
    if (int_id > 32 && int_id < 1025) return true;
3220202c:	e2403021 	sub	r3, r0, #33	@ 0x21
32202030:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32202034:	2a000000 	bcs	3220203c <gic_get_state+0x10>
}

enum int_state gic_get_state(unsigned long int_id)
{
    if (irq_in_gicd(int_id)) {
        return gicd_get_state(int_id);
32202038:	eafffe2f 	b	322018fc <gicd_get_state>
3220203c:	ee101fb0 	mrc	15, 0, r1, cr0, cr0, {5}
    } else {
        return gicr_get_state(int_id, get_cpuid());
32202040:	e6ef1071 	uxtb	r1, r1
32202044:	eaffff41 	b	32201d50 <gicr_get_state>

32202048 <gic_set_pend>:
    if (int_id > 32 && int_id < 1025) return true;
32202048:	e2403021 	sub	r3, r0, #33	@ 0x21
3220204c:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32202050:	2a000000 	bcs	32202058 <gic_set_pend+0x10>
}

void gic_set_pend(unsigned long int_id, bool pend)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_pend(int_id, pend);
32202054:	eafffd0e 	b	32201494 <gicd_set_pend>
32202058:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_pend(int_id, pend, get_cpuid());
3220205c:	e6ef2072 	uxtb	r2, r2
32202060:	eafffcec 	b	32201418 <gicr_set_pend>

32202064 <gic_set_act>:
    if (int_id > 32 && int_id < 1025) return true;
32202064:	e2403021 	sub	r3, r0, #33	@ 0x21
32202068:	e3530e3e 	cmp	r3, #992	@ 0x3e0
3220206c:	2a000000 	bcs	32202074 <gic_set_act+0x10>
}

void gic_set_act(unsigned long int_id, bool act)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_act(int_id, act);
32202070:	eafffe48 	b	32201998 <gicd_set_act>
32202074:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_act(int_id, act, get_cpuid());
32202078:	e6ef2072 	uxtb	r2, r2
3220207c:	eaffff59 	b	32201de8 <gicr_set_act>

32202080 <gic_set_state>:
    if (int_id > 32 && int_id < 1025) return true;
32202080:	e2403021 	sub	r3, r0, #33	@ 0x21
    }
}

void gic_set_state(unsigned long int_id, enum int_state state)
{
32202084:	e92d4070 	push	{r4, r5, r6, lr}
    if (int_id > 32 && int_id < 1025) return true;
32202088:	e3530e3e 	cmp	r3, #992	@ 0x3e0
    gicd_set_pend(int_id, state & PEND);
3220208c:	e2016001 	and	r6, r1, #1
{
32202090:	e1a04000 	mov	r4, r0
    gicd_set_act(int_id, state & ACT);
32202094:	e7e010d1 	ubfx	r1, r1, #1, #1
    if (int_id > 32 && int_id < 1025) return true;
32202098:	2a000004 	bcs	322020b0 <gic_set_state+0x30>
    gicd_set_act(int_id, state & ACT);
3220209c:	ebfffe3d 	bl	32201998 <gicd_set_act>
    gicd_set_pend(int_id, state & PEND);
322020a0:	e1a01006 	mov	r1, r6
322020a4:	e1a00004 	mov	r0, r4
    if (irq_in_gicd(int_id)) {
        return gicd_set_state(int_id, state);
    } else {
        return gicr_set_state(int_id, state, get_cpuid());
    }
}
322020a8:	e8bd4070 	pop	{r4, r5, r6, lr}
    gicd_set_pend(int_id, state & PEND);
322020ac:	eafffcf8 	b	32201494 <gicd_set_pend>
322020b0:	ee105fb0 	mrc	15, 0, r5, cr0, cr0, {5}
322020b4:	e6ef5075 	uxtb	r5, r5
    gicr_set_act(int_id, state & ACT, gicr_id);
322020b8:	e1a02005 	mov	r2, r5
322020bc:	ebffff49 	bl	32201de8 <gicr_set_act>
    gicr_set_pend(int_id, state & PEND, gicr_id);
322020c0:	e1a02005 	mov	r2, r5
322020c4:	e1a01006 	mov	r1, r6
322020c8:	e1a00004 	mov	r0, r4
}
322020cc:	e8bd4070 	pop	{r4, r5, r6, lr}
    gicr_set_pend(int_id, state & PEND, gicr_id);
322020d0:	eafffcd0 	b	32201418 <gicr_set_pend>

322020d4 <gic_set_trgt>:
    if (int_id > 32 && int_id < 1025) return true;
322020d4:	e2403021 	sub	r3, r0, #33	@ 0x21
322020d8:	e3530e3e 	cmp	r3, #992	@ 0x3e0
322020dc:	2a000000 	bcs	322020e4 <gic_set_trgt+0x10>

void gic_set_trgt(unsigned long int_id, uint8_t trgt)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_trgt(int_id, trgt);
322020e0:	eafffe56 	b	32201a40 <gicd_set_trgt>
322020e4:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
    __asm__ volatile(
322020e8:	e3053030 	movw	r3, #20528	@ 0x5030
322020ec:	e3433221 	movt	r3, #12833	@ 0x3221
322020f0:	e283c004 	add	ip, r3, #4
322020f4:	e1932e9f 	ldaex	r2, [r3]
322020f8:	e2821001 	add	r1, r2, #1
322020fc:	e1830f91 	strex	r0, r1, [r3]
32202100:	e3500000 	cmp	r0, #0
32202104:	1afffffa 	bne	322020f4 <gic_set_trgt+0x20>
32202108:	e59c1000 	ldr	r1, [ip]
3220210c:	e1520001 	cmp	r2, r1
32202110:	0a000001 	beq	3220211c <gic_set_trgt+0x48>
32202114:	e320f002 	wfe
32202118:	eafffffa 	b	32202108 <gic_set_trgt+0x34>
    __asm__ volatile(
3220211c:	e59c3000 	ldr	r3, [ip]
32202120:	e2833001 	add	r3, r3, #1
32202124:	e18cfc93 	stl	r3, [ip]
32202128:	f57ff04b 	dsb	ish
3220212c:	e320f004 	sev
    } else {
        return gicr_set_trgt(int_id, trgt, get_cpuid());
    }
}
32202130:	e12fff1e 	bx	lr

32202134 <gic_set_route>:
    if (gic_is_priv(int_id)) return;
32202134:	e350001f 	cmp	r0, #31
32202138:	912fff1e 	bxls	lr
    volatile uint32_t *irouter = (uint32_t*) &gicd->IROUTER[int_id];
3220213c:	e30c313c 	movw	r3, #49468	@ 0xc13c
32202140:	e3433220 	movt	r3, #12832	@ 0x3220
32202144:	e2800b03 	add	r0, r0, #3072	@ 0xc00
    irouter[1] = (_trgt >> 32);
32202148:	e3a0c000 	mov	ip, #0
    volatile uint32_t *irouter = (uint32_t*) &gicd->IROUTER[int_id];
3220214c:	e5933004 	ldr	r3, [r3, #4]
32202150:	e0832180 	add	r2, r3, r0, lsl #3
    irouter[0] = _trgt;
32202154:	e7831180 	str	r1, [r3, r0, lsl #3]
    irouter[1] = (_trgt >> 32);
32202158:	e582c004 	str	ip, [r2, #4]

void gic_set_route(unsigned long int_id, unsigned long trgt)
{
    return gicd_set_route(int_id, trgt);
}
3220215c:	e12fff1e 	bx	lr

32202160 <gic_set_enable>:
    if (int_id > 32 && int_id < 1025) return true;
32202160:	e2403021 	sub	r3, r0, #33	@ 0x21
32202164:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32202168:	2a000000 	bcs	32202170 <gic_set_enable+0x10>

void gic_set_enable(unsigned long int_id, bool en)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_enable(int_id, en);
3220216c:	eafffe62 	b	32201afc <gicd_set_enable>
32202170:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_enable(int_id, en, get_cpuid());
32202174:	e6ef2072 	uxtb	r2, r2
32202178:	eaffff6b 	b	32201f2c <gicr_set_enable>
3220217c:	00000000 	andeq	r0, r0, r0

32202180 <_exception_vector>:
.text

.balign 0x20
.global _exception_vector
_exception_vector:
    b .
32202180:	eafffffe 	b	32202180 <_exception_vector>
    b .
32202184:	eafffffe 	b	32202184 <_exception_vector+0x4>
    b .
32202188:	eafffffe 	b	32202188 <_exception_vector+0x8>
    b .
3220218c:	eafffffe 	b	3220218c <_exception_vector+0xc>
    b .
32202190:	eafffffe 	b	32202190 <_exception_vector+0x10>
    b .
32202194:	eafffffe 	b	32202194 <_exception_vector+0x14>
    b irq_handler
32202198:	eaffffff 	b	3220219c <irq_handler>

3220219c <irq_handler>:

irq_handler:
    push {r0-r12, r14}
3220219c:	e92d5fff 	push	{r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp, ip, lr}
    bl gic_handle
322021a0:	ebfffd64 	bl	32201738 <gic_handle>
    pop {r0-r12, r14}
322021a4:	e8bd5fff 	pop	{r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp, ip, lr}
    SUBS PC, lr, #4
322021a8:	e25ef004 	subs	pc, lr, #4

322021ac <__assert_func>:
322021ac:	f24c 35d0 	movw	r5, #50128	@ 0xc3d0
322021b0:	f2c3 2520 	movt	r5, #12832	@ 0x3220
322021b4:	b500      	push	{lr}
322021b6:	4614      	mov	r4, r2
322021b8:	460e      	mov	r6, r1
322021ba:	682d      	ldr	r5, [r5, #0]
322021bc:	461a      	mov	r2, r3
322021be:	b085      	sub	sp, #20
322021c0:	4603      	mov	r3, r0
322021c2:	68e8      	ldr	r0, [r5, #12]
322021c4:	b174      	cbz	r4, 322021e4 <__assert_func+0x38>
322021c6:	f64b 15b0 	movw	r5, #47536	@ 0xb9b0
322021ca:	f2c3 2520 	movt	r5, #12832	@ 0x3220
322021ce:	f64b 11c0 	movw	r1, #47552	@ 0xb9c0
322021d2:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322021d6:	e9cd 5401 	strd	r5, r4, [sp, #4]
322021da:	9600      	str	r6, [sp, #0]
322021dc:	f000 f81c 	bl	32202218 <fiprintf>
322021e0:	f003 fb1a 	bl	32205818 <abort>
322021e4:	f24b 7504 	movw	r5, #46852	@ 0xb704
322021e8:	f2c3 2520 	movt	r5, #12832	@ 0x3220
322021ec:	462c      	mov	r4, r5
322021ee:	e7ee      	b.n	322021ce <__assert_func+0x22>

322021f0 <__assert>:
322021f0:	b508      	push	{r3, lr}
322021f2:	4613      	mov	r3, r2
322021f4:	2200      	movs	r2, #0
322021f6:	f7ff ffd9 	bl	322021ac <__assert_func>
322021fa:	bf00      	nop

322021fc <_fiprintf_r>:
322021fc:	b40c      	push	{r2, r3}
322021fe:	b500      	push	{lr}
32202200:	b083      	sub	sp, #12
32202202:	ab04      	add	r3, sp, #16
32202204:	f853 2b04 	ldr.w	r2, [r3], #4
32202208:	9301      	str	r3, [sp, #4]
3220220a:	f000 f81b 	bl	32202244 <_vfiprintf_r>
3220220e:	b003      	add	sp, #12
32202210:	f85d eb04 	ldr.w	lr, [sp], #4
32202214:	b002      	add	sp, #8
32202216:	4770      	bx	lr

32202218 <fiprintf>:
32202218:	b40e      	push	{r1, r2, r3}
3220221a:	f24c 3cd0 	movw	ip, #50128	@ 0xc3d0
3220221e:	f2c3 2c20 	movt	ip, #12832	@ 0x3220
32202222:	b500      	push	{lr}
32202224:	4601      	mov	r1, r0
32202226:	b082      	sub	sp, #8
32202228:	f8dc 0000 	ldr.w	r0, [ip]
3220222c:	ab03      	add	r3, sp, #12
3220222e:	f853 2b04 	ldr.w	r2, [r3], #4
32202232:	9301      	str	r3, [sp, #4]
32202234:	f000 f806 	bl	32202244 <_vfiprintf_r>
32202238:	b002      	add	sp, #8
3220223a:	f85d eb04 	ldr.w	lr, [sp], #4
3220223e:	b003      	add	sp, #12
32202240:	4770      	bx	lr
32202242:	bf00      	nop

32202244 <_vfiprintf_r>:
32202244:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32202248:	4683      	mov	fp, r0
3220224a:	4615      	mov	r5, r2
3220224c:	b0c7      	sub	sp, #284	@ 0x11c
3220224e:	2208      	movs	r2, #8
32202250:	f10d 0a58 	add.w	sl, sp, #88	@ 0x58
32202254:	461c      	mov	r4, r3
32202256:	4650      	mov	r0, sl
32202258:	9105      	str	r1, [sp, #20]
3220225a:	2100      	movs	r1, #0
3220225c:	930c      	str	r3, [sp, #48]	@ 0x30
3220225e:	f001 ff83 	bl	32204168 <memset>
32202262:	f1bb 0f00 	cmp.w	fp, #0
32202266:	d004      	beq.n	32202272 <_vfiprintf_r+0x2e>
32202268:	f8db 3034 	ldr.w	r3, [fp, #52]	@ 0x34
3220226c:	2b00      	cmp	r3, #0
3220226e:	f000 878e 	beq.w	3220318e <_vfiprintf_r+0xf4a>
32202272:	9a05      	ldr	r2, [sp, #20]
32202274:	6e53      	ldr	r3, [r2, #100]	@ 0x64
32202276:	f9b2 200c 	ldrsh.w	r2, [r2, #12]
3220227a:	07df      	lsls	r7, r3, #31
3220227c:	f140 8147 	bpl.w	3220250e <_vfiprintf_r+0x2ca>
32202280:	0496      	lsls	r6, r2, #18
32202282:	f100 85f8 	bmi.w	32202e76 <_vfiprintf_r+0xc32>
32202286:	9905      	ldr	r1, [sp, #20]
32202288:	f442 5200 	orr.w	r2, r2, #8192	@ 0x2000
3220228c:	f423 5300 	bic.w	r3, r3, #8192	@ 0x2000
32202290:	818a      	strh	r2, [r1, #12]
32202292:	b212      	sxth	r2, r2
32202294:	664b      	str	r3, [r1, #100]	@ 0x64
32202296:	0716      	lsls	r6, r2, #28
32202298:	f140 80c4 	bpl.w	32202424 <_vfiprintf_r+0x1e0>
3220229c:	9b05      	ldr	r3, [sp, #20]
3220229e:	691b      	ldr	r3, [r3, #16]
322022a0:	2b00      	cmp	r3, #0
322022a2:	f000 80bf 	beq.w	32202424 <_vfiprintf_r+0x1e0>
322022a6:	f002 031a 	and.w	r3, r2, #26
322022aa:	2b0a      	cmp	r3, #10
322022ac:	f000 80c9 	beq.w	32202442 <_vfiprintf_r+0x1fe>
322022b0:	f24c 2940 	movw	r9, #49728	@ 0xc240
322022b4:	f2c3 2920 	movt	r9, #12832	@ 0x3220
322022b8:	46a8      	mov	r8, r5
322022ba:	2300      	movs	r3, #0
322022bc:	aa1d      	add	r2, sp, #116	@ 0x74
322022be:	af1d      	add	r7, sp, #116	@ 0x74
322022c0:	921a      	str	r2, [sp, #104]	@ 0x68
322022c2:	f64b 4298 	movw	r2, #48280	@ 0xbc98
322022c6:	f2c3 2220 	movt	r2, #12832	@ 0x3220
322022ca:	e9cd 331b 	strd	r3, r3, [sp, #108]	@ 0x6c
322022ce:	930f      	str	r3, [sp, #60]	@ 0x3c
322022d0:	920e      	str	r2, [sp, #56]	@ 0x38
322022d2:	e9cd 3310 	strd	r3, r3, [sp, #64]	@ 0x40
322022d6:	9308      	str	r3, [sp, #32]
322022d8:	9704      	str	r7, [sp, #16]
322022da:	4645      	mov	r5, r8
322022dc:	f8d9 40e4 	ldr.w	r4, [r9, #228]	@ 0xe4
322022e0:	f002 fc7a 	bl	32204bd8 <__locale_mb_cur_max>
322022e4:	462a      	mov	r2, r5
322022e6:	4603      	mov	r3, r0
322022e8:	a914      	add	r1, sp, #80	@ 0x50
322022ea:	4658      	mov	r0, fp
322022ec:	f8cd a000 	str.w	sl, [sp]
322022f0:	47a0      	blx	r4
322022f2:	2800      	cmp	r0, #0
322022f4:	f000 80c4 	beq.w	32202480 <_vfiprintf_r+0x23c>
322022f8:	4603      	mov	r3, r0
322022fa:	f2c0 80b9 	blt.w	32202470 <_vfiprintf_r+0x22c>
322022fe:	9a14      	ldr	r2, [sp, #80]	@ 0x50
32202300:	2a25      	cmp	r2, #37	@ 0x25
32202302:	d001      	beq.n	32202308 <_vfiprintf_r+0xc4>
32202304:	441d      	add	r5, r3
32202306:	e7e9      	b.n	322022dc <_vfiprintf_r+0x98>
32202308:	4604      	mov	r4, r0
3220230a:	ebb5 0608 	subs.w	r6, r5, r8
3220230e:	f040 80bb 	bne.w	32202488 <_vfiprintf_r+0x244>
32202312:	2300      	movs	r3, #0
32202314:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32202318:	4619      	mov	r1, r3
3220231a:	9309      	str	r3, [sp, #36]	@ 0x24
3220231c:	786b      	ldrb	r3, [r5, #1]
3220231e:	f105 0801 	add.w	r8, r5, #1
32202322:	f04f 32ff 	mov.w	r2, #4294967295	@ 0xffffffff
32202326:	9103      	str	r1, [sp, #12]
32202328:	9207      	str	r2, [sp, #28]
3220232a:	f108 0801 	add.w	r8, r8, #1
3220232e:	f1a3 0220 	sub.w	r2, r3, #32
32202332:	2a5a      	cmp	r2, #90	@ 0x5a
32202334:	f200 80f5 	bhi.w	32202522 <_vfiprintf_r+0x2de>
32202338:	e8df f012 	tbh	[pc, r2, lsl #1]
3220233c:	00f30400 	.word	0x00f30400
32202340:	03f800f3 	.word	0x03f800f3
32202344:	00f300f3 	.word	0x00f300f3
32202348:	03d800f3 	.word	0x03d800f3
3220234c:	00f300f3 	.word	0x00f300f3
32202350:	02230211 	.word	0x02230211
32202354:	021c00f3 	.word	0x021c00f3
32202358:	00f30414 	.word	0x00f30414
3220235c:	005b040c 	.word	0x005b040c
32202360:	005b005b 	.word	0x005b005b
32202364:	005b005b 	.word	0x005b005b
32202368:	005b005b 	.word	0x005b005b
3220236c:	005b005b 	.word	0x005b005b
32202370:	00f300f3 	.word	0x00f300f3
32202374:	00f300f3 	.word	0x00f300f3
32202378:	00f300f3 	.word	0x00f300f3
3220237c:	00f300f3 	.word	0x00f300f3
32202380:	01d000f3 	.word	0x01d000f3
32202384:	00f30325 	.word	0x00f30325
32202388:	00f300f3 	.word	0x00f300f3
3220238c:	00f300f3 	.word	0x00f300f3
32202390:	00f300f3 	.word	0x00f300f3
32202394:	00f300f3 	.word	0x00f300f3
32202398:	022900f3 	.word	0x022900f3
3220239c:	00f300f3 	.word	0x00f300f3
322023a0:	01a200f3 	.word	0x01a200f3
322023a4:	029c00f3 	.word	0x029c00f3
322023a8:	00f300f3 	.word	0x00f300f3
322023ac:	00f305e1 	.word	0x00f305e1
322023b0:	00f300f3 	.word	0x00f300f3
322023b4:	00f300f3 	.word	0x00f300f3
322023b8:	00f300f3 	.word	0x00f300f3
322023bc:	00f300f3 	.word	0x00f300f3
322023c0:	01d000f3 	.word	0x01d000f3
322023c4:	00f30172 	.word	0x00f30172
322023c8:	00f300f3 	.word	0x00f300f3
322023cc:	017203ce 	.word	0x017203ce
322023d0:	00f3006d 	.word	0x00f3006d
322023d4:	00f3031b 	.word	0x00f3031b
322023d8:	02f8030d 	.word	0x02f8030d
322023dc:	006d02c6 	.word	0x006d02c6
322023e0:	01a200f3 	.word	0x01a200f3
322023e4:	025d006a 	.word	0x025d006a
322023e8:	00f300f3 	.word	0x00f300f3
322023ec:	00f30629 	.word	0x00f30629
322023f0:	006a      	.short	0x006a
322023f2:	f1a3 0230 	sub.w	r2, r3, #48	@ 0x30
322023f6:	2300      	movs	r3, #0
322023f8:	210a      	movs	r1, #10
322023fa:	4618      	mov	r0, r3
322023fc:	f818 3b01 	ldrb.w	r3, [r8], #1
32202400:	fb01 2000 	mla	r0, r1, r0, r2
32202404:	f1a3 0230 	sub.w	r2, r3, #48	@ 0x30
32202408:	2a09      	cmp	r2, #9
3220240a:	d9f7      	bls.n	322023fc <_vfiprintf_r+0x1b8>
3220240c:	9009      	str	r0, [sp, #36]	@ 0x24
3220240e:	e78e      	b.n	3220232e <_vfiprintf_r+0xea>
32202410:	f898 3000 	ldrb.w	r3, [r8]
32202414:	e789      	b.n	3220232a <_vfiprintf_r+0xe6>
32202416:	9b03      	ldr	r3, [sp, #12]
32202418:	f043 0320 	orr.w	r3, r3, #32
3220241c:	9303      	str	r3, [sp, #12]
3220241e:	f898 3000 	ldrb.w	r3, [r8]
32202422:	e782      	b.n	3220232a <_vfiprintf_r+0xe6>
32202424:	9e05      	ldr	r6, [sp, #20]
32202426:	4658      	mov	r0, fp
32202428:	4631      	mov	r1, r6
3220242a:	f001 fda9 	bl	32203f80 <__swsetup_r>
3220242e:	2800      	cmp	r0, #0
32202430:	f040 87f3 	bne.w	3220341a <_vfiprintf_r+0x11d6>
32202434:	f9b6 200c 	ldrsh.w	r2, [r6, #12]
32202438:	f002 031a 	and.w	r3, r2, #26
3220243c:	2b0a      	cmp	r3, #10
3220243e:	f47f af37 	bne.w	322022b0 <_vfiprintf_r+0x6c>
32202442:	9905      	ldr	r1, [sp, #20]
32202444:	f9b1 300e 	ldrsh.w	r3, [r1, #14]
32202448:	2b00      	cmp	r3, #0
3220244a:	f6ff af31 	blt.w	322022b0 <_vfiprintf_r+0x6c>
3220244e:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
32202450:	07d8      	lsls	r0, r3, #31
32202452:	d402      	bmi.n	3220245a <_vfiprintf_r+0x216>
32202454:	0592      	lsls	r2, r2, #22
32202456:	f140 873e 	bpl.w	322032d6 <_vfiprintf_r+0x1092>
3220245a:	9905      	ldr	r1, [sp, #20]
3220245c:	4623      	mov	r3, r4
3220245e:	462a      	mov	r2, r5
32202460:	4658      	mov	r0, fp
32202462:	f001 f80d 	bl	32203480 <__sbprintf>
32202466:	9008      	str	r0, [sp, #32]
32202468:	9808      	ldr	r0, [sp, #32]
3220246a:	b047      	add	sp, #284	@ 0x11c
3220246c:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32202470:	2208      	movs	r2, #8
32202472:	2100      	movs	r1, #0
32202474:	4650      	mov	r0, sl
32202476:	f001 fe77 	bl	32204168 <memset>
3220247a:	2301      	movs	r3, #1
3220247c:	441d      	add	r5, r3
3220247e:	e72d      	b.n	322022dc <_vfiprintf_r+0x98>
32202480:	4604      	mov	r4, r0
32202482:	ebb5 0608 	subs.w	r6, r5, r8
32202486:	d012      	beq.n	322024ae <_vfiprintf_r+0x26a>
32202488:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
3220248a:	9904      	ldr	r1, [sp, #16]
3220248c:	9a1c      	ldr	r2, [sp, #112]	@ 0x70
3220248e:	3301      	adds	r3, #1
32202490:	2b07      	cmp	r3, #7
32202492:	931b      	str	r3, [sp, #108]	@ 0x6c
32202494:	4432      	add	r2, r6
32202496:	e9c1 8600 	strd	r8, r6, [r1]
3220249a:	921c      	str	r2, [sp, #112]	@ 0x70
3220249c:	dc11      	bgt.n	322024c2 <_vfiprintf_r+0x27e>
3220249e:	3108      	adds	r1, #8
322024a0:	9104      	str	r1, [sp, #16]
322024a2:	9b08      	ldr	r3, [sp, #32]
322024a4:	4433      	add	r3, r6
322024a6:	9308      	str	r3, [sp, #32]
322024a8:	2c00      	cmp	r4, #0
322024aa:	f47f af32 	bne.w	32202312 <_vfiprintf_r+0xce>
322024ae:	9b1c      	ldr	r3, [sp, #112]	@ 0x70
322024b0:	2b00      	cmp	r3, #0
322024b2:	f040 8768 	bne.w	32203386 <_vfiprintf_r+0x1142>
322024b6:	9b05      	ldr	r3, [sp, #20]
322024b8:	2200      	movs	r2, #0
322024ba:	921b      	str	r2, [sp, #108]	@ 0x6c
322024bc:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
322024c0:	e019      	b.n	322024f6 <_vfiprintf_r+0x2b2>
322024c2:	9905      	ldr	r1, [sp, #20]
322024c4:	aa1a      	add	r2, sp, #104	@ 0x68
322024c6:	4658      	mov	r0, fp
322024c8:	f001 f826 	bl	32203518 <__sprint_r>
322024cc:	b980      	cbnz	r0, 322024f0 <_vfiprintf_r+0x2ac>
322024ce:	ab1d      	add	r3, sp, #116	@ 0x74
322024d0:	9304      	str	r3, [sp, #16]
322024d2:	e7e6      	b.n	322024a2 <_vfiprintf_r+0x25e>
322024d4:	9905      	ldr	r1, [sp, #20]
322024d6:	aa1a      	add	r2, sp, #104	@ 0x68
322024d8:	4658      	mov	r0, fp
322024da:	f001 f81d 	bl	32203518 <__sprint_r>
322024de:	2800      	cmp	r0, #0
322024e0:	f000 8089 	beq.w	322025f6 <_vfiprintf_r+0x3b2>
322024e4:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322024e6:	b11b      	cbz	r3, 322024f0 <_vfiprintf_r+0x2ac>
322024e8:	990a      	ldr	r1, [sp, #40]	@ 0x28
322024ea:	4658      	mov	r0, fp
322024ec:	f003 f9fc 	bl	322058e8 <_free_r>
322024f0:	9b05      	ldr	r3, [sp, #20]
322024f2:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
322024f6:	9a05      	ldr	r2, [sp, #20]
322024f8:	6e52      	ldr	r2, [r2, #100]	@ 0x64
322024fa:	07d0      	lsls	r0, r2, #31
322024fc:	f140 8086 	bpl.w	3220260c <_vfiprintf_r+0x3c8>
32202500:	065b      	lsls	r3, r3, #25
32202502:	f100 8128 	bmi.w	32202756 <_vfiprintf_r+0x512>
32202506:	9808      	ldr	r0, [sp, #32]
32202508:	b047      	add	sp, #284	@ 0x11c
3220250a:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220250e:	0591      	lsls	r1, r2, #22
32202510:	f140 810a 	bpl.w	32202728 <_vfiprintf_r+0x4e4>
32202514:	0497      	lsls	r7, r2, #18
32202516:	f57f aeb6 	bpl.w	32202286 <_vfiprintf_r+0x42>
3220251a:	049e      	lsls	r6, r3, #18
3220251c:	f57f aebb 	bpl.w	32202296 <_vfiprintf_r+0x52>
32202520:	e111      	b.n	32202746 <_vfiprintf_r+0x502>
32202522:	2b00      	cmp	r3, #0
32202524:	d0c3      	beq.n	322024ae <_vfiprintf_r+0x26a>
32202526:	ad2d      	add	r5, sp, #180	@ 0xb4
32202528:	2201      	movs	r2, #1
3220252a:	f88d 30b4 	strb.w	r3, [sp, #180]	@ 0xb4
3220252e:	2300      	movs	r3, #0
32202530:	920b      	str	r2, [sp, #44]	@ 0x2c
32202532:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32202536:	930a      	str	r3, [sp, #40]	@ 0x28
32202538:	9307      	str	r3, [sp, #28]
3220253a:	9206      	str	r2, [sp, #24]
3220253c:	e9dd 301b 	ldrd	r3, r0, [sp, #108]	@ 0x6c
32202540:	9c03      	ldr	r4, [sp, #12]
32202542:	4601      	mov	r1, r0
32202544:	461a      	mov	r2, r3
32202546:	f014 0684 	ands.w	r6, r4, #132	@ 0x84
3220254a:	d12a      	bne.n	322025a2 <_vfiprintf_r+0x35e>
3220254c:	9c09      	ldr	r4, [sp, #36]	@ 0x24
3220254e:	9e06      	ldr	r6, [sp, #24]
32202550:	1ba4      	subs	r4, r4, r6
32202552:	2c00      	cmp	r4, #0
32202554:	f300 8423 	bgt.w	32202d9e <_vfiprintf_r+0xb5a>
32202558:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
3220255c:	b323      	cbz	r3, 322025a8 <_vfiprintf_r+0x364>
3220255e:	2600      	movs	r6, #0
32202560:	960d      	str	r6, [sp, #52]	@ 0x34
32202562:	9804      	ldr	r0, [sp, #16]
32202564:	3201      	adds	r2, #1
32202566:	2301      	movs	r3, #1
32202568:	3101      	adds	r1, #1
3220256a:	2a07      	cmp	r2, #7
3220256c:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32202570:	6043      	str	r3, [r0, #4]
32202572:	f10d 034b 	add.w	r3, sp, #75	@ 0x4b
32202576:	6003      	str	r3, [r0, #0]
32202578:	f300 83a3 	bgt.w	32202cc2 <_vfiprintf_r+0xa7e>
3220257c:	3008      	adds	r0, #8
3220257e:	9004      	str	r0, [sp, #16]
32202580:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32202582:	b173      	cbz	r3, 322025a2 <_vfiprintf_r+0x35e>
32202584:	9804      	ldr	r0, [sp, #16]
32202586:	3201      	adds	r2, #1
32202588:	ab13      	add	r3, sp, #76	@ 0x4c
3220258a:	3102      	adds	r1, #2
3220258c:	2a07      	cmp	r2, #7
3220258e:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32202592:	6003      	str	r3, [r0, #0]
32202594:	f04f 0302 	mov.w	r3, #2
32202598:	6043      	str	r3, [r0, #4]
3220259a:	f300 8385 	bgt.w	32202ca8 <_vfiprintf_r+0xa64>
3220259e:	3008      	adds	r0, #8
322025a0:	9004      	str	r0, [sp, #16]
322025a2:	2e80      	cmp	r6, #128	@ 0x80
322025a4:	f000 82fb 	beq.w	32202b9e <_vfiprintf_r+0x95a>
322025a8:	9b07      	ldr	r3, [sp, #28]
322025aa:	980b      	ldr	r0, [sp, #44]	@ 0x2c
322025ac:	1a1c      	subs	r4, r3, r0
322025ae:	2c00      	cmp	r4, #0
322025b0:	f300 8335 	bgt.w	32202c1e <_vfiprintf_r+0x9da>
322025b4:	9b04      	ldr	r3, [sp, #16]
322025b6:	3201      	adds	r2, #1
322025b8:	980b      	ldr	r0, [sp, #44]	@ 0x2c
322025ba:	2a07      	cmp	r2, #7
322025bc:	4401      	add	r1, r0
322025be:	601d      	str	r5, [r3, #0]
322025c0:	6058      	str	r0, [r3, #4]
322025c2:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
322025c6:	f300 8364 	bgt.w	32202c92 <_vfiprintf_r+0xa4e>
322025ca:	3308      	adds	r3, #8
322025cc:	461f      	mov	r7, r3
322025ce:	9b03      	ldr	r3, [sp, #12]
322025d0:	075c      	lsls	r4, r3, #29
322025d2:	d505      	bpl.n	322025e0 <_vfiprintf_r+0x39c>
322025d4:	9b09      	ldr	r3, [sp, #36]	@ 0x24
322025d6:	9a06      	ldr	r2, [sp, #24]
322025d8:	1a9c      	subs	r4, r3, r2
322025da:	2c00      	cmp	r4, #0
322025dc:	f300 837e 	bgt.w	32202cdc <_vfiprintf_r+0xa98>
322025e0:	9b09      	ldr	r3, [sp, #36]	@ 0x24
322025e2:	9a06      	ldr	r2, [sp, #24]
322025e4:	4293      	cmp	r3, r2
322025e6:	bfb8      	it	lt
322025e8:	4613      	movlt	r3, r2
322025ea:	9a08      	ldr	r2, [sp, #32]
322025ec:	441a      	add	r2, r3
322025ee:	9208      	str	r2, [sp, #32]
322025f0:	2900      	cmp	r1, #0
322025f2:	f47f af6f 	bne.w	322024d4 <_vfiprintf_r+0x290>
322025f6:	2300      	movs	r3, #0
322025f8:	931b      	str	r3, [sp, #108]	@ 0x6c
322025fa:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322025fc:	b11b      	cbz	r3, 32202606 <_vfiprintf_r+0x3c2>
322025fe:	990a      	ldr	r1, [sp, #40]	@ 0x28
32202600:	4658      	mov	r0, fp
32202602:	f003 f971 	bl	322058e8 <_free_r>
32202606:	ab1d      	add	r3, sp, #116	@ 0x74
32202608:	9304      	str	r3, [sp, #16]
3220260a:	e666      	b.n	322022da <_vfiprintf_r+0x96>
3220260c:	059a      	lsls	r2, r3, #22
3220260e:	f53f af77 	bmi.w	32202500 <_vfiprintf_r+0x2bc>
32202612:	9c05      	ldr	r4, [sp, #20]
32202614:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32202616:	f002 fba7 	bl	32204d68 <__retarget_lock_release_recursive>
3220261a:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
3220261e:	e76f      	b.n	32202500 <_vfiprintf_r+0x2bc>
32202620:	9b03      	ldr	r3, [sp, #12]
32202622:	069e      	lsls	r6, r3, #26
32202624:	f140 8431 	bpl.w	32202e8a <_vfiprintf_r+0xc46>
32202628:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3220262a:	3307      	adds	r3, #7
3220262c:	f023 0307 	bic.w	r3, r3, #7
32202630:	461a      	mov	r2, r3
32202632:	685b      	ldr	r3, [r3, #4]
32202634:	f852 4b08 	ldr.w	r4, [r2], #8
32202638:	461e      	mov	r6, r3
3220263a:	920c      	str	r2, [sp, #48]	@ 0x30
3220263c:	2b00      	cmp	r3, #0
3220263e:	f2c0 81b3 	blt.w	322029a8 <_vfiprintf_r+0x764>
32202642:	9b07      	ldr	r3, [sp, #28]
32202644:	2b00      	cmp	r3, #0
32202646:	f2c0 80fd 	blt.w	32202844 <_vfiprintf_r+0x600>
3220264a:	9a03      	ldr	r2, [sp, #12]
3220264c:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
32202650:	9203      	str	r2, [sp, #12]
32202652:	1e1a      	subs	r2, r3, #0
32202654:	bf18      	it	ne
32202656:	2201      	movne	r2, #1
32202658:	ea54 0306 	orrs.w	r3, r4, r6
3220265c:	f042 0301 	orr.w	r3, r2, #1
32202660:	bf08      	it	eq
32202662:	4613      	moveq	r3, r2
32202664:	2b00      	cmp	r3, #0
32202666:	f040 80ed 	bne.w	32202844 <_vfiprintf_r+0x600>
3220266a:	f89d 204b 	ldrb.w	r2, [sp, #75]	@ 0x4b
3220266e:	2a00      	cmp	r2, #0
32202670:	f040 8598 	bne.w	322031a4 <_vfiprintf_r+0xf60>
32202674:	ad46      	add	r5, sp, #280	@ 0x118
32202676:	920a      	str	r2, [sp, #40]	@ 0x28
32202678:	9207      	str	r2, [sp, #28]
3220267a:	920b      	str	r2, [sp, #44]	@ 0x2c
3220267c:	9206      	str	r2, [sp, #24]
3220267e:	e75d      	b.n	3220253c <_vfiprintf_r+0x2f8>
32202680:	9e0c      	ldr	r6, [sp, #48]	@ 0x30
32202682:	2200      	movs	r2, #0
32202684:	f88d 204b 	strb.w	r2, [sp, #75]	@ 0x4b
32202688:	f856 2b04 	ldr.w	r2, [r6], #4
3220268c:	920a      	str	r2, [sp, #40]	@ 0x28
3220268e:	2a00      	cmp	r2, #0
32202690:	f000 858f 	beq.w	322031b2 <_vfiprintf_r+0xf6e>
32202694:	2b53      	cmp	r3, #83	@ 0x53
32202696:	f000 84c0 	beq.w	3220301a <_vfiprintf_r+0xdd6>
3220269a:	9b03      	ldr	r3, [sp, #12]
3220269c:	f013 0410 	ands.w	r4, r3, #16
322026a0:	f040 84bb 	bne.w	3220301a <_vfiprintf_r+0xdd6>
322026a4:	9a07      	ldr	r2, [sp, #28]
322026a6:	2a00      	cmp	r2, #0
322026a8:	f2c0 85fe 	blt.w	322032a8 <_vfiprintf_r+0x1064>
322026ac:	980a      	ldr	r0, [sp, #40]	@ 0x28
322026ae:	4621      	mov	r1, r4
322026b0:	f002 fd3e 	bl	32205130 <memchr>
322026b4:	f89d 204b 	ldrb.w	r2, [sp, #75]	@ 0x4b
322026b8:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
322026ba:	2800      	cmp	r0, #0
322026bc:	f000 8690 	beq.w	322033e0 <_vfiprintf_r+0x119c>
322026c0:	1b43      	subs	r3, r0, r5
322026c2:	930b      	str	r3, [sp, #44]	@ 0x2c
322026c4:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
322026c8:	9306      	str	r3, [sp, #24]
322026ca:	2a00      	cmp	r2, #0
322026cc:	f000 8682 	beq.w	322033d4 <_vfiprintf_r+0x1190>
322026d0:	3301      	adds	r3, #1
322026d2:	9407      	str	r4, [sp, #28]
322026d4:	9306      	str	r3, [sp, #24]
322026d6:	960c      	str	r6, [sp, #48]	@ 0x30
322026d8:	940a      	str	r4, [sp, #40]	@ 0x28
322026da:	e3bf      	b.n	32202e5c <_vfiprintf_r+0xc18>
322026dc:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
322026de:	2b43      	cmp	r3, #67	@ 0x43
322026e0:	f102 0404 	add.w	r4, r2, #4
322026e4:	d003      	beq.n	322026ee <_vfiprintf_r+0x4aa>
322026e6:	9b03      	ldr	r3, [sp, #12]
322026e8:	06db      	lsls	r3, r3, #27
322026ea:	f140 8478 	bpl.w	32202fde <_vfiprintf_r+0xd9a>
322026ee:	2208      	movs	r2, #8
322026f0:	2100      	movs	r1, #0
322026f2:	a818      	add	r0, sp, #96	@ 0x60
322026f4:	ad2d      	add	r5, sp, #180	@ 0xb4
322026f6:	f001 fd37 	bl	32204168 <memset>
322026fa:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
322026fc:	4629      	mov	r1, r5
322026fe:	4658      	mov	r0, fp
32202700:	681a      	ldr	r2, [r3, #0]
32202702:	ab18      	add	r3, sp, #96	@ 0x60
32202704:	f004 fbc4 	bl	32206e90 <_wcrtomb_r>
32202708:	4603      	mov	r3, r0
3220270a:	3301      	adds	r3, #1
3220270c:	900b      	str	r0, [sp, #44]	@ 0x2c
3220270e:	f000 864c 	beq.w	322033aa <_vfiprintf_r+0x1166>
32202712:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32202714:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
32202718:	9306      	str	r3, [sp, #24]
3220271a:	2300      	movs	r3, #0
3220271c:	940c      	str	r4, [sp, #48]	@ 0x30
3220271e:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32202722:	930a      	str	r3, [sp, #40]	@ 0x28
32202724:	9307      	str	r3, [sp, #28]
32202726:	e709      	b.n	3220253c <_vfiprintf_r+0x2f8>
32202728:	9e05      	ldr	r6, [sp, #20]
3220272a:	6db0      	ldr	r0, [r6, #88]	@ 0x58
3220272c:	f002 fb14 	bl	32204d58 <__retarget_lock_acquire_recursive>
32202730:	f9b6 200c 	ldrsh.w	r2, [r6, #12]
32202734:	6e73      	ldr	r3, [r6, #100]	@ 0x64
32202736:	0490      	lsls	r0, r2, #18
32202738:	f57f ada5 	bpl.w	32202286 <_vfiprintf_r+0x42>
3220273c:	0499      	lsls	r1, r3, #18
3220273e:	f57f adaa 	bpl.w	32202296 <_vfiprintf_r+0x52>
32202742:	07db      	lsls	r3, r3, #31
32202744:	d407      	bmi.n	32202756 <_vfiprintf_r+0x512>
32202746:	9b05      	ldr	r3, [sp, #20]
32202748:	899b      	ldrh	r3, [r3, #12]
3220274a:	059f      	lsls	r7, r3, #22
3220274c:	d403      	bmi.n	32202756 <_vfiprintf_r+0x512>
3220274e:	9b05      	ldr	r3, [sp, #20]
32202750:	6d98      	ldr	r0, [r3, #88]	@ 0x58
32202752:	f002 fb09 	bl	32204d68 <__retarget_lock_release_recursive>
32202756:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
3220275a:	9308      	str	r3, [sp, #32]
3220275c:	e6d3      	b.n	32202506 <_vfiprintf_r+0x2c2>
3220275e:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202760:	f853 2b04 	ldr.w	r2, [r3], #4
32202764:	9209      	str	r2, [sp, #36]	@ 0x24
32202766:	2a00      	cmp	r2, #0
32202768:	f280 836b 	bge.w	32202e42 <_vfiprintf_r+0xbfe>
3220276c:	9a09      	ldr	r2, [sp, #36]	@ 0x24
3220276e:	930c      	str	r3, [sp, #48]	@ 0x30
32202770:	4252      	negs	r2, r2
32202772:	9209      	str	r2, [sp, #36]	@ 0x24
32202774:	9b03      	ldr	r3, [sp, #12]
32202776:	f043 0304 	orr.w	r3, r3, #4
3220277a:	9303      	str	r3, [sp, #12]
3220277c:	f898 3000 	ldrb.w	r3, [r8]
32202780:	e5d3      	b.n	3220232a <_vfiprintf_r+0xe6>
32202782:	232b      	movs	r3, #43	@ 0x2b
32202784:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32202788:	f898 3000 	ldrb.w	r3, [r8]
3220278c:	e5cd      	b.n	3220232a <_vfiprintf_r+0xe6>
3220278e:	9b03      	ldr	r3, [sp, #12]
32202790:	f043 0010 	orr.w	r0, r3, #16
32202794:	069d      	lsls	r5, r3, #26
32202796:	f140 8397 	bpl.w	32202ec8 <_vfiprintf_r+0xc84>
3220279a:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3220279c:	3307      	adds	r3, #7
3220279e:	f023 0307 	bic.w	r3, r3, #7
322027a2:	6859      	ldr	r1, [r3, #4]
322027a4:	f853 2b08 	ldr.w	r2, [r3], #8
322027a8:	930c      	str	r3, [sp, #48]	@ 0x30
322027aa:	2300      	movs	r3, #0
322027ac:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
322027b0:	9b07      	ldr	r3, [sp, #28]
322027b2:	2b00      	cmp	r3, #0
322027b4:	f2c0 82ce 	blt.w	32202d54 <_vfiprintf_r+0xb10>
322027b8:	9b07      	ldr	r3, [sp, #28]
322027ba:	1e1c      	subs	r4, r3, #0
322027bc:	bf18      	it	ne
322027be:	2401      	movne	r4, #1
322027c0:	ea52 0301 	orrs.w	r3, r2, r1
322027c4:	f044 0301 	orr.w	r3, r4, #1
322027c8:	bf08      	it	eq
322027ca:	4623      	moveq	r3, r4
322027cc:	f420 6490 	bic.w	r4, r0, #1152	@ 0x480
322027d0:	9403      	str	r4, [sp, #12]
322027d2:	2b00      	cmp	r3, #0
322027d4:	f040 82c1 	bne.w	32202d5a <_vfiprintf_r+0xb16>
322027d8:	f010 0201 	ands.w	r2, r0, #1
322027dc:	9206      	str	r2, [sp, #24]
322027de:	f000 8329 	beq.w	32202e34 <_vfiprintf_r+0xbf0>
322027e2:	4619      	mov	r1, r3
322027e4:	9307      	str	r3, [sp, #28]
322027e6:	f20d 1517 	addw	r5, sp, #279	@ 0x117
322027ea:	2330      	movs	r3, #48	@ 0x30
322027ec:	920b      	str	r2, [sp, #44]	@ 0x2c
322027ee:	f88d 3117 	strb.w	r3, [sp, #279]	@ 0x117
322027f2:	910a      	str	r1, [sp, #40]	@ 0x28
322027f4:	e6a2      	b.n	3220253c <_vfiprintf_r+0x2f8>
322027f6:	9a03      	ldr	r2, [sp, #12]
322027f8:	0696      	lsls	r6, r2, #26
322027fa:	d441      	bmi.n	32202880 <_vfiprintf_r+0x63c>
322027fc:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
322027fe:	9a03      	ldr	r2, [sp, #12]
32202800:	f853 4b04 	ldr.w	r4, [r3], #4
32202804:	f012 0210 	ands.w	r2, r2, #16
32202808:	9206      	str	r2, [sp, #24]
3220280a:	9a03      	ldr	r2, [sp, #12]
3220280c:	f040 8350 	bne.w	32202eb0 <_vfiprintf_r+0xc6c>
32202810:	f012 0240 	ands.w	r2, r2, #64	@ 0x40
32202814:	f000 84e5 	beq.w	322031e2 <_vfiprintf_r+0xf9e>
32202818:	9a07      	ldr	r2, [sp, #28]
3220281a:	b2a4      	uxth	r4, r4
3220281c:	9e06      	ldr	r6, [sp, #24]
3220281e:	2a00      	cmp	r2, #0
32202820:	f88d 604b 	strb.w	r6, [sp, #75]	@ 0x4b
32202824:	db0d      	blt.n	32202842 <_vfiprintf_r+0x5fe>
32202826:	9a03      	ldr	r2, [sp, #12]
32202828:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
3220282c:	9203      	str	r2, [sp, #12]
3220282e:	9a07      	ldr	r2, [sp, #28]
32202830:	2c00      	cmp	r4, #0
32202832:	bf08      	it	eq
32202834:	2a00      	cmpeq	r2, #0
32202836:	bf18      	it	ne
32202838:	2201      	movne	r2, #1
3220283a:	bf08      	it	eq
3220283c:	2200      	moveq	r2, #0
3220283e:	f000 8526 	beq.w	3220328e <_vfiprintf_r+0x104a>
32202842:	930c      	str	r3, [sp, #48]	@ 0x30
32202844:	2c0a      	cmp	r4, #10
32202846:	f176 0300 	sbcs.w	r3, r6, #0
3220284a:	f080 80c1 	bcs.w	322029d0 <_vfiprintf_r+0x78c>
3220284e:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
32202852:	3430      	adds	r4, #48	@ 0x30
32202854:	9a07      	ldr	r2, [sp, #28]
32202856:	f88d 4117 	strb.w	r4, [sp, #279]	@ 0x117
3220285a:	2a01      	cmp	r2, #1
3220285c:	bfb8      	it	lt
3220285e:	2201      	movlt	r2, #1
32202860:	9206      	str	r2, [sp, #24]
32202862:	2b00      	cmp	r3, #0
32202864:	f040 82f2 	bne.w	32202e4c <_vfiprintf_r+0xc08>
32202868:	930a      	str	r3, [sp, #40]	@ 0x28
3220286a:	f20d 1517 	addw	r5, sp, #279	@ 0x117
3220286e:	2301      	movs	r3, #1
32202870:	930b      	str	r3, [sp, #44]	@ 0x2c
32202872:	e663      	b.n	3220253c <_vfiprintf_r+0x2f8>
32202874:	9b03      	ldr	r3, [sp, #12]
32202876:	f043 0210 	orr.w	r2, r3, #16
3220287a:	069f      	lsls	r7, r3, #26
3220287c:	f140 8316 	bpl.w	32202eac <_vfiprintf_r+0xc68>
32202880:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202882:	2100      	movs	r1, #0
32202884:	f88d 104b 	strb.w	r1, [sp, #75]	@ 0x4b
32202888:	3307      	adds	r3, #7
3220288a:	f023 0307 	bic.w	r3, r3, #7
3220288e:	685e      	ldr	r6, [r3, #4]
32202890:	f853 4b08 	ldr.w	r4, [r3], #8
32202894:	930c      	str	r3, [sp, #48]	@ 0x30
32202896:	9b07      	ldr	r3, [sp, #28]
32202898:	428b      	cmp	r3, r1
3220289a:	f2c0 8313 	blt.w	32202ec4 <_vfiprintf_r+0xc80>
3220289e:	f022 0380 	bic.w	r3, r2, #128	@ 0x80
322028a2:	9303      	str	r3, [sp, #12]
322028a4:	9b07      	ldr	r3, [sp, #28]
322028a6:	1e1a      	subs	r2, r3, #0
322028a8:	bf18      	it	ne
322028aa:	2201      	movne	r2, #1
322028ac:	ea54 0306 	orrs.w	r3, r4, r6
322028b0:	f042 0301 	orr.w	r3, r2, #1
322028b4:	bf08      	it	eq
322028b6:	4613      	moveq	r3, r2
322028b8:	2b00      	cmp	r3, #0
322028ba:	d1c3      	bne.n	32202844 <_vfiprintf_r+0x600>
322028bc:	ad46      	add	r5, sp, #280	@ 0x118
322028be:	930a      	str	r3, [sp, #40]	@ 0x28
322028c0:	9307      	str	r3, [sp, #28]
322028c2:	930b      	str	r3, [sp, #44]	@ 0x2c
322028c4:	9306      	str	r3, [sp, #24]
322028c6:	e639      	b.n	3220253c <_vfiprintf_r+0x2f8>
322028c8:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
322028ca:	2100      	movs	r1, #0
322028cc:	9807      	ldr	r0, [sp, #28]
322028ce:	f647 0230 	movw	r2, #30768	@ 0x7830
322028d2:	f88d 104b 	strb.w	r1, [sp, #75]	@ 0x4b
322028d6:	f8ad 204c 	strh.w	r2, [sp, #76]	@ 0x4c
322028da:	4288      	cmp	r0, r1
322028dc:	f853 2b04 	ldr.w	r2, [r3], #4
322028e0:	f2c0 835a 	blt.w	32202f98 <_vfiprintf_r+0xd54>
322028e4:	9803      	ldr	r0, [sp, #12]
322028e6:	f020 0080 	bic.w	r0, r0, #128	@ 0x80
322028ea:	f040 0002 	orr.w	r0, r0, #2
322028ee:	9003      	str	r0, [sp, #12]
322028f0:	9807      	ldr	r0, [sp, #28]
322028f2:	2a00      	cmp	r2, #0
322028f4:	bf08      	it	eq
322028f6:	2800      	cmpeq	r0, #0
322028f8:	bf18      	it	ne
322028fa:	2001      	movne	r0, #1
322028fc:	bf08      	it	eq
322028fe:	2000      	moveq	r0, #0
32202900:	f040 8599 	bne.w	32203436 <_vfiprintf_r+0x11f2>
32202904:	ad46      	add	r5, sp, #280	@ 0x118
32202906:	9007      	str	r0, [sp, #28]
32202908:	930c      	str	r3, [sp, #48]	@ 0x30
3220290a:	9006      	str	r0, [sp, #24]
3220290c:	900b      	str	r0, [sp, #44]	@ 0x2c
3220290e:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32202912:	9b06      	ldr	r3, [sp, #24]
32202914:	9c03      	ldr	r4, [sp, #12]
32202916:	4608      	mov	r0, r1
32202918:	3302      	adds	r3, #2
3220291a:	9306      	str	r3, [sp, #24]
3220291c:	f014 0684 	ands.w	r6, r4, #132	@ 0x84
32202920:	4613      	mov	r3, r2
32202922:	f000 83cc 	beq.w	322030be <_vfiprintf_r+0xe7a>
32202926:	2300      	movs	r3, #0
32202928:	930a      	str	r3, [sp, #40]	@ 0x28
3220292a:	e62b      	b.n	32202584 <_vfiprintf_r+0x340>
3220292c:	9803      	ldr	r0, [sp, #12]
3220292e:	0684      	lsls	r4, r0, #26
32202930:	f53f af33 	bmi.w	3220279a <_vfiprintf_r+0x556>
32202934:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202936:	9903      	ldr	r1, [sp, #12]
32202938:	f853 2b04 	ldr.w	r2, [r3], #4
3220293c:	f011 0110 	ands.w	r1, r1, #16
32202940:	f040 8582 	bne.w	32203448 <_vfiprintf_r+0x1204>
32202944:	9c03      	ldr	r4, [sp, #12]
32202946:	f014 0040 	ands.w	r0, r4, #64	@ 0x40
3220294a:	f000 8440 	beq.w	322031ce <_vfiprintf_r+0xf8a>
3220294e:	b292      	uxth	r2, r2
32202950:	4620      	mov	r0, r4
32202952:	930c      	str	r3, [sp, #48]	@ 0x30
32202954:	e729      	b.n	322027aa <_vfiprintf_r+0x566>
32202956:	9b03      	ldr	r3, [sp, #12]
32202958:	069a      	lsls	r2, r3, #26
3220295a:	f140 82bc 	bpl.w	32202ed6 <_vfiprintf_r+0xc92>
3220295e:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202960:	9a08      	ldr	r2, [sp, #32]
32202962:	681b      	ldr	r3, [r3, #0]
32202964:	601a      	str	r2, [r3, #0]
32202966:	17d2      	asrs	r2, r2, #31
32202968:	605a      	str	r2, [r3, #4]
3220296a:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3220296c:	3304      	adds	r3, #4
3220296e:	930c      	str	r3, [sp, #48]	@ 0x30
32202970:	e4b3      	b.n	322022da <_vfiprintf_r+0x96>
32202972:	f898 3000 	ldrb.w	r3, [r8]
32202976:	2b6c      	cmp	r3, #108	@ 0x6c
32202978:	f000 8345 	beq.w	32203006 <_vfiprintf_r+0xdc2>
3220297c:	9a03      	ldr	r2, [sp, #12]
3220297e:	f042 0210 	orr.w	r2, r2, #16
32202982:	9203      	str	r2, [sp, #12]
32202984:	e4d1      	b.n	3220232a <_vfiprintf_r+0xe6>
32202986:	9b03      	ldr	r3, [sp, #12]
32202988:	f043 0210 	orr.w	r2, r3, #16
3220298c:	069f      	lsls	r7, r3, #26
3220298e:	f100 82b3 	bmi.w	32202ef8 <_vfiprintf_r+0xcb4>
32202992:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202994:	3304      	adds	r3, #4
32202996:	990c      	ldr	r1, [sp, #48]	@ 0x30
32202998:	930c      	str	r3, [sp, #48]	@ 0x30
3220299a:	9203      	str	r2, [sp, #12]
3220299c:	680c      	ldr	r4, [r1, #0]
3220299e:	17e6      	asrs	r6, r4, #31
322029a0:	4633      	mov	r3, r6
322029a2:	2b00      	cmp	r3, #0
322029a4:	f6bf ae4d 	bge.w	32202642 <_vfiprintf_r+0x3fe>
322029a8:	4264      	negs	r4, r4
322029aa:	f04f 032d 	mov.w	r3, #45	@ 0x2d
322029ae:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
322029b2:	9b07      	ldr	r3, [sp, #28]
322029b4:	eb66 0646 	sbc.w	r6, r6, r6, lsl #1
322029b8:	2b00      	cmp	r3, #0
322029ba:	f6ff af43 	blt.w	32202844 <_vfiprintf_r+0x600>
322029be:	9b03      	ldr	r3, [sp, #12]
322029c0:	2c0a      	cmp	r4, #10
322029c2:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
322029c6:	9303      	str	r3, [sp, #12]
322029c8:	f176 0300 	sbcs.w	r3, r6, #0
322029cc:	f4ff af3f 	bcc.w	3220284e <_vfiprintf_r+0x60a>
322029d0:	9b03      	ldr	r3, [sp, #12]
322029d2:	f64c 4ecd 	movw	lr, #52429	@ 0xcccd
322029d6:	f6cc 4ecc 	movt	lr, #52428	@ 0xcccc
322029da:	f8cd 902c 	str.w	r9, [sp, #44]	@ 0x2c
322029de:	f403 6580 	and.w	r5, r3, #1024	@ 0x400
322029e2:	2300      	movs	r3, #0
322029e4:	4677      	mov	r7, lr
322029e6:	f8dd 903c 	ldr.w	r9, [sp, #60]	@ 0x3c
322029ea:	a946      	add	r1, sp, #280	@ 0x118
322029ec:	469e      	mov	lr, r3
322029ee:	f8cd b018 	str.w	fp, [sp, #24]
322029f2:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
322029f6:	e023      	b.n	32202a40 <_vfiprintf_r+0x7fc>
322029f8:	19a3      	adds	r3, r4, r6
322029fa:	4630      	mov	r0, r6
322029fc:	f143 0300 	adc.w	r3, r3, #0
32202a00:	46a3      	mov	fp, r4
32202a02:	4641      	mov	r1, r8
32202a04:	fba7 2c03 	umull	r2, ip, r7, r3
32202a08:	f02c 0203 	bic.w	r2, ip, #3
32202a0c:	eb02 029c 	add.w	r2, r2, ip, lsr #2
32202a10:	1a9b      	subs	r3, r3, r2
32202a12:	f04f 32cc 	mov.w	r2, #3435973836	@ 0xcccccccc
32202a16:	1ae3      	subs	r3, r4, r3
32202a18:	f166 0600 	sbc.w	r6, r6, #0
32202a1c:	f1bb 0f0a 	cmp.w	fp, #10
32202a20:	f170 0000 	sbcs.w	r0, r0, #0
32202a24:	fb02 f203 	mul.w	r2, r2, r3
32202a28:	fb07 2206 	mla	r2, r7, r6, r2
32202a2c:	fba3 4307 	umull	r4, r3, r3, r7
32202a30:	4413      	add	r3, r2
32202a32:	ea4f 0454 	mov.w	r4, r4, lsr #1
32202a36:	ea44 74c3 	orr.w	r4, r4, r3, lsl #31
32202a3a:	ea4f 0653 	mov.w	r6, r3, lsr #1
32202a3e:	d332      	bcc.n	32202aa6 <_vfiprintf_r+0x862>
32202a40:	19a3      	adds	r3, r4, r6
32202a42:	f10e 0e01 	add.w	lr, lr, #1
32202a46:	f143 0300 	adc.w	r3, r3, #0
32202a4a:	f101 38ff 	add.w	r8, r1, #4294967295	@ 0xffffffff
32202a4e:	fba7 2003 	umull	r2, r0, r7, r3
32202a52:	f020 0203 	bic.w	r2, r0, #3
32202a56:	eb02 0290 	add.w	r2, r2, r0, lsr #2
32202a5a:	1a9b      	subs	r3, r3, r2
32202a5c:	1ae3      	subs	r3, r4, r3
32202a5e:	f166 0000 	sbc.w	r0, r6, #0
32202a62:	fba3 3207 	umull	r3, r2, r3, r7
32202a66:	085b      	lsrs	r3, r3, #1
32202a68:	fb07 2200 	mla	r2, r7, r0, r2
32202a6c:	ea43 73c2 	orr.w	r3, r3, r2, lsl #31
32202a70:	eb03 0383 	add.w	r3, r3, r3, lsl #2
32202a74:	eba4 0343 	sub.w	r3, r4, r3, lsl #1
32202a78:	3330      	adds	r3, #48	@ 0x30
32202a7a:	f801 3c01 	strb.w	r3, [r1, #-1]
32202a7e:	2d00      	cmp	r5, #0
32202a80:	d0ba      	beq.n	322029f8 <_vfiprintf_r+0x7b4>
32202a82:	f899 3000 	ldrb.w	r3, [r9]
32202a86:	eba3 020e 	sub.w	r2, r3, lr
32202a8a:	2bff      	cmp	r3, #255	@ 0xff
32202a8c:	fab2 f282 	clz	r2, r2
32202a90:	ea4f 1252 	mov.w	r2, r2, lsr #5
32202a94:	bf08      	it	eq
32202a96:	2200      	moveq	r2, #0
32202a98:	2a00      	cmp	r2, #0
32202a9a:	d0ad      	beq.n	322029f8 <_vfiprintf_r+0x7b4>
32202a9c:	2c0a      	cmp	r4, #10
32202a9e:	f176 0300 	sbcs.w	r3, r6, #0
32202aa2:	f080 841d 	bcs.w	322032e0 <_vfiprintf_r+0x109c>
32202aa6:	4645      	mov	r5, r8
32202aa8:	ab46      	add	r3, sp, #280	@ 0x118
32202aaa:	1b5b      	subs	r3, r3, r5
32202aac:	f8cd 903c 	str.w	r9, [sp, #60]	@ 0x3c
32202ab0:	461a      	mov	r2, r3
32202ab2:	9907      	ldr	r1, [sp, #28]
32202ab4:	e9dd 890a 	ldrd	r8, r9, [sp, #40]	@ 0x28
32202ab8:	930b      	str	r3, [sp, #44]	@ 0x2c
32202aba:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
32202abe:	4291      	cmp	r1, r2
32202ac0:	f8dd b018 	ldr.w	fp, [sp, #24]
32202ac4:	bfb8      	it	lt
32202ac6:	4611      	movlt	r1, r2
32202ac8:	9106      	str	r1, [sp, #24]
32202aca:	2b00      	cmp	r3, #0
32202acc:	f000 824c 	beq.w	32202f68 <_vfiprintf_r+0xd24>
32202ad0:	9b06      	ldr	r3, [sp, #24]
32202ad2:	3301      	adds	r3, #1
32202ad4:	9306      	str	r3, [sp, #24]
32202ad6:	e247      	b.n	32202f68 <_vfiprintf_r+0xd24>
32202ad8:	f898 3000 	ldrb.w	r3, [r8]
32202adc:	2b68      	cmp	r3, #104	@ 0x68
32202ade:	f000 8288 	beq.w	32202ff2 <_vfiprintf_r+0xdae>
32202ae2:	9a03      	ldr	r2, [sp, #12]
32202ae4:	f042 0240 	orr.w	r2, r2, #64	@ 0x40
32202ae8:	9203      	str	r2, [sp, #12]
32202aea:	e41e      	b.n	3220232a <_vfiprintf_r+0xe6>
32202aec:	4658      	mov	r0, fp
32202aee:	f002 f887 	bl	32204c00 <_localeconv_r>
32202af2:	6843      	ldr	r3, [r0, #4]
32202af4:	9311      	str	r3, [sp, #68]	@ 0x44
32202af6:	4618      	mov	r0, r3
32202af8:	f002 fe22 	bl	32205740 <strlen>
32202afc:	4604      	mov	r4, r0
32202afe:	9010      	str	r0, [sp, #64]	@ 0x40
32202b00:	4658      	mov	r0, fp
32202b02:	f002 f87d 	bl	32204c00 <_localeconv_r>
32202b06:	6882      	ldr	r2, [r0, #8]
32202b08:	f898 3000 	ldrb.w	r3, [r8]
32202b0c:	2c00      	cmp	r4, #0
32202b0e:	bf18      	it	ne
32202b10:	2a00      	cmpne	r2, #0
32202b12:	920f      	str	r2, [sp, #60]	@ 0x3c
32202b14:	f43f ac09 	beq.w	3220232a <_vfiprintf_r+0xe6>
32202b18:	7812      	ldrb	r2, [r2, #0]
32202b1a:	2a00      	cmp	r2, #0
32202b1c:	f43f ac05 	beq.w	3220232a <_vfiprintf_r+0xe6>
32202b20:	9a03      	ldr	r2, [sp, #12]
32202b22:	f442 6280 	orr.w	r2, r2, #1024	@ 0x400
32202b26:	9203      	str	r2, [sp, #12]
32202b28:	f7ff bbff 	b.w	3220232a <_vfiprintf_r+0xe6>
32202b2c:	9b03      	ldr	r3, [sp, #12]
32202b2e:	f043 0301 	orr.w	r3, r3, #1
32202b32:	9303      	str	r3, [sp, #12]
32202b34:	f898 3000 	ldrb.w	r3, [r8]
32202b38:	f7ff bbf7 	b.w	3220232a <_vfiprintf_r+0xe6>
32202b3c:	f89d 204b 	ldrb.w	r2, [sp, #75]	@ 0x4b
32202b40:	f898 3000 	ldrb.w	r3, [r8]
32202b44:	2a00      	cmp	r2, #0
32202b46:	f47f abf0 	bne.w	3220232a <_vfiprintf_r+0xe6>
32202b4a:	2220      	movs	r2, #32
32202b4c:	f88d 204b 	strb.w	r2, [sp, #75]	@ 0x4b
32202b50:	f7ff bbeb 	b.w	3220232a <_vfiprintf_r+0xe6>
32202b54:	9b03      	ldr	r3, [sp, #12]
32202b56:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
32202b5a:	9303      	str	r3, [sp, #12]
32202b5c:	f898 3000 	ldrb.w	r3, [r8]
32202b60:	f7ff bbe3 	b.w	3220232a <_vfiprintf_r+0xe6>
32202b64:	4641      	mov	r1, r8
32202b66:	f811 3b01 	ldrb.w	r3, [r1], #1
32202b6a:	2b2a      	cmp	r3, #42	@ 0x2a
32202b6c:	f000 8449 	beq.w	32203402 <_vfiprintf_r+0x11be>
32202b70:	f1a3 0230 	sub.w	r2, r3, #48	@ 0x30
32202b74:	2a09      	cmp	r2, #9
32202b76:	bf98      	it	ls
32202b78:	2000      	movls	r0, #0
32202b7a:	bf98      	it	ls
32202b7c:	240a      	movls	r4, #10
32202b7e:	f200 83fd 	bhi.w	3220337c <_vfiprintf_r+0x1138>
32202b82:	f811 3b01 	ldrb.w	r3, [r1], #1
32202b86:	fb04 2000 	mla	r0, r4, r0, r2
32202b8a:	f1a3 0230 	sub.w	r2, r3, #48	@ 0x30
32202b8e:	2a09      	cmp	r2, #9
32202b90:	d9f7      	bls.n	32202b82 <_vfiprintf_r+0x93e>
32202b92:	ea40 72e0 	orr.w	r2, r0, r0, asr #31
32202b96:	4688      	mov	r8, r1
32202b98:	9207      	str	r2, [sp, #28]
32202b9a:	f7ff bbc8 	b.w	3220232e <_vfiprintf_r+0xea>
32202b9e:	9b09      	ldr	r3, [sp, #36]	@ 0x24
32202ba0:	9806      	ldr	r0, [sp, #24]
32202ba2:	1a1c      	subs	r4, r3, r0
32202ba4:	2c00      	cmp	r4, #0
32202ba6:	f77f acff 	ble.w	322025a8 <_vfiprintf_r+0x364>
32202baa:	f64b 4798 	movw	r7, #48280	@ 0xbc98
32202bae:	f2c3 2720 	movt	r7, #12832	@ 0x3220
32202bb2:	2c10      	cmp	r4, #16
32202bb4:	dd21      	ble.n	32202bfa <_vfiprintf_r+0x9b6>
32202bb6:	950d      	str	r5, [sp, #52]	@ 0x34
32202bb8:	2610      	movs	r6, #16
32202bba:	9804      	ldr	r0, [sp, #16]
32202bbc:	9d05      	ldr	r5, [sp, #20]
32202bbe:	e002      	b.n	32202bc6 <_vfiprintf_r+0x982>
32202bc0:	3c10      	subs	r4, #16
32202bc2:	2c10      	cmp	r4, #16
32202bc4:	dd17      	ble.n	32202bf6 <_vfiprintf_r+0x9b2>
32202bc6:	3201      	adds	r2, #1
32202bc8:	3110      	adds	r1, #16
32202bca:	2a07      	cmp	r2, #7
32202bcc:	e9c0 7600 	strd	r7, r6, [r0]
32202bd0:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32202bd4:	bfd8      	it	le
32202bd6:	3008      	addle	r0, #8
32202bd8:	ddf2      	ble.n	32202bc0 <_vfiprintf_r+0x97c>
32202bda:	aa1a      	add	r2, sp, #104	@ 0x68
32202bdc:	4629      	mov	r1, r5
32202bde:	4658      	mov	r0, fp
32202be0:	f000 fc9a 	bl	32203518 <__sprint_r>
32202be4:	2800      	cmp	r0, #0
32202be6:	f47f ac7d 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202bea:	3c10      	subs	r4, #16
32202bec:	a81d      	add	r0, sp, #116	@ 0x74
32202bee:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32202bf2:	2c10      	cmp	r4, #16
32202bf4:	dce7      	bgt.n	32202bc6 <_vfiprintf_r+0x982>
32202bf6:	9d0d      	ldr	r5, [sp, #52]	@ 0x34
32202bf8:	9004      	str	r0, [sp, #16]
32202bfa:	9b04      	ldr	r3, [sp, #16]
32202bfc:	3201      	adds	r2, #1
32202bfe:	4421      	add	r1, r4
32202c00:	2a07      	cmp	r2, #7
32202c02:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32202c06:	601f      	str	r7, [r3, #0]
32202c08:	605c      	str	r4, [r3, #4]
32202c0a:	f300 828f 	bgt.w	3220312c <_vfiprintf_r+0xee8>
32202c0e:	3308      	adds	r3, #8
32202c10:	980b      	ldr	r0, [sp, #44]	@ 0x2c
32202c12:	9304      	str	r3, [sp, #16]
32202c14:	9b07      	ldr	r3, [sp, #28]
32202c16:	1a1c      	subs	r4, r3, r0
32202c18:	2c00      	cmp	r4, #0
32202c1a:	f77f accb 	ble.w	322025b4 <_vfiprintf_r+0x370>
32202c1e:	f64b 4798 	movw	r7, #48280	@ 0xbc98
32202c22:	f2c3 2720 	movt	r7, #12832	@ 0x3220
32202c26:	2c10      	cmp	r4, #16
32202c28:	dd26      	ble.n	32202c78 <_vfiprintf_r+0xa34>
32202c2a:	9b0e      	ldr	r3, [sp, #56]	@ 0x38
32202c2c:	2610      	movs	r6, #16
32202c2e:	9507      	str	r5, [sp, #28]
32202c30:	f8dd c010 	ldr.w	ip, [sp, #16]
32202c34:	461f      	mov	r7, r3
32202c36:	461d      	mov	r5, r3
32202c38:	e002      	b.n	32202c40 <_vfiprintf_r+0x9fc>
32202c3a:	3c10      	subs	r4, #16
32202c3c:	2c10      	cmp	r4, #16
32202c3e:	dd18      	ble.n	32202c72 <_vfiprintf_r+0xa2e>
32202c40:	3201      	adds	r2, #1
32202c42:	3110      	adds	r1, #16
32202c44:	e9cc 5600 	strd	r5, r6, [ip]
32202c48:	2a07      	cmp	r2, #7
32202c4a:	f10c 0c08 	add.w	ip, ip, #8
32202c4e:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32202c52:	ddf2      	ble.n	32202c3a <_vfiprintf_r+0x9f6>
32202c54:	9905      	ldr	r1, [sp, #20]
32202c56:	aa1a      	add	r2, sp, #104	@ 0x68
32202c58:	4658      	mov	r0, fp
32202c5a:	f000 fc5d 	bl	32203518 <__sprint_r>
32202c5e:	f10d 0c74 	add.w	ip, sp, #116	@ 0x74
32202c62:	2800      	cmp	r0, #0
32202c64:	f47f ac3e 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202c68:	3c10      	subs	r4, #16
32202c6a:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32202c6e:	2c10      	cmp	r4, #16
32202c70:	dce6      	bgt.n	32202c40 <_vfiprintf_r+0x9fc>
32202c72:	9d07      	ldr	r5, [sp, #28]
32202c74:	f8cd c010 	str.w	ip, [sp, #16]
32202c78:	9b04      	ldr	r3, [sp, #16]
32202c7a:	3201      	adds	r2, #1
32202c7c:	4421      	add	r1, r4
32202c7e:	2a07      	cmp	r2, #7
32202c80:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32202c84:	601f      	str	r7, [r3, #0]
32202c86:	605c      	str	r4, [r3, #4]
32202c88:	f300 80c6 	bgt.w	32202e18 <_vfiprintf_r+0xbd4>
32202c8c:	3308      	adds	r3, #8
32202c8e:	9304      	str	r3, [sp, #16]
32202c90:	e490      	b.n	322025b4 <_vfiprintf_r+0x370>
32202c92:	9905      	ldr	r1, [sp, #20]
32202c94:	aa1a      	add	r2, sp, #104	@ 0x68
32202c96:	4658      	mov	r0, fp
32202c98:	f000 fc3e 	bl	32203518 <__sprint_r>
32202c9c:	2800      	cmp	r0, #0
32202c9e:	f47f ac21 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202ca2:	991c      	ldr	r1, [sp, #112]	@ 0x70
32202ca4:	af1d      	add	r7, sp, #116	@ 0x74
32202ca6:	e492      	b.n	322025ce <_vfiprintf_r+0x38a>
32202ca8:	9905      	ldr	r1, [sp, #20]
32202caa:	aa1a      	add	r2, sp, #104	@ 0x68
32202cac:	4658      	mov	r0, fp
32202cae:	f000 fc33 	bl	32203518 <__sprint_r>
32202cb2:	2800      	cmp	r0, #0
32202cb4:	f47f ac16 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202cb8:	ab1d      	add	r3, sp, #116	@ 0x74
32202cba:	9304      	str	r3, [sp, #16]
32202cbc:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32202cc0:	e46f      	b.n	322025a2 <_vfiprintf_r+0x35e>
32202cc2:	9905      	ldr	r1, [sp, #20]
32202cc4:	aa1a      	add	r2, sp, #104	@ 0x68
32202cc6:	4658      	mov	r0, fp
32202cc8:	f000 fc26 	bl	32203518 <__sprint_r>
32202ccc:	2800      	cmp	r0, #0
32202cce:	f47f ac09 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202cd2:	ab1d      	add	r3, sp, #116	@ 0x74
32202cd4:	9304      	str	r3, [sp, #16]
32202cd6:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32202cda:	e451      	b.n	32202580 <_vfiprintf_r+0x33c>
32202cdc:	f64b 46a8 	movw	r6, #48296	@ 0xbca8
32202ce0:	f2c3 2620 	movt	r6, #12832	@ 0x3220
32202ce4:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32202ce6:	2c10      	cmp	r4, #16
32202ce8:	dd21      	ble.n	32202d2e <_vfiprintf_r+0xaea>
32202cea:	463a      	mov	r2, r7
32202cec:	2510      	movs	r5, #16
32202cee:	4637      	mov	r7, r6
32202cf0:	9e05      	ldr	r6, [sp, #20]
32202cf2:	e002      	b.n	32202cfa <_vfiprintf_r+0xab6>
32202cf4:	3c10      	subs	r4, #16
32202cf6:	2c10      	cmp	r4, #16
32202cf8:	dd17      	ble.n	32202d2a <_vfiprintf_r+0xae6>
32202cfa:	3301      	adds	r3, #1
32202cfc:	3110      	adds	r1, #16
32202cfe:	2b07      	cmp	r3, #7
32202d00:	e9c2 7500 	strd	r7, r5, [r2]
32202d04:	e9cd 311b 	strd	r3, r1, [sp, #108]	@ 0x6c
32202d08:	bfd8      	it	le
32202d0a:	3208      	addle	r2, #8
32202d0c:	ddf2      	ble.n	32202cf4 <_vfiprintf_r+0xab0>
32202d0e:	aa1a      	add	r2, sp, #104	@ 0x68
32202d10:	4631      	mov	r1, r6
32202d12:	4658      	mov	r0, fp
32202d14:	f000 fc00 	bl	32203518 <__sprint_r>
32202d18:	aa1d      	add	r2, sp, #116	@ 0x74
32202d1a:	2800      	cmp	r0, #0
32202d1c:	f47f abe2 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202d20:	3c10      	subs	r4, #16
32202d22:	e9dd 311b 	ldrd	r3, r1, [sp, #108]	@ 0x6c
32202d26:	2c10      	cmp	r4, #16
32202d28:	dce7      	bgt.n	32202cfa <_vfiprintf_r+0xab6>
32202d2a:	463e      	mov	r6, r7
32202d2c:	4617      	mov	r7, r2
32202d2e:	3301      	adds	r3, #1
32202d30:	4421      	add	r1, r4
32202d32:	2b07      	cmp	r3, #7
32202d34:	e9c7 6400 	strd	r6, r4, [r7]
32202d38:	e9cd 311b 	strd	r3, r1, [sp, #108]	@ 0x6c
32202d3c:	f77f ac50 	ble.w	322025e0 <_vfiprintf_r+0x39c>
32202d40:	9905      	ldr	r1, [sp, #20]
32202d42:	aa1a      	add	r2, sp, #104	@ 0x68
32202d44:	4658      	mov	r0, fp
32202d46:	f000 fbe7 	bl	32203518 <__sprint_r>
32202d4a:	2800      	cmp	r0, #0
32202d4c:	f47f abca 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202d50:	991c      	ldr	r1, [sp, #112]	@ 0x70
32202d52:	e445      	b.n	322025e0 <_vfiprintf_r+0x39c>
32202d54:	f420 6380 	bic.w	r3, r0, #1024	@ 0x400
32202d58:	9303      	str	r3, [sp, #12]
32202d5a:	ad46      	add	r5, sp, #280	@ 0x118
32202d5c:	08d0      	lsrs	r0, r2, #3
32202d5e:	f002 0307 	and.w	r3, r2, #7
32202d62:	ea40 7241 	orr.w	r2, r0, r1, lsl #29
32202d66:	08c9      	lsrs	r1, r1, #3
32202d68:	3330      	adds	r3, #48	@ 0x30
32202d6a:	4628      	mov	r0, r5
32202d6c:	ea52 0401 	orrs.w	r4, r2, r1
32202d70:	f805 3d01 	strb.w	r3, [r5, #-1]!
32202d74:	d1f2      	bne.n	32202d5c <_vfiprintf_r+0xb18>
32202d76:	9a03      	ldr	r2, [sp, #12]
32202d78:	2b30      	cmp	r3, #48	@ 0x30
32202d7a:	f002 0201 	and.w	r2, r2, #1
32202d7e:	bf08      	it	eq
32202d80:	2200      	moveq	r2, #0
32202d82:	2a00      	cmp	r2, #0
32202d84:	f040 81f2 	bne.w	3220316c <_vfiprintf_r+0xf28>
32202d88:	ab46      	add	r3, sp, #280	@ 0x118
32202d8a:	920a      	str	r2, [sp, #40]	@ 0x28
32202d8c:	9a07      	ldr	r2, [sp, #28]
32202d8e:	1b5b      	subs	r3, r3, r5
32202d90:	930b      	str	r3, [sp, #44]	@ 0x2c
32202d92:	429a      	cmp	r2, r3
32202d94:	bfb8      	it	lt
32202d96:	461a      	movlt	r2, r3
32202d98:	9206      	str	r2, [sp, #24]
32202d9a:	f7ff bbcf 	b.w	3220253c <_vfiprintf_r+0x2f8>
32202d9e:	2200      	movs	r2, #0
32202da0:	920d      	str	r2, [sp, #52]	@ 0x34
32202da2:	461a      	mov	r2, r3
32202da4:	f64b 46a8 	movw	r6, #48296	@ 0xbca8
32202da8:	f2c3 2620 	movt	r6, #12832	@ 0x3220
32202dac:	2310      	movs	r3, #16
32202dae:	e9dd 1704 	ldrd	r1, r7, [sp, #16]
32202db2:	2c10      	cmp	r4, #16
32202db4:	dc03      	bgt.n	32202dbe <_vfiprintf_r+0xb7a>
32202db6:	e01c      	b.n	32202df2 <_vfiprintf_r+0xbae>
32202db8:	3c10      	subs	r4, #16
32202dba:	2c10      	cmp	r4, #16
32202dbc:	dd18      	ble.n	32202df0 <_vfiprintf_r+0xbac>
32202dbe:	3201      	adds	r2, #1
32202dc0:	3010      	adds	r0, #16
32202dc2:	2a07      	cmp	r2, #7
32202dc4:	e9c1 6300 	strd	r6, r3, [r1]
32202dc8:	e9cd 201b 	strd	r2, r0, [sp, #108]	@ 0x6c
32202dcc:	bfd8      	it	le
32202dce:	3108      	addle	r1, #8
32202dd0:	ddf2      	ble.n	32202db8 <_vfiprintf_r+0xb74>
32202dd2:	4639      	mov	r1, r7
32202dd4:	aa1a      	add	r2, sp, #104	@ 0x68
32202dd6:	4658      	mov	r0, fp
32202dd8:	f000 fb9e 	bl	32203518 <__sprint_r>
32202ddc:	a91d      	add	r1, sp, #116	@ 0x74
32202dde:	2800      	cmp	r0, #0
32202de0:	f47f ab80 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202de4:	3c10      	subs	r4, #16
32202de6:	2310      	movs	r3, #16
32202de8:	e9dd 201b 	ldrd	r2, r0, [sp, #108]	@ 0x6c
32202dec:	2c10      	cmp	r4, #16
32202dee:	dce6      	bgt.n	32202dbe <_vfiprintf_r+0xb7a>
32202df0:	9104      	str	r1, [sp, #16]
32202df2:	9b04      	ldr	r3, [sp, #16]
32202df4:	3201      	adds	r2, #1
32202df6:	1821      	adds	r1, r4, r0
32202df8:	2a07      	cmp	r2, #7
32202dfa:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32202dfe:	601e      	str	r6, [r3, #0]
32202e00:	605c      	str	r4, [r3, #4]
32202e02:	f300 817e 	bgt.w	32203102 <_vfiprintf_r+0xebe>
32202e06:	f89d 604b 	ldrb.w	r6, [sp, #75]	@ 0x4b
32202e0a:	3308      	adds	r3, #8
32202e0c:	9304      	str	r3, [sp, #16]
32202e0e:	2e00      	cmp	r6, #0
32202e10:	d035      	beq.n	32202e7e <_vfiprintf_r+0xc3a>
32202e12:	2600      	movs	r6, #0
32202e14:	f7ff bba5 	b.w	32202562 <_vfiprintf_r+0x31e>
32202e18:	9905      	ldr	r1, [sp, #20]
32202e1a:	aa1a      	add	r2, sp, #104	@ 0x68
32202e1c:	4658      	mov	r0, fp
32202e1e:	f000 fb7b 	bl	32203518 <__sprint_r>
32202e22:	2800      	cmp	r0, #0
32202e24:	f47f ab5e 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32202e28:	ab1d      	add	r3, sp, #116	@ 0x74
32202e2a:	9304      	str	r3, [sp, #16]
32202e2c:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32202e30:	f7ff bbc0 	b.w	322025b4 <_vfiprintf_r+0x370>
32202e34:	9a06      	ldr	r2, [sp, #24]
32202e36:	ad46      	add	r5, sp, #280	@ 0x118
32202e38:	9207      	str	r2, [sp, #28]
32202e3a:	e9cd 220a 	strd	r2, r2, [sp, #40]	@ 0x28
32202e3e:	f7ff bb7d 	b.w	3220253c <_vfiprintf_r+0x2f8>
32202e42:	930c      	str	r3, [sp, #48]	@ 0x30
32202e44:	f898 3000 	ldrb.w	r3, [r8]
32202e48:	f7ff ba6f 	b.w	3220232a <_vfiprintf_r+0xe6>
32202e4c:	2500      	movs	r5, #0
32202e4e:	2301      	movs	r3, #1
32202e50:	e9cd 530a 	strd	r5, r3, [sp, #40]	@ 0x28
32202e54:	f20d 1517 	addw	r5, sp, #279	@ 0x117
32202e58:	3201      	adds	r2, #1
32202e5a:	9206      	str	r2, [sp, #24]
32202e5c:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32202e60:	9c03      	ldr	r4, [sp, #12]
32202e62:	4608      	mov	r0, r1
32202e64:	4613      	mov	r3, r2
32202e66:	f014 0684 	ands.w	r6, r4, #132	@ 0x84
32202e6a:	f43f ab6f 	beq.w	3220254c <_vfiprintf_r+0x308>
32202e6e:	2300      	movs	r3, #0
32202e70:	930d      	str	r3, [sp, #52]	@ 0x34
32202e72:	f7ff bb76 	b.w	32202562 <_vfiprintf_r+0x31e>
32202e76:	0498      	lsls	r0, r3, #18
32202e78:	f57f aa0d 	bpl.w	32202296 <_vfiprintf_r+0x52>
32202e7c:	e46b      	b.n	32202756 <_vfiprintf_r+0x512>
32202e7e:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32202e80:	2b00      	cmp	r3, #0
32202e82:	f47f ab7f 	bne.w	32202584 <_vfiprintf_r+0x340>
32202e86:	f7ff bb8f 	b.w	322025a8 <_vfiprintf_r+0x364>
32202e8a:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202e8c:	9a03      	ldr	r2, [sp, #12]
32202e8e:	f853 4b04 	ldr.w	r4, [r3], #4
32202e92:	06d5      	lsls	r5, r2, #27
32202e94:	f53f ad7f 	bmi.w	32202996 <_vfiprintf_r+0x752>
32202e98:	9a03      	ldr	r2, [sp, #12]
32202e9a:	0650      	lsls	r0, r2, #25
32202e9c:	f140 81af 	bpl.w	322031fe <_vfiprintf_r+0xfba>
32202ea0:	b224      	sxth	r4, r4
32202ea2:	930c      	str	r3, [sp, #48]	@ 0x30
32202ea4:	17e6      	asrs	r6, r4, #31
32202ea6:	4633      	mov	r3, r6
32202ea8:	f7ff bbc8 	b.w	3220263c <_vfiprintf_r+0x3f8>
32202eac:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202eae:	3304      	adds	r3, #4
32202eb0:	990c      	ldr	r1, [sp, #48]	@ 0x30
32202eb2:	2600      	movs	r6, #0
32202eb4:	930c      	str	r3, [sp, #48]	@ 0x30
32202eb6:	f88d 604b 	strb.w	r6, [sp, #75]	@ 0x4b
32202eba:	680c      	ldr	r4, [r1, #0]
32202ebc:	9907      	ldr	r1, [sp, #28]
32202ebe:	42b1      	cmp	r1, r6
32202ec0:	f6bf aced 	bge.w	3220289e <_vfiprintf_r+0x65a>
32202ec4:	9203      	str	r2, [sp, #12]
32202ec6:	e4bd      	b.n	32202844 <_vfiprintf_r+0x600>
32202ec8:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202eca:	3304      	adds	r3, #4
32202ecc:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32202ece:	2100      	movs	r1, #0
32202ed0:	930c      	str	r3, [sp, #48]	@ 0x30
32202ed2:	6812      	ldr	r2, [r2, #0]
32202ed4:	e469      	b.n	322027aa <_vfiprintf_r+0x566>
32202ed6:	9b03      	ldr	r3, [sp, #12]
32202ed8:	06db      	lsls	r3, r3, #27
32202eda:	f100 815d 	bmi.w	32203198 <_vfiprintf_r+0xf54>
32202ede:	9b03      	ldr	r3, [sp, #12]
32202ee0:	065f      	lsls	r7, r3, #25
32202ee2:	f100 81db 	bmi.w	3220329c <_vfiprintf_r+0x1058>
32202ee6:	9b03      	ldr	r3, [sp, #12]
32202ee8:	059e      	lsls	r6, r3, #22
32202eea:	f140 8155 	bpl.w	32203198 <_vfiprintf_r+0xf54>
32202eee:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202ef0:	9a08      	ldr	r2, [sp, #32]
32202ef2:	681b      	ldr	r3, [r3, #0]
32202ef4:	701a      	strb	r2, [r3, #0]
32202ef6:	e538      	b.n	3220296a <_vfiprintf_r+0x726>
32202ef8:	9203      	str	r2, [sp, #12]
32202efa:	f7ff bb95 	b.w	32202628 <_vfiprintf_r+0x3e4>
32202efe:	f64b 10f0 	movw	r0, #47600	@ 0xb9f0
32202f02:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32202f06:	9a03      	ldr	r2, [sp, #12]
32202f08:	f012 0120 	ands.w	r1, r2, #32
32202f0c:	f000 80e8 	beq.w	322030e0 <_vfiprintf_r+0xe9c>
32202f10:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32202f12:	3207      	adds	r2, #7
32202f14:	f022 0207 	bic.w	r2, r2, #7
32202f18:	4614      	mov	r4, r2
32202f1a:	6851      	ldr	r1, [r2, #4]
32202f1c:	f854 2b08 	ldr.w	r2, [r4], #8
32202f20:	940c      	str	r4, [sp, #48]	@ 0x30
32202f22:	ea52 0401 	orrs.w	r4, r2, r1
32202f26:	9c03      	ldr	r4, [sp, #12]
32202f28:	f004 0501 	and.w	r5, r4, #1
32202f2c:	f04f 0401 	mov.w	r4, #1
32202f30:	bf08      	it	eq
32202f32:	2500      	moveq	r5, #0
32202f34:	bf08      	it	eq
32202f36:	2400      	moveq	r4, #0
32202f38:	2d00      	cmp	r5, #0
32202f3a:	f040 8105 	bne.w	32203148 <_vfiprintf_r+0xf04>
32202f3e:	9b07      	ldr	r3, [sp, #28]
32202f40:	f88d 504b 	strb.w	r5, [sp, #75]	@ 0x4b
32202f44:	2b00      	cmp	r3, #0
32202f46:	9b03      	ldr	r3, [sp, #12]
32202f48:	f2c0 80c3 	blt.w	322030d2 <_vfiprintf_r+0xe8e>
32202f4c:	f423 6390 	bic.w	r3, r3, #1152	@ 0x480
32202f50:	9303      	str	r3, [sp, #12]
32202f52:	9b07      	ldr	r3, [sp, #28]
32202f54:	3b00      	subs	r3, #0
32202f56:	bf18      	it	ne
32202f58:	2301      	movne	r3, #1
32202f5a:	431c      	orrs	r4, r3
32202f5c:	f040 80bc 	bne.w	322030d8 <_vfiprintf_r+0xe94>
32202f60:	ad46      	add	r5, sp, #280	@ 0x118
32202f62:	9407      	str	r4, [sp, #28]
32202f64:	940b      	str	r4, [sp, #44]	@ 0x2c
32202f66:	9406      	str	r4, [sp, #24]
32202f68:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32202f6c:	9c03      	ldr	r4, [sp, #12]
32202f6e:	4608      	mov	r0, r1
32202f70:	4613      	mov	r3, r2
32202f72:	f014 0684 	ands.w	r6, r4, #132	@ 0x84
32202f76:	f000 8270 	beq.w	3220345a <_vfiprintf_r+0x1216>
32202f7a:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
32202f7e:	2b00      	cmp	r3, #0
32202f80:	f000 825f 	beq.w	32203442 <_vfiprintf_r+0x11fe>
32202f84:	2300      	movs	r3, #0
32202f86:	930a      	str	r3, [sp, #40]	@ 0x28
32202f88:	930d      	str	r3, [sp, #52]	@ 0x34
32202f8a:	f7ff baea 	b.w	32202562 <_vfiprintf_r+0x31e>
32202f8e:	f64b 2004 	movw	r0, #47620	@ 0xba04
32202f92:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32202f96:	e7b6      	b.n	32202f06 <_vfiprintf_r+0xcc2>
32202f98:	9803      	ldr	r0, [sp, #12]
32202f9a:	2402      	movs	r4, #2
32202f9c:	930c      	str	r3, [sp, #48]	@ 0x30
32202f9e:	f040 0002 	orr.w	r0, r0, #2
32202fa2:	9003      	str	r0, [sp, #12]
32202fa4:	f64b 2004 	movw	r0, #47620	@ 0xba04
32202fa8:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32202fac:	ad46      	add	r5, sp, #280	@ 0x118
32202fae:	f002 030f 	and.w	r3, r2, #15
32202fb2:	0912      	lsrs	r2, r2, #4
32202fb4:	ea42 7201 	orr.w	r2, r2, r1, lsl #28
32202fb8:	0909      	lsrs	r1, r1, #4
32202fba:	5cc3      	ldrb	r3, [r0, r3]
32202fbc:	f805 3d01 	strb.w	r3, [r5, #-1]!
32202fc0:	ea52 0301 	orrs.w	r3, r2, r1
32202fc4:	d1f3      	bne.n	32202fae <_vfiprintf_r+0xd6a>
32202fc6:	9a07      	ldr	r2, [sp, #28]
32202fc8:	ab46      	add	r3, sp, #280	@ 0x118
32202fca:	1b5b      	subs	r3, r3, r5
32202fcc:	930b      	str	r3, [sp, #44]	@ 0x2c
32202fce:	429a      	cmp	r2, r3
32202fd0:	bfb8      	it	lt
32202fd2:	461a      	movlt	r2, r3
32202fd4:	9206      	str	r2, [sp, #24]
32202fd6:	2c00      	cmp	r4, #0
32202fd8:	f47f ac99 	bne.w	3220290e <_vfiprintf_r+0x6ca>
32202fdc:	e7c4      	b.n	32202f68 <_vfiprintf_r+0xd24>
32202fde:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32202fe0:	ad2d      	add	r5, sp, #180	@ 0xb4
32202fe2:	681b      	ldr	r3, [r3, #0]
32202fe4:	f88d 30b4 	strb.w	r3, [sp, #180]	@ 0xb4
32202fe8:	2301      	movs	r3, #1
32202fea:	9306      	str	r3, [sp, #24]
32202fec:	930b      	str	r3, [sp, #44]	@ 0x2c
32202fee:	f7ff bb94 	b.w	3220271a <_vfiprintf_r+0x4d6>
32202ff2:	9b03      	ldr	r3, [sp, #12]
32202ff4:	f108 0801 	add.w	r8, r8, #1
32202ff8:	f443 7300 	orr.w	r3, r3, #512	@ 0x200
32202ffc:	9303      	str	r3, [sp, #12]
32202ffe:	f898 3000 	ldrb.w	r3, [r8]
32203002:	f7ff b992 	b.w	3220232a <_vfiprintf_r+0xe6>
32203006:	9b03      	ldr	r3, [sp, #12]
32203008:	f108 0801 	add.w	r8, r8, #1
3220300c:	f043 0320 	orr.w	r3, r3, #32
32203010:	9303      	str	r3, [sp, #12]
32203012:	f898 3000 	ldrb.w	r3, [r8]
32203016:	f7ff b988 	b.w	3220232a <_vfiprintf_r+0xe6>
3220301a:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
3220301c:	2208      	movs	r2, #8
3220301e:	2100      	movs	r1, #0
32203020:	a818      	add	r0, sp, #96	@ 0x60
32203022:	9315      	str	r3, [sp, #84]	@ 0x54
32203024:	f001 f8a0 	bl	32204168 <memset>
32203028:	9f07      	ldr	r7, [sp, #28]
3220302a:	2f00      	cmp	r7, #0
3220302c:	f2c0 80fc 	blt.w	32203228 <_vfiprintf_r+0xfe4>
32203030:	2400      	movs	r4, #0
32203032:	4625      	mov	r5, r4
32203034:	e00c      	b.n	32203050 <_vfiprintf_r+0xe0c>
32203036:	a92d      	add	r1, sp, #180	@ 0xb4
32203038:	4658      	mov	r0, fp
3220303a:	f003 ff29 	bl	32206e90 <_wcrtomb_r>
3220303e:	3404      	adds	r4, #4
32203040:	1c41      	adds	r1, r0, #1
32203042:	4428      	add	r0, r5
32203044:	f000 81b1 	beq.w	322033aa <_vfiprintf_r+0x1166>
32203048:	42b8      	cmp	r0, r7
3220304a:	dc06      	bgt.n	3220305a <_vfiprintf_r+0xe16>
3220304c:	d006      	beq.n	3220305c <_vfiprintf_r+0xe18>
3220304e:	4605      	mov	r5, r0
32203050:	9a15      	ldr	r2, [sp, #84]	@ 0x54
32203052:	ab18      	add	r3, sp, #96	@ 0x60
32203054:	5912      	ldr	r2, [r2, r4]
32203056:	2a00      	cmp	r2, #0
32203058:	d1ed      	bne.n	32203036 <_vfiprintf_r+0xdf2>
3220305a:	9507      	str	r5, [sp, #28]
3220305c:	9b07      	ldr	r3, [sp, #28]
3220305e:	2b00      	cmp	r3, #0
32203060:	f000 80f2 	beq.w	32203248 <_vfiprintf_r+0x1004>
32203064:	2b63      	cmp	r3, #99	@ 0x63
32203066:	f340 8132 	ble.w	322032ce <_vfiprintf_r+0x108a>
3220306a:	1c59      	adds	r1, r3, #1
3220306c:	4658      	mov	r0, fp
3220306e:	f002 fd8b 	bl	32205b88 <_malloc_r>
32203072:	4605      	mov	r5, r0
32203074:	2800      	cmp	r0, #0
32203076:	f000 8198 	beq.w	322033aa <_vfiprintf_r+0x1166>
3220307a:	900a      	str	r0, [sp, #40]	@ 0x28
3220307c:	2208      	movs	r2, #8
3220307e:	2100      	movs	r1, #0
32203080:	a818      	add	r0, sp, #96	@ 0x60
32203082:	f001 f871 	bl	32204168 <memset>
32203086:	9c07      	ldr	r4, [sp, #28]
32203088:	ab18      	add	r3, sp, #96	@ 0x60
3220308a:	aa15      	add	r2, sp, #84	@ 0x54
3220308c:	9300      	str	r3, [sp, #0]
3220308e:	4629      	mov	r1, r5
32203090:	4623      	mov	r3, r4
32203092:	4658      	mov	r0, fp
32203094:	f003 ff46 	bl	32206f24 <_wcsrtombs_r>
32203098:	4284      	cmp	r4, r0
3220309a:	f040 81d7 	bne.w	3220344c <_vfiprintf_r+0x1208>
3220309e:	9907      	ldr	r1, [sp, #28]
322030a0:	2300      	movs	r3, #0
322030a2:	546b      	strb	r3, [r5, r1]
322030a4:	ea21 72e1 	bic.w	r2, r1, r1, asr #31
322030a8:	9206      	str	r2, [sp, #24]
322030aa:	f89d 204b 	ldrb.w	r2, [sp, #75]	@ 0x4b
322030ae:	2a00      	cmp	r2, #0
322030b0:	f040 8173 	bne.w	3220339a <_vfiprintf_r+0x1156>
322030b4:	e9cd 160b 	strd	r1, r6, [sp, #44]	@ 0x2c
322030b8:	9207      	str	r2, [sp, #28]
322030ba:	f7ff ba3f 	b.w	3220253c <_vfiprintf_r+0x2f8>
322030be:	9c09      	ldr	r4, [sp, #36]	@ 0x24
322030c0:	9f06      	ldr	r7, [sp, #24]
322030c2:	960a      	str	r6, [sp, #40]	@ 0x28
322030c4:	1be4      	subs	r4, r4, r7
322030c6:	2c00      	cmp	r4, #0
322030c8:	f77f aa5c 	ble.w	32202584 <_vfiprintf_r+0x340>
322030cc:	2202      	movs	r2, #2
322030ce:	920d      	str	r2, [sp, #52]	@ 0x34
322030d0:	e667      	b.n	32202da2 <_vfiprintf_r+0xb5e>
322030d2:	f423 6380 	bic.w	r3, r3, #1024	@ 0x400
322030d6:	9303      	str	r3, [sp, #12]
322030d8:	9b03      	ldr	r3, [sp, #12]
322030da:	f003 0402 	and.w	r4, r3, #2
322030de:	e765      	b.n	32202fac <_vfiprintf_r+0xd68>
322030e0:	9c0c      	ldr	r4, [sp, #48]	@ 0x30
322030e2:	f854 2b04 	ldr.w	r2, [r4], #4
322030e6:	940c      	str	r4, [sp, #48]	@ 0x30
322030e8:	9c03      	ldr	r4, [sp, #12]
322030ea:	f014 0410 	ands.w	r4, r4, #16
322030ee:	f47f af18 	bne.w	32202f22 <_vfiprintf_r+0xcde>
322030f2:	9903      	ldr	r1, [sp, #12]
322030f4:	f011 0540 	ands.w	r5, r1, #64	@ 0x40
322030f8:	f000 808a 	beq.w	32203210 <_vfiprintf_r+0xfcc>
322030fc:	b292      	uxth	r2, r2
322030fe:	4621      	mov	r1, r4
32203100:	e70f      	b.n	32202f22 <_vfiprintf_r+0xcde>
32203102:	9905      	ldr	r1, [sp, #20]
32203104:	aa1a      	add	r2, sp, #104	@ 0x68
32203106:	4658      	mov	r0, fp
32203108:	f000 fa06 	bl	32203518 <__sprint_r>
3220310c:	4606      	mov	r6, r0
3220310e:	2800      	cmp	r0, #0
32203110:	f47f a9e8 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
32203114:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
32203118:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
3220311c:	2b00      	cmp	r3, #0
3220311e:	d17f      	bne.n	32203220 <_vfiprintf_r+0xfdc>
32203120:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32203122:	b16b      	cbz	r3, 32203140 <_vfiprintf_r+0xefc>
32203124:	ab1d      	add	r3, sp, #116	@ 0x74
32203126:	9304      	str	r3, [sp, #16]
32203128:	f7ff ba2c 	b.w	32202584 <_vfiprintf_r+0x340>
3220312c:	9905      	ldr	r1, [sp, #20]
3220312e:	aa1a      	add	r2, sp, #104	@ 0x68
32203130:	4658      	mov	r0, fp
32203132:	f000 f9f1 	bl	32203518 <__sprint_r>
32203136:	2800      	cmp	r0, #0
32203138:	f47f a9d4 	bne.w	322024e4 <_vfiprintf_r+0x2a0>
3220313c:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32203140:	ab1d      	add	r3, sp, #116	@ 0x74
32203142:	9304      	str	r3, [sp, #16]
32203144:	f7ff ba30 	b.w	322025a8 <_vfiprintf_r+0x364>
32203148:	f88d 304d 	strb.w	r3, [sp, #77]	@ 0x4d
3220314c:	2330      	movs	r3, #48	@ 0x30
3220314e:	f88d 304c 	strb.w	r3, [sp, #76]	@ 0x4c
32203152:	2300      	movs	r3, #0
32203154:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32203158:	9b07      	ldr	r3, [sp, #28]
3220315a:	2b00      	cmp	r3, #0
3220315c:	da7f      	bge.n	3220325e <_vfiprintf_r+0x101a>
3220315e:	9b03      	ldr	r3, [sp, #12]
32203160:	f423 6380 	bic.w	r3, r3, #1024	@ 0x400
32203164:	f043 0302 	orr.w	r3, r3, #2
32203168:	9303      	str	r3, [sp, #12]
3220316a:	e7b5      	b.n	322030d8 <_vfiprintf_r+0xe94>
3220316c:	9a07      	ldr	r2, [sp, #28]
3220316e:	3802      	subs	r0, #2
32203170:	2330      	movs	r3, #48	@ 0x30
32203172:	f805 3c01 	strb.w	r3, [r5, #-1]
32203176:	ab46      	add	r3, sp, #280	@ 0x118
32203178:	4605      	mov	r5, r0
3220317a:	1a1b      	subs	r3, r3, r0
3220317c:	930b      	str	r3, [sp, #44]	@ 0x2c
3220317e:	429a      	cmp	r2, r3
32203180:	bfb8      	it	lt
32203182:	461a      	movlt	r2, r3
32203184:	2300      	movs	r3, #0
32203186:	9206      	str	r2, [sp, #24]
32203188:	930a      	str	r3, [sp, #40]	@ 0x28
3220318a:	f7ff b9d7 	b.w	3220253c <_vfiprintf_r+0x2f8>
3220318e:	4658      	mov	r0, fp
32203190:	f000 fc24 	bl	322039dc <__sinit>
32203194:	f7ff b86d 	b.w	32202272 <_vfiprintf_r+0x2e>
32203198:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3220319a:	9a08      	ldr	r2, [sp, #32]
3220319c:	681b      	ldr	r3, [r3, #0]
3220319e:	601a      	str	r2, [r3, #0]
322031a0:	f7ff bbe3 	b.w	3220296a <_vfiprintf_r+0x726>
322031a4:	930a      	str	r3, [sp, #40]	@ 0x28
322031a6:	ad46      	add	r5, sp, #280	@ 0x118
322031a8:	930b      	str	r3, [sp, #44]	@ 0x2c
322031aa:	9307      	str	r3, [sp, #28]
322031ac:	2301      	movs	r3, #1
322031ae:	9306      	str	r3, [sp, #24]
322031b0:	e654      	b.n	32202e5c <_vfiprintf_r+0xc18>
322031b2:	9b07      	ldr	r3, [sp, #28]
322031b4:	f64b 2518 	movw	r5, #47640	@ 0xba18
322031b8:	f2c3 2520 	movt	r5, #12832	@ 0x3220
322031bc:	960c      	str	r6, [sp, #48]	@ 0x30
322031be:	2b06      	cmp	r3, #6
322031c0:	9207      	str	r2, [sp, #28]
322031c2:	bf28      	it	cs
322031c4:	2306      	movcs	r3, #6
322031c6:	9306      	str	r3, [sp, #24]
322031c8:	930b      	str	r3, [sp, #44]	@ 0x2c
322031ca:	f7ff b9b7 	b.w	3220253c <_vfiprintf_r+0x2f8>
322031ce:	9c03      	ldr	r4, [sp, #12]
322031d0:	f414 7100 	ands.w	r1, r4, #512	@ 0x200
322031d4:	d057      	beq.n	32203286 <_vfiprintf_r+0x1042>
322031d6:	4601      	mov	r1, r0
322031d8:	b2d2      	uxtb	r2, r2
322031da:	4620      	mov	r0, r4
322031dc:	930c      	str	r3, [sp, #48]	@ 0x30
322031de:	f7ff bae4 	b.w	322027aa <_vfiprintf_r+0x566>
322031e2:	9903      	ldr	r1, [sp, #12]
322031e4:	f411 7600 	ands.w	r6, r1, #512	@ 0x200
322031e8:	d045      	beq.n	32203276 <_vfiprintf_r+0x1032>
322031ea:	4616      	mov	r6, r2
322031ec:	f88d 204b 	strb.w	r2, [sp, #75]	@ 0x4b
322031f0:	9a07      	ldr	r2, [sp, #28]
322031f2:	b2e4      	uxtb	r4, r4
322031f4:	2a00      	cmp	r2, #0
322031f6:	f6bf ab16 	bge.w	32202826 <_vfiprintf_r+0x5e2>
322031fa:	f7ff bb22 	b.w	32202842 <_vfiprintf_r+0x5fe>
322031fe:	9a03      	ldr	r2, [sp, #12]
32203200:	0591      	lsls	r1, r2, #22
32203202:	d533      	bpl.n	3220326c <_vfiprintf_r+0x1028>
32203204:	b264      	sxtb	r4, r4
32203206:	930c      	str	r3, [sp, #48]	@ 0x30
32203208:	17e6      	asrs	r6, r4, #31
3220320a:	4633      	mov	r3, r6
3220320c:	f7ff ba16 	b.w	3220263c <_vfiprintf_r+0x3f8>
32203210:	9903      	ldr	r1, [sp, #12]
32203212:	f411 7100 	ands.w	r1, r1, #512	@ 0x200
32203216:	f43f ae84 	beq.w	32202f22 <_vfiprintf_r+0xcde>
3220321a:	b2d2      	uxtb	r2, r2
3220321c:	4629      	mov	r1, r5
3220321e:	e680      	b.n	32202f22 <_vfiprintf_r+0xcde>
32203220:	ab1d      	add	r3, sp, #116	@ 0x74
32203222:	9304      	str	r3, [sp, #16]
32203224:	f7ff b99d 	b.w	32202562 <_vfiprintf_r+0x31e>
32203228:	ab18      	add	r3, sp, #96	@ 0x60
3220322a:	9300      	str	r3, [sp, #0]
3220322c:	2300      	movs	r3, #0
3220322e:	aa15      	add	r2, sp, #84	@ 0x54
32203230:	4619      	mov	r1, r3
32203232:	4658      	mov	r0, fp
32203234:	f003 fe76 	bl	32206f24 <_wcsrtombs_r>
32203238:	4603      	mov	r3, r0
3220323a:	3301      	adds	r3, #1
3220323c:	9007      	str	r0, [sp, #28]
3220323e:	f000 80b4 	beq.w	322033aa <_vfiprintf_r+0x1166>
32203242:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32203244:	9315      	str	r3, [sp, #84]	@ 0x54
32203246:	e709      	b.n	3220305c <_vfiprintf_r+0xe18>
32203248:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
3220324c:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
3220324e:	3b00      	subs	r3, #0
32203250:	960c      	str	r6, [sp, #48]	@ 0x30
32203252:	bf18      	it	ne
32203254:	2301      	movne	r3, #1
32203256:	9306      	str	r3, [sp, #24]
32203258:	9b07      	ldr	r3, [sp, #28]
3220325a:	930b      	str	r3, [sp, #44]	@ 0x2c
3220325c:	e684      	b.n	32202f68 <_vfiprintf_r+0xd24>
3220325e:	9b03      	ldr	r3, [sp, #12]
32203260:	f423 6390 	bic.w	r3, r3, #1152	@ 0x480
32203264:	f043 0302 	orr.w	r3, r3, #2
32203268:	9303      	str	r3, [sp, #12]
3220326a:	e735      	b.n	322030d8 <_vfiprintf_r+0xe94>
3220326c:	17e6      	asrs	r6, r4, #31
3220326e:	930c      	str	r3, [sp, #48]	@ 0x30
32203270:	4633      	mov	r3, r6
32203272:	f7ff b9e3 	b.w	3220263c <_vfiprintf_r+0x3f8>
32203276:	9a07      	ldr	r2, [sp, #28]
32203278:	f88d 604b 	strb.w	r6, [sp, #75]	@ 0x4b
3220327c:	2a00      	cmp	r2, #0
3220327e:	f6bf aad2 	bge.w	32202826 <_vfiprintf_r+0x5e2>
32203282:	f7ff bade 	b.w	32202842 <_vfiprintf_r+0x5fe>
32203286:	9803      	ldr	r0, [sp, #12]
32203288:	930c      	str	r3, [sp, #48]	@ 0x30
3220328a:	f7ff ba8e 	b.w	322027aa <_vfiprintf_r+0x566>
3220328e:	ad46      	add	r5, sp, #280	@ 0x118
32203290:	9207      	str	r2, [sp, #28]
32203292:	930c      	str	r3, [sp, #48]	@ 0x30
32203294:	e9cd 220a 	strd	r2, r2, [sp, #40]	@ 0x28
32203298:	f7ff b950 	b.w	3220253c <_vfiprintf_r+0x2f8>
3220329c:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3220329e:	9a08      	ldr	r2, [sp, #32]
322032a0:	681b      	ldr	r3, [r3, #0]
322032a2:	801a      	strh	r2, [r3, #0]
322032a4:	f7ff bb61 	b.w	3220296a <_vfiprintf_r+0x726>
322032a8:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
322032aa:	4628      	mov	r0, r5
322032ac:	f002 fa48 	bl	32205740 <strlen>
322032b0:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
322032b4:	ea20 72e0 	bic.w	r2, r0, r0, asr #31
322032b8:	900b      	str	r0, [sp, #44]	@ 0x2c
322032ba:	9206      	str	r2, [sp, #24]
322032bc:	2b00      	cmp	r3, #0
322032be:	f000 8083 	beq.w	322033c8 <_vfiprintf_r+0x1184>
322032c2:	3201      	adds	r2, #1
322032c4:	9407      	str	r4, [sp, #28]
322032c6:	9206      	str	r2, [sp, #24]
322032c8:	960c      	str	r6, [sp, #48]	@ 0x30
322032ca:	940a      	str	r4, [sp, #40]	@ 0x28
322032cc:	e5c6      	b.n	32202e5c <_vfiprintf_r+0xc18>
322032ce:	2300      	movs	r3, #0
322032d0:	ad2d      	add	r5, sp, #180	@ 0xb4
322032d2:	930a      	str	r3, [sp, #40]	@ 0x28
322032d4:	e6d2      	b.n	3220307c <_vfiprintf_r+0xe38>
322032d6:	6d88      	ldr	r0, [r1, #88]	@ 0x58
322032d8:	f001 fd46 	bl	32204d68 <__retarget_lock_release_recursive>
322032dc:	f7ff b8bd 	b.w	3220245a <_vfiprintf_r+0x216>
322032e0:	9a10      	ldr	r2, [sp, #64]	@ 0x40
322032e2:	9911      	ldr	r1, [sp, #68]	@ 0x44
322032e4:	eba8 0b02 	sub.w	fp, r8, r2
322032e8:	4658      	mov	r0, fp
322032ea:	f000 ff8b 	bl	32204204 <strncpy>
322032ee:	f899 3001 	ldrb.w	r3, [r9, #1]
322032f2:	b10b      	cbz	r3, 322032f8 <_vfiprintf_r+0x10b4>
322032f4:	f109 0901 	add.w	r9, r9, #1
322032f8:	19a3      	adds	r3, r4, r6
322032fa:	f64c 42cd 	movw	r2, #52429	@ 0xcccd
322032fe:	f6cc 42cc 	movt	r2, #52428	@ 0xcccc
32203302:	f143 0300 	adc.w	r3, r3, #0
32203306:	f04f 31cc 	mov.w	r1, #3435973836	@ 0xcccccccc
3220330a:	f04f 0e01 	mov.w	lr, #1
3220330e:	f10b 38ff 	add.w	r8, fp, #4294967295	@ 0xffffffff
32203312:	fba2 0c03 	umull	r0, ip, r2, r3
32203316:	f02c 0003 	bic.w	r0, ip, #3
3220331a:	eb00 009c 	add.w	r0, r0, ip, lsr #2
3220331e:	1a1b      	subs	r3, r3, r0
32203320:	1ae3      	subs	r3, r4, r3
32203322:	f166 0600 	sbc.w	r6, r6, #0
32203326:	fb03 f101 	mul.w	r1, r3, r1
3220332a:	fb02 1106 	mla	r1, r2, r6, r1
3220332e:	fba3 3002 	umull	r3, r0, r3, r2
32203332:	4401      	add	r1, r0
32203334:	fa23 f30e 	lsr.w	r3, r3, lr
32203338:	ea43 74c1 	orr.w	r4, r3, r1, lsl #31
3220333c:	fa21 f60e 	lsr.w	r6, r1, lr
32203340:	19a3      	adds	r3, r4, r6
32203342:	f143 0300 	adc.w	r3, r3, #0
32203346:	fba2 1003 	umull	r1, r0, r2, r3
3220334a:	f020 0103 	bic.w	r1, r0, #3
3220334e:	eb01 0190 	add.w	r1, r1, r0, lsr #2
32203352:	1a5b      	subs	r3, r3, r1
32203354:	1ae3      	subs	r3, r4, r3
32203356:	f166 0000 	sbc.w	r0, r6, #0
3220335a:	fba3 3102 	umull	r3, r1, r3, r2
3220335e:	fa23 f30e 	lsr.w	r3, r3, lr
32203362:	fb02 1200 	mla	r2, r2, r0, r1
32203366:	ea43 73c2 	orr.w	r3, r3, r2, lsl #31
3220336a:	eb03 0383 	add.w	r3, r3, r3, lsl #2
3220336e:	eba4 0343 	sub.w	r3, r4, r3, lsl #1
32203372:	3330      	adds	r3, #48	@ 0x30
32203374:	f80b 3c01 	strb.w	r3, [fp, #-1]
32203378:	f7ff bb83 	b.w	32202a82 <_vfiprintf_r+0x83e>
3220337c:	2200      	movs	r2, #0
3220337e:	4688      	mov	r8, r1
32203380:	9207      	str	r2, [sp, #28]
32203382:	f7fe bfd4 	b.w	3220232e <_vfiprintf_r+0xea>
32203386:	9905      	ldr	r1, [sp, #20]
32203388:	aa1a      	add	r2, sp, #104	@ 0x68
3220338a:	4658      	mov	r0, fp
3220338c:	f000 f8c4 	bl	32203518 <__sprint_r>
32203390:	2800      	cmp	r0, #0
32203392:	f43f a890 	beq.w	322024b6 <_vfiprintf_r+0x272>
32203396:	f7ff b8ab 	b.w	322024f0 <_vfiprintf_r+0x2ac>
3220339a:	9a07      	ldr	r2, [sp, #28]
3220339c:	920b      	str	r2, [sp, #44]	@ 0x2c
3220339e:	9a06      	ldr	r2, [sp, #24]
322033a0:	960c      	str	r6, [sp, #48]	@ 0x30
322033a2:	3201      	adds	r2, #1
322033a4:	9307      	str	r3, [sp, #28]
322033a6:	9206      	str	r2, [sp, #24]
322033a8:	e558      	b.n	32202e5c <_vfiprintf_r+0xc18>
322033aa:	9805      	ldr	r0, [sp, #20]
322033ac:	6e42      	ldr	r2, [r0, #100]	@ 0x64
322033ae:	f9b0 300c 	ldrsh.w	r3, [r0, #12]
322033b2:	07d2      	lsls	r2, r2, #31
322033b4:	f043 0140 	orr.w	r1, r3, #64	@ 0x40
322033b8:	8181      	strh	r1, [r0, #12]
322033ba:	f53f a9cc 	bmi.w	32202756 <_vfiprintf_r+0x512>
322033be:	0599      	lsls	r1, r3, #22
322033c0:	f53f a9c9 	bmi.w	32202756 <_vfiprintf_r+0x512>
322033c4:	f7ff b925 	b.w	32202612 <_vfiprintf_r+0x3ce>
322033c8:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
322033ca:	9307      	str	r3, [sp, #28]
322033cc:	960c      	str	r6, [sp, #48]	@ 0x30
322033ce:	930a      	str	r3, [sp, #40]	@ 0x28
322033d0:	f7ff b8b4 	b.w	3220253c <_vfiprintf_r+0x2f8>
322033d4:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
322033d6:	9207      	str	r2, [sp, #28]
322033d8:	960c      	str	r6, [sp, #48]	@ 0x30
322033da:	920a      	str	r2, [sp, #40]	@ 0x28
322033dc:	f7ff b8ae 	b.w	3220253c <_vfiprintf_r+0x2f8>
322033e0:	b13a      	cbz	r2, 322033f2 <_vfiprintf_r+0x11ae>
322033e2:	9a07      	ldr	r2, [sp, #28]
322033e4:	960c      	str	r6, [sp, #48]	@ 0x30
322033e6:	1c51      	adds	r1, r2, #1
322033e8:	920b      	str	r2, [sp, #44]	@ 0x2c
322033ea:	9106      	str	r1, [sp, #24]
322033ec:	9007      	str	r0, [sp, #28]
322033ee:	900a      	str	r0, [sp, #40]	@ 0x28
322033f0:	e534      	b.n	32202e5c <_vfiprintf_r+0xc18>
322033f2:	9b07      	ldr	r3, [sp, #28]
322033f4:	920a      	str	r2, [sp, #40]	@ 0x28
322033f6:	960c      	str	r6, [sp, #48]	@ 0x30
322033f8:	930b      	str	r3, [sp, #44]	@ 0x2c
322033fa:	9306      	str	r3, [sp, #24]
322033fc:	9207      	str	r2, [sp, #28]
322033fe:	f7ff b89d 	b.w	3220253c <_vfiprintf_r+0x2f8>
32203402:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32203404:	f898 3001 	ldrb.w	r3, [r8, #1]
32203408:	4688      	mov	r8, r1
3220340a:	f852 1b04 	ldr.w	r1, [r2], #4
3220340e:	920c      	str	r2, [sp, #48]	@ 0x30
32203410:	ea41 72e1 	orr.w	r2, r1, r1, asr #31
32203414:	9207      	str	r2, [sp, #28]
32203416:	f7fe bf88 	b.w	3220232a <_vfiprintf_r+0xe6>
3220341a:	9a05      	ldr	r2, [sp, #20]
3220341c:	6e53      	ldr	r3, [r2, #100]	@ 0x64
3220341e:	07dd      	lsls	r5, r3, #31
32203420:	f53f a999 	bmi.w	32202756 <_vfiprintf_r+0x512>
32203424:	8993      	ldrh	r3, [r2, #12]
32203426:	059c      	lsls	r4, r3, #22
32203428:	f53f a995 	bmi.w	32202756 <_vfiprintf_r+0x512>
3220342c:	6d90      	ldr	r0, [r2, #88]	@ 0x58
3220342e:	f001 fc9b 	bl	32204d68 <__retarget_lock_release_recursive>
32203432:	f7ff b990 	b.w	32202756 <_vfiprintf_r+0x512>
32203436:	f64b 2004 	movw	r0, #47620	@ 0xba04
3220343a:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220343e:	930c      	str	r3, [sp, #48]	@ 0x30
32203440:	e64a      	b.n	322030d8 <_vfiprintf_r+0xe94>
32203442:	930a      	str	r3, [sp, #40]	@ 0x28
32203444:	f7ff b8ad 	b.w	322025a2 <_vfiprintf_r+0x35e>
32203448:	9803      	ldr	r0, [sp, #12]
3220344a:	e53f      	b.n	32202ecc <_vfiprintf_r+0xc88>
3220344c:	9a05      	ldr	r2, [sp, #20]
3220344e:	8993      	ldrh	r3, [r2, #12]
32203450:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32203454:	8193      	strh	r3, [r2, #12]
32203456:	f7ff b845 	b.w	322024e4 <_vfiprintf_r+0x2a0>
3220345a:	960a      	str	r6, [sp, #40]	@ 0x28
3220345c:	f7ff b876 	b.w	3220254c <_vfiprintf_r+0x308>

32203460 <vfiprintf>:
32203460:	f24c 3cd0 	movw	ip, #50128	@ 0xc3d0
32203464:	f2c3 2c20 	movt	ip, #12832	@ 0x3220
32203468:	b500      	push	{lr}
3220346a:	468e      	mov	lr, r1
3220346c:	4613      	mov	r3, r2
3220346e:	4601      	mov	r1, r0
32203470:	4672      	mov	r2, lr
32203472:	f8dc 0000 	ldr.w	r0, [ip]
32203476:	f85d eb04 	ldr.w	lr, [sp], #4
3220347a:	f7fe bee3 	b.w	32202244 <_vfiprintf_r>
3220347e:	bf00      	nop

32203480 <__sbprintf>:
32203480:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
32203484:	4698      	mov	r8, r3
32203486:	eddf 0b22 	vldr	d16, [pc, #136]	@ 32203510 <__sbprintf+0x90>
3220348a:	f5ad 6d8d 	sub.w	sp, sp, #1128	@ 0x468
3220348e:	4616      	mov	r6, r2
32203490:	ab05      	add	r3, sp, #20
32203492:	4607      	mov	r7, r0
32203494:	a816      	add	r0, sp, #88	@ 0x58
32203496:	460d      	mov	r5, r1
32203498:	466c      	mov	r4, sp
3220349a:	f943 078f 	vst1.32	{d16}, [r3]
3220349e:	898b      	ldrh	r3, [r1, #12]
322034a0:	f023 0302 	bic.w	r3, r3, #2
322034a4:	f8ad 300c 	strh.w	r3, [sp, #12]
322034a8:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
322034aa:	9319      	str	r3, [sp, #100]	@ 0x64
322034ac:	89cb      	ldrh	r3, [r1, #14]
322034ae:	f8ad 300e 	strh.w	r3, [sp, #14]
322034b2:	69cb      	ldr	r3, [r1, #28]
322034b4:	9307      	str	r3, [sp, #28]
322034b6:	6a4b      	ldr	r3, [r1, #36]	@ 0x24
322034b8:	9309      	str	r3, [sp, #36]	@ 0x24
322034ba:	ab1a      	add	r3, sp, #104	@ 0x68
322034bc:	9300      	str	r3, [sp, #0]
322034be:	9304      	str	r3, [sp, #16]
322034c0:	f44f 6380 	mov.w	r3, #1024	@ 0x400
322034c4:	9302      	str	r3, [sp, #8]
322034c6:	f001 fc3f 	bl	32204d48 <__retarget_lock_init_recursive>
322034ca:	4632      	mov	r2, r6
322034cc:	4643      	mov	r3, r8
322034ce:	4669      	mov	r1, sp
322034d0:	4638      	mov	r0, r7
322034d2:	f7fe feb7 	bl	32202244 <_vfiprintf_r>
322034d6:	1e06      	subs	r6, r0, #0
322034d8:	db08      	blt.n	322034ec <__sbprintf+0x6c>
322034da:	4669      	mov	r1, sp
322034dc:	4638      	mov	r0, r7
322034de:	f000 f8c7 	bl	32203670 <_fflush_r>
322034e2:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
322034e6:	2800      	cmp	r0, #0
322034e8:	bf18      	it	ne
322034ea:	461e      	movne	r6, r3
322034ec:	89a3      	ldrh	r3, [r4, #12]
322034ee:	065b      	lsls	r3, r3, #25
322034f0:	d503      	bpl.n	322034fa <__sbprintf+0x7a>
322034f2:	89ab      	ldrh	r3, [r5, #12]
322034f4:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
322034f8:	81ab      	strh	r3, [r5, #12]
322034fa:	6da0      	ldr	r0, [r4, #88]	@ 0x58
322034fc:	f001 fc28 	bl	32204d50 <__retarget_lock_close_recursive>
32203500:	4630      	mov	r0, r6
32203502:	f50d 6d8d 	add.w	sp, sp, #1128	@ 0x468
32203506:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
3220350a:	bf00      	nop
3220350c:	f3af 8000 	nop.w
32203510:	00000400 	.word	0x00000400
32203514:	00000000 	.word	0x00000000

32203518 <__sprint_r>:
32203518:	6893      	ldr	r3, [r2, #8]
3220351a:	b510      	push	{r4, lr}
3220351c:	4614      	mov	r4, r2
3220351e:	b91b      	cbnz	r3, 32203528 <__sprint_r+0x10>
32203520:	4618      	mov	r0, r3
32203522:	2300      	movs	r3, #0
32203524:	6063      	str	r3, [r4, #4]
32203526:	bd10      	pop	{r4, pc}
32203528:	f000 fab4 	bl	32203a94 <__sfvwrite_r>
3220352c:	2300      	movs	r3, #0
3220352e:	60a3      	str	r3, [r4, #8]
32203530:	2300      	movs	r3, #0
32203532:	6063      	str	r3, [r4, #4]
32203534:	bd10      	pop	{r4, pc}
32203536:	bf00      	nop

32203538 <__sflush_r>:
32203538:	f9b1 200c 	ldrsh.w	r2, [r1, #12]
3220353c:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
32203540:	460c      	mov	r4, r1
32203542:	4680      	mov	r8, r0
32203544:	0715      	lsls	r5, r2, #28
32203546:	d450      	bmi.n	322035ea <__sflush_r+0xb2>
32203548:	6849      	ldr	r1, [r1, #4]
3220354a:	f442 6300 	orr.w	r3, r2, #2048	@ 0x800
3220354e:	81a3      	strh	r3, [r4, #12]
32203550:	2900      	cmp	r1, #0
32203552:	dd6f      	ble.n	32203634 <__sflush_r+0xfc>
32203554:	6aa6      	ldr	r6, [r4, #40]	@ 0x28
32203556:	2e00      	cmp	r6, #0
32203558:	d044      	beq.n	322035e4 <__sflush_r+0xac>
3220355a:	f8d8 5000 	ldr.w	r5, [r8]
3220355e:	2100      	movs	r1, #0
32203560:	f412 5280 	ands.w	r2, r2, #4096	@ 0x1000
32203564:	f8c8 1000 	str.w	r1, [r8]
32203568:	d168      	bne.n	3220363c <__sflush_r+0x104>
3220356a:	69e1      	ldr	r1, [r4, #28]
3220356c:	2301      	movs	r3, #1
3220356e:	4640      	mov	r0, r8
32203570:	47b0      	blx	r6
32203572:	4602      	mov	r2, r0
32203574:	1c50      	adds	r0, r2, #1
32203576:	d06f      	beq.n	32203658 <__sflush_r+0x120>
32203578:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
3220357c:	6aa6      	ldr	r6, [r4, #40]	@ 0x28
3220357e:	0759      	lsls	r1, r3, #29
32203580:	d505      	bpl.n	3220358e <__sflush_r+0x56>
32203582:	6b23      	ldr	r3, [r4, #48]	@ 0x30
32203584:	6861      	ldr	r1, [r4, #4]
32203586:	1a52      	subs	r2, r2, r1
32203588:	b10b      	cbz	r3, 3220358e <__sflush_r+0x56>
3220358a:	6be3      	ldr	r3, [r4, #60]	@ 0x3c
3220358c:	1ad2      	subs	r2, r2, r3
3220358e:	2300      	movs	r3, #0
32203590:	69e1      	ldr	r1, [r4, #28]
32203592:	4640      	mov	r0, r8
32203594:	47b0      	blx	r6
32203596:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
3220359a:	1c42      	adds	r2, r0, #1
3220359c:	d150      	bne.n	32203640 <__sflush_r+0x108>
3220359e:	f8d8 1000 	ldr.w	r1, [r8]
322035a2:	291d      	cmp	r1, #29
322035a4:	d83f      	bhi.n	32203626 <__sflush_r+0xee>
322035a6:	2201      	movs	r2, #1
322035a8:	f2c2 0240 	movt	r2, #8256	@ 0x2040
322035ac:	40ca      	lsrs	r2, r1
322035ae:	07d7      	lsls	r7, r2, #31
322035b0:	d539      	bpl.n	32203626 <__sflush_r+0xee>
322035b2:	6922      	ldr	r2, [r4, #16]
322035b4:	04de      	lsls	r6, r3, #19
322035b6:	6022      	str	r2, [r4, #0]
322035b8:	f423 6200 	bic.w	r2, r3, #2048	@ 0x800
322035bc:	81a2      	strh	r2, [r4, #12]
322035be:	f04f 0200 	mov.w	r2, #0
322035c2:	6062      	str	r2, [r4, #4]
322035c4:	d501      	bpl.n	322035ca <__sflush_r+0x92>
322035c6:	2900      	cmp	r1, #0
322035c8:	d044      	beq.n	32203654 <__sflush_r+0x11c>
322035ca:	6b21      	ldr	r1, [r4, #48]	@ 0x30
322035cc:	f8c8 5000 	str.w	r5, [r8]
322035d0:	b141      	cbz	r1, 322035e4 <__sflush_r+0xac>
322035d2:	f104 0340 	add.w	r3, r4, #64	@ 0x40
322035d6:	4299      	cmp	r1, r3
322035d8:	d002      	beq.n	322035e0 <__sflush_r+0xa8>
322035da:	4640      	mov	r0, r8
322035dc:	f002 f984 	bl	322058e8 <_free_r>
322035e0:	2300      	movs	r3, #0
322035e2:	6323      	str	r3, [r4, #48]	@ 0x30
322035e4:	2000      	movs	r0, #0
322035e6:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
322035ea:	690e      	ldr	r6, [r1, #16]
322035ec:	2e00      	cmp	r6, #0
322035ee:	d0f9      	beq.n	322035e4 <__sflush_r+0xac>
322035f0:	680d      	ldr	r5, [r1, #0]
322035f2:	0792      	lsls	r2, r2, #30
322035f4:	600e      	str	r6, [r1, #0]
322035f6:	bf18      	it	ne
322035f8:	2300      	movne	r3, #0
322035fa:	eba5 0506 	sub.w	r5, r5, r6
322035fe:	d100      	bne.n	32203602 <__sflush_r+0xca>
32203600:	694b      	ldr	r3, [r1, #20]
32203602:	2d00      	cmp	r5, #0
32203604:	60a3      	str	r3, [r4, #8]
32203606:	dc04      	bgt.n	32203612 <__sflush_r+0xda>
32203608:	e7ec      	b.n	322035e4 <__sflush_r+0xac>
3220360a:	1a2d      	subs	r5, r5, r0
3220360c:	4406      	add	r6, r0
3220360e:	2d00      	cmp	r5, #0
32203610:	dde8      	ble.n	322035e4 <__sflush_r+0xac>
32203612:	69e1      	ldr	r1, [r4, #28]
32203614:	462b      	mov	r3, r5
32203616:	6a67      	ldr	r7, [r4, #36]	@ 0x24
32203618:	4632      	mov	r2, r6
3220361a:	4640      	mov	r0, r8
3220361c:	47b8      	blx	r7
3220361e:	2800      	cmp	r0, #0
32203620:	dcf3      	bgt.n	3220360a <__sflush_r+0xd2>
32203622:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32203626:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
3220362a:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3220362e:	81a3      	strh	r3, [r4, #12]
32203630:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
32203634:	6be1      	ldr	r1, [r4, #60]	@ 0x3c
32203636:	2900      	cmp	r1, #0
32203638:	dc8c      	bgt.n	32203554 <__sflush_r+0x1c>
3220363a:	e7d3      	b.n	322035e4 <__sflush_r+0xac>
3220363c:	6d22      	ldr	r2, [r4, #80]	@ 0x50
3220363e:	e79e      	b.n	3220357e <__sflush_r+0x46>
32203640:	6922      	ldr	r2, [r4, #16]
32203642:	6022      	str	r2, [r4, #0]
32203644:	f423 6200 	bic.w	r2, r3, #2048	@ 0x800
32203648:	04db      	lsls	r3, r3, #19
3220364a:	81a2      	strh	r2, [r4, #12]
3220364c:	f04f 0200 	mov.w	r2, #0
32203650:	6062      	str	r2, [r4, #4]
32203652:	d5ba      	bpl.n	322035ca <__sflush_r+0x92>
32203654:	6520      	str	r0, [r4, #80]	@ 0x50
32203656:	e7b8      	b.n	322035ca <__sflush_r+0x92>
32203658:	f8d8 3000 	ldr.w	r3, [r8]
3220365c:	2b00      	cmp	r3, #0
3220365e:	d08b      	beq.n	32203578 <__sflush_r+0x40>
32203660:	2b1d      	cmp	r3, #29
32203662:	bf18      	it	ne
32203664:	2b16      	cmpne	r3, #22
32203666:	d1dc      	bne.n	32203622 <__sflush_r+0xea>
32203668:	f8c8 5000 	str.w	r5, [r8]
3220366c:	e7ba      	b.n	322035e4 <__sflush_r+0xac>
3220366e:	bf00      	nop

32203670 <_fflush_r>:
32203670:	b538      	push	{r3, r4, r5, lr}
32203672:	460c      	mov	r4, r1
32203674:	4605      	mov	r5, r0
32203676:	b108      	cbz	r0, 3220367c <_fflush_r+0xc>
32203678:	6b43      	ldr	r3, [r0, #52]	@ 0x34
3220367a:	b303      	cbz	r3, 322036be <_fflush_r+0x4e>
3220367c:	f9b4 000c 	ldrsh.w	r0, [r4, #12]
32203680:	b188      	cbz	r0, 322036a6 <_fflush_r+0x36>
32203682:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32203684:	07db      	lsls	r3, r3, #31
32203686:	d401      	bmi.n	3220368c <_fflush_r+0x1c>
32203688:	0581      	lsls	r1, r0, #22
3220368a:	d50f      	bpl.n	322036ac <_fflush_r+0x3c>
3220368c:	4628      	mov	r0, r5
3220368e:	4621      	mov	r1, r4
32203690:	f7ff ff52 	bl	32203538 <__sflush_r>
32203694:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32203696:	4605      	mov	r5, r0
32203698:	07da      	lsls	r2, r3, #31
3220369a:	d402      	bmi.n	322036a2 <_fflush_r+0x32>
3220369c:	89a3      	ldrh	r3, [r4, #12]
3220369e:	059b      	lsls	r3, r3, #22
322036a0:	d508      	bpl.n	322036b4 <_fflush_r+0x44>
322036a2:	4628      	mov	r0, r5
322036a4:	bd38      	pop	{r3, r4, r5, pc}
322036a6:	4605      	mov	r5, r0
322036a8:	4628      	mov	r0, r5
322036aa:	bd38      	pop	{r3, r4, r5, pc}
322036ac:	6da0      	ldr	r0, [r4, #88]	@ 0x58
322036ae:	f001 fb53 	bl	32204d58 <__retarget_lock_acquire_recursive>
322036b2:	e7eb      	b.n	3220368c <_fflush_r+0x1c>
322036b4:	6da0      	ldr	r0, [r4, #88]	@ 0x58
322036b6:	f001 fb57 	bl	32204d68 <__retarget_lock_release_recursive>
322036ba:	4628      	mov	r0, r5
322036bc:	bd38      	pop	{r3, r4, r5, pc}
322036be:	f000 f98d 	bl	322039dc <__sinit>
322036c2:	e7db      	b.n	3220367c <_fflush_r+0xc>

322036c4 <fflush>:
322036c4:	b368      	cbz	r0, 32203722 <fflush+0x5e>
322036c6:	b538      	push	{r3, r4, r5, lr}
322036c8:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
322036cc:	f2c3 2320 	movt	r3, #12832	@ 0x3220
322036d0:	4604      	mov	r4, r0
322036d2:	681d      	ldr	r5, [r3, #0]
322036d4:	b10d      	cbz	r5, 322036da <fflush+0x16>
322036d6:	6b6b      	ldr	r3, [r5, #52]	@ 0x34
322036d8:	b1bb      	cbz	r3, 3220370a <fflush+0x46>
322036da:	f9b4 000c 	ldrsh.w	r0, [r4, #12]
322036de:	b188      	cbz	r0, 32203704 <fflush+0x40>
322036e0:	6e63      	ldr	r3, [r4, #100]	@ 0x64
322036e2:	07db      	lsls	r3, r3, #31
322036e4:	d401      	bmi.n	322036ea <fflush+0x26>
322036e6:	0581      	lsls	r1, r0, #22
322036e8:	d513      	bpl.n	32203712 <fflush+0x4e>
322036ea:	4628      	mov	r0, r5
322036ec:	4621      	mov	r1, r4
322036ee:	f7ff ff23 	bl	32203538 <__sflush_r>
322036f2:	6e63      	ldr	r3, [r4, #100]	@ 0x64
322036f4:	4605      	mov	r5, r0
322036f6:	07da      	lsls	r2, r3, #31
322036f8:	d402      	bmi.n	32203700 <fflush+0x3c>
322036fa:	89a3      	ldrh	r3, [r4, #12]
322036fc:	059b      	lsls	r3, r3, #22
322036fe:	d50c      	bpl.n	3220371a <fflush+0x56>
32203700:	4628      	mov	r0, r5
32203702:	bd38      	pop	{r3, r4, r5, pc}
32203704:	4605      	mov	r5, r0
32203706:	4628      	mov	r0, r5
32203708:	bd38      	pop	{r3, r4, r5, pc}
3220370a:	4628      	mov	r0, r5
3220370c:	f000 f966 	bl	322039dc <__sinit>
32203710:	e7e3      	b.n	322036da <fflush+0x16>
32203712:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32203714:	f001 fb20 	bl	32204d58 <__retarget_lock_acquire_recursive>
32203718:	e7e7      	b.n	322036ea <fflush+0x26>
3220371a:	6da0      	ldr	r0, [r4, #88]	@ 0x58
3220371c:	f001 fb24 	bl	32204d68 <__retarget_lock_release_recursive>
32203720:	e7ee      	b.n	32203700 <fflush+0x3c>
32203722:	f24c 1248 	movw	r2, #49480	@ 0xc148
32203726:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220372a:	f243 6171 	movw	r1, #13937	@ 0x3671
3220372e:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32203732:	f24c 30d8 	movw	r0, #50136	@ 0xc3d8
32203736:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220373a:	f000 bb27 	b.w	32203d8c <_fwalk_sglue>
3220373e:	bf00      	nop

32203740 <stdio_exit_handler>:
32203740:	f24c 1248 	movw	r2, #49480	@ 0xc148
32203744:	f2c3 2220 	movt	r2, #12832	@ 0x3220
32203748:	f249 2191 	movw	r1, #37521	@ 0x9291
3220374c:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32203750:	f24c 30d8 	movw	r0, #50136	@ 0xc3d8
32203754:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32203758:	f000 bb18 	b.w	32203d8c <_fwalk_sglue>

3220375c <cleanup_stdio>:
3220375c:	6841      	ldr	r1, [r0, #4]
3220375e:	f245 0340 	movw	r3, #20544	@ 0x5040
32203762:	f2c3 2321 	movt	r3, #12833	@ 0x3221
32203766:	b510      	push	{r4, lr}
32203768:	4299      	cmp	r1, r3
3220376a:	4604      	mov	r4, r0
3220376c:	d001      	beq.n	32203772 <cleanup_stdio+0x16>
3220376e:	f005 fd8f 	bl	32209290 <_fclose_r>
32203772:	68a1      	ldr	r1, [r4, #8]
32203774:	4b07      	ldr	r3, [pc, #28]	@ (32203794 <cleanup_stdio+0x38>)
32203776:	4299      	cmp	r1, r3
32203778:	d002      	beq.n	32203780 <cleanup_stdio+0x24>
3220377a:	4620      	mov	r0, r4
3220377c:	f005 fd88 	bl	32209290 <_fclose_r>
32203780:	68e1      	ldr	r1, [r4, #12]
32203782:	4b05      	ldr	r3, [pc, #20]	@ (32203798 <cleanup_stdio+0x3c>)
32203784:	4299      	cmp	r1, r3
32203786:	d004      	beq.n	32203792 <cleanup_stdio+0x36>
32203788:	4620      	mov	r0, r4
3220378a:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
3220378e:	f005 bd7f 	b.w	32209290 <_fclose_r>
32203792:	bd10      	pop	{r4, pc}
32203794:	322150a8 	.word	0x322150a8
32203798:	32215110 	.word	0x32215110

3220379c <__fp_lock>:
3220379c:	b508      	push	{r3, lr}
3220379e:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
322037a0:	07da      	lsls	r2, r3, #31
322037a2:	d402      	bmi.n	322037aa <__fp_lock+0xe>
322037a4:	898b      	ldrh	r3, [r1, #12]
322037a6:	059b      	lsls	r3, r3, #22
322037a8:	d501      	bpl.n	322037ae <__fp_lock+0x12>
322037aa:	2000      	movs	r0, #0
322037ac:	bd08      	pop	{r3, pc}
322037ae:	6d88      	ldr	r0, [r1, #88]	@ 0x58
322037b0:	f001 fad2 	bl	32204d58 <__retarget_lock_acquire_recursive>
322037b4:	2000      	movs	r0, #0
322037b6:	bd08      	pop	{r3, pc}

322037b8 <__fp_unlock>:
322037b8:	b508      	push	{r3, lr}
322037ba:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
322037bc:	07da      	lsls	r2, r3, #31
322037be:	d402      	bmi.n	322037c6 <__fp_unlock+0xe>
322037c0:	898b      	ldrh	r3, [r1, #12]
322037c2:	059b      	lsls	r3, r3, #22
322037c4:	d501      	bpl.n	322037ca <__fp_unlock+0x12>
322037c6:	2000      	movs	r0, #0
322037c8:	bd08      	pop	{r3, pc}
322037ca:	6d88      	ldr	r0, [r1, #88]	@ 0x58
322037cc:	f001 facc 	bl	32204d68 <__retarget_lock_release_recursive>
322037d0:	2000      	movs	r0, #0
322037d2:	bd08      	pop	{r3, pc}

322037d4 <global_stdio_init.part.0>:
322037d4:	b530      	push	{r4, r5, lr}
322037d6:	f245 0440 	movw	r4, #20544	@ 0x5040
322037da:	f2c3 2421 	movt	r4, #12833	@ 0x3221
322037de:	ed2d 8b02 	vpush	{d8}
322037e2:	4623      	mov	r3, r4
322037e4:	ed2d ab04 	vpush	{d10-d11}
322037e8:	b085      	sub	sp, #20
322037ea:	ef80 8010 	vmov.i32	d8, #0	@ 0x00000000
322037ee:	f104 0014 	add.w	r0, r4, #20
322037f2:	f245 1278 	movw	r2, #20856	@ 0x5178
322037f6:	f2c3 2221 	movt	r2, #12833	@ 0x3221
322037fa:	f643 61e9 	movw	r1, #16105	@ 0x3ee9
322037fe:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32203802:	9100      	str	r1, [sp, #0]
32203804:	f643 7111 	movw	r1, #16145	@ 0x3f11
32203808:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220380c:	9101      	str	r1, [sp, #4]
3220380e:	f643 7151 	movw	r1, #16209	@ 0x3f51
32203812:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32203816:	9102      	str	r1, [sp, #8]
32203818:	f643 7179 	movw	r1, #16249	@ 0x3f79
3220381c:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32203820:	9103      	str	r1, [sp, #12]
32203822:	f92d aadf 	vld1.64	{d10-d11}, [sp :64]
32203826:	2500      	movs	r5, #0
32203828:	f843 5b04 	str.w	r5, [r3], #4
3220382c:	f243 7141 	movw	r1, #14145	@ 0x3741
32203830:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32203834:	f900 878f 	vst1.32	{d8}, [r0]
32203838:	6011      	str	r1, [r2, #0]
3220383a:	f104 005c 	add.w	r0, r4, #92	@ 0x5c
3220383e:	4629      	mov	r1, r5
32203840:	2204      	movs	r2, #4
32203842:	60e2      	str	r2, [r4, #12]
32203844:	2208      	movs	r2, #8
32203846:	f903 878f 	vst1.32	{d8}, [r3]
3220384a:	6665      	str	r5, [r4, #100]	@ 0x64
3220384c:	6125      	str	r5, [r4, #16]
3220384e:	f000 fc8b 	bl	32204168 <memset>
32203852:	f104 0058 	add.w	r0, r4, #88	@ 0x58
32203856:	61e4      	str	r4, [r4, #28]
32203858:	ed84 ab08 	vstr	d10, [r4, #32]
3220385c:	ed84 bb0a 	vstr	d11, [r4, #40]	@ 0x28
32203860:	f001 fa72 	bl	32204d48 <__retarget_lock_init_recursive>
32203864:	f104 006c 	add.w	r0, r4, #108	@ 0x6c
32203868:	f104 017c 	add.w	r1, r4, #124	@ 0x7c
3220386c:	2208      	movs	r2, #8
3220386e:	66a5      	str	r5, [r4, #104]	@ 0x68
32203870:	2309      	movs	r3, #9
32203872:	f2c0 0301 	movt	r3, #1
32203876:	f900 878f 	vst1.32	{d8}, [r0]
3220387a:	f901 878f 	vst1.32	{d8}, [r1]
3220387e:	f104 00c4 	add.w	r0, r4, #196	@ 0xc4
32203882:	4629      	mov	r1, r5
32203884:	6763      	str	r3, [r4, #116]	@ 0x74
32203886:	f8c4 50cc 	str.w	r5, [r4, #204]	@ 0xcc
3220388a:	67a5      	str	r5, [r4, #120]	@ 0x78
3220388c:	f000 fc6c 	bl	32204168 <memset>
32203890:	f104 00c0 	add.w	r0, r4, #192	@ 0xc0
32203894:	f104 0368 	add.w	r3, r4, #104	@ 0x68
32203898:	ed84 ab22 	vstr	d10, [r4, #136]	@ 0x88
3220389c:	ed84 bb24 	vstr	d11, [r4, #144]	@ 0x90
322038a0:	f8c4 3084 	str.w	r3, [r4, #132]	@ 0x84
322038a4:	f001 fa50 	bl	32204d48 <__retarget_lock_init_recursive>
322038a8:	f104 00e4 	add.w	r0, r4, #228	@ 0xe4
322038ac:	f104 0cd4 	add.w	ip, r4, #212	@ 0xd4
322038b0:	2208      	movs	r2, #8
322038b2:	4629      	mov	r1, r5
322038b4:	f8c4 50d0 	str.w	r5, [r4, #208]	@ 0xd0
322038b8:	2312      	movs	r3, #18
322038ba:	f2c0 0302 	movt	r3, #2
322038be:	f900 878f 	vst1.32	{d8}, [r0]
322038c2:	f504 7096 	add.w	r0, r4, #300	@ 0x12c
322038c6:	f8c4 30dc 	str.w	r3, [r4, #220]	@ 0xdc
322038ca:	f8c4 5134 	str.w	r5, [r4, #308]	@ 0x134
322038ce:	f8c4 50e0 	str.w	r5, [r4, #224]	@ 0xe0
322038d2:	f90c 878f 	vst1.32	{d8}, [ip]
322038d6:	f000 fc47 	bl	32204168 <memset>
322038da:	f104 03d0 	add.w	r3, r4, #208	@ 0xd0
322038de:	f504 7094 	add.w	r0, r4, #296	@ 0x128
322038e2:	f8c4 30ec 	str.w	r3, [r4, #236]	@ 0xec
322038e6:	ed84 ab3c 	vstr	d10, [r4, #240]	@ 0xf0
322038ea:	ed84 bb3e 	vstr	d11, [r4, #248]	@ 0xf8
322038ee:	b005      	add	sp, #20
322038f0:	ecbd ab04 	vpop	{d10-d11}
322038f4:	ecbd 8b02 	vpop	{d8}
322038f8:	e8bd 4030 	ldmia.w	sp!, {r4, r5, lr}
322038fc:	f001 ba24 	b.w	32204d48 <__retarget_lock_init_recursive>

32203900 <__sfp>:
32203900:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
32203902:	4607      	mov	r7, r0
32203904:	f245 3064 	movw	r0, #21348	@ 0x5364
32203908:	f2c3 2021 	movt	r0, #12833	@ 0x3221
3220390c:	f001 fa24 	bl	32204d58 <__retarget_lock_acquire_recursive>
32203910:	f245 1378 	movw	r3, #20856	@ 0x5178
32203914:	f2c3 2321 	movt	r3, #12833	@ 0x3221
32203918:	681b      	ldr	r3, [r3, #0]
3220391a:	2b00      	cmp	r3, #0
3220391c:	d050      	beq.n	322039c0 <__sfp+0xc0>
3220391e:	f24c 1648 	movw	r6, #49480	@ 0xc148
32203922:	f2c3 2620 	movt	r6, #12832	@ 0x3220
32203926:	e9d6 3401 	ldrd	r3, r4, [r6, #4]
3220392a:	3b01      	subs	r3, #1
3220392c:	d503      	bpl.n	32203936 <__sfp+0x36>
3220392e:	e02e      	b.n	3220398e <__sfp+0x8e>
32203930:	3468      	adds	r4, #104	@ 0x68
32203932:	1c5a      	adds	r2, r3, #1
32203934:	d02b      	beq.n	3220398e <__sfp+0x8e>
32203936:	f9b4 500c 	ldrsh.w	r5, [r4, #12]
3220393a:	3b01      	subs	r3, #1
3220393c:	2d00      	cmp	r5, #0
3220393e:	d1f7      	bne.n	32203930 <__sfp+0x30>
32203940:	f104 0058 	add.w	r0, r4, #88	@ 0x58
32203944:	2301      	movs	r3, #1
32203946:	f6cf 73ff 	movt	r3, #65535	@ 0xffff
3220394a:	6665      	str	r5, [r4, #100]	@ 0x64
3220394c:	60e3      	str	r3, [r4, #12]
3220394e:	f001 f9fb 	bl	32204d48 <__retarget_lock_init_recursive>
32203952:	f245 3064 	movw	r0, #21348	@ 0x5364
32203956:	f2c3 2021 	movt	r0, #12833	@ 0x3221
3220395a:	f001 fa05 	bl	32204d68 <__retarget_lock_release_recursive>
3220395e:	4621      	mov	r1, r4
32203960:	efc0 0010 	vmov.i32	d16, #0	@ 0x00000000
32203964:	f104 0314 	add.w	r3, r4, #20
32203968:	2208      	movs	r2, #8
3220396a:	f104 005c 	add.w	r0, r4, #92	@ 0x5c
3220396e:	f841 5b04 	str.w	r5, [r1], #4
32203972:	f941 078f 	vst1.32	{d16}, [r1]
32203976:	4629      	mov	r1, r5
32203978:	6125      	str	r5, [r4, #16]
3220397a:	f943 078f 	vst1.32	{d16}, [r3]
3220397e:	f000 fbf3 	bl	32204168 <memset>
32203982:	e9c4 550c 	strd	r5, r5, [r4, #48]	@ 0x30
32203986:	e9c4 5511 	strd	r5, r5, [r4, #68]	@ 0x44
3220398a:	4620      	mov	r0, r4
3220398c:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3220398e:	6835      	ldr	r5, [r6, #0]
32203990:	b10d      	cbz	r5, 32203996 <__sfp+0x96>
32203992:	462e      	mov	r6, r5
32203994:	e7c7      	b.n	32203926 <__sfp+0x26>
32203996:	f44f 71d6 	mov.w	r1, #428	@ 0x1ac
3220399a:	4638      	mov	r0, r7
3220399c:	f002 f8f4 	bl	32205b88 <_malloc_r>
322039a0:	4604      	mov	r4, r0
322039a2:	b180      	cbz	r0, 322039c6 <__sfp+0xc6>
322039a4:	6005      	str	r5, [r0, #0]
322039a6:	2304      	movs	r3, #4
322039a8:	4629      	mov	r1, r5
322039aa:	6043      	str	r3, [r0, #4]
322039ac:	f44f 72d0 	mov.w	r2, #416	@ 0x1a0
322039b0:	300c      	adds	r0, #12
322039b2:	4625      	mov	r5, r4
322039b4:	60a0      	str	r0, [r4, #8]
322039b6:	f000 fbd7 	bl	32204168 <memset>
322039ba:	6034      	str	r4, [r6, #0]
322039bc:	462e      	mov	r6, r5
322039be:	e7b2      	b.n	32203926 <__sfp+0x26>
322039c0:	f7ff ff08 	bl	322037d4 <global_stdio_init.part.0>
322039c4:	e7ab      	b.n	3220391e <__sfp+0x1e>
322039c6:	6030      	str	r0, [r6, #0]
322039c8:	f245 3064 	movw	r0, #21348	@ 0x5364
322039cc:	f2c3 2021 	movt	r0, #12833	@ 0x3221
322039d0:	f001 f9ca 	bl	32204d68 <__retarget_lock_release_recursive>
322039d4:	230c      	movs	r3, #12
322039d6:	603b      	str	r3, [r7, #0]
322039d8:	e7d7      	b.n	3220398a <__sfp+0x8a>
322039da:	bf00      	nop

322039dc <__sinit>:
322039dc:	b510      	push	{r4, lr}
322039de:	4604      	mov	r4, r0
322039e0:	f245 3064 	movw	r0, #21348	@ 0x5364
322039e4:	f2c3 2021 	movt	r0, #12833	@ 0x3221
322039e8:	f001 f9b6 	bl	32204d58 <__retarget_lock_acquire_recursive>
322039ec:	6b63      	ldr	r3, [r4, #52]	@ 0x34
322039ee:	b953      	cbnz	r3, 32203a06 <__sinit+0x2a>
322039f0:	f245 1378 	movw	r3, #20856	@ 0x5178
322039f4:	f2c3 2321 	movt	r3, #12833	@ 0x3221
322039f8:	f243 725d 	movw	r2, #14173	@ 0x375d
322039fc:	f2c3 2220 	movt	r2, #12832	@ 0x3220
32203a00:	6362      	str	r2, [r4, #52]	@ 0x34
32203a02:	681b      	ldr	r3, [r3, #0]
32203a04:	b13b      	cbz	r3, 32203a16 <__sinit+0x3a>
32203a06:	f245 3064 	movw	r0, #21348	@ 0x5364
32203a0a:	f2c3 2021 	movt	r0, #12833	@ 0x3221
32203a0e:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
32203a12:	f001 b9a9 	b.w	32204d68 <__retarget_lock_release_recursive>
32203a16:	f7ff fedd 	bl	322037d4 <global_stdio_init.part.0>
32203a1a:	f245 3064 	movw	r0, #21348	@ 0x5364
32203a1e:	f2c3 2021 	movt	r0, #12833	@ 0x3221
32203a22:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
32203a26:	f001 b99f 	b.w	32204d68 <__retarget_lock_release_recursive>
32203a2a:	bf00      	nop

32203a2c <__sfp_lock_acquire>:
32203a2c:	f245 3064 	movw	r0, #21348	@ 0x5364
32203a30:	f2c3 2021 	movt	r0, #12833	@ 0x3221
32203a34:	f001 b990 	b.w	32204d58 <__retarget_lock_acquire_recursive>

32203a38 <__sfp_lock_release>:
32203a38:	f245 3064 	movw	r0, #21348	@ 0x5364
32203a3c:	f2c3 2021 	movt	r0, #12833	@ 0x3221
32203a40:	f001 b992 	b.w	32204d68 <__retarget_lock_release_recursive>

32203a44 <__fp_lock_all>:
32203a44:	b508      	push	{r3, lr}
32203a46:	f245 3064 	movw	r0, #21348	@ 0x5364
32203a4a:	f2c3 2021 	movt	r0, #12833	@ 0x3221
32203a4e:	f001 f983 	bl	32204d58 <__retarget_lock_acquire_recursive>
32203a52:	f24c 1248 	movw	r2, #49480	@ 0xc148
32203a56:	f2c3 2220 	movt	r2, #12832	@ 0x3220
32203a5a:	f243 719d 	movw	r1, #14237	@ 0x379d
32203a5e:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32203a62:	2000      	movs	r0, #0
32203a64:	e8bd 4008 	ldmia.w	sp!, {r3, lr}
32203a68:	f000 b990 	b.w	32203d8c <_fwalk_sglue>

32203a6c <__fp_unlock_all>:
32203a6c:	b508      	push	{r3, lr}
32203a6e:	2000      	movs	r0, #0
32203a70:	f24c 1248 	movw	r2, #49480	@ 0xc148
32203a74:	f2c3 2220 	movt	r2, #12832	@ 0x3220
32203a78:	f243 71b9 	movw	r1, #14265	@ 0x37b9
32203a7c:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32203a80:	f000 f984 	bl	32203d8c <_fwalk_sglue>
32203a84:	f245 3064 	movw	r0, #21348	@ 0x5364
32203a88:	f2c3 2021 	movt	r0, #12833	@ 0x3221
32203a8c:	e8bd 4008 	ldmia.w	sp!, {r3, lr}
32203a90:	f001 b96a 	b.w	32204d68 <__retarget_lock_release_recursive>

32203a94 <__sfvwrite_r>:
32203a94:	6893      	ldr	r3, [r2, #8]
32203a96:	2b00      	cmp	r3, #0
32203a98:	f000 80bb 	beq.w	32203c12 <__sfvwrite_r+0x17e>
32203a9c:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32203aa0:	4617      	mov	r7, r2
32203aa2:	f9b1 c00c 	ldrsh.w	ip, [r1, #12]
32203aa6:	b083      	sub	sp, #12
32203aa8:	4680      	mov	r8, r0
32203aaa:	460c      	mov	r4, r1
32203aac:	f01c 0f08 	tst.w	ip, #8
32203ab0:	d029      	beq.n	32203b06 <__sfvwrite_r+0x72>
32203ab2:	690b      	ldr	r3, [r1, #16]
32203ab4:	b33b      	cbz	r3, 32203b06 <__sfvwrite_r+0x72>
32203ab6:	683d      	ldr	r5, [r7, #0]
32203ab8:	f01c 0302 	ands.w	r3, ip, #2
32203abc:	d02f      	beq.n	32203b1e <__sfvwrite_r+0x8a>
32203abe:	f04f 0a00 	mov.w	sl, #0
32203ac2:	f44f 4b7c 	mov.w	fp, #64512	@ 0xfc00
32203ac6:	f6c7 7bff 	movt	fp, #32767	@ 0x7fff
32203aca:	4656      	mov	r6, sl
32203acc:	46b9      	mov	r9, r7
32203ace:	455e      	cmp	r6, fp
32203ad0:	4633      	mov	r3, r6
32203ad2:	4652      	mov	r2, sl
32203ad4:	bf28      	it	cs
32203ad6:	465b      	movcs	r3, fp
32203ad8:	4640      	mov	r0, r8
32203ada:	2e00      	cmp	r6, #0
32203adc:	f000 8087 	beq.w	32203bee <__sfvwrite_r+0x15a>
32203ae0:	69e1      	ldr	r1, [r4, #28]
32203ae2:	6a67      	ldr	r7, [r4, #36]	@ 0x24
32203ae4:	47b8      	blx	r7
32203ae6:	2800      	cmp	r0, #0
32203ae8:	f340 808b 	ble.w	32203c02 <__sfvwrite_r+0x16e>
32203aec:	f8d9 3008 	ldr.w	r3, [r9, #8]
32203af0:	4482      	add	sl, r0
32203af2:	1a36      	subs	r6, r6, r0
32203af4:	1a1b      	subs	r3, r3, r0
32203af6:	f8c9 3008 	str.w	r3, [r9, #8]
32203afa:	2b00      	cmp	r3, #0
32203afc:	d1e7      	bne.n	32203ace <__sfvwrite_r+0x3a>
32203afe:	2000      	movs	r0, #0
32203b00:	b003      	add	sp, #12
32203b02:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32203b06:	4621      	mov	r1, r4
32203b08:	4640      	mov	r0, r8
32203b0a:	f000 fa39 	bl	32203f80 <__swsetup_r>
32203b0e:	2800      	cmp	r0, #0
32203b10:	d17c      	bne.n	32203c0c <__sfvwrite_r+0x178>
32203b12:	f9b4 c00c 	ldrsh.w	ip, [r4, #12]
32203b16:	683d      	ldr	r5, [r7, #0]
32203b18:	f01c 0302 	ands.w	r3, ip, #2
32203b1c:	d1cf      	bne.n	32203abe <__sfvwrite_r+0x2a>
32203b1e:	f01c 0901 	ands.w	r9, ip, #1
32203b22:	d178      	bne.n	32203c16 <__sfvwrite_r+0x182>
32203b24:	464e      	mov	r6, r9
32203b26:	9700      	str	r7, [sp, #0]
32203b28:	2e00      	cmp	r6, #0
32203b2a:	d05c      	beq.n	32203be6 <__sfvwrite_r+0x152>
32203b2c:	6820      	ldr	r0, [r4, #0]
32203b2e:	f41c 7f00 	tst.w	ip, #512	@ 0x200
32203b32:	f8d4 b008 	ldr.w	fp, [r4, #8]
32203b36:	f000 80bd 	beq.w	32203cb4 <__sfvwrite_r+0x220>
32203b3a:	465a      	mov	r2, fp
32203b3c:	45b3      	cmp	fp, r6
32203b3e:	f200 80eb 	bhi.w	32203d18 <__sfvwrite_r+0x284>
32203b42:	f41c 6f90 	tst.w	ip, #1152	@ 0x480
32203b46:	d034      	beq.n	32203bb2 <__sfvwrite_r+0x11e>
32203b48:	6962      	ldr	r2, [r4, #20]
32203b4a:	6921      	ldr	r1, [r4, #16]
32203b4c:	eb02 0242 	add.w	r2, r2, r2, lsl #1
32203b50:	eba0 0a01 	sub.w	sl, r0, r1
32203b54:	f10a 0301 	add.w	r3, sl, #1
32203b58:	eb02 72d2 	add.w	r2, r2, r2, lsr #31
32203b5c:	4433      	add	r3, r6
32203b5e:	1052      	asrs	r2, r2, #1
32203b60:	4293      	cmp	r3, r2
32203b62:	bf98      	it	ls
32203b64:	4693      	movls	fp, r2
32203b66:	bf88      	it	hi
32203b68:	469b      	movhi	fp, r3
32203b6a:	bf88      	it	hi
32203b6c:	461a      	movhi	r2, r3
32203b6e:	f41c 6f80 	tst.w	ip, #1024	@ 0x400
32203b72:	f000 80ef 	beq.w	32203d54 <__sfvwrite_r+0x2c0>
32203b76:	4611      	mov	r1, r2
32203b78:	4640      	mov	r0, r8
32203b7a:	f002 f805 	bl	32205b88 <_malloc_r>
32203b7e:	2800      	cmp	r0, #0
32203b80:	f000 80fe 	beq.w	32203d80 <__sfvwrite_r+0x2ec>
32203b84:	4652      	mov	r2, sl
32203b86:	6921      	ldr	r1, [r4, #16]
32203b88:	9001      	str	r0, [sp, #4]
32203b8a:	f001 eb5a 	blx	32205240 <memcpy>
32203b8e:	89a2      	ldrh	r2, [r4, #12]
32203b90:	9b01      	ldr	r3, [sp, #4]
32203b92:	f422 6290 	bic.w	r2, r2, #1152	@ 0x480
32203b96:	f042 0280 	orr.w	r2, r2, #128	@ 0x80
32203b9a:	81a2      	strh	r2, [r4, #12]
32203b9c:	eb03 000a 	add.w	r0, r3, sl
32203ba0:	6123      	str	r3, [r4, #16]
32203ba2:	f8c4 b014 	str.w	fp, [r4, #20]
32203ba6:	ebab 030a 	sub.w	r3, fp, sl
32203baa:	4632      	mov	r2, r6
32203bac:	46b3      	mov	fp, r6
32203bae:	60a3      	str	r3, [r4, #8]
32203bb0:	6020      	str	r0, [r4, #0]
32203bb2:	4649      	mov	r1, r9
32203bb4:	9201      	str	r2, [sp, #4]
32203bb6:	f000 fa59 	bl	3220406c <memmove>
32203bba:	68a3      	ldr	r3, [r4, #8]
32203bbc:	9a01      	ldr	r2, [sp, #4]
32203bbe:	46b2      	mov	sl, r6
32203bc0:	eba3 010b 	sub.w	r1, r3, fp
32203bc4:	6823      	ldr	r3, [r4, #0]
32203bc6:	2600      	movs	r6, #0
32203bc8:	60a1      	str	r1, [r4, #8]
32203bca:	4413      	add	r3, r2
32203bcc:	6023      	str	r3, [r4, #0]
32203bce:	9a00      	ldr	r2, [sp, #0]
32203bd0:	44d1      	add	r9, sl
32203bd2:	6893      	ldr	r3, [r2, #8]
32203bd4:	eba3 030a 	sub.w	r3, r3, sl
32203bd8:	6093      	str	r3, [r2, #8]
32203bda:	2b00      	cmp	r3, #0
32203bdc:	d08f      	beq.n	32203afe <__sfvwrite_r+0x6a>
32203bde:	f9b4 c00c 	ldrsh.w	ip, [r4, #12]
32203be2:	2e00      	cmp	r6, #0
32203be4:	d1a2      	bne.n	32203b2c <__sfvwrite_r+0x98>
32203be6:	e9d5 9600 	ldrd	r9, r6, [r5]
32203bea:	3508      	adds	r5, #8
32203bec:	e79c      	b.n	32203b28 <__sfvwrite_r+0x94>
32203bee:	e9d5 a600 	ldrd	sl, r6, [r5]
32203bf2:	3508      	adds	r5, #8
32203bf4:	e76b      	b.n	32203ace <__sfvwrite_r+0x3a>
32203bf6:	4621      	mov	r1, r4
32203bf8:	4640      	mov	r0, r8
32203bfa:	f7ff fd39 	bl	32203670 <_fflush_r>
32203bfe:	2800      	cmp	r0, #0
32203c00:	d036      	beq.n	32203c70 <__sfvwrite_r+0x1dc>
32203c02:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32203c06:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32203c0a:	81a3      	strh	r3, [r4, #12]
32203c0c:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32203c10:	e776      	b.n	32203b00 <__sfvwrite_r+0x6c>
32203c12:	2000      	movs	r0, #0
32203c14:	4770      	bx	lr
32203c16:	46ba      	mov	sl, r7
32203c18:	4699      	mov	r9, r3
32203c1a:	4618      	mov	r0, r3
32203c1c:	461e      	mov	r6, r3
32203c1e:	461f      	mov	r7, r3
32203c20:	9500      	str	r5, [sp, #0]
32203c22:	2e00      	cmp	r6, #0
32203c24:	d032      	beq.n	32203c8c <__sfvwrite_r+0x1f8>
32203c26:	2800      	cmp	r0, #0
32203c28:	d039      	beq.n	32203c9e <__sfvwrite_r+0x20a>
32203c2a:	464a      	mov	r2, r9
32203c2c:	68a1      	ldr	r1, [r4, #8]
32203c2e:	42b2      	cmp	r2, r6
32203c30:	6963      	ldr	r3, [r4, #20]
32203c32:	bf28      	it	cs
32203c34:	4632      	movcs	r2, r6
32203c36:	6820      	ldr	r0, [r4, #0]
32203c38:	eb03 0b01 	add.w	fp, r3, r1
32203c3c:	6921      	ldr	r1, [r4, #16]
32203c3e:	4288      	cmp	r0, r1
32203c40:	bf98      	it	ls
32203c42:	2100      	movls	r1, #0
32203c44:	bf88      	it	hi
32203c46:	2101      	movhi	r1, #1
32203c48:	455a      	cmp	r2, fp
32203c4a:	bfd8      	it	le
32203c4c:	2100      	movle	r1, #0
32203c4e:	2900      	cmp	r1, #0
32203c50:	d172      	bne.n	32203d38 <__sfvwrite_r+0x2a4>
32203c52:	4293      	cmp	r3, r2
32203c54:	dc63      	bgt.n	32203d1e <__sfvwrite_r+0x28a>
32203c56:	69e1      	ldr	r1, [r4, #28]
32203c58:	463a      	mov	r2, r7
32203c5a:	6a65      	ldr	r5, [r4, #36]	@ 0x24
32203c5c:	4640      	mov	r0, r8
32203c5e:	47a8      	blx	r5
32203c60:	f1b0 0b00 	subs.w	fp, r0, #0
32203c64:	ddcd      	ble.n	32203c02 <__sfvwrite_r+0x16e>
32203c66:	ebb9 090b 	subs.w	r9, r9, fp
32203c6a:	bf18      	it	ne
32203c6c:	2001      	movne	r0, #1
32203c6e:	d0c2      	beq.n	32203bf6 <__sfvwrite_r+0x162>
32203c70:	f8da 3008 	ldr.w	r3, [sl, #8]
32203c74:	445f      	add	r7, fp
32203c76:	eba6 060b 	sub.w	r6, r6, fp
32203c7a:	eba3 030b 	sub.w	r3, r3, fp
32203c7e:	f8ca 3008 	str.w	r3, [sl, #8]
32203c82:	2b00      	cmp	r3, #0
32203c84:	f43f af3b 	beq.w	32203afe <__sfvwrite_r+0x6a>
32203c88:	2e00      	cmp	r6, #0
32203c8a:	d1cc      	bne.n	32203c26 <__sfvwrite_r+0x192>
32203c8c:	9a00      	ldr	r2, [sp, #0]
32203c8e:	4613      	mov	r3, r2
32203c90:	3208      	adds	r2, #8
32203c92:	f852 6c04 	ldr.w	r6, [r2, #-4]
32203c96:	9200      	str	r2, [sp, #0]
32203c98:	2e00      	cmp	r6, #0
32203c9a:	d0f7      	beq.n	32203c8c <__sfvwrite_r+0x1f8>
32203c9c:	681f      	ldr	r7, [r3, #0]
32203c9e:	4632      	mov	r2, r6
32203ca0:	210a      	movs	r1, #10
32203ca2:	4638      	mov	r0, r7
32203ca4:	f001 fa44 	bl	32205130 <memchr>
32203ca8:	2800      	cmp	r0, #0
32203caa:	d066      	beq.n	32203d7a <__sfvwrite_r+0x2e6>
32203cac:	3001      	adds	r0, #1
32203cae:	eba0 0907 	sub.w	r9, r0, r7
32203cb2:	e7ba      	b.n	32203c2a <__sfvwrite_r+0x196>
32203cb4:	6923      	ldr	r3, [r4, #16]
32203cb6:	4283      	cmp	r3, r0
32203cb8:	d316      	bcc.n	32203ce8 <__sfvwrite_r+0x254>
32203cba:	6962      	ldr	r2, [r4, #20]
32203cbc:	42b2      	cmp	r2, r6
32203cbe:	d813      	bhi.n	32203ce8 <__sfvwrite_r+0x254>
32203cc0:	f06f 4300 	mvn.w	r3, #2147483648	@ 0x80000000
32203cc4:	69e1      	ldr	r1, [r4, #28]
32203cc6:	42b3      	cmp	r3, r6
32203cc8:	6a67      	ldr	r7, [r4, #36]	@ 0x24
32203cca:	bf28      	it	cs
32203ccc:	4633      	movcs	r3, r6
32203cce:	4640      	mov	r0, r8
32203cd0:	fb93 f3f2 	sdiv	r3, r3, r2
32203cd4:	fb02 f303 	mul.w	r3, r2, r3
32203cd8:	464a      	mov	r2, r9
32203cda:	47b8      	blx	r7
32203cdc:	f1b0 0a00 	subs.w	sl, r0, #0
32203ce0:	dd8f      	ble.n	32203c02 <__sfvwrite_r+0x16e>
32203ce2:	eba6 060a 	sub.w	r6, r6, sl
32203ce6:	e772      	b.n	32203bce <__sfvwrite_r+0x13a>
32203ce8:	45b3      	cmp	fp, r6
32203cea:	46da      	mov	sl, fp
32203cec:	bf28      	it	cs
32203cee:	46b2      	movcs	sl, r6
32203cf0:	4649      	mov	r1, r9
32203cf2:	4652      	mov	r2, sl
32203cf4:	f000 f9ba 	bl	3220406c <memmove>
32203cf8:	68a3      	ldr	r3, [r4, #8]
32203cfa:	6822      	ldr	r2, [r4, #0]
32203cfc:	eba3 030a 	sub.w	r3, r3, sl
32203d00:	60a3      	str	r3, [r4, #8]
32203d02:	4452      	add	r2, sl
32203d04:	6022      	str	r2, [r4, #0]
32203d06:	2b00      	cmp	r3, #0
32203d08:	d1eb      	bne.n	32203ce2 <__sfvwrite_r+0x24e>
32203d0a:	4621      	mov	r1, r4
32203d0c:	4640      	mov	r0, r8
32203d0e:	f7ff fcaf 	bl	32203670 <_fflush_r>
32203d12:	2800      	cmp	r0, #0
32203d14:	d0e5      	beq.n	32203ce2 <__sfvwrite_r+0x24e>
32203d16:	e774      	b.n	32203c02 <__sfvwrite_r+0x16e>
32203d18:	46b3      	mov	fp, r6
32203d1a:	4632      	mov	r2, r6
32203d1c:	e749      	b.n	32203bb2 <__sfvwrite_r+0x11e>
32203d1e:	4639      	mov	r1, r7
32203d20:	9201      	str	r2, [sp, #4]
32203d22:	f000 f9a3 	bl	3220406c <memmove>
32203d26:	9a01      	ldr	r2, [sp, #4]
32203d28:	68a3      	ldr	r3, [r4, #8]
32203d2a:	4693      	mov	fp, r2
32203d2c:	1a9b      	subs	r3, r3, r2
32203d2e:	60a3      	str	r3, [r4, #8]
32203d30:	6823      	ldr	r3, [r4, #0]
32203d32:	4413      	add	r3, r2
32203d34:	6023      	str	r3, [r4, #0]
32203d36:	e796      	b.n	32203c66 <__sfvwrite_r+0x1d2>
32203d38:	4639      	mov	r1, r7
32203d3a:	465a      	mov	r2, fp
32203d3c:	f000 f996 	bl	3220406c <memmove>
32203d40:	6823      	ldr	r3, [r4, #0]
32203d42:	4621      	mov	r1, r4
32203d44:	4640      	mov	r0, r8
32203d46:	445b      	add	r3, fp
32203d48:	6023      	str	r3, [r4, #0]
32203d4a:	f7ff fc91 	bl	32203670 <_fflush_r>
32203d4e:	2800      	cmp	r0, #0
32203d50:	d089      	beq.n	32203c66 <__sfvwrite_r+0x1d2>
32203d52:	e756      	b.n	32203c02 <__sfvwrite_r+0x16e>
32203d54:	4640      	mov	r0, r8
32203d56:	f002 fc75 	bl	32206644 <_realloc_r>
32203d5a:	4603      	mov	r3, r0
32203d5c:	2800      	cmp	r0, #0
32203d5e:	f47f af1d 	bne.w	32203b9c <__sfvwrite_r+0x108>
32203d62:	6921      	ldr	r1, [r4, #16]
32203d64:	4640      	mov	r0, r8
32203d66:	f001 fdbf 	bl	322058e8 <_free_r>
32203d6a:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32203d6e:	220c      	movs	r2, #12
32203d70:	f8c8 2000 	str.w	r2, [r8]
32203d74:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32203d78:	e745      	b.n	32203c06 <__sfvwrite_r+0x172>
32203d7a:	1c72      	adds	r2, r6, #1
32203d7c:	4691      	mov	r9, r2
32203d7e:	e755      	b.n	32203c2c <__sfvwrite_r+0x198>
32203d80:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32203d84:	220c      	movs	r2, #12
32203d86:	f8c8 2000 	str.w	r2, [r8]
32203d8a:	e73c      	b.n	32203c06 <__sfvwrite_r+0x172>

32203d8c <_fwalk_sglue>:
32203d8c:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
32203d90:	4607      	mov	r7, r0
32203d92:	4688      	mov	r8, r1
32203d94:	4616      	mov	r6, r2
32203d96:	f04f 0900 	mov.w	r9, #0
32203d9a:	e9d6 5401 	ldrd	r5, r4, [r6, #4]
32203d9e:	3d01      	subs	r5, #1
32203da0:	d40f      	bmi.n	32203dc2 <_fwalk_sglue+0x36>
32203da2:	89a3      	ldrh	r3, [r4, #12]
32203da4:	2b01      	cmp	r3, #1
32203da6:	d908      	bls.n	32203dba <_fwalk_sglue+0x2e>
32203da8:	f9b4 300e 	ldrsh.w	r3, [r4, #14]
32203dac:	4621      	mov	r1, r4
32203dae:	4638      	mov	r0, r7
32203db0:	3301      	adds	r3, #1
32203db2:	d002      	beq.n	32203dba <_fwalk_sglue+0x2e>
32203db4:	47c0      	blx	r8
32203db6:	ea49 0900 	orr.w	r9, r9, r0
32203dba:	3d01      	subs	r5, #1
32203dbc:	3468      	adds	r4, #104	@ 0x68
32203dbe:	1c6b      	adds	r3, r5, #1
32203dc0:	d1ef      	bne.n	32203da2 <_fwalk_sglue+0x16>
32203dc2:	6836      	ldr	r6, [r6, #0]
32203dc4:	2e00      	cmp	r6, #0
32203dc6:	d1e8      	bne.n	32203d9a <_fwalk_sglue+0xe>
32203dc8:	4648      	mov	r0, r9
32203dca:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
32203dce:	bf00      	nop

32203dd0 <_printf_r>:
32203dd0:	b40e      	push	{r1, r2, r3}
32203dd2:	6881      	ldr	r1, [r0, #8]
32203dd4:	b500      	push	{lr}
32203dd6:	b082      	sub	sp, #8
32203dd8:	ab03      	add	r3, sp, #12
32203dda:	f853 2b04 	ldr.w	r2, [r3], #4
32203dde:	9301      	str	r3, [sp, #4]
32203de0:	f003 f8ca 	bl	32206f78 <_vfprintf_r>
32203de4:	b002      	add	sp, #8
32203de6:	f85d eb04 	ldr.w	lr, [sp], #4
32203dea:	b003      	add	sp, #12
32203dec:	4770      	bx	lr
32203dee:	bf00      	nop

32203df0 <printf>:
32203df0:	b40f      	push	{r0, r1, r2, r3}
32203df2:	f24c 32d0 	movw	r2, #50128	@ 0xc3d0
32203df6:	f2c3 2220 	movt	r2, #12832	@ 0x3220
32203dfa:	b500      	push	{lr}
32203dfc:	b083      	sub	sp, #12
32203dfe:	6810      	ldr	r0, [r2, #0]
32203e00:	ab04      	add	r3, sp, #16
32203e02:	6881      	ldr	r1, [r0, #8]
32203e04:	f853 2b04 	ldr.w	r2, [r3], #4
32203e08:	9301      	str	r3, [sp, #4]
32203e0a:	f003 f8b5 	bl	32206f78 <_vfprintf_r>
32203e0e:	b003      	add	sp, #12
32203e10:	f85d eb04 	ldr.w	lr, [sp], #4
32203e14:	b004      	add	sp, #16
32203e16:	4770      	bx	lr

32203e18 <_puts_r>:
32203e18:	b530      	push	{r4, r5, lr}
32203e1a:	4605      	mov	r5, r0
32203e1c:	4608      	mov	r0, r1
32203e1e:	b089      	sub	sp, #36	@ 0x24
32203e20:	460c      	mov	r4, r1
32203e22:	f001 fc8d 	bl	32205740 <strlen>
32203e26:	6b6a      	ldr	r2, [r5, #52]	@ 0x34
32203e28:	2101      	movs	r1, #1
32203e2a:	f64b 2320 	movw	r3, #47648	@ 0xba20
32203e2e:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32203e32:	e9cd 4004 	strd	r4, r0, [sp, #16]
32203e36:	e9cd 3106 	strd	r3, r1, [sp, #24]
32203e3a:	4408      	add	r0, r1
32203e3c:	2302      	movs	r3, #2
32203e3e:	a904      	add	r1, sp, #16
32203e40:	68ac      	ldr	r4, [r5, #8]
32203e42:	9003      	str	r0, [sp, #12]
32203e44:	e9cd 1301 	strd	r1, r3, [sp, #4]
32203e48:	2a00      	cmp	r2, #0
32203e4a:	d040      	beq.n	32203ece <_puts_r+0xb6>
32203e4c:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32203e4e:	f9b4 200c 	ldrsh.w	r2, [r4, #12]
32203e52:	07d8      	lsls	r0, r3, #31
32203e54:	d51a      	bpl.n	32203e8c <_puts_r+0x74>
32203e56:	0491      	lsls	r1, r2, #18
32203e58:	d421      	bmi.n	32203e9e <_puts_r+0x86>
32203e5a:	f442 5200 	orr.w	r2, r2, #8192	@ 0x2000
32203e5e:	f423 5300 	bic.w	r3, r3, #8192	@ 0x2000
32203e62:	81a2      	strh	r2, [r4, #12]
32203e64:	6663      	str	r3, [r4, #100]	@ 0x64
32203e66:	4628      	mov	r0, r5
32203e68:	aa01      	add	r2, sp, #4
32203e6a:	4621      	mov	r1, r4
32203e6c:	f04f 35ff 	mov.w	r5, #4294967295	@ 0xffffffff
32203e70:	f7ff fe10 	bl	32203a94 <__sfvwrite_r>
32203e74:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32203e76:	2800      	cmp	r0, #0
32203e78:	bf08      	it	eq
32203e7a:	250a      	moveq	r5, #10
32203e7c:	07da      	lsls	r2, r3, #31
32203e7e:	d402      	bmi.n	32203e86 <_puts_r+0x6e>
32203e80:	89a3      	ldrh	r3, [r4, #12]
32203e82:	059b      	lsls	r3, r3, #22
32203e84:	d510      	bpl.n	32203ea8 <_puts_r+0x90>
32203e86:	4628      	mov	r0, r5
32203e88:	b009      	add	sp, #36	@ 0x24
32203e8a:	bd30      	pop	{r4, r5, pc}
32203e8c:	0590      	lsls	r0, r2, #22
32203e8e:	d511      	bpl.n	32203eb4 <_puts_r+0x9c>
32203e90:	0491      	lsls	r1, r2, #18
32203e92:	d5e2      	bpl.n	32203e5a <_puts_r+0x42>
32203e94:	049b      	lsls	r3, r3, #18
32203e96:	d5e6      	bpl.n	32203e66 <_puts_r+0x4e>
32203e98:	f04f 35ff 	mov.w	r5, #4294967295	@ 0xffffffff
32203e9c:	e7f0      	b.n	32203e80 <_puts_r+0x68>
32203e9e:	049b      	lsls	r3, r3, #18
32203ea0:	d5e1      	bpl.n	32203e66 <_puts_r+0x4e>
32203ea2:	f04f 35ff 	mov.w	r5, #4294967295	@ 0xffffffff
32203ea6:	e7ee      	b.n	32203e86 <_puts_r+0x6e>
32203ea8:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32203eaa:	f000 ff5d 	bl	32204d68 <__retarget_lock_release_recursive>
32203eae:	4628      	mov	r0, r5
32203eb0:	b009      	add	sp, #36	@ 0x24
32203eb2:	bd30      	pop	{r4, r5, pc}
32203eb4:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32203eb6:	f000 ff4f 	bl	32204d58 <__retarget_lock_acquire_recursive>
32203eba:	f9b4 200c 	ldrsh.w	r2, [r4, #12]
32203ebe:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32203ec0:	0490      	lsls	r0, r2, #18
32203ec2:	d5ca      	bpl.n	32203e5a <_puts_r+0x42>
32203ec4:	0499      	lsls	r1, r3, #18
32203ec6:	d5ce      	bpl.n	32203e66 <_puts_r+0x4e>
32203ec8:	f04f 35ff 	mov.w	r5, #4294967295	@ 0xffffffff
32203ecc:	e7d6      	b.n	32203e7c <_puts_r+0x64>
32203ece:	4628      	mov	r0, r5
32203ed0:	f7ff fd84 	bl	322039dc <__sinit>
32203ed4:	e7ba      	b.n	32203e4c <_puts_r+0x34>
32203ed6:	bf00      	nop

32203ed8 <puts>:
32203ed8:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
32203edc:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32203ee0:	4601      	mov	r1, r0
32203ee2:	6818      	ldr	r0, [r3, #0]
32203ee4:	f7ff bf98 	b.w	32203e18 <_puts_r>

32203ee8 <__sread>:
32203ee8:	b510      	push	{r4, lr}
32203eea:	460c      	mov	r4, r1
32203eec:	f9b1 100e 	ldrsh.w	r1, [r1, #14]
32203ef0:	f000 fef2 	bl	32204cd8 <_read_r>
32203ef4:	2800      	cmp	r0, #0
32203ef6:	db03      	blt.n	32203f00 <__sread+0x18>
32203ef8:	6d23      	ldr	r3, [r4, #80]	@ 0x50
32203efa:	4403      	add	r3, r0
32203efc:	6523      	str	r3, [r4, #80]	@ 0x50
32203efe:	bd10      	pop	{r4, pc}
32203f00:	89a3      	ldrh	r3, [r4, #12]
32203f02:	f423 5380 	bic.w	r3, r3, #4096	@ 0x1000
32203f06:	81a3      	strh	r3, [r4, #12]
32203f08:	bd10      	pop	{r4, pc}
32203f0a:	bf00      	nop

32203f0c <__seofread>:
32203f0c:	2000      	movs	r0, #0
32203f0e:	4770      	bx	lr

32203f10 <__swrite>:
32203f10:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
32203f14:	460c      	mov	r4, r1
32203f16:	f9b1 100c 	ldrsh.w	r1, [r1, #12]
32203f1a:	461f      	mov	r7, r3
32203f1c:	4605      	mov	r5, r0
32203f1e:	4616      	mov	r6, r2
32203f20:	05cb      	lsls	r3, r1, #23
32203f22:	d40b      	bmi.n	32203f3c <__swrite+0x2c>
32203f24:	f421 5180 	bic.w	r1, r1, #4096	@ 0x1000
32203f28:	463b      	mov	r3, r7
32203f2a:	81a1      	strh	r1, [r4, #12]
32203f2c:	4632      	mov	r2, r6
32203f2e:	f9b4 100e 	ldrsh.w	r1, [r4, #14]
32203f32:	4628      	mov	r0, r5
32203f34:	e8bd 41f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, lr}
32203f38:	f000 bee6 	b.w	32204d08 <_write_r>
32203f3c:	f9b4 100e 	ldrsh.w	r1, [r4, #14]
32203f40:	2302      	movs	r3, #2
32203f42:	2200      	movs	r2, #0
32203f44:	f000 feb0 	bl	32204ca8 <_lseek_r>
32203f48:	f9b4 100c 	ldrsh.w	r1, [r4, #12]
32203f4c:	e7ea      	b.n	32203f24 <__swrite+0x14>
32203f4e:	bf00      	nop

32203f50 <__sseek>:
32203f50:	b510      	push	{r4, lr}
32203f52:	460c      	mov	r4, r1
32203f54:	f9b1 100e 	ldrsh.w	r1, [r1, #14]
32203f58:	f000 fea6 	bl	32204ca8 <_lseek_r>
32203f5c:	1c42      	adds	r2, r0, #1
32203f5e:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32203f62:	d004      	beq.n	32203f6e <__sseek+0x1e>
32203f64:	f443 5380 	orr.w	r3, r3, #4096	@ 0x1000
32203f68:	6520      	str	r0, [r4, #80]	@ 0x50
32203f6a:	81a3      	strh	r3, [r4, #12]
32203f6c:	bd10      	pop	{r4, pc}
32203f6e:	f423 5380 	bic.w	r3, r3, #4096	@ 0x1000
32203f72:	81a3      	strh	r3, [r4, #12]
32203f74:	bd10      	pop	{r4, pc}
32203f76:	bf00      	nop

32203f78 <__sclose>:
32203f78:	f9b1 100e 	ldrsh.w	r1, [r1, #14]
32203f7c:	f000 be48 	b.w	32204c10 <_close_r>

32203f80 <__swsetup_r>:
32203f80:	b538      	push	{r3, r4, r5, lr}
32203f82:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
32203f86:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32203f8a:	4605      	mov	r5, r0
32203f8c:	460c      	mov	r4, r1
32203f8e:	6818      	ldr	r0, [r3, #0]
32203f90:	b110      	cbz	r0, 32203f98 <__swsetup_r+0x18>
32203f92:	6b42      	ldr	r2, [r0, #52]	@ 0x34
32203f94:	2a00      	cmp	r2, #0
32203f96:	d058      	beq.n	3220404a <__swsetup_r+0xca>
32203f98:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32203f9c:	0719      	lsls	r1, r3, #28
32203f9e:	d50b      	bpl.n	32203fb8 <__swsetup_r+0x38>
32203fa0:	6922      	ldr	r2, [r4, #16]
32203fa2:	b19a      	cbz	r2, 32203fcc <__swsetup_r+0x4c>
32203fa4:	f013 0201 	ands.w	r2, r3, #1
32203fa8:	d01b      	beq.n	32203fe2 <__swsetup_r+0x62>
32203faa:	6963      	ldr	r3, [r4, #20]
32203fac:	2200      	movs	r2, #0
32203fae:	60a2      	str	r2, [r4, #8]
32203fb0:	425b      	negs	r3, r3
32203fb2:	61a3      	str	r3, [r4, #24]
32203fb4:	2000      	movs	r0, #0
32203fb6:	bd38      	pop	{r3, r4, r5, pc}
32203fb8:	06da      	lsls	r2, r3, #27
32203fba:	d54e      	bpl.n	3220405a <__swsetup_r+0xda>
32203fbc:	0758      	lsls	r0, r3, #29
32203fbe:	d415      	bmi.n	32203fec <__swsetup_r+0x6c>
32203fc0:	6922      	ldr	r2, [r4, #16]
32203fc2:	f043 0308 	orr.w	r3, r3, #8
32203fc6:	81a3      	strh	r3, [r4, #12]
32203fc8:	2a00      	cmp	r2, #0
32203fca:	d1eb      	bne.n	32203fa4 <__swsetup_r+0x24>
32203fcc:	0599      	lsls	r1, r3, #22
32203fce:	d525      	bpl.n	3220401c <__swsetup_r+0x9c>
32203fd0:	0618      	lsls	r0, r3, #24
32203fd2:	d423      	bmi.n	3220401c <__swsetup_r+0x9c>
32203fd4:	07d9      	lsls	r1, r3, #31
32203fd6:	d51d      	bpl.n	32204014 <__swsetup_r+0x94>
32203fd8:	6963      	ldr	r3, [r4, #20]
32203fda:	60a2      	str	r2, [r4, #8]
32203fdc:	425b      	negs	r3, r3
32203fde:	61a3      	str	r3, [r4, #24]
32203fe0:	e7e8      	b.n	32203fb4 <__swsetup_r+0x34>
32203fe2:	079b      	lsls	r3, r3, #30
32203fe4:	d418      	bmi.n	32204018 <__swsetup_r+0x98>
32203fe6:	6963      	ldr	r3, [r4, #20]
32203fe8:	60a3      	str	r3, [r4, #8]
32203fea:	e7e3      	b.n	32203fb4 <__swsetup_r+0x34>
32203fec:	6b21      	ldr	r1, [r4, #48]	@ 0x30
32203fee:	b151      	cbz	r1, 32204006 <__swsetup_r+0x86>
32203ff0:	f104 0240 	add.w	r2, r4, #64	@ 0x40
32203ff4:	4291      	cmp	r1, r2
32203ff6:	d004      	beq.n	32204002 <__swsetup_r+0x82>
32203ff8:	4628      	mov	r0, r5
32203ffa:	f001 fc75 	bl	322058e8 <_free_r>
32203ffe:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32204002:	2200      	movs	r2, #0
32204004:	6322      	str	r2, [r4, #48]	@ 0x30
32204006:	6922      	ldr	r2, [r4, #16]
32204008:	2100      	movs	r1, #0
3220400a:	f023 0324 	bic.w	r3, r3, #36	@ 0x24
3220400e:	e9c4 2100 	strd	r2, r1, [r4]
32204012:	e7d6      	b.n	32203fc2 <__swsetup_r+0x42>
32204014:	079d      	lsls	r5, r3, #30
32204016:	d51d      	bpl.n	32204054 <__swsetup_r+0xd4>
32204018:	60a2      	str	r2, [r4, #8]
3220401a:	e7cb      	b.n	32203fb4 <__swsetup_r+0x34>
3220401c:	4621      	mov	r1, r4
3220401e:	4628      	mov	r0, r5
32204020:	f005 f9a0 	bl	32209364 <__smakebuf_r>
32204024:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32204028:	6922      	ldr	r2, [r4, #16]
3220402a:	f013 0101 	ands.w	r1, r3, #1
3220402e:	d00f      	beq.n	32204050 <__swsetup_r+0xd0>
32204030:	6961      	ldr	r1, [r4, #20]
32204032:	2000      	movs	r0, #0
32204034:	60a0      	str	r0, [r4, #8]
32204036:	4249      	negs	r1, r1
32204038:	61a1      	str	r1, [r4, #24]
3220403a:	2a00      	cmp	r2, #0
3220403c:	d1ba      	bne.n	32203fb4 <__swsetup_r+0x34>
3220403e:	061a      	lsls	r2, r3, #24
32204040:	d5b8      	bpl.n	32203fb4 <__swsetup_r+0x34>
32204042:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32204046:	81a3      	strh	r3, [r4, #12]
32204048:	e00c      	b.n	32204064 <__swsetup_r+0xe4>
3220404a:	f7ff fcc7 	bl	322039dc <__sinit>
3220404e:	e7a3      	b.n	32203f98 <__swsetup_r+0x18>
32204050:	0798      	lsls	r0, r3, #30
32204052:	d400      	bmi.n	32204056 <__swsetup_r+0xd6>
32204054:	6961      	ldr	r1, [r4, #20]
32204056:	60a1      	str	r1, [r4, #8]
32204058:	e7ef      	b.n	3220403a <__swsetup_r+0xba>
3220405a:	2209      	movs	r2, #9
3220405c:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32204060:	602a      	str	r2, [r5, #0]
32204062:	81a3      	strh	r3, [r4, #12]
32204064:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32204068:	bd38      	pop	{r3, r4, r5, pc}
3220406a:	bf00      	nop

3220406c <memmove>:
3220406c:	4288      	cmp	r0, r1
3220406e:	d90d      	bls.n	3220408c <memmove+0x20>
32204070:	188b      	adds	r3, r1, r2
32204072:	4283      	cmp	r3, r0
32204074:	d90a      	bls.n	3220408c <memmove+0x20>
32204076:	eb00 0c02 	add.w	ip, r0, r2
3220407a:	b35a      	cbz	r2, 322040d4 <memmove+0x68>
3220407c:	4662      	mov	r2, ip
3220407e:	f813 cd01 	ldrb.w	ip, [r3, #-1]!
32204082:	f802 cd01 	strb.w	ip, [r2, #-1]!
32204086:	4299      	cmp	r1, r3
32204088:	d1f9      	bne.n	3220407e <memmove+0x12>
3220408a:	4770      	bx	lr
3220408c:	2a0f      	cmp	r2, #15
3220408e:	d80d      	bhi.n	322040ac <memmove+0x40>
32204090:	f102 3cff 	add.w	ip, r2, #4294967295	@ 0xffffffff
32204094:	b1f2      	cbz	r2, 322040d4 <memmove+0x68>
32204096:	f10c 0c01 	add.w	ip, ip, #1
3220409a:	1e43      	subs	r3, r0, #1
3220409c:	448c      	add	ip, r1
3220409e:	f811 2b01 	ldrb.w	r2, [r1], #1
322040a2:	f803 2f01 	strb.w	r2, [r3, #1]!
322040a6:	4561      	cmp	r1, ip
322040a8:	d1f9      	bne.n	3220409e <memmove+0x32>
322040aa:	4770      	bx	lr
322040ac:	ea40 0301 	orr.w	r3, r0, r1
322040b0:	b5f0      	push	{r4, r5, r6, r7, lr}
322040b2:	460c      	mov	r4, r1
322040b4:	079b      	lsls	r3, r3, #30
322040b6:	d00e      	beq.n	322040d6 <memmove+0x6a>
322040b8:	f102 3cff 	add.w	ip, r2, #4294967295	@ 0xffffffff
322040bc:	4603      	mov	r3, r0
322040be:	f10c 0c01 	add.w	ip, ip, #1
322040c2:	3b01      	subs	r3, #1
322040c4:	448c      	add	ip, r1
322040c6:	f811 2b01 	ldrb.w	r2, [r1], #1
322040ca:	f803 2f01 	strb.w	r2, [r3, #1]!
322040ce:	4561      	cmp	r1, ip
322040d0:	d1f9      	bne.n	322040c6 <memmove+0x5a>
322040d2:	bdf0      	pop	{r4, r5, r6, r7, pc}
322040d4:	4770      	bx	lr
322040d6:	f1a2 0510 	sub.w	r5, r2, #16
322040da:	f101 0e20 	add.w	lr, r1, #32
322040de:	f025 050f 	bic.w	r5, r5, #15
322040e2:	f101 0310 	add.w	r3, r1, #16
322040e6:	44ae      	add	lr, r5
322040e8:	f100 0c10 	add.w	ip, r0, #16
322040ec:	f853 6c10 	ldr.w	r6, [r3, #-16]
322040f0:	3310      	adds	r3, #16
322040f2:	f84c 6c10 	str.w	r6, [ip, #-16]
322040f6:	f10c 0c10 	add.w	ip, ip, #16
322040fa:	4573      	cmp	r3, lr
322040fc:	f853 6c1c 	ldr.w	r6, [r3, #-28]
32204100:	f84c 6c1c 	str.w	r6, [ip, #-28]
32204104:	f853 6c18 	ldr.w	r6, [r3, #-24]
32204108:	f84c 6c18 	str.w	r6, [ip, #-24]
3220410c:	f853 6c14 	ldr.w	r6, [r3, #-20]
32204110:	f84c 6c14 	str.w	r6, [ip, #-20]
32204114:	d1ea      	bne.n	322040ec <memmove+0x80>
32204116:	eb01 0c05 	add.w	ip, r1, r5
3220411a:	4405      	add	r5, r0
3220411c:	f105 0310 	add.w	r3, r5, #16
32204120:	f10c 0110 	add.w	r1, ip, #16
32204124:	f002 050f 	and.w	r5, r2, #15
32204128:	f012 0f0c 	tst.w	r2, #12
3220412c:	460e      	mov	r6, r1
3220412e:	bf08      	it	eq
32204130:	462a      	moveq	r2, r5
32204132:	d013      	beq.n	3220415c <memmove+0xf0>
32204134:	3d04      	subs	r5, #4
32204136:	eba0 0e04 	sub.w	lr, r0, r4
3220413a:	f025 0403 	bic.w	r4, r5, #3
3220413e:	44a4      	add	ip, r4
32204140:	f10c 0c14 	add.w	ip, ip, #20
32204144:	eb01 050e 	add.w	r5, r1, lr
32204148:	680f      	ldr	r7, [r1, #0]
3220414a:	3104      	adds	r1, #4
3220414c:	4561      	cmp	r1, ip
3220414e:	602f      	str	r7, [r5, #0]
32204150:	d1f8      	bne.n	32204144 <memmove+0xd8>
32204152:	3404      	adds	r4, #4
32204154:	f002 0203 	and.w	r2, r2, #3
32204158:	19a1      	adds	r1, r4, r6
3220415a:	4423      	add	r3, r4
3220415c:	f102 3cff 	add.w	ip, r2, #4294967295	@ 0xffffffff
32204160:	2a00      	cmp	r2, #0
32204162:	d1ac      	bne.n	322040be <memmove+0x52>
32204164:	bdf0      	pop	{r4, r5, r6, r7, pc}
32204166:	bf00      	nop

32204168 <memset>:
32204168:	b530      	push	{r4, r5, lr}
3220416a:	0785      	lsls	r5, r0, #30
3220416c:	d045      	beq.n	322041fa <memset+0x92>
3220416e:	eb00 0e02 	add.w	lr, r0, r2
32204172:	4684      	mov	ip, r0
32204174:	e004      	b.n	32204180 <memset+0x18>
32204176:	f803 1b01 	strb.w	r1, [r3], #1
3220417a:	079c      	lsls	r4, r3, #30
3220417c:	d004      	beq.n	32204188 <memset+0x20>
3220417e:	469c      	mov	ip, r3
32204180:	4663      	mov	r3, ip
32204182:	45f4      	cmp	ip, lr
32204184:	d1f7      	bne.n	32204176 <memset+0xe>
32204186:	bd30      	pop	{r4, r5, pc}
32204188:	3a01      	subs	r2, #1
3220418a:	4402      	add	r2, r0
3220418c:	eba2 020c 	sub.w	r2, r2, ip
32204190:	2a03      	cmp	r2, #3
32204192:	d927      	bls.n	322041e4 <memset+0x7c>
32204194:	b2cc      	uxtb	r4, r1
32204196:	f04f 3501 	mov.w	r5, #16843009	@ 0x1010101
3220419a:	2a0f      	cmp	r2, #15
3220419c:	fb05 f404 	mul.w	r4, r5, r4
322041a0:	eea0 4b90 	vdup.32	q8, r4
322041a4:	d92b      	bls.n	322041fe <memset+0x96>
322041a6:	f1a2 0c10 	sub.w	ip, r2, #16
322041aa:	f103 0510 	add.w	r5, r3, #16
322041ae:	f02c 0c0f 	bic.w	ip, ip, #15
322041b2:	44ac      	add	ip, r5
322041b4:	f943 0a8d 	vst1.32	{d16-d17}, [r3]!
322041b8:	4563      	cmp	r3, ip
322041ba:	d1fb      	bne.n	322041b4 <memset+0x4c>
322041bc:	f002 0e0f 	and.w	lr, r2, #15
322041c0:	f012 0f0c 	tst.w	r2, #12
322041c4:	d017      	beq.n	322041f6 <memset+0x8e>
322041c6:	461a      	mov	r2, r3
322041c8:	eb0e 0503 	add.w	r5, lr, r3
322041cc:	f842 4b04 	str.w	r4, [r2], #4
322041d0:	eba5 0c02 	sub.w	ip, r5, r2
322041d4:	f1bc 0f03 	cmp.w	ip, #3
322041d8:	d8f8      	bhi.n	322041cc <memset+0x64>
322041da:	f00e 0203 	and.w	r2, lr, #3
322041de:	f02e 0e03 	bic.w	lr, lr, #3
322041e2:	4473      	add	r3, lr
322041e4:	2a00      	cmp	r2, #0
322041e6:	d0ce      	beq.n	32204186 <memset+0x1e>
322041e8:	b2c9      	uxtb	r1, r1
322041ea:	441a      	add	r2, r3
322041ec:	f803 1b01 	strb.w	r1, [r3], #1
322041f0:	429a      	cmp	r2, r3
322041f2:	d1fb      	bne.n	322041ec <memset+0x84>
322041f4:	bd30      	pop	{r4, r5, pc}
322041f6:	4672      	mov	r2, lr
322041f8:	e7f4      	b.n	322041e4 <memset+0x7c>
322041fa:	4603      	mov	r3, r0
322041fc:	e7c8      	b.n	32204190 <memset+0x28>
322041fe:	4696      	mov	lr, r2
32204200:	e7e1      	b.n	322041c6 <memset+0x5e>
32204202:	bf00      	nop

32204204 <strncpy>:
32204204:	ea40 0301 	orr.w	r3, r0, r1
32204208:	2a03      	cmp	r2, #3
3220420a:	f003 0303 	and.w	r3, r3, #3
3220420e:	4684      	mov	ip, r0
32204210:	fab3 f383 	clz	r3, r3
32204214:	b510      	push	{r4, lr}
32204216:	ea4f 1353 	mov.w	r3, r3, lsr #5
3220421a:	bf98      	it	ls
3220421c:	2300      	movls	r3, #0
3220421e:	b9b3      	cbnz	r3, 3220424e <strncpy+0x4a>
32204220:	f101 3eff 	add.w	lr, r1, #4294967295	@ 0xffffffff
32204224:	e007      	b.n	32204236 <strncpy+0x32>
32204226:	f81e 1f01 	ldrb.w	r1, [lr, #1]!
3220422a:	1e54      	subs	r4, r2, #1
3220422c:	f803 1b01 	strb.w	r1, [r3], #1
32204230:	b129      	cbz	r1, 3220423e <strncpy+0x3a>
32204232:	469c      	mov	ip, r3
32204234:	4622      	mov	r2, r4
32204236:	4663      	mov	r3, ip
32204238:	2a00      	cmp	r2, #0
3220423a:	d1f4      	bne.n	32204226 <strncpy+0x22>
3220423c:	bd10      	pop	{r4, pc}
3220423e:	4494      	add	ip, r2
32204240:	2c00      	cmp	r4, #0
32204242:	d0fb      	beq.n	3220423c <strncpy+0x38>
32204244:	f803 1b01 	strb.w	r1, [r3], #1
32204248:	4563      	cmp	r3, ip
3220424a:	d1fb      	bne.n	32204244 <strncpy+0x40>
3220424c:	bd10      	pop	{r4, pc}
3220424e:	468e      	mov	lr, r1
32204250:	f8de 4000 	ldr.w	r4, [lr]
32204254:	4671      	mov	r1, lr
32204256:	f10e 0e04 	add.w	lr, lr, #4
3220425a:	f1a4 3301 	sub.w	r3, r4, #16843009	@ 0x1010101
3220425e:	ea23 0304 	bic.w	r3, r3, r4
32204262:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
32204266:	d1db      	bne.n	32204220 <strncpy+0x1c>
32204268:	3a04      	subs	r2, #4
3220426a:	f84c 4b04 	str.w	r4, [ip], #4
3220426e:	2a03      	cmp	r2, #3
32204270:	d8ee      	bhi.n	32204250 <strncpy+0x4c>
32204272:	4671      	mov	r1, lr
32204274:	e7d4      	b.n	32204220 <strncpy+0x1c>
32204276:	bf00      	nop

32204278 <currentlocale>:
32204278:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
3220427a:	f24c 1058 	movw	r0, #49496	@ 0xc158
3220427e:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32204282:	4d16      	ldr	r5, [pc, #88]	@ (322042dc <currentlocale+0x64>)
32204284:	4916      	ldr	r1, [pc, #88]	@ (322042e0 <currentlocale+0x68>)
32204286:	f105 06a0 	add.w	r6, r5, #160	@ 0xa0
3220428a:	462c      	mov	r4, r5
3220428c:	f000 fee8 	bl	32205060 <strcpy>
32204290:	4621      	mov	r1, r4
32204292:	4813      	ldr	r0, [pc, #76]	@ (322042e0 <currentlocale+0x68>)
32204294:	3420      	adds	r4, #32
32204296:	f000 fd73 	bl	32204d80 <strcmp>
3220429a:	b930      	cbnz	r0, 322042aa <currentlocale+0x32>
3220429c:	42b4      	cmp	r4, r6
3220429e:	d1f7      	bne.n	32204290 <currentlocale+0x18>
322042a0:	f24c 1058 	movw	r0, #49496	@ 0xc158
322042a4:	f2c3 2020 	movt	r0, #12832	@ 0x3220
322042a8:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
322042aa:	f64b 2724 	movw	r7, #47652	@ 0xba24
322042ae:	f2c3 2720 	movt	r7, #12832	@ 0x3220
322042b2:	f24c 1458 	movw	r4, #49496	@ 0xc158
322042b6:	f2c3 2420 	movt	r4, #12832	@ 0x3220
322042ba:	4639      	mov	r1, r7
322042bc:	4620      	mov	r0, r4
322042be:	f005 f90f 	bl	322094e0 <strcat>
322042c2:	4629      	mov	r1, r5
322042c4:	4620      	mov	r0, r4
322042c6:	3520      	adds	r5, #32
322042c8:	f005 f90a 	bl	322094e0 <strcat>
322042cc:	42b5      	cmp	r5, r6
322042ce:	d1f4      	bne.n	322042ba <currentlocale+0x42>
322042d0:	f24c 1058 	movw	r0, #49496	@ 0xc158
322042d4:	f2c3 2020 	movt	r0, #12832	@ 0x3220
322042d8:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
322042da:	bf00      	nop
322042dc:	3220c280 	.word	0x3220c280
322042e0:	3220c260 	.word	0x3220c260

322042e4 <__loadlocale>:
322042e4:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
322042e8:	eb00 1741 	add.w	r7, r0, r1, lsl #5
322042ec:	460e      	mov	r6, r1
322042ee:	b08f      	sub	sp, #60	@ 0x3c
322042f0:	4605      	mov	r5, r0
322042f2:	4639      	mov	r1, r7
322042f4:	4610      	mov	r0, r2
322042f6:	4614      	mov	r4, r2
322042f8:	f000 fd42 	bl	32204d80 <strcmp>
322042fc:	b918      	cbnz	r0, 32204306 <__loadlocale+0x22>
322042fe:	4638      	mov	r0, r7
32204300:	b00f      	add	sp, #60	@ 0x3c
32204302:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32204306:	f64b 2128 	movw	r1, #47656	@ 0xba28
3220430a:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220430e:	4620      	mov	r0, r4
32204310:	f000 fd36 	bl	32204d80 <strcmp>
32204314:	2800      	cmp	r0, #0
32204316:	f000 8089 	beq.w	3220442c <__loadlocale+0x148>
3220431a:	f64b 2130 	movw	r1, #47664	@ 0xba30
3220431e:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204322:	4620      	mov	r0, r4
32204324:	f000 fd2c 	bl	32204d80 <strcmp>
32204328:	2800      	cmp	r0, #0
3220432a:	d075      	beq.n	32204418 <__loadlocale+0x134>
3220432c:	7823      	ldrb	r3, [r4, #0]
3220432e:	2b43      	cmp	r3, #67	@ 0x43
32204330:	d067      	beq.n	32204402 <__loadlocale+0x11e>
32204332:	3b61      	subs	r3, #97	@ 0x61
32204334:	2b19      	cmp	r3, #25
32204336:	d86a      	bhi.n	3220440e <__loadlocale+0x12a>
32204338:	7863      	ldrb	r3, [r4, #1]
3220433a:	3b61      	subs	r3, #97	@ 0x61
3220433c:	2b19      	cmp	r3, #25
3220433e:	d866      	bhi.n	3220440e <__loadlocale+0x12a>
32204340:	78a3      	ldrb	r3, [r4, #2]
32204342:	f104 0902 	add.w	r9, r4, #2
32204346:	f1a3 0261 	sub.w	r2, r3, #97	@ 0x61
3220434a:	2a19      	cmp	r2, #25
3220434c:	d802      	bhi.n	32204354 <__loadlocale+0x70>
3220434e:	78e3      	ldrb	r3, [r4, #3]
32204350:	f104 0903 	add.w	r9, r4, #3
32204354:	2b5f      	cmp	r3, #95	@ 0x5f
32204356:	f000 8085 	beq.w	32204464 <__loadlocale+0x180>
3220435a:	2b2e      	cmp	r3, #46	@ 0x2e
3220435c:	d06e      	beq.n	3220443c <__loadlocale+0x158>
3220435e:	f013 0fbf 	tst.w	r3, #191	@ 0xbf
32204362:	d154      	bne.n	3220440e <__loadlocale+0x12a>
32204364:	f10d 0818 	add.w	r8, sp, #24
32204368:	f64b 213c 	movw	r1, #47676	@ 0xba3c
3220436c:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204370:	4640      	mov	r0, r8
32204372:	f000 fe75 	bl	32205060 <strcpy>
32204376:	f899 3000 	ldrb.w	r3, [r9]
3220437a:	2b40      	cmp	r3, #64	@ 0x40
3220437c:	f000 827a 	beq.w	32204874 <__loadlocale+0x590>
32204380:	f04f 0900 	mov.w	r9, #0
32204384:	f8cd 9004 	str.w	r9, [sp, #4]
32204388:	46cb      	mov	fp, r9
3220438a:	f89d 3018 	ldrb.w	r3, [sp, #24]
3220438e:	3b41      	subs	r3, #65	@ 0x41
32204390:	2b34      	cmp	r3, #52	@ 0x34
32204392:	d83c      	bhi.n	3220440e <__loadlocale+0x12a>
32204394:	e8df f013 	tbh	[pc, r3, lsl #1]
32204398:	003b01cd 	.word	0x003b01cd
3220439c:	003b0198 	.word	0x003b0198
322043a0:	003b016c 	.word	0x003b016c
322043a4:	003b0149 	.word	0x003b0149
322043a8:	012e01df 	.word	0x012e01df
322043ac:	003b0101 	.word	0x003b0101
322043b0:	003b003b 	.word	0x003b003b
322043b4:	00ef003b 	.word	0x00ef003b
322043b8:	003b003b 	.word	0x003b003b
322043bc:	00a900d4 	.word	0x00a900d4
322043c0:	003b0075 	.word	0x003b0075
322043c4:	003b003b 	.word	0x003b003b
322043c8:	003b003b 	.word	0x003b003b
322043cc:	003b003b 	.word	0x003b003b
322043d0:	003b003b 	.word	0x003b003b
322043d4:	003b003b 	.word	0x003b003b
322043d8:	003b01cd 	.word	0x003b01cd
322043dc:	003b0198 	.word	0x003b0198
322043e0:	003b016c 	.word	0x003b016c
322043e4:	003b0149 	.word	0x003b0149
322043e8:	012e01df 	.word	0x012e01df
322043ec:	003b0101 	.word	0x003b0101
322043f0:	003b003b 	.word	0x003b003b
322043f4:	00ef003b 	.word	0x00ef003b
322043f8:	003b003b 	.word	0x003b003b
322043fc:	00a900d4 	.word	0x00a900d4
32204400:	0075      	.short	0x0075
32204402:	7863      	ldrb	r3, [r4, #1]
32204404:	f104 0902 	add.w	r9, r4, #2
32204408:	3b2d      	subs	r3, #45	@ 0x2d
3220440a:	2b01      	cmp	r3, #1
3220440c:	d918      	bls.n	32204440 <__loadlocale+0x15c>
3220440e:	2700      	movs	r7, #0
32204410:	4638      	mov	r0, r7
32204412:	b00f      	add	sp, #60	@ 0x3c
32204414:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32204418:	f10d 0818 	add.w	r8, sp, #24
3220441c:	f64b 2134 	movw	r1, #47668	@ 0xba34
32204420:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204424:	4640      	mov	r0, r8
32204426:	f000 fe1b 	bl	32205060 <strcpy>
3220442a:	e7a9      	b.n	32204380 <__loadlocale+0x9c>
3220442c:	4620      	mov	r0, r4
3220442e:	f64b 2130 	movw	r1, #47664	@ 0xba30
32204432:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204436:	f000 fe13 	bl	32205060 <strcpy>
3220443a:	e76e      	b.n	3220431a <__loadlocale+0x36>
3220443c:	f109 0901 	add.w	r9, r9, #1
32204440:	f10d 0818 	add.w	r8, sp, #24
32204444:	4649      	mov	r1, r9
32204446:	4640      	mov	r0, r8
32204448:	f000 fe0a 	bl	32205060 <strcpy>
3220444c:	2140      	movs	r1, #64	@ 0x40
3220444e:	4640      	mov	r0, r8
32204450:	f005 f866 	bl	32209520 <strchr>
32204454:	b108      	cbz	r0, 3220445a <__loadlocale+0x176>
32204456:	2300      	movs	r3, #0
32204458:	7003      	strb	r3, [r0, #0]
3220445a:	4640      	mov	r0, r8
3220445c:	f001 f970 	bl	32205740 <strlen>
32204460:	4481      	add	r9, r0
32204462:	e788      	b.n	32204376 <__loadlocale+0x92>
32204464:	f899 3001 	ldrb.w	r3, [r9, #1]
32204468:	3b41      	subs	r3, #65	@ 0x41
3220446a:	2b19      	cmp	r3, #25
3220446c:	d8cf      	bhi.n	3220440e <__loadlocale+0x12a>
3220446e:	f899 3002 	ldrb.w	r3, [r9, #2]
32204472:	3b41      	subs	r3, #65	@ 0x41
32204474:	2b19      	cmp	r3, #25
32204476:	d8ca      	bhi.n	3220440e <__loadlocale+0x12a>
32204478:	f899 3003 	ldrb.w	r3, [r9, #3]
3220447c:	f109 0903 	add.w	r9, r9, #3
32204480:	e76b      	b.n	3220435a <__loadlocale+0x76>
32204482:	f64b 2168 	movw	r1, #47720	@ 0xba68
32204486:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220448a:	4640      	mov	r0, r8
3220448c:	f005 f802 	bl	32209494 <strcasecmp>
32204490:	b140      	cbz	r0, 322044a4 <__loadlocale+0x1c0>
32204492:	f64b 2170 	movw	r1, #47728	@ 0xba70
32204496:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220449a:	4640      	mov	r0, r8
3220449c:	f004 fffa 	bl	32209494 <strcasecmp>
322044a0:	2800      	cmp	r0, #0
322044a2:	d1b4      	bne.n	3220440e <__loadlocale+0x12a>
322044a4:	4640      	mov	r0, r8
322044a6:	f64b 2168 	movw	r1, #47720	@ 0xba68
322044aa:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322044ae:	f246 1ab1 	movw	sl, #25009	@ 0x61b1
322044b2:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
322044b6:	f000 fdd3 	bl	32205060 <strcpy>
322044ba:	f646 43ad 	movw	r3, #27821	@ 0x6cad
322044be:	f2c3 2320 	movt	r3, #12832	@ 0x3220
322044c2:	2206      	movs	r2, #6
322044c4:	2e02      	cmp	r6, #2
322044c6:	f000 81a7 	beq.w	32204818 <__loadlocale+0x534>
322044ca:	2e06      	cmp	r6, #6
322044cc:	d104      	bne.n	322044d8 <__loadlocale+0x1f4>
322044ce:	4641      	mov	r1, r8
322044d0:	f505 70a5 	add.w	r0, r5, #330	@ 0x14a
322044d4:	f000 fdc4 	bl	32205060 <strcpy>
322044d8:	4621      	mov	r1, r4
322044da:	4638      	mov	r0, r7
322044dc:	f000 fdc0 	bl	32205060 <strcpy>
322044e0:	4607      	mov	r7, r0
322044e2:	4638      	mov	r0, r7
322044e4:	b00f      	add	sp, #60	@ 0x3c
322044e6:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
322044ea:	f64b 21f8 	movw	r1, #47864	@ 0xbaf8
322044ee:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322044f2:	2203      	movs	r2, #3
322044f4:	4640      	mov	r0, r8
322044f6:	f005 f8a1 	bl	3220963c <strncasecmp>
322044fa:	2800      	cmp	r0, #0
322044fc:	d187      	bne.n	3220440e <__loadlocale+0x12a>
322044fe:	f89d 301b 	ldrb.w	r3, [sp, #27]
32204502:	f10d 001b 	add.w	r0, sp, #27
32204506:	2b2d      	cmp	r3, #45	@ 0x2d
32204508:	d100      	bne.n	3220450c <__loadlocale+0x228>
3220450a:	a807      	add	r0, sp, #28
3220450c:	f64b 21fc 	movw	r1, #47868	@ 0xbafc
32204510:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204514:	f000 fc34 	bl	32204d80 <strcmp>
32204518:	2800      	cmp	r0, #0
3220451a:	f47f af78 	bne.w	3220440e <__loadlocale+0x12a>
3220451e:	f64b 3100 	movw	r1, #47872	@ 0xbb00
32204522:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204526:	4640      	mov	r0, r8
32204528:	f000 fd9a 	bl	32205060 <strcpy>
3220452c:	f246 1a8d 	movw	sl, #24973	@ 0x618d
32204530:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32204534:	f646 4391 	movw	r3, #27793	@ 0x6c91
32204538:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220453c:	2201      	movs	r2, #1
3220453e:	e7c1      	b.n	322044c4 <__loadlocale+0x1e0>
32204540:	f64b 218c 	movw	r1, #47756	@ 0xba8c
32204544:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204548:	4640      	mov	r0, r8
3220454a:	f004 ffa3 	bl	32209494 <strcasecmp>
3220454e:	2800      	cmp	r0, #0
32204550:	f47f af5d 	bne.w	3220440e <__loadlocale+0x12a>
32204554:	f64b 218c 	movw	r1, #47756	@ 0xba8c
32204558:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220455c:	4640      	mov	r0, r8
3220455e:	f000 fd7f 	bl	32205060 <strcpy>
32204562:	f246 3aa9 	movw	sl, #25513	@ 0x63a9
32204566:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
3220456a:	f646 5351 	movw	r3, #27985	@ 0x6d51
3220456e:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32204572:	2202      	movs	r2, #2
32204574:	e7a6      	b.n	322044c4 <__loadlocale+0x1e0>
32204576:	f64b 21e8 	movw	r1, #47848	@ 0xbae8
3220457a:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220457e:	4640      	mov	r0, r8
32204580:	f004 ff88 	bl	32209494 <strcasecmp>
32204584:	2800      	cmp	r0, #0
32204586:	f47f af42 	bne.w	3220440e <__loadlocale+0x12a>
3220458a:	4640      	mov	r0, r8
3220458c:	f64b 21f0 	movw	r1, #47856	@ 0xbaf0
32204590:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204594:	f000 fd64 	bl	32205060 <strcpy>
32204598:	e7c8      	b.n	3220452c <__loadlocale+0x248>
3220459a:	f64b 21b0 	movw	r1, #47792	@ 0xbab0
3220459e:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322045a2:	2204      	movs	r2, #4
322045a4:	4640      	mov	r0, r8
322045a6:	f005 f849 	bl	3220963c <strncasecmp>
322045aa:	2800      	cmp	r0, #0
322045ac:	f47f af2f 	bne.w	3220440e <__loadlocale+0x12a>
322045b0:	f89d 301c 	ldrb.w	r3, [sp, #28]
322045b4:	aa07      	add	r2, sp, #28
322045b6:	2b2d      	cmp	r3, #45	@ 0x2d
322045b8:	d103      	bne.n	322045c2 <__loadlocale+0x2de>
322045ba:	f89d 301d 	ldrb.w	r3, [sp, #29]
322045be:	f10d 021d 	add.w	r2, sp, #29
322045c2:	f003 03df 	and.w	r3, r3, #223	@ 0xdf
322045c6:	2b52      	cmp	r3, #82	@ 0x52
322045c8:	f000 8170 	beq.w	322048ac <__loadlocale+0x5c8>
322045cc:	7813      	ldrb	r3, [r2, #0]
322045ce:	2b74      	cmp	r3, #116	@ 0x74
322045d0:	f000 8178 	beq.w	322048c4 <__loadlocale+0x5e0>
322045d4:	f200 8172 	bhi.w	322048bc <__loadlocale+0x5d8>
322045d8:	2b54      	cmp	r3, #84	@ 0x54
322045da:	f000 8173 	beq.w	322048c4 <__loadlocale+0x5e0>
322045de:	2b55      	cmp	r3, #85	@ 0x55
322045e0:	f47f af15 	bne.w	3220440e <__loadlocale+0x12a>
322045e4:	4640      	mov	r0, r8
322045e6:	f64b 21c0 	movw	r1, #47808	@ 0xbac0
322045ea:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322045ee:	f000 fd37 	bl	32205060 <strcpy>
322045f2:	e79b      	b.n	3220452c <__loadlocale+0x248>
322045f4:	f64b 2178 	movw	r1, #47736	@ 0xba78
322045f8:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322045fc:	4640      	mov	r0, r8
322045fe:	f004 ff49 	bl	32209494 <strcasecmp>
32204602:	2800      	cmp	r0, #0
32204604:	f47f af03 	bne.w	3220440e <__loadlocale+0x12a>
32204608:	4640      	mov	r0, r8
3220460a:	f64b 2178 	movw	r1, #47736	@ 0xba78
3220460e:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204612:	f246 4ae1 	movw	sl, #25825	@ 0x64e1
32204616:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
3220461a:	f000 fd21 	bl	32205060 <strcpy>
3220461e:	f646 6311 	movw	r3, #28177	@ 0x6e11
32204622:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32204626:	2208      	movs	r2, #8
32204628:	e74c      	b.n	322044c4 <__loadlocale+0x1e0>
3220462a:	f64b 21d0 	movw	r1, #47824	@ 0xbad0
3220462e:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204632:	2208      	movs	r2, #8
32204634:	4640      	mov	r0, r8
32204636:	f005 f801 	bl	3220963c <strncasecmp>
3220463a:	2800      	cmp	r0, #0
3220463c:	f47f aee7 	bne.w	3220440e <__loadlocale+0x12a>
32204640:	f89d 3020 	ldrb.w	r3, [sp, #32]
32204644:	a808      	add	r0, sp, #32
32204646:	2b2d      	cmp	r3, #45	@ 0x2d
32204648:	d101      	bne.n	3220464e <__loadlocale+0x36a>
3220464a:	f10d 0021 	add.w	r0, sp, #33	@ 0x21
3220464e:	f64b 21dc 	movw	r1, #47836	@ 0xbadc
32204652:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204656:	f004 ff1d 	bl	32209494 <strcasecmp>
3220465a:	2800      	cmp	r0, #0
3220465c:	f47f aed7 	bne.w	3220440e <__loadlocale+0x12a>
32204660:	4640      	mov	r0, r8
32204662:	f64b 21e0 	movw	r1, #47840	@ 0xbae0
32204666:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220466a:	f000 fcf9 	bl	32205060 <strcpy>
3220466e:	e75d      	b.n	3220452c <__loadlocale+0x248>
32204670:	f64b 217c 	movw	r1, #47740	@ 0xba7c
32204674:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204678:	2203      	movs	r2, #3
3220467a:	4640      	mov	r0, r8
3220467c:	f004 ffde 	bl	3220963c <strncasecmp>
32204680:	2800      	cmp	r0, #0
32204682:	f47f aec4 	bne.w	3220440e <__loadlocale+0x12a>
32204686:	f89d 301b 	ldrb.w	r3, [sp, #27]
3220468a:	f10d 001b 	add.w	r0, sp, #27
3220468e:	2b2d      	cmp	r3, #45	@ 0x2d
32204690:	d100      	bne.n	32204694 <__loadlocale+0x3b0>
32204692:	a807      	add	r0, sp, #28
32204694:	f64b 2180 	movw	r1, #47744	@ 0xba80
32204698:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220469c:	f004 fefa 	bl	32209494 <strcasecmp>
322046a0:	2800      	cmp	r0, #0
322046a2:	f47f aeb4 	bne.w	3220440e <__loadlocale+0x12a>
322046a6:	4640      	mov	r0, r8
322046a8:	f64b 2184 	movw	r1, #47748	@ 0xba84
322046ac:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322046b0:	f246 4a29 	movw	sl, #25641	@ 0x6429
322046b4:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
322046b8:	f000 fcd2 	bl	32205060 <strcpy>
322046bc:	f646 53a5 	movw	r3, #28069	@ 0x6da5
322046c0:	f2c3 2320 	movt	r3, #12832	@ 0x3220
322046c4:	2203      	movs	r2, #3
322046c6:	e6fd      	b.n	322044c4 <__loadlocale+0x1e0>
322046c8:	f89d 3019 	ldrb.w	r3, [sp, #25]
322046cc:	f003 03df 	and.w	r3, r3, #223	@ 0xdf
322046d0:	2b50      	cmp	r3, #80	@ 0x50
322046d2:	f47f ae9c 	bne.w	3220440e <__loadlocale+0x12a>
322046d6:	2202      	movs	r2, #2
322046d8:	4640      	mov	r0, r8
322046da:	f64b 21ac 	movw	r1, #47788	@ 0xbaac
322046de:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322046e2:	f7ff fd8f 	bl	32204204 <strncpy>
322046e6:	220a      	movs	r2, #10
322046e8:	a905      	add	r1, sp, #20
322046ea:	f10d 001a 	add.w	r0, sp, #26
322046ee:	f002 faa3 	bl	32206c38 <strtol>
322046f2:	9b05      	ldr	r3, [sp, #20]
322046f4:	781b      	ldrb	r3, [r3, #0]
322046f6:	2b00      	cmp	r3, #0
322046f8:	f47f ae89 	bne.w	3220440e <__loadlocale+0x12a>
322046fc:	f5b0 7f69 	cmp.w	r0, #932	@ 0x3a4
32204700:	f43f af2f 	beq.w	32204562 <__loadlocale+0x27e>
32204704:	f300 80e6 	bgt.w	322048d4 <__loadlocale+0x5f0>
32204708:	f240 336a 	movw	r3, #874	@ 0x36a
3220470c:	4298      	cmp	r0, r3
3220470e:	f73f ae7e 	bgt.w	3220440e <__loadlocale+0x12a>
32204712:	f240 3351 	movw	r3, #849	@ 0x351
32204716:	4298      	cmp	r0, r3
32204718:	f340 80f7 	ble.w	3220490a <__loadlocale+0x626>
3220471c:	f2a0 3052 	subw	r0, r0, #850	@ 0x352
32204720:	f241 13a5 	movw	r3, #4517	@ 0x11a5
32204724:	f2c0 1301 	movt	r3, #257	@ 0x101
32204728:	40c3      	lsrs	r3, r0
3220472a:	07db      	lsls	r3, r3, #31
3220472c:	f53f aefe 	bmi.w	3220452c <__loadlocale+0x248>
32204730:	e66d      	b.n	3220440e <__loadlocale+0x12a>
32204732:	f64b 2134 	movw	r1, #47668	@ 0xba34
32204736:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220473a:	4640      	mov	r0, r8
3220473c:	f004 feaa 	bl	32209494 <strcasecmp>
32204740:	2800      	cmp	r0, #0
32204742:	f47f ae64 	bne.w	3220440e <__loadlocale+0x12a>
32204746:	4640      	mov	r0, r8
32204748:	f64b 2134 	movw	r1, #47668	@ 0xba34
3220474c:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204750:	f000 fc86 	bl	32205060 <strcpy>
32204754:	e6ea      	b.n	3220452c <__loadlocale+0x248>
32204756:	f64b 2194 	movw	r1, #47764	@ 0xba94
3220475a:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220475e:	2203      	movs	r2, #3
32204760:	4640      	mov	r0, r8
32204762:	f004 ff6b 	bl	3220963c <strncasecmp>
32204766:	2800      	cmp	r0, #0
32204768:	f47f ae51 	bne.w	3220440e <__loadlocale+0x12a>
3220476c:	f89d 301b 	ldrb.w	r3, [sp, #27]
32204770:	f10d 0a1b 	add.w	sl, sp, #27
32204774:	2b2d      	cmp	r3, #45	@ 0x2d
32204776:	d101      	bne.n	3220477c <__loadlocale+0x498>
32204778:	f10d 0a1c 	add.w	sl, sp, #28
3220477c:	f64b 2198 	movw	r1, #47768	@ 0xba98
32204780:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204784:	2204      	movs	r2, #4
32204786:	4650      	mov	r0, sl
32204788:	f004 ff58 	bl	3220963c <strncasecmp>
3220478c:	2800      	cmp	r0, #0
3220478e:	f47f ae3e 	bne.w	3220440e <__loadlocale+0x12a>
32204792:	f89a 3004 	ldrb.w	r3, [sl, #4]
32204796:	f10a 0004 	add.w	r0, sl, #4
3220479a:	2b2d      	cmp	r3, #45	@ 0x2d
3220479c:	d101      	bne.n	322047a2 <__loadlocale+0x4be>
3220479e:	f10a 0005 	add.w	r0, sl, #5
322047a2:	220a      	movs	r2, #10
322047a4:	a905      	add	r1, sp, #20
322047a6:	f002 fa47 	bl	32206c38 <strtol>
322047aa:	f1a0 020c 	sub.w	r2, r0, #12
322047ae:	1e43      	subs	r3, r0, #1
322047b0:	fab2 f282 	clz	r2, r2
322047b4:	2b0f      	cmp	r3, #15
322047b6:	4682      	mov	sl, r0
322047b8:	bf98      	it	ls
322047ba:	2300      	movls	r3, #0
322047bc:	bf88      	it	hi
322047be:	2301      	movhi	r3, #1
322047c0:	0952      	lsrs	r2, r2, #5
322047c2:	4313      	orrs	r3, r2
322047c4:	f47f ae23 	bne.w	3220440e <__loadlocale+0x12a>
322047c8:	9b05      	ldr	r3, [sp, #20]
322047ca:	781b      	ldrb	r3, [r3, #0]
322047cc:	2b00      	cmp	r3, #0
322047ce:	f47f ae1e 	bne.w	3220440e <__loadlocale+0x12a>
322047d2:	4640      	mov	r0, r8
322047d4:	f64b 21a0 	movw	r1, #47776	@ 0xbaa0
322047d8:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322047dc:	f000 fc40 	bl	32205060 <strcpy>
322047e0:	f10d 0221 	add.w	r2, sp, #33	@ 0x21
322047e4:	f1ba 0f0a 	cmp.w	sl, #10
322047e8:	dd04      	ble.n	322047f4 <__loadlocale+0x510>
322047ea:	f10d 0222 	add.w	r2, sp, #34	@ 0x22
322047ee:	2331      	movs	r3, #49	@ 0x31
322047f0:	f88d 3021 	strb.w	r3, [sp, #33]	@ 0x21
322047f4:	f246 6367 	movw	r3, #26215	@ 0x6667
322047f8:	f2c6 6366 	movt	r3, #26214	@ 0x6666
322047fc:	fb83 130a 	smull	r1, r3, r3, sl
32204800:	ea4f 71ea 	mov.w	r1, sl, asr #31
32204804:	ebc1 03a3 	rsb	r3, r1, r3, asr #2
32204808:	210a      	movs	r1, #10
3220480a:	fb01 a313 	mls	r3, r1, r3, sl
3220480e:	3330      	adds	r3, #48	@ 0x30
32204810:	7013      	strb	r3, [r2, #0]
32204812:	2300      	movs	r3, #0
32204814:	7053      	strb	r3, [r2, #1]
32204816:	e689      	b.n	3220452c <__loadlocale+0x248>
32204818:	4641      	mov	r1, r8
3220481a:	f505 7095 	add.w	r0, r5, #298	@ 0x12a
3220481e:	e9cd 2302 	strd	r2, r3, [sp, #8]
32204822:	f000 fc1d 	bl	32205060 <strcpy>
32204826:	9b03      	ldr	r3, [sp, #12]
32204828:	4641      	mov	r1, r8
3220482a:	9a02      	ldr	r2, [sp, #8]
3220482c:	4628      	mov	r0, r5
3220482e:	e9c5 3a38 	strd	r3, sl, [r5, #224]	@ 0xe0
32204832:	f885 2128 	strb.w	r2, [r5, #296]	@ 0x128
32204836:	f002 fb95 	bl	32206f64 <__set_ctype>
3220483a:	f1b9 0f00 	cmp.w	r9, #0
3220483e:	d10f      	bne.n	32204860 <__loadlocale+0x57c>
32204840:	9a02      	ldr	r2, [sp, #8]
32204842:	f08b 0301 	eor.w	r3, fp, #1
32204846:	f003 0301 	and.w	r3, r3, #1
3220484a:	2a01      	cmp	r2, #1
3220484c:	bf08      	it	eq
3220484e:	2300      	moveq	r3, #0
32204850:	b133      	cbz	r3, 32204860 <__loadlocale+0x57c>
32204852:	f89d 9018 	ldrb.w	r9, [sp, #24]
32204856:	f1b9 0355 	subs.w	r3, r9, #85	@ 0x55
3220485a:	bf18      	it	ne
3220485c:	2301      	movne	r3, #1
3220485e:	4699      	mov	r9, r3
32204860:	9b01      	ldr	r3, [sp, #4]
32204862:	b913      	cbnz	r3, 3220486a <__loadlocale+0x586>
32204864:	f8c5 90e8 	str.w	r9, [r5, #232]	@ 0xe8
32204868:	e636      	b.n	322044d8 <__loadlocale+0x1f4>
3220486a:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
3220486e:	f8c5 30e8 	str.w	r3, [r5, #232]	@ 0xe8
32204872:	e631      	b.n	322044d8 <__loadlocale+0x1f4>
32204874:	f109 0a01 	add.w	sl, r9, #1
32204878:	f64b 2148 	movw	r1, #47688	@ 0xba48
3220487c:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204880:	4650      	mov	r0, sl
32204882:	f000 fa7d 	bl	32204d80 <strcmp>
32204886:	4683      	mov	fp, r0
32204888:	b918      	cbnz	r0, 32204892 <__loadlocale+0x5ae>
3220488a:	2301      	movs	r3, #1
3220488c:	4681      	mov	r9, r0
3220488e:	9301      	str	r3, [sp, #4]
32204890:	e57b      	b.n	3220438a <__loadlocale+0xa6>
32204892:	4650      	mov	r0, sl
32204894:	f64b 2154 	movw	r1, #47700	@ 0xba54
32204898:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220489c:	f000 fa70 	bl	32204d80 <strcmp>
322048a0:	4681      	mov	r9, r0
322048a2:	bb10      	cbnz	r0, 322048ea <__loadlocale+0x606>
322048a4:	f04f 0b01 	mov.w	fp, #1
322048a8:	9001      	str	r0, [sp, #4]
322048aa:	e56e      	b.n	3220438a <__loadlocale+0xa6>
322048ac:	4640      	mov	r0, r8
322048ae:	f64b 21b8 	movw	r1, #47800	@ 0xbab8
322048b2:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322048b6:	f000 fbd3 	bl	32205060 <strcpy>
322048ba:	e637      	b.n	3220452c <__loadlocale+0x248>
322048bc:	2b75      	cmp	r3, #117	@ 0x75
322048be:	f47f ada6 	bne.w	3220440e <__loadlocale+0x12a>
322048c2:	e68f      	b.n	322045e4 <__loadlocale+0x300>
322048c4:	4640      	mov	r0, r8
322048c6:	f64b 21c8 	movw	r1, #47816	@ 0xbac8
322048ca:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322048ce:	f000 fbc7 	bl	32205060 <strcpy>
322048d2:	e62b      	b.n	3220452c <__loadlocale+0x248>
322048d4:	f240 4365 	movw	r3, #1125	@ 0x465
322048d8:	4298      	cmp	r0, r3
322048da:	f43f ae27 	beq.w	3220452c <__loadlocale+0x248>
322048de:	f2a0 40e2 	subw	r0, r0, #1250	@ 0x4e2
322048e2:	2808      	cmp	r0, #8
322048e4:	f67f ae22 	bls.w	3220452c <__loadlocale+0x248>
322048e8:	e591      	b.n	3220440e <__loadlocale+0x12a>
322048ea:	4650      	mov	r0, sl
322048ec:	f64b 2160 	movw	r1, #47712	@ 0xba60
322048f0:	f2c3 2120 	movt	r1, #12832	@ 0x3220
322048f4:	f04f 0b00 	mov.w	fp, #0
322048f8:	f000 fa42 	bl	32204d80 <strcmp>
322048fc:	fab0 f980 	clz	r9, r0
32204900:	f8cd b004 	str.w	fp, [sp, #4]
32204904:	ea4f 1959 	mov.w	r9, r9, lsr #5
32204908:	e53f      	b.n	3220438a <__loadlocale+0xa6>
3220490a:	f240 23e1 	movw	r3, #737	@ 0x2e1
3220490e:	4298      	cmp	r0, r3
32204910:	f43f ae0c 	beq.w	3220452c <__loadlocale+0x248>
32204914:	dc09      	bgt.n	3220492a <__loadlocale+0x646>
32204916:	f240 13b5 	movw	r3, #437	@ 0x1b5
3220491a:	4298      	cmp	r0, r3
3220491c:	f43f ae06 	beq.w	3220452c <__loadlocale+0x248>
32204920:	f5b0 7f34 	cmp.w	r0, #720	@ 0x2d0
32204924:	f47f ad73 	bne.w	3220440e <__loadlocale+0x12a>
32204928:	e600      	b.n	3220452c <__loadlocale+0x248>
3220492a:	f240 3307 	movw	r3, #775	@ 0x307
3220492e:	4298      	cmp	r0, r3
32204930:	f47f ad6d 	bne.w	3220440e <__loadlocale+0x12a>
32204934:	e5fa      	b.n	3220452c <__loadlocale+0x248>
32204936:	bf00      	nop

32204938 <__get_locale_env>:
32204938:	b538      	push	{r3, r4, r5, lr}
3220493a:	460d      	mov	r5, r1
3220493c:	f64b 3108 	movw	r1, #47880	@ 0xbb08
32204940:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204944:	4604      	mov	r4, r0
32204946:	f001 f917 	bl	32205b78 <_getenv_r>
3220494a:	b108      	cbz	r0, 32204950 <__get_locale_env+0x18>
3220494c:	7803      	ldrb	r3, [r0, #0]
3220494e:	b9db      	cbnz	r3, 32204988 <__get_locale_env+0x50>
32204950:	f64b 6328 	movw	r3, #48680	@ 0xbe28
32204954:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32204958:	4620      	mov	r0, r4
3220495a:	f853 1025 	ldr.w	r1, [r3, r5, lsl #2]
3220495e:	f001 f90b 	bl	32205b78 <_getenv_r>
32204962:	b108      	cbz	r0, 32204968 <__get_locale_env+0x30>
32204964:	7803      	ldrb	r3, [r0, #0]
32204966:	b97b      	cbnz	r3, 32204988 <__get_locale_env+0x50>
32204968:	f64b 3110 	movw	r1, #47888	@ 0xbb10
3220496c:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32204970:	4620      	mov	r0, r4
32204972:	f001 f901 	bl	32205b78 <_getenv_r>
32204976:	b140      	cbz	r0, 3220498a <__get_locale_env+0x52>
32204978:	7802      	ldrb	r2, [r0, #0]
3220497a:	f24c 33b0 	movw	r3, #50096	@ 0xc3b0
3220497e:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32204982:	2a00      	cmp	r2, #0
32204984:	bf08      	it	eq
32204986:	4618      	moveq	r0, r3
32204988:	bd38      	pop	{r3, r4, r5, pc}
3220498a:	f24c 30b0 	movw	r0, #50096	@ 0xc3b0
3220498e:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32204992:	bd38      	pop	{r3, r4, r5, pc}

32204994 <_setlocale_r>:
32204994:	e92d 4ff8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
32204998:	2906      	cmp	r1, #6
3220499a:	4680      	mov	r8, r0
3220499c:	d86b      	bhi.n	32204a76 <_setlocale_r+0xe2>
3220499e:	468b      	mov	fp, r1
322049a0:	4692      	mov	sl, r2
322049a2:	2a00      	cmp	r2, #0
322049a4:	f000 80a5 	beq.w	32204af2 <_setlocale_r+0x15e>
322049a8:	f8df 9224 	ldr.w	r9, [pc, #548]	@ 32204bd0 <_setlocale_r+0x23c>
322049ac:	4e87      	ldr	r6, [pc, #540]	@ (32204bcc <_setlocale_r+0x238>)
322049ae:	f109 07c0 	add.w	r7, r9, #192	@ 0xc0
322049b2:	464c      	mov	r4, r9
322049b4:	4635      	mov	r5, r6
322049b6:	4629      	mov	r1, r5
322049b8:	4620      	mov	r0, r4
322049ba:	3420      	adds	r4, #32
322049bc:	f000 fb50 	bl	32205060 <strcpy>
322049c0:	3520      	adds	r5, #32
322049c2:	42bc      	cmp	r4, r7
322049c4:	d1f7      	bne.n	322049b6 <_setlocale_r+0x22>
322049c6:	f89a 3000 	ldrb.w	r3, [sl]
322049ca:	bbb3      	cbnz	r3, 32204a3a <_setlocale_r+0xa6>
322049cc:	f1bb 0f00 	cmp.w	fp, #0
322049d0:	f040 809c 	bne.w	32204b0c <_setlocale_r+0x178>
322049d4:	4f7e      	ldr	r7, [pc, #504]	@ (32204bd0 <_setlocale_r+0x23c>)
322049d6:	2401      	movs	r4, #1
322049d8:	4621      	mov	r1, r4
322049da:	4640      	mov	r0, r8
322049dc:	f7ff ffac 	bl	32204938 <__get_locale_env>
322049e0:	4605      	mov	r5, r0
322049e2:	f000 fead 	bl	32205740 <strlen>
322049e6:	4603      	mov	r3, r0
322049e8:	4629      	mov	r1, r5
322049ea:	4638      	mov	r0, r7
322049ec:	2b1f      	cmp	r3, #31
322049ee:	d842      	bhi.n	32204a76 <_setlocale_r+0xe2>
322049f0:	3401      	adds	r4, #1
322049f2:	f000 fb35 	bl	32205060 <strcpy>
322049f6:	3720      	adds	r7, #32
322049f8:	2c07      	cmp	r4, #7
322049fa:	d1ed      	bne.n	322049d8 <_setlocale_r+0x44>
322049fc:	f8df b1d4 	ldr.w	fp, [pc, #468]	@ 32204bd4 <_setlocale_r+0x240>
32204a00:	f24c 2a40 	movw	sl, #49728	@ 0xc240
32204a04:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32204a08:	4f71      	ldr	r7, [pc, #452]	@ (32204bd0 <_setlocale_r+0x23c>)
32204a0a:	465d      	mov	r5, fp
32204a0c:	2401      	movs	r4, #1
32204a0e:	4631      	mov	r1, r6
32204a10:	4628      	mov	r0, r5
32204a12:	f000 fb25 	bl	32205060 <strcpy>
32204a16:	463a      	mov	r2, r7
32204a18:	4621      	mov	r1, r4
32204a1a:	4650      	mov	r0, sl
32204a1c:	f7ff fc62 	bl	322042e4 <__loadlocale>
32204a20:	2800      	cmp	r0, #0
32204a22:	f000 8087 	beq.w	32204b34 <_setlocale_r+0x1a0>
32204a26:	3401      	adds	r4, #1
32204a28:	3520      	adds	r5, #32
32204a2a:	3620      	adds	r6, #32
32204a2c:	3720      	adds	r7, #32
32204a2e:	2c07      	cmp	r4, #7
32204a30:	d1ed      	bne.n	32204a0e <_setlocale_r+0x7a>
32204a32:	e8bd 4ff8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
32204a36:	f7ff bc1f 	b.w	32204278 <currentlocale>
32204a3a:	f1bb 0f00 	cmp.w	fp, #0
32204a3e:	d021      	beq.n	32204a84 <_setlocale_r+0xf0>
32204a40:	4650      	mov	r0, sl
32204a42:	f000 fe7d 	bl	32205740 <strlen>
32204a46:	281f      	cmp	r0, #31
32204a48:	d815      	bhi.n	32204a76 <_setlocale_r+0xe2>
32204a4a:	f245 2460 	movw	r4, #21088	@ 0x5260
32204a4e:	f2c3 2421 	movt	r4, #12833	@ 0x3221
32204a52:	eb04 144b 	add.w	r4, r4, fp, lsl #5
32204a56:	4651      	mov	r1, sl
32204a58:	4620      	mov	r0, r4
32204a5a:	f000 fb01 	bl	32205060 <strcpy>
32204a5e:	4622      	mov	r2, r4
32204a60:	4659      	mov	r1, fp
32204a62:	f24c 2040 	movw	r0, #49728	@ 0xc240
32204a66:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32204a6a:	f7ff fc3b 	bl	322042e4 <__loadlocale>
32204a6e:	4604      	mov	r4, r0
32204a70:	f7ff fc02 	bl	32204278 <currentlocale>
32204a74:	e003      	b.n	32204a7e <_setlocale_r+0xea>
32204a76:	2616      	movs	r6, #22
32204a78:	2400      	movs	r4, #0
32204a7a:	f8c8 6000 	str.w	r6, [r8]
32204a7e:	4620      	mov	r0, r4
32204a80:	e8bd 8ff8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp, pc}
32204a84:	212f      	movs	r1, #47	@ 0x2f
32204a86:	4650      	mov	r0, sl
32204a88:	f004 fd4a 	bl	32209520 <strchr>
32204a8c:	4604      	mov	r4, r0
32204a8e:	2800      	cmp	r0, #0
32204a90:	d07a      	beq.n	32204b88 <_setlocale_r+0x1f4>
32204a92:	7842      	ldrb	r2, [r0, #1]
32204a94:	2a2f      	cmp	r2, #47	@ 0x2f
32204a96:	bf08      	it	eq
32204a98:	1c43      	addeq	r3, r0, #1
32204a9a:	d104      	bne.n	32204aa6 <_setlocale_r+0x112>
32204a9c:	461c      	mov	r4, r3
32204a9e:	f813 2f01 	ldrb.w	r2, [r3, #1]!
32204aa2:	2a2f      	cmp	r2, #47	@ 0x2f
32204aa4:	d0fa      	beq.n	32204a9c <_setlocale_r+0x108>
32204aa6:	2a00      	cmp	r2, #0
32204aa8:	d0e5      	beq.n	32204a76 <_setlocale_r+0xe2>
32204aaa:	f8df b124 	ldr.w	fp, [pc, #292]	@ 32204bd0 <_setlocale_r+0x23c>
32204aae:	2501      	movs	r5, #1
32204ab0:	eba4 020a 	sub.w	r2, r4, sl
32204ab4:	2a1f      	cmp	r2, #31
32204ab6:	dcde      	bgt.n	32204a76 <_setlocale_r+0xe2>
32204ab8:	3201      	adds	r2, #1
32204aba:	4651      	mov	r1, sl
32204abc:	4658      	mov	r0, fp
32204abe:	3501      	adds	r5, #1
32204ac0:	f004 fd96 	bl	322095f0 <strlcpy>
32204ac4:	7823      	ldrb	r3, [r4, #0]
32204ac6:	2b2f      	cmp	r3, #47	@ 0x2f
32204ac8:	d103      	bne.n	32204ad2 <_setlocale_r+0x13e>
32204aca:	f814 3f01 	ldrb.w	r3, [r4, #1]!
32204ace:	2b2f      	cmp	r3, #47	@ 0x2f
32204ad0:	d0fb      	beq.n	32204aca <_setlocale_r+0x136>
32204ad2:	2b00      	cmp	r3, #0
32204ad4:	d067      	beq.n	32204ba6 <_setlocale_r+0x212>
32204ad6:	4622      	mov	r2, r4
32204ad8:	f812 3f01 	ldrb.w	r3, [r2, #1]!
32204adc:	2b00      	cmp	r3, #0
32204ade:	bf18      	it	ne
32204ae0:	2b2f      	cmpne	r3, #47	@ 0x2f
32204ae2:	d1f9      	bne.n	32204ad8 <_setlocale_r+0x144>
32204ae4:	f10b 0b20 	add.w	fp, fp, #32
32204ae8:	2d07      	cmp	r5, #7
32204aea:	d087      	beq.n	322049fc <_setlocale_r+0x68>
32204aec:	46a2      	mov	sl, r4
32204aee:	4614      	mov	r4, r2
32204af0:	e7de      	b.n	32204ab0 <_setlocale_r+0x11c>
32204af2:	f24c 1458 	movw	r4, #49496	@ 0xc158
32204af6:	f2c3 2420 	movt	r4, #12832	@ 0x3220
32204afa:	2900      	cmp	r1, #0
32204afc:	d0bf      	beq.n	32204a7e <_setlocale_r+0xea>
32204afe:	f24c 2440 	movw	r4, #49728	@ 0xc240
32204b02:	f2c3 2420 	movt	r4, #12832	@ 0x3220
32204b06:	eb04 1441 	add.w	r4, r4, r1, lsl #5
32204b0a:	e7b8      	b.n	32204a7e <_setlocale_r+0xea>
32204b0c:	4659      	mov	r1, fp
32204b0e:	4640      	mov	r0, r8
32204b10:	f7ff ff12 	bl	32204938 <__get_locale_env>
32204b14:	4605      	mov	r5, r0
32204b16:	f000 fe13 	bl	32205740 <strlen>
32204b1a:	281f      	cmp	r0, #31
32204b1c:	d8ab      	bhi.n	32204a76 <_setlocale_r+0xe2>
32204b1e:	f245 2460 	movw	r4, #21088	@ 0x5260
32204b22:	f2c3 2421 	movt	r4, #12833	@ 0x3221
32204b26:	eb04 144b 	add.w	r4, r4, fp, lsl #5
32204b2a:	4629      	mov	r1, r5
32204b2c:	4620      	mov	r0, r4
32204b2e:	f000 fa97 	bl	32205060 <strcpy>
32204b32:	e794      	b.n	32204a5e <_setlocale_r+0xca>
32204b34:	f8d8 6000 	ldr.w	r6, [r8]
32204b38:	2c01      	cmp	r4, #1
32204b3a:	d09d      	beq.n	32204a78 <_setlocale_r+0xe4>
32204b3c:	f24c 2740 	movw	r7, #49728	@ 0xc240
32204b40:	f2c3 2720 	movt	r7, #12832	@ 0x3220
32204b44:	f64b 2a30 	movw	sl, #47664	@ 0xba30
32204b48:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32204b4c:	2501      	movs	r5, #1
32204b4e:	e006      	b.n	32204b5e <_setlocale_r+0x1ca>
32204b50:	3501      	adds	r5, #1
32204b52:	f109 0920 	add.w	r9, r9, #32
32204b56:	f10b 0b20 	add.w	fp, fp, #32
32204b5a:	42a5      	cmp	r5, r4
32204b5c:	d08c      	beq.n	32204a78 <_setlocale_r+0xe4>
32204b5e:	4659      	mov	r1, fp
32204b60:	4648      	mov	r0, r9
32204b62:	f000 fa7d 	bl	32205060 <strcpy>
32204b66:	464a      	mov	r2, r9
32204b68:	4629      	mov	r1, r5
32204b6a:	4638      	mov	r0, r7
32204b6c:	f7ff fbba 	bl	322042e4 <__loadlocale>
32204b70:	2800      	cmp	r0, #0
32204b72:	d1ed      	bne.n	32204b50 <_setlocale_r+0x1bc>
32204b74:	4651      	mov	r1, sl
32204b76:	4648      	mov	r0, r9
32204b78:	f000 fa72 	bl	32205060 <strcpy>
32204b7c:	464a      	mov	r2, r9
32204b7e:	4629      	mov	r1, r5
32204b80:	4638      	mov	r0, r7
32204b82:	f7ff fbaf 	bl	322042e4 <__loadlocale>
32204b86:	e7e3      	b.n	32204b50 <_setlocale_r+0x1bc>
32204b88:	4650      	mov	r0, sl
32204b8a:	f000 fdd9 	bl	32205740 <strlen>
32204b8e:	281f      	cmp	r0, #31
32204b90:	f63f af71 	bhi.w	32204a76 <_setlocale_r+0xe2>
32204b94:	4c0e      	ldr	r4, [pc, #56]	@ (32204bd0 <_setlocale_r+0x23c>)
32204b96:	4620      	mov	r0, r4
32204b98:	4651      	mov	r1, sl
32204b9a:	3420      	adds	r4, #32
32204b9c:	f000 fa60 	bl	32205060 <strcpy>
32204ba0:	42bc      	cmp	r4, r7
32204ba2:	d1f8      	bne.n	32204b96 <_setlocale_r+0x202>
32204ba4:	e72a      	b.n	322049fc <_setlocale_r+0x68>
32204ba6:	f245 2460 	movw	r4, #21088	@ 0x5260
32204baa:	f2c3 2421 	movt	r4, #12833	@ 0x3221
32204bae:	eb04 1445 	add.w	r4, r4, r5, lsl #5
32204bb2:	2d07      	cmp	r5, #7
32204bb4:	f43f af22 	beq.w	322049fc <_setlocale_r+0x68>
32204bb8:	f1a4 0120 	sub.w	r1, r4, #32
32204bbc:	4620      	mov	r0, r4
32204bbe:	3420      	adds	r4, #32
32204bc0:	f000 fa4e 	bl	32205060 <strcpy>
32204bc4:	42bc      	cmp	r4, r7
32204bc6:	d1f7      	bne.n	32204bb8 <_setlocale_r+0x224>
32204bc8:	e718      	b.n	322049fc <_setlocale_r+0x68>
32204bca:	bf00      	nop
32204bcc:	3220c260 	.word	0x3220c260
32204bd0:	32215280 	.word	0x32215280
32204bd4:	322151a0 	.word	0x322151a0

32204bd8 <__locale_mb_cur_max>:
32204bd8:	f24c 2340 	movw	r3, #49728	@ 0xc240
32204bdc:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32204be0:	f893 0128 	ldrb.w	r0, [r3, #296]	@ 0x128
32204be4:	4770      	bx	lr
32204be6:	bf00      	nop

32204be8 <setlocale>:
32204be8:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
32204bec:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32204bf0:	460a      	mov	r2, r1
32204bf2:	4601      	mov	r1, r0
32204bf4:	6818      	ldr	r0, [r3, #0]
32204bf6:	f7ff becd 	b.w	32204994 <_setlocale_r>
32204bfa:	bf00      	nop

32204bfc <__localeconv_l>:
32204bfc:	30f0      	adds	r0, #240	@ 0xf0
32204bfe:	4770      	bx	lr

32204c00 <_localeconv_r>:
32204c00:	4800      	ldr	r0, [pc, #0]	@ (32204c04 <_localeconv_r+0x4>)
32204c02:	4770      	bx	lr
32204c04:	3220c330 	.word	0x3220c330

32204c08 <localeconv>:
32204c08:	4800      	ldr	r0, [pc, #0]	@ (32204c0c <localeconv+0x4>)
32204c0a:	4770      	bx	lr
32204c0c:	3220c330 	.word	0x3220c330

32204c10 <_close_r>:
32204c10:	b538      	push	{r3, r4, r5, lr}
32204c12:	f245 3444 	movw	r4, #21316	@ 0x5344
32204c16:	f2c3 2421 	movt	r4, #12833	@ 0x3221
32204c1a:	4605      	mov	r5, r0
32204c1c:	4608      	mov	r0, r1
32204c1e:	2200      	movs	r2, #0
32204c20:	6022      	str	r2, [r4, #0]
32204c22:	f7fb ec12 	blx	32200448 <_close>
32204c26:	1c43      	adds	r3, r0, #1
32204c28:	d000      	beq.n	32204c2c <_close_r+0x1c>
32204c2a:	bd38      	pop	{r3, r4, r5, pc}
32204c2c:	6823      	ldr	r3, [r4, #0]
32204c2e:	2b00      	cmp	r3, #0
32204c30:	d0fb      	beq.n	32204c2a <_close_r+0x1a>
32204c32:	602b      	str	r3, [r5, #0]
32204c34:	bd38      	pop	{r3, r4, r5, pc}
32204c36:	bf00      	nop

32204c38 <_reclaim_reent>:
32204c38:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
32204c3c:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32204c40:	681b      	ldr	r3, [r3, #0]
32204c42:	4283      	cmp	r3, r0
32204c44:	d02e      	beq.n	32204ca4 <_reclaim_reent+0x6c>
32204c46:	6c41      	ldr	r1, [r0, #68]	@ 0x44
32204c48:	b570      	push	{r4, r5, r6, lr}
32204c4a:	4605      	mov	r5, r0
32204c4c:	b181      	cbz	r1, 32204c70 <_reclaim_reent+0x38>
32204c4e:	2600      	movs	r6, #0
32204c50:	598c      	ldr	r4, [r1, r6]
32204c52:	b13c      	cbz	r4, 32204c64 <_reclaim_reent+0x2c>
32204c54:	4621      	mov	r1, r4
32204c56:	6824      	ldr	r4, [r4, #0]
32204c58:	4628      	mov	r0, r5
32204c5a:	f000 fe45 	bl	322058e8 <_free_r>
32204c5e:	2c00      	cmp	r4, #0
32204c60:	d1f8      	bne.n	32204c54 <_reclaim_reent+0x1c>
32204c62:	6c69      	ldr	r1, [r5, #68]	@ 0x44
32204c64:	3604      	adds	r6, #4
32204c66:	2e80      	cmp	r6, #128	@ 0x80
32204c68:	d1f2      	bne.n	32204c50 <_reclaim_reent+0x18>
32204c6a:	4628      	mov	r0, r5
32204c6c:	f000 fe3c 	bl	322058e8 <_free_r>
32204c70:	6ba9      	ldr	r1, [r5, #56]	@ 0x38
32204c72:	b111      	cbz	r1, 32204c7a <_reclaim_reent+0x42>
32204c74:	4628      	mov	r0, r5
32204c76:	f000 fe37 	bl	322058e8 <_free_r>
32204c7a:	6c2c      	ldr	r4, [r5, #64]	@ 0x40
32204c7c:	b134      	cbz	r4, 32204c8c <_reclaim_reent+0x54>
32204c7e:	4621      	mov	r1, r4
32204c80:	6824      	ldr	r4, [r4, #0]
32204c82:	4628      	mov	r0, r5
32204c84:	f000 fe30 	bl	322058e8 <_free_r>
32204c88:	2c00      	cmp	r4, #0
32204c8a:	d1f8      	bne.n	32204c7e <_reclaim_reent+0x46>
32204c8c:	6ce9      	ldr	r1, [r5, #76]	@ 0x4c
32204c8e:	b111      	cbz	r1, 32204c96 <_reclaim_reent+0x5e>
32204c90:	4628      	mov	r0, r5
32204c92:	f000 fe29 	bl	322058e8 <_free_r>
32204c96:	6b6b      	ldr	r3, [r5, #52]	@ 0x34
32204c98:	b11b      	cbz	r3, 32204ca2 <_reclaim_reent+0x6a>
32204c9a:	4628      	mov	r0, r5
32204c9c:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
32204ca0:	4718      	bx	r3
32204ca2:	bd70      	pop	{r4, r5, r6, pc}
32204ca4:	4770      	bx	lr
32204ca6:	bf00      	nop

32204ca8 <_lseek_r>:
32204ca8:	b538      	push	{r3, r4, r5, lr}
32204caa:	f245 3444 	movw	r4, #21316	@ 0x5344
32204cae:	f2c3 2421 	movt	r4, #12833	@ 0x3221
32204cb2:	460d      	mov	r5, r1
32204cb4:	4684      	mov	ip, r0
32204cb6:	4611      	mov	r1, r2
32204cb8:	4628      	mov	r0, r5
32204cba:	461a      	mov	r2, r3
32204cbc:	4665      	mov	r5, ip
32204cbe:	2300      	movs	r3, #0
32204cc0:	6023      	str	r3, [r4, #0]
32204cc2:	f7fb ebb4 	blx	3220042c <_lseek>
32204cc6:	1c43      	adds	r3, r0, #1
32204cc8:	d000      	beq.n	32204ccc <_lseek_r+0x24>
32204cca:	bd38      	pop	{r3, r4, r5, pc}
32204ccc:	6823      	ldr	r3, [r4, #0]
32204cce:	2b00      	cmp	r3, #0
32204cd0:	d0fb      	beq.n	32204cca <_lseek_r+0x22>
32204cd2:	602b      	str	r3, [r5, #0]
32204cd4:	bd38      	pop	{r3, r4, r5, pc}
32204cd6:	bf00      	nop

32204cd8 <_read_r>:
32204cd8:	b538      	push	{r3, r4, r5, lr}
32204cda:	f245 3444 	movw	r4, #21316	@ 0x5344
32204cde:	f2c3 2421 	movt	r4, #12833	@ 0x3221
32204ce2:	460d      	mov	r5, r1
32204ce4:	4684      	mov	ip, r0
32204ce6:	4611      	mov	r1, r2
32204ce8:	4628      	mov	r0, r5
32204cea:	461a      	mov	r2, r3
32204cec:	4665      	mov	r5, ip
32204cee:	2300      	movs	r3, #0
32204cf0:	6023      	str	r3, [r4, #0]
32204cf2:	f7fb eb5e 	blx	322003b0 <_read>
32204cf6:	1c43      	adds	r3, r0, #1
32204cf8:	d000      	beq.n	32204cfc <_read_r+0x24>
32204cfa:	bd38      	pop	{r3, r4, r5, pc}
32204cfc:	6823      	ldr	r3, [r4, #0]
32204cfe:	2b00      	cmp	r3, #0
32204d00:	d0fb      	beq.n	32204cfa <_read_r+0x22>
32204d02:	602b      	str	r3, [r5, #0]
32204d04:	bd38      	pop	{r3, r4, r5, pc}
32204d06:	bf00      	nop

32204d08 <_write_r>:
32204d08:	b538      	push	{r3, r4, r5, lr}
32204d0a:	f245 3444 	movw	r4, #21316	@ 0x5344
32204d0e:	f2c3 2421 	movt	r4, #12833	@ 0x3221
32204d12:	460d      	mov	r5, r1
32204d14:	4684      	mov	ip, r0
32204d16:	4611      	mov	r1, r2
32204d18:	4628      	mov	r0, r5
32204d1a:	461a      	mov	r2, r3
32204d1c:	4665      	mov	r5, ip
32204d1e:	2300      	movs	r3, #0
32204d20:	6023      	str	r3, [r4, #0]
32204d22:	f7fb eb5c 	blx	322003dc <_write>
32204d26:	1c43      	adds	r3, r0, #1
32204d28:	d000      	beq.n	32204d2c <_write_r+0x24>
32204d2a:	bd38      	pop	{r3, r4, r5, pc}
32204d2c:	6823      	ldr	r3, [r4, #0]
32204d2e:	2b00      	cmp	r3, #0
32204d30:	d0fb      	beq.n	32204d2a <_write_r+0x22>
32204d32:	602b      	str	r3, [r5, #0]
32204d34:	bd38      	pop	{r3, r4, r5, pc}
32204d36:	bf00      	nop

32204d38 <__errno>:
32204d38:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
32204d3c:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32204d40:	6818      	ldr	r0, [r3, #0]
32204d42:	4770      	bx	lr

32204d44 <__retarget_lock_init>:
32204d44:	4770      	bx	lr
32204d46:	bf00      	nop

32204d48 <__retarget_lock_init_recursive>:
32204d48:	4770      	bx	lr
32204d4a:	bf00      	nop

32204d4c <__retarget_lock_close>:
32204d4c:	4770      	bx	lr
32204d4e:	bf00      	nop

32204d50 <__retarget_lock_close_recursive>:
32204d50:	4770      	bx	lr
32204d52:	bf00      	nop

32204d54 <__retarget_lock_acquire>:
32204d54:	4770      	bx	lr
32204d56:	bf00      	nop

32204d58 <__retarget_lock_acquire_recursive>:
32204d58:	4770      	bx	lr
32204d5a:	bf00      	nop

32204d5c <__retarget_lock_try_acquire>:
32204d5c:	2001      	movs	r0, #1
32204d5e:	4770      	bx	lr

32204d60 <__retarget_lock_try_acquire_recursive>:
32204d60:	2001      	movs	r0, #1
32204d62:	4770      	bx	lr

32204d64 <__retarget_lock_release>:
32204d64:	4770      	bx	lr
32204d66:	bf00      	nop

32204d68 <__retarget_lock_release_recursive>:
32204d68:	4770      	bx	lr
32204d6a:	bf00      	nop
	...

32204d80 <strcmp>:
32204d80:	7802      	ldrb	r2, [r0, #0]
32204d82:	780b      	ldrb	r3, [r1, #0]
32204d84:	2a01      	cmp	r2, #1
32204d86:	bf28      	it	cs
32204d88:	429a      	cmpcs	r2, r3
32204d8a:	f040 80d8 	bne.w	32204f3e <strcmp+0x1be>
32204d8e:	e96d 4504 	strd	r4, r5, [sp, #-16]!
32204d92:	ea40 0401 	orr.w	r4, r0, r1
32204d96:	e9cd 6702 	strd	r6, r7, [sp, #8]
32204d9a:	f06f 0c00 	mvn.w	ip, #0
32204d9e:	ea4f 7244 	mov.w	r2, r4, lsl #29
32204da2:	b31a      	cbz	r2, 32204dec <strcmp+0x6c>
32204da4:	ea80 0401 	eor.w	r4, r0, r1
32204da8:	f014 0f07 	tst.w	r4, #7
32204dac:	d16b      	bne.n	32204e86 <strcmp+0x106>
32204dae:	f000 0407 	and.w	r4, r0, #7
32204db2:	f020 0007 	bic.w	r0, r0, #7
32204db6:	f004 0503 	and.w	r5, r4, #3
32204dba:	f021 0107 	bic.w	r1, r1, #7
32204dbe:	ea4f 05c5 	mov.w	r5, r5, lsl #3
32204dc2:	e8f0 2304 	ldrd	r2, r3, [r0], #16
32204dc6:	f014 0f04 	tst.w	r4, #4
32204dca:	e8f1 6704 	ldrd	r6, r7, [r1], #16
32204dce:	fa0c f405 	lsl.w	r4, ip, r5
32204dd2:	ea62 0204 	orn	r2, r2, r4
32204dd6:	ea66 0604 	orn	r6, r6, r4
32204dda:	d00b      	beq.n	32204df4 <strcmp+0x74>
32204ddc:	ea63 0304 	orn	r3, r3, r4
32204de0:	4662      	mov	r2, ip
32204de2:	ea67 0704 	orn	r7, r7, r4
32204de6:	4666      	mov	r6, ip
32204de8:	e004      	b.n	32204df4 <strcmp+0x74>
32204dea:	bf00      	nop
32204dec:	e8f0 2304 	ldrd	r2, r3, [r0], #16
32204df0:	e8f1 6704 	ldrd	r6, r7, [r1], #16
32204df4:	fa82 f54c 	uadd8	r5, r2, ip
32204df8:	ea82 0406 	eor.w	r4, r2, r6
32204dfc:	faa4 f48c 	sel	r4, r4, ip
32204e00:	bb6c      	cbnz	r4, 32204e5e <strcmp+0xde>
32204e02:	fa83 f54c 	uadd8	r5, r3, ip
32204e06:	ea83 0507 	eor.w	r5, r3, r7
32204e0a:	faa5 f58c 	sel	r5, r5, ip
32204e0e:	b995      	cbnz	r5, 32204e36 <strcmp+0xb6>
32204e10:	e950 2302 	ldrd	r2, r3, [r0, #-8]
32204e14:	e951 6702 	ldrd	r6, r7, [r1, #-8]
32204e18:	fa82 f54c 	uadd8	r5, r2, ip
32204e1c:	ea82 0406 	eor.w	r4, r2, r6
32204e20:	faa4 f48c 	sel	r4, r4, ip
32204e24:	fa83 f54c 	uadd8	r5, r3, ip
32204e28:	ea83 0507 	eor.w	r5, r3, r7
32204e2c:	faa5 f58c 	sel	r5, r5, ip
32204e30:	4325      	orrs	r5, r4
32204e32:	d0db      	beq.n	32204dec <strcmp+0x6c>
32204e34:	b99c      	cbnz	r4, 32204e5e <strcmp+0xde>
32204e36:	ba2d      	rev	r5, r5
32204e38:	fab5 f485 	clz	r4, r5
32204e3c:	f024 0407 	bic.w	r4, r4, #7
32204e40:	fa27 f104 	lsr.w	r1, r7, r4
32204e44:	e9dd 6702 	ldrd	r6, r7, [sp, #8]
32204e48:	fa23 f304 	lsr.w	r3, r3, r4
32204e4c:	f003 00ff 	and.w	r0, r3, #255	@ 0xff
32204e50:	f001 01ff 	and.w	r1, r1, #255	@ 0xff
32204e54:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32204e58:	eba0 0001 	sub.w	r0, r0, r1
32204e5c:	4770      	bx	lr
32204e5e:	ba24      	rev	r4, r4
32204e60:	fab4 f484 	clz	r4, r4
32204e64:	f024 0407 	bic.w	r4, r4, #7
32204e68:	fa26 f104 	lsr.w	r1, r6, r4
32204e6c:	e9dd 6702 	ldrd	r6, r7, [sp, #8]
32204e70:	fa22 f204 	lsr.w	r2, r2, r4
32204e74:	f002 00ff 	and.w	r0, r2, #255	@ 0xff
32204e78:	f001 01ff 	and.w	r1, r1, #255	@ 0xff
32204e7c:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32204e80:	eba0 0001 	sub.w	r0, r0, r1
32204e84:	4770      	bx	lr
32204e86:	f014 0f03 	tst.w	r4, #3
32204e8a:	d13c      	bne.n	32204f06 <strcmp+0x186>
32204e8c:	f010 0403 	ands.w	r4, r0, #3
32204e90:	d128      	bne.n	32204ee4 <strcmp+0x164>
32204e92:	f850 2b08 	ldr.w	r2, [r0], #8
32204e96:	f851 3b08 	ldr.w	r3, [r1], #8
32204e9a:	fa82 f54c 	uadd8	r5, r2, ip
32204e9e:	ea82 0503 	eor.w	r5, r2, r3
32204ea2:	faa5 f58c 	sel	r5, r5, ip
32204ea6:	b95d      	cbnz	r5, 32204ec0 <strcmp+0x140>
32204ea8:	f850 2c04 	ldr.w	r2, [r0, #-4]
32204eac:	f851 3c04 	ldr.w	r3, [r1, #-4]
32204eb0:	fa82 f54c 	uadd8	r5, r2, ip
32204eb4:	ea82 0503 	eor.w	r5, r2, r3
32204eb8:	faa5 f58c 	sel	r5, r5, ip
32204ebc:	2d00      	cmp	r5, #0
32204ebe:	d0e8      	beq.n	32204e92 <strcmp+0x112>
32204ec0:	ba2d      	rev	r5, r5
32204ec2:	fab5 f485 	clz	r4, r5
32204ec6:	f024 0407 	bic.w	r4, r4, #7
32204eca:	fa23 f104 	lsr.w	r1, r3, r4
32204ece:	fa22 f204 	lsr.w	r2, r2, r4
32204ed2:	f002 00ff 	and.w	r0, r2, #255	@ 0xff
32204ed6:	f001 01ff 	and.w	r1, r1, #255	@ 0xff
32204eda:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32204ede:	eba0 0001 	sub.w	r0, r0, r1
32204ee2:	4770      	bx	lr
32204ee4:	ea4f 04c4 	mov.w	r4, r4, lsl #3
32204ee8:	f020 0003 	bic.w	r0, r0, #3
32204eec:	f850 2b08 	ldr.w	r2, [r0], #8
32204ef0:	f021 0103 	bic.w	r1, r1, #3
32204ef4:	f851 3b08 	ldr.w	r3, [r1], #8
32204ef8:	fa0c f404 	lsl.w	r4, ip, r4
32204efc:	ea62 0204 	orn	r2, r2, r4
32204f00:	ea63 0304 	orn	r3, r3, r4
32204f04:	e7c9      	b.n	32204e9a <strcmp+0x11a>
32204f06:	f010 0403 	ands.w	r4, r0, #3
32204f0a:	d01d      	beq.n	32204f48 <strcmp+0x1c8>
32204f0c:	eba1 0104 	sub.w	r1, r1, r4
32204f10:	f020 0003 	bic.w	r0, r0, #3
32204f14:	07e4      	lsls	r4, r4, #31
32204f16:	f850 2b04 	ldr.w	r2, [r0], #4
32204f1a:	d006      	beq.n	32204f2a <strcmp+0x1aa>
32204f1c:	d212      	bcs.n	32204f44 <strcmp+0x1c4>
32204f1e:	788b      	ldrb	r3, [r1, #2]
32204f20:	fa5f f4a2 	uxtb.w	r4, r2, ror #16
32204f24:	1ae4      	subs	r4, r4, r3
32204f26:	d106      	bne.n	32204f36 <strcmp+0x1b6>
32204f28:	b12b      	cbz	r3, 32204f36 <strcmp+0x1b6>
32204f2a:	78cb      	ldrb	r3, [r1, #3]
32204f2c:	fa5f f4b2 	uxtb.w	r4, r2, ror #24
32204f30:	1ae4      	subs	r4, r4, r3
32204f32:	d100      	bne.n	32204f36 <strcmp+0x1b6>
32204f34:	b933      	cbnz	r3, 32204f44 <strcmp+0x1c4>
32204f36:	4620      	mov	r0, r4
32204f38:	f85d 4b10 	ldr.w	r4, [sp], #16
32204f3c:	4770      	bx	lr
32204f3e:	eba2 0003 	sub.w	r0, r2, r3
32204f42:	4770      	bx	lr
32204f44:	f101 0104 	add.w	r1, r1, #4
32204f48:	f850 2b04 	ldr.w	r2, [r0], #4
32204f4c:	07cc      	lsls	r4, r1, #31
32204f4e:	f021 0103 	bic.w	r1, r1, #3
32204f52:	f851 3b04 	ldr.w	r3, [r1], #4
32204f56:	d848      	bhi.n	32204fea <strcmp+0x26a>
32204f58:	d224      	bcs.n	32204fa4 <strcmp+0x224>
32204f5a:	f022 447f 	bic.w	r4, r2, #4278190080	@ 0xff000000
32204f5e:	fa82 f54c 	uadd8	r5, r2, ip
32204f62:	ea94 2513 	eors.w	r5, r4, r3, lsr #8
32204f66:	faa5 f58c 	sel	r5, r5, ip
32204f6a:	d10a      	bne.n	32204f82 <strcmp+0x202>
32204f6c:	b965      	cbnz	r5, 32204f88 <strcmp+0x208>
32204f6e:	f851 3b04 	ldr.w	r3, [r1], #4
32204f72:	ea84 0402 	eor.w	r4, r4, r2
32204f76:	ebb4 6f03 	cmp.w	r4, r3, lsl #24
32204f7a:	d10e      	bne.n	32204f9a <strcmp+0x21a>
32204f7c:	f850 2b04 	ldr.w	r2, [r0], #4
32204f80:	e7eb      	b.n	32204f5a <strcmp+0x1da>
32204f82:	ea4f 2313 	mov.w	r3, r3, lsr #8
32204f86:	e055      	b.n	32205034 <strcmp+0x2b4>
32204f88:	f035 457f 	bics.w	r5, r5, #4278190080	@ 0xff000000
32204f8c:	d14d      	bne.n	3220502a <strcmp+0x2aa>
32204f8e:	7808      	ldrb	r0, [r1, #0]
32204f90:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32204f94:	f1c0 0000 	rsb	r0, r0, #0
32204f98:	4770      	bx	lr
32204f9a:	ea4f 6212 	mov.w	r2, r2, lsr #24
32204f9e:	f003 03ff 	and.w	r3, r3, #255	@ 0xff
32204fa2:	e047      	b.n	32205034 <strcmp+0x2b4>
32204fa4:	ea02 441c 	and.w	r4, r2, ip, lsr #16
32204fa8:	fa82 f54c 	uadd8	r5, r2, ip
32204fac:	ea94 4513 	eors.w	r5, r4, r3, lsr #16
32204fb0:	faa5 f58c 	sel	r5, r5, ip
32204fb4:	d10a      	bne.n	32204fcc <strcmp+0x24c>
32204fb6:	b965      	cbnz	r5, 32204fd2 <strcmp+0x252>
32204fb8:	f851 3b04 	ldr.w	r3, [r1], #4
32204fbc:	ea84 0402 	eor.w	r4, r4, r2
32204fc0:	ebb4 4f03 	cmp.w	r4, r3, lsl #16
32204fc4:	d10c      	bne.n	32204fe0 <strcmp+0x260>
32204fc6:	f850 2b04 	ldr.w	r2, [r0], #4
32204fca:	e7eb      	b.n	32204fa4 <strcmp+0x224>
32204fcc:	ea4f 4313 	mov.w	r3, r3, lsr #16
32204fd0:	e030      	b.n	32205034 <strcmp+0x2b4>
32204fd2:	ea15 451c 	ands.w	r5, r5, ip, lsr #16
32204fd6:	d128      	bne.n	3220502a <strcmp+0x2aa>
32204fd8:	880b      	ldrh	r3, [r1, #0]
32204fda:	ea4f 4212 	mov.w	r2, r2, lsr #16
32204fde:	e029      	b.n	32205034 <strcmp+0x2b4>
32204fe0:	ea4f 4212 	mov.w	r2, r2, lsr #16
32204fe4:	ea03 431c 	and.w	r3, r3, ip, lsr #16
32204fe8:	e024      	b.n	32205034 <strcmp+0x2b4>
32204fea:	f002 04ff 	and.w	r4, r2, #255	@ 0xff
32204fee:	fa82 f54c 	uadd8	r5, r2, ip
32204ff2:	ea94 6513 	eors.w	r5, r4, r3, lsr #24
32204ff6:	faa5 f58c 	sel	r5, r5, ip
32204ffa:	d10a      	bne.n	32205012 <strcmp+0x292>
32204ffc:	b965      	cbnz	r5, 32205018 <strcmp+0x298>
32204ffe:	f851 3b04 	ldr.w	r3, [r1], #4
32205002:	ea84 0402 	eor.w	r4, r4, r2
32205006:	ebb4 2f03 	cmp.w	r4, r3, lsl #8
3220500a:	d109      	bne.n	32205020 <strcmp+0x2a0>
3220500c:	f850 2b04 	ldr.w	r2, [r0], #4
32205010:	e7eb      	b.n	32204fea <strcmp+0x26a>
32205012:	ea4f 6313 	mov.w	r3, r3, lsr #24
32205016:	e00d      	b.n	32205034 <strcmp+0x2b4>
32205018:	f015 0fff 	tst.w	r5, #255	@ 0xff
3220501c:	d105      	bne.n	3220502a <strcmp+0x2aa>
3220501e:	680b      	ldr	r3, [r1, #0]
32205020:	ea4f 2212 	mov.w	r2, r2, lsr #8
32205024:	f023 437f 	bic.w	r3, r3, #4278190080	@ 0xff000000
32205028:	e004      	b.n	32205034 <strcmp+0x2b4>
3220502a:	f04f 0000 	mov.w	r0, #0
3220502e:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32205032:	4770      	bx	lr
32205034:	ba12      	rev	r2, r2
32205036:	ba1b      	rev	r3, r3
32205038:	fa82 f44c 	uadd8	r4, r2, ip
3220503c:	ea82 0403 	eor.w	r4, r2, r3
32205040:	faa4 f58c 	sel	r5, r4, ip
32205044:	fab5 f485 	clz	r4, r5
32205048:	fa02 f204 	lsl.w	r2, r2, r4
3220504c:	fa03 f304 	lsl.w	r3, r3, r4
32205050:	ea4f 6012 	mov.w	r0, r2, lsr #24
32205054:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32205058:	eba0 6013 	sub.w	r0, r0, r3, lsr #24
3220505c:	4770      	bx	lr
3220505e:	bf00      	nop

32205060 <strcpy>:
32205060:	f891 f000 	pld	[r1]
32205064:	ea80 0201 	eor.w	r2, r0, r1
32205068:	4684      	mov	ip, r0
3220506a:	f012 0f03 	tst.w	r2, #3
3220506e:	d151      	bne.n	32205114 <strcpy+0xb4>
32205070:	f011 0f03 	tst.w	r1, #3
32205074:	d134      	bne.n	322050e0 <strcpy+0x80>
32205076:	f84d 4d04 	str.w	r4, [sp, #-4]!
3220507a:	f011 0f04 	tst.w	r1, #4
3220507e:	f851 3b04 	ldr.w	r3, [r1], #4
32205082:	d00b      	beq.n	3220509c <strcpy+0x3c>
32205084:	f1a3 3201 	sub.w	r2, r3, #16843009	@ 0x1010101
32205088:	439a      	bics	r2, r3
3220508a:	f012 3f80 	tst.w	r2, #2155905152	@ 0x80808080
3220508e:	bf04      	itt	eq
32205090:	f84c 3b04 	streq.w	r3, [ip], #4
32205094:	f851 3b04 	ldreq.w	r3, [r1], #4
32205098:	d118      	bne.n	322050cc <strcpy+0x6c>
3220509a:	bf00      	nop
3220509c:	f891 f008 	pld	[r1, #8]
322050a0:	f851 4b04 	ldr.w	r4, [r1], #4
322050a4:	f1a3 3201 	sub.w	r2, r3, #16843009	@ 0x1010101
322050a8:	439a      	bics	r2, r3
322050aa:	f012 3f80 	tst.w	r2, #2155905152	@ 0x80808080
322050ae:	f1a4 3201 	sub.w	r2, r4, #16843009	@ 0x1010101
322050b2:	d10b      	bne.n	322050cc <strcpy+0x6c>
322050b4:	f84c 3b04 	str.w	r3, [ip], #4
322050b8:	43a2      	bics	r2, r4
322050ba:	f012 3f80 	tst.w	r2, #2155905152	@ 0x80808080
322050be:	bf04      	itt	eq
322050c0:	f851 3b04 	ldreq.w	r3, [r1], #4
322050c4:	f84c 4b04 	streq.w	r4, [ip], #4
322050c8:	d0e8      	beq.n	3220509c <strcpy+0x3c>
322050ca:	4623      	mov	r3, r4
322050cc:	f80c 3b01 	strb.w	r3, [ip], #1
322050d0:	f013 0fff 	tst.w	r3, #255	@ 0xff
322050d4:	ea4f 2333 	mov.w	r3, r3, ror #8
322050d8:	d1f8      	bne.n	322050cc <strcpy+0x6c>
322050da:	f85d 4b04 	ldr.w	r4, [sp], #4
322050de:	4770      	bx	lr
322050e0:	f011 0f01 	tst.w	r1, #1
322050e4:	d006      	beq.n	322050f4 <strcpy+0x94>
322050e6:	f811 2b01 	ldrb.w	r2, [r1], #1
322050ea:	f80c 2b01 	strb.w	r2, [ip], #1
322050ee:	2a00      	cmp	r2, #0
322050f0:	bf08      	it	eq
322050f2:	4770      	bxeq	lr
322050f4:	f011 0f02 	tst.w	r1, #2
322050f8:	d0bd      	beq.n	32205076 <strcpy+0x16>
322050fa:	f831 2b02 	ldrh.w	r2, [r1], #2
322050fe:	f012 0fff 	tst.w	r2, #255	@ 0xff
32205102:	bf16      	itet	ne
32205104:	f82c 2b02 	strhne.w	r2, [ip], #2
32205108:	f88c 2000 	strbeq.w	r2, [ip]
3220510c:	f412 4f7f 	tstne.w	r2, #65280	@ 0xff00
32205110:	d1b1      	bne.n	32205076 <strcpy+0x16>
32205112:	4770      	bx	lr
32205114:	f811 2b01 	ldrb.w	r2, [r1], #1
32205118:	f80c 2b01 	strb.w	r2, [ip], #1
3220511c:	2a00      	cmp	r2, #0
3220511e:	d1f9      	bne.n	32205114 <strcpy+0xb4>
32205120:	4770      	bx	lr
32205122:	bf00      	nop
	...

32205130 <memchr>:
32205130:	2a07      	cmp	r2, #7
32205132:	d80a      	bhi.n	3220514a <memchr+0x1a>
32205134:	f001 01ff 	and.w	r1, r1, #255	@ 0xff
32205138:	3a01      	subs	r2, #1
3220513a:	d36a      	bcc.n	32205212 <memchr+0xe2>
3220513c:	f810 3b01 	ldrb.w	r3, [r0], #1
32205140:	428b      	cmp	r3, r1
32205142:	d1f9      	bne.n	32205138 <memchr+0x8>
32205144:	f1a0 0001 	sub.w	r0, r0, #1
32205148:	4770      	bx	lr
3220514a:	eee0 1b10 	vdup.8	q0, r1
3220514e:	f240 2301 	movw	r3, #513	@ 0x201
32205152:	f6c0 0304 	movt	r3, #2052	@ 0x804
32205156:	ea4f 1c03 	mov.w	ip, r3, lsl #4
3220515a:	ec4c 3b16 	vmov	d6, r3, ip
3220515e:	ec4c 3b17 	vmov	d7, r3, ip
32205162:	f020 011f 	bic.w	r1, r0, #31
32205166:	f010 0c1f 	ands.w	ip, r0, #31
3220516a:	d01c      	beq.n	322051a6 <memchr+0x76>
3220516c:	f921 223d 	vld1.8	{d2-d5}, [r1 :256]!
32205170:	f1ac 0320 	sub.w	r3, ip, #32
32205174:	18d2      	adds	r2, r2, r3
32205176:	ff02 2850 	vceq.i8	q1, q1, q0
3220517a:	ff04 4850 	vceq.i8	q2, q2, q0
3220517e:	ef02 2156 	vand	q1, q1, q3
32205182:	ef04 4156 	vand	q2, q2, q3
32205186:	ef02 2b13 	vpadd.i8	d2, d2, d3
3220518a:	ef04 4b15 	vpadd.i8	d4, d4, d5
3220518e:	ef02 2b14 	vpadd.i8	d2, d2, d4
32205192:	ef02 2b12 	vpadd.i8	d2, d2, d2
32205196:	ee12 0b10 	vmov.32	r0, d2[0]
3220519a:	fa20 f00c 	lsr.w	r0, r0, ip
3220519e:	fa00 f00c 	lsl.w	r0, r0, ip
322051a2:	d927      	bls.n	322051f4 <memchr+0xc4>
322051a4:	bb68      	cbnz	r0, 32205202 <memchr+0xd2>
322051a6:	ed2d 8b04 	vpush	{d8-d9}
322051aa:	bf00      	nop
322051ac:	f3af 8000 	nop.w
322051b0:	f921 223d 	vld1.8	{d2-d5}, [r1 :256]!
322051b4:	3a20      	subs	r2, #32
322051b6:	ff02 2850 	vceq.i8	q1, q1, q0
322051ba:	ff04 4850 	vceq.i8	q2, q2, q0
322051be:	d907      	bls.n	322051d0 <memchr+0xa0>
322051c0:	ef22 8154 	vorr	q4, q1, q2
322051c4:	ef28 8119 	vorr	d8, d8, d9
322051c8:	ec53 0b18 	vmov	r0, r3, d8
322051cc:	4318      	orrs	r0, r3
322051ce:	d0ef      	beq.n	322051b0 <memchr+0x80>
322051d0:	ecbd 8b04 	vpop	{d8-d9}
322051d4:	ef02 2156 	vand	q1, q1, q3
322051d8:	ef04 4156 	vand	q2, q2, q3
322051dc:	ef02 2b13 	vpadd.i8	d2, d2, d3
322051e0:	ef04 4b15 	vpadd.i8	d4, d4, d5
322051e4:	ef02 2b14 	vpadd.i8	d2, d2, d4
322051e8:	ef02 2b12 	vpadd.i8	d2, d2, d2
322051ec:	ee12 0b10 	vmov.32	r0, d2[0]
322051f0:	b178      	cbz	r0, 32205212 <memchr+0xe2>
322051f2:	d806      	bhi.n	32205202 <memchr+0xd2>
322051f4:	f1c2 0200 	rsb	r2, r2, #0
322051f8:	fa00 f002 	lsl.w	r0, r0, r2
322051fc:	40d0      	lsrs	r0, r2
322051fe:	bf08      	it	eq
32205200:	2100      	moveq	r1, #0
32205202:	fa90 f0a0 	rbit	r0, r0
32205206:	f1a1 0120 	sub.w	r1, r1, #32
3220520a:	fab0 f080 	clz	r0, r0
3220520e:	4408      	add	r0, r1
32205210:	4770      	bx	lr
32205212:	f04f 0000 	mov.w	r0, #0
32205216:	4770      	bx	lr
	...

32205240 <memcpy>:
32205240:	e1a0c000 	mov	ip, r0
32205244:	e3520040 	cmp	r2, #64	@ 0x40
32205248:	aa000019 	bge	322052b4 <memcpy+0x74>
3220524c:	e2023038 	and	r3, r2, #56	@ 0x38
32205250:	e2633034 	rsb	r3, r3, #52	@ 0x34
32205254:	e08ff003 	add	pc, pc, r3
32205258:	f421070d 	vld1.8	{d0}, [r1]!
3220525c:	f40c070d 	vst1.8	{d0}, [ip]!
32205260:	f421070d 	vld1.8	{d0}, [r1]!
32205264:	f40c070d 	vst1.8	{d0}, [ip]!
32205268:	f421070d 	vld1.8	{d0}, [r1]!
3220526c:	f40c070d 	vst1.8	{d0}, [ip]!
32205270:	f421070d 	vld1.8	{d0}, [r1]!
32205274:	f40c070d 	vst1.8	{d0}, [ip]!
32205278:	f421070d 	vld1.8	{d0}, [r1]!
3220527c:	f40c070d 	vst1.8	{d0}, [ip]!
32205280:	f421070d 	vld1.8	{d0}, [r1]!
32205284:	f40c070d 	vst1.8	{d0}, [ip]!
32205288:	f421070d 	vld1.8	{d0}, [r1]!
3220528c:	f40c070d 	vst1.8	{d0}, [ip]!
32205290:	e3120004 	tst	r2, #4
32205294:	14913004 	ldrne	r3, [r1], #4
32205298:	148c3004 	strne	r3, [ip], #4
3220529c:	e1b02f82 	lsls	r2, r2, #31
322052a0:	20d130b2 	ldrhcs	r3, [r1], #2
322052a4:	15d11000 	ldrbne	r1, [r1]
322052a8:	20cc30b2 	strhcs	r3, [ip], #2
322052ac:	15cc1000 	strbne	r1, [ip]
322052b0:	e12fff1e 	bx	lr
322052b4:	e52da004 	push	{sl}		@ (str sl, [sp, #-4]!)
322052b8:	e201a007 	and	sl, r1, #7
322052bc:	e20c3007 	and	r3, ip, #7
322052c0:	e153000a 	cmp	r3, sl
322052c4:	1a0000f1 	bne	32205690 <memcpy+0x450>
322052c8:	eeb00a40 	vmov.f32	s0, s0
322052cc:	e1b0ae8c 	lsls	sl, ip, #29
322052d0:	0a000008 	beq	322052f8 <memcpy+0xb8>
322052d4:	e27aa000 	rsbs	sl, sl, #0
322052d8:	e0422eaa 	sub	r2, r2, sl, lsr #29
322052dc:	44913004 	ldrmi	r3, [r1], #4
322052e0:	448c3004 	strmi	r3, [ip], #4
322052e4:	e1b0a10a 	lsls	sl, sl, #2
322052e8:	20d130b2 	ldrhcs	r3, [r1], #2
322052ec:	14d1a001 	ldrbne	sl, [r1], #1
322052f0:	20cc30b2 	strhcs	r3, [ip], #2
322052f4:	14cca001 	strbne	sl, [ip], #1
322052f8:	e252a040 	subs	sl, r2, #64	@ 0x40
322052fc:	ba000017 	blt	32205360 <memcpy+0x120>
32205300:	e35a0c02 	cmp	sl, #512	@ 0x200
32205304:	aa000032 	bge	322053d4 <memcpy+0x194>
32205308:	ed910b00 	vldr	d0, [r1]
3220530c:	e25aa040 	subs	sl, sl, #64	@ 0x40
32205310:	ed911b02 	vldr	d1, [r1, #8]
32205314:	ed8c0b00 	vstr	d0, [ip]
32205318:	ed910b04 	vldr	d0, [r1, #16]
3220531c:	ed8c1b02 	vstr	d1, [ip, #8]
32205320:	ed911b06 	vldr	d1, [r1, #24]
32205324:	ed8c0b04 	vstr	d0, [ip, #16]
32205328:	ed910b08 	vldr	d0, [r1, #32]
3220532c:	ed8c1b06 	vstr	d1, [ip, #24]
32205330:	ed911b0a 	vldr	d1, [r1, #40]	@ 0x28
32205334:	ed8c0b08 	vstr	d0, [ip, #32]
32205338:	ed910b0c 	vldr	d0, [r1, #48]	@ 0x30
3220533c:	ed8c1b0a 	vstr	d1, [ip, #40]	@ 0x28
32205340:	ed911b0e 	vldr	d1, [r1, #56]	@ 0x38
32205344:	ed8c0b0c 	vstr	d0, [ip, #48]	@ 0x30
32205348:	e2811040 	add	r1, r1, #64	@ 0x40
3220534c:	ed8c1b0e 	vstr	d1, [ip, #56]	@ 0x38
32205350:	e28cc040 	add	ip, ip, #64	@ 0x40
32205354:	aaffffeb 	bge	32205308 <memcpy+0xc8>
32205358:	e31a003f 	tst	sl, #63	@ 0x3f
3220535c:	0a00001a 	beq	322053cc <memcpy+0x18c>
32205360:	e20a3038 	and	r3, sl, #56	@ 0x38
32205364:	e08cc003 	add	ip, ip, r3
32205368:	e0811003 	add	r1, r1, r3
3220536c:	e2633034 	rsb	r3, r3, #52	@ 0x34
32205370:	e08ff003 	add	pc, pc, r3
32205374:	ed110b0e 	vldr	d0, [r1, #-56]	@ 0xffffffc8
32205378:	ed0c0b0e 	vstr	d0, [ip, #-56]	@ 0xffffffc8
3220537c:	ed110b0c 	vldr	d0, [r1, #-48]	@ 0xffffffd0
32205380:	ed0c0b0c 	vstr	d0, [ip, #-48]	@ 0xffffffd0
32205384:	ed110b0a 	vldr	d0, [r1, #-40]	@ 0xffffffd8
32205388:	ed0c0b0a 	vstr	d0, [ip, #-40]	@ 0xffffffd8
3220538c:	ed110b08 	vldr	d0, [r1, #-32]	@ 0xffffffe0
32205390:	ed0c0b08 	vstr	d0, [ip, #-32]	@ 0xffffffe0
32205394:	ed110b06 	vldr	d0, [r1, #-24]	@ 0xffffffe8
32205398:	ed0c0b06 	vstr	d0, [ip, #-24]	@ 0xffffffe8
3220539c:	ed110b04 	vldr	d0, [r1, #-16]
322053a0:	ed0c0b04 	vstr	d0, [ip, #-16]
322053a4:	ed110b02 	vldr	d0, [r1, #-8]
322053a8:	ed0c0b02 	vstr	d0, [ip, #-8]
322053ac:	e31a0004 	tst	sl, #4
322053b0:	14913004 	ldrne	r3, [r1], #4
322053b4:	148c3004 	strne	r3, [ip], #4
322053b8:	e1b0af8a 	lsls	sl, sl, #31
322053bc:	20d130b2 	ldrhcs	r3, [r1], #2
322053c0:	15d1a000 	ldrbne	sl, [r1]
322053c4:	20cc30b2 	strhcs	r3, [ip], #2
322053c8:	15cca000 	strbne	sl, [ip]
322053cc:	e49da004 	pop	{sl}		@ (ldr sl, [sp], #4)
322053d0:	e12fff1e 	bx	lr
322053d4:	ed913b00 	vldr	d3, [r1]
322053d8:	ed914b10 	vldr	d4, [r1, #64]	@ 0x40
322053dc:	ed915b20 	vldr	d5, [r1, #128]	@ 0x80
322053e0:	ed916b30 	vldr	d6, [r1, #192]	@ 0xc0
322053e4:	ed917b40 	vldr	d7, [r1, #256]	@ 0x100
322053e8:	ed910b02 	vldr	d0, [r1, #8]
322053ec:	ed911b04 	vldr	d1, [r1, #16]
322053f0:	ed912b06 	vldr	d2, [r1, #24]
322053f4:	e2811020 	add	r1, r1, #32
322053f8:	e25aad0a 	subs	sl, sl, #640	@ 0x280
322053fc:	ba000055 	blt	32205558 <memcpy+0x318>
32205400:	ed8c3b00 	vstr	d3, [ip]
32205404:	ed913b00 	vldr	d3, [r1]
32205408:	ed8c0b02 	vstr	d0, [ip, #8]
3220540c:	ed910b02 	vldr	d0, [r1, #8]
32205410:	ed8c1b04 	vstr	d1, [ip, #16]
32205414:	ed911b04 	vldr	d1, [r1, #16]
32205418:	ed8c2b06 	vstr	d2, [ip, #24]
3220541c:	ed912b06 	vldr	d2, [r1, #24]
32205420:	ed8c3b08 	vstr	d3, [ip, #32]
32205424:	ed913b48 	vldr	d3, [r1, #288]	@ 0x120
32205428:	ed8c0b0a 	vstr	d0, [ip, #40]	@ 0x28
3220542c:	ed910b0a 	vldr	d0, [r1, #40]	@ 0x28
32205430:	ed8c1b0c 	vstr	d1, [ip, #48]	@ 0x30
32205434:	ed911b0c 	vldr	d1, [r1, #48]	@ 0x30
32205438:	ed8c2b0e 	vstr	d2, [ip, #56]	@ 0x38
3220543c:	ed912b0e 	vldr	d2, [r1, #56]	@ 0x38
32205440:	ed8c4b10 	vstr	d4, [ip, #64]	@ 0x40
32205444:	ed914b10 	vldr	d4, [r1, #64]	@ 0x40
32205448:	ed8c0b12 	vstr	d0, [ip, #72]	@ 0x48
3220544c:	ed910b12 	vldr	d0, [r1, #72]	@ 0x48
32205450:	ed8c1b14 	vstr	d1, [ip, #80]	@ 0x50
32205454:	ed911b14 	vldr	d1, [r1, #80]	@ 0x50
32205458:	ed8c2b16 	vstr	d2, [ip, #88]	@ 0x58
3220545c:	ed912b16 	vldr	d2, [r1, #88]	@ 0x58
32205460:	ed8c4b18 	vstr	d4, [ip, #96]	@ 0x60
32205464:	ed914b58 	vldr	d4, [r1, #352]	@ 0x160
32205468:	ed8c0b1a 	vstr	d0, [ip, #104]	@ 0x68
3220546c:	ed910b1a 	vldr	d0, [r1, #104]	@ 0x68
32205470:	ed8c1b1c 	vstr	d1, [ip, #112]	@ 0x70
32205474:	ed911b1c 	vldr	d1, [r1, #112]	@ 0x70
32205478:	ed8c2b1e 	vstr	d2, [ip, #120]	@ 0x78
3220547c:	ed912b1e 	vldr	d2, [r1, #120]	@ 0x78
32205480:	ed8c5b20 	vstr	d5, [ip, #128]	@ 0x80
32205484:	ed915b20 	vldr	d5, [r1, #128]	@ 0x80
32205488:	ed8c0b22 	vstr	d0, [ip, #136]	@ 0x88
3220548c:	ed910b22 	vldr	d0, [r1, #136]	@ 0x88
32205490:	ed8c1b24 	vstr	d1, [ip, #144]	@ 0x90
32205494:	ed911b24 	vldr	d1, [r1, #144]	@ 0x90
32205498:	ed8c2b26 	vstr	d2, [ip, #152]	@ 0x98
3220549c:	ed912b26 	vldr	d2, [r1, #152]	@ 0x98
322054a0:	ed8c5b28 	vstr	d5, [ip, #160]	@ 0xa0
322054a4:	ed915b68 	vldr	d5, [r1, #416]	@ 0x1a0
322054a8:	ed8c0b2a 	vstr	d0, [ip, #168]	@ 0xa8
322054ac:	ed910b2a 	vldr	d0, [r1, #168]	@ 0xa8
322054b0:	ed8c1b2c 	vstr	d1, [ip, #176]	@ 0xb0
322054b4:	ed911b2c 	vldr	d1, [r1, #176]	@ 0xb0
322054b8:	ed8c2b2e 	vstr	d2, [ip, #184]	@ 0xb8
322054bc:	ed912b2e 	vldr	d2, [r1, #184]	@ 0xb8
322054c0:	e28cc0c0 	add	ip, ip, #192	@ 0xc0
322054c4:	e28110c0 	add	r1, r1, #192	@ 0xc0
322054c8:	ed8c6b00 	vstr	d6, [ip]
322054cc:	ed916b00 	vldr	d6, [r1]
322054d0:	ed8c0b02 	vstr	d0, [ip, #8]
322054d4:	ed910b02 	vldr	d0, [r1, #8]
322054d8:	ed8c1b04 	vstr	d1, [ip, #16]
322054dc:	ed911b04 	vldr	d1, [r1, #16]
322054e0:	ed8c2b06 	vstr	d2, [ip, #24]
322054e4:	ed912b06 	vldr	d2, [r1, #24]
322054e8:	ed8c6b08 	vstr	d6, [ip, #32]
322054ec:	ed916b48 	vldr	d6, [r1, #288]	@ 0x120
322054f0:	ed8c0b0a 	vstr	d0, [ip, #40]	@ 0x28
322054f4:	ed910b0a 	vldr	d0, [r1, #40]	@ 0x28
322054f8:	ed8c1b0c 	vstr	d1, [ip, #48]	@ 0x30
322054fc:	ed911b0c 	vldr	d1, [r1, #48]	@ 0x30
32205500:	ed8c2b0e 	vstr	d2, [ip, #56]	@ 0x38
32205504:	ed912b0e 	vldr	d2, [r1, #56]	@ 0x38
32205508:	ed8c7b10 	vstr	d7, [ip, #64]	@ 0x40
3220550c:	ed917b10 	vldr	d7, [r1, #64]	@ 0x40
32205510:	ed8c0b12 	vstr	d0, [ip, #72]	@ 0x48
32205514:	ed910b12 	vldr	d0, [r1, #72]	@ 0x48
32205518:	ed8c1b14 	vstr	d1, [ip, #80]	@ 0x50
3220551c:	ed911b14 	vldr	d1, [r1, #80]	@ 0x50
32205520:	ed8c2b16 	vstr	d2, [ip, #88]	@ 0x58
32205524:	ed912b16 	vldr	d2, [r1, #88]	@ 0x58
32205528:	ed8c7b18 	vstr	d7, [ip, #96]	@ 0x60
3220552c:	ed917b58 	vldr	d7, [r1, #352]	@ 0x160
32205530:	ed8c0b1a 	vstr	d0, [ip, #104]	@ 0x68
32205534:	ed910b1a 	vldr	d0, [r1, #104]	@ 0x68
32205538:	ed8c1b1c 	vstr	d1, [ip, #112]	@ 0x70
3220553c:	ed911b1c 	vldr	d1, [r1, #112]	@ 0x70
32205540:	ed8c2b1e 	vstr	d2, [ip, #120]	@ 0x78
32205544:	ed912b1e 	vldr	d2, [r1, #120]	@ 0x78
32205548:	e28cc080 	add	ip, ip, #128	@ 0x80
3220554c:	e2811080 	add	r1, r1, #128	@ 0x80
32205550:	e25aad05 	subs	sl, sl, #320	@ 0x140
32205554:	aaffffa9 	bge	32205400 <memcpy+0x1c0>
32205558:	ed8c3b00 	vstr	d3, [ip]
3220555c:	ed913b00 	vldr	d3, [r1]
32205560:	ed8c0b02 	vstr	d0, [ip, #8]
32205564:	ed910b02 	vldr	d0, [r1, #8]
32205568:	ed8c1b04 	vstr	d1, [ip, #16]
3220556c:	ed911b04 	vldr	d1, [r1, #16]
32205570:	ed8c2b06 	vstr	d2, [ip, #24]
32205574:	ed912b06 	vldr	d2, [r1, #24]
32205578:	ed8c3b08 	vstr	d3, [ip, #32]
3220557c:	ed8c0b0a 	vstr	d0, [ip, #40]	@ 0x28
32205580:	ed910b0a 	vldr	d0, [r1, #40]	@ 0x28
32205584:	ed8c1b0c 	vstr	d1, [ip, #48]	@ 0x30
32205588:	ed911b0c 	vldr	d1, [r1, #48]	@ 0x30
3220558c:	ed8c2b0e 	vstr	d2, [ip, #56]	@ 0x38
32205590:	ed912b0e 	vldr	d2, [r1, #56]	@ 0x38
32205594:	ed8c4b10 	vstr	d4, [ip, #64]	@ 0x40
32205598:	ed914b10 	vldr	d4, [r1, #64]	@ 0x40
3220559c:	ed8c0b12 	vstr	d0, [ip, #72]	@ 0x48
322055a0:	ed910b12 	vldr	d0, [r1, #72]	@ 0x48
322055a4:	ed8c1b14 	vstr	d1, [ip, #80]	@ 0x50
322055a8:	ed911b14 	vldr	d1, [r1, #80]	@ 0x50
322055ac:	ed8c2b16 	vstr	d2, [ip, #88]	@ 0x58
322055b0:	ed912b16 	vldr	d2, [r1, #88]	@ 0x58
322055b4:	ed8c4b18 	vstr	d4, [ip, #96]	@ 0x60
322055b8:	ed8c0b1a 	vstr	d0, [ip, #104]	@ 0x68
322055bc:	ed910b1a 	vldr	d0, [r1, #104]	@ 0x68
322055c0:	ed8c1b1c 	vstr	d1, [ip, #112]	@ 0x70
322055c4:	ed911b1c 	vldr	d1, [r1, #112]	@ 0x70
322055c8:	ed8c2b1e 	vstr	d2, [ip, #120]	@ 0x78
322055cc:	ed912b1e 	vldr	d2, [r1, #120]	@ 0x78
322055d0:	ed8c5b20 	vstr	d5, [ip, #128]	@ 0x80
322055d4:	ed915b20 	vldr	d5, [r1, #128]	@ 0x80
322055d8:	ed8c0b22 	vstr	d0, [ip, #136]	@ 0x88
322055dc:	ed910b22 	vldr	d0, [r1, #136]	@ 0x88
322055e0:	ed8c1b24 	vstr	d1, [ip, #144]	@ 0x90
322055e4:	ed911b24 	vldr	d1, [r1, #144]	@ 0x90
322055e8:	ed8c2b26 	vstr	d2, [ip, #152]	@ 0x98
322055ec:	ed912b26 	vldr	d2, [r1, #152]	@ 0x98
322055f0:	ed8c5b28 	vstr	d5, [ip, #160]	@ 0xa0
322055f4:	ed8c0b2a 	vstr	d0, [ip, #168]	@ 0xa8
322055f8:	ed910b2a 	vldr	d0, [r1, #168]	@ 0xa8
322055fc:	ed8c1b2c 	vstr	d1, [ip, #176]	@ 0xb0
32205600:	ed911b2c 	vldr	d1, [r1, #176]	@ 0xb0
32205604:	ed8c2b2e 	vstr	d2, [ip, #184]	@ 0xb8
32205608:	ed912b2e 	vldr	d2, [r1, #184]	@ 0xb8
3220560c:	e28110c0 	add	r1, r1, #192	@ 0xc0
32205610:	e28cc0c0 	add	ip, ip, #192	@ 0xc0
32205614:	ed8c6b00 	vstr	d6, [ip]
32205618:	ed916b00 	vldr	d6, [r1]
3220561c:	ed8c0b02 	vstr	d0, [ip, #8]
32205620:	ed910b02 	vldr	d0, [r1, #8]
32205624:	ed8c1b04 	vstr	d1, [ip, #16]
32205628:	ed911b04 	vldr	d1, [r1, #16]
3220562c:	ed8c2b06 	vstr	d2, [ip, #24]
32205630:	ed912b06 	vldr	d2, [r1, #24]
32205634:	ed8c6b08 	vstr	d6, [ip, #32]
32205638:	ed8c0b0a 	vstr	d0, [ip, #40]	@ 0x28
3220563c:	ed910b0a 	vldr	d0, [r1, #40]	@ 0x28
32205640:	ed8c1b0c 	vstr	d1, [ip, #48]	@ 0x30
32205644:	ed911b0c 	vldr	d1, [r1, #48]	@ 0x30
32205648:	ed8c2b0e 	vstr	d2, [ip, #56]	@ 0x38
3220564c:	ed912b0e 	vldr	d2, [r1, #56]	@ 0x38
32205650:	ed8c7b10 	vstr	d7, [ip, #64]	@ 0x40
32205654:	ed917b10 	vldr	d7, [r1, #64]	@ 0x40
32205658:	ed8c0b12 	vstr	d0, [ip, #72]	@ 0x48
3220565c:	ed910b12 	vldr	d0, [r1, #72]	@ 0x48
32205660:	ed8c1b14 	vstr	d1, [ip, #80]	@ 0x50
32205664:	ed911b14 	vldr	d1, [r1, #80]	@ 0x50
32205668:	ed8c2b16 	vstr	d2, [ip, #88]	@ 0x58
3220566c:	ed912b16 	vldr	d2, [r1, #88]	@ 0x58
32205670:	ed8c7b18 	vstr	d7, [ip, #96]	@ 0x60
32205674:	e2811060 	add	r1, r1, #96	@ 0x60
32205678:	ed8c0b1a 	vstr	d0, [ip, #104]	@ 0x68
3220567c:	ed8c1b1c 	vstr	d1, [ip, #112]	@ 0x70
32205680:	ed8c2b1e 	vstr	d2, [ip, #120]	@ 0x78
32205684:	e28cc080 	add	ip, ip, #128	@ 0x80
32205688:	e28aad05 	add	sl, sl, #320	@ 0x140
3220568c:	eaffff1d 	b	32205308 <memcpy+0xc8>
32205690:	f5d1f000 	pld	[r1]
32205694:	f5d1f040 	pld	[r1, #64]	@ 0x40
32205698:	e1b0ae8c 	lsls	sl, ip, #29
3220569c:	f5d1f080 	pld	[r1, #128]	@ 0x80
322056a0:	0a000008 	beq	322056c8 <memcpy+0x488>
322056a4:	e27aa000 	rsbs	sl, sl, #0
322056a8:	e0422eaa 	sub	r2, r2, sl, lsr #29
322056ac:	44913004 	ldrmi	r3, [r1], #4
322056b0:	448c3004 	strmi	r3, [ip], #4
322056b4:	e1b0a10a 	lsls	sl, sl, #2
322056b8:	14d13001 	ldrbne	r3, [r1], #1
322056bc:	20d1a0b2 	ldrhcs	sl, [r1], #2
322056c0:	14cc3001 	strbne	r3, [ip], #1
322056c4:	20cca0b2 	strhcs	sl, [ip], #2
322056c8:	f5d1f0c0 	pld	[r1, #192]	@ 0xc0
322056cc:	e2522040 	subs	r2, r2, #64	@ 0x40
322056d0:	449da004 	popmi	{sl}		@ (ldrmi sl, [sp], #4)
322056d4:	4afffedc 	bmi	3220524c <memcpy+0xc>
322056d8:	f5d1f100 	pld	[r1, #256]	@ 0x100
322056dc:	f421020d 	vld1.8	{d0-d3}, [r1]!
322056e0:	f421420d 	vld1.8	{d4-d7}, [r1]!
322056e4:	e2522040 	subs	r2, r2, #64	@ 0x40
322056e8:	4a000006 	bmi	32205708 <memcpy+0x4c8>
322056ec:	f5d1f100 	pld	[r1, #256]	@ 0x100
322056f0:	f40c021d 	vst1.8	{d0-d3}, [ip :64]!
322056f4:	f421020d 	vld1.8	{d0-d3}, [r1]!
322056f8:	f40c421d 	vst1.8	{d4-d7}, [ip :64]!
322056fc:	f421420d 	vld1.8	{d4-d7}, [r1]!
32205700:	e2522040 	subs	r2, r2, #64	@ 0x40
32205704:	5afffff8 	bpl	322056ec <memcpy+0x4ac>
32205708:	f40c021d 	vst1.8	{d0-d3}, [ip :64]!
3220570c:	f40c421d 	vst1.8	{d4-d7}, [ip :64]!
32205710:	e212203f 	ands	r2, r2, #63	@ 0x3f
32205714:	e49da004 	pop	{sl}		@ (ldr sl, [sp], #4)
32205718:	1afffecb 	bne	3220524c <memcpy+0xc>
3220571c:	e12fff1e 	bx	lr
	...

32205740 <strlen>:
32205740:	b430      	push	{r4, r5}
32205742:	f890 f000 	pld	[r0]
32205746:	f020 0107 	bic.w	r1, r0, #7
3220574a:	f06f 0c00 	mvn.w	ip, #0
3220574e:	f010 0407 	ands.w	r4, r0, #7
32205752:	f891 f020 	pld	[r1, #32]
32205756:	f040 8048 	bne.w	322057ea <strlen+0xaa>
3220575a:	f04f 0400 	mov.w	r4, #0
3220575e:	f06f 0007 	mvn.w	r0, #7
32205762:	e9d1 2300 	ldrd	r2, r3, [r1]
32205766:	f891 f040 	pld	[r1, #64]	@ 0x40
3220576a:	f100 0008 	add.w	r0, r0, #8
3220576e:	fa82 f24c 	uadd8	r2, r2, ip
32205772:	faa4 f28c 	sel	r2, r4, ip
32205776:	fa83 f34c 	uadd8	r3, r3, ip
3220577a:	faa2 f38c 	sel	r3, r2, ip
3220577e:	bb4b      	cbnz	r3, 322057d4 <strlen+0x94>
32205780:	e9d1 2302 	ldrd	r2, r3, [r1, #8]
32205784:	fa82 f24c 	uadd8	r2, r2, ip
32205788:	f100 0008 	add.w	r0, r0, #8
3220578c:	faa4 f28c 	sel	r2, r4, ip
32205790:	fa83 f34c 	uadd8	r3, r3, ip
32205794:	faa2 f38c 	sel	r3, r2, ip
32205798:	b9e3      	cbnz	r3, 322057d4 <strlen+0x94>
3220579a:	e9d1 2304 	ldrd	r2, r3, [r1, #16]
3220579e:	fa82 f24c 	uadd8	r2, r2, ip
322057a2:	f100 0008 	add.w	r0, r0, #8
322057a6:	faa4 f28c 	sel	r2, r4, ip
322057aa:	fa83 f34c 	uadd8	r3, r3, ip
322057ae:	faa2 f38c 	sel	r3, r2, ip
322057b2:	b97b      	cbnz	r3, 322057d4 <strlen+0x94>
322057b4:	e9d1 2306 	ldrd	r2, r3, [r1, #24]
322057b8:	f101 0120 	add.w	r1, r1, #32
322057bc:	fa82 f24c 	uadd8	r2, r2, ip
322057c0:	f100 0008 	add.w	r0, r0, #8
322057c4:	faa4 f28c 	sel	r2, r4, ip
322057c8:	fa83 f34c 	uadd8	r3, r3, ip
322057cc:	faa2 f38c 	sel	r3, r2, ip
322057d0:	2b00      	cmp	r3, #0
322057d2:	d0c6      	beq.n	32205762 <strlen+0x22>
322057d4:	2a00      	cmp	r2, #0
322057d6:	bf04      	itt	eq
322057d8:	3004      	addeq	r0, #4
322057da:	461a      	moveq	r2, r3
322057dc:	ba12      	rev	r2, r2
322057de:	fab2 f282 	clz	r2, r2
322057e2:	eb00 00d2 	add.w	r0, r0, r2, lsr #3
322057e6:	bc30      	pop	{r4, r5}
322057e8:	4770      	bx	lr
322057ea:	e9d1 2300 	ldrd	r2, r3, [r1]
322057ee:	f004 0503 	and.w	r5, r4, #3
322057f2:	f1c4 0000 	rsb	r0, r4, #0
322057f6:	ea4f 05c5 	mov.w	r5, r5, lsl #3
322057fa:	f014 0f04 	tst.w	r4, #4
322057fe:	f891 f040 	pld	[r1, #64]	@ 0x40
32205802:	fa0c f505 	lsl.w	r5, ip, r5
32205806:	ea62 0205 	orn	r2, r2, r5
3220580a:	bf1c      	itt	ne
3220580c:	ea63 0305 	ornne	r3, r3, r5
32205810:	4662      	movne	r2, ip
32205812:	f04f 0400 	mov.w	r4, #0
32205816:	e7aa      	b.n	3220576e <strlen+0x2e>

32205818 <abort>:
32205818:	2006      	movs	r0, #6
3220581a:	b508      	push	{r3, lr}
3220581c:	f004 f812 	bl	32209844 <raise>
32205820:	2001      	movs	r0, #1
32205822:	f7fa ee3a 	blx	32200498 <_exit>
32205826:	bf00      	nop

32205828 <_malloc_trim_r>:
32205828:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
3220582c:	f24c 5820 	movw	r8, #50464	@ 0xc520
32205830:	f2c3 2820 	movt	r8, #12832	@ 0x3220
32205834:	4606      	mov	r6, r0
32205836:	2008      	movs	r0, #8
32205838:	4689      	mov	r9, r1
3220583a:	f004 f901 	bl	32209a40 <sysconf>
3220583e:	4605      	mov	r5, r0
32205840:	4630      	mov	r0, r6
32205842:	f000 fef3 	bl	3220662c <__malloc_lock>
32205846:	f8d8 3008 	ldr.w	r3, [r8, #8]
3220584a:	685f      	ldr	r7, [r3, #4]
3220584c:	f027 0703 	bic.w	r7, r7, #3
32205850:	f1a7 0411 	sub.w	r4, r7, #17
32205854:	eba4 0409 	sub.w	r4, r4, r9
32205858:	442c      	add	r4, r5
3220585a:	fbb4 f4f5 	udiv	r4, r4, r5
3220585e:	3c01      	subs	r4, #1
32205860:	fb05 f404 	mul.w	r4, r5, r4
32205864:	42a5      	cmp	r5, r4
32205866:	dc08      	bgt.n	3220587a <_malloc_trim_r+0x52>
32205868:	2100      	movs	r1, #0
3220586a:	4630      	mov	r0, r6
3220586c:	f004 f8d4 	bl	32209a18 <_sbrk_r>
32205870:	f8d8 3008 	ldr.w	r3, [r8, #8]
32205874:	443b      	add	r3, r7
32205876:	4298      	cmp	r0, r3
32205878:	d005      	beq.n	32205886 <_malloc_trim_r+0x5e>
3220587a:	4630      	mov	r0, r6
3220587c:	f000 fedc 	bl	32206638 <__malloc_unlock>
32205880:	2000      	movs	r0, #0
32205882:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
32205886:	4261      	negs	r1, r4
32205888:	4630      	mov	r0, r6
3220588a:	f004 f8c5 	bl	32209a18 <_sbrk_r>
3220588e:	3001      	adds	r0, #1
32205890:	d012      	beq.n	322058b8 <_malloc_trim_r+0x90>
32205892:	f8d8 2008 	ldr.w	r2, [r8, #8]
32205896:	f245 3368 	movw	r3, #21352	@ 0x5368
3220589a:	f2c3 2321 	movt	r3, #12833	@ 0x3221
3220589e:	1b3f      	subs	r7, r7, r4
322058a0:	f047 0701 	orr.w	r7, r7, #1
322058a4:	4630      	mov	r0, r6
322058a6:	6057      	str	r7, [r2, #4]
322058a8:	681a      	ldr	r2, [r3, #0]
322058aa:	1b12      	subs	r2, r2, r4
322058ac:	601a      	str	r2, [r3, #0]
322058ae:	f000 fec3 	bl	32206638 <__malloc_unlock>
322058b2:	2001      	movs	r0, #1
322058b4:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
322058b8:	2100      	movs	r1, #0
322058ba:	4630      	mov	r0, r6
322058bc:	f004 f8ac 	bl	32209a18 <_sbrk_r>
322058c0:	f8d8 2008 	ldr.w	r2, [r8, #8]
322058c4:	1a83      	subs	r3, r0, r2
322058c6:	2b0f      	cmp	r3, #15
322058c8:	ddd7      	ble.n	3220587a <_malloc_trim_r+0x52>
322058ca:	f043 0301 	orr.w	r3, r3, #1
322058ce:	6053      	str	r3, [r2, #4]
322058d0:	f24c 5318 	movw	r3, #50456	@ 0xc518
322058d4:	f2c3 2320 	movt	r3, #12832	@ 0x3220
322058d8:	f245 3168 	movw	r1, #21352	@ 0x5368
322058dc:	f2c3 2121 	movt	r1, #12833	@ 0x3221
322058e0:	681b      	ldr	r3, [r3, #0]
322058e2:	1ac0      	subs	r0, r0, r3
322058e4:	6008      	str	r0, [r1, #0]
322058e6:	e7c8      	b.n	3220587a <_malloc_trim_r+0x52>

322058e8 <_free_r>:
322058e8:	2900      	cmp	r1, #0
322058ea:	d067      	beq.n	322059bc <_free_r+0xd4>
322058ec:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
322058ee:	460c      	mov	r4, r1
322058f0:	4606      	mov	r6, r0
322058f2:	f000 fe9b 	bl	3220662c <__malloc_lock>
322058f6:	f1a4 0208 	sub.w	r2, r4, #8
322058fa:	f854 7c04 	ldr.w	r7, [r4, #-4]
322058fe:	f24c 5120 	movw	r1, #50464	@ 0xc520
32205902:	f2c3 2120 	movt	r1, #12832	@ 0x3220
32205906:	f027 0301 	bic.w	r3, r7, #1
3220590a:	f007 0e01 	and.w	lr, r7, #1
3220590e:	eb02 0c03 	add.w	ip, r2, r3
32205912:	6888      	ldr	r0, [r1, #8]
32205914:	f8dc 5004 	ldr.w	r5, [ip, #4]
32205918:	4560      	cmp	r0, ip
3220591a:	f025 0503 	bic.w	r5, r5, #3
3220591e:	f000 8084 	beq.w	32205a2a <_free_r+0x142>
32205922:	eb0c 0005 	add.w	r0, ip, r5
32205926:	f8cc 5004 	str.w	r5, [ip, #4]
3220592a:	6840      	ldr	r0, [r0, #4]
3220592c:	f000 0001 	and.w	r0, r0, #1
32205930:	f1be 0f00 	cmp.w	lr, #0
32205934:	d131      	bne.n	3220599a <_free_r+0xb2>
32205936:	f854 4c08 	ldr.w	r4, [r4, #-8]
3220593a:	1b12      	subs	r2, r2, r4
3220593c:	4423      	add	r3, r4
3220593e:	f101 0408 	add.w	r4, r1, #8
32205942:	6897      	ldr	r7, [r2, #8]
32205944:	42a7      	cmp	r7, r4
32205946:	d064      	beq.n	32205a12 <_free_r+0x12a>
32205948:	f8d2 e00c 	ldr.w	lr, [r2, #12]
3220594c:	f8c7 e00c 	str.w	lr, [r7, #12]
32205950:	f8ce 7008 	str.w	r7, [lr, #8]
32205954:	2800      	cmp	r0, #0
32205956:	f000 8088 	beq.w	32205a6a <_free_r+0x182>
3220595a:	f043 0001 	orr.w	r0, r3, #1
3220595e:	6050      	str	r0, [r2, #4]
32205960:	f8cc 3000 	str.w	r3, [ip]
32205964:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
32205968:	d231      	bcs.n	322059ce <_free_r+0xe6>
3220596a:	08d8      	lsrs	r0, r3, #3
3220596c:	095c      	lsrs	r4, r3, #5
3220596e:	3001      	adds	r0, #1
32205970:	2301      	movs	r3, #1
32205972:	b200      	sxth	r0, r0
32205974:	40a3      	lsls	r3, r4
32205976:	684c      	ldr	r4, [r1, #4]
32205978:	4323      	orrs	r3, r4
3220597a:	f851 4030 	ldr.w	r4, [r1, r0, lsl #3]
3220597e:	604b      	str	r3, [r1, #4]
32205980:	eb01 03c0 	add.w	r3, r1, r0, lsl #3
32205984:	6094      	str	r4, [r2, #8]
32205986:	3b08      	subs	r3, #8
32205988:	60d3      	str	r3, [r2, #12]
3220598a:	f841 2030 	str.w	r2, [r1, r0, lsl #3]
3220598e:	60e2      	str	r2, [r4, #12]
32205990:	4630      	mov	r0, r6
32205992:	e8bd 40f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, lr}
32205996:	f000 be4f 	b.w	32206638 <__malloc_unlock>
3220599a:	b980      	cbnz	r0, 322059be <_free_r+0xd6>
3220599c:	442b      	add	r3, r5
3220599e:	f101 0408 	add.w	r4, r1, #8
322059a2:	f8dc 0008 	ldr.w	r0, [ip, #8]
322059a6:	f043 0501 	orr.w	r5, r3, #1
322059aa:	42a0      	cmp	r0, r4
322059ac:	d076      	beq.n	32205a9c <_free_r+0x1b4>
322059ae:	f8dc 400c 	ldr.w	r4, [ip, #12]
322059b2:	60c4      	str	r4, [r0, #12]
322059b4:	60a0      	str	r0, [r4, #8]
322059b6:	6055      	str	r5, [r2, #4]
322059b8:	50d3      	str	r3, [r2, r3]
322059ba:	e7d3      	b.n	32205964 <_free_r+0x7c>
322059bc:	4770      	bx	lr
322059be:	f047 0701 	orr.w	r7, r7, #1
322059c2:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
322059c6:	f844 7c04 	str.w	r7, [r4, #-4]
322059ca:	50d3      	str	r3, [r2, r3]
322059cc:	d3cd      	bcc.n	3220596a <_free_r+0x82>
322059ce:	0a5d      	lsrs	r5, r3, #9
322059d0:	f5b3 6f20 	cmp.w	r3, #2560	@ 0xa00
322059d4:	d24b      	bcs.n	32205a6e <_free_r+0x186>
322059d6:	099d      	lsrs	r5, r3, #6
322059d8:	f105 0439 	add.w	r4, r5, #57	@ 0x39
322059dc:	3538      	adds	r5, #56	@ 0x38
322059de:	b224      	sxth	r4, r4
322059e0:	00e4      	lsls	r4, r4, #3
322059e2:	1908      	adds	r0, r1, r4
322059e4:	590c      	ldr	r4, [r1, r4]
322059e6:	3808      	subs	r0, #8
322059e8:	42a0      	cmp	r0, r4
322059ea:	d103      	bne.n	322059f4 <_free_r+0x10c>
322059ec:	e064      	b.n	32205ab8 <_free_r+0x1d0>
322059ee:	68a4      	ldr	r4, [r4, #8]
322059f0:	42a0      	cmp	r0, r4
322059f2:	d004      	beq.n	322059fe <_free_r+0x116>
322059f4:	6861      	ldr	r1, [r4, #4]
322059f6:	f021 0103 	bic.w	r1, r1, #3
322059fa:	4299      	cmp	r1, r3
322059fc:	d8f7      	bhi.n	322059ee <_free_r+0x106>
322059fe:	68e0      	ldr	r0, [r4, #12]
32205a00:	e9c2 4002 	strd	r4, r0, [r2, #8]
32205a04:	6082      	str	r2, [r0, #8]
32205a06:	4630      	mov	r0, r6
32205a08:	60e2      	str	r2, [r4, #12]
32205a0a:	e8bd 40f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, lr}
32205a0e:	f000 be13 	b.w	32206638 <__malloc_unlock>
32205a12:	2800      	cmp	r0, #0
32205a14:	d136      	bne.n	32205a84 <_free_r+0x19c>
32205a16:	441d      	add	r5, r3
32205a18:	e9dc 1302 	ldrd	r1, r3, [ip, #8]
32205a1c:	60cb      	str	r3, [r1, #12]
32205a1e:	6099      	str	r1, [r3, #8]
32205a20:	f045 0301 	orr.w	r3, r5, #1
32205a24:	6053      	str	r3, [r2, #4]
32205a26:	5155      	str	r5, [r2, r5]
32205a28:	e7b2      	b.n	32205990 <_free_r+0xa8>
32205a2a:	441d      	add	r5, r3
32205a2c:	f1be 0f00 	cmp.w	lr, #0
32205a30:	d107      	bne.n	32205a42 <_free_r+0x15a>
32205a32:	f854 3c08 	ldr.w	r3, [r4, #-8]
32205a36:	1ad2      	subs	r2, r2, r3
32205a38:	441d      	add	r5, r3
32205a3a:	e9d2 0302 	ldrd	r0, r3, [r2, #8]
32205a3e:	60c3      	str	r3, [r0, #12]
32205a40:	6098      	str	r0, [r3, #8]
32205a42:	f045 0301 	orr.w	r3, r5, #1
32205a46:	6053      	str	r3, [r2, #4]
32205a48:	f24c 531c 	movw	r3, #50460	@ 0xc51c
32205a4c:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32205a50:	608a      	str	r2, [r1, #8]
32205a52:	681b      	ldr	r3, [r3, #0]
32205a54:	42ab      	cmp	r3, r5
32205a56:	d89b      	bhi.n	32205990 <_free_r+0xa8>
32205a58:	f245 3398 	movw	r3, #21400	@ 0x5398
32205a5c:	f2c3 2321 	movt	r3, #12833	@ 0x3221
32205a60:	4630      	mov	r0, r6
32205a62:	6819      	ldr	r1, [r3, #0]
32205a64:	f7ff fee0 	bl	32205828 <_malloc_trim_r>
32205a68:	e792      	b.n	32205990 <_free_r+0xa8>
32205a6a:	442b      	add	r3, r5
32205a6c:	e799      	b.n	322059a2 <_free_r+0xba>
32205a6e:	2d14      	cmp	r5, #20
32205a70:	d90e      	bls.n	32205a90 <_free_r+0x1a8>
32205a72:	2d54      	cmp	r5, #84	@ 0x54
32205a74:	d827      	bhi.n	32205ac6 <_free_r+0x1de>
32205a76:	0b1d      	lsrs	r5, r3, #12
32205a78:	f105 046f 	add.w	r4, r5, #111	@ 0x6f
32205a7c:	356e      	adds	r5, #110	@ 0x6e
32205a7e:	b224      	sxth	r4, r4
32205a80:	00e4      	lsls	r4, r4, #3
32205a82:	e7ae      	b.n	322059e2 <_free_r+0xfa>
32205a84:	f043 0101 	orr.w	r1, r3, #1
32205a88:	6051      	str	r1, [r2, #4]
32205a8a:	f8cc 3000 	str.w	r3, [ip]
32205a8e:	e77f      	b.n	32205990 <_free_r+0xa8>
32205a90:	f105 045c 	add.w	r4, r5, #92	@ 0x5c
32205a94:	355b      	adds	r5, #91	@ 0x5b
32205a96:	b224      	sxth	r4, r4
32205a98:	00e4      	lsls	r4, r4, #3
32205a9a:	e7a2      	b.n	322059e2 <_free_r+0xfa>
32205a9c:	ee80 4b90 	vdup.32	d16, r4
32205aa0:	ee81 2b90 	vdup.32	d17, r2
32205aa4:	3408      	adds	r4, #8
32205aa6:	f102 0108 	add.w	r1, r2, #8
32205aaa:	f944 178f 	vst1.32	{d17}, [r4]
32205aae:	f941 078f 	vst1.32	{d16}, [r1]
32205ab2:	6055      	str	r5, [r2, #4]
32205ab4:	50d3      	str	r3, [r2, r3]
32205ab6:	e76b      	b.n	32205990 <_free_r+0xa8>
32205ab8:	10ad      	asrs	r5, r5, #2
32205aba:	2301      	movs	r3, #1
32205abc:	40ab      	lsls	r3, r5
32205abe:	684d      	ldr	r5, [r1, #4]
32205ac0:	432b      	orrs	r3, r5
32205ac2:	604b      	str	r3, [r1, #4]
32205ac4:	e79c      	b.n	32205a00 <_free_r+0x118>
32205ac6:	f5b5 7faa 	cmp.w	r5, #340	@ 0x154
32205aca:	d806      	bhi.n	32205ada <_free_r+0x1f2>
32205acc:	0bdd      	lsrs	r5, r3, #15
32205ace:	f105 0478 	add.w	r4, r5, #120	@ 0x78
32205ad2:	3577      	adds	r5, #119	@ 0x77
32205ad4:	b224      	sxth	r4, r4
32205ad6:	00e4      	lsls	r4, r4, #3
32205ad8:	e783      	b.n	322059e2 <_free_r+0xfa>
32205ada:	f240 5054 	movw	r0, #1364	@ 0x554
32205ade:	4285      	cmp	r5, r0
32205ae0:	d805      	bhi.n	32205aee <_free_r+0x206>
32205ae2:	0c9d      	lsrs	r5, r3, #18
32205ae4:	f105 047d 	add.w	r4, r5, #125	@ 0x7d
32205ae8:	357c      	adds	r5, #124	@ 0x7c
32205aea:	00e4      	lsls	r4, r4, #3
32205aec:	e779      	b.n	322059e2 <_free_r+0xfa>
32205aee:	f44f 747e 	mov.w	r4, #1016	@ 0x3f8
32205af2:	257e      	movs	r5, #126	@ 0x7e
32205af4:	e775      	b.n	322059e2 <_free_r+0xfa>
32205af6:	bf00      	nop

32205af8 <_findenv_r>:
32205af8:	e92d 47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
32205afc:	f64c 1828 	movw	r8, #51496	@ 0xc928
32205b00:	f2c3 2820 	movt	r8, #12832	@ 0x3220
32205b04:	4681      	mov	r9, r0
32205b06:	460e      	mov	r6, r1
32205b08:	4617      	mov	r7, r2
32205b0a:	f004 ff5b 	bl	3220a9c4 <__env_lock>
32205b0e:	f8d8 5000 	ldr.w	r5, [r8]
32205b12:	b1fd      	cbz	r5, 32205b54 <_findenv_r+0x5c>
32205b14:	7833      	ldrb	r3, [r6, #0]
32205b16:	4634      	mov	r4, r6
32205b18:	2b00      	cmp	r3, #0
32205b1a:	bf18      	it	ne
32205b1c:	2b3d      	cmpne	r3, #61	@ 0x3d
32205b1e:	d005      	beq.n	32205b2c <_findenv_r+0x34>
32205b20:	f814 3f01 	ldrb.w	r3, [r4, #1]!
32205b24:	2b00      	cmp	r3, #0
32205b26:	bf18      	it	ne
32205b28:	2b3d      	cmpne	r3, #61	@ 0x3d
32205b2a:	d1f9      	bne.n	32205b20 <_findenv_r+0x28>
32205b2c:	2b3d      	cmp	r3, #61	@ 0x3d
32205b2e:	d011      	beq.n	32205b54 <_findenv_r+0x5c>
32205b30:	6828      	ldr	r0, [r5, #0]
32205b32:	1ba4      	subs	r4, r4, r6
32205b34:	b170      	cbz	r0, 32205b54 <_findenv_r+0x5c>
32205b36:	4622      	mov	r2, r4
32205b38:	4631      	mov	r1, r6
32205b3a:	f003 fda9 	bl	32209690 <strncmp>
32205b3e:	b928      	cbnz	r0, 32205b4c <_findenv_r+0x54>
32205b40:	682b      	ldr	r3, [r5, #0]
32205b42:	eb03 0a04 	add.w	sl, r3, r4
32205b46:	5d1b      	ldrb	r3, [r3, r4]
32205b48:	2b3d      	cmp	r3, #61	@ 0x3d
32205b4a:	d009      	beq.n	32205b60 <_findenv_r+0x68>
32205b4c:	f855 0f04 	ldr.w	r0, [r5, #4]!
32205b50:	2800      	cmp	r0, #0
32205b52:	d1f0      	bne.n	32205b36 <_findenv_r+0x3e>
32205b54:	4648      	mov	r0, r9
32205b56:	f004 ff3b 	bl	3220a9d0 <__env_unlock>
32205b5a:	2000      	movs	r0, #0
32205b5c:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}
32205b60:	f8d8 3000 	ldr.w	r3, [r8]
32205b64:	4648      	mov	r0, r9
32205b66:	1aed      	subs	r5, r5, r3
32205b68:	10ad      	asrs	r5, r5, #2
32205b6a:	603d      	str	r5, [r7, #0]
32205b6c:	f004 ff30 	bl	3220a9d0 <__env_unlock>
32205b70:	f10a 0001 	add.w	r0, sl, #1
32205b74:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}

32205b78 <_getenv_r>:
32205b78:	b500      	push	{lr}
32205b7a:	b083      	sub	sp, #12
32205b7c:	aa01      	add	r2, sp, #4
32205b7e:	f7ff ffbb 	bl	32205af8 <_findenv_r>
32205b82:	b003      	add	sp, #12
32205b84:	f85d fb04 	ldr.w	pc, [sp], #4

32205b88 <_malloc_r>:
32205b88:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32205b8c:	f101 030b 	add.w	r3, r1, #11
32205b90:	4607      	mov	r7, r0
32205b92:	b083      	sub	sp, #12
32205b94:	2b16      	cmp	r3, #22
32205b96:	d826      	bhi.n	32205be6 <_malloc_r+0x5e>
32205b98:	2910      	cmp	r1, #16
32205b9a:	f200 80bd 	bhi.w	32205d18 <_malloc_r+0x190>
32205b9e:	f000 fd45 	bl	3220662c <__malloc_lock>
32205ba2:	2510      	movs	r5, #16
32205ba4:	2318      	movs	r3, #24
32205ba6:	2002      	movs	r0, #2
32205ba8:	f24c 5620 	movw	r6, #50464	@ 0xc520
32205bac:	f2c3 2620 	movt	r6, #12832	@ 0x3220
32205bb0:	4433      	add	r3, r6
32205bb2:	f1a3 0208 	sub.w	r2, r3, #8
32205bb6:	685c      	ldr	r4, [r3, #4]
32205bb8:	4294      	cmp	r4, r2
32205bba:	f000 817d 	beq.w	32205eb8 <_malloc_r+0x330>
32205bbe:	6863      	ldr	r3, [r4, #4]
32205bc0:	4638      	mov	r0, r7
32205bc2:	e9d4 1202 	ldrd	r1, r2, [r4, #8]
32205bc6:	f023 0303 	bic.w	r3, r3, #3
32205bca:	4423      	add	r3, r4
32205bcc:	60ca      	str	r2, [r1, #12]
32205bce:	6091      	str	r1, [r2, #8]
32205bd0:	685a      	ldr	r2, [r3, #4]
32205bd2:	3408      	adds	r4, #8
32205bd4:	f042 0201 	orr.w	r2, r2, #1
32205bd8:	605a      	str	r2, [r3, #4]
32205bda:	f000 fd2d 	bl	32206638 <__malloc_unlock>
32205bde:	4620      	mov	r0, r4
32205be0:	b003      	add	sp, #12
32205be2:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32205be6:	f023 0507 	bic.w	r5, r3, #7
32205bea:	42a9      	cmp	r1, r5
32205bec:	bf98      	it	ls
32205bee:	2100      	movls	r1, #0
32205bf0:	bf88      	it	hi
32205bf2:	2101      	movhi	r1, #1
32205bf4:	ea51 71d3 	orrs.w	r1, r1, r3, lsr #31
32205bf8:	f040 808e 	bne.w	32205d18 <_malloc_r+0x190>
32205bfc:	f000 fd16 	bl	3220662c <__malloc_lock>
32205c00:	f5b5 7ffc 	cmp.w	r5, #504	@ 0x1f8
32205c04:	f0c0 82b1 	bcc.w	3220616a <_malloc_r+0x5e2>
32205c08:	ea5f 2e55 	movs.w	lr, r5, lsr #9
32205c0c:	f000 808b 	beq.w	32205d26 <_malloc_r+0x19e>
32205c10:	f1be 0f04 	cmp.w	lr, #4
32205c14:	f200 817c 	bhi.w	32205f10 <_malloc_r+0x388>
32205c18:	ea4f 1e95 	mov.w	lr, r5, lsr #6
32205c1c:	f10e 0039 	add.w	r0, lr, #57	@ 0x39
32205c20:	f10e 0e38 	add.w	lr, lr, #56	@ 0x38
32205c24:	b203      	sxth	r3, r0
32205c26:	00db      	lsls	r3, r3, #3
32205c28:	f24c 5620 	movw	r6, #50464	@ 0xc520
32205c2c:	f2c3 2620 	movt	r6, #12832	@ 0x3220
32205c30:	4433      	add	r3, r6
32205c32:	f1a3 0c08 	sub.w	ip, r3, #8
32205c36:	685c      	ldr	r4, [r3, #4]
32205c38:	45a4      	cmp	ip, r4
32205c3a:	d107      	bne.n	32205c4c <_malloc_r+0xc4>
32205c3c:	e00d      	b.n	32205c5a <_malloc_r+0xd2>
32205c3e:	68e1      	ldr	r1, [r4, #12]
32205c40:	2a00      	cmp	r2, #0
32205c42:	f280 8133 	bge.w	32205eac <_malloc_r+0x324>
32205c46:	460c      	mov	r4, r1
32205c48:	458c      	cmp	ip, r1
32205c4a:	d006      	beq.n	32205c5a <_malloc_r+0xd2>
32205c4c:	6863      	ldr	r3, [r4, #4]
32205c4e:	f023 0303 	bic.w	r3, r3, #3
32205c52:	1b5a      	subs	r2, r3, r5
32205c54:	2a0f      	cmp	r2, #15
32205c56:	ddf2      	ble.n	32205c3e <_malloc_r+0xb6>
32205c58:	4670      	mov	r0, lr
32205c5a:	4bc1      	ldr	r3, [pc, #772]	@ (32205f60 <_malloc_r+0x3d8>)
32205c5c:	6934      	ldr	r4, [r6, #16]
32205c5e:	ee80 3b90 	vdup.32	d16, r3
32205c62:	429c      	cmp	r4, r3
32205c64:	f000 810f 	beq.w	32205e86 <_malloc_r+0x2fe>
32205c68:	6863      	ldr	r3, [r4, #4]
32205c6a:	f023 0e03 	bic.w	lr, r3, #3
32205c6e:	ebae 0305 	sub.w	r3, lr, r5
32205c72:	2b0f      	cmp	r3, #15
32205c74:	f300 818f 	bgt.w	32205f96 <_malloc_r+0x40e>
32205c78:	2b00      	cmp	r3, #0
32205c7a:	edc6 0b04 	vstr	d16, [r6, #16]
32205c7e:	f280 817e 	bge.w	32205f7e <_malloc_r+0x3f6>
32205c82:	6871      	ldr	r1, [r6, #4]
32205c84:	f5be 7f00 	cmp.w	lr, #512	@ 0x200
32205c88:	f080 811d 	bcs.w	32205ec6 <_malloc_r+0x33e>
32205c8c:	ea4f 03de 	mov.w	r3, lr, lsr #3
32205c90:	2201      	movs	r2, #1
32205c92:	3301      	adds	r3, #1
32205c94:	ea4f 1e5e 	mov.w	lr, lr, lsr #5
32205c98:	b21b      	sxth	r3, r3
32205c9a:	fa02 f20e 	lsl.w	r2, r2, lr
32205c9e:	4311      	orrs	r1, r2
32205ca0:	6071      	str	r1, [r6, #4]
32205ca2:	eb06 02c3 	add.w	r2, r6, r3, lsl #3
32205ca6:	f856 c033 	ldr.w	ip, [r6, r3, lsl #3]
32205caa:	3a08      	subs	r2, #8
32205cac:	f8c4 c008 	str.w	ip, [r4, #8]
32205cb0:	60e2      	str	r2, [r4, #12]
32205cb2:	f846 4033 	str.w	r4, [r6, r3, lsl #3]
32205cb6:	f8cc 400c 	str.w	r4, [ip, #12]
32205cba:	1083      	asrs	r3, r0, #2
32205cbc:	f04f 0c01 	mov.w	ip, #1
32205cc0:	fa0c fc03 	lsl.w	ip, ip, r3
32205cc4:	458c      	cmp	ip, r1
32205cc6:	d834      	bhi.n	32205d32 <_malloc_r+0x1aa>
32205cc8:	ea1c 0f01 	tst.w	ip, r1
32205ccc:	d107      	bne.n	32205cde <_malloc_r+0x156>
32205cce:	f020 0003 	bic.w	r0, r0, #3
32205cd2:	ea4f 0c4c 	mov.w	ip, ip, lsl #1
32205cd6:	3004      	adds	r0, #4
32205cd8:	ea1c 0f01 	tst.w	ip, r1
32205cdc:	d0f9      	beq.n	32205cd2 <_malloc_r+0x14a>
32205cde:	eb06 09c0 	add.w	r9, r6, r0, lsl #3
32205ce2:	4680      	mov	r8, r0
32205ce4:	46ce      	mov	lr, r9
32205ce6:	f8de 300c 	ldr.w	r3, [lr, #12]
32205cea:	e00b      	b.n	32205d04 <_malloc_r+0x17c>
32205cec:	685a      	ldr	r2, [r3, #4]
32205cee:	461c      	mov	r4, r3
32205cf0:	68db      	ldr	r3, [r3, #12]
32205cf2:	f022 0203 	bic.w	r2, r2, #3
32205cf6:	1b51      	subs	r1, r2, r5
32205cf8:	290f      	cmp	r1, #15
32205cfa:	f300 8119 	bgt.w	32205f30 <_malloc_r+0x3a8>
32205cfe:	2900      	cmp	r1, #0
32205d00:	f280 8130 	bge.w	32205f64 <_malloc_r+0x3dc>
32205d04:	459e      	cmp	lr, r3
32205d06:	d1f1      	bne.n	32205cec <_malloc_r+0x164>
32205d08:	f108 0801 	add.w	r8, r8, #1
32205d0c:	f10e 0e08 	add.w	lr, lr, #8
32205d10:	f018 0f03 	tst.w	r8, #3
32205d14:	d1e7      	bne.n	32205ce6 <_malloc_r+0x15e>
32205d16:	e183      	b.n	32206020 <_malloc_r+0x498>
32205d18:	230c      	movs	r3, #12
32205d1a:	603b      	str	r3, [r7, #0]
32205d1c:	2400      	movs	r4, #0
32205d1e:	4620      	mov	r0, r4
32205d20:	b003      	add	sp, #12
32205d22:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32205d26:	f44f 7300 	mov.w	r3, #512	@ 0x200
32205d2a:	2040      	movs	r0, #64	@ 0x40
32205d2c:	f04f 0e3f 	mov.w	lr, #63	@ 0x3f
32205d30:	e77a      	b.n	32205c28 <_malloc_r+0xa0>
32205d32:	68b4      	ldr	r4, [r6, #8]
32205d34:	6863      	ldr	r3, [r4, #4]
32205d36:	f023 0903 	bic.w	r9, r3, #3
32205d3a:	45a9      	cmp	r9, r5
32205d3c:	eba9 0305 	sub.w	r3, r9, r5
32205d40:	bf28      	it	cs
32205d42:	2200      	movcs	r2, #0
32205d44:	bf38      	it	cc
32205d46:	2201      	movcc	r2, #1
32205d48:	2b0f      	cmp	r3, #15
32205d4a:	bfc8      	it	gt
32205d4c:	2100      	movgt	r1, #0
32205d4e:	bfd8      	it	le
32205d50:	2101      	movle	r1, #1
32205d52:	430a      	orrs	r2, r1
32205d54:	f000 8099 	beq.w	32205e8a <_malloc_r+0x302>
32205d58:	f245 3398 	movw	r3, #21400	@ 0x5398
32205d5c:	f2c3 2321 	movt	r3, #12833	@ 0x3221
32205d60:	2008      	movs	r0, #8
32205d62:	681b      	ldr	r3, [r3, #0]
32205d64:	f103 0810 	add.w	r8, r3, #16
32205d68:	eb04 0309 	add.w	r3, r4, r9
32205d6c:	9300      	str	r3, [sp, #0]
32205d6e:	f003 fe67 	bl	32209a40 <sysconf>
32205d72:	f24c 5318 	movw	r3, #50456	@ 0xc518
32205d76:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32205d7a:	44a8      	add	r8, r5
32205d7c:	4683      	mov	fp, r0
32205d7e:	681a      	ldr	r2, [r3, #0]
32205d80:	3201      	adds	r2, #1
32205d82:	d005      	beq.n	32205d90 <_malloc_r+0x208>
32205d84:	f108 38ff 	add.w	r8, r8, #4294967295	@ 0xffffffff
32205d88:	4242      	negs	r2, r0
32205d8a:	4480      	add	r8, r0
32205d8c:	ea02 0808 	and.w	r8, r2, r8
32205d90:	4641      	mov	r1, r8
32205d92:	4638      	mov	r0, r7
32205d94:	9300      	str	r3, [sp, #0]
32205d96:	f003 fe3f 	bl	32209a18 <_sbrk_r>
32205d9a:	9b00      	ldr	r3, [sp, #0]
32205d9c:	4682      	mov	sl, r0
32205d9e:	f1b0 3fff 	cmp.w	r0, #4294967295	@ 0xffffffff
32205da2:	f000 8118 	beq.w	32205fd6 <_malloc_r+0x44e>
32205da6:	eb04 0209 	add.w	r2, r4, r9
32205daa:	4282      	cmp	r2, r0
32205dac:	f200 8111 	bhi.w	32205fd2 <_malloc_r+0x44a>
32205db0:	f245 3268 	movw	r2, #21352	@ 0x5368
32205db4:	f2c3 2221 	movt	r2, #12833	@ 0x3221
32205db8:	f10b 3eff 	add.w	lr, fp, #4294967295	@ 0xffffffff
32205dbc:	6811      	ldr	r1, [r2, #0]
32205dbe:	eb08 0001 	add.w	r0, r8, r1
32205dc2:	6010      	str	r0, [r2, #0]
32205dc4:	f000 817e 	beq.w	322060c4 <_malloc_r+0x53c>
32205dc8:	6819      	ldr	r1, [r3, #0]
32205dca:	3101      	adds	r1, #1
32205dcc:	f000 8186 	beq.w	322060dc <_malloc_r+0x554>
32205dd0:	eb04 0309 	add.w	r3, r4, r9
32205dd4:	ebaa 0303 	sub.w	r3, sl, r3
32205dd8:	4403      	add	r3, r0
32205dda:	6013      	str	r3, [r2, #0]
32205ddc:	f01a 0307 	ands.w	r3, sl, #7
32205de0:	e9cd 3200 	strd	r3, r2, [sp]
32205de4:	f000 813a 	beq.w	3220605c <_malloc_r+0x4d4>
32205de8:	f1c3 0308 	rsb	r3, r3, #8
32205dec:	4638      	mov	r0, r7
32205dee:	449a      	add	sl, r3
32205df0:	445b      	add	r3, fp
32205df2:	44d0      	add	r8, sl
32205df4:	ea08 010e 	and.w	r1, r8, lr
32205df8:	1a5b      	subs	r3, r3, r1
32205dfa:	ea03 0b0e 	and.w	fp, r3, lr
32205dfe:	4659      	mov	r1, fp
32205e00:	f003 fe0a 	bl	32209a18 <_sbrk_r>
32205e04:	1c42      	adds	r2, r0, #1
32205e06:	9a01      	ldr	r2, [sp, #4]
32205e08:	f000 8185 	beq.w	32206116 <_malloc_r+0x58e>
32205e0c:	eba0 000a 	sub.w	r0, r0, sl
32205e10:	eb00 080b 	add.w	r8, r0, fp
32205e14:	6813      	ldr	r3, [r2, #0]
32205e16:	f048 0101 	orr.w	r1, r8, #1
32205e1a:	f8c6 a008 	str.w	sl, [r6, #8]
32205e1e:	42b4      	cmp	r4, r6
32205e20:	eb0b 0003 	add.w	r0, fp, r3
32205e24:	f8ca 1004 	str.w	r1, [sl, #4]
32205e28:	6010      	str	r0, [r2, #0]
32205e2a:	d01a      	beq.n	32205e62 <_malloc_r+0x2da>
32205e2c:	f1b9 0f0f 	cmp.w	r9, #15
32205e30:	f240 8157 	bls.w	322060e2 <_malloc_r+0x55a>
32205e34:	6863      	ldr	r3, [r4, #4]
32205e36:	f1a9 010c 	sub.w	r1, r9, #12
32205e3a:	f021 0107 	bic.w	r1, r1, #7
32205e3e:	efc0 0015 	vmov.i32	d16, #5	@ 0x00000005
32205e42:	f003 0301 	and.w	r3, r3, #1
32205e46:	290f      	cmp	r1, #15
32205e48:	ea43 0301 	orr.w	r3, r3, r1
32205e4c:	6063      	str	r3, [r4, #4]
32205e4e:	eb04 0301 	add.w	r3, r4, r1
32205e52:	f103 0304 	add.w	r3, r3, #4
32205e56:	f943 078f 	vst1.32	{d16}, [r3]
32205e5a:	f200 8164 	bhi.w	32206126 <_malloc_r+0x59e>
32205e5e:	f8da 1004 	ldr.w	r1, [sl, #4]
32205e62:	f245 3394 	movw	r3, #21396	@ 0x5394
32205e66:	f2c3 2321 	movt	r3, #12833	@ 0x3221
32205e6a:	681a      	ldr	r2, [r3, #0]
32205e6c:	4282      	cmp	r2, r0
32205e6e:	d200      	bcs.n	32205e72 <_malloc_r+0x2ea>
32205e70:	6018      	str	r0, [r3, #0]
32205e72:	f245 3390 	movw	r3, #21392	@ 0x5390
32205e76:	f2c3 2321 	movt	r3, #12833	@ 0x3221
32205e7a:	681a      	ldr	r2, [r3, #0]
32205e7c:	4282      	cmp	r2, r0
32205e7e:	d200      	bcs.n	32205e82 <_malloc_r+0x2fa>
32205e80:	6018      	str	r0, [r3, #0]
32205e82:	4654      	mov	r4, sl
32205e84:	e0a9      	b.n	32205fda <_malloc_r+0x452>
32205e86:	6871      	ldr	r1, [r6, #4]
32205e88:	e717      	b.n	32205cba <_malloc_r+0x132>
32205e8a:	1962      	adds	r2, r4, r5
32205e8c:	f043 0301 	orr.w	r3, r3, #1
32205e90:	4638      	mov	r0, r7
32205e92:	f045 0501 	orr.w	r5, r5, #1
32205e96:	3408      	adds	r4, #8
32205e98:	f844 5c04 	str.w	r5, [r4, #-4]
32205e9c:	60b2      	str	r2, [r6, #8]
32205e9e:	6053      	str	r3, [r2, #4]
32205ea0:	f000 fbca 	bl	32206638 <__malloc_unlock>
32205ea4:	4620      	mov	r0, r4
32205ea6:	b003      	add	sp, #12
32205ea8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32205eac:	68a2      	ldr	r2, [r4, #8]
32205eae:	4423      	add	r3, r4
32205eb0:	4638      	mov	r0, r7
32205eb2:	60d1      	str	r1, [r2, #12]
32205eb4:	608a      	str	r2, [r1, #8]
32205eb6:	e68b      	b.n	32205bd0 <_malloc_r+0x48>
32205eb8:	68dc      	ldr	r4, [r3, #12]
32205eba:	42a3      	cmp	r3, r4
32205ebc:	bf08      	it	eq
32205ebe:	3002      	addeq	r0, #2
32205ec0:	f43f aecb 	beq.w	32205c5a <_malloc_r+0xd2>
32205ec4:	e67b      	b.n	32205bbe <_malloc_r+0x36>
32205ec6:	ea4f 225e 	mov.w	r2, lr, lsr #9
32205eca:	f5be 6f20 	cmp.w	lr, #2560	@ 0xa00
32205ece:	d378      	bcc.n	32205fc2 <_malloc_r+0x43a>
32205ed0:	2a14      	cmp	r2, #20
32205ed2:	f200 80d6 	bhi.w	32206082 <_malloc_r+0x4fa>
32205ed6:	f102 035c 	add.w	r3, r2, #92	@ 0x5c
32205eda:	325b      	adds	r2, #91	@ 0x5b
32205edc:	b21b      	sxth	r3, r3
32205ede:	00db      	lsls	r3, r3, #3
32205ee0:	eb06 0c03 	add.w	ip, r6, r3
32205ee4:	58f3      	ldr	r3, [r6, r3]
32205ee6:	f1ac 0c08 	sub.w	ip, ip, #8
32205eea:	459c      	cmp	ip, r3
32205eec:	d103      	bne.n	32205ef6 <_malloc_r+0x36e>
32205eee:	e0ad      	b.n	3220604c <_malloc_r+0x4c4>
32205ef0:	689b      	ldr	r3, [r3, #8]
32205ef2:	459c      	cmp	ip, r3
32205ef4:	d004      	beq.n	32205f00 <_malloc_r+0x378>
32205ef6:	685a      	ldr	r2, [r3, #4]
32205ef8:	f022 0203 	bic.w	r2, r2, #3
32205efc:	4572      	cmp	r2, lr
32205efe:	d8f7      	bhi.n	32205ef0 <_malloc_r+0x368>
32205f00:	f8d3 c00c 	ldr.w	ip, [r3, #12]
32205f04:	e9c4 3c02 	strd	r3, ip, [r4, #8]
32205f08:	f8cc 4008 	str.w	r4, [ip, #8]
32205f0c:	60dc      	str	r4, [r3, #12]
32205f0e:	e6d4      	b.n	32205cba <_malloc_r+0x132>
32205f10:	f1be 0f14 	cmp.w	lr, #20
32205f14:	d977      	bls.n	32206006 <_malloc_r+0x47e>
32205f16:	f1be 0f54 	cmp.w	lr, #84	@ 0x54
32205f1a:	f200 80bc 	bhi.w	32206096 <_malloc_r+0x50e>
32205f1e:	ea4f 3e15 	mov.w	lr, r5, lsr #12
32205f22:	f10e 006f 	add.w	r0, lr, #111	@ 0x6f
32205f26:	f10e 0e6e 	add.w	lr, lr, #110	@ 0x6e
32205f2a:	b203      	sxth	r3, r0
32205f2c:	00db      	lsls	r3, r3, #3
32205f2e:	e67b      	b.n	32205c28 <_malloc_r+0xa0>
32205f30:	4638      	mov	r0, r7
32205f32:	1967      	adds	r7, r4, r5
32205f34:	f045 0501 	orr.w	r5, r5, #1
32205f38:	6065      	str	r5, [r4, #4]
32205f3a:	68a5      	ldr	r5, [r4, #8]
32205f3c:	ee81 7b90 	vdup.32	d17, r7
32205f40:	60eb      	str	r3, [r5, #12]
32205f42:	609d      	str	r5, [r3, #8]
32205f44:	f107 0308 	add.w	r3, r7, #8
32205f48:	edc6 1b04 	vstr	d17, [r6, #16]
32205f4c:	f943 078f 	vst1.32	{d16}, [r3]
32205f50:	f041 0301 	orr.w	r3, r1, #1
32205f54:	607b      	str	r3, [r7, #4]
32205f56:	50a1      	str	r1, [r4, r2]
32205f58:	3408      	adds	r4, #8
32205f5a:	f000 fb6d 	bl	32206638 <__malloc_unlock>
32205f5e:	e6de      	b.n	32205d1e <_malloc_r+0x196>
32205f60:	3220c528 	.word	0x3220c528
32205f64:	4422      	add	r2, r4
32205f66:	4638      	mov	r0, r7
32205f68:	6851      	ldr	r1, [r2, #4]
32205f6a:	f041 0101 	orr.w	r1, r1, #1
32205f6e:	6051      	str	r1, [r2, #4]
32205f70:	f854 2f08 	ldr.w	r2, [r4, #8]!
32205f74:	60d3      	str	r3, [r2, #12]
32205f76:	609a      	str	r2, [r3, #8]
32205f78:	f000 fb5e 	bl	32206638 <__malloc_unlock>
32205f7c:	e6cf      	b.n	32205d1e <_malloc_r+0x196>
32205f7e:	44a6      	add	lr, r4
32205f80:	4638      	mov	r0, r7
32205f82:	3408      	adds	r4, #8
32205f84:	f8de 3004 	ldr.w	r3, [lr, #4]
32205f88:	f043 0301 	orr.w	r3, r3, #1
32205f8c:	f8ce 3004 	str.w	r3, [lr, #4]
32205f90:	f000 fb52 	bl	32206638 <__malloc_unlock>
32205f94:	e6c3      	b.n	32205d1e <_malloc_r+0x196>
32205f96:	1962      	adds	r2, r4, r5
32205f98:	4638      	mov	r0, r7
32205f9a:	f102 0108 	add.w	r1, r2, #8
32205f9e:	f045 0501 	orr.w	r5, r5, #1
32205fa2:	ee81 2b90 	vdup.32	d17, r2
32205fa6:	6065      	str	r5, [r4, #4]
32205fa8:	edc6 1b04 	vstr	d17, [r6, #16]
32205fac:	f941 078f 	vst1.32	{d16}, [r1]
32205fb0:	f043 0101 	orr.w	r1, r3, #1
32205fb4:	6051      	str	r1, [r2, #4]
32205fb6:	f844 300e 	str.w	r3, [r4, lr]
32205fba:	3408      	adds	r4, #8
32205fbc:	f000 fb3c 	bl	32206638 <__malloc_unlock>
32205fc0:	e6ad      	b.n	32205d1e <_malloc_r+0x196>
32205fc2:	ea4f 129e 	mov.w	r2, lr, lsr #6
32205fc6:	f102 0339 	add.w	r3, r2, #57	@ 0x39
32205fca:	3238      	adds	r2, #56	@ 0x38
32205fcc:	b21b      	sxth	r3, r3
32205fce:	00db      	lsls	r3, r3, #3
32205fd0:	e786      	b.n	32205ee0 <_malloc_r+0x358>
32205fd2:	42b4      	cmp	r4, r6
32205fd4:	d06b      	beq.n	322060ae <_malloc_r+0x526>
32205fd6:	68b4      	ldr	r4, [r6, #8]
32205fd8:	6861      	ldr	r1, [r4, #4]
32205fda:	f021 0803 	bic.w	r8, r1, #3
32205fde:	45a8      	cmp	r8, r5
32205fe0:	eba8 0305 	sub.w	r3, r8, r5
32205fe4:	bf28      	it	cs
32205fe6:	2200      	movcs	r2, #0
32205fe8:	bf38      	it	cc
32205fea:	2201      	movcc	r2, #1
32205fec:	2b0f      	cmp	r3, #15
32205fee:	bfc8      	it	gt
32205ff0:	2100      	movgt	r1, #0
32205ff2:	bfd8      	it	le
32205ff4:	2101      	movle	r1, #1
32205ff6:	ea52 0801 	orrs.w	r8, r2, r1
32205ffa:	f43f af46 	beq.w	32205e8a <_malloc_r+0x302>
32205ffe:	4638      	mov	r0, r7
32206000:	f000 fb1a 	bl	32206638 <__malloc_unlock>
32206004:	e68a      	b.n	32205d1c <_malloc_r+0x194>
32206006:	f10e 005c 	add.w	r0, lr, #92	@ 0x5c
3220600a:	f10e 0e5b 	add.w	lr, lr, #91	@ 0x5b
3220600e:	b203      	sxth	r3, r0
32206010:	00db      	lsls	r3, r3, #3
32206012:	e609      	b.n	32205c28 <_malloc_r+0xa0>
32206014:	f859 3908 	ldr.w	r3, [r9], #-8
32206018:	3801      	subs	r0, #1
3220601a:	454b      	cmp	r3, r9
3220601c:	f040 80a3 	bne.w	32206166 <_malloc_r+0x5de>
32206020:	0784      	lsls	r4, r0, #30
32206022:	d1f7      	bne.n	32206014 <_malloc_r+0x48c>
32206024:	6873      	ldr	r3, [r6, #4]
32206026:	ea23 030c 	bic.w	r3, r3, ip
3220602a:	6073      	str	r3, [r6, #4]
3220602c:	ea4f 0c4c 	mov.w	ip, ip, lsl #1
32206030:	f10c 32ff 	add.w	r2, ip, #4294967295	@ 0xffffffff
32206034:	429a      	cmp	r2, r3
32206036:	d304      	bcc.n	32206042 <_malloc_r+0x4ba>
32206038:	e67b      	b.n	32205d32 <_malloc_r+0x1aa>
3220603a:	ea4f 0c4c 	mov.w	ip, ip, lsl #1
3220603e:	f108 0804 	add.w	r8, r8, #4
32206042:	ea1c 0f03 	tst.w	ip, r3
32206046:	d0f8      	beq.n	3220603a <_malloc_r+0x4b2>
32206048:	4640      	mov	r0, r8
3220604a:	e648      	b.n	32205cde <_malloc_r+0x156>
3220604c:	1092      	asrs	r2, r2, #2
3220604e:	f04f 0e01 	mov.w	lr, #1
32206052:	fa0e f202 	lsl.w	r2, lr, r2
32206056:	4311      	orrs	r1, r2
32206058:	6071      	str	r1, [r6, #4]
3220605a:	e753      	b.n	32205f04 <_malloc_r+0x37c>
3220605c:	eb0a 0308 	add.w	r3, sl, r8
32206060:	4638      	mov	r0, r7
32206062:	ea03 030e 	and.w	r3, r3, lr
32206066:	ebab 0b03 	sub.w	fp, fp, r3
3220606a:	ea0b 0b0e 	and.w	fp, fp, lr
3220606e:	4659      	mov	r1, fp
32206070:	f003 fcd2 	bl	32209a18 <_sbrk_r>
32206074:	9a01      	ldr	r2, [sp, #4]
32206076:	1c43      	adds	r3, r0, #1
32206078:	f47f aec8 	bne.w	32205e0c <_malloc_r+0x284>
3220607c:	f8dd b000 	ldr.w	fp, [sp]
32206080:	e6c8      	b.n	32205e14 <_malloc_r+0x28c>
32206082:	2a54      	cmp	r2, #84	@ 0x54
32206084:	d831      	bhi.n	322060ea <_malloc_r+0x562>
32206086:	ea4f 321e 	mov.w	r2, lr, lsr #12
3220608a:	f102 036f 	add.w	r3, r2, #111	@ 0x6f
3220608e:	326e      	adds	r2, #110	@ 0x6e
32206090:	b21b      	sxth	r3, r3
32206092:	00db      	lsls	r3, r3, #3
32206094:	e724      	b.n	32205ee0 <_malloc_r+0x358>
32206096:	f5be 7faa 	cmp.w	lr, #340	@ 0x154
3220609a:	d831      	bhi.n	32206100 <_malloc_r+0x578>
3220609c:	ea4f 3ed5 	mov.w	lr, r5, lsr #15
322060a0:	f10e 0078 	add.w	r0, lr, #120	@ 0x78
322060a4:	f10e 0e77 	add.w	lr, lr, #119	@ 0x77
322060a8:	b203      	sxth	r3, r0
322060aa:	00db      	lsls	r3, r3, #3
322060ac:	e5bc      	b.n	32205c28 <_malloc_r+0xa0>
322060ae:	f245 3268 	movw	r2, #21352	@ 0x5368
322060b2:	f2c3 2221 	movt	r2, #12833	@ 0x3221
322060b6:	f10b 3eff 	add.w	lr, fp, #4294967295	@ 0xffffffff
322060ba:	6811      	ldr	r1, [r2, #0]
322060bc:	eb08 0001 	add.w	r0, r8, r1
322060c0:	6010      	str	r0, [r2, #0]
322060c2:	e681      	b.n	32205dc8 <_malloc_r+0x240>
322060c4:	ea1a 0f0e 	tst.w	sl, lr
322060c8:	f47f ae7e 	bne.w	32205dc8 <_malloc_r+0x240>
322060cc:	f8d6 a008 	ldr.w	sl, [r6, #8]
322060d0:	44c8      	add	r8, r9
322060d2:	f048 0101 	orr.w	r1, r8, #1
322060d6:	f8ca 1004 	str.w	r1, [sl, #4]
322060da:	e6c2      	b.n	32205e62 <_malloc_r+0x2da>
322060dc:	f8c3 a000 	str.w	sl, [r3]
322060e0:	e67c      	b.n	32205ddc <_malloc_r+0x254>
322060e2:	2301      	movs	r3, #1
322060e4:	f8ca 3004 	str.w	r3, [sl, #4]
322060e8:	e789      	b.n	32205ffe <_malloc_r+0x476>
322060ea:	f5b2 7faa 	cmp.w	r2, #340	@ 0x154
322060ee:	d825      	bhi.n	3220613c <_malloc_r+0x5b4>
322060f0:	ea4f 32de 	mov.w	r2, lr, lsr #15
322060f4:	f102 0378 	add.w	r3, r2, #120	@ 0x78
322060f8:	3277      	adds	r2, #119	@ 0x77
322060fa:	b21b      	sxth	r3, r3
322060fc:	00db      	lsls	r3, r3, #3
322060fe:	e6ef      	b.n	32205ee0 <_malloc_r+0x358>
32206100:	f240 5354 	movw	r3, #1364	@ 0x554
32206104:	459e      	cmp	lr, r3
32206106:	d824      	bhi.n	32206152 <_malloc_r+0x5ca>
32206108:	0cab      	lsrs	r3, r5, #18
3220610a:	f103 007d 	add.w	r0, r3, #125	@ 0x7d
3220610e:	f103 0e7c 	add.w	lr, r3, #124	@ 0x7c
32206112:	00c3      	lsls	r3, r0, #3
32206114:	e588      	b.n	32205c28 <_malloc_r+0xa0>
32206116:	9b00      	ldr	r3, [sp, #0]
32206118:	f04f 0b00 	mov.w	fp, #0
3220611c:	3b08      	subs	r3, #8
3220611e:	4498      	add	r8, r3
32206120:	eba8 080a 	sub.w	r8, r8, sl
32206124:	e676      	b.n	32205e14 <_malloc_r+0x28c>
32206126:	4638      	mov	r0, r7
32206128:	f104 0108 	add.w	r1, r4, #8
3220612c:	9200      	str	r2, [sp, #0]
3220612e:	f7ff fbdb 	bl	322058e8 <_free_r>
32206132:	9a00      	ldr	r2, [sp, #0]
32206134:	f8d6 a008 	ldr.w	sl, [r6, #8]
32206138:	6810      	ldr	r0, [r2, #0]
3220613a:	e690      	b.n	32205e5e <_malloc_r+0x2d6>
3220613c:	f240 5354 	movw	r3, #1364	@ 0x554
32206140:	429a      	cmp	r2, r3
32206142:	d80c      	bhi.n	3220615e <_malloc_r+0x5d6>
32206144:	ea4f 429e 	mov.w	r2, lr, lsr #18
32206148:	f102 037d 	add.w	r3, r2, #125	@ 0x7d
3220614c:	327c      	adds	r2, #124	@ 0x7c
3220614e:	00db      	lsls	r3, r3, #3
32206150:	e6c6      	b.n	32205ee0 <_malloc_r+0x358>
32206152:	f44f 737e 	mov.w	r3, #1016	@ 0x3f8
32206156:	207f      	movs	r0, #127	@ 0x7f
32206158:	f04f 0e7e 	mov.w	lr, #126	@ 0x7e
3220615c:	e564      	b.n	32205c28 <_malloc_r+0xa0>
3220615e:	f44f 737e 	mov.w	r3, #1016	@ 0x3f8
32206162:	227e      	movs	r2, #126	@ 0x7e
32206164:	e6bc      	b.n	32205ee0 <_malloc_r+0x358>
32206166:	6873      	ldr	r3, [r6, #4]
32206168:	e760      	b.n	3220602c <_malloc_r+0x4a4>
3220616a:	08e8      	lsrs	r0, r5, #3
3220616c:	1c43      	adds	r3, r0, #1
3220616e:	b21b      	sxth	r3, r3
32206170:	00db      	lsls	r3, r3, #3
32206172:	e519      	b.n	32205ba8 <_malloc_r+0x20>

32206174 <_mbtowc_r>:
32206174:	f24c 2c40 	movw	ip, #49728	@ 0xc240
32206178:	f2c3 2c20 	movt	ip, #12832	@ 0x3220
3220617c:	b410      	push	{r4}
3220617e:	f8dc 40e4 	ldr.w	r4, [ip, #228]	@ 0xe4
32206182:	46a4      	mov	ip, r4
32206184:	f85d 4b04 	ldr.w	r4, [sp], #4
32206188:	4760      	bx	ip
3220618a:	bf00      	nop

3220618c <__ascii_mbtowc>:
3220618c:	b082      	sub	sp, #8
3220618e:	b151      	cbz	r1, 322061a6 <__ascii_mbtowc+0x1a>
32206190:	4610      	mov	r0, r2
32206192:	b132      	cbz	r2, 322061a2 <__ascii_mbtowc+0x16>
32206194:	b14b      	cbz	r3, 322061aa <__ascii_mbtowc+0x1e>
32206196:	7813      	ldrb	r3, [r2, #0]
32206198:	600b      	str	r3, [r1, #0]
3220619a:	7812      	ldrb	r2, [r2, #0]
3220619c:	1e10      	subs	r0, r2, #0
3220619e:	bf18      	it	ne
322061a0:	2001      	movne	r0, #1
322061a2:	b002      	add	sp, #8
322061a4:	4770      	bx	lr
322061a6:	a901      	add	r1, sp, #4
322061a8:	e7f2      	b.n	32206190 <__ascii_mbtowc+0x4>
322061aa:	f06f 0001 	mvn.w	r0, #1
322061ae:	e7f8      	b.n	322061a2 <__ascii_mbtowc+0x16>

322061b0 <__utf8_mbtowc>:
322061b0:	b5f0      	push	{r4, r5, r6, r7, lr}
322061b2:	4686      	mov	lr, r0
322061b4:	b083      	sub	sp, #12
322061b6:	9e08      	ldr	r6, [sp, #32]
322061b8:	2900      	cmp	r1, #0
322061ba:	d035      	beq.n	32206228 <__utf8_mbtowc+0x78>
322061bc:	b38a      	cbz	r2, 32206222 <__utf8_mbtowc+0x72>
322061be:	2b00      	cmp	r3, #0
322061c0:	d051      	beq.n	32206266 <__utf8_mbtowc+0xb6>
322061c2:	6835      	ldr	r5, [r6, #0]
322061c4:	bb35      	cbnz	r5, 32206214 <__utf8_mbtowc+0x64>
322061c6:	7814      	ldrb	r4, [r2, #0]
322061c8:	f04f 0c01 	mov.w	ip, #1
322061cc:	b33c      	cbz	r4, 3220621e <__utf8_mbtowc+0x6e>
322061ce:	2c7f      	cmp	r4, #127	@ 0x7f
322061d0:	dd4c      	ble.n	3220626c <__utf8_mbtowc+0xbc>
322061d2:	f1a4 00c0 	sub.w	r0, r4, #192	@ 0xc0
322061d6:	281f      	cmp	r0, #31
322061d8:	d828      	bhi.n	3220622c <__utf8_mbtowc+0x7c>
322061da:	7134      	strb	r4, [r6, #4]
322061dc:	b91d      	cbnz	r5, 322061e6 <__utf8_mbtowc+0x36>
322061de:	2001      	movs	r0, #1
322061e0:	6030      	str	r0, [r6, #0]
322061e2:	4283      	cmp	r3, r0
322061e4:	d03f      	beq.n	32206266 <__utf8_mbtowc+0xb6>
322061e6:	f812 300c 	ldrb.w	r3, [r2, ip]
322061ea:	f10c 0001 	add.w	r0, ip, #1
322061ee:	f1a3 0280 	sub.w	r2, r3, #128	@ 0x80
322061f2:	2a3f      	cmp	r2, #63	@ 0x3f
322061f4:	f200 80b3 	bhi.w	3220635e <__utf8_mbtowc+0x1ae>
322061f8:	2cc1      	cmp	r4, #193	@ 0xc1
322061fa:	f340 80b0 	ble.w	3220635e <__utf8_mbtowc+0x1ae>
322061fe:	01a4      	lsls	r4, r4, #6
32206200:	f003 033f 	and.w	r3, r3, #63	@ 0x3f
32206204:	f404 64f8 	and.w	r4, r4, #1984	@ 0x7c0
32206208:	431c      	orrs	r4, r3
3220620a:	2300      	movs	r3, #0
3220620c:	6033      	str	r3, [r6, #0]
3220620e:	600c      	str	r4, [r1, #0]
32206210:	b003      	add	sp, #12
32206212:	bdf0      	pop	{r4, r5, r6, r7, pc}
32206214:	7934      	ldrb	r4, [r6, #4]
32206216:	f04f 0c00 	mov.w	ip, #0
3220621a:	2c00      	cmp	r4, #0
3220621c:	d1d7      	bne.n	322061ce <__utf8_mbtowc+0x1e>
3220621e:	600c      	str	r4, [r1, #0]
32206220:	6034      	str	r4, [r6, #0]
32206222:	2000      	movs	r0, #0
32206224:	b003      	add	sp, #12
32206226:	bdf0      	pop	{r4, r5, r6, r7, pc}
32206228:	a901      	add	r1, sp, #4
3220622a:	e7c7      	b.n	322061bc <__utf8_mbtowc+0xc>
3220622c:	f1a4 00e0 	sub.w	r0, r4, #224	@ 0xe0
32206230:	280f      	cmp	r0, #15
32206232:	d821      	bhi.n	32206278 <__utf8_mbtowc+0xc8>
32206234:	7134      	strb	r4, [r6, #4]
32206236:	2d00      	cmp	r5, #0
32206238:	d164      	bne.n	32206304 <__utf8_mbtowc+0x154>
3220623a:	2001      	movs	r0, #1
3220623c:	6030      	str	r0, [r6, #0]
3220623e:	4283      	cmp	r3, r0
32206240:	d011      	beq.n	32206266 <__utf8_mbtowc+0xb6>
32206242:	f812 000c 	ldrb.w	r0, [r2, ip]
32206246:	2ce0      	cmp	r4, #224	@ 0xe0
32206248:	f10c 0c01 	add.w	ip, ip, #1
3220624c:	f000 80a8 	beq.w	322063a0 <__utf8_mbtowc+0x1f0>
32206250:	f1a0 0780 	sub.w	r7, r0, #128	@ 0x80
32206254:	4605      	mov	r5, r0
32206256:	2f3f      	cmp	r7, #63	@ 0x3f
32206258:	f200 8081 	bhi.w	3220635e <__utf8_mbtowc+0x1ae>
3220625c:	7170      	strb	r0, [r6, #5]
3220625e:	2002      	movs	r0, #2
32206260:	4283      	cmp	r3, r0
32206262:	6030      	str	r0, [r6, #0]
32206264:	d15a      	bne.n	3220631c <__utf8_mbtowc+0x16c>
32206266:	f06f 0001 	mvn.w	r0, #1
3220626a:	e7d1      	b.n	32206210 <__utf8_mbtowc+0x60>
3220626c:	2300      	movs	r3, #0
3220626e:	2001      	movs	r0, #1
32206270:	6033      	str	r3, [r6, #0]
32206272:	600c      	str	r4, [r1, #0]
32206274:	b003      	add	sp, #12
32206276:	bdf0      	pop	{r4, r5, r6, r7, pc}
32206278:	f1a4 00f0 	sub.w	r0, r4, #240	@ 0xf0
3220627c:	2804      	cmp	r0, #4
3220627e:	d86e      	bhi.n	3220635e <__utf8_mbtowc+0x1ae>
32206280:	7134      	strb	r4, [r6, #4]
32206282:	2d00      	cmp	r5, #0
32206284:	d05f      	beq.n	32206346 <__utf8_mbtowc+0x196>
32206286:	1c5f      	adds	r7, r3, #1
32206288:	bf18      	it	ne
3220628a:	3301      	addne	r3, #1
3220628c:	2d01      	cmp	r5, #1
3220628e:	d05e      	beq.n	3220634e <__utf8_mbtowc+0x19e>
32206290:	7977      	ldrb	r7, [r6, #5]
32206292:	2cf0      	cmp	r4, #240	@ 0xf0
32206294:	d061      	beq.n	3220635a <__utf8_mbtowc+0x1aa>
32206296:	f1a4 00f4 	sub.w	r0, r4, #244	@ 0xf4
3220629a:	2f8f      	cmp	r7, #143	@ 0x8f
3220629c:	fab0 f080 	clz	r0, r0
322062a0:	ea4f 1050 	mov.w	r0, r0, lsr #5
322062a4:	bfd8      	it	le
322062a6:	2000      	movle	r0, #0
322062a8:	2800      	cmp	r0, #0
322062aa:	d158      	bne.n	3220635e <__utf8_mbtowc+0x1ae>
322062ac:	f1a7 0080 	sub.w	r0, r7, #128	@ 0x80
322062b0:	283f      	cmp	r0, #63	@ 0x3f
322062b2:	d854      	bhi.n	3220635e <__utf8_mbtowc+0x1ae>
322062b4:	2d01      	cmp	r5, #1
322062b6:	7177      	strb	r7, [r6, #5]
322062b8:	d057      	beq.n	3220636a <__utf8_mbtowc+0x1ba>
322062ba:	1c58      	adds	r0, r3, #1
322062bc:	6830      	ldr	r0, [r6, #0]
322062be:	bf18      	it	ne
322062c0:	3301      	addne	r3, #1
322062c2:	2802      	cmp	r0, #2
322062c4:	d056      	beq.n	32206374 <__utf8_mbtowc+0x1c4>
322062c6:	79b5      	ldrb	r5, [r6, #6]
322062c8:	f1a5 0380 	sub.w	r3, r5, #128	@ 0x80
322062cc:	2b3f      	cmp	r3, #63	@ 0x3f
322062ce:	d846      	bhi.n	3220635e <__utf8_mbtowc+0x1ae>
322062d0:	f812 200c 	ldrb.w	r2, [r2, ip]
322062d4:	f10c 0001 	add.w	r0, ip, #1
322062d8:	f1a2 0380 	sub.w	r3, r2, #128	@ 0x80
322062dc:	2b3f      	cmp	r3, #63	@ 0x3f
322062de:	d83e      	bhi.n	3220635e <__utf8_mbtowc+0x1ae>
322062e0:	04a3      	lsls	r3, r4, #18
322062e2:	033f      	lsls	r7, r7, #12
322062e4:	f403 13e0 	and.w	r3, r3, #1835008	@ 0x1c0000
322062e8:	f407 377c 	and.w	r7, r7, #258048	@ 0x3f000
322062ec:	01ad      	lsls	r5, r5, #6
322062ee:	433b      	orrs	r3, r7
322062f0:	f405 657c 	and.w	r5, r5, #4032	@ 0xfc0
322062f4:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
322062f8:	432b      	orrs	r3, r5
322062fa:	4313      	orrs	r3, r2
322062fc:	2200      	movs	r2, #0
322062fe:	600b      	str	r3, [r1, #0]
32206300:	6032      	str	r2, [r6, #0]
32206302:	e785      	b.n	32206210 <__utf8_mbtowc+0x60>
32206304:	1c58      	adds	r0, r3, #1
32206306:	bf18      	it	ne
32206308:	3301      	addne	r3, #1
3220630a:	2d01      	cmp	r5, #1
3220630c:	d099      	beq.n	32206242 <__utf8_mbtowc+0x92>
3220630e:	7975      	ldrb	r5, [r6, #5]
32206310:	2ce0      	cmp	r4, #224	@ 0xe0
32206312:	d03d      	beq.n	32206390 <__utf8_mbtowc+0x1e0>
32206314:	f1a5 0380 	sub.w	r3, r5, #128	@ 0x80
32206318:	2b3f      	cmp	r3, #63	@ 0x3f
3220631a:	d820      	bhi.n	3220635e <__utf8_mbtowc+0x1ae>
3220631c:	f812 200c 	ldrb.w	r2, [r2, ip]
32206320:	f10c 0001 	add.w	r0, ip, #1
32206324:	f1a2 0380 	sub.w	r3, r2, #128	@ 0x80
32206328:	2b3f      	cmp	r3, #63	@ 0x3f
3220632a:	d818      	bhi.n	3220635e <__utf8_mbtowc+0x1ae>
3220632c:	0323      	lsls	r3, r4, #12
3220632e:	01ad      	lsls	r5, r5, #6
32206330:	f405 657c 	and.w	r5, r5, #4032	@ 0xfc0
32206334:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
32206338:	b29b      	uxth	r3, r3
3220633a:	432b      	orrs	r3, r5
3220633c:	4313      	orrs	r3, r2
3220633e:	2200      	movs	r2, #0
32206340:	6032      	str	r2, [r6, #0]
32206342:	600b      	str	r3, [r1, #0]
32206344:	e764      	b.n	32206210 <__utf8_mbtowc+0x60>
32206346:	2001      	movs	r0, #1
32206348:	6030      	str	r0, [r6, #0]
3220634a:	4283      	cmp	r3, r0
3220634c:	d08b      	beq.n	32206266 <__utf8_mbtowc+0xb6>
3220634e:	f812 700c 	ldrb.w	r7, [r2, ip]
32206352:	2501      	movs	r5, #1
32206354:	f10c 0c01 	add.w	ip, ip, #1
32206358:	e79b      	b.n	32206292 <__utf8_mbtowc+0xe2>
3220635a:	2f8f      	cmp	r7, #143	@ 0x8f
3220635c:	dca6      	bgt.n	322062ac <__utf8_mbtowc+0xfc>
3220635e:	238a      	movs	r3, #138	@ 0x8a
32206360:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32206364:	f8ce 3000 	str.w	r3, [lr]
32206368:	e752      	b.n	32206210 <__utf8_mbtowc+0x60>
3220636a:	2002      	movs	r0, #2
3220636c:	6030      	str	r0, [r6, #0]
3220636e:	4283      	cmp	r3, r0
32206370:	f43f af79 	beq.w	32206266 <__utf8_mbtowc+0xb6>
32206374:	f812 500c 	ldrb.w	r5, [r2, ip]
32206378:	f10c 0c01 	add.w	ip, ip, #1
3220637c:	f1a5 0080 	sub.w	r0, r5, #128	@ 0x80
32206380:	283f      	cmp	r0, #63	@ 0x3f
32206382:	d8ec      	bhi.n	3220635e <__utf8_mbtowc+0x1ae>
32206384:	2003      	movs	r0, #3
32206386:	71b5      	strb	r5, [r6, #6]
32206388:	4283      	cmp	r3, r0
3220638a:	6030      	str	r0, [r6, #0]
3220638c:	d1a0      	bne.n	322062d0 <__utf8_mbtowc+0x120>
3220638e:	e76a      	b.n	32206266 <__utf8_mbtowc+0xb6>
32206390:	2d9f      	cmp	r5, #159	@ 0x9f
32206392:	d9e4      	bls.n	3220635e <__utf8_mbtowc+0x1ae>
32206394:	f1a5 0380 	sub.w	r3, r5, #128	@ 0x80
32206398:	2b3f      	cmp	r3, #63	@ 0x3f
3220639a:	d8e0      	bhi.n	3220635e <__utf8_mbtowc+0x1ae>
3220639c:	7175      	strb	r5, [r6, #5]
3220639e:	e7bd      	b.n	3220631c <__utf8_mbtowc+0x16c>
322063a0:	289f      	cmp	r0, #159	@ 0x9f
322063a2:	f63f af55 	bhi.w	32206250 <__utf8_mbtowc+0xa0>
322063a6:	e7da      	b.n	3220635e <__utf8_mbtowc+0x1ae>

322063a8 <__sjis_mbtowc>:
322063a8:	b470      	push	{r4, r5, r6}
322063aa:	4684      	mov	ip, r0
322063ac:	b083      	sub	sp, #12
322063ae:	9d06      	ldr	r5, [sp, #24]
322063b0:	b379      	cbz	r1, 32206412 <__sjis_mbtowc+0x6a>
322063b2:	4610      	mov	r0, r2
322063b4:	b302      	cbz	r2, 322063f8 <__sjis_mbtowc+0x50>
322063b6:	b373      	cbz	r3, 32206416 <__sjis_mbtowc+0x6e>
322063b8:	6828      	ldr	r0, [r5, #0]
322063ba:	7814      	ldrb	r4, [r2, #0]
322063bc:	b9f8      	cbnz	r0, 322063fe <__sjis_mbtowc+0x56>
322063be:	f1a4 0081 	sub.w	r0, r4, #129	@ 0x81
322063c2:	f1a4 06e0 	sub.w	r6, r4, #224	@ 0xe0
322063c6:	281e      	cmp	r0, #30
322063c8:	bf88      	it	hi
322063ca:	2e0f      	cmphi	r6, #15
322063cc:	d819      	bhi.n	32206402 <__sjis_mbtowc+0x5a>
322063ce:	2001      	movs	r0, #1
322063d0:	712c      	strb	r4, [r5, #4]
322063d2:	4283      	cmp	r3, r0
322063d4:	6028      	str	r0, [r5, #0]
322063d6:	d01e      	beq.n	32206416 <__sjis_mbtowc+0x6e>
322063d8:	7854      	ldrb	r4, [r2, #1]
322063da:	2002      	movs	r0, #2
322063dc:	f1a4 0340 	sub.w	r3, r4, #64	@ 0x40
322063e0:	f1a4 0280 	sub.w	r2, r4, #128	@ 0x80
322063e4:	2b3e      	cmp	r3, #62	@ 0x3e
322063e6:	bf88      	it	hi
322063e8:	2a7c      	cmphi	r2, #124	@ 0x7c
322063ea:	d817      	bhi.n	3220641c <__sjis_mbtowc+0x74>
322063ec:	792b      	ldrb	r3, [r5, #4]
322063ee:	eb04 2403 	add.w	r4, r4, r3, lsl #8
322063f2:	2300      	movs	r3, #0
322063f4:	600c      	str	r4, [r1, #0]
322063f6:	602b      	str	r3, [r5, #0]
322063f8:	b003      	add	sp, #12
322063fa:	bc70      	pop	{r4, r5, r6}
322063fc:	4770      	bx	lr
322063fe:	2801      	cmp	r0, #1
32206400:	d0ec      	beq.n	322063dc <__sjis_mbtowc+0x34>
32206402:	600c      	str	r4, [r1, #0]
32206404:	7810      	ldrb	r0, [r2, #0]
32206406:	3800      	subs	r0, #0
32206408:	bf18      	it	ne
3220640a:	2001      	movne	r0, #1
3220640c:	b003      	add	sp, #12
3220640e:	bc70      	pop	{r4, r5, r6}
32206410:	4770      	bx	lr
32206412:	a901      	add	r1, sp, #4
32206414:	e7cd      	b.n	322063b2 <__sjis_mbtowc+0xa>
32206416:	f06f 0001 	mvn.w	r0, #1
3220641a:	e7ed      	b.n	322063f8 <__sjis_mbtowc+0x50>
3220641c:	238a      	movs	r3, #138	@ 0x8a
3220641e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32206422:	f8cc 3000 	str.w	r3, [ip]
32206426:	e7e7      	b.n	322063f8 <__sjis_mbtowc+0x50>

32206428 <__eucjp_mbtowc>:
32206428:	b570      	push	{r4, r5, r6, lr}
3220642a:	4686      	mov	lr, r0
3220642c:	b082      	sub	sp, #8
3220642e:	9d06      	ldr	r5, [sp, #24]
32206430:	2900      	cmp	r1, #0
32206432:	d040      	beq.n	322064b6 <__eucjp_mbtowc+0x8e>
32206434:	4610      	mov	r0, r2
32206436:	b382      	cbz	r2, 3220649a <__eucjp_mbtowc+0x72>
32206438:	2b00      	cmp	r3, #0
3220643a:	d047      	beq.n	322064cc <__eucjp_mbtowc+0xa4>
3220643c:	6828      	ldr	r0, [r5, #0]
3220643e:	7814      	ldrb	r4, [r2, #0]
32206440:	bb68      	cbnz	r0, 3220649e <__eucjp_mbtowc+0x76>
32206442:	f1a4 068e 	sub.w	r6, r4, #142	@ 0x8e
32206446:	f1a4 00a1 	sub.w	r0, r4, #161	@ 0xa1
3220644a:	2e01      	cmp	r6, #1
3220644c:	bf88      	it	hi
3220644e:	285d      	cmphi	r0, #93	@ 0x5d
32206450:	d82a      	bhi.n	322064a8 <__eucjp_mbtowc+0x80>
32206452:	2001      	movs	r0, #1
32206454:	712c      	strb	r4, [r5, #4]
32206456:	4283      	cmp	r3, r0
32206458:	6028      	str	r0, [r5, #0]
3220645a:	d037      	beq.n	322064cc <__eucjp_mbtowc+0xa4>
3220645c:	f892 c001 	ldrb.w	ip, [r2, #1]
32206460:	2002      	movs	r0, #2
32206462:	f1ac 04a1 	sub.w	r4, ip, #161	@ 0xa1
32206466:	2c5d      	cmp	r4, #93	@ 0x5d
32206468:	d833      	bhi.n	322064d2 <__eucjp_mbtowc+0xaa>
3220646a:	792c      	ldrb	r4, [r5, #4]
3220646c:	2c8f      	cmp	r4, #143	@ 0x8f
3220646e:	d124      	bne.n	322064ba <__eucjp_mbtowc+0x92>
32206470:	2402      	movs	r4, #2
32206472:	4298      	cmp	r0, r3
32206474:	f885 c005 	strb.w	ip, [r5, #5]
32206478:	602c      	str	r4, [r5, #0]
3220647a:	d227      	bcs.n	322064cc <__eucjp_mbtowc+0xa4>
3220647c:	f812 c000 	ldrb.w	ip, [r2, r0]
32206480:	3001      	adds	r0, #1
32206482:	f1ac 03a1 	sub.w	r3, ip, #161	@ 0xa1
32206486:	2b5d      	cmp	r3, #93	@ 0x5d
32206488:	d823      	bhi.n	322064d2 <__eucjp_mbtowc+0xaa>
3220648a:	796b      	ldrb	r3, [r5, #5]
3220648c:	f00c 0c7f 	and.w	ip, ip, #127	@ 0x7f
32206490:	2200      	movs	r2, #0
32206492:	eb0c 2303 	add.w	r3, ip, r3, lsl #8
32206496:	600b      	str	r3, [r1, #0]
32206498:	602a      	str	r2, [r5, #0]
3220649a:	b002      	add	sp, #8
3220649c:	bd70      	pop	{r4, r5, r6, pc}
3220649e:	46a4      	mov	ip, r4
322064a0:	2801      	cmp	r0, #1
322064a2:	d0de      	beq.n	32206462 <__eucjp_mbtowc+0x3a>
322064a4:	2802      	cmp	r0, #2
322064a6:	d00f      	beq.n	322064c8 <__eucjp_mbtowc+0xa0>
322064a8:	600c      	str	r4, [r1, #0]
322064aa:	7810      	ldrb	r0, [r2, #0]
322064ac:	3800      	subs	r0, #0
322064ae:	bf18      	it	ne
322064b0:	2001      	movne	r0, #1
322064b2:	b002      	add	sp, #8
322064b4:	bd70      	pop	{r4, r5, r6, pc}
322064b6:	a901      	add	r1, sp, #4
322064b8:	e7bc      	b.n	32206434 <__eucjp_mbtowc+0xc>
322064ba:	eb0c 2404 	add.w	r4, ip, r4, lsl #8
322064be:	2200      	movs	r2, #0
322064c0:	600c      	str	r4, [r1, #0]
322064c2:	602a      	str	r2, [r5, #0]
322064c4:	b002      	add	sp, #8
322064c6:	bd70      	pop	{r4, r5, r6, pc}
322064c8:	2001      	movs	r0, #1
322064ca:	e7da      	b.n	32206482 <__eucjp_mbtowc+0x5a>
322064cc:	f06f 0001 	mvn.w	r0, #1
322064d0:	e7e3      	b.n	3220649a <__eucjp_mbtowc+0x72>
322064d2:	238a      	movs	r3, #138	@ 0x8a
322064d4:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
322064d8:	f8ce 3000 	str.w	r3, [lr]
322064dc:	e7dd      	b.n	3220649a <__eucjp_mbtowc+0x72>
322064de:	bf00      	nop

322064e0 <__jis_mbtowc>:
322064e0:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
322064e4:	4682      	mov	sl, r0
322064e6:	b083      	sub	sp, #12
322064e8:	f8dd b030 	ldr.w	fp, [sp, #48]	@ 0x30
322064ec:	2900      	cmp	r1, #0
322064ee:	d037      	beq.n	32206560 <__jis_mbtowc+0x80>
322064f0:	2a00      	cmp	r2, #0
322064f2:	d038      	beq.n	32206566 <__jis_mbtowc+0x86>
322064f4:	2b00      	cmp	r3, #0
322064f6:	f000 808f 	beq.w	32206618 <__jis_mbtowc+0x138>
322064fa:	4694      	mov	ip, r2
322064fc:	f64b 6990 	movw	r9, #48784	@ 0xbe90
32206500:	f2c3 2920 	movt	r9, #12832	@ 0x3220
32206504:	4660      	mov	r0, ip
32206506:	f64b 6848 	movw	r8, #48712	@ 0xbe48
3220650a:	f2c3 2820 	movt	r8, #12832	@ 0x3220
3220650e:	f81c 5b01 	ldrb.w	r5, [ip], #1
32206512:	f04f 0e01 	mov.w	lr, #1
32206516:	f89b 4000 	ldrb.w	r4, [fp]
3220651a:	2d00      	cmp	r5, #0
3220651c:	d04b      	beq.n	322065b6 <__jis_mbtowc+0xd6>
3220651e:	f1a5 061b 	sub.w	r6, r5, #27
32206522:	b2f7      	uxtb	r7, r6
32206524:	2f2f      	cmp	r7, #47	@ 0x2f
32206526:	d826      	bhi.n	32206576 <__jis_mbtowc+0x96>
32206528:	2e2f      	cmp	r6, #47	@ 0x2f
3220652a:	d824      	bhi.n	32206576 <__jis_mbtowc+0x96>
3220652c:	e8df f006 	tbb	[pc, r6]
32206530:	23232370 	.word	0x23232370
32206534:	23232323 	.word	0x23232323
32206538:	23236e23 	.word	0x23236e23
3220653c:	23236623 	.word	0x23236623
32206540:	23232323 	.word	0x23232323
32206544:	23232323 	.word	0x23232323
32206548:	23232323 	.word	0x23232323
3220654c:	23232323 	.word	0x23232323
32206550:	23232323 	.word	0x23232323
32206554:	6a236823 	.word	0x6a236823
32206558:	23232323 	.word	0x23232323
3220655c:	6c232323 	.word	0x6c232323
32206560:	a901      	add	r1, sp, #4
32206562:	2a00      	cmp	r2, #0
32206564:	d1c6      	bne.n	322064f4 <__jis_mbtowc+0x14>
32206566:	f04f 0e01 	mov.w	lr, #1
3220656a:	f8cb 2000 	str.w	r2, [fp]
3220656e:	4670      	mov	r0, lr
32206570:	b003      	add	sp, #12
32206572:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32206576:	f1a5 0621 	sub.w	r6, r5, #33	@ 0x21
3220657a:	2708      	movs	r7, #8
3220657c:	2e5d      	cmp	r6, #93	@ 0x5d
3220657e:	bf98      	it	ls
32206580:	2707      	movls	r7, #7
32206582:	eb04 04c4 	add.w	r4, r4, r4, lsl #3
32206586:	eb08 0604 	add.w	r6, r8, r4
3220658a:	444c      	add	r4, r9
3220658c:	5df6      	ldrb	r6, [r6, r7]
3220658e:	5de4      	ldrb	r4, [r4, r7]
32206590:	2e05      	cmp	r6, #5
32206592:	d844      	bhi.n	3220661e <__jis_mbtowc+0x13e>
32206594:	e8df f006 	tbb	[pc, r6]
32206598:	11130320 	.word	0x11130320
3220659c:	2905      	.short	0x2905
3220659e:	f88b 5004 	strb.w	r5, [fp, #4]
322065a2:	f10e 0001 	add.w	r0, lr, #1
322065a6:	4573      	cmp	r3, lr
322065a8:	d934      	bls.n	32206614 <__jis_mbtowc+0x134>
322065aa:	4686      	mov	lr, r0
322065ac:	4660      	mov	r0, ip
322065ae:	f81c 5b01 	ldrb.w	r5, [ip], #1
322065b2:	2d00      	cmp	r5, #0
322065b4:	d1b3      	bne.n	3220651e <__jis_mbtowc+0x3e>
322065b6:	2706      	movs	r7, #6
322065b8:	e7e3      	b.n	32206582 <__jis_mbtowc+0xa2>
322065ba:	4662      	mov	r2, ip
322065bc:	e7f1      	b.n	322065a2 <__jis_mbtowc+0xc2>
322065be:	2301      	movs	r3, #1
322065c0:	f8cb 3000 	str.w	r3, [fp]
322065c4:	f89b 2004 	ldrb.w	r2, [fp, #4]
322065c8:	7803      	ldrb	r3, [r0, #0]
322065ca:	eb03 2302 	add.w	r3, r3, r2, lsl #8
322065ce:	600b      	str	r3, [r1, #0]
322065d0:	4670      	mov	r0, lr
322065d2:	b003      	add	sp, #12
322065d4:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
322065d8:	2300      	movs	r3, #0
322065da:	f8cb 3000 	str.w	r3, [fp]
322065de:	4670      	mov	r0, lr
322065e0:	7813      	ldrb	r3, [r2, #0]
322065e2:	600b      	str	r3, [r1, #0]
322065e4:	b003      	add	sp, #12
322065e6:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
322065ea:	2300      	movs	r3, #0
322065ec:	f8cb 3000 	str.w	r3, [fp]
322065f0:	469e      	mov	lr, r3
322065f2:	600b      	str	r3, [r1, #0]
322065f4:	4670      	mov	r0, lr
322065f6:	b003      	add	sp, #12
322065f8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
322065fc:	2702      	movs	r7, #2
322065fe:	e7c0      	b.n	32206582 <__jis_mbtowc+0xa2>
32206600:	2703      	movs	r7, #3
32206602:	e7be      	b.n	32206582 <__jis_mbtowc+0xa2>
32206604:	2704      	movs	r7, #4
32206606:	e7bc      	b.n	32206582 <__jis_mbtowc+0xa2>
32206608:	2705      	movs	r7, #5
3220660a:	e7ba      	b.n	32206582 <__jis_mbtowc+0xa2>
3220660c:	2701      	movs	r7, #1
3220660e:	e7b8      	b.n	32206582 <__jis_mbtowc+0xa2>
32206610:	2700      	movs	r7, #0
32206612:	e7b6      	b.n	32206582 <__jis_mbtowc+0xa2>
32206614:	f8cb 4000 	str.w	r4, [fp]
32206618:	f06f 0e01 	mvn.w	lr, #1
3220661c:	e7d8      	b.n	322065d0 <__jis_mbtowc+0xf0>
3220661e:	238a      	movs	r3, #138	@ 0x8a
32206620:	f04f 3eff 	mov.w	lr, #4294967295	@ 0xffffffff
32206624:	f8ca 3000 	str.w	r3, [sl]
32206628:	e7d2      	b.n	322065d0 <__jis_mbtowc+0xf0>
3220662a:	bf00      	nop

3220662c <__malloc_lock>:
3220662c:	f245 3058 	movw	r0, #21336	@ 0x5358
32206630:	f2c3 2021 	movt	r0, #12833	@ 0x3221
32206634:	f7fe bb90 	b.w	32204d58 <__retarget_lock_acquire_recursive>

32206638 <__malloc_unlock>:
32206638:	f245 3058 	movw	r0, #21336	@ 0x5358
3220663c:	f2c3 2021 	movt	r0, #12833	@ 0x3221
32206640:	f7fe bb92 	b.w	32204d68 <__retarget_lock_release_recursive>

32206644 <_realloc_r>:
32206644:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32206648:	4616      	mov	r6, r2
3220664a:	b083      	sub	sp, #12
3220664c:	2900      	cmp	r1, #0
3220664e:	f000 80bd 	beq.w	322067cc <_realloc_r+0x188>
32206652:	460c      	mov	r4, r1
32206654:	4680      	mov	r8, r0
32206656:	f7ff ffe9 	bl	3220662c <__malloc_lock>
3220665a:	f106 050b 	add.w	r5, r6, #11
3220665e:	f1a4 0908 	sub.w	r9, r4, #8
32206662:	2d16      	cmp	r5, #22
32206664:	f854 0c04 	ldr.w	r0, [r4, #-4]
32206668:	f020 0703 	bic.w	r7, r0, #3
3220666c:	d872      	bhi.n	32206754 <_realloc_r+0x110>
3220666e:	2210      	movs	r2, #16
32206670:	2300      	movs	r3, #0
32206672:	4615      	mov	r5, r2
32206674:	42b5      	cmp	r5, r6
32206676:	bf28      	it	cs
32206678:	2100      	movcs	r1, #0
3220667a:	bf38      	it	cc
3220667c:	2101      	movcc	r1, #1
3220667e:	430b      	orrs	r3, r1
32206680:	d174      	bne.n	3220676c <_realloc_r+0x128>
32206682:	4297      	cmp	r7, r2
32206684:	da7f      	bge.n	32206786 <_realloc_r+0x142>
32206686:	f24c 5a20 	movw	sl, #50464	@ 0xc520
3220668a:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
3220668e:	eb09 0107 	add.w	r1, r9, r7
32206692:	f8da 3008 	ldr.w	r3, [sl, #8]
32206696:	f8d1 c004 	ldr.w	ip, [r1, #4]
3220669a:	428b      	cmp	r3, r1
3220669c:	f000 80ae 	beq.w	322067fc <_realloc_r+0x1b8>
322066a0:	f02c 0301 	bic.w	r3, ip, #1
322066a4:	440b      	add	r3, r1
322066a6:	685b      	ldr	r3, [r3, #4]
322066a8:	07db      	lsls	r3, r3, #31
322066aa:	f100 8084 	bmi.w	322067b6 <_realloc_r+0x172>
322066ae:	f02c 0c03 	bic.w	ip, ip, #3
322066b2:	eb07 030c 	add.w	r3, r7, ip
322066b6:	4293      	cmp	r3, r2
322066b8:	da60      	bge.n	3220677c <_realloc_r+0x138>
322066ba:	07c3      	lsls	r3, r0, #31
322066bc:	d412      	bmi.n	322066e4 <_realloc_r+0xa0>
322066be:	f854 3c08 	ldr.w	r3, [r4, #-8]
322066c2:	eba9 0b03 	sub.w	fp, r9, r3
322066c6:	f8db 3004 	ldr.w	r3, [fp, #4]
322066ca:	f023 0003 	bic.w	r0, r3, #3
322066ce:	4484      	add	ip, r0
322066d0:	eb0c 0a07 	add.w	sl, ip, r7
322066d4:	4552      	cmp	r2, sl
322066d6:	f340 810c 	ble.w	322068f2 <_realloc_r+0x2ae>
322066da:	eb07 0a00 	add.w	sl, r7, r0
322066de:	4552      	cmp	r2, sl
322066e0:	f340 80e0 	ble.w	322068a4 <_realloc_r+0x260>
322066e4:	4631      	mov	r1, r6
322066e6:	4640      	mov	r0, r8
322066e8:	f7ff fa4e 	bl	32205b88 <_malloc_r>
322066ec:	4606      	mov	r6, r0
322066ee:	2800      	cmp	r0, #0
322066f0:	f000 8135 	beq.w	3220695e <_realloc_r+0x31a>
322066f4:	f854 3c04 	ldr.w	r3, [r4, #-4]
322066f8:	f1a0 0208 	sub.w	r2, r0, #8
322066fc:	f023 0301 	bic.w	r3, r3, #1
32206700:	444b      	add	r3, r9
32206702:	4293      	cmp	r3, r2
32206704:	f000 80c8 	beq.w	32206898 <_realloc_r+0x254>
32206708:	1f3a      	subs	r2, r7, #4
3220670a:	2a24      	cmp	r2, #36	@ 0x24
3220670c:	f200 80ed 	bhi.w	322068ea <_realloc_r+0x2a6>
32206710:	2a13      	cmp	r2, #19
32206712:	bf98      	it	ls
32206714:	4603      	movls	r3, r0
32206716:	bf98      	it	ls
32206718:	4622      	movls	r2, r4
3220671a:	d90a      	bls.n	32206732 <_realloc_r+0xee>
3220671c:	6823      	ldr	r3, [r4, #0]
3220671e:	2a1b      	cmp	r2, #27
32206720:	6003      	str	r3, [r0, #0]
32206722:	6863      	ldr	r3, [r4, #4]
32206724:	6043      	str	r3, [r0, #4]
32206726:	f200 80ef 	bhi.w	32206908 <_realloc_r+0x2c4>
3220672a:	f104 0208 	add.w	r2, r4, #8
3220672e:	f100 0308 	add.w	r3, r0, #8
32206732:	6811      	ldr	r1, [r2, #0]
32206734:	6019      	str	r1, [r3, #0]
32206736:	6851      	ldr	r1, [r2, #4]
32206738:	6059      	str	r1, [r3, #4]
3220673a:	6892      	ldr	r2, [r2, #8]
3220673c:	609a      	str	r2, [r3, #8]
3220673e:	4621      	mov	r1, r4
32206740:	4640      	mov	r0, r8
32206742:	f7ff f8d1 	bl	322058e8 <_free_r>
32206746:	4640      	mov	r0, r8
32206748:	f7ff ff76 	bl	32206638 <__malloc_unlock>
3220674c:	4630      	mov	r0, r6
3220674e:	b003      	add	sp, #12
32206750:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32206754:	f025 0507 	bic.w	r5, r5, #7
32206758:	42b5      	cmp	r5, r6
3220675a:	462a      	mov	r2, r5
3220675c:	ea4f 73d5 	mov.w	r3, r5, lsr #31
32206760:	bf28      	it	cs
32206762:	2100      	movcs	r1, #0
32206764:	bf38      	it	cc
32206766:	2101      	movcc	r1, #1
32206768:	430b      	orrs	r3, r1
3220676a:	d08a      	beq.n	32206682 <_realloc_r+0x3e>
3220676c:	230c      	movs	r3, #12
3220676e:	f8c8 3000 	str.w	r3, [r8]
32206772:	2600      	movs	r6, #0
32206774:	4630      	mov	r0, r6
32206776:	b003      	add	sp, #12
32206778:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220677c:	461f      	mov	r7, r3
3220677e:	e9d1 2302 	ldrd	r2, r3, [r1, #8]
32206782:	60d3      	str	r3, [r2, #12]
32206784:	609a      	str	r2, [r3, #8]
32206786:	f8d9 3004 	ldr.w	r3, [r9, #4]
3220678a:	1b78      	subs	r0, r7, r5
3220678c:	eb09 0207 	add.w	r2, r9, r7
32206790:	280f      	cmp	r0, #15
32206792:	f003 0301 	and.w	r3, r3, #1
32206796:	d81f      	bhi.n	322067d8 <_realloc_r+0x194>
32206798:	433b      	orrs	r3, r7
3220679a:	f8c9 3004 	str.w	r3, [r9, #4]
3220679e:	6853      	ldr	r3, [r2, #4]
322067a0:	f043 0301 	orr.w	r3, r3, #1
322067a4:	6053      	str	r3, [r2, #4]
322067a6:	4626      	mov	r6, r4
322067a8:	4640      	mov	r0, r8
322067aa:	f7ff ff45 	bl	32206638 <__malloc_unlock>
322067ae:	4630      	mov	r0, r6
322067b0:	b003      	add	sp, #12
322067b2:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
322067b6:	07c3      	lsls	r3, r0, #31
322067b8:	d494      	bmi.n	322066e4 <_realloc_r+0xa0>
322067ba:	f854 3c08 	ldr.w	r3, [r4, #-8]
322067be:	eba9 0b03 	sub.w	fp, r9, r3
322067c2:	f8db 3004 	ldr.w	r3, [fp, #4]
322067c6:	f023 0003 	bic.w	r0, r3, #3
322067ca:	e786      	b.n	322066da <_realloc_r+0x96>
322067cc:	4611      	mov	r1, r2
322067ce:	b003      	add	sp, #12
322067d0:	e8bd 4ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
322067d4:	f7ff b9d8 	b.w	32205b88 <_malloc_r>
322067d8:	eb09 0105 	add.w	r1, r9, r5
322067dc:	432b      	orrs	r3, r5
322067de:	f040 0001 	orr.w	r0, r0, #1
322067e2:	f8c9 3004 	str.w	r3, [r9, #4]
322067e6:	3108      	adds	r1, #8
322067e8:	f841 0c04 	str.w	r0, [r1, #-4]
322067ec:	4640      	mov	r0, r8
322067ee:	6853      	ldr	r3, [r2, #4]
322067f0:	f043 0301 	orr.w	r3, r3, #1
322067f4:	6053      	str	r3, [r2, #4]
322067f6:	f7ff f877 	bl	322058e8 <_free_r>
322067fa:	e7d4      	b.n	322067a6 <_realloc_r+0x162>
322067fc:	f02c 0c03 	bic.w	ip, ip, #3
32206800:	f105 0110 	add.w	r1, r5, #16
32206804:	eb0c 0307 	add.w	r3, ip, r7
32206808:	428b      	cmp	r3, r1
3220680a:	f280 8088 	bge.w	3220691e <_realloc_r+0x2da>
3220680e:	07c0      	lsls	r0, r0, #31
32206810:	f53f af68 	bmi.w	322066e4 <_realloc_r+0xa0>
32206814:	f854 3c08 	ldr.w	r3, [r4, #-8]
32206818:	eba9 0b03 	sub.w	fp, r9, r3
3220681c:	f8db 3004 	ldr.w	r3, [fp, #4]
32206820:	f023 0003 	bic.w	r0, r3, #3
32206824:	4484      	add	ip, r0
32206826:	eb0c 0307 	add.w	r3, ip, r7
3220682a:	4299      	cmp	r1, r3
3220682c:	f73f af55 	bgt.w	322066da <_realloc_r+0x96>
32206830:	465e      	mov	r6, fp
32206832:	f8db 100c 	ldr.w	r1, [fp, #12]
32206836:	1f3a      	subs	r2, r7, #4
32206838:	2a24      	cmp	r2, #36	@ 0x24
3220683a:	f856 0f08 	ldr.w	r0, [r6, #8]!
3220683e:	60c1      	str	r1, [r0, #12]
32206840:	6088      	str	r0, [r1, #8]
32206842:	f200 80a4 	bhi.w	3220698e <_realloc_r+0x34a>
32206846:	2a13      	cmp	r2, #19
32206848:	bf98      	it	ls
3220684a:	4632      	movls	r2, r6
3220684c:	d90b      	bls.n	32206866 <_realloc_r+0x222>
3220684e:	6821      	ldr	r1, [r4, #0]
32206850:	2a1b      	cmp	r2, #27
32206852:	f8cb 1008 	str.w	r1, [fp, #8]
32206856:	6861      	ldr	r1, [r4, #4]
32206858:	f8cb 100c 	str.w	r1, [fp, #12]
3220685c:	f200 809e 	bhi.w	3220699c <_realloc_r+0x358>
32206860:	3408      	adds	r4, #8
32206862:	f10b 0210 	add.w	r2, fp, #16
32206866:	6821      	ldr	r1, [r4, #0]
32206868:	6011      	str	r1, [r2, #0]
3220686a:	6861      	ldr	r1, [r4, #4]
3220686c:	6051      	str	r1, [r2, #4]
3220686e:	68a1      	ldr	r1, [r4, #8]
32206870:	6091      	str	r1, [r2, #8]
32206872:	eb0b 0205 	add.w	r2, fp, r5
32206876:	1b5b      	subs	r3, r3, r5
32206878:	f8ca 2008 	str.w	r2, [sl, #8]
3220687c:	f043 0301 	orr.w	r3, r3, #1
32206880:	4640      	mov	r0, r8
32206882:	6053      	str	r3, [r2, #4]
32206884:	f8db 3004 	ldr.w	r3, [fp, #4]
32206888:	f003 0301 	and.w	r3, r3, #1
3220688c:	432b      	orrs	r3, r5
3220688e:	f8cb 3004 	str.w	r3, [fp, #4]
32206892:	f7ff fed1 	bl	32206638 <__malloc_unlock>
32206896:	e78a      	b.n	322067ae <_realloc_r+0x16a>
32206898:	f850 3c04 	ldr.w	r3, [r0, #-4]
3220689c:	f023 0303 	bic.w	r3, r3, #3
322068a0:	441f      	add	r7, r3
322068a2:	e770      	b.n	32206786 <_realloc_r+0x142>
322068a4:	1f3a      	subs	r2, r7, #4
322068a6:	465e      	mov	r6, fp
322068a8:	f8db 300c 	ldr.w	r3, [fp, #12]
322068ac:	2a24      	cmp	r2, #36	@ 0x24
322068ae:	f856 1f08 	ldr.w	r1, [r6, #8]!
322068b2:	60cb      	str	r3, [r1, #12]
322068b4:	6099      	str	r1, [r3, #8]
322068b6:	d822      	bhi.n	322068fe <_realloc_r+0x2ba>
322068b8:	2a13      	cmp	r2, #19
322068ba:	bf98      	it	ls
322068bc:	4633      	movls	r3, r6
322068be:	d90a      	bls.n	322068d6 <_realloc_r+0x292>
322068c0:	6823      	ldr	r3, [r4, #0]
322068c2:	2a1b      	cmp	r2, #27
322068c4:	f8cb 3008 	str.w	r3, [fp, #8]
322068c8:	6863      	ldr	r3, [r4, #4]
322068ca:	f8cb 300c 	str.w	r3, [fp, #12]
322068ce:	d83a      	bhi.n	32206946 <_realloc_r+0x302>
322068d0:	3408      	adds	r4, #8
322068d2:	f10b 0310 	add.w	r3, fp, #16
322068d6:	6822      	ldr	r2, [r4, #0]
322068d8:	601a      	str	r2, [r3, #0]
322068da:	6862      	ldr	r2, [r4, #4]
322068dc:	605a      	str	r2, [r3, #4]
322068de:	68a2      	ldr	r2, [r4, #8]
322068e0:	609a      	str	r2, [r3, #8]
322068e2:	4634      	mov	r4, r6
322068e4:	4657      	mov	r7, sl
322068e6:	46d9      	mov	r9, fp
322068e8:	e74d      	b.n	32206786 <_realloc_r+0x142>
322068ea:	4621      	mov	r1, r4
322068ec:	f7fd fbbe 	bl	3220406c <memmove>
322068f0:	e725      	b.n	3220673e <_realloc_r+0xfa>
322068f2:	e9d1 1302 	ldrd	r1, r3, [r1, #8]
322068f6:	60cb      	str	r3, [r1, #12]
322068f8:	1f3a      	subs	r2, r7, #4
322068fa:	6099      	str	r1, [r3, #8]
322068fc:	e7d3      	b.n	322068a6 <_realloc_r+0x262>
322068fe:	4621      	mov	r1, r4
32206900:	4630      	mov	r0, r6
32206902:	f7fd fbb3 	bl	3220406c <memmove>
32206906:	e7ec      	b.n	322068e2 <_realloc_r+0x29e>
32206908:	68a3      	ldr	r3, [r4, #8]
3220690a:	2a24      	cmp	r2, #36	@ 0x24
3220690c:	6083      	str	r3, [r0, #8]
3220690e:	68e3      	ldr	r3, [r4, #12]
32206910:	60c3      	str	r3, [r0, #12]
32206912:	d028      	beq.n	32206966 <_realloc_r+0x322>
32206914:	f104 0210 	add.w	r2, r4, #16
32206918:	f100 0310 	add.w	r3, r0, #16
3220691c:	e709      	b.n	32206732 <_realloc_r+0xee>
3220691e:	eb09 0205 	add.w	r2, r9, r5
32206922:	1b5b      	subs	r3, r3, r5
32206924:	f8ca 2008 	str.w	r2, [sl, #8]
32206928:	f043 0301 	orr.w	r3, r3, #1
3220692c:	4640      	mov	r0, r8
3220692e:	4626      	mov	r6, r4
32206930:	6053      	str	r3, [r2, #4]
32206932:	f854 3c04 	ldr.w	r3, [r4, #-4]
32206936:	f003 0301 	and.w	r3, r3, #1
3220693a:	432b      	orrs	r3, r5
3220693c:	f844 3c04 	str.w	r3, [r4, #-4]
32206940:	f7ff fe7a 	bl	32206638 <__malloc_unlock>
32206944:	e733      	b.n	322067ae <_realloc_r+0x16a>
32206946:	68a3      	ldr	r3, [r4, #8]
32206948:	2a24      	cmp	r2, #36	@ 0x24
3220694a:	f8cb 3010 	str.w	r3, [fp, #16]
3220694e:	68e3      	ldr	r3, [r4, #12]
32206950:	f8cb 3014 	str.w	r3, [fp, #20]
32206954:	d010      	beq.n	32206978 <_realloc_r+0x334>
32206956:	3410      	adds	r4, #16
32206958:	f10b 0318 	add.w	r3, fp, #24
3220695c:	e7bb      	b.n	322068d6 <_realloc_r+0x292>
3220695e:	4640      	mov	r0, r8
32206960:	f7ff fe6a 	bl	32206638 <__malloc_unlock>
32206964:	e705      	b.n	32206772 <_realloc_r+0x12e>
32206966:	6923      	ldr	r3, [r4, #16]
32206968:	f104 0218 	add.w	r2, r4, #24
3220696c:	6103      	str	r3, [r0, #16]
3220696e:	f100 0318 	add.w	r3, r0, #24
32206972:	6961      	ldr	r1, [r4, #20]
32206974:	6141      	str	r1, [r0, #20]
32206976:	e6dc      	b.n	32206732 <_realloc_r+0xee>
32206978:	6923      	ldr	r3, [r4, #16]
3220697a:	3418      	adds	r4, #24
3220697c:	f8cb 3018 	str.w	r3, [fp, #24]
32206980:	f10b 0320 	add.w	r3, fp, #32
32206984:	f854 2c04 	ldr.w	r2, [r4, #-4]
32206988:	f8cb 201c 	str.w	r2, [fp, #28]
3220698c:	e7a3      	b.n	322068d6 <_realloc_r+0x292>
3220698e:	4621      	mov	r1, r4
32206990:	4630      	mov	r0, r6
32206992:	9301      	str	r3, [sp, #4]
32206994:	f7fd fb6a 	bl	3220406c <memmove>
32206998:	9b01      	ldr	r3, [sp, #4]
3220699a:	e76a      	b.n	32206872 <_realloc_r+0x22e>
3220699c:	68a1      	ldr	r1, [r4, #8]
3220699e:	2a24      	cmp	r2, #36	@ 0x24
322069a0:	f8cb 1010 	str.w	r1, [fp, #16]
322069a4:	68e1      	ldr	r1, [r4, #12]
322069a6:	f8cb 1014 	str.w	r1, [fp, #20]
322069aa:	d003      	beq.n	322069b4 <_realloc_r+0x370>
322069ac:	3410      	adds	r4, #16
322069ae:	f10b 0218 	add.w	r2, fp, #24
322069b2:	e758      	b.n	32206866 <_realloc_r+0x222>
322069b4:	6922      	ldr	r2, [r4, #16]
322069b6:	3418      	adds	r4, #24
322069b8:	f8cb 2018 	str.w	r2, [fp, #24]
322069bc:	f10b 0220 	add.w	r2, fp, #32
322069c0:	f854 1c04 	ldr.w	r1, [r4, #-4]
322069c4:	f8cb 101c 	str.w	r1, [fp, #28]
322069c8:	e74d      	b.n	32206866 <_realloc_r+0x222>
322069ca:	bf00      	nop

322069cc <_strtol_l.part.0>:
322069cc:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
322069d0:	4690      	mov	r8, r2
322069d2:	4a7c      	ldr	r2, [pc, #496]	@ (32206bc4 <_strtol_l.part.0+0x1f8>)
322069d4:	b083      	sub	sp, #12
322069d6:	4682      	mov	sl, r0
322069d8:	460d      	mov	r5, r1
322069da:	4628      	mov	r0, r5
322069dc:	f815 eb01 	ldrb.w	lr, [r5], #1
322069e0:	f812 600e 	ldrb.w	r6, [r2, lr]
322069e4:	f016 0608 	ands.w	r6, r6, #8
322069e8:	d1f7      	bne.n	322069da <_strtol_l.part.0+0xe>
322069ea:	f023 0210 	bic.w	r2, r3, #16
322069ee:	f1be 0f2d 	cmp.w	lr, #45	@ 0x2d
322069f2:	d072      	beq.n	32206ada <_strtol_l.part.0+0x10e>
322069f4:	f1be 0f2b 	cmp.w	lr, #43	@ 0x2b
322069f8:	d011      	beq.n	32206a1e <_strtol_l.part.0+0x52>
322069fa:	b9aa      	cbnz	r2, 32206a28 <_strtol_l.part.0+0x5c>
322069fc:	f1be 0f30 	cmp.w	lr, #48	@ 0x30
32206a00:	f000 80aa 	beq.w	32206b58 <_strtol_l.part.0+0x18c>
32206a04:	2b00      	cmp	r3, #0
32206a06:	f000 809f 	beq.w	32206b48 <_strtol_l.part.0+0x17c>
32206a0a:	2310      	movs	r3, #16
32206a0c:	f06f 4778 	mvn.w	r7, #4160749568	@ 0xf8000000
32206a10:	220f      	movs	r2, #15
32206a12:	4699      	mov	r9, r3
32206a14:	2000      	movs	r0, #0
32206a16:	f06f 4b00 	mvn.w	fp, #2147483648	@ 0x80000000
32206a1a:	9001      	str	r0, [sp, #4]
32206a1c:	e00d      	b.n	32206a3a <_strtol_l.part.0+0x6e>
32206a1e:	f895 e000 	ldrb.w	lr, [r5]
32206a22:	1c85      	adds	r5, r0, #2
32206a24:	2a00      	cmp	r2, #0
32206a26:	d07a      	beq.n	32206b1e <_strtol_l.part.0+0x152>
32206a28:	f06f 4200 	mvn.w	r2, #2147483648	@ 0x80000000
32206a2c:	4699      	mov	r9, r3
32206a2e:	4693      	mov	fp, r2
32206a30:	9601      	str	r6, [sp, #4]
32206a32:	fbb2 f7f3 	udiv	r7, r2, r3
32206a36:	fb03 2217 	mls	r2, r3, r7, r2
32206a3a:	2400      	movs	r4, #0
32206a3c:	4620      	mov	r0, r4
32206a3e:	e00d      	b.n	32206a5c <_strtol_l.part.0+0x90>
32206a40:	1bc4      	subs	r4, r0, r7
32206a42:	4594      	cmp	ip, r2
32206a44:	fab4 f484 	clz	r4, r4
32206a48:	ea4f 1454 	mov.w	r4, r4, lsr #5
32206a4c:	bfd8      	it	le
32206a4e:	2400      	movle	r4, #0
32206a50:	b9f4      	cbnz	r4, 32206a90 <_strtol_l.part.0+0xc4>
32206a52:	fb09 c000 	mla	r0, r9, r0, ip
32206a56:	2401      	movs	r4, #1
32206a58:	f815 eb01 	ldrb.w	lr, [r5], #1
32206a5c:	f1ae 0c30 	sub.w	ip, lr, #48	@ 0x30
32206a60:	f1bc 0f09 	cmp.w	ip, #9
32206a64:	d906      	bls.n	32206a74 <_strtol_l.part.0+0xa8>
32206a66:	f1ae 0c41 	sub.w	ip, lr, #65	@ 0x41
32206a6a:	f1bc 0f19 	cmp.w	ip, #25
32206a6e:	d812      	bhi.n	32206a96 <_strtol_l.part.0+0xca>
32206a70:	f1ae 0c37 	sub.w	ip, lr, #55	@ 0x37
32206a74:	459c      	cmp	ip, r3
32206a76:	da17      	bge.n	32206aa8 <_strtol_l.part.0+0xdc>
32206a78:	f1a4 34ff 	sub.w	r4, r4, #4294967295	@ 0xffffffff
32206a7c:	42b8      	cmp	r0, r7
32206a7e:	fab4 f484 	clz	r4, r4
32206a82:	bf98      	it	ls
32206a84:	2600      	movls	r6, #0
32206a86:	bf88      	it	hi
32206a88:	2601      	movhi	r6, #1
32206a8a:	0964      	lsrs	r4, r4, #5
32206a8c:	4334      	orrs	r4, r6
32206a8e:	d0d7      	beq.n	32206a40 <_strtol_l.part.0+0x74>
32206a90:	f04f 34ff 	mov.w	r4, #4294967295	@ 0xffffffff
32206a94:	e7e0      	b.n	32206a58 <_strtol_l.part.0+0x8c>
32206a96:	f1ae 0c61 	sub.w	ip, lr, #97	@ 0x61
32206a9a:	f1bc 0f19 	cmp.w	ip, #25
32206a9e:	d803      	bhi.n	32206aa8 <_strtol_l.part.0+0xdc>
32206aa0:	f1ae 0c57 	sub.w	ip, lr, #87	@ 0x57
32206aa4:	459c      	cmp	ip, r3
32206aa6:	dbe7      	blt.n	32206a78 <_strtol_l.part.0+0xac>
32206aa8:	1c63      	adds	r3, r4, #1
32206aaa:	d00c      	beq.n	32206ac6 <_strtol_l.part.0+0xfa>
32206aac:	9b01      	ldr	r3, [sp, #4]
32206aae:	b103      	cbz	r3, 32206ab2 <_strtol_l.part.0+0xe6>
32206ab0:	4240      	negs	r0, r0
32206ab2:	f1b8 0f00 	cmp.w	r8, #0
32206ab6:	d003      	beq.n	32206ac0 <_strtol_l.part.0+0xf4>
32206ab8:	2c00      	cmp	r4, #0
32206aba:	d15c      	bne.n	32206b76 <_strtol_l.part.0+0x1aa>
32206abc:	f8c8 1000 	str.w	r1, [r8]
32206ac0:	b003      	add	sp, #12
32206ac2:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32206ac6:	2322      	movs	r3, #34	@ 0x22
32206ac8:	4658      	mov	r0, fp
32206aca:	f8ca 3000 	str.w	r3, [sl]
32206ace:	f1b8 0f00 	cmp.w	r8, #0
32206ad2:	d0f5      	beq.n	32206ac0 <_strtol_l.part.0+0xf4>
32206ad4:	1e69      	subs	r1, r5, #1
32206ad6:	4658      	mov	r0, fp
32206ad8:	e7f0      	b.n	32206abc <_strtol_l.part.0+0xf0>
32206ada:	f895 e000 	ldrb.w	lr, [r5]
32206ade:	1c85      	adds	r5, r0, #2
32206ae0:	b982      	cbnz	r2, 32206b04 <_strtol_l.part.0+0x138>
32206ae2:	f1be 0f30 	cmp.w	lr, #48	@ 0x30
32206ae6:	d048      	beq.n	32206b7a <_strtol_l.part.0+0x1ae>
32206ae8:	2b00      	cmp	r3, #0
32206aea:	d156      	bne.n	32206b9a <_strtol_l.part.0+0x1ce>
32206aec:	230a      	movs	r3, #10
32206aee:	2001      	movs	r0, #1
32206af0:	f64c 47cc 	movw	r7, #52428	@ 0xcccc
32206af4:	f6c0 47cc 	movt	r7, #3276	@ 0xccc
32206af8:	2208      	movs	r2, #8
32206afa:	4699      	mov	r9, r3
32206afc:	f04f 4b00 	mov.w	fp, #2147483648	@ 0x80000000
32206b00:	9001      	str	r0, [sp, #4]
32206b02:	e79a      	b.n	32206a3a <_strtol_l.part.0+0x6e>
32206b04:	f04f 4700 	mov.w	r7, #2147483648	@ 0x80000000
32206b08:	2201      	movs	r2, #1
32206b0a:	46bb      	mov	fp, r7
32206b0c:	9201      	str	r2, [sp, #4]
32206b0e:	4699      	mov	r9, r3
32206b10:	fbb7 f7f3 	udiv	r7, r7, r3
32206b14:	fb03 f207 	mul.w	r2, r3, r7
32206b18:	ebab 0202 	sub.w	r2, fp, r2
32206b1c:	e78d      	b.n	32206a3a <_strtol_l.part.0+0x6e>
32206b1e:	f1be 0f30 	cmp.w	lr, #48	@ 0x30
32206b22:	f47f af6f 	bne.w	32206a04 <_strtol_l.part.0+0x38>
32206b26:	7882      	ldrb	r2, [r0, #2]
32206b28:	f002 02df 	and.w	r2, r2, #223	@ 0xdf
32206b2c:	2a58      	cmp	r2, #88	@ 0x58
32206b2e:	d11e      	bne.n	32206b6e <_strtol_l.part.0+0x1a2>
32206b30:	2310      	movs	r3, #16
32206b32:	f890 e003 	ldrb.w	lr, [r0, #3]
32206b36:	1d05      	adds	r5, r0, #4
32206b38:	4699      	mov	r9, r3
32206b3a:	f06f 4200 	mvn.w	r2, #2147483648	@ 0x80000000
32206b3e:	fbb2 f7f9 	udiv	r7, r2, r9
32206b42:	fb09 2217 	mls	r2, r9, r7, r2
32206b46:	e765      	b.n	32206a14 <_strtol_l.part.0+0x48>
32206b48:	230a      	movs	r3, #10
32206b4a:	f64c 47cc 	movw	r7, #52428	@ 0xcccc
32206b4e:	f6c0 47cc 	movt	r7, #3276	@ 0xccc
32206b52:	2207      	movs	r2, #7
32206b54:	4699      	mov	r9, r3
32206b56:	e75d      	b.n	32206a14 <_strtol_l.part.0+0x48>
32206b58:	782a      	ldrb	r2, [r5, #0]
32206b5a:	f002 02df 	and.w	r2, r2, #223	@ 0xdf
32206b5e:	2a58      	cmp	r2, #88	@ 0x58
32206b60:	d105      	bne.n	32206b6e <_strtol_l.part.0+0x1a2>
32206b62:	2310      	movs	r3, #16
32206b64:	f895 e001 	ldrb.w	lr, [r5, #1]
32206b68:	4699      	mov	r9, r3
32206b6a:	1cc5      	adds	r5, r0, #3
32206b6c:	e7e5      	b.n	32206b3a <_strtol_l.part.0+0x16e>
32206b6e:	bb1b      	cbnz	r3, 32206bb8 <_strtol_l.part.0+0x1ec>
32206b70:	2308      	movs	r3, #8
32206b72:	4699      	mov	r9, r3
32206b74:	e7e1      	b.n	32206b3a <_strtol_l.part.0+0x16e>
32206b76:	4683      	mov	fp, r0
32206b78:	e7ac      	b.n	32206ad4 <_strtol_l.part.0+0x108>
32206b7a:	7884      	ldrb	r4, [r0, #2]
32206b7c:	f004 04df 	and.w	r4, r4, #223	@ 0xdf
32206b80:	2c58      	cmp	r4, #88	@ 0x58
32206b82:	d013      	beq.n	32206bac <_strtol_l.part.0+0x1e0>
32206b84:	b1db      	cbz	r3, 32206bbe <_strtol_l.part.0+0x1f2>
32206b86:	2310      	movs	r3, #16
32206b88:	4699      	mov	r9, r3
32206b8a:	f04f 4700 	mov.w	r7, #2147483648	@ 0x80000000
32206b8e:	2001      	movs	r0, #1
32206b90:	46bb      	mov	fp, r7
32206b92:	9001      	str	r0, [sp, #4]
32206b94:	fbb7 f7f9 	udiv	r7, r7, r9
32206b98:	e74f      	b.n	32206a3a <_strtol_l.part.0+0x6e>
32206b9a:	2310      	movs	r3, #16
32206b9c:	2001      	movs	r0, #1
32206b9e:	f04f 6700 	mov.w	r7, #134217728	@ 0x8000000
32206ba2:	4699      	mov	r9, r3
32206ba4:	f04f 4b00 	mov.w	fp, #2147483648	@ 0x80000000
32206ba8:	9001      	str	r0, [sp, #4]
32206baa:	e746      	b.n	32206a3a <_strtol_l.part.0+0x6e>
32206bac:	2310      	movs	r3, #16
32206bae:	f890 e003 	ldrb.w	lr, [r0, #3]
32206bb2:	1d05      	adds	r5, r0, #4
32206bb4:	4699      	mov	r9, r3
32206bb6:	e7e8      	b.n	32206b8a <_strtol_l.part.0+0x1be>
32206bb8:	2310      	movs	r3, #16
32206bba:	4699      	mov	r9, r3
32206bbc:	e7bd      	b.n	32206b3a <_strtol_l.part.0+0x16e>
32206bbe:	2308      	movs	r3, #8
32206bc0:	4699      	mov	r9, r3
32206bc2:	e7e2      	b.n	32206b8a <_strtol_l.part.0+0x1be>
32206bc4:	3220bed9 	.word	0x3220bed9

32206bc8 <_strtol_r>:
32206bc8:	b570      	push	{r4, r5, r6, lr}
32206bca:	f1a3 0401 	sub.w	r4, r3, #1
32206bce:	fab4 f484 	clz	r4, r4
32206bd2:	2b24      	cmp	r3, #36	@ 0x24
32206bd4:	bf98      	it	ls
32206bd6:	2500      	movls	r5, #0
32206bd8:	bf88      	it	hi
32206bda:	2501      	movhi	r5, #1
32206bdc:	0964      	lsrs	r4, r4, #5
32206bde:	4325      	orrs	r5, r4
32206be0:	d103      	bne.n	32206bea <_strtol_r+0x22>
32206be2:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
32206be6:	f7ff bef1 	b.w	322069cc <_strtol_l.part.0>
32206bea:	f7fe f8a5 	bl	32204d38 <__errno>
32206bee:	2316      	movs	r3, #22
32206bf0:	6003      	str	r3, [r0, #0]
32206bf2:	2000      	movs	r0, #0
32206bf4:	bd70      	pop	{r4, r5, r6, pc}
32206bf6:	bf00      	nop

32206bf8 <strtol_l>:
32206bf8:	b570      	push	{r4, r5, r6, lr}
32206bfa:	f1a2 0501 	sub.w	r5, r2, #1
32206bfe:	fab5 f585 	clz	r5, r5
32206c02:	2a24      	cmp	r2, #36	@ 0x24
32206c04:	bf98      	it	ls
32206c06:	2400      	movls	r4, #0
32206c08:	bf88      	it	hi
32206c0a:	2401      	movhi	r4, #1
32206c0c:	096d      	lsrs	r5, r5, #5
32206c0e:	432c      	orrs	r4, r5
32206c10:	d10b      	bne.n	32206c2a <strtol_l+0x32>
32206c12:	f24c 34d0 	movw	r4, #50128	@ 0xc3d0
32206c16:	f2c3 2420 	movt	r4, #12832	@ 0x3220
32206c1a:	4613      	mov	r3, r2
32206c1c:	460a      	mov	r2, r1
32206c1e:	4601      	mov	r1, r0
32206c20:	6820      	ldr	r0, [r4, #0]
32206c22:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
32206c26:	f7ff bed1 	b.w	322069cc <_strtol_l.part.0>
32206c2a:	f7fe f885 	bl	32204d38 <__errno>
32206c2e:	2316      	movs	r3, #22
32206c30:	6003      	str	r3, [r0, #0]
32206c32:	2000      	movs	r0, #0
32206c34:	bd70      	pop	{r4, r5, r6, pc}
32206c36:	bf00      	nop

32206c38 <strtol>:
32206c38:	b570      	push	{r4, r5, r6, lr}
32206c3a:	f1a2 0501 	sub.w	r5, r2, #1
32206c3e:	fab5 f585 	clz	r5, r5
32206c42:	2a24      	cmp	r2, #36	@ 0x24
32206c44:	bf98      	it	ls
32206c46:	2400      	movls	r4, #0
32206c48:	bf88      	it	hi
32206c4a:	2401      	movhi	r4, #1
32206c4c:	096d      	lsrs	r5, r5, #5
32206c4e:	432c      	orrs	r4, r5
32206c50:	d10b      	bne.n	32206c6a <strtol+0x32>
32206c52:	f24c 34d0 	movw	r4, #50128	@ 0xc3d0
32206c56:	f2c3 2420 	movt	r4, #12832	@ 0x3220
32206c5a:	4613      	mov	r3, r2
32206c5c:	460a      	mov	r2, r1
32206c5e:	4601      	mov	r1, r0
32206c60:	6820      	ldr	r0, [r4, #0]
32206c62:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
32206c66:	f7ff beb1 	b.w	322069cc <_strtol_l.part.0>
32206c6a:	f7fe f865 	bl	32204d38 <__errno>
32206c6e:	2316      	movs	r3, #22
32206c70:	6003      	str	r3, [r0, #0]
32206c72:	2000      	movs	r0, #0
32206c74:	bd70      	pop	{r4, r5, r6, pc}
32206c76:	bf00      	nop

32206c78 <_wctomb_r>:
32206c78:	f24c 2c40 	movw	ip, #49728	@ 0xc240
32206c7c:	f2c3 2c20 	movt	ip, #12832	@ 0x3220
32206c80:	b410      	push	{r4}
32206c82:	f8dc 40e0 	ldr.w	r4, [ip, #224]	@ 0xe0
32206c86:	46a4      	mov	ip, r4
32206c88:	f85d 4b04 	ldr.w	r4, [sp], #4
32206c8c:	4760      	bx	ip
32206c8e:	bf00      	nop

32206c90 <__ascii_wctomb>:
32206c90:	4603      	mov	r3, r0
32206c92:	b149      	cbz	r1, 32206ca8 <__ascii_wctomb+0x18>
32206c94:	2aff      	cmp	r2, #255	@ 0xff
32206c96:	d802      	bhi.n	32206c9e <__ascii_wctomb+0xe>
32206c98:	2001      	movs	r0, #1
32206c9a:	700a      	strb	r2, [r1, #0]
32206c9c:	4770      	bx	lr
32206c9e:	228a      	movs	r2, #138	@ 0x8a
32206ca0:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32206ca4:	601a      	str	r2, [r3, #0]
32206ca6:	4770      	bx	lr
32206ca8:	4608      	mov	r0, r1
32206caa:	4770      	bx	lr

32206cac <__utf8_wctomb>:
32206cac:	4603      	mov	r3, r0
32206cae:	b3b1      	cbz	r1, 32206d1e <__utf8_wctomb+0x72>
32206cb0:	2a7f      	cmp	r2, #127	@ 0x7f
32206cb2:	d926      	bls.n	32206d02 <__utf8_wctomb+0x56>
32206cb4:	f1a2 0080 	sub.w	r0, r2, #128	@ 0x80
32206cb8:	f5b0 6ff0 	cmp.w	r0, #1920	@ 0x780
32206cbc:	d324      	bcc.n	32206d08 <__utf8_wctomb+0x5c>
32206cbe:	f5a2 6000 	sub.w	r0, r2, #2048	@ 0x800
32206cc2:	f5b0 4f78 	cmp.w	r0, #63488	@ 0xf800
32206cc6:	d32c      	bcc.n	32206d22 <__utf8_wctomb+0x76>
32206cc8:	f5a2 3080 	sub.w	r0, r2, #65536	@ 0x10000
32206ccc:	f5b0 1f80 	cmp.w	r0, #1048576	@ 0x100000
32206cd0:	d239      	bcs.n	32206d46 <__utf8_wctomb+0x9a>
32206cd2:	ea4f 4c92 	mov.w	ip, r2, lsr #18
32206cd6:	2300      	movs	r3, #0
32206cd8:	f3c2 3005 	ubfx	r0, r2, #12, #6
32206cdc:	f36c 0307 	bfi	r3, ip, #0, #8
32206ce0:	f3c2 1c85 	ubfx	ip, r2, #6, #6
32206ce4:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
32206ce8:	f360 230f 	bfi	r3, r0, #8, #8
32206cec:	2004      	movs	r0, #4
32206cee:	f36c 4317 	bfi	r3, ip, #16, #8
32206cf2:	f362 631f 	bfi	r3, r2, #24, #8
32206cf6:	f043 3380 	orr.w	r3, r3, #2155905152	@ 0x80808080
32206cfa:	f043 0370 	orr.w	r3, r3, #112	@ 0x70
32206cfe:	600b      	str	r3, [r1, #0]
32206d00:	4770      	bx	lr
32206d02:	2001      	movs	r0, #1
32206d04:	700a      	strb	r2, [r1, #0]
32206d06:	4770      	bx	lr
32206d08:	0993      	lsrs	r3, r2, #6
32206d0a:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
32206d0e:	f063 033f 	orn	r3, r3, #63	@ 0x3f
32206d12:	f062 027f 	orn	r2, r2, #127	@ 0x7f
32206d16:	2002      	movs	r0, #2
32206d18:	700b      	strb	r3, [r1, #0]
32206d1a:	704a      	strb	r2, [r1, #1]
32206d1c:	4770      	bx	lr
32206d1e:	4608      	mov	r0, r1
32206d20:	4770      	bx	lr
32206d22:	ea4f 3c12 	mov.w	ip, r2, lsr #12
32206d26:	f3c2 1385 	ubfx	r3, r2, #6, #6
32206d2a:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
32206d2e:	f06c 0c1f 	orn	ip, ip, #31
32206d32:	f063 037f 	orn	r3, r3, #127	@ 0x7f
32206d36:	f062 027f 	orn	r2, r2, #127	@ 0x7f
32206d3a:	2003      	movs	r0, #3
32206d3c:	f881 c000 	strb.w	ip, [r1]
32206d40:	704b      	strb	r3, [r1, #1]
32206d42:	708a      	strb	r2, [r1, #2]
32206d44:	4770      	bx	lr
32206d46:	228a      	movs	r2, #138	@ 0x8a
32206d48:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32206d4c:	601a      	str	r2, [r3, #0]
32206d4e:	4770      	bx	lr

32206d50 <__sjis_wctomb>:
32206d50:	b2d3      	uxtb	r3, r2
32206d52:	f3c2 2207 	ubfx	r2, r2, #8, #8
32206d56:	b1e9      	cbz	r1, 32206d94 <__sjis_wctomb+0x44>
32206d58:	b1ca      	cbz	r2, 32206d8e <__sjis_wctomb+0x3e>
32206d5a:	4684      	mov	ip, r0
32206d5c:	b410      	push	{r4}
32206d5e:	f102 007f 	add.w	r0, r2, #127	@ 0x7f
32206d62:	f102 0420 	add.w	r4, r2, #32
32206d66:	b2c0      	uxtb	r0, r0
32206d68:	b2e4      	uxtb	r4, r4
32206d6a:	281e      	cmp	r0, #30
32206d6c:	bf88      	it	hi
32206d6e:	2c0f      	cmphi	r4, #15
32206d70:	d812      	bhi.n	32206d98 <__sjis_wctomb+0x48>
32206d72:	f1a3 0040 	sub.w	r0, r3, #64	@ 0x40
32206d76:	f083 0480 	eor.w	r4, r3, #128	@ 0x80
32206d7a:	283e      	cmp	r0, #62	@ 0x3e
32206d7c:	bf88      	it	hi
32206d7e:	2c7c      	cmphi	r4, #124	@ 0x7c
32206d80:	d80a      	bhi.n	32206d98 <__sjis_wctomb+0x48>
32206d82:	2002      	movs	r0, #2
32206d84:	700a      	strb	r2, [r1, #0]
32206d86:	704b      	strb	r3, [r1, #1]
32206d88:	f85d 4b04 	ldr.w	r4, [sp], #4
32206d8c:	4770      	bx	lr
32206d8e:	2001      	movs	r0, #1
32206d90:	700b      	strb	r3, [r1, #0]
32206d92:	4770      	bx	lr
32206d94:	4608      	mov	r0, r1
32206d96:	4770      	bx	lr
32206d98:	238a      	movs	r3, #138	@ 0x8a
32206d9a:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32206d9e:	f8cc 3000 	str.w	r3, [ip]
32206da2:	e7f1      	b.n	32206d88 <__sjis_wctomb+0x38>

32206da4 <__eucjp_wctomb>:
32206da4:	b2d3      	uxtb	r3, r2
32206da6:	f3c2 2207 	ubfx	r2, r2, #8, #8
32206daa:	b329      	cbz	r1, 32206df8 <__eucjp_wctomb+0x54>
32206dac:	b30a      	cbz	r2, 32206df2 <__eucjp_wctomb+0x4e>
32206dae:	4684      	mov	ip, r0
32206db0:	b410      	push	{r4}
32206db2:	f102 005f 	add.w	r0, r2, #95	@ 0x5f
32206db6:	f102 0472 	add.w	r4, r2, #114	@ 0x72
32206dba:	b2c0      	uxtb	r0, r0
32206dbc:	b2e4      	uxtb	r4, r4
32206dbe:	2c01      	cmp	r4, #1
32206dc0:	bf88      	it	hi
32206dc2:	285d      	cmphi	r0, #93	@ 0x5d
32206dc4:	d81e      	bhi.n	32206e04 <__eucjp_wctomb+0x60>
32206dc6:	f103 045f 	add.w	r4, r3, #95	@ 0x5f
32206dca:	b2e4      	uxtb	r4, r4
32206dcc:	2c5d      	cmp	r4, #93	@ 0x5d
32206dce:	d915      	bls.n	32206dfc <__eucjp_wctomb+0x58>
32206dd0:	285d      	cmp	r0, #93	@ 0x5d
32206dd2:	d817      	bhi.n	32206e04 <__eucjp_wctomb+0x60>
32206dd4:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
32206dd8:	f103 005f 	add.w	r0, r3, #95	@ 0x5f
32206ddc:	b2c0      	uxtb	r0, r0
32206dde:	285d      	cmp	r0, #93	@ 0x5d
32206de0:	d810      	bhi.n	32206e04 <__eucjp_wctomb+0x60>
32206de2:	2003      	movs	r0, #3
32206de4:	248f      	movs	r4, #143	@ 0x8f
32206de6:	704a      	strb	r2, [r1, #1]
32206de8:	700c      	strb	r4, [r1, #0]
32206dea:	708b      	strb	r3, [r1, #2]
32206dec:	f85d 4b04 	ldr.w	r4, [sp], #4
32206df0:	4770      	bx	lr
32206df2:	2001      	movs	r0, #1
32206df4:	700b      	strb	r3, [r1, #0]
32206df6:	4770      	bx	lr
32206df8:	4608      	mov	r0, r1
32206dfa:	4770      	bx	lr
32206dfc:	2002      	movs	r0, #2
32206dfe:	700a      	strb	r2, [r1, #0]
32206e00:	704b      	strb	r3, [r1, #1]
32206e02:	e7f3      	b.n	32206dec <__eucjp_wctomb+0x48>
32206e04:	238a      	movs	r3, #138	@ 0x8a
32206e06:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32206e0a:	f8cc 3000 	str.w	r3, [ip]
32206e0e:	e7ed      	b.n	32206dec <__eucjp_wctomb+0x48>

32206e10 <__jis_wctomb>:
32206e10:	b500      	push	{lr}
32206e12:	fa5f fe82 	uxtb.w	lr, r2
32206e16:	f3c2 2207 	ubfx	r2, r2, #8, #8
32206e1a:	b379      	cbz	r1, 32206e7c <__jis_wctomb+0x6c>
32206e1c:	b97a      	cbnz	r2, 32206e3e <__jis_wctomb+0x2e>
32206e1e:	6818      	ldr	r0, [r3, #0]
32206e20:	b1f0      	cbz	r0, 32206e60 <__jis_wctomb+0x50>
32206e22:	468c      	mov	ip, r1
32206e24:	601a      	str	r2, [r3, #0]
32206e26:	f642 031b 	movw	r3, #10267	@ 0x281b
32206e2a:	2004      	movs	r0, #4
32206e2c:	f82c 3b03 	strh.w	r3, [ip], #3
32206e30:	2342      	movs	r3, #66	@ 0x42
32206e32:	708b      	strb	r3, [r1, #2]
32206e34:	4661      	mov	r1, ip
32206e36:	f881 e000 	strb.w	lr, [r1]
32206e3a:	f85d fb04 	ldr.w	pc, [sp], #4
32206e3e:	4684      	mov	ip, r0
32206e40:	f1a2 0021 	sub.w	r0, r2, #33	@ 0x21
32206e44:	285d      	cmp	r0, #93	@ 0x5d
32206e46:	d81c      	bhi.n	32206e82 <__jis_wctomb+0x72>
32206e48:	f1ae 0021 	sub.w	r0, lr, #33	@ 0x21
32206e4c:	285d      	cmp	r0, #93	@ 0x5d
32206e4e:	d818      	bhi.n	32206e82 <__jis_wctomb+0x72>
32206e50:	6818      	ldr	r0, [r3, #0]
32206e52:	b138      	cbz	r0, 32206e64 <__jis_wctomb+0x54>
32206e54:	2002      	movs	r0, #2
32206e56:	700a      	strb	r2, [r1, #0]
32206e58:	f881 e001 	strb.w	lr, [r1, #1]
32206e5c:	f85d fb04 	ldr.w	pc, [sp], #4
32206e60:	2001      	movs	r0, #1
32206e62:	e7e8      	b.n	32206e36 <__jis_wctomb+0x26>
32206e64:	2001      	movs	r0, #1
32206e66:	6018      	str	r0, [r3, #0]
32206e68:	460b      	mov	r3, r1
32206e6a:	f242 401b 	movw	r0, #9243	@ 0x241b
32206e6e:	f823 0b03 	strh.w	r0, [r3], #3
32206e72:	2042      	movs	r0, #66	@ 0x42
32206e74:	7088      	strb	r0, [r1, #2]
32206e76:	2005      	movs	r0, #5
32206e78:	4619      	mov	r1, r3
32206e7a:	e7ec      	b.n	32206e56 <__jis_wctomb+0x46>
32206e7c:	2001      	movs	r0, #1
32206e7e:	f85d fb04 	ldr.w	pc, [sp], #4
32206e82:	238a      	movs	r3, #138	@ 0x8a
32206e84:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32206e88:	f8cc 3000 	str.w	r3, [ip]
32206e8c:	e7d5      	b.n	32206e3a <__jis_wctomb+0x2a>
32206e8e:	bf00      	nop

32206e90 <_wcrtomb_r>:
32206e90:	b570      	push	{r4, r5, r6, lr}
32206e92:	4605      	mov	r5, r0
32206e94:	f500 7482 	add.w	r4, r0, #260	@ 0x104
32206e98:	b084      	sub	sp, #16
32206e9a:	b103      	cbz	r3, 32206e9e <_wcrtomb_r+0xe>
32206e9c:	461c      	mov	r4, r3
32206e9e:	f24c 2340 	movw	r3, #49728	@ 0xc240
32206ea2:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32206ea6:	f8d3 60e0 	ldr.w	r6, [r3, #224]	@ 0xe0
32206eaa:	4623      	mov	r3, r4
32206eac:	b129      	cbz	r1, 32206eba <_wcrtomb_r+0x2a>
32206eae:	4628      	mov	r0, r5
32206eb0:	47b0      	blx	r6
32206eb2:	1c43      	adds	r3, r0, #1
32206eb4:	d007      	beq.n	32206ec6 <_wcrtomb_r+0x36>
32206eb6:	b004      	add	sp, #16
32206eb8:	bd70      	pop	{r4, r5, r6, pc}
32206eba:	460a      	mov	r2, r1
32206ebc:	4628      	mov	r0, r5
32206ebe:	a901      	add	r1, sp, #4
32206ec0:	47b0      	blx	r6
32206ec2:	1c43      	adds	r3, r0, #1
32206ec4:	d1f7      	bne.n	32206eb6 <_wcrtomb_r+0x26>
32206ec6:	2200      	movs	r2, #0
32206ec8:	238a      	movs	r3, #138	@ 0x8a
32206eca:	6022      	str	r2, [r4, #0]
32206ecc:	602b      	str	r3, [r5, #0]
32206ece:	b004      	add	sp, #16
32206ed0:	bd70      	pop	{r4, r5, r6, pc}
32206ed2:	bf00      	nop

32206ed4 <wcrtomb>:
32206ed4:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
32206ed8:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32206edc:	b570      	push	{r4, r5, r6, lr}
32206ede:	681d      	ldr	r5, [r3, #0]
32206ee0:	b084      	sub	sp, #16
32206ee2:	f505 7482 	add.w	r4, r5, #260	@ 0x104
32206ee6:	b102      	cbz	r2, 32206eea <wcrtomb+0x16>
32206ee8:	4614      	mov	r4, r2
32206eea:	f24c 2340 	movw	r3, #49728	@ 0xc240
32206eee:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32206ef2:	f8d3 60e0 	ldr.w	r6, [r3, #224]	@ 0xe0
32206ef6:	b140      	cbz	r0, 32206f0a <wcrtomb+0x36>
32206ef8:	460a      	mov	r2, r1
32206efa:	4623      	mov	r3, r4
32206efc:	4601      	mov	r1, r0
32206efe:	4628      	mov	r0, r5
32206f00:	47b0      	blx	r6
32206f02:	1c43      	adds	r3, r0, #1
32206f04:	d008      	beq.n	32206f18 <wcrtomb+0x44>
32206f06:	b004      	add	sp, #16
32206f08:	bd70      	pop	{r4, r5, r6, pc}
32206f0a:	4623      	mov	r3, r4
32206f0c:	4602      	mov	r2, r0
32206f0e:	a901      	add	r1, sp, #4
32206f10:	4628      	mov	r0, r5
32206f12:	47b0      	blx	r6
32206f14:	1c43      	adds	r3, r0, #1
32206f16:	d1f6      	bne.n	32206f06 <wcrtomb+0x32>
32206f18:	2200      	movs	r2, #0
32206f1a:	238a      	movs	r3, #138	@ 0x8a
32206f1c:	6022      	str	r2, [r4, #0]
32206f1e:	602b      	str	r3, [r5, #0]
32206f20:	b004      	add	sp, #16
32206f22:	bd70      	pop	{r4, r5, r6, pc}

32206f24 <_wcsrtombs_r>:
32206f24:	b510      	push	{r4, lr}
32206f26:	461c      	mov	r4, r3
32206f28:	b082      	sub	sp, #8
32206f2a:	9b04      	ldr	r3, [sp, #16]
32206f2c:	9301      	str	r3, [sp, #4]
32206f2e:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
32206f32:	9400      	str	r4, [sp, #0]
32206f34:	f004 fb5a 	bl	3220b5ec <_wcsnrtombs_r>
32206f38:	b002      	add	sp, #8
32206f3a:	bd10      	pop	{r4, pc}

32206f3c <wcsrtombs>:
32206f3c:	b510      	push	{r4, lr}
32206f3e:	f24c 3cd0 	movw	ip, #50128	@ 0xc3d0
32206f42:	f2c3 2c20 	movt	ip, #12832	@ 0x3220
32206f46:	b082      	sub	sp, #8
32206f48:	4686      	mov	lr, r0
32206f4a:	4614      	mov	r4, r2
32206f4c:	460a      	mov	r2, r1
32206f4e:	f8dc 0000 	ldr.w	r0, [ip]
32206f52:	4671      	mov	r1, lr
32206f54:	9301      	str	r3, [sp, #4]
32206f56:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
32206f5a:	9400      	str	r4, [sp, #0]
32206f5c:	f004 fb46 	bl	3220b5ec <_wcsnrtombs_r>
32206f60:	b002      	add	sp, #8
32206f62:	bd10      	pop	{r4, pc}

32206f64 <__set_ctype>:
32206f64:	f64b 63d8 	movw	r3, #48856	@ 0xbed8
32206f68:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32206f6c:	f8c0 30ec 	str.w	r3, [r0, #236]	@ 0xec
32206f70:	4770      	bx	lr
32206f72:	bf00      	nop
32206f74:	0000      	movs	r0, r0
	...

32206f78 <_vfprintf_r>:
32206f78:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32206f7c:	461c      	mov	r4, r3
32206f7e:	4683      	mov	fp, r0
32206f80:	ed2d 8b04 	vpush	{d8-d9}
32206f84:	b0d1      	sub	sp, #324	@ 0x144
32206f86:	af20      	add	r7, sp, #128	@ 0x80
32206f88:	9103      	str	r1, [sp, #12]
32206f8a:	9206      	str	r2, [sp, #24]
32206f8c:	930a      	str	r3, [sp, #40]	@ 0x28
32206f8e:	f7fd fe37 	bl	32204c00 <_localeconv_r>
32206f92:	6803      	ldr	r3, [r0, #0]
32206f94:	9312      	str	r3, [sp, #72]	@ 0x48
32206f96:	4618      	mov	r0, r3
32206f98:	f7fe fbd2 	bl	32205740 <strlen>
32206f9c:	2208      	movs	r2, #8
32206f9e:	9011      	str	r0, [sp, #68]	@ 0x44
32206fa0:	2100      	movs	r1, #0
32206fa2:	4638      	mov	r0, r7
32206fa4:	f7fd f8e0 	bl	32204168 <memset>
32206fa8:	f1bb 0f00 	cmp.w	fp, #0
32206fac:	d004      	beq.n	32206fb8 <_vfprintf_r+0x40>
32206fae:	f8db 3034 	ldr.w	r3, [fp, #52]	@ 0x34
32206fb2:	2b00      	cmp	r3, #0
32206fb4:	f001 81e4 	beq.w	32208380 <_vfprintf_r+0x1408>
32206fb8:	9b03      	ldr	r3, [sp, #12]
32206fba:	6e5a      	ldr	r2, [r3, #100]	@ 0x64
32206fbc:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
32206fc0:	07d6      	lsls	r6, r2, #31
32206fc2:	f140 8142 	bpl.w	3220724a <_vfprintf_r+0x2d2>
32206fc6:	049d      	lsls	r5, r3, #18
32206fc8:	f100 8756 	bmi.w	32207e78 <_vfprintf_r+0xf00>
32206fcc:	9903      	ldr	r1, [sp, #12]
32206fce:	f443 5300 	orr.w	r3, r3, #8192	@ 0x2000
32206fd2:	f422 5200 	bic.w	r2, r2, #8192	@ 0x2000
32206fd6:	818b      	strh	r3, [r1, #12]
32206fd8:	b21b      	sxth	r3, r3
32206fda:	664a      	str	r2, [r1, #100]	@ 0x64
32206fdc:	071e      	lsls	r6, r3, #28
32206fde:	f140 80bb 	bpl.w	32207158 <_vfprintf_r+0x1e0>
32206fe2:	9a03      	ldr	r2, [sp, #12]
32206fe4:	6912      	ldr	r2, [r2, #16]
32206fe6:	2a00      	cmp	r2, #0
32206fe8:	f000 80b6 	beq.w	32207158 <_vfprintf_r+0x1e0>
32206fec:	f003 021a 	and.w	r2, r3, #26
32206ff0:	2a0a      	cmp	r2, #10
32206ff2:	f000 80c0 	beq.w	32207176 <_vfprintf_r+0x1fe>
32206ff6:	ef80 8e30 	vmov.i64	d8, #0x0000000000000000
32206ffa:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32206ffe:	2300      	movs	r3, #0
32207000:	aa27      	add	r2, sp, #156	@ 0x9c
32207002:	e9cd 3325 	strd	r3, r3, [sp, #148]	@ 0x94
32207006:	9224      	str	r2, [sp, #144]	@ 0x90
32207008:	f24c 2240 	movw	r2, #49728	@ 0xc240
3220700c:	f2c3 2220 	movt	r2, #12832	@ 0x3220
32207010:	930f      	str	r3, [sp, #60]	@ 0x3c
32207012:	920d      	str	r2, [sp, #52]	@ 0x34
32207014:	f64b 72e0 	movw	r2, #49120	@ 0xbfe0
32207018:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220701c:	9314      	str	r3, [sp, #80]	@ 0x50
3220701e:	9213      	str	r2, [sp, #76]	@ 0x4c
32207020:	9317      	str	r3, [sp, #92]	@ 0x5c
32207022:	e9cd 3315 	strd	r3, r3, [sp, #84]	@ 0x54
32207026:	9307      	str	r3, [sp, #28]
32207028:	9d06      	ldr	r5, [sp, #24]
3220702a:	9c0d      	ldr	r4, [sp, #52]	@ 0x34
3220702c:	f8d4 60e4 	ldr.w	r6, [r4, #228]	@ 0xe4
32207030:	f7fd fdd2 	bl	32204bd8 <__locale_mb_cur_max>
32207034:	462a      	mov	r2, r5
32207036:	4603      	mov	r3, r0
32207038:	a91c      	add	r1, sp, #112	@ 0x70
3220703a:	4658      	mov	r0, fp
3220703c:	9700      	str	r7, [sp, #0]
3220703e:	47b0      	blx	r6
32207040:	2800      	cmp	r0, #0
32207042:	f000 80b9 	beq.w	322071b8 <_vfprintf_r+0x240>
32207046:	4603      	mov	r3, r0
32207048:	f2c0 80ae 	blt.w	322071a8 <_vfprintf_r+0x230>
3220704c:	9a1c      	ldr	r2, [sp, #112]	@ 0x70
3220704e:	2a25      	cmp	r2, #37	@ 0x25
32207050:	d001      	beq.n	32207056 <_vfprintf_r+0xde>
32207052:	441d      	add	r5, r3
32207054:	e7ea      	b.n	3220702c <_vfprintf_r+0xb4>
32207056:	9b06      	ldr	r3, [sp, #24]
32207058:	4604      	mov	r4, r0
3220705a:	1aee      	subs	r6, r5, r3
3220705c:	f040 80b0 	bne.w	322071c0 <_vfprintf_r+0x248>
32207060:	786c      	ldrb	r4, [r5, #1]
32207062:	3501      	adds	r5, #1
32207064:	2300      	movs	r3, #0
32207066:	f04f 32ff 	mov.w	r2, #4294967295	@ 0xffffffff
3220706a:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
3220706e:	9308      	str	r3, [sp, #32]
32207070:	9205      	str	r2, [sp, #20]
32207072:	9302      	str	r3, [sp, #8]
32207074:	3501      	adds	r5, #1
32207076:	f1a4 0320 	sub.w	r3, r4, #32
3220707a:	2b5a      	cmp	r3, #90	@ 0x5a
3220707c:	f200 80f8 	bhi.w	32207270 <_vfprintf_r+0x2f8>
32207080:	e8df f013 	tbh	[pc, r3, lsl #1]
32207084:	00f604ab 	.word	0x00f604ab
32207088:	04a400f6 	.word	0x04a400f6
3220708c:	00f600f6 	.word	0x00f600f6
32207090:	048500f6 	.word	0x048500f6
32207094:	00f600f6 	.word	0x00f600f6
32207098:	037d036c 	.word	0x037d036c
3220709c:	037700f6 	.word	0x037700f6
322070a0:	00f604bd 	.word	0x00f604bd
322070a4:	005b04b6 	.word	0x005b04b6
322070a8:	005b005b 	.word	0x005b005b
322070ac:	005b005b 	.word	0x005b005b
322070b0:	005b005b 	.word	0x005b005b
322070b4:	005b005b 	.word	0x005b005b
322070b8:	00f600f6 	.word	0x00f600f6
322070bc:	00f600f6 	.word	0x00f600f6
322070c0:	00f600f6 	.word	0x00f600f6
322070c4:	017100f6 	.word	0x017100f6
322070c8:	02ae00f6 	.word	0x02ae00f6
322070cc:	01710430 	.word	0x01710430
322070d0:	01710171 	.word	0x01710171
322070d4:	00f600f6 	.word	0x00f600f6
322070d8:	00f600f6 	.word	0x00f600f6
322070dc:	00f60429 	.word	0x00f60429
322070e0:	03ef00f6 	.word	0x03ef00f6
322070e4:	00f600f6 	.word	0x00f600f6
322070e8:	02d200f6 	.word	0x02d200f6
322070ec:	046700f6 	.word	0x046700f6
322070f0:	00f600f6 	.word	0x00f600f6
322070f4:	00f60880 	.word	0x00f60880
322070f8:	00f600f6 	.word	0x00f600f6
322070fc:	00f600f6 	.word	0x00f600f6
32207100:	00f600f6 	.word	0x00f600f6
32207104:	017100f6 	.word	0x017100f6
32207108:	02ae00f6 	.word	0x02ae00f6
3220710c:	017101b8 	.word	0x017101b8
32207110:	01710171 	.word	0x01710171
32207114:	01b8045d 	.word	0x01b8045d
32207118:	00f601b2 	.word	0x00f601b2
3220711c:	00f60453 	.word	0x00f60453
32207120:	03ac03e0 	.word	0x03ac03e0
32207124:	01b20382 	.word	0x01b20382
32207128:	02d200f6 	.word	0x02d200f6
3220712c:	031d01b0 	.word	0x031d01b0
32207130:	00f600f6 	.word	0x00f600f6
32207134:	00f608b2 	.word	0x00f608b2
32207138:	01b0      	.short	0x01b0
3220713a:	2200      	movs	r2, #0
3220713c:	f1a4 0330 	sub.w	r3, r4, #48	@ 0x30
32207140:	4611      	mov	r1, r2
32207142:	220a      	movs	r2, #10
32207144:	f815 4b01 	ldrb.w	r4, [r5], #1
32207148:	fb02 3101 	mla	r1, r2, r1, r3
3220714c:	f1a4 0330 	sub.w	r3, r4, #48	@ 0x30
32207150:	2b09      	cmp	r3, #9
32207152:	d9f7      	bls.n	32207144 <_vfprintf_r+0x1cc>
32207154:	9108      	str	r1, [sp, #32]
32207156:	e78e      	b.n	32207076 <_vfprintf_r+0xfe>
32207158:	9d03      	ldr	r5, [sp, #12]
3220715a:	4658      	mov	r0, fp
3220715c:	4629      	mov	r1, r5
3220715e:	f7fc ff0f 	bl	32203f80 <__swsetup_r>
32207162:	2800      	cmp	r0, #0
32207164:	f041 87b0 	bne.w	322090c8 <_vfprintf_r+0x2150>
32207168:	f9b5 300c 	ldrsh.w	r3, [r5, #12]
3220716c:	f003 021a 	and.w	r2, r3, #26
32207170:	2a0a      	cmp	r2, #10
32207172:	f47f af40 	bne.w	32206ff6 <_vfprintf_r+0x7e>
32207176:	9903      	ldr	r1, [sp, #12]
32207178:	f9b1 200e 	ldrsh.w	r2, [r1, #14]
3220717c:	2a00      	cmp	r2, #0
3220717e:	f6ff af3a 	blt.w	32206ff6 <_vfprintf_r+0x7e>
32207182:	6e4a      	ldr	r2, [r1, #100]	@ 0x64
32207184:	07d0      	lsls	r0, r2, #31
32207186:	d402      	bmi.n	3220718e <_vfprintf_r+0x216>
32207188:	059a      	lsls	r2, r3, #22
3220718a:	f141 8370 	bpl.w	3220886e <_vfprintf_r+0x18f6>
3220718e:	9a06      	ldr	r2, [sp, #24]
32207190:	4623      	mov	r3, r4
32207192:	9903      	ldr	r1, [sp, #12]
32207194:	4658      	mov	r0, fp
32207196:	f002 f82f 	bl	322091f8 <__sbprintf>
3220719a:	9007      	str	r0, [sp, #28]
3220719c:	9807      	ldr	r0, [sp, #28]
3220719e:	b051      	add	sp, #324	@ 0x144
322071a0:	ecbd 8b04 	vpop	{d8-d9}
322071a4:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
322071a8:	2208      	movs	r2, #8
322071aa:	2100      	movs	r1, #0
322071ac:	4638      	mov	r0, r7
322071ae:	f7fc ffdb 	bl	32204168 <memset>
322071b2:	2301      	movs	r3, #1
322071b4:	441d      	add	r5, r3
322071b6:	e739      	b.n	3220702c <_vfprintf_r+0xb4>
322071b8:	9b06      	ldr	r3, [sp, #24]
322071ba:	4604      	mov	r4, r0
322071bc:	1aee      	subs	r6, r5, r3
322071be:	d012      	beq.n	322071e6 <_vfprintf_r+0x26e>
322071c0:	9b06      	ldr	r3, [sp, #24]
322071c2:	e9c9 3600 	strd	r3, r6, [r9]
322071c6:	f109 0908 	add.w	r9, r9, #8
322071ca:	9b25      	ldr	r3, [sp, #148]	@ 0x94
322071cc:	9926      	ldr	r1, [sp, #152]	@ 0x98
322071ce:	3301      	adds	r3, #1
322071d0:	9325      	str	r3, [sp, #148]	@ 0x94
322071d2:	4431      	add	r1, r6
322071d4:	2b07      	cmp	r3, #7
322071d6:	9126      	str	r1, [sp, #152]	@ 0x98
322071d8:	dc0f      	bgt.n	322071fa <_vfprintf_r+0x282>
322071da:	9b07      	ldr	r3, [sp, #28]
322071dc:	4433      	add	r3, r6
322071de:	9307      	str	r3, [sp, #28]
322071e0:	2c00      	cmp	r4, #0
322071e2:	f47f af3d 	bne.w	32207060 <_vfprintf_r+0xe8>
322071e6:	9b26      	ldr	r3, [sp, #152]	@ 0x98
322071e8:	2b00      	cmp	r3, #0
322071ea:	f041 8336 	bne.w	3220885a <_vfprintf_r+0x18e2>
322071ee:	9b03      	ldr	r3, [sp, #12]
322071f0:	2200      	movs	r2, #0
322071f2:	9225      	str	r2, [sp, #148]	@ 0x94
322071f4:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
322071f8:	e019      	b.n	3220722e <_vfprintf_r+0x2b6>
322071fa:	9903      	ldr	r1, [sp, #12]
322071fc:	aa24      	add	r2, sp, #144	@ 0x90
322071fe:	4658      	mov	r0, fp
32207200:	f7fc f98a 	bl	32203518 <__sprint_r>
32207204:	b980      	cbnz	r0, 32207228 <_vfprintf_r+0x2b0>
32207206:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
3220720a:	e7e6      	b.n	322071da <_vfprintf_r+0x262>
3220720c:	9903      	ldr	r1, [sp, #12]
3220720e:	aa24      	add	r2, sp, #144	@ 0x90
32207210:	4658      	mov	r0, fp
32207212:	f7fc f981 	bl	32203518 <__sprint_r>
32207216:	2800      	cmp	r0, #0
32207218:	f000 809a 	beq.w	32207350 <_vfprintf_r+0x3d8>
3220721c:	9b09      	ldr	r3, [sp, #36]	@ 0x24
3220721e:	b11b      	cbz	r3, 32207228 <_vfprintf_r+0x2b0>
32207220:	9909      	ldr	r1, [sp, #36]	@ 0x24
32207222:	4658      	mov	r0, fp
32207224:	f7fe fb60 	bl	322058e8 <_free_r>
32207228:	9b03      	ldr	r3, [sp, #12]
3220722a:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
3220722e:	9a03      	ldr	r2, [sp, #12]
32207230:	6e52      	ldr	r2, [r2, #100]	@ 0x64
32207232:	07d4      	lsls	r4, r2, #31
32207234:	f140 80cc 	bpl.w	322073d0 <_vfprintf_r+0x458>
32207238:	065a      	lsls	r2, r3, #25
3220723a:	f100 823c 	bmi.w	322076b6 <_vfprintf_r+0x73e>
3220723e:	9807      	ldr	r0, [sp, #28]
32207240:	b051      	add	sp, #324	@ 0x144
32207242:	ecbd 8b04 	vpop	{d8-d9}
32207246:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220724a:	0599      	lsls	r1, r3, #22
3220724c:	f140 8223 	bpl.w	32207696 <_vfprintf_r+0x71e>
32207250:	049e      	lsls	r6, r3, #18
32207252:	f57f aebb 	bpl.w	32206fcc <_vfprintf_r+0x54>
32207256:	0495      	lsls	r5, r2, #18
32207258:	f57f aec0 	bpl.w	32206fdc <_vfprintf_r+0x64>
3220725c:	9b03      	ldr	r3, [sp, #12]
3220725e:	899b      	ldrh	r3, [r3, #12]
32207260:	059f      	lsls	r7, r3, #22
32207262:	f100 8228 	bmi.w	322076b6 <_vfprintf_r+0x73e>
32207266:	9b03      	ldr	r3, [sp, #12]
32207268:	6d98      	ldr	r0, [r3, #88]	@ 0x58
3220726a:	f7fd fd7d 	bl	32204d68 <__retarget_lock_release_recursive>
3220726e:	e222      	b.n	322076b6 <_vfprintf_r+0x73e>
32207270:	9506      	str	r5, [sp, #24]
32207272:	2c00      	cmp	r4, #0
32207274:	d0b7      	beq.n	322071e6 <_vfprintf_r+0x26e>
32207276:	ad37      	add	r5, sp, #220	@ 0xdc
32207278:	2300      	movs	r3, #0
3220727a:	2201      	movs	r2, #1
3220727c:	f88d 40dc 	strb.w	r4, [sp, #220]	@ 0xdc
32207280:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32207284:	9309      	str	r3, [sp, #36]	@ 0x24
32207286:	920b      	str	r2, [sp, #44]	@ 0x2c
32207288:	9305      	str	r3, [sp, #20]
3220728a:	9310      	str	r3, [sp, #64]	@ 0x40
3220728c:	930e      	str	r3, [sp, #56]	@ 0x38
3220728e:	930c      	str	r3, [sp, #48]	@ 0x30
32207290:	9204      	str	r2, [sp, #16]
32207292:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32207294:	9b02      	ldr	r3, [sp, #8]
32207296:	4696      	mov	lr, r2
32207298:	f013 0a84 	ands.w	sl, r3, #132	@ 0x84
3220729c:	f000 80e5 	beq.w	3220746a <_vfprintf_r+0x4f2>
322072a0:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
322072a4:	b31b      	cbz	r3, 322072ee <_vfprintf_r+0x376>
322072a6:	9825      	ldr	r0, [sp, #148]	@ 0x94
322072a8:	2600      	movs	r6, #0
322072aa:	3001      	adds	r0, #1
322072ac:	2301      	movs	r3, #1
322072ae:	3201      	adds	r2, #1
322072b0:	f8c9 3004 	str.w	r3, [r9, #4]
322072b4:	2807      	cmp	r0, #7
322072b6:	f10d 0367 	add.w	r3, sp, #103	@ 0x67
322072ba:	f109 0908 	add.w	r9, r9, #8
322072be:	f849 3c08 	str.w	r3, [r9, #-8]
322072c2:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
322072c6:	f300 84c3 	bgt.w	32207c50 <_vfprintf_r+0xcd8>
322072ca:	9825      	ldr	r0, [sp, #148]	@ 0x94
322072cc:	b17e      	cbz	r6, 322072ee <_vfprintf_r+0x376>
322072ce:	3001      	adds	r0, #1
322072d0:	ab1a      	add	r3, sp, #104	@ 0x68
322072d2:	3202      	adds	r2, #2
322072d4:	f8c9 3000 	str.w	r3, [r9]
322072d8:	2807      	cmp	r0, #7
322072da:	f04f 0302 	mov.w	r3, #2
322072de:	f109 0908 	add.w	r9, r9, #8
322072e2:	f849 3c04 	str.w	r3, [r9, #-4]
322072e6:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
322072ea:	f300 84a4 	bgt.w	32207c36 <_vfprintf_r+0xcbe>
322072ee:	f1ba 0f80 	cmp.w	sl, #128	@ 0x80
322072f2:	f000 83a1 	beq.w	32207a38 <_vfprintf_r+0xac0>
322072f6:	9b05      	ldr	r3, [sp, #20]
322072f8:	990b      	ldr	r1, [sp, #44]	@ 0x2c
322072fa:	1a5e      	subs	r6, r3, r1
322072fc:	2e00      	cmp	r6, #0
322072fe:	f300 80c6 	bgt.w	3220748e <_vfprintf_r+0x516>
32207302:	9b02      	ldr	r3, [sp, #8]
32207304:	05de      	lsls	r6, r3, #23
32207306:	f100 810f 	bmi.w	32207528 <_vfprintf_r+0x5b0>
3220730a:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
3220730c:	f8c9 3004 	str.w	r3, [r9, #4]
32207310:	441a      	add	r2, r3
32207312:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207314:	f8c9 5000 	str.w	r5, [r9]
32207318:	3301      	adds	r3, #1
3220731a:	9226      	str	r2, [sp, #152]	@ 0x98
3220731c:	2b07      	cmp	r3, #7
3220731e:	9325      	str	r3, [sp, #148]	@ 0x94
32207320:	f300 842b 	bgt.w	32207b7a <_vfprintf_r+0xc02>
32207324:	f109 0908 	add.w	r9, r9, #8
32207328:	9b02      	ldr	r3, [sp, #8]
3220732a:	075d      	lsls	r5, r3, #29
3220732c:	d505      	bpl.n	3220733a <_vfprintf_r+0x3c2>
3220732e:	9b08      	ldr	r3, [sp, #32]
32207330:	9904      	ldr	r1, [sp, #16]
32207332:	1a5c      	subs	r4, r3, r1
32207334:	2c00      	cmp	r4, #0
32207336:	f300 8498 	bgt.w	32207c6a <_vfprintf_r+0xcf2>
3220733a:	9b08      	ldr	r3, [sp, #32]
3220733c:	9904      	ldr	r1, [sp, #16]
3220733e:	428b      	cmp	r3, r1
32207340:	bfb8      	it	lt
32207342:	460b      	movlt	r3, r1
32207344:	9907      	ldr	r1, [sp, #28]
32207346:	4419      	add	r1, r3
32207348:	9107      	str	r1, [sp, #28]
3220734a:	2a00      	cmp	r2, #0
3220734c:	f47f af5e 	bne.w	3220720c <_vfprintf_r+0x294>
32207350:	2300      	movs	r3, #0
32207352:	9325      	str	r3, [sp, #148]	@ 0x94
32207354:	9b09      	ldr	r3, [sp, #36]	@ 0x24
32207356:	b11b      	cbz	r3, 32207360 <_vfprintf_r+0x3e8>
32207358:	9909      	ldr	r1, [sp, #36]	@ 0x24
3220735a:	4658      	mov	r0, fp
3220735c:	f7fe fac4 	bl	322058e8 <_free_r>
32207360:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32207364:	e660      	b.n	32207028 <_vfprintf_r+0xb0>
32207366:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32207368:	eddf 0bad 	vldr	d16, [pc, #692]	@ 32207620 <_vfprintf_r+0x6a8>
3220736c:	3307      	adds	r3, #7
3220736e:	9506      	str	r5, [sp, #24]
32207370:	f023 0307 	bic.w	r3, r3, #7
32207374:	ecb3 8b02 	vldmia	r3!, {d8}
32207378:	eef0 1bc8 	vabs.f64	d17, d8
3220737c:	930a      	str	r3, [sp, #40]	@ 0x28
3220737e:	eef4 1b60 	vcmp.f64	d17, d16
32207382:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32207386:	f340 8606 	ble.w	32207f96 <_vfprintf_r+0x101e>
3220738a:	eeb5 8bc0 	vcmpe.f64	d8, #0.0
3220738e:	9b02      	ldr	r3, [sp, #8]
32207390:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32207394:	9302      	str	r3, [sp, #8]
32207396:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220739a:	f101 8314 	bmi.w	322089c6 <_vfprintf_r+0x1a4e>
3220739e:	f89d 2067 	ldrb.w	r2, [sp, #103]	@ 0x67
322073a2:	f64b 3560 	movw	r5, #47968	@ 0xbb60
322073a6:	f2c3 2520 	movt	r5, #12832	@ 0x3220
322073aa:	f64b 3364 	movw	r3, #47972	@ 0xbb64
322073ae:	f2c3 2320 	movt	r3, #12832	@ 0x3220
322073b2:	2c47      	cmp	r4, #71	@ 0x47
322073b4:	bfc8      	it	gt
322073b6:	461d      	movgt	r5, r3
322073b8:	2a00      	cmp	r2, #0
322073ba:	f041 8599 	bne.w	32208ef0 <_vfprintf_r+0x1f78>
322073be:	2103      	movs	r1, #3
322073c0:	9209      	str	r2, [sp, #36]	@ 0x24
322073c2:	910b      	str	r1, [sp, #44]	@ 0x2c
322073c4:	e9cd 1204 	strd	r1, r2, [sp, #16]
322073c8:	9210      	str	r2, [sp, #64]	@ 0x40
322073ca:	920e      	str	r2, [sp, #56]	@ 0x38
322073cc:	920c      	str	r2, [sp, #48]	@ 0x30
322073ce:	e760      	b.n	32207292 <_vfprintf_r+0x31a>
322073d0:	0599      	lsls	r1, r3, #22
322073d2:	f53f af31 	bmi.w	32207238 <_vfprintf_r+0x2c0>
322073d6:	9c03      	ldr	r4, [sp, #12]
322073d8:	6da0      	ldr	r0, [r4, #88]	@ 0x58
322073da:	f7fd fcc5 	bl	32204d68 <__retarget_lock_release_recursive>
322073de:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
322073e2:	e729      	b.n	32207238 <_vfprintf_r+0x2c0>
322073e4:	782c      	ldrb	r4, [r5, #0]
322073e6:	e645      	b.n	32207074 <_vfprintf_r+0xfc>
322073e8:	9b02      	ldr	r3, [sp, #8]
322073ea:	782c      	ldrb	r4, [r5, #0]
322073ec:	f043 0320 	orr.w	r3, r3, #32
322073f0:	9302      	str	r3, [sp, #8]
322073f2:	e63f      	b.n	32207074 <_vfprintf_r+0xfc>
322073f4:	9a02      	ldr	r2, [sp, #8]
322073f6:	9506      	str	r5, [sp, #24]
322073f8:	0690      	lsls	r0, r2, #26
322073fa:	f140 8693 	bpl.w	32208124 <_vfprintf_r+0x11ac>
322073fe:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32207400:	9202      	str	r2, [sp, #8]
32207402:	3307      	adds	r3, #7
32207404:	f023 0307 	bic.w	r3, r3, #7
32207408:	461a      	mov	r2, r3
3220740a:	685b      	ldr	r3, [r3, #4]
3220740c:	f852 6b08 	ldr.w	r6, [r2], #8
32207410:	4698      	mov	r8, r3
32207412:	920a      	str	r2, [sp, #40]	@ 0x28
32207414:	2b00      	cmp	r3, #0
32207416:	f2c0 8278 	blt.w	3220790a <_vfprintf_r+0x992>
3220741a:	9a05      	ldr	r2, [sp, #20]
3220741c:	2a00      	cmp	r2, #0
3220741e:	f2c0 8164 	blt.w	322076ea <_vfprintf_r+0x772>
32207422:	9b02      	ldr	r3, [sp, #8]
32207424:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32207428:	9302      	str	r3, [sp, #8]
3220742a:	ea46 0308 	orr.w	r3, r6, r8
3220742e:	2b00      	cmp	r3, #0
32207430:	bf08      	it	eq
32207432:	2a00      	cmpeq	r2, #0
32207434:	bf18      	it	ne
32207436:	2301      	movne	r3, #1
32207438:	bf08      	it	eq
3220743a:	2300      	moveq	r3, #0
3220743c:	f040 8155 	bne.w	322076ea <_vfprintf_r+0x772>
32207440:	461a      	mov	r2, r3
32207442:	9309      	str	r3, [sp, #36]	@ 0x24
32207444:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32207448:	ad50      	add	r5, sp, #320	@ 0x140
3220744a:	9205      	str	r2, [sp, #20]
3220744c:	1e19      	subs	r1, r3, #0
3220744e:	920b      	str	r2, [sp, #44]	@ 0x2c
32207450:	9b02      	ldr	r3, [sp, #8]
32207452:	bf18      	it	ne
32207454:	2101      	movne	r1, #1
32207456:	9210      	str	r2, [sp, #64]	@ 0x40
32207458:	920e      	str	r2, [sp, #56]	@ 0x38
3220745a:	f013 0a84 	ands.w	sl, r3, #132	@ 0x84
3220745e:	920c      	str	r2, [sp, #48]	@ 0x30
32207460:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32207462:	9104      	str	r1, [sp, #16]
32207464:	4696      	mov	lr, r2
32207466:	f47f af1b 	bne.w	322072a0 <_vfprintf_r+0x328>
3220746a:	9b08      	ldr	r3, [sp, #32]
3220746c:	9904      	ldr	r1, [sp, #16]
3220746e:	1a5e      	subs	r6, r3, r1
32207470:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207472:	2e00      	cmp	r6, #0
32207474:	f300 8396 	bgt.w	32207ba4 <_vfprintf_r+0xc2c>
32207478:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
3220747c:	2b00      	cmp	r3, #0
3220747e:	f47f af12 	bne.w	322072a6 <_vfprintf_r+0x32e>
32207482:	9b05      	ldr	r3, [sp, #20]
32207484:	990b      	ldr	r1, [sp, #44]	@ 0x2c
32207486:	1a5e      	subs	r6, r3, r1
32207488:	2e00      	cmp	r6, #0
3220748a:	f77f af3a 	ble.w	32207302 <_vfprintf_r+0x38a>
3220748e:	f64b 7ae0 	movw	sl, #49120	@ 0xbfe0
32207492:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32207496:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207498:	2e10      	cmp	r6, #16
3220749a:	dd29      	ble.n	322074f0 <_vfprintf_r+0x578>
3220749c:	9813      	ldr	r0, [sp, #76]	@ 0x4c
3220749e:	46cc      	mov	ip, r9
322074a0:	f04f 0810 	mov.w	r8, #16
322074a4:	46a9      	mov	r9, r5
322074a6:	4682      	mov	sl, r0
322074a8:	4625      	mov	r5, r4
322074aa:	4619      	mov	r1, r3
322074ac:	4604      	mov	r4, r0
322074ae:	e002      	b.n	322074b6 <_vfprintf_r+0x53e>
322074b0:	3e10      	subs	r6, #16
322074b2:	2e10      	cmp	r6, #16
322074b4:	dd18      	ble.n	322074e8 <_vfprintf_r+0x570>
322074b6:	3101      	adds	r1, #1
322074b8:	3210      	adds	r2, #16
322074ba:	e9cc 4800 	strd	r4, r8, [ip]
322074be:	2907      	cmp	r1, #7
322074c0:	f10c 0c08 	add.w	ip, ip, #8
322074c4:	e9cd 1225 	strd	r1, r2, [sp, #148]	@ 0x94
322074c8:	ddf2      	ble.n	322074b0 <_vfprintf_r+0x538>
322074ca:	9903      	ldr	r1, [sp, #12]
322074cc:	aa24      	add	r2, sp, #144	@ 0x90
322074ce:	4658      	mov	r0, fp
322074d0:	f7fc f822 	bl	32203518 <__sprint_r>
322074d4:	f10d 0c9c 	add.w	ip, sp, #156	@ 0x9c
322074d8:	2800      	cmp	r0, #0
322074da:	f47f ae9f 	bne.w	3220721c <_vfprintf_r+0x2a4>
322074de:	3e10      	subs	r6, #16
322074e0:	e9dd 1225 	ldrd	r1, r2, [sp, #148]	@ 0x94
322074e4:	2e10      	cmp	r6, #16
322074e6:	dce6      	bgt.n	322074b6 <_vfprintf_r+0x53e>
322074e8:	462c      	mov	r4, r5
322074ea:	460b      	mov	r3, r1
322074ec:	464d      	mov	r5, r9
322074ee:	46e1      	mov	r9, ip
322074f0:	3301      	adds	r3, #1
322074f2:	4432      	add	r2, r6
322074f4:	f8c9 a000 	str.w	sl, [r9]
322074f8:	2b07      	cmp	r3, #7
322074fa:	f8c9 6004 	str.w	r6, [r9, #4]
322074fe:	f109 0908 	add.w	r9, r9, #8
32207502:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207506:	f77f aefc 	ble.w	32207302 <_vfprintf_r+0x38a>
3220750a:	9903      	ldr	r1, [sp, #12]
3220750c:	aa24      	add	r2, sp, #144	@ 0x90
3220750e:	4658      	mov	r0, fp
32207510:	f7fc f802 	bl	32203518 <__sprint_r>
32207514:	2800      	cmp	r0, #0
32207516:	f47f ae81 	bne.w	3220721c <_vfprintf_r+0x2a4>
3220751a:	9b02      	ldr	r3, [sp, #8]
3220751c:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32207520:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32207522:	05de      	lsls	r6, r3, #23
32207524:	f57f aef1 	bpl.w	3220730a <_vfprintf_r+0x392>
32207528:	2c65      	cmp	r4, #101	@ 0x65
3220752a:	f340 82e5 	ble.w	32207af8 <_vfprintf_r+0xb80>
3220752e:	eeb5 8b40 	vcmp.f64	d8, #0.0
32207532:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32207536:	f040 83dc 	bne.w	32207cf2 <_vfprintf_r+0xd7a>
3220753a:	9b25      	ldr	r3, [sp, #148]	@ 0x94
3220753c:	2101      	movs	r1, #1
3220753e:	3201      	adds	r2, #1
32207540:	f8c9 1004 	str.w	r1, [r9, #4]
32207544:	3301      	adds	r3, #1
32207546:	f64b 3170 	movw	r1, #47984	@ 0xbb70
3220754a:	f2c3 2120 	movt	r1, #12832	@ 0x3220
3220754e:	f109 0908 	add.w	r9, r9, #8
32207552:	f849 1c08 	str.w	r1, [r9, #-8]
32207556:	2b07      	cmp	r3, #7
32207558:	9226      	str	r2, [sp, #152]	@ 0x98
3220755a:	9325      	str	r3, [sp, #148]	@ 0x94
3220755c:	f300 8724 	bgt.w	322083a8 <_vfprintf_r+0x1430>
32207560:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32207562:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32207564:	428b      	cmp	r3, r1
32207566:	f280 848b 	bge.w	32207e80 <_vfprintf_r+0xf08>
3220756a:	9b11      	ldr	r3, [sp, #68]	@ 0x44
3220756c:	9912      	ldr	r1, [sp, #72]	@ 0x48
3220756e:	441a      	add	r2, r3
32207570:	e9c9 1300 	strd	r1, r3, [r9]
32207574:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207576:	f109 0908 	add.w	r9, r9, #8
3220757a:	9226      	str	r2, [sp, #152]	@ 0x98
3220757c:	3301      	adds	r3, #1
3220757e:	9325      	str	r3, [sp, #148]	@ 0x94
32207580:	2b07      	cmp	r3, #7
32207582:	f300 865b 	bgt.w	3220823c <_vfprintf_r+0x12c4>
32207586:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32207588:	1e5c      	subs	r4, r3, #1
3220758a:	2c00      	cmp	r4, #0
3220758c:	f77f aecc 	ble.w	32207328 <_vfprintf_r+0x3b0>
32207590:	f64b 7ae0 	movw	sl, #49120	@ 0xbfe0
32207594:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32207598:	9b25      	ldr	r3, [sp, #148]	@ 0x94
3220759a:	2510      	movs	r5, #16
3220759c:	f8dd 800c 	ldr.w	r8, [sp, #12]
322075a0:	4656      	mov	r6, sl
322075a2:	2c10      	cmp	r4, #16
322075a4:	dc05      	bgt.n	322075b2 <_vfprintf_r+0x63a>
322075a6:	f000 bf6e 	b.w	32208486 <_vfprintf_r+0x150e>
322075aa:	3c10      	subs	r4, #16
322075ac:	2c10      	cmp	r4, #16
322075ae:	f340 8769 	ble.w	32208484 <_vfprintf_r+0x150c>
322075b2:	3301      	adds	r3, #1
322075b4:	3210      	adds	r2, #16
322075b6:	e9c9 6500 	strd	r6, r5, [r9]
322075ba:	2b07      	cmp	r3, #7
322075bc:	f109 0908 	add.w	r9, r9, #8
322075c0:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
322075c4:	ddf1      	ble.n	322075aa <_vfprintf_r+0x632>
322075c6:	aa24      	add	r2, sp, #144	@ 0x90
322075c8:	4641      	mov	r1, r8
322075ca:	4658      	mov	r0, fp
322075cc:	f7fb ffa4 	bl	32203518 <__sprint_r>
322075d0:	2800      	cmp	r0, #0
322075d2:	f47f ae23 	bne.w	3220721c <_vfprintf_r+0x2a4>
322075d6:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
322075da:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
322075de:	e7e4      	b.n	322075aa <_vfprintf_r+0x632>
322075e0:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322075e2:	2c43      	cmp	r4, #67	@ 0x43
322075e4:	9506      	str	r5, [sp, #24]
322075e6:	f103 0604 	add.w	r6, r3, #4
322075ea:	f000 8656 	beq.w	3220829a <_vfprintf_r+0x1322>
322075ee:	9b02      	ldr	r3, [sp, #8]
322075f0:	06db      	lsls	r3, r3, #27
322075f2:	f100 8652 	bmi.w	3220829a <_vfprintf_r+0x1322>
322075f6:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322075f8:	ad37      	add	r5, sp, #220	@ 0xdc
322075fa:	681b      	ldr	r3, [r3, #0]
322075fc:	f88d 30dc 	strb.w	r3, [sp, #220]	@ 0xdc
32207600:	2301      	movs	r3, #1
32207602:	9304      	str	r3, [sp, #16]
32207604:	930b      	str	r3, [sp, #44]	@ 0x2c
32207606:	2300      	movs	r3, #0
32207608:	960a      	str	r6, [sp, #40]	@ 0x28
3220760a:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
3220760e:	9309      	str	r3, [sp, #36]	@ 0x24
32207610:	9305      	str	r3, [sp, #20]
32207612:	9310      	str	r3, [sp, #64]	@ 0x40
32207614:	930e      	str	r3, [sp, #56]	@ 0x38
32207616:	930c      	str	r3, [sp, #48]	@ 0x30
32207618:	e63b      	b.n	32207292 <_vfprintf_r+0x31a>
3220761a:	bf00      	nop
3220761c:	f3af 8000 	nop.w
32207620:	ffffffff 	.word	0xffffffff
32207624:	7fefffff 	.word	0x7fefffff
32207628:	f8dd 8028 	ldr.w	r8, [sp, #40]	@ 0x28
3220762c:	2300      	movs	r3, #0
3220762e:	9506      	str	r5, [sp, #24]
32207630:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32207634:	f858 5b04 	ldr.w	r5, [r8], #4
32207638:	2d00      	cmp	r5, #0
3220763a:	f000 861a 	beq.w	32208272 <_vfprintf_r+0x12fa>
3220763e:	2c53      	cmp	r4, #83	@ 0x53
32207640:	f000 86bf 	beq.w	322083c2 <_vfprintf_r+0x144a>
32207644:	9b02      	ldr	r3, [sp, #8]
32207646:	f013 0310 	ands.w	r3, r3, #16
3220764a:	930c      	str	r3, [sp, #48]	@ 0x30
3220764c:	f040 86b9 	bne.w	322083c2 <_vfprintf_r+0x144a>
32207650:	9b05      	ldr	r3, [sp, #20]
32207652:	2b00      	cmp	r3, #0
32207654:	f2c1 80eb 	blt.w	3220882e <_vfprintf_r+0x18b6>
32207658:	461a      	mov	r2, r3
3220765a:	990c      	ldr	r1, [sp, #48]	@ 0x30
3220765c:	4628      	mov	r0, r5
3220765e:	f7fd fd67 	bl	32205130 <memchr>
32207662:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32207666:	9009      	str	r0, [sp, #36]	@ 0x24
32207668:	2800      	cmp	r0, #0
3220766a:	f001 83f9 	beq.w	32208e60 <_vfprintf_r+0x1ee8>
3220766e:	9a09      	ldr	r2, [sp, #36]	@ 0x24
32207670:	1b52      	subs	r2, r2, r5
32207672:	920b      	str	r2, [sp, #44]	@ 0x2c
32207674:	ea22 72e2 	bic.w	r2, r2, r2, asr #31
32207678:	9204      	str	r2, [sp, #16]
3220767a:	2b00      	cmp	r3, #0
3220767c:	f001 80e3 	beq.w	32208846 <_vfprintf_r+0x18ce>
32207680:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32207682:	3201      	adds	r2, #1
32207684:	2473      	movs	r4, #115	@ 0x73
32207686:	9204      	str	r2, [sp, #16]
32207688:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
3220768c:	9305      	str	r3, [sp, #20]
3220768e:	9310      	str	r3, [sp, #64]	@ 0x40
32207690:	930e      	str	r3, [sp, #56]	@ 0x38
32207692:	9309      	str	r3, [sp, #36]	@ 0x24
32207694:	e5fd      	b.n	32207292 <_vfprintf_r+0x31a>
32207696:	9d03      	ldr	r5, [sp, #12]
32207698:	6da8      	ldr	r0, [r5, #88]	@ 0x58
3220769a:	f7fd fb5d 	bl	32204d58 <__retarget_lock_acquire_recursive>
3220769e:	f9b5 300c 	ldrsh.w	r3, [r5, #12]
322076a2:	6e6a      	ldr	r2, [r5, #100]	@ 0x64
322076a4:	0498      	lsls	r0, r3, #18
322076a6:	f57f ac91 	bpl.w	32206fcc <_vfprintf_r+0x54>
322076aa:	0491      	lsls	r1, r2, #18
322076ac:	f57f ac96 	bpl.w	32206fdc <_vfprintf_r+0x64>
322076b0:	07d3      	lsls	r3, r2, #31
322076b2:	f57f add3 	bpl.w	3220725c <_vfprintf_r+0x2e4>
322076b6:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
322076ba:	9307      	str	r3, [sp, #28]
322076bc:	e5bf      	b.n	3220723e <_vfprintf_r+0x2c6>
322076be:	9a02      	ldr	r2, [sp, #8]
322076c0:	9506      	str	r5, [sp, #24]
322076c2:	0693      	lsls	r3, r2, #26
322076c4:	f140 8540 	bpl.w	32208148 <_vfprintf_r+0x11d0>
322076c8:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322076ca:	2100      	movs	r1, #0
322076cc:	f88d 1067 	strb.w	r1, [sp, #103]	@ 0x67
322076d0:	3307      	adds	r3, #7
322076d2:	f023 0307 	bic.w	r3, r3, #7
322076d6:	f8d3 8004 	ldr.w	r8, [r3, #4]
322076da:	f853 6b08 	ldr.w	r6, [r3], #8
322076de:	930a      	str	r3, [sp, #40]	@ 0x28
322076e0:	9b05      	ldr	r3, [sp, #20]
322076e2:	428b      	cmp	r3, r1
322076e4:	f280 83e0 	bge.w	32207ea8 <_vfprintf_r+0xf30>
322076e8:	9202      	str	r2, [sp, #8]
322076ea:	2e0a      	cmp	r6, #10
322076ec:	f178 0300 	sbcs.w	r3, r8, #0
322076f0:	f080 86d6 	bcs.w	322084a0 <_vfprintf_r+0x1528>
322076f4:	9b05      	ldr	r3, [sp, #20]
322076f6:	f20d 153f 	addw	r5, sp, #319	@ 0x13f
322076fa:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
322076fe:	3630      	adds	r6, #48	@ 0x30
32207700:	2b01      	cmp	r3, #1
32207702:	f04f 0e00 	mov.w	lr, #0
32207706:	bfb8      	it	lt
32207708:	2301      	movlt	r3, #1
3220770a:	f88d 613f 	strb.w	r6, [sp, #319]	@ 0x13f
3220770e:	9304      	str	r3, [sp, #16]
32207710:	2301      	movs	r3, #1
32207712:	e9cd 3e0b 	strd	r3, lr, [sp, #44]	@ 0x2c
32207716:	2300      	movs	r3, #0
32207718:	9309      	str	r3, [sp, #36]	@ 0x24
3220771a:	f1bc 0f00 	cmp.w	ip, #0
3220771e:	d002      	beq.n	32207726 <_vfprintf_r+0x7ae>
32207720:	9b04      	ldr	r3, [sp, #16]
32207722:	3301      	adds	r3, #1
32207724:	9304      	str	r3, [sp, #16]
32207726:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32207728:	2b00      	cmp	r3, #0
3220772a:	f001 8535 	beq.w	32209198 <_vfprintf_r+0x2220>
3220772e:	e9dd 0225 	ldrd	r0, r2, [sp, #148]	@ 0x94
32207732:	9b04      	ldr	r3, [sp, #16]
32207734:	9e02      	ldr	r6, [sp, #8]
32207736:	4696      	mov	lr, r2
32207738:	3302      	adds	r3, #2
3220773a:	9304      	str	r3, [sp, #16]
3220773c:	f016 0a84 	ands.w	sl, r6, #132	@ 0x84
32207740:	4603      	mov	r3, r0
32207742:	f000 81c7 	beq.w	32207ad4 <_vfprintf_r+0xb5c>
32207746:	f1bc 0f00 	cmp.w	ip, #0
3220774a:	f040 82cb 	bne.w	32207ce4 <_vfprintf_r+0xd6c>
3220774e:	f8cd c040 	str.w	ip, [sp, #64]	@ 0x40
32207752:	f8cd c038 	str.w	ip, [sp, #56]	@ 0x38
32207756:	f8cd c030 	str.w	ip, [sp, #48]	@ 0x30
3220775a:	e5b8      	b.n	322072ce <_vfprintf_r+0x356>
3220775c:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
3220775e:	f853 2b04 	ldr.w	r2, [r3], #4
32207762:	9208      	str	r2, [sp, #32]
32207764:	2a00      	cmp	r2, #0
32207766:	f280 8391 	bge.w	32207e8c <_vfprintf_r+0xf14>
3220776a:	9a08      	ldr	r2, [sp, #32]
3220776c:	930a      	str	r3, [sp, #40]	@ 0x28
3220776e:	4252      	negs	r2, r2
32207770:	9208      	str	r2, [sp, #32]
32207772:	9b02      	ldr	r3, [sp, #8]
32207774:	782c      	ldrb	r4, [r5, #0]
32207776:	f043 0304 	orr.w	r3, r3, #4
3220777a:	9302      	str	r3, [sp, #8]
3220777c:	e47a      	b.n	32207074 <_vfprintf_r+0xfc>
3220777e:	232b      	movs	r3, #43	@ 0x2b
32207780:	782c      	ldrb	r4, [r5, #0]
32207782:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32207786:	e475      	b.n	32207074 <_vfprintf_r+0xfc>
32207788:	9506      	str	r5, [sp, #24]
3220778a:	2200      	movs	r2, #0
3220778c:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
3220778e:	f647 0330 	movw	r3, #30768	@ 0x7830
32207792:	9805      	ldr	r0, [sp, #20]
32207794:	f8ad 3068 	strh.w	r3, [sp, #104]	@ 0x68
32207798:	f855 1b04 	ldr.w	r1, [r5], #4
3220779c:	4290      	cmp	r0, r2
3220779e:	f88d 2067 	strb.w	r2, [sp, #103]	@ 0x67
322077a2:	460b      	mov	r3, r1
322077a4:	f2c0 8526 	blt.w	322081f4 <_vfprintf_r+0x127c>
322077a8:	9802      	ldr	r0, [sp, #8]
322077aa:	f020 0080 	bic.w	r0, r0, #128	@ 0x80
322077ae:	f040 0002 	orr.w	r0, r0, #2
322077b2:	9002      	str	r0, [sp, #8]
322077b4:	9805      	ldr	r0, [sp, #20]
322077b6:	2900      	cmp	r1, #0
322077b8:	bf08      	it	eq
322077ba:	2800      	cmpeq	r0, #0
322077bc:	f000 86fe 	beq.w	322085bc <_vfprintf_r+0x1644>
322077c0:	f64b 2004 	movw	r0, #47620	@ 0xba04
322077c4:	f2c3 2020 	movt	r0, #12832	@ 0x3220
322077c8:	2478      	movs	r4, #120	@ 0x78
322077ca:	9902      	ldr	r1, [sp, #8]
322077cc:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
322077d0:	f001 0102 	and.w	r1, r1, #2
322077d4:	950a      	str	r5, [sp, #40]	@ 0x28
322077d6:	910c      	str	r1, [sp, #48]	@ 0x30
322077d8:	f000 bd19 	b.w	3220820e <_vfprintf_r+0x1296>
322077dc:	9802      	ldr	r0, [sp, #8]
322077de:	9506      	str	r5, [sp, #24]
322077e0:	0682      	lsls	r2, r0, #26
322077e2:	f140 83b6 	bpl.w	32207f52 <_vfprintf_r+0xfda>
322077e6:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322077e8:	3307      	adds	r3, #7
322077ea:	f023 0307 	bic.w	r3, r3, #7
322077ee:	6859      	ldr	r1, [r3, #4]
322077f0:	f853 2b08 	ldr.w	r2, [r3], #8
322077f4:	930a      	str	r3, [sp, #40]	@ 0x28
322077f6:	2300      	movs	r3, #0
322077f8:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
322077fc:	9b05      	ldr	r3, [sp, #20]
322077fe:	2b00      	cmp	r3, #0
32207800:	db41      	blt.n	32207886 <_vfprintf_r+0x90e>
32207802:	9b05      	ldr	r3, [sp, #20]
32207804:	1e1d      	subs	r5, r3, #0
32207806:	bf18      	it	ne
32207808:	2501      	movne	r5, #1
3220780a:	ea52 0301 	orrs.w	r3, r2, r1
3220780e:	f045 0301 	orr.w	r3, r5, #1
32207812:	bf08      	it	eq
32207814:	462b      	moveq	r3, r5
32207816:	f420 6590 	bic.w	r5, r0, #1152	@ 0x480
3220781a:	9502      	str	r5, [sp, #8]
3220781c:	2b00      	cmp	r3, #0
3220781e:	d135      	bne.n	3220788c <_vfprintf_r+0x914>
32207820:	f010 0201 	ands.w	r2, r0, #1
32207824:	9204      	str	r2, [sp, #16]
32207826:	f000 8335 	beq.w	32207e94 <_vfprintf_r+0xf1c>
3220782a:	4619      	mov	r1, r3
3220782c:	9305      	str	r3, [sp, #20]
3220782e:	f20d 153f 	addw	r5, sp, #319	@ 0x13f
32207832:	2330      	movs	r3, #48	@ 0x30
32207834:	920b      	str	r2, [sp, #44]	@ 0x2c
32207836:	f88d 313f 	strb.w	r3, [sp, #319]	@ 0x13f
3220783a:	9109      	str	r1, [sp, #36]	@ 0x24
3220783c:	9110      	str	r1, [sp, #64]	@ 0x40
3220783e:	910e      	str	r1, [sp, #56]	@ 0x38
32207840:	910c      	str	r1, [sp, #48]	@ 0x30
32207842:	e526      	b.n	32207292 <_vfprintf_r+0x31a>
32207844:	9902      	ldr	r1, [sp, #8]
32207846:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
32207848:	9506      	str	r5, [sp, #24]
3220784a:	1d13      	adds	r3, r2, #4
3220784c:	068e      	lsls	r6, r1, #26
3220784e:	f140 8391 	bpl.w	32207f74 <_vfprintf_r+0xffc>
32207852:	6812      	ldr	r2, [r2, #0]
32207854:	9907      	ldr	r1, [sp, #28]
32207856:	6011      	str	r1, [r2, #0]
32207858:	17c9      	asrs	r1, r1, #31
3220785a:	6051      	str	r1, [r2, #4]
3220785c:	930a      	str	r3, [sp, #40]	@ 0x28
3220785e:	f7ff bbe3 	b.w	32207028 <_vfprintf_r+0xb0>
32207862:	9b02      	ldr	r3, [sp, #8]
32207864:	9506      	str	r5, [sp, #24]
32207866:	f043 0010 	orr.w	r0, r3, #16
3220786a:	0699      	lsls	r1, r3, #26
3220786c:	d4bb      	bmi.n	322077e6 <_vfprintf_r+0x86e>
3220786e:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32207870:	3304      	adds	r3, #4
32207872:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
32207874:	2100      	movs	r1, #0
32207876:	930a      	str	r3, [sp, #40]	@ 0x28
32207878:	2300      	movs	r3, #0
3220787a:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
3220787e:	9b05      	ldr	r3, [sp, #20]
32207880:	6812      	ldr	r2, [r2, #0]
32207882:	2b00      	cmp	r3, #0
32207884:	dabd      	bge.n	32207802 <_vfprintf_r+0x88a>
32207886:	f420 6380 	bic.w	r3, r0, #1024	@ 0x400
3220788a:	9302      	str	r3, [sp, #8]
3220788c:	ad50      	add	r5, sp, #320	@ 0x140
3220788e:	08d0      	lsrs	r0, r2, #3
32207890:	f002 0307 	and.w	r3, r2, #7
32207894:	ea40 7241 	orr.w	r2, r0, r1, lsl #29
32207898:	08c9      	lsrs	r1, r1, #3
3220789a:	3330      	adds	r3, #48	@ 0x30
3220789c:	4628      	mov	r0, r5
3220789e:	ea52 0601 	orrs.w	r6, r2, r1
322078a2:	f805 3d01 	strb.w	r3, [r5, #-1]!
322078a6:	d1f2      	bne.n	3220788e <_vfprintf_r+0x916>
322078a8:	9a02      	ldr	r2, [sp, #8]
322078aa:	2b30      	cmp	r3, #48	@ 0x30
322078ac:	f002 0201 	and.w	r2, r2, #1
322078b0:	bf08      	it	eq
322078b2:	2200      	moveq	r2, #0
322078b4:	2a00      	cmp	r2, #0
322078b6:	f040 8568 	bne.w	3220838a <_vfprintf_r+0x1412>
322078ba:	9a05      	ldr	r2, [sp, #20]
322078bc:	ab50      	add	r3, sp, #320	@ 0x140
322078be:	1b5b      	subs	r3, r3, r5
322078c0:	930b      	str	r3, [sp, #44]	@ 0x2c
322078c2:	429a      	cmp	r2, r3
322078c4:	bfb8      	it	lt
322078c6:	461a      	movlt	r2, r3
322078c8:	9204      	str	r2, [sp, #16]
322078ca:	2300      	movs	r3, #0
322078cc:	9309      	str	r3, [sp, #36]	@ 0x24
322078ce:	9310      	str	r3, [sp, #64]	@ 0x40
322078d0:	930e      	str	r3, [sp, #56]	@ 0x38
322078d2:	930c      	str	r3, [sp, #48]	@ 0x30
322078d4:	e4dd      	b.n	32207292 <_vfprintf_r+0x31a>
322078d6:	9b02      	ldr	r3, [sp, #8]
322078d8:	782c      	ldrb	r4, [r5, #0]
322078da:	f043 0308 	orr.w	r3, r3, #8
322078de:	9302      	str	r3, [sp, #8]
322078e0:	f7ff bbc8 	b.w	32207074 <_vfprintf_r+0xfc>
322078e4:	9b02      	ldr	r3, [sp, #8]
322078e6:	9506      	str	r5, [sp, #24]
322078e8:	f043 0210 	orr.w	r2, r3, #16
322078ec:	069d      	lsls	r5, r3, #26
322078ee:	f53f ad86 	bmi.w	322073fe <_vfprintf_r+0x486>
322078f2:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322078f4:	3304      	adds	r3, #4
322078f6:	990a      	ldr	r1, [sp, #40]	@ 0x28
322078f8:	930a      	str	r3, [sp, #40]	@ 0x28
322078fa:	9202      	str	r2, [sp, #8]
322078fc:	680e      	ldr	r6, [r1, #0]
322078fe:	ea4f 78e6 	mov.w	r8, r6, asr #31
32207902:	4643      	mov	r3, r8
32207904:	2b00      	cmp	r3, #0
32207906:	f6bf ad88 	bge.w	3220741a <_vfprintf_r+0x4a2>
3220790a:	4276      	negs	r6, r6
3220790c:	f04f 032d 	mov.w	r3, #45	@ 0x2d
32207910:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32207914:	9b05      	ldr	r3, [sp, #20]
32207916:	eb68 0848 	sbc.w	r8, r8, r8, lsl #1
3220791a:	2b00      	cmp	r3, #0
3220791c:	f6ff aee5 	blt.w	322076ea <_vfprintf_r+0x772>
32207920:	9b02      	ldr	r3, [sp, #8]
32207922:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32207926:	9302      	str	r3, [sp, #8]
32207928:	e6df      	b.n	322076ea <_vfprintf_r+0x772>
3220792a:	782c      	ldrb	r4, [r5, #0]
3220792c:	9b02      	ldr	r3, [sp, #8]
3220792e:	2c6c      	cmp	r4, #108	@ 0x6c
32207930:	f000 8498 	beq.w	32208264 <_vfprintf_r+0x12ec>
32207934:	f043 0310 	orr.w	r3, r3, #16
32207938:	9302      	str	r3, [sp, #8]
3220793a:	f7ff bb9b 	b.w	32207074 <_vfprintf_r+0xfc>
3220793e:	782c      	ldrb	r4, [r5, #0]
32207940:	9b02      	ldr	r3, [sp, #8]
32207942:	2c68      	cmp	r4, #104	@ 0x68
32207944:	f000 8487 	beq.w	32208256 <_vfprintf_r+0x12de>
32207948:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
3220794c:	9302      	str	r3, [sp, #8]
3220794e:	f7ff bb91 	b.w	32207074 <_vfprintf_r+0xfc>
32207952:	9b02      	ldr	r3, [sp, #8]
32207954:	9506      	str	r5, [sp, #24]
32207956:	f043 0210 	orr.w	r2, r3, #16
3220795a:	0699      	lsls	r1, r3, #26
3220795c:	f53f aeb4 	bmi.w	322076c8 <_vfprintf_r+0x750>
32207960:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32207962:	3304      	adds	r3, #4
32207964:	990a      	ldr	r1, [sp, #40]	@ 0x28
32207966:	f04f 0800 	mov.w	r8, #0
3220796a:	9805      	ldr	r0, [sp, #20]
3220796c:	f88d 8067 	strb.w	r8, [sp, #103]	@ 0x67
32207970:	6809      	ldr	r1, [r1, #0]
32207972:	4540      	cmp	r0, r8
32207974:	460e      	mov	r6, r1
32207976:	f2c1 80ee 	blt.w	32208b56 <_vfprintf_r+0x1bde>
3220797a:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
3220797e:	4541      	cmp	r1, r8
32207980:	bf08      	it	eq
32207982:	4540      	cmpeq	r0, r8
32207984:	9202      	str	r2, [sp, #8]
32207986:	930a      	str	r3, [sp, #40]	@ 0x28
32207988:	f47f aeaf 	bne.w	322076ea <_vfprintf_r+0x772>
3220798c:	e29b      	b.n	32207ec6 <_vfprintf_r+0xf4e>
3220798e:	4658      	mov	r0, fp
32207990:	f7fd f936 	bl	32204c00 <_localeconv_r>
32207994:	6843      	ldr	r3, [r0, #4]
32207996:	9316      	str	r3, [sp, #88]	@ 0x58
32207998:	4618      	mov	r0, r3
3220799a:	f7fd fed1 	bl	32205740 <strlen>
3220799e:	4606      	mov	r6, r0
322079a0:	9015      	str	r0, [sp, #84]	@ 0x54
322079a2:	4658      	mov	r0, fp
322079a4:	f7fd f92c 	bl	32204c00 <_localeconv_r>
322079a8:	6883      	ldr	r3, [r0, #8]
322079aa:	782c      	ldrb	r4, [r5, #0]
322079ac:	2e00      	cmp	r6, #0
322079ae:	bf18      	it	ne
322079b0:	2b00      	cmpne	r3, #0
322079b2:	9317      	str	r3, [sp, #92]	@ 0x5c
322079b4:	f43f ab5e 	beq.w	32207074 <_vfprintf_r+0xfc>
322079b8:	781b      	ldrb	r3, [r3, #0]
322079ba:	2b00      	cmp	r3, #0
322079bc:	f43f ab5a 	beq.w	32207074 <_vfprintf_r+0xfc>
322079c0:	9b02      	ldr	r3, [sp, #8]
322079c2:	f443 6380 	orr.w	r3, r3, #1024	@ 0x400
322079c6:	9302      	str	r3, [sp, #8]
322079c8:	f7ff bb54 	b.w	32207074 <_vfprintf_r+0xfc>
322079cc:	9b02      	ldr	r3, [sp, #8]
322079ce:	782c      	ldrb	r4, [r5, #0]
322079d0:	f043 0301 	orr.w	r3, r3, #1
322079d4:	9302      	str	r3, [sp, #8]
322079d6:	f7ff bb4d 	b.w	32207074 <_vfprintf_r+0xfc>
322079da:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
322079de:	782c      	ldrb	r4, [r5, #0]
322079e0:	2b00      	cmp	r3, #0
322079e2:	f47f ab47 	bne.w	32207074 <_vfprintf_r+0xfc>
322079e6:	2320      	movs	r3, #32
322079e8:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
322079ec:	f7ff bb42 	b.w	32207074 <_vfprintf_r+0xfc>
322079f0:	9b02      	ldr	r3, [sp, #8]
322079f2:	782c      	ldrb	r4, [r5, #0]
322079f4:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
322079f8:	9302      	str	r3, [sp, #8]
322079fa:	f7ff bb3b 	b.w	32207074 <_vfprintf_r+0xfc>
322079fe:	462a      	mov	r2, r5
32207a00:	f812 4b01 	ldrb.w	r4, [r2], #1
32207a04:	2c2a      	cmp	r4, #42	@ 0x2a
32207a06:	f001 836d 	beq.w	322090e4 <_vfprintf_r+0x216c>
32207a0a:	f1a4 0330 	sub.w	r3, r4, #48	@ 0x30
32207a0e:	2b09      	cmp	r3, #9
32207a10:	bf98      	it	ls
32207a12:	2100      	movls	r1, #0
32207a14:	bf98      	it	ls
32207a16:	200a      	movls	r0, #10
32207a18:	f201 8182 	bhi.w	32208d20 <_vfprintf_r+0x1da8>
32207a1c:	f812 4b01 	ldrb.w	r4, [r2], #1
32207a20:	fb00 3101 	mla	r1, r0, r1, r3
32207a24:	f1a4 0330 	sub.w	r3, r4, #48	@ 0x30
32207a28:	2b09      	cmp	r3, #9
32207a2a:	d9f7      	bls.n	32207a1c <_vfprintf_r+0xaa4>
32207a2c:	ea41 73e1 	orr.w	r3, r1, r1, asr #31
32207a30:	4615      	mov	r5, r2
32207a32:	9305      	str	r3, [sp, #20]
32207a34:	f7ff bb1f 	b.w	32207076 <_vfprintf_r+0xfe>
32207a38:	9b08      	ldr	r3, [sp, #32]
32207a3a:	9904      	ldr	r1, [sp, #16]
32207a3c:	1a5e      	subs	r6, r3, r1
32207a3e:	2e00      	cmp	r6, #0
32207a40:	f77f ac59 	ble.w	322072f6 <_vfprintf_r+0x37e>
32207a44:	f64b 7ae0 	movw	sl, #49120	@ 0xbfe0
32207a48:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32207a4c:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207a4e:	2e10      	cmp	r6, #16
32207a50:	dd27      	ble.n	32207aa2 <_vfprintf_r+0xb2a>
32207a52:	4649      	mov	r1, r9
32207a54:	f04f 0810 	mov.w	r8, #16
32207a58:	46a9      	mov	r9, r5
32207a5a:	4625      	mov	r5, r4
32207a5c:	4654      	mov	r4, sl
32207a5e:	f8dd a00c 	ldr.w	sl, [sp, #12]
32207a62:	e002      	b.n	32207a6a <_vfprintf_r+0xaf2>
32207a64:	3e10      	subs	r6, #16
32207a66:	2e10      	cmp	r6, #16
32207a68:	dd17      	ble.n	32207a9a <_vfprintf_r+0xb22>
32207a6a:	3301      	adds	r3, #1
32207a6c:	3210      	adds	r2, #16
32207a6e:	2b07      	cmp	r3, #7
32207a70:	e9c1 4800 	strd	r4, r8, [r1]
32207a74:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207a78:	bfd8      	it	le
32207a7a:	3108      	addle	r1, #8
32207a7c:	ddf2      	ble.n	32207a64 <_vfprintf_r+0xaec>
32207a7e:	aa24      	add	r2, sp, #144	@ 0x90
32207a80:	4651      	mov	r1, sl
32207a82:	4658      	mov	r0, fp
32207a84:	f7fb fd48 	bl	32203518 <__sprint_r>
32207a88:	2800      	cmp	r0, #0
32207a8a:	f47f abc7 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207a8e:	3e10      	subs	r6, #16
32207a90:	a927      	add	r1, sp, #156	@ 0x9c
32207a92:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32207a96:	2e10      	cmp	r6, #16
32207a98:	dce7      	bgt.n	32207a6a <_vfprintf_r+0xaf2>
32207a9a:	46a2      	mov	sl, r4
32207a9c:	462c      	mov	r4, r5
32207a9e:	464d      	mov	r5, r9
32207aa0:	4689      	mov	r9, r1
32207aa2:	3301      	adds	r3, #1
32207aa4:	4432      	add	r2, r6
32207aa6:	f8c9 a000 	str.w	sl, [r9]
32207aaa:	2b07      	cmp	r3, #7
32207aac:	f8c9 6004 	str.w	r6, [r9, #4]
32207ab0:	f109 0908 	add.w	r9, r9, #8
32207ab4:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207ab8:	f77f ac1d 	ble.w	322072f6 <_vfprintf_r+0x37e>
32207abc:	9903      	ldr	r1, [sp, #12]
32207abe:	aa24      	add	r2, sp, #144	@ 0x90
32207ac0:	4658      	mov	r0, fp
32207ac2:	f7fb fd29 	bl	32203518 <__sprint_r>
32207ac6:	2800      	cmp	r0, #0
32207ac8:	f47f aba8 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207acc:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32207ace:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32207ad2:	e410      	b.n	322072f6 <_vfprintf_r+0x37e>
32207ad4:	9e08      	ldr	r6, [sp, #32]
32207ad6:	9904      	ldr	r1, [sp, #16]
32207ad8:	1a76      	subs	r6, r6, r1
32207ada:	2e00      	cmp	r6, #0
32207adc:	dc5a      	bgt.n	32207b94 <_vfprintf_r+0xc1c>
32207ade:	f8cd a040 	str.w	sl, [sp, #64]	@ 0x40
32207ae2:	f8cd a038 	str.w	sl, [sp, #56]	@ 0x38
32207ae6:	f8cd a030 	str.w	sl, [sp, #48]	@ 0x30
32207aea:	f1bc 0f00 	cmp.w	ip, #0
32207aee:	f43f abee 	beq.w	322072ce <_vfprintf_r+0x356>
32207af2:	2602      	movs	r6, #2
32207af4:	f7ff bbd9 	b.w	322072aa <_vfprintf_r+0x332>
32207af8:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207afa:	3201      	adds	r2, #1
32207afc:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32207afe:	f109 0008 	add.w	r0, r9, #8
32207b02:	3301      	adds	r3, #1
32207b04:	2901      	cmp	r1, #1
32207b06:	f340 8174 	ble.w	32207df2 <_vfprintf_r+0xe7a>
32207b0a:	2101      	movs	r1, #1
32207b0c:	2b07      	cmp	r3, #7
32207b0e:	f8c9 5000 	str.w	r5, [r9]
32207b12:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207b16:	f8c9 1004 	str.w	r1, [r9, #4]
32207b1a:	f300 83f1 	bgt.w	32208300 <_vfprintf_r+0x1388>
32207b1e:	9911      	ldr	r1, [sp, #68]	@ 0x44
32207b20:	3301      	adds	r3, #1
32207b22:	9c12      	ldr	r4, [sp, #72]	@ 0x48
32207b24:	2b07      	cmp	r3, #7
32207b26:	440a      	add	r2, r1
32207b28:	e9c0 4100 	strd	r4, r1, [r0]
32207b2c:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207b30:	bfd8      	it	le
32207b32:	3008      	addle	r0, #8
32207b34:	f300 83d8 	bgt.w	322082e8 <_vfprintf_r+0x1370>
32207b38:	eeb5 8b40 	vcmp.f64	d8, #0.0
32207b3c:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32207b3e:	1e4e      	subs	r6, r1, #1
32207b40:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32207b44:	f000 816f 	beq.w	32207e26 <_vfprintf_r+0xeae>
32207b48:	3301      	adds	r3, #1
32207b4a:	3501      	adds	r5, #1
32207b4c:	6005      	str	r5, [r0, #0]
32207b4e:	2b07      	cmp	r3, #7
32207b50:	6046      	str	r6, [r0, #4]
32207b52:	4432      	add	r2, r6
32207b54:	bfd8      	it	le
32207b56:	3008      	addle	r0, #8
32207b58:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207b5c:	f300 8157 	bgt.w	32207e0e <_vfprintf_r+0xe96>
32207b60:	9914      	ldr	r1, [sp, #80]	@ 0x50
32207b62:	3301      	adds	r3, #1
32207b64:	6041      	str	r1, [r0, #4]
32207b66:	f100 0908 	add.w	r9, r0, #8
32207b6a:	440a      	add	r2, r1
32207b6c:	2b07      	cmp	r3, #7
32207b6e:	a91e      	add	r1, sp, #120	@ 0x78
32207b70:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207b74:	6001      	str	r1, [r0, #0]
32207b76:	f77f abd7 	ble.w	32207328 <_vfprintf_r+0x3b0>
32207b7a:	9903      	ldr	r1, [sp, #12]
32207b7c:	aa24      	add	r2, sp, #144	@ 0x90
32207b7e:	4658      	mov	r0, fp
32207b80:	f7fb fcca 	bl	32203518 <__sprint_r>
32207b84:	2800      	cmp	r0, #0
32207b86:	f47f ab49 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207b8a:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32207b8c:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32207b90:	f7ff bbca 	b.w	32207328 <_vfprintf_r+0x3b0>
32207b94:	f8cd a040 	str.w	sl, [sp, #64]	@ 0x40
32207b98:	f8cd a038 	str.w	sl, [sp, #56]	@ 0x38
32207b9c:	f8cd a030 	str.w	sl, [sp, #48]	@ 0x30
32207ba0:	f04f 0a02 	mov.w	sl, #2
32207ba4:	f64b 78f0 	movw	r8, #49136	@ 0xbff0
32207ba8:	f2c3 2820 	movt	r8, #12832	@ 0x3220
32207bac:	4671      	mov	r1, lr
32207bae:	4618      	mov	r0, r3
32207bb0:	2e10      	cmp	r6, #16
32207bb2:	dd27      	ble.n	32207c04 <_vfprintf_r+0xc8c>
32207bb4:	464a      	mov	r2, r9
32207bb6:	2310      	movs	r3, #16
32207bb8:	46a9      	mov	r9, r5
32207bba:	4625      	mov	r5, r4
32207bbc:	4644      	mov	r4, r8
32207bbe:	f8dd 800c 	ldr.w	r8, [sp, #12]
32207bc2:	e002      	b.n	32207bca <_vfprintf_r+0xc52>
32207bc4:	3e10      	subs	r6, #16
32207bc6:	2e10      	cmp	r6, #16
32207bc8:	dd18      	ble.n	32207bfc <_vfprintf_r+0xc84>
32207bca:	3001      	adds	r0, #1
32207bcc:	3110      	adds	r1, #16
32207bce:	2807      	cmp	r0, #7
32207bd0:	e9c2 4300 	strd	r4, r3, [r2]
32207bd4:	e9cd 0125 	strd	r0, r1, [sp, #148]	@ 0x94
32207bd8:	bfd8      	it	le
32207bda:	3208      	addle	r2, #8
32207bdc:	ddf2      	ble.n	32207bc4 <_vfprintf_r+0xc4c>
32207bde:	aa24      	add	r2, sp, #144	@ 0x90
32207be0:	4641      	mov	r1, r8
32207be2:	4658      	mov	r0, fp
32207be4:	f7fb fc98 	bl	32203518 <__sprint_r>
32207be8:	aa27      	add	r2, sp, #156	@ 0x9c
32207bea:	2800      	cmp	r0, #0
32207bec:	f47f ab16 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207bf0:	3e10      	subs	r6, #16
32207bf2:	2310      	movs	r3, #16
32207bf4:	e9dd 0125 	ldrd	r0, r1, [sp, #148]	@ 0x94
32207bf8:	2e10      	cmp	r6, #16
32207bfa:	dce6      	bgt.n	32207bca <_vfprintf_r+0xc52>
32207bfc:	46a0      	mov	r8, r4
32207bfe:	462c      	mov	r4, r5
32207c00:	464d      	mov	r5, r9
32207c02:	4691      	mov	r9, r2
32207c04:	3001      	adds	r0, #1
32207c06:	1872      	adds	r2, r6, r1
32207c08:	2807      	cmp	r0, #7
32207c0a:	f8c9 8000 	str.w	r8, [r9]
32207c0e:	f8c9 6004 	str.w	r6, [r9, #4]
32207c12:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
32207c16:	f300 838a 	bgt.w	3220832e <_vfprintf_r+0x13b6>
32207c1a:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32207c1e:	f109 0908 	add.w	r9, r9, #8
32207c22:	2b00      	cmp	r3, #0
32207c24:	f040 815b 	bne.w	32207ede <_vfprintf_r+0xf66>
32207c28:	f1ba 0f00 	cmp.w	sl, #0
32207c2c:	f43f ab63 	beq.w	322072f6 <_vfprintf_r+0x37e>
32207c30:	469a      	mov	sl, r3
32207c32:	f7ff bb4c 	b.w	322072ce <_vfprintf_r+0x356>
32207c36:	9903      	ldr	r1, [sp, #12]
32207c38:	aa24      	add	r2, sp, #144	@ 0x90
32207c3a:	4658      	mov	r0, fp
32207c3c:	f7fb fc6c 	bl	32203518 <__sprint_r>
32207c40:	2800      	cmp	r0, #0
32207c42:	f47f aaeb 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207c46:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32207c48:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32207c4c:	f7ff bb4f 	b.w	322072ee <_vfprintf_r+0x376>
32207c50:	9903      	ldr	r1, [sp, #12]
32207c52:	aa24      	add	r2, sp, #144	@ 0x90
32207c54:	4658      	mov	r0, fp
32207c56:	f7fb fc5f 	bl	32203518 <__sprint_r>
32207c5a:	2800      	cmp	r0, #0
32207c5c:	f47f aade 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207c60:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32207c62:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32207c66:	f7ff bb30 	b.w	322072ca <_vfprintf_r+0x352>
32207c6a:	f64b 78f0 	movw	r8, #49136	@ 0xbff0
32207c6e:	f2c3 2820 	movt	r8, #12832	@ 0x3220
32207c72:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207c74:	2c10      	cmp	r4, #16
32207c76:	dd21      	ble.n	32207cbc <_vfprintf_r+0xd44>
32207c78:	4646      	mov	r6, r8
32207c7a:	2510      	movs	r5, #16
32207c7c:	f8dd 800c 	ldr.w	r8, [sp, #12]
32207c80:	e002      	b.n	32207c88 <_vfprintf_r+0xd10>
32207c82:	3c10      	subs	r4, #16
32207c84:	2c10      	cmp	r4, #16
32207c86:	dd18      	ble.n	32207cba <_vfprintf_r+0xd42>
32207c88:	3301      	adds	r3, #1
32207c8a:	3210      	adds	r2, #16
32207c8c:	e9c9 6500 	strd	r6, r5, [r9]
32207c90:	2b07      	cmp	r3, #7
32207c92:	f109 0908 	add.w	r9, r9, #8
32207c96:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207c9a:	ddf2      	ble.n	32207c82 <_vfprintf_r+0xd0a>
32207c9c:	aa24      	add	r2, sp, #144	@ 0x90
32207c9e:	4641      	mov	r1, r8
32207ca0:	4658      	mov	r0, fp
32207ca2:	f7fb fc39 	bl	32203518 <__sprint_r>
32207ca6:	2800      	cmp	r0, #0
32207ca8:	f47f aab8 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207cac:	3c10      	subs	r4, #16
32207cae:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32207cb2:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32207cb6:	2c10      	cmp	r4, #16
32207cb8:	dce6      	bgt.n	32207c88 <_vfprintf_r+0xd10>
32207cba:	46b0      	mov	r8, r6
32207cbc:	3301      	adds	r3, #1
32207cbe:	4422      	add	r2, r4
32207cc0:	2b07      	cmp	r3, #7
32207cc2:	e9c9 8400 	strd	r8, r4, [r9]
32207cc6:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207cca:	f77f ab36 	ble.w	3220733a <_vfprintf_r+0x3c2>
32207cce:	9903      	ldr	r1, [sp, #12]
32207cd0:	aa24      	add	r2, sp, #144	@ 0x90
32207cd2:	4658      	mov	r0, fp
32207cd4:	f7fb fc20 	bl	32203518 <__sprint_r>
32207cd8:	2800      	cmp	r0, #0
32207cda:	f47f aa9f 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207cde:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32207ce0:	f7ff bb2b 	b.w	3220733a <_vfprintf_r+0x3c2>
32207ce4:	2300      	movs	r3, #0
32207ce6:	2602      	movs	r6, #2
32207ce8:	9310      	str	r3, [sp, #64]	@ 0x40
32207cea:	930e      	str	r3, [sp, #56]	@ 0x38
32207cec:	930c      	str	r3, [sp, #48]	@ 0x30
32207cee:	f7ff badc 	b.w	322072aa <_vfprintf_r+0x332>
32207cf2:	991b      	ldr	r1, [sp, #108]	@ 0x6c
32207cf4:	2900      	cmp	r1, #0
32207cf6:	f340 80f7 	ble.w	32207ee8 <_vfprintf_r+0xf70>
32207cfa:	9c0c      	ldr	r4, [sp, #48]	@ 0x30
32207cfc:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32207cfe:	429c      	cmp	r4, r3
32207d00:	bfa8      	it	ge
32207d02:	461c      	movge	r4, r3
32207d04:	2c00      	cmp	r4, #0
32207d06:	dd0b      	ble.n	32207d20 <_vfprintf_r+0xda8>
32207d08:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207d0a:	4422      	add	r2, r4
32207d0c:	e9c9 5400 	strd	r5, r4, [r9]
32207d10:	f109 0908 	add.w	r9, r9, #8
32207d14:	3301      	adds	r3, #1
32207d16:	9226      	str	r2, [sp, #152]	@ 0x98
32207d18:	2b07      	cmp	r3, #7
32207d1a:	9325      	str	r3, [sp, #148]	@ 0x94
32207d1c:	f300 873c 	bgt.w	32208b98 <_vfprintf_r+0x1c20>
32207d20:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32207d22:	ea24 74e4 	bic.w	r4, r4, r4, asr #31
32207d26:	1b1c      	subs	r4, r3, r4
32207d28:	2c00      	cmp	r4, #0
32207d2a:	f300 8454 	bgt.w	322085d6 <_vfprintf_r+0x165e>
32207d2e:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32207d30:	442b      	add	r3, r5
32207d32:	4698      	mov	r8, r3
32207d34:	9b02      	ldr	r3, [sp, #8]
32207d36:	0558      	lsls	r0, r3, #21
32207d38:	f100 865b 	bmi.w	322089f2 <_vfprintf_r+0x1a7a>
32207d3c:	9c1b      	ldr	r4, [sp, #108]	@ 0x6c
32207d3e:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32207d40:	429c      	cmp	r4, r3
32207d42:	db03      	blt.n	32207d4c <_vfprintf_r+0xdd4>
32207d44:	9902      	ldr	r1, [sp, #8]
32207d46:	07c9      	lsls	r1, r1, #31
32207d48:	f140 8545 	bpl.w	322087d6 <_vfprintf_r+0x185e>
32207d4c:	9b11      	ldr	r3, [sp, #68]	@ 0x44
32207d4e:	9912      	ldr	r1, [sp, #72]	@ 0x48
32207d50:	441a      	add	r2, r3
32207d52:	e9c9 1300 	strd	r1, r3, [r9]
32207d56:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207d58:	f109 0908 	add.w	r9, r9, #8
32207d5c:	9226      	str	r2, [sp, #152]	@ 0x98
32207d5e:	3301      	adds	r3, #1
32207d60:	9325      	str	r3, [sp, #148]	@ 0x94
32207d62:	2b07      	cmp	r3, #7
32207d64:	f300 8743 	bgt.w	32208bee <_vfprintf_r+0x1c76>
32207d68:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32207d6a:	441d      	add	r5, r3
32207d6c:	1b1c      	subs	r4, r3, r4
32207d6e:	eba5 0508 	sub.w	r5, r5, r8
32207d72:	42a5      	cmp	r5, r4
32207d74:	bfa8      	it	ge
32207d76:	4625      	movge	r5, r4
32207d78:	2d00      	cmp	r5, #0
32207d7a:	dd0d      	ble.n	32207d98 <_vfprintf_r+0xe20>
32207d7c:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207d7e:	442a      	add	r2, r5
32207d80:	f8c9 8000 	str.w	r8, [r9]
32207d84:	f109 0908 	add.w	r9, r9, #8
32207d88:	3301      	adds	r3, #1
32207d8a:	f849 5c04 	str.w	r5, [r9, #-4]
32207d8e:	2b07      	cmp	r3, #7
32207d90:	9226      	str	r2, [sp, #152]	@ 0x98
32207d92:	9325      	str	r3, [sp, #148]	@ 0x94
32207d94:	f300 87b4 	bgt.w	32208d00 <_vfprintf_r+0x1d88>
32207d98:	ea25 75e5 	bic.w	r5, r5, r5, asr #31
32207d9c:	1b64      	subs	r4, r4, r5
32207d9e:	2c00      	cmp	r4, #0
32207da0:	f77f aac2 	ble.w	32207328 <_vfprintf_r+0x3b0>
32207da4:	f64b 7ae0 	movw	sl, #49120	@ 0xbfe0
32207da8:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32207dac:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207dae:	2510      	movs	r5, #16
32207db0:	f8dd 800c 	ldr.w	r8, [sp, #12]
32207db4:	4656      	mov	r6, sl
32207db6:	2c10      	cmp	r4, #16
32207db8:	dc04      	bgt.n	32207dc4 <_vfprintf_r+0xe4c>
32207dba:	e364      	b.n	32208486 <_vfprintf_r+0x150e>
32207dbc:	3c10      	subs	r4, #16
32207dbe:	2c10      	cmp	r4, #16
32207dc0:	f340 8360 	ble.w	32208484 <_vfprintf_r+0x150c>
32207dc4:	3301      	adds	r3, #1
32207dc6:	3210      	adds	r2, #16
32207dc8:	e9c9 6500 	strd	r6, r5, [r9]
32207dcc:	2b07      	cmp	r3, #7
32207dce:	f109 0908 	add.w	r9, r9, #8
32207dd2:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207dd6:	ddf1      	ble.n	32207dbc <_vfprintf_r+0xe44>
32207dd8:	aa24      	add	r2, sp, #144	@ 0x90
32207dda:	4641      	mov	r1, r8
32207ddc:	4658      	mov	r0, fp
32207dde:	f7fb fb9b 	bl	32203518 <__sprint_r>
32207de2:	2800      	cmp	r0, #0
32207de4:	f47f aa1a 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207de8:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32207dec:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32207df0:	e7e4      	b.n	32207dbc <_vfprintf_r+0xe44>
32207df2:	9902      	ldr	r1, [sp, #8]
32207df4:	07ce      	lsls	r6, r1, #31
32207df6:	f53f ae88 	bmi.w	32207b0a <_vfprintf_r+0xb92>
32207dfa:	2101      	movs	r1, #1
32207dfc:	2b07      	cmp	r3, #7
32207dfe:	f8c9 5000 	str.w	r5, [r9]
32207e02:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207e06:	f8c9 1004 	str.w	r1, [r9, #4]
32207e0a:	f77f aea9 	ble.w	32207b60 <_vfprintf_r+0xbe8>
32207e0e:	9903      	ldr	r1, [sp, #12]
32207e10:	aa24      	add	r2, sp, #144	@ 0x90
32207e12:	4658      	mov	r0, fp
32207e14:	f7fb fb80 	bl	32203518 <__sprint_r>
32207e18:	2800      	cmp	r0, #0
32207e1a:	f47f a9ff 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207e1e:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32207e22:	a827      	add	r0, sp, #156	@ 0x9c
32207e24:	e69c      	b.n	32207b60 <_vfprintf_r+0xbe8>
32207e26:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32207e28:	2901      	cmp	r1, #1
32207e2a:	f77f ae99 	ble.w	32207b60 <_vfprintf_r+0xbe8>
32207e2e:	f64b 7ae0 	movw	sl, #49120	@ 0xbfe0
32207e32:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32207e36:	f8dd 800c 	ldr.w	r8, [sp, #12]
32207e3a:	2410      	movs	r4, #16
32207e3c:	4655      	mov	r5, sl
32207e3e:	2911      	cmp	r1, #17
32207e40:	dc04      	bgt.n	32207e4c <_vfprintf_r+0xed4>
32207e42:	e3b6      	b.n	322085b2 <_vfprintf_r+0x163a>
32207e44:	3e10      	subs	r6, #16
32207e46:	2e10      	cmp	r6, #16
32207e48:	f340 83b2 	ble.w	322085b0 <_vfprintf_r+0x1638>
32207e4c:	3301      	adds	r3, #1
32207e4e:	3210      	adds	r2, #16
32207e50:	2b07      	cmp	r3, #7
32207e52:	e9c0 5400 	strd	r5, r4, [r0]
32207e56:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207e5a:	bfd8      	it	le
32207e5c:	3008      	addle	r0, #8
32207e5e:	ddf1      	ble.n	32207e44 <_vfprintf_r+0xecc>
32207e60:	aa24      	add	r2, sp, #144	@ 0x90
32207e62:	4641      	mov	r1, r8
32207e64:	4658      	mov	r0, fp
32207e66:	f7fb fb57 	bl	32203518 <__sprint_r>
32207e6a:	2800      	cmp	r0, #0
32207e6c:	f47f a9d6 	bne.w	3220721c <_vfprintf_r+0x2a4>
32207e70:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32207e74:	a827      	add	r0, sp, #156	@ 0x9c
32207e76:	e7e5      	b.n	32207e44 <_vfprintf_r+0xecc>
32207e78:	0490      	lsls	r0, r2, #18
32207e7a:	f57f a8af 	bpl.w	32206fdc <_vfprintf_r+0x64>
32207e7e:	e41a      	b.n	322076b6 <_vfprintf_r+0x73e>
32207e80:	9b02      	ldr	r3, [sp, #8]
32207e82:	07dd      	lsls	r5, r3, #31
32207e84:	f57f aa50 	bpl.w	32207328 <_vfprintf_r+0x3b0>
32207e88:	f7ff bb6f 	b.w	3220756a <_vfprintf_r+0x5f2>
32207e8c:	782c      	ldrb	r4, [r5, #0]
32207e8e:	930a      	str	r3, [sp, #40]	@ 0x28
32207e90:	f7ff b8f0 	b.w	32207074 <_vfprintf_r+0xfc>
32207e94:	9a04      	ldr	r2, [sp, #16]
32207e96:	ad50      	add	r5, sp, #320	@ 0x140
32207e98:	9205      	str	r2, [sp, #20]
32207e9a:	920b      	str	r2, [sp, #44]	@ 0x2c
32207e9c:	9210      	str	r2, [sp, #64]	@ 0x40
32207e9e:	920e      	str	r2, [sp, #56]	@ 0x38
32207ea0:	920c      	str	r2, [sp, #48]	@ 0x30
32207ea2:	9209      	str	r2, [sp, #36]	@ 0x24
32207ea4:	f7ff b9f5 	b.w	32207292 <_vfprintf_r+0x31a>
32207ea8:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
32207eac:	9202      	str	r2, [sp, #8]
32207eae:	1a5a      	subs	r2, r3, r1
32207eb0:	bf18      	it	ne
32207eb2:	2201      	movne	r2, #1
32207eb4:	ea56 0308 	orrs.w	r3, r6, r8
32207eb8:	f042 0301 	orr.w	r3, r2, #1
32207ebc:	bf08      	it	eq
32207ebe:	4613      	moveq	r3, r2
32207ec0:	2b00      	cmp	r3, #0
32207ec2:	f47f ac12 	bne.w	322076ea <_vfprintf_r+0x772>
32207ec6:	9a02      	ldr	r2, [sp, #8]
32207ec8:	2300      	movs	r3, #0
32207eca:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
32207ece:	ad50      	add	r5, sp, #320	@ 0x140
32207ed0:	f002 0202 	and.w	r2, r2, #2
32207ed4:	9304      	str	r3, [sp, #16]
32207ed6:	e9cd 320b 	strd	r3, r2, [sp, #44]	@ 0x2c
32207eda:	9305      	str	r3, [sp, #20]
32207edc:	e41b      	b.n	32207716 <_vfprintf_r+0x79e>
32207ede:	4656      	mov	r6, sl
32207ee0:	f04f 0a00 	mov.w	sl, #0
32207ee4:	f7ff b9e1 	b.w	322072aa <_vfprintf_r+0x332>
32207ee8:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207eea:	2001      	movs	r0, #1
32207eec:	3201      	adds	r2, #1
32207eee:	f8c9 0004 	str.w	r0, [r9, #4]
32207ef2:	3301      	adds	r3, #1
32207ef4:	f64b 3070 	movw	r0, #47984	@ 0xbb70
32207ef8:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32207efc:	f109 0908 	add.w	r9, r9, #8
32207f00:	f849 0c08 	str.w	r0, [r9, #-8]
32207f04:	2b07      	cmp	r3, #7
32207f06:	9226      	str	r2, [sp, #152]	@ 0x98
32207f08:	9325      	str	r3, [sp, #148]	@ 0x94
32207f0a:	f300 8627 	bgt.w	32208b5c <_vfprintf_r+0x1be4>
32207f0e:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32207f10:	430b      	orrs	r3, r1
32207f12:	f000 867a 	beq.w	32208c0a <_vfprintf_r+0x1c92>
32207f16:	9b11      	ldr	r3, [sp, #68]	@ 0x44
32207f18:	9812      	ldr	r0, [sp, #72]	@ 0x48
32207f1a:	441a      	add	r2, r3
32207f1c:	e9c9 0300 	strd	r0, r3, [r9]
32207f20:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32207f22:	f109 0908 	add.w	r9, r9, #8
32207f26:	9226      	str	r2, [sp, #152]	@ 0x98
32207f28:	3301      	adds	r3, #1
32207f2a:	9325      	str	r3, [sp, #148]	@ 0x94
32207f2c:	2b07      	cmp	r3, #7
32207f2e:	f300 864f 	bgt.w	32208bd0 <_vfprintf_r+0x1c58>
32207f32:	2900      	cmp	r1, #0
32207f34:	f2c0 8718 	blt.w	32208d68 <_vfprintf_r+0x1df0>
32207f38:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32207f3a:	3301      	adds	r3, #1
32207f3c:	2b07      	cmp	r3, #7
32207f3e:	f8c9 5000 	str.w	r5, [r9]
32207f42:	440a      	add	r2, r1
32207f44:	f8c9 1004 	str.w	r1, [r9, #4]
32207f48:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32207f4c:	f77f a9ea 	ble.w	32207324 <_vfprintf_r+0x3ac>
32207f50:	e613      	b.n	32207b7a <_vfprintf_r+0xc02>
32207f52:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32207f54:	9902      	ldr	r1, [sp, #8]
32207f56:	f853 2b04 	ldr.w	r2, [r3], #4
32207f5a:	f011 0110 	ands.w	r1, r1, #16
32207f5e:	f041 8106 	bne.w	3220916e <_vfprintf_r+0x21f6>
32207f62:	9d02      	ldr	r5, [sp, #8]
32207f64:	f015 0040 	ands.w	r0, r5, #64	@ 0x40
32207f68:	f000 835f 	beq.w	3220862a <_vfprintf_r+0x16b2>
32207f6c:	b292      	uxth	r2, r2
32207f6e:	4628      	mov	r0, r5
32207f70:	930a      	str	r3, [sp, #40]	@ 0x28
32207f72:	e440      	b.n	322077f6 <_vfprintf_r+0x87e>
32207f74:	9a02      	ldr	r2, [sp, #8]
32207f76:	06d5      	lsls	r5, r2, #27
32207f78:	f100 8314 	bmi.w	322085a4 <_vfprintf_r+0x162c>
32207f7c:	9a02      	ldr	r2, [sp, #8]
32207f7e:	0654      	lsls	r4, r2, #25
32207f80:	f100 8438 	bmi.w	322087f4 <_vfprintf_r+0x187c>
32207f84:	9a02      	ldr	r2, [sp, #8]
32207f86:	0590      	lsls	r0, r2, #22
32207f88:	f140 830c 	bpl.w	322085a4 <_vfprintf_r+0x162c>
32207f8c:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
32207f8e:	9907      	ldr	r1, [sp, #28]
32207f90:	6812      	ldr	r2, [r2, #0]
32207f92:	7011      	strb	r1, [r2, #0]
32207f94:	e462      	b.n	3220785c <_vfprintf_r+0x8e4>
32207f96:	eeb4 8b48 	vcmp.f64	d8, d8
32207f9a:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32207f9e:	f180 878a 	bvs.w	32208eb6 <_vfprintf_r+0x1f3e>
32207fa2:	f024 0620 	bic.w	r6, r4, #32
32207fa6:	2e41      	cmp	r6, #65	@ 0x41
32207fa8:	f040 836d 	bne.w	32208686 <_vfprintf_r+0x170e>
32207fac:	2c61      	cmp	r4, #97	@ 0x61
32207fae:	f04f 0330 	mov.w	r3, #48	@ 0x30
32207fb2:	f88d 3068 	strb.w	r3, [sp, #104]	@ 0x68
32207fb6:	f04f 0358 	mov.w	r3, #88	@ 0x58
32207fba:	bf08      	it	eq
32207fbc:	2378      	moveq	r3, #120	@ 0x78
32207fbe:	f88d 3069 	strb.w	r3, [sp, #105]	@ 0x69
32207fc2:	9b05      	ldr	r3, [sp, #20]
32207fc4:	2b63      	cmp	r3, #99	@ 0x63
32207fc6:	f300 8461 	bgt.w	3220888c <_vfprintf_r+0x1914>
32207fca:	ee18 3a90 	vmov	r3, s17
32207fce:	2b00      	cmp	r3, #0
32207fd0:	f2c0 8725 	blt.w	32208e1e <_vfprintf_r+0x1ea6>
32207fd4:	eeb0 0b48 	vmov.f64	d0, d8
32207fd8:	ad37      	add	r5, sp, #220	@ 0xdc
32207fda:	f04f 0800 	mov.w	r8, #0
32207fde:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
32207fe2:	a81b      	add	r0, sp, #108	@ 0x6c
32207fe4:	f001 fd3c 	bl	32209a60 <frexp>
32207fe8:	eef4 0b00 	vmov.f64	d16, #64	@ 0x3e000000  0.125
32207fec:	ee60 0b20 	vmul.f64	d16, d0, d16
32207ff0:	eef5 0b40 	vcmp.f64	d16, #0.0
32207ff4:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32207ff8:	d101      	bne.n	32207ffe <_vfprintf_r+0x1086>
32207ffa:	2301      	movs	r3, #1
32207ffc:	931b      	str	r3, [sp, #108]	@ 0x6c
32207ffe:	9b05      	ldr	r3, [sp, #20]
32208000:	f64b 10f0 	movw	r0, #47600	@ 0xb9f0
32208004:	f2c3 2020 	movt	r0, #12832	@ 0x3220
32208008:	eef3 2b00 	vmov.f64	d18, #48	@ 0x41800000  16.0
3220800c:	1e5a      	subs	r2, r3, #1
3220800e:	f64b 2304 	movw	r3, #47620	@ 0xba04
32208012:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32208016:	2c61      	cmp	r4, #97	@ 0x61
32208018:	bf08      	it	eq
3220801a:	4618      	moveq	r0, r3
3220801c:	462b      	mov	r3, r5
3220801e:	e006      	b.n	3220802e <_vfprintf_r+0x10b6>
32208020:	eef5 0b40 	vcmp.f64	d16, #0.0
32208024:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32208028:	f000 87a5 	beq.w	32208f76 <_vfprintf_r+0x1ffe>
3220802c:	460a      	mov	r2, r1
3220802e:	ee60 0ba2 	vmul.f64	d16, d16, d18
32208032:	469c      	mov	ip, r3
32208034:	1e51      	subs	r1, r2, #1
32208036:	eefd 7be0 	vcvt.s32.f64	s15, d16
3220803a:	ee17 6a90 	vmov	r6, s15
3220803e:	eef8 1be7 	vcvt.f64.s32	d17, s15
32208042:	5d86      	ldrb	r6, [r0, r6]
32208044:	ee70 0be1 	vsub.f64	d16, d16, d17
32208048:	f803 6b01 	strb.w	r6, [r3], #1
3220804c:	1c56      	adds	r6, r2, #1
3220804e:	d1e7      	bne.n	32208020 <_vfprintf_r+0x10a8>
32208050:	eef6 1b00 	vmov.f64	d17, #96	@ 0x3f000000  0.5
32208054:	eef4 0be1 	vcmpe.f64	d16, d17
32208058:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220805c:	dc08      	bgt.n	32208070 <_vfprintf_r+0x10f8>
3220805e:	eef4 0b61 	vcmp.f64	d16, d17
32208062:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32208066:	d11d      	bne.n	322080a4 <_vfprintf_r+0x112c>
32208068:	ee17 2a90 	vmov	r2, s15
3220806c:	07d6      	lsls	r6, r2, #31
3220806e:	d519      	bpl.n	322080a4 <_vfprintf_r+0x112c>
32208070:	f8cd c088 	str.w	ip, [sp, #136]	@ 0x88
32208074:	461a      	mov	r2, r3
32208076:	7bc6      	ldrb	r6, [r0, #15]
32208078:	f813 1c01 	ldrb.w	r1, [r3, #-1]
3220807c:	42b1      	cmp	r1, r6
3220807e:	d10a      	bne.n	32208096 <_vfprintf_r+0x111e>
32208080:	f04f 0c30 	mov.w	ip, #48	@ 0x30
32208084:	f802 cc01 	strb.w	ip, [r2, #-1]
32208088:	9a22      	ldr	r2, [sp, #136]	@ 0x88
3220808a:	1e51      	subs	r1, r2, #1
3220808c:	9122      	str	r1, [sp, #136]	@ 0x88
3220808e:	f812 1c01 	ldrb.w	r1, [r2, #-1]
32208092:	42b1      	cmp	r1, r6
32208094:	d0f6      	beq.n	32208084 <_vfprintf_r+0x110c>
32208096:	2939      	cmp	r1, #57	@ 0x39
32208098:	f001 805c 	beq.w	32209154 <_vfprintf_r+0x21dc>
3220809c:	3101      	adds	r1, #1
3220809e:	b2c9      	uxtb	r1, r1
322080a0:	f802 1c01 	strb.w	r1, [r2, #-1]
322080a4:	9a02      	ldr	r2, [sp, #8]
322080a6:	1b5b      	subs	r3, r3, r5
322080a8:	930f      	str	r3, [sp, #60]	@ 0x3c
322080aa:	f104 030f 	add.w	r3, r4, #15
322080ae:	f042 0102 	orr.w	r1, r2, #2
322080b2:	9a1b      	ldr	r2, [sp, #108]	@ 0x6c
322080b4:	f88d 3078 	strb.w	r3, [sp, #120]	@ 0x78
322080b8:	1e53      	subs	r3, r2, #1
322080ba:	931b      	str	r3, [sp, #108]	@ 0x6c
322080bc:	2b00      	cmp	r3, #0
322080be:	f2c0 87e8 	blt.w	32209092 <_vfprintf_r+0x211a>
322080c2:	222b      	movs	r2, #43	@ 0x2b
322080c4:	2b09      	cmp	r3, #9
322080c6:	f88d 2079 	strb.w	r2, [sp, #121]	@ 0x79
322080ca:	f300 842c 	bgt.w	32208926 <_vfprintf_r+0x19ae>
322080ce:	f10d 027a 	add.w	r2, sp, #122	@ 0x7a
322080d2:	3330      	adds	r3, #48	@ 0x30
322080d4:	f802 3b01 	strb.w	r3, [r2], #1
322080d8:	ab1e      	add	r3, sp, #120	@ 0x78
322080da:	1ad3      	subs	r3, r2, r3
322080dc:	9314      	str	r3, [sp, #80]	@ 0x50
322080de:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
322080e0:	9a14      	ldr	r2, [sp, #80]	@ 0x50
322080e2:	2b01      	cmp	r3, #1
322080e4:	441a      	add	r2, r3
322080e6:	920b      	str	r2, [sp, #44]	@ 0x2c
322080e8:	f340 86a2 	ble.w	32208e30 <_vfprintf_r+0x1eb8>
322080ec:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
322080ee:	9a11      	ldr	r2, [sp, #68]	@ 0x44
322080f0:	4413      	add	r3, r2
322080f2:	930b      	str	r3, [sp, #44]	@ 0x2c
322080f4:	f421 6380 	bic.w	r3, r1, #1024	@ 0x400
322080f8:	f001 0202 	and.w	r2, r1, #2
322080fc:	f443 7380 	orr.w	r3, r3, #256	@ 0x100
32208100:	9302      	str	r3, [sp, #8]
32208102:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32208104:	920c      	str	r2, [sp, #48]	@ 0x30
32208106:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
3220810a:	9304      	str	r3, [sp, #16]
3220810c:	f1b8 0f00 	cmp.w	r8, #0
32208110:	f000 8666 	beq.w	32208de0 <_vfprintf_r+0x1e68>
32208114:	f04f 0c2d 	mov.w	ip, #45	@ 0x2d
32208118:	2300      	movs	r3, #0
3220811a:	f88d c067 	strb.w	ip, [sp, #103]	@ 0x67
3220811e:	9305      	str	r3, [sp, #20]
32208120:	f7ff bafe 	b.w	32207720 <_vfprintf_r+0x7a8>
32208124:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32208126:	9a02      	ldr	r2, [sp, #8]
32208128:	f853 6b04 	ldr.w	r6, [r3], #4
3220812c:	06d1      	lsls	r1, r2, #27
3220812e:	f53f abe2 	bmi.w	322078f6 <_vfprintf_r+0x97e>
32208132:	9a02      	ldr	r2, [sp, #8]
32208134:	0652      	lsls	r2, r2, #25
32208136:	f140 829b 	bpl.w	32208670 <_vfprintf_r+0x16f8>
3220813a:	b236      	sxth	r6, r6
3220813c:	930a      	str	r3, [sp, #40]	@ 0x28
3220813e:	ea4f 78e6 	mov.w	r8, r6, asr #31
32208142:	4643      	mov	r3, r8
32208144:	f7ff b966 	b.w	32207414 <_vfprintf_r+0x49c>
32208148:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
3220814a:	9902      	ldr	r1, [sp, #8]
3220814c:	f853 2b04 	ldr.w	r2, [r3], #4
32208150:	f011 0810 	ands.w	r8, r1, #16
32208154:	f041 8032 	bne.w	322091bc <_vfprintf_r+0x2244>
32208158:	9802      	ldr	r0, [sp, #8]
3220815a:	f010 0140 	ands.w	r1, r0, #64	@ 0x40
3220815e:	f000 8277 	beq.w	32208650 <_vfprintf_r+0x16d8>
32208162:	b296      	uxth	r6, r2
32208164:	9a05      	ldr	r2, [sp, #20]
32208166:	f88d 8067 	strb.w	r8, [sp, #103]	@ 0x67
3220816a:	2a00      	cmp	r2, #0
3220816c:	f2c0 827d 	blt.w	3220866a <_vfprintf_r+0x16f2>
32208170:	f020 0180 	bic.w	r1, r0, #128	@ 0x80
32208174:	2a00      	cmp	r2, #0
32208176:	bf08      	it	eq
32208178:	2e00      	cmpeq	r6, #0
3220817a:	9102      	str	r1, [sp, #8]
3220817c:	930a      	str	r3, [sp, #40]	@ 0x28
3220817e:	f47f aab4 	bne.w	322076ea <_vfprintf_r+0x772>
32208182:	e6a0      	b.n	32207ec6 <_vfprintf_r+0xf4e>
32208184:	f64b 10f0 	movw	r0, #47600	@ 0xb9f0
32208188:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220818c:	9506      	str	r5, [sp, #24]
3220818e:	9b02      	ldr	r3, [sp, #8]
32208190:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
32208192:	f013 0220 	ands.w	r2, r3, #32
32208196:	f000 8098 	beq.w	322082ca <_vfprintf_r+0x1352>
3220819a:	3507      	adds	r5, #7
3220819c:	f025 0507 	bic.w	r5, r5, #7
322081a0:	686a      	ldr	r2, [r5, #4]
322081a2:	f855 3b08 	ldr.w	r3, [r5], #8
322081a6:	ea53 0102 	orrs.w	r1, r3, r2
322081aa:	9902      	ldr	r1, [sp, #8]
322081ac:	f04f 0601 	mov.w	r6, #1
322081b0:	bf08      	it	eq
322081b2:	2600      	moveq	r6, #0
322081b4:	f001 0101 	and.w	r1, r1, #1
322081b8:	bf08      	it	eq
322081ba:	2100      	moveq	r1, #0
322081bc:	2900      	cmp	r1, #0
322081be:	f040 80cb 	bne.w	32208358 <_vfprintf_r+0x13e0>
322081c2:	f88d 1067 	strb.w	r1, [sp, #103]	@ 0x67
322081c6:	9905      	ldr	r1, [sp, #20]
322081c8:	2900      	cmp	r1, #0
322081ca:	9902      	ldr	r1, [sp, #8]
322081cc:	f2c0 80a4 	blt.w	32208318 <_vfprintf_r+0x13a0>
322081d0:	f421 6190 	bic.w	r1, r1, #1152	@ 0x480
322081d4:	9102      	str	r1, [sp, #8]
322081d6:	9905      	ldr	r1, [sp, #20]
322081d8:	3900      	subs	r1, #0
322081da:	bf18      	it	ne
322081dc:	2101      	movne	r1, #1
322081de:	4331      	orrs	r1, r6
322081e0:	f47f aaf3 	bne.w	322077ca <_vfprintf_r+0x852>
322081e4:	950a      	str	r5, [sp, #40]	@ 0x28
322081e6:	e66e      	b.n	32207ec6 <_vfprintf_r+0xf4e>
322081e8:	f64b 2004 	movw	r0, #47620	@ 0xba04
322081ec:	f2c3 2020 	movt	r0, #12832	@ 0x3220
322081f0:	9506      	str	r5, [sp, #24]
322081f2:	e7cc      	b.n	3220818e <_vfprintf_r+0x1216>
322081f4:	9902      	ldr	r1, [sp, #8]
322081f6:	f64b 2004 	movw	r0, #47620	@ 0xba04
322081fa:	f2c3 2020 	movt	r0, #12832	@ 0x3220
322081fe:	4694      	mov	ip, r2
32208200:	2478      	movs	r4, #120	@ 0x78
32208202:	f041 0102 	orr.w	r1, r1, #2
32208206:	950a      	str	r5, [sp, #40]	@ 0x28
32208208:	9102      	str	r1, [sp, #8]
3220820a:	2102      	movs	r1, #2
3220820c:	910c      	str	r1, [sp, #48]	@ 0x30
3220820e:	ad50      	add	r5, sp, #320	@ 0x140
32208210:	f003 010f 	and.w	r1, r3, #15
32208214:	091b      	lsrs	r3, r3, #4
32208216:	ea43 7302 	orr.w	r3, r3, r2, lsl #28
3220821a:	0912      	lsrs	r2, r2, #4
3220821c:	5c41      	ldrb	r1, [r0, r1]
3220821e:	f805 1d01 	strb.w	r1, [r5, #-1]!
32208222:	ea53 0102 	orrs.w	r1, r3, r2
32208226:	d1f3      	bne.n	32208210 <_vfprintf_r+0x1298>
32208228:	9a05      	ldr	r2, [sp, #20]
3220822a:	ab50      	add	r3, sp, #320	@ 0x140
3220822c:	1b5b      	subs	r3, r3, r5
3220822e:	930b      	str	r3, [sp, #44]	@ 0x2c
32208230:	429a      	cmp	r2, r3
32208232:	bfb8      	it	lt
32208234:	461a      	movlt	r2, r3
32208236:	9204      	str	r2, [sp, #16]
32208238:	f7ff ba6d 	b.w	32207716 <_vfprintf_r+0x79e>
3220823c:	9903      	ldr	r1, [sp, #12]
3220823e:	aa24      	add	r2, sp, #144	@ 0x90
32208240:	4658      	mov	r0, fp
32208242:	f7fb f969 	bl	32203518 <__sprint_r>
32208246:	2800      	cmp	r0, #0
32208248:	f47e afe8 	bne.w	3220721c <_vfprintf_r+0x2a4>
3220824c:	9a26      	ldr	r2, [sp, #152]	@ 0x98
3220824e:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208252:	f7ff b998 	b.w	32207586 <_vfprintf_r+0x60e>
32208256:	786c      	ldrb	r4, [r5, #1]
32208258:	f443 7300 	orr.w	r3, r3, #512	@ 0x200
3220825c:	3501      	adds	r5, #1
3220825e:	9302      	str	r3, [sp, #8]
32208260:	f7fe bf08 	b.w	32207074 <_vfprintf_r+0xfc>
32208264:	786c      	ldrb	r4, [r5, #1]
32208266:	f043 0320 	orr.w	r3, r3, #32
3220826a:	3501      	adds	r5, #1
3220826c:	9302      	str	r3, [sp, #8]
3220826e:	f7fe bf01 	b.w	32207074 <_vfprintf_r+0xfc>
32208272:	9b05      	ldr	r3, [sp, #20]
32208274:	462a      	mov	r2, r5
32208276:	9505      	str	r5, [sp, #20]
32208278:	2b06      	cmp	r3, #6
3220827a:	9509      	str	r5, [sp, #36]	@ 0x24
3220827c:	bf28      	it	cs
3220827e:	2306      	movcs	r3, #6
32208280:	f64b 2518 	movw	r5, #47640	@ 0xba18
32208284:	f2c3 2520 	movt	r5, #12832	@ 0x3220
32208288:	9304      	str	r3, [sp, #16]
3220828a:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
3220828e:	930b      	str	r3, [sp, #44]	@ 0x2c
32208290:	9210      	str	r2, [sp, #64]	@ 0x40
32208292:	920e      	str	r2, [sp, #56]	@ 0x38
32208294:	920c      	str	r2, [sp, #48]	@ 0x30
32208296:	f7fe bffc 	b.w	32207292 <_vfprintf_r+0x31a>
3220829a:	2208      	movs	r2, #8
3220829c:	2100      	movs	r1, #0
3220829e:	a822      	add	r0, sp, #136	@ 0x88
322082a0:	ad37      	add	r5, sp, #220	@ 0xdc
322082a2:	f7fb ff61 	bl	32204168 <memset>
322082a6:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322082a8:	4629      	mov	r1, r5
322082aa:	4658      	mov	r0, fp
322082ac:	681a      	ldr	r2, [r3, #0]
322082ae:	ab22      	add	r3, sp, #136	@ 0x88
322082b0:	f7fe fdee 	bl	32206e90 <_wcrtomb_r>
322082b4:	4603      	mov	r3, r0
322082b6:	3301      	adds	r3, #1
322082b8:	900b      	str	r0, [sp, #44]	@ 0x2c
322082ba:	f000 8734 	beq.w	32209126 <_vfprintf_r+0x21ae>
322082be:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
322082c0:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
322082c4:	9304      	str	r3, [sp, #16]
322082c6:	f7ff b99e 	b.w	32207606 <_vfprintf_r+0x68e>
322082ca:	9902      	ldr	r1, [sp, #8]
322082cc:	f855 3b04 	ldr.w	r3, [r5], #4
322082d0:	f011 0110 	ands.w	r1, r1, #16
322082d4:	f47f af67 	bne.w	322081a6 <_vfprintf_r+0x122e>
322082d8:	9a02      	ldr	r2, [sp, #8]
322082da:	f012 0640 	ands.w	r6, r2, #64	@ 0x40
322082de:	f000 81af 	beq.w	32208640 <_vfprintf_r+0x16c8>
322082e2:	b29b      	uxth	r3, r3
322082e4:	460a      	mov	r2, r1
322082e6:	e75e      	b.n	322081a6 <_vfprintf_r+0x122e>
322082e8:	9903      	ldr	r1, [sp, #12]
322082ea:	aa24      	add	r2, sp, #144	@ 0x90
322082ec:	4658      	mov	r0, fp
322082ee:	f7fb f913 	bl	32203518 <__sprint_r>
322082f2:	2800      	cmp	r0, #0
322082f4:	f47e af92 	bne.w	3220721c <_vfprintf_r+0x2a4>
322082f8:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
322082fc:	a827      	add	r0, sp, #156	@ 0x9c
322082fe:	e41b      	b.n	32207b38 <_vfprintf_r+0xbc0>
32208300:	9903      	ldr	r1, [sp, #12]
32208302:	aa24      	add	r2, sp, #144	@ 0x90
32208304:	4658      	mov	r0, fp
32208306:	f7fb f907 	bl	32203518 <__sprint_r>
3220830a:	2800      	cmp	r0, #0
3220830c:	f47e af86 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208310:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32208314:	a827      	add	r0, sp, #156	@ 0x9c
32208316:	e402      	b.n	32207b1e <_vfprintf_r+0xba6>
32208318:	f421 6180 	bic.w	r1, r1, #1024	@ 0x400
3220831c:	9102      	str	r1, [sp, #8]
3220831e:	9902      	ldr	r1, [sp, #8]
32208320:	f04f 0c00 	mov.w	ip, #0
32208324:	950a      	str	r5, [sp, #40]	@ 0x28
32208326:	f001 0102 	and.w	r1, r1, #2
3220832a:	910c      	str	r1, [sp, #48]	@ 0x30
3220832c:	e76f      	b.n	3220820e <_vfprintf_r+0x1296>
3220832e:	9903      	ldr	r1, [sp, #12]
32208330:	aa24      	add	r2, sp, #144	@ 0x90
32208332:	4658      	mov	r0, fp
32208334:	f7fb f8f0 	bl	32203518 <__sprint_r>
32208338:	2800      	cmp	r0, #0
3220833a:	f47e af6f 	bne.w	3220721c <_vfprintf_r+0x2a4>
3220833e:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32208342:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32208344:	2b00      	cmp	r3, #0
32208346:	f000 813c 	beq.w	322085c2 <_vfprintf_r+0x164a>
3220834a:	4656      	mov	r6, sl
3220834c:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208350:	4682      	mov	sl, r0
32208352:	9825      	ldr	r0, [sp, #148]	@ 0x94
32208354:	f7fe bfa9 	b.w	322072aa <_vfprintf_r+0x332>
32208358:	2130      	movs	r1, #48	@ 0x30
3220835a:	f88d 1068 	strb.w	r1, [sp, #104]	@ 0x68
3220835e:	2100      	movs	r1, #0
32208360:	f88d 1067 	strb.w	r1, [sp, #103]	@ 0x67
32208364:	9905      	ldr	r1, [sp, #20]
32208366:	f88d 4069 	strb.w	r4, [sp, #105]	@ 0x69
3220836a:	2900      	cmp	r1, #0
3220836c:	f2c0 83eb 	blt.w	32208b46 <_vfprintf_r+0x1bce>
32208370:	9902      	ldr	r1, [sp, #8]
32208372:	f421 6190 	bic.w	r1, r1, #1152	@ 0x480
32208376:	f041 0102 	orr.w	r1, r1, #2
3220837a:	9102      	str	r1, [sp, #8]
3220837c:	f7ff ba25 	b.w	322077ca <_vfprintf_r+0x852>
32208380:	4658      	mov	r0, fp
32208382:	f7fb fb2b 	bl	322039dc <__sinit>
32208386:	f7fe be17 	b.w	32206fb8 <_vfprintf_r+0x40>
3220838a:	9a05      	ldr	r2, [sp, #20]
3220838c:	3802      	subs	r0, #2
3220838e:	2330      	movs	r3, #48	@ 0x30
32208390:	f805 3c01 	strb.w	r3, [r5, #-1]
32208394:	ab50      	add	r3, sp, #320	@ 0x140
32208396:	4605      	mov	r5, r0
32208398:	1a1b      	subs	r3, r3, r0
3220839a:	930b      	str	r3, [sp, #44]	@ 0x2c
3220839c:	429a      	cmp	r2, r3
3220839e:	bfb8      	it	lt
322083a0:	461a      	movlt	r2, r3
322083a2:	9204      	str	r2, [sp, #16]
322083a4:	f7ff ba91 	b.w	322078ca <_vfprintf_r+0x952>
322083a8:	9903      	ldr	r1, [sp, #12]
322083aa:	aa24      	add	r2, sp, #144	@ 0x90
322083ac:	4658      	mov	r0, fp
322083ae:	f7fb f8b3 	bl	32203518 <__sprint_r>
322083b2:	2800      	cmp	r0, #0
322083b4:	f47e af32 	bne.w	3220721c <_vfprintf_r+0x2a4>
322083b8:	9a26      	ldr	r2, [sp, #152]	@ 0x98
322083ba:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
322083be:	f7ff b8cf 	b.w	32207560 <_vfprintf_r+0x5e8>
322083c2:	f10d 0a88 	add.w	sl, sp, #136	@ 0x88
322083c6:	2208      	movs	r2, #8
322083c8:	2100      	movs	r1, #0
322083ca:	4650      	mov	r0, sl
322083cc:	951d      	str	r5, [sp, #116]	@ 0x74
322083ce:	f7fb fecb 	bl	32204168 <memset>
322083d2:	9b05      	ldr	r3, [sp, #20]
322083d4:	2b00      	cmp	r3, #0
322083d6:	f2c0 83a7 	blt.w	32208b28 <_vfprintf_r+0x1bb0>
322083da:	2600      	movs	r6, #0
322083dc:	f8cd 9010 	str.w	r9, [sp, #16]
322083e0:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
322083e4:	4699      	mov	r9, r3
322083e6:	46b0      	mov	r8, r6
322083e8:	e00d      	b.n	32208406 <_vfprintf_r+0x148e>
322083ea:	a937      	add	r1, sp, #220	@ 0xdc
322083ec:	4658      	mov	r0, fp
322083ee:	f7fe fd4f 	bl	32206e90 <_wcrtomb_r>
322083f2:	3604      	adds	r6, #4
322083f4:	1c43      	adds	r3, r0, #1
322083f6:	4440      	add	r0, r8
322083f8:	f000 851f 	beq.w	32208e3a <_vfprintf_r+0x1ec2>
322083fc:	4548      	cmp	r0, r9
322083fe:	dc07      	bgt.n	32208410 <_vfprintf_r+0x1498>
32208400:	f000 8526 	beq.w	32208e50 <_vfprintf_r+0x1ed8>
32208404:	4680      	mov	r8, r0
32208406:	9a1d      	ldr	r2, [sp, #116]	@ 0x74
32208408:	4653      	mov	r3, sl
3220840a:	5992      	ldr	r2, [r2, r6]
3220840c:	2a00      	cmp	r2, #0
3220840e:	d1ec      	bne.n	322083ea <_vfprintf_r+0x1472>
32208410:	f8cd 802c 	str.w	r8, [sp, #44]	@ 0x2c
32208414:	f8dd 9010 	ldr.w	r9, [sp, #16]
32208418:	f8dd 8024 	ldr.w	r8, [sp, #36]	@ 0x24
3220841c:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
3220841e:	2b00      	cmp	r3, #0
32208420:	f000 83aa 	beq.w	32208b78 <_vfprintf_r+0x1c00>
32208424:	2b63      	cmp	r3, #99	@ 0x63
32208426:	f340 8487 	ble.w	32208d38 <_vfprintf_r+0x1dc0>
3220842a:	1c59      	adds	r1, r3, #1
3220842c:	4658      	mov	r0, fp
3220842e:	f7fd fbab 	bl	32205b88 <_malloc_r>
32208432:	4605      	mov	r5, r0
32208434:	2800      	cmp	r0, #0
32208436:	f000 86ba 	beq.w	322091ae <_vfprintf_r+0x2236>
3220843a:	9009      	str	r0, [sp, #36]	@ 0x24
3220843c:	2208      	movs	r2, #8
3220843e:	2100      	movs	r1, #0
32208440:	4650      	mov	r0, sl
32208442:	f7fb fe91 	bl	32204168 <memset>
32208446:	9e0b      	ldr	r6, [sp, #44]	@ 0x2c
32208448:	aa1d      	add	r2, sp, #116	@ 0x74
3220844a:	4629      	mov	r1, r5
3220844c:	4633      	mov	r3, r6
3220844e:	4658      	mov	r0, fp
32208450:	f8cd a000 	str.w	sl, [sp]
32208454:	f7fe fd66 	bl	32206f24 <_wcsrtombs_r>
32208458:	4286      	cmp	r6, r0
3220845a:	f040 86a2 	bne.w	322091a2 <_vfprintf_r+0x222a>
3220845e:	9a0b      	ldr	r2, [sp, #44]	@ 0x2c
32208460:	2300      	movs	r3, #0
32208462:	54ab      	strb	r3, [r5, r2]
32208464:	ea22 72e2 	bic.w	r2, r2, r2, asr #31
32208468:	9204      	str	r2, [sp, #16]
3220846a:	f89d 2067 	ldrb.w	r2, [sp, #103]	@ 0x67
3220846e:	2a00      	cmp	r2, #0
32208470:	f040 84ab 	bne.w	32208dca <_vfprintf_r+0x1e52>
32208474:	9205      	str	r2, [sp, #20]
32208476:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
3220847a:	9210      	str	r2, [sp, #64]	@ 0x40
3220847c:	920e      	str	r2, [sp, #56]	@ 0x38
3220847e:	920c      	str	r2, [sp, #48]	@ 0x30
32208480:	f7fe bf07 	b.w	32207292 <_vfprintf_r+0x31a>
32208484:	46b2      	mov	sl, r6
32208486:	3301      	adds	r3, #1
32208488:	4422      	add	r2, r4
3220848a:	f8c9 a000 	str.w	sl, [r9]
3220848e:	2b07      	cmp	r3, #7
32208490:	f8c9 4004 	str.w	r4, [r9, #4]
32208494:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32208498:	f77e af44 	ble.w	32207324 <_vfprintf_r+0x3ac>
3220849c:	f7ff bb6d 	b.w	32207b7a <_vfprintf_r+0xc02>
322084a0:	9b02      	ldr	r3, [sp, #8]
322084a2:	f64c 4ecd 	movw	lr, #52429	@ 0xcccd
322084a6:	f6cc 4ecc 	movt	lr, #52428	@ 0xcccc
322084aa:	9409      	str	r4, [sp, #36]	@ 0x24
322084ac:	f403 6580 	and.w	r5, r3, #1024	@ 0x400
322084b0:	2300      	movs	r3, #0
322084b2:	4674      	mov	r4, lr
322084b4:	f8cd b02c 	str.w	fp, [sp, #44]	@ 0x2c
322084b8:	a950      	add	r1, sp, #320	@ 0x140
322084ba:	f8dd b05c 	ldr.w	fp, [sp, #92]	@ 0x5c
322084be:	469e      	mov	lr, r3
322084c0:	f8cd 9010 	str.w	r9, [sp, #16]
322084c4:	e024      	b.n	32208510 <_vfprintf_r+0x1598>
322084c6:	eb16 0308 	adds.w	r3, r6, r8
322084ca:	4640      	mov	r0, r8
322084cc:	f143 0300 	adc.w	r3, r3, #0
322084d0:	46b2      	mov	sl, r6
322084d2:	4649      	mov	r1, r9
322084d4:	fba4 2c03 	umull	r2, ip, r4, r3
322084d8:	f02c 0203 	bic.w	r2, ip, #3
322084dc:	eb02 029c 	add.w	r2, r2, ip, lsr #2
322084e0:	1a9b      	subs	r3, r3, r2
322084e2:	f04f 32cc 	mov.w	r2, #3435973836	@ 0xcccccccc
322084e6:	1af3      	subs	r3, r6, r3
322084e8:	f168 0800 	sbc.w	r8, r8, #0
322084ec:	f1ba 0f0a 	cmp.w	sl, #10
322084f0:	f170 0000 	sbcs.w	r0, r0, #0
322084f4:	fb02 f203 	mul.w	r2, r2, r3
322084f8:	fb04 2208 	mla	r2, r4, r8, r2
322084fc:	fba3 6304 	umull	r6, r3, r3, r4
32208500:	4413      	add	r3, r2
32208502:	ea4f 0656 	mov.w	r6, r6, lsr #1
32208506:	ea46 76c3 	orr.w	r6, r6, r3, lsl #31
3220850a:	ea4f 0853 	mov.w	r8, r3, lsr #1
3220850e:	d331      	bcc.n	32208574 <_vfprintf_r+0x15fc>
32208510:	eb16 0308 	adds.w	r3, r6, r8
32208514:	f10e 0e01 	add.w	lr, lr, #1
32208518:	f143 0300 	adc.w	r3, r3, #0
3220851c:	f101 39ff 	add.w	r9, r1, #4294967295	@ 0xffffffff
32208520:	fba4 2003 	umull	r2, r0, r4, r3
32208524:	f020 0203 	bic.w	r2, r0, #3
32208528:	eb02 0290 	add.w	r2, r2, r0, lsr #2
3220852c:	1a9b      	subs	r3, r3, r2
3220852e:	1af3      	subs	r3, r6, r3
32208530:	f168 0000 	sbc.w	r0, r8, #0
32208534:	fba3 3204 	umull	r3, r2, r3, r4
32208538:	085b      	lsrs	r3, r3, #1
3220853a:	fb04 2200 	mla	r2, r4, r0, r2
3220853e:	ea43 73c2 	orr.w	r3, r3, r2, lsl #31
32208542:	eb03 0383 	add.w	r3, r3, r3, lsl #2
32208546:	eba6 0343 	sub.w	r3, r6, r3, lsl #1
3220854a:	3330      	adds	r3, #48	@ 0x30
3220854c:	f801 3c01 	strb.w	r3, [r1, #-1]
32208550:	2d00      	cmp	r5, #0
32208552:	d0b8      	beq.n	322084c6 <_vfprintf_r+0x154e>
32208554:	f89b 3000 	ldrb.w	r3, [fp]
32208558:	f1b3 02ff 	subs.w	r2, r3, #255	@ 0xff
3220855c:	bf18      	it	ne
3220855e:	2201      	movne	r2, #1
32208560:	4573      	cmp	r3, lr
32208562:	bf18      	it	ne
32208564:	2200      	movne	r2, #0
32208566:	2a00      	cmp	r2, #0
32208568:	d0ad      	beq.n	322084c6 <_vfprintf_r+0x154e>
3220856a:	2e0a      	cmp	r6, #10
3220856c:	f178 0300 	sbcs.w	r3, r8, #0
32208570:	f080 835e 	bcs.w	32208c30 <_vfprintf_r+0x1cb8>
32208574:	9a05      	ldr	r2, [sp, #20]
32208576:	464d      	mov	r5, r9
32208578:	ab50      	add	r3, sp, #320	@ 0x140
3220857a:	f8dd 9010 	ldr.w	r9, [sp, #16]
3220857e:	1b5b      	subs	r3, r3, r5
32208580:	f8cd b05c 	str.w	fp, [sp, #92]	@ 0x5c
32208584:	429a      	cmp	r2, r3
32208586:	f8dd b02c 	ldr.w	fp, [sp, #44]	@ 0x2c
3220858a:	bfb8      	it	lt
3220858c:	461a      	movlt	r2, r3
3220858e:	930b      	str	r3, [sp, #44]	@ 0x2c
32208590:	9c09      	ldr	r4, [sp, #36]	@ 0x24
32208592:	2300      	movs	r3, #0
32208594:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
32208598:	f8cd e03c 	str.w	lr, [sp, #60]	@ 0x3c
3220859c:	9204      	str	r2, [sp, #16]
3220859e:	930c      	str	r3, [sp, #48]	@ 0x30
322085a0:	f7ff b8b9 	b.w	32207716 <_vfprintf_r+0x79e>
322085a4:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
322085a6:	9907      	ldr	r1, [sp, #28]
322085a8:	6812      	ldr	r2, [r2, #0]
322085aa:	6011      	str	r1, [r2, #0]
322085ac:	f7ff b956 	b.w	3220785c <_vfprintf_r+0x8e4>
322085b0:	46aa      	mov	sl, r5
322085b2:	3301      	adds	r3, #1
322085b4:	f8c0 a000 	str.w	sl, [r0]
322085b8:	f7ff bac9 	b.w	32207b4e <_vfprintf_r+0xbd6>
322085bc:	2478      	movs	r4, #120	@ 0x78
322085be:	950a      	str	r5, [sp, #40]	@ 0x28
322085c0:	e481      	b.n	32207ec6 <_vfprintf_r+0xf4e>
322085c2:	f1ba 0f00 	cmp.w	sl, #0
322085c6:	f000 8102 	beq.w	322087ce <_vfprintf_r+0x1856>
322085ca:	9825      	ldr	r0, [sp, #148]	@ 0x94
322085cc:	469a      	mov	sl, r3
322085ce:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
322085d2:	f7fe be7c 	b.w	322072ce <_vfprintf_r+0x356>
322085d6:	f64b 7ae0 	movw	sl, #49120	@ 0xbfe0
322085da:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
322085de:	9b25      	ldr	r3, [sp, #148]	@ 0x94
322085e0:	2c10      	cmp	r4, #16
322085e2:	f340 80da 	ble.w	3220879a <_vfprintf_r+0x1822>
322085e6:	4651      	mov	r1, sl
322085e8:	f8dd 800c 	ldr.w	r8, [sp, #12]
322085ec:	46aa      	mov	sl, r5
322085ee:	2610      	movs	r6, #16
322085f0:	460d      	mov	r5, r1
322085f2:	e003      	b.n	322085fc <_vfprintf_r+0x1684>
322085f4:	3c10      	subs	r4, #16
322085f6:	2c10      	cmp	r4, #16
322085f8:	f340 80cc 	ble.w	32208794 <_vfprintf_r+0x181c>
322085fc:	3301      	adds	r3, #1
322085fe:	3210      	adds	r2, #16
32208600:	e9c9 5600 	strd	r5, r6, [r9]
32208604:	2b07      	cmp	r3, #7
32208606:	f109 0908 	add.w	r9, r9, #8
3220860a:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
3220860e:	ddf1      	ble.n	322085f4 <_vfprintf_r+0x167c>
32208610:	aa24      	add	r2, sp, #144	@ 0x90
32208612:	4641      	mov	r1, r8
32208614:	4658      	mov	r0, fp
32208616:	f7fa ff7f 	bl	32203518 <__sprint_r>
3220861a:	2800      	cmp	r0, #0
3220861c:	f47e adfe 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208620:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32208624:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208628:	e7e4      	b.n	322085f4 <_vfprintf_r+0x167c>
3220862a:	9d02      	ldr	r5, [sp, #8]
3220862c:	f415 7100 	ands.w	r1, r5, #512	@ 0x200
32208630:	f000 80f9 	beq.w	32208826 <_vfprintf_r+0x18ae>
32208634:	4601      	mov	r1, r0
32208636:	b2d2      	uxtb	r2, r2
32208638:	4628      	mov	r0, r5
3220863a:	930a      	str	r3, [sp, #40]	@ 0x28
3220863c:	f7ff b8db 	b.w	322077f6 <_vfprintf_r+0x87e>
32208640:	9a02      	ldr	r2, [sp, #8]
32208642:	f412 7200 	ands.w	r2, r2, #512	@ 0x200
32208646:	f43f adae 	beq.w	322081a6 <_vfprintf_r+0x122e>
3220864a:	b2db      	uxtb	r3, r3
3220864c:	4632      	mov	r2, r6
3220864e:	e5aa      	b.n	322081a6 <_vfprintf_r+0x122e>
32208650:	9802      	ldr	r0, [sp, #8]
32208652:	f410 7800 	ands.w	r8, r0, #512	@ 0x200
32208656:	f000 80d3 	beq.w	32208800 <_vfprintf_r+0x1888>
3220865a:	b2d6      	uxtb	r6, r2
3220865c:	9a05      	ldr	r2, [sp, #20]
3220865e:	4688      	mov	r8, r1
32208660:	f88d 1067 	strb.w	r1, [sp, #103]	@ 0x67
32208664:	2a00      	cmp	r2, #0
32208666:	f6bf ad83 	bge.w	32208170 <_vfprintf_r+0x11f8>
3220866a:	930a      	str	r3, [sp, #40]	@ 0x28
3220866c:	f7ff b83d 	b.w	322076ea <_vfprintf_r+0x772>
32208670:	9a02      	ldr	r2, [sp, #8]
32208672:	0595      	lsls	r5, r2, #22
32208674:	f140 80b8 	bpl.w	322087e8 <_vfprintf_r+0x1870>
32208678:	b276      	sxtb	r6, r6
3220867a:	930a      	str	r3, [sp, #40]	@ 0x28
3220867c:	ea4f 78e6 	mov.w	r8, r6, asr #31
32208680:	4643      	mov	r3, r8
32208682:	f7fe bec7 	b.w	32207414 <_vfprintf_r+0x49c>
32208686:	9b02      	ldr	r3, [sp, #8]
32208688:	9a05      	ldr	r2, [sp, #20]
3220868a:	f443 7a80 	orr.w	sl, r3, #256	@ 0x100
3220868e:	ee18 3a90 	vmov	r3, s17
32208692:	1c51      	adds	r1, r2, #1
32208694:	f000 80f0 	beq.w	32208878 <_vfprintf_r+0x1900>
32208698:	2a00      	cmp	r2, #0
3220869a:	bf08      	it	eq
3220869c:	2e47      	cmpeq	r6, #71	@ 0x47
3220869e:	bf08      	it	eq
322086a0:	2201      	moveq	r2, #1
322086a2:	bf18      	it	ne
322086a4:	2200      	movne	r2, #0
322086a6:	f000 84d4 	beq.w	32209052 <_vfprintf_r+0x20da>
322086aa:	eeb0 9b48 	vmov.f64	d9, d8
322086ae:	4690      	mov	r8, r2
322086b0:	2b00      	cmp	r3, #0
322086b2:	da03      	bge.n	322086bc <_vfprintf_r+0x1744>
322086b4:	eeb1 9b48 	vneg.f64	d9, d8
322086b8:	f04f 082d 	mov.w	r8, #45	@ 0x2d
322086bc:	2c65      	cmp	r4, #101	@ 0x65
322086be:	f000 8306 	beq.w	32208cce <_vfprintf_r+0x1d56>
322086c2:	f300 80f7 	bgt.w	322088b4 <_vfprintf_r+0x193c>
322086c6:	2c45      	cmp	r4, #69	@ 0x45
322086c8:	f000 8301 	beq.w	32208cce <_vfprintf_r+0x1d56>
322086cc:	2c46      	cmp	r4, #70	@ 0x46
322086ce:	f040 80f4 	bne.w	322088ba <_vfprintf_r+0x1942>
322086d2:	9b05      	ldr	r3, [sp, #20]
322086d4:	2103      	movs	r1, #3
322086d6:	930f      	str	r3, [sp, #60]	@ 0x3c
322086d8:	ab22      	add	r3, sp, #136	@ 0x88
322086da:	eeb0 0b49 	vmov.f64	d0, d9
322086de:	9301      	str	r3, [sp, #4]
322086e0:	4658      	mov	r0, fp
322086e2:	ab1d      	add	r3, sp, #116	@ 0x74
322086e4:	9a0f      	ldr	r2, [sp, #60]	@ 0x3c
322086e6:	9300      	str	r3, [sp, #0]
322086e8:	ab1b      	add	r3, sp, #108	@ 0x6c
322086ea:	f001 fa8d 	bl	32209c08 <_dtoa_r>
322086ee:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
322086f0:	4605      	mov	r5, r0
322086f2:	2e46      	cmp	r6, #70	@ 0x46
322086f4:	eb00 0103 	add.w	r1, r0, r3
322086f8:	f040 8455 	bne.w	32208fa6 <_vfprintf_r+0x202e>
322086fc:	782b      	ldrb	r3, [r5, #0]
322086fe:	2b30      	cmp	r3, #48	@ 0x30
32208700:	f000 8468 	beq.w	32208fd4 <_vfprintf_r+0x205c>
32208704:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32208706:	eeb5 9b40 	vcmp.f64	d9, #0.0
3220870a:	4419      	add	r1, r3
3220870c:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32208710:	f000 845a 	beq.w	32208fc8 <_vfprintf_r+0x2050>
32208714:	9b22      	ldr	r3, [sp, #136]	@ 0x88
32208716:	4299      	cmp	r1, r3
32208718:	f240 8535 	bls.w	32209186 <_vfprintf_r+0x220e>
3220871c:	2030      	movs	r0, #48	@ 0x30
3220871e:	1c5a      	adds	r2, r3, #1
32208720:	9222      	str	r2, [sp, #136]	@ 0x88
32208722:	7018      	strb	r0, [r3, #0]
32208724:	9b22      	ldr	r3, [sp, #136]	@ 0x88
32208726:	428b      	cmp	r3, r1
32208728:	d3f9      	bcc.n	3220871e <_vfprintf_r+0x17a6>
3220872a:	9a1b      	ldr	r2, [sp, #108]	@ 0x6c
3220872c:	1b5b      	subs	r3, r3, r5
3220872e:	2e47      	cmp	r6, #71	@ 0x47
32208730:	920c      	str	r2, [sp, #48]	@ 0x30
32208732:	930f      	str	r3, [sp, #60]	@ 0x3c
32208734:	f000 80d7 	beq.w	322088e6 <_vfprintf_r+0x196e>
32208738:	2e46      	cmp	r6, #70	@ 0x46
3220873a:	f040 80e3 	bne.w	32208904 <_vfprintf_r+0x198c>
3220873e:	9b02      	ldr	r3, [sp, #8]
32208740:	9a05      	ldr	r2, [sp, #20]
32208742:	990c      	ldr	r1, [sp, #48]	@ 0x30
32208744:	f003 0301 	and.w	r3, r3, #1
32208748:	4313      	orrs	r3, r2
3220874a:	2900      	cmp	r1, #0
3220874c:	f340 84d9 	ble.w	32209102 <_vfprintf_r+0x218a>
32208750:	2b00      	cmp	r3, #0
32208752:	f040 83a9 	bne.w	32208ea8 <_vfprintf_r+0x1f30>
32208756:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32208758:	2466      	movs	r4, #102	@ 0x66
3220875a:	930b      	str	r3, [sp, #44]	@ 0x2c
3220875c:	9b02      	ldr	r3, [sp, #8]
3220875e:	055b      	lsls	r3, r3, #21
32208760:	f100 83d3 	bmi.w	32208f0a <_vfprintf_r+0x1f92>
32208764:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32208766:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
3220876a:	9304      	str	r3, [sp, #16]
3220876c:	f1b8 0f00 	cmp.w	r8, #0
32208770:	f000 82b2 	beq.w	32208cd8 <_vfprintf_r+0x1d60>
32208774:	9b04      	ldr	r3, [sp, #16]
32208776:	f8cd a008 	str.w	sl, [sp, #8]
3220877a:	3301      	adds	r3, #1
3220877c:	9304      	str	r3, [sp, #16]
3220877e:	2300      	movs	r3, #0
32208780:	9309      	str	r3, [sp, #36]	@ 0x24
32208782:	461a      	mov	r2, r3
32208784:	232d      	movs	r3, #45	@ 0x2d
32208786:	9205      	str	r2, [sp, #20]
32208788:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
3220878c:	9210      	str	r2, [sp, #64]	@ 0x40
3220878e:	920e      	str	r2, [sp, #56]	@ 0x38
32208790:	f7fe bd7f 	b.w	32207292 <_vfprintf_r+0x31a>
32208794:	4629      	mov	r1, r5
32208796:	4655      	mov	r5, sl
32208798:	468a      	mov	sl, r1
3220879a:	3301      	adds	r3, #1
3220879c:	4422      	add	r2, r4
3220879e:	f8c9 a000 	str.w	sl, [r9]
322087a2:	2b07      	cmp	r3, #7
322087a4:	f8c9 4004 	str.w	r4, [r9, #4]
322087a8:	f109 0908 	add.w	r9, r9, #8
322087ac:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
322087b0:	f77f aabd 	ble.w	32207d2e <_vfprintf_r+0xdb6>
322087b4:	9903      	ldr	r1, [sp, #12]
322087b6:	aa24      	add	r2, sp, #144	@ 0x90
322087b8:	4658      	mov	r0, fp
322087ba:	f7fa fead 	bl	32203518 <__sprint_r>
322087be:	2800      	cmp	r0, #0
322087c0:	f47e ad2c 	bne.w	3220721c <_vfprintf_r+0x2a4>
322087c4:	9a26      	ldr	r2, [sp, #152]	@ 0x98
322087c6:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
322087ca:	f7ff bab0 	b.w	32207d2e <_vfprintf_r+0xdb6>
322087ce:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
322087d2:	f7fe bd90 	b.w	322072f6 <_vfprintf_r+0x37e>
322087d6:	441d      	add	r5, r3
322087d8:	1b1c      	subs	r4, r3, r4
322087da:	eba5 0508 	sub.w	r5, r5, r8
322087de:	42a5      	cmp	r5, r4
322087e0:	bfa8      	it	ge
322087e2:	4625      	movge	r5, r4
322087e4:	f7ff bad8 	b.w	32207d98 <_vfprintf_r+0xe20>
322087e8:	ea4f 78e6 	mov.w	r8, r6, asr #31
322087ec:	930a      	str	r3, [sp, #40]	@ 0x28
322087ee:	4643      	mov	r3, r8
322087f0:	f7fe be10 	b.w	32207414 <_vfprintf_r+0x49c>
322087f4:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
322087f6:	9907      	ldr	r1, [sp, #28]
322087f8:	6812      	ldr	r2, [r2, #0]
322087fa:	8011      	strh	r1, [r2, #0]
322087fc:	f7ff b82e 	b.w	3220785c <_vfprintf_r+0x8e4>
32208800:	9905      	ldr	r1, [sp, #20]
32208802:	4616      	mov	r6, r2
32208804:	f88d 8067 	strb.w	r8, [sp, #103]	@ 0x67
32208808:	2900      	cmp	r1, #0
3220880a:	f6ff af2e 	blt.w	3220866a <_vfprintf_r+0x16f2>
3220880e:	9802      	ldr	r0, [sp, #8]
32208810:	2a00      	cmp	r2, #0
32208812:	bf08      	it	eq
32208814:	2900      	cmpeq	r1, #0
32208816:	930a      	str	r3, [sp, #40]	@ 0x28
32208818:	f020 0080 	bic.w	r0, r0, #128	@ 0x80
3220881c:	9002      	str	r0, [sp, #8]
3220881e:	f47e af64 	bne.w	322076ea <_vfprintf_r+0x772>
32208822:	f7ff bb50 	b.w	32207ec6 <_vfprintf_r+0xf4e>
32208826:	9802      	ldr	r0, [sp, #8]
32208828:	930a      	str	r3, [sp, #40]	@ 0x28
3220882a:	f7fe bfe4 	b.w	322077f6 <_vfprintf_r+0x87e>
3220882e:	4628      	mov	r0, r5
32208830:	f7fc ff86 	bl	32205740 <strlen>
32208834:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32208838:	ea20 72e0 	bic.w	r2, r0, r0, asr #31
3220883c:	900b      	str	r0, [sp, #44]	@ 0x2c
3220883e:	9204      	str	r2, [sp, #16]
32208840:	2b00      	cmp	r3, #0
32208842:	f47e af1d 	bne.w	32207680 <_vfprintf_r+0x708>
32208846:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32208848:	2473      	movs	r4, #115	@ 0x73
3220884a:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
3220884e:	9305      	str	r3, [sp, #20]
32208850:	9310      	str	r3, [sp, #64]	@ 0x40
32208852:	930e      	str	r3, [sp, #56]	@ 0x38
32208854:	9309      	str	r3, [sp, #36]	@ 0x24
32208856:	f7fe bd1c 	b.w	32207292 <_vfprintf_r+0x31a>
3220885a:	9903      	ldr	r1, [sp, #12]
3220885c:	aa24      	add	r2, sp, #144	@ 0x90
3220885e:	4658      	mov	r0, fp
32208860:	f7fa fe5a 	bl	32203518 <__sprint_r>
32208864:	2800      	cmp	r0, #0
32208866:	f43e acc2 	beq.w	322071ee <_vfprintf_r+0x276>
3220886a:	f7fe bcdd 	b.w	32207228 <_vfprintf_r+0x2b0>
3220886e:	6d88      	ldr	r0, [r1, #88]	@ 0x58
32208870:	f7fc fa7a 	bl	32204d68 <__retarget_lock_release_recursive>
32208874:	f7fe bc8b 	b.w	3220718e <_vfprintf_r+0x216>
32208878:	2b00      	cmp	r3, #0
3220887a:	f2c0 83e2 	blt.w	32209042 <_vfprintf_r+0x20ca>
3220887e:	2306      	movs	r3, #6
32208880:	eeb0 9b48 	vmov.f64	d9, d8
32208884:	f04f 0800 	mov.w	r8, #0
32208888:	9305      	str	r3, [sp, #20]
3220888a:	e717      	b.n	322086bc <_vfprintf_r+0x1744>
3220888c:	1c59      	adds	r1, r3, #1
3220888e:	4658      	mov	r0, fp
32208890:	f7fd f97a 	bl	32205b88 <_malloc_r>
32208894:	4605      	mov	r5, r0
32208896:	2800      	cmp	r0, #0
32208898:	f000 8445 	beq.w	32209126 <_vfprintf_r+0x21ae>
3220889c:	ee18 3a90 	vmov	r3, s17
322088a0:	2b00      	cmp	r3, #0
322088a2:	f2c0 840a 	blt.w	322090ba <_vfprintf_r+0x2142>
322088a6:	eeb0 0b48 	vmov.f64	d0, d8
322088aa:	f04f 0800 	mov.w	r8, #0
322088ae:	9009      	str	r0, [sp, #36]	@ 0x24
322088b0:	f7ff bb97 	b.w	32207fe2 <_vfprintf_r+0x106a>
322088b4:	2c66      	cmp	r4, #102	@ 0x66
322088b6:	f43f af0c 	beq.w	322086d2 <_vfprintf_r+0x175a>
322088ba:	ab22      	add	r3, sp, #136	@ 0x88
322088bc:	eeb0 0b49 	vmov.f64	d0, d9
322088c0:	9301      	str	r3, [sp, #4]
322088c2:	2102      	movs	r1, #2
322088c4:	ab1d      	add	r3, sp, #116	@ 0x74
322088c6:	9a05      	ldr	r2, [sp, #20]
322088c8:	9300      	str	r3, [sp, #0]
322088ca:	4658      	mov	r0, fp
322088cc:	ab1b      	add	r3, sp, #108	@ 0x6c
322088ce:	f001 f99b 	bl	32209c08 <_dtoa_r>
322088d2:	9b02      	ldr	r3, [sp, #8]
322088d4:	4605      	mov	r5, r0
322088d6:	07d8      	lsls	r0, r3, #31
322088d8:	f100 826a 	bmi.w	32208db0 <_vfprintf_r+0x1e38>
322088dc:	9b22      	ldr	r3, [sp, #136]	@ 0x88
322088de:	1b5b      	subs	r3, r3, r5
322088e0:	930f      	str	r3, [sp, #60]	@ 0x3c
322088e2:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
322088e4:	930c      	str	r3, [sp, #48]	@ 0x30
322088e6:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
322088e8:	9a05      	ldr	r2, [sp, #20]
322088ea:	4293      	cmp	r3, r2
322088ec:	bfd8      	it	le
322088ee:	2200      	movle	r2, #0
322088f0:	bfc8      	it	gt
322088f2:	2201      	movgt	r2, #1
322088f4:	1cd9      	adds	r1, r3, #3
322088f6:	bfa8      	it	ge
322088f8:	2300      	movge	r3, #0
322088fa:	bfb8      	it	lt
322088fc:	2301      	movlt	r3, #1
322088fe:	4313      	orrs	r3, r2
32208900:	d046      	beq.n	32208990 <_vfprintf_r+0x1a18>
32208902:	3c02      	subs	r4, #2
32208904:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32208906:	f88d 4078 	strb.w	r4, [sp, #120]	@ 0x78
3220890a:	3b01      	subs	r3, #1
3220890c:	931b      	str	r3, [sp, #108]	@ 0x6c
3220890e:	2b00      	cmp	r3, #0
32208910:	f2c0 82b5 	blt.w	32208e7e <_vfprintf_r+0x1f06>
32208914:	222b      	movs	r2, #43	@ 0x2b
32208916:	2b09      	cmp	r3, #9
32208918:	f88d 2079 	strb.w	r2, [sp, #121]	@ 0x79
3220891c:	f340 82b8 	ble.w	32208e90 <_vfprintf_r+0x1f18>
32208920:	9902      	ldr	r1, [sp, #8]
32208922:	2200      	movs	r2, #0
32208924:	9209      	str	r2, [sp, #36]	@ 0x24
32208926:	f10d 0e8f 	add.w	lr, sp, #143	@ 0x8f
3220892a:	f64c 4ccd 	movw	ip, #52429	@ 0xcccd
3220892e:	f6cc 4ccc 	movt	ip, #52428	@ 0xcccc
32208932:	4672      	mov	r2, lr
32208934:	f04f 0a0a 	mov.w	sl, #10
32208938:	9102      	str	r1, [sp, #8]
3220893a:	4610      	mov	r0, r2
3220893c:	fbac 1203 	umull	r1, r2, ip, r3
32208940:	461e      	mov	r6, r3
32208942:	2e63      	cmp	r6, #99	@ 0x63
32208944:	ea4f 02d2 	mov.w	r2, r2, lsr #3
32208948:	fb0a 3112 	mls	r1, sl, r2, r3
3220894c:	4613      	mov	r3, r2
3220894e:	f100 32ff 	add.w	r2, r0, #4294967295	@ 0xffffffff
32208952:	f101 0130 	add.w	r1, r1, #48	@ 0x30
32208956:	f800 1c01 	strb.w	r1, [r0, #-1]
3220895a:	dcee      	bgt.n	3220893a <_vfprintf_r+0x19c2>
3220895c:	3330      	adds	r3, #48	@ 0x30
3220895e:	f802 3c01 	strb.w	r3, [r2, #-1]
32208962:	1e83      	subs	r3, r0, #2
32208964:	9902      	ldr	r1, [sp, #8]
32208966:	4573      	cmp	r3, lr
32208968:	f080 83c7 	bcs.w	322090fa <_vfprintf_r+0x2182>
3220896c:	f10d 0279 	add.w	r2, sp, #121	@ 0x79
32208970:	f813 6b01 	ldrb.w	r6, [r3], #1
32208974:	f802 6f01 	strb.w	r6, [r2, #1]!
32208978:	4573      	cmp	r3, lr
3220897a:	d1f9      	bne.n	32208970 <_vfprintf_r+0x19f8>
3220897c:	f503 73a0 	add.w	r3, r3, #320	@ 0x140
32208980:	aa1e      	add	r2, sp, #120	@ 0x78
32208982:	446b      	add	r3, sp
32208984:	3bc4      	subs	r3, #196	@ 0xc4
32208986:	1a1b      	subs	r3, r3, r0
32208988:	1a9b      	subs	r3, r3, r2
3220898a:	9314      	str	r3, [sp, #80]	@ 0x50
3220898c:	f7ff bba7 	b.w	322080de <_vfprintf_r+0x1166>
32208990:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32208992:	9a0f      	ldr	r2, [sp, #60]	@ 0x3c
32208994:	4293      	cmp	r3, r2
32208996:	f2c0 81d4 	blt.w	32208d42 <_vfprintf_r+0x1dca>
3220899a:	9b02      	ldr	r3, [sp, #8]
3220899c:	f013 0f01 	tst.w	r3, #1
322089a0:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
322089a2:	f000 827f 	beq.w	32208ea4 <_vfprintf_r+0x1f2c>
322089a6:	9a11      	ldr	r2, [sp, #68]	@ 0x44
322089a8:	4413      	add	r3, r2
322089aa:	930b      	str	r3, [sp, #44]	@ 0x2c
322089ac:	9b02      	ldr	r3, [sp, #8]
322089ae:	055b      	lsls	r3, r3, #21
322089b0:	d503      	bpl.n	322089ba <_vfprintf_r+0x1a42>
322089b2:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
322089b4:	2b00      	cmp	r3, #0
322089b6:	f300 82a7 	bgt.w	32208f08 <_vfprintf_r+0x1f90>
322089ba:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
322089bc:	2467      	movs	r4, #103	@ 0x67
322089be:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
322089c2:	9304      	str	r3, [sp, #16]
322089c4:	e6d2      	b.n	3220876c <_vfprintf_r+0x17f4>
322089c6:	232d      	movs	r3, #45	@ 0x2d
322089c8:	2c47      	cmp	r4, #71	@ 0x47
322089ca:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
322089ce:	f300 81ac 	bgt.w	32208d2a <_vfprintf_r+0x1db2>
322089d2:	f64b 3560 	movw	r5, #47968	@ 0xbb60
322089d6:	f2c3 2520 	movt	r5, #12832	@ 0x3220
322089da:	2300      	movs	r3, #0
322089dc:	9309      	str	r3, [sp, #36]	@ 0x24
322089de:	2203      	movs	r2, #3
322089e0:	9305      	str	r3, [sp, #20]
322089e2:	9310      	str	r3, [sp, #64]	@ 0x40
322089e4:	930e      	str	r3, [sp, #56]	@ 0x38
322089e6:	930c      	str	r3, [sp, #48]	@ 0x30
322089e8:	2304      	movs	r3, #4
322089ea:	920b      	str	r2, [sp, #44]	@ 0x2c
322089ec:	9304      	str	r3, [sp, #16]
322089ee:	f7fe bc50 	b.w	32207292 <_vfprintf_r+0x31a>
322089f2:	9b0e      	ldr	r3, [sp, #56]	@ 0x38
322089f4:	9810      	ldr	r0, [sp, #64]	@ 0x40
322089f6:	4303      	orrs	r3, r0
322089f8:	f000 83cb 	beq.w	32209192 <_vfprintf_r+0x221a>
322089fc:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
322089fe:	4649      	mov	r1, r9
32208a00:	f64b 76e0 	movw	r6, #49120	@ 0xbfe0
32208a04:	f2c3 2620 	movt	r6, #12832	@ 0x3220
32208a08:	f8dd 905c 	ldr.w	r9, [sp, #92]	@ 0x5c
32208a0c:	18eb      	adds	r3, r5, r3
32208a0e:	4682      	mov	sl, r0
32208a10:	9510      	str	r5, [sp, #64]	@ 0x40
32208a12:	e031      	b.n	32208a78 <_vfprintf_r+0x1b00>
32208a14:	f10a 3aff 	add.w	sl, sl, #4294967295	@ 0xffffffff
32208a18:	9815      	ldr	r0, [sp, #84]	@ 0x54
32208a1a:	9c16      	ldr	r4, [sp, #88]	@ 0x58
32208a1c:	4402      	add	r2, r0
32208a1e:	e9c1 4000 	strd	r4, r0, [r1]
32208a22:	9825      	ldr	r0, [sp, #148]	@ 0x94
32208a24:	9226      	str	r2, [sp, #152]	@ 0x98
32208a26:	3001      	adds	r0, #1
32208a28:	9025      	str	r0, [sp, #148]	@ 0x94
32208a2a:	2807      	cmp	r0, #7
32208a2c:	bfd8      	it	le
32208a2e:	3108      	addle	r1, #8
32208a30:	dc4f      	bgt.n	32208ad2 <_vfprintf_r+0x1b5a>
32208a32:	f899 0000 	ldrb.w	r0, [r9]
32208a36:	eba3 0408 	sub.w	r4, r3, r8
32208a3a:	9305      	str	r3, [sp, #20]
32208a3c:	4284      	cmp	r4, r0
32208a3e:	bfa8      	it	ge
32208a40:	4604      	movge	r4, r0
32208a42:	2c00      	cmp	r4, #0
32208a44:	dd0b      	ble.n	32208a5e <_vfprintf_r+0x1ae6>
32208a46:	9825      	ldr	r0, [sp, #148]	@ 0x94
32208a48:	4422      	add	r2, r4
32208a4a:	e9c1 8400 	strd	r8, r4, [r1]
32208a4e:	3001      	adds	r0, #1
32208a50:	9226      	str	r2, [sp, #152]	@ 0x98
32208a52:	2807      	cmp	r0, #7
32208a54:	9025      	str	r0, [sp, #148]	@ 0x94
32208a56:	dc58      	bgt.n	32208b0a <_vfprintf_r+0x1b92>
32208a58:	f899 0000 	ldrb.w	r0, [r9]
32208a5c:	3108      	adds	r1, #8
32208a5e:	ea24 74e4 	bic.w	r4, r4, r4, asr #31
32208a62:	1b04      	subs	r4, r0, r4
32208a64:	2c00      	cmp	r4, #0
32208a66:	dc10      	bgt.n	32208a8a <_vfprintf_r+0x1b12>
32208a68:	9c0e      	ldr	r4, [sp, #56]	@ 0x38
32208a6a:	4480      	add	r8, r0
32208a6c:	4650      	mov	r0, sl
32208a6e:	2c00      	cmp	r4, #0
32208a70:	bfd8      	it	le
32208a72:	2800      	cmple	r0, #0
32208a74:	f340 82f7 	ble.w	32209066 <_vfprintf_r+0x20ee>
32208a78:	f1ba 0f00 	cmp.w	sl, #0
32208a7c:	dcca      	bgt.n	32208a14 <_vfprintf_r+0x1a9c>
32208a7e:	980e      	ldr	r0, [sp, #56]	@ 0x38
32208a80:	f109 39ff 	add.w	r9, r9, #4294967295	@ 0xffffffff
32208a84:	3801      	subs	r0, #1
32208a86:	900e      	str	r0, [sp, #56]	@ 0x38
32208a88:	e7c6      	b.n	32208a18 <_vfprintf_r+0x1aa0>
32208a8a:	f64b 7ce0 	movw	ip, #49120	@ 0xbfe0
32208a8e:	f2c3 2c20 	movt	ip, #12832	@ 0x3220
32208a92:	9825      	ldr	r0, [sp, #148]	@ 0x94
32208a94:	2c10      	cmp	r4, #16
32208a96:	dd2b      	ble.n	32208af0 <_vfprintf_r+0x1b78>
32208a98:	2510      	movs	r5, #16
32208a9a:	e9cd 630b 	strd	r6, r3, [sp, #44]	@ 0x2c
32208a9e:	e002      	b.n	32208aa6 <_vfprintf_r+0x1b2e>
32208aa0:	3c10      	subs	r4, #16
32208aa2:	2c10      	cmp	r4, #16
32208aa4:	dd22      	ble.n	32208aec <_vfprintf_r+0x1b74>
32208aa6:	3001      	adds	r0, #1
32208aa8:	3210      	adds	r2, #16
32208aaa:	2807      	cmp	r0, #7
32208aac:	e9c1 6500 	strd	r6, r5, [r1]
32208ab0:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
32208ab4:	bfd8      	it	le
32208ab6:	3108      	addle	r1, #8
32208ab8:	ddf2      	ble.n	32208aa0 <_vfprintf_r+0x1b28>
32208aba:	9903      	ldr	r1, [sp, #12]
32208abc:	aa24      	add	r2, sp, #144	@ 0x90
32208abe:	4658      	mov	r0, fp
32208ac0:	f7fa fd2a 	bl	32203518 <__sprint_r>
32208ac4:	2800      	cmp	r0, #0
32208ac6:	f47e aba9 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208aca:	e9dd 0225 	ldrd	r0, r2, [sp, #148]	@ 0x94
32208ace:	a927      	add	r1, sp, #156	@ 0x9c
32208ad0:	e7e6      	b.n	32208aa0 <_vfprintf_r+0x1b28>
32208ad2:	9903      	ldr	r1, [sp, #12]
32208ad4:	aa24      	add	r2, sp, #144	@ 0x90
32208ad6:	4658      	mov	r0, fp
32208ad8:	9305      	str	r3, [sp, #20]
32208ada:	f7fa fd1d 	bl	32203518 <__sprint_r>
32208ade:	2800      	cmp	r0, #0
32208ae0:	f47e ab9c 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208ae4:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32208ae6:	a927      	add	r1, sp, #156	@ 0x9c
32208ae8:	9b05      	ldr	r3, [sp, #20]
32208aea:	e7a2      	b.n	32208a32 <_vfprintf_r+0x1aba>
32208aec:	e9dd c30b 	ldrd	ip, r3, [sp, #44]	@ 0x2c
32208af0:	3001      	adds	r0, #1
32208af2:	4422      	add	r2, r4
32208af4:	2807      	cmp	r0, #7
32208af6:	f8c1 c000 	str.w	ip, [r1]
32208afa:	604c      	str	r4, [r1, #4]
32208afc:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
32208b00:	dc57      	bgt.n	32208bb2 <_vfprintf_r+0x1c3a>
32208b02:	f899 0000 	ldrb.w	r0, [r9]
32208b06:	3108      	adds	r1, #8
32208b08:	e7ae      	b.n	32208a68 <_vfprintf_r+0x1af0>
32208b0a:	9903      	ldr	r1, [sp, #12]
32208b0c:	aa24      	add	r2, sp, #144	@ 0x90
32208b0e:	4658      	mov	r0, fp
32208b10:	930b      	str	r3, [sp, #44]	@ 0x2c
32208b12:	f7fa fd01 	bl	32203518 <__sprint_r>
32208b16:	2800      	cmp	r0, #0
32208b18:	f47e ab80 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208b1c:	f899 0000 	ldrb.w	r0, [r9]
32208b20:	a927      	add	r1, sp, #156	@ 0x9c
32208b22:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32208b24:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32208b26:	e79a      	b.n	32208a5e <_vfprintf_r+0x1ae6>
32208b28:	2300      	movs	r3, #0
32208b2a:	aa1d      	add	r2, sp, #116	@ 0x74
32208b2c:	4619      	mov	r1, r3
32208b2e:	4658      	mov	r0, fp
32208b30:	f8cd a000 	str.w	sl, [sp]
32208b34:	f7fe f9f6 	bl	32206f24 <_wcsrtombs_r>
32208b38:	4603      	mov	r3, r0
32208b3a:	3301      	adds	r3, #1
32208b3c:	900b      	str	r0, [sp, #44]	@ 0x2c
32208b3e:	f000 817c 	beq.w	32208e3a <_vfprintf_r+0x1ec2>
32208b42:	951d      	str	r5, [sp, #116]	@ 0x74
32208b44:	e46a      	b.n	3220841c <_vfprintf_r+0x14a4>
32208b46:	9902      	ldr	r1, [sp, #8]
32208b48:	f421 6180 	bic.w	r1, r1, #1024	@ 0x400
32208b4c:	f041 0102 	orr.w	r1, r1, #2
32208b50:	9102      	str	r1, [sp, #8]
32208b52:	f7ff bbe4 	b.w	3220831e <_vfprintf_r+0x13a6>
32208b56:	930a      	str	r3, [sp, #40]	@ 0x28
32208b58:	f7fe bdc6 	b.w	322076e8 <_vfprintf_r+0x770>
32208b5c:	9903      	ldr	r1, [sp, #12]
32208b5e:	aa24      	add	r2, sp, #144	@ 0x90
32208b60:	4658      	mov	r0, fp
32208b62:	f7fa fcd9 	bl	32203518 <__sprint_r>
32208b66:	2800      	cmp	r0, #0
32208b68:	f47e ab58 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208b6c:	991b      	ldr	r1, [sp, #108]	@ 0x6c
32208b6e:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208b72:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32208b74:	f7ff b9cb 	b.w	32207f0e <_vfprintf_r+0xf96>
32208b78:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32208b7c:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
32208b80:	3b00      	subs	r3, #0
32208b82:	bf18      	it	ne
32208b84:	2301      	movne	r3, #1
32208b86:	9304      	str	r3, [sp, #16]
32208b88:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32208b8a:	9305      	str	r3, [sp, #20]
32208b8c:	9310      	str	r3, [sp, #64]	@ 0x40
32208b8e:	930e      	str	r3, [sp, #56]	@ 0x38
32208b90:	930c      	str	r3, [sp, #48]	@ 0x30
32208b92:	9309      	str	r3, [sp, #36]	@ 0x24
32208b94:	f7fe bb7d 	b.w	32207292 <_vfprintf_r+0x31a>
32208b98:	9903      	ldr	r1, [sp, #12]
32208b9a:	aa24      	add	r2, sp, #144	@ 0x90
32208b9c:	4658      	mov	r0, fp
32208b9e:	f7fa fcbb 	bl	32203518 <__sprint_r>
32208ba2:	2800      	cmp	r0, #0
32208ba4:	f47e ab3a 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208ba8:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32208baa:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208bae:	f7ff b8b7 	b.w	32207d20 <_vfprintf_r+0xda8>
32208bb2:	9903      	ldr	r1, [sp, #12]
32208bb4:	aa24      	add	r2, sp, #144	@ 0x90
32208bb6:	4658      	mov	r0, fp
32208bb8:	930b      	str	r3, [sp, #44]	@ 0x2c
32208bba:	f7fa fcad 	bl	32203518 <__sprint_r>
32208bbe:	2800      	cmp	r0, #0
32208bc0:	f47e ab2c 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208bc4:	f899 0000 	ldrb.w	r0, [r9]
32208bc8:	a927      	add	r1, sp, #156	@ 0x9c
32208bca:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32208bcc:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32208bce:	e74b      	b.n	32208a68 <_vfprintf_r+0x1af0>
32208bd0:	9903      	ldr	r1, [sp, #12]
32208bd2:	aa24      	add	r2, sp, #144	@ 0x90
32208bd4:	4658      	mov	r0, fp
32208bd6:	f7fa fc9f 	bl	32203518 <__sprint_r>
32208bda:	2800      	cmp	r0, #0
32208bdc:	f47e ab1e 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208be0:	991b      	ldr	r1, [sp, #108]	@ 0x6c
32208be2:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208be6:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32208bea:	f7ff b9a2 	b.w	32207f32 <_vfprintf_r+0xfba>
32208bee:	9903      	ldr	r1, [sp, #12]
32208bf0:	aa24      	add	r2, sp, #144	@ 0x90
32208bf2:	4658      	mov	r0, fp
32208bf4:	f7fa fc90 	bl	32203518 <__sprint_r>
32208bf8:	2800      	cmp	r0, #0
32208bfa:	f47e ab0f 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208bfe:	9c1b      	ldr	r4, [sp, #108]	@ 0x6c
32208c00:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208c04:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32208c06:	f7ff b8af 	b.w	32207d68 <_vfprintf_r+0xdf0>
32208c0a:	9b02      	ldr	r3, [sp, #8]
32208c0c:	07dc      	lsls	r4, r3, #31
32208c0e:	f57e ab8b 	bpl.w	32207328 <_vfprintf_r+0x3b0>
32208c12:	9b11      	ldr	r3, [sp, #68]	@ 0x44
32208c14:	9912      	ldr	r1, [sp, #72]	@ 0x48
32208c16:	441a      	add	r2, r3
32208c18:	e9c9 1300 	strd	r1, r3, [r9]
32208c1c:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32208c1e:	9226      	str	r2, [sp, #152]	@ 0x98
32208c20:	3301      	adds	r3, #1
32208c22:	9325      	str	r3, [sp, #148]	@ 0x94
32208c24:	2b07      	cmp	r3, #7
32208c26:	dcd3      	bgt.n	32208bd0 <_vfprintf_r+0x1c58>
32208c28:	f109 0908 	add.w	r9, r9, #8
32208c2c:	f7ff b984 	b.w	32207f38 <_vfprintf_r+0xfc0>
32208c30:	9a15      	ldr	r2, [sp, #84]	@ 0x54
32208c32:	9916      	ldr	r1, [sp, #88]	@ 0x58
32208c34:	eba9 0a02 	sub.w	sl, r9, r2
32208c38:	4650      	mov	r0, sl
32208c3a:	f7fb fae3 	bl	32204204 <strncpy>
32208c3e:	f89b 3001 	ldrb.w	r3, [fp, #1]
32208c42:	b10b      	cbz	r3, 32208c48 <_vfprintf_r+0x1cd0>
32208c44:	f10b 0b01 	add.w	fp, fp, #1
32208c48:	eb16 0308 	adds.w	r3, r6, r8
32208c4c:	f64c 42cd 	movw	r2, #52429	@ 0xcccd
32208c50:	f6cc 42cc 	movt	r2, #52428	@ 0xcccc
32208c54:	f143 0300 	adc.w	r3, r3, #0
32208c58:	f04f 31cc 	mov.w	r1, #3435973836	@ 0xcccccccc
32208c5c:	f04f 0e01 	mov.w	lr, #1
32208c60:	f10a 39ff 	add.w	r9, sl, #4294967295	@ 0xffffffff
32208c64:	fba2 0c03 	umull	r0, ip, r2, r3
32208c68:	f02c 0003 	bic.w	r0, ip, #3
32208c6c:	eb00 009c 	add.w	r0, r0, ip, lsr #2
32208c70:	1a1b      	subs	r3, r3, r0
32208c72:	1af3      	subs	r3, r6, r3
32208c74:	f168 0800 	sbc.w	r8, r8, #0
32208c78:	fb03 f101 	mul.w	r1, r3, r1
32208c7c:	fb02 1108 	mla	r1, r2, r8, r1
32208c80:	fba3 3002 	umull	r3, r0, r3, r2
32208c84:	4401      	add	r1, r0
32208c86:	fa23 f30e 	lsr.w	r3, r3, lr
32208c8a:	ea43 76c1 	orr.w	r6, r3, r1, lsl #31
32208c8e:	fa21 f80e 	lsr.w	r8, r1, lr
32208c92:	eb16 0308 	adds.w	r3, r6, r8
32208c96:	f143 0300 	adc.w	r3, r3, #0
32208c9a:	fba2 1003 	umull	r1, r0, r2, r3
32208c9e:	f020 0103 	bic.w	r1, r0, #3
32208ca2:	eb01 0190 	add.w	r1, r1, r0, lsr #2
32208ca6:	1a5b      	subs	r3, r3, r1
32208ca8:	1af3      	subs	r3, r6, r3
32208caa:	f168 0000 	sbc.w	r0, r8, #0
32208cae:	fba3 3102 	umull	r3, r1, r3, r2
32208cb2:	fa23 f30e 	lsr.w	r3, r3, lr
32208cb6:	fb02 1200 	mla	r2, r2, r0, r1
32208cba:	ea43 73c2 	orr.w	r3, r3, r2, lsl #31
32208cbe:	eb03 0383 	add.w	r3, r3, r3, lsl #2
32208cc2:	eba6 0343 	sub.w	r3, r6, r3, lsl #1
32208cc6:	3330      	adds	r3, #48	@ 0x30
32208cc8:	f80a 3c01 	strb.w	r3, [sl, #-1]
32208ccc:	e442      	b.n	32208554 <_vfprintf_r+0x15dc>
32208cce:	9b05      	ldr	r3, [sp, #20]
32208cd0:	2102      	movs	r1, #2
32208cd2:	3301      	adds	r3, #1
32208cd4:	930f      	str	r3, [sp, #60]	@ 0x3c
32208cd6:	e4ff      	b.n	322086d8 <_vfprintf_r+0x1760>
32208cd8:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32208cdc:	2b00      	cmp	r3, #0
32208cde:	f000 81cc 	beq.w	3220907a <_vfprintf_r+0x2102>
32208ce2:	9a04      	ldr	r2, [sp, #16]
32208ce4:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
32208ce8:	3201      	adds	r2, #1
32208cea:	f8cd a008 	str.w	sl, [sp, #8]
32208cee:	9204      	str	r2, [sp, #16]
32208cf0:	f8cd 8014 	str.w	r8, [sp, #20]
32208cf4:	f8cd 8040 	str.w	r8, [sp, #64]	@ 0x40
32208cf8:	f8cd 8038 	str.w	r8, [sp, #56]	@ 0x38
32208cfc:	f7fe bac9 	b.w	32207292 <_vfprintf_r+0x31a>
32208d00:	9903      	ldr	r1, [sp, #12]
32208d02:	aa24      	add	r2, sp, #144	@ 0x90
32208d04:	4658      	mov	r0, fp
32208d06:	f7fa fc07 	bl	32203518 <__sprint_r>
32208d0a:	2800      	cmp	r0, #0
32208d0c:	f47e aa86 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208d10:	9c1b      	ldr	r4, [sp, #108]	@ 0x6c
32208d12:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208d16:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32208d18:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32208d1a:	1b1c      	subs	r4, r3, r4
32208d1c:	f7ff b83c 	b.w	32207d98 <_vfprintf_r+0xe20>
32208d20:	2300      	movs	r3, #0
32208d22:	4615      	mov	r5, r2
32208d24:	9305      	str	r3, [sp, #20]
32208d26:	f7fe b9a6 	b.w	32207076 <_vfprintf_r+0xfe>
32208d2a:	2300      	movs	r3, #0
32208d2c:	f64b 3564 	movw	r5, #47972	@ 0xbb64
32208d30:	f2c3 2520 	movt	r5, #12832	@ 0x3220
32208d34:	9309      	str	r3, [sp, #36]	@ 0x24
32208d36:	e652      	b.n	322089de <_vfprintf_r+0x1a66>
32208d38:	2300      	movs	r3, #0
32208d3a:	ad37      	add	r5, sp, #220	@ 0xdc
32208d3c:	9309      	str	r3, [sp, #36]	@ 0x24
32208d3e:	f7ff bb7d 	b.w	3220843c <_vfprintf_r+0x14c4>
32208d42:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32208d44:	9a11      	ldr	r2, [sp, #68]	@ 0x44
32208d46:	189a      	adds	r2, r3, r2
32208d48:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32208d4a:	920b      	str	r2, [sp, #44]	@ 0x2c
32208d4c:	2b00      	cmp	r3, #0
32208d4e:	bfc8      	it	gt
32208d50:	2467      	movgt	r4, #103	@ 0x67
32208d52:	f73f ad03 	bgt.w	3220875c <_vfprintf_r+0x17e4>
32208d56:	f1c3 0301 	rsb	r3, r3, #1
32208d5a:	2467      	movs	r4, #103	@ 0x67
32208d5c:	441a      	add	r2, r3
32208d5e:	920b      	str	r2, [sp, #44]	@ 0x2c
32208d60:	ea22 73e2 	bic.w	r3, r2, r2, asr #31
32208d64:	9304      	str	r3, [sp, #16]
32208d66:	e501      	b.n	3220876c <_vfprintf_r+0x17f4>
32208d68:	424c      	negs	r4, r1
32208d6a:	3110      	adds	r1, #16
32208d6c:	f64b 7ae0 	movw	sl, #49120	@ 0xbfe0
32208d70:	f2c3 2a20 	movt	sl, #12832	@ 0x3220
32208d74:	bfb8      	it	lt
32208d76:	2610      	movlt	r6, #16
32208d78:	db03      	blt.n	32208d82 <_vfprintf_r+0x1e0a>
32208d7a:	e037      	b.n	32208dec <_vfprintf_r+0x1e74>
32208d7c:	3c10      	subs	r4, #16
32208d7e:	2c10      	cmp	r4, #16
32208d80:	dd34      	ble.n	32208dec <_vfprintf_r+0x1e74>
32208d82:	3301      	adds	r3, #1
32208d84:	3210      	adds	r2, #16
32208d86:	e9c9 a600 	strd	sl, r6, [r9]
32208d8a:	2b07      	cmp	r3, #7
32208d8c:	f109 0908 	add.w	r9, r9, #8
32208d90:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32208d94:	ddf2      	ble.n	32208d7c <_vfprintf_r+0x1e04>
32208d96:	9903      	ldr	r1, [sp, #12]
32208d98:	aa24      	add	r2, sp, #144	@ 0x90
32208d9a:	4658      	mov	r0, fp
32208d9c:	f7fa fbbc 	bl	32203518 <__sprint_r>
32208da0:	2800      	cmp	r0, #0
32208da2:	f47e aa3b 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208da6:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32208daa:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208dae:	e7e5      	b.n	32208d7c <_vfprintf_r+0x1e04>
32208db0:	eeb5 9b40 	vcmp.f64	d9, #0.0
32208db4:	9b05      	ldr	r3, [sp, #20]
32208db6:	18e9      	adds	r1, r5, r3
32208db8:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32208dbc:	f000 80ee 	beq.w	32208f9c <_vfprintf_r+0x2024>
32208dc0:	9b22      	ldr	r3, [sp, #136]	@ 0x88
32208dc2:	4299      	cmp	r1, r3
32208dc4:	f63f acaa 	bhi.w	3220871c <_vfprintf_r+0x17a4>
32208dc8:	e4af      	b.n	3220872a <_vfprintf_r+0x17b2>
32208dca:	9a04      	ldr	r2, [sp, #16]
32208dcc:	9305      	str	r3, [sp, #20]
32208dce:	3201      	adds	r2, #1
32208dd0:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
32208dd4:	9204      	str	r2, [sp, #16]
32208dd6:	9310      	str	r3, [sp, #64]	@ 0x40
32208dd8:	930e      	str	r3, [sp, #56]	@ 0x38
32208dda:	930c      	str	r3, [sp, #48]	@ 0x30
32208ddc:	f7fe ba59 	b.w	32207292 <_vfprintf_r+0x31a>
32208de0:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
32208de4:	f8cd 8014 	str.w	r8, [sp, #20]
32208de8:	f7fe bc97 	b.w	3220771a <_vfprintf_r+0x7a2>
32208dec:	3301      	adds	r3, #1
32208dee:	4422      	add	r2, r4
32208df0:	2b07      	cmp	r3, #7
32208df2:	f8c9 a000 	str.w	sl, [r9]
32208df6:	f8c9 4004 	str.w	r4, [r9, #4]
32208dfa:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32208dfe:	f77f af13 	ble.w	32208c28 <_vfprintf_r+0x1cb0>
32208e02:	9903      	ldr	r1, [sp, #12]
32208e04:	aa24      	add	r2, sp, #144	@ 0x90
32208e06:	4658      	mov	r0, fp
32208e08:	f7fa fb86 	bl	32203518 <__sprint_r>
32208e0c:	2800      	cmp	r0, #0
32208e0e:	f47e aa05 	bne.w	3220721c <_vfprintf_r+0x2a4>
32208e12:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32208e16:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32208e1a:	f7ff b88d 	b.w	32207f38 <_vfprintf_r+0xfc0>
32208e1e:	2300      	movs	r3, #0
32208e20:	eeb1 0b48 	vneg.f64	d0, d8
32208e24:	f04f 082d 	mov.w	r8, #45	@ 0x2d
32208e28:	ad37      	add	r5, sp, #220	@ 0xdc
32208e2a:	9309      	str	r3, [sp, #36]	@ 0x24
32208e2c:	f7ff b8d9 	b.w	32207fe2 <_vfprintf_r+0x106a>
32208e30:	07ca      	lsls	r2, r1, #31
32208e32:	f57f a95f 	bpl.w	322080f4 <_vfprintf_r+0x117c>
32208e36:	f7ff b959 	b.w	322080ec <_vfprintf_r+0x1174>
32208e3a:	9b03      	ldr	r3, [sp, #12]
32208e3c:	2200      	movs	r2, #0
32208e3e:	9209      	str	r2, [sp, #36]	@ 0x24
32208e40:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
32208e44:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32208e48:	9a03      	ldr	r2, [sp, #12]
32208e4a:	8193      	strh	r3, [r2, #12]
32208e4c:	f7fe b9e6 	b.w	3220721c <_vfprintf_r+0x2a4>
32208e50:	9b05      	ldr	r3, [sp, #20]
32208e52:	f8dd 9010 	ldr.w	r9, [sp, #16]
32208e56:	f8dd 8024 	ldr.w	r8, [sp, #36]	@ 0x24
32208e5a:	930b      	str	r3, [sp, #44]	@ 0x2c
32208e5c:	f7ff bade 	b.w	3220841c <_vfprintf_r+0x14a4>
32208e60:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
32208e64:	2b00      	cmp	r3, #0
32208e66:	f000 811e 	beq.w	322090a6 <_vfprintf_r+0x212e>
32208e6a:	9b05      	ldr	r3, [sp, #20]
32208e6c:	2473      	movs	r4, #115	@ 0x73
32208e6e:	930b      	str	r3, [sp, #44]	@ 0x2c
32208e70:	1c5a      	adds	r2, r3, #1
32208e72:	9005      	str	r0, [sp, #20]
32208e74:	9204      	str	r2, [sp, #16]
32208e76:	9010      	str	r0, [sp, #64]	@ 0x40
32208e78:	900e      	str	r0, [sp, #56]	@ 0x38
32208e7a:	f7fe ba0a 	b.w	32207292 <_vfprintf_r+0x31a>
32208e7e:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32208e80:	222d      	movs	r2, #45	@ 0x2d
32208e82:	f88d 2079 	strb.w	r2, [sp, #121]	@ 0x79
32208e86:	f1c3 0301 	rsb	r3, r3, #1
32208e8a:	2b09      	cmp	r3, #9
32208e8c:	f73f ad48 	bgt.w	32208920 <_vfprintf_r+0x19a8>
32208e90:	2230      	movs	r2, #48	@ 0x30
32208e92:	9902      	ldr	r1, [sp, #8]
32208e94:	f88d 207a 	strb.w	r2, [sp, #122]	@ 0x7a
32208e98:	2200      	movs	r2, #0
32208e9a:	9209      	str	r2, [sp, #36]	@ 0x24
32208e9c:	f10d 027b 	add.w	r2, sp, #123	@ 0x7b
32208ea0:	f7ff b917 	b.w	322080d2 <_vfprintf_r+0x115a>
32208ea4:	930b      	str	r3, [sp, #44]	@ 0x2c
32208ea6:	e581      	b.n	322089ac <_vfprintf_r+0x1a34>
32208ea8:	4613      	mov	r3, r2
32208eaa:	9a11      	ldr	r2, [sp, #68]	@ 0x44
32208eac:	2466      	movs	r4, #102	@ 0x66
32208eae:	4413      	add	r3, r2
32208eb0:	440b      	add	r3, r1
32208eb2:	930b      	str	r3, [sp, #44]	@ 0x2c
32208eb4:	e452      	b.n	3220875c <_vfprintf_r+0x17e4>
32208eb6:	9b02      	ldr	r3, [sp, #8]
32208eb8:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32208ebc:	9302      	str	r3, [sp, #8]
32208ebe:	ee18 3a90 	vmov	r3, s17
32208ec2:	f013 4300 	ands.w	r3, r3, #2147483648	@ 0x80000000
32208ec6:	930c      	str	r3, [sp, #48]	@ 0x30
32208ec8:	f000 80a1 	beq.w	3220900e <_vfprintf_r+0x2096>
32208ecc:	232d      	movs	r3, #45	@ 0x2d
32208ece:	f64b 356c 	movw	r5, #47980	@ 0xbb6c
32208ed2:	f2c3 2520 	movt	r5, #12832	@ 0x3220
32208ed6:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32208eda:	2c47      	cmp	r4, #71	@ 0x47
32208edc:	f04f 0300 	mov.w	r3, #0
32208ee0:	9309      	str	r3, [sp, #36]	@ 0x24
32208ee2:	f73f ad7c 	bgt.w	322089de <_vfprintf_r+0x1a66>
32208ee6:	f64b 3568 	movw	r5, #47976	@ 0xbb68
32208eea:	f2c3 2520 	movt	r5, #12832	@ 0x3220
32208eee:	e576      	b.n	322089de <_vfprintf_r+0x1a66>
32208ef0:	2300      	movs	r3, #0
32208ef2:	2203      	movs	r2, #3
32208ef4:	9309      	str	r3, [sp, #36]	@ 0x24
32208ef6:	920b      	str	r2, [sp, #44]	@ 0x2c
32208ef8:	2204      	movs	r2, #4
32208efa:	9305      	str	r3, [sp, #20]
32208efc:	9204      	str	r2, [sp, #16]
32208efe:	9310      	str	r3, [sp, #64]	@ 0x40
32208f00:	930e      	str	r3, [sp, #56]	@ 0x38
32208f02:	930c      	str	r3, [sp, #48]	@ 0x30
32208f04:	f7fe b9c5 	b.w	32207292 <_vfprintf_r+0x31a>
32208f08:	2467      	movs	r4, #103	@ 0x67
32208f0a:	9917      	ldr	r1, [sp, #92]	@ 0x5c
32208f0c:	780b      	ldrb	r3, [r1, #0]
32208f0e:	2bff      	cmp	r3, #255	@ 0xff
32208f10:	f000 8129 	beq.w	32209166 <_vfprintf_r+0x21ee>
32208f14:	2600      	movs	r6, #0
32208f16:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32208f18:	4630      	mov	r0, r6
32208f1a:	e003      	b.n	32208f24 <_vfprintf_r+0x1fac>
32208f1c:	3001      	adds	r0, #1
32208f1e:	3101      	adds	r1, #1
32208f20:	2bff      	cmp	r3, #255	@ 0xff
32208f22:	d008      	beq.n	32208f36 <_vfprintf_r+0x1fbe>
32208f24:	4293      	cmp	r3, r2
32208f26:	da06      	bge.n	32208f36 <_vfprintf_r+0x1fbe>
32208f28:	1ad2      	subs	r2, r2, r3
32208f2a:	784b      	ldrb	r3, [r1, #1]
32208f2c:	2b00      	cmp	r3, #0
32208f2e:	d1f5      	bne.n	32208f1c <_vfprintf_r+0x1fa4>
32208f30:	780b      	ldrb	r3, [r1, #0]
32208f32:	3601      	adds	r6, #1
32208f34:	e7f4      	b.n	32208f20 <_vfprintf_r+0x1fa8>
32208f36:	920c      	str	r2, [sp, #48]	@ 0x30
32208f38:	9117      	str	r1, [sp, #92]	@ 0x5c
32208f3a:	900e      	str	r0, [sp, #56]	@ 0x38
32208f3c:	9610      	str	r6, [sp, #64]	@ 0x40
32208f3e:	9a10      	ldr	r2, [sp, #64]	@ 0x40
32208f40:	9b0e      	ldr	r3, [sp, #56]	@ 0x38
32208f42:	9915      	ldr	r1, [sp, #84]	@ 0x54
32208f44:	4413      	add	r3, r2
32208f46:	9a0b      	ldr	r2, [sp, #44]	@ 0x2c
32208f48:	fb01 2303 	mla	r3, r1, r3, r2
32208f4c:	930b      	str	r3, [sp, #44]	@ 0x2c
32208f4e:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
32208f52:	9304      	str	r3, [sp, #16]
32208f54:	f1b8 0f00 	cmp.w	r8, #0
32208f58:	d049      	beq.n	32208fee <_vfprintf_r+0x2076>
32208f5a:	9b04      	ldr	r3, [sp, #16]
32208f5c:	f8cd a008 	str.w	sl, [sp, #8]
32208f60:	3301      	adds	r3, #1
32208f62:	9304      	str	r3, [sp, #16]
32208f64:	2300      	movs	r3, #0
32208f66:	9309      	str	r3, [sp, #36]	@ 0x24
32208f68:	461a      	mov	r2, r3
32208f6a:	232d      	movs	r3, #45	@ 0x2d
32208f6c:	9205      	str	r2, [sp, #20]
32208f6e:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32208f72:	f7fe b98e 	b.w	32207292 <_vfprintf_r+0x31a>
32208f76:	2a00      	cmp	r2, #0
32208f78:	bfa8      	it	ge
32208f7a:	1c50      	addge	r0, r2, #1
32208f7c:	bfa8      	it	ge
32208f7e:	4619      	movge	r1, r3
32208f80:	bfa8      	it	ge
32208f82:	18c0      	addge	r0, r0, r3
32208f84:	bfa8      	it	ge
32208f86:	2630      	movge	r6, #48	@ 0x30
32208f88:	f6ff a88c 	blt.w	322080a4 <_vfprintf_r+0x112c>
32208f8c:	f801 6b01 	strb.w	r6, [r1], #1
32208f90:	4281      	cmp	r1, r0
32208f92:	d1fb      	bne.n	32208f8c <_vfprintf_r+0x2014>
32208f94:	441a      	add	r2, r3
32208f96:	1c53      	adds	r3, r2, #1
32208f98:	f7ff b884 	b.w	322080a4 <_vfprintf_r+0x112c>
32208f9c:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32208f9e:	930c      	str	r3, [sp, #48]	@ 0x30
32208fa0:	9b05      	ldr	r3, [sp, #20]
32208fa2:	930f      	str	r3, [sp, #60]	@ 0x3c
32208fa4:	e49f      	b.n	322088e6 <_vfprintf_r+0x196e>
32208fa6:	eeb5 9b40 	vcmp.f64	d9, #0.0
32208faa:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32208fae:	d005      	beq.n	32208fbc <_vfprintf_r+0x2044>
32208fb0:	9b22      	ldr	r3, [sp, #136]	@ 0x88
32208fb2:	4299      	cmp	r1, r3
32208fb4:	f63f abb2 	bhi.w	3220871c <_vfprintf_r+0x17a4>
32208fb8:	1b5b      	subs	r3, r3, r5
32208fba:	930f      	str	r3, [sp, #60]	@ 0x3c
32208fbc:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32208fbe:	2e47      	cmp	r6, #71	@ 0x47
32208fc0:	930c      	str	r3, [sp, #48]	@ 0x30
32208fc2:	f47f ac9f 	bne.w	32208904 <_vfprintf_r+0x198c>
32208fc6:	e48e      	b.n	322088e6 <_vfprintf_r+0x196e>
32208fc8:	1b4b      	subs	r3, r1, r5
32208fca:	930f      	str	r3, [sp, #60]	@ 0x3c
32208fcc:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32208fce:	930c      	str	r3, [sp, #48]	@ 0x30
32208fd0:	f7ff bbb5 	b.w	3220873e <_vfprintf_r+0x17c6>
32208fd4:	eeb5 9b40 	vcmp.f64	d9, #0.0
32208fd8:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32208fdc:	f040 80bd 	bne.w	3220915a <_vfprintf_r+0x21e2>
32208fe0:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32208fe2:	930c      	str	r3, [sp, #48]	@ 0x30
32208fe4:	4419      	add	r1, r3
32208fe6:	1b4b      	subs	r3, r1, r5
32208fe8:	930f      	str	r3, [sp, #60]	@ 0x3c
32208fea:	f7ff bba8 	b.w	3220873e <_vfprintf_r+0x17c6>
32208fee:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32208ff2:	2b00      	cmp	r3, #0
32208ff4:	f000 80e5 	beq.w	322091c2 <_vfprintf_r+0x224a>
32208ff8:	9b04      	ldr	r3, [sp, #16]
32208ffa:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
32208ffe:	3301      	adds	r3, #1
32209000:	f8cd a008 	str.w	sl, [sp, #8]
32209004:	9304      	str	r3, [sp, #16]
32209006:	f8cd 8014 	str.w	r8, [sp, #20]
3220900a:	f7fe b942 	b.w	32207292 <_vfprintf_r+0x31a>
3220900e:	f89d 2067 	ldrb.w	r2, [sp, #103]	@ 0x67
32209012:	f64b 3568 	movw	r5, #47976	@ 0xbb68
32209016:	f2c3 2520 	movt	r5, #12832	@ 0x3220
3220901a:	f64b 336c 	movw	r3, #47980	@ 0xbb6c
3220901e:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32209022:	2c47      	cmp	r4, #71	@ 0x47
32209024:	bfc8      	it	gt
32209026:	461d      	movgt	r5, r3
32209028:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3220902a:	9305      	str	r3, [sp, #20]
3220902c:	2a00      	cmp	r2, #0
3220902e:	f040 80a1 	bne.w	32209174 <_vfprintf_r+0x21fc>
32209032:	2203      	movs	r2, #3
32209034:	9310      	str	r3, [sp, #64]	@ 0x40
32209036:	920b      	str	r2, [sp, #44]	@ 0x2c
32209038:	930e      	str	r3, [sp, #56]	@ 0x38
3220903a:	9309      	str	r3, [sp, #36]	@ 0x24
3220903c:	9204      	str	r2, [sp, #16]
3220903e:	f7fe b928 	b.w	32207292 <_vfprintf_r+0x31a>
32209042:	2306      	movs	r3, #6
32209044:	eeb1 9b48 	vneg.f64	d9, d8
32209048:	f04f 082d 	mov.w	r8, #45	@ 0x2d
3220904c:	9305      	str	r3, [sp, #20]
3220904e:	f7ff bb35 	b.w	322086bc <_vfprintf_r+0x1744>
32209052:	2b00      	cmp	r3, #0
32209054:	db76      	blt.n	32209144 <_vfprintf_r+0x21cc>
32209056:	2301      	movs	r3, #1
32209058:	eeb0 9b48 	vmov.f64	d9, d8
3220905c:	f04f 0800 	mov.w	r8, #0
32209060:	9305      	str	r3, [sp, #20]
32209062:	f7ff bb2b 	b.w	322086bc <_vfprintf_r+0x1744>
32209066:	9b05      	ldr	r3, [sp, #20]
32209068:	9d10      	ldr	r5, [sp, #64]	@ 0x40
3220906a:	f8cd 905c 	str.w	r9, [sp, #92]	@ 0x5c
3220906e:	4689      	mov	r9, r1
32209070:	4598      	cmp	r8, r3
32209072:	bf28      	it	cs
32209074:	4698      	movcs	r8, r3
32209076:	f7fe be61 	b.w	32207d3c <_vfprintf_r+0xdc4>
3220907a:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
3220907e:	f8cd a008 	str.w	sl, [sp, #8]
32209082:	f8cd 8014 	str.w	r8, [sp, #20]
32209086:	f8cd 8040 	str.w	r8, [sp, #64]	@ 0x40
3220908a:	f8cd 8038 	str.w	r8, [sp, #56]	@ 0x38
3220908e:	f7fe b900 	b.w	32207292 <_vfprintf_r+0x31a>
32209092:	f1c2 0301 	rsb	r3, r2, #1
32209096:	222d      	movs	r2, #45	@ 0x2d
32209098:	2b09      	cmp	r3, #9
3220909a:	f88d 2079 	strb.w	r2, [sp, #121]	@ 0x79
3220909e:	f73f ac42 	bgt.w	32208926 <_vfprintf_r+0x19ae>
322090a2:	f7ff b814 	b.w	322080ce <_vfprintf_r+0x1156>
322090a6:	9b05      	ldr	r3, [sp, #20]
322090a8:	2473      	movs	r4, #115	@ 0x73
322090aa:	930b      	str	r3, [sp, #44]	@ 0x2c
322090ac:	9304      	str	r3, [sp, #16]
322090ae:	9b09      	ldr	r3, [sp, #36]	@ 0x24
322090b0:	9310      	str	r3, [sp, #64]	@ 0x40
322090b2:	930e      	str	r3, [sp, #56]	@ 0x38
322090b4:	9305      	str	r3, [sp, #20]
322090b6:	f7fe b8ec 	b.w	32207292 <_vfprintf_r+0x31a>
322090ba:	eeb1 0b48 	vneg.f64	d0, d8
322090be:	f04f 082d 	mov.w	r8, #45	@ 0x2d
322090c2:	9009      	str	r0, [sp, #36]	@ 0x24
322090c4:	f7fe bf8d 	b.w	32207fe2 <_vfprintf_r+0x106a>
322090c8:	9a03      	ldr	r2, [sp, #12]
322090ca:	6e53      	ldr	r3, [r2, #100]	@ 0x64
322090cc:	07dd      	lsls	r5, r3, #31
322090ce:	f53e aaf2 	bmi.w	322076b6 <_vfprintf_r+0x73e>
322090d2:	8993      	ldrh	r3, [r2, #12]
322090d4:	059c      	lsls	r4, r3, #22
322090d6:	f53e aaee 	bmi.w	322076b6 <_vfprintf_r+0x73e>
322090da:	6d90      	ldr	r0, [r2, #88]	@ 0x58
322090dc:	f7fb fe44 	bl	32204d68 <__retarget_lock_release_recursive>
322090e0:	f7fe bae9 	b.w	322076b6 <_vfprintf_r+0x73e>
322090e4:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
322090e6:	786c      	ldrb	r4, [r5, #1]
322090e8:	4615      	mov	r5, r2
322090ea:	f853 2b04 	ldr.w	r2, [r3], #4
322090ee:	930a      	str	r3, [sp, #40]	@ 0x28
322090f0:	ea42 73e2 	orr.w	r3, r2, r2, asr #31
322090f4:	9305      	str	r3, [sp, #20]
322090f6:	f7fd bfbd 	b.w	32207074 <_vfprintf_r+0xfc>
322090fa:	2302      	movs	r3, #2
322090fc:	9314      	str	r3, [sp, #80]	@ 0x50
322090fe:	f7fe bfee 	b.w	322080de <_vfprintf_r+0x1166>
32209102:	b92b      	cbnz	r3, 32209110 <_vfprintf_r+0x2198>
32209104:	2301      	movs	r3, #1
32209106:	2466      	movs	r4, #102	@ 0x66
32209108:	9304      	str	r3, [sp, #16]
3220910a:	930b      	str	r3, [sp, #44]	@ 0x2c
3220910c:	f7ff bb2e 	b.w	3220876c <_vfprintf_r+0x17f4>
32209110:	9b11      	ldr	r3, [sp, #68]	@ 0x44
32209112:	2466      	movs	r4, #102	@ 0x66
32209114:	9a05      	ldr	r2, [sp, #20]
32209116:	3301      	adds	r3, #1
32209118:	441a      	add	r2, r3
3220911a:	920b      	str	r2, [sp, #44]	@ 0x2c
3220911c:	ea22 73e2 	bic.w	r3, r2, r2, asr #31
32209120:	9304      	str	r3, [sp, #16]
32209122:	f7ff bb23 	b.w	3220876c <_vfprintf_r+0x17f4>
32209126:	9803      	ldr	r0, [sp, #12]
32209128:	6e42      	ldr	r2, [r0, #100]	@ 0x64
3220912a:	f9b0 300c 	ldrsh.w	r3, [r0, #12]
3220912e:	f043 0140 	orr.w	r1, r3, #64	@ 0x40
32209132:	8181      	strh	r1, [r0, #12]
32209134:	07d0      	lsls	r0, r2, #31
32209136:	f53e aabe 	bmi.w	322076b6 <_vfprintf_r+0x73e>
3220913a:	0598      	lsls	r0, r3, #22
3220913c:	f53e aabb 	bmi.w	322076b6 <_vfprintf_r+0x73e>
32209140:	f7fe b949 	b.w	322073d6 <_vfprintf_r+0x45e>
32209144:	2301      	movs	r3, #1
32209146:	eeb1 9b48 	vneg.f64	d9, d8
3220914a:	f04f 082d 	mov.w	r8, #45	@ 0x2d
3220914e:	9305      	str	r3, [sp, #20]
32209150:	f7ff bab4 	b.w	322086bc <_vfprintf_r+0x1744>
32209154:	7a81      	ldrb	r1, [r0, #10]
32209156:	f7fe bfa3 	b.w	322080a0 <_vfprintf_r+0x1128>
3220915a:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
3220915c:	f1c3 0301 	rsb	r3, r3, #1
32209160:	931b      	str	r3, [sp, #108]	@ 0x6c
32209162:	f7ff bad0 	b.w	32208706 <_vfprintf_r+0x178e>
32209166:	2300      	movs	r3, #0
32209168:	9310      	str	r3, [sp, #64]	@ 0x40
3220916a:	930e      	str	r3, [sp, #56]	@ 0x38
3220916c:	e6e7      	b.n	32208f3e <_vfprintf_r+0x1fc6>
3220916e:	9802      	ldr	r0, [sp, #8]
32209170:	f7fe bb7f 	b.w	32207872 <_vfprintf_r+0x8fa>
32209174:	2203      	movs	r2, #3
32209176:	9310      	str	r3, [sp, #64]	@ 0x40
32209178:	930e      	str	r3, [sp, #56]	@ 0x38
3220917a:	9309      	str	r3, [sp, #36]	@ 0x24
3220917c:	2304      	movs	r3, #4
3220917e:	920b      	str	r2, [sp, #44]	@ 0x2c
32209180:	9304      	str	r3, [sp, #16]
32209182:	f7fe b886 	b.w	32207292 <_vfprintf_r+0x31a>
32209186:	1b5b      	subs	r3, r3, r5
32209188:	930f      	str	r3, [sp, #60]	@ 0x3c
3220918a:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
3220918c:	930c      	str	r3, [sp, #48]	@ 0x30
3220918e:	f7ff bad6 	b.w	3220873e <_vfprintf_r+0x17c6>
32209192:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32209194:	18eb      	adds	r3, r5, r3
32209196:	e76b      	b.n	32209070 <_vfprintf_r+0x20f8>
32209198:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3220919a:	9310      	str	r3, [sp, #64]	@ 0x40
3220919c:	930e      	str	r3, [sp, #56]	@ 0x38
3220919e:	f7fe b878 	b.w	32207292 <_vfprintf_r+0x31a>
322091a2:	9b03      	ldr	r3, [sp, #12]
322091a4:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
322091a8:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
322091ac:	e64c      	b.n	32208e48 <_vfprintf_r+0x1ed0>
322091ae:	9b03      	ldr	r3, [sp, #12]
322091b0:	9009      	str	r0, [sp, #36]	@ 0x24
322091b2:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
322091b6:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
322091ba:	e645      	b.n	32208e48 <_vfprintf_r+0x1ed0>
322091bc:	460a      	mov	r2, r1
322091be:	f7fe bbd1 	b.w	32207964 <_vfprintf_r+0x9ec>
322091c2:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
322091c6:	f8cd a008 	str.w	sl, [sp, #8]
322091ca:	f8cd 8014 	str.w	r8, [sp, #20]
322091ce:	f7fe b860 	b.w	32207292 <_vfprintf_r+0x31a>
322091d2:	bf00      	nop

322091d4 <vfprintf>:
322091d4:	f24c 3cd0 	movw	ip, #50128	@ 0xc3d0
322091d8:	f2c3 2c20 	movt	ip, #12832	@ 0x3220
322091dc:	b500      	push	{lr}
322091de:	468e      	mov	lr, r1
322091e0:	4613      	mov	r3, r2
322091e2:	4601      	mov	r1, r0
322091e4:	4672      	mov	r2, lr
322091e6:	f8dc 0000 	ldr.w	r0, [ip]
322091ea:	f85d eb04 	ldr.w	lr, [sp], #4
322091ee:	f7fd bec3 	b.w	32206f78 <_vfprintf_r>
322091f2:	bf00      	nop
322091f4:	0000      	movs	r0, r0
	...

322091f8 <__sbprintf>:
322091f8:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
322091fc:	4698      	mov	r8, r3
322091fe:	eddf 0b22 	vldr	d16, [pc, #136]	@ 32209288 <__sbprintf+0x90>
32209202:	f5ad 6d8d 	sub.w	sp, sp, #1128	@ 0x468
32209206:	4616      	mov	r6, r2
32209208:	ab05      	add	r3, sp, #20
3220920a:	4607      	mov	r7, r0
3220920c:	a816      	add	r0, sp, #88	@ 0x58
3220920e:	460d      	mov	r5, r1
32209210:	466c      	mov	r4, sp
32209212:	f943 078f 	vst1.32	{d16}, [r3]
32209216:	898b      	ldrh	r3, [r1, #12]
32209218:	f023 0302 	bic.w	r3, r3, #2
3220921c:	f8ad 300c 	strh.w	r3, [sp, #12]
32209220:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
32209222:	9319      	str	r3, [sp, #100]	@ 0x64
32209224:	89cb      	ldrh	r3, [r1, #14]
32209226:	f8ad 300e 	strh.w	r3, [sp, #14]
3220922a:	69cb      	ldr	r3, [r1, #28]
3220922c:	9307      	str	r3, [sp, #28]
3220922e:	6a4b      	ldr	r3, [r1, #36]	@ 0x24
32209230:	9309      	str	r3, [sp, #36]	@ 0x24
32209232:	ab1a      	add	r3, sp, #104	@ 0x68
32209234:	9300      	str	r3, [sp, #0]
32209236:	9304      	str	r3, [sp, #16]
32209238:	f44f 6380 	mov.w	r3, #1024	@ 0x400
3220923c:	9302      	str	r3, [sp, #8]
3220923e:	f7fb fd83 	bl	32204d48 <__retarget_lock_init_recursive>
32209242:	4632      	mov	r2, r6
32209244:	4643      	mov	r3, r8
32209246:	4669      	mov	r1, sp
32209248:	4638      	mov	r0, r7
3220924a:	f7fd fe95 	bl	32206f78 <_vfprintf_r>
3220924e:	1e06      	subs	r6, r0, #0
32209250:	db08      	blt.n	32209264 <__sbprintf+0x6c>
32209252:	4669      	mov	r1, sp
32209254:	4638      	mov	r0, r7
32209256:	f7fa fa0b 	bl	32203670 <_fflush_r>
3220925a:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
3220925e:	2800      	cmp	r0, #0
32209260:	bf18      	it	ne
32209262:	461e      	movne	r6, r3
32209264:	89a3      	ldrh	r3, [r4, #12]
32209266:	065b      	lsls	r3, r3, #25
32209268:	d503      	bpl.n	32209272 <__sbprintf+0x7a>
3220926a:	89ab      	ldrh	r3, [r5, #12]
3220926c:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32209270:	81ab      	strh	r3, [r5, #12]
32209272:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32209274:	f7fb fd6c 	bl	32204d50 <__retarget_lock_close_recursive>
32209278:	4630      	mov	r0, r6
3220927a:	f50d 6d8d 	add.w	sp, sp, #1128	@ 0x468
3220927e:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
32209282:	bf00      	nop
32209284:	f3af 8000 	nop.w
32209288:	00000400 	.word	0x00000400
3220928c:	00000000 	.word	0x00000000

32209290 <_fclose_r>:
32209290:	b570      	push	{r4, r5, r6, lr}
32209292:	2900      	cmp	r1, #0
32209294:	d040      	beq.n	32209318 <_fclose_r+0x88>
32209296:	4606      	mov	r6, r0
32209298:	460c      	mov	r4, r1
3220929a:	b110      	cbz	r0, 322092a2 <_fclose_r+0x12>
3220929c:	6b43      	ldr	r3, [r0, #52]	@ 0x34
3220929e:	2b00      	cmp	r3, #0
322092a0:	d03d      	beq.n	3220931e <_fclose_r+0x8e>
322092a2:	6e63      	ldr	r3, [r4, #100]	@ 0x64
322092a4:	f9b4 200c 	ldrsh.w	r2, [r4, #12]
322092a8:	07dd      	lsls	r5, r3, #31
322092aa:	d433      	bmi.n	32209314 <_fclose_r+0x84>
322092ac:	0590      	lsls	r0, r2, #22
322092ae:	d539      	bpl.n	32209324 <_fclose_r+0x94>
322092b0:	4621      	mov	r1, r4
322092b2:	4630      	mov	r0, r6
322092b4:	f7fa f940 	bl	32203538 <__sflush_r>
322092b8:	6ae3      	ldr	r3, [r4, #44]	@ 0x2c
322092ba:	4605      	mov	r5, r0
322092bc:	b13b      	cbz	r3, 322092ce <_fclose_r+0x3e>
322092be:	69e1      	ldr	r1, [r4, #28]
322092c0:	4630      	mov	r0, r6
322092c2:	4798      	blx	r3
322092c4:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
322092c8:	2800      	cmp	r0, #0
322092ca:	bfb8      	it	lt
322092cc:	461d      	movlt	r5, r3
322092ce:	89a3      	ldrh	r3, [r4, #12]
322092d0:	061a      	lsls	r2, r3, #24
322092d2:	d439      	bmi.n	32209348 <_fclose_r+0xb8>
322092d4:	6b21      	ldr	r1, [r4, #48]	@ 0x30
322092d6:	b141      	cbz	r1, 322092ea <_fclose_r+0x5a>
322092d8:	f104 0340 	add.w	r3, r4, #64	@ 0x40
322092dc:	4299      	cmp	r1, r3
322092de:	d002      	beq.n	322092e6 <_fclose_r+0x56>
322092e0:	4630      	mov	r0, r6
322092e2:	f7fc fb01 	bl	322058e8 <_free_r>
322092e6:	2300      	movs	r3, #0
322092e8:	6323      	str	r3, [r4, #48]	@ 0x30
322092ea:	6c61      	ldr	r1, [r4, #68]	@ 0x44
322092ec:	b121      	cbz	r1, 322092f8 <_fclose_r+0x68>
322092ee:	4630      	mov	r0, r6
322092f0:	f7fc fafa 	bl	322058e8 <_free_r>
322092f4:	2300      	movs	r3, #0
322092f6:	6463      	str	r3, [r4, #68]	@ 0x44
322092f8:	f7fa fb98 	bl	32203a2c <__sfp_lock_acquire>
322092fc:	6e63      	ldr	r3, [r4, #100]	@ 0x64
322092fe:	2200      	movs	r2, #0
32209300:	81a2      	strh	r2, [r4, #12]
32209302:	07db      	lsls	r3, r3, #31
32209304:	d51c      	bpl.n	32209340 <_fclose_r+0xb0>
32209306:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32209308:	f7fb fd22 	bl	32204d50 <__retarget_lock_close_recursive>
3220930c:	f7fa fb94 	bl	32203a38 <__sfp_lock_release>
32209310:	4628      	mov	r0, r5
32209312:	bd70      	pop	{r4, r5, r6, pc}
32209314:	2a00      	cmp	r2, #0
32209316:	d1cb      	bne.n	322092b0 <_fclose_r+0x20>
32209318:	2500      	movs	r5, #0
3220931a:	4628      	mov	r0, r5
3220931c:	bd70      	pop	{r4, r5, r6, pc}
3220931e:	f7fa fb5d 	bl	322039dc <__sinit>
32209322:	e7be      	b.n	322092a2 <_fclose_r+0x12>
32209324:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32209326:	f7fb fd17 	bl	32204d58 <__retarget_lock_acquire_recursive>
3220932a:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
3220932e:	2b00      	cmp	r3, #0
32209330:	d1be      	bne.n	322092b0 <_fclose_r+0x20>
32209332:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32209334:	07d9      	lsls	r1, r3, #31
32209336:	d4ef      	bmi.n	32209318 <_fclose_r+0x88>
32209338:	6da0      	ldr	r0, [r4, #88]	@ 0x58
3220933a:	f7fb fd15 	bl	32204d68 <__retarget_lock_release_recursive>
3220933e:	e7eb      	b.n	32209318 <_fclose_r+0x88>
32209340:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32209342:	f7fb fd11 	bl	32204d68 <__retarget_lock_release_recursive>
32209346:	e7de      	b.n	32209306 <_fclose_r+0x76>
32209348:	6921      	ldr	r1, [r4, #16]
3220934a:	4630      	mov	r0, r6
3220934c:	f7fc facc 	bl	322058e8 <_free_r>
32209350:	e7c0      	b.n	322092d4 <_fclose_r+0x44>
32209352:	bf00      	nop

32209354 <fclose>:
32209354:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
32209358:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220935c:	4601      	mov	r1, r0
3220935e:	6818      	ldr	r0, [r3, #0]
32209360:	f7ff bf96 	b.w	32209290 <_fclose_r>

32209364 <__smakebuf_r>:
32209364:	f9b1 300c 	ldrsh.w	r3, [r1, #12]
32209368:	b570      	push	{r4, r5, r6, lr}
3220936a:	460c      	mov	r4, r1
3220936c:	b096      	sub	sp, #88	@ 0x58
3220936e:	0799      	lsls	r1, r3, #30
32209370:	d507      	bpl.n	32209382 <__smakebuf_r+0x1e>
32209372:	f104 0343 	add.w	r3, r4, #67	@ 0x43
32209376:	2201      	movs	r2, #1
32209378:	6023      	str	r3, [r4, #0]
3220937a:	e9c4 3204 	strd	r3, r2, [r4, #16]
3220937e:	b016      	add	sp, #88	@ 0x58
32209380:	bd70      	pop	{r4, r5, r6, pc}
32209382:	f9b4 100e 	ldrsh.w	r1, [r4, #14]
32209386:	4605      	mov	r5, r0
32209388:	2900      	cmp	r1, #0
3220938a:	db2b      	blt.n	322093e4 <__smakebuf_r+0x80>
3220938c:	466a      	mov	r2, sp
3220938e:	f000 fb01 	bl	32209994 <_fstat_r>
32209392:	2800      	cmp	r0, #0
32209394:	db24      	blt.n	322093e0 <__smakebuf_r+0x7c>
32209396:	f44f 6180 	mov.w	r1, #1024	@ 0x400
3220939a:	4628      	mov	r0, r5
3220939c:	9e01      	ldr	r6, [sp, #4]
3220939e:	f7fc fbf3 	bl	32205b88 <_malloc_r>
322093a2:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
322093a6:	b3a0      	cbz	r0, 32209412 <__smakebuf_r+0xae>
322093a8:	f406 4670 	and.w	r6, r6, #61440	@ 0xf000
322093ac:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
322093b0:	f44f 6280 	mov.w	r2, #1024	@ 0x400
322093b4:	f5b6 5f00 	cmp.w	r6, #8192	@ 0x2000
322093b8:	6020      	str	r0, [r4, #0]
322093ba:	81a3      	strh	r3, [r4, #12]
322093bc:	6120      	str	r0, [r4, #16]
322093be:	6162      	str	r2, [r4, #20]
322093c0:	d135      	bne.n	3220942e <__smakebuf_r+0xca>
322093c2:	f9b4 100e 	ldrsh.w	r1, [r4, #14]
322093c6:	4628      	mov	r0, r5
322093c8:	f000 fafa 	bl	322099c0 <_isatty_r>
322093cc:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
322093d0:	b368      	cbz	r0, 3220942e <__smakebuf_r+0xca>
322093d2:	f023 0303 	bic.w	r3, r3, #3
322093d6:	f44f 6200 	mov.w	r2, #2048	@ 0x800
322093da:	f043 0301 	orr.w	r3, r3, #1
322093de:	e014      	b.n	3220940a <__smakebuf_r+0xa6>
322093e0:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
322093e4:	f013 0f80 	tst.w	r3, #128	@ 0x80
322093e8:	4628      	mov	r0, r5
322093ea:	f44f 6580 	mov.w	r5, #1024	@ 0x400
322093ee:	bf18      	it	ne
322093f0:	2540      	movne	r5, #64	@ 0x40
322093f2:	4629      	mov	r1, r5
322093f4:	f7fc fbc8 	bl	32205b88 <_malloc_r>
322093f8:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
322093fc:	b148      	cbz	r0, 32209412 <__smakebuf_r+0xae>
322093fe:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
32209402:	2200      	movs	r2, #0
32209404:	6020      	str	r0, [r4, #0]
32209406:	e9c4 0504 	strd	r0, r5, [r4, #16]
3220940a:	4313      	orrs	r3, r2
3220940c:	81a3      	strh	r3, [r4, #12]
3220940e:	b016      	add	sp, #88	@ 0x58
32209410:	bd70      	pop	{r4, r5, r6, pc}
32209412:	059a      	lsls	r2, r3, #22
32209414:	d4b3      	bmi.n	3220937e <__smakebuf_r+0x1a>
32209416:	f023 0303 	bic.w	r3, r3, #3
3220941a:	f104 0243 	add.w	r2, r4, #67	@ 0x43
3220941e:	f043 0302 	orr.w	r3, r3, #2
32209422:	2101      	movs	r1, #1
32209424:	81a3      	strh	r3, [r4, #12]
32209426:	6022      	str	r2, [r4, #0]
32209428:	e9c4 2104 	strd	r2, r1, [r4, #16]
3220942c:	e7a7      	b.n	3220937e <__smakebuf_r+0x1a>
3220942e:	f44f 6200 	mov.w	r2, #2048	@ 0x800
32209432:	e7ea      	b.n	3220940a <__smakebuf_r+0xa6>

32209434 <__swhatbuf_r>:
32209434:	b570      	push	{r4, r5, r6, lr}
32209436:	460c      	mov	r4, r1
32209438:	f9b1 100e 	ldrsh.w	r1, [r1, #14]
3220943c:	b096      	sub	sp, #88	@ 0x58
3220943e:	4615      	mov	r5, r2
32209440:	461e      	mov	r6, r3
32209442:	2900      	cmp	r1, #0
32209444:	db14      	blt.n	32209470 <__swhatbuf_r+0x3c>
32209446:	466a      	mov	r2, sp
32209448:	f000 faa4 	bl	32209994 <_fstat_r>
3220944c:	2800      	cmp	r0, #0
3220944e:	db0f      	blt.n	32209470 <__swhatbuf_r+0x3c>
32209450:	9901      	ldr	r1, [sp, #4]
32209452:	f44f 6380 	mov.w	r3, #1024	@ 0x400
32209456:	f44f 6000 	mov.w	r0, #2048	@ 0x800
3220945a:	f401 4170 	and.w	r1, r1, #61440	@ 0xf000
3220945e:	f5a1 5100 	sub.w	r1, r1, #8192	@ 0x2000
32209462:	fab1 f181 	clz	r1, r1
32209466:	0949      	lsrs	r1, r1, #5
32209468:	6031      	str	r1, [r6, #0]
3220946a:	602b      	str	r3, [r5, #0]
3220946c:	b016      	add	sp, #88	@ 0x58
3220946e:	bd70      	pop	{r4, r5, r6, pc}
32209470:	89a1      	ldrh	r1, [r4, #12]
32209472:	f011 0180 	ands.w	r1, r1, #128	@ 0x80
32209476:	d006      	beq.n	32209486 <__swhatbuf_r+0x52>
32209478:	2100      	movs	r1, #0
3220947a:	2340      	movs	r3, #64	@ 0x40
3220947c:	4608      	mov	r0, r1
3220947e:	6031      	str	r1, [r6, #0]
32209480:	602b      	str	r3, [r5, #0]
32209482:	b016      	add	sp, #88	@ 0x58
32209484:	bd70      	pop	{r4, r5, r6, pc}
32209486:	f44f 6380 	mov.w	r3, #1024	@ 0x400
3220948a:	4608      	mov	r0, r1
3220948c:	6031      	str	r1, [r6, #0]
3220948e:	602b      	str	r3, [r5, #0]
32209490:	b016      	add	sp, #88	@ 0x58
32209492:	bd70      	pop	{r4, r5, r6, pc}

32209494 <strcasecmp>:
32209494:	b410      	push	{r4}
32209496:	4684      	mov	ip, r0
32209498:	4c10      	ldr	r4, [pc, #64]	@ (322094dc <strcasecmp+0x48>)
3220949a:	f81c 3b01 	ldrb.w	r3, [ip], #1
3220949e:	f811 0b01 	ldrb.w	r0, [r1], #1
322094a2:	5ce2      	ldrb	r2, [r4, r3]
322094a4:	f002 0203 	and.w	r2, r2, #3
322094a8:	2a01      	cmp	r2, #1
322094aa:	5c22      	ldrb	r2, [r4, r0]
322094ac:	bf08      	it	eq
322094ae:	3320      	addeq	r3, #32
322094b0:	f002 0203 	and.w	r2, r2, #3
322094b4:	2a01      	cmp	r2, #1
322094b6:	d006      	beq.n	322094c6 <strcasecmp+0x32>
322094b8:	1a1b      	subs	r3, r3, r0
322094ba:	d10a      	bne.n	322094d2 <strcasecmp+0x3e>
322094bc:	2800      	cmp	r0, #0
322094be:	d1ec      	bne.n	3220949a <strcasecmp+0x6>
322094c0:	f85d 4b04 	ldr.w	r4, [sp], #4
322094c4:	4770      	bx	lr
322094c6:	3020      	adds	r0, #32
322094c8:	1a18      	subs	r0, r3, r0
322094ca:	d0e6      	beq.n	3220949a <strcasecmp+0x6>
322094cc:	f85d 4b04 	ldr.w	r4, [sp], #4
322094d0:	4770      	bx	lr
322094d2:	4618      	mov	r0, r3
322094d4:	f85d 4b04 	ldr.w	r4, [sp], #4
322094d8:	4770      	bx	lr
322094da:	bf00      	nop
322094dc:	3220bed9 	.word	0x3220bed9

322094e0 <strcat>:
322094e0:	b510      	push	{r4, lr}
322094e2:	0783      	lsls	r3, r0, #30
322094e4:	4604      	mov	r4, r0
322094e6:	d111      	bne.n	3220950c <strcat+0x2c>
322094e8:	6822      	ldr	r2, [r4, #0]
322094ea:	4620      	mov	r0, r4
322094ec:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
322094f0:	ea23 0302 	bic.w	r3, r3, r2
322094f4:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
322094f8:	d108      	bne.n	3220950c <strcat+0x2c>
322094fa:	f850 2f04 	ldr.w	r2, [r0, #4]!
322094fe:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
32209502:	ea23 0302 	bic.w	r3, r3, r2
32209506:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
3220950a:	d0f6      	beq.n	322094fa <strcat+0x1a>
3220950c:	7803      	ldrb	r3, [r0, #0]
3220950e:	b11b      	cbz	r3, 32209518 <strcat+0x38>
32209510:	f810 3f01 	ldrb.w	r3, [r0, #1]!
32209514:	2b00      	cmp	r3, #0
32209516:	d1fb      	bne.n	32209510 <strcat+0x30>
32209518:	f7fb fda2 	bl	32205060 <strcpy>
3220951c:	4620      	mov	r0, r4
3220951e:	bd10      	pop	{r4, pc}

32209520 <strchr>:
32209520:	4603      	mov	r3, r0
32209522:	f000 0203 	and.w	r2, r0, #3
32209526:	f011 01ff 	ands.w	r1, r1, #255	@ 0xff
3220952a:	d039      	beq.n	322095a0 <strchr+0x80>
3220952c:	bb8a      	cbnz	r2, 32209592 <strchr+0x72>
3220952e:	b510      	push	{r4, lr}
32209530:	f04f 3e01 	mov.w	lr, #16843009	@ 0x1010101
32209534:	6802      	ldr	r2, [r0, #0]
32209536:	fb0e fe01 	mul.w	lr, lr, r1
3220953a:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
3220953e:	ea23 0302 	bic.w	r3, r3, r2
32209542:	ea8e 0402 	eor.w	r4, lr, r2
32209546:	f1a4 3201 	sub.w	r2, r4, #16843009	@ 0x1010101
3220954a:	ea22 0204 	bic.w	r2, r2, r4
3220954e:	4313      	orrs	r3, r2
32209550:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
32209554:	d10f      	bne.n	32209576 <strchr+0x56>
32209556:	f850 4f04 	ldr.w	r4, [r0, #4]!
3220955a:	ea84 0c0e 	eor.w	ip, r4, lr
3220955e:	f1a4 3301 	sub.w	r3, r4, #16843009	@ 0x1010101
32209562:	f1ac 3201 	sub.w	r2, ip, #16843009	@ 0x1010101
32209566:	ea23 0304 	bic.w	r3, r3, r4
3220956a:	ea22 020c 	bic.w	r2, r2, ip
3220956e:	4313      	orrs	r3, r2
32209570:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
32209574:	d0ef      	beq.n	32209556 <strchr+0x36>
32209576:	7803      	ldrb	r3, [r0, #0]
32209578:	b923      	cbnz	r3, 32209584 <strchr+0x64>
3220957a:	e036      	b.n	322095ea <strchr+0xca>
3220957c:	f810 3f01 	ldrb.w	r3, [r0, #1]!
32209580:	2b00      	cmp	r3, #0
32209582:	d032      	beq.n	322095ea <strchr+0xca>
32209584:	4299      	cmp	r1, r3
32209586:	d1f9      	bne.n	3220957c <strchr+0x5c>
32209588:	bd10      	pop	{r4, pc}
3220958a:	428a      	cmp	r2, r1
3220958c:	d028      	beq.n	322095e0 <strchr+0xc0>
3220958e:	079a      	lsls	r2, r3, #30
32209590:	d029      	beq.n	322095e6 <strchr+0xc6>
32209592:	781a      	ldrb	r2, [r3, #0]
32209594:	4618      	mov	r0, r3
32209596:	3301      	adds	r3, #1
32209598:	2a00      	cmp	r2, #0
3220959a:	d1f6      	bne.n	3220958a <strchr+0x6a>
3220959c:	4610      	mov	r0, r2
3220959e:	4770      	bx	lr
322095a0:	b9ca      	cbnz	r2, 322095d6 <strchr+0xb6>
322095a2:	6802      	ldr	r2, [r0, #0]
322095a4:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
322095a8:	ea23 0302 	bic.w	r3, r3, r2
322095ac:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
322095b0:	d108      	bne.n	322095c4 <strchr+0xa4>
322095b2:	f850 2f04 	ldr.w	r2, [r0, #4]!
322095b6:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
322095ba:	ea23 0302 	bic.w	r3, r3, r2
322095be:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
322095c2:	d0f6      	beq.n	322095b2 <strchr+0x92>
322095c4:	7803      	ldrb	r3, [r0, #0]
322095c6:	b15b      	cbz	r3, 322095e0 <strchr+0xc0>
322095c8:	f810 3f01 	ldrb.w	r3, [r0, #1]!
322095cc:	2b00      	cmp	r3, #0
322095ce:	d1fb      	bne.n	322095c8 <strchr+0xa8>
322095d0:	4770      	bx	lr
322095d2:	0799      	lsls	r1, r3, #30
322095d4:	d005      	beq.n	322095e2 <strchr+0xc2>
322095d6:	4618      	mov	r0, r3
322095d8:	f813 2b01 	ldrb.w	r2, [r3], #1
322095dc:	2a00      	cmp	r2, #0
322095de:	d1f8      	bne.n	322095d2 <strchr+0xb2>
322095e0:	4770      	bx	lr
322095e2:	4618      	mov	r0, r3
322095e4:	e7dd      	b.n	322095a2 <strchr+0x82>
322095e6:	4618      	mov	r0, r3
322095e8:	e7a1      	b.n	3220952e <strchr+0xe>
322095ea:	4618      	mov	r0, r3
322095ec:	bd10      	pop	{r4, pc}
322095ee:	bf00      	nop

322095f0 <strlcpy>:
322095f0:	460b      	mov	r3, r1
322095f2:	b932      	cbnz	r2, 32209602 <strlcpy+0x12>
322095f4:	f813 2b01 	ldrb.w	r2, [r3], #1
322095f8:	2a00      	cmp	r2, #0
322095fa:	d1fb      	bne.n	322095f4 <strlcpy+0x4>
322095fc:	1a58      	subs	r0, r3, r1
322095fe:	3801      	subs	r0, #1
32209600:	4770      	bx	lr
32209602:	3a01      	subs	r2, #1
32209604:	d018      	beq.n	32209638 <strlcpy+0x48>
32209606:	b410      	push	{r4}
32209608:	e001      	b.n	3220960e <strlcpy+0x1e>
3220960a:	3a01      	subs	r2, #1
3220960c:	d00a      	beq.n	32209624 <strlcpy+0x34>
3220960e:	f813 4b01 	ldrb.w	r4, [r3], #1
32209612:	f800 4b01 	strb.w	r4, [r0], #1
32209616:	2c00      	cmp	r4, #0
32209618:	d1f7      	bne.n	3220960a <strlcpy+0x1a>
3220961a:	1a58      	subs	r0, r3, r1
3220961c:	f85d 4b04 	ldr.w	r4, [sp], #4
32209620:	3801      	subs	r0, #1
32209622:	4770      	bx	lr
32209624:	7002      	strb	r2, [r0, #0]
32209626:	f813 2b01 	ldrb.w	r2, [r3], #1
3220962a:	2a00      	cmp	r2, #0
3220962c:	d1fb      	bne.n	32209626 <strlcpy+0x36>
3220962e:	1a58      	subs	r0, r3, r1
32209630:	f85d 4b04 	ldr.w	r4, [sp], #4
32209634:	3801      	subs	r0, #1
32209636:	4770      	bx	lr
32209638:	7002      	strb	r2, [r0, #0]
3220963a:	e7db      	b.n	322095f4 <strlcpy+0x4>

3220963c <strncasecmp>:
3220963c:	b322      	cbz	r2, 32209688 <strncasecmp+0x4c>
3220963e:	b510      	push	{r4, lr}
32209640:	4402      	add	r2, r0
32209642:	4c12      	ldr	r4, [pc, #72]	@ (3220968c <strncasecmp+0x50>)
32209644:	4686      	mov	lr, r0
32209646:	e004      	b.n	32209652 <strncasecmp+0x16>
32209648:	1a1b      	subs	r3, r3, r0
3220964a:	d11b      	bne.n	32209684 <strncasecmp+0x48>
3220964c:	b1b8      	cbz	r0, 3220967e <strncasecmp+0x42>
3220964e:	4596      	cmp	lr, r2
32209650:	d016      	beq.n	32209680 <strncasecmp+0x44>
32209652:	f81e 3b01 	ldrb.w	r3, [lr], #1
32209656:	f811 0b01 	ldrb.w	r0, [r1], #1
3220965a:	f814 c003 	ldrb.w	ip, [r4, r3]
3220965e:	f00c 0c03 	and.w	ip, ip, #3
32209662:	f1bc 0f01 	cmp.w	ip, #1
32209666:	f814 c000 	ldrb.w	ip, [r4, r0]
3220966a:	bf08      	it	eq
3220966c:	3320      	addeq	r3, #32
3220966e:	f00c 0c03 	and.w	ip, ip, #3
32209672:	f1bc 0f01 	cmp.w	ip, #1
32209676:	d1e7      	bne.n	32209648 <strncasecmp+0xc>
32209678:	3020      	adds	r0, #32
3220967a:	1a18      	subs	r0, r3, r0
3220967c:	d0e7      	beq.n	3220964e <strncasecmp+0x12>
3220967e:	bd10      	pop	{r4, pc}
32209680:	2000      	movs	r0, #0
32209682:	bd10      	pop	{r4, pc}
32209684:	4618      	mov	r0, r3
32209686:	bd10      	pop	{r4, pc}
32209688:	4610      	mov	r0, r2
3220968a:	4770      	bx	lr
3220968c:	3220bed9 	.word	0x3220bed9

32209690 <strncmp>:
32209690:	b392      	cbz	r2, 322096f8 <strncmp+0x68>
32209692:	b530      	push	{r4, r5, lr}
32209694:	ea40 0401 	orr.w	r4, r0, r1
32209698:	4686      	mov	lr, r0
3220969a:	460b      	mov	r3, r1
3220969c:	07a4      	lsls	r4, r4, #30
3220969e:	d117      	bne.n	322096d0 <strncmp+0x40>
322096a0:	2a03      	cmp	r2, #3
322096a2:	d807      	bhi.n	322096b4 <strncmp+0x24>
322096a4:	e014      	b.n	322096d0 <strncmp+0x40>
322096a6:	3a04      	subs	r2, #4
322096a8:	d024      	beq.n	322096f4 <strncmp+0x64>
322096aa:	f01c 3f80 	tst.w	ip, #2155905152	@ 0x80808080
322096ae:	d121      	bne.n	322096f4 <strncmp+0x64>
322096b0:	2a03      	cmp	r2, #3
322096b2:	d925      	bls.n	32209700 <strncmp+0x70>
322096b4:	f8de 4000 	ldr.w	r4, [lr]
322096b8:	4619      	mov	r1, r3
322096ba:	f853 5b04 	ldr.w	r5, [r3], #4
322096be:	4670      	mov	r0, lr
322096c0:	f1a4 3c01 	sub.w	ip, r4, #16843009	@ 0x1010101
322096c4:	f10e 0e04 	add.w	lr, lr, #4
322096c8:	ea2c 0c04 	bic.w	ip, ip, r4
322096cc:	42ac      	cmp	r4, r5
322096ce:	d0ea      	beq.n	322096a6 <strncmp+0x16>
322096d0:	7803      	ldrb	r3, [r0, #0]
322096d2:	3a01      	subs	r2, #1
322096d4:	780c      	ldrb	r4, [r1, #0]
322096d6:	42a3      	cmp	r3, r4
322096d8:	bf08      	it	eq
322096da:	1812      	addeq	r2, r2, r0
322096dc:	d006      	beq.n	322096ec <strncmp+0x5c>
322096de:	e00d      	b.n	322096fc <strncmp+0x6c>
322096e0:	f810 3f01 	ldrb.w	r3, [r0, #1]!
322096e4:	f811 4f01 	ldrb.w	r4, [r1, #1]!
322096e8:	42a3      	cmp	r3, r4
322096ea:	d107      	bne.n	322096fc <strncmp+0x6c>
322096ec:	4290      	cmp	r0, r2
322096ee:	bf18      	it	ne
322096f0:	2b00      	cmpne	r3, #0
322096f2:	d1f5      	bne.n	322096e0 <strncmp+0x50>
322096f4:	2000      	movs	r0, #0
322096f6:	bd30      	pop	{r4, r5, pc}
322096f8:	4610      	mov	r0, r2
322096fa:	4770      	bx	lr
322096fc:	1b18      	subs	r0, r3, r4
322096fe:	bd30      	pop	{r4, r5, pc}
32209700:	4670      	mov	r0, lr
32209702:	4619      	mov	r1, r3
32209704:	e7e4      	b.n	322096d0 <strncmp+0x40>
32209706:	bf00      	nop

32209708 <_init_signal_r>:
32209708:	f8d0 3138 	ldr.w	r3, [r0, #312]	@ 0x138
3220970c:	b10b      	cbz	r3, 32209712 <_init_signal_r+0xa>
3220970e:	2000      	movs	r0, #0
32209710:	4770      	bx	lr
32209712:	b510      	push	{r4, lr}
32209714:	4604      	mov	r4, r0
32209716:	2180      	movs	r1, #128	@ 0x80
32209718:	f7fc fa36 	bl	32205b88 <_malloc_r>
3220971c:	f8c4 0138 	str.w	r0, [r4, #312]	@ 0x138
32209720:	b148      	cbz	r0, 32209736 <_init_signal_r+0x2e>
32209722:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
32209726:	f100 0380 	add.w	r3, r0, #128	@ 0x80
3220972a:	f940 0a8d 	vst1.32	{d16-d17}, [r0]!
3220972e:	4283      	cmp	r3, r0
32209730:	d1fb      	bne.n	3220972a <_init_signal_r+0x22>
32209732:	2000      	movs	r0, #0
32209734:	bd10      	pop	{r4, pc}
32209736:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3220973a:	bd10      	pop	{r4, pc}

3220973c <_signal_r>:
3220973c:	b530      	push	{r4, r5, lr}
3220973e:	291f      	cmp	r1, #31
32209740:	4605      	mov	r5, r0
32209742:	b083      	sub	sp, #12
32209744:	d809      	bhi.n	3220975a <_signal_r+0x1e>
32209746:	f8d0 3138 	ldr.w	r3, [r0, #312]	@ 0x138
3220974a:	460c      	mov	r4, r1
3220974c:	b15b      	cbz	r3, 32209766 <_signal_r+0x2a>
3220974e:	f853 0024 	ldr.w	r0, [r3, r4, lsl #2]
32209752:	f843 2024 	str.w	r2, [r3, r4, lsl #2]
32209756:	b003      	add	sp, #12
32209758:	bd30      	pop	{r4, r5, pc}
3220975a:	2316      	movs	r3, #22
3220975c:	6003      	str	r3, [r0, #0]
3220975e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32209762:	b003      	add	sp, #12
32209764:	bd30      	pop	{r4, r5, pc}
32209766:	2180      	movs	r1, #128	@ 0x80
32209768:	9201      	str	r2, [sp, #4]
3220976a:	f7fc fa0d 	bl	32205b88 <_malloc_r>
3220976e:	9a01      	ldr	r2, [sp, #4]
32209770:	4603      	mov	r3, r0
32209772:	4601      	mov	r1, r0
32209774:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
32209778:	f8c5 0138 	str.w	r0, [r5, #312]	@ 0x138
3220977c:	3080      	adds	r0, #128	@ 0x80
3220977e:	2b00      	cmp	r3, #0
32209780:	d0ed      	beq.n	3220975e <_signal_r+0x22>
32209782:	f941 0a8d 	vst1.32	{d16-d17}, [r1]!
32209786:	4288      	cmp	r0, r1
32209788:	d1fb      	bne.n	32209782 <_signal_r+0x46>
3220978a:	e7e0      	b.n	3220974e <_signal_r+0x12>

3220978c <_raise_r>:
3220978c:	b538      	push	{r3, r4, r5, lr}
3220978e:	291f      	cmp	r1, #31
32209790:	4605      	mov	r5, r0
32209792:	d81f      	bhi.n	322097d4 <_raise_r+0x48>
32209794:	f8d0 2138 	ldr.w	r2, [r0, #312]	@ 0x138
32209798:	460c      	mov	r4, r1
3220979a:	b16a      	cbz	r2, 322097b8 <_raise_r+0x2c>
3220979c:	f852 3021 	ldr.w	r3, [r2, r1, lsl #2]
322097a0:	b153      	cbz	r3, 322097b8 <_raise_r+0x2c>
322097a2:	2b01      	cmp	r3, #1
322097a4:	d006      	beq.n	322097b4 <_raise_r+0x28>
322097a6:	1c59      	adds	r1, r3, #1
322097a8:	d010      	beq.n	322097cc <_raise_r+0x40>
322097aa:	2100      	movs	r1, #0
322097ac:	4620      	mov	r0, r4
322097ae:	f842 1024 	str.w	r1, [r2, r4, lsl #2]
322097b2:	4798      	blx	r3
322097b4:	2000      	movs	r0, #0
322097b6:	bd38      	pop	{r3, r4, r5, pc}
322097b8:	4628      	mov	r0, r5
322097ba:	f000 f92b 	bl	32209a14 <_getpid_r>
322097be:	4622      	mov	r2, r4
322097c0:	4601      	mov	r1, r0
322097c2:	4628      	mov	r0, r5
322097c4:	e8bd 4038 	ldmia.w	sp!, {r3, r4, r5, lr}
322097c8:	f000 b90e 	b.w	322099e8 <_kill_r>
322097cc:	2316      	movs	r3, #22
322097ce:	2001      	movs	r0, #1
322097d0:	602b      	str	r3, [r5, #0]
322097d2:	bd38      	pop	{r3, r4, r5, pc}
322097d4:	2316      	movs	r3, #22
322097d6:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
322097da:	602b      	str	r3, [r5, #0]
322097dc:	bd38      	pop	{r3, r4, r5, pc}
322097de:	bf00      	nop

322097e0 <__sigtramp_r>:
322097e0:	291f      	cmp	r1, #31
322097e2:	d82c      	bhi.n	3220983e <__sigtramp_r+0x5e>
322097e4:	f8d0 2138 	ldr.w	r2, [r0, #312]	@ 0x138
322097e8:	b538      	push	{r3, r4, r5, lr}
322097ea:	460c      	mov	r4, r1
322097ec:	4605      	mov	r5, r0
322097ee:	b192      	cbz	r2, 32209816 <__sigtramp_r+0x36>
322097f0:	f852 3024 	ldr.w	r3, [r2, r4, lsl #2]
322097f4:	2001      	movs	r0, #1
322097f6:	b15b      	cbz	r3, 32209810 <__sigtramp_r+0x30>
322097f8:	1c59      	adds	r1, r3, #1
322097fa:	d00a      	beq.n	32209812 <__sigtramp_r+0x32>
322097fc:	2b01      	cmp	r3, #1
322097fe:	bf08      	it	eq
32209800:	2003      	moveq	r0, #3
32209802:	d005      	beq.n	32209810 <__sigtramp_r+0x30>
32209804:	2500      	movs	r5, #0
32209806:	4620      	mov	r0, r4
32209808:	f842 5024 	str.w	r5, [r2, r4, lsl #2]
3220980c:	4798      	blx	r3
3220980e:	4628      	mov	r0, r5
32209810:	bd38      	pop	{r3, r4, r5, pc}
32209812:	2002      	movs	r0, #2
32209814:	bd38      	pop	{r3, r4, r5, pc}
32209816:	2180      	movs	r1, #128	@ 0x80
32209818:	f7fc f9b6 	bl	32205b88 <_malloc_r>
3220981c:	4602      	mov	r2, r0
3220981e:	f8c5 0138 	str.w	r0, [r5, #312]	@ 0x138
32209822:	b148      	cbz	r0, 32209838 <__sigtramp_r+0x58>
32209824:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
32209828:	4603      	mov	r3, r0
3220982a:	f100 0180 	add.w	r1, r0, #128	@ 0x80
3220982e:	f943 0a8d 	vst1.32	{d16-d17}, [r3]!
32209832:	4299      	cmp	r1, r3
32209834:	d1fb      	bne.n	3220982e <__sigtramp_r+0x4e>
32209836:	e7db      	b.n	322097f0 <__sigtramp_r+0x10>
32209838:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3220983c:	bd38      	pop	{r3, r4, r5, pc}
3220983e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32209842:	4770      	bx	lr

32209844 <raise>:
32209844:	b538      	push	{r3, r4, r5, lr}
32209846:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
3220984a:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220984e:	281f      	cmp	r0, #31
32209850:	681d      	ldr	r5, [r3, #0]
32209852:	d81e      	bhi.n	32209892 <raise+0x4e>
32209854:	f8d5 2138 	ldr.w	r2, [r5, #312]	@ 0x138
32209858:	4604      	mov	r4, r0
3220985a:	b162      	cbz	r2, 32209876 <raise+0x32>
3220985c:	f852 3020 	ldr.w	r3, [r2, r0, lsl #2]
32209860:	b14b      	cbz	r3, 32209876 <raise+0x32>
32209862:	2b01      	cmp	r3, #1
32209864:	d005      	beq.n	32209872 <raise+0x2e>
32209866:	1c59      	adds	r1, r3, #1
32209868:	d00f      	beq.n	3220988a <raise+0x46>
3220986a:	2100      	movs	r1, #0
3220986c:	f842 1020 	str.w	r1, [r2, r0, lsl #2]
32209870:	4798      	blx	r3
32209872:	2000      	movs	r0, #0
32209874:	bd38      	pop	{r3, r4, r5, pc}
32209876:	4628      	mov	r0, r5
32209878:	f000 f8cc 	bl	32209a14 <_getpid_r>
3220987c:	4622      	mov	r2, r4
3220987e:	4601      	mov	r1, r0
32209880:	4628      	mov	r0, r5
32209882:	e8bd 4038 	ldmia.w	sp!, {r3, r4, r5, lr}
32209886:	f000 b8af 	b.w	322099e8 <_kill_r>
3220988a:	2316      	movs	r3, #22
3220988c:	2001      	movs	r0, #1
3220988e:	602b      	str	r3, [r5, #0]
32209890:	bd38      	pop	{r3, r4, r5, pc}
32209892:	2316      	movs	r3, #22
32209894:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32209898:	602b      	str	r3, [r5, #0]
3220989a:	bd38      	pop	{r3, r4, r5, pc}

3220989c <signal>:
3220989c:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
322098a0:	f2c3 2320 	movt	r3, #12832	@ 0x3220
322098a4:	b570      	push	{r4, r5, r6, lr}
322098a6:	281f      	cmp	r0, #31
322098a8:	681e      	ldr	r6, [r3, #0]
322098aa:	d809      	bhi.n	322098c0 <signal+0x24>
322098ac:	f8d6 3138 	ldr.w	r3, [r6, #312]	@ 0x138
322098b0:	4604      	mov	r4, r0
322098b2:	460d      	mov	r5, r1
322098b4:	b14b      	cbz	r3, 322098ca <signal+0x2e>
322098b6:	f853 0024 	ldr.w	r0, [r3, r4, lsl #2]
322098ba:	f843 5024 	str.w	r5, [r3, r4, lsl #2]
322098be:	bd70      	pop	{r4, r5, r6, pc}
322098c0:	2316      	movs	r3, #22
322098c2:	6033      	str	r3, [r6, #0]
322098c4:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
322098c8:	bd70      	pop	{r4, r5, r6, pc}
322098ca:	2180      	movs	r1, #128	@ 0x80
322098cc:	4630      	mov	r0, r6
322098ce:	f7fc f95b 	bl	32205b88 <_malloc_r>
322098d2:	4603      	mov	r3, r0
322098d4:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
322098d8:	4602      	mov	r2, r0
322098da:	f100 0180 	add.w	r1, r0, #128	@ 0x80
322098de:	f8c6 0138 	str.w	r0, [r6, #312]	@ 0x138
322098e2:	2800      	cmp	r0, #0
322098e4:	d0ee      	beq.n	322098c4 <signal+0x28>
322098e6:	f942 0a8d 	vst1.32	{d16-d17}, [r2]!
322098ea:	4291      	cmp	r1, r2
322098ec:	d1fb      	bne.n	322098e6 <signal+0x4a>
322098ee:	e7e2      	b.n	322098b6 <signal+0x1a>

322098f0 <_init_signal>:
322098f0:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
322098f4:	f2c3 2320 	movt	r3, #12832	@ 0x3220
322098f8:	b510      	push	{r4, lr}
322098fa:	681c      	ldr	r4, [r3, #0]
322098fc:	f8d4 3138 	ldr.w	r3, [r4, #312]	@ 0x138
32209900:	b10b      	cbz	r3, 32209906 <_init_signal+0x16>
32209902:	2000      	movs	r0, #0
32209904:	bd10      	pop	{r4, pc}
32209906:	2180      	movs	r1, #128	@ 0x80
32209908:	4620      	mov	r0, r4
3220990a:	f7fc f93d 	bl	32205b88 <_malloc_r>
3220990e:	f8c4 0138 	str.w	r0, [r4, #312]	@ 0x138
32209912:	b140      	cbz	r0, 32209926 <_init_signal+0x36>
32209914:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
32209918:	f100 0380 	add.w	r3, r0, #128	@ 0x80
3220991c:	f940 0a8d 	vst1.32	{d16-d17}, [r0]!
32209920:	4298      	cmp	r0, r3
32209922:	d1fb      	bne.n	3220991c <_init_signal+0x2c>
32209924:	e7ed      	b.n	32209902 <_init_signal+0x12>
32209926:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3220992a:	bd10      	pop	{r4, pc}

3220992c <__sigtramp>:
3220992c:	b538      	push	{r3, r4, r5, lr}
3220992e:	f24c 33d0 	movw	r3, #50128	@ 0xc3d0
32209932:	f2c3 2320 	movt	r3, #12832	@ 0x3220
32209936:	281f      	cmp	r0, #31
32209938:	681d      	ldr	r5, [r3, #0]
3220993a:	d828      	bhi.n	3220998e <__sigtramp+0x62>
3220993c:	f8d5 2138 	ldr.w	r2, [r5, #312]	@ 0x138
32209940:	4604      	mov	r4, r0
32209942:	b192      	cbz	r2, 3220996a <__sigtramp+0x3e>
32209944:	f852 3024 	ldr.w	r3, [r2, r4, lsl #2]
32209948:	2001      	movs	r0, #1
3220994a:	b15b      	cbz	r3, 32209964 <__sigtramp+0x38>
3220994c:	1c59      	adds	r1, r3, #1
3220994e:	d00a      	beq.n	32209966 <__sigtramp+0x3a>
32209950:	2b01      	cmp	r3, #1
32209952:	bf08      	it	eq
32209954:	2003      	moveq	r0, #3
32209956:	d005      	beq.n	32209964 <__sigtramp+0x38>
32209958:	2500      	movs	r5, #0
3220995a:	4620      	mov	r0, r4
3220995c:	f842 5024 	str.w	r5, [r2, r4, lsl #2]
32209960:	4798      	blx	r3
32209962:	4628      	mov	r0, r5
32209964:	bd38      	pop	{r3, r4, r5, pc}
32209966:	2002      	movs	r0, #2
32209968:	bd38      	pop	{r3, r4, r5, pc}
3220996a:	2180      	movs	r1, #128	@ 0x80
3220996c:	4628      	mov	r0, r5
3220996e:	f7fc f90b 	bl	32205b88 <_malloc_r>
32209972:	4602      	mov	r2, r0
32209974:	f8c5 0138 	str.w	r0, [r5, #312]	@ 0x138
32209978:	b148      	cbz	r0, 3220998e <__sigtramp+0x62>
3220997a:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
3220997e:	4603      	mov	r3, r0
32209980:	f100 0180 	add.w	r1, r0, #128	@ 0x80
32209984:	f943 0a8d 	vst1.32	{d16-d17}, [r3]!
32209988:	4299      	cmp	r1, r3
3220998a:	d1fb      	bne.n	32209984 <__sigtramp+0x58>
3220998c:	e7da      	b.n	32209944 <__sigtramp+0x18>
3220998e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32209992:	bd38      	pop	{r3, r4, r5, pc}

32209994 <_fstat_r>:
32209994:	b538      	push	{r3, r4, r5, lr}
32209996:	f245 3444 	movw	r4, #21316	@ 0x5344
3220999a:	f2c3 2421 	movt	r4, #12833	@ 0x3221
3220999e:	460d      	mov	r5, r1
322099a0:	4603      	mov	r3, r0
322099a2:	4611      	mov	r1, r2
322099a4:	4628      	mov	r0, r5
322099a6:	2200      	movs	r2, #0
322099a8:	461d      	mov	r5, r3
322099aa:	6022      	str	r2, [r4, #0]
322099ac:	f7f6 ed50 	blx	32200450 <_fstat>
322099b0:	1c43      	adds	r3, r0, #1
322099b2:	d000      	beq.n	322099b6 <_fstat_r+0x22>
322099b4:	bd38      	pop	{r3, r4, r5, pc}
322099b6:	6823      	ldr	r3, [r4, #0]
322099b8:	2b00      	cmp	r3, #0
322099ba:	d0fb      	beq.n	322099b4 <_fstat_r+0x20>
322099bc:	602b      	str	r3, [r5, #0]
322099be:	bd38      	pop	{r3, r4, r5, pc}

322099c0 <_isatty_r>:
322099c0:	b538      	push	{r3, r4, r5, lr}
322099c2:	f245 3444 	movw	r4, #21316	@ 0x5344
322099c6:	f2c3 2421 	movt	r4, #12833	@ 0x3221
322099ca:	4605      	mov	r5, r0
322099cc:	4608      	mov	r0, r1
322099ce:	2200      	movs	r2, #0
322099d0:	6022      	str	r2, [r4, #0]
322099d2:	f7f6 ed46 	blx	32200460 <_isatty>
322099d6:	1c43      	adds	r3, r0, #1
322099d8:	d000      	beq.n	322099dc <_isatty_r+0x1c>
322099da:	bd38      	pop	{r3, r4, r5, pc}
322099dc:	6823      	ldr	r3, [r4, #0]
322099de:	2b00      	cmp	r3, #0
322099e0:	d0fb      	beq.n	322099da <_isatty_r+0x1a>
322099e2:	602b      	str	r3, [r5, #0]
322099e4:	bd38      	pop	{r3, r4, r5, pc}
322099e6:	bf00      	nop

322099e8 <_kill_r>:
322099e8:	b538      	push	{r3, r4, r5, lr}
322099ea:	f245 3444 	movw	r4, #21316	@ 0x5344
322099ee:	f2c3 2421 	movt	r4, #12833	@ 0x3221
322099f2:	460d      	mov	r5, r1
322099f4:	4603      	mov	r3, r0
322099f6:	4611      	mov	r1, r2
322099f8:	4628      	mov	r0, r5
322099fa:	2200      	movs	r2, #0
322099fc:	461d      	mov	r5, r3
322099fe:	6022      	str	r2, [r4, #0]
32209a00:	f7f6 ed54 	blx	322004ac <_kill>
32209a04:	1c43      	adds	r3, r0, #1
32209a06:	d000      	beq.n	32209a0a <_kill_r+0x22>
32209a08:	bd38      	pop	{r3, r4, r5, pc}
32209a0a:	6823      	ldr	r3, [r4, #0]
32209a0c:	2b00      	cmp	r3, #0
32209a0e:	d0fb      	beq.n	32209a08 <_kill_r+0x20>
32209a10:	602b      	str	r3, [r5, #0]
32209a12:	bd38      	pop	{r3, r4, r5, pc}

32209a14 <_getpid_r>:
32209a14:	f001 be58 	b.w	3220b6c8 <___getpid_from_thumb>

32209a18 <_sbrk_r>:
32209a18:	b538      	push	{r3, r4, r5, lr}
32209a1a:	f245 3444 	movw	r4, #21316	@ 0x5344
32209a1e:	f2c3 2421 	movt	r4, #12833	@ 0x3221
32209a22:	4605      	mov	r5, r0
32209a24:	4608      	mov	r0, r1
32209a26:	2200      	movs	r2, #0
32209a28:	6022      	str	r2, [r4, #0]
32209a2a:	f7f6 ed28 	blx	3220047c <_sbrk>
32209a2e:	1c43      	adds	r3, r0, #1
32209a30:	d000      	beq.n	32209a34 <_sbrk_r+0x1c>
32209a32:	bd38      	pop	{r3, r4, r5, pc}
32209a34:	6823      	ldr	r3, [r4, #0]
32209a36:	2b00      	cmp	r3, #0
32209a38:	d0fb      	beq.n	32209a32 <_sbrk_r+0x1a>
32209a3a:	602b      	str	r3, [r5, #0]
32209a3c:	bd38      	pop	{r3, r4, r5, pc}
32209a3e:	bf00      	nop

32209a40 <sysconf>:
32209a40:	2808      	cmp	r0, #8
32209a42:	d102      	bne.n	32209a4a <sysconf+0xa>
32209a44:	f44f 5080 	mov.w	r0, #4096	@ 0x1000
32209a48:	4770      	bx	lr
32209a4a:	b508      	push	{r3, lr}
32209a4c:	f7fb f974 	bl	32204d38 <__errno>
32209a50:	4603      	mov	r3, r0
32209a52:	2216      	movs	r2, #22
32209a54:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32209a58:	601a      	str	r2, [r3, #0]
32209a5a:	bd08      	pop	{r3, pc}
32209a5c:	0000      	movs	r0, r0
	...

32209a60 <frexp>:
32209a60:	b430      	push	{r4, r5}
32209a62:	f64f 7cff 	movw	ip, #65535	@ 0xffff
32209a66:	f6c7 7cef 	movt	ip, #32751	@ 0x7fef
32209a6a:	b082      	sub	sp, #8
32209a6c:	2100      	movs	r1, #0
32209a6e:	6001      	str	r1, [r0, #0]
32209a70:	ed8d 0b00 	vstr	d0, [sp]
32209a74:	9a01      	ldr	r2, [sp, #4]
32209a76:	f022 4300 	bic.w	r3, r2, #2147483648	@ 0x80000000
32209a7a:	4563      	cmp	r3, ip
32209a7c:	d821      	bhi.n	32209ac2 <frexp+0x62>
32209a7e:	9c00      	ldr	r4, [sp, #0]
32209a80:	431c      	orrs	r4, r3
32209a82:	d01e      	beq.n	32209ac2 <frexp+0x62>
32209a84:	460c      	mov	r4, r1
32209a86:	f6c7 74f0 	movt	r4, #32752	@ 0x7ff0
32209a8a:	4014      	ands	r4, r2
32209a8c:	b954      	cbnz	r4, 32209aa4 <frexp+0x44>
32209a8e:	eddf 0b10 	vldr	d16, [pc, #64]	@ 32209ad0 <frexp+0x70>
32209a92:	f06f 0135 	mvn.w	r1, #53	@ 0x35
32209a96:	ee60 0b20 	vmul.f64	d16, d0, d16
32209a9a:	edcd 0b00 	vstr	d16, [sp]
32209a9e:	9a01      	ldr	r2, [sp, #4]
32209aa0:	f022 4300 	bic.w	r3, r2, #2147483648	@ 0x80000000
32209aa4:	151b      	asrs	r3, r3, #20
32209aa6:	f36f 521e 	bfc	r2, #20, #11
32209aaa:	e9dd 4500 	ldrd	r4, r5, [sp]
32209aae:	f2a3 33fe 	subw	r3, r3, #1022	@ 0x3fe
32209ab2:	f042 557f 	orr.w	r5, r2, #1069547520	@ 0x3fc00000
32209ab6:	440b      	add	r3, r1
32209ab8:	f445 1500 	orr.w	r5, r5, #2097152	@ 0x200000
32209abc:	6003      	str	r3, [r0, #0]
32209abe:	e9cd 4500 	strd	r4, r5, [sp]
32209ac2:	ed9d 0b00 	vldr	d0, [sp]
32209ac6:	b002      	add	sp, #8
32209ac8:	bc30      	pop	{r4, r5}
32209aca:	4770      	bx	lr
32209acc:	f3af 8000 	nop.w
32209ad0:	00000000 	.word	0x00000000
32209ad4:	43500000 	.word	0x43500000

32209ad8 <quorem>:
32209ad8:	6903      	ldr	r3, [r0, #16]
32209ada:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32209ade:	690d      	ldr	r5, [r1, #16]
32209ae0:	b085      	sub	sp, #20
32209ae2:	42ab      	cmp	r3, r5
32209ae4:	bfb8      	it	lt
32209ae6:	2000      	movlt	r0, #0
32209ae8:	f2c0 808b 	blt.w	32209c02 <quorem+0x12a>
32209aec:	3d01      	subs	r5, #1
32209aee:	f101 0414 	add.w	r4, r1, #20
32209af2:	f100 0814 	add.w	r8, r0, #20
32209af6:	4681      	mov	r9, r0
32209af8:	ea4f 0c85 	mov.w	ip, r5, lsl #2
32209afc:	f854 3025 	ldr.w	r3, [r4, r5, lsl #2]
32209b00:	eb04 070c 	add.w	r7, r4, ip
32209b04:	f858 2025 	ldr.w	r2, [r8, r5, lsl #2]
32209b08:	eb08 0b0c 	add.w	fp, r8, ip
32209b0c:	3301      	adds	r3, #1
32209b0e:	429a      	cmp	r2, r3
32209b10:	fbb2 f6f3 	udiv	r6, r2, r3
32209b14:	d341      	bcc.n	32209b9a <quorem+0xc2>
32209b16:	2000      	movs	r0, #0
32209b18:	46a2      	mov	sl, r4
32209b1a:	46c6      	mov	lr, r8
32209b1c:	e9cd c401 	strd	ip, r4, [sp, #4]
32209b20:	f8cd 800c 	str.w	r8, [sp, #12]
32209b24:	4603      	mov	r3, r0
32209b26:	4604      	mov	r4, r0
32209b28:	4688      	mov	r8, r1
32209b2a:	f85a 2b04 	ldr.w	r2, [sl], #4
32209b2e:	f8de 1000 	ldr.w	r1, [lr]
32209b32:	4557      	cmp	r7, sl
32209b34:	b290      	uxth	r0, r2
32209b36:	ea4f 4c12 	mov.w	ip, r2, lsr #16
32209b3a:	b28a      	uxth	r2, r1
32209b3c:	fb06 4000 	mla	r0, r6, r0, r4
32209b40:	ea4f 4410 	mov.w	r4, r0, lsr #16
32209b44:	b280      	uxth	r0, r0
32209b46:	eba2 0200 	sub.w	r2, r2, r0
32209b4a:	441a      	add	r2, r3
32209b4c:	fb06 440c 	mla	r4, r6, ip, r4
32209b50:	b2a3      	uxth	r3, r4
32209b52:	ea4f 4414 	mov.w	r4, r4, lsr #16
32209b56:	ebc3 4322 	rsb	r3, r3, r2, asr #16
32209b5a:	b292      	uxth	r2, r2
32209b5c:	eb03 4311 	add.w	r3, r3, r1, lsr #16
32209b60:	ea42 4203 	orr.w	r2, r2, r3, lsl #16
32209b64:	ea4f 4323 	mov.w	r3, r3, asr #16
32209b68:	f84e 2b04 	str.w	r2, [lr], #4
32209b6c:	d2dd      	bcs.n	32209b2a <quorem+0x52>
32209b6e:	e9dd c401 	ldrd	ip, r4, [sp, #4]
32209b72:	4641      	mov	r1, r8
32209b74:	f8dd 800c 	ldr.w	r8, [sp, #12]
32209b78:	f858 300c 	ldr.w	r3, [r8, ip]
32209b7c:	b96b      	cbnz	r3, 32209b9a <quorem+0xc2>
32209b7e:	f1ab 0b04 	sub.w	fp, fp, #4
32209b82:	45d8      	cmp	r8, fp
32209b84:	d303      	bcc.n	32209b8e <quorem+0xb6>
32209b86:	e006      	b.n	32209b96 <quorem+0xbe>
32209b88:	3d01      	subs	r5, #1
32209b8a:	45d8      	cmp	r8, fp
32209b8c:	d203      	bcs.n	32209b96 <quorem+0xbe>
32209b8e:	f85b 3904 	ldr.w	r3, [fp], #-4
32209b92:	2b00      	cmp	r3, #0
32209b94:	d0f8      	beq.n	32209b88 <quorem+0xb0>
32209b96:	f8c9 5010 	str.w	r5, [r9, #16]
32209b9a:	4648      	mov	r0, r9
32209b9c:	f001 fa46 	bl	3220b02c <__mcmp>
32209ba0:	2800      	cmp	r0, #0
32209ba2:	db2d      	blt.n	32209c00 <quorem+0x128>
32209ba4:	2200      	movs	r2, #0
32209ba6:	4641      	mov	r1, r8
32209ba8:	4694      	mov	ip, r2
32209baa:	f854 0b04 	ldr.w	r0, [r4], #4
32209bae:	680b      	ldr	r3, [r1, #0]
32209bb0:	42a7      	cmp	r7, r4
32209bb2:	fa1f fe80 	uxth.w	lr, r0
32209bb6:	ea4f 4010 	mov.w	r0, r0, lsr #16
32209bba:	b29a      	uxth	r2, r3
32209bbc:	eba2 020e 	sub.w	r2, r2, lr
32209bc0:	4462      	add	r2, ip
32209bc2:	ebc0 4022 	rsb	r0, r0, r2, asr #16
32209bc6:	b292      	uxth	r2, r2
32209bc8:	eb00 4013 	add.w	r0, r0, r3, lsr #16
32209bcc:	ea42 4200 	orr.w	r2, r2, r0, lsl #16
32209bd0:	ea4f 4c20 	mov.w	ip, r0, asr #16
32209bd4:	f841 2b04 	str.w	r2, [r1], #4
32209bd8:	d2e7      	bcs.n	32209baa <quorem+0xd2>
32209bda:	f858 2025 	ldr.w	r2, [r8, r5, lsl #2]
32209bde:	eb08 0385 	add.w	r3, r8, r5, lsl #2
32209be2:	b962      	cbnz	r2, 32209bfe <quorem+0x126>
32209be4:	3b04      	subs	r3, #4
32209be6:	4543      	cmp	r3, r8
32209be8:	d803      	bhi.n	32209bf2 <quorem+0x11a>
32209bea:	e006      	b.n	32209bfa <quorem+0x122>
32209bec:	3d01      	subs	r5, #1
32209bee:	4598      	cmp	r8, r3
32209bf0:	d203      	bcs.n	32209bfa <quorem+0x122>
32209bf2:	f853 2904 	ldr.w	r2, [r3], #-4
32209bf6:	2a00      	cmp	r2, #0
32209bf8:	d0f8      	beq.n	32209bec <quorem+0x114>
32209bfa:	f8c9 5010 	str.w	r5, [r9, #16]
32209bfe:	3601      	adds	r6, #1
32209c00:	4630      	mov	r0, r6
32209c02:	b005      	add	sp, #20
32209c04:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}

32209c08 <_dtoa_r>:
32209c08:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32209c0c:	ec57 6b10 	vmov	r6, r7, d0
32209c10:	4604      	mov	r4, r0
32209c12:	ed2d 8b02 	vpush	{d8}
32209c16:	b08f      	sub	sp, #60	@ 0x3c
32209c18:	4692      	mov	sl, r2
32209c1a:	9101      	str	r1, [sp, #4]
32209c1c:	6b81      	ldr	r1, [r0, #56]	@ 0x38
32209c1e:	9d1a      	ldr	r5, [sp, #104]	@ 0x68
32209c20:	9306      	str	r3, [sp, #24]
32209c22:	ed8d 0b02 	vstr	d0, [sp, #8]
32209c26:	b141      	cbz	r1, 32209c3a <_dtoa_r+0x32>
32209c28:	6bc2      	ldr	r2, [r0, #60]	@ 0x3c
32209c2a:	2301      	movs	r3, #1
32209c2c:	604a      	str	r2, [r1, #4]
32209c2e:	4093      	lsls	r3, r2
32209c30:	608b      	str	r3, [r1, #8]
32209c32:	f000 fefd 	bl	3220aa30 <_Bfree>
32209c36:	2300      	movs	r3, #0
32209c38:	63a3      	str	r3, [r4, #56]	@ 0x38
32209c3a:	f1b7 0800 	subs.w	r8, r7, #0
32209c3e:	bfa8      	it	ge
32209c40:	2300      	movge	r3, #0
32209c42:	da04      	bge.n	32209c4e <_dtoa_r+0x46>
32209c44:	2301      	movs	r3, #1
32209c46:	f028 4800 	bic.w	r8, r8, #2147483648	@ 0x80000000
32209c4a:	f8cd 800c 	str.w	r8, [sp, #12]
32209c4e:	602b      	str	r3, [r5, #0]
32209c50:	2300      	movs	r3, #0
32209c52:	f6c7 73f0 	movt	r3, #32752	@ 0x7ff0
32209c56:	ea33 0308 	bics.w	r3, r3, r8
32209c5a:	f000 8092 	beq.w	32209d82 <_dtoa_r+0x17a>
32209c5e:	ed9d 8b02 	vldr	d8, [sp, #8]
32209c62:	eeb5 8b40 	vcmp.f64	d8, #0.0
32209c66:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32209c6a:	d111      	bne.n	32209c90 <_dtoa_r+0x88>
32209c6c:	9a06      	ldr	r2, [sp, #24]
32209c6e:	2301      	movs	r3, #1
32209c70:	6013      	str	r3, [r2, #0]
32209c72:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32209c74:	b113      	cbz	r3, 32209c7c <_dtoa_r+0x74>
32209c76:	9a1b      	ldr	r2, [sp, #108]	@ 0x6c
32209c78:	4bc5      	ldr	r3, [pc, #788]	@ (32209f90 <_dtoa_r+0x388>)
32209c7a:	6013      	str	r3, [r2, #0]
32209c7c:	f64b 3770 	movw	r7, #47984	@ 0xbb70
32209c80:	f2c3 2720 	movt	r7, #12832	@ 0x3220
32209c84:	4638      	mov	r0, r7
32209c86:	b00f      	add	sp, #60	@ 0x3c
32209c88:	ecbd 8b02 	vpop	{d8}
32209c8c:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32209c90:	aa0c      	add	r2, sp, #48	@ 0x30
32209c92:	eeb0 0b48 	vmov.f64	d0, d8
32209c96:	a90d      	add	r1, sp, #52	@ 0x34
32209c98:	4620      	mov	r0, r4
32209c9a:	f001 fb3d 	bl	3220b318 <__d2b>
32209c9e:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32209ca0:	4681      	mov	r9, r0
32209ca2:	ea5f 5318 	movs.w	r3, r8, lsr #20
32209ca6:	f040 8086 	bne.w	32209db6 <_dtoa_r+0x1ae>
32209caa:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32209cac:	4413      	add	r3, r2
32209cae:	f203 4132 	addw	r1, r3, #1074	@ 0x432
32209cb2:	2920      	cmp	r1, #32
32209cb4:	f340 8173 	ble.w	32209f9e <_dtoa_r+0x396>
32209cb8:	f1c1 0140 	rsb	r1, r1, #64	@ 0x40
32209cbc:	fa08 f801 	lsl.w	r8, r8, r1
32209cc0:	f203 4112 	addw	r1, r3, #1042	@ 0x412
32209cc4:	fa26 f101 	lsr.w	r1, r6, r1
32209cc8:	ea48 0101 	orr.w	r1, r8, r1
32209ccc:	ee07 1a10 	vmov	s14, r1
32209cd0:	eeb8 7b47 	vcvt.f64.u32	d7, s14
32209cd4:	3b01      	subs	r3, #1
32209cd6:	f04f 0801 	mov.w	r8, #1
32209cda:	ee17 1a90 	vmov	r1, s15
32209cde:	f1a1 71f8 	sub.w	r1, r1, #32505856	@ 0x1f00000
32209ce2:	ee07 1a90 	vmov	s15, r1
32209ce6:	eef7 4b08 	vmov.f64	d20, #120	@ 0x3fc00000  1.5
32209cea:	eddf 3ba3 	vldr	d19, [pc, #652]	@ 32209f78 <_dtoa_r+0x370>
32209cee:	ee06 3a90 	vmov	s13, r3
32209cf2:	ee37 7b64 	vsub.f64	d7, d7, d20
32209cf6:	eddf 0ba2 	vldr	d16, [pc, #648]	@ 32209f80 <_dtoa_r+0x378>
32209cfa:	eef8 2be6 	vcvt.f64.s32	d18, s13
32209cfe:	eddf 1ba2 	vldr	d17, [pc, #648]	@ 32209f88 <_dtoa_r+0x380>
32209d02:	eee7 0b23 	vfma.f64	d16, d7, d19
32209d06:	eee2 0ba1 	vfma.f64	d16, d18, d17
32209d0a:	eef5 0bc0 	vcmpe.f64	d16, #0.0
32209d0e:	eefd 7be0 	vcvt.s32.f64	s15, d16
32209d12:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32209d16:	edcd 7a04 	vstr	s15, [sp, #16]
32209d1a:	f100 811c 	bmi.w	32209f56 <_dtoa_r+0x34e>
32209d1e:	9904      	ldr	r1, [sp, #16]
32209d20:	1ad3      	subs	r3, r2, r3
32209d22:	1e5d      	subs	r5, r3, #1
32209d24:	2916      	cmp	r1, #22
32209d26:	f200 8104 	bhi.w	32209f32 <_dtoa_r+0x32a>
32209d2a:	f24c 0260 	movw	r2, #49248	@ 0xc060
32209d2e:	f2c3 2220 	movt	r2, #12832	@ 0x3220
32209d32:	eb02 02c1 	add.w	r2, r2, r1, lsl #3
32209d36:	edd2 0b00 	vldr	d16, [r2]
32209d3a:	eeb4 8be0 	vcmpe.f64	d8, d16
32209d3e:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32209d42:	f100 8133 	bmi.w	32209fac <_dtoa_r+0x3a4>
32209d46:	2b00      	cmp	r3, #0
32209d48:	f340 84d9 	ble.w	3220a6fe <_dtoa_r+0xaf6>
32209d4c:	440d      	add	r5, r1
32209d4e:	2300      	movs	r3, #0
32209d50:	e9cd 1309 	strd	r1, r3, [sp, #36]	@ 0x24
32209d54:	9307      	str	r3, [sp, #28]
32209d56:	2300      	movs	r3, #0
32209d58:	9308      	str	r3, [sp, #32]
32209d5a:	9b01      	ldr	r3, [sp, #4]
32209d5c:	2b09      	cmp	r3, #9
32209d5e:	d844      	bhi.n	32209dea <_dtoa_r+0x1e2>
32209d60:	2b05      	cmp	r3, #5
32209d62:	bfd8      	it	le
32209d64:	2601      	movle	r6, #1
32209d66:	dd02      	ble.n	32209d6e <_dtoa_r+0x166>
32209d68:	2600      	movs	r6, #0
32209d6a:	3b04      	subs	r3, #4
32209d6c:	9301      	str	r3, [sp, #4]
32209d6e:	9b01      	ldr	r3, [sp, #4]
32209d70:	3b02      	subs	r3, #2
32209d72:	2b03      	cmp	r3, #3
32209d74:	d83b      	bhi.n	32209dee <_dtoa_r+0x1e6>
32209d76:	e8df f013 	tbh	[pc, r3, lsl #1]
32209d7a:	0215      	.short	0x0215
32209d7c:	02070212 	.word	0x02070212
32209d80:	011f      	.short	0x011f
32209d82:	9a06      	ldr	r2, [sp, #24]
32209d84:	f3c8 0813 	ubfx	r8, r8, #0, #20
32209d88:	f242 730f 	movw	r3, #9999	@ 0x270f
32209d8c:	ea58 0806 	orrs.w	r8, r8, r6
32209d90:	6013      	str	r3, [r2, #0]
32209d92:	d01f      	beq.n	32209dd4 <_dtoa_r+0x1cc>
32209d94:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32209d96:	f64b 3780 	movw	r7, #48000	@ 0xbb80
32209d9a:	f2c3 2720 	movt	r7, #12832	@ 0x3220
32209d9e:	2b00      	cmp	r3, #0
32209da0:	f43f af70 	beq.w	32209c84 <_dtoa_r+0x7c>
32209da4:	1cfb      	adds	r3, r7, #3
32209da6:	9a1b      	ldr	r2, [sp, #108]	@ 0x6c
32209da8:	4638      	mov	r0, r7
32209daa:	6013      	str	r3, [r2, #0]
32209dac:	b00f      	add	sp, #60	@ 0x3c
32209dae:	ecbd 8b02 	vpop	{d8}
32209db2:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32209db6:	ee18 1a90 	vmov	r1, s17
32209dba:	eeb0 7b48 	vmov.f64	d7, d8
32209dbe:	f2a3 33ff 	subw	r3, r3, #1023	@ 0x3ff
32209dc2:	f04f 0800 	mov.w	r8, #0
32209dc6:	f3c1 0113 	ubfx	r1, r1, #0, #20
32209dca:	f041 517f 	orr.w	r1, r1, #1069547520	@ 0x3fc00000
32209dce:	f441 1140 	orr.w	r1, r1, #3145728	@ 0x300000
32209dd2:	e786      	b.n	32209ce2 <_dtoa_r+0xda>
32209dd4:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32209dd6:	f64b 3774 	movw	r7, #47988	@ 0xbb74
32209dda:	f2c3 2720 	movt	r7, #12832	@ 0x3220
32209dde:	2b00      	cmp	r3, #0
32209de0:	f43f af50 	beq.w	32209c84 <_dtoa_r+0x7c>
32209de4:	f107 0308 	add.w	r3, r7, #8
32209de8:	e7dd      	b.n	32209da6 <_dtoa_r+0x19e>
32209dea:	2300      	movs	r3, #0
32209dec:	9301      	str	r3, [sp, #4]
32209dee:	2100      	movs	r1, #0
32209df0:	4620      	mov	r0, r4
32209df2:	63e1      	str	r1, [r4, #60]	@ 0x3c
32209df4:	f000 fdf2 	bl	3220a9dc <_Balloc>
32209df8:	4607      	mov	r7, r0
32209dfa:	2800      	cmp	r0, #0
32209dfc:	f000 8584 	beq.w	3220a908 <_dtoa_r+0xd00>
32209e00:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32209e02:	9904      	ldr	r1, [sp, #16]
32209e04:	43da      	mvns	r2, r3
32209e06:	63a7      	str	r7, [r4, #56]	@ 0x38
32209e08:	290e      	cmp	r1, #14
32209e0a:	ea4f 72d2 	mov.w	r2, r2, lsr #31
32209e0e:	bfc8      	it	gt
32209e10:	2200      	movgt	r2, #0
32209e12:	2a00      	cmp	r2, #0
32209e14:	f040 84dc 	bne.w	3220a7d0 <_dtoa_r+0xbc8>
32209e18:	4692      	mov	sl, r2
32209e1a:	f04f 3bff 	mov.w	fp, #4294967295	@ 0xffffffff
32209e1e:	f8cd b02c 	str.w	fp, [sp, #44]	@ 0x2c
32209e22:	f203 4333 	addw	r3, r3, #1075	@ 0x433
32209e26:	f1b8 0f00 	cmp.w	r8, #0
32209e2a:	f000 8217 	beq.w	3220a25c <_dtoa_r+0x654>
32209e2e:	9a07      	ldr	r2, [sp, #28]
32209e30:	441d      	add	r5, r3
32209e32:	4616      	mov	r6, r2
32209e34:	441a      	add	r2, r3
32209e36:	9b08      	ldr	r3, [sp, #32]
32209e38:	9207      	str	r2, [sp, #28]
32209e3a:	9305      	str	r3, [sp, #20]
32209e3c:	2101      	movs	r1, #1
32209e3e:	4620      	mov	r0, r4
32209e40:	f000 ff22 	bl	3220ac88 <__i2b>
32209e44:	2e00      	cmp	r6, #0
32209e46:	bf18      	it	ne
32209e48:	2d00      	cmpne	r5, #0
32209e4a:	4680      	mov	r8, r0
32209e4c:	f300 8465 	bgt.w	3220a71a <_dtoa_r+0xb12>
32209e50:	9b08      	ldr	r3, [sp, #32]
32209e52:	2b00      	cmp	r3, #0
32209e54:	f040 846e 	bne.w	3220a734 <_dtoa_r+0xb2c>
32209e58:	2301      	movs	r3, #1
32209e5a:	9308      	str	r3, [sp, #32]
32209e5c:	2101      	movs	r1, #1
32209e5e:	4620      	mov	r0, r4
32209e60:	f000 ff12 	bl	3220ac88 <__i2b>
32209e64:	9b09      	ldr	r3, [sp, #36]	@ 0x24
32209e66:	9005      	str	r0, [sp, #20]
32209e68:	2b00      	cmp	r3, #0
32209e6a:	f040 82a2 	bne.w	3220a3b2 <_dtoa_r+0x7aa>
32209e6e:	9b01      	ldr	r3, [sp, #4]
32209e70:	2b01      	cmp	r3, #1
32209e72:	f340 82d1 	ble.w	3220a418 <_dtoa_r+0x810>
32209e76:	2301      	movs	r3, #1
32209e78:	442b      	add	r3, r5
32209e7a:	f013 031f 	ands.w	r3, r3, #31
32209e7e:	f000 8241 	beq.w	3220a304 <_dtoa_r+0x6fc>
32209e82:	f1c3 0220 	rsb	r2, r3, #32
32209e86:	2a04      	cmp	r2, #4
32209e88:	f340 8414 	ble.w	3220a6b4 <_dtoa_r+0xaac>
32209e8c:	f1c3 031c 	rsb	r3, r3, #28
32209e90:	9a07      	ldr	r2, [sp, #28]
32209e92:	441e      	add	r6, r3
32209e94:	441d      	add	r5, r3
32209e96:	441a      	add	r2, r3
32209e98:	9207      	str	r2, [sp, #28]
32209e9a:	9b07      	ldr	r3, [sp, #28]
32209e9c:	2b00      	cmp	r3, #0
32209e9e:	dd05      	ble.n	32209eac <_dtoa_r+0x2a4>
32209ea0:	4649      	mov	r1, r9
32209ea2:	461a      	mov	r2, r3
32209ea4:	4620      	mov	r0, r4
32209ea6:	f001 f84d 	bl	3220af44 <__lshift>
32209eaa:	4681      	mov	r9, r0
32209eac:	2d00      	cmp	r5, #0
32209eae:	dd05      	ble.n	32209ebc <_dtoa_r+0x2b4>
32209eb0:	9905      	ldr	r1, [sp, #20]
32209eb2:	462a      	mov	r2, r5
32209eb4:	4620      	mov	r0, r4
32209eb6:	f001 f845 	bl	3220af44 <__lshift>
32209eba:	9005      	str	r0, [sp, #20]
32209ebc:	9b01      	ldr	r3, [sp, #4]
32209ebe:	2b02      	cmp	r3, #2
32209ec0:	bfd8      	it	le
32209ec2:	2300      	movle	r3, #0
32209ec4:	bfc8      	it	gt
32209ec6:	2301      	movgt	r3, #1
32209ec8:	9307      	str	r3, [sp, #28]
32209eca:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32209ecc:	2b00      	cmp	r3, #0
32209ece:	f040 824d 	bne.w	3220a36c <_dtoa_r+0x764>
32209ed2:	9d07      	ldr	r5, [sp, #28]
32209ed4:	f1bb 0f00 	cmp.w	fp, #0
32209ed8:	f005 0501 	and.w	r5, r5, #1
32209edc:	bfc8      	it	gt
32209ede:	2500      	movgt	r5, #0
32209ee0:	2d00      	cmp	r5, #0
32209ee2:	f000 8162 	beq.w	3220a1aa <_dtoa_r+0x5a2>
32209ee6:	f1bb 0f00 	cmp.w	fp, #0
32209eea:	f040 8234 	bne.w	3220a356 <_dtoa_r+0x74e>
32209eee:	9905      	ldr	r1, [sp, #20]
32209ef0:	465b      	mov	r3, fp
32209ef2:	2205      	movs	r2, #5
32209ef4:	4620      	mov	r0, r4
32209ef6:	f000 fda5 	bl	3220aa44 <__multadd>
32209efa:	4601      	mov	r1, r0
32209efc:	9005      	str	r0, [sp, #20]
32209efe:	4648      	mov	r0, r9
32209f00:	f001 f894 	bl	3220b02c <__mcmp>
32209f04:	2800      	cmp	r0, #0
32209f06:	f340 8226 	ble.w	3220a356 <_dtoa_r+0x74e>
32209f0a:	9e04      	ldr	r6, [sp, #16]
32209f0c:	46bb      	mov	fp, r7
32209f0e:	2331      	movs	r3, #49	@ 0x31
32209f10:	3601      	adds	r6, #1
32209f12:	f80b 3b01 	strb.w	r3, [fp], #1
32209f16:	9905      	ldr	r1, [sp, #20]
32209f18:	4620      	mov	r0, r4
32209f1a:	3601      	adds	r6, #1
32209f1c:	f000 fd88 	bl	3220aa30 <_Bfree>
32209f20:	f1b8 0f00 	cmp.w	r8, #0
32209f24:	f000 811b 	beq.w	3220a15e <_dtoa_r+0x556>
32209f28:	4641      	mov	r1, r8
32209f2a:	4620      	mov	r0, r4
32209f2c:	f000 fd80 	bl	3220aa30 <_Bfree>
32209f30:	e115      	b.n	3220a15e <_dtoa_r+0x556>
32209f32:	2201      	movs	r2, #1
32209f34:	920a      	str	r2, [sp, #40]	@ 0x28
32209f36:	2d00      	cmp	r5, #0
32209f38:	db2c      	blt.n	32209f94 <_dtoa_r+0x38c>
32209f3a:	2300      	movs	r3, #0
32209f3c:	9307      	str	r3, [sp, #28]
32209f3e:	9b04      	ldr	r3, [sp, #16]
32209f40:	2b00      	cmp	r3, #0
32209f42:	da15      	bge.n	32209f70 <_dtoa_r+0x368>
32209f44:	9a07      	ldr	r2, [sp, #28]
32209f46:	9b04      	ldr	r3, [sp, #16]
32209f48:	1ad2      	subs	r2, r2, r3
32209f4a:	425b      	negs	r3, r3
32209f4c:	9207      	str	r2, [sp, #28]
32209f4e:	9308      	str	r3, [sp, #32]
32209f50:	2300      	movs	r3, #0
32209f52:	9309      	str	r3, [sp, #36]	@ 0x24
32209f54:	e701      	b.n	32209d5a <_dtoa_r+0x152>
32209f56:	eef8 1be7 	vcvt.f64.s32	d17, s15
32209f5a:	eef4 1b60 	vcmp.f64	d17, d16
32209f5e:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32209f62:	f43f aedc 	beq.w	32209d1e <_dtoa_r+0x116>
32209f66:	ee17 1a90 	vmov	r1, s15
32209f6a:	3901      	subs	r1, #1
32209f6c:	9104      	str	r1, [sp, #16]
32209f6e:	e6d6      	b.n	32209d1e <_dtoa_r+0x116>
32209f70:	441d      	add	r5, r3
32209f72:	9309      	str	r3, [sp, #36]	@ 0x24
32209f74:	e6ef      	b.n	32209d56 <_dtoa_r+0x14e>
32209f76:	bf00      	nop
32209f78:	636f4361 	.word	0x636f4361
32209f7c:	3fd287a7 	.word	0x3fd287a7
32209f80:	8b60c8b3 	.word	0x8b60c8b3
32209f84:	3fc68a28 	.word	0x3fc68a28
32209f88:	509f79fb 	.word	0x509f79fb
32209f8c:	3fd34413 	.word	0x3fd34413
32209f90:	3220bb71 	.word	0x3220bb71
32209f94:	f1c3 0301 	rsb	r3, r3, #1
32209f98:	2500      	movs	r5, #0
32209f9a:	9307      	str	r3, [sp, #28]
32209f9c:	e7cf      	b.n	32209f3e <_dtoa_r+0x336>
32209f9e:	f1c1 0120 	rsb	r1, r1, #32
32209fa2:	fa06 f101 	lsl.w	r1, r6, r1
32209fa6:	ee07 1a10 	vmov	s14, r1
32209faa:	e691      	b.n	32209cd0 <_dtoa_r+0xc8>
32209fac:	9a04      	ldr	r2, [sp, #16]
32209fae:	3a01      	subs	r2, #1
32209fb0:	9204      	str	r2, [sp, #16]
32209fb2:	2200      	movs	r2, #0
32209fb4:	920a      	str	r2, [sp, #40]	@ 0x28
32209fb6:	e7be      	b.n	32209f36 <_dtoa_r+0x32e>
32209fb8:	2301      	movs	r3, #1
32209fba:	9305      	str	r3, [sp, #20]
32209fbc:	9b04      	ldr	r3, [sp, #16]
32209fbe:	4453      	add	r3, sl
32209fc0:	930b      	str	r3, [sp, #44]	@ 0x2c
32209fc2:	f103 0b01 	add.w	fp, r3, #1
32209fc6:	465f      	mov	r7, fp
32209fc8:	2f01      	cmp	r7, #1
32209fca:	bfb8      	it	lt
32209fcc:	2701      	movlt	r7, #1
32209fce:	2f17      	cmp	r7, #23
32209fd0:	bfc8      	it	gt
32209fd2:	2201      	movgt	r2, #1
32209fd4:	bfc8      	it	gt
32209fd6:	2304      	movgt	r3, #4
32209fd8:	f340 84e2 	ble.w	3220a9a0 <_dtoa_r+0xd98>
32209fdc:	005b      	lsls	r3, r3, #1
32209fde:	4611      	mov	r1, r2
32209fe0:	f103 0014 	add.w	r0, r3, #20
32209fe4:	3201      	adds	r2, #1
32209fe6:	42b8      	cmp	r0, r7
32209fe8:	d9f8      	bls.n	32209fdc <_dtoa_r+0x3d4>
32209fea:	63e1      	str	r1, [r4, #60]	@ 0x3c
32209fec:	4620      	mov	r0, r4
32209fee:	f000 fcf5 	bl	3220a9dc <_Balloc>
32209ff2:	4607      	mov	r7, r0
32209ff4:	2800      	cmp	r0, #0
32209ff6:	f000 8487 	beq.w	3220a908 <_dtoa_r+0xd00>
32209ffa:	f1bb 0f0e 	cmp.w	fp, #14
32209ffe:	f006 0601 	and.w	r6, r6, #1
3220a002:	63a0      	str	r0, [r4, #56]	@ 0x38
3220a004:	bf88      	it	hi
3220a006:	2600      	movhi	r6, #0
3220a008:	2e00      	cmp	r6, #0
3220a00a:	f000 8150 	beq.w	3220a2ae <_dtoa_r+0x6a6>
3220a00e:	9904      	ldr	r1, [sp, #16]
3220a010:	2900      	cmp	r1, #0
3220a012:	f340 8179 	ble.w	3220a308 <_dtoa_r+0x700>
3220a016:	f001 030f 	and.w	r3, r1, #15
3220a01a:	f24c 0260 	movw	r2, #49248	@ 0xc060
3220a01e:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220a022:	eb02 03c3 	add.w	r3, r2, r3, lsl #3
3220a026:	05ca      	lsls	r2, r1, #23
3220a028:	edd3 1b00 	vldr	d17, [r3]
3220a02c:	ea4f 1321 	mov.w	r3, r1, asr #4
3220a030:	f140 81d5 	bpl.w	3220a3de <_dtoa_r+0x7d6>
3220a034:	f24c 0238 	movw	r2, #49208	@ 0xc038
3220a038:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220a03c:	f003 030f 	and.w	r3, r3, #15
3220a040:	2103      	movs	r1, #3
3220a042:	edd2 0b08 	vldr	d16, [r2, #32]
3220a046:	eec8 2b20 	vdiv.f64	d18, d8, d16
3220a04a:	b16b      	cbz	r3, 3220a068 <_dtoa_r+0x460>
3220a04c:	f24c 0238 	movw	r2, #49208	@ 0xc038
3220a050:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220a054:	07de      	lsls	r6, r3, #31
3220a056:	f140 8105 	bpl.w	3220a264 <_dtoa_r+0x65c>
3220a05a:	ecf2 0b02 	vldmia	r2!, {d16}
3220a05e:	3101      	adds	r1, #1
3220a060:	105b      	asrs	r3, r3, #1
3220a062:	ee61 1ba0 	vmul.f64	d17, d17, d16
3220a066:	d1f5      	bne.n	3220a054 <_dtoa_r+0x44c>
3220a068:	eec2 0ba1 	vdiv.f64	d16, d18, d17
3220a06c:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
3220a06e:	b13b      	cbz	r3, 3220a080 <_dtoa_r+0x478>
3220a070:	eef7 1b00 	vmov.f64	d17, #112	@ 0x3f800000  1.0
3220a074:	eef4 0be1 	vcmpe.f64	d16, d17
3220a078:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a07c:	f100 8320 	bmi.w	3220a6c0 <_dtoa_r+0xab8>
3220a080:	ee07 1a90 	vmov	s15, r1
3220a084:	eef8 1be7 	vcvt.f64.s32	d17, s15
3220a088:	eeb1 7b0c 	vmov.f64	d7, #28	@ 0x40e00000  7.0
3220a08c:	eea1 7ba0 	vfma.f64	d7, d17, d16
3220a090:	ee17 1a90 	vmov	r1, s15
3220a094:	ec53 2b17 	vmov	r2, r3, d7
3220a098:	f1a1 7350 	sub.w	r3, r1, #54525952	@ 0x3400000
3220a09c:	f1bb 0f00 	cmp.w	fp, #0
3220a0a0:	f000 80f1 	beq.w	3220a286 <_dtoa_r+0x67e>
3220a0a4:	f8dd e010 	ldr.w	lr, [sp, #16]
3220a0a8:	465e      	mov	r6, fp
3220a0aa:	eefd 7be0 	vcvt.s32.f64	s15, d16
3220a0ae:	ec43 2b32 	vmov	d18, r2, r3
3220a0b2:	9805      	ldr	r0, [sp, #20]
3220a0b4:	f24c 0260 	movw	r2, #49248	@ 0xc060
3220a0b8:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220a0bc:	eb02 03c6 	add.w	r3, r2, r6, lsl #3
3220a0c0:	ee17 1a90 	vmov	r1, s15
3220a0c4:	eef8 1be7 	vcvt.f64.s32	d17, s15
3220a0c8:	ed53 3b02 	vldr	d19, [r3, #-8]
3220a0cc:	1c7b      	adds	r3, r7, #1
3220a0ce:	3130      	adds	r1, #48	@ 0x30
3220a0d0:	ee70 0be1 	vsub.f64	d16, d16, d17
3220a0d4:	b2c9      	uxtb	r1, r1
3220a0d6:	7039      	strb	r1, [r7, #0]
3220a0d8:	2800      	cmp	r0, #0
3220a0da:	f000 81be 	beq.w	3220a45a <_dtoa_r+0x852>
3220a0de:	eef6 4b00 	vmov.f64	d20, #96	@ 0x3f000000  0.5
3220a0e2:	eec4 1ba3 	vdiv.f64	d17, d20, d19
3220a0e6:	ee71 1be2 	vsub.f64	d17, d17, d18
3220a0ea:	eef4 1be0 	vcmpe.f64	d17, d16
3220a0ee:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a0f2:	f300 838f 	bgt.w	3220a814 <_dtoa_r+0xc0c>
3220a0f6:	2000      	movs	r0, #0
3220a0f8:	eef7 4b00 	vmov.f64	d20, #112	@ 0x3f800000  1.0
3220a0fc:	eef2 3b04 	vmov.f64	d19, #36	@ 0x41200000  10.0
3220a100:	e018      	b.n	3220a134 <_dtoa_r+0x52c>
3220a102:	3001      	adds	r0, #1
3220a104:	42b0      	cmp	r0, r6
3220a106:	f280 83a4 	bge.w	3220a852 <_dtoa_r+0xc4a>
3220a10a:	ee60 0ba3 	vmul.f64	d16, d16, d19
3220a10e:	ee61 1ba3 	vmul.f64	d17, d17, d19
3220a112:	eefd 7be0 	vcvt.s32.f64	s15, d16
3220a116:	eef8 2be7 	vcvt.f64.s32	d18, s15
3220a11a:	ee17 1a90 	vmov	r1, s15
3220a11e:	ee70 0be2 	vsub.f64	d16, d16, d18
3220a122:	3130      	adds	r1, #48	@ 0x30
3220a124:	f803 1b01 	strb.w	r1, [r3], #1
3220a128:	eef4 0be1 	vcmpe.f64	d16, d17
3220a12c:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a130:	f100 8370 	bmi.w	3220a814 <_dtoa_r+0xc0c>
3220a134:	ee74 2be0 	vsub.f64	d18, d20, d16
3220a138:	eef4 2be1 	vcmpe.f64	d18, d17
3220a13c:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a140:	d5df      	bpl.n	3220a102 <_dtoa_r+0x4fa>
3220a142:	e002      	b.n	3220a14a <_dtoa_r+0x542>
3220a144:	42bb      	cmp	r3, r7
3220a146:	f000 835f 	beq.w	3220a808 <_dtoa_r+0xc00>
3220a14a:	469b      	mov	fp, r3
3220a14c:	f813 1d01 	ldrb.w	r1, [r3, #-1]!
3220a150:	2939      	cmp	r1, #57	@ 0x39
3220a152:	d0f7      	beq.n	3220a144 <_dtoa_r+0x53c>
3220a154:	3101      	adds	r1, #1
3220a156:	b2c9      	uxtb	r1, r1
3220a158:	7019      	strb	r1, [r3, #0]
3220a15a:	f10e 0601 	add.w	r6, lr, #1
3220a15e:	4649      	mov	r1, r9
3220a160:	4620      	mov	r0, r4
3220a162:	f000 fc65 	bl	3220aa30 <_Bfree>
3220a166:	2300      	movs	r3, #0
3220a168:	f88b 3000 	strb.w	r3, [fp]
3220a16c:	9b06      	ldr	r3, [sp, #24]
3220a16e:	601e      	str	r6, [r3, #0]
3220a170:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
3220a172:	2b00      	cmp	r3, #0
3220a174:	f43f ad86 	beq.w	32209c84 <_dtoa_r+0x7c>
3220a178:	4638      	mov	r0, r7
3220a17a:	f8c3 b000 	str.w	fp, [r3]
3220a17e:	b00f      	add	sp, #60	@ 0x3c
3220a180:	ecbd 8b02 	vpop	{d8}
3220a184:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220a188:	2301      	movs	r3, #1
3220a18a:	9305      	str	r3, [sp, #20]
3220a18c:	f1ba 0f00 	cmp.w	sl, #0
3220a190:	f340 80e5 	ble.w	3220a35e <_dtoa_r+0x756>
3220a194:	46d3      	mov	fp, sl
3220a196:	4657      	mov	r7, sl
3220a198:	f8cd a02c 	str.w	sl, [sp, #44]	@ 0x2c
3220a19c:	e717      	b.n	32209fce <_dtoa_r+0x3c6>
3220a19e:	2300      	movs	r3, #0
3220a1a0:	9305      	str	r3, [sp, #20]
3220a1a2:	e70b      	b.n	32209fbc <_dtoa_r+0x3b4>
3220a1a4:	2300      	movs	r3, #0
3220a1a6:	9305      	str	r3, [sp, #20]
3220a1a8:	e7f0      	b.n	3220a18c <_dtoa_r+0x584>
3220a1aa:	9b08      	ldr	r3, [sp, #32]
3220a1ac:	2b00      	cmp	r3, #0
3220a1ae:	f040 81d6 	bne.w	3220a55e <_dtoa_r+0x956>
3220a1b2:	9e04      	ldr	r6, [sp, #16]
3220a1b4:	3601      	adds	r6, #1
3220a1b6:	46ba      	mov	sl, r7
3220a1b8:	9601      	str	r6, [sp, #4]
3220a1ba:	464f      	mov	r7, r9
3220a1bc:	4626      	mov	r6, r4
3220a1be:	2501      	movs	r5, #1
3220a1c0:	9c05      	ldr	r4, [sp, #20]
3220a1c2:	46d1      	mov	r9, sl
3220a1c4:	e007      	b.n	3220a1d6 <_dtoa_r+0x5ce>
3220a1c6:	4639      	mov	r1, r7
3220a1c8:	2300      	movs	r3, #0
3220a1ca:	220a      	movs	r2, #10
3220a1cc:	4630      	mov	r0, r6
3220a1ce:	f000 fc39 	bl	3220aa44 <__multadd>
3220a1d2:	3501      	adds	r5, #1
3220a1d4:	4607      	mov	r7, r0
3220a1d6:	4621      	mov	r1, r4
3220a1d8:	4638      	mov	r0, r7
3220a1da:	f7ff fc7d 	bl	32209ad8 <quorem>
3220a1de:	455d      	cmp	r5, fp
3220a1e0:	f100 0330 	add.w	r3, r0, #48	@ 0x30
3220a1e4:	f80a 3b01 	strb.w	r3, [sl], #1
3220a1e8:	dbed      	blt.n	3220a1c6 <_dtoa_r+0x5be>
3220a1ea:	464a      	mov	r2, r9
3220a1ec:	f1bb 0f00 	cmp.w	fp, #0
3220a1f0:	f10b 35ff 	add.w	r5, fp, #4294967295	@ 0xffffffff
3220a1f4:	46b9      	mov	r9, r7
3220a1f6:	bfd8      	it	le
3220a1f8:	2500      	movle	r5, #0
3220a1fa:	4617      	mov	r7, r2
3220a1fc:	3201      	adds	r2, #1
3220a1fe:	4634      	mov	r4, r6
3220a200:	4415      	add	r5, r2
3220a202:	9e01      	ldr	r6, [sp, #4]
3220a204:	2200      	movs	r2, #0
3220a206:	9201      	str	r2, [sp, #4]
3220a208:	4649      	mov	r1, r9
3220a20a:	2201      	movs	r2, #1
3220a20c:	4620      	mov	r0, r4
3220a20e:	9304      	str	r3, [sp, #16]
3220a210:	f000 fe98 	bl	3220af44 <__lshift>
3220a214:	9905      	ldr	r1, [sp, #20]
3220a216:	4681      	mov	r9, r0
3220a218:	f000 ff08 	bl	3220b02c <__mcmp>
3220a21c:	2800      	cmp	r0, #0
3220a21e:	dc03      	bgt.n	3220a228 <_dtoa_r+0x620>
3220a220:	e2e7      	b.n	3220a7f2 <_dtoa_r+0xbea>
3220a222:	42bd      	cmp	r5, r7
3220a224:	f000 82e1 	beq.w	3220a7ea <_dtoa_r+0xbe2>
3220a228:	46ab      	mov	fp, r5
3220a22a:	3d01      	subs	r5, #1
3220a22c:	f81b 3c01 	ldrb.w	r3, [fp, #-1]
3220a230:	2b39      	cmp	r3, #57	@ 0x39
3220a232:	d0f6      	beq.n	3220a222 <_dtoa_r+0x61a>
3220a234:	3301      	adds	r3, #1
3220a236:	702b      	strb	r3, [r5, #0]
3220a238:	9905      	ldr	r1, [sp, #20]
3220a23a:	4620      	mov	r0, r4
3220a23c:	f000 fbf8 	bl	3220aa30 <_Bfree>
3220a240:	f1b8 0f00 	cmp.w	r8, #0
3220a244:	d08b      	beq.n	3220a15e <_dtoa_r+0x556>
3220a246:	9901      	ldr	r1, [sp, #4]
3220a248:	4643      	mov	r3, r8
3220a24a:	2900      	cmp	r1, #0
3220a24c:	bf18      	it	ne
3220a24e:	4299      	cmpne	r1, r3
3220a250:	f43f ae6a 	beq.w	32209f28 <_dtoa_r+0x320>
3220a254:	4620      	mov	r0, r4
3220a256:	f000 fbeb 	bl	3220aa30 <_Bfree>
3220a25a:	e665      	b.n	32209f28 <_dtoa_r+0x320>
3220a25c:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3220a25e:	f1c3 0336 	rsb	r3, r3, #54	@ 0x36
3220a262:	e5e4      	b.n	32209e2e <_dtoa_r+0x226>
3220a264:	105b      	asrs	r3, r3, #1
3220a266:	3208      	adds	r2, #8
3220a268:	e6f4      	b.n	3220a054 <_dtoa_r+0x44c>
3220a26a:	ee07 1a90 	vmov	s15, r1
3220a26e:	eef8 1be7 	vcvt.f64.s32	d17, s15
3220a272:	eeb1 7b0c 	vmov.f64	d7, #28	@ 0x40e00000  7.0
3220a276:	eea1 7ba0 	vfma.f64	d7, d17, d16
3220a27a:	ee17 1a90 	vmov	r1, s15
3220a27e:	ec53 2b17 	vmov	r2, r3, d7
3220a282:	f1a1 7350 	sub.w	r3, r1, #54525952	@ 0x3400000
3220a286:	eef1 2b04 	vmov.f64	d18, #20	@ 0x40a00000  5.0
3220a28a:	ec43 2b31 	vmov	d17, r2, r3
3220a28e:	ee70 0be2 	vsub.f64	d16, d16, d18
3220a292:	eef4 0be1 	vcmpe.f64	d16, d17
3220a296:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a29a:	f300 826c 	bgt.w	3220a776 <_dtoa_r+0xb6e>
3220a29e:	eef1 1b61 	vneg.f64	d17, d17
3220a2a2:	eef4 0be1 	vcmpe.f64	d16, d17
3220a2a6:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a2aa:	f100 80ce 	bmi.w	3220a44a <_dtoa_r+0x842>
3220a2ae:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
3220a2b0:	9904      	ldr	r1, [sp, #16]
3220a2b2:	43da      	mvns	r2, r3
3220a2b4:	290e      	cmp	r1, #14
3220a2b6:	ea4f 72d2 	mov.w	r2, r2, lsr #31
3220a2ba:	bfc8      	it	gt
3220a2bc:	2200      	movgt	r2, #0
3220a2be:	2a00      	cmp	r2, #0
3220a2c0:	f040 8337 	bne.w	3220a932 <_dtoa_r+0xd2a>
3220a2c4:	9a05      	ldr	r2, [sp, #20]
3220a2c6:	2a00      	cmp	r2, #0
3220a2c8:	f040 808d 	bne.w	3220a3e6 <_dtoa_r+0x7de>
3220a2cc:	9e07      	ldr	r6, [sp, #28]
3220a2ce:	2e00      	cmp	r6, #0
3220a2d0:	bf18      	it	ne
3220a2d2:	2d00      	cmpne	r5, #0
3220a2d4:	d007      	beq.n	3220a2e6 <_dtoa_r+0x6de>
3220a2d6:	9a07      	ldr	r2, [sp, #28]
3220a2d8:	42aa      	cmp	r2, r5
3220a2da:	4613      	mov	r3, r2
3220a2dc:	bfa8      	it	ge
3220a2de:	462b      	movge	r3, r5
3220a2e0:	1aed      	subs	r5, r5, r3
3220a2e2:	1ad6      	subs	r6, r2, r3
3220a2e4:	9607      	str	r6, [sp, #28]
3220a2e6:	9b08      	ldr	r3, [sp, #32]
3220a2e8:	b90b      	cbnz	r3, 3220a2ee <_dtoa_r+0x6e6>
3220a2ea:	4698      	mov	r8, r3
3220a2ec:	e5b6      	b.n	32209e5c <_dtoa_r+0x254>
3220a2ee:	4649      	mov	r1, r9
3220a2f0:	9a08      	ldr	r2, [sp, #32]
3220a2f2:	4620      	mov	r0, r4
3220a2f4:	f000 fdc2 	bl	3220ae7c <__pow5mult>
3220a2f8:	2300      	movs	r3, #0
3220a2fa:	9e07      	ldr	r6, [sp, #28]
3220a2fc:	4681      	mov	r9, r0
3220a2fe:	4698      	mov	r8, r3
3220a300:	9308      	str	r3, [sp, #32]
3220a302:	e5ab      	b.n	32209e5c <_dtoa_r+0x254>
3220a304:	231c      	movs	r3, #28
3220a306:	e5c3      	b.n	32209e90 <_dtoa_r+0x288>
3220a308:	f000 8203 	beq.w	3220a712 <_dtoa_r+0xb0a>
3220a30c:	9b04      	ldr	r3, [sp, #16]
3220a30e:	f24c 0260 	movw	r2, #49248	@ 0xc060
3220a312:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220a316:	425b      	negs	r3, r3
3220a318:	f003 010f 	and.w	r1, r3, #15
3220a31c:	111b      	asrs	r3, r3, #4
3220a31e:	eb02 02c1 	add.w	r2, r2, r1, lsl #3
3220a322:	edd2 0b00 	vldr	d16, [r2]
3220a326:	ee68 0b20 	vmul.f64	d16, d8, d16
3220a32a:	f000 8330 	beq.w	3220a98e <_dtoa_r+0xd86>
3220a32e:	f24c 0238 	movw	r2, #49208	@ 0xc038
3220a332:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220a336:	2102      	movs	r1, #2
3220a338:	07d8      	lsls	r0, r3, #31
3220a33a:	d509      	bpl.n	3220a350 <_dtoa_r+0x748>
3220a33c:	ecf2 1b02 	vldmia	r2!, {d17}
3220a340:	3101      	adds	r1, #1
3220a342:	105b      	asrs	r3, r3, #1
3220a344:	ee60 0ba1 	vmul.f64	d16, d16, d17
3220a348:	f43f ae90 	beq.w	3220a06c <_dtoa_r+0x464>
3220a34c:	07d8      	lsls	r0, r3, #31
3220a34e:	d4f5      	bmi.n	3220a33c <_dtoa_r+0x734>
3220a350:	105b      	asrs	r3, r3, #1
3220a352:	3208      	adds	r2, #8
3220a354:	e7f0      	b.n	3220a338 <_dtoa_r+0x730>
3220a356:	ea6f 060a 	mvn.w	r6, sl
3220a35a:	46bb      	mov	fp, r7
3220a35c:	e5db      	b.n	32209f16 <_dtoa_r+0x30e>
3220a35e:	2301      	movs	r3, #1
3220a360:	2100      	movs	r1, #0
3220a362:	469b      	mov	fp, r3
3220a364:	469a      	mov	sl, r3
3220a366:	63e1      	str	r1, [r4, #60]	@ 0x3c
3220a368:	930b      	str	r3, [sp, #44]	@ 0x2c
3220a36a:	e63f      	b.n	32209fec <_dtoa_r+0x3e4>
3220a36c:	9905      	ldr	r1, [sp, #20]
3220a36e:	4648      	mov	r0, r9
3220a370:	f000 fe5c 	bl	3220b02c <__mcmp>
3220a374:	2800      	cmp	r0, #0
3220a376:	f6bf adac 	bge.w	32209ed2 <_dtoa_r+0x2ca>
3220a37a:	4649      	mov	r1, r9
3220a37c:	2300      	movs	r3, #0
3220a37e:	220a      	movs	r2, #10
3220a380:	4620      	mov	r0, r4
3220a382:	9d04      	ldr	r5, [sp, #16]
3220a384:	f000 fb5e 	bl	3220aa44 <__multadd>
3220a388:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
3220a38a:	4681      	mov	r9, r0
3220a38c:	f105 3bff 	add.w	fp, r5, #4294967295	@ 0xffffffff
3220a390:	9d07      	ldr	r5, [sp, #28]
3220a392:	2b00      	cmp	r3, #0
3220a394:	9b08      	ldr	r3, [sp, #32]
3220a396:	f005 0501 	and.w	r5, r5, #1
3220a39a:	bfc8      	it	gt
3220a39c:	2500      	movgt	r5, #0
3220a39e:	2b00      	cmp	r3, #0
3220a3a0:	f040 80cf 	bne.w	3220a542 <_dtoa_r+0x93a>
3220a3a4:	2d00      	cmp	r5, #0
3220a3a6:	f040 82ec 	bne.w	3220a982 <_dtoa_r+0xd7a>
3220a3aa:	9e04      	ldr	r6, [sp, #16]
3220a3ac:	f8dd b02c 	ldr.w	fp, [sp, #44]	@ 0x2c
3220a3b0:	e701      	b.n	3220a1b6 <_dtoa_r+0x5ae>
3220a3b2:	461a      	mov	r2, r3
3220a3b4:	4601      	mov	r1, r0
3220a3b6:	4620      	mov	r0, r4
3220a3b8:	f000 fd60 	bl	3220ae7c <__pow5mult>
3220a3bc:	9b01      	ldr	r3, [sp, #4]
3220a3be:	9005      	str	r0, [sp, #20]
3220a3c0:	2b01      	cmp	r3, #1
3220a3c2:	f340 81f8 	ble.w	3220a7b6 <_dtoa_r+0xbae>
3220a3c6:	2300      	movs	r3, #0
3220a3c8:	9309      	str	r3, [sp, #36]	@ 0x24
3220a3ca:	9a05      	ldr	r2, [sp, #20]
3220a3cc:	6913      	ldr	r3, [r2, #16]
3220a3ce:	eb02 0383 	add.w	r3, r2, r3, lsl #2
3220a3d2:	6918      	ldr	r0, [r3, #16]
3220a3d4:	f000 fbe8 	bl	3220aba8 <__hi0bits>
3220a3d8:	f1c0 0320 	rsb	r3, r0, #32
3220a3dc:	e54c      	b.n	32209e78 <_dtoa_r+0x270>
3220a3de:	eef0 2b48 	vmov.f64	d18, d8
3220a3e2:	2102      	movs	r1, #2
3220a3e4:	e631      	b.n	3220a04a <_dtoa_r+0x442>
3220a3e6:	9a01      	ldr	r2, [sp, #4]
3220a3e8:	2a01      	cmp	r2, #1
3220a3ea:	f77f ad1a 	ble.w	32209e22 <_dtoa_r+0x21a>
3220a3ee:	9b08      	ldr	r3, [sp, #32]
3220a3f0:	f10b 32ff 	add.w	r2, fp, #4294967295	@ 0xffffffff
3220a3f4:	4293      	cmp	r3, r2
3220a3f6:	f2c0 81c9 	blt.w	3220a78c <_dtoa_r+0xb84>
3220a3fa:	1a9b      	subs	r3, r3, r2
3220a3fc:	9305      	str	r3, [sp, #20]
3220a3fe:	9b07      	ldr	r3, [sp, #28]
3220a400:	f1bb 0f00 	cmp.w	fp, #0
3220a404:	eba3 060b 	sub.w	r6, r3, fp
3220a408:	f6ff ad18 	blt.w	32209e3c <_dtoa_r+0x234>
3220a40c:	9b07      	ldr	r3, [sp, #28]
3220a40e:	445d      	add	r5, fp
3220a410:	461e      	mov	r6, r3
3220a412:	445b      	add	r3, fp
3220a414:	9307      	str	r3, [sp, #28]
3220a416:	e511      	b.n	32209e3c <_dtoa_r+0x234>
3220a418:	9b02      	ldr	r3, [sp, #8]
3220a41a:	2b00      	cmp	r3, #0
3220a41c:	f47f ad2b 	bne.w	32209e76 <_dtoa_r+0x26e>
3220a420:	9b03      	ldr	r3, [sp, #12]
3220a422:	f3c3 0313 	ubfx	r3, r3, #0, #20
3220a426:	2b00      	cmp	r3, #0
3220a428:	f47f ad25 	bne.w	32209e76 <_dtoa_r+0x26e>
3220a42c:	9b03      	ldr	r3, [sp, #12]
3220a42e:	f023 4300 	bic.w	r3, r3, #2147483648	@ 0x80000000
3220a432:	0d1b      	lsrs	r3, r3, #20
3220a434:	051b      	lsls	r3, r3, #20
3220a436:	2b00      	cmp	r3, #0
3220a438:	f43f ad1d 	beq.w	32209e76 <_dtoa_r+0x26e>
3220a43c:	9b07      	ldr	r3, [sp, #28]
3220a43e:	3501      	adds	r5, #1
3220a440:	3301      	adds	r3, #1
3220a442:	9307      	str	r3, [sp, #28]
3220a444:	2301      	movs	r3, #1
3220a446:	9309      	str	r3, [sp, #36]	@ 0x24
3220a448:	e516      	b.n	32209e78 <_dtoa_r+0x270>
3220a44a:	2100      	movs	r1, #0
3220a44c:	4620      	mov	r0, r4
3220a44e:	f1ca 0600 	rsb	r6, sl, #0
3220a452:	46bb      	mov	fp, r7
3220a454:	f000 faec 	bl	3220aa30 <_Bfree>
3220a458:	e681      	b.n	3220a15e <_dtoa_r+0x556>
3220a45a:	ee62 3ba3 	vmul.f64	d19, d18, d19
3220a45e:	eb07 0c06 	add.w	ip, r7, r6
3220a462:	4618      	mov	r0, r3
3220a464:	2e01      	cmp	r6, #1
3220a466:	eef2 2b04 	vmov.f64	d18, #36	@ 0x41200000  10.0
3220a46a:	f000 8288 	beq.w	3220a97e <_dtoa_r+0xd76>
3220a46e:	ee60 0ba2 	vmul.f64	d16, d16, d18
3220a472:	eefd 7be0 	vcvt.s32.f64	s15, d16
3220a476:	ee17 1a90 	vmov	r1, s15
3220a47a:	eef8 1be7 	vcvt.f64.s32	d17, s15
3220a47e:	3130      	adds	r1, #48	@ 0x30
3220a480:	f800 1b01 	strb.w	r1, [r0], #1
3220a484:	ee70 0be1 	vsub.f64	d16, d16, d17
3220a488:	4584      	cmp	ip, r0
3220a48a:	d1f0      	bne.n	3220a46e <_dtoa_r+0x866>
3220a48c:	1e59      	subs	r1, r3, #1
3220a48e:	4431      	add	r1, r6
3220a490:	eef6 1b00 	vmov.f64	d17, #96	@ 0x3f000000  0.5
3220a494:	ee73 2ba1 	vadd.f64	d18, d19, d17
3220a498:	eef4 2be0 	vcmpe.f64	d18, d16
3220a49c:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a4a0:	f100 81bc 	bmi.w	3220a81c <_dtoa_r+0xc14>
3220a4a4:	ee71 1be3 	vsub.f64	d17, d17, d19
3220a4a8:	eef4 1be0 	vcmpe.f64	d17, d16
3220a4ac:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a4b0:	dc40      	bgt.n	3220a534 <_dtoa_r+0x92c>
3220a4b2:	990d      	ldr	r1, [sp, #52]	@ 0x34
3220a4b4:	9804      	ldr	r0, [sp, #16]
3220a4b6:	43c9      	mvns	r1, r1
3220a4b8:	280e      	cmp	r0, #14
3220a4ba:	ea4f 71d1 	mov.w	r1, r1, lsr #31
3220a4be:	bfc8      	it	gt
3220a4c0:	2100      	movgt	r1, #0
3220a4c2:	2900      	cmp	r1, #0
3220a4c4:	f43f af02 	beq.w	3220a2cc <_dtoa_r+0x6c4>
3220a4c8:	9904      	ldr	r1, [sp, #16]
3220a4ca:	eb02 02c1 	add.w	r2, r2, r1, lsl #3
3220a4ce:	edd2 1b00 	vldr	d17, [r2]
3220a4d2:	eec8 0b21 	vdiv.f64	d16, d8, d17
3220a4d6:	f1c3 0101 	rsb	r1, r3, #1
3220a4da:	f1bb 0f01 	cmp.w	fp, #1
3220a4de:	eef2 2b04 	vmov.f64	d18, #36	@ 0x41200000  10.0
3220a4e2:	eefd 7be0 	vcvt.s32.f64	s15, d16
3220a4e6:	eef8 0be7 	vcvt.f64.s32	d16, s15
3220a4ea:	ee17 2a90 	vmov	r2, s15
3220a4ee:	eea0 8be1 	vfms.f64	d8, d16, d17
3220a4f2:	f102 0230 	add.w	r2, r2, #48	@ 0x30
3220a4f6:	703a      	strb	r2, [r7, #0]
3220a4f8:	d111      	bne.n	3220a51e <_dtoa_r+0x916>
3220a4fa:	e1ee      	b.n	3220a8da <_dtoa_r+0xcd2>
3220a4fc:	eec8 0b21 	vdiv.f64	d16, d8, d17
3220a500:	eefd 7be0 	vcvt.s32.f64	s15, d16
3220a504:	ee17 2a90 	vmov	r2, s15
3220a508:	eef8 0be7 	vcvt.f64.s32	d16, s15
3220a50c:	3230      	adds	r2, #48	@ 0x30
3220a50e:	f803 2b01 	strb.w	r2, [r3], #1
3220a512:	eea0 8be1 	vfms.f64	d8, d16, d17
3220a516:	185a      	adds	r2, r3, r1
3220a518:	455a      	cmp	r2, fp
3220a51a:	f000 81de 	beq.w	3220a8da <_dtoa_r+0xcd2>
3220a51e:	ee28 8b22 	vmul.f64	d8, d8, d18
3220a522:	eeb5 8b40 	vcmp.f64	d8, #0.0
3220a526:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a52a:	d1e7      	bne.n	3220a4fc <_dtoa_r+0x8f4>
3220a52c:	9e04      	ldr	r6, [sp, #16]
3220a52e:	469b      	mov	fp, r3
3220a530:	3601      	adds	r6, #1
3220a532:	e614      	b.n	3220a15e <_dtoa_r+0x556>
3220a534:	468b      	mov	fp, r1
3220a536:	3901      	subs	r1, #1
3220a538:	f81b 3c01 	ldrb.w	r3, [fp, #-1]
3220a53c:	2b30      	cmp	r3, #48	@ 0x30
3220a53e:	d0f9      	beq.n	3220a534 <_dtoa_r+0x92c>
3220a540:	e60b      	b.n	3220a15a <_dtoa_r+0x552>
3220a542:	4641      	mov	r1, r8
3220a544:	2300      	movs	r3, #0
3220a546:	220a      	movs	r2, #10
3220a548:	4620      	mov	r0, r4
3220a54a:	f000 fa7b 	bl	3220aa44 <__multadd>
3220a54e:	f8cd b010 	str.w	fp, [sp, #16]
3220a552:	4680      	mov	r8, r0
3220a554:	f8dd b02c 	ldr.w	fp, [sp, #44]	@ 0x2c
3220a558:	2d00      	cmp	r5, #0
3220a55a:	f47f acc4 	bne.w	32209ee6 <_dtoa_r+0x2de>
3220a55e:	2e00      	cmp	r6, #0
3220a560:	dd05      	ble.n	3220a56e <_dtoa_r+0x966>
3220a562:	4641      	mov	r1, r8
3220a564:	4632      	mov	r2, r6
3220a566:	4620      	mov	r0, r4
3220a568:	f000 fcec 	bl	3220af44 <__lshift>
3220a56c:	4680      	mov	r8, r0
3220a56e:	9b09      	ldr	r3, [sp, #36]	@ 0x24
3220a570:	46c2      	mov	sl, r8
3220a572:	2b00      	cmp	r3, #0
3220a574:	f040 8154 	bne.w	3220a820 <_dtoa_r+0xc18>
3220a578:	1e7b      	subs	r3, r7, #1
3220a57a:	463e      	mov	r6, r7
3220a57c:	445b      	add	r3, fp
3220a57e:	9308      	str	r3, [sp, #32]
3220a580:	9b02      	ldr	r3, [sp, #8]
3220a582:	f003 0301 	and.w	r3, r3, #1
3220a586:	e9cd 3709 	strd	r3, r7, [sp, #36]	@ 0x24
3220a58a:	9905      	ldr	r1, [sp, #20]
3220a58c:	4648      	mov	r0, r9
3220a58e:	f7ff faa3 	bl	32209ad8 <quorem>
3220a592:	4641      	mov	r1, r8
3220a594:	4683      	mov	fp, r0
3220a596:	4648      	mov	r0, r9
3220a598:	f000 fd48 	bl	3220b02c <__mcmp>
3220a59c:	9905      	ldr	r1, [sp, #20]
3220a59e:	4605      	mov	r5, r0
3220a5a0:	4652      	mov	r2, sl
3220a5a2:	4620      	mov	r0, r4
3220a5a4:	f10b 0730 	add.w	r7, fp, #48	@ 0x30
3220a5a8:	f000 fd60 	bl	3220b06c <__mdiff>
3220a5ac:	68c3      	ldr	r3, [r0, #12]
3220a5ae:	4601      	mov	r1, r0
3220a5b0:	bb9b      	cbnz	r3, 3220a61a <_dtoa_r+0xa12>
3220a5b2:	9007      	str	r0, [sp, #28]
3220a5b4:	4648      	mov	r0, r9
3220a5b6:	f000 fd39 	bl	3220b02c <__mcmp>
3220a5ba:	9907      	ldr	r1, [sp, #28]
3220a5bc:	9007      	str	r0, [sp, #28]
3220a5be:	4620      	mov	r0, r4
3220a5c0:	f000 fa36 	bl	3220aa30 <_Bfree>
3220a5c4:	9b01      	ldr	r3, [sp, #4]
3220a5c6:	9a07      	ldr	r2, [sp, #28]
3220a5c8:	4313      	orrs	r3, r2
3220a5ca:	d156      	bne.n	3220a67a <_dtoa_r+0xa72>
3220a5cc:	9b09      	ldr	r3, [sp, #36]	@ 0x24
3220a5ce:	2b00      	cmp	r3, #0
3220a5d0:	f000 81cc 	beq.w	3220a96c <_dtoa_r+0xd64>
3220a5d4:	2d00      	cmp	r5, #0
3220a5d6:	f2c0 81c6 	blt.w	3220a966 <_dtoa_r+0xd5e>
3220a5da:	4635      	mov	r5, r6
3220a5dc:	9b08      	ldr	r3, [sp, #32]
3220a5de:	42b3      	cmp	r3, r6
3220a5e0:	f805 7b01 	strb.w	r7, [r5], #1
3220a5e4:	f000 819d 	beq.w	3220a922 <_dtoa_r+0xd1a>
3220a5e8:	4649      	mov	r1, r9
3220a5ea:	2300      	movs	r3, #0
3220a5ec:	220a      	movs	r2, #10
3220a5ee:	4620      	mov	r0, r4
3220a5f0:	f000 fa28 	bl	3220aa44 <__multadd>
3220a5f4:	4641      	mov	r1, r8
3220a5f6:	4681      	mov	r9, r0
3220a5f8:	2300      	movs	r3, #0
3220a5fa:	220a      	movs	r2, #10
3220a5fc:	4620      	mov	r0, r4
3220a5fe:	45d0      	cmp	r8, sl
3220a600:	d035      	beq.n	3220a66e <_dtoa_r+0xa66>
3220a602:	f000 fa1f 	bl	3220aa44 <__multadd>
3220a606:	4651      	mov	r1, sl
3220a608:	4680      	mov	r8, r0
3220a60a:	2300      	movs	r3, #0
3220a60c:	220a      	movs	r2, #10
3220a60e:	4620      	mov	r0, r4
3220a610:	f000 fa18 	bl	3220aa44 <__multadd>
3220a614:	462e      	mov	r6, r5
3220a616:	4682      	mov	sl, r0
3220a618:	e7b7      	b.n	3220a58a <_dtoa_r+0x982>
3220a61a:	4620      	mov	r0, r4
3220a61c:	9707      	str	r7, [sp, #28]
3220a61e:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3220a620:	f000 fa06 	bl	3220aa30 <_Bfree>
3220a624:	9b07      	ldr	r3, [sp, #28]
3220a626:	2d00      	cmp	r5, #0
3220a628:	db06      	blt.n	3220a638 <_dtoa_r+0xa30>
3220a62a:	9a02      	ldr	r2, [sp, #8]
3220a62c:	9901      	ldr	r1, [sp, #4]
3220a62e:	f002 0201 	and.w	r2, r2, #1
3220a632:	430d      	orrs	r5, r1
3220a634:	432a      	orrs	r2, r5
3220a636:	d12d      	bne.n	3220a694 <_dtoa_r+0xa8c>
3220a638:	4649      	mov	r1, r9
3220a63a:	2201      	movs	r2, #1
3220a63c:	4620      	mov	r0, r4
3220a63e:	9301      	str	r3, [sp, #4]
3220a640:	f000 fc80 	bl	3220af44 <__lshift>
3220a644:	9905      	ldr	r1, [sp, #20]
3220a646:	4681      	mov	r9, r0
3220a648:	f000 fcf0 	bl	3220b02c <__mcmp>
3220a64c:	9b01      	ldr	r3, [sp, #4]
3220a64e:	2800      	cmp	r0, #0
3220a650:	f340 81a0 	ble.w	3220a994 <_dtoa_r+0xd8c>
3220a654:	2b39      	cmp	r3, #57	@ 0x39
3220a656:	d023      	beq.n	3220a6a0 <_dtoa_r+0xa98>
3220a658:	f10b 0331 	add.w	r3, fp, #49	@ 0x31
3220a65c:	46b3      	mov	fp, r6
3220a65e:	9e04      	ldr	r6, [sp, #16]
3220a660:	f8cd 8004 	str.w	r8, [sp, #4]
3220a664:	46d0      	mov	r8, sl
3220a666:	3601      	adds	r6, #1
3220a668:	f80b 3b01 	strb.w	r3, [fp], #1
3220a66c:	e5e4      	b.n	3220a238 <_dtoa_r+0x630>
3220a66e:	f000 f9e9 	bl	3220aa44 <__multadd>
3220a672:	462e      	mov	r6, r5
3220a674:	4680      	mov	r8, r0
3220a676:	4682      	mov	sl, r0
3220a678:	e787      	b.n	3220a58a <_dtoa_r+0x982>
3220a67a:	2d00      	cmp	r5, #0
3220a67c:	f2c0 815e 	blt.w	3220a93c <_dtoa_r+0xd34>
3220a680:	9b01      	ldr	r3, [sp, #4]
3220a682:	431d      	orrs	r5, r3
3220a684:	9b09      	ldr	r3, [sp, #36]	@ 0x24
3220a686:	431d      	orrs	r5, r3
3220a688:	f000 8158 	beq.w	3220a93c <_dtoa_r+0xd34>
3220a68c:	2a00      	cmp	r2, #0
3220a68e:	dda4      	ble.n	3220a5da <_dtoa_r+0x9d2>
3220a690:	463b      	mov	r3, r7
3220a692:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3220a694:	2b39      	cmp	r3, #57	@ 0x39
3220a696:	bf18      	it	ne
3220a698:	46b3      	movne	fp, r6
3220a69a:	bf18      	it	ne
3220a69c:	3301      	addne	r3, #1
3220a69e:	d1de      	bne.n	3220a65e <_dtoa_r+0xa56>
3220a6a0:	4635      	mov	r5, r6
3220a6a2:	9e04      	ldr	r6, [sp, #16]
3220a6a4:	2339      	movs	r3, #57	@ 0x39
3220a6a6:	f8cd 8004 	str.w	r8, [sp, #4]
3220a6aa:	3601      	adds	r6, #1
3220a6ac:	46d0      	mov	r8, sl
3220a6ae:	f805 3b01 	strb.w	r3, [r5], #1
3220a6b2:	e5b9      	b.n	3220a228 <_dtoa_r+0x620>
3220a6b4:	f43f abf1 	beq.w	32209e9a <_dtoa_r+0x292>
3220a6b8:	f1c3 033c 	rsb	r3, r3, #60	@ 0x3c
3220a6bc:	f7ff bbe8 	b.w	32209e90 <_dtoa_r+0x288>
3220a6c0:	f1bb 0f00 	cmp.w	fp, #0
3220a6c4:	f43f add1 	beq.w	3220a26a <_dtoa_r+0x662>
3220a6c8:	9e0b      	ldr	r6, [sp, #44]	@ 0x2c
3220a6ca:	2e00      	cmp	r6, #0
3220a6cc:	f77f adef 	ble.w	3220a2ae <_dtoa_r+0x6a6>
3220a6d0:	3101      	adds	r1, #1
3220a6d2:	eef2 2b04 	vmov.f64	d18, #36	@ 0x41200000  10.0
3220a6d6:	ee07 1a90 	vmov	s15, r1
3220a6da:	9b04      	ldr	r3, [sp, #16]
3220a6dc:	ee60 0ba2 	vmul.f64	d16, d16, d18
3220a6e0:	eef8 1be7 	vcvt.f64.s32	d17, s15
3220a6e4:	eeb1 7b0c 	vmov.f64	d7, #28	@ 0x40e00000  7.0
3220a6e8:	f103 3eff 	add.w	lr, r3, #4294967295	@ 0xffffffff
3220a6ec:	eea0 7ba1 	vfma.f64	d7, d16, d17
3220a6f0:	ee17 1a90 	vmov	r1, s15
3220a6f4:	ec53 2b17 	vmov	r2, r3, d7
3220a6f8:	f1a1 7350 	sub.w	r3, r1, #54525952	@ 0x3400000
3220a6fc:	e4d5      	b.n	3220a0aa <_dtoa_r+0x4a2>
3220a6fe:	f1c3 0301 	rsb	r3, r3, #1
3220a702:	9307      	str	r3, [sp, #28]
3220a704:	9b04      	ldr	r3, [sp, #16]
3220a706:	9309      	str	r3, [sp, #36]	@ 0x24
3220a708:	461d      	mov	r5, r3
3220a70a:	2300      	movs	r3, #0
3220a70c:	930a      	str	r3, [sp, #40]	@ 0x28
3220a70e:	f7ff bb22 	b.w	32209d56 <_dtoa_r+0x14e>
3220a712:	eef0 0b48 	vmov.f64	d16, d8
3220a716:	2102      	movs	r1, #2
3220a718:	e4a8      	b.n	3220a06c <_dtoa_r+0x464>
3220a71a:	42ae      	cmp	r6, r5
3220a71c:	9a07      	ldr	r2, [sp, #28]
3220a71e:	4633      	mov	r3, r6
3220a720:	bfa8      	it	ge
3220a722:	462b      	movge	r3, r5
3220a724:	1ad2      	subs	r2, r2, r3
3220a726:	1af6      	subs	r6, r6, r3
3220a728:	1aed      	subs	r5, r5, r3
3220a72a:	9b08      	ldr	r3, [sp, #32]
3220a72c:	9207      	str	r2, [sp, #28]
3220a72e:	2b00      	cmp	r3, #0
3220a730:	f43f ab92 	beq.w	32209e58 <_dtoa_r+0x250>
3220a734:	9b05      	ldr	r3, [sp, #20]
3220a736:	2b00      	cmp	r3, #0
3220a738:	d06a      	beq.n	3220a810 <_dtoa_r+0xc08>
3220a73a:	461a      	mov	r2, r3
3220a73c:	4641      	mov	r1, r8
3220a73e:	4620      	mov	r0, r4
3220a740:	f000 fb9c 	bl	3220ae7c <__pow5mult>
3220a744:	464a      	mov	r2, r9
3220a746:	4601      	mov	r1, r0
3220a748:	4680      	mov	r8, r0
3220a74a:	4620      	mov	r0, r4
3220a74c:	f000 fad8 	bl	3220ad00 <__multiply>
3220a750:	4649      	mov	r1, r9
3220a752:	4681      	mov	r9, r0
3220a754:	4620      	mov	r0, r4
3220a756:	f000 f96b 	bl	3220aa30 <_Bfree>
3220a75a:	9908      	ldr	r1, [sp, #32]
3220a75c:	9b05      	ldr	r3, [sp, #20]
3220a75e:	1aca      	subs	r2, r1, r3
3220a760:	f43f ab7a 	beq.w	32209e58 <_dtoa_r+0x250>
3220a764:	4649      	mov	r1, r9
3220a766:	4620      	mov	r0, r4
3220a768:	f000 fb88 	bl	3220ae7c <__pow5mult>
3220a76c:	2301      	movs	r3, #1
3220a76e:	4681      	mov	r9, r0
3220a770:	9308      	str	r3, [sp, #32]
3220a772:	f7ff bb73 	b.w	32209e5c <_dtoa_r+0x254>
3220a776:	46bb      	mov	fp, r7
3220a778:	2331      	movs	r3, #49	@ 0x31
3220a77a:	2100      	movs	r1, #0
3220a77c:	4620      	mov	r0, r4
3220a77e:	f80b 3b01 	strb.w	r3, [fp], #1
3220a782:	f000 f955 	bl	3220aa30 <_Bfree>
3220a786:	9e04      	ldr	r6, [sp, #16]
3220a788:	3602      	adds	r6, #2
3220a78a:	e4e8      	b.n	3220a15e <_dtoa_r+0x556>
3220a78c:	9b08      	ldr	r3, [sp, #32]
3220a78e:	2101      	movs	r1, #1
3220a790:	9205      	str	r2, [sp, #20]
3220a792:	4620      	mov	r0, r4
3220a794:	1ad3      	subs	r3, r2, r3
3220a796:	9a09      	ldr	r2, [sp, #36]	@ 0x24
3220a798:	445d      	add	r5, fp
3220a79a:	441a      	add	r2, r3
3220a79c:	9209      	str	r2, [sp, #36]	@ 0x24
3220a79e:	f000 fa73 	bl	3220ac88 <__i2b>
3220a7a2:	9b07      	ldr	r3, [sp, #28]
3220a7a4:	9a05      	ldr	r2, [sp, #20]
3220a7a6:	4680      	mov	r8, r0
3220a7a8:	2b00      	cmp	r3, #0
3220a7aa:	f040 808a 	bne.w	3220a8c2 <_dtoa_r+0xcba>
3220a7ae:	461e      	mov	r6, r3
3220a7b0:	f8cd b01c 	str.w	fp, [sp, #28]
3220a7b4:	e7d6      	b.n	3220a764 <_dtoa_r+0xb5c>
3220a7b6:	9b02      	ldr	r3, [sp, #8]
3220a7b8:	2b00      	cmp	r3, #0
3220a7ba:	f47f ae04 	bne.w	3220a3c6 <_dtoa_r+0x7be>
3220a7be:	e9dd 1202 	ldrd	r1, r2, [sp, #8]
3220a7c2:	f3c2 0313 	ubfx	r3, r2, #0, #20
3220a7c6:	2b00      	cmp	r3, #0
3220a7c8:	f000 80be 	beq.w	3220a948 <_dtoa_r+0xd40>
3220a7cc:	9109      	str	r1, [sp, #36]	@ 0x24
3220a7ce:	e5fc      	b.n	3220a3ca <_dtoa_r+0x7c2>
3220a7d0:	9a04      	ldr	r2, [sp, #16]
3220a7d2:	f24c 0360 	movw	r3, #49248	@ 0xc060
3220a7d6:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220a7da:	f04f 3bff 	mov.w	fp, #4294967295	@ 0xffffffff
3220a7de:	eb03 03c2 	add.w	r3, r3, r2, lsl #3
3220a7e2:	edd3 1b00 	vldr	d17, [r3]
3220a7e6:	1c7b      	adds	r3, r7, #1
3220a7e8:	e673      	b.n	3220a4d2 <_dtoa_r+0x8ca>
3220a7ea:	2331      	movs	r3, #49	@ 0x31
3220a7ec:	3601      	adds	r6, #1
3220a7ee:	703b      	strb	r3, [r7, #0]
3220a7f0:	e522      	b.n	3220a238 <_dtoa_r+0x630>
3220a7f2:	d103      	bne.n	3220a7fc <_dtoa_r+0xbf4>
3220a7f4:	9b04      	ldr	r3, [sp, #16]
3220a7f6:	07db      	lsls	r3, r3, #31
3220a7f8:	f53f ad16 	bmi.w	3220a228 <_dtoa_r+0x620>
3220a7fc:	46ab      	mov	fp, r5
3220a7fe:	f815 3d01 	ldrb.w	r3, [r5, #-1]!
3220a802:	2b30      	cmp	r3, #48	@ 0x30
3220a804:	d0fa      	beq.n	3220a7fc <_dtoa_r+0xbf4>
3220a806:	e517      	b.n	3220a238 <_dtoa_r+0x630>
3220a808:	f10e 0e01 	add.w	lr, lr, #1
3220a80c:	2131      	movs	r1, #49	@ 0x31
3220a80e:	e4a3      	b.n	3220a158 <_dtoa_r+0x550>
3220a810:	9a08      	ldr	r2, [sp, #32]
3220a812:	e7a7      	b.n	3220a764 <_dtoa_r+0xb5c>
3220a814:	f10e 0601 	add.w	r6, lr, #1
3220a818:	469b      	mov	fp, r3
3220a81a:	e4a0      	b.n	3220a15e <_dtoa_r+0x556>
3220a81c:	460b      	mov	r3, r1
3220a81e:	e494      	b.n	3220a14a <_dtoa_r+0x542>
3220a820:	f8d8 1004 	ldr.w	r1, [r8, #4]
3220a824:	4620      	mov	r0, r4
3220a826:	f000 f8d9 	bl	3220a9dc <_Balloc>
3220a82a:	4605      	mov	r5, r0
3220a82c:	2800      	cmp	r0, #0
3220a82e:	f000 80bb 	beq.w	3220a9a8 <_dtoa_r+0xda0>
3220a832:	f8d8 3010 	ldr.w	r3, [r8, #16]
3220a836:	f108 010c 	add.w	r1, r8, #12
3220a83a:	300c      	adds	r0, #12
3220a83c:	3302      	adds	r3, #2
3220a83e:	009a      	lsls	r2, r3, #2
3220a840:	f7fa ecfe 	blx	32205240 <memcpy>
3220a844:	4629      	mov	r1, r5
3220a846:	2201      	movs	r2, #1
3220a848:	4620      	mov	r0, r4
3220a84a:	f000 fb7b 	bl	3220af44 <__lshift>
3220a84e:	4682      	mov	sl, r0
3220a850:	e692      	b.n	3220a578 <_dtoa_r+0x970>
3220a852:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
3220a854:	9804      	ldr	r0, [sp, #16]
3220a856:	43d9      	mvns	r1, r3
3220a858:	280e      	cmp	r0, #14
3220a85a:	ea4f 71d1 	mov.w	r1, r1, lsr #31
3220a85e:	bfc8      	it	gt
3220a860:	2100      	movgt	r1, #0
3220a862:	2900      	cmp	r1, #0
3220a864:	f43f adbf 	beq.w	3220a3e6 <_dtoa_r+0x7de>
3220a868:	9b04      	ldr	r3, [sp, #16]
3220a86a:	f1bb 0f00 	cmp.w	fp, #0
3220a86e:	eb02 02c3 	add.w	r2, r2, r3, lsl #3
3220a872:	bfc8      	it	gt
3220a874:	2300      	movgt	r3, #0
3220a876:	bfd8      	it	le
3220a878:	2301      	movle	r3, #1
3220a87a:	ea13 73da 	ands.w	r3, r3, sl, lsr #31
3220a87e:	edd2 1b00 	vldr	d17, [r2]
3220a882:	d0b0      	beq.n	3220a7e6 <_dtoa_r+0xbde>
3220a884:	f1bb 0f00 	cmp.w	fp, #0
3220a888:	f47f addf 	bne.w	3220a44a <_dtoa_r+0x842>
3220a88c:	eef1 0b04 	vmov.f64	d16, #20	@ 0x40a00000  5.0
3220a890:	4659      	mov	r1, fp
3220a892:	ee61 1ba0 	vmul.f64	d17, d17, d16
3220a896:	eeb4 8be1 	vcmpe.f64	d8, d17
3220a89a:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a89e:	d806      	bhi.n	3220a8ae <_dtoa_r+0xca6>
3220a8a0:	4620      	mov	r0, r4
3220a8a2:	f1ca 0600 	rsb	r6, sl, #0
3220a8a6:	46bb      	mov	fp, r7
3220a8a8:	f000 f8c2 	bl	3220aa30 <_Bfree>
3220a8ac:	e457      	b.n	3220a15e <_dtoa_r+0x556>
3220a8ae:	46bb      	mov	fp, r7
3220a8b0:	2331      	movs	r3, #49	@ 0x31
3220a8b2:	4620      	mov	r0, r4
3220a8b4:	f80b 3b01 	strb.w	r3, [fp], #1
3220a8b8:	f000 f8ba 	bl	3220aa30 <_Bfree>
3220a8bc:	9e04      	ldr	r6, [sp, #16]
3220a8be:	3602      	adds	r6, #2
3220a8c0:	e44d      	b.n	3220a15e <_dtoa_r+0x556>
3220a8c2:	9807      	ldr	r0, [sp, #28]
3220a8c4:	42a8      	cmp	r0, r5
3220a8c6:	4603      	mov	r3, r0
3220a8c8:	eb00 010b 	add.w	r1, r0, fp
3220a8cc:	bfa8      	it	ge
3220a8ce:	462b      	movge	r3, r5
3220a8d0:	1aed      	subs	r5, r5, r3
3220a8d2:	1ac6      	subs	r6, r0, r3
3220a8d4:	1acb      	subs	r3, r1, r3
3220a8d6:	9307      	str	r3, [sp, #28]
3220a8d8:	e744      	b.n	3220a764 <_dtoa_r+0xb5c>
3220a8da:	ee38 8b08 	vadd.f64	d8, d8, d8
3220a8de:	9a04      	ldr	r2, [sp, #16]
3220a8e0:	1c56      	adds	r6, r2, #1
3220a8e2:	eeb4 8be1 	vcmpe.f64	d8, d17
3220a8e6:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a8ea:	dc08      	bgt.n	3220a8fe <_dtoa_r+0xcf6>
3220a8ec:	eeb4 8b61 	vcmp.f64	d8, d17
3220a8f0:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3220a8f4:	d106      	bne.n	3220a904 <_dtoa_r+0xcfc>
3220a8f6:	ee17 2a90 	vmov	r2, s15
3220a8fa:	07d1      	lsls	r1, r2, #31
3220a8fc:	d502      	bpl.n	3220a904 <_dtoa_r+0xcfc>
3220a8fe:	f8dd e010 	ldr.w	lr, [sp, #16]
3220a902:	e422      	b.n	3220a14a <_dtoa_r+0x542>
3220a904:	469b      	mov	fp, r3
3220a906:	e42a      	b.n	3220a15e <_dtoa_r+0x556>
3220a908:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220a90c:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220a910:	f64b 3098 	movw	r0, #48024	@ 0xbb98
3220a914:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220a918:	2200      	movs	r2, #0
3220a91a:	f240 11af 	movw	r1, #431	@ 0x1af
3220a91e:	f7f7 fc45 	bl	322021ac <__assert_func>
3220a922:	9e04      	ldr	r6, [sp, #16]
3220a924:	463b      	mov	r3, r7
3220a926:	f8cd 8004 	str.w	r8, [sp, #4]
3220a92a:	46d0      	mov	r8, sl
3220a92c:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3220a92e:	3601      	adds	r6, #1
3220a930:	e46a      	b.n	3220a208 <_dtoa_r+0x600>
3220a932:	f24c 0260 	movw	r2, #49248	@ 0xc060
3220a936:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220a93a:	e795      	b.n	3220a868 <_dtoa_r+0xc60>
3220a93c:	463b      	mov	r3, r7
3220a93e:	2a00      	cmp	r2, #0
3220a940:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3220a942:	f73f ae79 	bgt.w	3220a638 <_dtoa_r+0xa30>
3220a946:	e689      	b.n	3220a65c <_dtoa_r+0xa54>
3220a948:	9b03      	ldr	r3, [sp, #12]
3220a94a:	f023 4300 	bic.w	r3, r3, #2147483648	@ 0x80000000
3220a94e:	0d1b      	lsrs	r3, r3, #20
3220a950:	051b      	lsls	r3, r3, #20
3220a952:	2b00      	cmp	r3, #0
3220a954:	f43f ad38 	beq.w	3220a3c8 <_dtoa_r+0x7c0>
3220a958:	9b07      	ldr	r3, [sp, #28]
3220a95a:	3501      	adds	r5, #1
3220a95c:	3301      	adds	r3, #1
3220a95e:	9307      	str	r3, [sp, #28]
3220a960:	2301      	movs	r3, #1
3220a962:	9309      	str	r3, [sp, #36]	@ 0x24
3220a964:	e531      	b.n	3220a3ca <_dtoa_r+0x7c2>
3220a966:	463b      	mov	r3, r7
3220a968:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3220a96a:	e677      	b.n	3220a65c <_dtoa_r+0xa54>
3220a96c:	463b      	mov	r3, r7
3220a96e:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3220a970:	2b39      	cmp	r3, #57	@ 0x39
3220a972:	f43f ae95 	beq.w	3220a6a0 <_dtoa_r+0xa98>
3220a976:	2d00      	cmp	r5, #0
3220a978:	f73f ae6e 	bgt.w	3220a658 <_dtoa_r+0xa50>
3220a97c:	e66e      	b.n	3220a65c <_dtoa_r+0xa54>
3220a97e:	4619      	mov	r1, r3
3220a980:	e586      	b.n	3220a490 <_dtoa_r+0x888>
3220a982:	f8cd b010 	str.w	fp, [sp, #16]
3220a986:	f8dd b02c 	ldr.w	fp, [sp, #44]	@ 0x2c
3220a98a:	f7ff baac 	b.w	32209ee6 <_dtoa_r+0x2de>
3220a98e:	2102      	movs	r1, #2
3220a990:	f7ff bb6c 	b.w	3220a06c <_dtoa_r+0x464>
3220a994:	f47f ae62 	bne.w	3220a65c <_dtoa_r+0xa54>
3220a998:	07da      	lsls	r2, r3, #31
3220a99a:	f57f ae5f 	bpl.w	3220a65c <_dtoa_r+0xa54>
3220a99e:	e659      	b.n	3220a654 <_dtoa_r+0xa4c>
3220a9a0:	2100      	movs	r1, #0
3220a9a2:	63e1      	str	r1, [r4, #60]	@ 0x3c
3220a9a4:	f7ff bb22 	b.w	32209fec <_dtoa_r+0x3e4>
3220a9a8:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220a9ac:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220a9b0:	f64b 3098 	movw	r0, #48024	@ 0xbb98
3220a9b4:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220a9b8:	462a      	mov	r2, r5
3220a9ba:	f240 21ef 	movw	r1, #751	@ 0x2ef
3220a9be:	f7f7 fbf5 	bl	322021ac <__assert_func>
3220a9c2:	bf00      	nop

3220a9c4 <__env_lock>:
3220a9c4:	f245 3054 	movw	r0, #21332	@ 0x5354
3220a9c8:	f2c3 2021 	movt	r0, #12833	@ 0x3221
3220a9cc:	f7fa b9c4 	b.w	32204d58 <__retarget_lock_acquire_recursive>

3220a9d0 <__env_unlock>:
3220a9d0:	f245 3054 	movw	r0, #21332	@ 0x5354
3220a9d4:	f2c3 2021 	movt	r0, #12833	@ 0x3221
3220a9d8:	f7fa b9c6 	b.w	32204d68 <__retarget_lock_release_recursive>

3220a9dc <_Balloc>:
3220a9dc:	b538      	push	{r3, r4, r5, lr}
3220a9de:	4605      	mov	r5, r0
3220a9e0:	6c43      	ldr	r3, [r0, #68]	@ 0x44
3220a9e2:	460c      	mov	r4, r1
3220a9e4:	b163      	cbz	r3, 3220aa00 <_Balloc+0x24>
3220a9e6:	f853 0024 	ldr.w	r0, [r3, r4, lsl #2]
3220a9ea:	b198      	cbz	r0, 3220aa14 <_Balloc+0x38>
3220a9ec:	6802      	ldr	r2, [r0, #0]
3220a9ee:	f843 2024 	str.w	r2, [r3, r4, lsl #2]
3220a9f2:	efc0 0010 	vmov.i32	d16, #0	@ 0x00000000
3220a9f6:	f100 030c 	add.w	r3, r0, #12
3220a9fa:	f943 078f 	vst1.32	{d16}, [r3]
3220a9fe:	bd38      	pop	{r3, r4, r5, pc}
3220aa00:	2221      	movs	r2, #33	@ 0x21
3220aa02:	2104      	movs	r1, #4
3220aa04:	f000 fe1e 	bl	3220b644 <_calloc_r>
3220aa08:	4603      	mov	r3, r0
3220aa0a:	6468      	str	r0, [r5, #68]	@ 0x44
3220aa0c:	2800      	cmp	r0, #0
3220aa0e:	d1ea      	bne.n	3220a9e6 <_Balloc+0xa>
3220aa10:	2000      	movs	r0, #0
3220aa12:	bd38      	pop	{r3, r4, r5, pc}
3220aa14:	2101      	movs	r1, #1
3220aa16:	4628      	mov	r0, r5
3220aa18:	fa01 f504 	lsl.w	r5, r1, r4
3220aa1c:	1d6a      	adds	r2, r5, #5
3220aa1e:	0092      	lsls	r2, r2, #2
3220aa20:	f000 fe10 	bl	3220b644 <_calloc_r>
3220aa24:	2800      	cmp	r0, #0
3220aa26:	d0f3      	beq.n	3220aa10 <_Balloc+0x34>
3220aa28:	e9c0 4501 	strd	r4, r5, [r0, #4]
3220aa2c:	e7e1      	b.n	3220a9f2 <_Balloc+0x16>
3220aa2e:	bf00      	nop

3220aa30 <_Bfree>:
3220aa30:	b131      	cbz	r1, 3220aa40 <_Bfree+0x10>
3220aa32:	6c43      	ldr	r3, [r0, #68]	@ 0x44
3220aa34:	684a      	ldr	r2, [r1, #4]
3220aa36:	f853 0022 	ldr.w	r0, [r3, r2, lsl #2]
3220aa3a:	6008      	str	r0, [r1, #0]
3220aa3c:	f843 1022 	str.w	r1, [r3, r2, lsl #2]
3220aa40:	4770      	bx	lr
3220aa42:	bf00      	nop

3220aa44 <__multadd>:
3220aa44:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
3220aa48:	4607      	mov	r7, r0
3220aa4a:	690d      	ldr	r5, [r1, #16]
3220aa4c:	460e      	mov	r6, r1
3220aa4e:	461c      	mov	r4, r3
3220aa50:	f101 0e14 	add.w	lr, r1, #20
3220aa54:	2000      	movs	r0, #0
3220aa56:	f8de 1000 	ldr.w	r1, [lr]
3220aa5a:	3001      	adds	r0, #1
3220aa5c:	4285      	cmp	r5, r0
3220aa5e:	b28b      	uxth	r3, r1
3220aa60:	ea4f 4111 	mov.w	r1, r1, lsr #16
3220aa64:	fb02 4303 	mla	r3, r2, r3, r4
3220aa68:	ea4f 4c13 	mov.w	ip, r3, lsr #16
3220aa6c:	b29b      	uxth	r3, r3
3220aa6e:	fb02 cc01 	mla	ip, r2, r1, ip
3220aa72:	eb03 430c 	add.w	r3, r3, ip, lsl #16
3220aa76:	ea4f 441c 	mov.w	r4, ip, lsr #16
3220aa7a:	f84e 3b04 	str.w	r3, [lr], #4
3220aa7e:	dcea      	bgt.n	3220aa56 <__multadd+0x12>
3220aa80:	b13c      	cbz	r4, 3220aa92 <__multadd+0x4e>
3220aa82:	68b3      	ldr	r3, [r6, #8]
3220aa84:	42ab      	cmp	r3, r5
3220aa86:	dd07      	ble.n	3220aa98 <__multadd+0x54>
3220aa88:	eb06 0385 	add.w	r3, r6, r5, lsl #2
3220aa8c:	3501      	adds	r5, #1
3220aa8e:	615c      	str	r4, [r3, #20]
3220aa90:	6135      	str	r5, [r6, #16]
3220aa92:	4630      	mov	r0, r6
3220aa94:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
3220aa98:	6871      	ldr	r1, [r6, #4]
3220aa9a:	4638      	mov	r0, r7
3220aa9c:	3101      	adds	r1, #1
3220aa9e:	f7ff ff9d 	bl	3220a9dc <_Balloc>
3220aaa2:	4680      	mov	r8, r0
3220aaa4:	b1a8      	cbz	r0, 3220aad2 <__multadd+0x8e>
3220aaa6:	6932      	ldr	r2, [r6, #16]
3220aaa8:	f106 010c 	add.w	r1, r6, #12
3220aaac:	300c      	adds	r0, #12
3220aaae:	3202      	adds	r2, #2
3220aab0:	0092      	lsls	r2, r2, #2
3220aab2:	f7fa ebc6 	blx	32205240 <memcpy>
3220aab6:	6c7b      	ldr	r3, [r7, #68]	@ 0x44
3220aab8:	6872      	ldr	r2, [r6, #4]
3220aaba:	f853 1022 	ldr.w	r1, [r3, r2, lsl #2]
3220aabe:	6031      	str	r1, [r6, #0]
3220aac0:	f843 6022 	str.w	r6, [r3, r2, lsl #2]
3220aac4:	4646      	mov	r6, r8
3220aac6:	eb06 0385 	add.w	r3, r6, r5, lsl #2
3220aaca:	3501      	adds	r5, #1
3220aacc:	615c      	str	r4, [r3, #20]
3220aace:	6135      	str	r5, [r6, #16]
3220aad0:	e7df      	b.n	3220aa92 <__multadd+0x4e>
3220aad2:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220aad6:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220aada:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220aade:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220aae2:	4642      	mov	r2, r8
3220aae4:	21ba      	movs	r1, #186	@ 0xba
3220aae6:	f7f7 fb61 	bl	322021ac <__assert_func>
3220aaea:	bf00      	nop

3220aaec <__s2b>:
3220aaec:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
3220aaf0:	461e      	mov	r6, r3
3220aaf2:	4617      	mov	r7, r2
3220aaf4:	3308      	adds	r3, #8
3220aaf6:	f648 6239 	movw	r2, #36409	@ 0x8e39
3220aafa:	f6c3 02e3 	movt	r2, #14563	@ 0x38e3
3220aafe:	460c      	mov	r4, r1
3220ab00:	4605      	mov	r5, r0
3220ab02:	2e09      	cmp	r6, #9
3220ab04:	fb82 1203 	smull	r1, r2, r2, r3
3220ab08:	ea4f 73e3 	mov.w	r3, r3, asr #31
3220ab0c:	ebc3 0362 	rsb	r3, r3, r2, asr #1
3220ab10:	dd3b      	ble.n	3220ab8a <__s2b+0x9e>
3220ab12:	f04f 0c01 	mov.w	ip, #1
3220ab16:	2100      	movs	r1, #0
3220ab18:	ea4f 0c4c 	mov.w	ip, ip, lsl #1
3220ab1c:	3101      	adds	r1, #1
3220ab1e:	4563      	cmp	r3, ip
3220ab20:	dcfa      	bgt.n	3220ab18 <__s2b+0x2c>
3220ab22:	4628      	mov	r0, r5
3220ab24:	f7ff ff5a 	bl	3220a9dc <_Balloc>
3220ab28:	4601      	mov	r1, r0
3220ab2a:	b380      	cbz	r0, 3220ab8e <__s2b+0xa2>
3220ab2c:	9b08      	ldr	r3, [sp, #32]
3220ab2e:	2f09      	cmp	r7, #9
3220ab30:	6143      	str	r3, [r0, #20]
3220ab32:	bfd8      	it	le
3220ab34:	340a      	addle	r4, #10
3220ab36:	f04f 0301 	mov.w	r3, #1
3220ab3a:	bfd8      	it	le
3220ab3c:	2709      	movle	r7, #9
3220ab3e:	6103      	str	r3, [r0, #16]
3220ab40:	dc10      	bgt.n	3220ab64 <__s2b+0x78>
3220ab42:	42be      	cmp	r6, r7
3220ab44:	dd0b      	ble.n	3220ab5e <__s2b+0x72>
3220ab46:	1bf6      	subs	r6, r6, r7
3220ab48:	4426      	add	r6, r4
3220ab4a:	f814 3b01 	ldrb.w	r3, [r4], #1
3220ab4e:	220a      	movs	r2, #10
3220ab50:	4628      	mov	r0, r5
3220ab52:	3b30      	subs	r3, #48	@ 0x30
3220ab54:	f7ff ff76 	bl	3220aa44 <__multadd>
3220ab58:	42b4      	cmp	r4, r6
3220ab5a:	4601      	mov	r1, r0
3220ab5c:	d1f5      	bne.n	3220ab4a <__s2b+0x5e>
3220ab5e:	4608      	mov	r0, r1
3220ab60:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
3220ab64:	f104 0809 	add.w	r8, r4, #9
3220ab68:	eb04 0907 	add.w	r9, r4, r7
3220ab6c:	4644      	mov	r4, r8
3220ab6e:	f814 3b01 	ldrb.w	r3, [r4], #1
3220ab72:	220a      	movs	r2, #10
3220ab74:	4628      	mov	r0, r5
3220ab76:	3b30      	subs	r3, #48	@ 0x30
3220ab78:	f7ff ff64 	bl	3220aa44 <__multadd>
3220ab7c:	454c      	cmp	r4, r9
3220ab7e:	4601      	mov	r1, r0
3220ab80:	d1f5      	bne.n	3220ab6e <__s2b+0x82>
3220ab82:	44b8      	add	r8, r7
3220ab84:	f1a8 0408 	sub.w	r4, r8, #8
3220ab88:	e7db      	b.n	3220ab42 <__s2b+0x56>
3220ab8a:	2100      	movs	r1, #0
3220ab8c:	e7c9      	b.n	3220ab22 <__s2b+0x36>
3220ab8e:	460a      	mov	r2, r1
3220ab90:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220ab94:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220ab98:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220ab9c:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220aba0:	21d3      	movs	r1, #211	@ 0xd3
3220aba2:	f7f7 fb03 	bl	322021ac <__assert_func>
3220aba6:	bf00      	nop

3220aba8 <__hi0bits>:
3220aba8:	f5b0 3f80 	cmp.w	r0, #65536	@ 0x10000
3220abac:	4603      	mov	r3, r0
3220abae:	bf38      	it	cc
3220abb0:	0403      	lslcc	r3, r0, #16
3220abb2:	bf28      	it	cs
3220abb4:	2000      	movcs	r0, #0
3220abb6:	bf38      	it	cc
3220abb8:	2010      	movcc	r0, #16
3220abba:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
3220abbe:	d201      	bcs.n	3220abc4 <__hi0bits+0x1c>
3220abc0:	3008      	adds	r0, #8
3220abc2:	021b      	lsls	r3, r3, #8
3220abc4:	f1b3 5f80 	cmp.w	r3, #268435456	@ 0x10000000
3220abc8:	d306      	bcc.n	3220abd8 <__hi0bits+0x30>
3220abca:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
3220abce:	d20f      	bcs.n	3220abf0 <__hi0bits+0x48>
3220abd0:	009a      	lsls	r2, r3, #2
3220abd2:	d412      	bmi.n	3220abfa <__hi0bits+0x52>
3220abd4:	3003      	adds	r0, #3
3220abd6:	4770      	bx	lr
3220abd8:	011a      	lsls	r2, r3, #4
3220abda:	3004      	adds	r0, #4
3220abdc:	f1b2 4f80 	cmp.w	r2, #1073741824	@ 0x40000000
3220abe0:	d207      	bcs.n	3220abf2 <__hi0bits+0x4a>
3220abe2:	019b      	lsls	r3, r3, #6
3220abe4:	d409      	bmi.n	3220abfa <__hi0bits+0x52>
3220abe6:	005b      	lsls	r3, r3, #1
3220abe8:	bf58      	it	pl
3220abea:	2020      	movpl	r0, #32
3220abec:	d4f2      	bmi.n	3220abd4 <__hi0bits+0x2c>
3220abee:	4770      	bx	lr
3220abf0:	461a      	mov	r2, r3
3220abf2:	2a00      	cmp	r2, #0
3220abf4:	dbfb      	blt.n	3220abee <__hi0bits+0x46>
3220abf6:	3001      	adds	r0, #1
3220abf8:	4770      	bx	lr
3220abfa:	3002      	adds	r0, #2
3220abfc:	4770      	bx	lr
3220abfe:	bf00      	nop

3220ac00 <__lo0bits>:
3220ac00:	6803      	ldr	r3, [r0, #0]
3220ac02:	4602      	mov	r2, r0
3220ac04:	0759      	lsls	r1, r3, #29
3220ac06:	d007      	beq.n	3220ac18 <__lo0bits+0x18>
3220ac08:	07d8      	lsls	r0, r3, #31
3220ac0a:	d42e      	bmi.n	3220ac6a <__lo0bits+0x6a>
3220ac0c:	0799      	lsls	r1, r3, #30
3220ac0e:	d532      	bpl.n	3220ac76 <__lo0bits+0x76>
3220ac10:	085b      	lsrs	r3, r3, #1
3220ac12:	2001      	movs	r0, #1
3220ac14:	6013      	str	r3, [r2, #0]
3220ac16:	4770      	bx	lr
3220ac18:	b299      	uxth	r1, r3
3220ac1a:	b989      	cbnz	r1, 3220ac40 <__lo0bits+0x40>
3220ac1c:	0c1b      	lsrs	r3, r3, #16
3220ac1e:	2018      	movs	r0, #24
3220ac20:	b2d9      	uxtb	r1, r3
3220ac22:	bb21      	cbnz	r1, 3220ac6e <__lo0bits+0x6e>
3220ac24:	0a1b      	lsrs	r3, r3, #8
3220ac26:	0719      	lsls	r1, r3, #28
3220ac28:	bf08      	it	eq
3220ac2a:	3004      	addeq	r0, #4
3220ac2c:	d00d      	beq.n	3220ac4a <__lo0bits+0x4a>
3220ac2e:	0799      	lsls	r1, r3, #30
3220ac30:	d00e      	beq.n	3220ac50 <__lo0bits+0x50>
3220ac32:	07d9      	lsls	r1, r3, #31
3220ac34:	bf58      	it	pl
3220ac36:	3001      	addpl	r0, #1
3220ac38:	bf58      	it	pl
3220ac3a:	085b      	lsrpl	r3, r3, #1
3220ac3c:	6013      	str	r3, [r2, #0]
3220ac3e:	4770      	bx	lr
3220ac40:	b2d9      	uxtb	r1, r3
3220ac42:	b1b1      	cbz	r1, 3220ac72 <__lo0bits+0x72>
3220ac44:	0718      	lsls	r0, r3, #28
3220ac46:	d11a      	bne.n	3220ac7e <__lo0bits+0x7e>
3220ac48:	2004      	movs	r0, #4
3220ac4a:	091b      	lsrs	r3, r3, #4
3220ac4c:	0799      	lsls	r1, r3, #30
3220ac4e:	d1f0      	bne.n	3220ac32 <__lo0bits+0x32>
3220ac50:	f013 0f04 	tst.w	r3, #4
3220ac54:	ea4f 0193 	mov.w	r1, r3, lsr #2
3220ac58:	bf18      	it	ne
3220ac5a:	3002      	addne	r0, #2
3220ac5c:	bf18      	it	ne
3220ac5e:	460b      	movne	r3, r1
3220ac60:	d1ec      	bne.n	3220ac3c <__lo0bits+0x3c>
3220ac62:	08db      	lsrs	r3, r3, #3
3220ac64:	d10e      	bne.n	3220ac84 <__lo0bits+0x84>
3220ac66:	2020      	movs	r0, #32
3220ac68:	4770      	bx	lr
3220ac6a:	2000      	movs	r0, #0
3220ac6c:	4770      	bx	lr
3220ac6e:	2010      	movs	r0, #16
3220ac70:	e7d9      	b.n	3220ac26 <__lo0bits+0x26>
3220ac72:	2008      	movs	r0, #8
3220ac74:	e7d6      	b.n	3220ac24 <__lo0bits+0x24>
3220ac76:	089b      	lsrs	r3, r3, #2
3220ac78:	2002      	movs	r0, #2
3220ac7a:	6013      	str	r3, [r2, #0]
3220ac7c:	4770      	bx	lr
3220ac7e:	08db      	lsrs	r3, r3, #3
3220ac80:	2003      	movs	r0, #3
3220ac82:	e7db      	b.n	3220ac3c <__lo0bits+0x3c>
3220ac84:	3003      	adds	r0, #3
3220ac86:	e7d9      	b.n	3220ac3c <__lo0bits+0x3c>

3220ac88 <__i2b>:
3220ac88:	b538      	push	{r3, r4, r5, lr}
3220ac8a:	4604      	mov	r4, r0
3220ac8c:	6c43      	ldr	r3, [r0, #68]	@ 0x44
3220ac8e:	460d      	mov	r5, r1
3220ac90:	b15b      	cbz	r3, 3220acaa <__i2b+0x22>
3220ac92:	6858      	ldr	r0, [r3, #4]
3220ac94:	b1f0      	cbz	r0, 3220acd4 <__i2b+0x4c>
3220ac96:	6802      	ldr	r2, [r0, #0]
3220ac98:	605a      	str	r2, [r3, #4]
3220ac9a:	eddf 0b15 	vldr	d16, [pc, #84]	@ 3220acf0 <__i2b+0x68>
3220ac9e:	f100 030c 	add.w	r3, r0, #12
3220aca2:	6145      	str	r5, [r0, #20]
3220aca4:	f943 078f 	vst1.32	{d16}, [r3]
3220aca8:	bd38      	pop	{r3, r4, r5, pc}
3220acaa:	2221      	movs	r2, #33	@ 0x21
3220acac:	2104      	movs	r1, #4
3220acae:	f000 fcc9 	bl	3220b644 <_calloc_r>
3220acb2:	4603      	mov	r3, r0
3220acb4:	6460      	str	r0, [r4, #68]	@ 0x44
3220acb6:	2800      	cmp	r0, #0
3220acb8:	d1eb      	bne.n	3220ac92 <__i2b+0xa>
3220acba:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220acbe:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220acc2:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220acc6:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220acca:	2200      	movs	r2, #0
3220accc:	f240 1145 	movw	r1, #325	@ 0x145
3220acd0:	f7f7 fa6c 	bl	322021ac <__assert_func>
3220acd4:	221c      	movs	r2, #28
3220acd6:	2101      	movs	r1, #1
3220acd8:	4620      	mov	r0, r4
3220acda:	f000 fcb3 	bl	3220b644 <_calloc_r>
3220acde:	2800      	cmp	r0, #0
3220ace0:	d0eb      	beq.n	3220acba <__i2b+0x32>
3220ace2:	eddf 0b05 	vldr	d16, [pc, #20]	@ 3220acf8 <__i2b+0x70>
3220ace6:	1d03      	adds	r3, r0, #4
3220ace8:	f943 078f 	vst1.32	{d16}, [r3]
3220acec:	e7d5      	b.n	3220ac9a <__i2b+0x12>
3220acee:	bf00      	nop
3220acf0:	00000000 	.word	0x00000000
3220acf4:	00000001 	.word	0x00000001
3220acf8:	00000001 	.word	0x00000001
3220acfc:	00000002 	.word	0x00000002

3220ad00 <__multiply>:
3220ad00:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
3220ad04:	4692      	mov	sl, r2
3220ad06:	690a      	ldr	r2, [r1, #16]
3220ad08:	460e      	mov	r6, r1
3220ad0a:	4651      	mov	r1, sl
3220ad0c:	f8da 3010 	ldr.w	r3, [sl, #16]
3220ad10:	b085      	sub	sp, #20
3220ad12:	429a      	cmp	r2, r3
3220ad14:	bfa8      	it	ge
3220ad16:	46b2      	movge	sl, r6
3220ad18:	bfb8      	it	lt
3220ad1a:	461d      	movlt	r5, r3
3220ad1c:	bfa8      	it	ge
3220ad1e:	4698      	movge	r8, r3
3220ad20:	bfa8      	it	ge
3220ad22:	460e      	movge	r6, r1
3220ad24:	bfa8      	it	ge
3220ad26:	4615      	movge	r5, r2
3220ad28:	bfb8      	it	lt
3220ad2a:	4690      	movlt	r8, r2
3220ad2c:	e9da 1301 	ldrd	r1, r3, [sl, #4]
3220ad30:	eb05 0408 	add.w	r4, r5, r8
3220ad34:	42a3      	cmp	r3, r4
3220ad36:	bfb8      	it	lt
3220ad38:	3101      	addlt	r1, #1
3220ad3a:	f7ff fe4f 	bl	3220a9dc <_Balloc>
3220ad3e:	4684      	mov	ip, r0
3220ad40:	2800      	cmp	r0, #0
3220ad42:	f000 808e 	beq.w	3220ae62 <__multiply+0x162>
3220ad46:	f100 0714 	add.w	r7, r0, #20
3220ad4a:	eb07 0e84 	add.w	lr, r7, r4, lsl #2
3220ad4e:	4577      	cmp	r7, lr
3220ad50:	bf38      	it	cc
3220ad52:	463b      	movcc	r3, r7
3220ad54:	bf38      	it	cc
3220ad56:	2200      	movcc	r2, #0
3220ad58:	d203      	bcs.n	3220ad62 <__multiply+0x62>
3220ad5a:	f843 2b04 	str.w	r2, [r3], #4
3220ad5e:	459e      	cmp	lr, r3
3220ad60:	d8fb      	bhi.n	3220ad5a <__multiply+0x5a>
3220ad62:	3614      	adds	r6, #20
3220ad64:	f10a 0914 	add.w	r9, sl, #20
3220ad68:	eb06 0888 	add.w	r8, r6, r8, lsl #2
3220ad6c:	eb09 0585 	add.w	r5, r9, r5, lsl #2
3220ad70:	4546      	cmp	r6, r8
3220ad72:	d267      	bcs.n	3220ae44 <__multiply+0x144>
3220ad74:	eba5 030a 	sub.w	r3, r5, sl
3220ad78:	f10a 0a15 	add.w	sl, sl, #21
3220ad7c:	3b15      	subs	r3, #21
3220ad7e:	f8cd e008 	str.w	lr, [sp, #8]
3220ad82:	f023 0303 	bic.w	r3, r3, #3
3220ad86:	46ae      	mov	lr, r5
3220ad88:	45aa      	cmp	sl, r5
3220ad8a:	bf88      	it	hi
3220ad8c:	2300      	movhi	r3, #0
3220ad8e:	9403      	str	r4, [sp, #12]
3220ad90:	469b      	mov	fp, r3
3220ad92:	46e2      	mov	sl, ip
3220ad94:	e004      	b.n	3220ada0 <__multiply+0xa0>
3220ad96:	0c09      	lsrs	r1, r1, #16
3220ad98:	d12c      	bne.n	3220adf4 <__multiply+0xf4>
3220ad9a:	3704      	adds	r7, #4
3220ad9c:	45b0      	cmp	r8, r6
3220ad9e:	d94e      	bls.n	3220ae3e <__multiply+0x13e>
3220ada0:	f856 1b04 	ldr.w	r1, [r6], #4
3220ada4:	b28d      	uxth	r5, r1
3220ada6:	2d00      	cmp	r5, #0
3220ada8:	d0f5      	beq.n	3220ad96 <__multiply+0x96>
3220adaa:	46cc      	mov	ip, r9
3220adac:	463c      	mov	r4, r7
3220adae:	2300      	movs	r3, #0
3220adb0:	9601      	str	r6, [sp, #4]
3220adb2:	f85c 0b04 	ldr.w	r0, [ip], #4
3220adb6:	6821      	ldr	r1, [r4, #0]
3220adb8:	45e6      	cmp	lr, ip
3220adba:	b286      	uxth	r6, r0
3220adbc:	ea4f 4010 	mov.w	r0, r0, lsr #16
3220adc0:	b28a      	uxth	r2, r1
3220adc2:	ea4f 4111 	mov.w	r1, r1, lsr #16
3220adc6:	fb05 2206 	mla	r2, r5, r6, r2
3220adca:	fb05 1100 	mla	r1, r5, r0, r1
3220adce:	441a      	add	r2, r3
3220add0:	eb01 4112 	add.w	r1, r1, r2, lsr #16
3220add4:	b292      	uxth	r2, r2
3220add6:	ea42 4201 	orr.w	r2, r2, r1, lsl #16
3220adda:	ea4f 4311 	mov.w	r3, r1, lsr #16
3220adde:	f844 2b04 	str.w	r2, [r4], #4
3220ade2:	d8e6      	bhi.n	3220adb2 <__multiply+0xb2>
3220ade4:	eb07 020b 	add.w	r2, r7, fp
3220ade8:	9e01      	ldr	r6, [sp, #4]
3220adea:	6053      	str	r3, [r2, #4]
3220adec:	f856 1c04 	ldr.w	r1, [r6, #-4]
3220adf0:	0c09      	lsrs	r1, r1, #16
3220adf2:	d0d2      	beq.n	3220ad9a <__multiply+0x9a>
3220adf4:	683b      	ldr	r3, [r7, #0]
3220adf6:	2200      	movs	r2, #0
3220adf8:	4648      	mov	r0, r9
3220adfa:	463d      	mov	r5, r7
3220adfc:	461c      	mov	r4, r3
3220adfe:	4694      	mov	ip, r2
3220ae00:	8802      	ldrh	r2, [r0, #0]
3220ae02:	b29b      	uxth	r3, r3
3220ae04:	fb01 c202 	mla	r2, r1, r2, ip
3220ae08:	eb02 4214 	add.w	r2, r2, r4, lsr #16
3220ae0c:	ea43 4302 	orr.w	r3, r3, r2, lsl #16
3220ae10:	f845 3b04 	str.w	r3, [r5], #4
3220ae14:	f850 3b04 	ldr.w	r3, [r0], #4
3220ae18:	682c      	ldr	r4, [r5, #0]
3220ae1a:	4586      	cmp	lr, r0
3220ae1c:	ea4f 4c13 	mov.w	ip, r3, lsr #16
3220ae20:	b2a3      	uxth	r3, r4
3220ae22:	fb01 330c 	mla	r3, r1, ip, r3
3220ae26:	eb03 4312 	add.w	r3, r3, r2, lsr #16
3220ae2a:	ea4f 4c13 	mov.w	ip, r3, lsr #16
3220ae2e:	d8e7      	bhi.n	3220ae00 <__multiply+0x100>
3220ae30:	eb07 020b 	add.w	r2, r7, fp
3220ae34:	45b0      	cmp	r8, r6
3220ae36:	f107 0704 	add.w	r7, r7, #4
3220ae3a:	6053      	str	r3, [r2, #4]
3220ae3c:	d8b0      	bhi.n	3220ada0 <__multiply+0xa0>
3220ae3e:	e9dd e402 	ldrd	lr, r4, [sp, #8]
3220ae42:	46d4      	mov	ip, sl
3220ae44:	2c00      	cmp	r4, #0
3220ae46:	dc02      	bgt.n	3220ae4e <__multiply+0x14e>
3220ae48:	e005      	b.n	3220ae56 <__multiply+0x156>
3220ae4a:	3c01      	subs	r4, #1
3220ae4c:	d003      	beq.n	3220ae56 <__multiply+0x156>
3220ae4e:	f85e 3d04 	ldr.w	r3, [lr, #-4]!
3220ae52:	2b00      	cmp	r3, #0
3220ae54:	d0f9      	beq.n	3220ae4a <__multiply+0x14a>
3220ae56:	4660      	mov	r0, ip
3220ae58:	f8cc 4010 	str.w	r4, [ip, #16]
3220ae5c:	b005      	add	sp, #20
3220ae5e:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220ae62:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220ae66:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220ae6a:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220ae6e:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220ae72:	4662      	mov	r2, ip
3220ae74:	f44f 71b1 	mov.w	r1, #354	@ 0x162
3220ae78:	f7f7 f998 	bl	322021ac <__assert_func>

3220ae7c <__pow5mult>:
3220ae7c:	f012 0303 	ands.w	r3, r2, #3
3220ae80:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
3220ae84:	4614      	mov	r4, r2
3220ae86:	4607      	mov	r7, r0
3220ae88:	bf08      	it	eq
3220ae8a:	460e      	moveq	r6, r1
3220ae8c:	d131      	bne.n	3220aef2 <__pow5mult+0x76>
3220ae8e:	10a4      	asrs	r4, r4, #2
3220ae90:	d02c      	beq.n	3220aeec <__pow5mult+0x70>
3220ae92:	6c3d      	ldr	r5, [r7, #64]	@ 0x40
3220ae94:	2d00      	cmp	r5, #0
3220ae96:	d038      	beq.n	3220af0a <__pow5mult+0x8e>
3220ae98:	f004 0301 	and.w	r3, r4, #1
3220ae9c:	f04f 0800 	mov.w	r8, #0
3220aea0:	1064      	asrs	r4, r4, #1
3220aea2:	b93b      	cbnz	r3, 3220aeb4 <__pow5mult+0x38>
3220aea4:	6828      	ldr	r0, [r5, #0]
3220aea6:	b1b8      	cbz	r0, 3220aed8 <__pow5mult+0x5c>
3220aea8:	4605      	mov	r5, r0
3220aeaa:	f004 0301 	and.w	r3, r4, #1
3220aeae:	1064      	asrs	r4, r4, #1
3220aeb0:	2b00      	cmp	r3, #0
3220aeb2:	d0f7      	beq.n	3220aea4 <__pow5mult+0x28>
3220aeb4:	462a      	mov	r2, r5
3220aeb6:	4631      	mov	r1, r6
3220aeb8:	4638      	mov	r0, r7
3220aeba:	f7ff ff21 	bl	3220ad00 <__multiply>
3220aebe:	b136      	cbz	r6, 3220aece <__pow5mult+0x52>
3220aec0:	6c7b      	ldr	r3, [r7, #68]	@ 0x44
3220aec2:	6871      	ldr	r1, [r6, #4]
3220aec4:	f853 2021 	ldr.w	r2, [r3, r1, lsl #2]
3220aec8:	6032      	str	r2, [r6, #0]
3220aeca:	f843 6021 	str.w	r6, [r3, r1, lsl #2]
3220aece:	b174      	cbz	r4, 3220aeee <__pow5mult+0x72>
3220aed0:	4606      	mov	r6, r0
3220aed2:	6828      	ldr	r0, [r5, #0]
3220aed4:	2800      	cmp	r0, #0
3220aed6:	d1e7      	bne.n	3220aea8 <__pow5mult+0x2c>
3220aed8:	462a      	mov	r2, r5
3220aeda:	4629      	mov	r1, r5
3220aedc:	4638      	mov	r0, r7
3220aede:	f7ff ff0f 	bl	3220ad00 <__multiply>
3220aee2:	6028      	str	r0, [r5, #0]
3220aee4:	4605      	mov	r5, r0
3220aee6:	f8c0 8000 	str.w	r8, [r0]
3220aeea:	e7de      	b.n	3220aeaa <__pow5mult+0x2e>
3220aeec:	4630      	mov	r0, r6
3220aeee:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
3220aef2:	3b01      	subs	r3, #1
3220aef4:	f24c 0200 	movw	r2, #49152	@ 0xc000
3220aef8:	f2c3 2220 	movt	r2, #12832	@ 0x3220
3220aefc:	f852 2023 	ldr.w	r2, [r2, r3, lsl #2]
3220af00:	2300      	movs	r3, #0
3220af02:	f7ff fd9f 	bl	3220aa44 <__multadd>
3220af06:	4606      	mov	r6, r0
3220af08:	e7c1      	b.n	3220ae8e <__pow5mult+0x12>
3220af0a:	2101      	movs	r1, #1
3220af0c:	4638      	mov	r0, r7
3220af0e:	f7ff fd65 	bl	3220a9dc <_Balloc>
3220af12:	4605      	mov	r5, r0
3220af14:	b140      	cbz	r0, 3220af28 <__pow5mult+0xac>
3220af16:	2301      	movs	r3, #1
3220af18:	f240 2271 	movw	r2, #625	@ 0x271
3220af1c:	e9c0 3204 	strd	r3, r2, [r0, #16]
3220af20:	2300      	movs	r3, #0
3220af22:	6438      	str	r0, [r7, #64]	@ 0x40
3220af24:	6003      	str	r3, [r0, #0]
3220af26:	e7b7      	b.n	3220ae98 <__pow5mult+0x1c>
3220af28:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220af2c:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220af30:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220af34:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220af38:	462a      	mov	r2, r5
3220af3a:	f240 1145 	movw	r1, #325	@ 0x145
3220af3e:	f7f7 f935 	bl	322021ac <__assert_func>
3220af42:	bf00      	nop

3220af44 <__lshift>:
3220af44:	e92d 47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
3220af48:	460c      	mov	r4, r1
3220af4a:	ea4f 1962 	mov.w	r9, r2, asr #5
3220af4e:	6849      	ldr	r1, [r1, #4]
3220af50:	4690      	mov	r8, r2
3220af52:	6927      	ldr	r7, [r4, #16]
3220af54:	4606      	mov	r6, r0
3220af56:	68a3      	ldr	r3, [r4, #8]
3220af58:	444f      	add	r7, r9
3220af5a:	1c7d      	adds	r5, r7, #1
3220af5c:	429d      	cmp	r5, r3
3220af5e:	dd03      	ble.n	3220af68 <__lshift+0x24>
3220af60:	005b      	lsls	r3, r3, #1
3220af62:	3101      	adds	r1, #1
3220af64:	429d      	cmp	r5, r3
3220af66:	dcfb      	bgt.n	3220af60 <__lshift+0x1c>
3220af68:	4630      	mov	r0, r6
3220af6a:	f7ff fd37 	bl	3220a9dc <_Balloc>
3220af6e:	4684      	mov	ip, r0
3220af70:	2800      	cmp	r0, #0
3220af72:	d04d      	beq.n	3220b010 <__lshift+0xcc>
3220af74:	3014      	adds	r0, #20
3220af76:	f1b9 0f00 	cmp.w	r9, #0
3220af7a:	dd0b      	ble.n	3220af94 <__lshift+0x50>
3220af7c:	f109 0205 	add.w	r2, r9, #5
3220af80:	4603      	mov	r3, r0
3220af82:	2100      	movs	r1, #0
3220af84:	eb0c 0282 	add.w	r2, ip, r2, lsl #2
3220af88:	f843 1b04 	str.w	r1, [r3], #4
3220af8c:	4293      	cmp	r3, r2
3220af8e:	d1fb      	bne.n	3220af88 <__lshift+0x44>
3220af90:	eb00 0089 	add.w	r0, r0, r9, lsl #2
3220af94:	6921      	ldr	r1, [r4, #16]
3220af96:	f104 0314 	add.w	r3, r4, #20
3220af9a:	f018 081f 	ands.w	r8, r8, #31
3220af9e:	eb03 0181 	add.w	r1, r3, r1, lsl #2
3220afa2:	d02d      	beq.n	3220b000 <__lshift+0xbc>
3220afa4:	f1c8 0920 	rsb	r9, r8, #32
3220afa8:	4686      	mov	lr, r0
3220afaa:	f04f 0a00 	mov.w	sl, #0
3220afae:	681a      	ldr	r2, [r3, #0]
3220afb0:	fa02 f208 	lsl.w	r2, r2, r8
3220afb4:	ea42 020a 	orr.w	r2, r2, sl
3220afb8:	f84e 2b04 	str.w	r2, [lr], #4
3220afbc:	f853 2b04 	ldr.w	r2, [r3], #4
3220afc0:	428b      	cmp	r3, r1
3220afc2:	fa22 fa09 	lsr.w	sl, r2, r9
3220afc6:	d3f2      	bcc.n	3220afae <__lshift+0x6a>
3220afc8:	1b0b      	subs	r3, r1, r4
3220afca:	f104 0215 	add.w	r2, r4, #21
3220afce:	3b15      	subs	r3, #21
3220afd0:	f023 0303 	bic.w	r3, r3, #3
3220afd4:	4291      	cmp	r1, r2
3220afd6:	bf38      	it	cc
3220afd8:	2300      	movcc	r3, #0
3220afda:	3304      	adds	r3, #4
3220afdc:	f840 a003 	str.w	sl, [r0, r3]
3220afe0:	f1ba 0f00 	cmp.w	sl, #0
3220afe4:	d100      	bne.n	3220afe8 <__lshift+0xa4>
3220afe6:	463d      	mov	r5, r7
3220afe8:	6c73      	ldr	r3, [r6, #68]	@ 0x44
3220afea:	4660      	mov	r0, ip
3220afec:	6862      	ldr	r2, [r4, #4]
3220afee:	f8cc 5010 	str.w	r5, [ip, #16]
3220aff2:	f853 1022 	ldr.w	r1, [r3, r2, lsl #2]
3220aff6:	6021      	str	r1, [r4, #0]
3220aff8:	f843 4022 	str.w	r4, [r3, r2, lsl #2]
3220affc:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}
3220b000:	3804      	subs	r0, #4
3220b002:	f853 2b04 	ldr.w	r2, [r3], #4
3220b006:	f840 2f04 	str.w	r2, [r0, #4]!
3220b00a:	4299      	cmp	r1, r3
3220b00c:	d8f9      	bhi.n	3220b002 <__lshift+0xbe>
3220b00e:	e7ea      	b.n	3220afe6 <__lshift+0xa2>
3220b010:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220b014:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220b018:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220b01c:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220b020:	4662      	mov	r2, ip
3220b022:	f44f 71ef 	mov.w	r1, #478	@ 0x1de
3220b026:	f7f7 f8c1 	bl	322021ac <__assert_func>
3220b02a:	bf00      	nop

3220b02c <__mcmp>:
3220b02c:	690b      	ldr	r3, [r1, #16]
3220b02e:	4684      	mov	ip, r0
3220b030:	6900      	ldr	r0, [r0, #16]
3220b032:	1ac0      	subs	r0, r0, r3
3220b034:	d118      	bne.n	3220b068 <__mcmp+0x3c>
3220b036:	009b      	lsls	r3, r3, #2
3220b038:	f10c 0c14 	add.w	ip, ip, #20
3220b03c:	3114      	adds	r1, #20
3220b03e:	eb0c 0203 	add.w	r2, ip, r3
3220b042:	b410      	push	{r4}
3220b044:	440b      	add	r3, r1
3220b046:	e001      	b.n	3220b04c <__mcmp+0x20>
3220b048:	4594      	cmp	ip, r2
3220b04a:	d20a      	bcs.n	3220b062 <__mcmp+0x36>
3220b04c:	f852 4d04 	ldr.w	r4, [r2, #-4]!
3220b050:	f853 1d04 	ldr.w	r1, [r3, #-4]!
3220b054:	428c      	cmp	r4, r1
3220b056:	d0f7      	beq.n	3220b048 <__mcmp+0x1c>
3220b058:	bf28      	it	cs
3220b05a:	2001      	movcs	r0, #1
3220b05c:	d201      	bcs.n	3220b062 <__mcmp+0x36>
3220b05e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3220b062:	f85d 4b04 	ldr.w	r4, [sp], #4
3220b066:	4770      	bx	lr
3220b068:	4770      	bx	lr
3220b06a:	bf00      	nop

3220b06c <__mdiff>:
3220b06c:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
3220b070:	4689      	mov	r9, r1
3220b072:	690d      	ldr	r5, [r1, #16]
3220b074:	6913      	ldr	r3, [r2, #16]
3220b076:	b083      	sub	sp, #12
3220b078:	4614      	mov	r4, r2
3220b07a:	1aed      	subs	r5, r5, r3
3220b07c:	2d00      	cmp	r5, #0
3220b07e:	d113      	bne.n	3220b0a8 <__mdiff+0x3c>
3220b080:	009b      	lsls	r3, r3, #2
3220b082:	f101 0714 	add.w	r7, r1, #20
3220b086:	f102 0114 	add.w	r1, r2, #20
3220b08a:	4419      	add	r1, r3
3220b08c:	443b      	add	r3, r7
3220b08e:	e001      	b.n	3220b094 <__mdiff+0x28>
3220b090:	429f      	cmp	r7, r3
3220b092:	d27e      	bcs.n	3220b192 <__mdiff+0x126>
3220b094:	f853 6d04 	ldr.w	r6, [r3, #-4]!
3220b098:	f851 2d04 	ldr.w	r2, [r1, #-4]!
3220b09c:	4296      	cmp	r6, r2
3220b09e:	d0f7      	beq.n	3220b090 <__mdiff+0x24>
3220b0a0:	f080 8084 	bcs.w	3220b1ac <__mdiff+0x140>
3220b0a4:	2501      	movs	r5, #1
3220b0a6:	e003      	b.n	3220b0b0 <__mdiff+0x44>
3220b0a8:	dbfc      	blt.n	3220b0a4 <__mdiff+0x38>
3220b0aa:	2500      	movs	r5, #0
3220b0ac:	460c      	mov	r4, r1
3220b0ae:	4691      	mov	r9, r2
3220b0b0:	6861      	ldr	r1, [r4, #4]
3220b0b2:	f7ff fc93 	bl	3220a9dc <_Balloc>
3220b0b6:	4601      	mov	r1, r0
3220b0b8:	2800      	cmp	r0, #0
3220b0ba:	f000 808a 	beq.w	3220b1d2 <__mdiff+0x166>
3220b0be:	6927      	ldr	r7, [r4, #16]
3220b0c0:	f104 0b14 	add.w	fp, r4, #20
3220b0c4:	60c5      	str	r5, [r0, #12]
3220b0c6:	f104 0210 	add.w	r2, r4, #16
3220b0ca:	f8d9 0010 	ldr.w	r0, [r9, #16]
3220b0ce:	f109 0514 	add.w	r5, r9, #20
3220b0d2:	f101 0a14 	add.w	sl, r1, #20
3220b0d6:	eb0b 0e87 	add.w	lr, fp, r7, lsl #2
3220b0da:	46d0      	mov	r8, sl
3220b0dc:	2300      	movs	r3, #0
3220b0de:	eb05 0080 	add.w	r0, r5, r0, lsl #2
3220b0e2:	4694      	mov	ip, r2
3220b0e4:	f8cd b004 	str.w	fp, [sp, #4]
3220b0e8:	f855 6b04 	ldr.w	r6, [r5], #4
3220b0ec:	f85c 2f04 	ldr.w	r2, [ip, #4]!
3220b0f0:	42a8      	cmp	r0, r5
3220b0f2:	fa1f fb86 	uxth.w	fp, r6
3220b0f6:	b294      	uxth	r4, r2
3220b0f8:	eba4 040b 	sub.w	r4, r4, fp
3220b0fc:	441c      	add	r4, r3
3220b0fe:	ea4f 4316 	mov.w	r3, r6, lsr #16
3220b102:	ebc3 4312 	rsb	r3, r3, r2, lsr #16
3220b106:	eb03 4324 	add.w	r3, r3, r4, asr #16
3220b10a:	b2a4      	uxth	r4, r4
3220b10c:	ea44 4403 	orr.w	r4, r4, r3, lsl #16
3220b110:	ea4f 4323 	mov.w	r3, r3, asr #16
3220b114:	f848 4b04 	str.w	r4, [r8], #4
3220b118:	d8e6      	bhi.n	3220b0e8 <__mdiff+0x7c>
3220b11a:	eba0 0209 	sub.w	r2, r0, r9
3220b11e:	f8dd b004 	ldr.w	fp, [sp, #4]
3220b122:	3a15      	subs	r2, #21
3220b124:	f109 0915 	add.w	r9, r9, #21
3220b128:	f022 0203 	bic.w	r2, r2, #3
3220b12c:	4626      	mov	r6, r4
3220b12e:	4548      	cmp	r0, r9
3220b130:	bf38      	it	cc
3220b132:	2200      	movcc	r2, #0
3220b134:	eb0b 0402 	add.w	r4, fp, r2
3220b138:	4452      	add	r2, sl
3220b13a:	3404      	adds	r4, #4
3220b13c:	1d15      	adds	r5, r2, #4
3220b13e:	4620      	mov	r0, r4
3220b140:	45a6      	cmp	lr, r4
3220b142:	d937      	bls.n	3220b1b4 <__mdiff+0x148>
3220b144:	ebaa 0a0b 	sub.w	sl, sl, fp
3220b148:	eb00 0c0a 	add.w	ip, r0, sl
3220b14c:	f850 2b04 	ldr.w	r2, [r0], #4
3220b150:	18d6      	adds	r6, r2, r3
3220b152:	4586      	cmp	lr, r0
3220b154:	fa13 f382 	uxtah	r3, r3, r2
3220b158:	ea4f 4212 	mov.w	r2, r2, lsr #16
3220b15c:	b2b6      	uxth	r6, r6
3220b15e:	eb02 4223 	add.w	r2, r2, r3, asr #16
3220b162:	ea46 4602 	orr.w	r6, r6, r2, lsl #16
3220b166:	ea4f 4322 	mov.w	r3, r2, asr #16
3220b16a:	f8cc 6000 	str.w	r6, [ip]
3220b16e:	d8eb      	bhi.n	3220b148 <__mdiff+0xdc>
3220b170:	f10e 33ff 	add.w	r3, lr, #4294967295	@ 0xffffffff
3220b174:	1b1b      	subs	r3, r3, r4
3220b176:	f023 0303 	bic.w	r3, r3, #3
3220b17a:	442b      	add	r3, r5
3220b17c:	b926      	cbnz	r6, 3220b188 <__mdiff+0x11c>
3220b17e:	f853 2d04 	ldr.w	r2, [r3, #-4]!
3220b182:	3f01      	subs	r7, #1
3220b184:	2a00      	cmp	r2, #0
3220b186:	d0fa      	beq.n	3220b17e <__mdiff+0x112>
3220b188:	4608      	mov	r0, r1
3220b18a:	610f      	str	r7, [r1, #16]
3220b18c:	b003      	add	sp, #12
3220b18e:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220b192:	2100      	movs	r1, #0
3220b194:	f7ff fc22 	bl	3220a9dc <_Balloc>
3220b198:	4601      	mov	r1, r0
3220b19a:	b168      	cbz	r0, 3220b1b8 <__mdiff+0x14c>
3220b19c:	2201      	movs	r2, #1
3220b19e:	2300      	movs	r3, #0
3220b1a0:	e9c0 2304 	strd	r2, r3, [r0, #16]
3220b1a4:	4608      	mov	r0, r1
3220b1a6:	b003      	add	sp, #12
3220b1a8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220b1ac:	4623      	mov	r3, r4
3220b1ae:	464c      	mov	r4, r9
3220b1b0:	4699      	mov	r9, r3
3220b1b2:	e77d      	b.n	3220b0b0 <__mdiff+0x44>
3220b1b4:	4613      	mov	r3, r2
3220b1b6:	e7e1      	b.n	3220b17c <__mdiff+0x110>
3220b1b8:	460a      	mov	r2, r1
3220b1ba:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220b1be:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220b1c2:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220b1c6:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220b1ca:	f240 2137 	movw	r1, #567	@ 0x237
3220b1ce:	f7f6 ffed 	bl	322021ac <__assert_func>
3220b1d2:	460a      	mov	r2, r1
3220b1d4:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220b1d8:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220b1dc:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220b1e0:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220b1e4:	f240 2145 	movw	r1, #581	@ 0x245
3220b1e8:	f7f6 ffe0 	bl	322021ac <__assert_func>

3220b1ec <__ulp>:
3220b1ec:	b082      	sub	sp, #8
3220b1ee:	2300      	movs	r3, #0
3220b1f0:	f6c7 73f0 	movt	r3, #32752	@ 0x7ff0
3220b1f4:	ed8d 0b00 	vstr	d0, [sp]
3220b1f8:	9a01      	ldr	r2, [sp, #4]
3220b1fa:	4013      	ands	r3, r2
3220b1fc:	f1a3 7350 	sub.w	r3, r3, #54525952	@ 0x3400000
3220b200:	2b00      	cmp	r3, #0
3220b202:	bfc8      	it	gt
3220b204:	2200      	movgt	r2, #0
3220b206:	dd05      	ble.n	3220b214 <__ulp+0x28>
3220b208:	4619      	mov	r1, r3
3220b20a:	4610      	mov	r0, r2
3220b20c:	ec41 0b10 	vmov	d0, r0, r1
3220b210:	b002      	add	sp, #8
3220b212:	4770      	bx	lr
3220b214:	425b      	negs	r3, r3
3220b216:	f1b3 7fa0 	cmp.w	r3, #20971520	@ 0x1400000
3220b21a:	ea4f 5123 	mov.w	r1, r3, asr #20
3220b21e:	da09      	bge.n	3220b234 <__ulp+0x48>
3220b220:	f44f 2300 	mov.w	r3, #524288	@ 0x80000
3220b224:	2200      	movs	r2, #0
3220b226:	4610      	mov	r0, r2
3220b228:	410b      	asrs	r3, r1
3220b22a:	4619      	mov	r1, r3
3220b22c:	ec41 0b10 	vmov	d0, r0, r1
3220b230:	b002      	add	sp, #8
3220b232:	4770      	bx	lr
3220b234:	3914      	subs	r1, #20
3220b236:	f04f 4200 	mov.w	r2, #2147483648	@ 0x80000000
3220b23a:	291e      	cmp	r1, #30
3220b23c:	f04f 0300 	mov.w	r3, #0
3220b240:	fa22 f201 	lsr.w	r2, r2, r1
3220b244:	bfc8      	it	gt
3220b246:	2201      	movgt	r2, #1
3220b248:	4619      	mov	r1, r3
3220b24a:	4610      	mov	r0, r2
3220b24c:	ec41 0b10 	vmov	d0, r0, r1
3220b250:	b002      	add	sp, #8
3220b252:	4770      	bx	lr

3220b254 <__b2d>:
3220b254:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
3220b256:	f100 0614 	add.w	r6, r0, #20
3220b25a:	6904      	ldr	r4, [r0, #16]
3220b25c:	eb06 0484 	add.w	r4, r6, r4, lsl #2
3220b260:	1f27      	subs	r7, r4, #4
3220b262:	f854 5c04 	ldr.w	r5, [r4, #-4]
3220b266:	4628      	mov	r0, r5
3220b268:	f7ff fc9e 	bl	3220aba8 <__hi0bits>
3220b26c:	f1c0 0320 	rsb	r3, r0, #32
3220b270:	280a      	cmp	r0, #10
3220b272:	600b      	str	r3, [r1, #0]
3220b274:	dd2c      	ble.n	3220b2d0 <__b2d+0x7c>
3220b276:	f1a0 010b 	sub.w	r1, r0, #11
3220b27a:	42be      	cmp	r6, r7
3220b27c:	d21c      	bcs.n	3220b2b8 <__b2d+0x64>
3220b27e:	f854 0c08 	ldr.w	r0, [r4, #-8]
3220b282:	b1e9      	cbz	r1, 3220b2c0 <__b2d+0x6c>
3220b284:	f1c1 0c20 	rsb	ip, r1, #32
3220b288:	408d      	lsls	r5, r1
3220b28a:	f1a4 0708 	sub.w	r7, r4, #8
3220b28e:	fa20 f30c 	lsr.w	r3, r0, ip
3220b292:	42be      	cmp	r6, r7
3220b294:	ea45 0503 	orr.w	r5, r5, r3
3220b298:	fa00 f001 	lsl.w	r0, r0, r1
3220b29c:	f045 537f 	orr.w	r3, r5, #1069547520	@ 0x3fc00000
3220b2a0:	f443 1340 	orr.w	r3, r3, #3145728	@ 0x300000
3220b2a4:	d210      	bcs.n	3220b2c8 <__b2d+0x74>
3220b2a6:	f854 1c0c 	ldr.w	r1, [r4, #-12]
3220b2aa:	fa21 f10c 	lsr.w	r1, r1, ip
3220b2ae:	4308      	orrs	r0, r1
3220b2b0:	4602      	mov	r2, r0
3220b2b2:	ec43 2b10 	vmov	d0, r2, r3
3220b2b6:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3220b2b8:	280b      	cmp	r0, #11
3220b2ba:	bf08      	it	eq
3220b2bc:	2000      	moveq	r0, #0
3220b2be:	d11f      	bne.n	3220b300 <__b2d+0xac>
3220b2c0:	f045 537f 	orr.w	r3, r5, #1069547520	@ 0x3fc00000
3220b2c4:	f443 1340 	orr.w	r3, r3, #3145728	@ 0x300000
3220b2c8:	4602      	mov	r2, r0
3220b2ca:	ec43 2b10 	vmov	d0, r2, r3
3220b2ce:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3220b2d0:	f1c0 0c0b 	rsb	ip, r0, #11
3220b2d4:	42be      	cmp	r6, r7
3220b2d6:	fa25 f10c 	lsr.w	r1, r5, ip
3220b2da:	f041 537f 	orr.w	r3, r1, #1069547520	@ 0x3fc00000
3220b2de:	bf28      	it	cs
3220b2e0:	2100      	movcs	r1, #0
3220b2e2:	f443 1340 	orr.w	r3, r3, #3145728	@ 0x300000
3220b2e6:	d203      	bcs.n	3220b2f0 <__b2d+0x9c>
3220b2e8:	f854 1c08 	ldr.w	r1, [r4, #-8]
3220b2ec:	fa21 f10c 	lsr.w	r1, r1, ip
3220b2f0:	3015      	adds	r0, #21
3220b2f2:	fa05 f000 	lsl.w	r0, r5, r0
3220b2f6:	4308      	orrs	r0, r1
3220b2f8:	4602      	mov	r2, r0
3220b2fa:	ec43 2b10 	vmov	d0, r2, r3
3220b2fe:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3220b300:	fa05 f101 	lsl.w	r1, r5, r1
3220b304:	2000      	movs	r0, #0
3220b306:	f041 537f 	orr.w	r3, r1, #1069547520	@ 0x3fc00000
3220b30a:	4602      	mov	r2, r0
3220b30c:	f443 1340 	orr.w	r3, r3, #3145728	@ 0x300000
3220b310:	ec43 2b10 	vmov	d0, r2, r3
3220b314:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3220b316:	bf00      	nop

3220b318 <__d2b>:
3220b318:	e92d 43f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, lr}
3220b31c:	460e      	mov	r6, r1
3220b31e:	2101      	movs	r1, #1
3220b320:	b083      	sub	sp, #12
3220b322:	ec59 8b10 	vmov	r8, r9, d0
3220b326:	4615      	mov	r5, r2
3220b328:	f7ff fb58 	bl	3220a9dc <_Balloc>
3220b32c:	4607      	mov	r7, r0
3220b32e:	2800      	cmp	r0, #0
3220b330:	d045      	beq.n	3220b3be <__d2b+0xa6>
3220b332:	f3c9 0313 	ubfx	r3, r9, #0, #20
3220b336:	f3c9 540a 	ubfx	r4, r9, #20, #11
3220b33a:	b10c      	cbz	r4, 3220b340 <__d2b+0x28>
3220b33c:	f443 1380 	orr.w	r3, r3, #1048576	@ 0x100000
3220b340:	9301      	str	r3, [sp, #4]
3220b342:	f1b8 0300 	subs.w	r3, r8, #0
3220b346:	d113      	bne.n	3220b370 <__d2b+0x58>
3220b348:	a801      	add	r0, sp, #4
3220b34a:	f7ff fc59 	bl	3220ac00 <__lo0bits>
3220b34e:	9b01      	ldr	r3, [sp, #4]
3220b350:	2101      	movs	r1, #1
3220b352:	3020      	adds	r0, #32
3220b354:	617b      	str	r3, [r7, #20]
3220b356:	6139      	str	r1, [r7, #16]
3220b358:	b314      	cbz	r4, 3220b3a0 <__d2b+0x88>
3220b35a:	f2a4 4433 	subw	r4, r4, #1075	@ 0x433
3220b35e:	4404      	add	r4, r0
3220b360:	f1c0 0035 	rsb	r0, r0, #53	@ 0x35
3220b364:	6034      	str	r4, [r6, #0]
3220b366:	6028      	str	r0, [r5, #0]
3220b368:	4638      	mov	r0, r7
3220b36a:	b003      	add	sp, #12
3220b36c:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
3220b370:	4668      	mov	r0, sp
3220b372:	9300      	str	r3, [sp, #0]
3220b374:	f7ff fc44 	bl	3220ac00 <__lo0bits>
3220b378:	e9dd 2300 	ldrd	r2, r3, [sp]
3220b37c:	b130      	cbz	r0, 3220b38c <__d2b+0x74>
3220b37e:	f1c0 0120 	rsb	r1, r0, #32
3220b382:	fa03 f101 	lsl.w	r1, r3, r1
3220b386:	430a      	orrs	r2, r1
3220b388:	40c3      	lsrs	r3, r0
3220b38a:	9301      	str	r3, [sp, #4]
3220b38c:	2b00      	cmp	r3, #0
3220b38e:	f04f 0101 	mov.w	r1, #1
3220b392:	617a      	str	r2, [r7, #20]
3220b394:	bf18      	it	ne
3220b396:	2102      	movne	r1, #2
3220b398:	61bb      	str	r3, [r7, #24]
3220b39a:	6139      	str	r1, [r7, #16]
3220b39c:	2c00      	cmp	r4, #0
3220b39e:	d1dc      	bne.n	3220b35a <__d2b+0x42>
3220b3a0:	eb07 0381 	add.w	r3, r7, r1, lsl #2
3220b3a4:	f2a0 4032 	subw	r0, r0, #1074	@ 0x432
3220b3a8:	6030      	str	r0, [r6, #0]
3220b3aa:	6918      	ldr	r0, [r3, #16]
3220b3ac:	f7ff fbfc 	bl	3220aba8 <__hi0bits>
3220b3b0:	ebc0 1041 	rsb	r0, r0, r1, lsl #5
3220b3b4:	6028      	str	r0, [r5, #0]
3220b3b6:	4638      	mov	r0, r7
3220b3b8:	b003      	add	sp, #12
3220b3ba:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
3220b3be:	f64b 3384 	movw	r3, #48004	@ 0xbb84
3220b3c2:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220b3c6:	f64b 30f4 	movw	r0, #48116	@ 0xbbf4
3220b3ca:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220b3ce:	463a      	mov	r2, r7
3220b3d0:	f240 310f 	movw	r1, #783	@ 0x30f
3220b3d4:	f7f6 feea 	bl	322021ac <__assert_func>

3220b3d8 <__ratio>:
3220b3d8:	b5f0      	push	{r4, r5, r6, r7, lr}
3220b3da:	460e      	mov	r6, r1
3220b3dc:	4607      	mov	r7, r0
3220b3de:	b083      	sub	sp, #12
3220b3e0:	4669      	mov	r1, sp
3220b3e2:	f7ff ff37 	bl	3220b254 <__b2d>
3220b3e6:	a901      	add	r1, sp, #4
3220b3e8:	4630      	mov	r0, r6
3220b3ea:	eeb0 7b40 	vmov.f64	d7, d0
3220b3ee:	ec55 4b10 	vmov	r4, r5, d0
3220b3f2:	f7ff ff2f 	bl	3220b254 <__b2d>
3220b3f6:	6933      	ldr	r3, [r6, #16]
3220b3f8:	693a      	ldr	r2, [r7, #16]
3220b3fa:	1ad2      	subs	r2, r2, r3
3220b3fc:	e9dd 3100 	ldrd	r3, r1, [sp]
3220b400:	1a5b      	subs	r3, r3, r1
3220b402:	eb03 1342 	add.w	r3, r3, r2, lsl #5
3220b406:	2b00      	cmp	r3, #0
3220b408:	dd09      	ble.n	3220b41e <__ratio+0x46>
3220b40a:	ee17 2a90 	vmov	r2, s15
3220b40e:	eb02 5503 	add.w	r5, r2, r3, lsl #20
3220b412:	ec45 4b17 	vmov	d7, r4, r5
3220b416:	ee87 0b00 	vdiv.f64	d0, d7, d0
3220b41a:	b003      	add	sp, #12
3220b41c:	bdf0      	pop	{r4, r5, r6, r7, pc}
3220b41e:	ec51 0b10 	vmov	r0, r1, d0
3220b422:	ee10 2a90 	vmov	r2, s1
3220b426:	eba2 5103 	sub.w	r1, r2, r3, lsl #20
3220b42a:	ec41 0b10 	vmov	d0, r0, r1
3220b42e:	ee87 0b00 	vdiv.f64	d0, d7, d0
3220b432:	b003      	add	sp, #12
3220b434:	bdf0      	pop	{r4, r5, r6, r7, pc}
3220b436:	bf00      	nop

3220b438 <_mprec_log10>:
3220b438:	2817      	cmp	r0, #23
3220b43a:	eeb7 0b00 	vmov.f64	d0, #112	@ 0x3f800000  1.0
3220b43e:	eef2 0b04 	vmov.f64	d16, #36	@ 0x41200000  10.0
3220b442:	dd04      	ble.n	3220b44e <_mprec_log10+0x16>
3220b444:	ee20 0b20 	vmul.f64	d0, d0, d16
3220b448:	3801      	subs	r0, #1
3220b44a:	d1fb      	bne.n	3220b444 <_mprec_log10+0xc>
3220b44c:	4770      	bx	lr
3220b44e:	f24c 0360 	movw	r3, #49248	@ 0xc060
3220b452:	f2c3 2320 	movt	r3, #12832	@ 0x3220
3220b456:	eb03 03c0 	add.w	r3, r3, r0, lsl #3
3220b45a:	ed93 0b00 	vldr	d0, [r3]
3220b45e:	4770      	bx	lr

3220b460 <__copybits>:
3220b460:	3901      	subs	r1, #1
3220b462:	f102 0314 	add.w	r3, r2, #20
3220b466:	ea4f 1c61 	mov.w	ip, r1, asr #5
3220b46a:	6911      	ldr	r1, [r2, #16]
3220b46c:	f10c 0c01 	add.w	ip, ip, #1
3220b470:	eb03 0181 	add.w	r1, r3, r1, lsl #2
3220b474:	eb00 0c8c 	add.w	ip, r0, ip, lsl #2
3220b478:	428b      	cmp	r3, r1
3220b47a:	d216      	bcs.n	3220b4aa <__copybits+0x4a>
3220b47c:	b510      	push	{r4, lr}
3220b47e:	f1a0 0e04 	sub.w	lr, r0, #4
3220b482:	f853 4b04 	ldr.w	r4, [r3], #4
3220b486:	f84e 4f04 	str.w	r4, [lr, #4]!
3220b48a:	4299      	cmp	r1, r3
3220b48c:	d8f9      	bhi.n	3220b482 <__copybits+0x22>
3220b48e:	1a89      	subs	r1, r1, r2
3220b490:	3004      	adds	r0, #4
3220b492:	3915      	subs	r1, #21
3220b494:	f021 0103 	bic.w	r1, r1, #3
3220b498:	4408      	add	r0, r1
3220b49a:	4584      	cmp	ip, r0
3220b49c:	d904      	bls.n	3220b4a8 <__copybits+0x48>
3220b49e:	2300      	movs	r3, #0
3220b4a0:	f840 3b04 	str.w	r3, [r0], #4
3220b4a4:	4584      	cmp	ip, r0
3220b4a6:	d8fb      	bhi.n	3220b4a0 <__copybits+0x40>
3220b4a8:	bd10      	pop	{r4, pc}
3220b4aa:	4584      	cmp	ip, r0
3220b4ac:	d905      	bls.n	3220b4ba <__copybits+0x5a>
3220b4ae:	2300      	movs	r3, #0
3220b4b0:	f840 3b04 	str.w	r3, [r0], #4
3220b4b4:	4584      	cmp	ip, r0
3220b4b6:	d8fb      	bhi.n	3220b4b0 <__copybits+0x50>
3220b4b8:	4770      	bx	lr
3220b4ba:	4770      	bx	lr

3220b4bc <__any_on>:
3220b4bc:	6903      	ldr	r3, [r0, #16]
3220b4be:	114a      	asrs	r2, r1, #5
3220b4c0:	f100 0c14 	add.w	ip, r0, #20
3220b4c4:	4293      	cmp	r3, r2
3220b4c6:	da09      	bge.n	3220b4dc <__any_on+0x20>
3220b4c8:	eb0c 0383 	add.w	r3, ip, r3, lsl #2
3220b4cc:	e002      	b.n	3220b4d4 <__any_on+0x18>
3220b4ce:	f853 2d04 	ldr.w	r2, [r3, #-4]!
3220b4d2:	b982      	cbnz	r2, 3220b4f6 <__any_on+0x3a>
3220b4d4:	4563      	cmp	r3, ip
3220b4d6:	d8fa      	bhi.n	3220b4ce <__any_on+0x12>
3220b4d8:	2000      	movs	r0, #0
3220b4da:	4770      	bx	lr
3220b4dc:	eb0c 0382 	add.w	r3, ip, r2, lsl #2
3220b4e0:	ddf8      	ble.n	3220b4d4 <__any_on+0x18>
3220b4e2:	f011 011f 	ands.w	r1, r1, #31
3220b4e6:	d0f5      	beq.n	3220b4d4 <__any_on+0x18>
3220b4e8:	f85c 0022 	ldr.w	r0, [ip, r2, lsl #2]
3220b4ec:	fa20 f201 	lsr.w	r2, r0, r1
3220b4f0:	408a      	lsls	r2, r1
3220b4f2:	4290      	cmp	r0, r2
3220b4f4:	d0ee      	beq.n	3220b4d4 <__any_on+0x18>
3220b4f6:	2001      	movs	r0, #1
3220b4f8:	4770      	bx	lr
3220b4fa:	bf00      	nop

3220b4fc <_wcsnrtombs_l>:
3220b4fc:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
3220b500:	461c      	mov	r4, r3
3220b502:	b08b      	sub	sp, #44	@ 0x2c
3220b504:	e9dd 8915 	ldrd	r8, r9, [sp, #84]	@ 0x54
3220b508:	9002      	str	r0, [sp, #8]
3220b50a:	9f14      	ldr	r7, [sp, #80]	@ 0x50
3220b50c:	f1b8 0f00 	cmp.w	r8, #0
3220b510:	d050      	beq.n	3220b5b4 <_wcsnrtombs_l+0xb8>
3220b512:	6816      	ldr	r6, [r2, #0]
3220b514:	2900      	cmp	r1, #0
3220b516:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
3220b51a:	46c3      	mov	fp, r8
3220b51c:	bf08      	it	eq
3220b51e:	461f      	moveq	r7, r3
3220b520:	2500      	movs	r5, #0
3220b522:	4692      	mov	sl, r2
3220b524:	4688      	mov	r8, r1
3220b526:	9601      	str	r6, [sp, #4]
3220b528:	9103      	str	r1, [sp, #12]
3220b52a:	e007      	b.n	3220b53c <_wcsnrtombs_l+0x40>
3220b52c:	9b01      	ldr	r3, [sp, #4]
3220b52e:	3c01      	subs	r4, #1
3220b530:	f853 0b04 	ldr.w	r0, [r3], #4
3220b534:	9301      	str	r3, [sp, #4]
3220b536:	2800      	cmp	r0, #0
3220b538:	d04a      	beq.n	3220b5d0 <_wcsnrtombs_l+0xd4>
3220b53a:	4665      	mov	r5, ip
3220b53c:	42af      	cmp	r7, r5
3220b53e:	d935      	bls.n	3220b5ac <_wcsnrtombs_l+0xb0>
3220b540:	2c00      	cmp	r4, #0
3220b542:	d033      	beq.n	3220b5ac <_wcsnrtombs_l+0xb0>
3220b544:	f8db 3000 	ldr.w	r3, [fp]
3220b548:	a906      	add	r1, sp, #24
3220b54a:	9304      	str	r3, [sp, #16]
3220b54c:	f8db 3004 	ldr.w	r3, [fp, #4]
3220b550:	9305      	str	r3, [sp, #20]
3220b552:	9b01      	ldr	r3, [sp, #4]
3220b554:	9802      	ldr	r0, [sp, #8]
3220b556:	f8d9 60e0 	ldr.w	r6, [r9, #224]	@ 0xe0
3220b55a:	681a      	ldr	r2, [r3, #0]
3220b55c:	465b      	mov	r3, fp
3220b55e:	47b0      	blx	r6
3220b560:	1c43      	adds	r3, r0, #1
3220b562:	d01c      	beq.n	3220b59e <_wcsnrtombs_l+0xa2>
3220b564:	eb00 0c05 	add.w	ip, r0, r5
3220b568:	45bc      	cmp	ip, r7
3220b56a:	d826      	bhi.n	3220b5ba <_wcsnrtombs_l+0xbe>
3220b56c:	9b03      	ldr	r3, [sp, #12]
3220b56e:	2b00      	cmp	r3, #0
3220b570:	d0dc      	beq.n	3220b52c <_wcsnrtombs_l+0x30>
3220b572:	2800      	cmp	r0, #0
3220b574:	dd0d      	ble.n	3220b592 <_wcsnrtombs_l+0x96>
3220b576:	f108 32ff 	add.w	r2, r8, #4294967295	@ 0xffffffff
3220b57a:	9e01      	ldr	r6, [sp, #4]
3220b57c:	a906      	add	r1, sp, #24
3220b57e:	eb02 0e00 	add.w	lr, r2, r0
3220b582:	f811 3b01 	ldrb.w	r3, [r1], #1
3220b586:	f802 3f01 	strb.w	r3, [r2, #1]!
3220b58a:	4572      	cmp	r2, lr
3220b58c:	d1f9      	bne.n	3220b582 <_wcsnrtombs_l+0x86>
3220b58e:	4480      	add	r8, r0
3220b590:	9601      	str	r6, [sp, #4]
3220b592:	f8da 2000 	ldr.w	r2, [sl]
3220b596:	3204      	adds	r2, #4
3220b598:	f8ca 2000 	str.w	r2, [sl]
3220b59c:	e7c6      	b.n	3220b52c <_wcsnrtombs_l+0x30>
3220b59e:	9b02      	ldr	r3, [sp, #8]
3220b5a0:	4605      	mov	r5, r0
3220b5a2:	218a      	movs	r1, #138	@ 0x8a
3220b5a4:	2200      	movs	r2, #0
3220b5a6:	6019      	str	r1, [r3, #0]
3220b5a8:	f8cb 2000 	str.w	r2, [fp]
3220b5ac:	4628      	mov	r0, r5
3220b5ae:	b00b      	add	sp, #44	@ 0x2c
3220b5b0:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220b5b4:	f500 7886 	add.w	r8, r0, #268	@ 0x10c
3220b5b8:	e7ab      	b.n	3220b512 <_wcsnrtombs_l+0x16>
3220b5ba:	46d8      	mov	r8, fp
3220b5bc:	f8dd a010 	ldr.w	sl, [sp, #16]
3220b5c0:	f8dd b014 	ldr.w	fp, [sp, #20]
3220b5c4:	4628      	mov	r0, r5
3220b5c6:	e9c8 ab00 	strd	sl, fp, [r8]
3220b5ca:	b00b      	add	sp, #44	@ 0x2c
3220b5cc:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3220b5d0:	9903      	ldr	r1, [sp, #12]
3220b5d2:	46d8      	mov	r8, fp
3220b5d4:	b109      	cbz	r1, 3220b5da <_wcsnrtombs_l+0xde>
3220b5d6:	f8ca 0000 	str.w	r0, [sl]
3220b5da:	f10c 35ff 	add.w	r5, ip, #4294967295	@ 0xffffffff
3220b5de:	2200      	movs	r2, #0
3220b5e0:	4628      	mov	r0, r5
3220b5e2:	f8c8 2000 	str.w	r2, [r8]
3220b5e6:	b00b      	add	sp, #44	@ 0x2c
3220b5e8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}

3220b5ec <_wcsnrtombs_r>:
3220b5ec:	b510      	push	{r4, lr}
3220b5ee:	f24c 2440 	movw	r4, #49728	@ 0xc240
3220b5f2:	f2c3 2420 	movt	r4, #12832	@ 0x3220
3220b5f6:	b084      	sub	sp, #16
3220b5f8:	9806      	ldr	r0, [sp, #24]
3220b5fa:	9000      	str	r0, [sp, #0]
3220b5fc:	9807      	ldr	r0, [sp, #28]
3220b5fe:	9001      	str	r0, [sp, #4]
3220b600:	f24c 30d0 	movw	r0, #50128	@ 0xc3d0
3220b604:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220b608:	9402      	str	r4, [sp, #8]
3220b60a:	6800      	ldr	r0, [r0, #0]
3220b60c:	f7ff ff76 	bl	3220b4fc <_wcsnrtombs_l>
3220b610:	b004      	add	sp, #16
3220b612:	bd10      	pop	{r4, pc}

3220b614 <wcsnrtombs>:
3220b614:	b510      	push	{r4, lr}
3220b616:	4694      	mov	ip, r2
3220b618:	461c      	mov	r4, r3
3220b61a:	b084      	sub	sp, #16
3220b61c:	4663      	mov	r3, ip
3220b61e:	9a06      	ldr	r2, [sp, #24]
3220b620:	9201      	str	r2, [sp, #4]
3220b622:	460a      	mov	r2, r1
3220b624:	4601      	mov	r1, r0
3220b626:	f24c 30d0 	movw	r0, #50128	@ 0xc3d0
3220b62a:	f2c3 2020 	movt	r0, #12832	@ 0x3220
3220b62e:	9400      	str	r4, [sp, #0]
3220b630:	f24c 2440 	movw	r4, #49728	@ 0xc240
3220b634:	f2c3 2420 	movt	r4, #12832	@ 0x3220
3220b638:	9402      	str	r4, [sp, #8]
3220b63a:	6800      	ldr	r0, [r0, #0]
3220b63c:	f7ff ff5e 	bl	3220b4fc <_wcsnrtombs_l>
3220b640:	b004      	add	sp, #16
3220b642:	bd10      	pop	{r4, pc}

3220b644 <_calloc_r>:
3220b644:	b538      	push	{r3, r4, r5, lr}
3220b646:	fba1 1402 	umull	r1, r4, r1, r2
3220b64a:	bb4c      	cbnz	r4, 3220b6a0 <_calloc_r+0x5c>
3220b64c:	f7fa fa9c 	bl	32205b88 <_malloc_r>
3220b650:	4605      	mov	r5, r0
3220b652:	b348      	cbz	r0, 3220b6a8 <_calloc_r+0x64>
3220b654:	f850 2c04 	ldr.w	r2, [r0, #-4]
3220b658:	f022 0203 	bic.w	r2, r2, #3
3220b65c:	3a04      	subs	r2, #4
3220b65e:	2a24      	cmp	r2, #36	@ 0x24
3220b660:	d819      	bhi.n	3220b696 <_calloc_r+0x52>
3220b662:	2a13      	cmp	r2, #19
3220b664:	bf98      	it	ls
3220b666:	4603      	movls	r3, r0
3220b668:	d90d      	bls.n	3220b686 <_calloc_r+0x42>
3220b66a:	efc0 0010 	vmov.i32	d16, #0	@ 0x00000000
3220b66e:	f100 0308 	add.w	r3, r0, #8
3220b672:	2a1b      	cmp	r2, #27
3220b674:	f940 078f 	vst1.32	{d16}, [r0]
3220b678:	d905      	bls.n	3220b686 <_calloc_r+0x42>
3220b67a:	f943 078f 	vst1.32	{d16}, [r3]
3220b67e:	2a24      	cmp	r2, #36	@ 0x24
3220b680:	f100 0310 	add.w	r3, r0, #16
3220b684:	d013      	beq.n	3220b6ae <_calloc_r+0x6a>
3220b686:	efc0 0010 	vmov.i32	d16, #0	@ 0x00000000
3220b68a:	2200      	movs	r2, #0
3220b68c:	4628      	mov	r0, r5
3220b68e:	609a      	str	r2, [r3, #8]
3220b690:	f943 078f 	vst1.32	{d16}, [r3]
3220b694:	bd38      	pop	{r3, r4, r5, pc}
3220b696:	4621      	mov	r1, r4
3220b698:	f7f8 fd66 	bl	32204168 <memset>
3220b69c:	4628      	mov	r0, r5
3220b69e:	bd38      	pop	{r3, r4, r5, pc}
3220b6a0:	f7f9 fb4a 	bl	32204d38 <__errno>
3220b6a4:	230c      	movs	r3, #12
3220b6a6:	6003      	str	r3, [r0, #0]
3220b6a8:	2500      	movs	r5, #0
3220b6aa:	4628      	mov	r0, r5
3220b6ac:	bd38      	pop	{r3, r4, r5, pc}
3220b6ae:	f100 0210 	add.w	r2, r0, #16
3220b6b2:	f100 0318 	add.w	r3, r0, #24
3220b6b6:	f942 078f 	vst1.32	{d16}, [r2]
3220b6ba:	e7e4      	b.n	3220b686 <_calloc_r+0x42>
3220b6bc:	0000      	movs	r0, r0
	...

3220b6c0 <__puts_from_arm>:
3220b6c0:	e51ff004 	ldr	pc, [pc, #-4]	@ 3220b6c4 <__puts_from_arm+0x4>
3220b6c4:	32203ed9 	.word	0x32203ed9

3220b6c8 <___getpid_from_thumb>:
3220b6c8:	4778      	bx	pc
3220b6ca:	e7fd      	b.n	3220b6c8 <___getpid_from_thumb>
3220b6cc:	eaffd374 	b	322004a4 <_getpid>
