
/home/daniel/workspace/osyxtech/bao-benchmarks/src/irq-lat-wce/irq-lat-wce-guest2/build/irq-lat-wce-guest2/irq-lat-wce-guest2.elf:     file format elf32-littlearm


Disassembly of section .start:

32300000 <_start>:

.section .start, "ax"
.global _start
_start:

    mrs r0, cpsr
32300000:	e10f0000 	mrs	r0, CPSR
    and r1, r0, #CPSR_M_MSK
32300004:	e200100f 	and	r1, r0, #15
    cmp r1, #CPSR_M_HYP
32300008:	e351000a 	cmp	r1, #10
    beq 1f
3230000c:	0a000001 	beq	32300018 <_start+0x18>
    cps #MODE_SVC
32300010:	f1020013 	cps	#19
    b entry_el1
32300014:	ea000018 	b	3230007c <entry_el1>
1:
#if GIC_VERSION == GICV3
    mrc p15, 4, r0, c12, c9, 5 // icc_hsre
32300018:	ee9c0fb9 	mrc	15, 4, r0, cr12, cr9, {5}
    orr r0, r0, #0x9
3230001c:	e3800009 	orr	r0, r0, #9
    mcr p15, 4, r0, c12, c9, 5 // icc_hsre
32300020:	ee8c0fb9 	mcr	15, 4, r0, cr12, cr9, {5}
#endif

###
    /* --- Read/modify/write HACTLR (ACTLR_EL2 equivalent) --- */
    mrc     p15, 4, r0, c1, c0, 1        /* r0 = HACTLR */
32300024:	ee910f30 	mrc	15, 4, r0, cr1, cr0, {1}
    orr     r0, r0, #ACTLR_PERIPHPREGIONR
32300028:	e3800c01 	orr	r0, r0, #256	@ 0x100
    mcr     p15, 4, r0, c1, c0, 1        /* HACTLR = r0 */
3230002c:	ee810f30 	mcr	15, 4, r0, cr1, cr0, {1}

    /* --- Read/modify/write IMP_PERIPHPREGIONR (IMPLEMENTATION-DEFINED) --- */
    /* Replace the following MRC/MCR with the encoding from your TRM. */
    mrc     p15, 0, r1, c15, c0, 0       /* r1 = IMP_PERIPHPREGIONR (PLACEHOLDER) */
32300030:	ee1f1f10 	mrc	15, 0, r1, cr15, cr0, {0}
    orr     r1, r1, #(IMP_PERIPHPREGIONR_ENABLEEL10 | IMP_PERIPHPREGIONR_ENABLEEL2)
32300034:	e3811003 	orr	r1, r1, #3
    mcr     p15, 0, r1, c15, c0, 0       /* IMP_PERIPHPREGIONR = r1 (PLACEHOLDER) */
32300038:	ee0f1f10 	mcr	15, 0, r1, cr15, cr0, {0}

    isb
3230003c:	f57ff06f 	isb	sy
###



#if defined(MPU)
    ldr r0, =0x76120010
32300040:	e59f0188 	ldr	r0, [pc, #392]	@ 323001d0 <clear+0x1c>
    ldr r1, [r0]
32300044:	e5901000 	ldr	r1, [r0]
    and r1, r1, #0x0
32300048:	e2011000 	and	r1, r1, #0
    str r1, [r0]
3230004c:	e5801000 	str	r1, [r0]
    ldr r0, =FREQ
32300050:	e59f017c 	ldr	r0, [pc, #380]	@ 323001d4 <clear+0x20>
    mcr p15, 0, r0, c14, c0, 0 // cntfrq
32300054:	ee0e0f10 	mcr	15, 0, r0, cr14, cr0, {0}
#endif

    mrs r0, cpsr
32300058:	e10f0000 	mrs	r0, CPSR
    mov r1, #MODE_SVC
3230005c:	e3a01013 	mov	r1, #19
    bfi r0, r1, #0, #5
32300060:	e7c40011 	bfi	r0, r1, #0, #5
    msr spsr_hyp, r0
32300064:	e16ef300 	msr	SPSR_hyp, r0
    ldr r0, =entry_el1
32300068:	e59f0168 	ldr	r0, [pc, #360]	@ 323001d8 <clear+0x24>
    msr elr_hyp, r0
3230006c:	e12ef300 	msr	ELR_hyp, r0
    dsb
32300070:	f57ff04f 	dsb	sy
    isb
32300074:	f57ff06f 	isb	sy
    eret
32300078:	e160006e 	eret

3230007c <entry_el1>:

entry_el1:
    mrc p15, 0, r0, c0, c0, 5 // mpidr
3230007c:	ee100fb0 	mrc	15, 0, r0, cr0, cr0, {5}
    and r0, r0, #MPIDR_CPU_MASK
32300080:	e20000ff 	and	r0, r0, #255	@ 0xff

    ldr r1, =_exception_vector
32300084:	e59f1150 	ldr	r1, [pc, #336]	@ 323001dc <clear+0x28>
    mcr	p15, 0, r1, c12, c0, 0 // vbar
32300088:	ee0c1f10 	mcr	15, 0, r1, cr12, cr0, {0}

    // Enable floating point
    mov r1, #(0xf << 20)
3230008c:	e3a0160f 	mov	r1, #15728640	@ 0xf00000
    mcr p15, 0, r1, c1, c0, 2 // cpacr
32300090:	ee011f50 	mcr	15, 0, r1, cr1, cr0, {2}
    isb
32300094:	f57ff06f 	isb	sy
    mov r1, #(0x1 << 30)
32300098:	e3a01101 	mov	r1, #1073741824	@ 0x40000000
    vmsr fpexc, r1
3230009c:	eee81a10 	vmsr	fpexc, r1

    // TODO: invalidate caches, bp, etc...

    ldr r4, =MAIR_EL1_DFLT
323000a0:	e59f4138 	ldr	r4, [pc, #312]	@ 323001e0 <clear+0x2c>
    mcr p15, 0, r4, c10, c2, 0 // mair
323000a4:	ee0a4f12 	mcr	15, 0, r4, cr10, cr2, {0}

#ifdef MPU

    // Set MPU region for cacheability and shareability
    mov r4, #0
323000a8:	e3a04000 	mov	r4, #0
    mcr p15, 0, r4, c6, c2, 1  // prselr
323000ac:	ee064f32 	mcr	15, 0, r4, cr6, cr2, {1}
    ldr r4, =(MEM_BASE)
323000b0:	e59f412c 	ldr	r4, [pc, #300]	@ 323001e4 <clear+0x30>
    and r4, r4, #PRBAR_BASE_MSK
323000b4:	e3c4403f 	bic	r4, r4, #63	@ 0x3f
    orr r4, r4, #(PRBAR_SH_IS | PRBAR_AP_RW_ALL)
323000b8:	e384401a 	orr	r4, r4, #26
    mcr p15, 0, r4, c6, c3, 0  // prbar
323000bc:	ee064f13 	mcr	15, 0, r4, cr6, cr3, {0}
    ldr r4, =(MEM_BASE + MEM_SIZE - 1)
323000c0:	e59f4120 	ldr	r4, [pc, #288]	@ 323001e8 <clear+0x34>
    and r4, r4, #PRLAR_LIMIT_MSK
323000c4:	e3c4403f 	bic	r4, r4, #63	@ 0x3f
    orr r4, r4, #(PRLAR_ATTR(1) | PRLAR_EN)
323000c8:	e3844003 	orr	r4, r4, #3
    mcr p15, 0, r4, c6, c3, 1  // prlar
323000cc:	ee064f33 	mcr	15, 0, r4, cr6, cr3, {1}

    ldr r4, =(MEM_BASE)
323000d0:	e59f410c 	ldr	r4, [pc, #268]	@ 323001e4 <clear+0x30>
    cmp r4, #0
323000d4:	e3540000 	cmp	r4, #0
    blne devices_low
323000d8:	1b000003 	blne	323000ec <devices_low>
    ldr r5, =(MEM_BASE + MEM_SIZE)
323000dc:	e3a055c9 	mov	r5, #843055104	@ 0x32400000
    cmp r5, #0xffffffff
323000e0:	e3750001 	cmn	r5, #1
    bne devices_high
323000e4:	1a00000a 	bne	32300114 <devices_high>
    b 1f
323000e8:	ea000011 	b	32300134 <devices_high+0x20>

323000ec <devices_low>:

    devices_low:
    mov r4, #1
323000ec:	e3a04001 	mov	r4, #1
    mcr p15, 0, r4, c6, c2, 1  // prselr
323000f0:	ee064f32 	mcr	15, 0, r4, cr6, cr2, {1}
    mov r4, #(PRBAR_BASE(0) | PRBAR_SH_IS | PRBAR_AP_RW_ALL)
323000f4:	e3a0401a 	mov	r4, #26
    mcr p15, 0, r4, c6, c3, 0  // prbar
323000f8:	ee064f13 	mcr	15, 0, r4, cr6, cr3, {0}
    ldr r4, =(MEM_BASE - 1)
323000fc:	e59f40e8 	ldr	r4, [pc, #232]	@ 323001ec <clear+0x38>
    and r4, r4, #PRLAR_LIMIT_MSK
32300100:	e3c4403f 	bic	r4, r4, #63	@ 0x3f
    orr r4, r4, #(PRLAR_ATTR(2) | PRLAR_EN)
32300104:	e3844005 	orr	r4, r4, #5
    mcr p15, 0, r4, c6, c3, 1  // prlar
32300108:	ee064f33 	mcr	15, 0, r4, cr6, cr3, {1}
    mov r4, #1
3230010c:	e3a04001 	mov	r4, #1
    bx lr
32300110:	e12fff1e 	bx	lr

32300114 <devices_high>:

    devices_high:
    add r4, r4, #1
32300114:	e2844001 	add	r4, r4, #1
    mcr p15, 0, r4, c6, c2, 1  // prselr
32300118:	ee064f32 	mcr	15, 0, r4, cr6, cr2, {1}
    ldr r4, =(MEM_BASE + MEM_SIZE)
3230011c:	e3a045c9 	mov	r4, #843055104	@ 0x32400000
    and r4, r4, #PRBAR_BASE_MSK
32300120:	e3c4403f 	bic	r4, r4, #63	@ 0x3f
    orr r4, r4, #(PRBAR_SH_IS | PRBAR_AP_RW_ALL)
32300124:	e384401a 	orr	r4, r4, #26
    mcr p15, 0, r4, c6, c3, 0  // prbar
32300128:	ee064f13 	mcr	15, 0, r4, cr6, cr3, {0}
    mov r4, #(PRLAR_LIMIT(0xffffffffUL) | PRLAR_ATTR(2) | PRLAR_EN)
3230012c:	e3e0403a 	mvn	r4, #58	@ 0x3a
    mcr p15, 0, r4, c6, c3, 1  // prlar
32300130:	ee064f33 	mcr	15, 0, r4, cr6, cr3, {1}

    1:
    dsb
32300134:	f57ff04f 	dsb	sy
    isb
32300138:	f57ff06f 	isb	sy

    ldr r1, =(SCTLR_RES1 | SCTLR_C | SCTLR_I | SCTLR_BR   | SCTLR_M)
3230013c:	e59f10ac 	ldr	r1, [pc, #172]	@ 323001f0 <clear+0x3c>
    mcr p15, 0, r1, c1, c0, 0 // sctlr
32300140:	ee011f10 	mcr	15, 0, r1, cr1, cr0, {0}
    dsb
    isb

#endif

	dsb	nsh
32300144:	f57ff047 	dsb	un
	isb
32300148:	f57ff06f 	isb	sy

    cmp r0, #0
3230014c:	e3500000 	cmp	r0, #0
    bne 1f
32300150:	1a000005 	bne	3230016c <devices_high+0x58>

    ldr r11, =__bss_start 
32300154:	e59fb098 	ldr	fp, [pc, #152]	@ 323001f4 <clear+0x40>
    ldr r12, =__bss_end
32300158:	e59fc098 	ldr	ip, [pc, #152]	@ 323001f8 <clear+0x44>
    bl  clear
3230015c:	eb000014 	bl	323001b4 <clear>
    .balign 4
wait_flag:
    .word 0x0
    .popsection

    ldr r1, =wait_flag
32300160:	e59f1094 	ldr	r1, [pc, #148]	@ 323001fc <clear+0x48>
    mov r2, #1
32300164:	e3a02001 	mov	r2, #1
    str r2, [r1]
32300168:	e5812000 	str	r2, [r1]
1:
    ldr r1, =wait_flag
3230016c:	e59f1088 	ldr	r1, [pc, #136]	@ 323001fc <clear+0x48>
    ldr r2, [r1]
32300170:	e5912000 	ldr	r2, [r1]
    cmp r2, #0
32300174:	e3520000 	cmp	r2, #0
    beq 1b
32300178:	0afffffb 	beq	3230016c <devices_high+0x58>

    ldr r1, =_stack_base
3230017c:	e59f107c 	ldr	r1, [pc, #124]	@ 32300200 <clear+0x4c>
    ldr r2, =STACK_SIZE
32300180:	e3a02901 	mov	r2, #16384	@ 0x4000
    add r3, r2, r2 // r3 = 2 * STACK_SIZE
32300184:	e0823002 	add	r3, r2, r2
#ifndef SINGLE_CORE
    mul r4, r3, r0 // r4 = cpuid * (2*STACK_SIZE)
32300188:	e0040093 	mul	r4, r3, r0
    add r1, r1, r4
3230018c:	e0811004 	add	r1, r1, r4
#endif
    add sp, r1, r2
32300190:	e081d002 	add	sp, r1, r2
    cps #MODE_IRQ
32300194:	f1020012 	cps	#18
    isb
32300198:	f57ff06f 	isb	sy
    add sp, r1, r3
3230019c:	e081d003 	add	sp, r1, r3
    cps #MODE_SVC
323001a0:	f1020013 	cps	#19
    isb
323001a4:	f57ff06f 	isb	sy

    // TODO: other c runtime init (eg ctors)

    bl _init
323001a8:	eb000080 	bl	323003b0 <_init>
    b _exit
323001ac:	ea000073 	b	32300380 <_exit>

323001b0 <psci_wake_up>:

.global psci_wake_up
psci_wake_up:
    b .
323001b0:	eafffffe 	b	323001b0 <psci_wake_up>

323001b4 <clear>:

 .func clear
clear:
    mov r10, #0
323001b4:	e3a0a000 	mov	sl, #0
2:
	cmp	r11, r12			
323001b8:	e15b000c 	cmp	fp, ip
	bge 1f				
323001bc:	aa000002 	bge	323001cc <clear+0x18>
	str	r10, [r11]
323001c0:	e58ba000 	str	sl, [fp]
    add r11, r11, #4
323001c4:	e28bb004 	add	fp, fp, #4
	b	2b				
323001c8:	eafffffa 	b	323001b8 <clear+0x4>
1:
	bx lr
323001cc:	e12fff1e 	bx	lr
    ldr r0, =0x76120010
323001d0:	76120010 	.word	0x76120010
    ldr r0, =FREQ
323001d4:	02625a00 	.word	0x02625a00
    ldr r0, =entry_el1
323001d8:	3230007c 	.word	0x3230007c
    ldr r1, =_exception_vector
323001dc:	32302080 	.word	0x32302080
    ldr r4, =MAIR_EL1_DFLT
323001e0:	0004ff00 	.word	0x0004ff00
    ldr r4, =(MEM_BASE)
323001e4:	32300000 	.word	0x32300000
    ldr r4, =(MEM_BASE + MEM_SIZE - 1)
323001e8:	323fffff 	.word	0x323fffff
    ldr r4, =(MEM_BASE - 1)
323001ec:	322fffff 	.word	0x322fffff
    ldr r1, =(SCTLR_RES1 | SCTLR_C | SCTLR_I | SCTLR_BR   | SCTLR_M)
323001f0:	30c71835 	.word	0x30c71835
    ldr r11, =__bss_start 
323001f4:	32314000 	.word	0x32314000
    ldr r12, =__bss_end
323001f8:	32315398 	.word	0x32315398
    ldr r1, =wait_flag
323001fc:	3230c018 	.word	0x3230c018
    ldr r1, =_stack_base
32300200:	323153a0 	.word	0x323153a0

Disassembly of section .text:

32300240 <main>:

#define SMCC64_BIT              (0x40000000)
#define SMCC32_FID_VND_HYP_SRVC (0x86000000)
#define SMCC64_FID_VND_HYP_SRVC (SMCC32_FID_VND_HYP_SRVC | SMCC64_BIT)

void main(void){
32300240:	e92d4010 	push	{r4, lr}

    printf("Bao bare-metal irq-lat WCE 2\n");
32300244:	e30b05d0 	movw	r0, #46544	@ 0xb5d0
32300248:	e3430230 	movt	r0, #12848	@ 0x3230
3230024c:	fa000ee1 	blx	32303dd8 <puts>
#ifndef __ARCH_BAO_H__
#define __ARCH_BAO_H__

static inline void bao_hypercall(unsigned long fid)
{
    asm volatile(
32300250:	e3a03003 	mov	r3, #3
32300254:	e34c3600 	movt	r3, #50688	@ 0xc600
32300258:	e1a00003 	mov	r0, r3
3230025c:	e140ea71 	hvc	3745	@ 0xea1

    while(1) {
32300260:	eafffffc 	b	32300258 <main+0x18>

32300264 <irq_set_handler>:
#include <irq.h>

irq_handler_t irq_handlers[IRQ_NUM]; 

void irq_set_handler(unsigned id, irq_handler_t handler){
    if(id < IRQ_NUM)
32300264:	e3500b01 	cmp	r0, #1024	@ 0x400
        irq_handlers[id] = handler;
32300268:	33043000 	movwcc	r3, #16384	@ 0x4000
3230026c:	33433231 	movtcc	r3, #12849	@ 0x3231
32300270:	37831100 	strcc	r1, [r3, r0, lsl #2]
}
32300274:	e12fff1e 	bx	lr

32300278 <irq_handle>:

void irq_handle(unsigned id){
    if(id < IRQ_NUM && irq_handlers[id] != NULL)
32300278:	e3500b01 	cmp	r0, #1024	@ 0x400
3230027c:	212fff1e 	bxcs	lr
32300280:	e3042000 	movw	r2, #16384	@ 0x4000
32300284:	e3432231 	movt	r2, #12849	@ 0x3231
32300288:	e7923100 	ldr	r3, [r2, r0, lsl #2]
3230028c:	e3530000 	cmp	r3, #0
32300290:	012fff1e 	bxeq	lr
        irq_handlers[id](id);
32300294:	e12fff13 	bx	r3

32300298 <_read>:
#include <fences.h>
#include <wfi.h>
#include <plat.h>

int _read(int file, char *ptr, int len)
{
32300298:	e92d4070 	push	{r4, r5, r6, lr}
    int i;
    for (i = 0; i < len; ++i)
3230029c:	e2526000 	subs	r6, r2, #0
323002a0:	da000005 	ble	323002bc <_read+0x24>
323002a4:	e2414001 	sub	r4, r1, #1
323002a8:	e0845006 	add	r5, r4, r6
    {
        ptr[i] = uart_getchar();
323002ac:	eb00035e 	bl	3230102c <uart_getchar>
323002b0:	e5e40001 	strb	r0, [r4, #1]!
    for (i = 0; i < len; ++i)
323002b4:	e1540005 	cmp	r4, r5
323002b8:	1afffffb 	bne	323002ac <_read+0x14>
    }

    return len;
}
323002bc:	e1a00006 	mov	r0, r6
323002c0:	e8bd8070 	pop	{r4, r5, r6, pc}

323002c4 <_write>:

int _write(int file, char *ptr, int len)
{
323002c4:	e92d4070 	push	{r4, r5, r6, lr}
    int i;
    for (i = 0; i < len; ++i)
323002c8:	e2526000 	subs	r6, r2, #0
323002cc:	da00000e 	ble	3230030c <_write+0x48>
323002d0:	e2414001 	sub	r4, r1, #1
323002d4:	e0845006 	add	r5, r4, r6
323002d8:	ea000002 	b	323002e8 <_write+0x24>
    {
        if (ptr[i] == '\n')
        {
            uart_putc('\r');
        }
        uart_putc(ptr[i]);
323002dc:	eb00034c 	bl	32301014 <uart_putc>
    for (i = 0; i < len; ++i)
323002e0:	e1540005 	cmp	r4, r5
323002e4:	0a000008 	beq	3230030c <_write+0x48>
        if (ptr[i] == '\n')
323002e8:	e5f40001 	ldrb	r0, [r4, #1]!
323002ec:	e350000a 	cmp	r0, #10
323002f0:	1afffff9 	bne	323002dc <_write+0x18>
            uart_putc('\r');
323002f4:	e3a0000d 	mov	r0, #13
323002f8:	eb000345 	bl	32301014 <uart_putc>
        uart_putc(ptr[i]);
323002fc:	e5d40000 	ldrb	r0, [r4]
32300300:	eb000343 	bl	32301014 <uart_putc>
    for (i = 0; i < len; ++i)
32300304:	e1540005 	cmp	r4, r5
32300308:	1afffff6 	bne	323002e8 <_write+0x24>
    }

    return len;
}
3230030c:	e1a00006 	mov	r0, r6
32300310:	e8bd8070 	pop	{r4, r5, r6, pc}

32300314 <_lseek>:

int _lseek(int file, int ptr, int dir)
{
32300314:	e92d4010 	push	{r4, lr}
    errno = ESPIPE;
32300318:	fa001246 	blx	32304c38 <__errno>
3230031c:	e1a03000 	mov	r3, r0
32300320:	e3a0201d 	mov	r2, #29
    return -1;
}
32300324:	e3e00000 	mvn	r0, #0
    errno = ESPIPE;
32300328:	e5832000 	str	r2, [r3]
}
3230032c:	e8bd8010 	pop	{r4, pc}

32300330 <_close>:

int _close(int file)
{
    return -1;
}
32300330:	e3e00000 	mvn	r0, #0
32300334:	e12fff1e 	bx	lr

32300338 <_fstat>:

int _fstat(int file, struct stat *st)
{
    st->st_mode = S_IFCHR;
32300338:	e3a03a02 	mov	r3, #8192	@ 0x2000
    return 0;
}
3230033c:	e3a00000 	mov	r0, #0
    st->st_mode = S_IFCHR;
32300340:	e5813004 	str	r3, [r1, #4]
}
32300344:	e12fff1e 	bx	lr

32300348 <_isatty>:

int _isatty(int fd)
{
32300348:	e92d4010 	push	{r4, lr}
    errno = ENOTTY;
3230034c:	fa001239 	blx	32304c38 <__errno>
32300350:	e1a03000 	mov	r3, r0
32300354:	e3a02019 	mov	r2, #25
    return 0;
}
32300358:	e3a00000 	mov	r0, #0
    errno = ENOTTY;
3230035c:	e5832000 	str	r2, [r3]
}
32300360:	e8bd8010 	pop	{r4, pc}

32300364 <_sbrk>:

void* _sbrk(int increment)
{
    extern char _heap_base;
    static char* heap_end = &_heap_base;
    char* current_heap_end = heap_end;
32300364:	e30c3008 	movw	r3, #49160	@ 0xc008
32300368:	e3433230 	movt	r3, #12848	@ 0x3230
{
3230036c:	e1a02000 	mov	r2, r0
    char* current_heap_end = heap_end;
32300370:	e5930000 	ldr	r0, [r3]
    heap_end += increment;
32300374:	e0802002 	add	r2, r0, r2
32300378:	e5832000 	str	r2, [r3]
    return current_heap_end;
}
3230037c:	e12fff1e 	bx	lr

32300380 <_exit>:
    DMB(ishld);
}

static inline void fence_ord()
{
    DMB(ish);
32300380:	f57ff05b 	dmb	ish
#ifndef WFI_H
#define WFI_H

static inline void wfi(){
    asm volatile("wfi\n\t" ::: "memory");
32300384:	e320f003 	wfi

void _exit(int return_value)
{
    fence_ord();
    while (1) {
32300388:	eafffffd 	b	32300384 <_exit+0x4>

3230038c <_getpid>:
}

int _getpid(void)
{
  return 1;
}
3230038c:	e3a00001 	mov	r0, #1
32300390:	e12fff1e 	bx	lr

32300394 <_kill>:

int _kill(int pid, int sig)
{
32300394:	e92d4010 	push	{r4, lr}
    errno = EINVAL;
32300398:	fa001226 	blx	32304c38 <__errno>
3230039c:	e1a03000 	mov	r3, r0
323003a0:	e3a02016 	mov	r2, #22
    return -1;
}
323003a4:	e3e00000 	mvn	r0, #0
    errno = EINVAL;
323003a8:	e5832000 	str	r2, [r3]
}
323003ac:	e8bd8010 	pop	{r4, pc}

323003b0 <_init>:

static bool init_done = false;
static spinlock_t init_lock = SPINLOCK_INITVAL;

__attribute__((weak))
void _init(){
323003b0:	e92d4010 	push	{r4, lr}
    uint32_t ticket;
    uint32_t next;
    uint32_t temp;

    (void)lock;
    __asm__ volatile(
323003b4:	e3054000 	movw	r4, #20480	@ 0x5000
323003b8:	e3434231 	movt	r4, #12849	@ 0x3231
323003bc:	e2840004 	add	r0, r4, #4
323003c0:	e1943e9f 	ldaex	r3, [r4]
323003c4:	e2832001 	add	r2, r3, #1
323003c8:	e1841f92 	strex	r1, r2, [r4]
323003cc:	e3510000 	cmp	r1, #0
323003d0:	1afffffa 	bne	323003c0 <_init+0x10>
323003d4:	e5902000 	ldr	r2, [r0]
323003d8:	e1530002 	cmp	r3, r2
323003dc:	0a000001 	beq	323003e8 <_init+0x38>
323003e0:	e320f002 	wfe
323003e4:	eafffffa 	b	323003d4 <_init+0x24>

    spin_lock(&init_lock);
    if(!init_done) {
323003e8:	e5d43008 	ldrb	r3, [r4, #8]
323003ec:	e3530000 	cmp	r3, #0
323003f0:	0a000008 	beq	32300418 <_init+0x68>

static inline void spin_unlock(spinlock_t* lock)
{
    uint32_t temp;

    __asm__ volatile(
323003f4:	e2842004 	add	r2, r4, #4
323003f8:	e5923000 	ldr	r3, [r2]
323003fc:	e2833001 	add	r3, r3, #1
32300400:	e182fc93 	stl	r3, [r2]
32300404:	f57ff04b 	dsb	ish
32300408:	e320f004 	sev
        plat_init();
        uart_init();
    }
    spin_unlock(&init_lock);

    arch_init();
3230040c:	eb000363 	bl	323011a0 <arch_init>

    int ret = main();
32300410:	ebffff8a 	bl	32300240 <main>
    _exit(ret);
32300414:	ebffffd9 	bl	32300380 <_exit>
        init_done = true;
32300418:	e3a03001 	mov	r3, #1
3230041c:	e5c43008 	strb	r3, [r4, #8]
        plat_init();
32300420:	eb00030d 	bl	3230105c <plat_init>
        uart_init();
32300424:	eb0002f2 	bl	32300ff4 <uart_init>
32300428:	eafffff1 	b	323003f4 <_init+0x44>

3230042c <virtio_console_mmio_init>:
    return ret;
}

bool virtio_console_mmio_init(struct virtio_console *console)
{
    if (console->mmio->MagicValue != VIRTIO_MAGIC_VALUE)
3230042c:	e5903048 	ldr	r3, [r0, #72]	@ 0x48
32300430:	e3062976 	movw	r2, #26998	@ 0x6976
32300434:	e3472472 	movt	r2, #29810	@ 0x7472
{
32300438:	e92d4010 	push	{r4, lr}
    if (console->mmio->MagicValue != VIRTIO_MAGIC_VALUE)
3230043c:	e5931000 	ldr	r1, [r3]
32300440:	e1510002 	cmp	r1, r2
32300444:	1a000056 	bne	323005a4 <virtio_console_mmio_init+0x178>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register magic value mismatch\n");
        return false;
    }

    if (console->mmio->Version != VIRTIO_VERSION_NO_LEGACY)
32300448:	e5932004 	ldr	r2, [r3, #4]
3230044c:	e3520002 	cmp	r2, #2
32300450:	1a00004b 	bne	32300584 <virtio_console_mmio_init+0x158>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register version mismatch\n");
        return false;
    }

    if (console->mmio->DeviceID != console->device_id)
32300454:	e2802f5b 	add	r2, r0, #364	@ 0x16c
32300458:	e5931008 	ldr	r1, [r3, #8]
3230045c:	e1d220b0 	ldrh	r2, [r2]
32300460:	e1510002 	cmp	r1, r2
32300464:	1a00005e 	bne	323005e4 <virtio_console_mmio_init+0x1b8>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register device ID mismatch\n");
        return false;
    }

    console->mmio->Status = RESET;
32300468:	e3a02000 	mov	r2, #0
3230046c:	e5832070 	str	r2, [r3, #112]	@ 0x70
    console->mmio->Status |= ACKNOWLEDGE;
32300470:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
32300474:	e3811001 	orr	r1, r1, #1
32300478:	e5831070 	str	r1, [r3, #112]	@ 0x70
    console->mmio->Status |= DRIVER;
3230047c:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
32300480:	e3811002 	orr	r1, r1, #2
32300484:	e5831070 	str	r1, [r3, #112]	@ 0x70

    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER))
32300488:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
3230048c:	e3510003 	cmp	r1, #3
32300490:	1a00004b 	bne	323005c4 <virtio_console_mmio_init+0x198>
        return false;
    }

    for (int i = 0; i < VIRTIO_MMIO_FEATURE_SEL_SIZE; i++)
    {
        console->mmio->DeviceFeaturesSel = i;
32300494:	e5832014 	str	r2, [r3, #20]
32300498:	e3a0c001 	mov	ip, #1
        console->mmio->DriverFeaturesSel = i;
3230049c:	e5832024 	str	r2, [r3, #36]	@ 0x24
        uint64_t acked_features = console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
        console->mmio->DriverFeatures = acked_features;
        console->negotiated_feature_bits |= (acked_features << (i * 32));
    }

    if (console->negotiated_feature_bits != VIRTIO_CONSOLE_FEATURES)
323004a0:	e5901170 	ldr	r1, [r0, #368]	@ 0x170
        uint64_t acked_features = console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
323004a4:	e593e010 	ldr	lr, [r3, #16]
        console->mmio->DriverFeatures = acked_features;
323004a8:	e5832020 	str	r2, [r3, #32]
        console->mmio->DeviceFeaturesSel = i;
323004ac:	e583c014 	str	ip, [r3, #20]
        console->mmio->DriverFeaturesSel = i;
323004b0:	e583c024 	str	ip, [r3, #36]	@ 0x24
        uint64_t acked_features = console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
323004b4:	e593e010 	ldr	lr, [r3, #16]
    if (console->negotiated_feature_bits != VIRTIO_CONSOLE_FEATURES)
323004b8:	e590e174 	ldr	lr, [r0, #372]	@ 0x174
        console->mmio->DriverFeatures = acked_features;
323004bc:	e5832020 	str	r2, [r3, #32]
    if (console->negotiated_feature_bits != VIRTIO_CONSOLE_FEATURES)
323004c0:	e191100e 	orrs	r1, r1, lr
323004c4:	1a00004e 	bne	32300604 <virtio_console_mmio_init+0x1d8>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register feature mismatch\n");
        return false;
    }

    console->config_space.cols = console->mmio->Config & 0xFFFF;
323004c8:	e5931100 	ldr	r1, [r3, #256]	@ 0x100
323004cc:	e1c014bc 	strh	r1, [r0, #76]	@ 0x4c
    console->config_space.rows = (console->mmio->Config >> 16) & 0xFFFF;
323004d0:	e5931100 	ldr	r1, [r3, #256]	@ 0x100
323004d4:	e1a01821 	lsr	r1, r1, #16
323004d8:	e1c014be 	strh	r1, [r0, #78]	@ 0x4e
    console->config_space.max_nr_ports = *((volatile uint32_t *)((uintptr_t)&console->mmio->Config + 0x4));
323004dc:	e5931104 	ldr	r1, [r3, #260]	@ 0x104
323004e0:	e5801050 	str	r1, [r0, #80]	@ 0x50
    console->config_space.emerg_wr = *((volatile uint32_t *)((uintptr_t)&console->mmio->Config + 0x8));
323004e4:	e5931108 	ldr	r1, [r3, #264]	@ 0x108
323004e8:	e5801054 	str	r1, [r0, #84]	@ 0x54

    console->mmio->Status |= FEATURES_OK;
323004ec:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
323004f0:	e3811008 	orr	r1, r1, #8
323004f4:	e5831070 	str	r1, [r3, #112]	@ 0x70

    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER | FEATURES_OK))
323004f8:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
323004fc:	e351000b 	cmp	r1, #11
32300500:	1a00002f 	bne	323005c4 <virtio_console_mmio_init+0x198>
        return false;
    }

    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
    {
        console->mmio->QueueSel = vq_id;
32300504:	e5832030 	str	r2, [r3, #48]	@ 0x30
        if (console->mmio->QueueReady != 0)
32300508:	e2822001 	add	r2, r2, #1
3230050c:	e5931044 	ldr	r1, [r3, #68]	@ 0x44
32300510:	e3510000 	cmp	r1, #0
32300514:	1a000041 	bne	32300620 <virtio_console_mmio_init+0x1f4>
            console->mmio->Status |= FAILED;
            printf("VirtIO MMIO register queue ready mismatch\n");
            return false;
        }

        int queue_num_max = console->mmio->QueueNumMax;
32300518:	e5931034 	ldr	r1, [r3, #52]	@ 0x34

        if (queue_num_max == 0)
3230051c:	e3510000 	cmp	r1, #0
32300520:	0a000045 	beq	3230063c <virtio_console_mmio_init+0x210>
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
32300524:	e3520002 	cmp	r2, #2
            return false;
        }

        console->mmio->QueueDescLow = (uint32_t)((uint64_t)console->vqs[vq_id].desc & 0xFFFFFFFF);
        console->mmio->QueueDescHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].desc >> 32) & 0xFFFFFFFF);
        console->mmio->QueueDriverLow = (uint32_t)((uint64_t)console->vqs[vq_id].avail & 0xFFFFFFFF);
32300528:	e8900006 	ldm	r0, {r1, r2}
        console->mmio->QueueDescLow = (uint32_t)((uint64_t)console->vqs[vq_id].desc & 0xFFFFFFFF);
3230052c:	e5831080 	str	r1, [r3, #128]	@ 0x80
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
32300530:	e2800024 	add	r0, r0, #36	@ 0x24
        console->mmio->QueueDescHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].desc >> 32) & 0xFFFFFFFF);
32300534:	e1a01fc1 	asr	r1, r1, #31
32300538:	e5831084 	str	r1, [r3, #132]	@ 0x84
        console->mmio->QueueDriverHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].avail >> 32) & 0xFFFFFFFF);
        console->mmio->QueueDeviceLow= (uint32_t)((uint64_t)console->vqs[vq_id].used & 0xFFFFFFFF);
3230053c:	e510101c 	ldr	r1, [r0, #-28]	@ 0xffffffe4
        console->mmio->QueueDriverLow = (uint32_t)((uint64_t)console->vqs[vq_id].avail & 0xFFFFFFFF);
32300540:	e5832090 	str	r2, [r3, #144]	@ 0x90
        console->mmio->QueueDriverHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].avail >> 32) & 0xFFFFFFFF);
32300544:	e1a02fc2 	asr	r2, r2, #31
32300548:	e5832094 	str	r2, [r3, #148]	@ 0x94
        console->mmio->QueueDeviceLow= (uint32_t)((uint64_t)console->vqs[vq_id].used & 0xFFFFFFFF);
3230054c:	e3a02001 	mov	r2, #1
32300550:	e58310a0 	str	r1, [r3, #160]	@ 0xa0
        console->mmio->QueueDeviceHigh = (uint32_t)(((uint64_t)console->vqs[vq_id].used >> 32) & 0xFFFFFFFF);
32300554:	e1a01fc1 	asr	r1, r1, #31
32300558:	e58310a4 	str	r1, [r3, #164]	@ 0xa4

        console->mmio->QueueReady = 1;
3230055c:	e583c044 	str	ip, [r3, #68]	@ 0x44
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
32300560:	1affffe7 	bne	32300504 <virtio_console_mmio_init+0xd8>
    }

    console->mmio->Status |= DRIVER_OK;
32300564:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
32300568:	e3811004 	orr	r1, r1, #4
3230056c:	e5831070 	str	r1, [r3, #112]	@ 0x70
    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER | FEATURES_OK | DRIVER_OK))
32300570:	e5931070 	ldr	r1, [r3, #112]	@ 0x70
32300574:	e351000f 	cmp	r1, #15
32300578:	1a000011 	bne	323005c4 <virtio_console_mmio_init+0x198>
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register status mismatch\n");
        return false;
    }

    return true;
3230057c:	e1a00002 	mov	r0, r2
}
32300580:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
32300584:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register version mismatch\n");
32300588:	e30b061c 	movw	r0, #46620	@ 0xb61c
3230058c:	e3430230 	movt	r0, #12848	@ 0x3230
        console->mmio->Status |= FAILED;
32300590:	e3822080 	orr	r2, r2, #128	@ 0x80
32300594:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register version mismatch\n");
32300598:	fa000e0e 	blx	32303dd8 <puts>
        return false;
3230059c:	e3a00000 	mov	r0, #0
323005a0:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
323005a4:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register magic value mismatch\n");
323005a8:	e30b05f0 	movw	r0, #46576	@ 0xb5f0
323005ac:	e3430230 	movt	r0, #12848	@ 0x3230
        console->mmio->Status |= FAILED;
323005b0:	e3822080 	orr	r2, r2, #128	@ 0x80
323005b4:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register magic value mismatch\n");
323005b8:	fa000e06 	blx	32303dd8 <puts>
        return false;
323005bc:	e3a00000 	mov	r0, #0
323005c0:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
323005c4:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register status mismatch\n");
323005c8:	e30b066c 	movw	r0, #46700	@ 0xb66c
323005cc:	e3430230 	movt	r0, #12848	@ 0x3230
        console->mmio->Status |= FAILED;
323005d0:	e3822080 	orr	r2, r2, #128	@ 0x80
323005d4:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register status mismatch\n");
323005d8:	fa000dfe 	blx	32303dd8 <puts>
        return false;
323005dc:	e3a00000 	mov	r0, #0
323005e0:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
323005e4:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register device ID mismatch\n");
323005e8:	e30b0644 	movw	r0, #46660	@ 0xb644
323005ec:	e3430230 	movt	r0, #12848	@ 0x3230
        console->mmio->Status |= FAILED;
323005f0:	e3822080 	orr	r2, r2, #128	@ 0x80
323005f4:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register device ID mismatch\n");
323005f8:	fa000df6 	blx	32303dd8 <puts>
        return false;
323005fc:	e3a00000 	mov	r0, #0
32300600:	e8bd8010 	pop	{r4, pc}
        console->mmio->Status |= FAILED;
32300604:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register feature mismatch\n");
32300608:	e30b0694 	movw	r0, #46740	@ 0xb694
3230060c:	e3430230 	movt	r0, #12848	@ 0x3230
        console->mmio->Status |= FAILED;
32300610:	e3822080 	orr	r2, r2, #128	@ 0x80
32300614:	e5832070 	str	r2, [r3, #112]	@ 0x70
        printf("VirtIO MMIO register feature mismatch\n");
32300618:	fa000dee 	blx	32303dd8 <puts>
        return false;
3230061c:	eaffffde 	b	3230059c <virtio_console_mmio_init+0x170>
            console->mmio->Status |= FAILED;
32300620:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
            printf("VirtIO MMIO register queue ready mismatch\n");
32300624:	e30b06bc 	movw	r0, #46780	@ 0xb6bc
32300628:	e3430230 	movt	r0, #12848	@ 0x3230
            console->mmio->Status |= FAILED;
3230062c:	e3822080 	orr	r2, r2, #128	@ 0x80
32300630:	e5832070 	str	r2, [r3, #112]	@ 0x70
            printf("VirtIO MMIO register queue ready mismatch\n");
32300634:	fa000de7 	blx	32303dd8 <puts>
            return false;
32300638:	eaffffd7 	b	3230059c <virtio_console_mmio_init+0x170>
            console->mmio->Status |= FAILED;
3230063c:	e5932070 	ldr	r2, [r3, #112]	@ 0x70
            printf("VirtIO MMIO register queue number max mismatch\n");
32300640:	e30b06e8 	movw	r0, #46824	@ 0xb6e8
32300644:	e3430230 	movt	r0, #12848	@ 0x3230
            console->mmio->Status |= FAILED;
32300648:	e3822080 	orr	r2, r2, #128	@ 0x80
3230064c:	e5832070 	str	r2, [r3, #112]	@ 0x70
            printf("VirtIO MMIO register queue number max mismatch\n");
32300650:	fa000de0 	blx	32303dd8 <puts>
            return false;
32300654:	eaffffd0 	b	3230059c <virtio_console_mmio_init+0x170>

32300658 <virtio_console_init>:
{
32300658:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
3230065c:	e1a04000 	mov	r4, r0
    console->device_id = VIRTIO_CONSOLE_DEVICE_ID;
32300660:	e280ef5b 	add	lr, r0, #364	@ 0x16c
    console->negotiated_feature_bits = 0;
32300664:	e284ce17 	add	ip, r4, #368	@ 0x170
32300668:	e1a03001 	mov	r3, r1
{
3230066c:	e24dd014 	sub	sp, sp, #20
    console->ready = false;
32300670:	e3a00000 	mov	r0, #0
    console->device_id = VIRTIO_CONSOLE_DEVICE_ID;
32300674:	e3a05003 	mov	r5, #3
    console->ready = false;
32300678:	e5c40178 	strb	r0, [r4, #376]	@ 0x178
    console->negotiated_feature_bits = 0;
3230067c:	e3a06000 	mov	r6, #0
    console->device_id = VIRTIO_CONSOLE_DEVICE_ID;
32300680:	e1ce50b0 	strh	r5, [lr]
    console->negotiated_feature_bits = 0;
32300684:	e3a07000 	mov	r7, #0
    console->mmio = (volatile struct virtio_mmio_reg *)mmio_base;
32300688:	e5842048 	str	r2, [r4, #72]	@ 0x48
 */
static inline void virtq_init(struct virtq *vq, uint16_t queue_index, char* vq_base_addr)
{
    /* Initialize the descriptor ring */
    vq->desc = (volatile struct virtq_desc *)VIRTQ_DESC_ADDR(vq_base_addr);
    for (int i = 0; i < VIRTQ_SIZE; i++)
3230068c:	e300e401 	movw	lr, #1025	@ 0x401
    console->negotiated_feature_bits = 0;
32300690:	e1cc60f0 	strd	r6, [ip]
    vq->desc = (volatile struct virtq_desc *)VIRTQ_DESC_ADDR(vq_base_addr);
32300694:	e3a02001 	mov	r2, #1
    console->rx_buffer[0] = '\0';
32300698:	e5c40058 	strb	r0, [r4, #88]	@ 0x58
    console->rx_buffer_pos = 0;
3230069c:	e5840158 	str	r0, [r4, #344]	@ 0x158
    console->rx_lock = SPINLOCK_INITVAL;
323006a0:	e584015c 	str	r0, [r4, #348]	@ 0x15c
323006a4:	e5840160 	str	r0, [r4, #352]	@ 0x160
    console->tx_lock = SPINLOCK_INITVAL;
323006a8:	e5840164 	str	r0, [r4, #356]	@ 0x164
323006ac:	e5840168 	str	r0, [r4, #360]	@ 0x168
323006b0:	e5841000 	str	r1, [r4]
    {
        vq->desc[i].addr = 0;
323006b4:	e6ffc072 	uxth	ip, r2
    for (int i = 0; i < VIRTQ_SIZE; i++)
323006b8:	e2822001 	add	r2, r2, #1
        vq->desc[i].addr = 0;
323006bc:	e1c360f0 	strd	r6, [r3]
    for (int i = 0; i < VIRTQ_SIZE; i++)
323006c0:	e152000e 	cmp	r2, lr
        vq->desc[i].len = 0;
323006c4:	e5830008 	str	r0, [r3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++)
323006c8:	e2833010 	add	r3, r3, #16
        vq->desc[i].flags = 0;
323006cc:	e14300b4 	strh	r0, [r3, #-4]
        vq->desc[i].next = i + 1;
323006d0:	e143c0b2 	strh	ip, [r3, #-2]
    for (int i = 0; i < VIRTQ_SIZE; i++)
323006d4:	1afffff6 	bne	323006b4 <virtio_console_init+0x5c>
    vq->desc[VIRTQ_SIZE - 1].next = 0;
    vq->desc_next_free = 0;
    vq->desc_num_free = VIRTQ_SIZE;

    /* Initialize the available ring */
    vq->avail = (volatile struct virtq_avail *)VIRTQ_AVAIL_ADDR(vq_base_addr);
323006d8:	e281c901 	add	ip, r1, #16384	@ 0x4000
    vq->desc[VIRTQ_SIZE - 1].next = 0;
323006dc:	e2813dff 	add	r3, r1, #16320	@ 0x3fc0
    vq->desc_next_free = 0;
323006e0:	e3a02301 	mov	r2, #67108864	@ 0x4000000
    vq->desc[VIRTQ_SIZE - 1].next = 0;
323006e4:	e1c303be 	strh	r0, [r3, #62]	@ 0x3e
    vq->avail->flags = 0;
    vq->avail->idx = 0;
    for (int i = 0; i < VIRTQ_SIZE; i++)
323006e8:	e3a03000 	mov	r3, #0
    vq->desc_next_free = 0;
323006ec:	e584200e 	str	r2, [r4, #14]
    vq->avail = (volatile struct virtq_avail *)VIRTQ_AVAIL_ADDR(vq_base_addr);
323006f0:	e584c004 	str	ip, [r4, #4]
    vq->avail->flags = 0;
323006f4:	e1cc00b0 	strh	r0, [ip]
    vq->avail->idx = 0;
323006f8:	e1cc00b2 	strh	r0, [ip, #2]
    {
        vq->avail->ring[i] = 0;
323006fc:	e1a00003 	mov	r0, r3
32300700:	e08c2083 	add	r2, ip, r3, lsl #1
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300704:	e2833001 	add	r3, r3, #1
32300708:	e3530b01 	cmp	r3, #1024	@ 0x400
        vq->avail->ring[i] = 0;
3230070c:	e1c200b4 	strh	r0, [r2, #4]
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300710:	1afffffa 	bne	32300700 <virtio_console_init+0xa8>
    }
    vq->avail_last_idx = 0;

    /* Initialize the used ring */
    vq->used = (volatile struct virtq_used *)VIRTQ_USED_ADDR(vq_base_addr);
32300714:	e2813a05 	add	r3, r1, #20480	@ 0x5000
    vq->avail_last_idx = 0;
32300718:	e1c401b2 	strh	r0, [r4, #18]
    vq->used = (volatile struct virtq_used *)VIRTQ_USED_ADDR(vq_base_addr);
3230071c:	e5843008 	str	r3, [r4, #8]
    vq->used->flags = 0;
    vq->used->idx = 0;
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300720:	e3a02000 	mov	r2, #0
    vq->used->flags = 0;
32300724:	e1c300b0 	strh	r0, [r3]
    vq->used->idx = 0;
32300728:	e1c300b2 	strh	r0, [r3, #2]
    {
        vq->used->ring[i].id = 0;
3230072c:	e1a00002 	mov	r0, r2
32300730:	e0813182 	add	r3, r1, r2, lsl #3
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300734:	e2822001 	add	r2, r2, #1
        vq->used->ring[i].id = 0;
32300738:	e2833a05 	add	r3, r3, #20480	@ 0x5000
    for (int i = 0; i < VIRTQ_SIZE; i++)
3230073c:	e3520b01 	cmp	r2, #1024	@ 0x400
        vq->used->ring[i].id = 0;
32300740:	e5830004 	str	r0, [r3, #4]
        vq->used->ring[i].len = 0;
32300744:	e5830008 	str	r0, [r3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300748:	1afffff8 	bne	32300730 <virtio_console_init+0xd8>
    vq->last_used_idx = 0;

    vq->queue_index = queue_index;

    /* Initialize the memory pool */
    virtio_memory_pool_init(&vq->pool, (char *)VIRTQ_MEMORY_POOL_ADDR(vq_base_addr), VIRTQ_MEMORY_POOL_SIZE);
3230074c:	e2812902 	add	r2, r1, #32768	@ 0x8000
    vq->last_used_idx = 0;
32300750:	e1c401b4 	strh	r0, [r4, #20]
    vq->queue_index = queue_index;
32300754:	e1c400bc 	strh	r0, [r4, #12]
 * @param size Length of the memory to allocate
 */
static inline void virtio_memory_pool_init(struct virtio_memory_pool* pool, char* base, unsigned long size)
{
    pool->base = base;
    pool->size = size;
32300758:	e3a03801 	mov	r3, #65536	@ 0x10000
    pool->offset = 0;
3230075c:	e5840020 	str	r0, [r4, #32]
    pool->size = size;
32300760:	e584301c 	str	r3, [r4, #28]

    /* Mark all memory as free */
    for (unsigned long i = 0; i < size; i++) {
32300764:	e3a03001 	mov	r3, #1
    pool->base = base;
32300768:	e5842018 	str	r2, [r4, #24]
        pool->base[i] = 0;
3230076c:	e5c20000 	strb	r0, [r2]
32300770:	e3a00000 	mov	r0, #0
32300774:	e5942018 	ldr	r2, [r4, #24]
32300778:	e7c20003 	strb	r0, [r2, r3]
    for (unsigned long i = 0; i < size; i++) {
3230077c:	e2833001 	add	r3, r3, #1
32300780:	e3530801 	cmp	r3, #65536	@ 0x10000
32300784:	1afffffa 	bne	32300774 <virtio_console_init+0x11c>
    virtq_init(&console->vqs[VIRTIO_CONSOLE_TX_VQ_IDX], VIRTIO_CONSOLE_TX_VQ_IDX, shmem_base + VIRTQ_SIZE_TOTAL);
32300788:	e2810906 	add	r0, r1, #98304	@ 0x18000
    vq->desc = (volatile struct virtq_desc *)VIRTQ_DESC_ADDR(vq_base_addr);
3230078c:	e3a02001 	mov	r2, #1
32300790:	e1a03000 	mov	r3, r0
32300794:	e5840024 	str	r0, [r4, #36]	@ 0x24
        vq->desc[i].addr = 0;
32300798:	e3a06000 	mov	r6, #0
3230079c:	e3a07000 	mov	r7, #0
        vq->desc[i].len = 0;
323007a0:	e3a00000 	mov	r0, #0
    for (int i = 0; i < VIRTQ_SIZE; i++)
323007a4:	e300e401 	movw	lr, #1025	@ 0x401
        vq->desc[i].addr = 0;
323007a8:	e6ffc072 	uxth	ip, r2
    for (int i = 0; i < VIRTQ_SIZE; i++)
323007ac:	e2822001 	add	r2, r2, #1
        vq->desc[i].addr = 0;
323007b0:	e1c360f0 	strd	r6, [r3]
    for (int i = 0; i < VIRTQ_SIZE; i++)
323007b4:	e152000e 	cmp	r2, lr
        vq->desc[i].len = 0;
323007b8:	e5830008 	str	r0, [r3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++)
323007bc:	e2833010 	add	r3, r3, #16
        vq->desc[i].flags = 0;
323007c0:	e14300b4 	strh	r0, [r3, #-4]
        vq->desc[i].next = i + 1;
323007c4:	e143c0b2 	strh	ip, [r3, #-2]
    for (int i = 0; i < VIRTQ_SIZE; i++)
323007c8:	1afffff6 	bne	323007a8 <virtio_console_init+0x150>
    vq->desc[VIRTQ_SIZE - 1].next = 0;
323007cc:	e2813b6f 	add	r3, r1, #113664	@ 0x1bc00
    vq->avail = (volatile struct virtq_avail *)VIRTQ_AVAIL_ADDR(vq_base_addr);
323007d0:	e281c907 	add	ip, r1, #114688	@ 0x1c000
    vq->desc[VIRTQ_SIZE - 1].next = 0;
323007d4:	e2833e3f 	add	r3, r3, #1008	@ 0x3f0
    vq->desc_next_free = 0;
323007d8:	e3a02301 	mov	r2, #67108864	@ 0x4000000
    vq->desc[VIRTQ_SIZE - 1].next = 0;
323007dc:	e1c300be 	strh	r0, [r3, #14]
    for (int i = 0; i < VIRTQ_SIZE; i++)
323007e0:	e3a03000 	mov	r3, #0
    vq->desc_next_free = 0;
323007e4:	e5842032 	str	r2, [r4, #50]	@ 0x32
    vq->avail = (volatile struct virtq_avail *)VIRTQ_AVAIL_ADDR(vq_base_addr);
323007e8:	e584c028 	str	ip, [r4, #40]	@ 0x28
    vq->avail->flags = 0;
323007ec:	e1cc00b0 	strh	r0, [ip]
    vq->avail->idx = 0;
323007f0:	e1cc00b2 	strh	r0, [ip, #2]
        vq->avail->ring[i] = 0;
323007f4:	e1a00003 	mov	r0, r3
323007f8:	e08c2083 	add	r2, ip, r3, lsl #1
    for (int i = 0; i < VIRTQ_SIZE; i++)
323007fc:	e2833001 	add	r3, r3, #1
32300800:	e3530b01 	cmp	r3, #1024	@ 0x400
        vq->avail->ring[i] = 0;
32300804:	e1c200b4 	strh	r0, [r2, #4]
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300808:	1afffffa 	bne	323007f8 <virtio_console_init+0x1a0>
    vq->used = (volatile struct virtq_used *)VIRTQ_USED_ADDR(vq_base_addr);
3230080c:	e2813a1d 	add	r3, r1, #118784	@ 0x1d000
    vq->avail_last_idx = 0;
32300810:	e1c403b6 	strh	r0, [r4, #54]	@ 0x36
    vq->used = (volatile struct virtq_used *)VIRTQ_USED_ADDR(vq_base_addr);
32300814:	e584302c 	str	r3, [r4, #44]	@ 0x2c
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300818:	e3a02000 	mov	r2, #0
    vq->used->flags = 0;
3230081c:	e1c300b0 	strh	r0, [r3]
    vq->used->idx = 0;
32300820:	e1c300b2 	strh	r0, [r3, #2]
        vq->used->ring[i].id = 0;
32300824:	e1a00002 	mov	r0, r2
32300828:	e0813182 	add	r3, r1, r2, lsl #3
    for (int i = 0; i < VIRTQ_SIZE; i++)
3230082c:	e2822001 	add	r2, r2, #1
        vq->used->ring[i].id = 0;
32300830:	e2833a1d 	add	r3, r3, #118784	@ 0x1d000
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300834:	e3520b01 	cmp	r2, #1024	@ 0x400
        vq->used->ring[i].id = 0;
32300838:	e5830004 	str	r0, [r3, #4]
        vq->used->ring[i].len = 0;
3230083c:	e5830008 	str	r0, [r3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++)
32300840:	1afffff8 	bne	32300828 <virtio_console_init+0x1d0>
    virtio_memory_pool_init(&vq->pool, (char *)VIRTQ_MEMORY_POOL_ADDR(vq_base_addr), VIRTQ_MEMORY_POOL_SIZE);
32300844:	e2811802 	add	r1, r1, #131072	@ 0x20000
    vq->queue_index = queue_index;
32300848:	e3a03001 	mov	r3, #1
    vq->last_used_idx = 0;
3230084c:	e1c403b8 	strh	r0, [r4, #56]	@ 0x38
    pool->size = size;
32300850:	e3a02801 	mov	r2, #65536	@ 0x10000
    vq->queue_index = queue_index;
32300854:	e1c433b0 	strh	r3, [r4, #48]	@ 0x30
        pool->base[i] = 0;
32300858:	e3a0c000 	mov	ip, #0
    pool->base = base;
3230085c:	e584103c 	str	r1, [r4, #60]	@ 0x3c
    pool->offset = 0;
32300860:	e5840044 	str	r0, [r4, #68]	@ 0x44
    pool->size = size;
32300864:	e5842040 	str	r2, [r4, #64]	@ 0x40
        pool->base[i] = 0;
32300868:	e5c10000 	strb	r0, [r1]
3230086c:	e594203c 	ldr	r2, [r4, #60]	@ 0x3c
32300870:	e7c2c003 	strb	ip, [r2, r3]
    for (unsigned long i = 0; i < size; i++) {
32300874:	e2833001 	add	r3, r3, #1
32300878:	e3530801 	cmp	r3, #65536	@ 0x10000
3230087c:	1afffffa 	bne	3230086c <virtio_console_init+0x214>
 * @param vq VirtIO virtqueue
 * @return true if there are free slots, false otherwise
 */
static inline bool virtq_has_free_slots(struct virtq *vq)
{
    return vq->desc_num_free != 0;
32300880:	e1d431b0 	ldrh	r3, [r4, #16]
    while (virtq_has_free_slots(&console->vqs[VIRTIO_CONSOLE_RX_VQ_IDX]))
32300884:	e3530000 	cmp	r3, #0
32300888:	0a00004e 	beq	323009c8 <virtio_console_init+0x370>
 * @return Returns the next free descriptor index
 */
static inline uint16_t virtq_get_free_desc_id(struct virtq *vq)
{
    assert(virtq_has_free_slots(vq));
    uint16_t idx = vq->desc_next_free;
3230088c:	e1d480be 	ldrh	r8, [r4, #14]
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
    vq->desc_num_free--;
32300890:	e2433001 	sub	r3, r3, #1
 * @param alloc_size Size of the memory to allocate
 * @return Returns a pointer to the allocated memory, or NULL if the allocation failed
 */
static inline char* virtio_memory_pool_alloc(struct virtio_memory_pool* pool, unsigned long alloc_size) {
    /** Check if the requested allocation size is larger than the pool size */
    if (alloc_size > pool->size) {
32300894:	e594201c 	ldr	r2, [r4, #28]
    return &vq->desc[id % VIRTQ_SIZE];
32300898:	e5940000 	ldr	r0, [r4]
    vq->desc_num_free--;
3230089c:	e6ffc073 	uxth	ip, r3
323008a0:	e352003f 	cmp	r2, #63	@ 0x3f
323008a4:	e58d2004 	str	r2, [sp, #4]
    return &vq->desc[id % VIRTQ_SIZE];
323008a8:	e7e92058 	ubfx	r2, r8, #0, #10
 */
static inline void virtq_desc_init(volatile struct virtq_desc *desc, uint64_t addr, uint32_t len)
{
    desc->addr = addr;
    desc->len = len;
    desc->flags = 0;
323008ac:	83a09000 	movhi	r9, #0
    return &vq->desc[id % VIRTQ_SIZE];
323008b0:	e0802202 	add	r2, r0, r2, lsl #4
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
323008b4:	e1d210be 	ldrh	r1, [r2, #14]
    vq->desc_num_free--;
323008b8:	e1c4c1b0 	strh	ip, [r4, #16]
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
323008bc:	e6ff1071 	uxth	r1, r1
323008c0:	e1c410be 	strh	r1, [r4, #14]
323008c4:	9a00003c 	bls	323009bc <virtio_console_init+0x364>
        return NULL;
    }

    /** Check if there is enough space from the current offset to the end of the pool */
    if (pool->offset + alloc_size <= pool->size) {
323008c8:	e5946020 	ldr	r6, [r4, #32]
323008cc:	e59d3004 	ldr	r3, [sp, #4]
323008d0:	e2867040 	add	r7, r6, #64	@ 0x40
323008d4:	e1530007 	cmp	r3, r7
323008d8:	3a000040 	bcc	323009e0 <virtio_console_init+0x388>
        /* Get the pointer to the possible allocated memory */
        char *ptr = pool->base + pool->offset;
323008dc:	e594e018 	ldr	lr, [r4, #24]

        /* Check if the memory is already allocated */
        for (unsigned long i = 0; i < alloc_size; i++) {
323008e0:	e286503f 	add	r5, r6, #63	@ 0x3f
323008e4:	e2463001 	sub	r3, r6, #1
323008e8:	e1cda0f8 	strd	sl, [sp, #8]
323008ec:	e08e5005 	add	r5, lr, r5
323008f0:	e1a0b004 	mov	fp, r4
323008f4:	e08e3003 	add	r3, lr, r3
323008f8:	e1a04008 	mov	r4, r8
323008fc:	e1a08001 	mov	r8, r1
32300900:	e1a01002 	mov	r1, r2
32300904:	e1a02005 	mov	r2, r5
            if (pool->base[pool->offset + i] != 0) {
32300908:	e5f35001 	ldrb	r5, [r3, #1]!
3230090c:	e3550000 	cmp	r5, #0
32300910:	1a000028 	bne	323009b8 <virtio_console_init+0x360>
        for (unsigned long i = 0; i < alloc_size; i++) {
32300914:	e1530002 	cmp	r3, r2
32300918:	1afffffa 	bne	32300908 <virtio_console_init+0x2b0>
        char *ptr = pool->base + pool->offset;
3230091c:	e1a02001 	mov	r2, r1
32300920:	e08ee006 	add	lr, lr, r6
32300924:	e1a01008 	mov	r1, r8
32300928:	e1a08004 	mov	r8, r4
3230092c:	e1a0400b 	mov	r4, fp
        if(io_buffer == NULL) {
32300930:	e35e0000 	cmp	lr, #0
                return NULL;
            }
        }

        /* Increment the offset for the next allocation */
        pool->offset += alloc_size;
32300934:	e5847020 	str	r7, [r4, #32]
32300938:	0a00001f 	beq	323009bc <virtio_console_init+0x364>
        virtq_desc_init(desc, (uint64_t)io_buffer, VIRTIO_CONSOLE_RX_BUFFER_SIZE);
3230093c:	e1a0a00e 	mov	sl, lr
32300940:	e1a0bfce 	asr	fp, lr, #31
    desc->len = len;
32300944:	e3a03040 	mov	r3, #64	@ 0x40
    desc->addr = addr;
32300948:	e1c2a0f0 	strd	sl, [r2]
    desc->len = len;
3230094c:	e5823008 	str	r3, [r2, #8]
    while (virtq_has_free_slots(&console->vqs[VIRTIO_CONSOLE_RX_VQ_IDX]))
32300950:	e35c0000 	cmp	ip, #0
    desc->flags = 0;
32300954:	e1c290bc 	strh	r9, [r2, #12]
    desc->next = 0;
32300958:	e1c290be 	strh	r9, [r2, #14]
 * @param vq VirtIO virtqueue
 * @param id Descriptor index
 */
static inline void virtq_add_avail_buf(struct virtq *vq, uint16_t id)
{
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
3230095c:	e594e004 	ldr	lr, [r4, #4]
    desc->flags |= VIRTQ_DESC_F_WRITE;
32300960:	e1d230bc 	ldrh	r3, [r2, #12]
32300964:	e3833002 	orr	r3, r3, #2
32300968:	e1c230bc 	strh	r3, [r2, #12]
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
3230096c:	e1de30b2 	ldrh	r3, [lr, #2]
32300970:	e7e93053 	ubfx	r3, r3, #0, #10
32300974:	e08e3083 	add	r3, lr, r3, lsl #1
32300978:	e1c380b4 	strh	r8, [r3, #4]
    vq->avail->idx++;
3230097c:	e1de30b2 	ldrh	r3, [lr, #2]
32300980:	e2833001 	add	r3, r3, #1
32300984:	e6ff3073 	uxth	r3, r3
32300988:	e1ce30b2 	strh	r3, [lr, #2]
3230098c:	0a00000d 	beq	323009c8 <virtio_console_init+0x370>
    return &vq->desc[id % VIRTQ_SIZE];
32300990:	e7e92051 	ubfx	r2, r1, #0, #10
    vq->desc_num_free--;
32300994:	e1a08001 	mov	r8, r1
32300998:	e24cc001 	sub	ip, ip, #1
    return &vq->desc[id % VIRTQ_SIZE];
3230099c:	e0802202 	add	r2, r0, r2, lsl #4
    vq->desc_num_free--;
323009a0:	e6ffc07c 	uxth	ip, ip
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
323009a4:	e1d210be 	ldrh	r1, [r2, #14]
    vq->desc_num_free--;
323009a8:	e1c4c1b0 	strh	ip, [r4, #16]
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
323009ac:	e6ff1071 	uxth	r1, r1
323009b0:	e1c410be 	strh	r1, [r4, #14]
    if (alloc_size > pool->size) {
323009b4:	eaffffc3 	b	323008c8 <virtio_console_init+0x270>
323009b8:	e1a0400b 	mov	r4, fp
            printf("Failed to allocate memory for I/O buffer\n");
323009bc:	e30b0718 	movw	r0, #46872	@ 0xb718
323009c0:	e3430230 	movt	r0, #12848	@ 0x3230
323009c4:	fa000d03 	blx	32303dd8 <puts>
    ret = virtio_console_mmio_init(console);
323009c8:	e1a00004 	mov	r0, r4
323009cc:	ebfffe96 	bl	3230042c <virtio_console_mmio_init>
    console->ready = true;
323009d0:	e3a03001 	mov	r3, #1
323009d4:	e5c43178 	strb	r3, [r4, #376]	@ 0x178
}
323009d8:	e28dd014 	add	sp, sp, #20
323009dc:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
        /* Return the pointer to the allocated memory */
        return ptr;
    }

    /** If we reached the end of the pool, wrap around (circular buffer behavior) */
    if (alloc_size <= pool->offset) {
323009e0:	e356003f 	cmp	r6, #63	@ 0x3f
323009e4:	9afffff4 	bls	323009bc <virtio_console_init+0x364>
        /* Get the pointer to the possible allocated memory */
        char *ptr = pool->base;
323009e8:	e594e018 	ldr	lr, [r4, #24]

        /* Check if the memory is already allocated */
        for (unsigned long i = 0; i < alloc_size; i++) {
323009ec:	e24e3001 	sub	r3, lr, #1
323009f0:	e28e603f 	add	r6, lr, #63	@ 0x3f
            if (pool->base[i] != 0) {
323009f4:	e5f35001 	ldrb	r5, [r3, #1]!
323009f8:	e3550000 	cmp	r5, #0
323009fc:	1affffee 	bne	323009bc <virtio_console_init+0x364>
        for (unsigned long i = 0; i < alloc_size; i++) {
32300a00:	e1530006 	cmp	r3, r6
32300a04:	1afffffa 	bne	323009f4 <virtio_console_init+0x39c>
32300a08:	e3a07040 	mov	r7, #64	@ 0x40
32300a0c:	eaffffc7 	b	32300930 <virtio_console_init+0x2d8>

32300a10 <virtio_console_transmit>:
{
    return console->rx_buffer_pos > 1;
}

void virtio_console_transmit(struct virtio_console *console, char *const data)
{
32300a10:	e92d4ff8 	push	{r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
    int data_len = strlen(data);

    if (!console->ready) {
32300a14:	e5d03178 	ldrb	r3, [r0, #376]	@ 0x178
32300a18:	e3530000 	cmp	r3, #0
32300a1c:	0a000060 	beq	32300ba4 <virtio_console_transmit+0x194>
32300a20:	e1a04000 	mov	r4, r0
    int data_len = strlen(data);
32300a24:	e1a00001 	mov	r0, r1
32300a28:	e1a0b001 	mov	fp, r1
32300a2c:	fa001303 	blx	32305640 <strlen>
        printf("VirtIO console device is not ready\n");
        return;
    }

    if (data == NULL || data_len == 0) {
32300a30:	e2505000 	subs	r5, r0, #0
32300a34:	0a00004a 	beq	32300b64 <virtio_console_transmit+0x154>
        printf("No data to transmit\n");
        return;
    }

    spin_lock(&console->tx_lock);
32300a38:	e2846f59 	add	r6, r4, #356	@ 0x164
    __asm__ volatile(
32300a3c:	e2860004 	add	r0, r6, #4
32300a40:	e1963e9f 	ldaex	r3, [r6]
32300a44:	e2832001 	add	r2, r3, #1
32300a48:	e1861f92 	strex	r1, r2, [r6]
32300a4c:	e3510000 	cmp	r1, #0
32300a50:	1afffffa 	bne	32300a40 <virtio_console_transmit+0x30>
32300a54:	e5902000 	ldr	r2, [r0]
32300a58:	e1530002 	cmp	r3, r2
32300a5c:	0a000001 	beq	32300a68 <virtio_console_transmit+0x58>
32300a60:	e320f002 	wfe
32300a64:	eafffffa 	b	32300a54 <virtio_console_transmit+0x44>
    return vq->desc_num_free != 0;
32300a68:	e1d433b4 	ldrh	r3, [r4, #52]	@ 0x34
    assert(virtq_has_free_slots(vq));
32300a6c:	e3530000 	cmp	r3, #0
32300a70:	0a000059 	beq	32300bdc <virtio_console_transmit+0x1cc>
    uint16_t idx = vq->desc_next_free;
32300a74:	e1d493b2 	ldrh	r9, [r4, #50]	@ 0x32
    vq->desc_num_free--;
32300a78:	e2433001 	sub	r3, r3, #1
    return &vq->desc[id % VIRTQ_SIZE];
32300a7c:	e594a024 	ldr	sl, [r4, #36]	@ 0x24
    if (alloc_size > pool->size) {
32300a80:	e5942040 	ldr	r2, [r4, #64]	@ 0x40
32300a84:	e7e98059 	ubfx	r8, r9, #0, #10
32300a88:	e1550002 	cmp	r5, r2
32300a8c:	e1a08208 	lsl	r8, r8, #4
32300a90:	e08a7008 	add	r7, sl, r8
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
32300a94:	e1d710be 	ldrh	r1, [r7, #14]
32300a98:	e1c413b2 	strh	r1, [r4, #50]	@ 0x32
    vq->desc_num_free--;
32300a9c:	e1c433b4 	strh	r3, [r4, #52]	@ 0x34
32300aa0:	8a000043 	bhi	32300bb4 <virtio_console_transmit+0x1a4>
    if (pool->offset + alloc_size <= pool->size) {
32300aa4:	e5943044 	ldr	r3, [r4, #68]	@ 0x44
32300aa8:	e085c003 	add	ip, r5, r3
32300aac:	e152000c 	cmp	r2, ip
32300ab0:	3a00002f 	bcc	32300b74 <virtio_console_transmit+0x164>
        for (unsigned long i = 0; i < alloc_size; i++) {
32300ab4:	e594203c 	ldr	r2, [r4, #60]	@ 0x3c
32300ab8:	e0822003 	add	r2, r2, r3
32300abc:	e1a03002 	mov	r3, r2
32300ac0:	e0850002 	add	r0, r5, r2
            if (pool->base[pool->offset + i] != 0) {
32300ac4:	e4d31001 	ldrb	r1, [r3], #1
32300ac8:	e3510000 	cmp	r1, #0
32300acc:	1a000038 	bne	32300bb4 <virtio_console_transmit+0x1a4>
        for (unsigned long i = 0; i < alloc_size; i++) {
32300ad0:	e1530000 	cmp	r3, r0
32300ad4:	1afffffa 	bne	32300ac4 <virtio_console_transmit+0xb4>
    /* Get the descriptor */
    volatile struct virtq_desc *desc = virtq_get_desc_by_id(vq, desc_id);

    /* Allocate memory for the I/O buffer from the memory pool */
    char *const io_buffer = virtio_memory_pool_alloc(&vq->pool, data_len);
    if(io_buffer == NULL) {
32300ad8:	e3520000 	cmp	r2, #0

        /* Reset the offset */
        pool->offset = 0;

        /* Increment the offset for the next allocation */
        pool->offset += alloc_size;
32300adc:	e584c044 	str	ip, [r4, #68]	@ 0x44
32300ae0:	0a000033 	beq	32300bb4 <virtio_console_transmit+0x1a4>
        spin_unlock(&console->tx_lock);
        return;
    }

    /* Copy the data to the I/O buffer */
    strcpy(io_buffer, data);
32300ae4:	e1a0100b 	mov	r1, fp
32300ae8:	e1a00002 	mov	r0, r2
32300aec:	fa00111b 	blx	32304f60 <strcpy>
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
32300af0:	e5943028 	ldr	r3, [r4, #40]	@ 0x28

    /* Add the buffer to the available ring */
    virtq_add_avail_buf(vq, desc_id);

    /* Notify the backend device */
    virtio_mmio_queue_notify(console->mmio, vq->queue_index);
32300af4:	e594b048 	ldr	fp, [r4, #72]	@ 0x48
    desc->flags = 0;
32300af8:	e3a0e000 	mov	lr, #0
32300afc:	e1d443b0 	ldrh	r4, [r4, #48]	@ 0x30
    virtq_desc_init(desc, (uint64_t)io_buffer, data_len);
32300b00:	e1a01fc0 	asr	r1, r0, #31
    desc->addr = addr;
32300b04:	e18a00f8 	strd	r0, [sl, r8]
    desc->flags &= ~VIRTQ_DESC_F_WRITE;
32300b08:	e30fcffd 	movw	ip, #65533	@ 0xfffd
    desc->len = len;
32300b0c:	e5875008 	str	r5, [r7, #8]
    desc->flags = 0;
32300b10:	e1c7e0bc 	strh	lr, [r7, #12]
    desc->next = 0;
32300b14:	e1c7e0be 	strh	lr, [r7, #14]
    desc->flags &= ~VIRTQ_DESC_F_WRITE;
32300b18:	e1d720bc 	ldrh	r2, [r7, #12]
32300b1c:	e00cc002 	and	ip, ip, r2
32300b20:	e1c7c0bc 	strh	ip, [r7, #12]
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
32300b24:	e1d320b2 	ldrh	r2, [r3, #2]
32300b28:	e7e92052 	ubfx	r2, r2, #0, #10
32300b2c:	e0832082 	add	r2, r3, r2, lsl #1
32300b30:	e1c290b4 	strh	r9, [r2, #4]
    vq->avail->idx++;
32300b34:	e1d320b2 	ldrh	r2, [r3, #2]
32300b38:	e2822001 	add	r2, r2, #1
32300b3c:	e6ff2072 	uxth	r2, r2
32300b40:	e1c320b2 	strh	r2, [r3, #2]
    __asm__ volatile(
32300b44:	e2862004 	add	r2, r6, #4
    uint32_t Config;            // offset 0x100
} __attribute__((__packed__, aligned(0x1000)));

static inline void virtio_mmio_queue_notify(volatile struct virtio_mmio_reg *mmio, uint32_t queue_id)
{
    mmio->QueueNotify = queue_id;
32300b48:	e58b4050 	str	r4, [fp, #80]	@ 0x50
32300b4c:	e5923000 	ldr	r3, [r2]
32300b50:	e2833001 	add	r3, r3, #1
32300b54:	e182fc93 	stl	r3, [r2]
32300b58:	f57ff04b 	dsb	ish
32300b5c:	e320f004 	sev

    spin_unlock(&console->tx_lock);
}
32300b60:	e8bd8ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, pc}
        printf("No data to transmit\n");
32300b64:	e30b0768 	movw	r0, #46952	@ 0xb768
32300b68:	e3430230 	movt	r0, #12848	@ 0x3230
}
32300b6c:	e8bd4ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
        printf("No data to transmit\n");
32300b70:	ea002a94 	b	3230b5c8 <__puts_from_arm>
    if (alloc_size <= pool->offset) {
32300b74:	e1550003 	cmp	r5, r3
32300b78:	8a00000d 	bhi	32300bb4 <virtio_console_transmit+0x1a4>
        char *ptr = pool->base;
32300b7c:	e594203c 	ldr	r2, [r4, #60]	@ 0x3c
        for (unsigned long i = 0; i < alloc_size; i++) {
32300b80:	e2423001 	sub	r3, r2, #1
32300b84:	e0830005 	add	r0, r3, r5
            if (pool->base[i] != 0) {
32300b88:	e5f31001 	ldrb	r1, [r3, #1]!
32300b8c:	e3510000 	cmp	r1, #0
32300b90:	1a000007 	bne	32300bb4 <virtio_console_transmit+0x1a4>
        for (unsigned long i = 0; i < alloc_size; i++) {
32300b94:	e1500003 	cmp	r0, r3
32300b98:	1afffffa 	bne	32300b88 <virtio_console_transmit+0x178>
32300b9c:	e1a0c005 	mov	ip, r5
32300ba0:	eaffffcc 	b	32300ad8 <virtio_console_transmit+0xc8>
        printf("VirtIO console device is not ready\n");
32300ba4:	e30b0744 	movw	r0, #46916	@ 0xb744
32300ba8:	e3430230 	movt	r0, #12848	@ 0x3230
}
32300bac:	e8bd4ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
        printf("VirtIO console device is not ready\n");
32300bb0:	ea002a84 	b	3230b5c8 <__puts_from_arm>
        printf("Failed to allocate memory for I/O buffer\n");
32300bb4:	e30b0718 	movw	r0, #46872	@ 0xb718
32300bb8:	e3430230 	movt	r0, #12848	@ 0x3230
32300bbc:	fa000c85 	blx	32303dd8 <puts>
32300bc0:	e2862004 	add	r2, r6, #4
32300bc4:	e5923000 	ldr	r3, [r2]
32300bc8:	e2833001 	add	r3, r3, #1
32300bcc:	e182fc93 	stl	r3, [r2]
32300bd0:	f57ff04b 	dsb	ish
32300bd4:	e320f004 	sev
        return;
32300bd8:	e8bd8ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, pc}
    assert(virtq_has_free_slots(vq));
32300bdc:	e30b377c 	movw	r3, #46972	@ 0xb77c
32300be0:	e3433230 	movt	r3, #12848	@ 0x3230
32300be4:	e30b2b2c 	movw	r2, #47916	@ 0xbb2c
32300be8:	e3432230 	movt	r2, #12848	@ 0x3230
32300bec:	e30b0798 	movw	r0, #47000	@ 0xb798
32300bf0:	e3430230 	movt	r0, #12848	@ 0x3230
32300bf4:	e3a010c1 	mov	r1, #193	@ 0xc1
32300bf8:	fa00052b 	blx	323020ac <__assert_func>

32300bfc <virtio_console_receive>:

bool virtio_console_receive(struct virtio_console *console)
{
    uint32_t interrupt_status = 0;

    if (!console->ready) {
32300bfc:	e5d03178 	ldrb	r3, [r0, #376]	@ 0x178
32300c00:	e3530000 	cmp	r3, #0
32300c04:	0a000004 	beq	32300c1c <virtio_console_receive+0x20>
        return false;
    }

    /* Read and acknowledge interrupts */
    interrupt_status = console->mmio->InterruptStatus;
32300c08:	e5902048 	ldr	r2, [r0, #72]	@ 0x48
32300c0c:	e5923060 	ldr	r3, [r2, #96]	@ 0x60
    console->mmio->InterruptACK = interrupt_status;
32300c10:	e5823064 	str	r3, [r2, #100]	@ 0x64

    if (interrupt_status & VIRTIO_MMIO_INT_CONFIG) {
32300c14:	e2133002 	ands	r3, r3, #2
32300c18:	0a000001 	beq	32300c24 <virtio_console_receive+0x28>
        return false;
32300c1c:	e3a00000 	mov	r0, #0
        return false;
    }

    /* Return true if there are receive buffers available */
    return virtio_console_rx_has_buffers(console);
}
32300c20:	e12fff1e 	bx	lr
{
32300c24:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
    spin_lock(&console->rx_lock);
32300c28:	e280ef57 	add	lr, r0, #348	@ 0x15c
    __asm__ volatile(
32300c2c:	e28e4004 	add	r4, lr, #4
{
32300c30:	e24dd01c 	sub	sp, sp, #28
32300c34:	e19e2e9f 	ldaex	r2, [lr]
32300c38:	e2821001 	add	r1, r2, #1
32300c3c:	e18ecf91 	strex	ip, r1, [lr]
32300c40:	e35c0000 	cmp	ip, #0
32300c44:	1afffffa 	bne	32300c34 <virtio_console_receive+0x38>
32300c48:	e5941000 	ldr	r1, [r4]
32300c4c:	e1520001 	cmp	r2, r1
32300c50:	0a000001 	beq	32300c5c <virtio_console_receive+0x60>
32300c54:	e320f002 	wfe
32300c58:	eafffffa 	b	32300c48 <virtio_console_receive+0x4c>
    console->rx_buffer[0] = '\0';
32300c5c:	e5c03058 	strb	r3, [r0, #88]	@ 0x58
    console->rx_buffer_pos = 0;
32300c60:	e5803158 	str	r3, [r0, #344]	@ 0x158
    __asm__ volatile(
32300c64:	e5942000 	ldr	r2, [r4]
32300c68:	e2822001 	add	r2, r2, #1
32300c6c:	e184fc92 	stl	r2, [r4]
32300c70:	f57ff04b 	dsb	ish
32300c74:	e320f004 	sev
    return vq->used->idx != vq->last_used_idx;
32300c78:	e5902008 	ldr	r2, [r0, #8]
32300c7c:	e1d041b4 	ldrh	r4, [r0, #20]
32300c80:	e1d210b2 	ldrh	r1, [r2, #2]
        if (!virtq_used_has_buf(vq)) {
32300c84:	e1510004 	cmp	r1, r4
32300c88:	01a01000 	moveq	r1, r0
32300c8c:	0a000052 	beq	32300ddc <virtio_console_receive+0x1e0>
32300c90:	e58d3010 	str	r3, [sp, #16]
32300c94:	e1a01000 	mov	r1, r0
32300c98:	e1a03000 	mov	r3, r0
32300c9c:	e1d2c0b2 	ldrh	ip, [r2, #2]
        while (virtq_used_has_buf(vq))
32300ca0:	e15c0004 	cmp	ip, r4
32300ca4:	0a000049 	beq	32300dd0 <virtio_console_receive+0x1d4>
32300ca8:	e30f7fa9 	movw	r7, #65449	@ 0xffa9
32300cac:	e34f7fff 	movt	r7, #65535	@ 0xffff
32300cb0:	e0477000 	sub	r7, r7, r0
32300cb4:	e2808096 	add	r8, r0, #150	@ 0x96
32300cb8:	e58d0004 	str	r0, [sp, #4]
        return false;
    }

    /** Free the memory */
    for (unsigned long i = 0; i < size; i++) {
        pool->base[offset + i] = 0;
32300cbc:	e3a09000 	mov	r9, #0
32300cc0:	e59d0010 	ldr	r0, [sp, #16]
32300cc4:	e58d1014 	str	r1, [sp, #20]
32300cc8:	e1d210b2 	ldrh	r1, [r2, #2]
    return vq->avail->ring[vq->avail_last_idx++ % VIRTQ_SIZE];
}

static inline uint16_t virtq_get_used_buf_id(struct virtq *vq)
{
    assert(virtq_used_has_buf(vq));
32300ccc:	e1540001 	cmp	r4, r1
32300cd0:	0a00009c 	beq	32300f48 <virtio_console_receive+0x34c>
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
32300cd4:	e7e91054 	ubfx	r1, r4, #0, #10
    return &vq->desc[id % VIRTQ_SIZE];
32300cd8:	e593a000 	ldr	sl, [r3]
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
32300cdc:	e2844001 	add	r4, r4, #1
32300ce0:	e1c341b4 	strh	r4, [r3, #20]
32300ce4:	e0822181 	add	r2, r2, r1, lsl #3
32300ce8:	e5921004 	ldr	r1, [r2, #4]
    assert(vq->desc_num_free < VIRTQ_SIZE);
32300cec:	e1d321b0 	ldrh	r2, [r3, #16]
    return &vq->desc[id % VIRTQ_SIZE];
32300cf0:	e7e9c051 	ubfx	ip, r1, #0, #10
    assert(vq->desc_num_free < VIRTQ_SIZE);
32300cf4:	e3520b01 	cmp	r2, #1024	@ 0x400
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
32300cf8:	e6ff1071 	uxth	r1, r1
    return &vq->desc[id % VIRTQ_SIZE];
32300cfc:	e1a0c20c 	lsl	ip, ip, #4
32300d00:	e08a600c 	add	r6, sl, ip
    assert(vq->desc_num_free < VIRTQ_SIZE);
32300d04:	2a000096 	bcs	32300f64 <virtio_console_receive+0x368>
    virtq_get_desc_by_id(vq, id)->next = vq->desc_next_free;
32300d08:	e1d340be 	ldrh	r4, [r3, #14]
    vq->desc_num_free++;
32300d0c:	e2822001 	add	r2, r2, #1
    virtq_get_desc_by_id(vq, id)->next = vq->desc_next_free;
32300d10:	e1c640be 	strh	r4, [r6, #14]
            if (vq_id == VIRTIO_CONSOLE_RX_VQ_IDX) {
32300d14:	e3500000 	cmp	r0, #0
    vq->desc_next_free = id;
32300d18:	e1c310be 	strh	r1, [r3, #14]
    vq->desc_num_free++;
32300d1c:	e1c321b0 	strh	r2, [r3, #16]
32300d20:	0a00004b 	beq	32300e54 <virtio_console_receive+0x258>
            if(!virtio_memory_pool_free(&vq->pool, (char*)desc->addr, desc->len)) {
32300d24:	e18a40dc 	ldrd	r4, [sl, ip]
    if (ptr < pool->base || ptr >= pool->base + pool->size) {
32300d28:	e5931018 	ldr	r1, [r3, #24]
32300d2c:	e5962008 	ldr	r2, [r6, #8]
32300d30:	e1a0b004 	mov	fp, r4
32300d34:	e1540001 	cmp	r4, r1
32300d38:	3a000008 	bcc	32300d60 <virtio_console_receive+0x164>
32300d3c:	e593601c 	ldr	r6, [r3, #28]
    if (size > pool->size) {
32300d40:	e1520006 	cmp	r2, r6
    if (ptr < pool->base || ptr >= pool->base + pool->size) {
32300d44:	e081a006 	add	sl, r1, r6
    if (size > pool->size) {
32300d48:	93a0c000 	movls	ip, #0
32300d4c:	83a0c001 	movhi	ip, #1
32300d50:	e15a0004 	cmp	sl, r4
32300d54:	938cc001 	orrls	ip, ip, #1
32300d58:	e35c0000 	cmp	ip, #0
32300d5c:	0a000005 	beq	32300d78 <virtio_console_receive+0x17c>
                printf("Failed to free memory from the memory pool\n");
32300d60:	e30b0834 	movw	r0, #47156	@ 0xb834
32300d64:	e3430230 	movt	r0, #12848	@ 0x3230
32300d68:	fa000c1a 	blx	32303dd8 <puts>
        return false;
32300d6c:	e3a00000 	mov	r0, #0
}
32300d70:	e28dd01c 	add	sp, sp, #28
32300d74:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
    unsigned long offset = ptr - pool->base;
32300d78:	e0444001 	sub	r4, r4, r1
    if (offset < 0 || offset >= pool->size) {
32300d7c:	e1560004 	cmp	r6, r4
32300d80:	9afffff6 	bls	32300d60 <virtio_console_receive+0x164>
    for (unsigned long i = 0; i < size; i++) {
32300d84:	e3520000 	cmp	r2, #0
32300d88:	0a000009 	beq	32300db4 <virtio_console_receive+0x1b8>
32300d8c:	e3520001 	cmp	r2, #1
        pool->base[offset + i] = 0;
32300d90:	e5cbc000 	strb	ip, [fp]
    for (unsigned long i = 0; i < size; i++) {
32300d94:	0a000006 	beq	32300db4 <virtio_console_receive+0x1b8>
32300d98:	e0822004 	add	r2, r2, r4
32300d9c:	e2844001 	add	r4, r4, #1
        pool->base[offset + i] = 0;
32300da0:	e5931018 	ldr	r1, [r3, #24]
32300da4:	e7c19004 	strb	r9, [r1, r4]
    for (unsigned long i = 0; i < size; i++) {
32300da8:	e2844001 	add	r4, r4, #1
32300dac:	e1540002 	cmp	r4, r2
32300db0:	1afffffa 	bne	32300da0 <virtio_console_receive+0x1a4>
    return vq->used->idx != vq->last_used_idx;
32300db4:	e5932008 	ldr	r2, [r3, #8]
32300db8:	e1d341b4 	ldrh	r4, [r3, #20]
32300dbc:	e1d210b2 	ldrh	r1, [r2, #2]
        while (virtq_used_has_buf(vq))
32300dc0:	e1510004 	cmp	r1, r4
32300dc4:	1affffbf 	bne	32300cc8 <virtio_console_receive+0xcc>
32300dc8:	e59d1014 	ldr	r1, [sp, #20]
32300dcc:	e59d0004 	ldr	r0, [sp, #4]
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++)
32300dd0:	e59d3010 	ldr	r3, [sp, #16]
32300dd4:	e3530001 	cmp	r3, #1
32300dd8:	0a000008 	beq	32300e00 <virtio_console_receive+0x204>
32300ddc:	e591202c 	ldr	r2, [r1, #44]	@ 0x2c
32300de0:	e2811024 	add	r1, r1, #36	@ 0x24
32300de4:	e1a03001 	mov	r3, r1
32300de8:	e1d2c0b2 	ldrh	ip, [r2, #2]
32300dec:	e1d141b4 	ldrh	r4, [r1, #20]
        if (!virtq_used_has_buf(vq)) {
32300df0:	e154000c 	cmp	r4, ip
32300df4:	13a0c001 	movne	ip, #1
32300df8:	158dc010 	strne	ip, [sp, #16]
32300dfc:	1affffa6 	bne	32300c9c <virtio_console_receive+0xa0>
    __asm__ volatile(
32300e00:	e28ec004 	add	ip, lr, #4
32300e04:	e19e3e9f 	ldaex	r3, [lr]
32300e08:	e2832001 	add	r2, r3, #1
32300e0c:	e18e1f92 	strex	r1, r2, [lr]
32300e10:	e3510000 	cmp	r1, #0
32300e14:	1afffffa 	bne	32300e04 <virtio_console_receive+0x208>
32300e18:	e59c2000 	ldr	r2, [ip]
32300e1c:	e1530002 	cmp	r3, r2
32300e20:	0a000001 	beq	32300e2c <virtio_console_receive+0x230>
32300e24:	e320f002 	wfe
32300e28:	eafffffa 	b	32300e18 <virtio_console_receive+0x21c>
    if (console->rx_buffer_pos < VIRTIO_CONSOLE_RX_CONSOLE_SIZE - 1) {
32300e2c:	e5903158 	ldr	r3, [r0, #344]	@ 0x158
32300e30:	e35300fe 	cmp	r3, #254	@ 0xfe
32300e34:	9a000033 	bls	32300f08 <virtio_console_receive+0x30c>
    __asm__ volatile(
32300e38:	e28e2004 	add	r2, lr, #4
32300e3c:	e5923000 	ldr	r3, [r2]
32300e40:	e2833001 	add	r3, r3, #1
32300e44:	e182fc93 	stl	r3, [r2]
32300e48:	f57ff04b 	dsb	ish
32300e4c:	e320f004 	sev
    return success;
32300e50:	eaffffc5 	b	32300d6c <virtio_console_receive+0x170>
                char* msg = (char*)desc->addr;
32300e54:	e18a40dc 	ldrd	r4, [sl, ip]
32300e58:	e1cd40f8 	strd	r4, [sp, #8]
    __asm__ volatile(
32300e5c:	e28e4004 	add	r4, lr, #4
32300e60:	e19e2e9f 	ldaex	r2, [lr]
32300e64:	e2821001 	add	r1, r2, #1
32300e68:	e18ebf91 	strex	fp, r1, [lr]
32300e6c:	e35b0000 	cmp	fp, #0
32300e70:	1afffffa 	bne	32300e60 <virtio_console_receive+0x264>
32300e74:	e5941000 	ldr	r1, [r4]
32300e78:	e1520001 	cmp	r2, r1
32300e7c:	0a000001 	beq	32300e88 <virtio_console_receive+0x28c>
32300e80:	e320f002 	wfe
32300e84:	eafffffa 	b	32300e74 <virtio_console_receive+0x278>
    if (console->rx_buffer_pos >= VIRTIO_CONSOLE_RX_CONSOLE_SIZE - VIRTIO_CONSOLE_RX_BUFFER_SIZE) {
32300e88:	e59d2004 	ldr	r2, [sp, #4]
32300e8c:	e592b158 	ldr	fp, [r2, #344]	@ 0x158
32300e90:	e35b00bf 	cmp	fp, #191	@ 0xbf
32300e94:	9a000005 	bls	32300eb0 <virtio_console_receive+0x2b4>
    __asm__ volatile(
32300e98:	e5943000 	ldr	r3, [r4]
32300e9c:	e2833001 	add	r3, r3, #1
32300ea0:	e184fc93 	stl	r3, [r4]
32300ea4:	f57ff04b 	dsb	ish
32300ea8:	e320f004 	sev
    return success;
32300eac:	eaffffae 	b	32300d6c <virtio_console_receive+0x170>
        for (int i = console->rx_buffer_pos; i < VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1 && console->rx_buffer_pos < VIRTIO_CONSOLE_RX_CONSOLE_SIZE; i++) {
32300eb0:	e35b003e 	cmp	fp, #62	@ 0x3e
32300eb4:	ca000009 	bgt	32300ee0 <virtio_console_receive+0x2e4>
32300eb8:	e59d1004 	ldr	r1, [sp, #4]
32300ebc:	e28b2057 	add	r2, fp, #87	@ 0x57
32300ec0:	e1cd40d8 	ldrd	r4, [sp, #8]
32300ec4:	e0812002 	add	r2, r1, r2
            console->rx_buffer[i] = data[i];
32300ec8:	e0821007 	add	r1, r2, r7
32300ecc:	e0811004 	add	r1, r1, r4
32300ed0:	e5d11000 	ldrb	r1, [r1]
32300ed4:	e5e21001 	strb	r1, [r2, #1]!
        for (int i = console->rx_buffer_pos; i < VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1 && console->rx_buffer_pos < VIRTIO_CONSOLE_RX_CONSOLE_SIZE; i++) {
32300ed8:	e1520008 	cmp	r2, r8
32300edc:	1afffff9 	bne	32300ec8 <virtio_console_receive+0x2cc>
        console->rx_buffer_pos += VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1;
32300ee0:	e59d2004 	ldr	r2, [sp, #4]
32300ee4:	e28bb03f 	add	fp, fp, #63	@ 0x3f
32300ee8:	e28e1004 	add	r1, lr, #4
32300eec:	e582b158 	str	fp, [r2, #344]	@ 0x158
32300ef0:	e5912000 	ldr	r2, [r1]
32300ef4:	e2822001 	add	r2, r2, #1
32300ef8:	e181fc92 	stl	r2, [r1]
32300efc:	f57ff04b 	dsb	ish
32300f00:	e320f004 	sev
    return success;
32300f04:	eaffff86 	b	32300d24 <virtio_console_receive+0x128>
        console->rx_buffer[console->rx_buffer_pos] = '\0';
32300f08:	e0802003 	add	r2, r0, r3
32300f0c:	e3a01000 	mov	r1, #0
        console->rx_buffer_pos++;
32300f10:	e2833001 	add	r3, r3, #1
        console->rx_buffer[console->rx_buffer_pos] = '\0';
32300f14:	e5c21058 	strb	r1, [r2, #88]	@ 0x58
        console->rx_buffer_pos++;
32300f18:	e5803158 	str	r3, [r0, #344]	@ 0x158
32300f1c:	e59c3000 	ldr	r3, [ip]
32300f20:	e2833001 	add	r3, r3, #1
32300f24:	e18cfc93 	stl	r3, [ip]
32300f28:	f57ff04b 	dsb	ish
32300f2c:	e320f004 	sev
    return console->rx_buffer_pos > 1;
32300f30:	e5900158 	ldr	r0, [r0, #344]	@ 0x158
32300f34:	e3500001 	cmp	r0, #1
32300f38:	93a00000 	movls	r0, #0
32300f3c:	83a00001 	movhi	r0, #1
}
32300f40:	e28dd01c 	add	sp, sp, #28
32300f44:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
    assert(virtq_used_has_buf(vq));
32300f48:	e30b37fc 	movw	r3, #47100	@ 0xb7fc
32300f4c:	e3433230 	movt	r3, #12848	@ 0x3230
32300f50:	e30b0798 	movw	r0, #47000	@ 0xb798
32300f54:	e3430230 	movt	r0, #12848	@ 0x3230
32300f58:	e59f2020 	ldr	r2, [pc, #32]	@ 32300f80 <virtio_console_receive+0x384>
32300f5c:	e3a01f56 	mov	r1, #344	@ 0x158
32300f60:	fa000451 	blx	323020ac <__assert_func>
    assert(vq->desc_num_free < VIRTQ_SIZE);
32300f64:	e30b3814 	movw	r3, #47124	@ 0xb814
32300f68:	e3433230 	movt	r3, #12848	@ 0x3230
32300f6c:	e30b0798 	movw	r0, #47000	@ 0xb798
32300f70:	e3430230 	movt	r0, #12848	@ 0x3230
32300f74:	e59f2008 	ldr	r2, [pc, #8]	@ 32300f84 <virtio_console_receive+0x388>
32300f78:	e3a010cf 	mov	r1, #207	@ 0xcf
32300f7c:	fa00044a 	blx	323020ac <__assert_func>
32300f80:	3230bb44 	.word	0x3230bb44
32300f84:	3230bb5c 	.word	0x3230bb5c

32300f88 <virtio_console_rx_get_buffer>:

char* virtio_console_rx_get_buffer(struct virtio_console *console)
{
    return console->rx_buffer;
}
32300f88:	e2800058 	add	r0, r0, #88	@ 0x58
32300f8c:	e12fff1e 	bx	lr

32300f90 <virtio_console_rx_print_buffer>:

void virtio_console_rx_print_buffer(struct virtio_console *console)
{
32300f90:	e92d4010 	push	{r4, lr}
    spin_lock(&console->rx_lock);
32300f94:	e2804f57 	add	r4, r0, #348	@ 0x15c
{
32300f98:	e1a01000 	mov	r1, r0
    __asm__ volatile(
32300f9c:	e284c004 	add	ip, r4, #4
32300fa0:	e1943e9f 	ldaex	r3, [r4]
32300fa4:	e2832001 	add	r2, r3, #1
32300fa8:	e1840f92 	strex	r0, r2, [r4]
32300fac:	e3500000 	cmp	r0, #0
32300fb0:	1afffffa 	bne	32300fa0 <virtio_console_rx_print_buffer+0x10>
32300fb4:	e59c2000 	ldr	r2, [ip]
32300fb8:	e1530002 	cmp	r3, r2
32300fbc:	0a000001 	beq	32300fc8 <virtio_console_rx_print_buffer+0x38>
32300fc0:	e320f002 	wfe
32300fc4:	eafffffa 	b	32300fb4 <virtio_console_rx_print_buffer+0x24>
    printf("Received message on the VirtIO console: %s\n", console->rx_buffer);
32300fc8:	e30b0860 	movw	r0, #47200	@ 0xb860
32300fcc:	e3430230 	movt	r0, #12848	@ 0x3230
32300fd0:	e2811058 	add	r1, r1, #88	@ 0x58
32300fd4:	fa000b45 	blx	32303cf0 <printf>
    __asm__ volatile(
32300fd8:	e2842004 	add	r2, r4, #4
32300fdc:	e5923000 	ldr	r3, [r2]
32300fe0:	e2833001 	add	r3, r3, #1
32300fe4:	e182fc93 	stl	r3, [r2]
32300fe8:	f57ff04b 	dsb	ish
32300fec:	e320f004 	sev
    spin_unlock(&console->rx_lock);
32300ff0:	e8bd8010 	pop	{r4, pc}

32300ff4 <uart_init>:
#include <linflexd_uart.h>

volatile struct linflexd *uart  =  (volatile struct linflexd *)PLAT_UART_ADDR;

void uart_init(void)
{
32300ff4:	e92d4010 	push	{r4, lr}
    linflexd_uart_init(uart);
32300ff8:	e30c400c 	movw	r4, #49164	@ 0xc00c
32300ffc:	e3434230 	movt	r4, #12848	@ 0x3230
32301000:	e5940000 	ldr	r0, [r4]
32301004:	eb00002f 	bl	323010c8 <linflexd_uart_init>
    linflexd_uart_enable(uart);
32301008:	e5940000 	ldr	r0, [r4]
}
3230100c:	e8bd4010 	pop	{r4, lr}
    linflexd_uart_enable(uart);
32301010:	ea000028 	b	323010b8 <linflexd_uart_enable>

32301014 <uart_putc>:

void uart_putc(char c)
{
    linflexd_uart_putc(uart, c);
32301014:	e30c300c 	movw	r3, #49164	@ 0xc00c
32301018:	e3433230 	movt	r3, #12848	@ 0x3230
{
3230101c:	e1a01000 	mov	r1, r0
    linflexd_uart_putc(uart, c);
32301020:	e5930000 	ldr	r0, [r3]
32301024:	e6af1071 	sxtb	r1, r1
32301028:	ea000047 	b	3230114c <linflexd_uart_putc>

3230102c <uart_getchar>:
}

char uart_getchar(void)
{
    return linflexd_uart_getc(uart);
3230102c:	e30c300c 	movw	r3, #49164	@ 0xc00c
32301030:	e3433230 	movt	r3, #12848	@ 0x3230
32301034:	e5930000 	ldr	r0, [r3]
32301038:	ea00003b 	b	3230112c <linflexd_uart_getc>

3230103c <uart_enable_rxirq>:
}

void uart_enable_rxirq(void)
{
    linflexd_uart_rxirq(uart);
3230103c:	e30c300c 	movw	r3, #49164	@ 0xc00c
32301040:	e3433230 	movt	r3, #12848	@ 0x3230
32301044:	e5930000 	ldr	r0, [r3]
32301048:	ea000030 	b	32301110 <linflexd_uart_rxirq>

3230104c <uart_clear_rxirq>:
}

void uart_clear_rxirq(void)
{
    linflexd_uart_clear_rxirq(uart);
3230104c:	e30c300c 	movw	r3, #49164	@ 0xc00c
32301050:	e3433230 	movt	r3, #12848	@ 0x3230
32301054:	e5930000 	ldr	r0, [r3]
32301058:	ea000030 	b	32301120 <linflexd_uart_clear_rxirq>

3230105c <plat_init>:
SYSREG_GEN_ACCESSORS(far_el1, 4, c6, c0, 0);
SYSREG_GEN_ACCESSORS(vbar_el1, 0, c12, c0, 0);
SYSREG_GEN_ACCESSORS(clidr_el1, 1, c0, c0, 1);
SYSREG_GEN_ACCESSORS(csselr_el1, 2, c0, c0, 0);
SYSREG_GEN_ACCESSORS(ctr_el0, 0, c0, c0, 1);
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
3230105c:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
#include <core.h>
#include <sysregs.h>

static inline unsigned long get_cpuid(){
    unsigned long cpuid = sysreg_mpidr_el1_read();
    return cpuid & MPIDR_CPU_MASK;
32301060:	e6ef3073 	uxtb	r3, r3
    mmio_write(SIUL2_IMCR_OFF(47), SIUL2_IMCR_RX);
}

void plat_init(void)
{
    if(cpu_is_master()){
32301064:	e3530000 	cmp	r3, #0
32301068:	112fff1e 	bxne	lr
        return (*(volatile TYPE*)(addr));                    \
    }

MMIO_OPS_GEN(mmio32, uint32_t)
MMIO_OPS_GEN(mmio64, uint64_t)
MMIO_OPS_GEN(mmio, unsigned long)
3230106c:	e3a02000 	mov	r2, #0
32301070:	e3442003 	movt	r2, #16387	@ 0x4003
32301074:	e3a03008 	mov	r3, #8
32301078:	e5823400 	str	r3, [r2, #1024]	@ 0x400
3230107c:	e5923404 	ldr	r3, [r2, #1028]	@ 0x404
    } while ((reg_val & MC_CGM_0_MUX_4_CSS_SWIP) != 0);
32301080:	e3130801 	tst	r3, #65536	@ 0x10000
32301084:	1afffffc 	bne	3230107c <plat_init+0x20>
32301088:	e3a03000 	mov	r3, #0
3230108c:	e3443052 	movt	r3, #16466	@ 0x4052
32301090:	e3a00102 	mov	r0, #-2147483648	@ 0x80000000
32301094:	e3a01001 	mov	r1, #1
32301098:	e3401021 	movt	r1, #33	@ 0x21
3230109c:	e5820408 	str	r0, [r2, #1032]	@ 0x408
323010a0:	e5831240 	str	r1, [r3, #576]	@ 0x240
323010a4:	e3a00809 	mov	r0, #589824	@ 0x90000
323010a8:	e3a02002 	mov	r2, #2
323010ac:	e5830244 	str	r0, [r3, #580]	@ 0x244
323010b0:	e5832afc 	str	r2, [r3, #2812]	@ 0xafc
        plat_clock();
        plat_iomux();
    }
323010b4:	e12fff1e 	bx	lr

323010b8 <linflexd_uart_enable>:
#include <linflexd_uart.h>

void linflexd_uart_enable(volatile struct linflexd * uart)
{
    /* Request normal mode */
    uart->lincr1 &= ~(LINFLEXD_LINCR1_SLEEP | LINFLEXD_LINCR1_INIT);
323010b8:	e5903000 	ldr	r3, [r0]
323010bc:	e3c33003 	bic	r3, r3, #3
323010c0:	e5803000 	str	r3, [r0]
}
323010c4:	e12fff1e 	bx	lr

323010c8 <linflexd_uart_init>:
}

void linflexd_uart_init(volatile struct linflexd * uart)
{
    /* Request init mode */
    uart->lincr1 = (uart->lincr1 & ~(LINFLEXD_LINCR1_SLEEP)) | LINFLEXD_LINCR1_INIT;
323010c8:	e5903000 	ldr	r3, [r0]

    /* Setup UART mode */
    uart->uartcr = (LINFLEXD_UARTCR_UART);
323010cc:	e3a01001 	mov	r1, #1
    uart->linibrr = ibr;
323010d0:	e3a0201a 	mov	r2, #26
    uart->lincr1 = (uart->lincr1 & ~(LINFLEXD_LINCR1_SLEEP)) | LINFLEXD_LINCR1_INIT;
323010d4:	e3c33003 	bic	r3, r3, #3
323010d8:	e1833001 	orr	r3, r3, r1
323010dc:	e5803000 	str	r3, [r0]
    uart->uartcr = (LINFLEXD_UARTCR_UART);
323010e0:	e5801010 	str	r1, [r0, #16]
     * no parity
     * buffer mode
     * 115200
     * Tx and Rx mode
     */
    uart->uartcr &= ~(1<<2);
323010e4:	e5903010 	ldr	r3, [r0, #16]
323010e8:	e3c33004 	bic	r3, r3, #4
323010ec:	e5803010 	str	r3, [r0, #16]
    uart->uartcr |= LINFLEXD_UARTCR_WL0 | LINFLEXD_UARTCR_TXEN | LINFLEXD_UARTCR_RXEN;
323010f0:	e5903010 	ldr	r3, [r0, #16]
323010f4:	e3833032 	orr	r3, r3, #50	@ 0x32
323010f8:	e5803010 	str	r3, [r0, #16]
    uart->linibrr = ibr;
323010fc:	e5802028 	str	r2, [r0, #40]	@ 0x28

    /* Set the baud rate */
    uart_set_baudrate(uart);

    /* Sanitize tx empty flag */
    uart->uartsr |= LINFLEXD_UARTSR_DTFTFF;
32301100:	e5903014 	ldr	r3, [r0, #20]
32301104:	e3833002 	orr	r3, r3, #2
32301108:	e5803014 	str	r3, [r0, #20]
}
3230110c:	e12fff1e 	bx	lr

32301110 <linflexd_uart_rxirq>:

void linflexd_uart_rxirq(volatile struct linflexd * uart)
{
    /* Enable data transmitted interrupt */
    uart->linier |= LINFLEXD_LINIER_DRIE;
32301110:	e5903004 	ldr	r3, [r0, #4]
32301114:	e3833004 	orr	r3, r3, #4
32301118:	e5803004 	str	r3, [r0, #4]
}
3230111c:	e12fff1e 	bx	lr

32301120 <linflexd_uart_clear_rxirq>:

void linflexd_uart_clear_rxirq(volatile struct linflexd * uart)
{
    /* Clear the receive buffer full flag */
    //uart->uartsr |= LINFLEXD_UARTSR_DRFRFE;
    uart->uartsr = LINFLEXD_UARTSR_RMB;
32301120:	e3a03c02 	mov	r3, #512	@ 0x200
32301124:	e5803014 	str	r3, [r0, #20]
}
32301128:	e12fff1e 	bx	lr

3230112c <linflexd_uart_getc>:

uint8_t linflexd_uart_getc(volatile struct linflexd * uart){

    uint8_t data = 0;

    while ((uart->uartsr & LINFLEXD_UARTSR_RMB) == 0u) {
3230112c:	e5903014 	ldr	r3, [r0, #20]
32301130:	e3130c02 	tst	r3, #512	@ 0x200
32301134:	0afffffc 	beq	3230112c <linflexd_uart_getc>
    /* wait for receive buffer full */
    }

    data = uart->bdrm & (0xFF);
32301138:	e590303c 	ldr	r3, [r0, #60]	@ 0x3c
    uart->uartsr = LINFLEXD_UARTSR_RMB;
3230113c:	e3a02c02 	mov	r2, #512	@ 0x200
32301140:	e5802014 	str	r2, [r0, #20]

    linflexd_uart_clear_rxirq(uart);

    return data;
}
32301144:	e6ef0073 	uxtb	r0, r3
32301148:	e12fff1e 	bx	lr

3230114c <linflexd_uart_putc>:
void linflexd_uart_putc(volatile struct linflexd * uart, int8_t c)
{
    uint32_t reg_val;

    do {
        reg_val = (uart->linsr & LINFLEXD_LINSR_LINS_MASK) >> LINFLEXD_LINSR_LINS_SHIFT;
3230114c:	e5903008 	ldr	r3, [r0, #8]
32301150:	e7e33653 	ubfx	r3, r3, #12, #4
    } while (reg_val == LINFLEXD_LINSR_LINS_DRDT || reg_val == LINFLEXD_LINSR_LINS_HRT);
32301154:	e2433007 	sub	r3, r3, #7
32301158:	e3530001 	cmp	r3, #1
3230115c:	9afffffa 	bls	3230114c <linflexd_uart_putc>

    uart->bdrl = (uint32_t)c;
32301160:	e5801038 	str	r1, [r0, #56]	@ 0x38

}
32301164:	e12fff1e 	bx	lr

32301168 <linflexd_uart_puts>:

void linflexd_uart_puts(volatile struct linflexd * uart, const char *s)
{
    while (*s)
32301168:	e5d13000 	ldrb	r3, [r1]
3230116c:	e3530000 	cmp	r3, #0
32301170:	012fff1e 	bxeq	lr
    {
        linflexd_uart_putc(uart,*s++);
32301174:	e6af2073 	sxtb	r2, r3
        reg_val = (uart->linsr & LINFLEXD_LINSR_LINS_MASK) >> LINFLEXD_LINSR_LINS_SHIFT;
32301178:	e5903008 	ldr	r3, [r0, #8]
3230117c:	e7e33653 	ubfx	r3, r3, #12, #4
    } while (reg_val == LINFLEXD_LINSR_LINS_DRDT || reg_val == LINFLEXD_LINSR_LINS_HRT);
32301180:	e2433007 	sub	r3, r3, #7
32301184:	e3530001 	cmp	r3, #1
32301188:	9afffffa 	bls	32301178 <linflexd_uart_puts+0x10>
    uart->bdrl = (uint32_t)c;
3230118c:	e5802038 	str	r2, [r0, #56]	@ 0x38
    while (*s)
32301190:	e5f13001 	ldrb	r3, [r1, #1]!
32301194:	e3530000 	cmp	r3, #0
32301198:	1afffff5 	bne	32301174 <linflexd_uart_puts+0xc>
3230119c:	e12fff1e 	bx	lr

323011a0 <arch_init>:
#include <sysregs.h>

void _start();

__attribute__((weak))
void arch_init(){
323011a0:	e92d4070 	push	{r4, r5, r6, lr}
323011a4:	ee104fb0 	mrc	15, 0, r4, cr0, cr0, {5}
    unsigned long cpuid = get_cpuid();
    gic_init();
323011a8:	eb000114 	bl	32301600 <gic_init>
323011ac:	e6ef4074 	uxtb	r4, r4
SYSREG_GEN_ACCESSORS(ccsidr2, 1, c0, c0, 2);
SYSREG_GEN_ACCESSORS(mair0, 4, c10, c2, 0);
SYSREG_GEN_ACCESSORS(mair1, 4, c10, c2, 1);
SYSREG_GEN_ACCESSORS_MERGE(mair_el1, mair0, mair1);

SYSREG_GEN_ACCESSORS(cntfrq_el0, 0, c14, c0, 0);
323011b0:	ee1e2f10 	mrc	15, 0, r2, cr14, cr0, {0}
    TIMER_FREQ = sysreg_cntfrq_el0_read();
323011b4:	e3053018 	movw	r3, #20504	@ 0x5018
323011b8:	e3433231 	movt	r3, #12849	@ 0x3231
    //sysreg_cntv_ctl_el0_write(3);

#if !(defined(SINGLE_CORE) || defined(NO_FIRMWARE))
    if(cpuid == 0){
323011bc:	e3540000 	cmp	r4, #0
    TIMER_FREQ = sysreg_cntfrq_el0_read();
323011c0:	e5832000 	str	r2, [r3]
    if(cpuid == 0){
323011c4:	1a00000a 	bne	323011f4 <arch_init+0x54>
        size_t i = 0;
        int ret = PSCI_E_SUCCESS;
        do {
            if(i == cpuid) continue;
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
323011c8:	e3005000 	movw	r5, #0
323011cc:	e3435230 	movt	r5, #12848	@ 0x3230
            if(i == cpuid) continue;
323011d0:	e3540001 	cmp	r4, #1
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
323011d4:	e1a01005 	mov	r1, r5
323011d8:	e3a02000 	mov	r2, #0
            if(i == cpuid) continue;
323011dc:	33a04001 	movcc	r4, #1
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
323011e0:	e1a00004 	mov	r0, r4
323011e4:	eb000016 	bl	32301244 <psci_cpu_on>
        } while(i++, ret == PSCI_E_SUCCESS);
323011e8:	e2844001 	add	r4, r4, #1
323011ec:	e3500000 	cmp	r0, #0
323011f0:	0afffff6 	beq	323011d0 <arch_init+0x30>
static inline void arm_dc_civac(uintptr_t cache_addr) {
    sysreg_dccivac_write(cache_addr);
}

static inline void arm_unmask_irq() {
    asm volatile("cpsie i");
323011f4:	f1080080 	cpsie	i
    }
#endif
    arm_unmask_irq();
}
323011f8:	e8bd8070 	pop	{r4, r5, r6, pc}

323011fc <smc_call>:
	register unsigned long r0 asm("r0") = x0;
	register unsigned long r1 asm("r1") = x1;
	register unsigned long r2 asm("r2") = x2;
	register unsigned long r3 asm("r3") = x3;

    asm volatile(
323011fc:	e1400070 	hvc	0
			: "=r" (r0)
			: "r" (r0), "r" (r1), "r" (r2)
			: "r3");

	return r0;
}
32301200:	e12fff1e 	bx	lr

32301204 <psci_version>:
	register unsigned long r1 asm("r1") = x1;
32301204:	e3a01000 	mov	r1, #0
	register unsigned long r0 asm("r0") = x0;
32301208:	e3a00321 	mov	r0, #-2080374784	@ 0x84000000
	register unsigned long r2 asm("r2") = x2;
3230120c:	e1a02001 	mov	r2, r1
    asm volatile(
32301210:	e1400070 	hvc	0
--------------------------------- */

int32_t psci_version(void)
{
    return smc_call(PSCI_VERSION, 0, 0, 0);
}
32301214:	e12fff1e 	bx	lr

32301218 <psci_cpu_suspend>:


int32_t psci_cpu_suspend(uint32_t power_state, uintptr_t entrypoint, 
                    unsigned long context_id)
{
32301218:	e1a03000 	mov	r3, r0
3230121c:	e1a02001 	mov	r2, r1
	register unsigned long r0 asm("r0") = x0;
32301220:	e3a00361 	mov	r0, #-2080374783	@ 0x84000001
	register unsigned long r1 asm("r1") = x1;
32301224:	e1a01003 	mov	r1, r3
    asm volatile(
32301228:	e1400070 	hvc	0
    return smc_call(PSCI_CPU_SUSPEND, power_state, entrypoint, context_id);
}
3230122c:	e12fff1e 	bx	lr

32301230 <psci_cpu_off>:
	register unsigned long r1 asm("r1") = x1;
32301230:	e3a01000 	mov	r1, #0
	register unsigned long r0 asm("r0") = x0;
32301234:	e3a003a1 	mov	r0, #-2080374782	@ 0x84000002
	register unsigned long r2 asm("r2") = x2;
32301238:	e1a02001 	mov	r2, r1
    asm volatile(
3230123c:	e1400070 	hvc	0

int32_t psci_cpu_off(void)
{
    return smc_call(PSCI_CPU_OFF, 0, 0, 0);
}
32301240:	e12fff1e 	bx	lr

32301244 <psci_cpu_on>:

int32_t psci_cpu_on(unsigned long target_cpu, uintptr_t entrypoint, 
                    unsigned long context_id)
{
32301244:	e1a03000 	mov	r3, r0
32301248:	e1a02001 	mov	r2, r1
	register unsigned long r0 asm("r0") = x0;
3230124c:	e3a003e1 	mov	r0, #-2080374781	@ 0x84000003
	register unsigned long r1 asm("r1") = x1;
32301250:	e1a01003 	mov	r1, r3
    asm volatile(
32301254:	e1400070 	hvc	0
    return smc_call(PSCI_CPU_ON, target_cpu, entrypoint, context_id);
}
32301258:	e12fff1e 	bx	lr

3230125c <psci_affinity_info>:

int32_t psci_affinity_info(unsigned long target_affinity, 
                            uint32_t lowest_affinity_level)
{
3230125c:	e1a03000 	mov	r3, r0
32301260:	e1a02001 	mov	r2, r1
	register unsigned long r0 asm("r0") = x0;
32301264:	e3a00004 	mov	r0, #4
32301268:	e3480400 	movt	r0, #33792	@ 0x8400
	register unsigned long r1 asm("r1") = x1;
3230126c:	e1a01003 	mov	r1, r3
    asm volatile(
32301270:	e1400070 	hvc	0
    return smc_call(PSCI_AFFINITY_INFO, target_affinity, 
                    lowest_affinity_level, 0);
}
32301274:	e12fff1e 	bx	lr

32301278 <irq_enable>:

#ifndef GIC_VERSION
#error "GIC_VERSION not defined for this platform"
#endif

void irq_enable(unsigned id) {
32301278:	e92d4010 	push	{r4, lr}
   gic_set_enable(id, true); 
3230127c:	e3a01001 	mov	r1, #1
void irq_enable(unsigned id) {
32301280:	e1a04000 	mov	r4, r0
   gic_set_enable(id, true); 
32301284:	eb00036f 	bl	32302048 <gic_set_enable>
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
32301288:	ee101fb0 	mrc	15, 0, r1, cr0, cr0, {5}
   if(GIC_VERSION == GICV2) {
       gic_set_trgt(id, gic_get_trgt(id) | (1 << get_cpuid()));
   } else {
       gic_set_route(id, get_cpuid());
3230128c:	e1a00004 	mov	r0, r4
32301290:	e6ef1071 	uxtb	r1, r1
   }
}
32301294:	e8bd4010 	pop	{r4, lr}
       gic_set_route(id, get_cpuid());
32301298:	ea00035f 	b	3230201c <gic_set_route>

3230129c <irq_set_prio>:

void irq_set_prio(unsigned id, unsigned prio){
    gic_set_prio(id, (uint8_t) prio);
3230129c:	e6ef1071 	uxtb	r1, r1
323012a0:	ea000306 	b	32301ec0 <gic_set_prio>

323012a4 <irq_send_ipi>:
}

void irq_send_ipi(unsigned long target_cpu_mask) {
323012a4:	e92d4070 	push	{r4, r5, r6, lr}
    for(int i = 0; i < sizeof(target_cpu_mask)*8; i++) {
        if(target_cpu_mask & (1ull << i)) {
323012a8:	e3a05000 	mov	r5, #0
void irq_send_ipi(unsigned long target_cpu_mask) {
323012ac:	e1a06000 	mov	r6, r0
    for(int i = 0; i < sizeof(target_cpu_mask)*8; i++) {
323012b0:	e1a04005 	mov	r4, r5
323012b4:	ea000002 	b	323012c4 <irq_send_ipi+0x20>
323012b8:	e2844001 	add	r4, r4, #1
323012bc:	e3540020 	cmp	r4, #32
323012c0:	08bd8070 	popeq	{r4, r5, r6, pc}
        if(target_cpu_mask & (1ull << i)) {
323012c4:	e2641020 	rsb	r1, r4, #32
323012c8:	e2442020 	sub	r2, r4, #32
323012cc:	e1a03436 	lsr	r3, r6, r4
323012d0:	e1833115 	orr	r3, r3, r5, lsl r1
323012d4:	e1833235 	orr	r3, r3, r5, lsr r2
323012d8:	e3130001 	tst	r3, #1
323012dc:	0afffff5 	beq	323012b8 <irq_send_ipi+0x14>
            gic_send_sgi(i, IPI_IRQ_ID);
323012e0:	e1a00004 	mov	r0, r4
323012e4:	e3a01000 	mov	r1, #0
323012e8:	eb0002e9 	bl	32301e94 <gic_send_sgi>
323012ec:	eafffff1 	b	323012b8 <irq_send_ipi+0x14>

323012f0 <irq_disable>:
        }
    }
}

void irq_disable(unsigned id) {
   gic_set_enable(id, false);
323012f0:	e3a01000 	mov	r1, #0
323012f4:	ea000353 	b	32302048 <gic_set_enable>

323012f8 <irq_clear_pend>:
}

void irq_clear_pend(unsigned id) {
   gic_set_pend(id, false);
323012f8:	e3a01000 	mov	r1, #0
323012fc:	ea00030b 	b	32301f30 <gic_set_pend>

32301300 <gicr_set_pend>:
    __asm__ volatile(
32301300:	e3053028 	movw	r3, #20520	@ 0x5028
32301304:	e3433231 	movt	r3, #12849	@ 0x3231

    return pend | act;
}

static void gicr_set_pend(unsigned long int_id, bool pend, uint32_t gicr_id)
{
32301308:	e92d4030 	push	{r4, r5, lr}
3230130c:	e2835004 	add	r5, r3, #4
32301310:	e193ce9f 	ldaex	ip, [r3]
32301314:	e28ce001 	add	lr, ip, #1
32301318:	e1834f9e 	strex	r4, lr, [r3]
3230131c:	e3540000 	cmp	r4, #0
32301320:	1afffffa 	bne	32301310 <gicr_set_pend+0x10>
32301324:	e595e000 	ldr	lr, [r5]
32301328:	e15c000e 	cmp	ip, lr
3230132c:	0a000001 	beq	32301338 <gicr_set_pend+0x38>
32301330:	e320f002 	wfe
32301334:	eafffffa 	b	32301324 <gicr_set_pend+0x24>
    spin_lock(&gicr_lock);
    if (pend) {
        gicr[gicr_id].ISPENDR0 = (1U) << (int_id);
32301338:	e30cc010 	movw	ip, #49168	@ 0xc010
3230133c:	e343c230 	movt	ip, #12848	@ 0x3230
    if (pend) {
32301340:	e3510000 	cmp	r1, #0
        gicr[gicr_id].ISPENDR0 = (1U) << (int_id);
32301344:	e59c1000 	ldr	r1, [ip]
32301348:	e0812882 	add	r2, r1, r2, lsl #17
3230134c:	e3a01001 	mov	r1, #1
32301350:	e2822801 	add	r2, r2, #65536	@ 0x10000
32301354:	e1a00011 	lsl	r0, r1, r0
32301358:	15820200 	strne	r0, [r2, #512]	@ 0x200
    } else {
        gicr[gicr_id].ICPENDR0 = (1U) << (int_id);
3230135c:	05820280 	streq	r0, [r2, #640]	@ 0x280
    __asm__ volatile(
32301360:	e2832004 	add	r2, r3, #4
32301364:	e5923000 	ldr	r3, [r2]
32301368:	e2833001 	add	r3, r3, #1
3230136c:	e182fc93 	stl	r3, [r2]
32301370:	f57ff04b 	dsb	ish
32301374:	e320f004 	sev
    }
    spin_unlock(&gicr_lock);
}
32301378:	e8bd8030 	pop	{r4, r5, pc}

3230137c <gicd_set_pend>:
    __asm__ volatile(
3230137c:	e3053028 	movw	r3, #20520	@ 0x5028
32301380:	e3433231 	movt	r3, #12849	@ 0x3231
{
32301384:	e92d4030 	push	{r4, r5, lr}
32301388:	e2834008 	add	r4, r3, #8
3230138c:	e283500c 	add	r5, r3, #12
32301390:	e1942e9f 	ldaex	r2, [r4]
32301394:	e282c001 	add	ip, r2, #1
32301398:	e184ef9c 	strex	lr, ip, [r4]
3230139c:	e35e0000 	cmp	lr, #0
323013a0:	1afffffa 	bne	32301390 <gicd_set_pend+0x14>
323013a4:	e595c000 	ldr	ip, [r5]
323013a8:	e152000c 	cmp	r2, ip
323013ac:	0a000001 	beq	323013b8 <gicd_set_pend+0x3c>
323013b0:	e320f002 	wfe
323013b4:	eafffffa 	b	323013a4 <gicd_set_pend+0x28>
            gicd->SPENDSGIR[reg_ind] = (1U) << (off + get_cpuid());
323013b8:	e30c2010 	movw	r2, #49168	@ 0xc010
323013bc:	e3432230 	movt	r2, #12848	@ 0x3230
    if (gic_is_sgi(int_id)) {
323013c0:	e350000f 	cmp	r0, #15
            gicd->SPENDSGIR[reg_ind] = (1U) << (off + get_cpuid());
323013c4:	e5922004 	ldr	r2, [r2, #4]
    if (gic_is_sgi(int_id)) {
323013c8:	8a00000b 	bhi	323013fc <gicd_set_pend+0x80>
        if (pend) {
323013cc:	e3510000 	cmp	r1, #0
        unsigned long reg_ind = GICD_SGI_REG(int_id);
323013d0:	e1a01120 	lsr	r1, r0, #2
        unsigned long off = GICD_SGI_OFF(int_id);
323013d4:	e2000003 	and	r0, r0, #3
323013d8:	e1a00180 	lsl	r0, r0, #3
        if (pend) {
323013dc:	0a000015 	beq	32301438 <gicd_set_pend+0xbc>
323013e0:	ee10cfb0 	mrc	15, 0, ip, cr0, cr0, {5}
            gicd->SPENDSGIR[reg_ind] = (1U) << (off + get_cpuid());
323013e4:	e0822101 	add	r2, r2, r1, lsl #2
323013e8:	e6e0007c 	uxtab	r0, r0, ip
323013ec:	e3a01001 	mov	r1, #1
323013f0:	e1a01011 	lsl	r1, r1, r0
323013f4:	e5821f20 	str	r1, [r2, #3872]	@ 0xf20
323013f8:	ea000007 	b	3230141c <gicd_set_pend+0xa0>
        unsigned long reg_ind = GIC_INT_REG(int_id);
323013fc:	e1a0c2a0 	lsr	ip, r0, #5
            gicd->ISPENDR[reg_ind] = GIC_INT_MASK(int_id);
32301400:	e200001f 	and	r0, r0, #31
        if (pend) {
32301404:	e3510000 	cmp	r1, #0
            gicd->ISPENDR[reg_ind] = GIC_INT_MASK(int_id);
32301408:	e3a01001 	mov	r1, #1
3230140c:	e082210c 	add	r2, r2, ip, lsl #2
32301410:	e1a01011 	lsl	r1, r1, r0
32301414:	15821200 	strne	r1, [r2, #512]	@ 0x200
            gicd->ICPENDR[reg_ind] = GIC_INT_MASK(int_id);
32301418:	05821280 	streq	r1, [r2, #640]	@ 0x280
    __asm__ volatile(
3230141c:	e283200c 	add	r2, r3, #12
32301420:	e5923000 	ldr	r3, [r2]
32301424:	e2833001 	add	r3, r3, #1
32301428:	e182fc93 	stl	r3, [r2]
3230142c:	f57ff04b 	dsb	ish
32301430:	e320f004 	sev
}
32301434:	e8bd8030 	pop	{r4, r5, pc}
            gicd->CPENDSGIR[reg_ind] = BIT_MASK(off, 8);
32301438:	e0822101 	add	r2, r2, r1, lsl #2
3230143c:	e3e0e000 	mvn	lr, #0
32301440:	e280c008 	add	ip, r0, #8
32301444:	e1a0101e 	lsl	r1, lr, r0
32301448:	e1c11c1e 	bic	r1, r1, lr, lsl ip
3230144c:	e5821f10 	str	r1, [r2, #3856]	@ 0xf10
32301450:	eafffff1 	b	3230141c <gicd_set_pend+0xa0>

32301454 <gic_num_irqs>:
        bit_extract(gicd->TYPER, GICD_TYPER_ITLN_OFF, GICD_TYPER_ITLN_LEN);
32301454:	e30c3010 	movw	r3, #49168	@ 0xc010
32301458:	e3433230 	movt	r3, #12848	@ 0x3230
3230145c:	e5933004 	ldr	r3, [r3, #4]
32301460:	e5930004 	ldr	r0, [r3, #4]
    return word &= ~(1UL << off);
}

static inline unsigned long bit_extract(unsigned long word, unsigned long off, unsigned long len)
{
    return (word >> off) & BIT_MASK(0, len);
32301464:	e200001f 	and	r0, r0, #31
    return 32 * itlinenumber + 1;
32301468:	e1a00280 	lsl	r0, r0, #5
}
3230146c:	e2800001 	add	r0, r0, #1
32301470:	e12fff1e 	bx	lr

32301474 <gic_cpu_init>:
{
32301474:	e52de004 	push	{lr}		@ (str lr, [sp, #-4]!)
SYSREG_GEN_ACCESSORS(icc_sre_el1, 0, c12, c12, 5);
32301478:	ee1c3fbc 	mrc	15, 0, r3, cr12, cr12, {5}
    sysreg_icc_sre_el1_write(sysreg_icc_sre_el1_read() | ICC_SRE_SRE_BIT);
3230147c:	e3833001 	orr	r3, r3, #1
32301480:	ee0c3fbc 	mcr	15, 0, r3, cr12, cr12, {5}
    ISB();
32301484:	f57ff06f 	isb	sy
    gicd->CTLR |= (1ull << 6);
32301488:	e30c3010 	movw	r3, #49168	@ 0xc010
3230148c:	e3433230 	movt	r3, #12848	@ 0x3230
    gicr[get_cpuid()].WAKER &= ~GICR_ProcessorSleep_BIT;
32301490:	e8930006 	ldm	r3, {r1, r2}
    gicd->CTLR |= (1ull << 6);
32301494:	e5923000 	ldr	r3, [r2]
32301498:	e3833040 	orr	r3, r3, #64	@ 0x40
3230149c:	e5823000 	str	r3, [r2]
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
323014a0:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
323014a4:	e6ef3073 	uxtb	r3, r3
    gicr[get_cpuid()].WAKER &= ~GICR_ProcessorSleep_BIT;
323014a8:	e0813883 	add	r3, r1, r3, lsl #17
323014ac:	e5932014 	ldr	r2, [r3, #20]
323014b0:	e3c22002 	bic	r2, r2, #2
323014b4:	e5832014 	str	r2, [r3, #20]
323014b8:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
323014bc:	e6ef3073 	uxtb	r3, r3
    while(gicr[get_cpuid()].WAKER & GICR_ChildrenASleep_BIT) { }
323014c0:	e0813883 	add	r3, r1, r3, lsl #17
323014c4:	e5932014 	ldr	r2, [r3, #20]
323014c8:	e2122004 	ands	r2, r2, #4
323014cc:	1afffff9 	bne	323014b8 <gic_cpu_init+0x44>
323014d0:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
323014d4:	e6ef3073 	uxtb	r3, r3
    gicr[get_cpuid()].IGROUPR0 = -1;
323014d8:	e3e0c000 	mvn	ip, #0
323014dc:	e0813883 	add	r3, r1, r3, lsl #17
323014e0:	e2833801 	add	r3, r3, #65536	@ 0x10000
323014e4:	e583c080 	str	ip, [r3, #128]	@ 0x80
323014e8:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
323014ec:	e6ef3073 	uxtb	r3, r3
    gicr[get_cpuid()].ICENABLER0 = -1;
323014f0:	e0813883 	add	r3, r1, r3, lsl #17
323014f4:	e2833801 	add	r3, r3, #65536	@ 0x10000
323014f8:	e583c180 	str	ip, [r3, #384]	@ 0x180
323014fc:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
32301500:	e6ef3073 	uxtb	r3, r3
    gicr[get_cpuid()].ICPENDR0 = -1;
32301504:	e0813883 	add	r3, r1, r3, lsl #17
32301508:	e2833801 	add	r3, r3, #65536	@ 0x10000
3230150c:	e583c280 	str	ip, [r3, #640]	@ 0x280
32301510:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
32301514:	e6ef3073 	uxtb	r3, r3
        gicr[get_cpuid()].IPRIORITYR[i] = -1;
32301518:	e1a0e00c 	mov	lr, ip
    gicr[get_cpuid()].ICACTIVER0 = -1;
3230151c:	e0813883 	add	r3, r1, r3, lsl #17
32301520:	e2833801 	add	r3, r3, #65536	@ 0x10000
32301524:	e583c380 	str	ip, [r3, #896]	@ 0x380
32301528:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
3230152c:	e6ef3073 	uxtb	r3, r3
        gicr[get_cpuid()].IPRIORITYR[i] = -1;
32301530:	e2820901 	add	r0, r2, #16384	@ 0x4000
    for (int i = 0; i < GIC_NUM_PRIO_REGS(GIC_CPU_PRIV); i++) {
32301534:	e2822001 	add	r2, r2, #1
        gicr[get_cpuid()].IPRIORITYR[i] = -1;
32301538:	e0813883 	add	r3, r1, r3, lsl #17
    for (int i = 0; i < GIC_NUM_PRIO_REGS(GIC_CPU_PRIV); i++) {
3230153c:	e3520008 	cmp	r2, #8
        gicr[get_cpuid()].IPRIORITYR[i] = -1;
32301540:	e0833100 	add	r3, r3, r0, lsl #2
32301544:	e583c400 	str	ip, [r3, #1024]	@ 0x400
    for (int i = 0; i < GIC_NUM_PRIO_REGS(GIC_CPU_PRIV); i++) {
32301548:	1afffff6 	bne	32301528 <gic_cpu_init+0xb4>
SYSREG_GEN_ACCESSORS(icc_pmr_el1, 0, c4, c6, 0);
3230154c:	ee04ef16 	mcr	15, 0, lr, cr4, cr6, {0}
SYSREG_GEN_ACCESSORS(icc_ctlr_el1, 0, c12, c12, 4);
32301550:	e3a03001 	mov	r3, #1
32301554:	ee0c3f9c 	mcr	15, 0, r3, cr12, cr12, {4}
SYSREG_GEN_ACCESSORS(icc_igrpen1_el1, 0, c12, c12, 7);
32301558:	ee0c3ffc 	mcr	15, 0, r3, cr12, cr12, {7}
}
3230155c:	e49df004 	pop	{pc}		@ (ldr pc, [sp], #4)

32301560 <gicd_init>:
        bit_extract(gicd->TYPER, GICD_TYPER_ITLN_OFF, GICD_TYPER_ITLN_LEN);
32301560:	e30c3010 	movw	r3, #49168	@ 0xc010
32301564:	e3433230 	movt	r3, #12848	@ 0x3230
{
32301568:	e52de004 	push	{lr}		@ (str lr, [sp, #-4]!)
        bit_extract(gicd->TYPER, GICD_TYPER_ITLN_OFF, GICD_TYPER_ITLN_LEN);
3230156c:	e5930004 	ldr	r0, [r3, #4]
32301570:	e5903004 	ldr	r3, [r0, #4]
32301574:	e203c01f 	and	ip, r3, #31
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
32301578:	e313001e 	tst	r3, #30
3230157c:	0a000009 	beq	323015a8 <gicd_init+0x48>
32301580:	e3a01001 	mov	r1, #1
        gicd->IGROUPR[i] = -1;
32301584:	e3e02000 	mvn	r2, #0
32301588:	e0803101 	add	r3, r0, r1, lsl #2
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
3230158c:	e2811001 	add	r1, r1, #1
32301590:	e15c0001 	cmp	ip, r1
        gicd->IGROUPR[i] = -1;
32301594:	e5832080 	str	r2, [r3, #128]	@ 0x80
        gicd->ICENABLER[i] = -1;
32301598:	e5832180 	str	r2, [r3, #384]	@ 0x180
        gicd->ICPENDR[i] = -1;
3230159c:	e5832280 	str	r2, [r3, #640]	@ 0x280
        gicd->ICACTIVER[i] = -1;
323015a0:	e5832380 	str	r2, [r3, #896]	@ 0x380
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
323015a4:	8afffff7 	bhi	32301588 <gicd_init+0x28>
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_PRIO_REGS(int_num); i++)
323015a8:	e1a0e18c 	lsl	lr, ip, #3
323015ac:	e35c0004 	cmp	ip, #4
323015b0:	9a00000e 	bls	323015f0 <gicd_init+0x90>
323015b4:	e3a03020 	mov	r3, #32
        gicd->IPRIORITYR[i] = -1;
323015b8:	e3e0c000 	mvn	ip, #0
323015bc:	e0802103 	add	r2, r0, r3, lsl #2
323015c0:	e1a01003 	mov	r1, r3
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_PRIO_REGS(int_num); i++)
323015c4:	e2833001 	add	r3, r3, #1
323015c8:	e15e0003 	cmp	lr, r3
        gicd->IPRIORITYR[i] = -1;
323015cc:	e582c400 	str	ip, [r2, #1024]	@ 0x400
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_PRIO_REGS(int_num); i++)
323015d0:	1afffff9 	bne	323015bc <gicd_init+0x5c>
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_TARGET_REGS(int_num); i++)
323015d4:	e3a03020 	mov	r3, #32
        gicd->ITARGETSR[i] = 0;
323015d8:	e3a0e000 	mov	lr, #0
323015dc:	e0802103 	add	r2, r0, r3, lsl #2
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_TARGET_REGS(int_num); i++)
323015e0:	e1510003 	cmp	r1, r3
        gicd->ITARGETSR[i] = 0;
323015e4:	e2833001 	add	r3, r3, #1
323015e8:	e582e800 	str	lr, [r2, #2048]	@ 0x800
    for (int i = GIC_CPU_PRIV; i < GIC_NUM_TARGET_REGS(int_num); i++)
323015ec:	1afffffa 	bne	323015dc <gicd_init+0x7c>
    gicd->CTLR |= GICD_CTLR_ARE_NS_BIT | GICD_CTLR_ENA_BIT;
323015f0:	e5903000 	ldr	r3, [r0]
323015f4:	e3833012 	orr	r3, r3, #18
323015f8:	e5803000 	str	r3, [r0]
}
323015fc:	e49df004 	pop	{pc}		@ (ldr pc, [sp], #4)

32301600 <gic_init>:
{
32301600:	e92d4010 	push	{r4, lr}
    gic_cpu_init();
32301604:	ebffff9a 	bl	32301474 <gic_cpu_init>
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
32301608:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
3230160c:	e6ef3073 	uxtb	r3, r3
    if (get_cpuid() == 0) {
32301610:	e3530000 	cmp	r3, #0
32301614:	18bd8010 	popne	{r4, pc}
}
32301618:	e8bd4010 	pop	{r4, lr}
        gicd_init();
3230161c:	eaffffcf 	b	32301560 <gicd_init>

32301620 <gic_handle>:
{
32301620:	e92d4010 	push	{r4, lr}
SYSREG_GEN_ACCESSORS(icc_iar1_el1, 0, c12, c12, 0);
32301624:	ee1c4f1c 	mrc	15, 0, r4, cr12, cr12, {0}
    unsigned long id = ack & ((1UL << 24) -1);
32301628:	e3c404ff 	bic	r0, r4, #-16777216	@ 0xff000000
    if (id >= 1022) return;
3230162c:	e30033fd 	movw	r3, #1021	@ 0x3fd
32301630:	e1500003 	cmp	r0, r3
32301634:	88bd8010 	pophi	{r4, pc}
    irq_handle(id);
32301638:	ebfffb0e 	bl	32300278 <irq_handle>
SYSREG_GEN_ACCESSORS(icc_eoir1_el1, 0, c12, c12, 1);
3230163c:	ee0c4f3c 	mcr	15, 0, r4, cr12, cr12, {1}
}
32301640:	e8bd8010 	pop	{r4, pc}

32301644 <gicd_get_prio>:
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32301644:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32301648:	e3053028 	movw	r3, #20520	@ 0x5028
3230164c:	e3433231 	movt	r3, #12849	@ 0x3231
{
32301650:	e92d4030 	push	{r4, r5, lr}
    unsigned long off = GIC_PRIO_OFF(int_id);
32301654:	e2002018 	and	r2, r0, #24
32301658:	e2834008 	add	r4, r3, #8
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
3230165c:	e1a002a0 	lsr	r0, r0, #5
32301660:	e283500c 	add	r5, r3, #12
32301664:	e1941e9f 	ldaex	r1, [r4]
32301668:	e281c001 	add	ip, r1, #1
3230166c:	e184ef9c 	strex	lr, ip, [r4]
32301670:	e35e0000 	cmp	lr, #0
32301674:	1afffffa 	bne	32301664 <gicd_get_prio+0x20>
32301678:	e595c000 	ldr	ip, [r5]
3230167c:	e151000c 	cmp	r1, ip
32301680:	0a000001 	beq	3230168c <gicd_get_prio+0x48>
32301684:	e320f002 	wfe
32301688:	eafffffa 	b	32301678 <gicd_get_prio+0x34>
        gicd->IPRIORITYR[reg_ind] >> off & BIT_MASK(off, GIC_PRIO_BITS);
3230168c:	e30c1010 	movw	r1, #49168	@ 0xc010
32301690:	e3431230 	movt	r1, #12848	@ 0x3230
32301694:	e5911004 	ldr	r1, [r1, #4]
32301698:	e0811100 	add	r1, r1, r0, lsl #2
3230169c:	e5910400 	ldr	r0, [r1, #1024]	@ 0x400
    __asm__ volatile(
323016a0:	e5953000 	ldr	r3, [r5]
323016a4:	e2833001 	add	r3, r3, #1
323016a8:	e185fc93 	stl	r3, [r5]
323016ac:	f57ff04b 	dsb	ish
323016b0:	e320f004 	sev
323016b4:	e3e0c000 	mvn	ip, #0
323016b8:	e1a03230 	lsr	r3, r0, r2
323016bc:	e2821008 	add	r1, r2, #8
    unsigned long prio =
323016c0:	e003321c 	and	r3, r3, ip, lsl r2
}
323016c4:	e1c3011c 	bic	r0, r3, ip, lsl r1
323016c8:	e8bd8030 	pop	{r4, r5, pc}

323016cc <gicd_set_icfgr>:
    __asm__ volatile(
323016cc:	e3053028 	movw	r3, #20520	@ 0x5028
323016d0:	e3433231 	movt	r3, #12849	@ 0x3231
{
323016d4:	e92d4030 	push	{r4, r5, lr}
323016d8:	e2834008 	add	r4, r3, #8
323016dc:	e283500c 	add	r5, r3, #12
323016e0:	e1942e9f 	ldaex	r2, [r4]
323016e4:	e282c001 	add	ip, r2, #1
323016e8:	e184ef9c 	strex	lr, ip, [r4]
323016ec:	e35e0000 	cmp	lr, #0
323016f0:	1afffffa 	bne	323016e0 <gicd_set_icfgr+0x14>
323016f4:	e595c000 	ldr	ip, [r5]
323016f8:	e152000c 	cmp	r2, ip
323016fc:	0a000001 	beq	32301708 <gicd_set_icfgr+0x3c>
32301700:	e320f002 	wfe
32301704:	eafffffa 	b	323016f4 <gicd_set_icfgr+0x28>
    gicd->ICFGR[reg_ind] = (gicd->ICFGR[reg_ind] & ~mask) | ((cfg << off) & mask);
32301708:	e30c2010 	movw	r2, #49168	@ 0xc010
3230170c:	e3432230 	movt	r2, #12848	@ 0x3230
    unsigned long reg_ind = (int_id * GIC_CONFIG_BITS) / (sizeof(uint32_t) * 8);
32301710:	e1a00080 	lsl	r0, r0, #1
    unsigned long mask = ((1U << GIC_CONFIG_BITS) - 1) << off;
32301714:	e3a0e003 	mov	lr, #3
    unsigned long off = (int_id * GIC_CONFIG_BITS) % (sizeof(uint32_t) * 8);
32301718:	e200c01e 	and	ip, r0, #30
    gicd->ICFGR[reg_ind] = (gicd->ICFGR[reg_ind] & ~mask) | ((cfg << off) & mask);
3230171c:	e5922004 	ldr	r2, [r2, #4]
    unsigned long reg_ind = (int_id * GIC_CONFIG_BITS) / (sizeof(uint32_t) * 8);
32301720:	e1a002a0 	lsr	r0, r0, #5
32301724:	e0822100 	add	r2, r2, r0, lsl #2
    gicd->ICFGR[reg_ind] = (gicd->ICFGR[reg_ind] & ~mask) | ((cfg << off) & mask);
32301728:	e5920c00 	ldr	r0, [r2, #3072]	@ 0xc00
3230172c:	e0201c11 	eor	r1, r0, r1, lsl ip
32301730:	e0011c1e 	and	r1, r1, lr, lsl ip
32301734:	e0211000 	eor	r1, r1, r0
32301738:	e5821c00 	str	r1, [r2, #3072]	@ 0xc00
    __asm__ volatile(
3230173c:	e5953000 	ldr	r3, [r5]
32301740:	e2833001 	add	r3, r3, #1
32301744:	e185fc93 	stl	r3, [r5]
32301748:	f57ff04b 	dsb	ish
3230174c:	e320f004 	sev
}
32301750:	e8bd8030 	pop	{r4, r5, pc}

32301754 <gicd_set_prio>:
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32301754:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32301758:	e3052028 	movw	r2, #20520	@ 0x5028
3230175c:	e3432231 	movt	r2, #12849	@ 0x3231
{
32301760:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long off = GIC_PRIO_OFF(int_id);
32301764:	e200c018 	and	ip, r0, #24
32301768:	e2825008 	add	r5, r2, #8
3230176c:	e282600c 	add	r6, r2, #12
32301770:	e1953e9f 	ldaex	r3, [r5]
32301774:	e283e001 	add	lr, r3, #1
32301778:	e1854f9e 	strex	r4, lr, [r5]
3230177c:	e3540000 	cmp	r4, #0
32301780:	1afffffa 	bne	32301770 <gicd_set_prio+0x1c>
32301784:	e596e000 	ldr	lr, [r6]
32301788:	e153000e 	cmp	r3, lr
3230178c:	0a000001 	beq	32301798 <gicd_set_prio+0x44>
32301790:	e320f002 	wfe
32301794:	eafffffa 	b	32301784 <gicd_set_prio+0x30>
        (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
32301798:	e30c3010 	movw	r3, #49168	@ 0xc010
3230179c:	e3433230 	movt	r3, #12848	@ 0x3230
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
323017a0:	e1a002a0 	lsr	r0, r0, #5
    unsigned long mask = BIT_MASK(off, GIC_PRIO_BITS);
323017a4:	e3e04000 	mvn	r4, #0
323017a8:	e5933004 	ldr	r3, [r3, #4]
323017ac:	e0830100 	add	r0, r3, r0, lsl #2
        (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
323017b0:	e590e400 	ldr	lr, [r0, #1024]	@ 0x400
323017b4:	e02e3c11 	eor	r3, lr, r1, lsl ip
    unsigned long mask = BIT_MASK(off, GIC_PRIO_BITS);
323017b8:	e28c1008 	add	r1, ip, #8
        (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
323017bc:	e1c33114 	bic	r3, r3, r4, lsl r1
323017c0:	e0033c14 	and	r3, r3, r4, lsl ip
323017c4:	e023300e 	eor	r3, r3, lr
    gicd->IPRIORITYR[reg_ind] =
323017c8:	e5803400 	str	r3, [r0, #1024]	@ 0x400
    __asm__ volatile(
323017cc:	e5963000 	ldr	r3, [r6]
323017d0:	e2833001 	add	r3, r3, #1
323017d4:	e186fc93 	stl	r3, [r6]
323017d8:	f57ff04b 	dsb	ish
323017dc:	e320f004 	sev
}
323017e0:	e8bd8070 	pop	{r4, r5, r6, pc}

323017e4 <gicd_get_state>:
    unsigned long mask = GIC_INT_MASK(int_id);
323017e4:	e200101f 	and	r1, r0, #31
323017e8:	e3a02001 	mov	r2, #1
    __asm__ volatile(
323017ec:	e3053028 	movw	r3, #20520	@ 0x5028
323017f0:	e3433231 	movt	r3, #12849	@ 0x3231
{
323017f4:	e92d4030 	push	{r4, r5, lr}
    unsigned long mask = GIC_INT_MASK(int_id);
323017f8:	e1a02112 	lsl	r2, r2, r1
323017fc:	e2834008 	add	r4, r3, #8
32301800:	e283500c 	add	r5, r3, #12
32301804:	e1941e9f 	ldaex	r1, [r4]
32301808:	e281c001 	add	ip, r1, #1
3230180c:	e184ef9c 	strex	lr, ip, [r4]
32301810:	e35e0000 	cmp	lr, #0
32301814:	1afffffa 	bne	32301804 <gicd_get_state+0x20>
32301818:	e595c000 	ldr	ip, [r5]
3230181c:	e151000c 	cmp	r1, ip
32301820:	0a000001 	beq	3230182c <gicd_get_state+0x48>
32301824:	e320f002 	wfe
32301828:	eafffffa 	b	32301818 <gicd_get_state+0x34>
    enum int_state pend = (gicd->ISPENDR[reg_ind] & mask) ? PEND : 0;
3230182c:	e30c1010 	movw	r1, #49168	@ 0xc010
32301830:	e3431230 	movt	r1, #12848	@ 0x3230
    unsigned long reg_ind = GIC_INT_REG(int_id);
32301834:	e1a002a0 	lsr	r0, r0, #5
32301838:	e5911004 	ldr	r1, [r1, #4]
3230183c:	e0811100 	add	r1, r1, r0, lsl #2
    __asm__ volatile(
32301840:	e1a00005 	mov	r0, r5
    enum int_state pend = (gicd->ISPENDR[reg_ind] & mask) ? PEND : 0;
32301844:	e591c200 	ldr	ip, [r1, #512]	@ 0x200
    enum int_state act = (gicd->ISACTIVER[reg_ind] & mask) ? ACT : 0;
32301848:	e5911300 	ldr	r1, [r1, #768]	@ 0x300
3230184c:	e5953000 	ldr	r3, [r5]
32301850:	e2833001 	add	r3, r3, #1
32301854:	e185fc93 	stl	r3, [r5]
32301858:	f57ff04b 	dsb	ish
3230185c:	e320f004 	sev
32301860:	e1110002 	tst	r1, r2
32301864:	13a00001 	movne	r0, #1
32301868:	03a00000 	moveq	r0, #0
    enum int_state pend = (gicd->ISPENDR[reg_ind] & mask) ? PEND : 0;
3230186c:	e11c0002 	tst	ip, r2
32301870:	13a03001 	movne	r3, #1
32301874:	03a03000 	moveq	r3, #0
}
32301878:	e1830080 	orr	r0, r3, r0, lsl #1
3230187c:	e8bd8030 	pop	{r4, r5, pc}

32301880 <gicd_set_act>:
    __asm__ volatile(
32301880:	e3053028 	movw	r3, #20520	@ 0x5028
32301884:	e3433231 	movt	r3, #12849	@ 0x3231
{
32301888:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long reg_ind = GIC_INT_REG(int_id);
3230188c:	e1a0c2a0 	lsr	ip, r0, #5
32301890:	e2835008 	add	r5, r3, #8
32301894:	e283600c 	add	r6, r3, #12
32301898:	e1952e9f 	ldaex	r2, [r5]
3230189c:	e282e001 	add	lr, r2, #1
323018a0:	e1854f9e 	strex	r4, lr, [r5]
323018a4:	e3540000 	cmp	r4, #0
323018a8:	1afffffa 	bne	32301898 <gicd_set_act+0x18>
323018ac:	e596e000 	ldr	lr, [r6]
323018b0:	e152000e 	cmp	r2, lr
323018b4:	0a000001 	beq	323018c0 <gicd_set_act+0x40>
323018b8:	e320f002 	wfe
323018bc:	eafffffa 	b	323018ac <gicd_set_act+0x2c>
        gicd->ISACTIVER[reg_ind] = GIC_INT_MASK(int_id);
323018c0:	e30c2010 	movw	r2, #49168	@ 0xc010
323018c4:	e3432230 	movt	r2, #12848	@ 0x3230
323018c8:	e200001f 	and	r0, r0, #31
    if (act) {
323018cc:	e3510000 	cmp	r1, #0
        gicd->ISACTIVER[reg_ind] = GIC_INT_MASK(int_id);
323018d0:	e3a01001 	mov	r1, #1
323018d4:	e5922004 	ldr	r2, [r2, #4]
323018d8:	e1a01011 	lsl	r1, r1, r0
323018dc:	e082210c 	add	r2, r2, ip, lsl #2
323018e0:	15821300 	strne	r1, [r2, #768]	@ 0x300
        gicd->ICACTIVER[reg_ind] = GIC_INT_MASK(int_id);
323018e4:	05821380 	streq	r1, [r2, #896]	@ 0x380
    __asm__ volatile(
323018e8:	e283200c 	add	r2, r3, #12
323018ec:	e5923000 	ldr	r3, [r2]
323018f0:	e2833001 	add	r3, r3, #1
323018f4:	e182fc93 	stl	r3, [r2]
323018f8:	f57ff04b 	dsb	ish
323018fc:	e320f004 	sev
}
32301900:	e8bd8070 	pop	{r4, r5, r6, pc}

32301904 <gicd_set_state>:
{
32301904:	e92d4070 	push	{r4, r5, r6, lr}
32301908:	e1a04001 	mov	r4, r1
3230190c:	e1a05000 	mov	r5, r0
    gicd_set_act(int_id, state & ACT);
32301910:	e7e010d1 	ubfx	r1, r1, #1, #1
32301914:	ebffffd9 	bl	32301880 <gicd_set_act>
    gicd_set_pend(int_id, state & PEND);
32301918:	e2041001 	and	r1, r4, #1
3230191c:	e1a00005 	mov	r0, r5
}
32301920:	e8bd4070 	pop	{r4, r5, r6, lr}
    gicd_set_pend(int_id, state & PEND);
32301924:	eafffe94 	b	3230137c <gicd_set_pend>

32301928 <gicd_set_trgt>:
    unsigned long reg_ind = GIC_TARGET_REG(int_id);
32301928:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
3230192c:	e3052028 	movw	r2, #20520	@ 0x5028
32301930:	e3432231 	movt	r2, #12849	@ 0x3231
{
32301934:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long off = GIC_TARGET_OFF(int_id);
32301938:	e200c018 	and	ip, r0, #24
3230193c:	e2825008 	add	r5, r2, #8
32301940:	e282600c 	add	r6, r2, #12
32301944:	e1953e9f 	ldaex	r3, [r5]
32301948:	e283e001 	add	lr, r3, #1
3230194c:	e1854f9e 	strex	r4, lr, [r5]
32301950:	e3540000 	cmp	r4, #0
32301954:	1afffffa 	bne	32301944 <gicd_set_trgt+0x1c>
32301958:	e596e000 	ldr	lr, [r6]
3230195c:	e153000e 	cmp	r3, lr
32301960:	0a000001 	beq	3230196c <gicd_set_trgt+0x44>
32301964:	e320f002 	wfe
32301968:	eafffffa 	b	32301958 <gicd_set_trgt+0x30>
        (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
3230196c:	e30c3010 	movw	r3, #49168	@ 0xc010
32301970:	e3433230 	movt	r3, #12848	@ 0x3230
    unsigned long reg_ind = GIC_TARGET_REG(int_id);
32301974:	e1a002a0 	lsr	r0, r0, #5
    uint32_t mask = BIT_MASK(off, GIC_TARGET_BITS);
32301978:	e3e04000 	mvn	r4, #0
3230197c:	e5933004 	ldr	r3, [r3, #4]
32301980:	e0830100 	add	r0, r3, r0, lsl #2
        (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
32301984:	e590e800 	ldr	lr, [r0, #2048]	@ 0x800
32301988:	e02e3c11 	eor	r3, lr, r1, lsl ip
    uint32_t mask = BIT_MASK(off, GIC_TARGET_BITS);
3230198c:	e28c1008 	add	r1, ip, #8
        (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
32301990:	e1c33114 	bic	r3, r3, r4, lsl r1
32301994:	e0033c14 	and	r3, r3, r4, lsl ip
32301998:	e023300e 	eor	r3, r3, lr
    gicd->ITARGETSR[reg_ind] =
3230199c:	e5803800 	str	r3, [r0, #2048]	@ 0x800
    __asm__ volatile(
323019a0:	e5963000 	ldr	r3, [r6]
323019a4:	e2833001 	add	r3, r3, #1
323019a8:	e186fc93 	stl	r3, [r6]
323019ac:	f57ff04b 	dsb	ish
323019b0:	e320f004 	sev
}
323019b4:	e8bd8070 	pop	{r4, r5, r6, pc}

323019b8 <gicd_set_route>:
void gicd_set_route(unsigned long int_id, unsigned long trgt)
323019b8:	e350001f 	cmp	r0, #31
323019bc:	912fff1e 	bxls	lr
323019c0:	e30c3010 	movw	r3, #49168	@ 0xc010
323019c4:	e3433230 	movt	r3, #12848	@ 0x3230
323019c8:	e2800b03 	add	r0, r0, #3072	@ 0xc00
323019cc:	e3a0c000 	mov	ip, #0
323019d0:	e5933004 	ldr	r3, [r3, #4]
323019d4:	e0832180 	add	r2, r3, r0, lsl #3
323019d8:	e7831180 	str	r1, [r3, r0, lsl #3]
323019dc:	e582c004 	str	ip, [r2, #4]
323019e0:	e12fff1e 	bx	lr

323019e4 <gicd_set_enable>:
    unsigned long bit = GIC_INT_MASK(int_id);
323019e4:	e200c01f 	and	ip, r0, #31
323019e8:	e3a02001 	mov	r2, #1
    __asm__ volatile(
323019ec:	e3053028 	movw	r3, #20520	@ 0x5028
323019f0:	e3433231 	movt	r3, #12849	@ 0x3231
{
323019f4:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long reg_ind = GIC_INT_REG(int_id);
323019f8:	e1a002a0 	lsr	r0, r0, #5
    unsigned long bit = GIC_INT_MASK(int_id);
323019fc:	e1a0cc12 	lsl	ip, r2, ip
32301a00:	e2835008 	add	r5, r3, #8
32301a04:	e283600c 	add	r6, r3, #12
32301a08:	e1952e9f 	ldaex	r2, [r5]
32301a0c:	e282e001 	add	lr, r2, #1
32301a10:	e1854f9e 	strex	r4, lr, [r5]
32301a14:	e3540000 	cmp	r4, #0
32301a18:	1afffffa 	bne	32301a08 <gicd_set_enable+0x24>
32301a1c:	e596e000 	ldr	lr, [r6]
32301a20:	e152000e 	cmp	r2, lr
32301a24:	0a000001 	beq	32301a30 <gicd_set_enable+0x4c>
32301a28:	e320f002 	wfe
32301a2c:	eafffffa 	b	32301a1c <gicd_set_enable+0x38>
        gicd->ISENABLER[reg_ind] = bit;
32301a30:	e30c2010 	movw	r2, #49168	@ 0xc010
32301a34:	e3432230 	movt	r2, #12848	@ 0x3230
    if (en)
32301a38:	e3510000 	cmp	r1, #0
        gicd->ISENABLER[reg_ind] = bit;
32301a3c:	e5922004 	ldr	r2, [r2, #4]
32301a40:	e0822100 	add	r2, r2, r0, lsl #2
32301a44:	1582c100 	strne	ip, [r2, #256]	@ 0x100
        gicd->ICENABLER[reg_ind] = bit;
32301a48:	0582c180 	streq	ip, [r2, #384]	@ 0x180
    __asm__ volatile(
32301a4c:	e283200c 	add	r2, r3, #12
32301a50:	e5923000 	ldr	r3, [r2]
32301a54:	e2833001 	add	r3, r3, #1
32301a58:	e182fc93 	stl	r3, [r2]
32301a5c:	f57ff04b 	dsb	ish
32301a60:	e320f004 	sev
}
32301a64:	e8bd8070 	pop	{r4, r5, r6, pc}

32301a68 <gicr_set_prio>:
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32301a68:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32301a6c:	e3053028 	movw	r3, #20520	@ 0x5028
32301a70:	e3433231 	movt	r3, #12849	@ 0x3231
{
32301a74:	e92d4070 	push	{r4, r5, r6, lr}
    unsigned long off = GIC_PRIO_OFF(int_id);
32301a78:	e200c018 	and	ip, r0, #24
32301a7c:	e2836004 	add	r6, r3, #4
32301a80:	e193ee9f 	ldaex	lr, [r3]
32301a84:	e28e4001 	add	r4, lr, #1
32301a88:	e1835f94 	strex	r5, r4, [r3]
32301a8c:	e3550000 	cmp	r5, #0
32301a90:	1afffffa 	bne	32301a80 <gicr_set_prio+0x18>
32301a94:	e5964000 	ldr	r4, [r6]
32301a98:	e15e0004 	cmp	lr, r4
32301a9c:	0a000001 	beq	32301aa8 <gicr_set_prio+0x40>
32301aa0:	e320f002 	wfe
32301aa4:	eafffffa 	b	32301a94 <gicr_set_prio+0x2c>
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32301aa8:	e1a002a0 	lsr	r0, r0, #5
        (gicr[gicr_id].IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
32301aac:	e1a02882 	lsl	r2, r2, #17
    unsigned long mask = BIT_MASK(off, GIC_PRIO_BITS);
32301ab0:	e28ce008 	add	lr, ip, #8
32301ab4:	e3e04000 	mvn	r4, #0
32301ab8:	e0822100 	add	r2, r2, r0, lsl #2
        (gicr[gicr_id].IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
32301abc:	e30c0010 	movw	r0, #49168	@ 0xc010
32301ac0:	e3430230 	movt	r0, #12848	@ 0x3230
32301ac4:	e5900000 	ldr	r0, [r0]
32301ac8:	e0802002 	add	r2, r0, r2
32301acc:	e2822801 	add	r2, r2, #65536	@ 0x10000
32301ad0:	e5920400 	ldr	r0, [r2, #1024]	@ 0x400
32301ad4:	e0201c11 	eor	r1, r0, r1, lsl ip
32301ad8:	e1c11e14 	bic	r1, r1, r4, lsl lr
    unsigned long mask = BIT_MASK(off, GIC_PRIO_BITS);
32301adc:	e1a0e004 	mov	lr, r4
        (gicr[gicr_id].IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
32301ae0:	e0011c14 	and	r1, r1, r4, lsl ip
32301ae4:	e0211000 	eor	r1, r1, r0
    gicr[gicr_id].IPRIORITYR[reg_ind] =
32301ae8:	e5821400 	str	r1, [r2, #1024]	@ 0x400
    __asm__ volatile(
32301aec:	e5963000 	ldr	r3, [r6]
32301af0:	e2833001 	add	r3, r3, #1
32301af4:	e186fc93 	stl	r3, [r6]
32301af8:	f57ff04b 	dsb	ish
32301afc:	e320f004 	sev
}
32301b00:	e8bd8070 	pop	{r4, r5, r6, pc}

32301b04 <gicr_get_prio>:
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32301b04:	e1a00180 	lsl	r0, r0, #3
    __asm__ volatile(
32301b08:	e3053028 	movw	r3, #20520	@ 0x5028
32301b0c:	e3433231 	movt	r3, #12849	@ 0x3231
{
32301b10:	e92d4030 	push	{r4, r5, lr}
    unsigned long off = GIC_PRIO_OFF(int_id);
32301b14:	e200c018 	and	ip, r0, #24
32301b18:	e2835004 	add	r5, r3, #4
    unsigned long reg_ind = GIC_PRIO_REG(int_id);
32301b1c:	e1a002a0 	lsr	r0, r0, #5
32301b20:	e1932e9f 	ldaex	r2, [r3]
32301b24:	e282e001 	add	lr, r2, #1
32301b28:	e1834f9e 	strex	r4, lr, [r3]
32301b2c:	e3540000 	cmp	r4, #0
32301b30:	1afffffa 	bne	32301b20 <gicr_get_prio+0x1c>
32301b34:	e595e000 	ldr	lr, [r5]
32301b38:	e152000e 	cmp	r2, lr
32301b3c:	0a000001 	beq	32301b48 <gicr_get_prio+0x44>
32301b40:	e320f002 	wfe
32301b44:	eafffffa 	b	32301b34 <gicr_get_prio+0x30>
        gicr[gicr_id].IPRIORITYR[reg_ind] >> off & BIT_MASK(off, GIC_PRIO_BITS);
32301b48:	e30c2010 	movw	r2, #49168	@ 0xc010
32301b4c:	e3432230 	movt	r2, #12848	@ 0x3230
32301b50:	e2800901 	add	r0, r0, #16384	@ 0x4000
32301b54:	e5922000 	ldr	r2, [r2]
32301b58:	e0821881 	add	r1, r2, r1, lsl #17
32301b5c:	e0811100 	add	r1, r1, r0, lsl #2
32301b60:	e5910400 	ldr	r0, [r1, #1024]	@ 0x400
    __asm__ volatile(
32301b64:	e5953000 	ldr	r3, [r5]
32301b68:	e2833001 	add	r3, r3, #1
32301b6c:	e185fc93 	stl	r3, [r5]
32301b70:	f57ff04b 	dsb	ish
32301b74:	e320f004 	sev
32301b78:	e3e01000 	mvn	r1, #0
32301b7c:	e1a03c30 	lsr	r3, r0, ip
32301b80:	e28c2008 	add	r2, ip, #8
    unsigned long prio =
32301b84:	e0033c11 	and	r3, r3, r1, lsl ip
}
32301b88:	e1c30211 	bic	r0, r3, r1, lsl r2
32301b8c:	e8bd8030 	pop	{r4, r5, pc}

32301b90 <gicr_set_icfgr>:
    __asm__ volatile(
32301b90:	e3053028 	movw	r3, #20520	@ 0x5028
32301b94:	e3433231 	movt	r3, #12849	@ 0x3231
{
32301b98:	e92d4030 	push	{r4, r5, lr}
32301b9c:	e2835004 	add	r5, r3, #4
32301ba0:	e193ce9f 	ldaex	ip, [r3]
32301ba4:	e28ce001 	add	lr, ip, #1
32301ba8:	e1834f9e 	strex	r4, lr, [r3]
32301bac:	e3540000 	cmp	r4, #0
32301bb0:	1afffffa 	bne	32301ba0 <gicr_set_icfgr+0x10>
32301bb4:	e595e000 	ldr	lr, [r5]
32301bb8:	e15c000e 	cmp	ip, lr
32301bbc:	0a000001 	beq	32301bc8 <gicr_set_icfgr+0x38>
32301bc0:	e320f002 	wfe
32301bc4:	eafffffa 	b	32301bb4 <gicr_set_icfgr+0x24>
    unsigned long reg_ind = (int_id * GIC_CONFIG_BITS) / (sizeof(uint32_t) * 8);
32301bc8:	e1a00080 	lsl	r0, r0, #1
    if (reg_ind == 0) {
32301bcc:	e350001f 	cmp	r0, #31
    unsigned long off = (int_id * GIC_CONFIG_BITS) % (sizeof(uint32_t) * 8);
32301bd0:	e200c01e 	and	ip, r0, #30
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32301bd4:	e30c0010 	movw	r0, #49168	@ 0xc010
32301bd8:	e3430230 	movt	r0, #12848	@ 0x3230
32301bdc:	e1a01c11 	lsl	r1, r1, ip
32301be0:	e5900000 	ldr	r0, [r0]
32301be4:	e0802882 	add	r2, r0, r2, lsl #17
    unsigned long mask = ((1U << GIC_CONFIG_BITS) - 1) << off;
32301be8:	e3a00003 	mov	r0, #3
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32301bec:	e2822801 	add	r2, r2, #65536	@ 0x10000
    unsigned long mask = ((1U << GIC_CONFIG_BITS) - 1) << off;
32301bf0:	e1a00c10 	lsl	r0, r0, ip
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32301bf4:	9592cc00 	ldrls	ip, [r2, #3072]	@ 0xc00
            (gicr[gicr_id].ICFGR1 & ~mask) | ((cfg << off) & mask);
32301bf8:	8592cc04 	ldrhi	ip, [r2, #3076]	@ 0xc04
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32301bfc:	9021100c 	eorls	r1, r1, ip
            (gicr[gicr_id].ICFGR1 & ~mask) | ((cfg << off) & mask);
32301c00:	8021100c 	eorhi	r1, r1, ip
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32301c04:	90011000 	andls	r1, r1, r0
            (gicr[gicr_id].ICFGR1 & ~mask) | ((cfg << off) & mask);
32301c08:	80011000 	andhi	r1, r1, r0
            (gicr[gicr_id].ICFGR0 & ~mask) | ((cfg << off) & mask);
32301c0c:	9021100c 	eorls	r1, r1, ip
            (gicr[gicr_id].ICFGR1 & ~mask) | ((cfg << off) & mask);
32301c10:	8021100c 	eorhi	r1, r1, ip
        gicr[gicr_id].ICFGR0 =
32301c14:	95821c00 	strls	r1, [r2, #3072]	@ 0xc00
        gicr[gicr_id].ICFGR1 =
32301c18:	85821c04 	strhi	r1, [r2, #3076]	@ 0xc04
    __asm__ volatile(
32301c1c:	e2832004 	add	r2, r3, #4
32301c20:	e5923000 	ldr	r3, [r2]
32301c24:	e2833001 	add	r3, r3, #1
32301c28:	e182fc93 	stl	r3, [r2]
32301c2c:	f57ff04b 	dsb	ish
32301c30:	e320f004 	sev
}
32301c34:	e8bd8030 	pop	{r4, r5, pc}

32301c38 <gicr_get_state>:
    unsigned long mask = GIC_INT_MASK(int_id);
32301c38:	e200001f 	and	r0, r0, #31
32301c3c:	e3a0c001 	mov	ip, #1
    __asm__ volatile(
32301c40:	e3053028 	movw	r3, #20520	@ 0x5028
32301c44:	e3433231 	movt	r3, #12849	@ 0x3231
{
32301c48:	e92d4010 	push	{r4, lr}
    unsigned long mask = GIC_INT_MASK(int_id);
32301c4c:	e1a0c01c 	lsl	ip, ip, r0
32301c50:	e2834004 	add	r4, r3, #4
32301c54:	e1932e9f 	ldaex	r2, [r3]
32301c58:	e2820001 	add	r0, r2, #1
32301c5c:	e183ef90 	strex	lr, r0, [r3]
32301c60:	e35e0000 	cmp	lr, #0
32301c64:	1afffffa 	bne	32301c54 <gicr_get_state+0x1c>
32301c68:	e5940000 	ldr	r0, [r4]
32301c6c:	e1520000 	cmp	r2, r0
32301c70:	0a000001 	beq	32301c7c <gicr_get_state+0x44>
32301c74:	e320f002 	wfe
32301c78:	eafffffa 	b	32301c68 <gicr_get_state+0x30>
    enum int_state pend = (gicr[gicr_id].ISPENDR0 & mask) ? PEND : 0;
32301c7c:	e30c2010 	movw	r2, #49168	@ 0xc010
32301c80:	e3432230 	movt	r2, #12848	@ 0x3230
    __asm__ volatile(
32301c84:	e1a00004 	mov	r0, r4
32301c88:	e5922000 	ldr	r2, [r2]
32301c8c:	e0821881 	add	r1, r2, r1, lsl #17
32301c90:	e2811801 	add	r1, r1, #65536	@ 0x10000
32301c94:	e5912200 	ldr	r2, [r1, #512]	@ 0x200
    enum int_state act = (gicr[gicr_id].ISACTIVER0 & mask) ? ACT : 0;
32301c98:	e5911300 	ldr	r1, [r1, #768]	@ 0x300
32301c9c:	e5943000 	ldr	r3, [r4]
32301ca0:	e2833001 	add	r3, r3, #1
32301ca4:	e184fc93 	stl	r3, [r4]
32301ca8:	f57ff04b 	dsb	ish
32301cac:	e320f004 	sev
32301cb0:	e111000c 	tst	r1, ip
32301cb4:	13a00001 	movne	r0, #1
32301cb8:	03a00000 	moveq	r0, #0
    enum int_state pend = (gicr[gicr_id].ISPENDR0 & mask) ? PEND : 0;
32301cbc:	e112000c 	tst	r2, ip
32301cc0:	13a03001 	movne	r3, #1
32301cc4:	03a03000 	moveq	r3, #0
}
32301cc8:	e1830080 	orr	r0, r3, r0, lsl #1
32301ccc:	e8bd8010 	pop	{r4, pc}

32301cd0 <gicr_set_act>:
    __asm__ volatile(
32301cd0:	e3053028 	movw	r3, #20520	@ 0x5028
32301cd4:	e3433231 	movt	r3, #12849	@ 0x3231

void gicr_set_act(unsigned long int_id, bool act, uint32_t gicr_id)
{
32301cd8:	e92d4030 	push	{r4, r5, lr}
32301cdc:	e2835004 	add	r5, r3, #4
32301ce0:	e193ce9f 	ldaex	ip, [r3]
32301ce4:	e28ce001 	add	lr, ip, #1
32301ce8:	e1834f9e 	strex	r4, lr, [r3]
32301cec:	e3540000 	cmp	r4, #0
32301cf0:	1afffffa 	bne	32301ce0 <gicr_set_act+0x10>
32301cf4:	e595e000 	ldr	lr, [r5]
32301cf8:	e15c000e 	cmp	ip, lr
32301cfc:	0a000001 	beq	32301d08 <gicr_set_act+0x38>
32301d00:	e320f002 	wfe
32301d04:	eafffffa 	b	32301cf4 <gicr_set_act+0x24>
    spin_lock(&gicr_lock);

    if (act) {
        gicr[gicr_id].ISACTIVER0 = GIC_INT_MASK(int_id);
32301d08:	e30cc010 	movw	ip, #49168	@ 0xc010
32301d0c:	e343c230 	movt	ip, #12848	@ 0x3230
    if (act) {
32301d10:	e3510000 	cmp	r1, #0
        gicr[gicr_id].ISACTIVER0 = GIC_INT_MASK(int_id);
32301d14:	e200001f 	and	r0, r0, #31
32301d18:	e59c1000 	ldr	r1, [ip]
32301d1c:	e0812882 	add	r2, r1, r2, lsl #17
32301d20:	e3a01001 	mov	r1, #1
32301d24:	e2822801 	add	r2, r2, #65536	@ 0x10000
32301d28:	e1a01011 	lsl	r1, r1, r0
32301d2c:	15821300 	strne	r1, [r2, #768]	@ 0x300
    } else {
        gicr[gicr_id].ICACTIVER0 = GIC_INT_MASK(int_id);
32301d30:	05821380 	streq	r1, [r2, #896]	@ 0x380
    __asm__ volatile(
32301d34:	e2832004 	add	r2, r3, #4
32301d38:	e5923000 	ldr	r3, [r2]
32301d3c:	e2833001 	add	r3, r3, #1
32301d40:	e182fc93 	stl	r3, [r2]
32301d44:	f57ff04b 	dsb	ish
32301d48:	e320f004 	sev
    }

    spin_unlock(&gicr_lock);
}
32301d4c:	e8bd8030 	pop	{r4, r5, pc}

32301d50 <gicr_set_state>:

void gicr_set_state(unsigned long int_id, enum int_state state, uint32_t gicr_id)
{
32301d50:	e92d4070 	push	{r4, r5, r6, lr}
32301d54:	e1a04001 	mov	r4, r1
32301d58:	e1a05000 	mov	r5, r0
32301d5c:	e1a06002 	mov	r6, r2
    gicr_set_act(int_id, state & ACT, gicr_id);
32301d60:	e7e010d1 	ubfx	r1, r1, #1, #1
32301d64:	ebffffd9 	bl	32301cd0 <gicr_set_act>
    gicr_set_pend(int_id, state & PEND, gicr_id);
32301d68:	e1a02006 	mov	r2, r6
32301d6c:	e2041001 	and	r1, r4, #1
32301d70:	e1a00005 	mov	r0, r5
}
32301d74:	e8bd4070 	pop	{r4, r5, r6, lr}
    gicr_set_pend(int_id, state & PEND, gicr_id);
32301d78:	eafffd60 	b	32301300 <gicr_set_pend>

32301d7c <gicr_set_trgt>:
    __asm__ volatile(
32301d7c:	e3053028 	movw	r3, #20520	@ 0x5028
32301d80:	e3433231 	movt	r3, #12849	@ 0x3231
32301d84:	e283c004 	add	ip, r3, #4
32301d88:	e1932e9f 	ldaex	r2, [r3]
32301d8c:	e2821001 	add	r1, r2, #1
32301d90:	e1830f91 	strex	r0, r1, [r3]
32301d94:	e3500000 	cmp	r0, #0
32301d98:	1afffffa 	bne	32301d88 <gicr_set_trgt+0xc>
32301d9c:	e59c1000 	ldr	r1, [ip]
32301da0:	e1520001 	cmp	r2, r1
32301da4:	0a000001 	beq	32301db0 <gicr_set_trgt+0x34>
32301da8:	e320f002 	wfe
32301dac:	eafffffa 	b	32301d9c <gicr_set_trgt+0x20>
    __asm__ volatile(
32301db0:	e59c3000 	ldr	r3, [ip]
32301db4:	e2833001 	add	r3, r3, #1
32301db8:	e18cfc93 	stl	r3, [ip]
32301dbc:	f57ff04b 	dsb	ish
32301dc0:	e320f004 	sev
void gicr_set_trgt(unsigned long int_id, uint8_t trgt, uint32_t gicr_id)
{
    spin_lock(&gicr_lock);

    spin_unlock(&gicr_lock);
}
32301dc4:	e12fff1e 	bx	lr

32301dc8 <gicr_set_route>:
    __asm__ volatile(
32301dc8:	e3053028 	movw	r3, #20520	@ 0x5028
32301dcc:	e3433231 	movt	r3, #12849	@ 0x3231
32301dd0:	e283c004 	add	ip, r3, #4
32301dd4:	e1932e9f 	ldaex	r2, [r3]
32301dd8:	e2821001 	add	r1, r2, #1
32301ddc:	e1830f91 	strex	r0, r1, [r3]
32301de0:	e3500000 	cmp	r0, #0
32301de4:	1afffffa 	bne	32301dd4 <gicr_set_route+0xc>
32301de8:	e59c1000 	ldr	r1, [ip]
32301dec:	e1520001 	cmp	r2, r1
32301df0:	0a000001 	beq	32301dfc <gicr_set_route+0x34>
32301df4:	e320f002 	wfe
32301df8:	eafffffa 	b	32301de8 <gicr_set_route+0x20>
    __asm__ volatile(
32301dfc:	e59c3000 	ldr	r3, [ip]
32301e00:	e2833001 	add	r3, r3, #1
32301e04:	e18cfc93 	stl	r3, [ip]
32301e08:	f57ff04b 	dsb	ish
32301e0c:	e320f004 	sev

void gicr_set_route(unsigned long int_id, uint8_t trgt, uint32_t gicr_id)
{
    gicr_set_trgt(int_id, trgt, gicr_id);
}
32301e10:	e12fff1e 	bx	lr

32301e14 <gicr_set_enable>:

void gicr_set_enable(unsigned long int_id, bool en, uint32_t gicr_id)
{
    unsigned long bit = GIC_INT_MASK(int_id);
32301e14:	e200001f 	and	r0, r0, #31
32301e18:	e3a03001 	mov	r3, #1
{
32301e1c:	e92d4030 	push	{r4, r5, lr}
    unsigned long bit = GIC_INT_MASK(int_id);
32301e20:	e1a00013 	lsl	r0, r3, r0
    __asm__ volatile(
32301e24:	e3053028 	movw	r3, #20520	@ 0x5028
32301e28:	e3433231 	movt	r3, #12849	@ 0x3231
32301e2c:	e2835004 	add	r5, r3, #4
32301e30:	e193ce9f 	ldaex	ip, [r3]
32301e34:	e28ce001 	add	lr, ip, #1
32301e38:	e1834f9e 	strex	r4, lr, [r3]
32301e3c:	e3540000 	cmp	r4, #0
32301e40:	1afffffa 	bne	32301e30 <gicr_set_enable+0x1c>
32301e44:	e595e000 	ldr	lr, [r5]
32301e48:	e15c000e 	cmp	ip, lr
32301e4c:	0a000001 	beq	32301e58 <gicr_set_enable+0x44>
32301e50:	e320f002 	wfe
32301e54:	eafffffa 	b	32301e44 <gicr_set_enable+0x30>

    spin_lock(&gicr_lock);
    if (en)
        gicr[gicr_id].ISENABLER0 = bit;
32301e58:	e30cc010 	movw	ip, #49168	@ 0xc010
32301e5c:	e343c230 	movt	ip, #12848	@ 0x3230
    if (en)
32301e60:	e3510000 	cmp	r1, #0
        gicr[gicr_id].ISENABLER0 = bit;
32301e64:	e59c1000 	ldr	r1, [ip]
32301e68:	e0812882 	add	r2, r1, r2, lsl #17
32301e6c:	e2822801 	add	r2, r2, #65536	@ 0x10000
32301e70:	15820100 	strne	r0, [r2, #256]	@ 0x100
    else
        gicr[gicr_id].ICENABLER0 = bit;
32301e74:	05820180 	streq	r0, [r2, #384]	@ 0x180
    __asm__ volatile(
32301e78:	e2832004 	add	r2, r3, #4
32301e7c:	e5923000 	ldr	r3, [r2]
32301e80:	e2833001 	add	r3, r3, #1
32301e84:	e182fc93 	stl	r3, [r2]
32301e88:	f57ff04b 	dsb	ish
32301e8c:	e320f004 	sev
    spin_unlock(&gicr_lock);
}
32301e90:	e8bd8030 	pop	{r4, r5, pc}

32301e94 <gic_send_sgi>:
    else return false;
}

void gic_send_sgi(unsigned long cpu_target, unsigned long sgi_num)
{
    if (sgi_num >= GIC_MAX_SGIS) return;
32301e94:	e351000f 	cmp	r1, #15
32301e98:	812fff1e 	bxhi	lr
    
    unsigned long sgi = (1UL << (cpu_target & 0xffull)) | (sgi_num << 24);
32301e9c:	e6ef0070 	uxtb	r0, r0
32301ea0:	e1a01c01 	lsl	r1, r1, #24
32301ea4:	e3a0c001 	mov	ip, #1
    sysreg_icc_sgi1r_el1_write(sgi); 
32301ea8:	e3a03000 	mov	r3, #0
32301eac:	e181201c 	orr	r2, r1, ip, lsl r0
SYSREG_GEN_ACCESSORS_64(icc_sgi1r_el1, 0, c12);
32301eb0:	e3a00000 	mov	r0, #0
32301eb4:	e3a01000 	mov	r1, #0
32301eb8:	ec402f0c 	mcrr	15, 0, r2, r0, cr12
}
32301ebc:	e12fff1e 	bx	lr

32301ec0 <gic_set_prio>:
    if (int_id > 32 && int_id < 1025) return true;
32301ec0:	e2403021 	sub	r3, r0, #33	@ 0x21
32301ec4:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32301ec8:	2a000000 	bcs	32301ed0 <gic_set_prio+0x10>

void gic_set_prio(unsigned long int_id, uint8_t prio)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_prio(int_id, prio);
32301ecc:	eafffe20 	b	32301754 <gicd_set_prio>
SYSREG_GEN_ACCESSORS(mpidr_el1, 0, c0, c0, 5);
32301ed0:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_prio(int_id, prio, get_cpuid());
32301ed4:	e6ef2072 	uxtb	r2, r2
32301ed8:	eafffee2 	b	32301a68 <gicr_set_prio>

32301edc <gic_get_prio>:
    if (int_id > 32 && int_id < 1025) return true;
32301edc:	e2403021 	sub	r3, r0, #33	@ 0x21
32301ee0:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32301ee4:	2a000000 	bcs	32301eec <gic_get_prio+0x10>
}

unsigned long gic_get_prio(unsigned long int_id)
{
    if (irq_in_gicd(int_id)) {
        return gicd_get_prio(int_id);
32301ee8:	eafffdd5 	b	32301644 <gicd_get_prio>
32301eec:	ee101fb0 	mrc	15, 0, r1, cr0, cr0, {5}
    } else {
        return gicr_get_prio(int_id, get_cpuid());
32301ef0:	e6ef1071 	uxtb	r1, r1
32301ef4:	eaffff02 	b	32301b04 <gicr_get_prio>

32301ef8 <gic_set_icfgr>:
    if (int_id > 32 && int_id < 1025) return true;
32301ef8:	e2403021 	sub	r3, r0, #33	@ 0x21
32301efc:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32301f00:	2a000000 	bcs	32301f08 <gic_set_icfgr+0x10>
}

void gic_set_icfgr(unsigned long int_id, uint8_t cfg)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_icfgr(int_id, cfg);
32301f04:	eafffdf0 	b	323016cc <gicd_set_icfgr>
32301f08:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_icfgr(int_id, cfg, get_cpuid());
32301f0c:	e6ef2072 	uxtb	r2, r2
32301f10:	eaffff1e 	b	32301b90 <gicr_set_icfgr>

32301f14 <gic_get_state>:
    if (int_id > 32 && int_id < 1025) return true;
32301f14:	e2403021 	sub	r3, r0, #33	@ 0x21
32301f18:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32301f1c:	2a000000 	bcs	32301f24 <gic_get_state+0x10>
}

enum int_state gic_get_state(unsigned long int_id)
{
    if (irq_in_gicd(int_id)) {
        return gicd_get_state(int_id);
32301f20:	eafffe2f 	b	323017e4 <gicd_get_state>
32301f24:	ee101fb0 	mrc	15, 0, r1, cr0, cr0, {5}
    } else {
        return gicr_get_state(int_id, get_cpuid());
32301f28:	e6ef1071 	uxtb	r1, r1
32301f2c:	eaffff41 	b	32301c38 <gicr_get_state>

32301f30 <gic_set_pend>:
    if (int_id > 32 && int_id < 1025) return true;
32301f30:	e2403021 	sub	r3, r0, #33	@ 0x21
32301f34:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32301f38:	2a000000 	bcs	32301f40 <gic_set_pend+0x10>
}

void gic_set_pend(unsigned long int_id, bool pend)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_pend(int_id, pend);
32301f3c:	eafffd0e 	b	3230137c <gicd_set_pend>
32301f40:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_pend(int_id, pend, get_cpuid());
32301f44:	e6ef2072 	uxtb	r2, r2
32301f48:	eafffcec 	b	32301300 <gicr_set_pend>

32301f4c <gic_set_act>:
    if (int_id > 32 && int_id < 1025) return true;
32301f4c:	e2403021 	sub	r3, r0, #33	@ 0x21
32301f50:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32301f54:	2a000000 	bcs	32301f5c <gic_set_act+0x10>
}

void gic_set_act(unsigned long int_id, bool act)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_act(int_id, act);
32301f58:	eafffe48 	b	32301880 <gicd_set_act>
32301f5c:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_act(int_id, act, get_cpuid());
32301f60:	e6ef2072 	uxtb	r2, r2
32301f64:	eaffff59 	b	32301cd0 <gicr_set_act>

32301f68 <gic_set_state>:
    if (int_id > 32 && int_id < 1025) return true;
32301f68:	e2403021 	sub	r3, r0, #33	@ 0x21
    }
}

void gic_set_state(unsigned long int_id, enum int_state state)
{
32301f6c:	e92d4070 	push	{r4, r5, r6, lr}
    if (int_id > 32 && int_id < 1025) return true;
32301f70:	e3530e3e 	cmp	r3, #992	@ 0x3e0
    gicd_set_pend(int_id, state & PEND);
32301f74:	e2016001 	and	r6, r1, #1
{
32301f78:	e1a04000 	mov	r4, r0
    gicd_set_act(int_id, state & ACT);
32301f7c:	e7e010d1 	ubfx	r1, r1, #1, #1
    if (int_id > 32 && int_id < 1025) return true;
32301f80:	2a000004 	bcs	32301f98 <gic_set_state+0x30>
    gicd_set_act(int_id, state & ACT);
32301f84:	ebfffe3d 	bl	32301880 <gicd_set_act>
    gicd_set_pend(int_id, state & PEND);
32301f88:	e1a01006 	mov	r1, r6
32301f8c:	e1a00004 	mov	r0, r4
    if (irq_in_gicd(int_id)) {
        return gicd_set_state(int_id, state);
    } else {
        return gicr_set_state(int_id, state, get_cpuid());
    }
}
32301f90:	e8bd4070 	pop	{r4, r5, r6, lr}
    gicd_set_pend(int_id, state & PEND);
32301f94:	eafffcf8 	b	3230137c <gicd_set_pend>
32301f98:	ee105fb0 	mrc	15, 0, r5, cr0, cr0, {5}
32301f9c:	e6ef5075 	uxtb	r5, r5
    gicr_set_act(int_id, state & ACT, gicr_id);
32301fa0:	e1a02005 	mov	r2, r5
32301fa4:	ebffff49 	bl	32301cd0 <gicr_set_act>
    gicr_set_pend(int_id, state & PEND, gicr_id);
32301fa8:	e1a02005 	mov	r2, r5
32301fac:	e1a01006 	mov	r1, r6
32301fb0:	e1a00004 	mov	r0, r4
}
32301fb4:	e8bd4070 	pop	{r4, r5, r6, lr}
    gicr_set_pend(int_id, state & PEND, gicr_id);
32301fb8:	eafffcd0 	b	32301300 <gicr_set_pend>

32301fbc <gic_set_trgt>:
    if (int_id > 32 && int_id < 1025) return true;
32301fbc:	e2403021 	sub	r3, r0, #33	@ 0x21
32301fc0:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32301fc4:	2a000000 	bcs	32301fcc <gic_set_trgt+0x10>

void gic_set_trgt(unsigned long int_id, uint8_t trgt)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_trgt(int_id, trgt);
32301fc8:	eafffe56 	b	32301928 <gicd_set_trgt>
32301fcc:	ee103fb0 	mrc	15, 0, r3, cr0, cr0, {5}
    __asm__ volatile(
32301fd0:	e3053028 	movw	r3, #20520	@ 0x5028
32301fd4:	e3433231 	movt	r3, #12849	@ 0x3231
32301fd8:	e283c004 	add	ip, r3, #4
32301fdc:	e1932e9f 	ldaex	r2, [r3]
32301fe0:	e2821001 	add	r1, r2, #1
32301fe4:	e1830f91 	strex	r0, r1, [r3]
32301fe8:	e3500000 	cmp	r0, #0
32301fec:	1afffffa 	bne	32301fdc <gic_set_trgt+0x20>
32301ff0:	e59c1000 	ldr	r1, [ip]
32301ff4:	e1520001 	cmp	r2, r1
32301ff8:	0a000001 	beq	32302004 <gic_set_trgt+0x48>
32301ffc:	e320f002 	wfe
32302000:	eafffffa 	b	32301ff0 <gic_set_trgt+0x34>
    __asm__ volatile(
32302004:	e59c3000 	ldr	r3, [ip]
32302008:	e2833001 	add	r3, r3, #1
3230200c:	e18cfc93 	stl	r3, [ip]
32302010:	f57ff04b 	dsb	ish
32302014:	e320f004 	sev
    } else {
        return gicr_set_trgt(int_id, trgt, get_cpuid());
    }
}
32302018:	e12fff1e 	bx	lr

3230201c <gic_set_route>:
    if (gic_is_priv(int_id)) return;
3230201c:	e350001f 	cmp	r0, #31
32302020:	912fff1e 	bxls	lr
    volatile uint32_t *irouter = (uint32_t*) &gicd->IROUTER[int_id];
32302024:	e30c3010 	movw	r3, #49168	@ 0xc010
32302028:	e3433230 	movt	r3, #12848	@ 0x3230
3230202c:	e2800b03 	add	r0, r0, #3072	@ 0xc00
    irouter[1] = (_trgt >> 32);
32302030:	e3a0c000 	mov	ip, #0
    volatile uint32_t *irouter = (uint32_t*) &gicd->IROUTER[int_id];
32302034:	e5933004 	ldr	r3, [r3, #4]
32302038:	e0832180 	add	r2, r3, r0, lsl #3
    irouter[0] = _trgt;
3230203c:	e7831180 	str	r1, [r3, r0, lsl #3]
    irouter[1] = (_trgt >> 32);
32302040:	e582c004 	str	ip, [r2, #4]

void gic_set_route(unsigned long int_id, unsigned long trgt)
{
    return gicd_set_route(int_id, trgt);
}
32302044:	e12fff1e 	bx	lr

32302048 <gic_set_enable>:
    if (int_id > 32 && int_id < 1025) return true;
32302048:	e2403021 	sub	r3, r0, #33	@ 0x21
3230204c:	e3530e3e 	cmp	r3, #992	@ 0x3e0
32302050:	2a000000 	bcs	32302058 <gic_set_enable+0x10>

void gic_set_enable(unsigned long int_id, bool en)
{
    if (irq_in_gicd(int_id)) {
        return gicd_set_enable(int_id, en);
32302054:	eafffe62 	b	323019e4 <gicd_set_enable>
32302058:	ee102fb0 	mrc	15, 0, r2, cr0, cr0, {5}
    } else {
        return gicr_set_enable(int_id, en, get_cpuid());
3230205c:	e6ef2072 	uxtb	r2, r2
32302060:	eaffff6b 	b	32301e14 <gicr_set_enable>
	...

32302080 <_exception_vector>:
.text

.balign 0x20
.global _exception_vector
_exception_vector:
    b .
32302080:	eafffffe 	b	32302080 <_exception_vector>
    b .
32302084:	eafffffe 	b	32302084 <_exception_vector+0x4>
    b .
32302088:	eafffffe 	b	32302088 <_exception_vector+0x8>
    b .
3230208c:	eafffffe 	b	3230208c <_exception_vector+0xc>
    b .
32302090:	eafffffe 	b	32302090 <_exception_vector+0x10>
    b .
32302094:	eafffffe 	b	32302094 <_exception_vector+0x14>
    b irq_handler
32302098:	eaffffff 	b	3230209c <irq_handler>

3230209c <irq_handler>:

irq_handler:
    push {r0-r12, r14}
3230209c:	e92d5fff 	push	{r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp, ip, lr}
    bl gic_handle
323020a0:	ebfffd5e 	bl	32301620 <gic_handle>
    pop {r0-r12, r14}
323020a4:	e8bd5fff 	pop	{r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp, ip, lr}
    SUBS PC, lr, #4
323020a8:	e25ef004 	subs	pc, lr, #4

323020ac <__assert_func>:
323020ac:	f24c 25a0 	movw	r5, #49824	@ 0xc2a0
323020b0:	f2c3 2530 	movt	r5, #12848	@ 0x3230
323020b4:	b500      	push	{lr}
323020b6:	4614      	mov	r4, r2
323020b8:	460e      	mov	r6, r1
323020ba:	682d      	ldr	r5, [r5, #0]
323020bc:	461a      	mov	r2, r3
323020be:	b085      	sub	sp, #20
323020c0:	4603      	mov	r3, r0
323020c2:	68e8      	ldr	r0, [r5, #12]
323020c4:	b174      	cbz	r4, 323020e4 <__assert_func+0x38>
323020c6:	f64b 058c 	movw	r5, #47244	@ 0xb88c
323020ca:	f2c3 2530 	movt	r5, #12848	@ 0x3230
323020ce:	f64b 019c 	movw	r1, #47260	@ 0xb89c
323020d2:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323020d6:	e9cd 5401 	strd	r5, r4, [sp, #4]
323020da:	9600      	str	r6, [sp, #0]
323020dc:	f000 f81c 	bl	32302118 <fiprintf>
323020e0:	f003 fb1a 	bl	32305718 <abort>
323020e4:	f64b 0598 	movw	r5, #47256	@ 0xb898
323020e8:	f2c3 2530 	movt	r5, #12848	@ 0x3230
323020ec:	462c      	mov	r4, r5
323020ee:	e7ee      	b.n	323020ce <__assert_func+0x22>

323020f0 <__assert>:
323020f0:	b508      	push	{r3, lr}
323020f2:	4613      	mov	r3, r2
323020f4:	2200      	movs	r2, #0
323020f6:	f7ff ffd9 	bl	323020ac <__assert_func>
323020fa:	bf00      	nop

323020fc <_fiprintf_r>:
323020fc:	b40c      	push	{r2, r3}
323020fe:	b500      	push	{lr}
32302100:	b083      	sub	sp, #12
32302102:	ab04      	add	r3, sp, #16
32302104:	f853 2b04 	ldr.w	r2, [r3], #4
32302108:	9301      	str	r3, [sp, #4]
3230210a:	f000 f81b 	bl	32302144 <_vfiprintf_r>
3230210e:	b003      	add	sp, #12
32302110:	f85d eb04 	ldr.w	lr, [sp], #4
32302114:	b002      	add	sp, #8
32302116:	4770      	bx	lr

32302118 <fiprintf>:
32302118:	b40e      	push	{r1, r2, r3}
3230211a:	f24c 2ca0 	movw	ip, #49824	@ 0xc2a0
3230211e:	f2c3 2c30 	movt	ip, #12848	@ 0x3230
32302122:	b500      	push	{lr}
32302124:	4601      	mov	r1, r0
32302126:	b082      	sub	sp, #8
32302128:	f8dc 0000 	ldr.w	r0, [ip]
3230212c:	ab03      	add	r3, sp, #12
3230212e:	f853 2b04 	ldr.w	r2, [r3], #4
32302132:	9301      	str	r3, [sp, #4]
32302134:	f000 f806 	bl	32302144 <_vfiprintf_r>
32302138:	b002      	add	sp, #8
3230213a:	f85d eb04 	ldr.w	lr, [sp], #4
3230213e:	b003      	add	sp, #12
32302140:	4770      	bx	lr
32302142:	bf00      	nop

32302144 <_vfiprintf_r>:
32302144:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32302148:	4683      	mov	fp, r0
3230214a:	4615      	mov	r5, r2
3230214c:	b0c7      	sub	sp, #284	@ 0x11c
3230214e:	2208      	movs	r2, #8
32302150:	f10d 0a58 	add.w	sl, sp, #88	@ 0x58
32302154:	461c      	mov	r4, r3
32302156:	4650      	mov	r0, sl
32302158:	9105      	str	r1, [sp, #20]
3230215a:	2100      	movs	r1, #0
3230215c:	930c      	str	r3, [sp, #48]	@ 0x30
3230215e:	f001 ff83 	bl	32304068 <memset>
32302162:	f1bb 0f00 	cmp.w	fp, #0
32302166:	d004      	beq.n	32302172 <_vfiprintf_r+0x2e>
32302168:	f8db 3034 	ldr.w	r3, [fp, #52]	@ 0x34
3230216c:	2b00      	cmp	r3, #0
3230216e:	f000 878e 	beq.w	3230308e <_vfiprintf_r+0xf4a>
32302172:	9a05      	ldr	r2, [sp, #20]
32302174:	6e53      	ldr	r3, [r2, #100]	@ 0x64
32302176:	f9b2 200c 	ldrsh.w	r2, [r2, #12]
3230217a:	07df      	lsls	r7, r3, #31
3230217c:	f140 8147 	bpl.w	3230240e <_vfiprintf_r+0x2ca>
32302180:	0496      	lsls	r6, r2, #18
32302182:	f100 85f8 	bmi.w	32302d76 <_vfiprintf_r+0xc32>
32302186:	9905      	ldr	r1, [sp, #20]
32302188:	f442 5200 	orr.w	r2, r2, #8192	@ 0x2000
3230218c:	f423 5300 	bic.w	r3, r3, #8192	@ 0x2000
32302190:	818a      	strh	r2, [r1, #12]
32302192:	b212      	sxth	r2, r2
32302194:	664b      	str	r3, [r1, #100]	@ 0x64
32302196:	0716      	lsls	r6, r2, #28
32302198:	f140 80c4 	bpl.w	32302324 <_vfiprintf_r+0x1e0>
3230219c:	9b05      	ldr	r3, [sp, #20]
3230219e:	691b      	ldr	r3, [r3, #16]
323021a0:	2b00      	cmp	r3, #0
323021a2:	f000 80bf 	beq.w	32302324 <_vfiprintf_r+0x1e0>
323021a6:	f002 031a 	and.w	r3, r2, #26
323021aa:	2b0a      	cmp	r3, #10
323021ac:	f000 80c9 	beq.w	32302342 <_vfiprintf_r+0x1fe>
323021b0:	f24c 1910 	movw	r9, #49424	@ 0xc110
323021b4:	f2c3 2930 	movt	r9, #12848	@ 0x3230
323021b8:	46a8      	mov	r8, r5
323021ba:	2300      	movs	r3, #0
323021bc:	aa1d      	add	r2, sp, #116	@ 0x74
323021be:	af1d      	add	r7, sp, #116	@ 0x74
323021c0:	921a      	str	r2, [sp, #104]	@ 0x68
323021c2:	f64b 3270 	movw	r2, #47984	@ 0xbb70
323021c6:	f2c3 2230 	movt	r2, #12848	@ 0x3230
323021ca:	e9cd 331b 	strd	r3, r3, [sp, #108]	@ 0x6c
323021ce:	930f      	str	r3, [sp, #60]	@ 0x3c
323021d0:	920e      	str	r2, [sp, #56]	@ 0x38
323021d2:	e9cd 3310 	strd	r3, r3, [sp, #64]	@ 0x40
323021d6:	9308      	str	r3, [sp, #32]
323021d8:	9704      	str	r7, [sp, #16]
323021da:	4645      	mov	r5, r8
323021dc:	f8d9 40e4 	ldr.w	r4, [r9, #228]	@ 0xe4
323021e0:	f002 fc7a 	bl	32304ad8 <__locale_mb_cur_max>
323021e4:	462a      	mov	r2, r5
323021e6:	4603      	mov	r3, r0
323021e8:	a914      	add	r1, sp, #80	@ 0x50
323021ea:	4658      	mov	r0, fp
323021ec:	f8cd a000 	str.w	sl, [sp]
323021f0:	47a0      	blx	r4
323021f2:	2800      	cmp	r0, #0
323021f4:	f000 80c4 	beq.w	32302380 <_vfiprintf_r+0x23c>
323021f8:	4603      	mov	r3, r0
323021fa:	f2c0 80b9 	blt.w	32302370 <_vfiprintf_r+0x22c>
323021fe:	9a14      	ldr	r2, [sp, #80]	@ 0x50
32302200:	2a25      	cmp	r2, #37	@ 0x25
32302202:	d001      	beq.n	32302208 <_vfiprintf_r+0xc4>
32302204:	441d      	add	r5, r3
32302206:	e7e9      	b.n	323021dc <_vfiprintf_r+0x98>
32302208:	4604      	mov	r4, r0
3230220a:	ebb5 0608 	subs.w	r6, r5, r8
3230220e:	f040 80bb 	bne.w	32302388 <_vfiprintf_r+0x244>
32302212:	2300      	movs	r3, #0
32302214:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32302218:	4619      	mov	r1, r3
3230221a:	9309      	str	r3, [sp, #36]	@ 0x24
3230221c:	786b      	ldrb	r3, [r5, #1]
3230221e:	f105 0801 	add.w	r8, r5, #1
32302222:	f04f 32ff 	mov.w	r2, #4294967295	@ 0xffffffff
32302226:	9103      	str	r1, [sp, #12]
32302228:	9207      	str	r2, [sp, #28]
3230222a:	f108 0801 	add.w	r8, r8, #1
3230222e:	f1a3 0220 	sub.w	r2, r3, #32
32302232:	2a5a      	cmp	r2, #90	@ 0x5a
32302234:	f200 80f5 	bhi.w	32302422 <_vfiprintf_r+0x2de>
32302238:	e8df f012 	tbh	[pc, r2, lsl #1]
3230223c:	00f30400 	.word	0x00f30400
32302240:	03f800f3 	.word	0x03f800f3
32302244:	00f300f3 	.word	0x00f300f3
32302248:	03d800f3 	.word	0x03d800f3
3230224c:	00f300f3 	.word	0x00f300f3
32302250:	02230211 	.word	0x02230211
32302254:	021c00f3 	.word	0x021c00f3
32302258:	00f30414 	.word	0x00f30414
3230225c:	005b040c 	.word	0x005b040c
32302260:	005b005b 	.word	0x005b005b
32302264:	005b005b 	.word	0x005b005b
32302268:	005b005b 	.word	0x005b005b
3230226c:	005b005b 	.word	0x005b005b
32302270:	00f300f3 	.word	0x00f300f3
32302274:	00f300f3 	.word	0x00f300f3
32302278:	00f300f3 	.word	0x00f300f3
3230227c:	00f300f3 	.word	0x00f300f3
32302280:	01d000f3 	.word	0x01d000f3
32302284:	00f30325 	.word	0x00f30325
32302288:	00f300f3 	.word	0x00f300f3
3230228c:	00f300f3 	.word	0x00f300f3
32302290:	00f300f3 	.word	0x00f300f3
32302294:	00f300f3 	.word	0x00f300f3
32302298:	022900f3 	.word	0x022900f3
3230229c:	00f300f3 	.word	0x00f300f3
323022a0:	01a200f3 	.word	0x01a200f3
323022a4:	029c00f3 	.word	0x029c00f3
323022a8:	00f300f3 	.word	0x00f300f3
323022ac:	00f305e1 	.word	0x00f305e1
323022b0:	00f300f3 	.word	0x00f300f3
323022b4:	00f300f3 	.word	0x00f300f3
323022b8:	00f300f3 	.word	0x00f300f3
323022bc:	00f300f3 	.word	0x00f300f3
323022c0:	01d000f3 	.word	0x01d000f3
323022c4:	00f30172 	.word	0x00f30172
323022c8:	00f300f3 	.word	0x00f300f3
323022cc:	017203ce 	.word	0x017203ce
323022d0:	00f3006d 	.word	0x00f3006d
323022d4:	00f3031b 	.word	0x00f3031b
323022d8:	02f8030d 	.word	0x02f8030d
323022dc:	006d02c6 	.word	0x006d02c6
323022e0:	01a200f3 	.word	0x01a200f3
323022e4:	025d006a 	.word	0x025d006a
323022e8:	00f300f3 	.word	0x00f300f3
323022ec:	00f30629 	.word	0x00f30629
323022f0:	006a      	.short	0x006a
323022f2:	f1a3 0230 	sub.w	r2, r3, #48	@ 0x30
323022f6:	2300      	movs	r3, #0
323022f8:	210a      	movs	r1, #10
323022fa:	4618      	mov	r0, r3
323022fc:	f818 3b01 	ldrb.w	r3, [r8], #1
32302300:	fb01 2000 	mla	r0, r1, r0, r2
32302304:	f1a3 0230 	sub.w	r2, r3, #48	@ 0x30
32302308:	2a09      	cmp	r2, #9
3230230a:	d9f7      	bls.n	323022fc <_vfiprintf_r+0x1b8>
3230230c:	9009      	str	r0, [sp, #36]	@ 0x24
3230230e:	e78e      	b.n	3230222e <_vfiprintf_r+0xea>
32302310:	f898 3000 	ldrb.w	r3, [r8]
32302314:	e789      	b.n	3230222a <_vfiprintf_r+0xe6>
32302316:	9b03      	ldr	r3, [sp, #12]
32302318:	f043 0320 	orr.w	r3, r3, #32
3230231c:	9303      	str	r3, [sp, #12]
3230231e:	f898 3000 	ldrb.w	r3, [r8]
32302322:	e782      	b.n	3230222a <_vfiprintf_r+0xe6>
32302324:	9e05      	ldr	r6, [sp, #20]
32302326:	4658      	mov	r0, fp
32302328:	4631      	mov	r1, r6
3230232a:	f001 fda9 	bl	32303e80 <__swsetup_r>
3230232e:	2800      	cmp	r0, #0
32302330:	f040 87f3 	bne.w	3230331a <_vfiprintf_r+0x11d6>
32302334:	f9b6 200c 	ldrsh.w	r2, [r6, #12]
32302338:	f002 031a 	and.w	r3, r2, #26
3230233c:	2b0a      	cmp	r3, #10
3230233e:	f47f af37 	bne.w	323021b0 <_vfiprintf_r+0x6c>
32302342:	9905      	ldr	r1, [sp, #20]
32302344:	f9b1 300e 	ldrsh.w	r3, [r1, #14]
32302348:	2b00      	cmp	r3, #0
3230234a:	f6ff af31 	blt.w	323021b0 <_vfiprintf_r+0x6c>
3230234e:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
32302350:	07d8      	lsls	r0, r3, #31
32302352:	d402      	bmi.n	3230235a <_vfiprintf_r+0x216>
32302354:	0592      	lsls	r2, r2, #22
32302356:	f140 873e 	bpl.w	323031d6 <_vfiprintf_r+0x1092>
3230235a:	9905      	ldr	r1, [sp, #20]
3230235c:	4623      	mov	r3, r4
3230235e:	462a      	mov	r2, r5
32302360:	4658      	mov	r0, fp
32302362:	f001 f80d 	bl	32303380 <__sbprintf>
32302366:	9008      	str	r0, [sp, #32]
32302368:	9808      	ldr	r0, [sp, #32]
3230236a:	b047      	add	sp, #284	@ 0x11c
3230236c:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32302370:	2208      	movs	r2, #8
32302372:	2100      	movs	r1, #0
32302374:	4650      	mov	r0, sl
32302376:	f001 fe77 	bl	32304068 <memset>
3230237a:	2301      	movs	r3, #1
3230237c:	441d      	add	r5, r3
3230237e:	e72d      	b.n	323021dc <_vfiprintf_r+0x98>
32302380:	4604      	mov	r4, r0
32302382:	ebb5 0608 	subs.w	r6, r5, r8
32302386:	d012      	beq.n	323023ae <_vfiprintf_r+0x26a>
32302388:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
3230238a:	9904      	ldr	r1, [sp, #16]
3230238c:	9a1c      	ldr	r2, [sp, #112]	@ 0x70
3230238e:	3301      	adds	r3, #1
32302390:	2b07      	cmp	r3, #7
32302392:	931b      	str	r3, [sp, #108]	@ 0x6c
32302394:	4432      	add	r2, r6
32302396:	e9c1 8600 	strd	r8, r6, [r1]
3230239a:	921c      	str	r2, [sp, #112]	@ 0x70
3230239c:	dc11      	bgt.n	323023c2 <_vfiprintf_r+0x27e>
3230239e:	3108      	adds	r1, #8
323023a0:	9104      	str	r1, [sp, #16]
323023a2:	9b08      	ldr	r3, [sp, #32]
323023a4:	4433      	add	r3, r6
323023a6:	9308      	str	r3, [sp, #32]
323023a8:	2c00      	cmp	r4, #0
323023aa:	f47f af32 	bne.w	32302212 <_vfiprintf_r+0xce>
323023ae:	9b1c      	ldr	r3, [sp, #112]	@ 0x70
323023b0:	2b00      	cmp	r3, #0
323023b2:	f040 8768 	bne.w	32303286 <_vfiprintf_r+0x1142>
323023b6:	9b05      	ldr	r3, [sp, #20]
323023b8:	2200      	movs	r2, #0
323023ba:	921b      	str	r2, [sp, #108]	@ 0x6c
323023bc:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
323023c0:	e019      	b.n	323023f6 <_vfiprintf_r+0x2b2>
323023c2:	9905      	ldr	r1, [sp, #20]
323023c4:	aa1a      	add	r2, sp, #104	@ 0x68
323023c6:	4658      	mov	r0, fp
323023c8:	f001 f826 	bl	32303418 <__sprint_r>
323023cc:	b980      	cbnz	r0, 323023f0 <_vfiprintf_r+0x2ac>
323023ce:	ab1d      	add	r3, sp, #116	@ 0x74
323023d0:	9304      	str	r3, [sp, #16]
323023d2:	e7e6      	b.n	323023a2 <_vfiprintf_r+0x25e>
323023d4:	9905      	ldr	r1, [sp, #20]
323023d6:	aa1a      	add	r2, sp, #104	@ 0x68
323023d8:	4658      	mov	r0, fp
323023da:	f001 f81d 	bl	32303418 <__sprint_r>
323023de:	2800      	cmp	r0, #0
323023e0:	f000 8089 	beq.w	323024f6 <_vfiprintf_r+0x3b2>
323023e4:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
323023e6:	b11b      	cbz	r3, 323023f0 <_vfiprintf_r+0x2ac>
323023e8:	990a      	ldr	r1, [sp, #40]	@ 0x28
323023ea:	4658      	mov	r0, fp
323023ec:	f003 f9fc 	bl	323057e8 <_free_r>
323023f0:	9b05      	ldr	r3, [sp, #20]
323023f2:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
323023f6:	9a05      	ldr	r2, [sp, #20]
323023f8:	6e52      	ldr	r2, [r2, #100]	@ 0x64
323023fa:	07d0      	lsls	r0, r2, #31
323023fc:	f140 8086 	bpl.w	3230250c <_vfiprintf_r+0x3c8>
32302400:	065b      	lsls	r3, r3, #25
32302402:	f100 8128 	bmi.w	32302656 <_vfiprintf_r+0x512>
32302406:	9808      	ldr	r0, [sp, #32]
32302408:	b047      	add	sp, #284	@ 0x11c
3230240a:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230240e:	0591      	lsls	r1, r2, #22
32302410:	f140 810a 	bpl.w	32302628 <_vfiprintf_r+0x4e4>
32302414:	0497      	lsls	r7, r2, #18
32302416:	f57f aeb6 	bpl.w	32302186 <_vfiprintf_r+0x42>
3230241a:	049e      	lsls	r6, r3, #18
3230241c:	f57f aebb 	bpl.w	32302196 <_vfiprintf_r+0x52>
32302420:	e111      	b.n	32302646 <_vfiprintf_r+0x502>
32302422:	2b00      	cmp	r3, #0
32302424:	d0c3      	beq.n	323023ae <_vfiprintf_r+0x26a>
32302426:	ad2d      	add	r5, sp, #180	@ 0xb4
32302428:	2201      	movs	r2, #1
3230242a:	f88d 30b4 	strb.w	r3, [sp, #180]	@ 0xb4
3230242e:	2300      	movs	r3, #0
32302430:	920b      	str	r2, [sp, #44]	@ 0x2c
32302432:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32302436:	930a      	str	r3, [sp, #40]	@ 0x28
32302438:	9307      	str	r3, [sp, #28]
3230243a:	9206      	str	r2, [sp, #24]
3230243c:	e9dd 301b 	ldrd	r3, r0, [sp, #108]	@ 0x6c
32302440:	9c03      	ldr	r4, [sp, #12]
32302442:	4601      	mov	r1, r0
32302444:	461a      	mov	r2, r3
32302446:	f014 0684 	ands.w	r6, r4, #132	@ 0x84
3230244a:	d12a      	bne.n	323024a2 <_vfiprintf_r+0x35e>
3230244c:	9c09      	ldr	r4, [sp, #36]	@ 0x24
3230244e:	9e06      	ldr	r6, [sp, #24]
32302450:	1ba4      	subs	r4, r4, r6
32302452:	2c00      	cmp	r4, #0
32302454:	f300 8423 	bgt.w	32302c9e <_vfiprintf_r+0xb5a>
32302458:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
3230245c:	b323      	cbz	r3, 323024a8 <_vfiprintf_r+0x364>
3230245e:	2600      	movs	r6, #0
32302460:	960d      	str	r6, [sp, #52]	@ 0x34
32302462:	9804      	ldr	r0, [sp, #16]
32302464:	3201      	adds	r2, #1
32302466:	2301      	movs	r3, #1
32302468:	3101      	adds	r1, #1
3230246a:	2a07      	cmp	r2, #7
3230246c:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32302470:	6043      	str	r3, [r0, #4]
32302472:	f10d 034b 	add.w	r3, sp, #75	@ 0x4b
32302476:	6003      	str	r3, [r0, #0]
32302478:	f300 83a3 	bgt.w	32302bc2 <_vfiprintf_r+0xa7e>
3230247c:	3008      	adds	r0, #8
3230247e:	9004      	str	r0, [sp, #16]
32302480:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32302482:	b173      	cbz	r3, 323024a2 <_vfiprintf_r+0x35e>
32302484:	9804      	ldr	r0, [sp, #16]
32302486:	3201      	adds	r2, #1
32302488:	ab13      	add	r3, sp, #76	@ 0x4c
3230248a:	3102      	adds	r1, #2
3230248c:	2a07      	cmp	r2, #7
3230248e:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32302492:	6003      	str	r3, [r0, #0]
32302494:	f04f 0302 	mov.w	r3, #2
32302498:	6043      	str	r3, [r0, #4]
3230249a:	f300 8385 	bgt.w	32302ba8 <_vfiprintf_r+0xa64>
3230249e:	3008      	adds	r0, #8
323024a0:	9004      	str	r0, [sp, #16]
323024a2:	2e80      	cmp	r6, #128	@ 0x80
323024a4:	f000 82fb 	beq.w	32302a9e <_vfiprintf_r+0x95a>
323024a8:	9b07      	ldr	r3, [sp, #28]
323024aa:	980b      	ldr	r0, [sp, #44]	@ 0x2c
323024ac:	1a1c      	subs	r4, r3, r0
323024ae:	2c00      	cmp	r4, #0
323024b0:	f300 8335 	bgt.w	32302b1e <_vfiprintf_r+0x9da>
323024b4:	9b04      	ldr	r3, [sp, #16]
323024b6:	3201      	adds	r2, #1
323024b8:	980b      	ldr	r0, [sp, #44]	@ 0x2c
323024ba:	2a07      	cmp	r2, #7
323024bc:	4401      	add	r1, r0
323024be:	601d      	str	r5, [r3, #0]
323024c0:	6058      	str	r0, [r3, #4]
323024c2:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
323024c6:	f300 8364 	bgt.w	32302b92 <_vfiprintf_r+0xa4e>
323024ca:	3308      	adds	r3, #8
323024cc:	461f      	mov	r7, r3
323024ce:	9b03      	ldr	r3, [sp, #12]
323024d0:	075c      	lsls	r4, r3, #29
323024d2:	d505      	bpl.n	323024e0 <_vfiprintf_r+0x39c>
323024d4:	9b09      	ldr	r3, [sp, #36]	@ 0x24
323024d6:	9a06      	ldr	r2, [sp, #24]
323024d8:	1a9c      	subs	r4, r3, r2
323024da:	2c00      	cmp	r4, #0
323024dc:	f300 837e 	bgt.w	32302bdc <_vfiprintf_r+0xa98>
323024e0:	9b09      	ldr	r3, [sp, #36]	@ 0x24
323024e2:	9a06      	ldr	r2, [sp, #24]
323024e4:	4293      	cmp	r3, r2
323024e6:	bfb8      	it	lt
323024e8:	4613      	movlt	r3, r2
323024ea:	9a08      	ldr	r2, [sp, #32]
323024ec:	441a      	add	r2, r3
323024ee:	9208      	str	r2, [sp, #32]
323024f0:	2900      	cmp	r1, #0
323024f2:	f47f af6f 	bne.w	323023d4 <_vfiprintf_r+0x290>
323024f6:	2300      	movs	r3, #0
323024f8:	931b      	str	r3, [sp, #108]	@ 0x6c
323024fa:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
323024fc:	b11b      	cbz	r3, 32302506 <_vfiprintf_r+0x3c2>
323024fe:	990a      	ldr	r1, [sp, #40]	@ 0x28
32302500:	4658      	mov	r0, fp
32302502:	f003 f971 	bl	323057e8 <_free_r>
32302506:	ab1d      	add	r3, sp, #116	@ 0x74
32302508:	9304      	str	r3, [sp, #16]
3230250a:	e666      	b.n	323021da <_vfiprintf_r+0x96>
3230250c:	059a      	lsls	r2, r3, #22
3230250e:	f53f af77 	bmi.w	32302400 <_vfiprintf_r+0x2bc>
32302512:	9c05      	ldr	r4, [sp, #20]
32302514:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32302516:	f002 fba7 	bl	32304c68 <__retarget_lock_release_recursive>
3230251a:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
3230251e:	e76f      	b.n	32302400 <_vfiprintf_r+0x2bc>
32302520:	9b03      	ldr	r3, [sp, #12]
32302522:	069e      	lsls	r6, r3, #26
32302524:	f140 8431 	bpl.w	32302d8a <_vfiprintf_r+0xc46>
32302528:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3230252a:	3307      	adds	r3, #7
3230252c:	f023 0307 	bic.w	r3, r3, #7
32302530:	461a      	mov	r2, r3
32302532:	685b      	ldr	r3, [r3, #4]
32302534:	f852 4b08 	ldr.w	r4, [r2], #8
32302538:	461e      	mov	r6, r3
3230253a:	920c      	str	r2, [sp, #48]	@ 0x30
3230253c:	2b00      	cmp	r3, #0
3230253e:	f2c0 81b3 	blt.w	323028a8 <_vfiprintf_r+0x764>
32302542:	9b07      	ldr	r3, [sp, #28]
32302544:	2b00      	cmp	r3, #0
32302546:	f2c0 80fd 	blt.w	32302744 <_vfiprintf_r+0x600>
3230254a:	9a03      	ldr	r2, [sp, #12]
3230254c:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
32302550:	9203      	str	r2, [sp, #12]
32302552:	1e1a      	subs	r2, r3, #0
32302554:	bf18      	it	ne
32302556:	2201      	movne	r2, #1
32302558:	ea54 0306 	orrs.w	r3, r4, r6
3230255c:	f042 0301 	orr.w	r3, r2, #1
32302560:	bf08      	it	eq
32302562:	4613      	moveq	r3, r2
32302564:	2b00      	cmp	r3, #0
32302566:	f040 80ed 	bne.w	32302744 <_vfiprintf_r+0x600>
3230256a:	f89d 204b 	ldrb.w	r2, [sp, #75]	@ 0x4b
3230256e:	2a00      	cmp	r2, #0
32302570:	f040 8598 	bne.w	323030a4 <_vfiprintf_r+0xf60>
32302574:	ad46      	add	r5, sp, #280	@ 0x118
32302576:	920a      	str	r2, [sp, #40]	@ 0x28
32302578:	9207      	str	r2, [sp, #28]
3230257a:	920b      	str	r2, [sp, #44]	@ 0x2c
3230257c:	9206      	str	r2, [sp, #24]
3230257e:	e75d      	b.n	3230243c <_vfiprintf_r+0x2f8>
32302580:	9e0c      	ldr	r6, [sp, #48]	@ 0x30
32302582:	2200      	movs	r2, #0
32302584:	f88d 204b 	strb.w	r2, [sp, #75]	@ 0x4b
32302588:	f856 2b04 	ldr.w	r2, [r6], #4
3230258c:	920a      	str	r2, [sp, #40]	@ 0x28
3230258e:	2a00      	cmp	r2, #0
32302590:	f000 858f 	beq.w	323030b2 <_vfiprintf_r+0xf6e>
32302594:	2b53      	cmp	r3, #83	@ 0x53
32302596:	f000 84c0 	beq.w	32302f1a <_vfiprintf_r+0xdd6>
3230259a:	9b03      	ldr	r3, [sp, #12]
3230259c:	f013 0410 	ands.w	r4, r3, #16
323025a0:	f040 84bb 	bne.w	32302f1a <_vfiprintf_r+0xdd6>
323025a4:	9a07      	ldr	r2, [sp, #28]
323025a6:	2a00      	cmp	r2, #0
323025a8:	f2c0 85fe 	blt.w	323031a8 <_vfiprintf_r+0x1064>
323025ac:	980a      	ldr	r0, [sp, #40]	@ 0x28
323025ae:	4621      	mov	r1, r4
323025b0:	f002 fd3e 	bl	32305030 <memchr>
323025b4:	f89d 204b 	ldrb.w	r2, [sp, #75]	@ 0x4b
323025b8:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
323025ba:	2800      	cmp	r0, #0
323025bc:	f000 8690 	beq.w	323032e0 <_vfiprintf_r+0x119c>
323025c0:	1b43      	subs	r3, r0, r5
323025c2:	930b      	str	r3, [sp, #44]	@ 0x2c
323025c4:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
323025c8:	9306      	str	r3, [sp, #24]
323025ca:	2a00      	cmp	r2, #0
323025cc:	f000 8682 	beq.w	323032d4 <_vfiprintf_r+0x1190>
323025d0:	3301      	adds	r3, #1
323025d2:	9407      	str	r4, [sp, #28]
323025d4:	9306      	str	r3, [sp, #24]
323025d6:	960c      	str	r6, [sp, #48]	@ 0x30
323025d8:	940a      	str	r4, [sp, #40]	@ 0x28
323025da:	e3bf      	b.n	32302d5c <_vfiprintf_r+0xc18>
323025dc:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
323025de:	2b43      	cmp	r3, #67	@ 0x43
323025e0:	f102 0404 	add.w	r4, r2, #4
323025e4:	d003      	beq.n	323025ee <_vfiprintf_r+0x4aa>
323025e6:	9b03      	ldr	r3, [sp, #12]
323025e8:	06db      	lsls	r3, r3, #27
323025ea:	f140 8478 	bpl.w	32302ede <_vfiprintf_r+0xd9a>
323025ee:	2208      	movs	r2, #8
323025f0:	2100      	movs	r1, #0
323025f2:	a818      	add	r0, sp, #96	@ 0x60
323025f4:	ad2d      	add	r5, sp, #180	@ 0xb4
323025f6:	f001 fd37 	bl	32304068 <memset>
323025fa:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
323025fc:	4629      	mov	r1, r5
323025fe:	4658      	mov	r0, fp
32302600:	681a      	ldr	r2, [r3, #0]
32302602:	ab18      	add	r3, sp, #96	@ 0x60
32302604:	f004 fbc4 	bl	32306d90 <_wcrtomb_r>
32302608:	4603      	mov	r3, r0
3230260a:	3301      	adds	r3, #1
3230260c:	900b      	str	r0, [sp, #44]	@ 0x2c
3230260e:	f000 864c 	beq.w	323032aa <_vfiprintf_r+0x1166>
32302612:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32302614:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
32302618:	9306      	str	r3, [sp, #24]
3230261a:	2300      	movs	r3, #0
3230261c:	940c      	str	r4, [sp, #48]	@ 0x30
3230261e:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32302622:	930a      	str	r3, [sp, #40]	@ 0x28
32302624:	9307      	str	r3, [sp, #28]
32302626:	e709      	b.n	3230243c <_vfiprintf_r+0x2f8>
32302628:	9e05      	ldr	r6, [sp, #20]
3230262a:	6db0      	ldr	r0, [r6, #88]	@ 0x58
3230262c:	f002 fb14 	bl	32304c58 <__retarget_lock_acquire_recursive>
32302630:	f9b6 200c 	ldrsh.w	r2, [r6, #12]
32302634:	6e73      	ldr	r3, [r6, #100]	@ 0x64
32302636:	0490      	lsls	r0, r2, #18
32302638:	f57f ada5 	bpl.w	32302186 <_vfiprintf_r+0x42>
3230263c:	0499      	lsls	r1, r3, #18
3230263e:	f57f adaa 	bpl.w	32302196 <_vfiprintf_r+0x52>
32302642:	07db      	lsls	r3, r3, #31
32302644:	d407      	bmi.n	32302656 <_vfiprintf_r+0x512>
32302646:	9b05      	ldr	r3, [sp, #20]
32302648:	899b      	ldrh	r3, [r3, #12]
3230264a:	059f      	lsls	r7, r3, #22
3230264c:	d403      	bmi.n	32302656 <_vfiprintf_r+0x512>
3230264e:	9b05      	ldr	r3, [sp, #20]
32302650:	6d98      	ldr	r0, [r3, #88]	@ 0x58
32302652:	f002 fb09 	bl	32304c68 <__retarget_lock_release_recursive>
32302656:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
3230265a:	9308      	str	r3, [sp, #32]
3230265c:	e6d3      	b.n	32302406 <_vfiprintf_r+0x2c2>
3230265e:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302660:	f853 2b04 	ldr.w	r2, [r3], #4
32302664:	9209      	str	r2, [sp, #36]	@ 0x24
32302666:	2a00      	cmp	r2, #0
32302668:	f280 836b 	bge.w	32302d42 <_vfiprintf_r+0xbfe>
3230266c:	9a09      	ldr	r2, [sp, #36]	@ 0x24
3230266e:	930c      	str	r3, [sp, #48]	@ 0x30
32302670:	4252      	negs	r2, r2
32302672:	9209      	str	r2, [sp, #36]	@ 0x24
32302674:	9b03      	ldr	r3, [sp, #12]
32302676:	f043 0304 	orr.w	r3, r3, #4
3230267a:	9303      	str	r3, [sp, #12]
3230267c:	f898 3000 	ldrb.w	r3, [r8]
32302680:	e5d3      	b.n	3230222a <_vfiprintf_r+0xe6>
32302682:	232b      	movs	r3, #43	@ 0x2b
32302684:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32302688:	f898 3000 	ldrb.w	r3, [r8]
3230268c:	e5cd      	b.n	3230222a <_vfiprintf_r+0xe6>
3230268e:	9b03      	ldr	r3, [sp, #12]
32302690:	f043 0010 	orr.w	r0, r3, #16
32302694:	069d      	lsls	r5, r3, #26
32302696:	f140 8397 	bpl.w	32302dc8 <_vfiprintf_r+0xc84>
3230269a:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3230269c:	3307      	adds	r3, #7
3230269e:	f023 0307 	bic.w	r3, r3, #7
323026a2:	6859      	ldr	r1, [r3, #4]
323026a4:	f853 2b08 	ldr.w	r2, [r3], #8
323026a8:	930c      	str	r3, [sp, #48]	@ 0x30
323026aa:	2300      	movs	r3, #0
323026ac:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
323026b0:	9b07      	ldr	r3, [sp, #28]
323026b2:	2b00      	cmp	r3, #0
323026b4:	f2c0 82ce 	blt.w	32302c54 <_vfiprintf_r+0xb10>
323026b8:	9b07      	ldr	r3, [sp, #28]
323026ba:	1e1c      	subs	r4, r3, #0
323026bc:	bf18      	it	ne
323026be:	2401      	movne	r4, #1
323026c0:	ea52 0301 	orrs.w	r3, r2, r1
323026c4:	f044 0301 	orr.w	r3, r4, #1
323026c8:	bf08      	it	eq
323026ca:	4623      	moveq	r3, r4
323026cc:	f420 6490 	bic.w	r4, r0, #1152	@ 0x480
323026d0:	9403      	str	r4, [sp, #12]
323026d2:	2b00      	cmp	r3, #0
323026d4:	f040 82c1 	bne.w	32302c5a <_vfiprintf_r+0xb16>
323026d8:	f010 0201 	ands.w	r2, r0, #1
323026dc:	9206      	str	r2, [sp, #24]
323026de:	f000 8329 	beq.w	32302d34 <_vfiprintf_r+0xbf0>
323026e2:	4619      	mov	r1, r3
323026e4:	9307      	str	r3, [sp, #28]
323026e6:	f20d 1517 	addw	r5, sp, #279	@ 0x117
323026ea:	2330      	movs	r3, #48	@ 0x30
323026ec:	920b      	str	r2, [sp, #44]	@ 0x2c
323026ee:	f88d 3117 	strb.w	r3, [sp, #279]	@ 0x117
323026f2:	910a      	str	r1, [sp, #40]	@ 0x28
323026f4:	e6a2      	b.n	3230243c <_vfiprintf_r+0x2f8>
323026f6:	9a03      	ldr	r2, [sp, #12]
323026f8:	0696      	lsls	r6, r2, #26
323026fa:	d441      	bmi.n	32302780 <_vfiprintf_r+0x63c>
323026fc:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
323026fe:	9a03      	ldr	r2, [sp, #12]
32302700:	f853 4b04 	ldr.w	r4, [r3], #4
32302704:	f012 0210 	ands.w	r2, r2, #16
32302708:	9206      	str	r2, [sp, #24]
3230270a:	9a03      	ldr	r2, [sp, #12]
3230270c:	f040 8350 	bne.w	32302db0 <_vfiprintf_r+0xc6c>
32302710:	f012 0240 	ands.w	r2, r2, #64	@ 0x40
32302714:	f000 84e5 	beq.w	323030e2 <_vfiprintf_r+0xf9e>
32302718:	9a07      	ldr	r2, [sp, #28]
3230271a:	b2a4      	uxth	r4, r4
3230271c:	9e06      	ldr	r6, [sp, #24]
3230271e:	2a00      	cmp	r2, #0
32302720:	f88d 604b 	strb.w	r6, [sp, #75]	@ 0x4b
32302724:	db0d      	blt.n	32302742 <_vfiprintf_r+0x5fe>
32302726:	9a03      	ldr	r2, [sp, #12]
32302728:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
3230272c:	9203      	str	r2, [sp, #12]
3230272e:	9a07      	ldr	r2, [sp, #28]
32302730:	2c00      	cmp	r4, #0
32302732:	bf08      	it	eq
32302734:	2a00      	cmpeq	r2, #0
32302736:	bf18      	it	ne
32302738:	2201      	movne	r2, #1
3230273a:	bf08      	it	eq
3230273c:	2200      	moveq	r2, #0
3230273e:	f000 8526 	beq.w	3230318e <_vfiprintf_r+0x104a>
32302742:	930c      	str	r3, [sp, #48]	@ 0x30
32302744:	2c0a      	cmp	r4, #10
32302746:	f176 0300 	sbcs.w	r3, r6, #0
3230274a:	f080 80c1 	bcs.w	323028d0 <_vfiprintf_r+0x78c>
3230274e:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
32302752:	3430      	adds	r4, #48	@ 0x30
32302754:	9a07      	ldr	r2, [sp, #28]
32302756:	f88d 4117 	strb.w	r4, [sp, #279]	@ 0x117
3230275a:	2a01      	cmp	r2, #1
3230275c:	bfb8      	it	lt
3230275e:	2201      	movlt	r2, #1
32302760:	9206      	str	r2, [sp, #24]
32302762:	2b00      	cmp	r3, #0
32302764:	f040 82f2 	bne.w	32302d4c <_vfiprintf_r+0xc08>
32302768:	930a      	str	r3, [sp, #40]	@ 0x28
3230276a:	f20d 1517 	addw	r5, sp, #279	@ 0x117
3230276e:	2301      	movs	r3, #1
32302770:	930b      	str	r3, [sp, #44]	@ 0x2c
32302772:	e663      	b.n	3230243c <_vfiprintf_r+0x2f8>
32302774:	9b03      	ldr	r3, [sp, #12]
32302776:	f043 0210 	orr.w	r2, r3, #16
3230277a:	069f      	lsls	r7, r3, #26
3230277c:	f140 8316 	bpl.w	32302dac <_vfiprintf_r+0xc68>
32302780:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302782:	2100      	movs	r1, #0
32302784:	f88d 104b 	strb.w	r1, [sp, #75]	@ 0x4b
32302788:	3307      	adds	r3, #7
3230278a:	f023 0307 	bic.w	r3, r3, #7
3230278e:	685e      	ldr	r6, [r3, #4]
32302790:	f853 4b08 	ldr.w	r4, [r3], #8
32302794:	930c      	str	r3, [sp, #48]	@ 0x30
32302796:	9b07      	ldr	r3, [sp, #28]
32302798:	428b      	cmp	r3, r1
3230279a:	f2c0 8313 	blt.w	32302dc4 <_vfiprintf_r+0xc80>
3230279e:	f022 0380 	bic.w	r3, r2, #128	@ 0x80
323027a2:	9303      	str	r3, [sp, #12]
323027a4:	9b07      	ldr	r3, [sp, #28]
323027a6:	1e1a      	subs	r2, r3, #0
323027a8:	bf18      	it	ne
323027aa:	2201      	movne	r2, #1
323027ac:	ea54 0306 	orrs.w	r3, r4, r6
323027b0:	f042 0301 	orr.w	r3, r2, #1
323027b4:	bf08      	it	eq
323027b6:	4613      	moveq	r3, r2
323027b8:	2b00      	cmp	r3, #0
323027ba:	d1c3      	bne.n	32302744 <_vfiprintf_r+0x600>
323027bc:	ad46      	add	r5, sp, #280	@ 0x118
323027be:	930a      	str	r3, [sp, #40]	@ 0x28
323027c0:	9307      	str	r3, [sp, #28]
323027c2:	930b      	str	r3, [sp, #44]	@ 0x2c
323027c4:	9306      	str	r3, [sp, #24]
323027c6:	e639      	b.n	3230243c <_vfiprintf_r+0x2f8>
323027c8:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
323027ca:	2100      	movs	r1, #0
323027cc:	9807      	ldr	r0, [sp, #28]
323027ce:	f647 0230 	movw	r2, #30768	@ 0x7830
323027d2:	f88d 104b 	strb.w	r1, [sp, #75]	@ 0x4b
323027d6:	f8ad 204c 	strh.w	r2, [sp, #76]	@ 0x4c
323027da:	4288      	cmp	r0, r1
323027dc:	f853 2b04 	ldr.w	r2, [r3], #4
323027e0:	f2c0 835a 	blt.w	32302e98 <_vfiprintf_r+0xd54>
323027e4:	9803      	ldr	r0, [sp, #12]
323027e6:	f020 0080 	bic.w	r0, r0, #128	@ 0x80
323027ea:	f040 0002 	orr.w	r0, r0, #2
323027ee:	9003      	str	r0, [sp, #12]
323027f0:	9807      	ldr	r0, [sp, #28]
323027f2:	2a00      	cmp	r2, #0
323027f4:	bf08      	it	eq
323027f6:	2800      	cmpeq	r0, #0
323027f8:	bf18      	it	ne
323027fa:	2001      	movne	r0, #1
323027fc:	bf08      	it	eq
323027fe:	2000      	moveq	r0, #0
32302800:	f040 8599 	bne.w	32303336 <_vfiprintf_r+0x11f2>
32302804:	ad46      	add	r5, sp, #280	@ 0x118
32302806:	9007      	str	r0, [sp, #28]
32302808:	930c      	str	r3, [sp, #48]	@ 0x30
3230280a:	9006      	str	r0, [sp, #24]
3230280c:	900b      	str	r0, [sp, #44]	@ 0x2c
3230280e:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32302812:	9b06      	ldr	r3, [sp, #24]
32302814:	9c03      	ldr	r4, [sp, #12]
32302816:	4608      	mov	r0, r1
32302818:	3302      	adds	r3, #2
3230281a:	9306      	str	r3, [sp, #24]
3230281c:	f014 0684 	ands.w	r6, r4, #132	@ 0x84
32302820:	4613      	mov	r3, r2
32302822:	f000 83cc 	beq.w	32302fbe <_vfiprintf_r+0xe7a>
32302826:	2300      	movs	r3, #0
32302828:	930a      	str	r3, [sp, #40]	@ 0x28
3230282a:	e62b      	b.n	32302484 <_vfiprintf_r+0x340>
3230282c:	9803      	ldr	r0, [sp, #12]
3230282e:	0684      	lsls	r4, r0, #26
32302830:	f53f af33 	bmi.w	3230269a <_vfiprintf_r+0x556>
32302834:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302836:	9903      	ldr	r1, [sp, #12]
32302838:	f853 2b04 	ldr.w	r2, [r3], #4
3230283c:	f011 0110 	ands.w	r1, r1, #16
32302840:	f040 8582 	bne.w	32303348 <_vfiprintf_r+0x1204>
32302844:	9c03      	ldr	r4, [sp, #12]
32302846:	f014 0040 	ands.w	r0, r4, #64	@ 0x40
3230284a:	f000 8440 	beq.w	323030ce <_vfiprintf_r+0xf8a>
3230284e:	b292      	uxth	r2, r2
32302850:	4620      	mov	r0, r4
32302852:	930c      	str	r3, [sp, #48]	@ 0x30
32302854:	e729      	b.n	323026aa <_vfiprintf_r+0x566>
32302856:	9b03      	ldr	r3, [sp, #12]
32302858:	069a      	lsls	r2, r3, #26
3230285a:	f140 82bc 	bpl.w	32302dd6 <_vfiprintf_r+0xc92>
3230285e:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302860:	9a08      	ldr	r2, [sp, #32]
32302862:	681b      	ldr	r3, [r3, #0]
32302864:	601a      	str	r2, [r3, #0]
32302866:	17d2      	asrs	r2, r2, #31
32302868:	605a      	str	r2, [r3, #4]
3230286a:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3230286c:	3304      	adds	r3, #4
3230286e:	930c      	str	r3, [sp, #48]	@ 0x30
32302870:	e4b3      	b.n	323021da <_vfiprintf_r+0x96>
32302872:	f898 3000 	ldrb.w	r3, [r8]
32302876:	2b6c      	cmp	r3, #108	@ 0x6c
32302878:	f000 8345 	beq.w	32302f06 <_vfiprintf_r+0xdc2>
3230287c:	9a03      	ldr	r2, [sp, #12]
3230287e:	f042 0210 	orr.w	r2, r2, #16
32302882:	9203      	str	r2, [sp, #12]
32302884:	e4d1      	b.n	3230222a <_vfiprintf_r+0xe6>
32302886:	9b03      	ldr	r3, [sp, #12]
32302888:	f043 0210 	orr.w	r2, r3, #16
3230288c:	069f      	lsls	r7, r3, #26
3230288e:	f100 82b3 	bmi.w	32302df8 <_vfiprintf_r+0xcb4>
32302892:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302894:	3304      	adds	r3, #4
32302896:	990c      	ldr	r1, [sp, #48]	@ 0x30
32302898:	930c      	str	r3, [sp, #48]	@ 0x30
3230289a:	9203      	str	r2, [sp, #12]
3230289c:	680c      	ldr	r4, [r1, #0]
3230289e:	17e6      	asrs	r6, r4, #31
323028a0:	4633      	mov	r3, r6
323028a2:	2b00      	cmp	r3, #0
323028a4:	f6bf ae4d 	bge.w	32302542 <_vfiprintf_r+0x3fe>
323028a8:	4264      	negs	r4, r4
323028aa:	f04f 032d 	mov.w	r3, #45	@ 0x2d
323028ae:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
323028b2:	9b07      	ldr	r3, [sp, #28]
323028b4:	eb66 0646 	sbc.w	r6, r6, r6, lsl #1
323028b8:	2b00      	cmp	r3, #0
323028ba:	f6ff af43 	blt.w	32302744 <_vfiprintf_r+0x600>
323028be:	9b03      	ldr	r3, [sp, #12]
323028c0:	2c0a      	cmp	r4, #10
323028c2:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
323028c6:	9303      	str	r3, [sp, #12]
323028c8:	f176 0300 	sbcs.w	r3, r6, #0
323028cc:	f4ff af3f 	bcc.w	3230274e <_vfiprintf_r+0x60a>
323028d0:	9b03      	ldr	r3, [sp, #12]
323028d2:	f64c 4ecd 	movw	lr, #52429	@ 0xcccd
323028d6:	f6cc 4ecc 	movt	lr, #52428	@ 0xcccc
323028da:	f8cd 902c 	str.w	r9, [sp, #44]	@ 0x2c
323028de:	f403 6580 	and.w	r5, r3, #1024	@ 0x400
323028e2:	2300      	movs	r3, #0
323028e4:	4677      	mov	r7, lr
323028e6:	f8dd 903c 	ldr.w	r9, [sp, #60]	@ 0x3c
323028ea:	a946      	add	r1, sp, #280	@ 0x118
323028ec:	469e      	mov	lr, r3
323028ee:	f8cd b018 	str.w	fp, [sp, #24]
323028f2:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
323028f6:	e023      	b.n	32302940 <_vfiprintf_r+0x7fc>
323028f8:	19a3      	adds	r3, r4, r6
323028fa:	4630      	mov	r0, r6
323028fc:	f143 0300 	adc.w	r3, r3, #0
32302900:	46a3      	mov	fp, r4
32302902:	4641      	mov	r1, r8
32302904:	fba7 2c03 	umull	r2, ip, r7, r3
32302908:	f02c 0203 	bic.w	r2, ip, #3
3230290c:	eb02 029c 	add.w	r2, r2, ip, lsr #2
32302910:	1a9b      	subs	r3, r3, r2
32302912:	f04f 32cc 	mov.w	r2, #3435973836	@ 0xcccccccc
32302916:	1ae3      	subs	r3, r4, r3
32302918:	f166 0600 	sbc.w	r6, r6, #0
3230291c:	f1bb 0f0a 	cmp.w	fp, #10
32302920:	f170 0000 	sbcs.w	r0, r0, #0
32302924:	fb02 f203 	mul.w	r2, r2, r3
32302928:	fb07 2206 	mla	r2, r7, r6, r2
3230292c:	fba3 4307 	umull	r4, r3, r3, r7
32302930:	4413      	add	r3, r2
32302932:	ea4f 0454 	mov.w	r4, r4, lsr #1
32302936:	ea44 74c3 	orr.w	r4, r4, r3, lsl #31
3230293a:	ea4f 0653 	mov.w	r6, r3, lsr #1
3230293e:	d332      	bcc.n	323029a6 <_vfiprintf_r+0x862>
32302940:	19a3      	adds	r3, r4, r6
32302942:	f10e 0e01 	add.w	lr, lr, #1
32302946:	f143 0300 	adc.w	r3, r3, #0
3230294a:	f101 38ff 	add.w	r8, r1, #4294967295	@ 0xffffffff
3230294e:	fba7 2003 	umull	r2, r0, r7, r3
32302952:	f020 0203 	bic.w	r2, r0, #3
32302956:	eb02 0290 	add.w	r2, r2, r0, lsr #2
3230295a:	1a9b      	subs	r3, r3, r2
3230295c:	1ae3      	subs	r3, r4, r3
3230295e:	f166 0000 	sbc.w	r0, r6, #0
32302962:	fba3 3207 	umull	r3, r2, r3, r7
32302966:	085b      	lsrs	r3, r3, #1
32302968:	fb07 2200 	mla	r2, r7, r0, r2
3230296c:	ea43 73c2 	orr.w	r3, r3, r2, lsl #31
32302970:	eb03 0383 	add.w	r3, r3, r3, lsl #2
32302974:	eba4 0343 	sub.w	r3, r4, r3, lsl #1
32302978:	3330      	adds	r3, #48	@ 0x30
3230297a:	f801 3c01 	strb.w	r3, [r1, #-1]
3230297e:	2d00      	cmp	r5, #0
32302980:	d0ba      	beq.n	323028f8 <_vfiprintf_r+0x7b4>
32302982:	f899 3000 	ldrb.w	r3, [r9]
32302986:	eba3 020e 	sub.w	r2, r3, lr
3230298a:	2bff      	cmp	r3, #255	@ 0xff
3230298c:	fab2 f282 	clz	r2, r2
32302990:	ea4f 1252 	mov.w	r2, r2, lsr #5
32302994:	bf08      	it	eq
32302996:	2200      	moveq	r2, #0
32302998:	2a00      	cmp	r2, #0
3230299a:	d0ad      	beq.n	323028f8 <_vfiprintf_r+0x7b4>
3230299c:	2c0a      	cmp	r4, #10
3230299e:	f176 0300 	sbcs.w	r3, r6, #0
323029a2:	f080 841d 	bcs.w	323031e0 <_vfiprintf_r+0x109c>
323029a6:	4645      	mov	r5, r8
323029a8:	ab46      	add	r3, sp, #280	@ 0x118
323029aa:	1b5b      	subs	r3, r3, r5
323029ac:	f8cd 903c 	str.w	r9, [sp, #60]	@ 0x3c
323029b0:	461a      	mov	r2, r3
323029b2:	9907      	ldr	r1, [sp, #28]
323029b4:	e9dd 890a 	ldrd	r8, r9, [sp, #40]	@ 0x28
323029b8:	930b      	str	r3, [sp, #44]	@ 0x2c
323029ba:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
323029be:	4291      	cmp	r1, r2
323029c0:	f8dd b018 	ldr.w	fp, [sp, #24]
323029c4:	bfb8      	it	lt
323029c6:	4611      	movlt	r1, r2
323029c8:	9106      	str	r1, [sp, #24]
323029ca:	2b00      	cmp	r3, #0
323029cc:	f000 824c 	beq.w	32302e68 <_vfiprintf_r+0xd24>
323029d0:	9b06      	ldr	r3, [sp, #24]
323029d2:	3301      	adds	r3, #1
323029d4:	9306      	str	r3, [sp, #24]
323029d6:	e247      	b.n	32302e68 <_vfiprintf_r+0xd24>
323029d8:	f898 3000 	ldrb.w	r3, [r8]
323029dc:	2b68      	cmp	r3, #104	@ 0x68
323029de:	f000 8288 	beq.w	32302ef2 <_vfiprintf_r+0xdae>
323029e2:	9a03      	ldr	r2, [sp, #12]
323029e4:	f042 0240 	orr.w	r2, r2, #64	@ 0x40
323029e8:	9203      	str	r2, [sp, #12]
323029ea:	e41e      	b.n	3230222a <_vfiprintf_r+0xe6>
323029ec:	4658      	mov	r0, fp
323029ee:	f002 f887 	bl	32304b00 <_localeconv_r>
323029f2:	6843      	ldr	r3, [r0, #4]
323029f4:	9311      	str	r3, [sp, #68]	@ 0x44
323029f6:	4618      	mov	r0, r3
323029f8:	f002 fe22 	bl	32305640 <strlen>
323029fc:	4604      	mov	r4, r0
323029fe:	9010      	str	r0, [sp, #64]	@ 0x40
32302a00:	4658      	mov	r0, fp
32302a02:	f002 f87d 	bl	32304b00 <_localeconv_r>
32302a06:	6882      	ldr	r2, [r0, #8]
32302a08:	f898 3000 	ldrb.w	r3, [r8]
32302a0c:	2c00      	cmp	r4, #0
32302a0e:	bf18      	it	ne
32302a10:	2a00      	cmpne	r2, #0
32302a12:	920f      	str	r2, [sp, #60]	@ 0x3c
32302a14:	f43f ac09 	beq.w	3230222a <_vfiprintf_r+0xe6>
32302a18:	7812      	ldrb	r2, [r2, #0]
32302a1a:	2a00      	cmp	r2, #0
32302a1c:	f43f ac05 	beq.w	3230222a <_vfiprintf_r+0xe6>
32302a20:	9a03      	ldr	r2, [sp, #12]
32302a22:	f442 6280 	orr.w	r2, r2, #1024	@ 0x400
32302a26:	9203      	str	r2, [sp, #12]
32302a28:	f7ff bbff 	b.w	3230222a <_vfiprintf_r+0xe6>
32302a2c:	9b03      	ldr	r3, [sp, #12]
32302a2e:	f043 0301 	orr.w	r3, r3, #1
32302a32:	9303      	str	r3, [sp, #12]
32302a34:	f898 3000 	ldrb.w	r3, [r8]
32302a38:	f7ff bbf7 	b.w	3230222a <_vfiprintf_r+0xe6>
32302a3c:	f89d 204b 	ldrb.w	r2, [sp, #75]	@ 0x4b
32302a40:	f898 3000 	ldrb.w	r3, [r8]
32302a44:	2a00      	cmp	r2, #0
32302a46:	f47f abf0 	bne.w	3230222a <_vfiprintf_r+0xe6>
32302a4a:	2220      	movs	r2, #32
32302a4c:	f88d 204b 	strb.w	r2, [sp, #75]	@ 0x4b
32302a50:	f7ff bbeb 	b.w	3230222a <_vfiprintf_r+0xe6>
32302a54:	9b03      	ldr	r3, [sp, #12]
32302a56:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
32302a5a:	9303      	str	r3, [sp, #12]
32302a5c:	f898 3000 	ldrb.w	r3, [r8]
32302a60:	f7ff bbe3 	b.w	3230222a <_vfiprintf_r+0xe6>
32302a64:	4641      	mov	r1, r8
32302a66:	f811 3b01 	ldrb.w	r3, [r1], #1
32302a6a:	2b2a      	cmp	r3, #42	@ 0x2a
32302a6c:	f000 8449 	beq.w	32303302 <_vfiprintf_r+0x11be>
32302a70:	f1a3 0230 	sub.w	r2, r3, #48	@ 0x30
32302a74:	2a09      	cmp	r2, #9
32302a76:	bf98      	it	ls
32302a78:	2000      	movls	r0, #0
32302a7a:	bf98      	it	ls
32302a7c:	240a      	movls	r4, #10
32302a7e:	f200 83fd 	bhi.w	3230327c <_vfiprintf_r+0x1138>
32302a82:	f811 3b01 	ldrb.w	r3, [r1], #1
32302a86:	fb04 2000 	mla	r0, r4, r0, r2
32302a8a:	f1a3 0230 	sub.w	r2, r3, #48	@ 0x30
32302a8e:	2a09      	cmp	r2, #9
32302a90:	d9f7      	bls.n	32302a82 <_vfiprintf_r+0x93e>
32302a92:	ea40 72e0 	orr.w	r2, r0, r0, asr #31
32302a96:	4688      	mov	r8, r1
32302a98:	9207      	str	r2, [sp, #28]
32302a9a:	f7ff bbc8 	b.w	3230222e <_vfiprintf_r+0xea>
32302a9e:	9b09      	ldr	r3, [sp, #36]	@ 0x24
32302aa0:	9806      	ldr	r0, [sp, #24]
32302aa2:	1a1c      	subs	r4, r3, r0
32302aa4:	2c00      	cmp	r4, #0
32302aa6:	f77f acff 	ble.w	323024a8 <_vfiprintf_r+0x364>
32302aaa:	f64b 3770 	movw	r7, #47984	@ 0xbb70
32302aae:	f2c3 2730 	movt	r7, #12848	@ 0x3230
32302ab2:	2c10      	cmp	r4, #16
32302ab4:	dd21      	ble.n	32302afa <_vfiprintf_r+0x9b6>
32302ab6:	950d      	str	r5, [sp, #52]	@ 0x34
32302ab8:	2610      	movs	r6, #16
32302aba:	9804      	ldr	r0, [sp, #16]
32302abc:	9d05      	ldr	r5, [sp, #20]
32302abe:	e002      	b.n	32302ac6 <_vfiprintf_r+0x982>
32302ac0:	3c10      	subs	r4, #16
32302ac2:	2c10      	cmp	r4, #16
32302ac4:	dd17      	ble.n	32302af6 <_vfiprintf_r+0x9b2>
32302ac6:	3201      	adds	r2, #1
32302ac8:	3110      	adds	r1, #16
32302aca:	2a07      	cmp	r2, #7
32302acc:	e9c0 7600 	strd	r7, r6, [r0]
32302ad0:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32302ad4:	bfd8      	it	le
32302ad6:	3008      	addle	r0, #8
32302ad8:	ddf2      	ble.n	32302ac0 <_vfiprintf_r+0x97c>
32302ada:	aa1a      	add	r2, sp, #104	@ 0x68
32302adc:	4629      	mov	r1, r5
32302ade:	4658      	mov	r0, fp
32302ae0:	f000 fc9a 	bl	32303418 <__sprint_r>
32302ae4:	2800      	cmp	r0, #0
32302ae6:	f47f ac7d 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302aea:	3c10      	subs	r4, #16
32302aec:	a81d      	add	r0, sp, #116	@ 0x74
32302aee:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32302af2:	2c10      	cmp	r4, #16
32302af4:	dce7      	bgt.n	32302ac6 <_vfiprintf_r+0x982>
32302af6:	9d0d      	ldr	r5, [sp, #52]	@ 0x34
32302af8:	9004      	str	r0, [sp, #16]
32302afa:	9b04      	ldr	r3, [sp, #16]
32302afc:	3201      	adds	r2, #1
32302afe:	4421      	add	r1, r4
32302b00:	2a07      	cmp	r2, #7
32302b02:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32302b06:	601f      	str	r7, [r3, #0]
32302b08:	605c      	str	r4, [r3, #4]
32302b0a:	f300 828f 	bgt.w	3230302c <_vfiprintf_r+0xee8>
32302b0e:	3308      	adds	r3, #8
32302b10:	980b      	ldr	r0, [sp, #44]	@ 0x2c
32302b12:	9304      	str	r3, [sp, #16]
32302b14:	9b07      	ldr	r3, [sp, #28]
32302b16:	1a1c      	subs	r4, r3, r0
32302b18:	2c00      	cmp	r4, #0
32302b1a:	f77f accb 	ble.w	323024b4 <_vfiprintf_r+0x370>
32302b1e:	f64b 3770 	movw	r7, #47984	@ 0xbb70
32302b22:	f2c3 2730 	movt	r7, #12848	@ 0x3230
32302b26:	2c10      	cmp	r4, #16
32302b28:	dd26      	ble.n	32302b78 <_vfiprintf_r+0xa34>
32302b2a:	9b0e      	ldr	r3, [sp, #56]	@ 0x38
32302b2c:	2610      	movs	r6, #16
32302b2e:	9507      	str	r5, [sp, #28]
32302b30:	f8dd c010 	ldr.w	ip, [sp, #16]
32302b34:	461f      	mov	r7, r3
32302b36:	461d      	mov	r5, r3
32302b38:	e002      	b.n	32302b40 <_vfiprintf_r+0x9fc>
32302b3a:	3c10      	subs	r4, #16
32302b3c:	2c10      	cmp	r4, #16
32302b3e:	dd18      	ble.n	32302b72 <_vfiprintf_r+0xa2e>
32302b40:	3201      	adds	r2, #1
32302b42:	3110      	adds	r1, #16
32302b44:	e9cc 5600 	strd	r5, r6, [ip]
32302b48:	2a07      	cmp	r2, #7
32302b4a:	f10c 0c08 	add.w	ip, ip, #8
32302b4e:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32302b52:	ddf2      	ble.n	32302b3a <_vfiprintf_r+0x9f6>
32302b54:	9905      	ldr	r1, [sp, #20]
32302b56:	aa1a      	add	r2, sp, #104	@ 0x68
32302b58:	4658      	mov	r0, fp
32302b5a:	f000 fc5d 	bl	32303418 <__sprint_r>
32302b5e:	f10d 0c74 	add.w	ip, sp, #116	@ 0x74
32302b62:	2800      	cmp	r0, #0
32302b64:	f47f ac3e 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302b68:	3c10      	subs	r4, #16
32302b6a:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32302b6e:	2c10      	cmp	r4, #16
32302b70:	dce6      	bgt.n	32302b40 <_vfiprintf_r+0x9fc>
32302b72:	9d07      	ldr	r5, [sp, #28]
32302b74:	f8cd c010 	str.w	ip, [sp, #16]
32302b78:	9b04      	ldr	r3, [sp, #16]
32302b7a:	3201      	adds	r2, #1
32302b7c:	4421      	add	r1, r4
32302b7e:	2a07      	cmp	r2, #7
32302b80:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32302b84:	601f      	str	r7, [r3, #0]
32302b86:	605c      	str	r4, [r3, #4]
32302b88:	f300 80c6 	bgt.w	32302d18 <_vfiprintf_r+0xbd4>
32302b8c:	3308      	adds	r3, #8
32302b8e:	9304      	str	r3, [sp, #16]
32302b90:	e490      	b.n	323024b4 <_vfiprintf_r+0x370>
32302b92:	9905      	ldr	r1, [sp, #20]
32302b94:	aa1a      	add	r2, sp, #104	@ 0x68
32302b96:	4658      	mov	r0, fp
32302b98:	f000 fc3e 	bl	32303418 <__sprint_r>
32302b9c:	2800      	cmp	r0, #0
32302b9e:	f47f ac21 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302ba2:	991c      	ldr	r1, [sp, #112]	@ 0x70
32302ba4:	af1d      	add	r7, sp, #116	@ 0x74
32302ba6:	e492      	b.n	323024ce <_vfiprintf_r+0x38a>
32302ba8:	9905      	ldr	r1, [sp, #20]
32302baa:	aa1a      	add	r2, sp, #104	@ 0x68
32302bac:	4658      	mov	r0, fp
32302bae:	f000 fc33 	bl	32303418 <__sprint_r>
32302bb2:	2800      	cmp	r0, #0
32302bb4:	f47f ac16 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302bb8:	ab1d      	add	r3, sp, #116	@ 0x74
32302bba:	9304      	str	r3, [sp, #16]
32302bbc:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32302bc0:	e46f      	b.n	323024a2 <_vfiprintf_r+0x35e>
32302bc2:	9905      	ldr	r1, [sp, #20]
32302bc4:	aa1a      	add	r2, sp, #104	@ 0x68
32302bc6:	4658      	mov	r0, fp
32302bc8:	f000 fc26 	bl	32303418 <__sprint_r>
32302bcc:	2800      	cmp	r0, #0
32302bce:	f47f ac09 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302bd2:	ab1d      	add	r3, sp, #116	@ 0x74
32302bd4:	9304      	str	r3, [sp, #16]
32302bd6:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32302bda:	e451      	b.n	32302480 <_vfiprintf_r+0x33c>
32302bdc:	f64b 3680 	movw	r6, #48000	@ 0xbb80
32302be0:	f2c3 2630 	movt	r6, #12848	@ 0x3230
32302be4:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32302be6:	2c10      	cmp	r4, #16
32302be8:	dd21      	ble.n	32302c2e <_vfiprintf_r+0xaea>
32302bea:	463a      	mov	r2, r7
32302bec:	2510      	movs	r5, #16
32302bee:	4637      	mov	r7, r6
32302bf0:	9e05      	ldr	r6, [sp, #20]
32302bf2:	e002      	b.n	32302bfa <_vfiprintf_r+0xab6>
32302bf4:	3c10      	subs	r4, #16
32302bf6:	2c10      	cmp	r4, #16
32302bf8:	dd17      	ble.n	32302c2a <_vfiprintf_r+0xae6>
32302bfa:	3301      	adds	r3, #1
32302bfc:	3110      	adds	r1, #16
32302bfe:	2b07      	cmp	r3, #7
32302c00:	e9c2 7500 	strd	r7, r5, [r2]
32302c04:	e9cd 311b 	strd	r3, r1, [sp, #108]	@ 0x6c
32302c08:	bfd8      	it	le
32302c0a:	3208      	addle	r2, #8
32302c0c:	ddf2      	ble.n	32302bf4 <_vfiprintf_r+0xab0>
32302c0e:	aa1a      	add	r2, sp, #104	@ 0x68
32302c10:	4631      	mov	r1, r6
32302c12:	4658      	mov	r0, fp
32302c14:	f000 fc00 	bl	32303418 <__sprint_r>
32302c18:	aa1d      	add	r2, sp, #116	@ 0x74
32302c1a:	2800      	cmp	r0, #0
32302c1c:	f47f abe2 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302c20:	3c10      	subs	r4, #16
32302c22:	e9dd 311b 	ldrd	r3, r1, [sp, #108]	@ 0x6c
32302c26:	2c10      	cmp	r4, #16
32302c28:	dce7      	bgt.n	32302bfa <_vfiprintf_r+0xab6>
32302c2a:	463e      	mov	r6, r7
32302c2c:	4617      	mov	r7, r2
32302c2e:	3301      	adds	r3, #1
32302c30:	4421      	add	r1, r4
32302c32:	2b07      	cmp	r3, #7
32302c34:	e9c7 6400 	strd	r6, r4, [r7]
32302c38:	e9cd 311b 	strd	r3, r1, [sp, #108]	@ 0x6c
32302c3c:	f77f ac50 	ble.w	323024e0 <_vfiprintf_r+0x39c>
32302c40:	9905      	ldr	r1, [sp, #20]
32302c42:	aa1a      	add	r2, sp, #104	@ 0x68
32302c44:	4658      	mov	r0, fp
32302c46:	f000 fbe7 	bl	32303418 <__sprint_r>
32302c4a:	2800      	cmp	r0, #0
32302c4c:	f47f abca 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302c50:	991c      	ldr	r1, [sp, #112]	@ 0x70
32302c52:	e445      	b.n	323024e0 <_vfiprintf_r+0x39c>
32302c54:	f420 6380 	bic.w	r3, r0, #1024	@ 0x400
32302c58:	9303      	str	r3, [sp, #12]
32302c5a:	ad46      	add	r5, sp, #280	@ 0x118
32302c5c:	08d0      	lsrs	r0, r2, #3
32302c5e:	f002 0307 	and.w	r3, r2, #7
32302c62:	ea40 7241 	orr.w	r2, r0, r1, lsl #29
32302c66:	08c9      	lsrs	r1, r1, #3
32302c68:	3330      	adds	r3, #48	@ 0x30
32302c6a:	4628      	mov	r0, r5
32302c6c:	ea52 0401 	orrs.w	r4, r2, r1
32302c70:	f805 3d01 	strb.w	r3, [r5, #-1]!
32302c74:	d1f2      	bne.n	32302c5c <_vfiprintf_r+0xb18>
32302c76:	9a03      	ldr	r2, [sp, #12]
32302c78:	2b30      	cmp	r3, #48	@ 0x30
32302c7a:	f002 0201 	and.w	r2, r2, #1
32302c7e:	bf08      	it	eq
32302c80:	2200      	moveq	r2, #0
32302c82:	2a00      	cmp	r2, #0
32302c84:	f040 81f2 	bne.w	3230306c <_vfiprintf_r+0xf28>
32302c88:	ab46      	add	r3, sp, #280	@ 0x118
32302c8a:	920a      	str	r2, [sp, #40]	@ 0x28
32302c8c:	9a07      	ldr	r2, [sp, #28]
32302c8e:	1b5b      	subs	r3, r3, r5
32302c90:	930b      	str	r3, [sp, #44]	@ 0x2c
32302c92:	429a      	cmp	r2, r3
32302c94:	bfb8      	it	lt
32302c96:	461a      	movlt	r2, r3
32302c98:	9206      	str	r2, [sp, #24]
32302c9a:	f7ff bbcf 	b.w	3230243c <_vfiprintf_r+0x2f8>
32302c9e:	2200      	movs	r2, #0
32302ca0:	920d      	str	r2, [sp, #52]	@ 0x34
32302ca2:	461a      	mov	r2, r3
32302ca4:	f64b 3680 	movw	r6, #48000	@ 0xbb80
32302ca8:	f2c3 2630 	movt	r6, #12848	@ 0x3230
32302cac:	2310      	movs	r3, #16
32302cae:	e9dd 1704 	ldrd	r1, r7, [sp, #16]
32302cb2:	2c10      	cmp	r4, #16
32302cb4:	dc03      	bgt.n	32302cbe <_vfiprintf_r+0xb7a>
32302cb6:	e01c      	b.n	32302cf2 <_vfiprintf_r+0xbae>
32302cb8:	3c10      	subs	r4, #16
32302cba:	2c10      	cmp	r4, #16
32302cbc:	dd18      	ble.n	32302cf0 <_vfiprintf_r+0xbac>
32302cbe:	3201      	adds	r2, #1
32302cc0:	3010      	adds	r0, #16
32302cc2:	2a07      	cmp	r2, #7
32302cc4:	e9c1 6300 	strd	r6, r3, [r1]
32302cc8:	e9cd 201b 	strd	r2, r0, [sp, #108]	@ 0x6c
32302ccc:	bfd8      	it	le
32302cce:	3108      	addle	r1, #8
32302cd0:	ddf2      	ble.n	32302cb8 <_vfiprintf_r+0xb74>
32302cd2:	4639      	mov	r1, r7
32302cd4:	aa1a      	add	r2, sp, #104	@ 0x68
32302cd6:	4658      	mov	r0, fp
32302cd8:	f000 fb9e 	bl	32303418 <__sprint_r>
32302cdc:	a91d      	add	r1, sp, #116	@ 0x74
32302cde:	2800      	cmp	r0, #0
32302ce0:	f47f ab80 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302ce4:	3c10      	subs	r4, #16
32302ce6:	2310      	movs	r3, #16
32302ce8:	e9dd 201b 	ldrd	r2, r0, [sp, #108]	@ 0x6c
32302cec:	2c10      	cmp	r4, #16
32302cee:	dce6      	bgt.n	32302cbe <_vfiprintf_r+0xb7a>
32302cf0:	9104      	str	r1, [sp, #16]
32302cf2:	9b04      	ldr	r3, [sp, #16]
32302cf4:	3201      	adds	r2, #1
32302cf6:	1821      	adds	r1, r4, r0
32302cf8:	2a07      	cmp	r2, #7
32302cfa:	e9cd 211b 	strd	r2, r1, [sp, #108]	@ 0x6c
32302cfe:	601e      	str	r6, [r3, #0]
32302d00:	605c      	str	r4, [r3, #4]
32302d02:	f300 817e 	bgt.w	32303002 <_vfiprintf_r+0xebe>
32302d06:	f89d 604b 	ldrb.w	r6, [sp, #75]	@ 0x4b
32302d0a:	3308      	adds	r3, #8
32302d0c:	9304      	str	r3, [sp, #16]
32302d0e:	2e00      	cmp	r6, #0
32302d10:	d035      	beq.n	32302d7e <_vfiprintf_r+0xc3a>
32302d12:	2600      	movs	r6, #0
32302d14:	f7ff bba5 	b.w	32302462 <_vfiprintf_r+0x31e>
32302d18:	9905      	ldr	r1, [sp, #20]
32302d1a:	aa1a      	add	r2, sp, #104	@ 0x68
32302d1c:	4658      	mov	r0, fp
32302d1e:	f000 fb7b 	bl	32303418 <__sprint_r>
32302d22:	2800      	cmp	r0, #0
32302d24:	f47f ab5e 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32302d28:	ab1d      	add	r3, sp, #116	@ 0x74
32302d2a:	9304      	str	r3, [sp, #16]
32302d2c:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32302d30:	f7ff bbc0 	b.w	323024b4 <_vfiprintf_r+0x370>
32302d34:	9a06      	ldr	r2, [sp, #24]
32302d36:	ad46      	add	r5, sp, #280	@ 0x118
32302d38:	9207      	str	r2, [sp, #28]
32302d3a:	e9cd 220a 	strd	r2, r2, [sp, #40]	@ 0x28
32302d3e:	f7ff bb7d 	b.w	3230243c <_vfiprintf_r+0x2f8>
32302d42:	930c      	str	r3, [sp, #48]	@ 0x30
32302d44:	f898 3000 	ldrb.w	r3, [r8]
32302d48:	f7ff ba6f 	b.w	3230222a <_vfiprintf_r+0xe6>
32302d4c:	2500      	movs	r5, #0
32302d4e:	2301      	movs	r3, #1
32302d50:	e9cd 530a 	strd	r5, r3, [sp, #40]	@ 0x28
32302d54:	f20d 1517 	addw	r5, sp, #279	@ 0x117
32302d58:	3201      	adds	r2, #1
32302d5a:	9206      	str	r2, [sp, #24]
32302d5c:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32302d60:	9c03      	ldr	r4, [sp, #12]
32302d62:	4608      	mov	r0, r1
32302d64:	4613      	mov	r3, r2
32302d66:	f014 0684 	ands.w	r6, r4, #132	@ 0x84
32302d6a:	f43f ab6f 	beq.w	3230244c <_vfiprintf_r+0x308>
32302d6e:	2300      	movs	r3, #0
32302d70:	930d      	str	r3, [sp, #52]	@ 0x34
32302d72:	f7ff bb76 	b.w	32302462 <_vfiprintf_r+0x31e>
32302d76:	0498      	lsls	r0, r3, #18
32302d78:	f57f aa0d 	bpl.w	32302196 <_vfiprintf_r+0x52>
32302d7c:	e46b      	b.n	32302656 <_vfiprintf_r+0x512>
32302d7e:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32302d80:	2b00      	cmp	r3, #0
32302d82:	f47f ab7f 	bne.w	32302484 <_vfiprintf_r+0x340>
32302d86:	f7ff bb8f 	b.w	323024a8 <_vfiprintf_r+0x364>
32302d8a:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302d8c:	9a03      	ldr	r2, [sp, #12]
32302d8e:	f853 4b04 	ldr.w	r4, [r3], #4
32302d92:	06d5      	lsls	r5, r2, #27
32302d94:	f53f ad7f 	bmi.w	32302896 <_vfiprintf_r+0x752>
32302d98:	9a03      	ldr	r2, [sp, #12]
32302d9a:	0650      	lsls	r0, r2, #25
32302d9c:	f140 81af 	bpl.w	323030fe <_vfiprintf_r+0xfba>
32302da0:	b224      	sxth	r4, r4
32302da2:	930c      	str	r3, [sp, #48]	@ 0x30
32302da4:	17e6      	asrs	r6, r4, #31
32302da6:	4633      	mov	r3, r6
32302da8:	f7ff bbc8 	b.w	3230253c <_vfiprintf_r+0x3f8>
32302dac:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302dae:	3304      	adds	r3, #4
32302db0:	990c      	ldr	r1, [sp, #48]	@ 0x30
32302db2:	2600      	movs	r6, #0
32302db4:	930c      	str	r3, [sp, #48]	@ 0x30
32302db6:	f88d 604b 	strb.w	r6, [sp, #75]	@ 0x4b
32302dba:	680c      	ldr	r4, [r1, #0]
32302dbc:	9907      	ldr	r1, [sp, #28]
32302dbe:	42b1      	cmp	r1, r6
32302dc0:	f6bf aced 	bge.w	3230279e <_vfiprintf_r+0x65a>
32302dc4:	9203      	str	r2, [sp, #12]
32302dc6:	e4bd      	b.n	32302744 <_vfiprintf_r+0x600>
32302dc8:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302dca:	3304      	adds	r3, #4
32302dcc:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32302dce:	2100      	movs	r1, #0
32302dd0:	930c      	str	r3, [sp, #48]	@ 0x30
32302dd2:	6812      	ldr	r2, [r2, #0]
32302dd4:	e469      	b.n	323026aa <_vfiprintf_r+0x566>
32302dd6:	9b03      	ldr	r3, [sp, #12]
32302dd8:	06db      	lsls	r3, r3, #27
32302dda:	f100 815d 	bmi.w	32303098 <_vfiprintf_r+0xf54>
32302dde:	9b03      	ldr	r3, [sp, #12]
32302de0:	065f      	lsls	r7, r3, #25
32302de2:	f100 81db 	bmi.w	3230319c <_vfiprintf_r+0x1058>
32302de6:	9b03      	ldr	r3, [sp, #12]
32302de8:	059e      	lsls	r6, r3, #22
32302dea:	f140 8155 	bpl.w	32303098 <_vfiprintf_r+0xf54>
32302dee:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302df0:	9a08      	ldr	r2, [sp, #32]
32302df2:	681b      	ldr	r3, [r3, #0]
32302df4:	701a      	strb	r2, [r3, #0]
32302df6:	e538      	b.n	3230286a <_vfiprintf_r+0x726>
32302df8:	9203      	str	r2, [sp, #12]
32302dfa:	f7ff bb95 	b.w	32302528 <_vfiprintf_r+0x3e4>
32302dfe:	f64b 00cc 	movw	r0, #47308	@ 0xb8cc
32302e02:	f2c3 2030 	movt	r0, #12848	@ 0x3230
32302e06:	9a03      	ldr	r2, [sp, #12]
32302e08:	f012 0120 	ands.w	r1, r2, #32
32302e0c:	f000 80e8 	beq.w	32302fe0 <_vfiprintf_r+0xe9c>
32302e10:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32302e12:	3207      	adds	r2, #7
32302e14:	f022 0207 	bic.w	r2, r2, #7
32302e18:	4614      	mov	r4, r2
32302e1a:	6851      	ldr	r1, [r2, #4]
32302e1c:	f854 2b08 	ldr.w	r2, [r4], #8
32302e20:	940c      	str	r4, [sp, #48]	@ 0x30
32302e22:	ea52 0401 	orrs.w	r4, r2, r1
32302e26:	9c03      	ldr	r4, [sp, #12]
32302e28:	f004 0501 	and.w	r5, r4, #1
32302e2c:	f04f 0401 	mov.w	r4, #1
32302e30:	bf08      	it	eq
32302e32:	2500      	moveq	r5, #0
32302e34:	bf08      	it	eq
32302e36:	2400      	moveq	r4, #0
32302e38:	2d00      	cmp	r5, #0
32302e3a:	f040 8105 	bne.w	32303048 <_vfiprintf_r+0xf04>
32302e3e:	9b07      	ldr	r3, [sp, #28]
32302e40:	f88d 504b 	strb.w	r5, [sp, #75]	@ 0x4b
32302e44:	2b00      	cmp	r3, #0
32302e46:	9b03      	ldr	r3, [sp, #12]
32302e48:	f2c0 80c3 	blt.w	32302fd2 <_vfiprintf_r+0xe8e>
32302e4c:	f423 6390 	bic.w	r3, r3, #1152	@ 0x480
32302e50:	9303      	str	r3, [sp, #12]
32302e52:	9b07      	ldr	r3, [sp, #28]
32302e54:	3b00      	subs	r3, #0
32302e56:	bf18      	it	ne
32302e58:	2301      	movne	r3, #1
32302e5a:	431c      	orrs	r4, r3
32302e5c:	f040 80bc 	bne.w	32302fd8 <_vfiprintf_r+0xe94>
32302e60:	ad46      	add	r5, sp, #280	@ 0x118
32302e62:	9407      	str	r4, [sp, #28]
32302e64:	940b      	str	r4, [sp, #44]	@ 0x2c
32302e66:	9406      	str	r4, [sp, #24]
32302e68:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32302e6c:	9c03      	ldr	r4, [sp, #12]
32302e6e:	4608      	mov	r0, r1
32302e70:	4613      	mov	r3, r2
32302e72:	f014 0684 	ands.w	r6, r4, #132	@ 0x84
32302e76:	f000 8270 	beq.w	3230335a <_vfiprintf_r+0x1216>
32302e7a:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
32302e7e:	2b00      	cmp	r3, #0
32302e80:	f000 825f 	beq.w	32303342 <_vfiprintf_r+0x11fe>
32302e84:	2300      	movs	r3, #0
32302e86:	930a      	str	r3, [sp, #40]	@ 0x28
32302e88:	930d      	str	r3, [sp, #52]	@ 0x34
32302e8a:	f7ff baea 	b.w	32302462 <_vfiprintf_r+0x31e>
32302e8e:	f64b 00e0 	movw	r0, #47328	@ 0xb8e0
32302e92:	f2c3 2030 	movt	r0, #12848	@ 0x3230
32302e96:	e7b6      	b.n	32302e06 <_vfiprintf_r+0xcc2>
32302e98:	9803      	ldr	r0, [sp, #12]
32302e9a:	2402      	movs	r4, #2
32302e9c:	930c      	str	r3, [sp, #48]	@ 0x30
32302e9e:	f040 0002 	orr.w	r0, r0, #2
32302ea2:	9003      	str	r0, [sp, #12]
32302ea4:	f64b 00e0 	movw	r0, #47328	@ 0xb8e0
32302ea8:	f2c3 2030 	movt	r0, #12848	@ 0x3230
32302eac:	ad46      	add	r5, sp, #280	@ 0x118
32302eae:	f002 030f 	and.w	r3, r2, #15
32302eb2:	0912      	lsrs	r2, r2, #4
32302eb4:	ea42 7201 	orr.w	r2, r2, r1, lsl #28
32302eb8:	0909      	lsrs	r1, r1, #4
32302eba:	5cc3      	ldrb	r3, [r0, r3]
32302ebc:	f805 3d01 	strb.w	r3, [r5, #-1]!
32302ec0:	ea52 0301 	orrs.w	r3, r2, r1
32302ec4:	d1f3      	bne.n	32302eae <_vfiprintf_r+0xd6a>
32302ec6:	9a07      	ldr	r2, [sp, #28]
32302ec8:	ab46      	add	r3, sp, #280	@ 0x118
32302eca:	1b5b      	subs	r3, r3, r5
32302ecc:	930b      	str	r3, [sp, #44]	@ 0x2c
32302ece:	429a      	cmp	r2, r3
32302ed0:	bfb8      	it	lt
32302ed2:	461a      	movlt	r2, r3
32302ed4:	9206      	str	r2, [sp, #24]
32302ed6:	2c00      	cmp	r4, #0
32302ed8:	f47f ac99 	bne.w	3230280e <_vfiprintf_r+0x6ca>
32302edc:	e7c4      	b.n	32302e68 <_vfiprintf_r+0xd24>
32302ede:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32302ee0:	ad2d      	add	r5, sp, #180	@ 0xb4
32302ee2:	681b      	ldr	r3, [r3, #0]
32302ee4:	f88d 30b4 	strb.w	r3, [sp, #180]	@ 0xb4
32302ee8:	2301      	movs	r3, #1
32302eea:	9306      	str	r3, [sp, #24]
32302eec:	930b      	str	r3, [sp, #44]	@ 0x2c
32302eee:	f7ff bb94 	b.w	3230261a <_vfiprintf_r+0x4d6>
32302ef2:	9b03      	ldr	r3, [sp, #12]
32302ef4:	f108 0801 	add.w	r8, r8, #1
32302ef8:	f443 7300 	orr.w	r3, r3, #512	@ 0x200
32302efc:	9303      	str	r3, [sp, #12]
32302efe:	f898 3000 	ldrb.w	r3, [r8]
32302f02:	f7ff b992 	b.w	3230222a <_vfiprintf_r+0xe6>
32302f06:	9b03      	ldr	r3, [sp, #12]
32302f08:	f108 0801 	add.w	r8, r8, #1
32302f0c:	f043 0320 	orr.w	r3, r3, #32
32302f10:	9303      	str	r3, [sp, #12]
32302f12:	f898 3000 	ldrb.w	r3, [r8]
32302f16:	f7ff b988 	b.w	3230222a <_vfiprintf_r+0xe6>
32302f1a:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32302f1c:	2208      	movs	r2, #8
32302f1e:	2100      	movs	r1, #0
32302f20:	a818      	add	r0, sp, #96	@ 0x60
32302f22:	9315      	str	r3, [sp, #84]	@ 0x54
32302f24:	f001 f8a0 	bl	32304068 <memset>
32302f28:	9f07      	ldr	r7, [sp, #28]
32302f2a:	2f00      	cmp	r7, #0
32302f2c:	f2c0 80fc 	blt.w	32303128 <_vfiprintf_r+0xfe4>
32302f30:	2400      	movs	r4, #0
32302f32:	4625      	mov	r5, r4
32302f34:	e00c      	b.n	32302f50 <_vfiprintf_r+0xe0c>
32302f36:	a92d      	add	r1, sp, #180	@ 0xb4
32302f38:	4658      	mov	r0, fp
32302f3a:	f003 ff29 	bl	32306d90 <_wcrtomb_r>
32302f3e:	3404      	adds	r4, #4
32302f40:	1c41      	adds	r1, r0, #1
32302f42:	4428      	add	r0, r5
32302f44:	f000 81b1 	beq.w	323032aa <_vfiprintf_r+0x1166>
32302f48:	42b8      	cmp	r0, r7
32302f4a:	dc06      	bgt.n	32302f5a <_vfiprintf_r+0xe16>
32302f4c:	d006      	beq.n	32302f5c <_vfiprintf_r+0xe18>
32302f4e:	4605      	mov	r5, r0
32302f50:	9a15      	ldr	r2, [sp, #84]	@ 0x54
32302f52:	ab18      	add	r3, sp, #96	@ 0x60
32302f54:	5912      	ldr	r2, [r2, r4]
32302f56:	2a00      	cmp	r2, #0
32302f58:	d1ed      	bne.n	32302f36 <_vfiprintf_r+0xdf2>
32302f5a:	9507      	str	r5, [sp, #28]
32302f5c:	9b07      	ldr	r3, [sp, #28]
32302f5e:	2b00      	cmp	r3, #0
32302f60:	f000 80f2 	beq.w	32303148 <_vfiprintf_r+0x1004>
32302f64:	2b63      	cmp	r3, #99	@ 0x63
32302f66:	f340 8132 	ble.w	323031ce <_vfiprintf_r+0x108a>
32302f6a:	1c59      	adds	r1, r3, #1
32302f6c:	4658      	mov	r0, fp
32302f6e:	f002 fd8b 	bl	32305a88 <_malloc_r>
32302f72:	4605      	mov	r5, r0
32302f74:	2800      	cmp	r0, #0
32302f76:	f000 8198 	beq.w	323032aa <_vfiprintf_r+0x1166>
32302f7a:	900a      	str	r0, [sp, #40]	@ 0x28
32302f7c:	2208      	movs	r2, #8
32302f7e:	2100      	movs	r1, #0
32302f80:	a818      	add	r0, sp, #96	@ 0x60
32302f82:	f001 f871 	bl	32304068 <memset>
32302f86:	9c07      	ldr	r4, [sp, #28]
32302f88:	ab18      	add	r3, sp, #96	@ 0x60
32302f8a:	aa15      	add	r2, sp, #84	@ 0x54
32302f8c:	9300      	str	r3, [sp, #0]
32302f8e:	4629      	mov	r1, r5
32302f90:	4623      	mov	r3, r4
32302f92:	4658      	mov	r0, fp
32302f94:	f003 ff46 	bl	32306e24 <_wcsrtombs_r>
32302f98:	4284      	cmp	r4, r0
32302f9a:	f040 81d7 	bne.w	3230334c <_vfiprintf_r+0x1208>
32302f9e:	9907      	ldr	r1, [sp, #28]
32302fa0:	2300      	movs	r3, #0
32302fa2:	546b      	strb	r3, [r5, r1]
32302fa4:	ea21 72e1 	bic.w	r2, r1, r1, asr #31
32302fa8:	9206      	str	r2, [sp, #24]
32302faa:	f89d 204b 	ldrb.w	r2, [sp, #75]	@ 0x4b
32302fae:	2a00      	cmp	r2, #0
32302fb0:	f040 8173 	bne.w	3230329a <_vfiprintf_r+0x1156>
32302fb4:	e9cd 160b 	strd	r1, r6, [sp, #44]	@ 0x2c
32302fb8:	9207      	str	r2, [sp, #28]
32302fba:	f7ff ba3f 	b.w	3230243c <_vfiprintf_r+0x2f8>
32302fbe:	9c09      	ldr	r4, [sp, #36]	@ 0x24
32302fc0:	9f06      	ldr	r7, [sp, #24]
32302fc2:	960a      	str	r6, [sp, #40]	@ 0x28
32302fc4:	1be4      	subs	r4, r4, r7
32302fc6:	2c00      	cmp	r4, #0
32302fc8:	f77f aa5c 	ble.w	32302484 <_vfiprintf_r+0x340>
32302fcc:	2202      	movs	r2, #2
32302fce:	920d      	str	r2, [sp, #52]	@ 0x34
32302fd0:	e667      	b.n	32302ca2 <_vfiprintf_r+0xb5e>
32302fd2:	f423 6380 	bic.w	r3, r3, #1024	@ 0x400
32302fd6:	9303      	str	r3, [sp, #12]
32302fd8:	9b03      	ldr	r3, [sp, #12]
32302fda:	f003 0402 	and.w	r4, r3, #2
32302fde:	e765      	b.n	32302eac <_vfiprintf_r+0xd68>
32302fe0:	9c0c      	ldr	r4, [sp, #48]	@ 0x30
32302fe2:	f854 2b04 	ldr.w	r2, [r4], #4
32302fe6:	940c      	str	r4, [sp, #48]	@ 0x30
32302fe8:	9c03      	ldr	r4, [sp, #12]
32302fea:	f014 0410 	ands.w	r4, r4, #16
32302fee:	f47f af18 	bne.w	32302e22 <_vfiprintf_r+0xcde>
32302ff2:	9903      	ldr	r1, [sp, #12]
32302ff4:	f011 0540 	ands.w	r5, r1, #64	@ 0x40
32302ff8:	f000 808a 	beq.w	32303110 <_vfiprintf_r+0xfcc>
32302ffc:	b292      	uxth	r2, r2
32302ffe:	4621      	mov	r1, r4
32303000:	e70f      	b.n	32302e22 <_vfiprintf_r+0xcde>
32303002:	9905      	ldr	r1, [sp, #20]
32303004:	aa1a      	add	r2, sp, #104	@ 0x68
32303006:	4658      	mov	r0, fp
32303008:	f000 fa06 	bl	32303418 <__sprint_r>
3230300c:	4606      	mov	r6, r0
3230300e:	2800      	cmp	r0, #0
32303010:	f47f a9e8 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
32303014:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
32303018:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
3230301c:	2b00      	cmp	r3, #0
3230301e:	d17f      	bne.n	32303120 <_vfiprintf_r+0xfdc>
32303020:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32303022:	b16b      	cbz	r3, 32303040 <_vfiprintf_r+0xefc>
32303024:	ab1d      	add	r3, sp, #116	@ 0x74
32303026:	9304      	str	r3, [sp, #16]
32303028:	f7ff ba2c 	b.w	32302484 <_vfiprintf_r+0x340>
3230302c:	9905      	ldr	r1, [sp, #20]
3230302e:	aa1a      	add	r2, sp, #104	@ 0x68
32303030:	4658      	mov	r0, fp
32303032:	f000 f9f1 	bl	32303418 <__sprint_r>
32303036:	2800      	cmp	r0, #0
32303038:	f47f a9d4 	bne.w	323023e4 <_vfiprintf_r+0x2a0>
3230303c:	e9dd 211b 	ldrd	r2, r1, [sp, #108]	@ 0x6c
32303040:	ab1d      	add	r3, sp, #116	@ 0x74
32303042:	9304      	str	r3, [sp, #16]
32303044:	f7ff ba30 	b.w	323024a8 <_vfiprintf_r+0x364>
32303048:	f88d 304d 	strb.w	r3, [sp, #77]	@ 0x4d
3230304c:	2330      	movs	r3, #48	@ 0x30
3230304e:	f88d 304c 	strb.w	r3, [sp, #76]	@ 0x4c
32303052:	2300      	movs	r3, #0
32303054:	f88d 304b 	strb.w	r3, [sp, #75]	@ 0x4b
32303058:	9b07      	ldr	r3, [sp, #28]
3230305a:	2b00      	cmp	r3, #0
3230305c:	da7f      	bge.n	3230315e <_vfiprintf_r+0x101a>
3230305e:	9b03      	ldr	r3, [sp, #12]
32303060:	f423 6380 	bic.w	r3, r3, #1024	@ 0x400
32303064:	f043 0302 	orr.w	r3, r3, #2
32303068:	9303      	str	r3, [sp, #12]
3230306a:	e7b5      	b.n	32302fd8 <_vfiprintf_r+0xe94>
3230306c:	9a07      	ldr	r2, [sp, #28]
3230306e:	3802      	subs	r0, #2
32303070:	2330      	movs	r3, #48	@ 0x30
32303072:	f805 3c01 	strb.w	r3, [r5, #-1]
32303076:	ab46      	add	r3, sp, #280	@ 0x118
32303078:	4605      	mov	r5, r0
3230307a:	1a1b      	subs	r3, r3, r0
3230307c:	930b      	str	r3, [sp, #44]	@ 0x2c
3230307e:	429a      	cmp	r2, r3
32303080:	bfb8      	it	lt
32303082:	461a      	movlt	r2, r3
32303084:	2300      	movs	r3, #0
32303086:	9206      	str	r2, [sp, #24]
32303088:	930a      	str	r3, [sp, #40]	@ 0x28
3230308a:	f7ff b9d7 	b.w	3230243c <_vfiprintf_r+0x2f8>
3230308e:	4658      	mov	r0, fp
32303090:	f000 fc24 	bl	323038dc <__sinit>
32303094:	f7ff b86d 	b.w	32302172 <_vfiprintf_r+0x2e>
32303098:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3230309a:	9a08      	ldr	r2, [sp, #32]
3230309c:	681b      	ldr	r3, [r3, #0]
3230309e:	601a      	str	r2, [r3, #0]
323030a0:	f7ff bbe3 	b.w	3230286a <_vfiprintf_r+0x726>
323030a4:	930a      	str	r3, [sp, #40]	@ 0x28
323030a6:	ad46      	add	r5, sp, #280	@ 0x118
323030a8:	930b      	str	r3, [sp, #44]	@ 0x2c
323030aa:	9307      	str	r3, [sp, #28]
323030ac:	2301      	movs	r3, #1
323030ae:	9306      	str	r3, [sp, #24]
323030b0:	e654      	b.n	32302d5c <_vfiprintf_r+0xc18>
323030b2:	9b07      	ldr	r3, [sp, #28]
323030b4:	f64b 05f4 	movw	r5, #47348	@ 0xb8f4
323030b8:	f2c3 2530 	movt	r5, #12848	@ 0x3230
323030bc:	960c      	str	r6, [sp, #48]	@ 0x30
323030be:	2b06      	cmp	r3, #6
323030c0:	9207      	str	r2, [sp, #28]
323030c2:	bf28      	it	cs
323030c4:	2306      	movcs	r3, #6
323030c6:	9306      	str	r3, [sp, #24]
323030c8:	930b      	str	r3, [sp, #44]	@ 0x2c
323030ca:	f7ff b9b7 	b.w	3230243c <_vfiprintf_r+0x2f8>
323030ce:	9c03      	ldr	r4, [sp, #12]
323030d0:	f414 7100 	ands.w	r1, r4, #512	@ 0x200
323030d4:	d057      	beq.n	32303186 <_vfiprintf_r+0x1042>
323030d6:	4601      	mov	r1, r0
323030d8:	b2d2      	uxtb	r2, r2
323030da:	4620      	mov	r0, r4
323030dc:	930c      	str	r3, [sp, #48]	@ 0x30
323030de:	f7ff bae4 	b.w	323026aa <_vfiprintf_r+0x566>
323030e2:	9903      	ldr	r1, [sp, #12]
323030e4:	f411 7600 	ands.w	r6, r1, #512	@ 0x200
323030e8:	d045      	beq.n	32303176 <_vfiprintf_r+0x1032>
323030ea:	4616      	mov	r6, r2
323030ec:	f88d 204b 	strb.w	r2, [sp, #75]	@ 0x4b
323030f0:	9a07      	ldr	r2, [sp, #28]
323030f2:	b2e4      	uxtb	r4, r4
323030f4:	2a00      	cmp	r2, #0
323030f6:	f6bf ab16 	bge.w	32302726 <_vfiprintf_r+0x5e2>
323030fa:	f7ff bb22 	b.w	32302742 <_vfiprintf_r+0x5fe>
323030fe:	9a03      	ldr	r2, [sp, #12]
32303100:	0591      	lsls	r1, r2, #22
32303102:	d533      	bpl.n	3230316c <_vfiprintf_r+0x1028>
32303104:	b264      	sxtb	r4, r4
32303106:	930c      	str	r3, [sp, #48]	@ 0x30
32303108:	17e6      	asrs	r6, r4, #31
3230310a:	4633      	mov	r3, r6
3230310c:	f7ff ba16 	b.w	3230253c <_vfiprintf_r+0x3f8>
32303110:	9903      	ldr	r1, [sp, #12]
32303112:	f411 7100 	ands.w	r1, r1, #512	@ 0x200
32303116:	f43f ae84 	beq.w	32302e22 <_vfiprintf_r+0xcde>
3230311a:	b2d2      	uxtb	r2, r2
3230311c:	4629      	mov	r1, r5
3230311e:	e680      	b.n	32302e22 <_vfiprintf_r+0xcde>
32303120:	ab1d      	add	r3, sp, #116	@ 0x74
32303122:	9304      	str	r3, [sp, #16]
32303124:	f7ff b99d 	b.w	32302462 <_vfiprintf_r+0x31e>
32303128:	ab18      	add	r3, sp, #96	@ 0x60
3230312a:	9300      	str	r3, [sp, #0]
3230312c:	2300      	movs	r3, #0
3230312e:	aa15      	add	r2, sp, #84	@ 0x54
32303130:	4619      	mov	r1, r3
32303132:	4658      	mov	r0, fp
32303134:	f003 fe76 	bl	32306e24 <_wcsrtombs_r>
32303138:	4603      	mov	r3, r0
3230313a:	3301      	adds	r3, #1
3230313c:	9007      	str	r0, [sp, #28]
3230313e:	f000 80b4 	beq.w	323032aa <_vfiprintf_r+0x1166>
32303142:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32303144:	9315      	str	r3, [sp, #84]	@ 0x54
32303146:	e709      	b.n	32302f5c <_vfiprintf_r+0xe18>
32303148:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
3230314c:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
3230314e:	3b00      	subs	r3, #0
32303150:	960c      	str	r6, [sp, #48]	@ 0x30
32303152:	bf18      	it	ne
32303154:	2301      	movne	r3, #1
32303156:	9306      	str	r3, [sp, #24]
32303158:	9b07      	ldr	r3, [sp, #28]
3230315a:	930b      	str	r3, [sp, #44]	@ 0x2c
3230315c:	e684      	b.n	32302e68 <_vfiprintf_r+0xd24>
3230315e:	9b03      	ldr	r3, [sp, #12]
32303160:	f423 6390 	bic.w	r3, r3, #1152	@ 0x480
32303164:	f043 0302 	orr.w	r3, r3, #2
32303168:	9303      	str	r3, [sp, #12]
3230316a:	e735      	b.n	32302fd8 <_vfiprintf_r+0xe94>
3230316c:	17e6      	asrs	r6, r4, #31
3230316e:	930c      	str	r3, [sp, #48]	@ 0x30
32303170:	4633      	mov	r3, r6
32303172:	f7ff b9e3 	b.w	3230253c <_vfiprintf_r+0x3f8>
32303176:	9a07      	ldr	r2, [sp, #28]
32303178:	f88d 604b 	strb.w	r6, [sp, #75]	@ 0x4b
3230317c:	2a00      	cmp	r2, #0
3230317e:	f6bf aad2 	bge.w	32302726 <_vfiprintf_r+0x5e2>
32303182:	f7ff bade 	b.w	32302742 <_vfiprintf_r+0x5fe>
32303186:	9803      	ldr	r0, [sp, #12]
32303188:	930c      	str	r3, [sp, #48]	@ 0x30
3230318a:	f7ff ba8e 	b.w	323026aa <_vfiprintf_r+0x566>
3230318e:	ad46      	add	r5, sp, #280	@ 0x118
32303190:	9207      	str	r2, [sp, #28]
32303192:	930c      	str	r3, [sp, #48]	@ 0x30
32303194:	e9cd 220a 	strd	r2, r2, [sp, #40]	@ 0x28
32303198:	f7ff b950 	b.w	3230243c <_vfiprintf_r+0x2f8>
3230319c:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3230319e:	9a08      	ldr	r2, [sp, #32]
323031a0:	681b      	ldr	r3, [r3, #0]
323031a2:	801a      	strh	r2, [r3, #0]
323031a4:	f7ff bb61 	b.w	3230286a <_vfiprintf_r+0x726>
323031a8:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
323031aa:	4628      	mov	r0, r5
323031ac:	f002 fa48 	bl	32305640 <strlen>
323031b0:	f89d 304b 	ldrb.w	r3, [sp, #75]	@ 0x4b
323031b4:	ea20 72e0 	bic.w	r2, r0, r0, asr #31
323031b8:	900b      	str	r0, [sp, #44]	@ 0x2c
323031ba:	9206      	str	r2, [sp, #24]
323031bc:	2b00      	cmp	r3, #0
323031be:	f000 8083 	beq.w	323032c8 <_vfiprintf_r+0x1184>
323031c2:	3201      	adds	r2, #1
323031c4:	9407      	str	r4, [sp, #28]
323031c6:	9206      	str	r2, [sp, #24]
323031c8:	960c      	str	r6, [sp, #48]	@ 0x30
323031ca:	940a      	str	r4, [sp, #40]	@ 0x28
323031cc:	e5c6      	b.n	32302d5c <_vfiprintf_r+0xc18>
323031ce:	2300      	movs	r3, #0
323031d0:	ad2d      	add	r5, sp, #180	@ 0xb4
323031d2:	930a      	str	r3, [sp, #40]	@ 0x28
323031d4:	e6d2      	b.n	32302f7c <_vfiprintf_r+0xe38>
323031d6:	6d88      	ldr	r0, [r1, #88]	@ 0x58
323031d8:	f001 fd46 	bl	32304c68 <__retarget_lock_release_recursive>
323031dc:	f7ff b8bd 	b.w	3230235a <_vfiprintf_r+0x216>
323031e0:	9a10      	ldr	r2, [sp, #64]	@ 0x40
323031e2:	9911      	ldr	r1, [sp, #68]	@ 0x44
323031e4:	eba8 0b02 	sub.w	fp, r8, r2
323031e8:	4658      	mov	r0, fp
323031ea:	f000 ff8b 	bl	32304104 <strncpy>
323031ee:	f899 3001 	ldrb.w	r3, [r9, #1]
323031f2:	b10b      	cbz	r3, 323031f8 <_vfiprintf_r+0x10b4>
323031f4:	f109 0901 	add.w	r9, r9, #1
323031f8:	19a3      	adds	r3, r4, r6
323031fa:	f64c 42cd 	movw	r2, #52429	@ 0xcccd
323031fe:	f6cc 42cc 	movt	r2, #52428	@ 0xcccc
32303202:	f143 0300 	adc.w	r3, r3, #0
32303206:	f04f 31cc 	mov.w	r1, #3435973836	@ 0xcccccccc
3230320a:	f04f 0e01 	mov.w	lr, #1
3230320e:	f10b 38ff 	add.w	r8, fp, #4294967295	@ 0xffffffff
32303212:	fba2 0c03 	umull	r0, ip, r2, r3
32303216:	f02c 0003 	bic.w	r0, ip, #3
3230321a:	eb00 009c 	add.w	r0, r0, ip, lsr #2
3230321e:	1a1b      	subs	r3, r3, r0
32303220:	1ae3      	subs	r3, r4, r3
32303222:	f166 0600 	sbc.w	r6, r6, #0
32303226:	fb03 f101 	mul.w	r1, r3, r1
3230322a:	fb02 1106 	mla	r1, r2, r6, r1
3230322e:	fba3 3002 	umull	r3, r0, r3, r2
32303232:	4401      	add	r1, r0
32303234:	fa23 f30e 	lsr.w	r3, r3, lr
32303238:	ea43 74c1 	orr.w	r4, r3, r1, lsl #31
3230323c:	fa21 f60e 	lsr.w	r6, r1, lr
32303240:	19a3      	adds	r3, r4, r6
32303242:	f143 0300 	adc.w	r3, r3, #0
32303246:	fba2 1003 	umull	r1, r0, r2, r3
3230324a:	f020 0103 	bic.w	r1, r0, #3
3230324e:	eb01 0190 	add.w	r1, r1, r0, lsr #2
32303252:	1a5b      	subs	r3, r3, r1
32303254:	1ae3      	subs	r3, r4, r3
32303256:	f166 0000 	sbc.w	r0, r6, #0
3230325a:	fba3 3102 	umull	r3, r1, r3, r2
3230325e:	fa23 f30e 	lsr.w	r3, r3, lr
32303262:	fb02 1200 	mla	r2, r2, r0, r1
32303266:	ea43 73c2 	orr.w	r3, r3, r2, lsl #31
3230326a:	eb03 0383 	add.w	r3, r3, r3, lsl #2
3230326e:	eba4 0343 	sub.w	r3, r4, r3, lsl #1
32303272:	3330      	adds	r3, #48	@ 0x30
32303274:	f80b 3c01 	strb.w	r3, [fp, #-1]
32303278:	f7ff bb83 	b.w	32302982 <_vfiprintf_r+0x83e>
3230327c:	2200      	movs	r2, #0
3230327e:	4688      	mov	r8, r1
32303280:	9207      	str	r2, [sp, #28]
32303282:	f7fe bfd4 	b.w	3230222e <_vfiprintf_r+0xea>
32303286:	9905      	ldr	r1, [sp, #20]
32303288:	aa1a      	add	r2, sp, #104	@ 0x68
3230328a:	4658      	mov	r0, fp
3230328c:	f000 f8c4 	bl	32303418 <__sprint_r>
32303290:	2800      	cmp	r0, #0
32303292:	f43f a890 	beq.w	323023b6 <_vfiprintf_r+0x272>
32303296:	f7ff b8ab 	b.w	323023f0 <_vfiprintf_r+0x2ac>
3230329a:	9a07      	ldr	r2, [sp, #28]
3230329c:	920b      	str	r2, [sp, #44]	@ 0x2c
3230329e:	9a06      	ldr	r2, [sp, #24]
323032a0:	960c      	str	r6, [sp, #48]	@ 0x30
323032a2:	3201      	adds	r2, #1
323032a4:	9307      	str	r3, [sp, #28]
323032a6:	9206      	str	r2, [sp, #24]
323032a8:	e558      	b.n	32302d5c <_vfiprintf_r+0xc18>
323032aa:	9805      	ldr	r0, [sp, #20]
323032ac:	6e42      	ldr	r2, [r0, #100]	@ 0x64
323032ae:	f9b0 300c 	ldrsh.w	r3, [r0, #12]
323032b2:	07d2      	lsls	r2, r2, #31
323032b4:	f043 0140 	orr.w	r1, r3, #64	@ 0x40
323032b8:	8181      	strh	r1, [r0, #12]
323032ba:	f53f a9cc 	bmi.w	32302656 <_vfiprintf_r+0x512>
323032be:	0599      	lsls	r1, r3, #22
323032c0:	f53f a9c9 	bmi.w	32302656 <_vfiprintf_r+0x512>
323032c4:	f7ff b925 	b.w	32302512 <_vfiprintf_r+0x3ce>
323032c8:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
323032ca:	9307      	str	r3, [sp, #28]
323032cc:	960c      	str	r6, [sp, #48]	@ 0x30
323032ce:	930a      	str	r3, [sp, #40]	@ 0x28
323032d0:	f7ff b8b4 	b.w	3230243c <_vfiprintf_r+0x2f8>
323032d4:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
323032d6:	9207      	str	r2, [sp, #28]
323032d8:	960c      	str	r6, [sp, #48]	@ 0x30
323032da:	920a      	str	r2, [sp, #40]	@ 0x28
323032dc:	f7ff b8ae 	b.w	3230243c <_vfiprintf_r+0x2f8>
323032e0:	b13a      	cbz	r2, 323032f2 <_vfiprintf_r+0x11ae>
323032e2:	9a07      	ldr	r2, [sp, #28]
323032e4:	960c      	str	r6, [sp, #48]	@ 0x30
323032e6:	1c51      	adds	r1, r2, #1
323032e8:	920b      	str	r2, [sp, #44]	@ 0x2c
323032ea:	9106      	str	r1, [sp, #24]
323032ec:	9007      	str	r0, [sp, #28]
323032ee:	900a      	str	r0, [sp, #40]	@ 0x28
323032f0:	e534      	b.n	32302d5c <_vfiprintf_r+0xc18>
323032f2:	9b07      	ldr	r3, [sp, #28]
323032f4:	920a      	str	r2, [sp, #40]	@ 0x28
323032f6:	960c      	str	r6, [sp, #48]	@ 0x30
323032f8:	930b      	str	r3, [sp, #44]	@ 0x2c
323032fa:	9306      	str	r3, [sp, #24]
323032fc:	9207      	str	r2, [sp, #28]
323032fe:	f7ff b89d 	b.w	3230243c <_vfiprintf_r+0x2f8>
32303302:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32303304:	f898 3001 	ldrb.w	r3, [r8, #1]
32303308:	4688      	mov	r8, r1
3230330a:	f852 1b04 	ldr.w	r1, [r2], #4
3230330e:	920c      	str	r2, [sp, #48]	@ 0x30
32303310:	ea41 72e1 	orr.w	r2, r1, r1, asr #31
32303314:	9207      	str	r2, [sp, #28]
32303316:	f7fe bf88 	b.w	3230222a <_vfiprintf_r+0xe6>
3230331a:	9a05      	ldr	r2, [sp, #20]
3230331c:	6e53      	ldr	r3, [r2, #100]	@ 0x64
3230331e:	07dd      	lsls	r5, r3, #31
32303320:	f53f a999 	bmi.w	32302656 <_vfiprintf_r+0x512>
32303324:	8993      	ldrh	r3, [r2, #12]
32303326:	059c      	lsls	r4, r3, #22
32303328:	f53f a995 	bmi.w	32302656 <_vfiprintf_r+0x512>
3230332c:	6d90      	ldr	r0, [r2, #88]	@ 0x58
3230332e:	f001 fc9b 	bl	32304c68 <__retarget_lock_release_recursive>
32303332:	f7ff b990 	b.w	32302656 <_vfiprintf_r+0x512>
32303336:	f64b 00e0 	movw	r0, #47328	@ 0xb8e0
3230333a:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230333e:	930c      	str	r3, [sp, #48]	@ 0x30
32303340:	e64a      	b.n	32302fd8 <_vfiprintf_r+0xe94>
32303342:	930a      	str	r3, [sp, #40]	@ 0x28
32303344:	f7ff b8ad 	b.w	323024a2 <_vfiprintf_r+0x35e>
32303348:	9803      	ldr	r0, [sp, #12]
3230334a:	e53f      	b.n	32302dcc <_vfiprintf_r+0xc88>
3230334c:	9a05      	ldr	r2, [sp, #20]
3230334e:	8993      	ldrh	r3, [r2, #12]
32303350:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32303354:	8193      	strh	r3, [r2, #12]
32303356:	f7ff b845 	b.w	323023e4 <_vfiprintf_r+0x2a0>
3230335a:	960a      	str	r6, [sp, #40]	@ 0x28
3230335c:	f7ff b876 	b.w	3230244c <_vfiprintf_r+0x308>

32303360 <vfiprintf>:
32303360:	f24c 2ca0 	movw	ip, #49824	@ 0xc2a0
32303364:	f2c3 2c30 	movt	ip, #12848	@ 0x3230
32303368:	b500      	push	{lr}
3230336a:	468e      	mov	lr, r1
3230336c:	4613      	mov	r3, r2
3230336e:	4601      	mov	r1, r0
32303370:	4672      	mov	r2, lr
32303372:	f8dc 0000 	ldr.w	r0, [ip]
32303376:	f85d eb04 	ldr.w	lr, [sp], #4
3230337a:	f7fe bee3 	b.w	32302144 <_vfiprintf_r>
3230337e:	bf00      	nop

32303380 <__sbprintf>:
32303380:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
32303384:	4698      	mov	r8, r3
32303386:	eddf 0b22 	vldr	d16, [pc, #136]	@ 32303410 <__sbprintf+0x90>
3230338a:	f5ad 6d8d 	sub.w	sp, sp, #1128	@ 0x468
3230338e:	4616      	mov	r6, r2
32303390:	ab05      	add	r3, sp, #20
32303392:	4607      	mov	r7, r0
32303394:	a816      	add	r0, sp, #88	@ 0x58
32303396:	460d      	mov	r5, r1
32303398:	466c      	mov	r4, sp
3230339a:	f943 078f 	vst1.32	{d16}, [r3]
3230339e:	898b      	ldrh	r3, [r1, #12]
323033a0:	f023 0302 	bic.w	r3, r3, #2
323033a4:	f8ad 300c 	strh.w	r3, [sp, #12]
323033a8:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
323033aa:	9319      	str	r3, [sp, #100]	@ 0x64
323033ac:	89cb      	ldrh	r3, [r1, #14]
323033ae:	f8ad 300e 	strh.w	r3, [sp, #14]
323033b2:	69cb      	ldr	r3, [r1, #28]
323033b4:	9307      	str	r3, [sp, #28]
323033b6:	6a4b      	ldr	r3, [r1, #36]	@ 0x24
323033b8:	9309      	str	r3, [sp, #36]	@ 0x24
323033ba:	ab1a      	add	r3, sp, #104	@ 0x68
323033bc:	9300      	str	r3, [sp, #0]
323033be:	9304      	str	r3, [sp, #16]
323033c0:	f44f 6380 	mov.w	r3, #1024	@ 0x400
323033c4:	9302      	str	r3, [sp, #8]
323033c6:	f001 fc3f 	bl	32304c48 <__retarget_lock_init_recursive>
323033ca:	4632      	mov	r2, r6
323033cc:	4643      	mov	r3, r8
323033ce:	4669      	mov	r1, sp
323033d0:	4638      	mov	r0, r7
323033d2:	f7fe feb7 	bl	32302144 <_vfiprintf_r>
323033d6:	1e06      	subs	r6, r0, #0
323033d8:	db08      	blt.n	323033ec <__sbprintf+0x6c>
323033da:	4669      	mov	r1, sp
323033dc:	4638      	mov	r0, r7
323033de:	f000 f8c7 	bl	32303570 <_fflush_r>
323033e2:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
323033e6:	2800      	cmp	r0, #0
323033e8:	bf18      	it	ne
323033ea:	461e      	movne	r6, r3
323033ec:	89a3      	ldrh	r3, [r4, #12]
323033ee:	065b      	lsls	r3, r3, #25
323033f0:	d503      	bpl.n	323033fa <__sbprintf+0x7a>
323033f2:	89ab      	ldrh	r3, [r5, #12]
323033f4:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
323033f8:	81ab      	strh	r3, [r5, #12]
323033fa:	6da0      	ldr	r0, [r4, #88]	@ 0x58
323033fc:	f001 fc28 	bl	32304c50 <__retarget_lock_close_recursive>
32303400:	4630      	mov	r0, r6
32303402:	f50d 6d8d 	add.w	sp, sp, #1128	@ 0x468
32303406:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
3230340a:	bf00      	nop
3230340c:	f3af 8000 	nop.w
32303410:	00000400 	.word	0x00000400
32303414:	00000000 	.word	0x00000000

32303418 <__sprint_r>:
32303418:	6893      	ldr	r3, [r2, #8]
3230341a:	b510      	push	{r4, lr}
3230341c:	4614      	mov	r4, r2
3230341e:	b91b      	cbnz	r3, 32303428 <__sprint_r+0x10>
32303420:	4618      	mov	r0, r3
32303422:	2300      	movs	r3, #0
32303424:	6063      	str	r3, [r4, #4]
32303426:	bd10      	pop	{r4, pc}
32303428:	f000 fab4 	bl	32303994 <__sfvwrite_r>
3230342c:	2300      	movs	r3, #0
3230342e:	60a3      	str	r3, [r4, #8]
32303430:	2300      	movs	r3, #0
32303432:	6063      	str	r3, [r4, #4]
32303434:	bd10      	pop	{r4, pc}
32303436:	bf00      	nop

32303438 <__sflush_r>:
32303438:	f9b1 200c 	ldrsh.w	r2, [r1, #12]
3230343c:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
32303440:	460c      	mov	r4, r1
32303442:	4680      	mov	r8, r0
32303444:	0715      	lsls	r5, r2, #28
32303446:	d450      	bmi.n	323034ea <__sflush_r+0xb2>
32303448:	6849      	ldr	r1, [r1, #4]
3230344a:	f442 6300 	orr.w	r3, r2, #2048	@ 0x800
3230344e:	81a3      	strh	r3, [r4, #12]
32303450:	2900      	cmp	r1, #0
32303452:	dd6f      	ble.n	32303534 <__sflush_r+0xfc>
32303454:	6aa6      	ldr	r6, [r4, #40]	@ 0x28
32303456:	2e00      	cmp	r6, #0
32303458:	d044      	beq.n	323034e4 <__sflush_r+0xac>
3230345a:	f8d8 5000 	ldr.w	r5, [r8]
3230345e:	2100      	movs	r1, #0
32303460:	f412 5280 	ands.w	r2, r2, #4096	@ 0x1000
32303464:	f8c8 1000 	str.w	r1, [r8]
32303468:	d168      	bne.n	3230353c <__sflush_r+0x104>
3230346a:	69e1      	ldr	r1, [r4, #28]
3230346c:	2301      	movs	r3, #1
3230346e:	4640      	mov	r0, r8
32303470:	47b0      	blx	r6
32303472:	4602      	mov	r2, r0
32303474:	1c50      	adds	r0, r2, #1
32303476:	d06f      	beq.n	32303558 <__sflush_r+0x120>
32303478:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
3230347c:	6aa6      	ldr	r6, [r4, #40]	@ 0x28
3230347e:	0759      	lsls	r1, r3, #29
32303480:	d505      	bpl.n	3230348e <__sflush_r+0x56>
32303482:	6b23      	ldr	r3, [r4, #48]	@ 0x30
32303484:	6861      	ldr	r1, [r4, #4]
32303486:	1a52      	subs	r2, r2, r1
32303488:	b10b      	cbz	r3, 3230348e <__sflush_r+0x56>
3230348a:	6be3      	ldr	r3, [r4, #60]	@ 0x3c
3230348c:	1ad2      	subs	r2, r2, r3
3230348e:	2300      	movs	r3, #0
32303490:	69e1      	ldr	r1, [r4, #28]
32303492:	4640      	mov	r0, r8
32303494:	47b0      	blx	r6
32303496:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
3230349a:	1c42      	adds	r2, r0, #1
3230349c:	d150      	bne.n	32303540 <__sflush_r+0x108>
3230349e:	f8d8 1000 	ldr.w	r1, [r8]
323034a2:	291d      	cmp	r1, #29
323034a4:	d83f      	bhi.n	32303526 <__sflush_r+0xee>
323034a6:	2201      	movs	r2, #1
323034a8:	f2c2 0240 	movt	r2, #8256	@ 0x2040
323034ac:	40ca      	lsrs	r2, r1
323034ae:	07d7      	lsls	r7, r2, #31
323034b0:	d539      	bpl.n	32303526 <__sflush_r+0xee>
323034b2:	6922      	ldr	r2, [r4, #16]
323034b4:	04de      	lsls	r6, r3, #19
323034b6:	6022      	str	r2, [r4, #0]
323034b8:	f423 6200 	bic.w	r2, r3, #2048	@ 0x800
323034bc:	81a2      	strh	r2, [r4, #12]
323034be:	f04f 0200 	mov.w	r2, #0
323034c2:	6062      	str	r2, [r4, #4]
323034c4:	d501      	bpl.n	323034ca <__sflush_r+0x92>
323034c6:	2900      	cmp	r1, #0
323034c8:	d044      	beq.n	32303554 <__sflush_r+0x11c>
323034ca:	6b21      	ldr	r1, [r4, #48]	@ 0x30
323034cc:	f8c8 5000 	str.w	r5, [r8]
323034d0:	b141      	cbz	r1, 323034e4 <__sflush_r+0xac>
323034d2:	f104 0340 	add.w	r3, r4, #64	@ 0x40
323034d6:	4299      	cmp	r1, r3
323034d8:	d002      	beq.n	323034e0 <__sflush_r+0xa8>
323034da:	4640      	mov	r0, r8
323034dc:	f002 f984 	bl	323057e8 <_free_r>
323034e0:	2300      	movs	r3, #0
323034e2:	6323      	str	r3, [r4, #48]	@ 0x30
323034e4:	2000      	movs	r0, #0
323034e6:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
323034ea:	690e      	ldr	r6, [r1, #16]
323034ec:	2e00      	cmp	r6, #0
323034ee:	d0f9      	beq.n	323034e4 <__sflush_r+0xac>
323034f0:	680d      	ldr	r5, [r1, #0]
323034f2:	0792      	lsls	r2, r2, #30
323034f4:	600e      	str	r6, [r1, #0]
323034f6:	bf18      	it	ne
323034f8:	2300      	movne	r3, #0
323034fa:	eba5 0506 	sub.w	r5, r5, r6
323034fe:	d100      	bne.n	32303502 <__sflush_r+0xca>
32303500:	694b      	ldr	r3, [r1, #20]
32303502:	2d00      	cmp	r5, #0
32303504:	60a3      	str	r3, [r4, #8]
32303506:	dc04      	bgt.n	32303512 <__sflush_r+0xda>
32303508:	e7ec      	b.n	323034e4 <__sflush_r+0xac>
3230350a:	1a2d      	subs	r5, r5, r0
3230350c:	4406      	add	r6, r0
3230350e:	2d00      	cmp	r5, #0
32303510:	dde8      	ble.n	323034e4 <__sflush_r+0xac>
32303512:	69e1      	ldr	r1, [r4, #28]
32303514:	462b      	mov	r3, r5
32303516:	6a67      	ldr	r7, [r4, #36]	@ 0x24
32303518:	4632      	mov	r2, r6
3230351a:	4640      	mov	r0, r8
3230351c:	47b8      	blx	r7
3230351e:	2800      	cmp	r0, #0
32303520:	dcf3      	bgt.n	3230350a <__sflush_r+0xd2>
32303522:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32303526:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
3230352a:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3230352e:	81a3      	strh	r3, [r4, #12]
32303530:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
32303534:	6be1      	ldr	r1, [r4, #60]	@ 0x3c
32303536:	2900      	cmp	r1, #0
32303538:	dc8c      	bgt.n	32303454 <__sflush_r+0x1c>
3230353a:	e7d3      	b.n	323034e4 <__sflush_r+0xac>
3230353c:	6d22      	ldr	r2, [r4, #80]	@ 0x50
3230353e:	e79e      	b.n	3230347e <__sflush_r+0x46>
32303540:	6922      	ldr	r2, [r4, #16]
32303542:	6022      	str	r2, [r4, #0]
32303544:	f423 6200 	bic.w	r2, r3, #2048	@ 0x800
32303548:	04db      	lsls	r3, r3, #19
3230354a:	81a2      	strh	r2, [r4, #12]
3230354c:	f04f 0200 	mov.w	r2, #0
32303550:	6062      	str	r2, [r4, #4]
32303552:	d5ba      	bpl.n	323034ca <__sflush_r+0x92>
32303554:	6520      	str	r0, [r4, #80]	@ 0x50
32303556:	e7b8      	b.n	323034ca <__sflush_r+0x92>
32303558:	f8d8 3000 	ldr.w	r3, [r8]
3230355c:	2b00      	cmp	r3, #0
3230355e:	d08b      	beq.n	32303478 <__sflush_r+0x40>
32303560:	2b1d      	cmp	r3, #29
32303562:	bf18      	it	ne
32303564:	2b16      	cmpne	r3, #22
32303566:	d1dc      	bne.n	32303522 <__sflush_r+0xea>
32303568:	f8c8 5000 	str.w	r5, [r8]
3230356c:	e7ba      	b.n	323034e4 <__sflush_r+0xac>
3230356e:	bf00      	nop

32303570 <_fflush_r>:
32303570:	b538      	push	{r3, r4, r5, lr}
32303572:	460c      	mov	r4, r1
32303574:	4605      	mov	r5, r0
32303576:	b108      	cbz	r0, 3230357c <_fflush_r+0xc>
32303578:	6b43      	ldr	r3, [r0, #52]	@ 0x34
3230357a:	b303      	cbz	r3, 323035be <_fflush_r+0x4e>
3230357c:	f9b4 000c 	ldrsh.w	r0, [r4, #12]
32303580:	b188      	cbz	r0, 323035a6 <_fflush_r+0x36>
32303582:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32303584:	07db      	lsls	r3, r3, #31
32303586:	d401      	bmi.n	3230358c <_fflush_r+0x1c>
32303588:	0581      	lsls	r1, r0, #22
3230358a:	d50f      	bpl.n	323035ac <_fflush_r+0x3c>
3230358c:	4628      	mov	r0, r5
3230358e:	4621      	mov	r1, r4
32303590:	f7ff ff52 	bl	32303438 <__sflush_r>
32303594:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32303596:	4605      	mov	r5, r0
32303598:	07da      	lsls	r2, r3, #31
3230359a:	d402      	bmi.n	323035a2 <_fflush_r+0x32>
3230359c:	89a3      	ldrh	r3, [r4, #12]
3230359e:	059b      	lsls	r3, r3, #22
323035a0:	d508      	bpl.n	323035b4 <_fflush_r+0x44>
323035a2:	4628      	mov	r0, r5
323035a4:	bd38      	pop	{r3, r4, r5, pc}
323035a6:	4605      	mov	r5, r0
323035a8:	4628      	mov	r0, r5
323035aa:	bd38      	pop	{r3, r4, r5, pc}
323035ac:	6da0      	ldr	r0, [r4, #88]	@ 0x58
323035ae:	f001 fb53 	bl	32304c58 <__retarget_lock_acquire_recursive>
323035b2:	e7eb      	b.n	3230358c <_fflush_r+0x1c>
323035b4:	6da0      	ldr	r0, [r4, #88]	@ 0x58
323035b6:	f001 fb57 	bl	32304c68 <__retarget_lock_release_recursive>
323035ba:	4628      	mov	r0, r5
323035bc:	bd38      	pop	{r3, r4, r5, pc}
323035be:	f000 f98d 	bl	323038dc <__sinit>
323035c2:	e7db      	b.n	3230357c <_fflush_r+0xc>

323035c4 <fflush>:
323035c4:	b368      	cbz	r0, 32303622 <fflush+0x5e>
323035c6:	b538      	push	{r3, r4, r5, lr}
323035c8:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
323035cc:	f2c3 2330 	movt	r3, #12848	@ 0x3230
323035d0:	4604      	mov	r4, r0
323035d2:	681d      	ldr	r5, [r3, #0]
323035d4:	b10d      	cbz	r5, 323035da <fflush+0x16>
323035d6:	6b6b      	ldr	r3, [r5, #52]	@ 0x34
323035d8:	b1bb      	cbz	r3, 3230360a <fflush+0x46>
323035da:	f9b4 000c 	ldrsh.w	r0, [r4, #12]
323035de:	b188      	cbz	r0, 32303604 <fflush+0x40>
323035e0:	6e63      	ldr	r3, [r4, #100]	@ 0x64
323035e2:	07db      	lsls	r3, r3, #31
323035e4:	d401      	bmi.n	323035ea <fflush+0x26>
323035e6:	0581      	lsls	r1, r0, #22
323035e8:	d513      	bpl.n	32303612 <fflush+0x4e>
323035ea:	4628      	mov	r0, r5
323035ec:	4621      	mov	r1, r4
323035ee:	f7ff ff23 	bl	32303438 <__sflush_r>
323035f2:	6e63      	ldr	r3, [r4, #100]	@ 0x64
323035f4:	4605      	mov	r5, r0
323035f6:	07da      	lsls	r2, r3, #31
323035f8:	d402      	bmi.n	32303600 <fflush+0x3c>
323035fa:	89a3      	ldrh	r3, [r4, #12]
323035fc:	059b      	lsls	r3, r3, #22
323035fe:	d50c      	bpl.n	3230361a <fflush+0x56>
32303600:	4628      	mov	r0, r5
32303602:	bd38      	pop	{r3, r4, r5, pc}
32303604:	4605      	mov	r5, r0
32303606:	4628      	mov	r0, r5
32303608:	bd38      	pop	{r3, r4, r5, pc}
3230360a:	4628      	mov	r0, r5
3230360c:	f000 f966 	bl	323038dc <__sinit>
32303610:	e7e3      	b.n	323035da <fflush+0x16>
32303612:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32303614:	f001 fb20 	bl	32304c58 <__retarget_lock_acquire_recursive>
32303618:	e7e7      	b.n	323035ea <fflush+0x26>
3230361a:	6da0      	ldr	r0, [r4, #88]	@ 0x58
3230361c:	f001 fb24 	bl	32304c68 <__retarget_lock_release_recursive>
32303620:	e7ee      	b.n	32303600 <fflush+0x3c>
32303622:	f24c 021c 	movw	r2, #49180	@ 0xc01c
32303626:	f2c3 2230 	movt	r2, #12848	@ 0x3230
3230362a:	f243 5171 	movw	r1, #13681	@ 0x3571
3230362e:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32303632:	f24c 20a8 	movw	r0, #49832	@ 0xc2a8
32303636:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230363a:	f000 bb27 	b.w	32303c8c <_fwalk_sglue>
3230363e:	bf00      	nop

32303640 <stdio_exit_handler>:
32303640:	f24c 021c 	movw	r2, #49180	@ 0xc01c
32303644:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32303648:	f249 1191 	movw	r1, #37265	@ 0x9191
3230364c:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32303650:	f24c 20a8 	movw	r0, #49832	@ 0xc2a8
32303654:	f2c3 2030 	movt	r0, #12848	@ 0x3230
32303658:	f000 bb18 	b.w	32303c8c <_fwalk_sglue>

3230365c <cleanup_stdio>:
3230365c:	6841      	ldr	r1, [r0, #4]
3230365e:	f245 0338 	movw	r3, #20536	@ 0x5038
32303662:	f2c3 2331 	movt	r3, #12849	@ 0x3231
32303666:	b510      	push	{r4, lr}
32303668:	4299      	cmp	r1, r3
3230366a:	4604      	mov	r4, r0
3230366c:	d001      	beq.n	32303672 <cleanup_stdio+0x16>
3230366e:	f005 fd8f 	bl	32309190 <_fclose_r>
32303672:	68a1      	ldr	r1, [r4, #8]
32303674:	4b07      	ldr	r3, [pc, #28]	@ (32303694 <cleanup_stdio+0x38>)
32303676:	4299      	cmp	r1, r3
32303678:	d002      	beq.n	32303680 <cleanup_stdio+0x24>
3230367a:	4620      	mov	r0, r4
3230367c:	f005 fd88 	bl	32309190 <_fclose_r>
32303680:	68e1      	ldr	r1, [r4, #12]
32303682:	4b05      	ldr	r3, [pc, #20]	@ (32303698 <cleanup_stdio+0x3c>)
32303684:	4299      	cmp	r1, r3
32303686:	d004      	beq.n	32303692 <cleanup_stdio+0x36>
32303688:	4620      	mov	r0, r4
3230368a:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
3230368e:	f005 bd7f 	b.w	32309190 <_fclose_r>
32303692:	bd10      	pop	{r4, pc}
32303694:	323150a0 	.word	0x323150a0
32303698:	32315108 	.word	0x32315108

3230369c <__fp_lock>:
3230369c:	b508      	push	{r3, lr}
3230369e:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
323036a0:	07da      	lsls	r2, r3, #31
323036a2:	d402      	bmi.n	323036aa <__fp_lock+0xe>
323036a4:	898b      	ldrh	r3, [r1, #12]
323036a6:	059b      	lsls	r3, r3, #22
323036a8:	d501      	bpl.n	323036ae <__fp_lock+0x12>
323036aa:	2000      	movs	r0, #0
323036ac:	bd08      	pop	{r3, pc}
323036ae:	6d88      	ldr	r0, [r1, #88]	@ 0x58
323036b0:	f001 fad2 	bl	32304c58 <__retarget_lock_acquire_recursive>
323036b4:	2000      	movs	r0, #0
323036b6:	bd08      	pop	{r3, pc}

323036b8 <__fp_unlock>:
323036b8:	b508      	push	{r3, lr}
323036ba:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
323036bc:	07da      	lsls	r2, r3, #31
323036be:	d402      	bmi.n	323036c6 <__fp_unlock+0xe>
323036c0:	898b      	ldrh	r3, [r1, #12]
323036c2:	059b      	lsls	r3, r3, #22
323036c4:	d501      	bpl.n	323036ca <__fp_unlock+0x12>
323036c6:	2000      	movs	r0, #0
323036c8:	bd08      	pop	{r3, pc}
323036ca:	6d88      	ldr	r0, [r1, #88]	@ 0x58
323036cc:	f001 facc 	bl	32304c68 <__retarget_lock_release_recursive>
323036d0:	2000      	movs	r0, #0
323036d2:	bd08      	pop	{r3, pc}

323036d4 <global_stdio_init.part.0>:
323036d4:	b530      	push	{r4, r5, lr}
323036d6:	f245 0438 	movw	r4, #20536	@ 0x5038
323036da:	f2c3 2431 	movt	r4, #12849	@ 0x3231
323036de:	ed2d 8b02 	vpush	{d8}
323036e2:	4623      	mov	r3, r4
323036e4:	ed2d ab04 	vpush	{d10-d11}
323036e8:	b085      	sub	sp, #20
323036ea:	ef80 8010 	vmov.i32	d8, #0	@ 0x00000000
323036ee:	f104 0014 	add.w	r0, r4, #20
323036f2:	f245 1270 	movw	r2, #20848	@ 0x5170
323036f6:	f2c3 2231 	movt	r2, #12849	@ 0x3231
323036fa:	f643 51e9 	movw	r1, #15849	@ 0x3de9
323036fe:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32303702:	9100      	str	r1, [sp, #0]
32303704:	f643 6111 	movw	r1, #15889	@ 0x3e11
32303708:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230370c:	9101      	str	r1, [sp, #4]
3230370e:	f643 6151 	movw	r1, #15953	@ 0x3e51
32303712:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32303716:	9102      	str	r1, [sp, #8]
32303718:	f643 6179 	movw	r1, #15993	@ 0x3e79
3230371c:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32303720:	9103      	str	r1, [sp, #12]
32303722:	f92d aadf 	vld1.64	{d10-d11}, [sp :64]
32303726:	2500      	movs	r5, #0
32303728:	f843 5b04 	str.w	r5, [r3], #4
3230372c:	f243 6141 	movw	r1, #13889	@ 0x3641
32303730:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32303734:	f900 878f 	vst1.32	{d8}, [r0]
32303738:	6011      	str	r1, [r2, #0]
3230373a:	f104 005c 	add.w	r0, r4, #92	@ 0x5c
3230373e:	4629      	mov	r1, r5
32303740:	2204      	movs	r2, #4
32303742:	60e2      	str	r2, [r4, #12]
32303744:	2208      	movs	r2, #8
32303746:	f903 878f 	vst1.32	{d8}, [r3]
3230374a:	6665      	str	r5, [r4, #100]	@ 0x64
3230374c:	6125      	str	r5, [r4, #16]
3230374e:	f000 fc8b 	bl	32304068 <memset>
32303752:	f104 0058 	add.w	r0, r4, #88	@ 0x58
32303756:	61e4      	str	r4, [r4, #28]
32303758:	ed84 ab08 	vstr	d10, [r4, #32]
3230375c:	ed84 bb0a 	vstr	d11, [r4, #40]	@ 0x28
32303760:	f001 fa72 	bl	32304c48 <__retarget_lock_init_recursive>
32303764:	f104 006c 	add.w	r0, r4, #108	@ 0x6c
32303768:	f104 017c 	add.w	r1, r4, #124	@ 0x7c
3230376c:	2208      	movs	r2, #8
3230376e:	66a5      	str	r5, [r4, #104]	@ 0x68
32303770:	2309      	movs	r3, #9
32303772:	f2c0 0301 	movt	r3, #1
32303776:	f900 878f 	vst1.32	{d8}, [r0]
3230377a:	f901 878f 	vst1.32	{d8}, [r1]
3230377e:	f104 00c4 	add.w	r0, r4, #196	@ 0xc4
32303782:	4629      	mov	r1, r5
32303784:	6763      	str	r3, [r4, #116]	@ 0x74
32303786:	f8c4 50cc 	str.w	r5, [r4, #204]	@ 0xcc
3230378a:	67a5      	str	r5, [r4, #120]	@ 0x78
3230378c:	f000 fc6c 	bl	32304068 <memset>
32303790:	f104 00c0 	add.w	r0, r4, #192	@ 0xc0
32303794:	f104 0368 	add.w	r3, r4, #104	@ 0x68
32303798:	ed84 ab22 	vstr	d10, [r4, #136]	@ 0x88
3230379c:	ed84 bb24 	vstr	d11, [r4, #144]	@ 0x90
323037a0:	f8c4 3084 	str.w	r3, [r4, #132]	@ 0x84
323037a4:	f001 fa50 	bl	32304c48 <__retarget_lock_init_recursive>
323037a8:	f104 00e4 	add.w	r0, r4, #228	@ 0xe4
323037ac:	f104 0cd4 	add.w	ip, r4, #212	@ 0xd4
323037b0:	2208      	movs	r2, #8
323037b2:	4629      	mov	r1, r5
323037b4:	f8c4 50d0 	str.w	r5, [r4, #208]	@ 0xd0
323037b8:	2312      	movs	r3, #18
323037ba:	f2c0 0302 	movt	r3, #2
323037be:	f900 878f 	vst1.32	{d8}, [r0]
323037c2:	f504 7096 	add.w	r0, r4, #300	@ 0x12c
323037c6:	f8c4 30dc 	str.w	r3, [r4, #220]	@ 0xdc
323037ca:	f8c4 5134 	str.w	r5, [r4, #308]	@ 0x134
323037ce:	f8c4 50e0 	str.w	r5, [r4, #224]	@ 0xe0
323037d2:	f90c 878f 	vst1.32	{d8}, [ip]
323037d6:	f000 fc47 	bl	32304068 <memset>
323037da:	f104 03d0 	add.w	r3, r4, #208	@ 0xd0
323037de:	f504 7094 	add.w	r0, r4, #296	@ 0x128
323037e2:	f8c4 30ec 	str.w	r3, [r4, #236]	@ 0xec
323037e6:	ed84 ab3c 	vstr	d10, [r4, #240]	@ 0xf0
323037ea:	ed84 bb3e 	vstr	d11, [r4, #248]	@ 0xf8
323037ee:	b005      	add	sp, #20
323037f0:	ecbd ab04 	vpop	{d10-d11}
323037f4:	ecbd 8b02 	vpop	{d8}
323037f8:	e8bd 4030 	ldmia.w	sp!, {r4, r5, lr}
323037fc:	f001 ba24 	b.w	32304c48 <__retarget_lock_init_recursive>

32303800 <__sfp>:
32303800:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
32303802:	4607      	mov	r7, r0
32303804:	f245 305c 	movw	r0, #21340	@ 0x535c
32303808:	f2c3 2031 	movt	r0, #12849	@ 0x3231
3230380c:	f001 fa24 	bl	32304c58 <__retarget_lock_acquire_recursive>
32303810:	f245 1370 	movw	r3, #20848	@ 0x5170
32303814:	f2c3 2331 	movt	r3, #12849	@ 0x3231
32303818:	681b      	ldr	r3, [r3, #0]
3230381a:	2b00      	cmp	r3, #0
3230381c:	d050      	beq.n	323038c0 <__sfp+0xc0>
3230381e:	f24c 061c 	movw	r6, #49180	@ 0xc01c
32303822:	f2c3 2630 	movt	r6, #12848	@ 0x3230
32303826:	e9d6 3401 	ldrd	r3, r4, [r6, #4]
3230382a:	3b01      	subs	r3, #1
3230382c:	d503      	bpl.n	32303836 <__sfp+0x36>
3230382e:	e02e      	b.n	3230388e <__sfp+0x8e>
32303830:	3468      	adds	r4, #104	@ 0x68
32303832:	1c5a      	adds	r2, r3, #1
32303834:	d02b      	beq.n	3230388e <__sfp+0x8e>
32303836:	f9b4 500c 	ldrsh.w	r5, [r4, #12]
3230383a:	3b01      	subs	r3, #1
3230383c:	2d00      	cmp	r5, #0
3230383e:	d1f7      	bne.n	32303830 <__sfp+0x30>
32303840:	f104 0058 	add.w	r0, r4, #88	@ 0x58
32303844:	2301      	movs	r3, #1
32303846:	f6cf 73ff 	movt	r3, #65535	@ 0xffff
3230384a:	6665      	str	r5, [r4, #100]	@ 0x64
3230384c:	60e3      	str	r3, [r4, #12]
3230384e:	f001 f9fb 	bl	32304c48 <__retarget_lock_init_recursive>
32303852:	f245 305c 	movw	r0, #21340	@ 0x535c
32303856:	f2c3 2031 	movt	r0, #12849	@ 0x3231
3230385a:	f001 fa05 	bl	32304c68 <__retarget_lock_release_recursive>
3230385e:	4621      	mov	r1, r4
32303860:	efc0 0010 	vmov.i32	d16, #0	@ 0x00000000
32303864:	f104 0314 	add.w	r3, r4, #20
32303868:	2208      	movs	r2, #8
3230386a:	f104 005c 	add.w	r0, r4, #92	@ 0x5c
3230386e:	f841 5b04 	str.w	r5, [r1], #4
32303872:	f941 078f 	vst1.32	{d16}, [r1]
32303876:	4629      	mov	r1, r5
32303878:	6125      	str	r5, [r4, #16]
3230387a:	f943 078f 	vst1.32	{d16}, [r3]
3230387e:	f000 fbf3 	bl	32304068 <memset>
32303882:	e9c4 550c 	strd	r5, r5, [r4, #48]	@ 0x30
32303886:	e9c4 5511 	strd	r5, r5, [r4, #68]	@ 0x44
3230388a:	4620      	mov	r0, r4
3230388c:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3230388e:	6835      	ldr	r5, [r6, #0]
32303890:	b10d      	cbz	r5, 32303896 <__sfp+0x96>
32303892:	462e      	mov	r6, r5
32303894:	e7c7      	b.n	32303826 <__sfp+0x26>
32303896:	f44f 71d6 	mov.w	r1, #428	@ 0x1ac
3230389a:	4638      	mov	r0, r7
3230389c:	f002 f8f4 	bl	32305a88 <_malloc_r>
323038a0:	4604      	mov	r4, r0
323038a2:	b180      	cbz	r0, 323038c6 <__sfp+0xc6>
323038a4:	6005      	str	r5, [r0, #0]
323038a6:	2304      	movs	r3, #4
323038a8:	4629      	mov	r1, r5
323038aa:	6043      	str	r3, [r0, #4]
323038ac:	f44f 72d0 	mov.w	r2, #416	@ 0x1a0
323038b0:	300c      	adds	r0, #12
323038b2:	4625      	mov	r5, r4
323038b4:	60a0      	str	r0, [r4, #8]
323038b6:	f000 fbd7 	bl	32304068 <memset>
323038ba:	6034      	str	r4, [r6, #0]
323038bc:	462e      	mov	r6, r5
323038be:	e7b2      	b.n	32303826 <__sfp+0x26>
323038c0:	f7ff ff08 	bl	323036d4 <global_stdio_init.part.0>
323038c4:	e7ab      	b.n	3230381e <__sfp+0x1e>
323038c6:	6030      	str	r0, [r6, #0]
323038c8:	f245 305c 	movw	r0, #21340	@ 0x535c
323038cc:	f2c3 2031 	movt	r0, #12849	@ 0x3231
323038d0:	f001 f9ca 	bl	32304c68 <__retarget_lock_release_recursive>
323038d4:	230c      	movs	r3, #12
323038d6:	603b      	str	r3, [r7, #0]
323038d8:	e7d7      	b.n	3230388a <__sfp+0x8a>
323038da:	bf00      	nop

323038dc <__sinit>:
323038dc:	b510      	push	{r4, lr}
323038de:	4604      	mov	r4, r0
323038e0:	f245 305c 	movw	r0, #21340	@ 0x535c
323038e4:	f2c3 2031 	movt	r0, #12849	@ 0x3231
323038e8:	f001 f9b6 	bl	32304c58 <__retarget_lock_acquire_recursive>
323038ec:	6b63      	ldr	r3, [r4, #52]	@ 0x34
323038ee:	b953      	cbnz	r3, 32303906 <__sinit+0x2a>
323038f0:	f245 1370 	movw	r3, #20848	@ 0x5170
323038f4:	f2c3 2331 	movt	r3, #12849	@ 0x3231
323038f8:	f243 625d 	movw	r2, #13917	@ 0x365d
323038fc:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32303900:	6362      	str	r2, [r4, #52]	@ 0x34
32303902:	681b      	ldr	r3, [r3, #0]
32303904:	b13b      	cbz	r3, 32303916 <__sinit+0x3a>
32303906:	f245 305c 	movw	r0, #21340	@ 0x535c
3230390a:	f2c3 2031 	movt	r0, #12849	@ 0x3231
3230390e:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
32303912:	f001 b9a9 	b.w	32304c68 <__retarget_lock_release_recursive>
32303916:	f7ff fedd 	bl	323036d4 <global_stdio_init.part.0>
3230391a:	f245 305c 	movw	r0, #21340	@ 0x535c
3230391e:	f2c3 2031 	movt	r0, #12849	@ 0x3231
32303922:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
32303926:	f001 b99f 	b.w	32304c68 <__retarget_lock_release_recursive>
3230392a:	bf00      	nop

3230392c <__sfp_lock_acquire>:
3230392c:	f245 305c 	movw	r0, #21340	@ 0x535c
32303930:	f2c3 2031 	movt	r0, #12849	@ 0x3231
32303934:	f001 b990 	b.w	32304c58 <__retarget_lock_acquire_recursive>

32303938 <__sfp_lock_release>:
32303938:	f245 305c 	movw	r0, #21340	@ 0x535c
3230393c:	f2c3 2031 	movt	r0, #12849	@ 0x3231
32303940:	f001 b992 	b.w	32304c68 <__retarget_lock_release_recursive>

32303944 <__fp_lock_all>:
32303944:	b508      	push	{r3, lr}
32303946:	f245 305c 	movw	r0, #21340	@ 0x535c
3230394a:	f2c3 2031 	movt	r0, #12849	@ 0x3231
3230394e:	f001 f983 	bl	32304c58 <__retarget_lock_acquire_recursive>
32303952:	f24c 021c 	movw	r2, #49180	@ 0xc01c
32303956:	f2c3 2230 	movt	r2, #12848	@ 0x3230
3230395a:	f243 619d 	movw	r1, #13981	@ 0x369d
3230395e:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32303962:	2000      	movs	r0, #0
32303964:	e8bd 4008 	ldmia.w	sp!, {r3, lr}
32303968:	f000 b990 	b.w	32303c8c <_fwalk_sglue>

3230396c <__fp_unlock_all>:
3230396c:	b508      	push	{r3, lr}
3230396e:	2000      	movs	r0, #0
32303970:	f24c 021c 	movw	r2, #49180	@ 0xc01c
32303974:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32303978:	f243 61b9 	movw	r1, #14009	@ 0x36b9
3230397c:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32303980:	f000 f984 	bl	32303c8c <_fwalk_sglue>
32303984:	f245 305c 	movw	r0, #21340	@ 0x535c
32303988:	f2c3 2031 	movt	r0, #12849	@ 0x3231
3230398c:	e8bd 4008 	ldmia.w	sp!, {r3, lr}
32303990:	f001 b96a 	b.w	32304c68 <__retarget_lock_release_recursive>

32303994 <__sfvwrite_r>:
32303994:	6893      	ldr	r3, [r2, #8]
32303996:	2b00      	cmp	r3, #0
32303998:	f000 80bb 	beq.w	32303b12 <__sfvwrite_r+0x17e>
3230399c:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
323039a0:	4617      	mov	r7, r2
323039a2:	f9b1 c00c 	ldrsh.w	ip, [r1, #12]
323039a6:	b083      	sub	sp, #12
323039a8:	4680      	mov	r8, r0
323039aa:	460c      	mov	r4, r1
323039ac:	f01c 0f08 	tst.w	ip, #8
323039b0:	d029      	beq.n	32303a06 <__sfvwrite_r+0x72>
323039b2:	690b      	ldr	r3, [r1, #16]
323039b4:	b33b      	cbz	r3, 32303a06 <__sfvwrite_r+0x72>
323039b6:	683d      	ldr	r5, [r7, #0]
323039b8:	f01c 0302 	ands.w	r3, ip, #2
323039bc:	d02f      	beq.n	32303a1e <__sfvwrite_r+0x8a>
323039be:	f04f 0a00 	mov.w	sl, #0
323039c2:	f44f 4b7c 	mov.w	fp, #64512	@ 0xfc00
323039c6:	f6c7 7bff 	movt	fp, #32767	@ 0x7fff
323039ca:	4656      	mov	r6, sl
323039cc:	46b9      	mov	r9, r7
323039ce:	455e      	cmp	r6, fp
323039d0:	4633      	mov	r3, r6
323039d2:	4652      	mov	r2, sl
323039d4:	bf28      	it	cs
323039d6:	465b      	movcs	r3, fp
323039d8:	4640      	mov	r0, r8
323039da:	2e00      	cmp	r6, #0
323039dc:	f000 8087 	beq.w	32303aee <__sfvwrite_r+0x15a>
323039e0:	69e1      	ldr	r1, [r4, #28]
323039e2:	6a67      	ldr	r7, [r4, #36]	@ 0x24
323039e4:	47b8      	blx	r7
323039e6:	2800      	cmp	r0, #0
323039e8:	f340 808b 	ble.w	32303b02 <__sfvwrite_r+0x16e>
323039ec:	f8d9 3008 	ldr.w	r3, [r9, #8]
323039f0:	4482      	add	sl, r0
323039f2:	1a36      	subs	r6, r6, r0
323039f4:	1a1b      	subs	r3, r3, r0
323039f6:	f8c9 3008 	str.w	r3, [r9, #8]
323039fa:	2b00      	cmp	r3, #0
323039fc:	d1e7      	bne.n	323039ce <__sfvwrite_r+0x3a>
323039fe:	2000      	movs	r0, #0
32303a00:	b003      	add	sp, #12
32303a02:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32303a06:	4621      	mov	r1, r4
32303a08:	4640      	mov	r0, r8
32303a0a:	f000 fa39 	bl	32303e80 <__swsetup_r>
32303a0e:	2800      	cmp	r0, #0
32303a10:	d17c      	bne.n	32303b0c <__sfvwrite_r+0x178>
32303a12:	f9b4 c00c 	ldrsh.w	ip, [r4, #12]
32303a16:	683d      	ldr	r5, [r7, #0]
32303a18:	f01c 0302 	ands.w	r3, ip, #2
32303a1c:	d1cf      	bne.n	323039be <__sfvwrite_r+0x2a>
32303a1e:	f01c 0901 	ands.w	r9, ip, #1
32303a22:	d178      	bne.n	32303b16 <__sfvwrite_r+0x182>
32303a24:	464e      	mov	r6, r9
32303a26:	9700      	str	r7, [sp, #0]
32303a28:	2e00      	cmp	r6, #0
32303a2a:	d05c      	beq.n	32303ae6 <__sfvwrite_r+0x152>
32303a2c:	6820      	ldr	r0, [r4, #0]
32303a2e:	f41c 7f00 	tst.w	ip, #512	@ 0x200
32303a32:	f8d4 b008 	ldr.w	fp, [r4, #8]
32303a36:	f000 80bd 	beq.w	32303bb4 <__sfvwrite_r+0x220>
32303a3a:	465a      	mov	r2, fp
32303a3c:	45b3      	cmp	fp, r6
32303a3e:	f200 80eb 	bhi.w	32303c18 <__sfvwrite_r+0x284>
32303a42:	f41c 6f90 	tst.w	ip, #1152	@ 0x480
32303a46:	d034      	beq.n	32303ab2 <__sfvwrite_r+0x11e>
32303a48:	6962      	ldr	r2, [r4, #20]
32303a4a:	6921      	ldr	r1, [r4, #16]
32303a4c:	eb02 0242 	add.w	r2, r2, r2, lsl #1
32303a50:	eba0 0a01 	sub.w	sl, r0, r1
32303a54:	f10a 0301 	add.w	r3, sl, #1
32303a58:	eb02 72d2 	add.w	r2, r2, r2, lsr #31
32303a5c:	4433      	add	r3, r6
32303a5e:	1052      	asrs	r2, r2, #1
32303a60:	4293      	cmp	r3, r2
32303a62:	bf98      	it	ls
32303a64:	4693      	movls	fp, r2
32303a66:	bf88      	it	hi
32303a68:	469b      	movhi	fp, r3
32303a6a:	bf88      	it	hi
32303a6c:	461a      	movhi	r2, r3
32303a6e:	f41c 6f80 	tst.w	ip, #1024	@ 0x400
32303a72:	f000 80ef 	beq.w	32303c54 <__sfvwrite_r+0x2c0>
32303a76:	4611      	mov	r1, r2
32303a78:	4640      	mov	r0, r8
32303a7a:	f002 f805 	bl	32305a88 <_malloc_r>
32303a7e:	2800      	cmp	r0, #0
32303a80:	f000 80fe 	beq.w	32303c80 <__sfvwrite_r+0x2ec>
32303a84:	4652      	mov	r2, sl
32303a86:	6921      	ldr	r1, [r4, #16]
32303a88:	9001      	str	r0, [sp, #4]
32303a8a:	f001 eb5a 	blx	32305140 <memcpy>
32303a8e:	89a2      	ldrh	r2, [r4, #12]
32303a90:	9b01      	ldr	r3, [sp, #4]
32303a92:	f422 6290 	bic.w	r2, r2, #1152	@ 0x480
32303a96:	f042 0280 	orr.w	r2, r2, #128	@ 0x80
32303a9a:	81a2      	strh	r2, [r4, #12]
32303a9c:	eb03 000a 	add.w	r0, r3, sl
32303aa0:	6123      	str	r3, [r4, #16]
32303aa2:	f8c4 b014 	str.w	fp, [r4, #20]
32303aa6:	ebab 030a 	sub.w	r3, fp, sl
32303aaa:	4632      	mov	r2, r6
32303aac:	46b3      	mov	fp, r6
32303aae:	60a3      	str	r3, [r4, #8]
32303ab0:	6020      	str	r0, [r4, #0]
32303ab2:	4649      	mov	r1, r9
32303ab4:	9201      	str	r2, [sp, #4]
32303ab6:	f000 fa59 	bl	32303f6c <memmove>
32303aba:	68a3      	ldr	r3, [r4, #8]
32303abc:	9a01      	ldr	r2, [sp, #4]
32303abe:	46b2      	mov	sl, r6
32303ac0:	eba3 010b 	sub.w	r1, r3, fp
32303ac4:	6823      	ldr	r3, [r4, #0]
32303ac6:	2600      	movs	r6, #0
32303ac8:	60a1      	str	r1, [r4, #8]
32303aca:	4413      	add	r3, r2
32303acc:	6023      	str	r3, [r4, #0]
32303ace:	9a00      	ldr	r2, [sp, #0]
32303ad0:	44d1      	add	r9, sl
32303ad2:	6893      	ldr	r3, [r2, #8]
32303ad4:	eba3 030a 	sub.w	r3, r3, sl
32303ad8:	6093      	str	r3, [r2, #8]
32303ada:	2b00      	cmp	r3, #0
32303adc:	d08f      	beq.n	323039fe <__sfvwrite_r+0x6a>
32303ade:	f9b4 c00c 	ldrsh.w	ip, [r4, #12]
32303ae2:	2e00      	cmp	r6, #0
32303ae4:	d1a2      	bne.n	32303a2c <__sfvwrite_r+0x98>
32303ae6:	e9d5 9600 	ldrd	r9, r6, [r5]
32303aea:	3508      	adds	r5, #8
32303aec:	e79c      	b.n	32303a28 <__sfvwrite_r+0x94>
32303aee:	e9d5 a600 	ldrd	sl, r6, [r5]
32303af2:	3508      	adds	r5, #8
32303af4:	e76b      	b.n	323039ce <__sfvwrite_r+0x3a>
32303af6:	4621      	mov	r1, r4
32303af8:	4640      	mov	r0, r8
32303afa:	f7ff fd39 	bl	32303570 <_fflush_r>
32303afe:	2800      	cmp	r0, #0
32303b00:	d036      	beq.n	32303b70 <__sfvwrite_r+0x1dc>
32303b02:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32303b06:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32303b0a:	81a3      	strh	r3, [r4, #12]
32303b0c:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32303b10:	e776      	b.n	32303a00 <__sfvwrite_r+0x6c>
32303b12:	2000      	movs	r0, #0
32303b14:	4770      	bx	lr
32303b16:	46ba      	mov	sl, r7
32303b18:	4699      	mov	r9, r3
32303b1a:	4618      	mov	r0, r3
32303b1c:	461e      	mov	r6, r3
32303b1e:	461f      	mov	r7, r3
32303b20:	9500      	str	r5, [sp, #0]
32303b22:	2e00      	cmp	r6, #0
32303b24:	d032      	beq.n	32303b8c <__sfvwrite_r+0x1f8>
32303b26:	2800      	cmp	r0, #0
32303b28:	d039      	beq.n	32303b9e <__sfvwrite_r+0x20a>
32303b2a:	464a      	mov	r2, r9
32303b2c:	68a1      	ldr	r1, [r4, #8]
32303b2e:	42b2      	cmp	r2, r6
32303b30:	6963      	ldr	r3, [r4, #20]
32303b32:	bf28      	it	cs
32303b34:	4632      	movcs	r2, r6
32303b36:	6820      	ldr	r0, [r4, #0]
32303b38:	eb03 0b01 	add.w	fp, r3, r1
32303b3c:	6921      	ldr	r1, [r4, #16]
32303b3e:	4288      	cmp	r0, r1
32303b40:	bf98      	it	ls
32303b42:	2100      	movls	r1, #0
32303b44:	bf88      	it	hi
32303b46:	2101      	movhi	r1, #1
32303b48:	455a      	cmp	r2, fp
32303b4a:	bfd8      	it	le
32303b4c:	2100      	movle	r1, #0
32303b4e:	2900      	cmp	r1, #0
32303b50:	d172      	bne.n	32303c38 <__sfvwrite_r+0x2a4>
32303b52:	4293      	cmp	r3, r2
32303b54:	dc63      	bgt.n	32303c1e <__sfvwrite_r+0x28a>
32303b56:	69e1      	ldr	r1, [r4, #28]
32303b58:	463a      	mov	r2, r7
32303b5a:	6a65      	ldr	r5, [r4, #36]	@ 0x24
32303b5c:	4640      	mov	r0, r8
32303b5e:	47a8      	blx	r5
32303b60:	f1b0 0b00 	subs.w	fp, r0, #0
32303b64:	ddcd      	ble.n	32303b02 <__sfvwrite_r+0x16e>
32303b66:	ebb9 090b 	subs.w	r9, r9, fp
32303b6a:	bf18      	it	ne
32303b6c:	2001      	movne	r0, #1
32303b6e:	d0c2      	beq.n	32303af6 <__sfvwrite_r+0x162>
32303b70:	f8da 3008 	ldr.w	r3, [sl, #8]
32303b74:	445f      	add	r7, fp
32303b76:	eba6 060b 	sub.w	r6, r6, fp
32303b7a:	eba3 030b 	sub.w	r3, r3, fp
32303b7e:	f8ca 3008 	str.w	r3, [sl, #8]
32303b82:	2b00      	cmp	r3, #0
32303b84:	f43f af3b 	beq.w	323039fe <__sfvwrite_r+0x6a>
32303b88:	2e00      	cmp	r6, #0
32303b8a:	d1cc      	bne.n	32303b26 <__sfvwrite_r+0x192>
32303b8c:	9a00      	ldr	r2, [sp, #0]
32303b8e:	4613      	mov	r3, r2
32303b90:	3208      	adds	r2, #8
32303b92:	f852 6c04 	ldr.w	r6, [r2, #-4]
32303b96:	9200      	str	r2, [sp, #0]
32303b98:	2e00      	cmp	r6, #0
32303b9a:	d0f7      	beq.n	32303b8c <__sfvwrite_r+0x1f8>
32303b9c:	681f      	ldr	r7, [r3, #0]
32303b9e:	4632      	mov	r2, r6
32303ba0:	210a      	movs	r1, #10
32303ba2:	4638      	mov	r0, r7
32303ba4:	f001 fa44 	bl	32305030 <memchr>
32303ba8:	2800      	cmp	r0, #0
32303baa:	d066      	beq.n	32303c7a <__sfvwrite_r+0x2e6>
32303bac:	3001      	adds	r0, #1
32303bae:	eba0 0907 	sub.w	r9, r0, r7
32303bb2:	e7ba      	b.n	32303b2a <__sfvwrite_r+0x196>
32303bb4:	6923      	ldr	r3, [r4, #16]
32303bb6:	4283      	cmp	r3, r0
32303bb8:	d316      	bcc.n	32303be8 <__sfvwrite_r+0x254>
32303bba:	6962      	ldr	r2, [r4, #20]
32303bbc:	42b2      	cmp	r2, r6
32303bbe:	d813      	bhi.n	32303be8 <__sfvwrite_r+0x254>
32303bc0:	f06f 4300 	mvn.w	r3, #2147483648	@ 0x80000000
32303bc4:	69e1      	ldr	r1, [r4, #28]
32303bc6:	42b3      	cmp	r3, r6
32303bc8:	6a67      	ldr	r7, [r4, #36]	@ 0x24
32303bca:	bf28      	it	cs
32303bcc:	4633      	movcs	r3, r6
32303bce:	4640      	mov	r0, r8
32303bd0:	fb93 f3f2 	sdiv	r3, r3, r2
32303bd4:	fb02 f303 	mul.w	r3, r2, r3
32303bd8:	464a      	mov	r2, r9
32303bda:	47b8      	blx	r7
32303bdc:	f1b0 0a00 	subs.w	sl, r0, #0
32303be0:	dd8f      	ble.n	32303b02 <__sfvwrite_r+0x16e>
32303be2:	eba6 060a 	sub.w	r6, r6, sl
32303be6:	e772      	b.n	32303ace <__sfvwrite_r+0x13a>
32303be8:	45b3      	cmp	fp, r6
32303bea:	46da      	mov	sl, fp
32303bec:	bf28      	it	cs
32303bee:	46b2      	movcs	sl, r6
32303bf0:	4649      	mov	r1, r9
32303bf2:	4652      	mov	r2, sl
32303bf4:	f000 f9ba 	bl	32303f6c <memmove>
32303bf8:	68a3      	ldr	r3, [r4, #8]
32303bfa:	6822      	ldr	r2, [r4, #0]
32303bfc:	eba3 030a 	sub.w	r3, r3, sl
32303c00:	60a3      	str	r3, [r4, #8]
32303c02:	4452      	add	r2, sl
32303c04:	6022      	str	r2, [r4, #0]
32303c06:	2b00      	cmp	r3, #0
32303c08:	d1eb      	bne.n	32303be2 <__sfvwrite_r+0x24e>
32303c0a:	4621      	mov	r1, r4
32303c0c:	4640      	mov	r0, r8
32303c0e:	f7ff fcaf 	bl	32303570 <_fflush_r>
32303c12:	2800      	cmp	r0, #0
32303c14:	d0e5      	beq.n	32303be2 <__sfvwrite_r+0x24e>
32303c16:	e774      	b.n	32303b02 <__sfvwrite_r+0x16e>
32303c18:	46b3      	mov	fp, r6
32303c1a:	4632      	mov	r2, r6
32303c1c:	e749      	b.n	32303ab2 <__sfvwrite_r+0x11e>
32303c1e:	4639      	mov	r1, r7
32303c20:	9201      	str	r2, [sp, #4]
32303c22:	f000 f9a3 	bl	32303f6c <memmove>
32303c26:	9a01      	ldr	r2, [sp, #4]
32303c28:	68a3      	ldr	r3, [r4, #8]
32303c2a:	4693      	mov	fp, r2
32303c2c:	1a9b      	subs	r3, r3, r2
32303c2e:	60a3      	str	r3, [r4, #8]
32303c30:	6823      	ldr	r3, [r4, #0]
32303c32:	4413      	add	r3, r2
32303c34:	6023      	str	r3, [r4, #0]
32303c36:	e796      	b.n	32303b66 <__sfvwrite_r+0x1d2>
32303c38:	4639      	mov	r1, r7
32303c3a:	465a      	mov	r2, fp
32303c3c:	f000 f996 	bl	32303f6c <memmove>
32303c40:	6823      	ldr	r3, [r4, #0]
32303c42:	4621      	mov	r1, r4
32303c44:	4640      	mov	r0, r8
32303c46:	445b      	add	r3, fp
32303c48:	6023      	str	r3, [r4, #0]
32303c4a:	f7ff fc91 	bl	32303570 <_fflush_r>
32303c4e:	2800      	cmp	r0, #0
32303c50:	d089      	beq.n	32303b66 <__sfvwrite_r+0x1d2>
32303c52:	e756      	b.n	32303b02 <__sfvwrite_r+0x16e>
32303c54:	4640      	mov	r0, r8
32303c56:	f002 fc75 	bl	32306544 <_realloc_r>
32303c5a:	4603      	mov	r3, r0
32303c5c:	2800      	cmp	r0, #0
32303c5e:	f47f af1d 	bne.w	32303a9c <__sfvwrite_r+0x108>
32303c62:	6921      	ldr	r1, [r4, #16]
32303c64:	4640      	mov	r0, r8
32303c66:	f001 fdbf 	bl	323057e8 <_free_r>
32303c6a:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32303c6e:	220c      	movs	r2, #12
32303c70:	f8c8 2000 	str.w	r2, [r8]
32303c74:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32303c78:	e745      	b.n	32303b06 <__sfvwrite_r+0x172>
32303c7a:	1c72      	adds	r2, r6, #1
32303c7c:	4691      	mov	r9, r2
32303c7e:	e755      	b.n	32303b2c <__sfvwrite_r+0x198>
32303c80:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32303c84:	220c      	movs	r2, #12
32303c86:	f8c8 2000 	str.w	r2, [r8]
32303c8a:	e73c      	b.n	32303b06 <__sfvwrite_r+0x172>

32303c8c <_fwalk_sglue>:
32303c8c:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
32303c90:	4607      	mov	r7, r0
32303c92:	4688      	mov	r8, r1
32303c94:	4616      	mov	r6, r2
32303c96:	f04f 0900 	mov.w	r9, #0
32303c9a:	e9d6 5401 	ldrd	r5, r4, [r6, #4]
32303c9e:	3d01      	subs	r5, #1
32303ca0:	d40f      	bmi.n	32303cc2 <_fwalk_sglue+0x36>
32303ca2:	89a3      	ldrh	r3, [r4, #12]
32303ca4:	2b01      	cmp	r3, #1
32303ca6:	d908      	bls.n	32303cba <_fwalk_sglue+0x2e>
32303ca8:	f9b4 300e 	ldrsh.w	r3, [r4, #14]
32303cac:	4621      	mov	r1, r4
32303cae:	4638      	mov	r0, r7
32303cb0:	3301      	adds	r3, #1
32303cb2:	d002      	beq.n	32303cba <_fwalk_sglue+0x2e>
32303cb4:	47c0      	blx	r8
32303cb6:	ea49 0900 	orr.w	r9, r9, r0
32303cba:	3d01      	subs	r5, #1
32303cbc:	3468      	adds	r4, #104	@ 0x68
32303cbe:	1c6b      	adds	r3, r5, #1
32303cc0:	d1ef      	bne.n	32303ca2 <_fwalk_sglue+0x16>
32303cc2:	6836      	ldr	r6, [r6, #0]
32303cc4:	2e00      	cmp	r6, #0
32303cc6:	d1e8      	bne.n	32303c9a <_fwalk_sglue+0xe>
32303cc8:	4648      	mov	r0, r9
32303cca:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
32303cce:	bf00      	nop

32303cd0 <_printf_r>:
32303cd0:	b40e      	push	{r1, r2, r3}
32303cd2:	6881      	ldr	r1, [r0, #8]
32303cd4:	b500      	push	{lr}
32303cd6:	b082      	sub	sp, #8
32303cd8:	ab03      	add	r3, sp, #12
32303cda:	f853 2b04 	ldr.w	r2, [r3], #4
32303cde:	9301      	str	r3, [sp, #4]
32303ce0:	f003 f8ca 	bl	32306e78 <_vfprintf_r>
32303ce4:	b002      	add	sp, #8
32303ce6:	f85d eb04 	ldr.w	lr, [sp], #4
32303cea:	b003      	add	sp, #12
32303cec:	4770      	bx	lr
32303cee:	bf00      	nop

32303cf0 <printf>:
32303cf0:	b40f      	push	{r0, r1, r2, r3}
32303cf2:	f24c 22a0 	movw	r2, #49824	@ 0xc2a0
32303cf6:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32303cfa:	b500      	push	{lr}
32303cfc:	b083      	sub	sp, #12
32303cfe:	6810      	ldr	r0, [r2, #0]
32303d00:	ab04      	add	r3, sp, #16
32303d02:	6881      	ldr	r1, [r0, #8]
32303d04:	f853 2b04 	ldr.w	r2, [r3], #4
32303d08:	9301      	str	r3, [sp, #4]
32303d0a:	f003 f8b5 	bl	32306e78 <_vfprintf_r>
32303d0e:	b003      	add	sp, #12
32303d10:	f85d eb04 	ldr.w	lr, [sp], #4
32303d14:	b004      	add	sp, #16
32303d16:	4770      	bx	lr

32303d18 <_puts_r>:
32303d18:	b530      	push	{r4, r5, lr}
32303d1a:	4605      	mov	r5, r0
32303d1c:	4608      	mov	r0, r1
32303d1e:	b089      	sub	sp, #36	@ 0x24
32303d20:	460c      	mov	r4, r1
32303d22:	f001 fc8d 	bl	32305640 <strlen>
32303d26:	6b6a      	ldr	r2, [r5, #52]	@ 0x34
32303d28:	2101      	movs	r1, #1
32303d2a:	f64b 03fc 	movw	r3, #47356	@ 0xb8fc
32303d2e:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32303d32:	e9cd 4004 	strd	r4, r0, [sp, #16]
32303d36:	e9cd 3106 	strd	r3, r1, [sp, #24]
32303d3a:	4408      	add	r0, r1
32303d3c:	2302      	movs	r3, #2
32303d3e:	a904      	add	r1, sp, #16
32303d40:	68ac      	ldr	r4, [r5, #8]
32303d42:	9003      	str	r0, [sp, #12]
32303d44:	e9cd 1301 	strd	r1, r3, [sp, #4]
32303d48:	2a00      	cmp	r2, #0
32303d4a:	d040      	beq.n	32303dce <_puts_r+0xb6>
32303d4c:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32303d4e:	f9b4 200c 	ldrsh.w	r2, [r4, #12]
32303d52:	07d8      	lsls	r0, r3, #31
32303d54:	d51a      	bpl.n	32303d8c <_puts_r+0x74>
32303d56:	0491      	lsls	r1, r2, #18
32303d58:	d421      	bmi.n	32303d9e <_puts_r+0x86>
32303d5a:	f442 5200 	orr.w	r2, r2, #8192	@ 0x2000
32303d5e:	f423 5300 	bic.w	r3, r3, #8192	@ 0x2000
32303d62:	81a2      	strh	r2, [r4, #12]
32303d64:	6663      	str	r3, [r4, #100]	@ 0x64
32303d66:	4628      	mov	r0, r5
32303d68:	aa01      	add	r2, sp, #4
32303d6a:	4621      	mov	r1, r4
32303d6c:	f04f 35ff 	mov.w	r5, #4294967295	@ 0xffffffff
32303d70:	f7ff fe10 	bl	32303994 <__sfvwrite_r>
32303d74:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32303d76:	2800      	cmp	r0, #0
32303d78:	bf08      	it	eq
32303d7a:	250a      	moveq	r5, #10
32303d7c:	07da      	lsls	r2, r3, #31
32303d7e:	d402      	bmi.n	32303d86 <_puts_r+0x6e>
32303d80:	89a3      	ldrh	r3, [r4, #12]
32303d82:	059b      	lsls	r3, r3, #22
32303d84:	d510      	bpl.n	32303da8 <_puts_r+0x90>
32303d86:	4628      	mov	r0, r5
32303d88:	b009      	add	sp, #36	@ 0x24
32303d8a:	bd30      	pop	{r4, r5, pc}
32303d8c:	0590      	lsls	r0, r2, #22
32303d8e:	d511      	bpl.n	32303db4 <_puts_r+0x9c>
32303d90:	0491      	lsls	r1, r2, #18
32303d92:	d5e2      	bpl.n	32303d5a <_puts_r+0x42>
32303d94:	049b      	lsls	r3, r3, #18
32303d96:	d5e6      	bpl.n	32303d66 <_puts_r+0x4e>
32303d98:	f04f 35ff 	mov.w	r5, #4294967295	@ 0xffffffff
32303d9c:	e7f0      	b.n	32303d80 <_puts_r+0x68>
32303d9e:	049b      	lsls	r3, r3, #18
32303da0:	d5e1      	bpl.n	32303d66 <_puts_r+0x4e>
32303da2:	f04f 35ff 	mov.w	r5, #4294967295	@ 0xffffffff
32303da6:	e7ee      	b.n	32303d86 <_puts_r+0x6e>
32303da8:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32303daa:	f000 ff5d 	bl	32304c68 <__retarget_lock_release_recursive>
32303dae:	4628      	mov	r0, r5
32303db0:	b009      	add	sp, #36	@ 0x24
32303db2:	bd30      	pop	{r4, r5, pc}
32303db4:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32303db6:	f000 ff4f 	bl	32304c58 <__retarget_lock_acquire_recursive>
32303dba:	f9b4 200c 	ldrsh.w	r2, [r4, #12]
32303dbe:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32303dc0:	0490      	lsls	r0, r2, #18
32303dc2:	d5ca      	bpl.n	32303d5a <_puts_r+0x42>
32303dc4:	0499      	lsls	r1, r3, #18
32303dc6:	d5ce      	bpl.n	32303d66 <_puts_r+0x4e>
32303dc8:	f04f 35ff 	mov.w	r5, #4294967295	@ 0xffffffff
32303dcc:	e7d6      	b.n	32303d7c <_puts_r+0x64>
32303dce:	4628      	mov	r0, r5
32303dd0:	f7ff fd84 	bl	323038dc <__sinit>
32303dd4:	e7ba      	b.n	32303d4c <_puts_r+0x34>
32303dd6:	bf00      	nop

32303dd8 <puts>:
32303dd8:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
32303ddc:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32303de0:	4601      	mov	r1, r0
32303de2:	6818      	ldr	r0, [r3, #0]
32303de4:	f7ff bf98 	b.w	32303d18 <_puts_r>

32303de8 <__sread>:
32303de8:	b510      	push	{r4, lr}
32303dea:	460c      	mov	r4, r1
32303dec:	f9b1 100e 	ldrsh.w	r1, [r1, #14]
32303df0:	f000 fef2 	bl	32304bd8 <_read_r>
32303df4:	2800      	cmp	r0, #0
32303df6:	db03      	blt.n	32303e00 <__sread+0x18>
32303df8:	6d23      	ldr	r3, [r4, #80]	@ 0x50
32303dfa:	4403      	add	r3, r0
32303dfc:	6523      	str	r3, [r4, #80]	@ 0x50
32303dfe:	bd10      	pop	{r4, pc}
32303e00:	89a3      	ldrh	r3, [r4, #12]
32303e02:	f423 5380 	bic.w	r3, r3, #4096	@ 0x1000
32303e06:	81a3      	strh	r3, [r4, #12]
32303e08:	bd10      	pop	{r4, pc}
32303e0a:	bf00      	nop

32303e0c <__seofread>:
32303e0c:	2000      	movs	r0, #0
32303e0e:	4770      	bx	lr

32303e10 <__swrite>:
32303e10:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
32303e14:	460c      	mov	r4, r1
32303e16:	f9b1 100c 	ldrsh.w	r1, [r1, #12]
32303e1a:	461f      	mov	r7, r3
32303e1c:	4605      	mov	r5, r0
32303e1e:	4616      	mov	r6, r2
32303e20:	05cb      	lsls	r3, r1, #23
32303e22:	d40b      	bmi.n	32303e3c <__swrite+0x2c>
32303e24:	f421 5180 	bic.w	r1, r1, #4096	@ 0x1000
32303e28:	463b      	mov	r3, r7
32303e2a:	81a1      	strh	r1, [r4, #12]
32303e2c:	4632      	mov	r2, r6
32303e2e:	f9b4 100e 	ldrsh.w	r1, [r4, #14]
32303e32:	4628      	mov	r0, r5
32303e34:	e8bd 41f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, lr}
32303e38:	f000 bee6 	b.w	32304c08 <_write_r>
32303e3c:	f9b4 100e 	ldrsh.w	r1, [r4, #14]
32303e40:	2302      	movs	r3, #2
32303e42:	2200      	movs	r2, #0
32303e44:	f000 feb0 	bl	32304ba8 <_lseek_r>
32303e48:	f9b4 100c 	ldrsh.w	r1, [r4, #12]
32303e4c:	e7ea      	b.n	32303e24 <__swrite+0x14>
32303e4e:	bf00      	nop

32303e50 <__sseek>:
32303e50:	b510      	push	{r4, lr}
32303e52:	460c      	mov	r4, r1
32303e54:	f9b1 100e 	ldrsh.w	r1, [r1, #14]
32303e58:	f000 fea6 	bl	32304ba8 <_lseek_r>
32303e5c:	1c42      	adds	r2, r0, #1
32303e5e:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32303e62:	d004      	beq.n	32303e6e <__sseek+0x1e>
32303e64:	f443 5380 	orr.w	r3, r3, #4096	@ 0x1000
32303e68:	6520      	str	r0, [r4, #80]	@ 0x50
32303e6a:	81a3      	strh	r3, [r4, #12]
32303e6c:	bd10      	pop	{r4, pc}
32303e6e:	f423 5380 	bic.w	r3, r3, #4096	@ 0x1000
32303e72:	81a3      	strh	r3, [r4, #12]
32303e74:	bd10      	pop	{r4, pc}
32303e76:	bf00      	nop

32303e78 <__sclose>:
32303e78:	f9b1 100e 	ldrsh.w	r1, [r1, #14]
32303e7c:	f000 be48 	b.w	32304b10 <_close_r>

32303e80 <__swsetup_r>:
32303e80:	b538      	push	{r3, r4, r5, lr}
32303e82:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
32303e86:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32303e8a:	4605      	mov	r5, r0
32303e8c:	460c      	mov	r4, r1
32303e8e:	6818      	ldr	r0, [r3, #0]
32303e90:	b110      	cbz	r0, 32303e98 <__swsetup_r+0x18>
32303e92:	6b42      	ldr	r2, [r0, #52]	@ 0x34
32303e94:	2a00      	cmp	r2, #0
32303e96:	d058      	beq.n	32303f4a <__swsetup_r+0xca>
32303e98:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32303e9c:	0719      	lsls	r1, r3, #28
32303e9e:	d50b      	bpl.n	32303eb8 <__swsetup_r+0x38>
32303ea0:	6922      	ldr	r2, [r4, #16]
32303ea2:	b19a      	cbz	r2, 32303ecc <__swsetup_r+0x4c>
32303ea4:	f013 0201 	ands.w	r2, r3, #1
32303ea8:	d01b      	beq.n	32303ee2 <__swsetup_r+0x62>
32303eaa:	6963      	ldr	r3, [r4, #20]
32303eac:	2200      	movs	r2, #0
32303eae:	60a2      	str	r2, [r4, #8]
32303eb0:	425b      	negs	r3, r3
32303eb2:	61a3      	str	r3, [r4, #24]
32303eb4:	2000      	movs	r0, #0
32303eb6:	bd38      	pop	{r3, r4, r5, pc}
32303eb8:	06da      	lsls	r2, r3, #27
32303eba:	d54e      	bpl.n	32303f5a <__swsetup_r+0xda>
32303ebc:	0758      	lsls	r0, r3, #29
32303ebe:	d415      	bmi.n	32303eec <__swsetup_r+0x6c>
32303ec0:	6922      	ldr	r2, [r4, #16]
32303ec2:	f043 0308 	orr.w	r3, r3, #8
32303ec6:	81a3      	strh	r3, [r4, #12]
32303ec8:	2a00      	cmp	r2, #0
32303eca:	d1eb      	bne.n	32303ea4 <__swsetup_r+0x24>
32303ecc:	0599      	lsls	r1, r3, #22
32303ece:	d525      	bpl.n	32303f1c <__swsetup_r+0x9c>
32303ed0:	0618      	lsls	r0, r3, #24
32303ed2:	d423      	bmi.n	32303f1c <__swsetup_r+0x9c>
32303ed4:	07d9      	lsls	r1, r3, #31
32303ed6:	d51d      	bpl.n	32303f14 <__swsetup_r+0x94>
32303ed8:	6963      	ldr	r3, [r4, #20]
32303eda:	60a2      	str	r2, [r4, #8]
32303edc:	425b      	negs	r3, r3
32303ede:	61a3      	str	r3, [r4, #24]
32303ee0:	e7e8      	b.n	32303eb4 <__swsetup_r+0x34>
32303ee2:	079b      	lsls	r3, r3, #30
32303ee4:	d418      	bmi.n	32303f18 <__swsetup_r+0x98>
32303ee6:	6963      	ldr	r3, [r4, #20]
32303ee8:	60a3      	str	r3, [r4, #8]
32303eea:	e7e3      	b.n	32303eb4 <__swsetup_r+0x34>
32303eec:	6b21      	ldr	r1, [r4, #48]	@ 0x30
32303eee:	b151      	cbz	r1, 32303f06 <__swsetup_r+0x86>
32303ef0:	f104 0240 	add.w	r2, r4, #64	@ 0x40
32303ef4:	4291      	cmp	r1, r2
32303ef6:	d004      	beq.n	32303f02 <__swsetup_r+0x82>
32303ef8:	4628      	mov	r0, r5
32303efa:	f001 fc75 	bl	323057e8 <_free_r>
32303efe:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32303f02:	2200      	movs	r2, #0
32303f04:	6322      	str	r2, [r4, #48]	@ 0x30
32303f06:	6922      	ldr	r2, [r4, #16]
32303f08:	2100      	movs	r1, #0
32303f0a:	f023 0324 	bic.w	r3, r3, #36	@ 0x24
32303f0e:	e9c4 2100 	strd	r2, r1, [r4]
32303f12:	e7d6      	b.n	32303ec2 <__swsetup_r+0x42>
32303f14:	079d      	lsls	r5, r3, #30
32303f16:	d51d      	bpl.n	32303f54 <__swsetup_r+0xd4>
32303f18:	60a2      	str	r2, [r4, #8]
32303f1a:	e7cb      	b.n	32303eb4 <__swsetup_r+0x34>
32303f1c:	4621      	mov	r1, r4
32303f1e:	4628      	mov	r0, r5
32303f20:	f005 f9a0 	bl	32309264 <__smakebuf_r>
32303f24:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
32303f28:	6922      	ldr	r2, [r4, #16]
32303f2a:	f013 0101 	ands.w	r1, r3, #1
32303f2e:	d00f      	beq.n	32303f50 <__swsetup_r+0xd0>
32303f30:	6961      	ldr	r1, [r4, #20]
32303f32:	2000      	movs	r0, #0
32303f34:	60a0      	str	r0, [r4, #8]
32303f36:	4249      	negs	r1, r1
32303f38:	61a1      	str	r1, [r4, #24]
32303f3a:	2a00      	cmp	r2, #0
32303f3c:	d1ba      	bne.n	32303eb4 <__swsetup_r+0x34>
32303f3e:	061a      	lsls	r2, r3, #24
32303f40:	d5b8      	bpl.n	32303eb4 <__swsetup_r+0x34>
32303f42:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32303f46:	81a3      	strh	r3, [r4, #12]
32303f48:	e00c      	b.n	32303f64 <__swsetup_r+0xe4>
32303f4a:	f7ff fcc7 	bl	323038dc <__sinit>
32303f4e:	e7a3      	b.n	32303e98 <__swsetup_r+0x18>
32303f50:	0798      	lsls	r0, r3, #30
32303f52:	d400      	bmi.n	32303f56 <__swsetup_r+0xd6>
32303f54:	6961      	ldr	r1, [r4, #20]
32303f56:	60a1      	str	r1, [r4, #8]
32303f58:	e7ef      	b.n	32303f3a <__swsetup_r+0xba>
32303f5a:	2209      	movs	r2, #9
32303f5c:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32303f60:	602a      	str	r2, [r5, #0]
32303f62:	81a3      	strh	r3, [r4, #12]
32303f64:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32303f68:	bd38      	pop	{r3, r4, r5, pc}
32303f6a:	bf00      	nop

32303f6c <memmove>:
32303f6c:	4288      	cmp	r0, r1
32303f6e:	d90d      	bls.n	32303f8c <memmove+0x20>
32303f70:	188b      	adds	r3, r1, r2
32303f72:	4283      	cmp	r3, r0
32303f74:	d90a      	bls.n	32303f8c <memmove+0x20>
32303f76:	eb00 0c02 	add.w	ip, r0, r2
32303f7a:	b35a      	cbz	r2, 32303fd4 <memmove+0x68>
32303f7c:	4662      	mov	r2, ip
32303f7e:	f813 cd01 	ldrb.w	ip, [r3, #-1]!
32303f82:	f802 cd01 	strb.w	ip, [r2, #-1]!
32303f86:	4299      	cmp	r1, r3
32303f88:	d1f9      	bne.n	32303f7e <memmove+0x12>
32303f8a:	4770      	bx	lr
32303f8c:	2a0f      	cmp	r2, #15
32303f8e:	d80d      	bhi.n	32303fac <memmove+0x40>
32303f90:	f102 3cff 	add.w	ip, r2, #4294967295	@ 0xffffffff
32303f94:	b1f2      	cbz	r2, 32303fd4 <memmove+0x68>
32303f96:	f10c 0c01 	add.w	ip, ip, #1
32303f9a:	1e43      	subs	r3, r0, #1
32303f9c:	448c      	add	ip, r1
32303f9e:	f811 2b01 	ldrb.w	r2, [r1], #1
32303fa2:	f803 2f01 	strb.w	r2, [r3, #1]!
32303fa6:	4561      	cmp	r1, ip
32303fa8:	d1f9      	bne.n	32303f9e <memmove+0x32>
32303faa:	4770      	bx	lr
32303fac:	ea40 0301 	orr.w	r3, r0, r1
32303fb0:	b5f0      	push	{r4, r5, r6, r7, lr}
32303fb2:	460c      	mov	r4, r1
32303fb4:	079b      	lsls	r3, r3, #30
32303fb6:	d00e      	beq.n	32303fd6 <memmove+0x6a>
32303fb8:	f102 3cff 	add.w	ip, r2, #4294967295	@ 0xffffffff
32303fbc:	4603      	mov	r3, r0
32303fbe:	f10c 0c01 	add.w	ip, ip, #1
32303fc2:	3b01      	subs	r3, #1
32303fc4:	448c      	add	ip, r1
32303fc6:	f811 2b01 	ldrb.w	r2, [r1], #1
32303fca:	f803 2f01 	strb.w	r2, [r3, #1]!
32303fce:	4561      	cmp	r1, ip
32303fd0:	d1f9      	bne.n	32303fc6 <memmove+0x5a>
32303fd2:	bdf0      	pop	{r4, r5, r6, r7, pc}
32303fd4:	4770      	bx	lr
32303fd6:	f1a2 0510 	sub.w	r5, r2, #16
32303fda:	f101 0e20 	add.w	lr, r1, #32
32303fde:	f025 050f 	bic.w	r5, r5, #15
32303fe2:	f101 0310 	add.w	r3, r1, #16
32303fe6:	44ae      	add	lr, r5
32303fe8:	f100 0c10 	add.w	ip, r0, #16
32303fec:	f853 6c10 	ldr.w	r6, [r3, #-16]
32303ff0:	3310      	adds	r3, #16
32303ff2:	f84c 6c10 	str.w	r6, [ip, #-16]
32303ff6:	f10c 0c10 	add.w	ip, ip, #16
32303ffa:	4573      	cmp	r3, lr
32303ffc:	f853 6c1c 	ldr.w	r6, [r3, #-28]
32304000:	f84c 6c1c 	str.w	r6, [ip, #-28]
32304004:	f853 6c18 	ldr.w	r6, [r3, #-24]
32304008:	f84c 6c18 	str.w	r6, [ip, #-24]
3230400c:	f853 6c14 	ldr.w	r6, [r3, #-20]
32304010:	f84c 6c14 	str.w	r6, [ip, #-20]
32304014:	d1ea      	bne.n	32303fec <memmove+0x80>
32304016:	eb01 0c05 	add.w	ip, r1, r5
3230401a:	4405      	add	r5, r0
3230401c:	f105 0310 	add.w	r3, r5, #16
32304020:	f10c 0110 	add.w	r1, ip, #16
32304024:	f002 050f 	and.w	r5, r2, #15
32304028:	f012 0f0c 	tst.w	r2, #12
3230402c:	460e      	mov	r6, r1
3230402e:	bf08      	it	eq
32304030:	462a      	moveq	r2, r5
32304032:	d013      	beq.n	3230405c <memmove+0xf0>
32304034:	3d04      	subs	r5, #4
32304036:	eba0 0e04 	sub.w	lr, r0, r4
3230403a:	f025 0403 	bic.w	r4, r5, #3
3230403e:	44a4      	add	ip, r4
32304040:	f10c 0c14 	add.w	ip, ip, #20
32304044:	eb01 050e 	add.w	r5, r1, lr
32304048:	680f      	ldr	r7, [r1, #0]
3230404a:	3104      	adds	r1, #4
3230404c:	4561      	cmp	r1, ip
3230404e:	602f      	str	r7, [r5, #0]
32304050:	d1f8      	bne.n	32304044 <memmove+0xd8>
32304052:	3404      	adds	r4, #4
32304054:	f002 0203 	and.w	r2, r2, #3
32304058:	19a1      	adds	r1, r4, r6
3230405a:	4423      	add	r3, r4
3230405c:	f102 3cff 	add.w	ip, r2, #4294967295	@ 0xffffffff
32304060:	2a00      	cmp	r2, #0
32304062:	d1ac      	bne.n	32303fbe <memmove+0x52>
32304064:	bdf0      	pop	{r4, r5, r6, r7, pc}
32304066:	bf00      	nop

32304068 <memset>:
32304068:	b530      	push	{r4, r5, lr}
3230406a:	0785      	lsls	r5, r0, #30
3230406c:	d045      	beq.n	323040fa <memset+0x92>
3230406e:	eb00 0e02 	add.w	lr, r0, r2
32304072:	4684      	mov	ip, r0
32304074:	e004      	b.n	32304080 <memset+0x18>
32304076:	f803 1b01 	strb.w	r1, [r3], #1
3230407a:	079c      	lsls	r4, r3, #30
3230407c:	d004      	beq.n	32304088 <memset+0x20>
3230407e:	469c      	mov	ip, r3
32304080:	4663      	mov	r3, ip
32304082:	45f4      	cmp	ip, lr
32304084:	d1f7      	bne.n	32304076 <memset+0xe>
32304086:	bd30      	pop	{r4, r5, pc}
32304088:	3a01      	subs	r2, #1
3230408a:	4402      	add	r2, r0
3230408c:	eba2 020c 	sub.w	r2, r2, ip
32304090:	2a03      	cmp	r2, #3
32304092:	d927      	bls.n	323040e4 <memset+0x7c>
32304094:	b2cc      	uxtb	r4, r1
32304096:	f04f 3501 	mov.w	r5, #16843009	@ 0x1010101
3230409a:	2a0f      	cmp	r2, #15
3230409c:	fb05 f404 	mul.w	r4, r5, r4
323040a0:	eea0 4b90 	vdup.32	q8, r4
323040a4:	d92b      	bls.n	323040fe <memset+0x96>
323040a6:	f1a2 0c10 	sub.w	ip, r2, #16
323040aa:	f103 0510 	add.w	r5, r3, #16
323040ae:	f02c 0c0f 	bic.w	ip, ip, #15
323040b2:	44ac      	add	ip, r5
323040b4:	f943 0a8d 	vst1.32	{d16-d17}, [r3]!
323040b8:	4563      	cmp	r3, ip
323040ba:	d1fb      	bne.n	323040b4 <memset+0x4c>
323040bc:	f002 0e0f 	and.w	lr, r2, #15
323040c0:	f012 0f0c 	tst.w	r2, #12
323040c4:	d017      	beq.n	323040f6 <memset+0x8e>
323040c6:	461a      	mov	r2, r3
323040c8:	eb0e 0503 	add.w	r5, lr, r3
323040cc:	f842 4b04 	str.w	r4, [r2], #4
323040d0:	eba5 0c02 	sub.w	ip, r5, r2
323040d4:	f1bc 0f03 	cmp.w	ip, #3
323040d8:	d8f8      	bhi.n	323040cc <memset+0x64>
323040da:	f00e 0203 	and.w	r2, lr, #3
323040de:	f02e 0e03 	bic.w	lr, lr, #3
323040e2:	4473      	add	r3, lr
323040e4:	2a00      	cmp	r2, #0
323040e6:	d0ce      	beq.n	32304086 <memset+0x1e>
323040e8:	b2c9      	uxtb	r1, r1
323040ea:	441a      	add	r2, r3
323040ec:	f803 1b01 	strb.w	r1, [r3], #1
323040f0:	429a      	cmp	r2, r3
323040f2:	d1fb      	bne.n	323040ec <memset+0x84>
323040f4:	bd30      	pop	{r4, r5, pc}
323040f6:	4672      	mov	r2, lr
323040f8:	e7f4      	b.n	323040e4 <memset+0x7c>
323040fa:	4603      	mov	r3, r0
323040fc:	e7c8      	b.n	32304090 <memset+0x28>
323040fe:	4696      	mov	lr, r2
32304100:	e7e1      	b.n	323040c6 <memset+0x5e>
32304102:	bf00      	nop

32304104 <strncpy>:
32304104:	ea40 0301 	orr.w	r3, r0, r1
32304108:	2a03      	cmp	r2, #3
3230410a:	f003 0303 	and.w	r3, r3, #3
3230410e:	4684      	mov	ip, r0
32304110:	fab3 f383 	clz	r3, r3
32304114:	b510      	push	{r4, lr}
32304116:	ea4f 1353 	mov.w	r3, r3, lsr #5
3230411a:	bf98      	it	ls
3230411c:	2300      	movls	r3, #0
3230411e:	b9b3      	cbnz	r3, 3230414e <strncpy+0x4a>
32304120:	f101 3eff 	add.w	lr, r1, #4294967295	@ 0xffffffff
32304124:	e007      	b.n	32304136 <strncpy+0x32>
32304126:	f81e 1f01 	ldrb.w	r1, [lr, #1]!
3230412a:	1e54      	subs	r4, r2, #1
3230412c:	f803 1b01 	strb.w	r1, [r3], #1
32304130:	b129      	cbz	r1, 3230413e <strncpy+0x3a>
32304132:	469c      	mov	ip, r3
32304134:	4622      	mov	r2, r4
32304136:	4663      	mov	r3, ip
32304138:	2a00      	cmp	r2, #0
3230413a:	d1f4      	bne.n	32304126 <strncpy+0x22>
3230413c:	bd10      	pop	{r4, pc}
3230413e:	4494      	add	ip, r2
32304140:	2c00      	cmp	r4, #0
32304142:	d0fb      	beq.n	3230413c <strncpy+0x38>
32304144:	f803 1b01 	strb.w	r1, [r3], #1
32304148:	4563      	cmp	r3, ip
3230414a:	d1fb      	bne.n	32304144 <strncpy+0x40>
3230414c:	bd10      	pop	{r4, pc}
3230414e:	468e      	mov	lr, r1
32304150:	f8de 4000 	ldr.w	r4, [lr]
32304154:	4671      	mov	r1, lr
32304156:	f10e 0e04 	add.w	lr, lr, #4
3230415a:	f1a4 3301 	sub.w	r3, r4, #16843009	@ 0x1010101
3230415e:	ea23 0304 	bic.w	r3, r3, r4
32304162:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
32304166:	d1db      	bne.n	32304120 <strncpy+0x1c>
32304168:	3a04      	subs	r2, #4
3230416a:	f84c 4b04 	str.w	r4, [ip], #4
3230416e:	2a03      	cmp	r2, #3
32304170:	d8ee      	bhi.n	32304150 <strncpy+0x4c>
32304172:	4671      	mov	r1, lr
32304174:	e7d4      	b.n	32304120 <strncpy+0x1c>
32304176:	bf00      	nop

32304178 <currentlocale>:
32304178:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
3230417a:	f24c 0028 	movw	r0, #49192	@ 0xc028
3230417e:	f2c3 2030 	movt	r0, #12848	@ 0x3230
32304182:	4d16      	ldr	r5, [pc, #88]	@ (323041dc <currentlocale+0x64>)
32304184:	4916      	ldr	r1, [pc, #88]	@ (323041e0 <currentlocale+0x68>)
32304186:	f105 06a0 	add.w	r6, r5, #160	@ 0xa0
3230418a:	462c      	mov	r4, r5
3230418c:	f000 fee8 	bl	32304f60 <strcpy>
32304190:	4621      	mov	r1, r4
32304192:	4813      	ldr	r0, [pc, #76]	@ (323041e0 <currentlocale+0x68>)
32304194:	3420      	adds	r4, #32
32304196:	f000 fd73 	bl	32304c80 <strcmp>
3230419a:	b930      	cbnz	r0, 323041aa <currentlocale+0x32>
3230419c:	42b4      	cmp	r4, r6
3230419e:	d1f7      	bne.n	32304190 <currentlocale+0x18>
323041a0:	f24c 0028 	movw	r0, #49192	@ 0xc028
323041a4:	f2c3 2030 	movt	r0, #12848	@ 0x3230
323041a8:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
323041aa:	f64b 1700 	movw	r7, #47360	@ 0xb900
323041ae:	f2c3 2730 	movt	r7, #12848	@ 0x3230
323041b2:	f24c 0428 	movw	r4, #49192	@ 0xc028
323041b6:	f2c3 2430 	movt	r4, #12848	@ 0x3230
323041ba:	4639      	mov	r1, r7
323041bc:	4620      	mov	r0, r4
323041be:	f005 f90f 	bl	323093e0 <strcat>
323041c2:	4629      	mov	r1, r5
323041c4:	4620      	mov	r0, r4
323041c6:	3520      	adds	r5, #32
323041c8:	f005 f90a 	bl	323093e0 <strcat>
323041cc:	42b5      	cmp	r5, r6
323041ce:	d1f4      	bne.n	323041ba <currentlocale+0x42>
323041d0:	f24c 0028 	movw	r0, #49192	@ 0xc028
323041d4:	f2c3 2030 	movt	r0, #12848	@ 0x3230
323041d8:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
323041da:	bf00      	nop
323041dc:	3230c150 	.word	0x3230c150
323041e0:	3230c130 	.word	0x3230c130

323041e4 <__loadlocale>:
323041e4:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
323041e8:	eb00 1741 	add.w	r7, r0, r1, lsl #5
323041ec:	460e      	mov	r6, r1
323041ee:	b08f      	sub	sp, #60	@ 0x3c
323041f0:	4605      	mov	r5, r0
323041f2:	4639      	mov	r1, r7
323041f4:	4610      	mov	r0, r2
323041f6:	4614      	mov	r4, r2
323041f8:	f000 fd42 	bl	32304c80 <strcmp>
323041fc:	b918      	cbnz	r0, 32304206 <__loadlocale+0x22>
323041fe:	4638      	mov	r0, r7
32304200:	b00f      	add	sp, #60	@ 0x3c
32304202:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32304206:	f64b 1104 	movw	r1, #47364	@ 0xb904
3230420a:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230420e:	4620      	mov	r0, r4
32304210:	f000 fd36 	bl	32304c80 <strcmp>
32304214:	2800      	cmp	r0, #0
32304216:	f000 8089 	beq.w	3230432c <__loadlocale+0x148>
3230421a:	f64b 110c 	movw	r1, #47372	@ 0xb90c
3230421e:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304222:	4620      	mov	r0, r4
32304224:	f000 fd2c 	bl	32304c80 <strcmp>
32304228:	2800      	cmp	r0, #0
3230422a:	d075      	beq.n	32304318 <__loadlocale+0x134>
3230422c:	7823      	ldrb	r3, [r4, #0]
3230422e:	2b43      	cmp	r3, #67	@ 0x43
32304230:	d067      	beq.n	32304302 <__loadlocale+0x11e>
32304232:	3b61      	subs	r3, #97	@ 0x61
32304234:	2b19      	cmp	r3, #25
32304236:	d86a      	bhi.n	3230430e <__loadlocale+0x12a>
32304238:	7863      	ldrb	r3, [r4, #1]
3230423a:	3b61      	subs	r3, #97	@ 0x61
3230423c:	2b19      	cmp	r3, #25
3230423e:	d866      	bhi.n	3230430e <__loadlocale+0x12a>
32304240:	78a3      	ldrb	r3, [r4, #2]
32304242:	f104 0902 	add.w	r9, r4, #2
32304246:	f1a3 0261 	sub.w	r2, r3, #97	@ 0x61
3230424a:	2a19      	cmp	r2, #25
3230424c:	d802      	bhi.n	32304254 <__loadlocale+0x70>
3230424e:	78e3      	ldrb	r3, [r4, #3]
32304250:	f104 0903 	add.w	r9, r4, #3
32304254:	2b5f      	cmp	r3, #95	@ 0x5f
32304256:	f000 8085 	beq.w	32304364 <__loadlocale+0x180>
3230425a:	2b2e      	cmp	r3, #46	@ 0x2e
3230425c:	d06e      	beq.n	3230433c <__loadlocale+0x158>
3230425e:	f013 0fbf 	tst.w	r3, #191	@ 0xbf
32304262:	d154      	bne.n	3230430e <__loadlocale+0x12a>
32304264:	f10d 0818 	add.w	r8, sp, #24
32304268:	f64b 1118 	movw	r1, #47384	@ 0xb918
3230426c:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304270:	4640      	mov	r0, r8
32304272:	f000 fe75 	bl	32304f60 <strcpy>
32304276:	f899 3000 	ldrb.w	r3, [r9]
3230427a:	2b40      	cmp	r3, #64	@ 0x40
3230427c:	f000 827a 	beq.w	32304774 <__loadlocale+0x590>
32304280:	f04f 0900 	mov.w	r9, #0
32304284:	f8cd 9004 	str.w	r9, [sp, #4]
32304288:	46cb      	mov	fp, r9
3230428a:	f89d 3018 	ldrb.w	r3, [sp, #24]
3230428e:	3b41      	subs	r3, #65	@ 0x41
32304290:	2b34      	cmp	r3, #52	@ 0x34
32304292:	d83c      	bhi.n	3230430e <__loadlocale+0x12a>
32304294:	e8df f013 	tbh	[pc, r3, lsl #1]
32304298:	003b01cd 	.word	0x003b01cd
3230429c:	003b0198 	.word	0x003b0198
323042a0:	003b016c 	.word	0x003b016c
323042a4:	003b0149 	.word	0x003b0149
323042a8:	012e01df 	.word	0x012e01df
323042ac:	003b0101 	.word	0x003b0101
323042b0:	003b003b 	.word	0x003b003b
323042b4:	00ef003b 	.word	0x00ef003b
323042b8:	003b003b 	.word	0x003b003b
323042bc:	00a900d4 	.word	0x00a900d4
323042c0:	003b0075 	.word	0x003b0075
323042c4:	003b003b 	.word	0x003b003b
323042c8:	003b003b 	.word	0x003b003b
323042cc:	003b003b 	.word	0x003b003b
323042d0:	003b003b 	.word	0x003b003b
323042d4:	003b003b 	.word	0x003b003b
323042d8:	003b01cd 	.word	0x003b01cd
323042dc:	003b0198 	.word	0x003b0198
323042e0:	003b016c 	.word	0x003b016c
323042e4:	003b0149 	.word	0x003b0149
323042e8:	012e01df 	.word	0x012e01df
323042ec:	003b0101 	.word	0x003b0101
323042f0:	003b003b 	.word	0x003b003b
323042f4:	00ef003b 	.word	0x00ef003b
323042f8:	003b003b 	.word	0x003b003b
323042fc:	00a900d4 	.word	0x00a900d4
32304300:	0075      	.short	0x0075
32304302:	7863      	ldrb	r3, [r4, #1]
32304304:	f104 0902 	add.w	r9, r4, #2
32304308:	3b2d      	subs	r3, #45	@ 0x2d
3230430a:	2b01      	cmp	r3, #1
3230430c:	d918      	bls.n	32304340 <__loadlocale+0x15c>
3230430e:	2700      	movs	r7, #0
32304310:	4638      	mov	r0, r7
32304312:	b00f      	add	sp, #60	@ 0x3c
32304314:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32304318:	f10d 0818 	add.w	r8, sp, #24
3230431c:	f64b 1110 	movw	r1, #47376	@ 0xb910
32304320:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304324:	4640      	mov	r0, r8
32304326:	f000 fe1b 	bl	32304f60 <strcpy>
3230432a:	e7a9      	b.n	32304280 <__loadlocale+0x9c>
3230432c:	4620      	mov	r0, r4
3230432e:	f64b 110c 	movw	r1, #47372	@ 0xb90c
32304332:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304336:	f000 fe13 	bl	32304f60 <strcpy>
3230433a:	e76e      	b.n	3230421a <__loadlocale+0x36>
3230433c:	f109 0901 	add.w	r9, r9, #1
32304340:	f10d 0818 	add.w	r8, sp, #24
32304344:	4649      	mov	r1, r9
32304346:	4640      	mov	r0, r8
32304348:	f000 fe0a 	bl	32304f60 <strcpy>
3230434c:	2140      	movs	r1, #64	@ 0x40
3230434e:	4640      	mov	r0, r8
32304350:	f005 f866 	bl	32309420 <strchr>
32304354:	b108      	cbz	r0, 3230435a <__loadlocale+0x176>
32304356:	2300      	movs	r3, #0
32304358:	7003      	strb	r3, [r0, #0]
3230435a:	4640      	mov	r0, r8
3230435c:	f001 f970 	bl	32305640 <strlen>
32304360:	4481      	add	r9, r0
32304362:	e788      	b.n	32304276 <__loadlocale+0x92>
32304364:	f899 3001 	ldrb.w	r3, [r9, #1]
32304368:	3b41      	subs	r3, #65	@ 0x41
3230436a:	2b19      	cmp	r3, #25
3230436c:	d8cf      	bhi.n	3230430e <__loadlocale+0x12a>
3230436e:	f899 3002 	ldrb.w	r3, [r9, #2]
32304372:	3b41      	subs	r3, #65	@ 0x41
32304374:	2b19      	cmp	r3, #25
32304376:	d8ca      	bhi.n	3230430e <__loadlocale+0x12a>
32304378:	f899 3003 	ldrb.w	r3, [r9, #3]
3230437c:	f109 0903 	add.w	r9, r9, #3
32304380:	e76b      	b.n	3230425a <__loadlocale+0x76>
32304382:	f64b 1144 	movw	r1, #47428	@ 0xb944
32304386:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230438a:	4640      	mov	r0, r8
3230438c:	f005 f802 	bl	32309394 <strcasecmp>
32304390:	b140      	cbz	r0, 323043a4 <__loadlocale+0x1c0>
32304392:	f64b 114c 	movw	r1, #47436	@ 0xb94c
32304396:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230439a:	4640      	mov	r0, r8
3230439c:	f004 fffa 	bl	32309394 <strcasecmp>
323043a0:	2800      	cmp	r0, #0
323043a2:	d1b4      	bne.n	3230430e <__loadlocale+0x12a>
323043a4:	4640      	mov	r0, r8
323043a6:	f64b 1144 	movw	r1, #47428	@ 0xb944
323043aa:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323043ae:	f246 0ab1 	movw	sl, #24753	@ 0x60b1
323043b2:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
323043b6:	f000 fdd3 	bl	32304f60 <strcpy>
323043ba:	f646 33ad 	movw	r3, #27565	@ 0x6bad
323043be:	f2c3 2330 	movt	r3, #12848	@ 0x3230
323043c2:	2206      	movs	r2, #6
323043c4:	2e02      	cmp	r6, #2
323043c6:	f000 81a7 	beq.w	32304718 <__loadlocale+0x534>
323043ca:	2e06      	cmp	r6, #6
323043cc:	d104      	bne.n	323043d8 <__loadlocale+0x1f4>
323043ce:	4641      	mov	r1, r8
323043d0:	f505 70a5 	add.w	r0, r5, #330	@ 0x14a
323043d4:	f000 fdc4 	bl	32304f60 <strcpy>
323043d8:	4621      	mov	r1, r4
323043da:	4638      	mov	r0, r7
323043dc:	f000 fdc0 	bl	32304f60 <strcpy>
323043e0:	4607      	mov	r7, r0
323043e2:	4638      	mov	r0, r7
323043e4:	b00f      	add	sp, #60	@ 0x3c
323043e6:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
323043ea:	f64b 11d4 	movw	r1, #47572	@ 0xb9d4
323043ee:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323043f2:	2203      	movs	r2, #3
323043f4:	4640      	mov	r0, r8
323043f6:	f005 f8a1 	bl	3230953c <strncasecmp>
323043fa:	2800      	cmp	r0, #0
323043fc:	d187      	bne.n	3230430e <__loadlocale+0x12a>
323043fe:	f89d 301b 	ldrb.w	r3, [sp, #27]
32304402:	f10d 001b 	add.w	r0, sp, #27
32304406:	2b2d      	cmp	r3, #45	@ 0x2d
32304408:	d100      	bne.n	3230440c <__loadlocale+0x228>
3230440a:	a807      	add	r0, sp, #28
3230440c:	f64b 11d8 	movw	r1, #47576	@ 0xb9d8
32304410:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304414:	f000 fc34 	bl	32304c80 <strcmp>
32304418:	2800      	cmp	r0, #0
3230441a:	f47f af78 	bne.w	3230430e <__loadlocale+0x12a>
3230441e:	f64b 11dc 	movw	r1, #47580	@ 0xb9dc
32304422:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304426:	4640      	mov	r0, r8
32304428:	f000 fd9a 	bl	32304f60 <strcpy>
3230442c:	f246 0a8d 	movw	sl, #24717	@ 0x608d
32304430:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
32304434:	f646 3391 	movw	r3, #27537	@ 0x6b91
32304438:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230443c:	2201      	movs	r2, #1
3230443e:	e7c1      	b.n	323043c4 <__loadlocale+0x1e0>
32304440:	f64b 1168 	movw	r1, #47464	@ 0xb968
32304444:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304448:	4640      	mov	r0, r8
3230444a:	f004 ffa3 	bl	32309394 <strcasecmp>
3230444e:	2800      	cmp	r0, #0
32304450:	f47f af5d 	bne.w	3230430e <__loadlocale+0x12a>
32304454:	f64b 1168 	movw	r1, #47464	@ 0xb968
32304458:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230445c:	4640      	mov	r0, r8
3230445e:	f000 fd7f 	bl	32304f60 <strcpy>
32304462:	f246 2aa9 	movw	sl, #25257	@ 0x62a9
32304466:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
3230446a:	f646 4351 	movw	r3, #27729	@ 0x6c51
3230446e:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32304472:	2202      	movs	r2, #2
32304474:	e7a6      	b.n	323043c4 <__loadlocale+0x1e0>
32304476:	f64b 11c4 	movw	r1, #47556	@ 0xb9c4
3230447a:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230447e:	4640      	mov	r0, r8
32304480:	f004 ff88 	bl	32309394 <strcasecmp>
32304484:	2800      	cmp	r0, #0
32304486:	f47f af42 	bne.w	3230430e <__loadlocale+0x12a>
3230448a:	4640      	mov	r0, r8
3230448c:	f64b 11cc 	movw	r1, #47564	@ 0xb9cc
32304490:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304494:	f000 fd64 	bl	32304f60 <strcpy>
32304498:	e7c8      	b.n	3230442c <__loadlocale+0x248>
3230449a:	f64b 118c 	movw	r1, #47500	@ 0xb98c
3230449e:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323044a2:	2204      	movs	r2, #4
323044a4:	4640      	mov	r0, r8
323044a6:	f005 f849 	bl	3230953c <strncasecmp>
323044aa:	2800      	cmp	r0, #0
323044ac:	f47f af2f 	bne.w	3230430e <__loadlocale+0x12a>
323044b0:	f89d 301c 	ldrb.w	r3, [sp, #28]
323044b4:	aa07      	add	r2, sp, #28
323044b6:	2b2d      	cmp	r3, #45	@ 0x2d
323044b8:	d103      	bne.n	323044c2 <__loadlocale+0x2de>
323044ba:	f89d 301d 	ldrb.w	r3, [sp, #29]
323044be:	f10d 021d 	add.w	r2, sp, #29
323044c2:	f003 03df 	and.w	r3, r3, #223	@ 0xdf
323044c6:	2b52      	cmp	r3, #82	@ 0x52
323044c8:	f000 8170 	beq.w	323047ac <__loadlocale+0x5c8>
323044cc:	7813      	ldrb	r3, [r2, #0]
323044ce:	2b74      	cmp	r3, #116	@ 0x74
323044d0:	f000 8178 	beq.w	323047c4 <__loadlocale+0x5e0>
323044d4:	f200 8172 	bhi.w	323047bc <__loadlocale+0x5d8>
323044d8:	2b54      	cmp	r3, #84	@ 0x54
323044da:	f000 8173 	beq.w	323047c4 <__loadlocale+0x5e0>
323044de:	2b55      	cmp	r3, #85	@ 0x55
323044e0:	f47f af15 	bne.w	3230430e <__loadlocale+0x12a>
323044e4:	4640      	mov	r0, r8
323044e6:	f64b 119c 	movw	r1, #47516	@ 0xb99c
323044ea:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323044ee:	f000 fd37 	bl	32304f60 <strcpy>
323044f2:	e79b      	b.n	3230442c <__loadlocale+0x248>
323044f4:	f64b 1154 	movw	r1, #47444	@ 0xb954
323044f8:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323044fc:	4640      	mov	r0, r8
323044fe:	f004 ff49 	bl	32309394 <strcasecmp>
32304502:	2800      	cmp	r0, #0
32304504:	f47f af03 	bne.w	3230430e <__loadlocale+0x12a>
32304508:	4640      	mov	r0, r8
3230450a:	f64b 1154 	movw	r1, #47444	@ 0xb954
3230450e:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304512:	f246 3ae1 	movw	sl, #25569	@ 0x63e1
32304516:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
3230451a:	f000 fd21 	bl	32304f60 <strcpy>
3230451e:	f646 5311 	movw	r3, #27921	@ 0x6d11
32304522:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32304526:	2208      	movs	r2, #8
32304528:	e74c      	b.n	323043c4 <__loadlocale+0x1e0>
3230452a:	f64b 11ac 	movw	r1, #47532	@ 0xb9ac
3230452e:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304532:	2208      	movs	r2, #8
32304534:	4640      	mov	r0, r8
32304536:	f005 f801 	bl	3230953c <strncasecmp>
3230453a:	2800      	cmp	r0, #0
3230453c:	f47f aee7 	bne.w	3230430e <__loadlocale+0x12a>
32304540:	f89d 3020 	ldrb.w	r3, [sp, #32]
32304544:	a808      	add	r0, sp, #32
32304546:	2b2d      	cmp	r3, #45	@ 0x2d
32304548:	d101      	bne.n	3230454e <__loadlocale+0x36a>
3230454a:	f10d 0021 	add.w	r0, sp, #33	@ 0x21
3230454e:	f64b 11b8 	movw	r1, #47544	@ 0xb9b8
32304552:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304556:	f004 ff1d 	bl	32309394 <strcasecmp>
3230455a:	2800      	cmp	r0, #0
3230455c:	f47f aed7 	bne.w	3230430e <__loadlocale+0x12a>
32304560:	4640      	mov	r0, r8
32304562:	f64b 11bc 	movw	r1, #47548	@ 0xb9bc
32304566:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230456a:	f000 fcf9 	bl	32304f60 <strcpy>
3230456e:	e75d      	b.n	3230442c <__loadlocale+0x248>
32304570:	f64b 1158 	movw	r1, #47448	@ 0xb958
32304574:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304578:	2203      	movs	r2, #3
3230457a:	4640      	mov	r0, r8
3230457c:	f004 ffde 	bl	3230953c <strncasecmp>
32304580:	2800      	cmp	r0, #0
32304582:	f47f aec4 	bne.w	3230430e <__loadlocale+0x12a>
32304586:	f89d 301b 	ldrb.w	r3, [sp, #27]
3230458a:	f10d 001b 	add.w	r0, sp, #27
3230458e:	2b2d      	cmp	r3, #45	@ 0x2d
32304590:	d100      	bne.n	32304594 <__loadlocale+0x3b0>
32304592:	a807      	add	r0, sp, #28
32304594:	f64b 115c 	movw	r1, #47452	@ 0xb95c
32304598:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230459c:	f004 fefa 	bl	32309394 <strcasecmp>
323045a0:	2800      	cmp	r0, #0
323045a2:	f47f aeb4 	bne.w	3230430e <__loadlocale+0x12a>
323045a6:	4640      	mov	r0, r8
323045a8:	f64b 1160 	movw	r1, #47456	@ 0xb960
323045ac:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323045b0:	f246 3a29 	movw	sl, #25385	@ 0x6329
323045b4:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
323045b8:	f000 fcd2 	bl	32304f60 <strcpy>
323045bc:	f646 43a5 	movw	r3, #27813	@ 0x6ca5
323045c0:	f2c3 2330 	movt	r3, #12848	@ 0x3230
323045c4:	2203      	movs	r2, #3
323045c6:	e6fd      	b.n	323043c4 <__loadlocale+0x1e0>
323045c8:	f89d 3019 	ldrb.w	r3, [sp, #25]
323045cc:	f003 03df 	and.w	r3, r3, #223	@ 0xdf
323045d0:	2b50      	cmp	r3, #80	@ 0x50
323045d2:	f47f ae9c 	bne.w	3230430e <__loadlocale+0x12a>
323045d6:	2202      	movs	r2, #2
323045d8:	4640      	mov	r0, r8
323045da:	f64b 1188 	movw	r1, #47496	@ 0xb988
323045de:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323045e2:	f7ff fd8f 	bl	32304104 <strncpy>
323045e6:	220a      	movs	r2, #10
323045e8:	a905      	add	r1, sp, #20
323045ea:	f10d 001a 	add.w	r0, sp, #26
323045ee:	f002 faa3 	bl	32306b38 <strtol>
323045f2:	9b05      	ldr	r3, [sp, #20]
323045f4:	781b      	ldrb	r3, [r3, #0]
323045f6:	2b00      	cmp	r3, #0
323045f8:	f47f ae89 	bne.w	3230430e <__loadlocale+0x12a>
323045fc:	f5b0 7f69 	cmp.w	r0, #932	@ 0x3a4
32304600:	f43f af2f 	beq.w	32304462 <__loadlocale+0x27e>
32304604:	f300 80e6 	bgt.w	323047d4 <__loadlocale+0x5f0>
32304608:	f240 336a 	movw	r3, #874	@ 0x36a
3230460c:	4298      	cmp	r0, r3
3230460e:	f73f ae7e 	bgt.w	3230430e <__loadlocale+0x12a>
32304612:	f240 3351 	movw	r3, #849	@ 0x351
32304616:	4298      	cmp	r0, r3
32304618:	f340 80f7 	ble.w	3230480a <__loadlocale+0x626>
3230461c:	f2a0 3052 	subw	r0, r0, #850	@ 0x352
32304620:	f241 13a5 	movw	r3, #4517	@ 0x11a5
32304624:	f2c0 1301 	movt	r3, #257	@ 0x101
32304628:	40c3      	lsrs	r3, r0
3230462a:	07db      	lsls	r3, r3, #31
3230462c:	f53f aefe 	bmi.w	3230442c <__loadlocale+0x248>
32304630:	e66d      	b.n	3230430e <__loadlocale+0x12a>
32304632:	f64b 1110 	movw	r1, #47376	@ 0xb910
32304636:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230463a:	4640      	mov	r0, r8
3230463c:	f004 feaa 	bl	32309394 <strcasecmp>
32304640:	2800      	cmp	r0, #0
32304642:	f47f ae64 	bne.w	3230430e <__loadlocale+0x12a>
32304646:	4640      	mov	r0, r8
32304648:	f64b 1110 	movw	r1, #47376	@ 0xb910
3230464c:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304650:	f000 fc86 	bl	32304f60 <strcpy>
32304654:	e6ea      	b.n	3230442c <__loadlocale+0x248>
32304656:	f64b 1170 	movw	r1, #47472	@ 0xb970
3230465a:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230465e:	2203      	movs	r2, #3
32304660:	4640      	mov	r0, r8
32304662:	f004 ff6b 	bl	3230953c <strncasecmp>
32304666:	2800      	cmp	r0, #0
32304668:	f47f ae51 	bne.w	3230430e <__loadlocale+0x12a>
3230466c:	f89d 301b 	ldrb.w	r3, [sp, #27]
32304670:	f10d 0a1b 	add.w	sl, sp, #27
32304674:	2b2d      	cmp	r3, #45	@ 0x2d
32304676:	d101      	bne.n	3230467c <__loadlocale+0x498>
32304678:	f10d 0a1c 	add.w	sl, sp, #28
3230467c:	f64b 1174 	movw	r1, #47476	@ 0xb974
32304680:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304684:	2204      	movs	r2, #4
32304686:	4650      	mov	r0, sl
32304688:	f004 ff58 	bl	3230953c <strncasecmp>
3230468c:	2800      	cmp	r0, #0
3230468e:	f47f ae3e 	bne.w	3230430e <__loadlocale+0x12a>
32304692:	f89a 3004 	ldrb.w	r3, [sl, #4]
32304696:	f10a 0004 	add.w	r0, sl, #4
3230469a:	2b2d      	cmp	r3, #45	@ 0x2d
3230469c:	d101      	bne.n	323046a2 <__loadlocale+0x4be>
3230469e:	f10a 0005 	add.w	r0, sl, #5
323046a2:	220a      	movs	r2, #10
323046a4:	a905      	add	r1, sp, #20
323046a6:	f002 fa47 	bl	32306b38 <strtol>
323046aa:	f1a0 020c 	sub.w	r2, r0, #12
323046ae:	1e43      	subs	r3, r0, #1
323046b0:	fab2 f282 	clz	r2, r2
323046b4:	2b0f      	cmp	r3, #15
323046b6:	4682      	mov	sl, r0
323046b8:	bf98      	it	ls
323046ba:	2300      	movls	r3, #0
323046bc:	bf88      	it	hi
323046be:	2301      	movhi	r3, #1
323046c0:	0952      	lsrs	r2, r2, #5
323046c2:	4313      	orrs	r3, r2
323046c4:	f47f ae23 	bne.w	3230430e <__loadlocale+0x12a>
323046c8:	9b05      	ldr	r3, [sp, #20]
323046ca:	781b      	ldrb	r3, [r3, #0]
323046cc:	2b00      	cmp	r3, #0
323046ce:	f47f ae1e 	bne.w	3230430e <__loadlocale+0x12a>
323046d2:	4640      	mov	r0, r8
323046d4:	f64b 117c 	movw	r1, #47484	@ 0xb97c
323046d8:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323046dc:	f000 fc40 	bl	32304f60 <strcpy>
323046e0:	f10d 0221 	add.w	r2, sp, #33	@ 0x21
323046e4:	f1ba 0f0a 	cmp.w	sl, #10
323046e8:	dd04      	ble.n	323046f4 <__loadlocale+0x510>
323046ea:	f10d 0222 	add.w	r2, sp, #34	@ 0x22
323046ee:	2331      	movs	r3, #49	@ 0x31
323046f0:	f88d 3021 	strb.w	r3, [sp, #33]	@ 0x21
323046f4:	f246 6367 	movw	r3, #26215	@ 0x6667
323046f8:	f2c6 6366 	movt	r3, #26214	@ 0x6666
323046fc:	fb83 130a 	smull	r1, r3, r3, sl
32304700:	ea4f 71ea 	mov.w	r1, sl, asr #31
32304704:	ebc1 03a3 	rsb	r3, r1, r3, asr #2
32304708:	210a      	movs	r1, #10
3230470a:	fb01 a313 	mls	r3, r1, r3, sl
3230470e:	3330      	adds	r3, #48	@ 0x30
32304710:	7013      	strb	r3, [r2, #0]
32304712:	2300      	movs	r3, #0
32304714:	7053      	strb	r3, [r2, #1]
32304716:	e689      	b.n	3230442c <__loadlocale+0x248>
32304718:	4641      	mov	r1, r8
3230471a:	f505 7095 	add.w	r0, r5, #298	@ 0x12a
3230471e:	e9cd 2302 	strd	r2, r3, [sp, #8]
32304722:	f000 fc1d 	bl	32304f60 <strcpy>
32304726:	9b03      	ldr	r3, [sp, #12]
32304728:	4641      	mov	r1, r8
3230472a:	9a02      	ldr	r2, [sp, #8]
3230472c:	4628      	mov	r0, r5
3230472e:	e9c5 3a38 	strd	r3, sl, [r5, #224]	@ 0xe0
32304732:	f885 2128 	strb.w	r2, [r5, #296]	@ 0x128
32304736:	f002 fb95 	bl	32306e64 <__set_ctype>
3230473a:	f1b9 0f00 	cmp.w	r9, #0
3230473e:	d10f      	bne.n	32304760 <__loadlocale+0x57c>
32304740:	9a02      	ldr	r2, [sp, #8]
32304742:	f08b 0301 	eor.w	r3, fp, #1
32304746:	f003 0301 	and.w	r3, r3, #1
3230474a:	2a01      	cmp	r2, #1
3230474c:	bf08      	it	eq
3230474e:	2300      	moveq	r3, #0
32304750:	b133      	cbz	r3, 32304760 <__loadlocale+0x57c>
32304752:	f89d 9018 	ldrb.w	r9, [sp, #24]
32304756:	f1b9 0355 	subs.w	r3, r9, #85	@ 0x55
3230475a:	bf18      	it	ne
3230475c:	2301      	movne	r3, #1
3230475e:	4699      	mov	r9, r3
32304760:	9b01      	ldr	r3, [sp, #4]
32304762:	b913      	cbnz	r3, 3230476a <__loadlocale+0x586>
32304764:	f8c5 90e8 	str.w	r9, [r5, #232]	@ 0xe8
32304768:	e636      	b.n	323043d8 <__loadlocale+0x1f4>
3230476a:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
3230476e:	f8c5 30e8 	str.w	r3, [r5, #232]	@ 0xe8
32304772:	e631      	b.n	323043d8 <__loadlocale+0x1f4>
32304774:	f109 0a01 	add.w	sl, r9, #1
32304778:	f64b 1124 	movw	r1, #47396	@ 0xb924
3230477c:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304780:	4650      	mov	r0, sl
32304782:	f000 fa7d 	bl	32304c80 <strcmp>
32304786:	4683      	mov	fp, r0
32304788:	b918      	cbnz	r0, 32304792 <__loadlocale+0x5ae>
3230478a:	2301      	movs	r3, #1
3230478c:	4681      	mov	r9, r0
3230478e:	9301      	str	r3, [sp, #4]
32304790:	e57b      	b.n	3230428a <__loadlocale+0xa6>
32304792:	4650      	mov	r0, sl
32304794:	f64b 1130 	movw	r1, #47408	@ 0xb930
32304798:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230479c:	f000 fa70 	bl	32304c80 <strcmp>
323047a0:	4681      	mov	r9, r0
323047a2:	bb10      	cbnz	r0, 323047ea <__loadlocale+0x606>
323047a4:	f04f 0b01 	mov.w	fp, #1
323047a8:	9001      	str	r0, [sp, #4]
323047aa:	e56e      	b.n	3230428a <__loadlocale+0xa6>
323047ac:	4640      	mov	r0, r8
323047ae:	f64b 1194 	movw	r1, #47508	@ 0xb994
323047b2:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323047b6:	f000 fbd3 	bl	32304f60 <strcpy>
323047ba:	e637      	b.n	3230442c <__loadlocale+0x248>
323047bc:	2b75      	cmp	r3, #117	@ 0x75
323047be:	f47f ada6 	bne.w	3230430e <__loadlocale+0x12a>
323047c2:	e68f      	b.n	323044e4 <__loadlocale+0x300>
323047c4:	4640      	mov	r0, r8
323047c6:	f64b 11a4 	movw	r1, #47524	@ 0xb9a4
323047ca:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323047ce:	f000 fbc7 	bl	32304f60 <strcpy>
323047d2:	e62b      	b.n	3230442c <__loadlocale+0x248>
323047d4:	f240 4365 	movw	r3, #1125	@ 0x465
323047d8:	4298      	cmp	r0, r3
323047da:	f43f ae27 	beq.w	3230442c <__loadlocale+0x248>
323047de:	f2a0 40e2 	subw	r0, r0, #1250	@ 0x4e2
323047e2:	2808      	cmp	r0, #8
323047e4:	f67f ae22 	bls.w	3230442c <__loadlocale+0x248>
323047e8:	e591      	b.n	3230430e <__loadlocale+0x12a>
323047ea:	4650      	mov	r0, sl
323047ec:	f64b 113c 	movw	r1, #47420	@ 0xb93c
323047f0:	f2c3 2130 	movt	r1, #12848	@ 0x3230
323047f4:	f04f 0b00 	mov.w	fp, #0
323047f8:	f000 fa42 	bl	32304c80 <strcmp>
323047fc:	fab0 f980 	clz	r9, r0
32304800:	f8cd b004 	str.w	fp, [sp, #4]
32304804:	ea4f 1959 	mov.w	r9, r9, lsr #5
32304808:	e53f      	b.n	3230428a <__loadlocale+0xa6>
3230480a:	f240 23e1 	movw	r3, #737	@ 0x2e1
3230480e:	4298      	cmp	r0, r3
32304810:	f43f ae0c 	beq.w	3230442c <__loadlocale+0x248>
32304814:	dc09      	bgt.n	3230482a <__loadlocale+0x646>
32304816:	f240 13b5 	movw	r3, #437	@ 0x1b5
3230481a:	4298      	cmp	r0, r3
3230481c:	f43f ae06 	beq.w	3230442c <__loadlocale+0x248>
32304820:	f5b0 7f34 	cmp.w	r0, #720	@ 0x2d0
32304824:	f47f ad73 	bne.w	3230430e <__loadlocale+0x12a>
32304828:	e600      	b.n	3230442c <__loadlocale+0x248>
3230482a:	f240 3307 	movw	r3, #775	@ 0x307
3230482e:	4298      	cmp	r0, r3
32304830:	f47f ad6d 	bne.w	3230430e <__loadlocale+0x12a>
32304834:	e5fa      	b.n	3230442c <__loadlocale+0x248>
32304836:	bf00      	nop

32304838 <__get_locale_env>:
32304838:	b538      	push	{r3, r4, r5, lr}
3230483a:	460d      	mov	r5, r1
3230483c:	f64b 11e4 	movw	r1, #47588	@ 0xb9e4
32304840:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304844:	4604      	mov	r4, r0
32304846:	f001 f917 	bl	32305a78 <_getenv_r>
3230484a:	b108      	cbz	r0, 32304850 <__get_locale_env+0x18>
3230484c:	7803      	ldrb	r3, [r0, #0]
3230484e:	b9db      	cbnz	r3, 32304888 <__get_locale_env+0x50>
32304850:	f64b 5300 	movw	r3, #48384	@ 0xbd00
32304854:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32304858:	4620      	mov	r0, r4
3230485a:	f853 1025 	ldr.w	r1, [r3, r5, lsl #2]
3230485e:	f001 f90b 	bl	32305a78 <_getenv_r>
32304862:	b108      	cbz	r0, 32304868 <__get_locale_env+0x30>
32304864:	7803      	ldrb	r3, [r0, #0]
32304866:	b97b      	cbnz	r3, 32304888 <__get_locale_env+0x50>
32304868:	f64b 11ec 	movw	r1, #47596	@ 0xb9ec
3230486c:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32304870:	4620      	mov	r0, r4
32304872:	f001 f901 	bl	32305a78 <_getenv_r>
32304876:	b140      	cbz	r0, 3230488a <__get_locale_env+0x52>
32304878:	7802      	ldrb	r2, [r0, #0]
3230487a:	f24c 2380 	movw	r3, #49792	@ 0xc280
3230487e:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32304882:	2a00      	cmp	r2, #0
32304884:	bf08      	it	eq
32304886:	4618      	moveq	r0, r3
32304888:	bd38      	pop	{r3, r4, r5, pc}
3230488a:	f24c 2080 	movw	r0, #49792	@ 0xc280
3230488e:	f2c3 2030 	movt	r0, #12848	@ 0x3230
32304892:	bd38      	pop	{r3, r4, r5, pc}

32304894 <_setlocale_r>:
32304894:	e92d 4ff8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
32304898:	2906      	cmp	r1, #6
3230489a:	4680      	mov	r8, r0
3230489c:	d86b      	bhi.n	32304976 <_setlocale_r+0xe2>
3230489e:	468b      	mov	fp, r1
323048a0:	4692      	mov	sl, r2
323048a2:	2a00      	cmp	r2, #0
323048a4:	f000 80a5 	beq.w	323049f2 <_setlocale_r+0x15e>
323048a8:	f8df 9224 	ldr.w	r9, [pc, #548]	@ 32304ad0 <_setlocale_r+0x23c>
323048ac:	4e87      	ldr	r6, [pc, #540]	@ (32304acc <_setlocale_r+0x238>)
323048ae:	f109 07c0 	add.w	r7, r9, #192	@ 0xc0
323048b2:	464c      	mov	r4, r9
323048b4:	4635      	mov	r5, r6
323048b6:	4629      	mov	r1, r5
323048b8:	4620      	mov	r0, r4
323048ba:	3420      	adds	r4, #32
323048bc:	f000 fb50 	bl	32304f60 <strcpy>
323048c0:	3520      	adds	r5, #32
323048c2:	42bc      	cmp	r4, r7
323048c4:	d1f7      	bne.n	323048b6 <_setlocale_r+0x22>
323048c6:	f89a 3000 	ldrb.w	r3, [sl]
323048ca:	bbb3      	cbnz	r3, 3230493a <_setlocale_r+0xa6>
323048cc:	f1bb 0f00 	cmp.w	fp, #0
323048d0:	f040 809c 	bne.w	32304a0c <_setlocale_r+0x178>
323048d4:	4f7e      	ldr	r7, [pc, #504]	@ (32304ad0 <_setlocale_r+0x23c>)
323048d6:	2401      	movs	r4, #1
323048d8:	4621      	mov	r1, r4
323048da:	4640      	mov	r0, r8
323048dc:	f7ff ffac 	bl	32304838 <__get_locale_env>
323048e0:	4605      	mov	r5, r0
323048e2:	f000 fead 	bl	32305640 <strlen>
323048e6:	4603      	mov	r3, r0
323048e8:	4629      	mov	r1, r5
323048ea:	4638      	mov	r0, r7
323048ec:	2b1f      	cmp	r3, #31
323048ee:	d842      	bhi.n	32304976 <_setlocale_r+0xe2>
323048f0:	3401      	adds	r4, #1
323048f2:	f000 fb35 	bl	32304f60 <strcpy>
323048f6:	3720      	adds	r7, #32
323048f8:	2c07      	cmp	r4, #7
323048fa:	d1ed      	bne.n	323048d8 <_setlocale_r+0x44>
323048fc:	f8df b1d4 	ldr.w	fp, [pc, #468]	@ 32304ad4 <_setlocale_r+0x240>
32304900:	f24c 1a10 	movw	sl, #49424	@ 0xc110
32304904:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
32304908:	4f71      	ldr	r7, [pc, #452]	@ (32304ad0 <_setlocale_r+0x23c>)
3230490a:	465d      	mov	r5, fp
3230490c:	2401      	movs	r4, #1
3230490e:	4631      	mov	r1, r6
32304910:	4628      	mov	r0, r5
32304912:	f000 fb25 	bl	32304f60 <strcpy>
32304916:	463a      	mov	r2, r7
32304918:	4621      	mov	r1, r4
3230491a:	4650      	mov	r0, sl
3230491c:	f7ff fc62 	bl	323041e4 <__loadlocale>
32304920:	2800      	cmp	r0, #0
32304922:	f000 8087 	beq.w	32304a34 <_setlocale_r+0x1a0>
32304926:	3401      	adds	r4, #1
32304928:	3520      	adds	r5, #32
3230492a:	3620      	adds	r6, #32
3230492c:	3720      	adds	r7, #32
3230492e:	2c07      	cmp	r4, #7
32304930:	d1ed      	bne.n	3230490e <_setlocale_r+0x7a>
32304932:	e8bd 4ff8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
32304936:	f7ff bc1f 	b.w	32304178 <currentlocale>
3230493a:	f1bb 0f00 	cmp.w	fp, #0
3230493e:	d021      	beq.n	32304984 <_setlocale_r+0xf0>
32304940:	4650      	mov	r0, sl
32304942:	f000 fe7d 	bl	32305640 <strlen>
32304946:	281f      	cmp	r0, #31
32304948:	d815      	bhi.n	32304976 <_setlocale_r+0xe2>
3230494a:	f245 2458 	movw	r4, #21080	@ 0x5258
3230494e:	f2c3 2431 	movt	r4, #12849	@ 0x3231
32304952:	eb04 144b 	add.w	r4, r4, fp, lsl #5
32304956:	4651      	mov	r1, sl
32304958:	4620      	mov	r0, r4
3230495a:	f000 fb01 	bl	32304f60 <strcpy>
3230495e:	4622      	mov	r2, r4
32304960:	4659      	mov	r1, fp
32304962:	f24c 1010 	movw	r0, #49424	@ 0xc110
32304966:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230496a:	f7ff fc3b 	bl	323041e4 <__loadlocale>
3230496e:	4604      	mov	r4, r0
32304970:	f7ff fc02 	bl	32304178 <currentlocale>
32304974:	e003      	b.n	3230497e <_setlocale_r+0xea>
32304976:	2616      	movs	r6, #22
32304978:	2400      	movs	r4, #0
3230497a:	f8c8 6000 	str.w	r6, [r8]
3230497e:	4620      	mov	r0, r4
32304980:	e8bd 8ff8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp, pc}
32304984:	212f      	movs	r1, #47	@ 0x2f
32304986:	4650      	mov	r0, sl
32304988:	f004 fd4a 	bl	32309420 <strchr>
3230498c:	4604      	mov	r4, r0
3230498e:	2800      	cmp	r0, #0
32304990:	d07a      	beq.n	32304a88 <_setlocale_r+0x1f4>
32304992:	7842      	ldrb	r2, [r0, #1]
32304994:	2a2f      	cmp	r2, #47	@ 0x2f
32304996:	bf08      	it	eq
32304998:	1c43      	addeq	r3, r0, #1
3230499a:	d104      	bne.n	323049a6 <_setlocale_r+0x112>
3230499c:	461c      	mov	r4, r3
3230499e:	f813 2f01 	ldrb.w	r2, [r3, #1]!
323049a2:	2a2f      	cmp	r2, #47	@ 0x2f
323049a4:	d0fa      	beq.n	3230499c <_setlocale_r+0x108>
323049a6:	2a00      	cmp	r2, #0
323049a8:	d0e5      	beq.n	32304976 <_setlocale_r+0xe2>
323049aa:	f8df b124 	ldr.w	fp, [pc, #292]	@ 32304ad0 <_setlocale_r+0x23c>
323049ae:	2501      	movs	r5, #1
323049b0:	eba4 020a 	sub.w	r2, r4, sl
323049b4:	2a1f      	cmp	r2, #31
323049b6:	dcde      	bgt.n	32304976 <_setlocale_r+0xe2>
323049b8:	3201      	adds	r2, #1
323049ba:	4651      	mov	r1, sl
323049bc:	4658      	mov	r0, fp
323049be:	3501      	adds	r5, #1
323049c0:	f004 fd96 	bl	323094f0 <strlcpy>
323049c4:	7823      	ldrb	r3, [r4, #0]
323049c6:	2b2f      	cmp	r3, #47	@ 0x2f
323049c8:	d103      	bne.n	323049d2 <_setlocale_r+0x13e>
323049ca:	f814 3f01 	ldrb.w	r3, [r4, #1]!
323049ce:	2b2f      	cmp	r3, #47	@ 0x2f
323049d0:	d0fb      	beq.n	323049ca <_setlocale_r+0x136>
323049d2:	2b00      	cmp	r3, #0
323049d4:	d067      	beq.n	32304aa6 <_setlocale_r+0x212>
323049d6:	4622      	mov	r2, r4
323049d8:	f812 3f01 	ldrb.w	r3, [r2, #1]!
323049dc:	2b00      	cmp	r3, #0
323049de:	bf18      	it	ne
323049e0:	2b2f      	cmpne	r3, #47	@ 0x2f
323049e2:	d1f9      	bne.n	323049d8 <_setlocale_r+0x144>
323049e4:	f10b 0b20 	add.w	fp, fp, #32
323049e8:	2d07      	cmp	r5, #7
323049ea:	d087      	beq.n	323048fc <_setlocale_r+0x68>
323049ec:	46a2      	mov	sl, r4
323049ee:	4614      	mov	r4, r2
323049f0:	e7de      	b.n	323049b0 <_setlocale_r+0x11c>
323049f2:	f24c 0428 	movw	r4, #49192	@ 0xc028
323049f6:	f2c3 2430 	movt	r4, #12848	@ 0x3230
323049fa:	2900      	cmp	r1, #0
323049fc:	d0bf      	beq.n	3230497e <_setlocale_r+0xea>
323049fe:	f24c 1410 	movw	r4, #49424	@ 0xc110
32304a02:	f2c3 2430 	movt	r4, #12848	@ 0x3230
32304a06:	eb04 1441 	add.w	r4, r4, r1, lsl #5
32304a0a:	e7b8      	b.n	3230497e <_setlocale_r+0xea>
32304a0c:	4659      	mov	r1, fp
32304a0e:	4640      	mov	r0, r8
32304a10:	f7ff ff12 	bl	32304838 <__get_locale_env>
32304a14:	4605      	mov	r5, r0
32304a16:	f000 fe13 	bl	32305640 <strlen>
32304a1a:	281f      	cmp	r0, #31
32304a1c:	d8ab      	bhi.n	32304976 <_setlocale_r+0xe2>
32304a1e:	f245 2458 	movw	r4, #21080	@ 0x5258
32304a22:	f2c3 2431 	movt	r4, #12849	@ 0x3231
32304a26:	eb04 144b 	add.w	r4, r4, fp, lsl #5
32304a2a:	4629      	mov	r1, r5
32304a2c:	4620      	mov	r0, r4
32304a2e:	f000 fa97 	bl	32304f60 <strcpy>
32304a32:	e794      	b.n	3230495e <_setlocale_r+0xca>
32304a34:	f8d8 6000 	ldr.w	r6, [r8]
32304a38:	2c01      	cmp	r4, #1
32304a3a:	d09d      	beq.n	32304978 <_setlocale_r+0xe4>
32304a3c:	f24c 1710 	movw	r7, #49424	@ 0xc110
32304a40:	f2c3 2730 	movt	r7, #12848	@ 0x3230
32304a44:	f64b 1a0c 	movw	sl, #47372	@ 0xb90c
32304a48:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
32304a4c:	2501      	movs	r5, #1
32304a4e:	e006      	b.n	32304a5e <_setlocale_r+0x1ca>
32304a50:	3501      	adds	r5, #1
32304a52:	f109 0920 	add.w	r9, r9, #32
32304a56:	f10b 0b20 	add.w	fp, fp, #32
32304a5a:	42a5      	cmp	r5, r4
32304a5c:	d08c      	beq.n	32304978 <_setlocale_r+0xe4>
32304a5e:	4659      	mov	r1, fp
32304a60:	4648      	mov	r0, r9
32304a62:	f000 fa7d 	bl	32304f60 <strcpy>
32304a66:	464a      	mov	r2, r9
32304a68:	4629      	mov	r1, r5
32304a6a:	4638      	mov	r0, r7
32304a6c:	f7ff fbba 	bl	323041e4 <__loadlocale>
32304a70:	2800      	cmp	r0, #0
32304a72:	d1ed      	bne.n	32304a50 <_setlocale_r+0x1bc>
32304a74:	4651      	mov	r1, sl
32304a76:	4648      	mov	r0, r9
32304a78:	f000 fa72 	bl	32304f60 <strcpy>
32304a7c:	464a      	mov	r2, r9
32304a7e:	4629      	mov	r1, r5
32304a80:	4638      	mov	r0, r7
32304a82:	f7ff fbaf 	bl	323041e4 <__loadlocale>
32304a86:	e7e3      	b.n	32304a50 <_setlocale_r+0x1bc>
32304a88:	4650      	mov	r0, sl
32304a8a:	f000 fdd9 	bl	32305640 <strlen>
32304a8e:	281f      	cmp	r0, #31
32304a90:	f63f af71 	bhi.w	32304976 <_setlocale_r+0xe2>
32304a94:	4c0e      	ldr	r4, [pc, #56]	@ (32304ad0 <_setlocale_r+0x23c>)
32304a96:	4620      	mov	r0, r4
32304a98:	4651      	mov	r1, sl
32304a9a:	3420      	adds	r4, #32
32304a9c:	f000 fa60 	bl	32304f60 <strcpy>
32304aa0:	42bc      	cmp	r4, r7
32304aa2:	d1f8      	bne.n	32304a96 <_setlocale_r+0x202>
32304aa4:	e72a      	b.n	323048fc <_setlocale_r+0x68>
32304aa6:	f245 2458 	movw	r4, #21080	@ 0x5258
32304aaa:	f2c3 2431 	movt	r4, #12849	@ 0x3231
32304aae:	eb04 1445 	add.w	r4, r4, r5, lsl #5
32304ab2:	2d07      	cmp	r5, #7
32304ab4:	f43f af22 	beq.w	323048fc <_setlocale_r+0x68>
32304ab8:	f1a4 0120 	sub.w	r1, r4, #32
32304abc:	4620      	mov	r0, r4
32304abe:	3420      	adds	r4, #32
32304ac0:	f000 fa4e 	bl	32304f60 <strcpy>
32304ac4:	42bc      	cmp	r4, r7
32304ac6:	d1f7      	bne.n	32304ab8 <_setlocale_r+0x224>
32304ac8:	e718      	b.n	323048fc <_setlocale_r+0x68>
32304aca:	bf00      	nop
32304acc:	3230c130 	.word	0x3230c130
32304ad0:	32315278 	.word	0x32315278
32304ad4:	32315198 	.word	0x32315198

32304ad8 <__locale_mb_cur_max>:
32304ad8:	f24c 1310 	movw	r3, #49424	@ 0xc110
32304adc:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32304ae0:	f893 0128 	ldrb.w	r0, [r3, #296]	@ 0x128
32304ae4:	4770      	bx	lr
32304ae6:	bf00      	nop

32304ae8 <setlocale>:
32304ae8:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
32304aec:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32304af0:	460a      	mov	r2, r1
32304af2:	4601      	mov	r1, r0
32304af4:	6818      	ldr	r0, [r3, #0]
32304af6:	f7ff becd 	b.w	32304894 <_setlocale_r>
32304afa:	bf00      	nop

32304afc <__localeconv_l>:
32304afc:	30f0      	adds	r0, #240	@ 0xf0
32304afe:	4770      	bx	lr

32304b00 <_localeconv_r>:
32304b00:	4800      	ldr	r0, [pc, #0]	@ (32304b04 <_localeconv_r+0x4>)
32304b02:	4770      	bx	lr
32304b04:	3230c200 	.word	0x3230c200

32304b08 <localeconv>:
32304b08:	4800      	ldr	r0, [pc, #0]	@ (32304b0c <localeconv+0x4>)
32304b0a:	4770      	bx	lr
32304b0c:	3230c200 	.word	0x3230c200

32304b10 <_close_r>:
32304b10:	b538      	push	{r3, r4, r5, lr}
32304b12:	f245 343c 	movw	r4, #21308	@ 0x533c
32304b16:	f2c3 2431 	movt	r4, #12849	@ 0x3231
32304b1a:	4605      	mov	r5, r0
32304b1c:	4608      	mov	r0, r1
32304b1e:	2200      	movs	r2, #0
32304b20:	6022      	str	r2, [r4, #0]
32304b22:	f7fb ec06 	blx	32300330 <_close>
32304b26:	1c43      	adds	r3, r0, #1
32304b28:	d000      	beq.n	32304b2c <_close_r+0x1c>
32304b2a:	bd38      	pop	{r3, r4, r5, pc}
32304b2c:	6823      	ldr	r3, [r4, #0]
32304b2e:	2b00      	cmp	r3, #0
32304b30:	d0fb      	beq.n	32304b2a <_close_r+0x1a>
32304b32:	602b      	str	r3, [r5, #0]
32304b34:	bd38      	pop	{r3, r4, r5, pc}
32304b36:	bf00      	nop

32304b38 <_reclaim_reent>:
32304b38:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
32304b3c:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32304b40:	681b      	ldr	r3, [r3, #0]
32304b42:	4283      	cmp	r3, r0
32304b44:	d02e      	beq.n	32304ba4 <_reclaim_reent+0x6c>
32304b46:	6c41      	ldr	r1, [r0, #68]	@ 0x44
32304b48:	b570      	push	{r4, r5, r6, lr}
32304b4a:	4605      	mov	r5, r0
32304b4c:	b181      	cbz	r1, 32304b70 <_reclaim_reent+0x38>
32304b4e:	2600      	movs	r6, #0
32304b50:	598c      	ldr	r4, [r1, r6]
32304b52:	b13c      	cbz	r4, 32304b64 <_reclaim_reent+0x2c>
32304b54:	4621      	mov	r1, r4
32304b56:	6824      	ldr	r4, [r4, #0]
32304b58:	4628      	mov	r0, r5
32304b5a:	f000 fe45 	bl	323057e8 <_free_r>
32304b5e:	2c00      	cmp	r4, #0
32304b60:	d1f8      	bne.n	32304b54 <_reclaim_reent+0x1c>
32304b62:	6c69      	ldr	r1, [r5, #68]	@ 0x44
32304b64:	3604      	adds	r6, #4
32304b66:	2e80      	cmp	r6, #128	@ 0x80
32304b68:	d1f2      	bne.n	32304b50 <_reclaim_reent+0x18>
32304b6a:	4628      	mov	r0, r5
32304b6c:	f000 fe3c 	bl	323057e8 <_free_r>
32304b70:	6ba9      	ldr	r1, [r5, #56]	@ 0x38
32304b72:	b111      	cbz	r1, 32304b7a <_reclaim_reent+0x42>
32304b74:	4628      	mov	r0, r5
32304b76:	f000 fe37 	bl	323057e8 <_free_r>
32304b7a:	6c2c      	ldr	r4, [r5, #64]	@ 0x40
32304b7c:	b134      	cbz	r4, 32304b8c <_reclaim_reent+0x54>
32304b7e:	4621      	mov	r1, r4
32304b80:	6824      	ldr	r4, [r4, #0]
32304b82:	4628      	mov	r0, r5
32304b84:	f000 fe30 	bl	323057e8 <_free_r>
32304b88:	2c00      	cmp	r4, #0
32304b8a:	d1f8      	bne.n	32304b7e <_reclaim_reent+0x46>
32304b8c:	6ce9      	ldr	r1, [r5, #76]	@ 0x4c
32304b8e:	b111      	cbz	r1, 32304b96 <_reclaim_reent+0x5e>
32304b90:	4628      	mov	r0, r5
32304b92:	f000 fe29 	bl	323057e8 <_free_r>
32304b96:	6b6b      	ldr	r3, [r5, #52]	@ 0x34
32304b98:	b11b      	cbz	r3, 32304ba2 <_reclaim_reent+0x6a>
32304b9a:	4628      	mov	r0, r5
32304b9c:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
32304ba0:	4718      	bx	r3
32304ba2:	bd70      	pop	{r4, r5, r6, pc}
32304ba4:	4770      	bx	lr
32304ba6:	bf00      	nop

32304ba8 <_lseek_r>:
32304ba8:	b538      	push	{r3, r4, r5, lr}
32304baa:	f245 343c 	movw	r4, #21308	@ 0x533c
32304bae:	f2c3 2431 	movt	r4, #12849	@ 0x3231
32304bb2:	460d      	mov	r5, r1
32304bb4:	4684      	mov	ip, r0
32304bb6:	4611      	mov	r1, r2
32304bb8:	4628      	mov	r0, r5
32304bba:	461a      	mov	r2, r3
32304bbc:	4665      	mov	r5, ip
32304bbe:	2300      	movs	r3, #0
32304bc0:	6023      	str	r3, [r4, #0]
32304bc2:	f7fb eba8 	blx	32300314 <_lseek>
32304bc6:	1c43      	adds	r3, r0, #1
32304bc8:	d000      	beq.n	32304bcc <_lseek_r+0x24>
32304bca:	bd38      	pop	{r3, r4, r5, pc}
32304bcc:	6823      	ldr	r3, [r4, #0]
32304bce:	2b00      	cmp	r3, #0
32304bd0:	d0fb      	beq.n	32304bca <_lseek_r+0x22>
32304bd2:	602b      	str	r3, [r5, #0]
32304bd4:	bd38      	pop	{r3, r4, r5, pc}
32304bd6:	bf00      	nop

32304bd8 <_read_r>:
32304bd8:	b538      	push	{r3, r4, r5, lr}
32304bda:	f245 343c 	movw	r4, #21308	@ 0x533c
32304bde:	f2c3 2431 	movt	r4, #12849	@ 0x3231
32304be2:	460d      	mov	r5, r1
32304be4:	4684      	mov	ip, r0
32304be6:	4611      	mov	r1, r2
32304be8:	4628      	mov	r0, r5
32304bea:	461a      	mov	r2, r3
32304bec:	4665      	mov	r5, ip
32304bee:	2300      	movs	r3, #0
32304bf0:	6023      	str	r3, [r4, #0]
32304bf2:	f7fb eb52 	blx	32300298 <_read>
32304bf6:	1c43      	adds	r3, r0, #1
32304bf8:	d000      	beq.n	32304bfc <_read_r+0x24>
32304bfa:	bd38      	pop	{r3, r4, r5, pc}
32304bfc:	6823      	ldr	r3, [r4, #0]
32304bfe:	2b00      	cmp	r3, #0
32304c00:	d0fb      	beq.n	32304bfa <_read_r+0x22>
32304c02:	602b      	str	r3, [r5, #0]
32304c04:	bd38      	pop	{r3, r4, r5, pc}
32304c06:	bf00      	nop

32304c08 <_write_r>:
32304c08:	b538      	push	{r3, r4, r5, lr}
32304c0a:	f245 343c 	movw	r4, #21308	@ 0x533c
32304c0e:	f2c3 2431 	movt	r4, #12849	@ 0x3231
32304c12:	460d      	mov	r5, r1
32304c14:	4684      	mov	ip, r0
32304c16:	4611      	mov	r1, r2
32304c18:	4628      	mov	r0, r5
32304c1a:	461a      	mov	r2, r3
32304c1c:	4665      	mov	r5, ip
32304c1e:	2300      	movs	r3, #0
32304c20:	6023      	str	r3, [r4, #0]
32304c22:	f7fb eb50 	blx	323002c4 <_write>
32304c26:	1c43      	adds	r3, r0, #1
32304c28:	d000      	beq.n	32304c2c <_write_r+0x24>
32304c2a:	bd38      	pop	{r3, r4, r5, pc}
32304c2c:	6823      	ldr	r3, [r4, #0]
32304c2e:	2b00      	cmp	r3, #0
32304c30:	d0fb      	beq.n	32304c2a <_write_r+0x22>
32304c32:	602b      	str	r3, [r5, #0]
32304c34:	bd38      	pop	{r3, r4, r5, pc}
32304c36:	bf00      	nop

32304c38 <__errno>:
32304c38:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
32304c3c:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32304c40:	6818      	ldr	r0, [r3, #0]
32304c42:	4770      	bx	lr

32304c44 <__retarget_lock_init>:
32304c44:	4770      	bx	lr
32304c46:	bf00      	nop

32304c48 <__retarget_lock_init_recursive>:
32304c48:	4770      	bx	lr
32304c4a:	bf00      	nop

32304c4c <__retarget_lock_close>:
32304c4c:	4770      	bx	lr
32304c4e:	bf00      	nop

32304c50 <__retarget_lock_close_recursive>:
32304c50:	4770      	bx	lr
32304c52:	bf00      	nop

32304c54 <__retarget_lock_acquire>:
32304c54:	4770      	bx	lr
32304c56:	bf00      	nop

32304c58 <__retarget_lock_acquire_recursive>:
32304c58:	4770      	bx	lr
32304c5a:	bf00      	nop

32304c5c <__retarget_lock_try_acquire>:
32304c5c:	2001      	movs	r0, #1
32304c5e:	4770      	bx	lr

32304c60 <__retarget_lock_try_acquire_recursive>:
32304c60:	2001      	movs	r0, #1
32304c62:	4770      	bx	lr

32304c64 <__retarget_lock_release>:
32304c64:	4770      	bx	lr
32304c66:	bf00      	nop

32304c68 <__retarget_lock_release_recursive>:
32304c68:	4770      	bx	lr
32304c6a:	bf00      	nop
	...

32304c80 <strcmp>:
32304c80:	7802      	ldrb	r2, [r0, #0]
32304c82:	780b      	ldrb	r3, [r1, #0]
32304c84:	2a01      	cmp	r2, #1
32304c86:	bf28      	it	cs
32304c88:	429a      	cmpcs	r2, r3
32304c8a:	f040 80d8 	bne.w	32304e3e <strcmp+0x1be>
32304c8e:	e96d 4504 	strd	r4, r5, [sp, #-16]!
32304c92:	ea40 0401 	orr.w	r4, r0, r1
32304c96:	e9cd 6702 	strd	r6, r7, [sp, #8]
32304c9a:	f06f 0c00 	mvn.w	ip, #0
32304c9e:	ea4f 7244 	mov.w	r2, r4, lsl #29
32304ca2:	b31a      	cbz	r2, 32304cec <strcmp+0x6c>
32304ca4:	ea80 0401 	eor.w	r4, r0, r1
32304ca8:	f014 0f07 	tst.w	r4, #7
32304cac:	d16b      	bne.n	32304d86 <strcmp+0x106>
32304cae:	f000 0407 	and.w	r4, r0, #7
32304cb2:	f020 0007 	bic.w	r0, r0, #7
32304cb6:	f004 0503 	and.w	r5, r4, #3
32304cba:	f021 0107 	bic.w	r1, r1, #7
32304cbe:	ea4f 05c5 	mov.w	r5, r5, lsl #3
32304cc2:	e8f0 2304 	ldrd	r2, r3, [r0], #16
32304cc6:	f014 0f04 	tst.w	r4, #4
32304cca:	e8f1 6704 	ldrd	r6, r7, [r1], #16
32304cce:	fa0c f405 	lsl.w	r4, ip, r5
32304cd2:	ea62 0204 	orn	r2, r2, r4
32304cd6:	ea66 0604 	orn	r6, r6, r4
32304cda:	d00b      	beq.n	32304cf4 <strcmp+0x74>
32304cdc:	ea63 0304 	orn	r3, r3, r4
32304ce0:	4662      	mov	r2, ip
32304ce2:	ea67 0704 	orn	r7, r7, r4
32304ce6:	4666      	mov	r6, ip
32304ce8:	e004      	b.n	32304cf4 <strcmp+0x74>
32304cea:	bf00      	nop
32304cec:	e8f0 2304 	ldrd	r2, r3, [r0], #16
32304cf0:	e8f1 6704 	ldrd	r6, r7, [r1], #16
32304cf4:	fa82 f54c 	uadd8	r5, r2, ip
32304cf8:	ea82 0406 	eor.w	r4, r2, r6
32304cfc:	faa4 f48c 	sel	r4, r4, ip
32304d00:	bb6c      	cbnz	r4, 32304d5e <strcmp+0xde>
32304d02:	fa83 f54c 	uadd8	r5, r3, ip
32304d06:	ea83 0507 	eor.w	r5, r3, r7
32304d0a:	faa5 f58c 	sel	r5, r5, ip
32304d0e:	b995      	cbnz	r5, 32304d36 <strcmp+0xb6>
32304d10:	e950 2302 	ldrd	r2, r3, [r0, #-8]
32304d14:	e951 6702 	ldrd	r6, r7, [r1, #-8]
32304d18:	fa82 f54c 	uadd8	r5, r2, ip
32304d1c:	ea82 0406 	eor.w	r4, r2, r6
32304d20:	faa4 f48c 	sel	r4, r4, ip
32304d24:	fa83 f54c 	uadd8	r5, r3, ip
32304d28:	ea83 0507 	eor.w	r5, r3, r7
32304d2c:	faa5 f58c 	sel	r5, r5, ip
32304d30:	4325      	orrs	r5, r4
32304d32:	d0db      	beq.n	32304cec <strcmp+0x6c>
32304d34:	b99c      	cbnz	r4, 32304d5e <strcmp+0xde>
32304d36:	ba2d      	rev	r5, r5
32304d38:	fab5 f485 	clz	r4, r5
32304d3c:	f024 0407 	bic.w	r4, r4, #7
32304d40:	fa27 f104 	lsr.w	r1, r7, r4
32304d44:	e9dd 6702 	ldrd	r6, r7, [sp, #8]
32304d48:	fa23 f304 	lsr.w	r3, r3, r4
32304d4c:	f003 00ff 	and.w	r0, r3, #255	@ 0xff
32304d50:	f001 01ff 	and.w	r1, r1, #255	@ 0xff
32304d54:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32304d58:	eba0 0001 	sub.w	r0, r0, r1
32304d5c:	4770      	bx	lr
32304d5e:	ba24      	rev	r4, r4
32304d60:	fab4 f484 	clz	r4, r4
32304d64:	f024 0407 	bic.w	r4, r4, #7
32304d68:	fa26 f104 	lsr.w	r1, r6, r4
32304d6c:	e9dd 6702 	ldrd	r6, r7, [sp, #8]
32304d70:	fa22 f204 	lsr.w	r2, r2, r4
32304d74:	f002 00ff 	and.w	r0, r2, #255	@ 0xff
32304d78:	f001 01ff 	and.w	r1, r1, #255	@ 0xff
32304d7c:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32304d80:	eba0 0001 	sub.w	r0, r0, r1
32304d84:	4770      	bx	lr
32304d86:	f014 0f03 	tst.w	r4, #3
32304d8a:	d13c      	bne.n	32304e06 <strcmp+0x186>
32304d8c:	f010 0403 	ands.w	r4, r0, #3
32304d90:	d128      	bne.n	32304de4 <strcmp+0x164>
32304d92:	f850 2b08 	ldr.w	r2, [r0], #8
32304d96:	f851 3b08 	ldr.w	r3, [r1], #8
32304d9a:	fa82 f54c 	uadd8	r5, r2, ip
32304d9e:	ea82 0503 	eor.w	r5, r2, r3
32304da2:	faa5 f58c 	sel	r5, r5, ip
32304da6:	b95d      	cbnz	r5, 32304dc0 <strcmp+0x140>
32304da8:	f850 2c04 	ldr.w	r2, [r0, #-4]
32304dac:	f851 3c04 	ldr.w	r3, [r1, #-4]
32304db0:	fa82 f54c 	uadd8	r5, r2, ip
32304db4:	ea82 0503 	eor.w	r5, r2, r3
32304db8:	faa5 f58c 	sel	r5, r5, ip
32304dbc:	2d00      	cmp	r5, #0
32304dbe:	d0e8      	beq.n	32304d92 <strcmp+0x112>
32304dc0:	ba2d      	rev	r5, r5
32304dc2:	fab5 f485 	clz	r4, r5
32304dc6:	f024 0407 	bic.w	r4, r4, #7
32304dca:	fa23 f104 	lsr.w	r1, r3, r4
32304dce:	fa22 f204 	lsr.w	r2, r2, r4
32304dd2:	f002 00ff 	and.w	r0, r2, #255	@ 0xff
32304dd6:	f001 01ff 	and.w	r1, r1, #255	@ 0xff
32304dda:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32304dde:	eba0 0001 	sub.w	r0, r0, r1
32304de2:	4770      	bx	lr
32304de4:	ea4f 04c4 	mov.w	r4, r4, lsl #3
32304de8:	f020 0003 	bic.w	r0, r0, #3
32304dec:	f850 2b08 	ldr.w	r2, [r0], #8
32304df0:	f021 0103 	bic.w	r1, r1, #3
32304df4:	f851 3b08 	ldr.w	r3, [r1], #8
32304df8:	fa0c f404 	lsl.w	r4, ip, r4
32304dfc:	ea62 0204 	orn	r2, r2, r4
32304e00:	ea63 0304 	orn	r3, r3, r4
32304e04:	e7c9      	b.n	32304d9a <strcmp+0x11a>
32304e06:	f010 0403 	ands.w	r4, r0, #3
32304e0a:	d01d      	beq.n	32304e48 <strcmp+0x1c8>
32304e0c:	eba1 0104 	sub.w	r1, r1, r4
32304e10:	f020 0003 	bic.w	r0, r0, #3
32304e14:	07e4      	lsls	r4, r4, #31
32304e16:	f850 2b04 	ldr.w	r2, [r0], #4
32304e1a:	d006      	beq.n	32304e2a <strcmp+0x1aa>
32304e1c:	d212      	bcs.n	32304e44 <strcmp+0x1c4>
32304e1e:	788b      	ldrb	r3, [r1, #2]
32304e20:	fa5f f4a2 	uxtb.w	r4, r2, ror #16
32304e24:	1ae4      	subs	r4, r4, r3
32304e26:	d106      	bne.n	32304e36 <strcmp+0x1b6>
32304e28:	b12b      	cbz	r3, 32304e36 <strcmp+0x1b6>
32304e2a:	78cb      	ldrb	r3, [r1, #3]
32304e2c:	fa5f f4b2 	uxtb.w	r4, r2, ror #24
32304e30:	1ae4      	subs	r4, r4, r3
32304e32:	d100      	bne.n	32304e36 <strcmp+0x1b6>
32304e34:	b933      	cbnz	r3, 32304e44 <strcmp+0x1c4>
32304e36:	4620      	mov	r0, r4
32304e38:	f85d 4b10 	ldr.w	r4, [sp], #16
32304e3c:	4770      	bx	lr
32304e3e:	eba2 0003 	sub.w	r0, r2, r3
32304e42:	4770      	bx	lr
32304e44:	f101 0104 	add.w	r1, r1, #4
32304e48:	f850 2b04 	ldr.w	r2, [r0], #4
32304e4c:	07cc      	lsls	r4, r1, #31
32304e4e:	f021 0103 	bic.w	r1, r1, #3
32304e52:	f851 3b04 	ldr.w	r3, [r1], #4
32304e56:	d848      	bhi.n	32304eea <strcmp+0x26a>
32304e58:	d224      	bcs.n	32304ea4 <strcmp+0x224>
32304e5a:	f022 447f 	bic.w	r4, r2, #4278190080	@ 0xff000000
32304e5e:	fa82 f54c 	uadd8	r5, r2, ip
32304e62:	ea94 2513 	eors.w	r5, r4, r3, lsr #8
32304e66:	faa5 f58c 	sel	r5, r5, ip
32304e6a:	d10a      	bne.n	32304e82 <strcmp+0x202>
32304e6c:	b965      	cbnz	r5, 32304e88 <strcmp+0x208>
32304e6e:	f851 3b04 	ldr.w	r3, [r1], #4
32304e72:	ea84 0402 	eor.w	r4, r4, r2
32304e76:	ebb4 6f03 	cmp.w	r4, r3, lsl #24
32304e7a:	d10e      	bne.n	32304e9a <strcmp+0x21a>
32304e7c:	f850 2b04 	ldr.w	r2, [r0], #4
32304e80:	e7eb      	b.n	32304e5a <strcmp+0x1da>
32304e82:	ea4f 2313 	mov.w	r3, r3, lsr #8
32304e86:	e055      	b.n	32304f34 <strcmp+0x2b4>
32304e88:	f035 457f 	bics.w	r5, r5, #4278190080	@ 0xff000000
32304e8c:	d14d      	bne.n	32304f2a <strcmp+0x2aa>
32304e8e:	7808      	ldrb	r0, [r1, #0]
32304e90:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32304e94:	f1c0 0000 	rsb	r0, r0, #0
32304e98:	4770      	bx	lr
32304e9a:	ea4f 6212 	mov.w	r2, r2, lsr #24
32304e9e:	f003 03ff 	and.w	r3, r3, #255	@ 0xff
32304ea2:	e047      	b.n	32304f34 <strcmp+0x2b4>
32304ea4:	ea02 441c 	and.w	r4, r2, ip, lsr #16
32304ea8:	fa82 f54c 	uadd8	r5, r2, ip
32304eac:	ea94 4513 	eors.w	r5, r4, r3, lsr #16
32304eb0:	faa5 f58c 	sel	r5, r5, ip
32304eb4:	d10a      	bne.n	32304ecc <strcmp+0x24c>
32304eb6:	b965      	cbnz	r5, 32304ed2 <strcmp+0x252>
32304eb8:	f851 3b04 	ldr.w	r3, [r1], #4
32304ebc:	ea84 0402 	eor.w	r4, r4, r2
32304ec0:	ebb4 4f03 	cmp.w	r4, r3, lsl #16
32304ec4:	d10c      	bne.n	32304ee0 <strcmp+0x260>
32304ec6:	f850 2b04 	ldr.w	r2, [r0], #4
32304eca:	e7eb      	b.n	32304ea4 <strcmp+0x224>
32304ecc:	ea4f 4313 	mov.w	r3, r3, lsr #16
32304ed0:	e030      	b.n	32304f34 <strcmp+0x2b4>
32304ed2:	ea15 451c 	ands.w	r5, r5, ip, lsr #16
32304ed6:	d128      	bne.n	32304f2a <strcmp+0x2aa>
32304ed8:	880b      	ldrh	r3, [r1, #0]
32304eda:	ea4f 4212 	mov.w	r2, r2, lsr #16
32304ede:	e029      	b.n	32304f34 <strcmp+0x2b4>
32304ee0:	ea4f 4212 	mov.w	r2, r2, lsr #16
32304ee4:	ea03 431c 	and.w	r3, r3, ip, lsr #16
32304ee8:	e024      	b.n	32304f34 <strcmp+0x2b4>
32304eea:	f002 04ff 	and.w	r4, r2, #255	@ 0xff
32304eee:	fa82 f54c 	uadd8	r5, r2, ip
32304ef2:	ea94 6513 	eors.w	r5, r4, r3, lsr #24
32304ef6:	faa5 f58c 	sel	r5, r5, ip
32304efa:	d10a      	bne.n	32304f12 <strcmp+0x292>
32304efc:	b965      	cbnz	r5, 32304f18 <strcmp+0x298>
32304efe:	f851 3b04 	ldr.w	r3, [r1], #4
32304f02:	ea84 0402 	eor.w	r4, r4, r2
32304f06:	ebb4 2f03 	cmp.w	r4, r3, lsl #8
32304f0a:	d109      	bne.n	32304f20 <strcmp+0x2a0>
32304f0c:	f850 2b04 	ldr.w	r2, [r0], #4
32304f10:	e7eb      	b.n	32304eea <strcmp+0x26a>
32304f12:	ea4f 6313 	mov.w	r3, r3, lsr #24
32304f16:	e00d      	b.n	32304f34 <strcmp+0x2b4>
32304f18:	f015 0fff 	tst.w	r5, #255	@ 0xff
32304f1c:	d105      	bne.n	32304f2a <strcmp+0x2aa>
32304f1e:	680b      	ldr	r3, [r1, #0]
32304f20:	ea4f 2212 	mov.w	r2, r2, lsr #8
32304f24:	f023 437f 	bic.w	r3, r3, #4278190080	@ 0xff000000
32304f28:	e004      	b.n	32304f34 <strcmp+0x2b4>
32304f2a:	f04f 0000 	mov.w	r0, #0
32304f2e:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32304f32:	4770      	bx	lr
32304f34:	ba12      	rev	r2, r2
32304f36:	ba1b      	rev	r3, r3
32304f38:	fa82 f44c 	uadd8	r4, r2, ip
32304f3c:	ea82 0403 	eor.w	r4, r2, r3
32304f40:	faa4 f58c 	sel	r5, r4, ip
32304f44:	fab5 f485 	clz	r4, r5
32304f48:	fa02 f204 	lsl.w	r2, r2, r4
32304f4c:	fa03 f304 	lsl.w	r3, r3, r4
32304f50:	ea4f 6012 	mov.w	r0, r2, lsr #24
32304f54:	e8fd 4504 	ldrd	r4, r5, [sp], #16
32304f58:	eba0 6013 	sub.w	r0, r0, r3, lsr #24
32304f5c:	4770      	bx	lr
32304f5e:	bf00      	nop

32304f60 <strcpy>:
32304f60:	f891 f000 	pld	[r1]
32304f64:	ea80 0201 	eor.w	r2, r0, r1
32304f68:	4684      	mov	ip, r0
32304f6a:	f012 0f03 	tst.w	r2, #3
32304f6e:	d151      	bne.n	32305014 <strcpy+0xb4>
32304f70:	f011 0f03 	tst.w	r1, #3
32304f74:	d134      	bne.n	32304fe0 <strcpy+0x80>
32304f76:	f84d 4d04 	str.w	r4, [sp, #-4]!
32304f7a:	f011 0f04 	tst.w	r1, #4
32304f7e:	f851 3b04 	ldr.w	r3, [r1], #4
32304f82:	d00b      	beq.n	32304f9c <strcpy+0x3c>
32304f84:	f1a3 3201 	sub.w	r2, r3, #16843009	@ 0x1010101
32304f88:	439a      	bics	r2, r3
32304f8a:	f012 3f80 	tst.w	r2, #2155905152	@ 0x80808080
32304f8e:	bf04      	itt	eq
32304f90:	f84c 3b04 	streq.w	r3, [ip], #4
32304f94:	f851 3b04 	ldreq.w	r3, [r1], #4
32304f98:	d118      	bne.n	32304fcc <strcpy+0x6c>
32304f9a:	bf00      	nop
32304f9c:	f891 f008 	pld	[r1, #8]
32304fa0:	f851 4b04 	ldr.w	r4, [r1], #4
32304fa4:	f1a3 3201 	sub.w	r2, r3, #16843009	@ 0x1010101
32304fa8:	439a      	bics	r2, r3
32304faa:	f012 3f80 	tst.w	r2, #2155905152	@ 0x80808080
32304fae:	f1a4 3201 	sub.w	r2, r4, #16843009	@ 0x1010101
32304fb2:	d10b      	bne.n	32304fcc <strcpy+0x6c>
32304fb4:	f84c 3b04 	str.w	r3, [ip], #4
32304fb8:	43a2      	bics	r2, r4
32304fba:	f012 3f80 	tst.w	r2, #2155905152	@ 0x80808080
32304fbe:	bf04      	itt	eq
32304fc0:	f851 3b04 	ldreq.w	r3, [r1], #4
32304fc4:	f84c 4b04 	streq.w	r4, [ip], #4
32304fc8:	d0e8      	beq.n	32304f9c <strcpy+0x3c>
32304fca:	4623      	mov	r3, r4
32304fcc:	f80c 3b01 	strb.w	r3, [ip], #1
32304fd0:	f013 0fff 	tst.w	r3, #255	@ 0xff
32304fd4:	ea4f 2333 	mov.w	r3, r3, ror #8
32304fd8:	d1f8      	bne.n	32304fcc <strcpy+0x6c>
32304fda:	f85d 4b04 	ldr.w	r4, [sp], #4
32304fde:	4770      	bx	lr
32304fe0:	f011 0f01 	tst.w	r1, #1
32304fe4:	d006      	beq.n	32304ff4 <strcpy+0x94>
32304fe6:	f811 2b01 	ldrb.w	r2, [r1], #1
32304fea:	f80c 2b01 	strb.w	r2, [ip], #1
32304fee:	2a00      	cmp	r2, #0
32304ff0:	bf08      	it	eq
32304ff2:	4770      	bxeq	lr
32304ff4:	f011 0f02 	tst.w	r1, #2
32304ff8:	d0bd      	beq.n	32304f76 <strcpy+0x16>
32304ffa:	f831 2b02 	ldrh.w	r2, [r1], #2
32304ffe:	f012 0fff 	tst.w	r2, #255	@ 0xff
32305002:	bf16      	itet	ne
32305004:	f82c 2b02 	strhne.w	r2, [ip], #2
32305008:	f88c 2000 	strbeq.w	r2, [ip]
3230500c:	f412 4f7f 	tstne.w	r2, #65280	@ 0xff00
32305010:	d1b1      	bne.n	32304f76 <strcpy+0x16>
32305012:	4770      	bx	lr
32305014:	f811 2b01 	ldrb.w	r2, [r1], #1
32305018:	f80c 2b01 	strb.w	r2, [ip], #1
3230501c:	2a00      	cmp	r2, #0
3230501e:	d1f9      	bne.n	32305014 <strcpy+0xb4>
32305020:	4770      	bx	lr
32305022:	bf00      	nop
	...

32305030 <memchr>:
32305030:	2a07      	cmp	r2, #7
32305032:	d80a      	bhi.n	3230504a <memchr+0x1a>
32305034:	f001 01ff 	and.w	r1, r1, #255	@ 0xff
32305038:	3a01      	subs	r2, #1
3230503a:	d36a      	bcc.n	32305112 <memchr+0xe2>
3230503c:	f810 3b01 	ldrb.w	r3, [r0], #1
32305040:	428b      	cmp	r3, r1
32305042:	d1f9      	bne.n	32305038 <memchr+0x8>
32305044:	f1a0 0001 	sub.w	r0, r0, #1
32305048:	4770      	bx	lr
3230504a:	eee0 1b10 	vdup.8	q0, r1
3230504e:	f240 2301 	movw	r3, #513	@ 0x201
32305052:	f6c0 0304 	movt	r3, #2052	@ 0x804
32305056:	ea4f 1c03 	mov.w	ip, r3, lsl #4
3230505a:	ec4c 3b16 	vmov	d6, r3, ip
3230505e:	ec4c 3b17 	vmov	d7, r3, ip
32305062:	f020 011f 	bic.w	r1, r0, #31
32305066:	f010 0c1f 	ands.w	ip, r0, #31
3230506a:	d01c      	beq.n	323050a6 <memchr+0x76>
3230506c:	f921 223d 	vld1.8	{d2-d5}, [r1 :256]!
32305070:	f1ac 0320 	sub.w	r3, ip, #32
32305074:	18d2      	adds	r2, r2, r3
32305076:	ff02 2850 	vceq.i8	q1, q1, q0
3230507a:	ff04 4850 	vceq.i8	q2, q2, q0
3230507e:	ef02 2156 	vand	q1, q1, q3
32305082:	ef04 4156 	vand	q2, q2, q3
32305086:	ef02 2b13 	vpadd.i8	d2, d2, d3
3230508a:	ef04 4b15 	vpadd.i8	d4, d4, d5
3230508e:	ef02 2b14 	vpadd.i8	d2, d2, d4
32305092:	ef02 2b12 	vpadd.i8	d2, d2, d2
32305096:	ee12 0b10 	vmov.32	r0, d2[0]
3230509a:	fa20 f00c 	lsr.w	r0, r0, ip
3230509e:	fa00 f00c 	lsl.w	r0, r0, ip
323050a2:	d927      	bls.n	323050f4 <memchr+0xc4>
323050a4:	bb68      	cbnz	r0, 32305102 <memchr+0xd2>
323050a6:	ed2d 8b04 	vpush	{d8-d9}
323050aa:	bf00      	nop
323050ac:	f3af 8000 	nop.w
323050b0:	f921 223d 	vld1.8	{d2-d5}, [r1 :256]!
323050b4:	3a20      	subs	r2, #32
323050b6:	ff02 2850 	vceq.i8	q1, q1, q0
323050ba:	ff04 4850 	vceq.i8	q2, q2, q0
323050be:	d907      	bls.n	323050d0 <memchr+0xa0>
323050c0:	ef22 8154 	vorr	q4, q1, q2
323050c4:	ef28 8119 	vorr	d8, d8, d9
323050c8:	ec53 0b18 	vmov	r0, r3, d8
323050cc:	4318      	orrs	r0, r3
323050ce:	d0ef      	beq.n	323050b0 <memchr+0x80>
323050d0:	ecbd 8b04 	vpop	{d8-d9}
323050d4:	ef02 2156 	vand	q1, q1, q3
323050d8:	ef04 4156 	vand	q2, q2, q3
323050dc:	ef02 2b13 	vpadd.i8	d2, d2, d3
323050e0:	ef04 4b15 	vpadd.i8	d4, d4, d5
323050e4:	ef02 2b14 	vpadd.i8	d2, d2, d4
323050e8:	ef02 2b12 	vpadd.i8	d2, d2, d2
323050ec:	ee12 0b10 	vmov.32	r0, d2[0]
323050f0:	b178      	cbz	r0, 32305112 <memchr+0xe2>
323050f2:	d806      	bhi.n	32305102 <memchr+0xd2>
323050f4:	f1c2 0200 	rsb	r2, r2, #0
323050f8:	fa00 f002 	lsl.w	r0, r0, r2
323050fc:	40d0      	lsrs	r0, r2
323050fe:	bf08      	it	eq
32305100:	2100      	moveq	r1, #0
32305102:	fa90 f0a0 	rbit	r0, r0
32305106:	f1a1 0120 	sub.w	r1, r1, #32
3230510a:	fab0 f080 	clz	r0, r0
3230510e:	4408      	add	r0, r1
32305110:	4770      	bx	lr
32305112:	f04f 0000 	mov.w	r0, #0
32305116:	4770      	bx	lr
	...

32305140 <memcpy>:
32305140:	e1a0c000 	mov	ip, r0
32305144:	e3520040 	cmp	r2, #64	@ 0x40
32305148:	aa000019 	bge	323051b4 <memcpy+0x74>
3230514c:	e2023038 	and	r3, r2, #56	@ 0x38
32305150:	e2633034 	rsb	r3, r3, #52	@ 0x34
32305154:	e08ff003 	add	pc, pc, r3
32305158:	f421070d 	vld1.8	{d0}, [r1]!
3230515c:	f40c070d 	vst1.8	{d0}, [ip]!
32305160:	f421070d 	vld1.8	{d0}, [r1]!
32305164:	f40c070d 	vst1.8	{d0}, [ip]!
32305168:	f421070d 	vld1.8	{d0}, [r1]!
3230516c:	f40c070d 	vst1.8	{d0}, [ip]!
32305170:	f421070d 	vld1.8	{d0}, [r1]!
32305174:	f40c070d 	vst1.8	{d0}, [ip]!
32305178:	f421070d 	vld1.8	{d0}, [r1]!
3230517c:	f40c070d 	vst1.8	{d0}, [ip]!
32305180:	f421070d 	vld1.8	{d0}, [r1]!
32305184:	f40c070d 	vst1.8	{d0}, [ip]!
32305188:	f421070d 	vld1.8	{d0}, [r1]!
3230518c:	f40c070d 	vst1.8	{d0}, [ip]!
32305190:	e3120004 	tst	r2, #4
32305194:	14913004 	ldrne	r3, [r1], #4
32305198:	148c3004 	strne	r3, [ip], #4
3230519c:	e1b02f82 	lsls	r2, r2, #31
323051a0:	20d130b2 	ldrhcs	r3, [r1], #2
323051a4:	15d11000 	ldrbne	r1, [r1]
323051a8:	20cc30b2 	strhcs	r3, [ip], #2
323051ac:	15cc1000 	strbne	r1, [ip]
323051b0:	e12fff1e 	bx	lr
323051b4:	e52da004 	push	{sl}		@ (str sl, [sp, #-4]!)
323051b8:	e201a007 	and	sl, r1, #7
323051bc:	e20c3007 	and	r3, ip, #7
323051c0:	e153000a 	cmp	r3, sl
323051c4:	1a0000f1 	bne	32305590 <memcpy+0x450>
323051c8:	eeb00a40 	vmov.f32	s0, s0
323051cc:	e1b0ae8c 	lsls	sl, ip, #29
323051d0:	0a000008 	beq	323051f8 <memcpy+0xb8>
323051d4:	e27aa000 	rsbs	sl, sl, #0
323051d8:	e0422eaa 	sub	r2, r2, sl, lsr #29
323051dc:	44913004 	ldrmi	r3, [r1], #4
323051e0:	448c3004 	strmi	r3, [ip], #4
323051e4:	e1b0a10a 	lsls	sl, sl, #2
323051e8:	20d130b2 	ldrhcs	r3, [r1], #2
323051ec:	14d1a001 	ldrbne	sl, [r1], #1
323051f0:	20cc30b2 	strhcs	r3, [ip], #2
323051f4:	14cca001 	strbne	sl, [ip], #1
323051f8:	e252a040 	subs	sl, r2, #64	@ 0x40
323051fc:	ba000017 	blt	32305260 <memcpy+0x120>
32305200:	e35a0c02 	cmp	sl, #512	@ 0x200
32305204:	aa000032 	bge	323052d4 <memcpy+0x194>
32305208:	ed910b00 	vldr	d0, [r1]
3230520c:	e25aa040 	subs	sl, sl, #64	@ 0x40
32305210:	ed911b02 	vldr	d1, [r1, #8]
32305214:	ed8c0b00 	vstr	d0, [ip]
32305218:	ed910b04 	vldr	d0, [r1, #16]
3230521c:	ed8c1b02 	vstr	d1, [ip, #8]
32305220:	ed911b06 	vldr	d1, [r1, #24]
32305224:	ed8c0b04 	vstr	d0, [ip, #16]
32305228:	ed910b08 	vldr	d0, [r1, #32]
3230522c:	ed8c1b06 	vstr	d1, [ip, #24]
32305230:	ed911b0a 	vldr	d1, [r1, #40]	@ 0x28
32305234:	ed8c0b08 	vstr	d0, [ip, #32]
32305238:	ed910b0c 	vldr	d0, [r1, #48]	@ 0x30
3230523c:	ed8c1b0a 	vstr	d1, [ip, #40]	@ 0x28
32305240:	ed911b0e 	vldr	d1, [r1, #56]	@ 0x38
32305244:	ed8c0b0c 	vstr	d0, [ip, #48]	@ 0x30
32305248:	e2811040 	add	r1, r1, #64	@ 0x40
3230524c:	ed8c1b0e 	vstr	d1, [ip, #56]	@ 0x38
32305250:	e28cc040 	add	ip, ip, #64	@ 0x40
32305254:	aaffffeb 	bge	32305208 <memcpy+0xc8>
32305258:	e31a003f 	tst	sl, #63	@ 0x3f
3230525c:	0a00001a 	beq	323052cc <memcpy+0x18c>
32305260:	e20a3038 	and	r3, sl, #56	@ 0x38
32305264:	e08cc003 	add	ip, ip, r3
32305268:	e0811003 	add	r1, r1, r3
3230526c:	e2633034 	rsb	r3, r3, #52	@ 0x34
32305270:	e08ff003 	add	pc, pc, r3
32305274:	ed110b0e 	vldr	d0, [r1, #-56]	@ 0xffffffc8
32305278:	ed0c0b0e 	vstr	d0, [ip, #-56]	@ 0xffffffc8
3230527c:	ed110b0c 	vldr	d0, [r1, #-48]	@ 0xffffffd0
32305280:	ed0c0b0c 	vstr	d0, [ip, #-48]	@ 0xffffffd0
32305284:	ed110b0a 	vldr	d0, [r1, #-40]	@ 0xffffffd8
32305288:	ed0c0b0a 	vstr	d0, [ip, #-40]	@ 0xffffffd8
3230528c:	ed110b08 	vldr	d0, [r1, #-32]	@ 0xffffffe0
32305290:	ed0c0b08 	vstr	d0, [ip, #-32]	@ 0xffffffe0
32305294:	ed110b06 	vldr	d0, [r1, #-24]	@ 0xffffffe8
32305298:	ed0c0b06 	vstr	d0, [ip, #-24]	@ 0xffffffe8
3230529c:	ed110b04 	vldr	d0, [r1, #-16]
323052a0:	ed0c0b04 	vstr	d0, [ip, #-16]
323052a4:	ed110b02 	vldr	d0, [r1, #-8]
323052a8:	ed0c0b02 	vstr	d0, [ip, #-8]
323052ac:	e31a0004 	tst	sl, #4
323052b0:	14913004 	ldrne	r3, [r1], #4
323052b4:	148c3004 	strne	r3, [ip], #4
323052b8:	e1b0af8a 	lsls	sl, sl, #31
323052bc:	20d130b2 	ldrhcs	r3, [r1], #2
323052c0:	15d1a000 	ldrbne	sl, [r1]
323052c4:	20cc30b2 	strhcs	r3, [ip], #2
323052c8:	15cca000 	strbne	sl, [ip]
323052cc:	e49da004 	pop	{sl}		@ (ldr sl, [sp], #4)
323052d0:	e12fff1e 	bx	lr
323052d4:	ed913b00 	vldr	d3, [r1]
323052d8:	ed914b10 	vldr	d4, [r1, #64]	@ 0x40
323052dc:	ed915b20 	vldr	d5, [r1, #128]	@ 0x80
323052e0:	ed916b30 	vldr	d6, [r1, #192]	@ 0xc0
323052e4:	ed917b40 	vldr	d7, [r1, #256]	@ 0x100
323052e8:	ed910b02 	vldr	d0, [r1, #8]
323052ec:	ed911b04 	vldr	d1, [r1, #16]
323052f0:	ed912b06 	vldr	d2, [r1, #24]
323052f4:	e2811020 	add	r1, r1, #32
323052f8:	e25aad0a 	subs	sl, sl, #640	@ 0x280
323052fc:	ba000055 	blt	32305458 <memcpy+0x318>
32305300:	ed8c3b00 	vstr	d3, [ip]
32305304:	ed913b00 	vldr	d3, [r1]
32305308:	ed8c0b02 	vstr	d0, [ip, #8]
3230530c:	ed910b02 	vldr	d0, [r1, #8]
32305310:	ed8c1b04 	vstr	d1, [ip, #16]
32305314:	ed911b04 	vldr	d1, [r1, #16]
32305318:	ed8c2b06 	vstr	d2, [ip, #24]
3230531c:	ed912b06 	vldr	d2, [r1, #24]
32305320:	ed8c3b08 	vstr	d3, [ip, #32]
32305324:	ed913b48 	vldr	d3, [r1, #288]	@ 0x120
32305328:	ed8c0b0a 	vstr	d0, [ip, #40]	@ 0x28
3230532c:	ed910b0a 	vldr	d0, [r1, #40]	@ 0x28
32305330:	ed8c1b0c 	vstr	d1, [ip, #48]	@ 0x30
32305334:	ed911b0c 	vldr	d1, [r1, #48]	@ 0x30
32305338:	ed8c2b0e 	vstr	d2, [ip, #56]	@ 0x38
3230533c:	ed912b0e 	vldr	d2, [r1, #56]	@ 0x38
32305340:	ed8c4b10 	vstr	d4, [ip, #64]	@ 0x40
32305344:	ed914b10 	vldr	d4, [r1, #64]	@ 0x40
32305348:	ed8c0b12 	vstr	d0, [ip, #72]	@ 0x48
3230534c:	ed910b12 	vldr	d0, [r1, #72]	@ 0x48
32305350:	ed8c1b14 	vstr	d1, [ip, #80]	@ 0x50
32305354:	ed911b14 	vldr	d1, [r1, #80]	@ 0x50
32305358:	ed8c2b16 	vstr	d2, [ip, #88]	@ 0x58
3230535c:	ed912b16 	vldr	d2, [r1, #88]	@ 0x58
32305360:	ed8c4b18 	vstr	d4, [ip, #96]	@ 0x60
32305364:	ed914b58 	vldr	d4, [r1, #352]	@ 0x160
32305368:	ed8c0b1a 	vstr	d0, [ip, #104]	@ 0x68
3230536c:	ed910b1a 	vldr	d0, [r1, #104]	@ 0x68
32305370:	ed8c1b1c 	vstr	d1, [ip, #112]	@ 0x70
32305374:	ed911b1c 	vldr	d1, [r1, #112]	@ 0x70
32305378:	ed8c2b1e 	vstr	d2, [ip, #120]	@ 0x78
3230537c:	ed912b1e 	vldr	d2, [r1, #120]	@ 0x78
32305380:	ed8c5b20 	vstr	d5, [ip, #128]	@ 0x80
32305384:	ed915b20 	vldr	d5, [r1, #128]	@ 0x80
32305388:	ed8c0b22 	vstr	d0, [ip, #136]	@ 0x88
3230538c:	ed910b22 	vldr	d0, [r1, #136]	@ 0x88
32305390:	ed8c1b24 	vstr	d1, [ip, #144]	@ 0x90
32305394:	ed911b24 	vldr	d1, [r1, #144]	@ 0x90
32305398:	ed8c2b26 	vstr	d2, [ip, #152]	@ 0x98
3230539c:	ed912b26 	vldr	d2, [r1, #152]	@ 0x98
323053a0:	ed8c5b28 	vstr	d5, [ip, #160]	@ 0xa0
323053a4:	ed915b68 	vldr	d5, [r1, #416]	@ 0x1a0
323053a8:	ed8c0b2a 	vstr	d0, [ip, #168]	@ 0xa8
323053ac:	ed910b2a 	vldr	d0, [r1, #168]	@ 0xa8
323053b0:	ed8c1b2c 	vstr	d1, [ip, #176]	@ 0xb0
323053b4:	ed911b2c 	vldr	d1, [r1, #176]	@ 0xb0
323053b8:	ed8c2b2e 	vstr	d2, [ip, #184]	@ 0xb8
323053bc:	ed912b2e 	vldr	d2, [r1, #184]	@ 0xb8
323053c0:	e28cc0c0 	add	ip, ip, #192	@ 0xc0
323053c4:	e28110c0 	add	r1, r1, #192	@ 0xc0
323053c8:	ed8c6b00 	vstr	d6, [ip]
323053cc:	ed916b00 	vldr	d6, [r1]
323053d0:	ed8c0b02 	vstr	d0, [ip, #8]
323053d4:	ed910b02 	vldr	d0, [r1, #8]
323053d8:	ed8c1b04 	vstr	d1, [ip, #16]
323053dc:	ed911b04 	vldr	d1, [r1, #16]
323053e0:	ed8c2b06 	vstr	d2, [ip, #24]
323053e4:	ed912b06 	vldr	d2, [r1, #24]
323053e8:	ed8c6b08 	vstr	d6, [ip, #32]
323053ec:	ed916b48 	vldr	d6, [r1, #288]	@ 0x120
323053f0:	ed8c0b0a 	vstr	d0, [ip, #40]	@ 0x28
323053f4:	ed910b0a 	vldr	d0, [r1, #40]	@ 0x28
323053f8:	ed8c1b0c 	vstr	d1, [ip, #48]	@ 0x30
323053fc:	ed911b0c 	vldr	d1, [r1, #48]	@ 0x30
32305400:	ed8c2b0e 	vstr	d2, [ip, #56]	@ 0x38
32305404:	ed912b0e 	vldr	d2, [r1, #56]	@ 0x38
32305408:	ed8c7b10 	vstr	d7, [ip, #64]	@ 0x40
3230540c:	ed917b10 	vldr	d7, [r1, #64]	@ 0x40
32305410:	ed8c0b12 	vstr	d0, [ip, #72]	@ 0x48
32305414:	ed910b12 	vldr	d0, [r1, #72]	@ 0x48
32305418:	ed8c1b14 	vstr	d1, [ip, #80]	@ 0x50
3230541c:	ed911b14 	vldr	d1, [r1, #80]	@ 0x50
32305420:	ed8c2b16 	vstr	d2, [ip, #88]	@ 0x58
32305424:	ed912b16 	vldr	d2, [r1, #88]	@ 0x58
32305428:	ed8c7b18 	vstr	d7, [ip, #96]	@ 0x60
3230542c:	ed917b58 	vldr	d7, [r1, #352]	@ 0x160
32305430:	ed8c0b1a 	vstr	d0, [ip, #104]	@ 0x68
32305434:	ed910b1a 	vldr	d0, [r1, #104]	@ 0x68
32305438:	ed8c1b1c 	vstr	d1, [ip, #112]	@ 0x70
3230543c:	ed911b1c 	vldr	d1, [r1, #112]	@ 0x70
32305440:	ed8c2b1e 	vstr	d2, [ip, #120]	@ 0x78
32305444:	ed912b1e 	vldr	d2, [r1, #120]	@ 0x78
32305448:	e28cc080 	add	ip, ip, #128	@ 0x80
3230544c:	e2811080 	add	r1, r1, #128	@ 0x80
32305450:	e25aad05 	subs	sl, sl, #320	@ 0x140
32305454:	aaffffa9 	bge	32305300 <memcpy+0x1c0>
32305458:	ed8c3b00 	vstr	d3, [ip]
3230545c:	ed913b00 	vldr	d3, [r1]
32305460:	ed8c0b02 	vstr	d0, [ip, #8]
32305464:	ed910b02 	vldr	d0, [r1, #8]
32305468:	ed8c1b04 	vstr	d1, [ip, #16]
3230546c:	ed911b04 	vldr	d1, [r1, #16]
32305470:	ed8c2b06 	vstr	d2, [ip, #24]
32305474:	ed912b06 	vldr	d2, [r1, #24]
32305478:	ed8c3b08 	vstr	d3, [ip, #32]
3230547c:	ed8c0b0a 	vstr	d0, [ip, #40]	@ 0x28
32305480:	ed910b0a 	vldr	d0, [r1, #40]	@ 0x28
32305484:	ed8c1b0c 	vstr	d1, [ip, #48]	@ 0x30
32305488:	ed911b0c 	vldr	d1, [r1, #48]	@ 0x30
3230548c:	ed8c2b0e 	vstr	d2, [ip, #56]	@ 0x38
32305490:	ed912b0e 	vldr	d2, [r1, #56]	@ 0x38
32305494:	ed8c4b10 	vstr	d4, [ip, #64]	@ 0x40
32305498:	ed914b10 	vldr	d4, [r1, #64]	@ 0x40
3230549c:	ed8c0b12 	vstr	d0, [ip, #72]	@ 0x48
323054a0:	ed910b12 	vldr	d0, [r1, #72]	@ 0x48
323054a4:	ed8c1b14 	vstr	d1, [ip, #80]	@ 0x50
323054a8:	ed911b14 	vldr	d1, [r1, #80]	@ 0x50
323054ac:	ed8c2b16 	vstr	d2, [ip, #88]	@ 0x58
323054b0:	ed912b16 	vldr	d2, [r1, #88]	@ 0x58
323054b4:	ed8c4b18 	vstr	d4, [ip, #96]	@ 0x60
323054b8:	ed8c0b1a 	vstr	d0, [ip, #104]	@ 0x68
323054bc:	ed910b1a 	vldr	d0, [r1, #104]	@ 0x68
323054c0:	ed8c1b1c 	vstr	d1, [ip, #112]	@ 0x70
323054c4:	ed911b1c 	vldr	d1, [r1, #112]	@ 0x70
323054c8:	ed8c2b1e 	vstr	d2, [ip, #120]	@ 0x78
323054cc:	ed912b1e 	vldr	d2, [r1, #120]	@ 0x78
323054d0:	ed8c5b20 	vstr	d5, [ip, #128]	@ 0x80
323054d4:	ed915b20 	vldr	d5, [r1, #128]	@ 0x80
323054d8:	ed8c0b22 	vstr	d0, [ip, #136]	@ 0x88
323054dc:	ed910b22 	vldr	d0, [r1, #136]	@ 0x88
323054e0:	ed8c1b24 	vstr	d1, [ip, #144]	@ 0x90
323054e4:	ed911b24 	vldr	d1, [r1, #144]	@ 0x90
323054e8:	ed8c2b26 	vstr	d2, [ip, #152]	@ 0x98
323054ec:	ed912b26 	vldr	d2, [r1, #152]	@ 0x98
323054f0:	ed8c5b28 	vstr	d5, [ip, #160]	@ 0xa0
323054f4:	ed8c0b2a 	vstr	d0, [ip, #168]	@ 0xa8
323054f8:	ed910b2a 	vldr	d0, [r1, #168]	@ 0xa8
323054fc:	ed8c1b2c 	vstr	d1, [ip, #176]	@ 0xb0
32305500:	ed911b2c 	vldr	d1, [r1, #176]	@ 0xb0
32305504:	ed8c2b2e 	vstr	d2, [ip, #184]	@ 0xb8
32305508:	ed912b2e 	vldr	d2, [r1, #184]	@ 0xb8
3230550c:	e28110c0 	add	r1, r1, #192	@ 0xc0
32305510:	e28cc0c0 	add	ip, ip, #192	@ 0xc0
32305514:	ed8c6b00 	vstr	d6, [ip]
32305518:	ed916b00 	vldr	d6, [r1]
3230551c:	ed8c0b02 	vstr	d0, [ip, #8]
32305520:	ed910b02 	vldr	d0, [r1, #8]
32305524:	ed8c1b04 	vstr	d1, [ip, #16]
32305528:	ed911b04 	vldr	d1, [r1, #16]
3230552c:	ed8c2b06 	vstr	d2, [ip, #24]
32305530:	ed912b06 	vldr	d2, [r1, #24]
32305534:	ed8c6b08 	vstr	d6, [ip, #32]
32305538:	ed8c0b0a 	vstr	d0, [ip, #40]	@ 0x28
3230553c:	ed910b0a 	vldr	d0, [r1, #40]	@ 0x28
32305540:	ed8c1b0c 	vstr	d1, [ip, #48]	@ 0x30
32305544:	ed911b0c 	vldr	d1, [r1, #48]	@ 0x30
32305548:	ed8c2b0e 	vstr	d2, [ip, #56]	@ 0x38
3230554c:	ed912b0e 	vldr	d2, [r1, #56]	@ 0x38
32305550:	ed8c7b10 	vstr	d7, [ip, #64]	@ 0x40
32305554:	ed917b10 	vldr	d7, [r1, #64]	@ 0x40
32305558:	ed8c0b12 	vstr	d0, [ip, #72]	@ 0x48
3230555c:	ed910b12 	vldr	d0, [r1, #72]	@ 0x48
32305560:	ed8c1b14 	vstr	d1, [ip, #80]	@ 0x50
32305564:	ed911b14 	vldr	d1, [r1, #80]	@ 0x50
32305568:	ed8c2b16 	vstr	d2, [ip, #88]	@ 0x58
3230556c:	ed912b16 	vldr	d2, [r1, #88]	@ 0x58
32305570:	ed8c7b18 	vstr	d7, [ip, #96]	@ 0x60
32305574:	e2811060 	add	r1, r1, #96	@ 0x60
32305578:	ed8c0b1a 	vstr	d0, [ip, #104]	@ 0x68
3230557c:	ed8c1b1c 	vstr	d1, [ip, #112]	@ 0x70
32305580:	ed8c2b1e 	vstr	d2, [ip, #120]	@ 0x78
32305584:	e28cc080 	add	ip, ip, #128	@ 0x80
32305588:	e28aad05 	add	sl, sl, #320	@ 0x140
3230558c:	eaffff1d 	b	32305208 <memcpy+0xc8>
32305590:	f5d1f000 	pld	[r1]
32305594:	f5d1f040 	pld	[r1, #64]	@ 0x40
32305598:	e1b0ae8c 	lsls	sl, ip, #29
3230559c:	f5d1f080 	pld	[r1, #128]	@ 0x80
323055a0:	0a000008 	beq	323055c8 <memcpy+0x488>
323055a4:	e27aa000 	rsbs	sl, sl, #0
323055a8:	e0422eaa 	sub	r2, r2, sl, lsr #29
323055ac:	44913004 	ldrmi	r3, [r1], #4
323055b0:	448c3004 	strmi	r3, [ip], #4
323055b4:	e1b0a10a 	lsls	sl, sl, #2
323055b8:	14d13001 	ldrbne	r3, [r1], #1
323055bc:	20d1a0b2 	ldrhcs	sl, [r1], #2
323055c0:	14cc3001 	strbne	r3, [ip], #1
323055c4:	20cca0b2 	strhcs	sl, [ip], #2
323055c8:	f5d1f0c0 	pld	[r1, #192]	@ 0xc0
323055cc:	e2522040 	subs	r2, r2, #64	@ 0x40
323055d0:	449da004 	popmi	{sl}		@ (ldrmi sl, [sp], #4)
323055d4:	4afffedc 	bmi	3230514c <memcpy+0xc>
323055d8:	f5d1f100 	pld	[r1, #256]	@ 0x100
323055dc:	f421020d 	vld1.8	{d0-d3}, [r1]!
323055e0:	f421420d 	vld1.8	{d4-d7}, [r1]!
323055e4:	e2522040 	subs	r2, r2, #64	@ 0x40
323055e8:	4a000006 	bmi	32305608 <memcpy+0x4c8>
323055ec:	f5d1f100 	pld	[r1, #256]	@ 0x100
323055f0:	f40c021d 	vst1.8	{d0-d3}, [ip :64]!
323055f4:	f421020d 	vld1.8	{d0-d3}, [r1]!
323055f8:	f40c421d 	vst1.8	{d4-d7}, [ip :64]!
323055fc:	f421420d 	vld1.8	{d4-d7}, [r1]!
32305600:	e2522040 	subs	r2, r2, #64	@ 0x40
32305604:	5afffff8 	bpl	323055ec <memcpy+0x4ac>
32305608:	f40c021d 	vst1.8	{d0-d3}, [ip :64]!
3230560c:	f40c421d 	vst1.8	{d4-d7}, [ip :64]!
32305610:	e212203f 	ands	r2, r2, #63	@ 0x3f
32305614:	e49da004 	pop	{sl}		@ (ldr sl, [sp], #4)
32305618:	1afffecb 	bne	3230514c <memcpy+0xc>
3230561c:	e12fff1e 	bx	lr
	...

32305640 <strlen>:
32305640:	b430      	push	{r4, r5}
32305642:	f890 f000 	pld	[r0]
32305646:	f020 0107 	bic.w	r1, r0, #7
3230564a:	f06f 0c00 	mvn.w	ip, #0
3230564e:	f010 0407 	ands.w	r4, r0, #7
32305652:	f891 f020 	pld	[r1, #32]
32305656:	f040 8048 	bne.w	323056ea <strlen+0xaa>
3230565a:	f04f 0400 	mov.w	r4, #0
3230565e:	f06f 0007 	mvn.w	r0, #7
32305662:	e9d1 2300 	ldrd	r2, r3, [r1]
32305666:	f891 f040 	pld	[r1, #64]	@ 0x40
3230566a:	f100 0008 	add.w	r0, r0, #8
3230566e:	fa82 f24c 	uadd8	r2, r2, ip
32305672:	faa4 f28c 	sel	r2, r4, ip
32305676:	fa83 f34c 	uadd8	r3, r3, ip
3230567a:	faa2 f38c 	sel	r3, r2, ip
3230567e:	bb4b      	cbnz	r3, 323056d4 <strlen+0x94>
32305680:	e9d1 2302 	ldrd	r2, r3, [r1, #8]
32305684:	fa82 f24c 	uadd8	r2, r2, ip
32305688:	f100 0008 	add.w	r0, r0, #8
3230568c:	faa4 f28c 	sel	r2, r4, ip
32305690:	fa83 f34c 	uadd8	r3, r3, ip
32305694:	faa2 f38c 	sel	r3, r2, ip
32305698:	b9e3      	cbnz	r3, 323056d4 <strlen+0x94>
3230569a:	e9d1 2304 	ldrd	r2, r3, [r1, #16]
3230569e:	fa82 f24c 	uadd8	r2, r2, ip
323056a2:	f100 0008 	add.w	r0, r0, #8
323056a6:	faa4 f28c 	sel	r2, r4, ip
323056aa:	fa83 f34c 	uadd8	r3, r3, ip
323056ae:	faa2 f38c 	sel	r3, r2, ip
323056b2:	b97b      	cbnz	r3, 323056d4 <strlen+0x94>
323056b4:	e9d1 2306 	ldrd	r2, r3, [r1, #24]
323056b8:	f101 0120 	add.w	r1, r1, #32
323056bc:	fa82 f24c 	uadd8	r2, r2, ip
323056c0:	f100 0008 	add.w	r0, r0, #8
323056c4:	faa4 f28c 	sel	r2, r4, ip
323056c8:	fa83 f34c 	uadd8	r3, r3, ip
323056cc:	faa2 f38c 	sel	r3, r2, ip
323056d0:	2b00      	cmp	r3, #0
323056d2:	d0c6      	beq.n	32305662 <strlen+0x22>
323056d4:	2a00      	cmp	r2, #0
323056d6:	bf04      	itt	eq
323056d8:	3004      	addeq	r0, #4
323056da:	461a      	moveq	r2, r3
323056dc:	ba12      	rev	r2, r2
323056de:	fab2 f282 	clz	r2, r2
323056e2:	eb00 00d2 	add.w	r0, r0, r2, lsr #3
323056e6:	bc30      	pop	{r4, r5}
323056e8:	4770      	bx	lr
323056ea:	e9d1 2300 	ldrd	r2, r3, [r1]
323056ee:	f004 0503 	and.w	r5, r4, #3
323056f2:	f1c4 0000 	rsb	r0, r4, #0
323056f6:	ea4f 05c5 	mov.w	r5, r5, lsl #3
323056fa:	f014 0f04 	tst.w	r4, #4
323056fe:	f891 f040 	pld	[r1, #64]	@ 0x40
32305702:	fa0c f505 	lsl.w	r5, ip, r5
32305706:	ea62 0205 	orn	r2, r2, r5
3230570a:	bf1c      	itt	ne
3230570c:	ea63 0305 	ornne	r3, r3, r5
32305710:	4662      	movne	r2, ip
32305712:	f04f 0400 	mov.w	r4, #0
32305716:	e7aa      	b.n	3230566e <strlen+0x2e>

32305718 <abort>:
32305718:	2006      	movs	r0, #6
3230571a:	b508      	push	{r3, lr}
3230571c:	f004 f812 	bl	32309744 <raise>
32305720:	2001      	movs	r0, #1
32305722:	f7fa ee2e 	blx	32300380 <_exit>
32305726:	bf00      	nop

32305728 <_malloc_trim_r>:
32305728:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
3230572c:	f24c 38f0 	movw	r8, #50160	@ 0xc3f0
32305730:	f2c3 2830 	movt	r8, #12848	@ 0x3230
32305734:	4606      	mov	r6, r0
32305736:	2008      	movs	r0, #8
32305738:	4689      	mov	r9, r1
3230573a:	f004 f901 	bl	32309940 <sysconf>
3230573e:	4605      	mov	r5, r0
32305740:	4630      	mov	r0, r6
32305742:	f000 fef3 	bl	3230652c <__malloc_lock>
32305746:	f8d8 3008 	ldr.w	r3, [r8, #8]
3230574a:	685f      	ldr	r7, [r3, #4]
3230574c:	f027 0703 	bic.w	r7, r7, #3
32305750:	f1a7 0411 	sub.w	r4, r7, #17
32305754:	eba4 0409 	sub.w	r4, r4, r9
32305758:	442c      	add	r4, r5
3230575a:	fbb4 f4f5 	udiv	r4, r4, r5
3230575e:	3c01      	subs	r4, #1
32305760:	fb05 f404 	mul.w	r4, r5, r4
32305764:	42a5      	cmp	r5, r4
32305766:	dc08      	bgt.n	3230577a <_malloc_trim_r+0x52>
32305768:	2100      	movs	r1, #0
3230576a:	4630      	mov	r0, r6
3230576c:	f004 f8d4 	bl	32309918 <_sbrk_r>
32305770:	f8d8 3008 	ldr.w	r3, [r8, #8]
32305774:	443b      	add	r3, r7
32305776:	4298      	cmp	r0, r3
32305778:	d005      	beq.n	32305786 <_malloc_trim_r+0x5e>
3230577a:	4630      	mov	r0, r6
3230577c:	f000 fedc 	bl	32306538 <__malloc_unlock>
32305780:	2000      	movs	r0, #0
32305782:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
32305786:	4261      	negs	r1, r4
32305788:	4630      	mov	r0, r6
3230578a:	f004 f8c5 	bl	32309918 <_sbrk_r>
3230578e:	3001      	adds	r0, #1
32305790:	d012      	beq.n	323057b8 <_malloc_trim_r+0x90>
32305792:	f8d8 2008 	ldr.w	r2, [r8, #8]
32305796:	f245 3360 	movw	r3, #21344	@ 0x5360
3230579a:	f2c3 2331 	movt	r3, #12849	@ 0x3231
3230579e:	1b3f      	subs	r7, r7, r4
323057a0:	f047 0701 	orr.w	r7, r7, #1
323057a4:	4630      	mov	r0, r6
323057a6:	6057      	str	r7, [r2, #4]
323057a8:	681a      	ldr	r2, [r3, #0]
323057aa:	1b12      	subs	r2, r2, r4
323057ac:	601a      	str	r2, [r3, #0]
323057ae:	f000 fec3 	bl	32306538 <__malloc_unlock>
323057b2:	2001      	movs	r0, #1
323057b4:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
323057b8:	2100      	movs	r1, #0
323057ba:	4630      	mov	r0, r6
323057bc:	f004 f8ac 	bl	32309918 <_sbrk_r>
323057c0:	f8d8 2008 	ldr.w	r2, [r8, #8]
323057c4:	1a83      	subs	r3, r0, r2
323057c6:	2b0f      	cmp	r3, #15
323057c8:	ddd7      	ble.n	3230577a <_malloc_trim_r+0x52>
323057ca:	f043 0301 	orr.w	r3, r3, #1
323057ce:	6053      	str	r3, [r2, #4]
323057d0:	f24c 33e8 	movw	r3, #50152	@ 0xc3e8
323057d4:	f2c3 2330 	movt	r3, #12848	@ 0x3230
323057d8:	f245 3160 	movw	r1, #21344	@ 0x5360
323057dc:	f2c3 2131 	movt	r1, #12849	@ 0x3231
323057e0:	681b      	ldr	r3, [r3, #0]
323057e2:	1ac0      	subs	r0, r0, r3
323057e4:	6008      	str	r0, [r1, #0]
323057e6:	e7c8      	b.n	3230577a <_malloc_trim_r+0x52>

323057e8 <_free_r>:
323057e8:	2900      	cmp	r1, #0
323057ea:	d067      	beq.n	323058bc <_free_r+0xd4>
323057ec:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
323057ee:	460c      	mov	r4, r1
323057f0:	4606      	mov	r6, r0
323057f2:	f000 fe9b 	bl	3230652c <__malloc_lock>
323057f6:	f1a4 0208 	sub.w	r2, r4, #8
323057fa:	f854 7c04 	ldr.w	r7, [r4, #-4]
323057fe:	f24c 31f0 	movw	r1, #50160	@ 0xc3f0
32305802:	f2c3 2130 	movt	r1, #12848	@ 0x3230
32305806:	f027 0301 	bic.w	r3, r7, #1
3230580a:	f007 0e01 	and.w	lr, r7, #1
3230580e:	eb02 0c03 	add.w	ip, r2, r3
32305812:	6888      	ldr	r0, [r1, #8]
32305814:	f8dc 5004 	ldr.w	r5, [ip, #4]
32305818:	4560      	cmp	r0, ip
3230581a:	f025 0503 	bic.w	r5, r5, #3
3230581e:	f000 8084 	beq.w	3230592a <_free_r+0x142>
32305822:	eb0c 0005 	add.w	r0, ip, r5
32305826:	f8cc 5004 	str.w	r5, [ip, #4]
3230582a:	6840      	ldr	r0, [r0, #4]
3230582c:	f000 0001 	and.w	r0, r0, #1
32305830:	f1be 0f00 	cmp.w	lr, #0
32305834:	d131      	bne.n	3230589a <_free_r+0xb2>
32305836:	f854 4c08 	ldr.w	r4, [r4, #-8]
3230583a:	1b12      	subs	r2, r2, r4
3230583c:	4423      	add	r3, r4
3230583e:	f101 0408 	add.w	r4, r1, #8
32305842:	6897      	ldr	r7, [r2, #8]
32305844:	42a7      	cmp	r7, r4
32305846:	d064      	beq.n	32305912 <_free_r+0x12a>
32305848:	f8d2 e00c 	ldr.w	lr, [r2, #12]
3230584c:	f8c7 e00c 	str.w	lr, [r7, #12]
32305850:	f8ce 7008 	str.w	r7, [lr, #8]
32305854:	2800      	cmp	r0, #0
32305856:	f000 8088 	beq.w	3230596a <_free_r+0x182>
3230585a:	f043 0001 	orr.w	r0, r3, #1
3230585e:	6050      	str	r0, [r2, #4]
32305860:	f8cc 3000 	str.w	r3, [ip]
32305864:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
32305868:	d231      	bcs.n	323058ce <_free_r+0xe6>
3230586a:	08d8      	lsrs	r0, r3, #3
3230586c:	095c      	lsrs	r4, r3, #5
3230586e:	3001      	adds	r0, #1
32305870:	2301      	movs	r3, #1
32305872:	b200      	sxth	r0, r0
32305874:	40a3      	lsls	r3, r4
32305876:	684c      	ldr	r4, [r1, #4]
32305878:	4323      	orrs	r3, r4
3230587a:	f851 4030 	ldr.w	r4, [r1, r0, lsl #3]
3230587e:	604b      	str	r3, [r1, #4]
32305880:	eb01 03c0 	add.w	r3, r1, r0, lsl #3
32305884:	6094      	str	r4, [r2, #8]
32305886:	3b08      	subs	r3, #8
32305888:	60d3      	str	r3, [r2, #12]
3230588a:	f841 2030 	str.w	r2, [r1, r0, lsl #3]
3230588e:	60e2      	str	r2, [r4, #12]
32305890:	4630      	mov	r0, r6
32305892:	e8bd 40f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, lr}
32305896:	f000 be4f 	b.w	32306538 <__malloc_unlock>
3230589a:	b980      	cbnz	r0, 323058be <_free_r+0xd6>
3230589c:	442b      	add	r3, r5
3230589e:	f101 0408 	add.w	r4, r1, #8
323058a2:	f8dc 0008 	ldr.w	r0, [ip, #8]
323058a6:	f043 0501 	orr.w	r5, r3, #1
323058aa:	42a0      	cmp	r0, r4
323058ac:	d076      	beq.n	3230599c <_free_r+0x1b4>
323058ae:	f8dc 400c 	ldr.w	r4, [ip, #12]
323058b2:	60c4      	str	r4, [r0, #12]
323058b4:	60a0      	str	r0, [r4, #8]
323058b6:	6055      	str	r5, [r2, #4]
323058b8:	50d3      	str	r3, [r2, r3]
323058ba:	e7d3      	b.n	32305864 <_free_r+0x7c>
323058bc:	4770      	bx	lr
323058be:	f047 0701 	orr.w	r7, r7, #1
323058c2:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
323058c6:	f844 7c04 	str.w	r7, [r4, #-4]
323058ca:	50d3      	str	r3, [r2, r3]
323058cc:	d3cd      	bcc.n	3230586a <_free_r+0x82>
323058ce:	0a5d      	lsrs	r5, r3, #9
323058d0:	f5b3 6f20 	cmp.w	r3, #2560	@ 0xa00
323058d4:	d24b      	bcs.n	3230596e <_free_r+0x186>
323058d6:	099d      	lsrs	r5, r3, #6
323058d8:	f105 0439 	add.w	r4, r5, #57	@ 0x39
323058dc:	3538      	adds	r5, #56	@ 0x38
323058de:	b224      	sxth	r4, r4
323058e0:	00e4      	lsls	r4, r4, #3
323058e2:	1908      	adds	r0, r1, r4
323058e4:	590c      	ldr	r4, [r1, r4]
323058e6:	3808      	subs	r0, #8
323058e8:	42a0      	cmp	r0, r4
323058ea:	d103      	bne.n	323058f4 <_free_r+0x10c>
323058ec:	e064      	b.n	323059b8 <_free_r+0x1d0>
323058ee:	68a4      	ldr	r4, [r4, #8]
323058f0:	42a0      	cmp	r0, r4
323058f2:	d004      	beq.n	323058fe <_free_r+0x116>
323058f4:	6861      	ldr	r1, [r4, #4]
323058f6:	f021 0103 	bic.w	r1, r1, #3
323058fa:	4299      	cmp	r1, r3
323058fc:	d8f7      	bhi.n	323058ee <_free_r+0x106>
323058fe:	68e0      	ldr	r0, [r4, #12]
32305900:	e9c2 4002 	strd	r4, r0, [r2, #8]
32305904:	6082      	str	r2, [r0, #8]
32305906:	4630      	mov	r0, r6
32305908:	60e2      	str	r2, [r4, #12]
3230590a:	e8bd 40f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, lr}
3230590e:	f000 be13 	b.w	32306538 <__malloc_unlock>
32305912:	2800      	cmp	r0, #0
32305914:	d136      	bne.n	32305984 <_free_r+0x19c>
32305916:	441d      	add	r5, r3
32305918:	e9dc 1302 	ldrd	r1, r3, [ip, #8]
3230591c:	60cb      	str	r3, [r1, #12]
3230591e:	6099      	str	r1, [r3, #8]
32305920:	f045 0301 	orr.w	r3, r5, #1
32305924:	6053      	str	r3, [r2, #4]
32305926:	5155      	str	r5, [r2, r5]
32305928:	e7b2      	b.n	32305890 <_free_r+0xa8>
3230592a:	441d      	add	r5, r3
3230592c:	f1be 0f00 	cmp.w	lr, #0
32305930:	d107      	bne.n	32305942 <_free_r+0x15a>
32305932:	f854 3c08 	ldr.w	r3, [r4, #-8]
32305936:	1ad2      	subs	r2, r2, r3
32305938:	441d      	add	r5, r3
3230593a:	e9d2 0302 	ldrd	r0, r3, [r2, #8]
3230593e:	60c3      	str	r3, [r0, #12]
32305940:	6098      	str	r0, [r3, #8]
32305942:	f045 0301 	orr.w	r3, r5, #1
32305946:	6053      	str	r3, [r2, #4]
32305948:	f24c 33ec 	movw	r3, #50156	@ 0xc3ec
3230594c:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32305950:	608a      	str	r2, [r1, #8]
32305952:	681b      	ldr	r3, [r3, #0]
32305954:	42ab      	cmp	r3, r5
32305956:	d89b      	bhi.n	32305890 <_free_r+0xa8>
32305958:	f245 3390 	movw	r3, #21392	@ 0x5390
3230595c:	f2c3 2331 	movt	r3, #12849	@ 0x3231
32305960:	4630      	mov	r0, r6
32305962:	6819      	ldr	r1, [r3, #0]
32305964:	f7ff fee0 	bl	32305728 <_malloc_trim_r>
32305968:	e792      	b.n	32305890 <_free_r+0xa8>
3230596a:	442b      	add	r3, r5
3230596c:	e799      	b.n	323058a2 <_free_r+0xba>
3230596e:	2d14      	cmp	r5, #20
32305970:	d90e      	bls.n	32305990 <_free_r+0x1a8>
32305972:	2d54      	cmp	r5, #84	@ 0x54
32305974:	d827      	bhi.n	323059c6 <_free_r+0x1de>
32305976:	0b1d      	lsrs	r5, r3, #12
32305978:	f105 046f 	add.w	r4, r5, #111	@ 0x6f
3230597c:	356e      	adds	r5, #110	@ 0x6e
3230597e:	b224      	sxth	r4, r4
32305980:	00e4      	lsls	r4, r4, #3
32305982:	e7ae      	b.n	323058e2 <_free_r+0xfa>
32305984:	f043 0101 	orr.w	r1, r3, #1
32305988:	6051      	str	r1, [r2, #4]
3230598a:	f8cc 3000 	str.w	r3, [ip]
3230598e:	e77f      	b.n	32305890 <_free_r+0xa8>
32305990:	f105 045c 	add.w	r4, r5, #92	@ 0x5c
32305994:	355b      	adds	r5, #91	@ 0x5b
32305996:	b224      	sxth	r4, r4
32305998:	00e4      	lsls	r4, r4, #3
3230599a:	e7a2      	b.n	323058e2 <_free_r+0xfa>
3230599c:	ee80 4b90 	vdup.32	d16, r4
323059a0:	ee81 2b90 	vdup.32	d17, r2
323059a4:	3408      	adds	r4, #8
323059a6:	f102 0108 	add.w	r1, r2, #8
323059aa:	f944 178f 	vst1.32	{d17}, [r4]
323059ae:	f941 078f 	vst1.32	{d16}, [r1]
323059b2:	6055      	str	r5, [r2, #4]
323059b4:	50d3      	str	r3, [r2, r3]
323059b6:	e76b      	b.n	32305890 <_free_r+0xa8>
323059b8:	10ad      	asrs	r5, r5, #2
323059ba:	2301      	movs	r3, #1
323059bc:	40ab      	lsls	r3, r5
323059be:	684d      	ldr	r5, [r1, #4]
323059c0:	432b      	orrs	r3, r5
323059c2:	604b      	str	r3, [r1, #4]
323059c4:	e79c      	b.n	32305900 <_free_r+0x118>
323059c6:	f5b5 7faa 	cmp.w	r5, #340	@ 0x154
323059ca:	d806      	bhi.n	323059da <_free_r+0x1f2>
323059cc:	0bdd      	lsrs	r5, r3, #15
323059ce:	f105 0478 	add.w	r4, r5, #120	@ 0x78
323059d2:	3577      	adds	r5, #119	@ 0x77
323059d4:	b224      	sxth	r4, r4
323059d6:	00e4      	lsls	r4, r4, #3
323059d8:	e783      	b.n	323058e2 <_free_r+0xfa>
323059da:	f240 5054 	movw	r0, #1364	@ 0x554
323059de:	4285      	cmp	r5, r0
323059e0:	d805      	bhi.n	323059ee <_free_r+0x206>
323059e2:	0c9d      	lsrs	r5, r3, #18
323059e4:	f105 047d 	add.w	r4, r5, #125	@ 0x7d
323059e8:	357c      	adds	r5, #124	@ 0x7c
323059ea:	00e4      	lsls	r4, r4, #3
323059ec:	e779      	b.n	323058e2 <_free_r+0xfa>
323059ee:	f44f 747e 	mov.w	r4, #1016	@ 0x3f8
323059f2:	257e      	movs	r5, #126	@ 0x7e
323059f4:	e775      	b.n	323058e2 <_free_r+0xfa>
323059f6:	bf00      	nop

323059f8 <_findenv_r>:
323059f8:	e92d 47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
323059fc:	f24c 78f8 	movw	r8, #51192	@ 0xc7f8
32305a00:	f2c3 2830 	movt	r8, #12848	@ 0x3230
32305a04:	4681      	mov	r9, r0
32305a06:	460e      	mov	r6, r1
32305a08:	4617      	mov	r7, r2
32305a0a:	f004 ff5b 	bl	3230a8c4 <__env_lock>
32305a0e:	f8d8 5000 	ldr.w	r5, [r8]
32305a12:	b1fd      	cbz	r5, 32305a54 <_findenv_r+0x5c>
32305a14:	7833      	ldrb	r3, [r6, #0]
32305a16:	4634      	mov	r4, r6
32305a18:	2b00      	cmp	r3, #0
32305a1a:	bf18      	it	ne
32305a1c:	2b3d      	cmpne	r3, #61	@ 0x3d
32305a1e:	d005      	beq.n	32305a2c <_findenv_r+0x34>
32305a20:	f814 3f01 	ldrb.w	r3, [r4, #1]!
32305a24:	2b00      	cmp	r3, #0
32305a26:	bf18      	it	ne
32305a28:	2b3d      	cmpne	r3, #61	@ 0x3d
32305a2a:	d1f9      	bne.n	32305a20 <_findenv_r+0x28>
32305a2c:	2b3d      	cmp	r3, #61	@ 0x3d
32305a2e:	d011      	beq.n	32305a54 <_findenv_r+0x5c>
32305a30:	6828      	ldr	r0, [r5, #0]
32305a32:	1ba4      	subs	r4, r4, r6
32305a34:	b170      	cbz	r0, 32305a54 <_findenv_r+0x5c>
32305a36:	4622      	mov	r2, r4
32305a38:	4631      	mov	r1, r6
32305a3a:	f003 fda9 	bl	32309590 <strncmp>
32305a3e:	b928      	cbnz	r0, 32305a4c <_findenv_r+0x54>
32305a40:	682b      	ldr	r3, [r5, #0]
32305a42:	eb03 0a04 	add.w	sl, r3, r4
32305a46:	5d1b      	ldrb	r3, [r3, r4]
32305a48:	2b3d      	cmp	r3, #61	@ 0x3d
32305a4a:	d009      	beq.n	32305a60 <_findenv_r+0x68>
32305a4c:	f855 0f04 	ldr.w	r0, [r5, #4]!
32305a50:	2800      	cmp	r0, #0
32305a52:	d1f0      	bne.n	32305a36 <_findenv_r+0x3e>
32305a54:	4648      	mov	r0, r9
32305a56:	f004 ff3b 	bl	3230a8d0 <__env_unlock>
32305a5a:	2000      	movs	r0, #0
32305a5c:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}
32305a60:	f8d8 3000 	ldr.w	r3, [r8]
32305a64:	4648      	mov	r0, r9
32305a66:	1aed      	subs	r5, r5, r3
32305a68:	10ad      	asrs	r5, r5, #2
32305a6a:	603d      	str	r5, [r7, #0]
32305a6c:	f004 ff30 	bl	3230a8d0 <__env_unlock>
32305a70:	f10a 0001 	add.w	r0, sl, #1
32305a74:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}

32305a78 <_getenv_r>:
32305a78:	b500      	push	{lr}
32305a7a:	b083      	sub	sp, #12
32305a7c:	aa01      	add	r2, sp, #4
32305a7e:	f7ff ffbb 	bl	323059f8 <_findenv_r>
32305a82:	b003      	add	sp, #12
32305a84:	f85d fb04 	ldr.w	pc, [sp], #4

32305a88 <_malloc_r>:
32305a88:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32305a8c:	f101 030b 	add.w	r3, r1, #11
32305a90:	4607      	mov	r7, r0
32305a92:	b083      	sub	sp, #12
32305a94:	2b16      	cmp	r3, #22
32305a96:	d826      	bhi.n	32305ae6 <_malloc_r+0x5e>
32305a98:	2910      	cmp	r1, #16
32305a9a:	f200 80bd 	bhi.w	32305c18 <_malloc_r+0x190>
32305a9e:	f000 fd45 	bl	3230652c <__malloc_lock>
32305aa2:	2510      	movs	r5, #16
32305aa4:	2318      	movs	r3, #24
32305aa6:	2002      	movs	r0, #2
32305aa8:	f24c 36f0 	movw	r6, #50160	@ 0xc3f0
32305aac:	f2c3 2630 	movt	r6, #12848	@ 0x3230
32305ab0:	4433      	add	r3, r6
32305ab2:	f1a3 0208 	sub.w	r2, r3, #8
32305ab6:	685c      	ldr	r4, [r3, #4]
32305ab8:	4294      	cmp	r4, r2
32305aba:	f000 817d 	beq.w	32305db8 <_malloc_r+0x330>
32305abe:	6863      	ldr	r3, [r4, #4]
32305ac0:	4638      	mov	r0, r7
32305ac2:	e9d4 1202 	ldrd	r1, r2, [r4, #8]
32305ac6:	f023 0303 	bic.w	r3, r3, #3
32305aca:	4423      	add	r3, r4
32305acc:	60ca      	str	r2, [r1, #12]
32305ace:	6091      	str	r1, [r2, #8]
32305ad0:	685a      	ldr	r2, [r3, #4]
32305ad2:	3408      	adds	r4, #8
32305ad4:	f042 0201 	orr.w	r2, r2, #1
32305ad8:	605a      	str	r2, [r3, #4]
32305ada:	f000 fd2d 	bl	32306538 <__malloc_unlock>
32305ade:	4620      	mov	r0, r4
32305ae0:	b003      	add	sp, #12
32305ae2:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32305ae6:	f023 0507 	bic.w	r5, r3, #7
32305aea:	42a9      	cmp	r1, r5
32305aec:	bf98      	it	ls
32305aee:	2100      	movls	r1, #0
32305af0:	bf88      	it	hi
32305af2:	2101      	movhi	r1, #1
32305af4:	ea51 71d3 	orrs.w	r1, r1, r3, lsr #31
32305af8:	f040 808e 	bne.w	32305c18 <_malloc_r+0x190>
32305afc:	f000 fd16 	bl	3230652c <__malloc_lock>
32305b00:	f5b5 7ffc 	cmp.w	r5, #504	@ 0x1f8
32305b04:	f0c0 82b1 	bcc.w	3230606a <_malloc_r+0x5e2>
32305b08:	ea5f 2e55 	movs.w	lr, r5, lsr #9
32305b0c:	f000 808b 	beq.w	32305c26 <_malloc_r+0x19e>
32305b10:	f1be 0f04 	cmp.w	lr, #4
32305b14:	f200 817c 	bhi.w	32305e10 <_malloc_r+0x388>
32305b18:	ea4f 1e95 	mov.w	lr, r5, lsr #6
32305b1c:	f10e 0039 	add.w	r0, lr, #57	@ 0x39
32305b20:	f10e 0e38 	add.w	lr, lr, #56	@ 0x38
32305b24:	b203      	sxth	r3, r0
32305b26:	00db      	lsls	r3, r3, #3
32305b28:	f24c 36f0 	movw	r6, #50160	@ 0xc3f0
32305b2c:	f2c3 2630 	movt	r6, #12848	@ 0x3230
32305b30:	4433      	add	r3, r6
32305b32:	f1a3 0c08 	sub.w	ip, r3, #8
32305b36:	685c      	ldr	r4, [r3, #4]
32305b38:	45a4      	cmp	ip, r4
32305b3a:	d107      	bne.n	32305b4c <_malloc_r+0xc4>
32305b3c:	e00d      	b.n	32305b5a <_malloc_r+0xd2>
32305b3e:	68e1      	ldr	r1, [r4, #12]
32305b40:	2a00      	cmp	r2, #0
32305b42:	f280 8133 	bge.w	32305dac <_malloc_r+0x324>
32305b46:	460c      	mov	r4, r1
32305b48:	458c      	cmp	ip, r1
32305b4a:	d006      	beq.n	32305b5a <_malloc_r+0xd2>
32305b4c:	6863      	ldr	r3, [r4, #4]
32305b4e:	f023 0303 	bic.w	r3, r3, #3
32305b52:	1b5a      	subs	r2, r3, r5
32305b54:	2a0f      	cmp	r2, #15
32305b56:	ddf2      	ble.n	32305b3e <_malloc_r+0xb6>
32305b58:	4670      	mov	r0, lr
32305b5a:	4bc1      	ldr	r3, [pc, #772]	@ (32305e60 <_malloc_r+0x3d8>)
32305b5c:	6934      	ldr	r4, [r6, #16]
32305b5e:	ee80 3b90 	vdup.32	d16, r3
32305b62:	429c      	cmp	r4, r3
32305b64:	f000 810f 	beq.w	32305d86 <_malloc_r+0x2fe>
32305b68:	6863      	ldr	r3, [r4, #4]
32305b6a:	f023 0e03 	bic.w	lr, r3, #3
32305b6e:	ebae 0305 	sub.w	r3, lr, r5
32305b72:	2b0f      	cmp	r3, #15
32305b74:	f300 818f 	bgt.w	32305e96 <_malloc_r+0x40e>
32305b78:	2b00      	cmp	r3, #0
32305b7a:	edc6 0b04 	vstr	d16, [r6, #16]
32305b7e:	f280 817e 	bge.w	32305e7e <_malloc_r+0x3f6>
32305b82:	6871      	ldr	r1, [r6, #4]
32305b84:	f5be 7f00 	cmp.w	lr, #512	@ 0x200
32305b88:	f080 811d 	bcs.w	32305dc6 <_malloc_r+0x33e>
32305b8c:	ea4f 03de 	mov.w	r3, lr, lsr #3
32305b90:	2201      	movs	r2, #1
32305b92:	3301      	adds	r3, #1
32305b94:	ea4f 1e5e 	mov.w	lr, lr, lsr #5
32305b98:	b21b      	sxth	r3, r3
32305b9a:	fa02 f20e 	lsl.w	r2, r2, lr
32305b9e:	4311      	orrs	r1, r2
32305ba0:	6071      	str	r1, [r6, #4]
32305ba2:	eb06 02c3 	add.w	r2, r6, r3, lsl #3
32305ba6:	f856 c033 	ldr.w	ip, [r6, r3, lsl #3]
32305baa:	3a08      	subs	r2, #8
32305bac:	f8c4 c008 	str.w	ip, [r4, #8]
32305bb0:	60e2      	str	r2, [r4, #12]
32305bb2:	f846 4033 	str.w	r4, [r6, r3, lsl #3]
32305bb6:	f8cc 400c 	str.w	r4, [ip, #12]
32305bba:	1083      	asrs	r3, r0, #2
32305bbc:	f04f 0c01 	mov.w	ip, #1
32305bc0:	fa0c fc03 	lsl.w	ip, ip, r3
32305bc4:	458c      	cmp	ip, r1
32305bc6:	d834      	bhi.n	32305c32 <_malloc_r+0x1aa>
32305bc8:	ea1c 0f01 	tst.w	ip, r1
32305bcc:	d107      	bne.n	32305bde <_malloc_r+0x156>
32305bce:	f020 0003 	bic.w	r0, r0, #3
32305bd2:	ea4f 0c4c 	mov.w	ip, ip, lsl #1
32305bd6:	3004      	adds	r0, #4
32305bd8:	ea1c 0f01 	tst.w	ip, r1
32305bdc:	d0f9      	beq.n	32305bd2 <_malloc_r+0x14a>
32305bde:	eb06 09c0 	add.w	r9, r6, r0, lsl #3
32305be2:	4680      	mov	r8, r0
32305be4:	46ce      	mov	lr, r9
32305be6:	f8de 300c 	ldr.w	r3, [lr, #12]
32305bea:	e00b      	b.n	32305c04 <_malloc_r+0x17c>
32305bec:	685a      	ldr	r2, [r3, #4]
32305bee:	461c      	mov	r4, r3
32305bf0:	68db      	ldr	r3, [r3, #12]
32305bf2:	f022 0203 	bic.w	r2, r2, #3
32305bf6:	1b51      	subs	r1, r2, r5
32305bf8:	290f      	cmp	r1, #15
32305bfa:	f300 8119 	bgt.w	32305e30 <_malloc_r+0x3a8>
32305bfe:	2900      	cmp	r1, #0
32305c00:	f280 8130 	bge.w	32305e64 <_malloc_r+0x3dc>
32305c04:	459e      	cmp	lr, r3
32305c06:	d1f1      	bne.n	32305bec <_malloc_r+0x164>
32305c08:	f108 0801 	add.w	r8, r8, #1
32305c0c:	f10e 0e08 	add.w	lr, lr, #8
32305c10:	f018 0f03 	tst.w	r8, #3
32305c14:	d1e7      	bne.n	32305be6 <_malloc_r+0x15e>
32305c16:	e183      	b.n	32305f20 <_malloc_r+0x498>
32305c18:	230c      	movs	r3, #12
32305c1a:	603b      	str	r3, [r7, #0]
32305c1c:	2400      	movs	r4, #0
32305c1e:	4620      	mov	r0, r4
32305c20:	b003      	add	sp, #12
32305c22:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32305c26:	f44f 7300 	mov.w	r3, #512	@ 0x200
32305c2a:	2040      	movs	r0, #64	@ 0x40
32305c2c:	f04f 0e3f 	mov.w	lr, #63	@ 0x3f
32305c30:	e77a      	b.n	32305b28 <_malloc_r+0xa0>
32305c32:	68b4      	ldr	r4, [r6, #8]
32305c34:	6863      	ldr	r3, [r4, #4]
32305c36:	f023 0903 	bic.w	r9, r3, #3
32305c3a:	45a9      	cmp	r9, r5
32305c3c:	eba9 0305 	sub.w	r3, r9, r5
32305c40:	bf28      	it	cs
32305c42:	2200      	movcs	r2, #0
32305c44:	bf38      	it	cc
32305c46:	2201      	movcc	r2, #1
32305c48:	2b0f      	cmp	r3, #15
32305c4a:	bfc8      	it	gt
32305c4c:	2100      	movgt	r1, #0
32305c4e:	bfd8      	it	le
32305c50:	2101      	movle	r1, #1
32305c52:	430a      	orrs	r2, r1
32305c54:	f000 8099 	beq.w	32305d8a <_malloc_r+0x302>
32305c58:	f245 3390 	movw	r3, #21392	@ 0x5390
32305c5c:	f2c3 2331 	movt	r3, #12849	@ 0x3231
32305c60:	2008      	movs	r0, #8
32305c62:	681b      	ldr	r3, [r3, #0]
32305c64:	f103 0810 	add.w	r8, r3, #16
32305c68:	eb04 0309 	add.w	r3, r4, r9
32305c6c:	9300      	str	r3, [sp, #0]
32305c6e:	f003 fe67 	bl	32309940 <sysconf>
32305c72:	f24c 33e8 	movw	r3, #50152	@ 0xc3e8
32305c76:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32305c7a:	44a8      	add	r8, r5
32305c7c:	4683      	mov	fp, r0
32305c7e:	681a      	ldr	r2, [r3, #0]
32305c80:	3201      	adds	r2, #1
32305c82:	d005      	beq.n	32305c90 <_malloc_r+0x208>
32305c84:	f108 38ff 	add.w	r8, r8, #4294967295	@ 0xffffffff
32305c88:	4242      	negs	r2, r0
32305c8a:	4480      	add	r8, r0
32305c8c:	ea02 0808 	and.w	r8, r2, r8
32305c90:	4641      	mov	r1, r8
32305c92:	4638      	mov	r0, r7
32305c94:	9300      	str	r3, [sp, #0]
32305c96:	f003 fe3f 	bl	32309918 <_sbrk_r>
32305c9a:	9b00      	ldr	r3, [sp, #0]
32305c9c:	4682      	mov	sl, r0
32305c9e:	f1b0 3fff 	cmp.w	r0, #4294967295	@ 0xffffffff
32305ca2:	f000 8118 	beq.w	32305ed6 <_malloc_r+0x44e>
32305ca6:	eb04 0209 	add.w	r2, r4, r9
32305caa:	4282      	cmp	r2, r0
32305cac:	f200 8111 	bhi.w	32305ed2 <_malloc_r+0x44a>
32305cb0:	f245 3260 	movw	r2, #21344	@ 0x5360
32305cb4:	f2c3 2231 	movt	r2, #12849	@ 0x3231
32305cb8:	f10b 3eff 	add.w	lr, fp, #4294967295	@ 0xffffffff
32305cbc:	6811      	ldr	r1, [r2, #0]
32305cbe:	eb08 0001 	add.w	r0, r8, r1
32305cc2:	6010      	str	r0, [r2, #0]
32305cc4:	f000 817e 	beq.w	32305fc4 <_malloc_r+0x53c>
32305cc8:	6819      	ldr	r1, [r3, #0]
32305cca:	3101      	adds	r1, #1
32305ccc:	f000 8186 	beq.w	32305fdc <_malloc_r+0x554>
32305cd0:	eb04 0309 	add.w	r3, r4, r9
32305cd4:	ebaa 0303 	sub.w	r3, sl, r3
32305cd8:	4403      	add	r3, r0
32305cda:	6013      	str	r3, [r2, #0]
32305cdc:	f01a 0307 	ands.w	r3, sl, #7
32305ce0:	e9cd 3200 	strd	r3, r2, [sp]
32305ce4:	f000 813a 	beq.w	32305f5c <_malloc_r+0x4d4>
32305ce8:	f1c3 0308 	rsb	r3, r3, #8
32305cec:	4638      	mov	r0, r7
32305cee:	449a      	add	sl, r3
32305cf0:	445b      	add	r3, fp
32305cf2:	44d0      	add	r8, sl
32305cf4:	ea08 010e 	and.w	r1, r8, lr
32305cf8:	1a5b      	subs	r3, r3, r1
32305cfa:	ea03 0b0e 	and.w	fp, r3, lr
32305cfe:	4659      	mov	r1, fp
32305d00:	f003 fe0a 	bl	32309918 <_sbrk_r>
32305d04:	1c42      	adds	r2, r0, #1
32305d06:	9a01      	ldr	r2, [sp, #4]
32305d08:	f000 8185 	beq.w	32306016 <_malloc_r+0x58e>
32305d0c:	eba0 000a 	sub.w	r0, r0, sl
32305d10:	eb00 080b 	add.w	r8, r0, fp
32305d14:	6813      	ldr	r3, [r2, #0]
32305d16:	f048 0101 	orr.w	r1, r8, #1
32305d1a:	f8c6 a008 	str.w	sl, [r6, #8]
32305d1e:	42b4      	cmp	r4, r6
32305d20:	eb0b 0003 	add.w	r0, fp, r3
32305d24:	f8ca 1004 	str.w	r1, [sl, #4]
32305d28:	6010      	str	r0, [r2, #0]
32305d2a:	d01a      	beq.n	32305d62 <_malloc_r+0x2da>
32305d2c:	f1b9 0f0f 	cmp.w	r9, #15
32305d30:	f240 8157 	bls.w	32305fe2 <_malloc_r+0x55a>
32305d34:	6863      	ldr	r3, [r4, #4]
32305d36:	f1a9 010c 	sub.w	r1, r9, #12
32305d3a:	f021 0107 	bic.w	r1, r1, #7
32305d3e:	efc0 0015 	vmov.i32	d16, #5	@ 0x00000005
32305d42:	f003 0301 	and.w	r3, r3, #1
32305d46:	290f      	cmp	r1, #15
32305d48:	ea43 0301 	orr.w	r3, r3, r1
32305d4c:	6063      	str	r3, [r4, #4]
32305d4e:	eb04 0301 	add.w	r3, r4, r1
32305d52:	f103 0304 	add.w	r3, r3, #4
32305d56:	f943 078f 	vst1.32	{d16}, [r3]
32305d5a:	f200 8164 	bhi.w	32306026 <_malloc_r+0x59e>
32305d5e:	f8da 1004 	ldr.w	r1, [sl, #4]
32305d62:	f245 338c 	movw	r3, #21388	@ 0x538c
32305d66:	f2c3 2331 	movt	r3, #12849	@ 0x3231
32305d6a:	681a      	ldr	r2, [r3, #0]
32305d6c:	4282      	cmp	r2, r0
32305d6e:	d200      	bcs.n	32305d72 <_malloc_r+0x2ea>
32305d70:	6018      	str	r0, [r3, #0]
32305d72:	f245 3388 	movw	r3, #21384	@ 0x5388
32305d76:	f2c3 2331 	movt	r3, #12849	@ 0x3231
32305d7a:	681a      	ldr	r2, [r3, #0]
32305d7c:	4282      	cmp	r2, r0
32305d7e:	d200      	bcs.n	32305d82 <_malloc_r+0x2fa>
32305d80:	6018      	str	r0, [r3, #0]
32305d82:	4654      	mov	r4, sl
32305d84:	e0a9      	b.n	32305eda <_malloc_r+0x452>
32305d86:	6871      	ldr	r1, [r6, #4]
32305d88:	e717      	b.n	32305bba <_malloc_r+0x132>
32305d8a:	1962      	adds	r2, r4, r5
32305d8c:	f043 0301 	orr.w	r3, r3, #1
32305d90:	4638      	mov	r0, r7
32305d92:	f045 0501 	orr.w	r5, r5, #1
32305d96:	3408      	adds	r4, #8
32305d98:	f844 5c04 	str.w	r5, [r4, #-4]
32305d9c:	60b2      	str	r2, [r6, #8]
32305d9e:	6053      	str	r3, [r2, #4]
32305da0:	f000 fbca 	bl	32306538 <__malloc_unlock>
32305da4:	4620      	mov	r0, r4
32305da6:	b003      	add	sp, #12
32305da8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32305dac:	68a2      	ldr	r2, [r4, #8]
32305dae:	4423      	add	r3, r4
32305db0:	4638      	mov	r0, r7
32305db2:	60d1      	str	r1, [r2, #12]
32305db4:	608a      	str	r2, [r1, #8]
32305db6:	e68b      	b.n	32305ad0 <_malloc_r+0x48>
32305db8:	68dc      	ldr	r4, [r3, #12]
32305dba:	42a3      	cmp	r3, r4
32305dbc:	bf08      	it	eq
32305dbe:	3002      	addeq	r0, #2
32305dc0:	f43f aecb 	beq.w	32305b5a <_malloc_r+0xd2>
32305dc4:	e67b      	b.n	32305abe <_malloc_r+0x36>
32305dc6:	ea4f 225e 	mov.w	r2, lr, lsr #9
32305dca:	f5be 6f20 	cmp.w	lr, #2560	@ 0xa00
32305dce:	d378      	bcc.n	32305ec2 <_malloc_r+0x43a>
32305dd0:	2a14      	cmp	r2, #20
32305dd2:	f200 80d6 	bhi.w	32305f82 <_malloc_r+0x4fa>
32305dd6:	f102 035c 	add.w	r3, r2, #92	@ 0x5c
32305dda:	325b      	adds	r2, #91	@ 0x5b
32305ddc:	b21b      	sxth	r3, r3
32305dde:	00db      	lsls	r3, r3, #3
32305de0:	eb06 0c03 	add.w	ip, r6, r3
32305de4:	58f3      	ldr	r3, [r6, r3]
32305de6:	f1ac 0c08 	sub.w	ip, ip, #8
32305dea:	459c      	cmp	ip, r3
32305dec:	d103      	bne.n	32305df6 <_malloc_r+0x36e>
32305dee:	e0ad      	b.n	32305f4c <_malloc_r+0x4c4>
32305df0:	689b      	ldr	r3, [r3, #8]
32305df2:	459c      	cmp	ip, r3
32305df4:	d004      	beq.n	32305e00 <_malloc_r+0x378>
32305df6:	685a      	ldr	r2, [r3, #4]
32305df8:	f022 0203 	bic.w	r2, r2, #3
32305dfc:	4572      	cmp	r2, lr
32305dfe:	d8f7      	bhi.n	32305df0 <_malloc_r+0x368>
32305e00:	f8d3 c00c 	ldr.w	ip, [r3, #12]
32305e04:	e9c4 3c02 	strd	r3, ip, [r4, #8]
32305e08:	f8cc 4008 	str.w	r4, [ip, #8]
32305e0c:	60dc      	str	r4, [r3, #12]
32305e0e:	e6d4      	b.n	32305bba <_malloc_r+0x132>
32305e10:	f1be 0f14 	cmp.w	lr, #20
32305e14:	d977      	bls.n	32305f06 <_malloc_r+0x47e>
32305e16:	f1be 0f54 	cmp.w	lr, #84	@ 0x54
32305e1a:	f200 80bc 	bhi.w	32305f96 <_malloc_r+0x50e>
32305e1e:	ea4f 3e15 	mov.w	lr, r5, lsr #12
32305e22:	f10e 006f 	add.w	r0, lr, #111	@ 0x6f
32305e26:	f10e 0e6e 	add.w	lr, lr, #110	@ 0x6e
32305e2a:	b203      	sxth	r3, r0
32305e2c:	00db      	lsls	r3, r3, #3
32305e2e:	e67b      	b.n	32305b28 <_malloc_r+0xa0>
32305e30:	4638      	mov	r0, r7
32305e32:	1967      	adds	r7, r4, r5
32305e34:	f045 0501 	orr.w	r5, r5, #1
32305e38:	6065      	str	r5, [r4, #4]
32305e3a:	68a5      	ldr	r5, [r4, #8]
32305e3c:	ee81 7b90 	vdup.32	d17, r7
32305e40:	60eb      	str	r3, [r5, #12]
32305e42:	609d      	str	r5, [r3, #8]
32305e44:	f107 0308 	add.w	r3, r7, #8
32305e48:	edc6 1b04 	vstr	d17, [r6, #16]
32305e4c:	f943 078f 	vst1.32	{d16}, [r3]
32305e50:	f041 0301 	orr.w	r3, r1, #1
32305e54:	607b      	str	r3, [r7, #4]
32305e56:	50a1      	str	r1, [r4, r2]
32305e58:	3408      	adds	r4, #8
32305e5a:	f000 fb6d 	bl	32306538 <__malloc_unlock>
32305e5e:	e6de      	b.n	32305c1e <_malloc_r+0x196>
32305e60:	3230c3f8 	.word	0x3230c3f8
32305e64:	4422      	add	r2, r4
32305e66:	4638      	mov	r0, r7
32305e68:	6851      	ldr	r1, [r2, #4]
32305e6a:	f041 0101 	orr.w	r1, r1, #1
32305e6e:	6051      	str	r1, [r2, #4]
32305e70:	f854 2f08 	ldr.w	r2, [r4, #8]!
32305e74:	60d3      	str	r3, [r2, #12]
32305e76:	609a      	str	r2, [r3, #8]
32305e78:	f000 fb5e 	bl	32306538 <__malloc_unlock>
32305e7c:	e6cf      	b.n	32305c1e <_malloc_r+0x196>
32305e7e:	44a6      	add	lr, r4
32305e80:	4638      	mov	r0, r7
32305e82:	3408      	adds	r4, #8
32305e84:	f8de 3004 	ldr.w	r3, [lr, #4]
32305e88:	f043 0301 	orr.w	r3, r3, #1
32305e8c:	f8ce 3004 	str.w	r3, [lr, #4]
32305e90:	f000 fb52 	bl	32306538 <__malloc_unlock>
32305e94:	e6c3      	b.n	32305c1e <_malloc_r+0x196>
32305e96:	1962      	adds	r2, r4, r5
32305e98:	4638      	mov	r0, r7
32305e9a:	f102 0108 	add.w	r1, r2, #8
32305e9e:	f045 0501 	orr.w	r5, r5, #1
32305ea2:	ee81 2b90 	vdup.32	d17, r2
32305ea6:	6065      	str	r5, [r4, #4]
32305ea8:	edc6 1b04 	vstr	d17, [r6, #16]
32305eac:	f941 078f 	vst1.32	{d16}, [r1]
32305eb0:	f043 0101 	orr.w	r1, r3, #1
32305eb4:	6051      	str	r1, [r2, #4]
32305eb6:	f844 300e 	str.w	r3, [r4, lr]
32305eba:	3408      	adds	r4, #8
32305ebc:	f000 fb3c 	bl	32306538 <__malloc_unlock>
32305ec0:	e6ad      	b.n	32305c1e <_malloc_r+0x196>
32305ec2:	ea4f 129e 	mov.w	r2, lr, lsr #6
32305ec6:	f102 0339 	add.w	r3, r2, #57	@ 0x39
32305eca:	3238      	adds	r2, #56	@ 0x38
32305ecc:	b21b      	sxth	r3, r3
32305ece:	00db      	lsls	r3, r3, #3
32305ed0:	e786      	b.n	32305de0 <_malloc_r+0x358>
32305ed2:	42b4      	cmp	r4, r6
32305ed4:	d06b      	beq.n	32305fae <_malloc_r+0x526>
32305ed6:	68b4      	ldr	r4, [r6, #8]
32305ed8:	6861      	ldr	r1, [r4, #4]
32305eda:	f021 0803 	bic.w	r8, r1, #3
32305ede:	45a8      	cmp	r8, r5
32305ee0:	eba8 0305 	sub.w	r3, r8, r5
32305ee4:	bf28      	it	cs
32305ee6:	2200      	movcs	r2, #0
32305ee8:	bf38      	it	cc
32305eea:	2201      	movcc	r2, #1
32305eec:	2b0f      	cmp	r3, #15
32305eee:	bfc8      	it	gt
32305ef0:	2100      	movgt	r1, #0
32305ef2:	bfd8      	it	le
32305ef4:	2101      	movle	r1, #1
32305ef6:	ea52 0801 	orrs.w	r8, r2, r1
32305efa:	f43f af46 	beq.w	32305d8a <_malloc_r+0x302>
32305efe:	4638      	mov	r0, r7
32305f00:	f000 fb1a 	bl	32306538 <__malloc_unlock>
32305f04:	e68a      	b.n	32305c1c <_malloc_r+0x194>
32305f06:	f10e 005c 	add.w	r0, lr, #92	@ 0x5c
32305f0a:	f10e 0e5b 	add.w	lr, lr, #91	@ 0x5b
32305f0e:	b203      	sxth	r3, r0
32305f10:	00db      	lsls	r3, r3, #3
32305f12:	e609      	b.n	32305b28 <_malloc_r+0xa0>
32305f14:	f859 3908 	ldr.w	r3, [r9], #-8
32305f18:	3801      	subs	r0, #1
32305f1a:	454b      	cmp	r3, r9
32305f1c:	f040 80a3 	bne.w	32306066 <_malloc_r+0x5de>
32305f20:	0784      	lsls	r4, r0, #30
32305f22:	d1f7      	bne.n	32305f14 <_malloc_r+0x48c>
32305f24:	6873      	ldr	r3, [r6, #4]
32305f26:	ea23 030c 	bic.w	r3, r3, ip
32305f2a:	6073      	str	r3, [r6, #4]
32305f2c:	ea4f 0c4c 	mov.w	ip, ip, lsl #1
32305f30:	f10c 32ff 	add.w	r2, ip, #4294967295	@ 0xffffffff
32305f34:	429a      	cmp	r2, r3
32305f36:	d304      	bcc.n	32305f42 <_malloc_r+0x4ba>
32305f38:	e67b      	b.n	32305c32 <_malloc_r+0x1aa>
32305f3a:	ea4f 0c4c 	mov.w	ip, ip, lsl #1
32305f3e:	f108 0804 	add.w	r8, r8, #4
32305f42:	ea1c 0f03 	tst.w	ip, r3
32305f46:	d0f8      	beq.n	32305f3a <_malloc_r+0x4b2>
32305f48:	4640      	mov	r0, r8
32305f4a:	e648      	b.n	32305bde <_malloc_r+0x156>
32305f4c:	1092      	asrs	r2, r2, #2
32305f4e:	f04f 0e01 	mov.w	lr, #1
32305f52:	fa0e f202 	lsl.w	r2, lr, r2
32305f56:	4311      	orrs	r1, r2
32305f58:	6071      	str	r1, [r6, #4]
32305f5a:	e753      	b.n	32305e04 <_malloc_r+0x37c>
32305f5c:	eb0a 0308 	add.w	r3, sl, r8
32305f60:	4638      	mov	r0, r7
32305f62:	ea03 030e 	and.w	r3, r3, lr
32305f66:	ebab 0b03 	sub.w	fp, fp, r3
32305f6a:	ea0b 0b0e 	and.w	fp, fp, lr
32305f6e:	4659      	mov	r1, fp
32305f70:	f003 fcd2 	bl	32309918 <_sbrk_r>
32305f74:	9a01      	ldr	r2, [sp, #4]
32305f76:	1c43      	adds	r3, r0, #1
32305f78:	f47f aec8 	bne.w	32305d0c <_malloc_r+0x284>
32305f7c:	f8dd b000 	ldr.w	fp, [sp]
32305f80:	e6c8      	b.n	32305d14 <_malloc_r+0x28c>
32305f82:	2a54      	cmp	r2, #84	@ 0x54
32305f84:	d831      	bhi.n	32305fea <_malloc_r+0x562>
32305f86:	ea4f 321e 	mov.w	r2, lr, lsr #12
32305f8a:	f102 036f 	add.w	r3, r2, #111	@ 0x6f
32305f8e:	326e      	adds	r2, #110	@ 0x6e
32305f90:	b21b      	sxth	r3, r3
32305f92:	00db      	lsls	r3, r3, #3
32305f94:	e724      	b.n	32305de0 <_malloc_r+0x358>
32305f96:	f5be 7faa 	cmp.w	lr, #340	@ 0x154
32305f9a:	d831      	bhi.n	32306000 <_malloc_r+0x578>
32305f9c:	ea4f 3ed5 	mov.w	lr, r5, lsr #15
32305fa0:	f10e 0078 	add.w	r0, lr, #120	@ 0x78
32305fa4:	f10e 0e77 	add.w	lr, lr, #119	@ 0x77
32305fa8:	b203      	sxth	r3, r0
32305faa:	00db      	lsls	r3, r3, #3
32305fac:	e5bc      	b.n	32305b28 <_malloc_r+0xa0>
32305fae:	f245 3260 	movw	r2, #21344	@ 0x5360
32305fb2:	f2c3 2231 	movt	r2, #12849	@ 0x3231
32305fb6:	f10b 3eff 	add.w	lr, fp, #4294967295	@ 0xffffffff
32305fba:	6811      	ldr	r1, [r2, #0]
32305fbc:	eb08 0001 	add.w	r0, r8, r1
32305fc0:	6010      	str	r0, [r2, #0]
32305fc2:	e681      	b.n	32305cc8 <_malloc_r+0x240>
32305fc4:	ea1a 0f0e 	tst.w	sl, lr
32305fc8:	f47f ae7e 	bne.w	32305cc8 <_malloc_r+0x240>
32305fcc:	f8d6 a008 	ldr.w	sl, [r6, #8]
32305fd0:	44c8      	add	r8, r9
32305fd2:	f048 0101 	orr.w	r1, r8, #1
32305fd6:	f8ca 1004 	str.w	r1, [sl, #4]
32305fda:	e6c2      	b.n	32305d62 <_malloc_r+0x2da>
32305fdc:	f8c3 a000 	str.w	sl, [r3]
32305fe0:	e67c      	b.n	32305cdc <_malloc_r+0x254>
32305fe2:	2301      	movs	r3, #1
32305fe4:	f8ca 3004 	str.w	r3, [sl, #4]
32305fe8:	e789      	b.n	32305efe <_malloc_r+0x476>
32305fea:	f5b2 7faa 	cmp.w	r2, #340	@ 0x154
32305fee:	d825      	bhi.n	3230603c <_malloc_r+0x5b4>
32305ff0:	ea4f 32de 	mov.w	r2, lr, lsr #15
32305ff4:	f102 0378 	add.w	r3, r2, #120	@ 0x78
32305ff8:	3277      	adds	r2, #119	@ 0x77
32305ffa:	b21b      	sxth	r3, r3
32305ffc:	00db      	lsls	r3, r3, #3
32305ffe:	e6ef      	b.n	32305de0 <_malloc_r+0x358>
32306000:	f240 5354 	movw	r3, #1364	@ 0x554
32306004:	459e      	cmp	lr, r3
32306006:	d824      	bhi.n	32306052 <_malloc_r+0x5ca>
32306008:	0cab      	lsrs	r3, r5, #18
3230600a:	f103 007d 	add.w	r0, r3, #125	@ 0x7d
3230600e:	f103 0e7c 	add.w	lr, r3, #124	@ 0x7c
32306012:	00c3      	lsls	r3, r0, #3
32306014:	e588      	b.n	32305b28 <_malloc_r+0xa0>
32306016:	9b00      	ldr	r3, [sp, #0]
32306018:	f04f 0b00 	mov.w	fp, #0
3230601c:	3b08      	subs	r3, #8
3230601e:	4498      	add	r8, r3
32306020:	eba8 080a 	sub.w	r8, r8, sl
32306024:	e676      	b.n	32305d14 <_malloc_r+0x28c>
32306026:	4638      	mov	r0, r7
32306028:	f104 0108 	add.w	r1, r4, #8
3230602c:	9200      	str	r2, [sp, #0]
3230602e:	f7ff fbdb 	bl	323057e8 <_free_r>
32306032:	9a00      	ldr	r2, [sp, #0]
32306034:	f8d6 a008 	ldr.w	sl, [r6, #8]
32306038:	6810      	ldr	r0, [r2, #0]
3230603a:	e690      	b.n	32305d5e <_malloc_r+0x2d6>
3230603c:	f240 5354 	movw	r3, #1364	@ 0x554
32306040:	429a      	cmp	r2, r3
32306042:	d80c      	bhi.n	3230605e <_malloc_r+0x5d6>
32306044:	ea4f 429e 	mov.w	r2, lr, lsr #18
32306048:	f102 037d 	add.w	r3, r2, #125	@ 0x7d
3230604c:	327c      	adds	r2, #124	@ 0x7c
3230604e:	00db      	lsls	r3, r3, #3
32306050:	e6c6      	b.n	32305de0 <_malloc_r+0x358>
32306052:	f44f 737e 	mov.w	r3, #1016	@ 0x3f8
32306056:	207f      	movs	r0, #127	@ 0x7f
32306058:	f04f 0e7e 	mov.w	lr, #126	@ 0x7e
3230605c:	e564      	b.n	32305b28 <_malloc_r+0xa0>
3230605e:	f44f 737e 	mov.w	r3, #1016	@ 0x3f8
32306062:	227e      	movs	r2, #126	@ 0x7e
32306064:	e6bc      	b.n	32305de0 <_malloc_r+0x358>
32306066:	6873      	ldr	r3, [r6, #4]
32306068:	e760      	b.n	32305f2c <_malloc_r+0x4a4>
3230606a:	08e8      	lsrs	r0, r5, #3
3230606c:	1c43      	adds	r3, r0, #1
3230606e:	b21b      	sxth	r3, r3
32306070:	00db      	lsls	r3, r3, #3
32306072:	e519      	b.n	32305aa8 <_malloc_r+0x20>

32306074 <_mbtowc_r>:
32306074:	f24c 1c10 	movw	ip, #49424	@ 0xc110
32306078:	f2c3 2c30 	movt	ip, #12848	@ 0x3230
3230607c:	b410      	push	{r4}
3230607e:	f8dc 40e4 	ldr.w	r4, [ip, #228]	@ 0xe4
32306082:	46a4      	mov	ip, r4
32306084:	f85d 4b04 	ldr.w	r4, [sp], #4
32306088:	4760      	bx	ip
3230608a:	bf00      	nop

3230608c <__ascii_mbtowc>:
3230608c:	b082      	sub	sp, #8
3230608e:	b151      	cbz	r1, 323060a6 <__ascii_mbtowc+0x1a>
32306090:	4610      	mov	r0, r2
32306092:	b132      	cbz	r2, 323060a2 <__ascii_mbtowc+0x16>
32306094:	b14b      	cbz	r3, 323060aa <__ascii_mbtowc+0x1e>
32306096:	7813      	ldrb	r3, [r2, #0]
32306098:	600b      	str	r3, [r1, #0]
3230609a:	7812      	ldrb	r2, [r2, #0]
3230609c:	1e10      	subs	r0, r2, #0
3230609e:	bf18      	it	ne
323060a0:	2001      	movne	r0, #1
323060a2:	b002      	add	sp, #8
323060a4:	4770      	bx	lr
323060a6:	a901      	add	r1, sp, #4
323060a8:	e7f2      	b.n	32306090 <__ascii_mbtowc+0x4>
323060aa:	f06f 0001 	mvn.w	r0, #1
323060ae:	e7f8      	b.n	323060a2 <__ascii_mbtowc+0x16>

323060b0 <__utf8_mbtowc>:
323060b0:	b5f0      	push	{r4, r5, r6, r7, lr}
323060b2:	4686      	mov	lr, r0
323060b4:	b083      	sub	sp, #12
323060b6:	9e08      	ldr	r6, [sp, #32]
323060b8:	2900      	cmp	r1, #0
323060ba:	d035      	beq.n	32306128 <__utf8_mbtowc+0x78>
323060bc:	b38a      	cbz	r2, 32306122 <__utf8_mbtowc+0x72>
323060be:	2b00      	cmp	r3, #0
323060c0:	d051      	beq.n	32306166 <__utf8_mbtowc+0xb6>
323060c2:	6835      	ldr	r5, [r6, #0]
323060c4:	bb35      	cbnz	r5, 32306114 <__utf8_mbtowc+0x64>
323060c6:	7814      	ldrb	r4, [r2, #0]
323060c8:	f04f 0c01 	mov.w	ip, #1
323060cc:	b33c      	cbz	r4, 3230611e <__utf8_mbtowc+0x6e>
323060ce:	2c7f      	cmp	r4, #127	@ 0x7f
323060d0:	dd4c      	ble.n	3230616c <__utf8_mbtowc+0xbc>
323060d2:	f1a4 00c0 	sub.w	r0, r4, #192	@ 0xc0
323060d6:	281f      	cmp	r0, #31
323060d8:	d828      	bhi.n	3230612c <__utf8_mbtowc+0x7c>
323060da:	7134      	strb	r4, [r6, #4]
323060dc:	b91d      	cbnz	r5, 323060e6 <__utf8_mbtowc+0x36>
323060de:	2001      	movs	r0, #1
323060e0:	6030      	str	r0, [r6, #0]
323060e2:	4283      	cmp	r3, r0
323060e4:	d03f      	beq.n	32306166 <__utf8_mbtowc+0xb6>
323060e6:	f812 300c 	ldrb.w	r3, [r2, ip]
323060ea:	f10c 0001 	add.w	r0, ip, #1
323060ee:	f1a3 0280 	sub.w	r2, r3, #128	@ 0x80
323060f2:	2a3f      	cmp	r2, #63	@ 0x3f
323060f4:	f200 80b3 	bhi.w	3230625e <__utf8_mbtowc+0x1ae>
323060f8:	2cc1      	cmp	r4, #193	@ 0xc1
323060fa:	f340 80b0 	ble.w	3230625e <__utf8_mbtowc+0x1ae>
323060fe:	01a4      	lsls	r4, r4, #6
32306100:	f003 033f 	and.w	r3, r3, #63	@ 0x3f
32306104:	f404 64f8 	and.w	r4, r4, #1984	@ 0x7c0
32306108:	431c      	orrs	r4, r3
3230610a:	2300      	movs	r3, #0
3230610c:	6033      	str	r3, [r6, #0]
3230610e:	600c      	str	r4, [r1, #0]
32306110:	b003      	add	sp, #12
32306112:	bdf0      	pop	{r4, r5, r6, r7, pc}
32306114:	7934      	ldrb	r4, [r6, #4]
32306116:	f04f 0c00 	mov.w	ip, #0
3230611a:	2c00      	cmp	r4, #0
3230611c:	d1d7      	bne.n	323060ce <__utf8_mbtowc+0x1e>
3230611e:	600c      	str	r4, [r1, #0]
32306120:	6034      	str	r4, [r6, #0]
32306122:	2000      	movs	r0, #0
32306124:	b003      	add	sp, #12
32306126:	bdf0      	pop	{r4, r5, r6, r7, pc}
32306128:	a901      	add	r1, sp, #4
3230612a:	e7c7      	b.n	323060bc <__utf8_mbtowc+0xc>
3230612c:	f1a4 00e0 	sub.w	r0, r4, #224	@ 0xe0
32306130:	280f      	cmp	r0, #15
32306132:	d821      	bhi.n	32306178 <__utf8_mbtowc+0xc8>
32306134:	7134      	strb	r4, [r6, #4]
32306136:	2d00      	cmp	r5, #0
32306138:	d164      	bne.n	32306204 <__utf8_mbtowc+0x154>
3230613a:	2001      	movs	r0, #1
3230613c:	6030      	str	r0, [r6, #0]
3230613e:	4283      	cmp	r3, r0
32306140:	d011      	beq.n	32306166 <__utf8_mbtowc+0xb6>
32306142:	f812 000c 	ldrb.w	r0, [r2, ip]
32306146:	2ce0      	cmp	r4, #224	@ 0xe0
32306148:	f10c 0c01 	add.w	ip, ip, #1
3230614c:	f000 80a8 	beq.w	323062a0 <__utf8_mbtowc+0x1f0>
32306150:	f1a0 0780 	sub.w	r7, r0, #128	@ 0x80
32306154:	4605      	mov	r5, r0
32306156:	2f3f      	cmp	r7, #63	@ 0x3f
32306158:	f200 8081 	bhi.w	3230625e <__utf8_mbtowc+0x1ae>
3230615c:	7170      	strb	r0, [r6, #5]
3230615e:	2002      	movs	r0, #2
32306160:	4283      	cmp	r3, r0
32306162:	6030      	str	r0, [r6, #0]
32306164:	d15a      	bne.n	3230621c <__utf8_mbtowc+0x16c>
32306166:	f06f 0001 	mvn.w	r0, #1
3230616a:	e7d1      	b.n	32306110 <__utf8_mbtowc+0x60>
3230616c:	2300      	movs	r3, #0
3230616e:	2001      	movs	r0, #1
32306170:	6033      	str	r3, [r6, #0]
32306172:	600c      	str	r4, [r1, #0]
32306174:	b003      	add	sp, #12
32306176:	bdf0      	pop	{r4, r5, r6, r7, pc}
32306178:	f1a4 00f0 	sub.w	r0, r4, #240	@ 0xf0
3230617c:	2804      	cmp	r0, #4
3230617e:	d86e      	bhi.n	3230625e <__utf8_mbtowc+0x1ae>
32306180:	7134      	strb	r4, [r6, #4]
32306182:	2d00      	cmp	r5, #0
32306184:	d05f      	beq.n	32306246 <__utf8_mbtowc+0x196>
32306186:	1c5f      	adds	r7, r3, #1
32306188:	bf18      	it	ne
3230618a:	3301      	addne	r3, #1
3230618c:	2d01      	cmp	r5, #1
3230618e:	d05e      	beq.n	3230624e <__utf8_mbtowc+0x19e>
32306190:	7977      	ldrb	r7, [r6, #5]
32306192:	2cf0      	cmp	r4, #240	@ 0xf0
32306194:	d061      	beq.n	3230625a <__utf8_mbtowc+0x1aa>
32306196:	f1a4 00f4 	sub.w	r0, r4, #244	@ 0xf4
3230619a:	2f8f      	cmp	r7, #143	@ 0x8f
3230619c:	fab0 f080 	clz	r0, r0
323061a0:	ea4f 1050 	mov.w	r0, r0, lsr #5
323061a4:	bfd8      	it	le
323061a6:	2000      	movle	r0, #0
323061a8:	2800      	cmp	r0, #0
323061aa:	d158      	bne.n	3230625e <__utf8_mbtowc+0x1ae>
323061ac:	f1a7 0080 	sub.w	r0, r7, #128	@ 0x80
323061b0:	283f      	cmp	r0, #63	@ 0x3f
323061b2:	d854      	bhi.n	3230625e <__utf8_mbtowc+0x1ae>
323061b4:	2d01      	cmp	r5, #1
323061b6:	7177      	strb	r7, [r6, #5]
323061b8:	d057      	beq.n	3230626a <__utf8_mbtowc+0x1ba>
323061ba:	1c58      	adds	r0, r3, #1
323061bc:	6830      	ldr	r0, [r6, #0]
323061be:	bf18      	it	ne
323061c0:	3301      	addne	r3, #1
323061c2:	2802      	cmp	r0, #2
323061c4:	d056      	beq.n	32306274 <__utf8_mbtowc+0x1c4>
323061c6:	79b5      	ldrb	r5, [r6, #6]
323061c8:	f1a5 0380 	sub.w	r3, r5, #128	@ 0x80
323061cc:	2b3f      	cmp	r3, #63	@ 0x3f
323061ce:	d846      	bhi.n	3230625e <__utf8_mbtowc+0x1ae>
323061d0:	f812 200c 	ldrb.w	r2, [r2, ip]
323061d4:	f10c 0001 	add.w	r0, ip, #1
323061d8:	f1a2 0380 	sub.w	r3, r2, #128	@ 0x80
323061dc:	2b3f      	cmp	r3, #63	@ 0x3f
323061de:	d83e      	bhi.n	3230625e <__utf8_mbtowc+0x1ae>
323061e0:	04a3      	lsls	r3, r4, #18
323061e2:	033f      	lsls	r7, r7, #12
323061e4:	f403 13e0 	and.w	r3, r3, #1835008	@ 0x1c0000
323061e8:	f407 377c 	and.w	r7, r7, #258048	@ 0x3f000
323061ec:	01ad      	lsls	r5, r5, #6
323061ee:	433b      	orrs	r3, r7
323061f0:	f405 657c 	and.w	r5, r5, #4032	@ 0xfc0
323061f4:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
323061f8:	432b      	orrs	r3, r5
323061fa:	4313      	orrs	r3, r2
323061fc:	2200      	movs	r2, #0
323061fe:	600b      	str	r3, [r1, #0]
32306200:	6032      	str	r2, [r6, #0]
32306202:	e785      	b.n	32306110 <__utf8_mbtowc+0x60>
32306204:	1c58      	adds	r0, r3, #1
32306206:	bf18      	it	ne
32306208:	3301      	addne	r3, #1
3230620a:	2d01      	cmp	r5, #1
3230620c:	d099      	beq.n	32306142 <__utf8_mbtowc+0x92>
3230620e:	7975      	ldrb	r5, [r6, #5]
32306210:	2ce0      	cmp	r4, #224	@ 0xe0
32306212:	d03d      	beq.n	32306290 <__utf8_mbtowc+0x1e0>
32306214:	f1a5 0380 	sub.w	r3, r5, #128	@ 0x80
32306218:	2b3f      	cmp	r3, #63	@ 0x3f
3230621a:	d820      	bhi.n	3230625e <__utf8_mbtowc+0x1ae>
3230621c:	f812 200c 	ldrb.w	r2, [r2, ip]
32306220:	f10c 0001 	add.w	r0, ip, #1
32306224:	f1a2 0380 	sub.w	r3, r2, #128	@ 0x80
32306228:	2b3f      	cmp	r3, #63	@ 0x3f
3230622a:	d818      	bhi.n	3230625e <__utf8_mbtowc+0x1ae>
3230622c:	0323      	lsls	r3, r4, #12
3230622e:	01ad      	lsls	r5, r5, #6
32306230:	f405 657c 	and.w	r5, r5, #4032	@ 0xfc0
32306234:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
32306238:	b29b      	uxth	r3, r3
3230623a:	432b      	orrs	r3, r5
3230623c:	4313      	orrs	r3, r2
3230623e:	2200      	movs	r2, #0
32306240:	6032      	str	r2, [r6, #0]
32306242:	600b      	str	r3, [r1, #0]
32306244:	e764      	b.n	32306110 <__utf8_mbtowc+0x60>
32306246:	2001      	movs	r0, #1
32306248:	6030      	str	r0, [r6, #0]
3230624a:	4283      	cmp	r3, r0
3230624c:	d08b      	beq.n	32306166 <__utf8_mbtowc+0xb6>
3230624e:	f812 700c 	ldrb.w	r7, [r2, ip]
32306252:	2501      	movs	r5, #1
32306254:	f10c 0c01 	add.w	ip, ip, #1
32306258:	e79b      	b.n	32306192 <__utf8_mbtowc+0xe2>
3230625a:	2f8f      	cmp	r7, #143	@ 0x8f
3230625c:	dca6      	bgt.n	323061ac <__utf8_mbtowc+0xfc>
3230625e:	238a      	movs	r3, #138	@ 0x8a
32306260:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32306264:	f8ce 3000 	str.w	r3, [lr]
32306268:	e752      	b.n	32306110 <__utf8_mbtowc+0x60>
3230626a:	2002      	movs	r0, #2
3230626c:	6030      	str	r0, [r6, #0]
3230626e:	4283      	cmp	r3, r0
32306270:	f43f af79 	beq.w	32306166 <__utf8_mbtowc+0xb6>
32306274:	f812 500c 	ldrb.w	r5, [r2, ip]
32306278:	f10c 0c01 	add.w	ip, ip, #1
3230627c:	f1a5 0080 	sub.w	r0, r5, #128	@ 0x80
32306280:	283f      	cmp	r0, #63	@ 0x3f
32306282:	d8ec      	bhi.n	3230625e <__utf8_mbtowc+0x1ae>
32306284:	2003      	movs	r0, #3
32306286:	71b5      	strb	r5, [r6, #6]
32306288:	4283      	cmp	r3, r0
3230628a:	6030      	str	r0, [r6, #0]
3230628c:	d1a0      	bne.n	323061d0 <__utf8_mbtowc+0x120>
3230628e:	e76a      	b.n	32306166 <__utf8_mbtowc+0xb6>
32306290:	2d9f      	cmp	r5, #159	@ 0x9f
32306292:	d9e4      	bls.n	3230625e <__utf8_mbtowc+0x1ae>
32306294:	f1a5 0380 	sub.w	r3, r5, #128	@ 0x80
32306298:	2b3f      	cmp	r3, #63	@ 0x3f
3230629a:	d8e0      	bhi.n	3230625e <__utf8_mbtowc+0x1ae>
3230629c:	7175      	strb	r5, [r6, #5]
3230629e:	e7bd      	b.n	3230621c <__utf8_mbtowc+0x16c>
323062a0:	289f      	cmp	r0, #159	@ 0x9f
323062a2:	f63f af55 	bhi.w	32306150 <__utf8_mbtowc+0xa0>
323062a6:	e7da      	b.n	3230625e <__utf8_mbtowc+0x1ae>

323062a8 <__sjis_mbtowc>:
323062a8:	b470      	push	{r4, r5, r6}
323062aa:	4684      	mov	ip, r0
323062ac:	b083      	sub	sp, #12
323062ae:	9d06      	ldr	r5, [sp, #24]
323062b0:	b379      	cbz	r1, 32306312 <__sjis_mbtowc+0x6a>
323062b2:	4610      	mov	r0, r2
323062b4:	b302      	cbz	r2, 323062f8 <__sjis_mbtowc+0x50>
323062b6:	b373      	cbz	r3, 32306316 <__sjis_mbtowc+0x6e>
323062b8:	6828      	ldr	r0, [r5, #0]
323062ba:	7814      	ldrb	r4, [r2, #0]
323062bc:	b9f8      	cbnz	r0, 323062fe <__sjis_mbtowc+0x56>
323062be:	f1a4 0081 	sub.w	r0, r4, #129	@ 0x81
323062c2:	f1a4 06e0 	sub.w	r6, r4, #224	@ 0xe0
323062c6:	281e      	cmp	r0, #30
323062c8:	bf88      	it	hi
323062ca:	2e0f      	cmphi	r6, #15
323062cc:	d819      	bhi.n	32306302 <__sjis_mbtowc+0x5a>
323062ce:	2001      	movs	r0, #1
323062d0:	712c      	strb	r4, [r5, #4]
323062d2:	4283      	cmp	r3, r0
323062d4:	6028      	str	r0, [r5, #0]
323062d6:	d01e      	beq.n	32306316 <__sjis_mbtowc+0x6e>
323062d8:	7854      	ldrb	r4, [r2, #1]
323062da:	2002      	movs	r0, #2
323062dc:	f1a4 0340 	sub.w	r3, r4, #64	@ 0x40
323062e0:	f1a4 0280 	sub.w	r2, r4, #128	@ 0x80
323062e4:	2b3e      	cmp	r3, #62	@ 0x3e
323062e6:	bf88      	it	hi
323062e8:	2a7c      	cmphi	r2, #124	@ 0x7c
323062ea:	d817      	bhi.n	3230631c <__sjis_mbtowc+0x74>
323062ec:	792b      	ldrb	r3, [r5, #4]
323062ee:	eb04 2403 	add.w	r4, r4, r3, lsl #8
323062f2:	2300      	movs	r3, #0
323062f4:	600c      	str	r4, [r1, #0]
323062f6:	602b      	str	r3, [r5, #0]
323062f8:	b003      	add	sp, #12
323062fa:	bc70      	pop	{r4, r5, r6}
323062fc:	4770      	bx	lr
323062fe:	2801      	cmp	r0, #1
32306300:	d0ec      	beq.n	323062dc <__sjis_mbtowc+0x34>
32306302:	600c      	str	r4, [r1, #0]
32306304:	7810      	ldrb	r0, [r2, #0]
32306306:	3800      	subs	r0, #0
32306308:	bf18      	it	ne
3230630a:	2001      	movne	r0, #1
3230630c:	b003      	add	sp, #12
3230630e:	bc70      	pop	{r4, r5, r6}
32306310:	4770      	bx	lr
32306312:	a901      	add	r1, sp, #4
32306314:	e7cd      	b.n	323062b2 <__sjis_mbtowc+0xa>
32306316:	f06f 0001 	mvn.w	r0, #1
3230631a:	e7ed      	b.n	323062f8 <__sjis_mbtowc+0x50>
3230631c:	238a      	movs	r3, #138	@ 0x8a
3230631e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32306322:	f8cc 3000 	str.w	r3, [ip]
32306326:	e7e7      	b.n	323062f8 <__sjis_mbtowc+0x50>

32306328 <__eucjp_mbtowc>:
32306328:	b570      	push	{r4, r5, r6, lr}
3230632a:	4686      	mov	lr, r0
3230632c:	b082      	sub	sp, #8
3230632e:	9d06      	ldr	r5, [sp, #24]
32306330:	2900      	cmp	r1, #0
32306332:	d040      	beq.n	323063b6 <__eucjp_mbtowc+0x8e>
32306334:	4610      	mov	r0, r2
32306336:	b382      	cbz	r2, 3230639a <__eucjp_mbtowc+0x72>
32306338:	2b00      	cmp	r3, #0
3230633a:	d047      	beq.n	323063cc <__eucjp_mbtowc+0xa4>
3230633c:	6828      	ldr	r0, [r5, #0]
3230633e:	7814      	ldrb	r4, [r2, #0]
32306340:	bb68      	cbnz	r0, 3230639e <__eucjp_mbtowc+0x76>
32306342:	f1a4 068e 	sub.w	r6, r4, #142	@ 0x8e
32306346:	f1a4 00a1 	sub.w	r0, r4, #161	@ 0xa1
3230634a:	2e01      	cmp	r6, #1
3230634c:	bf88      	it	hi
3230634e:	285d      	cmphi	r0, #93	@ 0x5d
32306350:	d82a      	bhi.n	323063a8 <__eucjp_mbtowc+0x80>
32306352:	2001      	movs	r0, #1
32306354:	712c      	strb	r4, [r5, #4]
32306356:	4283      	cmp	r3, r0
32306358:	6028      	str	r0, [r5, #0]
3230635a:	d037      	beq.n	323063cc <__eucjp_mbtowc+0xa4>
3230635c:	f892 c001 	ldrb.w	ip, [r2, #1]
32306360:	2002      	movs	r0, #2
32306362:	f1ac 04a1 	sub.w	r4, ip, #161	@ 0xa1
32306366:	2c5d      	cmp	r4, #93	@ 0x5d
32306368:	d833      	bhi.n	323063d2 <__eucjp_mbtowc+0xaa>
3230636a:	792c      	ldrb	r4, [r5, #4]
3230636c:	2c8f      	cmp	r4, #143	@ 0x8f
3230636e:	d124      	bne.n	323063ba <__eucjp_mbtowc+0x92>
32306370:	2402      	movs	r4, #2
32306372:	4298      	cmp	r0, r3
32306374:	f885 c005 	strb.w	ip, [r5, #5]
32306378:	602c      	str	r4, [r5, #0]
3230637a:	d227      	bcs.n	323063cc <__eucjp_mbtowc+0xa4>
3230637c:	f812 c000 	ldrb.w	ip, [r2, r0]
32306380:	3001      	adds	r0, #1
32306382:	f1ac 03a1 	sub.w	r3, ip, #161	@ 0xa1
32306386:	2b5d      	cmp	r3, #93	@ 0x5d
32306388:	d823      	bhi.n	323063d2 <__eucjp_mbtowc+0xaa>
3230638a:	796b      	ldrb	r3, [r5, #5]
3230638c:	f00c 0c7f 	and.w	ip, ip, #127	@ 0x7f
32306390:	2200      	movs	r2, #0
32306392:	eb0c 2303 	add.w	r3, ip, r3, lsl #8
32306396:	600b      	str	r3, [r1, #0]
32306398:	602a      	str	r2, [r5, #0]
3230639a:	b002      	add	sp, #8
3230639c:	bd70      	pop	{r4, r5, r6, pc}
3230639e:	46a4      	mov	ip, r4
323063a0:	2801      	cmp	r0, #1
323063a2:	d0de      	beq.n	32306362 <__eucjp_mbtowc+0x3a>
323063a4:	2802      	cmp	r0, #2
323063a6:	d00f      	beq.n	323063c8 <__eucjp_mbtowc+0xa0>
323063a8:	600c      	str	r4, [r1, #0]
323063aa:	7810      	ldrb	r0, [r2, #0]
323063ac:	3800      	subs	r0, #0
323063ae:	bf18      	it	ne
323063b0:	2001      	movne	r0, #1
323063b2:	b002      	add	sp, #8
323063b4:	bd70      	pop	{r4, r5, r6, pc}
323063b6:	a901      	add	r1, sp, #4
323063b8:	e7bc      	b.n	32306334 <__eucjp_mbtowc+0xc>
323063ba:	eb0c 2404 	add.w	r4, ip, r4, lsl #8
323063be:	2200      	movs	r2, #0
323063c0:	600c      	str	r4, [r1, #0]
323063c2:	602a      	str	r2, [r5, #0]
323063c4:	b002      	add	sp, #8
323063c6:	bd70      	pop	{r4, r5, r6, pc}
323063c8:	2001      	movs	r0, #1
323063ca:	e7da      	b.n	32306382 <__eucjp_mbtowc+0x5a>
323063cc:	f06f 0001 	mvn.w	r0, #1
323063d0:	e7e3      	b.n	3230639a <__eucjp_mbtowc+0x72>
323063d2:	238a      	movs	r3, #138	@ 0x8a
323063d4:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
323063d8:	f8ce 3000 	str.w	r3, [lr]
323063dc:	e7dd      	b.n	3230639a <__eucjp_mbtowc+0x72>
323063de:	bf00      	nop

323063e0 <__jis_mbtowc>:
323063e0:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
323063e4:	4682      	mov	sl, r0
323063e6:	b083      	sub	sp, #12
323063e8:	f8dd b030 	ldr.w	fp, [sp, #48]	@ 0x30
323063ec:	2900      	cmp	r1, #0
323063ee:	d037      	beq.n	32306460 <__jis_mbtowc+0x80>
323063f0:	2a00      	cmp	r2, #0
323063f2:	d038      	beq.n	32306466 <__jis_mbtowc+0x86>
323063f4:	2b00      	cmp	r3, #0
323063f6:	f000 808f 	beq.w	32306518 <__jis_mbtowc+0x138>
323063fa:	4694      	mov	ip, r2
323063fc:	f64b 5968 	movw	r9, #48488	@ 0xbd68
32306400:	f2c3 2930 	movt	r9, #12848	@ 0x3230
32306404:	4660      	mov	r0, ip
32306406:	f64b 5820 	movw	r8, #48416	@ 0xbd20
3230640a:	f2c3 2830 	movt	r8, #12848	@ 0x3230
3230640e:	f81c 5b01 	ldrb.w	r5, [ip], #1
32306412:	f04f 0e01 	mov.w	lr, #1
32306416:	f89b 4000 	ldrb.w	r4, [fp]
3230641a:	2d00      	cmp	r5, #0
3230641c:	d04b      	beq.n	323064b6 <__jis_mbtowc+0xd6>
3230641e:	f1a5 061b 	sub.w	r6, r5, #27
32306422:	b2f7      	uxtb	r7, r6
32306424:	2f2f      	cmp	r7, #47	@ 0x2f
32306426:	d826      	bhi.n	32306476 <__jis_mbtowc+0x96>
32306428:	2e2f      	cmp	r6, #47	@ 0x2f
3230642a:	d824      	bhi.n	32306476 <__jis_mbtowc+0x96>
3230642c:	e8df f006 	tbb	[pc, r6]
32306430:	23232370 	.word	0x23232370
32306434:	23232323 	.word	0x23232323
32306438:	23236e23 	.word	0x23236e23
3230643c:	23236623 	.word	0x23236623
32306440:	23232323 	.word	0x23232323
32306444:	23232323 	.word	0x23232323
32306448:	23232323 	.word	0x23232323
3230644c:	23232323 	.word	0x23232323
32306450:	23232323 	.word	0x23232323
32306454:	6a236823 	.word	0x6a236823
32306458:	23232323 	.word	0x23232323
3230645c:	6c232323 	.word	0x6c232323
32306460:	a901      	add	r1, sp, #4
32306462:	2a00      	cmp	r2, #0
32306464:	d1c6      	bne.n	323063f4 <__jis_mbtowc+0x14>
32306466:	f04f 0e01 	mov.w	lr, #1
3230646a:	f8cb 2000 	str.w	r2, [fp]
3230646e:	4670      	mov	r0, lr
32306470:	b003      	add	sp, #12
32306472:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32306476:	f1a5 0621 	sub.w	r6, r5, #33	@ 0x21
3230647a:	2708      	movs	r7, #8
3230647c:	2e5d      	cmp	r6, #93	@ 0x5d
3230647e:	bf98      	it	ls
32306480:	2707      	movls	r7, #7
32306482:	eb04 04c4 	add.w	r4, r4, r4, lsl #3
32306486:	eb08 0604 	add.w	r6, r8, r4
3230648a:	444c      	add	r4, r9
3230648c:	5df6      	ldrb	r6, [r6, r7]
3230648e:	5de4      	ldrb	r4, [r4, r7]
32306490:	2e05      	cmp	r6, #5
32306492:	d844      	bhi.n	3230651e <__jis_mbtowc+0x13e>
32306494:	e8df f006 	tbb	[pc, r6]
32306498:	11130320 	.word	0x11130320
3230649c:	2905      	.short	0x2905
3230649e:	f88b 5004 	strb.w	r5, [fp, #4]
323064a2:	f10e 0001 	add.w	r0, lr, #1
323064a6:	4573      	cmp	r3, lr
323064a8:	d934      	bls.n	32306514 <__jis_mbtowc+0x134>
323064aa:	4686      	mov	lr, r0
323064ac:	4660      	mov	r0, ip
323064ae:	f81c 5b01 	ldrb.w	r5, [ip], #1
323064b2:	2d00      	cmp	r5, #0
323064b4:	d1b3      	bne.n	3230641e <__jis_mbtowc+0x3e>
323064b6:	2706      	movs	r7, #6
323064b8:	e7e3      	b.n	32306482 <__jis_mbtowc+0xa2>
323064ba:	4662      	mov	r2, ip
323064bc:	e7f1      	b.n	323064a2 <__jis_mbtowc+0xc2>
323064be:	2301      	movs	r3, #1
323064c0:	f8cb 3000 	str.w	r3, [fp]
323064c4:	f89b 2004 	ldrb.w	r2, [fp, #4]
323064c8:	7803      	ldrb	r3, [r0, #0]
323064ca:	eb03 2302 	add.w	r3, r3, r2, lsl #8
323064ce:	600b      	str	r3, [r1, #0]
323064d0:	4670      	mov	r0, lr
323064d2:	b003      	add	sp, #12
323064d4:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
323064d8:	2300      	movs	r3, #0
323064da:	f8cb 3000 	str.w	r3, [fp]
323064de:	4670      	mov	r0, lr
323064e0:	7813      	ldrb	r3, [r2, #0]
323064e2:	600b      	str	r3, [r1, #0]
323064e4:	b003      	add	sp, #12
323064e6:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
323064ea:	2300      	movs	r3, #0
323064ec:	f8cb 3000 	str.w	r3, [fp]
323064f0:	469e      	mov	lr, r3
323064f2:	600b      	str	r3, [r1, #0]
323064f4:	4670      	mov	r0, lr
323064f6:	b003      	add	sp, #12
323064f8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
323064fc:	2702      	movs	r7, #2
323064fe:	e7c0      	b.n	32306482 <__jis_mbtowc+0xa2>
32306500:	2703      	movs	r7, #3
32306502:	e7be      	b.n	32306482 <__jis_mbtowc+0xa2>
32306504:	2704      	movs	r7, #4
32306506:	e7bc      	b.n	32306482 <__jis_mbtowc+0xa2>
32306508:	2705      	movs	r7, #5
3230650a:	e7ba      	b.n	32306482 <__jis_mbtowc+0xa2>
3230650c:	2701      	movs	r7, #1
3230650e:	e7b8      	b.n	32306482 <__jis_mbtowc+0xa2>
32306510:	2700      	movs	r7, #0
32306512:	e7b6      	b.n	32306482 <__jis_mbtowc+0xa2>
32306514:	f8cb 4000 	str.w	r4, [fp]
32306518:	f06f 0e01 	mvn.w	lr, #1
3230651c:	e7d8      	b.n	323064d0 <__jis_mbtowc+0xf0>
3230651e:	238a      	movs	r3, #138	@ 0x8a
32306520:	f04f 3eff 	mov.w	lr, #4294967295	@ 0xffffffff
32306524:	f8ca 3000 	str.w	r3, [sl]
32306528:	e7d2      	b.n	323064d0 <__jis_mbtowc+0xf0>
3230652a:	bf00      	nop

3230652c <__malloc_lock>:
3230652c:	f245 3050 	movw	r0, #21328	@ 0x5350
32306530:	f2c3 2031 	movt	r0, #12849	@ 0x3231
32306534:	f7fe bb90 	b.w	32304c58 <__retarget_lock_acquire_recursive>

32306538 <__malloc_unlock>:
32306538:	f245 3050 	movw	r0, #21328	@ 0x5350
3230653c:	f2c3 2031 	movt	r0, #12849	@ 0x3231
32306540:	f7fe bb92 	b.w	32304c68 <__retarget_lock_release_recursive>

32306544 <_realloc_r>:
32306544:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32306548:	4616      	mov	r6, r2
3230654a:	b083      	sub	sp, #12
3230654c:	2900      	cmp	r1, #0
3230654e:	f000 80bd 	beq.w	323066cc <_realloc_r+0x188>
32306552:	460c      	mov	r4, r1
32306554:	4680      	mov	r8, r0
32306556:	f7ff ffe9 	bl	3230652c <__malloc_lock>
3230655a:	f106 050b 	add.w	r5, r6, #11
3230655e:	f1a4 0908 	sub.w	r9, r4, #8
32306562:	2d16      	cmp	r5, #22
32306564:	f854 0c04 	ldr.w	r0, [r4, #-4]
32306568:	f020 0703 	bic.w	r7, r0, #3
3230656c:	d872      	bhi.n	32306654 <_realloc_r+0x110>
3230656e:	2210      	movs	r2, #16
32306570:	2300      	movs	r3, #0
32306572:	4615      	mov	r5, r2
32306574:	42b5      	cmp	r5, r6
32306576:	bf28      	it	cs
32306578:	2100      	movcs	r1, #0
3230657a:	bf38      	it	cc
3230657c:	2101      	movcc	r1, #1
3230657e:	430b      	orrs	r3, r1
32306580:	d174      	bne.n	3230666c <_realloc_r+0x128>
32306582:	4297      	cmp	r7, r2
32306584:	da7f      	bge.n	32306686 <_realloc_r+0x142>
32306586:	f24c 3af0 	movw	sl, #50160	@ 0xc3f0
3230658a:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
3230658e:	eb09 0107 	add.w	r1, r9, r7
32306592:	f8da 3008 	ldr.w	r3, [sl, #8]
32306596:	f8d1 c004 	ldr.w	ip, [r1, #4]
3230659a:	428b      	cmp	r3, r1
3230659c:	f000 80ae 	beq.w	323066fc <_realloc_r+0x1b8>
323065a0:	f02c 0301 	bic.w	r3, ip, #1
323065a4:	440b      	add	r3, r1
323065a6:	685b      	ldr	r3, [r3, #4]
323065a8:	07db      	lsls	r3, r3, #31
323065aa:	f100 8084 	bmi.w	323066b6 <_realloc_r+0x172>
323065ae:	f02c 0c03 	bic.w	ip, ip, #3
323065b2:	eb07 030c 	add.w	r3, r7, ip
323065b6:	4293      	cmp	r3, r2
323065b8:	da60      	bge.n	3230667c <_realloc_r+0x138>
323065ba:	07c3      	lsls	r3, r0, #31
323065bc:	d412      	bmi.n	323065e4 <_realloc_r+0xa0>
323065be:	f854 3c08 	ldr.w	r3, [r4, #-8]
323065c2:	eba9 0b03 	sub.w	fp, r9, r3
323065c6:	f8db 3004 	ldr.w	r3, [fp, #4]
323065ca:	f023 0003 	bic.w	r0, r3, #3
323065ce:	4484      	add	ip, r0
323065d0:	eb0c 0a07 	add.w	sl, ip, r7
323065d4:	4552      	cmp	r2, sl
323065d6:	f340 810c 	ble.w	323067f2 <_realloc_r+0x2ae>
323065da:	eb07 0a00 	add.w	sl, r7, r0
323065de:	4552      	cmp	r2, sl
323065e0:	f340 80e0 	ble.w	323067a4 <_realloc_r+0x260>
323065e4:	4631      	mov	r1, r6
323065e6:	4640      	mov	r0, r8
323065e8:	f7ff fa4e 	bl	32305a88 <_malloc_r>
323065ec:	4606      	mov	r6, r0
323065ee:	2800      	cmp	r0, #0
323065f0:	f000 8135 	beq.w	3230685e <_realloc_r+0x31a>
323065f4:	f854 3c04 	ldr.w	r3, [r4, #-4]
323065f8:	f1a0 0208 	sub.w	r2, r0, #8
323065fc:	f023 0301 	bic.w	r3, r3, #1
32306600:	444b      	add	r3, r9
32306602:	4293      	cmp	r3, r2
32306604:	f000 80c8 	beq.w	32306798 <_realloc_r+0x254>
32306608:	1f3a      	subs	r2, r7, #4
3230660a:	2a24      	cmp	r2, #36	@ 0x24
3230660c:	f200 80ed 	bhi.w	323067ea <_realloc_r+0x2a6>
32306610:	2a13      	cmp	r2, #19
32306612:	bf98      	it	ls
32306614:	4603      	movls	r3, r0
32306616:	bf98      	it	ls
32306618:	4622      	movls	r2, r4
3230661a:	d90a      	bls.n	32306632 <_realloc_r+0xee>
3230661c:	6823      	ldr	r3, [r4, #0]
3230661e:	2a1b      	cmp	r2, #27
32306620:	6003      	str	r3, [r0, #0]
32306622:	6863      	ldr	r3, [r4, #4]
32306624:	6043      	str	r3, [r0, #4]
32306626:	f200 80ef 	bhi.w	32306808 <_realloc_r+0x2c4>
3230662a:	f104 0208 	add.w	r2, r4, #8
3230662e:	f100 0308 	add.w	r3, r0, #8
32306632:	6811      	ldr	r1, [r2, #0]
32306634:	6019      	str	r1, [r3, #0]
32306636:	6851      	ldr	r1, [r2, #4]
32306638:	6059      	str	r1, [r3, #4]
3230663a:	6892      	ldr	r2, [r2, #8]
3230663c:	609a      	str	r2, [r3, #8]
3230663e:	4621      	mov	r1, r4
32306640:	4640      	mov	r0, r8
32306642:	f7ff f8d1 	bl	323057e8 <_free_r>
32306646:	4640      	mov	r0, r8
32306648:	f7ff ff76 	bl	32306538 <__malloc_unlock>
3230664c:	4630      	mov	r0, r6
3230664e:	b003      	add	sp, #12
32306650:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32306654:	f025 0507 	bic.w	r5, r5, #7
32306658:	42b5      	cmp	r5, r6
3230665a:	462a      	mov	r2, r5
3230665c:	ea4f 73d5 	mov.w	r3, r5, lsr #31
32306660:	bf28      	it	cs
32306662:	2100      	movcs	r1, #0
32306664:	bf38      	it	cc
32306666:	2101      	movcc	r1, #1
32306668:	430b      	orrs	r3, r1
3230666a:	d08a      	beq.n	32306582 <_realloc_r+0x3e>
3230666c:	230c      	movs	r3, #12
3230666e:	f8c8 3000 	str.w	r3, [r8]
32306672:	2600      	movs	r6, #0
32306674:	4630      	mov	r0, r6
32306676:	b003      	add	sp, #12
32306678:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230667c:	461f      	mov	r7, r3
3230667e:	e9d1 2302 	ldrd	r2, r3, [r1, #8]
32306682:	60d3      	str	r3, [r2, #12]
32306684:	609a      	str	r2, [r3, #8]
32306686:	f8d9 3004 	ldr.w	r3, [r9, #4]
3230668a:	1b78      	subs	r0, r7, r5
3230668c:	eb09 0207 	add.w	r2, r9, r7
32306690:	280f      	cmp	r0, #15
32306692:	f003 0301 	and.w	r3, r3, #1
32306696:	d81f      	bhi.n	323066d8 <_realloc_r+0x194>
32306698:	433b      	orrs	r3, r7
3230669a:	f8c9 3004 	str.w	r3, [r9, #4]
3230669e:	6853      	ldr	r3, [r2, #4]
323066a0:	f043 0301 	orr.w	r3, r3, #1
323066a4:	6053      	str	r3, [r2, #4]
323066a6:	4626      	mov	r6, r4
323066a8:	4640      	mov	r0, r8
323066aa:	f7ff ff45 	bl	32306538 <__malloc_unlock>
323066ae:	4630      	mov	r0, r6
323066b0:	b003      	add	sp, #12
323066b2:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
323066b6:	07c3      	lsls	r3, r0, #31
323066b8:	d494      	bmi.n	323065e4 <_realloc_r+0xa0>
323066ba:	f854 3c08 	ldr.w	r3, [r4, #-8]
323066be:	eba9 0b03 	sub.w	fp, r9, r3
323066c2:	f8db 3004 	ldr.w	r3, [fp, #4]
323066c6:	f023 0003 	bic.w	r0, r3, #3
323066ca:	e786      	b.n	323065da <_realloc_r+0x96>
323066cc:	4611      	mov	r1, r2
323066ce:	b003      	add	sp, #12
323066d0:	e8bd 4ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
323066d4:	f7ff b9d8 	b.w	32305a88 <_malloc_r>
323066d8:	eb09 0105 	add.w	r1, r9, r5
323066dc:	432b      	orrs	r3, r5
323066de:	f040 0001 	orr.w	r0, r0, #1
323066e2:	f8c9 3004 	str.w	r3, [r9, #4]
323066e6:	3108      	adds	r1, #8
323066e8:	f841 0c04 	str.w	r0, [r1, #-4]
323066ec:	4640      	mov	r0, r8
323066ee:	6853      	ldr	r3, [r2, #4]
323066f0:	f043 0301 	orr.w	r3, r3, #1
323066f4:	6053      	str	r3, [r2, #4]
323066f6:	f7ff f877 	bl	323057e8 <_free_r>
323066fa:	e7d4      	b.n	323066a6 <_realloc_r+0x162>
323066fc:	f02c 0c03 	bic.w	ip, ip, #3
32306700:	f105 0110 	add.w	r1, r5, #16
32306704:	eb0c 0307 	add.w	r3, ip, r7
32306708:	428b      	cmp	r3, r1
3230670a:	f280 8088 	bge.w	3230681e <_realloc_r+0x2da>
3230670e:	07c0      	lsls	r0, r0, #31
32306710:	f53f af68 	bmi.w	323065e4 <_realloc_r+0xa0>
32306714:	f854 3c08 	ldr.w	r3, [r4, #-8]
32306718:	eba9 0b03 	sub.w	fp, r9, r3
3230671c:	f8db 3004 	ldr.w	r3, [fp, #4]
32306720:	f023 0003 	bic.w	r0, r3, #3
32306724:	4484      	add	ip, r0
32306726:	eb0c 0307 	add.w	r3, ip, r7
3230672a:	4299      	cmp	r1, r3
3230672c:	f73f af55 	bgt.w	323065da <_realloc_r+0x96>
32306730:	465e      	mov	r6, fp
32306732:	f8db 100c 	ldr.w	r1, [fp, #12]
32306736:	1f3a      	subs	r2, r7, #4
32306738:	2a24      	cmp	r2, #36	@ 0x24
3230673a:	f856 0f08 	ldr.w	r0, [r6, #8]!
3230673e:	60c1      	str	r1, [r0, #12]
32306740:	6088      	str	r0, [r1, #8]
32306742:	f200 80a4 	bhi.w	3230688e <_realloc_r+0x34a>
32306746:	2a13      	cmp	r2, #19
32306748:	bf98      	it	ls
3230674a:	4632      	movls	r2, r6
3230674c:	d90b      	bls.n	32306766 <_realloc_r+0x222>
3230674e:	6821      	ldr	r1, [r4, #0]
32306750:	2a1b      	cmp	r2, #27
32306752:	f8cb 1008 	str.w	r1, [fp, #8]
32306756:	6861      	ldr	r1, [r4, #4]
32306758:	f8cb 100c 	str.w	r1, [fp, #12]
3230675c:	f200 809e 	bhi.w	3230689c <_realloc_r+0x358>
32306760:	3408      	adds	r4, #8
32306762:	f10b 0210 	add.w	r2, fp, #16
32306766:	6821      	ldr	r1, [r4, #0]
32306768:	6011      	str	r1, [r2, #0]
3230676a:	6861      	ldr	r1, [r4, #4]
3230676c:	6051      	str	r1, [r2, #4]
3230676e:	68a1      	ldr	r1, [r4, #8]
32306770:	6091      	str	r1, [r2, #8]
32306772:	eb0b 0205 	add.w	r2, fp, r5
32306776:	1b5b      	subs	r3, r3, r5
32306778:	f8ca 2008 	str.w	r2, [sl, #8]
3230677c:	f043 0301 	orr.w	r3, r3, #1
32306780:	4640      	mov	r0, r8
32306782:	6053      	str	r3, [r2, #4]
32306784:	f8db 3004 	ldr.w	r3, [fp, #4]
32306788:	f003 0301 	and.w	r3, r3, #1
3230678c:	432b      	orrs	r3, r5
3230678e:	f8cb 3004 	str.w	r3, [fp, #4]
32306792:	f7ff fed1 	bl	32306538 <__malloc_unlock>
32306796:	e78a      	b.n	323066ae <_realloc_r+0x16a>
32306798:	f850 3c04 	ldr.w	r3, [r0, #-4]
3230679c:	f023 0303 	bic.w	r3, r3, #3
323067a0:	441f      	add	r7, r3
323067a2:	e770      	b.n	32306686 <_realloc_r+0x142>
323067a4:	1f3a      	subs	r2, r7, #4
323067a6:	465e      	mov	r6, fp
323067a8:	f8db 300c 	ldr.w	r3, [fp, #12]
323067ac:	2a24      	cmp	r2, #36	@ 0x24
323067ae:	f856 1f08 	ldr.w	r1, [r6, #8]!
323067b2:	60cb      	str	r3, [r1, #12]
323067b4:	6099      	str	r1, [r3, #8]
323067b6:	d822      	bhi.n	323067fe <_realloc_r+0x2ba>
323067b8:	2a13      	cmp	r2, #19
323067ba:	bf98      	it	ls
323067bc:	4633      	movls	r3, r6
323067be:	d90a      	bls.n	323067d6 <_realloc_r+0x292>
323067c0:	6823      	ldr	r3, [r4, #0]
323067c2:	2a1b      	cmp	r2, #27
323067c4:	f8cb 3008 	str.w	r3, [fp, #8]
323067c8:	6863      	ldr	r3, [r4, #4]
323067ca:	f8cb 300c 	str.w	r3, [fp, #12]
323067ce:	d83a      	bhi.n	32306846 <_realloc_r+0x302>
323067d0:	3408      	adds	r4, #8
323067d2:	f10b 0310 	add.w	r3, fp, #16
323067d6:	6822      	ldr	r2, [r4, #0]
323067d8:	601a      	str	r2, [r3, #0]
323067da:	6862      	ldr	r2, [r4, #4]
323067dc:	605a      	str	r2, [r3, #4]
323067de:	68a2      	ldr	r2, [r4, #8]
323067e0:	609a      	str	r2, [r3, #8]
323067e2:	4634      	mov	r4, r6
323067e4:	4657      	mov	r7, sl
323067e6:	46d9      	mov	r9, fp
323067e8:	e74d      	b.n	32306686 <_realloc_r+0x142>
323067ea:	4621      	mov	r1, r4
323067ec:	f7fd fbbe 	bl	32303f6c <memmove>
323067f0:	e725      	b.n	3230663e <_realloc_r+0xfa>
323067f2:	e9d1 1302 	ldrd	r1, r3, [r1, #8]
323067f6:	60cb      	str	r3, [r1, #12]
323067f8:	1f3a      	subs	r2, r7, #4
323067fa:	6099      	str	r1, [r3, #8]
323067fc:	e7d3      	b.n	323067a6 <_realloc_r+0x262>
323067fe:	4621      	mov	r1, r4
32306800:	4630      	mov	r0, r6
32306802:	f7fd fbb3 	bl	32303f6c <memmove>
32306806:	e7ec      	b.n	323067e2 <_realloc_r+0x29e>
32306808:	68a3      	ldr	r3, [r4, #8]
3230680a:	2a24      	cmp	r2, #36	@ 0x24
3230680c:	6083      	str	r3, [r0, #8]
3230680e:	68e3      	ldr	r3, [r4, #12]
32306810:	60c3      	str	r3, [r0, #12]
32306812:	d028      	beq.n	32306866 <_realloc_r+0x322>
32306814:	f104 0210 	add.w	r2, r4, #16
32306818:	f100 0310 	add.w	r3, r0, #16
3230681c:	e709      	b.n	32306632 <_realloc_r+0xee>
3230681e:	eb09 0205 	add.w	r2, r9, r5
32306822:	1b5b      	subs	r3, r3, r5
32306824:	f8ca 2008 	str.w	r2, [sl, #8]
32306828:	f043 0301 	orr.w	r3, r3, #1
3230682c:	4640      	mov	r0, r8
3230682e:	4626      	mov	r6, r4
32306830:	6053      	str	r3, [r2, #4]
32306832:	f854 3c04 	ldr.w	r3, [r4, #-4]
32306836:	f003 0301 	and.w	r3, r3, #1
3230683a:	432b      	orrs	r3, r5
3230683c:	f844 3c04 	str.w	r3, [r4, #-4]
32306840:	f7ff fe7a 	bl	32306538 <__malloc_unlock>
32306844:	e733      	b.n	323066ae <_realloc_r+0x16a>
32306846:	68a3      	ldr	r3, [r4, #8]
32306848:	2a24      	cmp	r2, #36	@ 0x24
3230684a:	f8cb 3010 	str.w	r3, [fp, #16]
3230684e:	68e3      	ldr	r3, [r4, #12]
32306850:	f8cb 3014 	str.w	r3, [fp, #20]
32306854:	d010      	beq.n	32306878 <_realloc_r+0x334>
32306856:	3410      	adds	r4, #16
32306858:	f10b 0318 	add.w	r3, fp, #24
3230685c:	e7bb      	b.n	323067d6 <_realloc_r+0x292>
3230685e:	4640      	mov	r0, r8
32306860:	f7ff fe6a 	bl	32306538 <__malloc_unlock>
32306864:	e705      	b.n	32306672 <_realloc_r+0x12e>
32306866:	6923      	ldr	r3, [r4, #16]
32306868:	f104 0218 	add.w	r2, r4, #24
3230686c:	6103      	str	r3, [r0, #16]
3230686e:	f100 0318 	add.w	r3, r0, #24
32306872:	6961      	ldr	r1, [r4, #20]
32306874:	6141      	str	r1, [r0, #20]
32306876:	e6dc      	b.n	32306632 <_realloc_r+0xee>
32306878:	6923      	ldr	r3, [r4, #16]
3230687a:	3418      	adds	r4, #24
3230687c:	f8cb 3018 	str.w	r3, [fp, #24]
32306880:	f10b 0320 	add.w	r3, fp, #32
32306884:	f854 2c04 	ldr.w	r2, [r4, #-4]
32306888:	f8cb 201c 	str.w	r2, [fp, #28]
3230688c:	e7a3      	b.n	323067d6 <_realloc_r+0x292>
3230688e:	4621      	mov	r1, r4
32306890:	4630      	mov	r0, r6
32306892:	9301      	str	r3, [sp, #4]
32306894:	f7fd fb6a 	bl	32303f6c <memmove>
32306898:	9b01      	ldr	r3, [sp, #4]
3230689a:	e76a      	b.n	32306772 <_realloc_r+0x22e>
3230689c:	68a1      	ldr	r1, [r4, #8]
3230689e:	2a24      	cmp	r2, #36	@ 0x24
323068a0:	f8cb 1010 	str.w	r1, [fp, #16]
323068a4:	68e1      	ldr	r1, [r4, #12]
323068a6:	f8cb 1014 	str.w	r1, [fp, #20]
323068aa:	d003      	beq.n	323068b4 <_realloc_r+0x370>
323068ac:	3410      	adds	r4, #16
323068ae:	f10b 0218 	add.w	r2, fp, #24
323068b2:	e758      	b.n	32306766 <_realloc_r+0x222>
323068b4:	6922      	ldr	r2, [r4, #16]
323068b6:	3418      	adds	r4, #24
323068b8:	f8cb 2018 	str.w	r2, [fp, #24]
323068bc:	f10b 0220 	add.w	r2, fp, #32
323068c0:	f854 1c04 	ldr.w	r1, [r4, #-4]
323068c4:	f8cb 101c 	str.w	r1, [fp, #28]
323068c8:	e74d      	b.n	32306766 <_realloc_r+0x222>
323068ca:	bf00      	nop

323068cc <_strtol_l.part.0>:
323068cc:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
323068d0:	4690      	mov	r8, r2
323068d2:	4a7c      	ldr	r2, [pc, #496]	@ (32306ac4 <_strtol_l.part.0+0x1f8>)
323068d4:	b083      	sub	sp, #12
323068d6:	4682      	mov	sl, r0
323068d8:	460d      	mov	r5, r1
323068da:	4628      	mov	r0, r5
323068dc:	f815 eb01 	ldrb.w	lr, [r5], #1
323068e0:	f812 600e 	ldrb.w	r6, [r2, lr]
323068e4:	f016 0608 	ands.w	r6, r6, #8
323068e8:	d1f7      	bne.n	323068da <_strtol_l.part.0+0xe>
323068ea:	f023 0210 	bic.w	r2, r3, #16
323068ee:	f1be 0f2d 	cmp.w	lr, #45	@ 0x2d
323068f2:	d072      	beq.n	323069da <_strtol_l.part.0+0x10e>
323068f4:	f1be 0f2b 	cmp.w	lr, #43	@ 0x2b
323068f8:	d011      	beq.n	3230691e <_strtol_l.part.0+0x52>
323068fa:	b9aa      	cbnz	r2, 32306928 <_strtol_l.part.0+0x5c>
323068fc:	f1be 0f30 	cmp.w	lr, #48	@ 0x30
32306900:	f000 80aa 	beq.w	32306a58 <_strtol_l.part.0+0x18c>
32306904:	2b00      	cmp	r3, #0
32306906:	f000 809f 	beq.w	32306a48 <_strtol_l.part.0+0x17c>
3230690a:	2310      	movs	r3, #16
3230690c:	f06f 4778 	mvn.w	r7, #4160749568	@ 0xf8000000
32306910:	220f      	movs	r2, #15
32306912:	4699      	mov	r9, r3
32306914:	2000      	movs	r0, #0
32306916:	f06f 4b00 	mvn.w	fp, #2147483648	@ 0x80000000
3230691a:	9001      	str	r0, [sp, #4]
3230691c:	e00d      	b.n	3230693a <_strtol_l.part.0+0x6e>
3230691e:	f895 e000 	ldrb.w	lr, [r5]
32306922:	1c85      	adds	r5, r0, #2
32306924:	2a00      	cmp	r2, #0
32306926:	d07a      	beq.n	32306a1e <_strtol_l.part.0+0x152>
32306928:	f06f 4200 	mvn.w	r2, #2147483648	@ 0x80000000
3230692c:	4699      	mov	r9, r3
3230692e:	4693      	mov	fp, r2
32306930:	9601      	str	r6, [sp, #4]
32306932:	fbb2 f7f3 	udiv	r7, r2, r3
32306936:	fb03 2217 	mls	r2, r3, r7, r2
3230693a:	2400      	movs	r4, #0
3230693c:	4620      	mov	r0, r4
3230693e:	e00d      	b.n	3230695c <_strtol_l.part.0+0x90>
32306940:	1bc4      	subs	r4, r0, r7
32306942:	4594      	cmp	ip, r2
32306944:	fab4 f484 	clz	r4, r4
32306948:	ea4f 1454 	mov.w	r4, r4, lsr #5
3230694c:	bfd8      	it	le
3230694e:	2400      	movle	r4, #0
32306950:	b9f4      	cbnz	r4, 32306990 <_strtol_l.part.0+0xc4>
32306952:	fb09 c000 	mla	r0, r9, r0, ip
32306956:	2401      	movs	r4, #1
32306958:	f815 eb01 	ldrb.w	lr, [r5], #1
3230695c:	f1ae 0c30 	sub.w	ip, lr, #48	@ 0x30
32306960:	f1bc 0f09 	cmp.w	ip, #9
32306964:	d906      	bls.n	32306974 <_strtol_l.part.0+0xa8>
32306966:	f1ae 0c41 	sub.w	ip, lr, #65	@ 0x41
3230696a:	f1bc 0f19 	cmp.w	ip, #25
3230696e:	d812      	bhi.n	32306996 <_strtol_l.part.0+0xca>
32306970:	f1ae 0c37 	sub.w	ip, lr, #55	@ 0x37
32306974:	459c      	cmp	ip, r3
32306976:	da17      	bge.n	323069a8 <_strtol_l.part.0+0xdc>
32306978:	f1a4 34ff 	sub.w	r4, r4, #4294967295	@ 0xffffffff
3230697c:	42b8      	cmp	r0, r7
3230697e:	fab4 f484 	clz	r4, r4
32306982:	bf98      	it	ls
32306984:	2600      	movls	r6, #0
32306986:	bf88      	it	hi
32306988:	2601      	movhi	r6, #1
3230698a:	0964      	lsrs	r4, r4, #5
3230698c:	4334      	orrs	r4, r6
3230698e:	d0d7      	beq.n	32306940 <_strtol_l.part.0+0x74>
32306990:	f04f 34ff 	mov.w	r4, #4294967295	@ 0xffffffff
32306994:	e7e0      	b.n	32306958 <_strtol_l.part.0+0x8c>
32306996:	f1ae 0c61 	sub.w	ip, lr, #97	@ 0x61
3230699a:	f1bc 0f19 	cmp.w	ip, #25
3230699e:	d803      	bhi.n	323069a8 <_strtol_l.part.0+0xdc>
323069a0:	f1ae 0c57 	sub.w	ip, lr, #87	@ 0x57
323069a4:	459c      	cmp	ip, r3
323069a6:	dbe7      	blt.n	32306978 <_strtol_l.part.0+0xac>
323069a8:	1c63      	adds	r3, r4, #1
323069aa:	d00c      	beq.n	323069c6 <_strtol_l.part.0+0xfa>
323069ac:	9b01      	ldr	r3, [sp, #4]
323069ae:	b103      	cbz	r3, 323069b2 <_strtol_l.part.0+0xe6>
323069b0:	4240      	negs	r0, r0
323069b2:	f1b8 0f00 	cmp.w	r8, #0
323069b6:	d003      	beq.n	323069c0 <_strtol_l.part.0+0xf4>
323069b8:	2c00      	cmp	r4, #0
323069ba:	d15c      	bne.n	32306a76 <_strtol_l.part.0+0x1aa>
323069bc:	f8c8 1000 	str.w	r1, [r8]
323069c0:	b003      	add	sp, #12
323069c2:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
323069c6:	2322      	movs	r3, #34	@ 0x22
323069c8:	4658      	mov	r0, fp
323069ca:	f8ca 3000 	str.w	r3, [sl]
323069ce:	f1b8 0f00 	cmp.w	r8, #0
323069d2:	d0f5      	beq.n	323069c0 <_strtol_l.part.0+0xf4>
323069d4:	1e69      	subs	r1, r5, #1
323069d6:	4658      	mov	r0, fp
323069d8:	e7f0      	b.n	323069bc <_strtol_l.part.0+0xf0>
323069da:	f895 e000 	ldrb.w	lr, [r5]
323069de:	1c85      	adds	r5, r0, #2
323069e0:	b982      	cbnz	r2, 32306a04 <_strtol_l.part.0+0x138>
323069e2:	f1be 0f30 	cmp.w	lr, #48	@ 0x30
323069e6:	d048      	beq.n	32306a7a <_strtol_l.part.0+0x1ae>
323069e8:	2b00      	cmp	r3, #0
323069ea:	d156      	bne.n	32306a9a <_strtol_l.part.0+0x1ce>
323069ec:	230a      	movs	r3, #10
323069ee:	2001      	movs	r0, #1
323069f0:	f64c 47cc 	movw	r7, #52428	@ 0xcccc
323069f4:	f6c0 47cc 	movt	r7, #3276	@ 0xccc
323069f8:	2208      	movs	r2, #8
323069fa:	4699      	mov	r9, r3
323069fc:	f04f 4b00 	mov.w	fp, #2147483648	@ 0x80000000
32306a00:	9001      	str	r0, [sp, #4]
32306a02:	e79a      	b.n	3230693a <_strtol_l.part.0+0x6e>
32306a04:	f04f 4700 	mov.w	r7, #2147483648	@ 0x80000000
32306a08:	2201      	movs	r2, #1
32306a0a:	46bb      	mov	fp, r7
32306a0c:	9201      	str	r2, [sp, #4]
32306a0e:	4699      	mov	r9, r3
32306a10:	fbb7 f7f3 	udiv	r7, r7, r3
32306a14:	fb03 f207 	mul.w	r2, r3, r7
32306a18:	ebab 0202 	sub.w	r2, fp, r2
32306a1c:	e78d      	b.n	3230693a <_strtol_l.part.0+0x6e>
32306a1e:	f1be 0f30 	cmp.w	lr, #48	@ 0x30
32306a22:	f47f af6f 	bne.w	32306904 <_strtol_l.part.0+0x38>
32306a26:	7882      	ldrb	r2, [r0, #2]
32306a28:	f002 02df 	and.w	r2, r2, #223	@ 0xdf
32306a2c:	2a58      	cmp	r2, #88	@ 0x58
32306a2e:	d11e      	bne.n	32306a6e <_strtol_l.part.0+0x1a2>
32306a30:	2310      	movs	r3, #16
32306a32:	f890 e003 	ldrb.w	lr, [r0, #3]
32306a36:	1d05      	adds	r5, r0, #4
32306a38:	4699      	mov	r9, r3
32306a3a:	f06f 4200 	mvn.w	r2, #2147483648	@ 0x80000000
32306a3e:	fbb2 f7f9 	udiv	r7, r2, r9
32306a42:	fb09 2217 	mls	r2, r9, r7, r2
32306a46:	e765      	b.n	32306914 <_strtol_l.part.0+0x48>
32306a48:	230a      	movs	r3, #10
32306a4a:	f64c 47cc 	movw	r7, #52428	@ 0xcccc
32306a4e:	f6c0 47cc 	movt	r7, #3276	@ 0xccc
32306a52:	2207      	movs	r2, #7
32306a54:	4699      	mov	r9, r3
32306a56:	e75d      	b.n	32306914 <_strtol_l.part.0+0x48>
32306a58:	782a      	ldrb	r2, [r5, #0]
32306a5a:	f002 02df 	and.w	r2, r2, #223	@ 0xdf
32306a5e:	2a58      	cmp	r2, #88	@ 0x58
32306a60:	d105      	bne.n	32306a6e <_strtol_l.part.0+0x1a2>
32306a62:	2310      	movs	r3, #16
32306a64:	f895 e001 	ldrb.w	lr, [r5, #1]
32306a68:	4699      	mov	r9, r3
32306a6a:	1cc5      	adds	r5, r0, #3
32306a6c:	e7e5      	b.n	32306a3a <_strtol_l.part.0+0x16e>
32306a6e:	bb1b      	cbnz	r3, 32306ab8 <_strtol_l.part.0+0x1ec>
32306a70:	2308      	movs	r3, #8
32306a72:	4699      	mov	r9, r3
32306a74:	e7e1      	b.n	32306a3a <_strtol_l.part.0+0x16e>
32306a76:	4683      	mov	fp, r0
32306a78:	e7ac      	b.n	323069d4 <_strtol_l.part.0+0x108>
32306a7a:	7884      	ldrb	r4, [r0, #2]
32306a7c:	f004 04df 	and.w	r4, r4, #223	@ 0xdf
32306a80:	2c58      	cmp	r4, #88	@ 0x58
32306a82:	d013      	beq.n	32306aac <_strtol_l.part.0+0x1e0>
32306a84:	b1db      	cbz	r3, 32306abe <_strtol_l.part.0+0x1f2>
32306a86:	2310      	movs	r3, #16
32306a88:	4699      	mov	r9, r3
32306a8a:	f04f 4700 	mov.w	r7, #2147483648	@ 0x80000000
32306a8e:	2001      	movs	r0, #1
32306a90:	46bb      	mov	fp, r7
32306a92:	9001      	str	r0, [sp, #4]
32306a94:	fbb7 f7f9 	udiv	r7, r7, r9
32306a98:	e74f      	b.n	3230693a <_strtol_l.part.0+0x6e>
32306a9a:	2310      	movs	r3, #16
32306a9c:	2001      	movs	r0, #1
32306a9e:	f04f 6700 	mov.w	r7, #134217728	@ 0x8000000
32306aa2:	4699      	mov	r9, r3
32306aa4:	f04f 4b00 	mov.w	fp, #2147483648	@ 0x80000000
32306aa8:	9001      	str	r0, [sp, #4]
32306aaa:	e746      	b.n	3230693a <_strtol_l.part.0+0x6e>
32306aac:	2310      	movs	r3, #16
32306aae:	f890 e003 	ldrb.w	lr, [r0, #3]
32306ab2:	1d05      	adds	r5, r0, #4
32306ab4:	4699      	mov	r9, r3
32306ab6:	e7e8      	b.n	32306a8a <_strtol_l.part.0+0x1be>
32306ab8:	2310      	movs	r3, #16
32306aba:	4699      	mov	r9, r3
32306abc:	e7bd      	b.n	32306a3a <_strtol_l.part.0+0x16e>
32306abe:	2308      	movs	r3, #8
32306ac0:	4699      	mov	r9, r3
32306ac2:	e7e2      	b.n	32306a8a <_strtol_l.part.0+0x1be>
32306ac4:	3230bdb1 	.word	0x3230bdb1

32306ac8 <_strtol_r>:
32306ac8:	b570      	push	{r4, r5, r6, lr}
32306aca:	f1a3 0401 	sub.w	r4, r3, #1
32306ace:	fab4 f484 	clz	r4, r4
32306ad2:	2b24      	cmp	r3, #36	@ 0x24
32306ad4:	bf98      	it	ls
32306ad6:	2500      	movls	r5, #0
32306ad8:	bf88      	it	hi
32306ada:	2501      	movhi	r5, #1
32306adc:	0964      	lsrs	r4, r4, #5
32306ade:	4325      	orrs	r5, r4
32306ae0:	d103      	bne.n	32306aea <_strtol_r+0x22>
32306ae2:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
32306ae6:	f7ff bef1 	b.w	323068cc <_strtol_l.part.0>
32306aea:	f7fe f8a5 	bl	32304c38 <__errno>
32306aee:	2316      	movs	r3, #22
32306af0:	6003      	str	r3, [r0, #0]
32306af2:	2000      	movs	r0, #0
32306af4:	bd70      	pop	{r4, r5, r6, pc}
32306af6:	bf00      	nop

32306af8 <strtol_l>:
32306af8:	b570      	push	{r4, r5, r6, lr}
32306afa:	f1a2 0501 	sub.w	r5, r2, #1
32306afe:	fab5 f585 	clz	r5, r5
32306b02:	2a24      	cmp	r2, #36	@ 0x24
32306b04:	bf98      	it	ls
32306b06:	2400      	movls	r4, #0
32306b08:	bf88      	it	hi
32306b0a:	2401      	movhi	r4, #1
32306b0c:	096d      	lsrs	r5, r5, #5
32306b0e:	432c      	orrs	r4, r5
32306b10:	d10b      	bne.n	32306b2a <strtol_l+0x32>
32306b12:	f24c 24a0 	movw	r4, #49824	@ 0xc2a0
32306b16:	f2c3 2430 	movt	r4, #12848	@ 0x3230
32306b1a:	4613      	mov	r3, r2
32306b1c:	460a      	mov	r2, r1
32306b1e:	4601      	mov	r1, r0
32306b20:	6820      	ldr	r0, [r4, #0]
32306b22:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
32306b26:	f7ff bed1 	b.w	323068cc <_strtol_l.part.0>
32306b2a:	f7fe f885 	bl	32304c38 <__errno>
32306b2e:	2316      	movs	r3, #22
32306b30:	6003      	str	r3, [r0, #0]
32306b32:	2000      	movs	r0, #0
32306b34:	bd70      	pop	{r4, r5, r6, pc}
32306b36:	bf00      	nop

32306b38 <strtol>:
32306b38:	b570      	push	{r4, r5, r6, lr}
32306b3a:	f1a2 0501 	sub.w	r5, r2, #1
32306b3e:	fab5 f585 	clz	r5, r5
32306b42:	2a24      	cmp	r2, #36	@ 0x24
32306b44:	bf98      	it	ls
32306b46:	2400      	movls	r4, #0
32306b48:	bf88      	it	hi
32306b4a:	2401      	movhi	r4, #1
32306b4c:	096d      	lsrs	r5, r5, #5
32306b4e:	432c      	orrs	r4, r5
32306b50:	d10b      	bne.n	32306b6a <strtol+0x32>
32306b52:	f24c 24a0 	movw	r4, #49824	@ 0xc2a0
32306b56:	f2c3 2430 	movt	r4, #12848	@ 0x3230
32306b5a:	4613      	mov	r3, r2
32306b5c:	460a      	mov	r2, r1
32306b5e:	4601      	mov	r1, r0
32306b60:	6820      	ldr	r0, [r4, #0]
32306b62:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
32306b66:	f7ff beb1 	b.w	323068cc <_strtol_l.part.0>
32306b6a:	f7fe f865 	bl	32304c38 <__errno>
32306b6e:	2316      	movs	r3, #22
32306b70:	6003      	str	r3, [r0, #0]
32306b72:	2000      	movs	r0, #0
32306b74:	bd70      	pop	{r4, r5, r6, pc}
32306b76:	bf00      	nop

32306b78 <_wctomb_r>:
32306b78:	f24c 1c10 	movw	ip, #49424	@ 0xc110
32306b7c:	f2c3 2c30 	movt	ip, #12848	@ 0x3230
32306b80:	b410      	push	{r4}
32306b82:	f8dc 40e0 	ldr.w	r4, [ip, #224]	@ 0xe0
32306b86:	46a4      	mov	ip, r4
32306b88:	f85d 4b04 	ldr.w	r4, [sp], #4
32306b8c:	4760      	bx	ip
32306b8e:	bf00      	nop

32306b90 <__ascii_wctomb>:
32306b90:	4603      	mov	r3, r0
32306b92:	b149      	cbz	r1, 32306ba8 <__ascii_wctomb+0x18>
32306b94:	2aff      	cmp	r2, #255	@ 0xff
32306b96:	d802      	bhi.n	32306b9e <__ascii_wctomb+0xe>
32306b98:	2001      	movs	r0, #1
32306b9a:	700a      	strb	r2, [r1, #0]
32306b9c:	4770      	bx	lr
32306b9e:	228a      	movs	r2, #138	@ 0x8a
32306ba0:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32306ba4:	601a      	str	r2, [r3, #0]
32306ba6:	4770      	bx	lr
32306ba8:	4608      	mov	r0, r1
32306baa:	4770      	bx	lr

32306bac <__utf8_wctomb>:
32306bac:	4603      	mov	r3, r0
32306bae:	b3b1      	cbz	r1, 32306c1e <__utf8_wctomb+0x72>
32306bb0:	2a7f      	cmp	r2, #127	@ 0x7f
32306bb2:	d926      	bls.n	32306c02 <__utf8_wctomb+0x56>
32306bb4:	f1a2 0080 	sub.w	r0, r2, #128	@ 0x80
32306bb8:	f5b0 6ff0 	cmp.w	r0, #1920	@ 0x780
32306bbc:	d324      	bcc.n	32306c08 <__utf8_wctomb+0x5c>
32306bbe:	f5a2 6000 	sub.w	r0, r2, #2048	@ 0x800
32306bc2:	f5b0 4f78 	cmp.w	r0, #63488	@ 0xf800
32306bc6:	d32c      	bcc.n	32306c22 <__utf8_wctomb+0x76>
32306bc8:	f5a2 3080 	sub.w	r0, r2, #65536	@ 0x10000
32306bcc:	f5b0 1f80 	cmp.w	r0, #1048576	@ 0x100000
32306bd0:	d239      	bcs.n	32306c46 <__utf8_wctomb+0x9a>
32306bd2:	ea4f 4c92 	mov.w	ip, r2, lsr #18
32306bd6:	2300      	movs	r3, #0
32306bd8:	f3c2 3005 	ubfx	r0, r2, #12, #6
32306bdc:	f36c 0307 	bfi	r3, ip, #0, #8
32306be0:	f3c2 1c85 	ubfx	ip, r2, #6, #6
32306be4:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
32306be8:	f360 230f 	bfi	r3, r0, #8, #8
32306bec:	2004      	movs	r0, #4
32306bee:	f36c 4317 	bfi	r3, ip, #16, #8
32306bf2:	f362 631f 	bfi	r3, r2, #24, #8
32306bf6:	f043 3380 	orr.w	r3, r3, #2155905152	@ 0x80808080
32306bfa:	f043 0370 	orr.w	r3, r3, #112	@ 0x70
32306bfe:	600b      	str	r3, [r1, #0]
32306c00:	4770      	bx	lr
32306c02:	2001      	movs	r0, #1
32306c04:	700a      	strb	r2, [r1, #0]
32306c06:	4770      	bx	lr
32306c08:	0993      	lsrs	r3, r2, #6
32306c0a:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
32306c0e:	f063 033f 	orn	r3, r3, #63	@ 0x3f
32306c12:	f062 027f 	orn	r2, r2, #127	@ 0x7f
32306c16:	2002      	movs	r0, #2
32306c18:	700b      	strb	r3, [r1, #0]
32306c1a:	704a      	strb	r2, [r1, #1]
32306c1c:	4770      	bx	lr
32306c1e:	4608      	mov	r0, r1
32306c20:	4770      	bx	lr
32306c22:	ea4f 3c12 	mov.w	ip, r2, lsr #12
32306c26:	f3c2 1385 	ubfx	r3, r2, #6, #6
32306c2a:	f002 023f 	and.w	r2, r2, #63	@ 0x3f
32306c2e:	f06c 0c1f 	orn	ip, ip, #31
32306c32:	f063 037f 	orn	r3, r3, #127	@ 0x7f
32306c36:	f062 027f 	orn	r2, r2, #127	@ 0x7f
32306c3a:	2003      	movs	r0, #3
32306c3c:	f881 c000 	strb.w	ip, [r1]
32306c40:	704b      	strb	r3, [r1, #1]
32306c42:	708a      	strb	r2, [r1, #2]
32306c44:	4770      	bx	lr
32306c46:	228a      	movs	r2, #138	@ 0x8a
32306c48:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32306c4c:	601a      	str	r2, [r3, #0]
32306c4e:	4770      	bx	lr

32306c50 <__sjis_wctomb>:
32306c50:	b2d3      	uxtb	r3, r2
32306c52:	f3c2 2207 	ubfx	r2, r2, #8, #8
32306c56:	b1e9      	cbz	r1, 32306c94 <__sjis_wctomb+0x44>
32306c58:	b1ca      	cbz	r2, 32306c8e <__sjis_wctomb+0x3e>
32306c5a:	4684      	mov	ip, r0
32306c5c:	b410      	push	{r4}
32306c5e:	f102 007f 	add.w	r0, r2, #127	@ 0x7f
32306c62:	f102 0420 	add.w	r4, r2, #32
32306c66:	b2c0      	uxtb	r0, r0
32306c68:	b2e4      	uxtb	r4, r4
32306c6a:	281e      	cmp	r0, #30
32306c6c:	bf88      	it	hi
32306c6e:	2c0f      	cmphi	r4, #15
32306c70:	d812      	bhi.n	32306c98 <__sjis_wctomb+0x48>
32306c72:	f1a3 0040 	sub.w	r0, r3, #64	@ 0x40
32306c76:	f083 0480 	eor.w	r4, r3, #128	@ 0x80
32306c7a:	283e      	cmp	r0, #62	@ 0x3e
32306c7c:	bf88      	it	hi
32306c7e:	2c7c      	cmphi	r4, #124	@ 0x7c
32306c80:	d80a      	bhi.n	32306c98 <__sjis_wctomb+0x48>
32306c82:	2002      	movs	r0, #2
32306c84:	700a      	strb	r2, [r1, #0]
32306c86:	704b      	strb	r3, [r1, #1]
32306c88:	f85d 4b04 	ldr.w	r4, [sp], #4
32306c8c:	4770      	bx	lr
32306c8e:	2001      	movs	r0, #1
32306c90:	700b      	strb	r3, [r1, #0]
32306c92:	4770      	bx	lr
32306c94:	4608      	mov	r0, r1
32306c96:	4770      	bx	lr
32306c98:	238a      	movs	r3, #138	@ 0x8a
32306c9a:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32306c9e:	f8cc 3000 	str.w	r3, [ip]
32306ca2:	e7f1      	b.n	32306c88 <__sjis_wctomb+0x38>

32306ca4 <__eucjp_wctomb>:
32306ca4:	b2d3      	uxtb	r3, r2
32306ca6:	f3c2 2207 	ubfx	r2, r2, #8, #8
32306caa:	b329      	cbz	r1, 32306cf8 <__eucjp_wctomb+0x54>
32306cac:	b30a      	cbz	r2, 32306cf2 <__eucjp_wctomb+0x4e>
32306cae:	4684      	mov	ip, r0
32306cb0:	b410      	push	{r4}
32306cb2:	f102 005f 	add.w	r0, r2, #95	@ 0x5f
32306cb6:	f102 0472 	add.w	r4, r2, #114	@ 0x72
32306cba:	b2c0      	uxtb	r0, r0
32306cbc:	b2e4      	uxtb	r4, r4
32306cbe:	2c01      	cmp	r4, #1
32306cc0:	bf88      	it	hi
32306cc2:	285d      	cmphi	r0, #93	@ 0x5d
32306cc4:	d81e      	bhi.n	32306d04 <__eucjp_wctomb+0x60>
32306cc6:	f103 045f 	add.w	r4, r3, #95	@ 0x5f
32306cca:	b2e4      	uxtb	r4, r4
32306ccc:	2c5d      	cmp	r4, #93	@ 0x5d
32306cce:	d915      	bls.n	32306cfc <__eucjp_wctomb+0x58>
32306cd0:	285d      	cmp	r0, #93	@ 0x5d
32306cd2:	d817      	bhi.n	32306d04 <__eucjp_wctomb+0x60>
32306cd4:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
32306cd8:	f103 005f 	add.w	r0, r3, #95	@ 0x5f
32306cdc:	b2c0      	uxtb	r0, r0
32306cde:	285d      	cmp	r0, #93	@ 0x5d
32306ce0:	d810      	bhi.n	32306d04 <__eucjp_wctomb+0x60>
32306ce2:	2003      	movs	r0, #3
32306ce4:	248f      	movs	r4, #143	@ 0x8f
32306ce6:	704a      	strb	r2, [r1, #1]
32306ce8:	700c      	strb	r4, [r1, #0]
32306cea:	708b      	strb	r3, [r1, #2]
32306cec:	f85d 4b04 	ldr.w	r4, [sp], #4
32306cf0:	4770      	bx	lr
32306cf2:	2001      	movs	r0, #1
32306cf4:	700b      	strb	r3, [r1, #0]
32306cf6:	4770      	bx	lr
32306cf8:	4608      	mov	r0, r1
32306cfa:	4770      	bx	lr
32306cfc:	2002      	movs	r0, #2
32306cfe:	700a      	strb	r2, [r1, #0]
32306d00:	704b      	strb	r3, [r1, #1]
32306d02:	e7f3      	b.n	32306cec <__eucjp_wctomb+0x48>
32306d04:	238a      	movs	r3, #138	@ 0x8a
32306d06:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32306d0a:	f8cc 3000 	str.w	r3, [ip]
32306d0e:	e7ed      	b.n	32306cec <__eucjp_wctomb+0x48>

32306d10 <__jis_wctomb>:
32306d10:	b500      	push	{lr}
32306d12:	fa5f fe82 	uxtb.w	lr, r2
32306d16:	f3c2 2207 	ubfx	r2, r2, #8, #8
32306d1a:	b379      	cbz	r1, 32306d7c <__jis_wctomb+0x6c>
32306d1c:	b97a      	cbnz	r2, 32306d3e <__jis_wctomb+0x2e>
32306d1e:	6818      	ldr	r0, [r3, #0]
32306d20:	b1f0      	cbz	r0, 32306d60 <__jis_wctomb+0x50>
32306d22:	468c      	mov	ip, r1
32306d24:	601a      	str	r2, [r3, #0]
32306d26:	f642 031b 	movw	r3, #10267	@ 0x281b
32306d2a:	2004      	movs	r0, #4
32306d2c:	f82c 3b03 	strh.w	r3, [ip], #3
32306d30:	2342      	movs	r3, #66	@ 0x42
32306d32:	708b      	strb	r3, [r1, #2]
32306d34:	4661      	mov	r1, ip
32306d36:	f881 e000 	strb.w	lr, [r1]
32306d3a:	f85d fb04 	ldr.w	pc, [sp], #4
32306d3e:	4684      	mov	ip, r0
32306d40:	f1a2 0021 	sub.w	r0, r2, #33	@ 0x21
32306d44:	285d      	cmp	r0, #93	@ 0x5d
32306d46:	d81c      	bhi.n	32306d82 <__jis_wctomb+0x72>
32306d48:	f1ae 0021 	sub.w	r0, lr, #33	@ 0x21
32306d4c:	285d      	cmp	r0, #93	@ 0x5d
32306d4e:	d818      	bhi.n	32306d82 <__jis_wctomb+0x72>
32306d50:	6818      	ldr	r0, [r3, #0]
32306d52:	b138      	cbz	r0, 32306d64 <__jis_wctomb+0x54>
32306d54:	2002      	movs	r0, #2
32306d56:	700a      	strb	r2, [r1, #0]
32306d58:	f881 e001 	strb.w	lr, [r1, #1]
32306d5c:	f85d fb04 	ldr.w	pc, [sp], #4
32306d60:	2001      	movs	r0, #1
32306d62:	e7e8      	b.n	32306d36 <__jis_wctomb+0x26>
32306d64:	2001      	movs	r0, #1
32306d66:	6018      	str	r0, [r3, #0]
32306d68:	460b      	mov	r3, r1
32306d6a:	f242 401b 	movw	r0, #9243	@ 0x241b
32306d6e:	f823 0b03 	strh.w	r0, [r3], #3
32306d72:	2042      	movs	r0, #66	@ 0x42
32306d74:	7088      	strb	r0, [r1, #2]
32306d76:	2005      	movs	r0, #5
32306d78:	4619      	mov	r1, r3
32306d7a:	e7ec      	b.n	32306d56 <__jis_wctomb+0x46>
32306d7c:	2001      	movs	r0, #1
32306d7e:	f85d fb04 	ldr.w	pc, [sp], #4
32306d82:	238a      	movs	r3, #138	@ 0x8a
32306d84:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32306d88:	f8cc 3000 	str.w	r3, [ip]
32306d8c:	e7d5      	b.n	32306d3a <__jis_wctomb+0x2a>
32306d8e:	bf00      	nop

32306d90 <_wcrtomb_r>:
32306d90:	b570      	push	{r4, r5, r6, lr}
32306d92:	4605      	mov	r5, r0
32306d94:	f500 7482 	add.w	r4, r0, #260	@ 0x104
32306d98:	b084      	sub	sp, #16
32306d9a:	b103      	cbz	r3, 32306d9e <_wcrtomb_r+0xe>
32306d9c:	461c      	mov	r4, r3
32306d9e:	f24c 1310 	movw	r3, #49424	@ 0xc110
32306da2:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32306da6:	f8d3 60e0 	ldr.w	r6, [r3, #224]	@ 0xe0
32306daa:	4623      	mov	r3, r4
32306dac:	b129      	cbz	r1, 32306dba <_wcrtomb_r+0x2a>
32306dae:	4628      	mov	r0, r5
32306db0:	47b0      	blx	r6
32306db2:	1c43      	adds	r3, r0, #1
32306db4:	d007      	beq.n	32306dc6 <_wcrtomb_r+0x36>
32306db6:	b004      	add	sp, #16
32306db8:	bd70      	pop	{r4, r5, r6, pc}
32306dba:	460a      	mov	r2, r1
32306dbc:	4628      	mov	r0, r5
32306dbe:	a901      	add	r1, sp, #4
32306dc0:	47b0      	blx	r6
32306dc2:	1c43      	adds	r3, r0, #1
32306dc4:	d1f7      	bne.n	32306db6 <_wcrtomb_r+0x26>
32306dc6:	2200      	movs	r2, #0
32306dc8:	238a      	movs	r3, #138	@ 0x8a
32306dca:	6022      	str	r2, [r4, #0]
32306dcc:	602b      	str	r3, [r5, #0]
32306dce:	b004      	add	sp, #16
32306dd0:	bd70      	pop	{r4, r5, r6, pc}
32306dd2:	bf00      	nop

32306dd4 <wcrtomb>:
32306dd4:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
32306dd8:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32306ddc:	b570      	push	{r4, r5, r6, lr}
32306dde:	681d      	ldr	r5, [r3, #0]
32306de0:	b084      	sub	sp, #16
32306de2:	f505 7482 	add.w	r4, r5, #260	@ 0x104
32306de6:	b102      	cbz	r2, 32306dea <wcrtomb+0x16>
32306de8:	4614      	mov	r4, r2
32306dea:	f24c 1310 	movw	r3, #49424	@ 0xc110
32306dee:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32306df2:	f8d3 60e0 	ldr.w	r6, [r3, #224]	@ 0xe0
32306df6:	b140      	cbz	r0, 32306e0a <wcrtomb+0x36>
32306df8:	460a      	mov	r2, r1
32306dfa:	4623      	mov	r3, r4
32306dfc:	4601      	mov	r1, r0
32306dfe:	4628      	mov	r0, r5
32306e00:	47b0      	blx	r6
32306e02:	1c43      	adds	r3, r0, #1
32306e04:	d008      	beq.n	32306e18 <wcrtomb+0x44>
32306e06:	b004      	add	sp, #16
32306e08:	bd70      	pop	{r4, r5, r6, pc}
32306e0a:	4623      	mov	r3, r4
32306e0c:	4602      	mov	r2, r0
32306e0e:	a901      	add	r1, sp, #4
32306e10:	4628      	mov	r0, r5
32306e12:	47b0      	blx	r6
32306e14:	1c43      	adds	r3, r0, #1
32306e16:	d1f6      	bne.n	32306e06 <wcrtomb+0x32>
32306e18:	2200      	movs	r2, #0
32306e1a:	238a      	movs	r3, #138	@ 0x8a
32306e1c:	6022      	str	r2, [r4, #0]
32306e1e:	602b      	str	r3, [r5, #0]
32306e20:	b004      	add	sp, #16
32306e22:	bd70      	pop	{r4, r5, r6, pc}

32306e24 <_wcsrtombs_r>:
32306e24:	b510      	push	{r4, lr}
32306e26:	461c      	mov	r4, r3
32306e28:	b082      	sub	sp, #8
32306e2a:	9b04      	ldr	r3, [sp, #16]
32306e2c:	9301      	str	r3, [sp, #4]
32306e2e:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
32306e32:	9400      	str	r4, [sp, #0]
32306e34:	f004 fb5a 	bl	3230b4ec <_wcsnrtombs_r>
32306e38:	b002      	add	sp, #8
32306e3a:	bd10      	pop	{r4, pc}

32306e3c <wcsrtombs>:
32306e3c:	b510      	push	{r4, lr}
32306e3e:	f24c 2ca0 	movw	ip, #49824	@ 0xc2a0
32306e42:	f2c3 2c30 	movt	ip, #12848	@ 0x3230
32306e46:	b082      	sub	sp, #8
32306e48:	4686      	mov	lr, r0
32306e4a:	4614      	mov	r4, r2
32306e4c:	460a      	mov	r2, r1
32306e4e:	f8dc 0000 	ldr.w	r0, [ip]
32306e52:	4671      	mov	r1, lr
32306e54:	9301      	str	r3, [sp, #4]
32306e56:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
32306e5a:	9400      	str	r4, [sp, #0]
32306e5c:	f004 fb46 	bl	3230b4ec <_wcsnrtombs_r>
32306e60:	b002      	add	sp, #8
32306e62:	bd10      	pop	{r4, pc}

32306e64 <__set_ctype>:
32306e64:	f64b 53b0 	movw	r3, #48560	@ 0xbdb0
32306e68:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32306e6c:	f8c0 30ec 	str.w	r3, [r0, #236]	@ 0xec
32306e70:	4770      	bx	lr
32306e72:	bf00      	nop
32306e74:	0000      	movs	r0, r0
	...

32306e78 <_vfprintf_r>:
32306e78:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32306e7c:	461c      	mov	r4, r3
32306e7e:	4683      	mov	fp, r0
32306e80:	ed2d 8b04 	vpush	{d8-d9}
32306e84:	b0d1      	sub	sp, #324	@ 0x144
32306e86:	af20      	add	r7, sp, #128	@ 0x80
32306e88:	9103      	str	r1, [sp, #12]
32306e8a:	9206      	str	r2, [sp, #24]
32306e8c:	930a      	str	r3, [sp, #40]	@ 0x28
32306e8e:	f7fd fe37 	bl	32304b00 <_localeconv_r>
32306e92:	6803      	ldr	r3, [r0, #0]
32306e94:	9312      	str	r3, [sp, #72]	@ 0x48
32306e96:	4618      	mov	r0, r3
32306e98:	f7fe fbd2 	bl	32305640 <strlen>
32306e9c:	2208      	movs	r2, #8
32306e9e:	9011      	str	r0, [sp, #68]	@ 0x44
32306ea0:	2100      	movs	r1, #0
32306ea2:	4638      	mov	r0, r7
32306ea4:	f7fd f8e0 	bl	32304068 <memset>
32306ea8:	f1bb 0f00 	cmp.w	fp, #0
32306eac:	d004      	beq.n	32306eb8 <_vfprintf_r+0x40>
32306eae:	f8db 3034 	ldr.w	r3, [fp, #52]	@ 0x34
32306eb2:	2b00      	cmp	r3, #0
32306eb4:	f001 81e4 	beq.w	32308280 <_vfprintf_r+0x1408>
32306eb8:	9b03      	ldr	r3, [sp, #12]
32306eba:	6e5a      	ldr	r2, [r3, #100]	@ 0x64
32306ebc:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
32306ec0:	07d6      	lsls	r6, r2, #31
32306ec2:	f140 8142 	bpl.w	3230714a <_vfprintf_r+0x2d2>
32306ec6:	049d      	lsls	r5, r3, #18
32306ec8:	f100 8756 	bmi.w	32307d78 <_vfprintf_r+0xf00>
32306ecc:	9903      	ldr	r1, [sp, #12]
32306ece:	f443 5300 	orr.w	r3, r3, #8192	@ 0x2000
32306ed2:	f422 5200 	bic.w	r2, r2, #8192	@ 0x2000
32306ed6:	818b      	strh	r3, [r1, #12]
32306ed8:	b21b      	sxth	r3, r3
32306eda:	664a      	str	r2, [r1, #100]	@ 0x64
32306edc:	071e      	lsls	r6, r3, #28
32306ede:	f140 80bb 	bpl.w	32307058 <_vfprintf_r+0x1e0>
32306ee2:	9a03      	ldr	r2, [sp, #12]
32306ee4:	6912      	ldr	r2, [r2, #16]
32306ee6:	2a00      	cmp	r2, #0
32306ee8:	f000 80b6 	beq.w	32307058 <_vfprintf_r+0x1e0>
32306eec:	f003 021a 	and.w	r2, r3, #26
32306ef0:	2a0a      	cmp	r2, #10
32306ef2:	f000 80c0 	beq.w	32307076 <_vfprintf_r+0x1fe>
32306ef6:	ef80 8e30 	vmov.i64	d8, #0x0000000000000000
32306efa:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32306efe:	2300      	movs	r3, #0
32306f00:	aa27      	add	r2, sp, #156	@ 0x9c
32306f02:	e9cd 3325 	strd	r3, r3, [sp, #148]	@ 0x94
32306f06:	9224      	str	r2, [sp, #144]	@ 0x90
32306f08:	f24c 1210 	movw	r2, #49424	@ 0xc110
32306f0c:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32306f10:	930f      	str	r3, [sp, #60]	@ 0x3c
32306f12:	920d      	str	r2, [sp, #52]	@ 0x34
32306f14:	f64b 62b8 	movw	r2, #48824	@ 0xbeb8
32306f18:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32306f1c:	9314      	str	r3, [sp, #80]	@ 0x50
32306f1e:	9213      	str	r2, [sp, #76]	@ 0x4c
32306f20:	9317      	str	r3, [sp, #92]	@ 0x5c
32306f22:	e9cd 3315 	strd	r3, r3, [sp, #84]	@ 0x54
32306f26:	9307      	str	r3, [sp, #28]
32306f28:	9d06      	ldr	r5, [sp, #24]
32306f2a:	9c0d      	ldr	r4, [sp, #52]	@ 0x34
32306f2c:	f8d4 60e4 	ldr.w	r6, [r4, #228]	@ 0xe4
32306f30:	f7fd fdd2 	bl	32304ad8 <__locale_mb_cur_max>
32306f34:	462a      	mov	r2, r5
32306f36:	4603      	mov	r3, r0
32306f38:	a91c      	add	r1, sp, #112	@ 0x70
32306f3a:	4658      	mov	r0, fp
32306f3c:	9700      	str	r7, [sp, #0]
32306f3e:	47b0      	blx	r6
32306f40:	2800      	cmp	r0, #0
32306f42:	f000 80b9 	beq.w	323070b8 <_vfprintf_r+0x240>
32306f46:	4603      	mov	r3, r0
32306f48:	f2c0 80ae 	blt.w	323070a8 <_vfprintf_r+0x230>
32306f4c:	9a1c      	ldr	r2, [sp, #112]	@ 0x70
32306f4e:	2a25      	cmp	r2, #37	@ 0x25
32306f50:	d001      	beq.n	32306f56 <_vfprintf_r+0xde>
32306f52:	441d      	add	r5, r3
32306f54:	e7ea      	b.n	32306f2c <_vfprintf_r+0xb4>
32306f56:	9b06      	ldr	r3, [sp, #24]
32306f58:	4604      	mov	r4, r0
32306f5a:	1aee      	subs	r6, r5, r3
32306f5c:	f040 80b0 	bne.w	323070c0 <_vfprintf_r+0x248>
32306f60:	786c      	ldrb	r4, [r5, #1]
32306f62:	3501      	adds	r5, #1
32306f64:	2300      	movs	r3, #0
32306f66:	f04f 32ff 	mov.w	r2, #4294967295	@ 0xffffffff
32306f6a:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32306f6e:	9308      	str	r3, [sp, #32]
32306f70:	9205      	str	r2, [sp, #20]
32306f72:	9302      	str	r3, [sp, #8]
32306f74:	3501      	adds	r5, #1
32306f76:	f1a4 0320 	sub.w	r3, r4, #32
32306f7a:	2b5a      	cmp	r3, #90	@ 0x5a
32306f7c:	f200 80f8 	bhi.w	32307170 <_vfprintf_r+0x2f8>
32306f80:	e8df f013 	tbh	[pc, r3, lsl #1]
32306f84:	00f604ab 	.word	0x00f604ab
32306f88:	04a400f6 	.word	0x04a400f6
32306f8c:	00f600f6 	.word	0x00f600f6
32306f90:	048500f6 	.word	0x048500f6
32306f94:	00f600f6 	.word	0x00f600f6
32306f98:	037d036c 	.word	0x037d036c
32306f9c:	037700f6 	.word	0x037700f6
32306fa0:	00f604bd 	.word	0x00f604bd
32306fa4:	005b04b6 	.word	0x005b04b6
32306fa8:	005b005b 	.word	0x005b005b
32306fac:	005b005b 	.word	0x005b005b
32306fb0:	005b005b 	.word	0x005b005b
32306fb4:	005b005b 	.word	0x005b005b
32306fb8:	00f600f6 	.word	0x00f600f6
32306fbc:	00f600f6 	.word	0x00f600f6
32306fc0:	00f600f6 	.word	0x00f600f6
32306fc4:	017100f6 	.word	0x017100f6
32306fc8:	02ae00f6 	.word	0x02ae00f6
32306fcc:	01710430 	.word	0x01710430
32306fd0:	01710171 	.word	0x01710171
32306fd4:	00f600f6 	.word	0x00f600f6
32306fd8:	00f600f6 	.word	0x00f600f6
32306fdc:	00f60429 	.word	0x00f60429
32306fe0:	03ef00f6 	.word	0x03ef00f6
32306fe4:	00f600f6 	.word	0x00f600f6
32306fe8:	02d200f6 	.word	0x02d200f6
32306fec:	046700f6 	.word	0x046700f6
32306ff0:	00f600f6 	.word	0x00f600f6
32306ff4:	00f60880 	.word	0x00f60880
32306ff8:	00f600f6 	.word	0x00f600f6
32306ffc:	00f600f6 	.word	0x00f600f6
32307000:	00f600f6 	.word	0x00f600f6
32307004:	017100f6 	.word	0x017100f6
32307008:	02ae00f6 	.word	0x02ae00f6
3230700c:	017101b8 	.word	0x017101b8
32307010:	01710171 	.word	0x01710171
32307014:	01b8045d 	.word	0x01b8045d
32307018:	00f601b2 	.word	0x00f601b2
3230701c:	00f60453 	.word	0x00f60453
32307020:	03ac03e0 	.word	0x03ac03e0
32307024:	01b20382 	.word	0x01b20382
32307028:	02d200f6 	.word	0x02d200f6
3230702c:	031d01b0 	.word	0x031d01b0
32307030:	00f600f6 	.word	0x00f600f6
32307034:	00f608b2 	.word	0x00f608b2
32307038:	01b0      	.short	0x01b0
3230703a:	2200      	movs	r2, #0
3230703c:	f1a4 0330 	sub.w	r3, r4, #48	@ 0x30
32307040:	4611      	mov	r1, r2
32307042:	220a      	movs	r2, #10
32307044:	f815 4b01 	ldrb.w	r4, [r5], #1
32307048:	fb02 3101 	mla	r1, r2, r1, r3
3230704c:	f1a4 0330 	sub.w	r3, r4, #48	@ 0x30
32307050:	2b09      	cmp	r3, #9
32307052:	d9f7      	bls.n	32307044 <_vfprintf_r+0x1cc>
32307054:	9108      	str	r1, [sp, #32]
32307056:	e78e      	b.n	32306f76 <_vfprintf_r+0xfe>
32307058:	9d03      	ldr	r5, [sp, #12]
3230705a:	4658      	mov	r0, fp
3230705c:	4629      	mov	r1, r5
3230705e:	f7fc ff0f 	bl	32303e80 <__swsetup_r>
32307062:	2800      	cmp	r0, #0
32307064:	f041 87b0 	bne.w	32308fc8 <_vfprintf_r+0x2150>
32307068:	f9b5 300c 	ldrsh.w	r3, [r5, #12]
3230706c:	f003 021a 	and.w	r2, r3, #26
32307070:	2a0a      	cmp	r2, #10
32307072:	f47f af40 	bne.w	32306ef6 <_vfprintf_r+0x7e>
32307076:	9903      	ldr	r1, [sp, #12]
32307078:	f9b1 200e 	ldrsh.w	r2, [r1, #14]
3230707c:	2a00      	cmp	r2, #0
3230707e:	f6ff af3a 	blt.w	32306ef6 <_vfprintf_r+0x7e>
32307082:	6e4a      	ldr	r2, [r1, #100]	@ 0x64
32307084:	07d0      	lsls	r0, r2, #31
32307086:	d402      	bmi.n	3230708e <_vfprintf_r+0x216>
32307088:	059a      	lsls	r2, r3, #22
3230708a:	f141 8370 	bpl.w	3230876e <_vfprintf_r+0x18f6>
3230708e:	9a06      	ldr	r2, [sp, #24]
32307090:	4623      	mov	r3, r4
32307092:	9903      	ldr	r1, [sp, #12]
32307094:	4658      	mov	r0, fp
32307096:	f002 f82f 	bl	323090f8 <__sbprintf>
3230709a:	9007      	str	r0, [sp, #28]
3230709c:	9807      	ldr	r0, [sp, #28]
3230709e:	b051      	add	sp, #324	@ 0x144
323070a0:	ecbd 8b04 	vpop	{d8-d9}
323070a4:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
323070a8:	2208      	movs	r2, #8
323070aa:	2100      	movs	r1, #0
323070ac:	4638      	mov	r0, r7
323070ae:	f7fc ffdb 	bl	32304068 <memset>
323070b2:	2301      	movs	r3, #1
323070b4:	441d      	add	r5, r3
323070b6:	e739      	b.n	32306f2c <_vfprintf_r+0xb4>
323070b8:	9b06      	ldr	r3, [sp, #24]
323070ba:	4604      	mov	r4, r0
323070bc:	1aee      	subs	r6, r5, r3
323070be:	d012      	beq.n	323070e6 <_vfprintf_r+0x26e>
323070c0:	9b06      	ldr	r3, [sp, #24]
323070c2:	e9c9 3600 	strd	r3, r6, [r9]
323070c6:	f109 0908 	add.w	r9, r9, #8
323070ca:	9b25      	ldr	r3, [sp, #148]	@ 0x94
323070cc:	9926      	ldr	r1, [sp, #152]	@ 0x98
323070ce:	3301      	adds	r3, #1
323070d0:	9325      	str	r3, [sp, #148]	@ 0x94
323070d2:	4431      	add	r1, r6
323070d4:	2b07      	cmp	r3, #7
323070d6:	9126      	str	r1, [sp, #152]	@ 0x98
323070d8:	dc0f      	bgt.n	323070fa <_vfprintf_r+0x282>
323070da:	9b07      	ldr	r3, [sp, #28]
323070dc:	4433      	add	r3, r6
323070de:	9307      	str	r3, [sp, #28]
323070e0:	2c00      	cmp	r4, #0
323070e2:	f47f af3d 	bne.w	32306f60 <_vfprintf_r+0xe8>
323070e6:	9b26      	ldr	r3, [sp, #152]	@ 0x98
323070e8:	2b00      	cmp	r3, #0
323070ea:	f041 8336 	bne.w	3230875a <_vfprintf_r+0x18e2>
323070ee:	9b03      	ldr	r3, [sp, #12]
323070f0:	2200      	movs	r2, #0
323070f2:	9225      	str	r2, [sp, #148]	@ 0x94
323070f4:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
323070f8:	e019      	b.n	3230712e <_vfprintf_r+0x2b6>
323070fa:	9903      	ldr	r1, [sp, #12]
323070fc:	aa24      	add	r2, sp, #144	@ 0x90
323070fe:	4658      	mov	r0, fp
32307100:	f7fc f98a 	bl	32303418 <__sprint_r>
32307104:	b980      	cbnz	r0, 32307128 <_vfprintf_r+0x2b0>
32307106:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
3230710a:	e7e6      	b.n	323070da <_vfprintf_r+0x262>
3230710c:	9903      	ldr	r1, [sp, #12]
3230710e:	aa24      	add	r2, sp, #144	@ 0x90
32307110:	4658      	mov	r0, fp
32307112:	f7fc f981 	bl	32303418 <__sprint_r>
32307116:	2800      	cmp	r0, #0
32307118:	f000 809a 	beq.w	32307250 <_vfprintf_r+0x3d8>
3230711c:	9b09      	ldr	r3, [sp, #36]	@ 0x24
3230711e:	b11b      	cbz	r3, 32307128 <_vfprintf_r+0x2b0>
32307120:	9909      	ldr	r1, [sp, #36]	@ 0x24
32307122:	4658      	mov	r0, fp
32307124:	f7fe fb60 	bl	323057e8 <_free_r>
32307128:	9b03      	ldr	r3, [sp, #12]
3230712a:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
3230712e:	9a03      	ldr	r2, [sp, #12]
32307130:	6e52      	ldr	r2, [r2, #100]	@ 0x64
32307132:	07d4      	lsls	r4, r2, #31
32307134:	f140 80cc 	bpl.w	323072d0 <_vfprintf_r+0x458>
32307138:	065a      	lsls	r2, r3, #25
3230713a:	f100 823c 	bmi.w	323075b6 <_vfprintf_r+0x73e>
3230713e:	9807      	ldr	r0, [sp, #28]
32307140:	b051      	add	sp, #324	@ 0x144
32307142:	ecbd 8b04 	vpop	{d8-d9}
32307146:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230714a:	0599      	lsls	r1, r3, #22
3230714c:	f140 8223 	bpl.w	32307596 <_vfprintf_r+0x71e>
32307150:	049e      	lsls	r6, r3, #18
32307152:	f57f aebb 	bpl.w	32306ecc <_vfprintf_r+0x54>
32307156:	0495      	lsls	r5, r2, #18
32307158:	f57f aec0 	bpl.w	32306edc <_vfprintf_r+0x64>
3230715c:	9b03      	ldr	r3, [sp, #12]
3230715e:	899b      	ldrh	r3, [r3, #12]
32307160:	059f      	lsls	r7, r3, #22
32307162:	f100 8228 	bmi.w	323075b6 <_vfprintf_r+0x73e>
32307166:	9b03      	ldr	r3, [sp, #12]
32307168:	6d98      	ldr	r0, [r3, #88]	@ 0x58
3230716a:	f7fd fd7d 	bl	32304c68 <__retarget_lock_release_recursive>
3230716e:	e222      	b.n	323075b6 <_vfprintf_r+0x73e>
32307170:	9506      	str	r5, [sp, #24]
32307172:	2c00      	cmp	r4, #0
32307174:	d0b7      	beq.n	323070e6 <_vfprintf_r+0x26e>
32307176:	ad37      	add	r5, sp, #220	@ 0xdc
32307178:	2300      	movs	r3, #0
3230717a:	2201      	movs	r2, #1
3230717c:	f88d 40dc 	strb.w	r4, [sp, #220]	@ 0xdc
32307180:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32307184:	9309      	str	r3, [sp, #36]	@ 0x24
32307186:	920b      	str	r2, [sp, #44]	@ 0x2c
32307188:	9305      	str	r3, [sp, #20]
3230718a:	9310      	str	r3, [sp, #64]	@ 0x40
3230718c:	930e      	str	r3, [sp, #56]	@ 0x38
3230718e:	930c      	str	r3, [sp, #48]	@ 0x30
32307190:	9204      	str	r2, [sp, #16]
32307192:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32307194:	9b02      	ldr	r3, [sp, #8]
32307196:	4696      	mov	lr, r2
32307198:	f013 0a84 	ands.w	sl, r3, #132	@ 0x84
3230719c:	f000 80e5 	beq.w	3230736a <_vfprintf_r+0x4f2>
323071a0:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
323071a4:	b31b      	cbz	r3, 323071ee <_vfprintf_r+0x376>
323071a6:	9825      	ldr	r0, [sp, #148]	@ 0x94
323071a8:	2600      	movs	r6, #0
323071aa:	3001      	adds	r0, #1
323071ac:	2301      	movs	r3, #1
323071ae:	3201      	adds	r2, #1
323071b0:	f8c9 3004 	str.w	r3, [r9, #4]
323071b4:	2807      	cmp	r0, #7
323071b6:	f10d 0367 	add.w	r3, sp, #103	@ 0x67
323071ba:	f109 0908 	add.w	r9, r9, #8
323071be:	f849 3c08 	str.w	r3, [r9, #-8]
323071c2:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
323071c6:	f300 84c3 	bgt.w	32307b50 <_vfprintf_r+0xcd8>
323071ca:	9825      	ldr	r0, [sp, #148]	@ 0x94
323071cc:	b17e      	cbz	r6, 323071ee <_vfprintf_r+0x376>
323071ce:	3001      	adds	r0, #1
323071d0:	ab1a      	add	r3, sp, #104	@ 0x68
323071d2:	3202      	adds	r2, #2
323071d4:	f8c9 3000 	str.w	r3, [r9]
323071d8:	2807      	cmp	r0, #7
323071da:	f04f 0302 	mov.w	r3, #2
323071de:	f109 0908 	add.w	r9, r9, #8
323071e2:	f849 3c04 	str.w	r3, [r9, #-4]
323071e6:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
323071ea:	f300 84a4 	bgt.w	32307b36 <_vfprintf_r+0xcbe>
323071ee:	f1ba 0f80 	cmp.w	sl, #128	@ 0x80
323071f2:	f000 83a1 	beq.w	32307938 <_vfprintf_r+0xac0>
323071f6:	9b05      	ldr	r3, [sp, #20]
323071f8:	990b      	ldr	r1, [sp, #44]	@ 0x2c
323071fa:	1a5e      	subs	r6, r3, r1
323071fc:	2e00      	cmp	r6, #0
323071fe:	f300 80c6 	bgt.w	3230738e <_vfprintf_r+0x516>
32307202:	9b02      	ldr	r3, [sp, #8]
32307204:	05de      	lsls	r6, r3, #23
32307206:	f100 810f 	bmi.w	32307428 <_vfprintf_r+0x5b0>
3230720a:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
3230720c:	f8c9 3004 	str.w	r3, [r9, #4]
32307210:	441a      	add	r2, r3
32307212:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307214:	f8c9 5000 	str.w	r5, [r9]
32307218:	3301      	adds	r3, #1
3230721a:	9226      	str	r2, [sp, #152]	@ 0x98
3230721c:	2b07      	cmp	r3, #7
3230721e:	9325      	str	r3, [sp, #148]	@ 0x94
32307220:	f300 842b 	bgt.w	32307a7a <_vfprintf_r+0xc02>
32307224:	f109 0908 	add.w	r9, r9, #8
32307228:	9b02      	ldr	r3, [sp, #8]
3230722a:	075d      	lsls	r5, r3, #29
3230722c:	d505      	bpl.n	3230723a <_vfprintf_r+0x3c2>
3230722e:	9b08      	ldr	r3, [sp, #32]
32307230:	9904      	ldr	r1, [sp, #16]
32307232:	1a5c      	subs	r4, r3, r1
32307234:	2c00      	cmp	r4, #0
32307236:	f300 8498 	bgt.w	32307b6a <_vfprintf_r+0xcf2>
3230723a:	9b08      	ldr	r3, [sp, #32]
3230723c:	9904      	ldr	r1, [sp, #16]
3230723e:	428b      	cmp	r3, r1
32307240:	bfb8      	it	lt
32307242:	460b      	movlt	r3, r1
32307244:	9907      	ldr	r1, [sp, #28]
32307246:	4419      	add	r1, r3
32307248:	9107      	str	r1, [sp, #28]
3230724a:	2a00      	cmp	r2, #0
3230724c:	f47f af5e 	bne.w	3230710c <_vfprintf_r+0x294>
32307250:	2300      	movs	r3, #0
32307252:	9325      	str	r3, [sp, #148]	@ 0x94
32307254:	9b09      	ldr	r3, [sp, #36]	@ 0x24
32307256:	b11b      	cbz	r3, 32307260 <_vfprintf_r+0x3e8>
32307258:	9909      	ldr	r1, [sp, #36]	@ 0x24
3230725a:	4658      	mov	r0, fp
3230725c:	f7fe fac4 	bl	323057e8 <_free_r>
32307260:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32307264:	e660      	b.n	32306f28 <_vfprintf_r+0xb0>
32307266:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32307268:	eddf 0bad 	vldr	d16, [pc, #692]	@ 32307520 <_vfprintf_r+0x6a8>
3230726c:	3307      	adds	r3, #7
3230726e:	9506      	str	r5, [sp, #24]
32307270:	f023 0307 	bic.w	r3, r3, #7
32307274:	ecb3 8b02 	vldmia	r3!, {d8}
32307278:	eef0 1bc8 	vabs.f64	d17, d8
3230727c:	930a      	str	r3, [sp, #40]	@ 0x28
3230727e:	eef4 1b60 	vcmp.f64	d17, d16
32307282:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32307286:	f340 8606 	ble.w	32307e96 <_vfprintf_r+0x101e>
3230728a:	eeb5 8bc0 	vcmpe.f64	d8, #0.0
3230728e:	9b02      	ldr	r3, [sp, #8]
32307290:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32307294:	9302      	str	r3, [sp, #8]
32307296:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230729a:	f101 8314 	bmi.w	323088c6 <_vfprintf_r+0x1a4e>
3230729e:	f89d 2067 	ldrb.w	r2, [sp, #103]	@ 0x67
323072a2:	f64b 253c 	movw	r5, #47676	@ 0xba3c
323072a6:	f2c3 2530 	movt	r5, #12848	@ 0x3230
323072aa:	f64b 2340 	movw	r3, #47680	@ 0xba40
323072ae:	f2c3 2330 	movt	r3, #12848	@ 0x3230
323072b2:	2c47      	cmp	r4, #71	@ 0x47
323072b4:	bfc8      	it	gt
323072b6:	461d      	movgt	r5, r3
323072b8:	2a00      	cmp	r2, #0
323072ba:	f041 8599 	bne.w	32308df0 <_vfprintf_r+0x1f78>
323072be:	2103      	movs	r1, #3
323072c0:	9209      	str	r2, [sp, #36]	@ 0x24
323072c2:	910b      	str	r1, [sp, #44]	@ 0x2c
323072c4:	e9cd 1204 	strd	r1, r2, [sp, #16]
323072c8:	9210      	str	r2, [sp, #64]	@ 0x40
323072ca:	920e      	str	r2, [sp, #56]	@ 0x38
323072cc:	920c      	str	r2, [sp, #48]	@ 0x30
323072ce:	e760      	b.n	32307192 <_vfprintf_r+0x31a>
323072d0:	0599      	lsls	r1, r3, #22
323072d2:	f53f af31 	bmi.w	32307138 <_vfprintf_r+0x2c0>
323072d6:	9c03      	ldr	r4, [sp, #12]
323072d8:	6da0      	ldr	r0, [r4, #88]	@ 0x58
323072da:	f7fd fcc5 	bl	32304c68 <__retarget_lock_release_recursive>
323072de:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
323072e2:	e729      	b.n	32307138 <_vfprintf_r+0x2c0>
323072e4:	782c      	ldrb	r4, [r5, #0]
323072e6:	e645      	b.n	32306f74 <_vfprintf_r+0xfc>
323072e8:	9b02      	ldr	r3, [sp, #8]
323072ea:	782c      	ldrb	r4, [r5, #0]
323072ec:	f043 0320 	orr.w	r3, r3, #32
323072f0:	9302      	str	r3, [sp, #8]
323072f2:	e63f      	b.n	32306f74 <_vfprintf_r+0xfc>
323072f4:	9a02      	ldr	r2, [sp, #8]
323072f6:	9506      	str	r5, [sp, #24]
323072f8:	0690      	lsls	r0, r2, #26
323072fa:	f140 8693 	bpl.w	32308024 <_vfprintf_r+0x11ac>
323072fe:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32307300:	9202      	str	r2, [sp, #8]
32307302:	3307      	adds	r3, #7
32307304:	f023 0307 	bic.w	r3, r3, #7
32307308:	461a      	mov	r2, r3
3230730a:	685b      	ldr	r3, [r3, #4]
3230730c:	f852 6b08 	ldr.w	r6, [r2], #8
32307310:	4698      	mov	r8, r3
32307312:	920a      	str	r2, [sp, #40]	@ 0x28
32307314:	2b00      	cmp	r3, #0
32307316:	f2c0 8278 	blt.w	3230780a <_vfprintf_r+0x992>
3230731a:	9a05      	ldr	r2, [sp, #20]
3230731c:	2a00      	cmp	r2, #0
3230731e:	f2c0 8164 	blt.w	323075ea <_vfprintf_r+0x772>
32307322:	9b02      	ldr	r3, [sp, #8]
32307324:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32307328:	9302      	str	r3, [sp, #8]
3230732a:	ea46 0308 	orr.w	r3, r6, r8
3230732e:	2b00      	cmp	r3, #0
32307330:	bf08      	it	eq
32307332:	2a00      	cmpeq	r2, #0
32307334:	bf18      	it	ne
32307336:	2301      	movne	r3, #1
32307338:	bf08      	it	eq
3230733a:	2300      	moveq	r3, #0
3230733c:	f040 8155 	bne.w	323075ea <_vfprintf_r+0x772>
32307340:	461a      	mov	r2, r3
32307342:	9309      	str	r3, [sp, #36]	@ 0x24
32307344:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32307348:	ad50      	add	r5, sp, #320	@ 0x140
3230734a:	9205      	str	r2, [sp, #20]
3230734c:	1e19      	subs	r1, r3, #0
3230734e:	920b      	str	r2, [sp, #44]	@ 0x2c
32307350:	9b02      	ldr	r3, [sp, #8]
32307352:	bf18      	it	ne
32307354:	2101      	movne	r1, #1
32307356:	9210      	str	r2, [sp, #64]	@ 0x40
32307358:	920e      	str	r2, [sp, #56]	@ 0x38
3230735a:	f013 0a84 	ands.w	sl, r3, #132	@ 0x84
3230735e:	920c      	str	r2, [sp, #48]	@ 0x30
32307360:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32307362:	9104      	str	r1, [sp, #16]
32307364:	4696      	mov	lr, r2
32307366:	f47f af1b 	bne.w	323071a0 <_vfprintf_r+0x328>
3230736a:	9b08      	ldr	r3, [sp, #32]
3230736c:	9904      	ldr	r1, [sp, #16]
3230736e:	1a5e      	subs	r6, r3, r1
32307370:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307372:	2e00      	cmp	r6, #0
32307374:	f300 8396 	bgt.w	32307aa4 <_vfprintf_r+0xc2c>
32307378:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
3230737c:	2b00      	cmp	r3, #0
3230737e:	f47f af12 	bne.w	323071a6 <_vfprintf_r+0x32e>
32307382:	9b05      	ldr	r3, [sp, #20]
32307384:	990b      	ldr	r1, [sp, #44]	@ 0x2c
32307386:	1a5e      	subs	r6, r3, r1
32307388:	2e00      	cmp	r6, #0
3230738a:	f77f af3a 	ble.w	32307202 <_vfprintf_r+0x38a>
3230738e:	f64b 6ab8 	movw	sl, #48824	@ 0xbeb8
32307392:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
32307396:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307398:	2e10      	cmp	r6, #16
3230739a:	dd29      	ble.n	323073f0 <_vfprintf_r+0x578>
3230739c:	9813      	ldr	r0, [sp, #76]	@ 0x4c
3230739e:	46cc      	mov	ip, r9
323073a0:	f04f 0810 	mov.w	r8, #16
323073a4:	46a9      	mov	r9, r5
323073a6:	4682      	mov	sl, r0
323073a8:	4625      	mov	r5, r4
323073aa:	4619      	mov	r1, r3
323073ac:	4604      	mov	r4, r0
323073ae:	e002      	b.n	323073b6 <_vfprintf_r+0x53e>
323073b0:	3e10      	subs	r6, #16
323073b2:	2e10      	cmp	r6, #16
323073b4:	dd18      	ble.n	323073e8 <_vfprintf_r+0x570>
323073b6:	3101      	adds	r1, #1
323073b8:	3210      	adds	r2, #16
323073ba:	e9cc 4800 	strd	r4, r8, [ip]
323073be:	2907      	cmp	r1, #7
323073c0:	f10c 0c08 	add.w	ip, ip, #8
323073c4:	e9cd 1225 	strd	r1, r2, [sp, #148]	@ 0x94
323073c8:	ddf2      	ble.n	323073b0 <_vfprintf_r+0x538>
323073ca:	9903      	ldr	r1, [sp, #12]
323073cc:	aa24      	add	r2, sp, #144	@ 0x90
323073ce:	4658      	mov	r0, fp
323073d0:	f7fc f822 	bl	32303418 <__sprint_r>
323073d4:	f10d 0c9c 	add.w	ip, sp, #156	@ 0x9c
323073d8:	2800      	cmp	r0, #0
323073da:	f47f ae9f 	bne.w	3230711c <_vfprintf_r+0x2a4>
323073de:	3e10      	subs	r6, #16
323073e0:	e9dd 1225 	ldrd	r1, r2, [sp, #148]	@ 0x94
323073e4:	2e10      	cmp	r6, #16
323073e6:	dce6      	bgt.n	323073b6 <_vfprintf_r+0x53e>
323073e8:	462c      	mov	r4, r5
323073ea:	460b      	mov	r3, r1
323073ec:	464d      	mov	r5, r9
323073ee:	46e1      	mov	r9, ip
323073f0:	3301      	adds	r3, #1
323073f2:	4432      	add	r2, r6
323073f4:	f8c9 a000 	str.w	sl, [r9]
323073f8:	2b07      	cmp	r3, #7
323073fa:	f8c9 6004 	str.w	r6, [r9, #4]
323073fe:	f109 0908 	add.w	r9, r9, #8
32307402:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307406:	f77f aefc 	ble.w	32307202 <_vfprintf_r+0x38a>
3230740a:	9903      	ldr	r1, [sp, #12]
3230740c:	aa24      	add	r2, sp, #144	@ 0x90
3230740e:	4658      	mov	r0, fp
32307410:	f7fc f802 	bl	32303418 <__sprint_r>
32307414:	2800      	cmp	r0, #0
32307416:	f47f ae81 	bne.w	3230711c <_vfprintf_r+0x2a4>
3230741a:	9b02      	ldr	r3, [sp, #8]
3230741c:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32307420:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32307422:	05de      	lsls	r6, r3, #23
32307424:	f57f aef1 	bpl.w	3230720a <_vfprintf_r+0x392>
32307428:	2c65      	cmp	r4, #101	@ 0x65
3230742a:	f340 82e5 	ble.w	323079f8 <_vfprintf_r+0xb80>
3230742e:	eeb5 8b40 	vcmp.f64	d8, #0.0
32307432:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32307436:	f040 83dc 	bne.w	32307bf2 <_vfprintf_r+0xd7a>
3230743a:	9b25      	ldr	r3, [sp, #148]	@ 0x94
3230743c:	2101      	movs	r1, #1
3230743e:	3201      	adds	r2, #1
32307440:	f8c9 1004 	str.w	r1, [r9, #4]
32307444:	3301      	adds	r3, #1
32307446:	f64b 214c 	movw	r1, #47692	@ 0xba4c
3230744a:	f2c3 2130 	movt	r1, #12848	@ 0x3230
3230744e:	f109 0908 	add.w	r9, r9, #8
32307452:	f849 1c08 	str.w	r1, [r9, #-8]
32307456:	2b07      	cmp	r3, #7
32307458:	9226      	str	r2, [sp, #152]	@ 0x98
3230745a:	9325      	str	r3, [sp, #148]	@ 0x94
3230745c:	f300 8724 	bgt.w	323082a8 <_vfprintf_r+0x1430>
32307460:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32307462:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32307464:	428b      	cmp	r3, r1
32307466:	f280 848b 	bge.w	32307d80 <_vfprintf_r+0xf08>
3230746a:	9b11      	ldr	r3, [sp, #68]	@ 0x44
3230746c:	9912      	ldr	r1, [sp, #72]	@ 0x48
3230746e:	441a      	add	r2, r3
32307470:	e9c9 1300 	strd	r1, r3, [r9]
32307474:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307476:	f109 0908 	add.w	r9, r9, #8
3230747a:	9226      	str	r2, [sp, #152]	@ 0x98
3230747c:	3301      	adds	r3, #1
3230747e:	9325      	str	r3, [sp, #148]	@ 0x94
32307480:	2b07      	cmp	r3, #7
32307482:	f300 865b 	bgt.w	3230813c <_vfprintf_r+0x12c4>
32307486:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32307488:	1e5c      	subs	r4, r3, #1
3230748a:	2c00      	cmp	r4, #0
3230748c:	f77f aecc 	ble.w	32307228 <_vfprintf_r+0x3b0>
32307490:	f64b 6ab8 	movw	sl, #48824	@ 0xbeb8
32307494:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
32307498:	9b25      	ldr	r3, [sp, #148]	@ 0x94
3230749a:	2510      	movs	r5, #16
3230749c:	f8dd 800c 	ldr.w	r8, [sp, #12]
323074a0:	4656      	mov	r6, sl
323074a2:	2c10      	cmp	r4, #16
323074a4:	dc05      	bgt.n	323074b2 <_vfprintf_r+0x63a>
323074a6:	f000 bf6e 	b.w	32308386 <_vfprintf_r+0x150e>
323074aa:	3c10      	subs	r4, #16
323074ac:	2c10      	cmp	r4, #16
323074ae:	f340 8769 	ble.w	32308384 <_vfprintf_r+0x150c>
323074b2:	3301      	adds	r3, #1
323074b4:	3210      	adds	r2, #16
323074b6:	e9c9 6500 	strd	r6, r5, [r9]
323074ba:	2b07      	cmp	r3, #7
323074bc:	f109 0908 	add.w	r9, r9, #8
323074c0:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
323074c4:	ddf1      	ble.n	323074aa <_vfprintf_r+0x632>
323074c6:	aa24      	add	r2, sp, #144	@ 0x90
323074c8:	4641      	mov	r1, r8
323074ca:	4658      	mov	r0, fp
323074cc:	f7fb ffa4 	bl	32303418 <__sprint_r>
323074d0:	2800      	cmp	r0, #0
323074d2:	f47f ae23 	bne.w	3230711c <_vfprintf_r+0x2a4>
323074d6:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
323074da:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
323074de:	e7e4      	b.n	323074aa <_vfprintf_r+0x632>
323074e0:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
323074e2:	2c43      	cmp	r4, #67	@ 0x43
323074e4:	9506      	str	r5, [sp, #24]
323074e6:	f103 0604 	add.w	r6, r3, #4
323074ea:	f000 8656 	beq.w	3230819a <_vfprintf_r+0x1322>
323074ee:	9b02      	ldr	r3, [sp, #8]
323074f0:	06db      	lsls	r3, r3, #27
323074f2:	f100 8652 	bmi.w	3230819a <_vfprintf_r+0x1322>
323074f6:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
323074f8:	ad37      	add	r5, sp, #220	@ 0xdc
323074fa:	681b      	ldr	r3, [r3, #0]
323074fc:	f88d 30dc 	strb.w	r3, [sp, #220]	@ 0xdc
32307500:	2301      	movs	r3, #1
32307502:	9304      	str	r3, [sp, #16]
32307504:	930b      	str	r3, [sp, #44]	@ 0x2c
32307506:	2300      	movs	r3, #0
32307508:	960a      	str	r6, [sp, #40]	@ 0x28
3230750a:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
3230750e:	9309      	str	r3, [sp, #36]	@ 0x24
32307510:	9305      	str	r3, [sp, #20]
32307512:	9310      	str	r3, [sp, #64]	@ 0x40
32307514:	930e      	str	r3, [sp, #56]	@ 0x38
32307516:	930c      	str	r3, [sp, #48]	@ 0x30
32307518:	e63b      	b.n	32307192 <_vfprintf_r+0x31a>
3230751a:	bf00      	nop
3230751c:	f3af 8000 	nop.w
32307520:	ffffffff 	.word	0xffffffff
32307524:	7fefffff 	.word	0x7fefffff
32307528:	f8dd 8028 	ldr.w	r8, [sp, #40]	@ 0x28
3230752c:	2300      	movs	r3, #0
3230752e:	9506      	str	r5, [sp, #24]
32307530:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32307534:	f858 5b04 	ldr.w	r5, [r8], #4
32307538:	2d00      	cmp	r5, #0
3230753a:	f000 861a 	beq.w	32308172 <_vfprintf_r+0x12fa>
3230753e:	2c53      	cmp	r4, #83	@ 0x53
32307540:	f000 86bf 	beq.w	323082c2 <_vfprintf_r+0x144a>
32307544:	9b02      	ldr	r3, [sp, #8]
32307546:	f013 0310 	ands.w	r3, r3, #16
3230754a:	930c      	str	r3, [sp, #48]	@ 0x30
3230754c:	f040 86b9 	bne.w	323082c2 <_vfprintf_r+0x144a>
32307550:	9b05      	ldr	r3, [sp, #20]
32307552:	2b00      	cmp	r3, #0
32307554:	f2c1 80eb 	blt.w	3230872e <_vfprintf_r+0x18b6>
32307558:	461a      	mov	r2, r3
3230755a:	990c      	ldr	r1, [sp, #48]	@ 0x30
3230755c:	4628      	mov	r0, r5
3230755e:	f7fd fd67 	bl	32305030 <memchr>
32307562:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32307566:	9009      	str	r0, [sp, #36]	@ 0x24
32307568:	2800      	cmp	r0, #0
3230756a:	f001 83f9 	beq.w	32308d60 <_vfprintf_r+0x1ee8>
3230756e:	9a09      	ldr	r2, [sp, #36]	@ 0x24
32307570:	1b52      	subs	r2, r2, r5
32307572:	920b      	str	r2, [sp, #44]	@ 0x2c
32307574:	ea22 72e2 	bic.w	r2, r2, r2, asr #31
32307578:	9204      	str	r2, [sp, #16]
3230757a:	2b00      	cmp	r3, #0
3230757c:	f001 80e3 	beq.w	32308746 <_vfprintf_r+0x18ce>
32307580:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32307582:	3201      	adds	r2, #1
32307584:	2473      	movs	r4, #115	@ 0x73
32307586:	9204      	str	r2, [sp, #16]
32307588:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
3230758c:	9305      	str	r3, [sp, #20]
3230758e:	9310      	str	r3, [sp, #64]	@ 0x40
32307590:	930e      	str	r3, [sp, #56]	@ 0x38
32307592:	9309      	str	r3, [sp, #36]	@ 0x24
32307594:	e5fd      	b.n	32307192 <_vfprintf_r+0x31a>
32307596:	9d03      	ldr	r5, [sp, #12]
32307598:	6da8      	ldr	r0, [r5, #88]	@ 0x58
3230759a:	f7fd fb5d 	bl	32304c58 <__retarget_lock_acquire_recursive>
3230759e:	f9b5 300c 	ldrsh.w	r3, [r5, #12]
323075a2:	6e6a      	ldr	r2, [r5, #100]	@ 0x64
323075a4:	0498      	lsls	r0, r3, #18
323075a6:	f57f ac91 	bpl.w	32306ecc <_vfprintf_r+0x54>
323075aa:	0491      	lsls	r1, r2, #18
323075ac:	f57f ac96 	bpl.w	32306edc <_vfprintf_r+0x64>
323075b0:	07d3      	lsls	r3, r2, #31
323075b2:	f57f add3 	bpl.w	3230715c <_vfprintf_r+0x2e4>
323075b6:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
323075ba:	9307      	str	r3, [sp, #28]
323075bc:	e5bf      	b.n	3230713e <_vfprintf_r+0x2c6>
323075be:	9a02      	ldr	r2, [sp, #8]
323075c0:	9506      	str	r5, [sp, #24]
323075c2:	0693      	lsls	r3, r2, #26
323075c4:	f140 8540 	bpl.w	32308048 <_vfprintf_r+0x11d0>
323075c8:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
323075ca:	2100      	movs	r1, #0
323075cc:	f88d 1067 	strb.w	r1, [sp, #103]	@ 0x67
323075d0:	3307      	adds	r3, #7
323075d2:	f023 0307 	bic.w	r3, r3, #7
323075d6:	f8d3 8004 	ldr.w	r8, [r3, #4]
323075da:	f853 6b08 	ldr.w	r6, [r3], #8
323075de:	930a      	str	r3, [sp, #40]	@ 0x28
323075e0:	9b05      	ldr	r3, [sp, #20]
323075e2:	428b      	cmp	r3, r1
323075e4:	f280 83e0 	bge.w	32307da8 <_vfprintf_r+0xf30>
323075e8:	9202      	str	r2, [sp, #8]
323075ea:	2e0a      	cmp	r6, #10
323075ec:	f178 0300 	sbcs.w	r3, r8, #0
323075f0:	f080 86d6 	bcs.w	323083a0 <_vfprintf_r+0x1528>
323075f4:	9b05      	ldr	r3, [sp, #20]
323075f6:	f20d 153f 	addw	r5, sp, #319	@ 0x13f
323075fa:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
323075fe:	3630      	adds	r6, #48	@ 0x30
32307600:	2b01      	cmp	r3, #1
32307602:	f04f 0e00 	mov.w	lr, #0
32307606:	bfb8      	it	lt
32307608:	2301      	movlt	r3, #1
3230760a:	f88d 613f 	strb.w	r6, [sp, #319]	@ 0x13f
3230760e:	9304      	str	r3, [sp, #16]
32307610:	2301      	movs	r3, #1
32307612:	e9cd 3e0b 	strd	r3, lr, [sp, #44]	@ 0x2c
32307616:	2300      	movs	r3, #0
32307618:	9309      	str	r3, [sp, #36]	@ 0x24
3230761a:	f1bc 0f00 	cmp.w	ip, #0
3230761e:	d002      	beq.n	32307626 <_vfprintf_r+0x7ae>
32307620:	9b04      	ldr	r3, [sp, #16]
32307622:	3301      	adds	r3, #1
32307624:	9304      	str	r3, [sp, #16]
32307626:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32307628:	2b00      	cmp	r3, #0
3230762a:	f001 8535 	beq.w	32309098 <_vfprintf_r+0x2220>
3230762e:	e9dd 0225 	ldrd	r0, r2, [sp, #148]	@ 0x94
32307632:	9b04      	ldr	r3, [sp, #16]
32307634:	9e02      	ldr	r6, [sp, #8]
32307636:	4696      	mov	lr, r2
32307638:	3302      	adds	r3, #2
3230763a:	9304      	str	r3, [sp, #16]
3230763c:	f016 0a84 	ands.w	sl, r6, #132	@ 0x84
32307640:	4603      	mov	r3, r0
32307642:	f000 81c7 	beq.w	323079d4 <_vfprintf_r+0xb5c>
32307646:	f1bc 0f00 	cmp.w	ip, #0
3230764a:	f040 82cb 	bne.w	32307be4 <_vfprintf_r+0xd6c>
3230764e:	f8cd c040 	str.w	ip, [sp, #64]	@ 0x40
32307652:	f8cd c038 	str.w	ip, [sp, #56]	@ 0x38
32307656:	f8cd c030 	str.w	ip, [sp, #48]	@ 0x30
3230765a:	e5b8      	b.n	323071ce <_vfprintf_r+0x356>
3230765c:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
3230765e:	f853 2b04 	ldr.w	r2, [r3], #4
32307662:	9208      	str	r2, [sp, #32]
32307664:	2a00      	cmp	r2, #0
32307666:	f280 8391 	bge.w	32307d8c <_vfprintf_r+0xf14>
3230766a:	9a08      	ldr	r2, [sp, #32]
3230766c:	930a      	str	r3, [sp, #40]	@ 0x28
3230766e:	4252      	negs	r2, r2
32307670:	9208      	str	r2, [sp, #32]
32307672:	9b02      	ldr	r3, [sp, #8]
32307674:	782c      	ldrb	r4, [r5, #0]
32307676:	f043 0304 	orr.w	r3, r3, #4
3230767a:	9302      	str	r3, [sp, #8]
3230767c:	e47a      	b.n	32306f74 <_vfprintf_r+0xfc>
3230767e:	232b      	movs	r3, #43	@ 0x2b
32307680:	782c      	ldrb	r4, [r5, #0]
32307682:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32307686:	e475      	b.n	32306f74 <_vfprintf_r+0xfc>
32307688:	9506      	str	r5, [sp, #24]
3230768a:	2200      	movs	r2, #0
3230768c:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
3230768e:	f647 0330 	movw	r3, #30768	@ 0x7830
32307692:	9805      	ldr	r0, [sp, #20]
32307694:	f8ad 3068 	strh.w	r3, [sp, #104]	@ 0x68
32307698:	f855 1b04 	ldr.w	r1, [r5], #4
3230769c:	4290      	cmp	r0, r2
3230769e:	f88d 2067 	strb.w	r2, [sp, #103]	@ 0x67
323076a2:	460b      	mov	r3, r1
323076a4:	f2c0 8526 	blt.w	323080f4 <_vfprintf_r+0x127c>
323076a8:	9802      	ldr	r0, [sp, #8]
323076aa:	f020 0080 	bic.w	r0, r0, #128	@ 0x80
323076ae:	f040 0002 	orr.w	r0, r0, #2
323076b2:	9002      	str	r0, [sp, #8]
323076b4:	9805      	ldr	r0, [sp, #20]
323076b6:	2900      	cmp	r1, #0
323076b8:	bf08      	it	eq
323076ba:	2800      	cmpeq	r0, #0
323076bc:	f000 86fe 	beq.w	323084bc <_vfprintf_r+0x1644>
323076c0:	f64b 00e0 	movw	r0, #47328	@ 0xb8e0
323076c4:	f2c3 2030 	movt	r0, #12848	@ 0x3230
323076c8:	2478      	movs	r4, #120	@ 0x78
323076ca:	9902      	ldr	r1, [sp, #8]
323076cc:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
323076d0:	f001 0102 	and.w	r1, r1, #2
323076d4:	950a      	str	r5, [sp, #40]	@ 0x28
323076d6:	910c      	str	r1, [sp, #48]	@ 0x30
323076d8:	f000 bd19 	b.w	3230810e <_vfprintf_r+0x1296>
323076dc:	9802      	ldr	r0, [sp, #8]
323076de:	9506      	str	r5, [sp, #24]
323076e0:	0682      	lsls	r2, r0, #26
323076e2:	f140 83b6 	bpl.w	32307e52 <_vfprintf_r+0xfda>
323076e6:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
323076e8:	3307      	adds	r3, #7
323076ea:	f023 0307 	bic.w	r3, r3, #7
323076ee:	6859      	ldr	r1, [r3, #4]
323076f0:	f853 2b08 	ldr.w	r2, [r3], #8
323076f4:	930a      	str	r3, [sp, #40]	@ 0x28
323076f6:	2300      	movs	r3, #0
323076f8:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
323076fc:	9b05      	ldr	r3, [sp, #20]
323076fe:	2b00      	cmp	r3, #0
32307700:	db41      	blt.n	32307786 <_vfprintf_r+0x90e>
32307702:	9b05      	ldr	r3, [sp, #20]
32307704:	1e1d      	subs	r5, r3, #0
32307706:	bf18      	it	ne
32307708:	2501      	movne	r5, #1
3230770a:	ea52 0301 	orrs.w	r3, r2, r1
3230770e:	f045 0301 	orr.w	r3, r5, #1
32307712:	bf08      	it	eq
32307714:	462b      	moveq	r3, r5
32307716:	f420 6590 	bic.w	r5, r0, #1152	@ 0x480
3230771a:	9502      	str	r5, [sp, #8]
3230771c:	2b00      	cmp	r3, #0
3230771e:	d135      	bne.n	3230778c <_vfprintf_r+0x914>
32307720:	f010 0201 	ands.w	r2, r0, #1
32307724:	9204      	str	r2, [sp, #16]
32307726:	f000 8335 	beq.w	32307d94 <_vfprintf_r+0xf1c>
3230772a:	4619      	mov	r1, r3
3230772c:	9305      	str	r3, [sp, #20]
3230772e:	f20d 153f 	addw	r5, sp, #319	@ 0x13f
32307732:	2330      	movs	r3, #48	@ 0x30
32307734:	920b      	str	r2, [sp, #44]	@ 0x2c
32307736:	f88d 313f 	strb.w	r3, [sp, #319]	@ 0x13f
3230773a:	9109      	str	r1, [sp, #36]	@ 0x24
3230773c:	9110      	str	r1, [sp, #64]	@ 0x40
3230773e:	910e      	str	r1, [sp, #56]	@ 0x38
32307740:	910c      	str	r1, [sp, #48]	@ 0x30
32307742:	e526      	b.n	32307192 <_vfprintf_r+0x31a>
32307744:	9902      	ldr	r1, [sp, #8]
32307746:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
32307748:	9506      	str	r5, [sp, #24]
3230774a:	1d13      	adds	r3, r2, #4
3230774c:	068e      	lsls	r6, r1, #26
3230774e:	f140 8391 	bpl.w	32307e74 <_vfprintf_r+0xffc>
32307752:	6812      	ldr	r2, [r2, #0]
32307754:	9907      	ldr	r1, [sp, #28]
32307756:	6011      	str	r1, [r2, #0]
32307758:	17c9      	asrs	r1, r1, #31
3230775a:	6051      	str	r1, [r2, #4]
3230775c:	930a      	str	r3, [sp, #40]	@ 0x28
3230775e:	f7ff bbe3 	b.w	32306f28 <_vfprintf_r+0xb0>
32307762:	9b02      	ldr	r3, [sp, #8]
32307764:	9506      	str	r5, [sp, #24]
32307766:	f043 0010 	orr.w	r0, r3, #16
3230776a:	0699      	lsls	r1, r3, #26
3230776c:	d4bb      	bmi.n	323076e6 <_vfprintf_r+0x86e>
3230776e:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32307770:	3304      	adds	r3, #4
32307772:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
32307774:	2100      	movs	r1, #0
32307776:	930a      	str	r3, [sp, #40]	@ 0x28
32307778:	2300      	movs	r3, #0
3230777a:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
3230777e:	9b05      	ldr	r3, [sp, #20]
32307780:	6812      	ldr	r2, [r2, #0]
32307782:	2b00      	cmp	r3, #0
32307784:	dabd      	bge.n	32307702 <_vfprintf_r+0x88a>
32307786:	f420 6380 	bic.w	r3, r0, #1024	@ 0x400
3230778a:	9302      	str	r3, [sp, #8]
3230778c:	ad50      	add	r5, sp, #320	@ 0x140
3230778e:	08d0      	lsrs	r0, r2, #3
32307790:	f002 0307 	and.w	r3, r2, #7
32307794:	ea40 7241 	orr.w	r2, r0, r1, lsl #29
32307798:	08c9      	lsrs	r1, r1, #3
3230779a:	3330      	adds	r3, #48	@ 0x30
3230779c:	4628      	mov	r0, r5
3230779e:	ea52 0601 	orrs.w	r6, r2, r1
323077a2:	f805 3d01 	strb.w	r3, [r5, #-1]!
323077a6:	d1f2      	bne.n	3230778e <_vfprintf_r+0x916>
323077a8:	9a02      	ldr	r2, [sp, #8]
323077aa:	2b30      	cmp	r3, #48	@ 0x30
323077ac:	f002 0201 	and.w	r2, r2, #1
323077b0:	bf08      	it	eq
323077b2:	2200      	moveq	r2, #0
323077b4:	2a00      	cmp	r2, #0
323077b6:	f040 8568 	bne.w	3230828a <_vfprintf_r+0x1412>
323077ba:	9a05      	ldr	r2, [sp, #20]
323077bc:	ab50      	add	r3, sp, #320	@ 0x140
323077be:	1b5b      	subs	r3, r3, r5
323077c0:	930b      	str	r3, [sp, #44]	@ 0x2c
323077c2:	429a      	cmp	r2, r3
323077c4:	bfb8      	it	lt
323077c6:	461a      	movlt	r2, r3
323077c8:	9204      	str	r2, [sp, #16]
323077ca:	2300      	movs	r3, #0
323077cc:	9309      	str	r3, [sp, #36]	@ 0x24
323077ce:	9310      	str	r3, [sp, #64]	@ 0x40
323077d0:	930e      	str	r3, [sp, #56]	@ 0x38
323077d2:	930c      	str	r3, [sp, #48]	@ 0x30
323077d4:	e4dd      	b.n	32307192 <_vfprintf_r+0x31a>
323077d6:	9b02      	ldr	r3, [sp, #8]
323077d8:	782c      	ldrb	r4, [r5, #0]
323077da:	f043 0308 	orr.w	r3, r3, #8
323077de:	9302      	str	r3, [sp, #8]
323077e0:	f7ff bbc8 	b.w	32306f74 <_vfprintf_r+0xfc>
323077e4:	9b02      	ldr	r3, [sp, #8]
323077e6:	9506      	str	r5, [sp, #24]
323077e8:	f043 0210 	orr.w	r2, r3, #16
323077ec:	069d      	lsls	r5, r3, #26
323077ee:	f53f ad86 	bmi.w	323072fe <_vfprintf_r+0x486>
323077f2:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
323077f4:	3304      	adds	r3, #4
323077f6:	990a      	ldr	r1, [sp, #40]	@ 0x28
323077f8:	930a      	str	r3, [sp, #40]	@ 0x28
323077fa:	9202      	str	r2, [sp, #8]
323077fc:	680e      	ldr	r6, [r1, #0]
323077fe:	ea4f 78e6 	mov.w	r8, r6, asr #31
32307802:	4643      	mov	r3, r8
32307804:	2b00      	cmp	r3, #0
32307806:	f6bf ad88 	bge.w	3230731a <_vfprintf_r+0x4a2>
3230780a:	4276      	negs	r6, r6
3230780c:	f04f 032d 	mov.w	r3, #45	@ 0x2d
32307810:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32307814:	9b05      	ldr	r3, [sp, #20]
32307816:	eb68 0848 	sbc.w	r8, r8, r8, lsl #1
3230781a:	2b00      	cmp	r3, #0
3230781c:	f6ff aee5 	blt.w	323075ea <_vfprintf_r+0x772>
32307820:	9b02      	ldr	r3, [sp, #8]
32307822:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32307826:	9302      	str	r3, [sp, #8]
32307828:	e6df      	b.n	323075ea <_vfprintf_r+0x772>
3230782a:	782c      	ldrb	r4, [r5, #0]
3230782c:	9b02      	ldr	r3, [sp, #8]
3230782e:	2c6c      	cmp	r4, #108	@ 0x6c
32307830:	f000 8498 	beq.w	32308164 <_vfprintf_r+0x12ec>
32307834:	f043 0310 	orr.w	r3, r3, #16
32307838:	9302      	str	r3, [sp, #8]
3230783a:	f7ff bb9b 	b.w	32306f74 <_vfprintf_r+0xfc>
3230783e:	782c      	ldrb	r4, [r5, #0]
32307840:	9b02      	ldr	r3, [sp, #8]
32307842:	2c68      	cmp	r4, #104	@ 0x68
32307844:	f000 8487 	beq.w	32308156 <_vfprintf_r+0x12de>
32307848:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
3230784c:	9302      	str	r3, [sp, #8]
3230784e:	f7ff bb91 	b.w	32306f74 <_vfprintf_r+0xfc>
32307852:	9b02      	ldr	r3, [sp, #8]
32307854:	9506      	str	r5, [sp, #24]
32307856:	f043 0210 	orr.w	r2, r3, #16
3230785a:	0699      	lsls	r1, r3, #26
3230785c:	f53f aeb4 	bmi.w	323075c8 <_vfprintf_r+0x750>
32307860:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32307862:	3304      	adds	r3, #4
32307864:	990a      	ldr	r1, [sp, #40]	@ 0x28
32307866:	f04f 0800 	mov.w	r8, #0
3230786a:	9805      	ldr	r0, [sp, #20]
3230786c:	f88d 8067 	strb.w	r8, [sp, #103]	@ 0x67
32307870:	6809      	ldr	r1, [r1, #0]
32307872:	4540      	cmp	r0, r8
32307874:	460e      	mov	r6, r1
32307876:	f2c1 80ee 	blt.w	32308a56 <_vfprintf_r+0x1bde>
3230787a:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
3230787e:	4541      	cmp	r1, r8
32307880:	bf08      	it	eq
32307882:	4540      	cmpeq	r0, r8
32307884:	9202      	str	r2, [sp, #8]
32307886:	930a      	str	r3, [sp, #40]	@ 0x28
32307888:	f47f aeaf 	bne.w	323075ea <_vfprintf_r+0x772>
3230788c:	e29b      	b.n	32307dc6 <_vfprintf_r+0xf4e>
3230788e:	4658      	mov	r0, fp
32307890:	f7fd f936 	bl	32304b00 <_localeconv_r>
32307894:	6843      	ldr	r3, [r0, #4]
32307896:	9316      	str	r3, [sp, #88]	@ 0x58
32307898:	4618      	mov	r0, r3
3230789a:	f7fd fed1 	bl	32305640 <strlen>
3230789e:	4606      	mov	r6, r0
323078a0:	9015      	str	r0, [sp, #84]	@ 0x54
323078a2:	4658      	mov	r0, fp
323078a4:	f7fd f92c 	bl	32304b00 <_localeconv_r>
323078a8:	6883      	ldr	r3, [r0, #8]
323078aa:	782c      	ldrb	r4, [r5, #0]
323078ac:	2e00      	cmp	r6, #0
323078ae:	bf18      	it	ne
323078b0:	2b00      	cmpne	r3, #0
323078b2:	9317      	str	r3, [sp, #92]	@ 0x5c
323078b4:	f43f ab5e 	beq.w	32306f74 <_vfprintf_r+0xfc>
323078b8:	781b      	ldrb	r3, [r3, #0]
323078ba:	2b00      	cmp	r3, #0
323078bc:	f43f ab5a 	beq.w	32306f74 <_vfprintf_r+0xfc>
323078c0:	9b02      	ldr	r3, [sp, #8]
323078c2:	f443 6380 	orr.w	r3, r3, #1024	@ 0x400
323078c6:	9302      	str	r3, [sp, #8]
323078c8:	f7ff bb54 	b.w	32306f74 <_vfprintf_r+0xfc>
323078cc:	9b02      	ldr	r3, [sp, #8]
323078ce:	782c      	ldrb	r4, [r5, #0]
323078d0:	f043 0301 	orr.w	r3, r3, #1
323078d4:	9302      	str	r3, [sp, #8]
323078d6:	f7ff bb4d 	b.w	32306f74 <_vfprintf_r+0xfc>
323078da:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
323078de:	782c      	ldrb	r4, [r5, #0]
323078e0:	2b00      	cmp	r3, #0
323078e2:	f47f ab47 	bne.w	32306f74 <_vfprintf_r+0xfc>
323078e6:	2320      	movs	r3, #32
323078e8:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
323078ec:	f7ff bb42 	b.w	32306f74 <_vfprintf_r+0xfc>
323078f0:	9b02      	ldr	r3, [sp, #8]
323078f2:	782c      	ldrb	r4, [r5, #0]
323078f4:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
323078f8:	9302      	str	r3, [sp, #8]
323078fa:	f7ff bb3b 	b.w	32306f74 <_vfprintf_r+0xfc>
323078fe:	462a      	mov	r2, r5
32307900:	f812 4b01 	ldrb.w	r4, [r2], #1
32307904:	2c2a      	cmp	r4, #42	@ 0x2a
32307906:	f001 836d 	beq.w	32308fe4 <_vfprintf_r+0x216c>
3230790a:	f1a4 0330 	sub.w	r3, r4, #48	@ 0x30
3230790e:	2b09      	cmp	r3, #9
32307910:	bf98      	it	ls
32307912:	2100      	movls	r1, #0
32307914:	bf98      	it	ls
32307916:	200a      	movls	r0, #10
32307918:	f201 8182 	bhi.w	32308c20 <_vfprintf_r+0x1da8>
3230791c:	f812 4b01 	ldrb.w	r4, [r2], #1
32307920:	fb00 3101 	mla	r1, r0, r1, r3
32307924:	f1a4 0330 	sub.w	r3, r4, #48	@ 0x30
32307928:	2b09      	cmp	r3, #9
3230792a:	d9f7      	bls.n	3230791c <_vfprintf_r+0xaa4>
3230792c:	ea41 73e1 	orr.w	r3, r1, r1, asr #31
32307930:	4615      	mov	r5, r2
32307932:	9305      	str	r3, [sp, #20]
32307934:	f7ff bb1f 	b.w	32306f76 <_vfprintf_r+0xfe>
32307938:	9b08      	ldr	r3, [sp, #32]
3230793a:	9904      	ldr	r1, [sp, #16]
3230793c:	1a5e      	subs	r6, r3, r1
3230793e:	2e00      	cmp	r6, #0
32307940:	f77f ac59 	ble.w	323071f6 <_vfprintf_r+0x37e>
32307944:	f64b 6ab8 	movw	sl, #48824	@ 0xbeb8
32307948:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
3230794c:	9b25      	ldr	r3, [sp, #148]	@ 0x94
3230794e:	2e10      	cmp	r6, #16
32307950:	dd27      	ble.n	323079a2 <_vfprintf_r+0xb2a>
32307952:	4649      	mov	r1, r9
32307954:	f04f 0810 	mov.w	r8, #16
32307958:	46a9      	mov	r9, r5
3230795a:	4625      	mov	r5, r4
3230795c:	4654      	mov	r4, sl
3230795e:	f8dd a00c 	ldr.w	sl, [sp, #12]
32307962:	e002      	b.n	3230796a <_vfprintf_r+0xaf2>
32307964:	3e10      	subs	r6, #16
32307966:	2e10      	cmp	r6, #16
32307968:	dd17      	ble.n	3230799a <_vfprintf_r+0xb22>
3230796a:	3301      	adds	r3, #1
3230796c:	3210      	adds	r2, #16
3230796e:	2b07      	cmp	r3, #7
32307970:	e9c1 4800 	strd	r4, r8, [r1]
32307974:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307978:	bfd8      	it	le
3230797a:	3108      	addle	r1, #8
3230797c:	ddf2      	ble.n	32307964 <_vfprintf_r+0xaec>
3230797e:	aa24      	add	r2, sp, #144	@ 0x90
32307980:	4651      	mov	r1, sl
32307982:	4658      	mov	r0, fp
32307984:	f7fb fd48 	bl	32303418 <__sprint_r>
32307988:	2800      	cmp	r0, #0
3230798a:	f47f abc7 	bne.w	3230711c <_vfprintf_r+0x2a4>
3230798e:	3e10      	subs	r6, #16
32307990:	a927      	add	r1, sp, #156	@ 0x9c
32307992:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32307996:	2e10      	cmp	r6, #16
32307998:	dce7      	bgt.n	3230796a <_vfprintf_r+0xaf2>
3230799a:	46a2      	mov	sl, r4
3230799c:	462c      	mov	r4, r5
3230799e:	464d      	mov	r5, r9
323079a0:	4689      	mov	r9, r1
323079a2:	3301      	adds	r3, #1
323079a4:	4432      	add	r2, r6
323079a6:	f8c9 a000 	str.w	sl, [r9]
323079aa:	2b07      	cmp	r3, #7
323079ac:	f8c9 6004 	str.w	r6, [r9, #4]
323079b0:	f109 0908 	add.w	r9, r9, #8
323079b4:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
323079b8:	f77f ac1d 	ble.w	323071f6 <_vfprintf_r+0x37e>
323079bc:	9903      	ldr	r1, [sp, #12]
323079be:	aa24      	add	r2, sp, #144	@ 0x90
323079c0:	4658      	mov	r0, fp
323079c2:	f7fb fd29 	bl	32303418 <__sprint_r>
323079c6:	2800      	cmp	r0, #0
323079c8:	f47f aba8 	bne.w	3230711c <_vfprintf_r+0x2a4>
323079cc:	9a26      	ldr	r2, [sp, #152]	@ 0x98
323079ce:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
323079d2:	e410      	b.n	323071f6 <_vfprintf_r+0x37e>
323079d4:	9e08      	ldr	r6, [sp, #32]
323079d6:	9904      	ldr	r1, [sp, #16]
323079d8:	1a76      	subs	r6, r6, r1
323079da:	2e00      	cmp	r6, #0
323079dc:	dc5a      	bgt.n	32307a94 <_vfprintf_r+0xc1c>
323079de:	f8cd a040 	str.w	sl, [sp, #64]	@ 0x40
323079e2:	f8cd a038 	str.w	sl, [sp, #56]	@ 0x38
323079e6:	f8cd a030 	str.w	sl, [sp, #48]	@ 0x30
323079ea:	f1bc 0f00 	cmp.w	ip, #0
323079ee:	f43f abee 	beq.w	323071ce <_vfprintf_r+0x356>
323079f2:	2602      	movs	r6, #2
323079f4:	f7ff bbd9 	b.w	323071aa <_vfprintf_r+0x332>
323079f8:	9b25      	ldr	r3, [sp, #148]	@ 0x94
323079fa:	3201      	adds	r2, #1
323079fc:	990f      	ldr	r1, [sp, #60]	@ 0x3c
323079fe:	f109 0008 	add.w	r0, r9, #8
32307a02:	3301      	adds	r3, #1
32307a04:	2901      	cmp	r1, #1
32307a06:	f340 8174 	ble.w	32307cf2 <_vfprintf_r+0xe7a>
32307a0a:	2101      	movs	r1, #1
32307a0c:	2b07      	cmp	r3, #7
32307a0e:	f8c9 5000 	str.w	r5, [r9]
32307a12:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307a16:	f8c9 1004 	str.w	r1, [r9, #4]
32307a1a:	f300 83f1 	bgt.w	32308200 <_vfprintf_r+0x1388>
32307a1e:	9911      	ldr	r1, [sp, #68]	@ 0x44
32307a20:	3301      	adds	r3, #1
32307a22:	9c12      	ldr	r4, [sp, #72]	@ 0x48
32307a24:	2b07      	cmp	r3, #7
32307a26:	440a      	add	r2, r1
32307a28:	e9c0 4100 	strd	r4, r1, [r0]
32307a2c:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307a30:	bfd8      	it	le
32307a32:	3008      	addle	r0, #8
32307a34:	f300 83d8 	bgt.w	323081e8 <_vfprintf_r+0x1370>
32307a38:	eeb5 8b40 	vcmp.f64	d8, #0.0
32307a3c:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32307a3e:	1e4e      	subs	r6, r1, #1
32307a40:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32307a44:	f000 816f 	beq.w	32307d26 <_vfprintf_r+0xeae>
32307a48:	3301      	adds	r3, #1
32307a4a:	3501      	adds	r5, #1
32307a4c:	6005      	str	r5, [r0, #0]
32307a4e:	2b07      	cmp	r3, #7
32307a50:	6046      	str	r6, [r0, #4]
32307a52:	4432      	add	r2, r6
32307a54:	bfd8      	it	le
32307a56:	3008      	addle	r0, #8
32307a58:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307a5c:	f300 8157 	bgt.w	32307d0e <_vfprintf_r+0xe96>
32307a60:	9914      	ldr	r1, [sp, #80]	@ 0x50
32307a62:	3301      	adds	r3, #1
32307a64:	6041      	str	r1, [r0, #4]
32307a66:	f100 0908 	add.w	r9, r0, #8
32307a6a:	440a      	add	r2, r1
32307a6c:	2b07      	cmp	r3, #7
32307a6e:	a91e      	add	r1, sp, #120	@ 0x78
32307a70:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307a74:	6001      	str	r1, [r0, #0]
32307a76:	f77f abd7 	ble.w	32307228 <_vfprintf_r+0x3b0>
32307a7a:	9903      	ldr	r1, [sp, #12]
32307a7c:	aa24      	add	r2, sp, #144	@ 0x90
32307a7e:	4658      	mov	r0, fp
32307a80:	f7fb fcca 	bl	32303418 <__sprint_r>
32307a84:	2800      	cmp	r0, #0
32307a86:	f47f ab49 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307a8a:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32307a8c:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32307a90:	f7ff bbca 	b.w	32307228 <_vfprintf_r+0x3b0>
32307a94:	f8cd a040 	str.w	sl, [sp, #64]	@ 0x40
32307a98:	f8cd a038 	str.w	sl, [sp, #56]	@ 0x38
32307a9c:	f8cd a030 	str.w	sl, [sp, #48]	@ 0x30
32307aa0:	f04f 0a02 	mov.w	sl, #2
32307aa4:	f64b 68c8 	movw	r8, #48840	@ 0xbec8
32307aa8:	f2c3 2830 	movt	r8, #12848	@ 0x3230
32307aac:	4671      	mov	r1, lr
32307aae:	4618      	mov	r0, r3
32307ab0:	2e10      	cmp	r6, #16
32307ab2:	dd27      	ble.n	32307b04 <_vfprintf_r+0xc8c>
32307ab4:	464a      	mov	r2, r9
32307ab6:	2310      	movs	r3, #16
32307ab8:	46a9      	mov	r9, r5
32307aba:	4625      	mov	r5, r4
32307abc:	4644      	mov	r4, r8
32307abe:	f8dd 800c 	ldr.w	r8, [sp, #12]
32307ac2:	e002      	b.n	32307aca <_vfprintf_r+0xc52>
32307ac4:	3e10      	subs	r6, #16
32307ac6:	2e10      	cmp	r6, #16
32307ac8:	dd18      	ble.n	32307afc <_vfprintf_r+0xc84>
32307aca:	3001      	adds	r0, #1
32307acc:	3110      	adds	r1, #16
32307ace:	2807      	cmp	r0, #7
32307ad0:	e9c2 4300 	strd	r4, r3, [r2]
32307ad4:	e9cd 0125 	strd	r0, r1, [sp, #148]	@ 0x94
32307ad8:	bfd8      	it	le
32307ada:	3208      	addle	r2, #8
32307adc:	ddf2      	ble.n	32307ac4 <_vfprintf_r+0xc4c>
32307ade:	aa24      	add	r2, sp, #144	@ 0x90
32307ae0:	4641      	mov	r1, r8
32307ae2:	4658      	mov	r0, fp
32307ae4:	f7fb fc98 	bl	32303418 <__sprint_r>
32307ae8:	aa27      	add	r2, sp, #156	@ 0x9c
32307aea:	2800      	cmp	r0, #0
32307aec:	f47f ab16 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307af0:	3e10      	subs	r6, #16
32307af2:	2310      	movs	r3, #16
32307af4:	e9dd 0125 	ldrd	r0, r1, [sp, #148]	@ 0x94
32307af8:	2e10      	cmp	r6, #16
32307afa:	dce6      	bgt.n	32307aca <_vfprintf_r+0xc52>
32307afc:	46a0      	mov	r8, r4
32307afe:	462c      	mov	r4, r5
32307b00:	464d      	mov	r5, r9
32307b02:	4691      	mov	r9, r2
32307b04:	3001      	adds	r0, #1
32307b06:	1872      	adds	r2, r6, r1
32307b08:	2807      	cmp	r0, #7
32307b0a:	f8c9 8000 	str.w	r8, [r9]
32307b0e:	f8c9 6004 	str.w	r6, [r9, #4]
32307b12:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
32307b16:	f300 838a 	bgt.w	3230822e <_vfprintf_r+0x13b6>
32307b1a:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32307b1e:	f109 0908 	add.w	r9, r9, #8
32307b22:	2b00      	cmp	r3, #0
32307b24:	f040 815b 	bne.w	32307dde <_vfprintf_r+0xf66>
32307b28:	f1ba 0f00 	cmp.w	sl, #0
32307b2c:	f43f ab63 	beq.w	323071f6 <_vfprintf_r+0x37e>
32307b30:	469a      	mov	sl, r3
32307b32:	f7ff bb4c 	b.w	323071ce <_vfprintf_r+0x356>
32307b36:	9903      	ldr	r1, [sp, #12]
32307b38:	aa24      	add	r2, sp, #144	@ 0x90
32307b3a:	4658      	mov	r0, fp
32307b3c:	f7fb fc6c 	bl	32303418 <__sprint_r>
32307b40:	2800      	cmp	r0, #0
32307b42:	f47f aaeb 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307b46:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32307b48:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32307b4c:	f7ff bb4f 	b.w	323071ee <_vfprintf_r+0x376>
32307b50:	9903      	ldr	r1, [sp, #12]
32307b52:	aa24      	add	r2, sp, #144	@ 0x90
32307b54:	4658      	mov	r0, fp
32307b56:	f7fb fc5f 	bl	32303418 <__sprint_r>
32307b5a:	2800      	cmp	r0, #0
32307b5c:	f47f aade 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307b60:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32307b62:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32307b66:	f7ff bb30 	b.w	323071ca <_vfprintf_r+0x352>
32307b6a:	f64b 68c8 	movw	r8, #48840	@ 0xbec8
32307b6e:	f2c3 2830 	movt	r8, #12848	@ 0x3230
32307b72:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307b74:	2c10      	cmp	r4, #16
32307b76:	dd21      	ble.n	32307bbc <_vfprintf_r+0xd44>
32307b78:	4646      	mov	r6, r8
32307b7a:	2510      	movs	r5, #16
32307b7c:	f8dd 800c 	ldr.w	r8, [sp, #12]
32307b80:	e002      	b.n	32307b88 <_vfprintf_r+0xd10>
32307b82:	3c10      	subs	r4, #16
32307b84:	2c10      	cmp	r4, #16
32307b86:	dd18      	ble.n	32307bba <_vfprintf_r+0xd42>
32307b88:	3301      	adds	r3, #1
32307b8a:	3210      	adds	r2, #16
32307b8c:	e9c9 6500 	strd	r6, r5, [r9]
32307b90:	2b07      	cmp	r3, #7
32307b92:	f109 0908 	add.w	r9, r9, #8
32307b96:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307b9a:	ddf2      	ble.n	32307b82 <_vfprintf_r+0xd0a>
32307b9c:	aa24      	add	r2, sp, #144	@ 0x90
32307b9e:	4641      	mov	r1, r8
32307ba0:	4658      	mov	r0, fp
32307ba2:	f7fb fc39 	bl	32303418 <__sprint_r>
32307ba6:	2800      	cmp	r0, #0
32307ba8:	f47f aab8 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307bac:	3c10      	subs	r4, #16
32307bae:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32307bb2:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32307bb6:	2c10      	cmp	r4, #16
32307bb8:	dce6      	bgt.n	32307b88 <_vfprintf_r+0xd10>
32307bba:	46b0      	mov	r8, r6
32307bbc:	3301      	adds	r3, #1
32307bbe:	4422      	add	r2, r4
32307bc0:	2b07      	cmp	r3, #7
32307bc2:	e9c9 8400 	strd	r8, r4, [r9]
32307bc6:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307bca:	f77f ab36 	ble.w	3230723a <_vfprintf_r+0x3c2>
32307bce:	9903      	ldr	r1, [sp, #12]
32307bd0:	aa24      	add	r2, sp, #144	@ 0x90
32307bd2:	4658      	mov	r0, fp
32307bd4:	f7fb fc20 	bl	32303418 <__sprint_r>
32307bd8:	2800      	cmp	r0, #0
32307bda:	f47f aa9f 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307bde:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32307be0:	f7ff bb2b 	b.w	3230723a <_vfprintf_r+0x3c2>
32307be4:	2300      	movs	r3, #0
32307be6:	2602      	movs	r6, #2
32307be8:	9310      	str	r3, [sp, #64]	@ 0x40
32307bea:	930e      	str	r3, [sp, #56]	@ 0x38
32307bec:	930c      	str	r3, [sp, #48]	@ 0x30
32307bee:	f7ff badc 	b.w	323071aa <_vfprintf_r+0x332>
32307bf2:	991b      	ldr	r1, [sp, #108]	@ 0x6c
32307bf4:	2900      	cmp	r1, #0
32307bf6:	f340 80f7 	ble.w	32307de8 <_vfprintf_r+0xf70>
32307bfa:	9c0c      	ldr	r4, [sp, #48]	@ 0x30
32307bfc:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32307bfe:	429c      	cmp	r4, r3
32307c00:	bfa8      	it	ge
32307c02:	461c      	movge	r4, r3
32307c04:	2c00      	cmp	r4, #0
32307c06:	dd0b      	ble.n	32307c20 <_vfprintf_r+0xda8>
32307c08:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307c0a:	4422      	add	r2, r4
32307c0c:	e9c9 5400 	strd	r5, r4, [r9]
32307c10:	f109 0908 	add.w	r9, r9, #8
32307c14:	3301      	adds	r3, #1
32307c16:	9226      	str	r2, [sp, #152]	@ 0x98
32307c18:	2b07      	cmp	r3, #7
32307c1a:	9325      	str	r3, [sp, #148]	@ 0x94
32307c1c:	f300 873c 	bgt.w	32308a98 <_vfprintf_r+0x1c20>
32307c20:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32307c22:	ea24 74e4 	bic.w	r4, r4, r4, asr #31
32307c26:	1b1c      	subs	r4, r3, r4
32307c28:	2c00      	cmp	r4, #0
32307c2a:	f300 8454 	bgt.w	323084d6 <_vfprintf_r+0x165e>
32307c2e:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32307c30:	442b      	add	r3, r5
32307c32:	4698      	mov	r8, r3
32307c34:	9b02      	ldr	r3, [sp, #8]
32307c36:	0558      	lsls	r0, r3, #21
32307c38:	f100 865b 	bmi.w	323088f2 <_vfprintf_r+0x1a7a>
32307c3c:	9c1b      	ldr	r4, [sp, #108]	@ 0x6c
32307c3e:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32307c40:	429c      	cmp	r4, r3
32307c42:	db03      	blt.n	32307c4c <_vfprintf_r+0xdd4>
32307c44:	9902      	ldr	r1, [sp, #8]
32307c46:	07c9      	lsls	r1, r1, #31
32307c48:	f140 8545 	bpl.w	323086d6 <_vfprintf_r+0x185e>
32307c4c:	9b11      	ldr	r3, [sp, #68]	@ 0x44
32307c4e:	9912      	ldr	r1, [sp, #72]	@ 0x48
32307c50:	441a      	add	r2, r3
32307c52:	e9c9 1300 	strd	r1, r3, [r9]
32307c56:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307c58:	f109 0908 	add.w	r9, r9, #8
32307c5c:	9226      	str	r2, [sp, #152]	@ 0x98
32307c5e:	3301      	adds	r3, #1
32307c60:	9325      	str	r3, [sp, #148]	@ 0x94
32307c62:	2b07      	cmp	r3, #7
32307c64:	f300 8743 	bgt.w	32308aee <_vfprintf_r+0x1c76>
32307c68:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32307c6a:	441d      	add	r5, r3
32307c6c:	1b1c      	subs	r4, r3, r4
32307c6e:	eba5 0508 	sub.w	r5, r5, r8
32307c72:	42a5      	cmp	r5, r4
32307c74:	bfa8      	it	ge
32307c76:	4625      	movge	r5, r4
32307c78:	2d00      	cmp	r5, #0
32307c7a:	dd0d      	ble.n	32307c98 <_vfprintf_r+0xe20>
32307c7c:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307c7e:	442a      	add	r2, r5
32307c80:	f8c9 8000 	str.w	r8, [r9]
32307c84:	f109 0908 	add.w	r9, r9, #8
32307c88:	3301      	adds	r3, #1
32307c8a:	f849 5c04 	str.w	r5, [r9, #-4]
32307c8e:	2b07      	cmp	r3, #7
32307c90:	9226      	str	r2, [sp, #152]	@ 0x98
32307c92:	9325      	str	r3, [sp, #148]	@ 0x94
32307c94:	f300 87b4 	bgt.w	32308c00 <_vfprintf_r+0x1d88>
32307c98:	ea25 75e5 	bic.w	r5, r5, r5, asr #31
32307c9c:	1b64      	subs	r4, r4, r5
32307c9e:	2c00      	cmp	r4, #0
32307ca0:	f77f aac2 	ble.w	32307228 <_vfprintf_r+0x3b0>
32307ca4:	f64b 6ab8 	movw	sl, #48824	@ 0xbeb8
32307ca8:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
32307cac:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307cae:	2510      	movs	r5, #16
32307cb0:	f8dd 800c 	ldr.w	r8, [sp, #12]
32307cb4:	4656      	mov	r6, sl
32307cb6:	2c10      	cmp	r4, #16
32307cb8:	dc04      	bgt.n	32307cc4 <_vfprintf_r+0xe4c>
32307cba:	e364      	b.n	32308386 <_vfprintf_r+0x150e>
32307cbc:	3c10      	subs	r4, #16
32307cbe:	2c10      	cmp	r4, #16
32307cc0:	f340 8360 	ble.w	32308384 <_vfprintf_r+0x150c>
32307cc4:	3301      	adds	r3, #1
32307cc6:	3210      	adds	r2, #16
32307cc8:	e9c9 6500 	strd	r6, r5, [r9]
32307ccc:	2b07      	cmp	r3, #7
32307cce:	f109 0908 	add.w	r9, r9, #8
32307cd2:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307cd6:	ddf1      	ble.n	32307cbc <_vfprintf_r+0xe44>
32307cd8:	aa24      	add	r2, sp, #144	@ 0x90
32307cda:	4641      	mov	r1, r8
32307cdc:	4658      	mov	r0, fp
32307cde:	f7fb fb9b 	bl	32303418 <__sprint_r>
32307ce2:	2800      	cmp	r0, #0
32307ce4:	f47f aa1a 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307ce8:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32307cec:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32307cf0:	e7e4      	b.n	32307cbc <_vfprintf_r+0xe44>
32307cf2:	9902      	ldr	r1, [sp, #8]
32307cf4:	07ce      	lsls	r6, r1, #31
32307cf6:	f53f ae88 	bmi.w	32307a0a <_vfprintf_r+0xb92>
32307cfa:	2101      	movs	r1, #1
32307cfc:	2b07      	cmp	r3, #7
32307cfe:	f8c9 5000 	str.w	r5, [r9]
32307d02:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307d06:	f8c9 1004 	str.w	r1, [r9, #4]
32307d0a:	f77f aea9 	ble.w	32307a60 <_vfprintf_r+0xbe8>
32307d0e:	9903      	ldr	r1, [sp, #12]
32307d10:	aa24      	add	r2, sp, #144	@ 0x90
32307d12:	4658      	mov	r0, fp
32307d14:	f7fb fb80 	bl	32303418 <__sprint_r>
32307d18:	2800      	cmp	r0, #0
32307d1a:	f47f a9ff 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307d1e:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32307d22:	a827      	add	r0, sp, #156	@ 0x9c
32307d24:	e69c      	b.n	32307a60 <_vfprintf_r+0xbe8>
32307d26:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32307d28:	2901      	cmp	r1, #1
32307d2a:	f77f ae99 	ble.w	32307a60 <_vfprintf_r+0xbe8>
32307d2e:	f64b 6ab8 	movw	sl, #48824	@ 0xbeb8
32307d32:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
32307d36:	f8dd 800c 	ldr.w	r8, [sp, #12]
32307d3a:	2410      	movs	r4, #16
32307d3c:	4655      	mov	r5, sl
32307d3e:	2911      	cmp	r1, #17
32307d40:	dc04      	bgt.n	32307d4c <_vfprintf_r+0xed4>
32307d42:	e3b6      	b.n	323084b2 <_vfprintf_r+0x163a>
32307d44:	3e10      	subs	r6, #16
32307d46:	2e10      	cmp	r6, #16
32307d48:	f340 83b2 	ble.w	323084b0 <_vfprintf_r+0x1638>
32307d4c:	3301      	adds	r3, #1
32307d4e:	3210      	adds	r2, #16
32307d50:	2b07      	cmp	r3, #7
32307d52:	e9c0 5400 	strd	r5, r4, [r0]
32307d56:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307d5a:	bfd8      	it	le
32307d5c:	3008      	addle	r0, #8
32307d5e:	ddf1      	ble.n	32307d44 <_vfprintf_r+0xecc>
32307d60:	aa24      	add	r2, sp, #144	@ 0x90
32307d62:	4641      	mov	r1, r8
32307d64:	4658      	mov	r0, fp
32307d66:	f7fb fb57 	bl	32303418 <__sprint_r>
32307d6a:	2800      	cmp	r0, #0
32307d6c:	f47f a9d6 	bne.w	3230711c <_vfprintf_r+0x2a4>
32307d70:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32307d74:	a827      	add	r0, sp, #156	@ 0x9c
32307d76:	e7e5      	b.n	32307d44 <_vfprintf_r+0xecc>
32307d78:	0490      	lsls	r0, r2, #18
32307d7a:	f57f a8af 	bpl.w	32306edc <_vfprintf_r+0x64>
32307d7e:	e41a      	b.n	323075b6 <_vfprintf_r+0x73e>
32307d80:	9b02      	ldr	r3, [sp, #8]
32307d82:	07dd      	lsls	r5, r3, #31
32307d84:	f57f aa50 	bpl.w	32307228 <_vfprintf_r+0x3b0>
32307d88:	f7ff bb6f 	b.w	3230746a <_vfprintf_r+0x5f2>
32307d8c:	782c      	ldrb	r4, [r5, #0]
32307d8e:	930a      	str	r3, [sp, #40]	@ 0x28
32307d90:	f7ff b8f0 	b.w	32306f74 <_vfprintf_r+0xfc>
32307d94:	9a04      	ldr	r2, [sp, #16]
32307d96:	ad50      	add	r5, sp, #320	@ 0x140
32307d98:	9205      	str	r2, [sp, #20]
32307d9a:	920b      	str	r2, [sp, #44]	@ 0x2c
32307d9c:	9210      	str	r2, [sp, #64]	@ 0x40
32307d9e:	920e      	str	r2, [sp, #56]	@ 0x38
32307da0:	920c      	str	r2, [sp, #48]	@ 0x30
32307da2:	9209      	str	r2, [sp, #36]	@ 0x24
32307da4:	f7ff b9f5 	b.w	32307192 <_vfprintf_r+0x31a>
32307da8:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
32307dac:	9202      	str	r2, [sp, #8]
32307dae:	1a5a      	subs	r2, r3, r1
32307db0:	bf18      	it	ne
32307db2:	2201      	movne	r2, #1
32307db4:	ea56 0308 	orrs.w	r3, r6, r8
32307db8:	f042 0301 	orr.w	r3, r2, #1
32307dbc:	bf08      	it	eq
32307dbe:	4613      	moveq	r3, r2
32307dc0:	2b00      	cmp	r3, #0
32307dc2:	f47f ac12 	bne.w	323075ea <_vfprintf_r+0x772>
32307dc6:	9a02      	ldr	r2, [sp, #8]
32307dc8:	2300      	movs	r3, #0
32307dca:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
32307dce:	ad50      	add	r5, sp, #320	@ 0x140
32307dd0:	f002 0202 	and.w	r2, r2, #2
32307dd4:	9304      	str	r3, [sp, #16]
32307dd6:	e9cd 320b 	strd	r3, r2, [sp, #44]	@ 0x2c
32307dda:	9305      	str	r3, [sp, #20]
32307ddc:	e41b      	b.n	32307616 <_vfprintf_r+0x79e>
32307dde:	4656      	mov	r6, sl
32307de0:	f04f 0a00 	mov.w	sl, #0
32307de4:	f7ff b9e1 	b.w	323071aa <_vfprintf_r+0x332>
32307de8:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307dea:	2001      	movs	r0, #1
32307dec:	3201      	adds	r2, #1
32307dee:	f8c9 0004 	str.w	r0, [r9, #4]
32307df2:	3301      	adds	r3, #1
32307df4:	f64b 204c 	movw	r0, #47692	@ 0xba4c
32307df8:	f2c3 2030 	movt	r0, #12848	@ 0x3230
32307dfc:	f109 0908 	add.w	r9, r9, #8
32307e00:	f849 0c08 	str.w	r0, [r9, #-8]
32307e04:	2b07      	cmp	r3, #7
32307e06:	9226      	str	r2, [sp, #152]	@ 0x98
32307e08:	9325      	str	r3, [sp, #148]	@ 0x94
32307e0a:	f300 8627 	bgt.w	32308a5c <_vfprintf_r+0x1be4>
32307e0e:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32307e10:	430b      	orrs	r3, r1
32307e12:	f000 867a 	beq.w	32308b0a <_vfprintf_r+0x1c92>
32307e16:	9b11      	ldr	r3, [sp, #68]	@ 0x44
32307e18:	9812      	ldr	r0, [sp, #72]	@ 0x48
32307e1a:	441a      	add	r2, r3
32307e1c:	e9c9 0300 	strd	r0, r3, [r9]
32307e20:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32307e22:	f109 0908 	add.w	r9, r9, #8
32307e26:	9226      	str	r2, [sp, #152]	@ 0x98
32307e28:	3301      	adds	r3, #1
32307e2a:	9325      	str	r3, [sp, #148]	@ 0x94
32307e2c:	2b07      	cmp	r3, #7
32307e2e:	f300 864f 	bgt.w	32308ad0 <_vfprintf_r+0x1c58>
32307e32:	2900      	cmp	r1, #0
32307e34:	f2c0 8718 	blt.w	32308c68 <_vfprintf_r+0x1df0>
32307e38:	990f      	ldr	r1, [sp, #60]	@ 0x3c
32307e3a:	3301      	adds	r3, #1
32307e3c:	2b07      	cmp	r3, #7
32307e3e:	f8c9 5000 	str.w	r5, [r9]
32307e42:	440a      	add	r2, r1
32307e44:	f8c9 1004 	str.w	r1, [r9, #4]
32307e48:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32307e4c:	f77f a9ea 	ble.w	32307224 <_vfprintf_r+0x3ac>
32307e50:	e613      	b.n	32307a7a <_vfprintf_r+0xc02>
32307e52:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32307e54:	9902      	ldr	r1, [sp, #8]
32307e56:	f853 2b04 	ldr.w	r2, [r3], #4
32307e5a:	f011 0110 	ands.w	r1, r1, #16
32307e5e:	f041 8106 	bne.w	3230906e <_vfprintf_r+0x21f6>
32307e62:	9d02      	ldr	r5, [sp, #8]
32307e64:	f015 0040 	ands.w	r0, r5, #64	@ 0x40
32307e68:	f000 835f 	beq.w	3230852a <_vfprintf_r+0x16b2>
32307e6c:	b292      	uxth	r2, r2
32307e6e:	4628      	mov	r0, r5
32307e70:	930a      	str	r3, [sp, #40]	@ 0x28
32307e72:	e440      	b.n	323076f6 <_vfprintf_r+0x87e>
32307e74:	9a02      	ldr	r2, [sp, #8]
32307e76:	06d5      	lsls	r5, r2, #27
32307e78:	f100 8314 	bmi.w	323084a4 <_vfprintf_r+0x162c>
32307e7c:	9a02      	ldr	r2, [sp, #8]
32307e7e:	0654      	lsls	r4, r2, #25
32307e80:	f100 8438 	bmi.w	323086f4 <_vfprintf_r+0x187c>
32307e84:	9a02      	ldr	r2, [sp, #8]
32307e86:	0590      	lsls	r0, r2, #22
32307e88:	f140 830c 	bpl.w	323084a4 <_vfprintf_r+0x162c>
32307e8c:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
32307e8e:	9907      	ldr	r1, [sp, #28]
32307e90:	6812      	ldr	r2, [r2, #0]
32307e92:	7011      	strb	r1, [r2, #0]
32307e94:	e462      	b.n	3230775c <_vfprintf_r+0x8e4>
32307e96:	eeb4 8b48 	vcmp.f64	d8, d8
32307e9a:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32307e9e:	f180 878a 	bvs.w	32308db6 <_vfprintf_r+0x1f3e>
32307ea2:	f024 0620 	bic.w	r6, r4, #32
32307ea6:	2e41      	cmp	r6, #65	@ 0x41
32307ea8:	f040 836d 	bne.w	32308586 <_vfprintf_r+0x170e>
32307eac:	2c61      	cmp	r4, #97	@ 0x61
32307eae:	f04f 0330 	mov.w	r3, #48	@ 0x30
32307eb2:	f88d 3068 	strb.w	r3, [sp, #104]	@ 0x68
32307eb6:	f04f 0358 	mov.w	r3, #88	@ 0x58
32307eba:	bf08      	it	eq
32307ebc:	2378      	moveq	r3, #120	@ 0x78
32307ebe:	f88d 3069 	strb.w	r3, [sp, #105]	@ 0x69
32307ec2:	9b05      	ldr	r3, [sp, #20]
32307ec4:	2b63      	cmp	r3, #99	@ 0x63
32307ec6:	f300 8461 	bgt.w	3230878c <_vfprintf_r+0x1914>
32307eca:	ee18 3a90 	vmov	r3, s17
32307ece:	2b00      	cmp	r3, #0
32307ed0:	f2c0 8725 	blt.w	32308d1e <_vfprintf_r+0x1ea6>
32307ed4:	eeb0 0b48 	vmov.f64	d0, d8
32307ed8:	ad37      	add	r5, sp, #220	@ 0xdc
32307eda:	f04f 0800 	mov.w	r8, #0
32307ede:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
32307ee2:	a81b      	add	r0, sp, #108	@ 0x6c
32307ee4:	f001 fd3c 	bl	32309960 <frexp>
32307ee8:	eef4 0b00 	vmov.f64	d16, #64	@ 0x3e000000  0.125
32307eec:	ee60 0b20 	vmul.f64	d16, d0, d16
32307ef0:	eef5 0b40 	vcmp.f64	d16, #0.0
32307ef4:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32307ef8:	d101      	bne.n	32307efe <_vfprintf_r+0x1086>
32307efa:	2301      	movs	r3, #1
32307efc:	931b      	str	r3, [sp, #108]	@ 0x6c
32307efe:	9b05      	ldr	r3, [sp, #20]
32307f00:	f64b 00cc 	movw	r0, #47308	@ 0xb8cc
32307f04:	f2c3 2030 	movt	r0, #12848	@ 0x3230
32307f08:	eef3 2b00 	vmov.f64	d18, #48	@ 0x41800000  16.0
32307f0c:	1e5a      	subs	r2, r3, #1
32307f0e:	f64b 03e0 	movw	r3, #47328	@ 0xb8e0
32307f12:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32307f16:	2c61      	cmp	r4, #97	@ 0x61
32307f18:	bf08      	it	eq
32307f1a:	4618      	moveq	r0, r3
32307f1c:	462b      	mov	r3, r5
32307f1e:	e006      	b.n	32307f2e <_vfprintf_r+0x10b6>
32307f20:	eef5 0b40 	vcmp.f64	d16, #0.0
32307f24:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32307f28:	f000 87a5 	beq.w	32308e76 <_vfprintf_r+0x1ffe>
32307f2c:	460a      	mov	r2, r1
32307f2e:	ee60 0ba2 	vmul.f64	d16, d16, d18
32307f32:	469c      	mov	ip, r3
32307f34:	1e51      	subs	r1, r2, #1
32307f36:	eefd 7be0 	vcvt.s32.f64	s15, d16
32307f3a:	ee17 6a90 	vmov	r6, s15
32307f3e:	eef8 1be7 	vcvt.f64.s32	d17, s15
32307f42:	5d86      	ldrb	r6, [r0, r6]
32307f44:	ee70 0be1 	vsub.f64	d16, d16, d17
32307f48:	f803 6b01 	strb.w	r6, [r3], #1
32307f4c:	1c56      	adds	r6, r2, #1
32307f4e:	d1e7      	bne.n	32307f20 <_vfprintf_r+0x10a8>
32307f50:	eef6 1b00 	vmov.f64	d17, #96	@ 0x3f000000  0.5
32307f54:	eef4 0be1 	vcmpe.f64	d16, d17
32307f58:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32307f5c:	dc08      	bgt.n	32307f70 <_vfprintf_r+0x10f8>
32307f5e:	eef4 0b61 	vcmp.f64	d16, d17
32307f62:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32307f66:	d11d      	bne.n	32307fa4 <_vfprintf_r+0x112c>
32307f68:	ee17 2a90 	vmov	r2, s15
32307f6c:	07d6      	lsls	r6, r2, #31
32307f6e:	d519      	bpl.n	32307fa4 <_vfprintf_r+0x112c>
32307f70:	f8cd c088 	str.w	ip, [sp, #136]	@ 0x88
32307f74:	461a      	mov	r2, r3
32307f76:	7bc6      	ldrb	r6, [r0, #15]
32307f78:	f813 1c01 	ldrb.w	r1, [r3, #-1]
32307f7c:	42b1      	cmp	r1, r6
32307f7e:	d10a      	bne.n	32307f96 <_vfprintf_r+0x111e>
32307f80:	f04f 0c30 	mov.w	ip, #48	@ 0x30
32307f84:	f802 cc01 	strb.w	ip, [r2, #-1]
32307f88:	9a22      	ldr	r2, [sp, #136]	@ 0x88
32307f8a:	1e51      	subs	r1, r2, #1
32307f8c:	9122      	str	r1, [sp, #136]	@ 0x88
32307f8e:	f812 1c01 	ldrb.w	r1, [r2, #-1]
32307f92:	42b1      	cmp	r1, r6
32307f94:	d0f6      	beq.n	32307f84 <_vfprintf_r+0x110c>
32307f96:	2939      	cmp	r1, #57	@ 0x39
32307f98:	f001 805c 	beq.w	32309054 <_vfprintf_r+0x21dc>
32307f9c:	3101      	adds	r1, #1
32307f9e:	b2c9      	uxtb	r1, r1
32307fa0:	f802 1c01 	strb.w	r1, [r2, #-1]
32307fa4:	9a02      	ldr	r2, [sp, #8]
32307fa6:	1b5b      	subs	r3, r3, r5
32307fa8:	930f      	str	r3, [sp, #60]	@ 0x3c
32307faa:	f104 030f 	add.w	r3, r4, #15
32307fae:	f042 0102 	orr.w	r1, r2, #2
32307fb2:	9a1b      	ldr	r2, [sp, #108]	@ 0x6c
32307fb4:	f88d 3078 	strb.w	r3, [sp, #120]	@ 0x78
32307fb8:	1e53      	subs	r3, r2, #1
32307fba:	931b      	str	r3, [sp, #108]	@ 0x6c
32307fbc:	2b00      	cmp	r3, #0
32307fbe:	f2c0 87e8 	blt.w	32308f92 <_vfprintf_r+0x211a>
32307fc2:	222b      	movs	r2, #43	@ 0x2b
32307fc4:	2b09      	cmp	r3, #9
32307fc6:	f88d 2079 	strb.w	r2, [sp, #121]	@ 0x79
32307fca:	f300 842c 	bgt.w	32308826 <_vfprintf_r+0x19ae>
32307fce:	f10d 027a 	add.w	r2, sp, #122	@ 0x7a
32307fd2:	3330      	adds	r3, #48	@ 0x30
32307fd4:	f802 3b01 	strb.w	r3, [r2], #1
32307fd8:	ab1e      	add	r3, sp, #120	@ 0x78
32307fda:	1ad3      	subs	r3, r2, r3
32307fdc:	9314      	str	r3, [sp, #80]	@ 0x50
32307fde:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32307fe0:	9a14      	ldr	r2, [sp, #80]	@ 0x50
32307fe2:	2b01      	cmp	r3, #1
32307fe4:	441a      	add	r2, r3
32307fe6:	920b      	str	r2, [sp, #44]	@ 0x2c
32307fe8:	f340 86a2 	ble.w	32308d30 <_vfprintf_r+0x1eb8>
32307fec:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32307fee:	9a11      	ldr	r2, [sp, #68]	@ 0x44
32307ff0:	4413      	add	r3, r2
32307ff2:	930b      	str	r3, [sp, #44]	@ 0x2c
32307ff4:	f421 6380 	bic.w	r3, r1, #1024	@ 0x400
32307ff8:	f001 0202 	and.w	r2, r1, #2
32307ffc:	f443 7380 	orr.w	r3, r3, #256	@ 0x100
32308000:	9302      	str	r3, [sp, #8]
32308002:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32308004:	920c      	str	r2, [sp, #48]	@ 0x30
32308006:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
3230800a:	9304      	str	r3, [sp, #16]
3230800c:	f1b8 0f00 	cmp.w	r8, #0
32308010:	f000 8666 	beq.w	32308ce0 <_vfprintf_r+0x1e68>
32308014:	f04f 0c2d 	mov.w	ip, #45	@ 0x2d
32308018:	2300      	movs	r3, #0
3230801a:	f88d c067 	strb.w	ip, [sp, #103]	@ 0x67
3230801e:	9305      	str	r3, [sp, #20]
32308020:	f7ff bafe 	b.w	32307620 <_vfprintf_r+0x7a8>
32308024:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32308026:	9a02      	ldr	r2, [sp, #8]
32308028:	f853 6b04 	ldr.w	r6, [r3], #4
3230802c:	06d1      	lsls	r1, r2, #27
3230802e:	f53f abe2 	bmi.w	323077f6 <_vfprintf_r+0x97e>
32308032:	9a02      	ldr	r2, [sp, #8]
32308034:	0652      	lsls	r2, r2, #25
32308036:	f140 829b 	bpl.w	32308570 <_vfprintf_r+0x16f8>
3230803a:	b236      	sxth	r6, r6
3230803c:	930a      	str	r3, [sp, #40]	@ 0x28
3230803e:	ea4f 78e6 	mov.w	r8, r6, asr #31
32308042:	4643      	mov	r3, r8
32308044:	f7ff b966 	b.w	32307314 <_vfprintf_r+0x49c>
32308048:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
3230804a:	9902      	ldr	r1, [sp, #8]
3230804c:	f853 2b04 	ldr.w	r2, [r3], #4
32308050:	f011 0810 	ands.w	r8, r1, #16
32308054:	f041 8032 	bne.w	323090bc <_vfprintf_r+0x2244>
32308058:	9802      	ldr	r0, [sp, #8]
3230805a:	f010 0140 	ands.w	r1, r0, #64	@ 0x40
3230805e:	f000 8277 	beq.w	32308550 <_vfprintf_r+0x16d8>
32308062:	b296      	uxth	r6, r2
32308064:	9a05      	ldr	r2, [sp, #20]
32308066:	f88d 8067 	strb.w	r8, [sp, #103]	@ 0x67
3230806a:	2a00      	cmp	r2, #0
3230806c:	f2c0 827d 	blt.w	3230856a <_vfprintf_r+0x16f2>
32308070:	f020 0180 	bic.w	r1, r0, #128	@ 0x80
32308074:	2a00      	cmp	r2, #0
32308076:	bf08      	it	eq
32308078:	2e00      	cmpeq	r6, #0
3230807a:	9102      	str	r1, [sp, #8]
3230807c:	930a      	str	r3, [sp, #40]	@ 0x28
3230807e:	f47f aab4 	bne.w	323075ea <_vfprintf_r+0x772>
32308082:	e6a0      	b.n	32307dc6 <_vfprintf_r+0xf4e>
32308084:	f64b 00cc 	movw	r0, #47308	@ 0xb8cc
32308088:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230808c:	9506      	str	r5, [sp, #24]
3230808e:	9b02      	ldr	r3, [sp, #8]
32308090:	9d0a      	ldr	r5, [sp, #40]	@ 0x28
32308092:	f013 0220 	ands.w	r2, r3, #32
32308096:	f000 8098 	beq.w	323081ca <_vfprintf_r+0x1352>
3230809a:	3507      	adds	r5, #7
3230809c:	f025 0507 	bic.w	r5, r5, #7
323080a0:	686a      	ldr	r2, [r5, #4]
323080a2:	f855 3b08 	ldr.w	r3, [r5], #8
323080a6:	ea53 0102 	orrs.w	r1, r3, r2
323080aa:	9902      	ldr	r1, [sp, #8]
323080ac:	f04f 0601 	mov.w	r6, #1
323080b0:	bf08      	it	eq
323080b2:	2600      	moveq	r6, #0
323080b4:	f001 0101 	and.w	r1, r1, #1
323080b8:	bf08      	it	eq
323080ba:	2100      	moveq	r1, #0
323080bc:	2900      	cmp	r1, #0
323080be:	f040 80cb 	bne.w	32308258 <_vfprintf_r+0x13e0>
323080c2:	f88d 1067 	strb.w	r1, [sp, #103]	@ 0x67
323080c6:	9905      	ldr	r1, [sp, #20]
323080c8:	2900      	cmp	r1, #0
323080ca:	9902      	ldr	r1, [sp, #8]
323080cc:	f2c0 80a4 	blt.w	32308218 <_vfprintf_r+0x13a0>
323080d0:	f421 6190 	bic.w	r1, r1, #1152	@ 0x480
323080d4:	9102      	str	r1, [sp, #8]
323080d6:	9905      	ldr	r1, [sp, #20]
323080d8:	3900      	subs	r1, #0
323080da:	bf18      	it	ne
323080dc:	2101      	movne	r1, #1
323080de:	4331      	orrs	r1, r6
323080e0:	f47f aaf3 	bne.w	323076ca <_vfprintf_r+0x852>
323080e4:	950a      	str	r5, [sp, #40]	@ 0x28
323080e6:	e66e      	b.n	32307dc6 <_vfprintf_r+0xf4e>
323080e8:	f64b 00e0 	movw	r0, #47328	@ 0xb8e0
323080ec:	f2c3 2030 	movt	r0, #12848	@ 0x3230
323080f0:	9506      	str	r5, [sp, #24]
323080f2:	e7cc      	b.n	3230808e <_vfprintf_r+0x1216>
323080f4:	9902      	ldr	r1, [sp, #8]
323080f6:	f64b 00e0 	movw	r0, #47328	@ 0xb8e0
323080fa:	f2c3 2030 	movt	r0, #12848	@ 0x3230
323080fe:	4694      	mov	ip, r2
32308100:	2478      	movs	r4, #120	@ 0x78
32308102:	f041 0102 	orr.w	r1, r1, #2
32308106:	950a      	str	r5, [sp, #40]	@ 0x28
32308108:	9102      	str	r1, [sp, #8]
3230810a:	2102      	movs	r1, #2
3230810c:	910c      	str	r1, [sp, #48]	@ 0x30
3230810e:	ad50      	add	r5, sp, #320	@ 0x140
32308110:	f003 010f 	and.w	r1, r3, #15
32308114:	091b      	lsrs	r3, r3, #4
32308116:	ea43 7302 	orr.w	r3, r3, r2, lsl #28
3230811a:	0912      	lsrs	r2, r2, #4
3230811c:	5c41      	ldrb	r1, [r0, r1]
3230811e:	f805 1d01 	strb.w	r1, [r5, #-1]!
32308122:	ea53 0102 	orrs.w	r1, r3, r2
32308126:	d1f3      	bne.n	32308110 <_vfprintf_r+0x1298>
32308128:	9a05      	ldr	r2, [sp, #20]
3230812a:	ab50      	add	r3, sp, #320	@ 0x140
3230812c:	1b5b      	subs	r3, r3, r5
3230812e:	930b      	str	r3, [sp, #44]	@ 0x2c
32308130:	429a      	cmp	r2, r3
32308132:	bfb8      	it	lt
32308134:	461a      	movlt	r2, r3
32308136:	9204      	str	r2, [sp, #16]
32308138:	f7ff ba6d 	b.w	32307616 <_vfprintf_r+0x79e>
3230813c:	9903      	ldr	r1, [sp, #12]
3230813e:	aa24      	add	r2, sp, #144	@ 0x90
32308140:	4658      	mov	r0, fp
32308142:	f7fb f969 	bl	32303418 <__sprint_r>
32308146:	2800      	cmp	r0, #0
32308148:	f47e afe8 	bne.w	3230711c <_vfprintf_r+0x2a4>
3230814c:	9a26      	ldr	r2, [sp, #152]	@ 0x98
3230814e:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308152:	f7ff b998 	b.w	32307486 <_vfprintf_r+0x60e>
32308156:	786c      	ldrb	r4, [r5, #1]
32308158:	f443 7300 	orr.w	r3, r3, #512	@ 0x200
3230815c:	3501      	adds	r5, #1
3230815e:	9302      	str	r3, [sp, #8]
32308160:	f7fe bf08 	b.w	32306f74 <_vfprintf_r+0xfc>
32308164:	786c      	ldrb	r4, [r5, #1]
32308166:	f043 0320 	orr.w	r3, r3, #32
3230816a:	3501      	adds	r5, #1
3230816c:	9302      	str	r3, [sp, #8]
3230816e:	f7fe bf01 	b.w	32306f74 <_vfprintf_r+0xfc>
32308172:	9b05      	ldr	r3, [sp, #20]
32308174:	462a      	mov	r2, r5
32308176:	9505      	str	r5, [sp, #20]
32308178:	2b06      	cmp	r3, #6
3230817a:	9509      	str	r5, [sp, #36]	@ 0x24
3230817c:	bf28      	it	cs
3230817e:	2306      	movcs	r3, #6
32308180:	f64b 05f4 	movw	r5, #47348	@ 0xb8f4
32308184:	f2c3 2530 	movt	r5, #12848	@ 0x3230
32308188:	9304      	str	r3, [sp, #16]
3230818a:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
3230818e:	930b      	str	r3, [sp, #44]	@ 0x2c
32308190:	9210      	str	r2, [sp, #64]	@ 0x40
32308192:	920e      	str	r2, [sp, #56]	@ 0x38
32308194:	920c      	str	r2, [sp, #48]	@ 0x30
32308196:	f7fe bffc 	b.w	32307192 <_vfprintf_r+0x31a>
3230819a:	2208      	movs	r2, #8
3230819c:	2100      	movs	r1, #0
3230819e:	a822      	add	r0, sp, #136	@ 0x88
323081a0:	ad37      	add	r5, sp, #220	@ 0xdc
323081a2:	f7fb ff61 	bl	32304068 <memset>
323081a6:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
323081a8:	4629      	mov	r1, r5
323081aa:	4658      	mov	r0, fp
323081ac:	681a      	ldr	r2, [r3, #0]
323081ae:	ab22      	add	r3, sp, #136	@ 0x88
323081b0:	f7fe fdee 	bl	32306d90 <_wcrtomb_r>
323081b4:	4603      	mov	r3, r0
323081b6:	3301      	adds	r3, #1
323081b8:	900b      	str	r0, [sp, #44]	@ 0x2c
323081ba:	f000 8734 	beq.w	32309026 <_vfprintf_r+0x21ae>
323081be:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
323081c0:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
323081c4:	9304      	str	r3, [sp, #16]
323081c6:	f7ff b99e 	b.w	32307506 <_vfprintf_r+0x68e>
323081ca:	9902      	ldr	r1, [sp, #8]
323081cc:	f855 3b04 	ldr.w	r3, [r5], #4
323081d0:	f011 0110 	ands.w	r1, r1, #16
323081d4:	f47f af67 	bne.w	323080a6 <_vfprintf_r+0x122e>
323081d8:	9a02      	ldr	r2, [sp, #8]
323081da:	f012 0640 	ands.w	r6, r2, #64	@ 0x40
323081de:	f000 81af 	beq.w	32308540 <_vfprintf_r+0x16c8>
323081e2:	b29b      	uxth	r3, r3
323081e4:	460a      	mov	r2, r1
323081e6:	e75e      	b.n	323080a6 <_vfprintf_r+0x122e>
323081e8:	9903      	ldr	r1, [sp, #12]
323081ea:	aa24      	add	r2, sp, #144	@ 0x90
323081ec:	4658      	mov	r0, fp
323081ee:	f7fb f913 	bl	32303418 <__sprint_r>
323081f2:	2800      	cmp	r0, #0
323081f4:	f47e af92 	bne.w	3230711c <_vfprintf_r+0x2a4>
323081f8:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
323081fc:	a827      	add	r0, sp, #156	@ 0x9c
323081fe:	e41b      	b.n	32307a38 <_vfprintf_r+0xbc0>
32308200:	9903      	ldr	r1, [sp, #12]
32308202:	aa24      	add	r2, sp, #144	@ 0x90
32308204:	4658      	mov	r0, fp
32308206:	f7fb f907 	bl	32303418 <__sprint_r>
3230820a:	2800      	cmp	r0, #0
3230820c:	f47e af86 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308210:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32308214:	a827      	add	r0, sp, #156	@ 0x9c
32308216:	e402      	b.n	32307a1e <_vfprintf_r+0xba6>
32308218:	f421 6180 	bic.w	r1, r1, #1024	@ 0x400
3230821c:	9102      	str	r1, [sp, #8]
3230821e:	9902      	ldr	r1, [sp, #8]
32308220:	f04f 0c00 	mov.w	ip, #0
32308224:	950a      	str	r5, [sp, #40]	@ 0x28
32308226:	f001 0102 	and.w	r1, r1, #2
3230822a:	910c      	str	r1, [sp, #48]	@ 0x30
3230822c:	e76f      	b.n	3230810e <_vfprintf_r+0x1296>
3230822e:	9903      	ldr	r1, [sp, #12]
32308230:	aa24      	add	r2, sp, #144	@ 0x90
32308232:	4658      	mov	r0, fp
32308234:	f7fb f8f0 	bl	32303418 <__sprint_r>
32308238:	2800      	cmp	r0, #0
3230823a:	f47e af6f 	bne.w	3230711c <_vfprintf_r+0x2a4>
3230823e:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32308242:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32308244:	2b00      	cmp	r3, #0
32308246:	f000 813c 	beq.w	323084c2 <_vfprintf_r+0x164a>
3230824a:	4656      	mov	r6, sl
3230824c:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308250:	4682      	mov	sl, r0
32308252:	9825      	ldr	r0, [sp, #148]	@ 0x94
32308254:	f7fe bfa9 	b.w	323071aa <_vfprintf_r+0x332>
32308258:	2130      	movs	r1, #48	@ 0x30
3230825a:	f88d 1068 	strb.w	r1, [sp, #104]	@ 0x68
3230825e:	2100      	movs	r1, #0
32308260:	f88d 1067 	strb.w	r1, [sp, #103]	@ 0x67
32308264:	9905      	ldr	r1, [sp, #20]
32308266:	f88d 4069 	strb.w	r4, [sp, #105]	@ 0x69
3230826a:	2900      	cmp	r1, #0
3230826c:	f2c0 83eb 	blt.w	32308a46 <_vfprintf_r+0x1bce>
32308270:	9902      	ldr	r1, [sp, #8]
32308272:	f421 6190 	bic.w	r1, r1, #1152	@ 0x480
32308276:	f041 0102 	orr.w	r1, r1, #2
3230827a:	9102      	str	r1, [sp, #8]
3230827c:	f7ff ba25 	b.w	323076ca <_vfprintf_r+0x852>
32308280:	4658      	mov	r0, fp
32308282:	f7fb fb2b 	bl	323038dc <__sinit>
32308286:	f7fe be17 	b.w	32306eb8 <_vfprintf_r+0x40>
3230828a:	9a05      	ldr	r2, [sp, #20]
3230828c:	3802      	subs	r0, #2
3230828e:	2330      	movs	r3, #48	@ 0x30
32308290:	f805 3c01 	strb.w	r3, [r5, #-1]
32308294:	ab50      	add	r3, sp, #320	@ 0x140
32308296:	4605      	mov	r5, r0
32308298:	1a1b      	subs	r3, r3, r0
3230829a:	930b      	str	r3, [sp, #44]	@ 0x2c
3230829c:	429a      	cmp	r2, r3
3230829e:	bfb8      	it	lt
323082a0:	461a      	movlt	r2, r3
323082a2:	9204      	str	r2, [sp, #16]
323082a4:	f7ff ba91 	b.w	323077ca <_vfprintf_r+0x952>
323082a8:	9903      	ldr	r1, [sp, #12]
323082aa:	aa24      	add	r2, sp, #144	@ 0x90
323082ac:	4658      	mov	r0, fp
323082ae:	f7fb f8b3 	bl	32303418 <__sprint_r>
323082b2:	2800      	cmp	r0, #0
323082b4:	f47e af32 	bne.w	3230711c <_vfprintf_r+0x2a4>
323082b8:	9a26      	ldr	r2, [sp, #152]	@ 0x98
323082ba:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
323082be:	f7ff b8cf 	b.w	32307460 <_vfprintf_r+0x5e8>
323082c2:	f10d 0a88 	add.w	sl, sp, #136	@ 0x88
323082c6:	2208      	movs	r2, #8
323082c8:	2100      	movs	r1, #0
323082ca:	4650      	mov	r0, sl
323082cc:	951d      	str	r5, [sp, #116]	@ 0x74
323082ce:	f7fb fecb 	bl	32304068 <memset>
323082d2:	9b05      	ldr	r3, [sp, #20]
323082d4:	2b00      	cmp	r3, #0
323082d6:	f2c0 83a7 	blt.w	32308a28 <_vfprintf_r+0x1bb0>
323082da:	2600      	movs	r6, #0
323082dc:	f8cd 9010 	str.w	r9, [sp, #16]
323082e0:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
323082e4:	4699      	mov	r9, r3
323082e6:	46b0      	mov	r8, r6
323082e8:	e00d      	b.n	32308306 <_vfprintf_r+0x148e>
323082ea:	a937      	add	r1, sp, #220	@ 0xdc
323082ec:	4658      	mov	r0, fp
323082ee:	f7fe fd4f 	bl	32306d90 <_wcrtomb_r>
323082f2:	3604      	adds	r6, #4
323082f4:	1c43      	adds	r3, r0, #1
323082f6:	4440      	add	r0, r8
323082f8:	f000 851f 	beq.w	32308d3a <_vfprintf_r+0x1ec2>
323082fc:	4548      	cmp	r0, r9
323082fe:	dc07      	bgt.n	32308310 <_vfprintf_r+0x1498>
32308300:	f000 8526 	beq.w	32308d50 <_vfprintf_r+0x1ed8>
32308304:	4680      	mov	r8, r0
32308306:	9a1d      	ldr	r2, [sp, #116]	@ 0x74
32308308:	4653      	mov	r3, sl
3230830a:	5992      	ldr	r2, [r2, r6]
3230830c:	2a00      	cmp	r2, #0
3230830e:	d1ec      	bne.n	323082ea <_vfprintf_r+0x1472>
32308310:	f8cd 802c 	str.w	r8, [sp, #44]	@ 0x2c
32308314:	f8dd 9010 	ldr.w	r9, [sp, #16]
32308318:	f8dd 8024 	ldr.w	r8, [sp, #36]	@ 0x24
3230831c:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
3230831e:	2b00      	cmp	r3, #0
32308320:	f000 83aa 	beq.w	32308a78 <_vfprintf_r+0x1c00>
32308324:	2b63      	cmp	r3, #99	@ 0x63
32308326:	f340 8487 	ble.w	32308c38 <_vfprintf_r+0x1dc0>
3230832a:	1c59      	adds	r1, r3, #1
3230832c:	4658      	mov	r0, fp
3230832e:	f7fd fbab 	bl	32305a88 <_malloc_r>
32308332:	4605      	mov	r5, r0
32308334:	2800      	cmp	r0, #0
32308336:	f000 86ba 	beq.w	323090ae <_vfprintf_r+0x2236>
3230833a:	9009      	str	r0, [sp, #36]	@ 0x24
3230833c:	2208      	movs	r2, #8
3230833e:	2100      	movs	r1, #0
32308340:	4650      	mov	r0, sl
32308342:	f7fb fe91 	bl	32304068 <memset>
32308346:	9e0b      	ldr	r6, [sp, #44]	@ 0x2c
32308348:	aa1d      	add	r2, sp, #116	@ 0x74
3230834a:	4629      	mov	r1, r5
3230834c:	4633      	mov	r3, r6
3230834e:	4658      	mov	r0, fp
32308350:	f8cd a000 	str.w	sl, [sp]
32308354:	f7fe fd66 	bl	32306e24 <_wcsrtombs_r>
32308358:	4286      	cmp	r6, r0
3230835a:	f040 86a2 	bne.w	323090a2 <_vfprintf_r+0x222a>
3230835e:	9a0b      	ldr	r2, [sp, #44]	@ 0x2c
32308360:	2300      	movs	r3, #0
32308362:	54ab      	strb	r3, [r5, r2]
32308364:	ea22 72e2 	bic.w	r2, r2, r2, asr #31
32308368:	9204      	str	r2, [sp, #16]
3230836a:	f89d 2067 	ldrb.w	r2, [sp, #103]	@ 0x67
3230836e:	2a00      	cmp	r2, #0
32308370:	f040 84ab 	bne.w	32308cca <_vfprintf_r+0x1e52>
32308374:	9205      	str	r2, [sp, #20]
32308376:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
3230837a:	9210      	str	r2, [sp, #64]	@ 0x40
3230837c:	920e      	str	r2, [sp, #56]	@ 0x38
3230837e:	920c      	str	r2, [sp, #48]	@ 0x30
32308380:	f7fe bf07 	b.w	32307192 <_vfprintf_r+0x31a>
32308384:	46b2      	mov	sl, r6
32308386:	3301      	adds	r3, #1
32308388:	4422      	add	r2, r4
3230838a:	f8c9 a000 	str.w	sl, [r9]
3230838e:	2b07      	cmp	r3, #7
32308390:	f8c9 4004 	str.w	r4, [r9, #4]
32308394:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32308398:	f77e af44 	ble.w	32307224 <_vfprintf_r+0x3ac>
3230839c:	f7ff bb6d 	b.w	32307a7a <_vfprintf_r+0xc02>
323083a0:	9b02      	ldr	r3, [sp, #8]
323083a2:	f64c 4ecd 	movw	lr, #52429	@ 0xcccd
323083a6:	f6cc 4ecc 	movt	lr, #52428	@ 0xcccc
323083aa:	9409      	str	r4, [sp, #36]	@ 0x24
323083ac:	f403 6580 	and.w	r5, r3, #1024	@ 0x400
323083b0:	2300      	movs	r3, #0
323083b2:	4674      	mov	r4, lr
323083b4:	f8cd b02c 	str.w	fp, [sp, #44]	@ 0x2c
323083b8:	a950      	add	r1, sp, #320	@ 0x140
323083ba:	f8dd b05c 	ldr.w	fp, [sp, #92]	@ 0x5c
323083be:	469e      	mov	lr, r3
323083c0:	f8cd 9010 	str.w	r9, [sp, #16]
323083c4:	e024      	b.n	32308410 <_vfprintf_r+0x1598>
323083c6:	eb16 0308 	adds.w	r3, r6, r8
323083ca:	4640      	mov	r0, r8
323083cc:	f143 0300 	adc.w	r3, r3, #0
323083d0:	46b2      	mov	sl, r6
323083d2:	4649      	mov	r1, r9
323083d4:	fba4 2c03 	umull	r2, ip, r4, r3
323083d8:	f02c 0203 	bic.w	r2, ip, #3
323083dc:	eb02 029c 	add.w	r2, r2, ip, lsr #2
323083e0:	1a9b      	subs	r3, r3, r2
323083e2:	f04f 32cc 	mov.w	r2, #3435973836	@ 0xcccccccc
323083e6:	1af3      	subs	r3, r6, r3
323083e8:	f168 0800 	sbc.w	r8, r8, #0
323083ec:	f1ba 0f0a 	cmp.w	sl, #10
323083f0:	f170 0000 	sbcs.w	r0, r0, #0
323083f4:	fb02 f203 	mul.w	r2, r2, r3
323083f8:	fb04 2208 	mla	r2, r4, r8, r2
323083fc:	fba3 6304 	umull	r6, r3, r3, r4
32308400:	4413      	add	r3, r2
32308402:	ea4f 0656 	mov.w	r6, r6, lsr #1
32308406:	ea46 76c3 	orr.w	r6, r6, r3, lsl #31
3230840a:	ea4f 0853 	mov.w	r8, r3, lsr #1
3230840e:	d331      	bcc.n	32308474 <_vfprintf_r+0x15fc>
32308410:	eb16 0308 	adds.w	r3, r6, r8
32308414:	f10e 0e01 	add.w	lr, lr, #1
32308418:	f143 0300 	adc.w	r3, r3, #0
3230841c:	f101 39ff 	add.w	r9, r1, #4294967295	@ 0xffffffff
32308420:	fba4 2003 	umull	r2, r0, r4, r3
32308424:	f020 0203 	bic.w	r2, r0, #3
32308428:	eb02 0290 	add.w	r2, r2, r0, lsr #2
3230842c:	1a9b      	subs	r3, r3, r2
3230842e:	1af3      	subs	r3, r6, r3
32308430:	f168 0000 	sbc.w	r0, r8, #0
32308434:	fba3 3204 	umull	r3, r2, r3, r4
32308438:	085b      	lsrs	r3, r3, #1
3230843a:	fb04 2200 	mla	r2, r4, r0, r2
3230843e:	ea43 73c2 	orr.w	r3, r3, r2, lsl #31
32308442:	eb03 0383 	add.w	r3, r3, r3, lsl #2
32308446:	eba6 0343 	sub.w	r3, r6, r3, lsl #1
3230844a:	3330      	adds	r3, #48	@ 0x30
3230844c:	f801 3c01 	strb.w	r3, [r1, #-1]
32308450:	2d00      	cmp	r5, #0
32308452:	d0b8      	beq.n	323083c6 <_vfprintf_r+0x154e>
32308454:	f89b 3000 	ldrb.w	r3, [fp]
32308458:	f1b3 02ff 	subs.w	r2, r3, #255	@ 0xff
3230845c:	bf18      	it	ne
3230845e:	2201      	movne	r2, #1
32308460:	4573      	cmp	r3, lr
32308462:	bf18      	it	ne
32308464:	2200      	movne	r2, #0
32308466:	2a00      	cmp	r2, #0
32308468:	d0ad      	beq.n	323083c6 <_vfprintf_r+0x154e>
3230846a:	2e0a      	cmp	r6, #10
3230846c:	f178 0300 	sbcs.w	r3, r8, #0
32308470:	f080 835e 	bcs.w	32308b30 <_vfprintf_r+0x1cb8>
32308474:	9a05      	ldr	r2, [sp, #20]
32308476:	464d      	mov	r5, r9
32308478:	ab50      	add	r3, sp, #320	@ 0x140
3230847a:	f8dd 9010 	ldr.w	r9, [sp, #16]
3230847e:	1b5b      	subs	r3, r3, r5
32308480:	f8cd b05c 	str.w	fp, [sp, #92]	@ 0x5c
32308484:	429a      	cmp	r2, r3
32308486:	f8dd b02c 	ldr.w	fp, [sp, #44]	@ 0x2c
3230848a:	bfb8      	it	lt
3230848c:	461a      	movlt	r2, r3
3230848e:	930b      	str	r3, [sp, #44]	@ 0x2c
32308490:	9c09      	ldr	r4, [sp, #36]	@ 0x24
32308492:	2300      	movs	r3, #0
32308494:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
32308498:	f8cd e03c 	str.w	lr, [sp, #60]	@ 0x3c
3230849c:	9204      	str	r2, [sp, #16]
3230849e:	930c      	str	r3, [sp, #48]	@ 0x30
323084a0:	f7ff b8b9 	b.w	32307616 <_vfprintf_r+0x79e>
323084a4:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
323084a6:	9907      	ldr	r1, [sp, #28]
323084a8:	6812      	ldr	r2, [r2, #0]
323084aa:	6011      	str	r1, [r2, #0]
323084ac:	f7ff b956 	b.w	3230775c <_vfprintf_r+0x8e4>
323084b0:	46aa      	mov	sl, r5
323084b2:	3301      	adds	r3, #1
323084b4:	f8c0 a000 	str.w	sl, [r0]
323084b8:	f7ff bac9 	b.w	32307a4e <_vfprintf_r+0xbd6>
323084bc:	2478      	movs	r4, #120	@ 0x78
323084be:	950a      	str	r5, [sp, #40]	@ 0x28
323084c0:	e481      	b.n	32307dc6 <_vfprintf_r+0xf4e>
323084c2:	f1ba 0f00 	cmp.w	sl, #0
323084c6:	f000 8102 	beq.w	323086ce <_vfprintf_r+0x1856>
323084ca:	9825      	ldr	r0, [sp, #148]	@ 0x94
323084cc:	469a      	mov	sl, r3
323084ce:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
323084d2:	f7fe be7c 	b.w	323071ce <_vfprintf_r+0x356>
323084d6:	f64b 6ab8 	movw	sl, #48824	@ 0xbeb8
323084da:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
323084de:	9b25      	ldr	r3, [sp, #148]	@ 0x94
323084e0:	2c10      	cmp	r4, #16
323084e2:	f340 80da 	ble.w	3230869a <_vfprintf_r+0x1822>
323084e6:	4651      	mov	r1, sl
323084e8:	f8dd 800c 	ldr.w	r8, [sp, #12]
323084ec:	46aa      	mov	sl, r5
323084ee:	2610      	movs	r6, #16
323084f0:	460d      	mov	r5, r1
323084f2:	e003      	b.n	323084fc <_vfprintf_r+0x1684>
323084f4:	3c10      	subs	r4, #16
323084f6:	2c10      	cmp	r4, #16
323084f8:	f340 80cc 	ble.w	32308694 <_vfprintf_r+0x181c>
323084fc:	3301      	adds	r3, #1
323084fe:	3210      	adds	r2, #16
32308500:	e9c9 5600 	strd	r5, r6, [r9]
32308504:	2b07      	cmp	r3, #7
32308506:	f109 0908 	add.w	r9, r9, #8
3230850a:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
3230850e:	ddf1      	ble.n	323084f4 <_vfprintf_r+0x167c>
32308510:	aa24      	add	r2, sp, #144	@ 0x90
32308512:	4641      	mov	r1, r8
32308514:	4658      	mov	r0, fp
32308516:	f7fa ff7f 	bl	32303418 <__sprint_r>
3230851a:	2800      	cmp	r0, #0
3230851c:	f47e adfe 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308520:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32308524:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308528:	e7e4      	b.n	323084f4 <_vfprintf_r+0x167c>
3230852a:	9d02      	ldr	r5, [sp, #8]
3230852c:	f415 7100 	ands.w	r1, r5, #512	@ 0x200
32308530:	f000 80f9 	beq.w	32308726 <_vfprintf_r+0x18ae>
32308534:	4601      	mov	r1, r0
32308536:	b2d2      	uxtb	r2, r2
32308538:	4628      	mov	r0, r5
3230853a:	930a      	str	r3, [sp, #40]	@ 0x28
3230853c:	f7ff b8db 	b.w	323076f6 <_vfprintf_r+0x87e>
32308540:	9a02      	ldr	r2, [sp, #8]
32308542:	f412 7200 	ands.w	r2, r2, #512	@ 0x200
32308546:	f43f adae 	beq.w	323080a6 <_vfprintf_r+0x122e>
3230854a:	b2db      	uxtb	r3, r3
3230854c:	4632      	mov	r2, r6
3230854e:	e5aa      	b.n	323080a6 <_vfprintf_r+0x122e>
32308550:	9802      	ldr	r0, [sp, #8]
32308552:	f410 7800 	ands.w	r8, r0, #512	@ 0x200
32308556:	f000 80d3 	beq.w	32308700 <_vfprintf_r+0x1888>
3230855a:	b2d6      	uxtb	r6, r2
3230855c:	9a05      	ldr	r2, [sp, #20]
3230855e:	4688      	mov	r8, r1
32308560:	f88d 1067 	strb.w	r1, [sp, #103]	@ 0x67
32308564:	2a00      	cmp	r2, #0
32308566:	f6bf ad83 	bge.w	32308070 <_vfprintf_r+0x11f8>
3230856a:	930a      	str	r3, [sp, #40]	@ 0x28
3230856c:	f7ff b83d 	b.w	323075ea <_vfprintf_r+0x772>
32308570:	9a02      	ldr	r2, [sp, #8]
32308572:	0595      	lsls	r5, r2, #22
32308574:	f140 80b8 	bpl.w	323086e8 <_vfprintf_r+0x1870>
32308578:	b276      	sxtb	r6, r6
3230857a:	930a      	str	r3, [sp, #40]	@ 0x28
3230857c:	ea4f 78e6 	mov.w	r8, r6, asr #31
32308580:	4643      	mov	r3, r8
32308582:	f7fe bec7 	b.w	32307314 <_vfprintf_r+0x49c>
32308586:	9b02      	ldr	r3, [sp, #8]
32308588:	9a05      	ldr	r2, [sp, #20]
3230858a:	f443 7a80 	orr.w	sl, r3, #256	@ 0x100
3230858e:	ee18 3a90 	vmov	r3, s17
32308592:	1c51      	adds	r1, r2, #1
32308594:	f000 80f0 	beq.w	32308778 <_vfprintf_r+0x1900>
32308598:	2a00      	cmp	r2, #0
3230859a:	bf08      	it	eq
3230859c:	2e47      	cmpeq	r6, #71	@ 0x47
3230859e:	bf08      	it	eq
323085a0:	2201      	moveq	r2, #1
323085a2:	bf18      	it	ne
323085a4:	2200      	movne	r2, #0
323085a6:	f000 84d4 	beq.w	32308f52 <_vfprintf_r+0x20da>
323085aa:	eeb0 9b48 	vmov.f64	d9, d8
323085ae:	4690      	mov	r8, r2
323085b0:	2b00      	cmp	r3, #0
323085b2:	da03      	bge.n	323085bc <_vfprintf_r+0x1744>
323085b4:	eeb1 9b48 	vneg.f64	d9, d8
323085b8:	f04f 082d 	mov.w	r8, #45	@ 0x2d
323085bc:	2c65      	cmp	r4, #101	@ 0x65
323085be:	f000 8306 	beq.w	32308bce <_vfprintf_r+0x1d56>
323085c2:	f300 80f7 	bgt.w	323087b4 <_vfprintf_r+0x193c>
323085c6:	2c45      	cmp	r4, #69	@ 0x45
323085c8:	f000 8301 	beq.w	32308bce <_vfprintf_r+0x1d56>
323085cc:	2c46      	cmp	r4, #70	@ 0x46
323085ce:	f040 80f4 	bne.w	323087ba <_vfprintf_r+0x1942>
323085d2:	9b05      	ldr	r3, [sp, #20]
323085d4:	2103      	movs	r1, #3
323085d6:	930f      	str	r3, [sp, #60]	@ 0x3c
323085d8:	ab22      	add	r3, sp, #136	@ 0x88
323085da:	eeb0 0b49 	vmov.f64	d0, d9
323085de:	9301      	str	r3, [sp, #4]
323085e0:	4658      	mov	r0, fp
323085e2:	ab1d      	add	r3, sp, #116	@ 0x74
323085e4:	9a0f      	ldr	r2, [sp, #60]	@ 0x3c
323085e6:	9300      	str	r3, [sp, #0]
323085e8:	ab1b      	add	r3, sp, #108	@ 0x6c
323085ea:	f001 fa8d 	bl	32309b08 <_dtoa_r>
323085ee:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
323085f0:	4605      	mov	r5, r0
323085f2:	2e46      	cmp	r6, #70	@ 0x46
323085f4:	eb00 0103 	add.w	r1, r0, r3
323085f8:	f040 8455 	bne.w	32308ea6 <_vfprintf_r+0x202e>
323085fc:	782b      	ldrb	r3, [r5, #0]
323085fe:	2b30      	cmp	r3, #48	@ 0x30
32308600:	f000 8468 	beq.w	32308ed4 <_vfprintf_r+0x205c>
32308604:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32308606:	eeb5 9b40 	vcmp.f64	d9, #0.0
3230860a:	4419      	add	r1, r3
3230860c:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32308610:	f000 845a 	beq.w	32308ec8 <_vfprintf_r+0x2050>
32308614:	9b22      	ldr	r3, [sp, #136]	@ 0x88
32308616:	4299      	cmp	r1, r3
32308618:	f240 8535 	bls.w	32309086 <_vfprintf_r+0x220e>
3230861c:	2030      	movs	r0, #48	@ 0x30
3230861e:	1c5a      	adds	r2, r3, #1
32308620:	9222      	str	r2, [sp, #136]	@ 0x88
32308622:	7018      	strb	r0, [r3, #0]
32308624:	9b22      	ldr	r3, [sp, #136]	@ 0x88
32308626:	428b      	cmp	r3, r1
32308628:	d3f9      	bcc.n	3230861e <_vfprintf_r+0x17a6>
3230862a:	9a1b      	ldr	r2, [sp, #108]	@ 0x6c
3230862c:	1b5b      	subs	r3, r3, r5
3230862e:	2e47      	cmp	r6, #71	@ 0x47
32308630:	920c      	str	r2, [sp, #48]	@ 0x30
32308632:	930f      	str	r3, [sp, #60]	@ 0x3c
32308634:	f000 80d7 	beq.w	323087e6 <_vfprintf_r+0x196e>
32308638:	2e46      	cmp	r6, #70	@ 0x46
3230863a:	f040 80e3 	bne.w	32308804 <_vfprintf_r+0x198c>
3230863e:	9b02      	ldr	r3, [sp, #8]
32308640:	9a05      	ldr	r2, [sp, #20]
32308642:	990c      	ldr	r1, [sp, #48]	@ 0x30
32308644:	f003 0301 	and.w	r3, r3, #1
32308648:	4313      	orrs	r3, r2
3230864a:	2900      	cmp	r1, #0
3230864c:	f340 84d9 	ble.w	32309002 <_vfprintf_r+0x218a>
32308650:	2b00      	cmp	r3, #0
32308652:	f040 83a9 	bne.w	32308da8 <_vfprintf_r+0x1f30>
32308656:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32308658:	2466      	movs	r4, #102	@ 0x66
3230865a:	930b      	str	r3, [sp, #44]	@ 0x2c
3230865c:	9b02      	ldr	r3, [sp, #8]
3230865e:	055b      	lsls	r3, r3, #21
32308660:	f100 83d3 	bmi.w	32308e0a <_vfprintf_r+0x1f92>
32308664:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32308666:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
3230866a:	9304      	str	r3, [sp, #16]
3230866c:	f1b8 0f00 	cmp.w	r8, #0
32308670:	f000 82b2 	beq.w	32308bd8 <_vfprintf_r+0x1d60>
32308674:	9b04      	ldr	r3, [sp, #16]
32308676:	f8cd a008 	str.w	sl, [sp, #8]
3230867a:	3301      	adds	r3, #1
3230867c:	9304      	str	r3, [sp, #16]
3230867e:	2300      	movs	r3, #0
32308680:	9309      	str	r3, [sp, #36]	@ 0x24
32308682:	461a      	mov	r2, r3
32308684:	232d      	movs	r3, #45	@ 0x2d
32308686:	9205      	str	r2, [sp, #20]
32308688:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
3230868c:	9210      	str	r2, [sp, #64]	@ 0x40
3230868e:	920e      	str	r2, [sp, #56]	@ 0x38
32308690:	f7fe bd7f 	b.w	32307192 <_vfprintf_r+0x31a>
32308694:	4629      	mov	r1, r5
32308696:	4655      	mov	r5, sl
32308698:	468a      	mov	sl, r1
3230869a:	3301      	adds	r3, #1
3230869c:	4422      	add	r2, r4
3230869e:	f8c9 a000 	str.w	sl, [r9]
323086a2:	2b07      	cmp	r3, #7
323086a4:	f8c9 4004 	str.w	r4, [r9, #4]
323086a8:	f109 0908 	add.w	r9, r9, #8
323086ac:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
323086b0:	f77f aabd 	ble.w	32307c2e <_vfprintf_r+0xdb6>
323086b4:	9903      	ldr	r1, [sp, #12]
323086b6:	aa24      	add	r2, sp, #144	@ 0x90
323086b8:	4658      	mov	r0, fp
323086ba:	f7fa fead 	bl	32303418 <__sprint_r>
323086be:	2800      	cmp	r0, #0
323086c0:	f47e ad2c 	bne.w	3230711c <_vfprintf_r+0x2a4>
323086c4:	9a26      	ldr	r2, [sp, #152]	@ 0x98
323086c6:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
323086ca:	f7ff bab0 	b.w	32307c2e <_vfprintf_r+0xdb6>
323086ce:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
323086d2:	f7fe bd90 	b.w	323071f6 <_vfprintf_r+0x37e>
323086d6:	441d      	add	r5, r3
323086d8:	1b1c      	subs	r4, r3, r4
323086da:	eba5 0508 	sub.w	r5, r5, r8
323086de:	42a5      	cmp	r5, r4
323086e0:	bfa8      	it	ge
323086e2:	4625      	movge	r5, r4
323086e4:	f7ff bad8 	b.w	32307c98 <_vfprintf_r+0xe20>
323086e8:	ea4f 78e6 	mov.w	r8, r6, asr #31
323086ec:	930a      	str	r3, [sp, #40]	@ 0x28
323086ee:	4643      	mov	r3, r8
323086f0:	f7fe be10 	b.w	32307314 <_vfprintf_r+0x49c>
323086f4:	9a0a      	ldr	r2, [sp, #40]	@ 0x28
323086f6:	9907      	ldr	r1, [sp, #28]
323086f8:	6812      	ldr	r2, [r2, #0]
323086fa:	8011      	strh	r1, [r2, #0]
323086fc:	f7ff b82e 	b.w	3230775c <_vfprintf_r+0x8e4>
32308700:	9905      	ldr	r1, [sp, #20]
32308702:	4616      	mov	r6, r2
32308704:	f88d 8067 	strb.w	r8, [sp, #103]	@ 0x67
32308708:	2900      	cmp	r1, #0
3230870a:	f6ff af2e 	blt.w	3230856a <_vfprintf_r+0x16f2>
3230870e:	9802      	ldr	r0, [sp, #8]
32308710:	2a00      	cmp	r2, #0
32308712:	bf08      	it	eq
32308714:	2900      	cmpeq	r1, #0
32308716:	930a      	str	r3, [sp, #40]	@ 0x28
32308718:	f020 0080 	bic.w	r0, r0, #128	@ 0x80
3230871c:	9002      	str	r0, [sp, #8]
3230871e:	f47e af64 	bne.w	323075ea <_vfprintf_r+0x772>
32308722:	f7ff bb50 	b.w	32307dc6 <_vfprintf_r+0xf4e>
32308726:	9802      	ldr	r0, [sp, #8]
32308728:	930a      	str	r3, [sp, #40]	@ 0x28
3230872a:	f7fe bfe4 	b.w	323076f6 <_vfprintf_r+0x87e>
3230872e:	4628      	mov	r0, r5
32308730:	f7fc ff86 	bl	32305640 <strlen>
32308734:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32308738:	ea20 72e0 	bic.w	r2, r0, r0, asr #31
3230873c:	900b      	str	r0, [sp, #44]	@ 0x2c
3230873e:	9204      	str	r2, [sp, #16]
32308740:	2b00      	cmp	r3, #0
32308742:	f47e af1d 	bne.w	32307580 <_vfprintf_r+0x708>
32308746:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32308748:	2473      	movs	r4, #115	@ 0x73
3230874a:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
3230874e:	9305      	str	r3, [sp, #20]
32308750:	9310      	str	r3, [sp, #64]	@ 0x40
32308752:	930e      	str	r3, [sp, #56]	@ 0x38
32308754:	9309      	str	r3, [sp, #36]	@ 0x24
32308756:	f7fe bd1c 	b.w	32307192 <_vfprintf_r+0x31a>
3230875a:	9903      	ldr	r1, [sp, #12]
3230875c:	aa24      	add	r2, sp, #144	@ 0x90
3230875e:	4658      	mov	r0, fp
32308760:	f7fa fe5a 	bl	32303418 <__sprint_r>
32308764:	2800      	cmp	r0, #0
32308766:	f43e acc2 	beq.w	323070ee <_vfprintf_r+0x276>
3230876a:	f7fe bcdd 	b.w	32307128 <_vfprintf_r+0x2b0>
3230876e:	6d88      	ldr	r0, [r1, #88]	@ 0x58
32308770:	f7fc fa7a 	bl	32304c68 <__retarget_lock_release_recursive>
32308774:	f7fe bc8b 	b.w	3230708e <_vfprintf_r+0x216>
32308778:	2b00      	cmp	r3, #0
3230877a:	f2c0 83e2 	blt.w	32308f42 <_vfprintf_r+0x20ca>
3230877e:	2306      	movs	r3, #6
32308780:	eeb0 9b48 	vmov.f64	d9, d8
32308784:	f04f 0800 	mov.w	r8, #0
32308788:	9305      	str	r3, [sp, #20]
3230878a:	e717      	b.n	323085bc <_vfprintf_r+0x1744>
3230878c:	1c59      	adds	r1, r3, #1
3230878e:	4658      	mov	r0, fp
32308790:	f7fd f97a 	bl	32305a88 <_malloc_r>
32308794:	4605      	mov	r5, r0
32308796:	2800      	cmp	r0, #0
32308798:	f000 8445 	beq.w	32309026 <_vfprintf_r+0x21ae>
3230879c:	ee18 3a90 	vmov	r3, s17
323087a0:	2b00      	cmp	r3, #0
323087a2:	f2c0 840a 	blt.w	32308fba <_vfprintf_r+0x2142>
323087a6:	eeb0 0b48 	vmov.f64	d0, d8
323087aa:	f04f 0800 	mov.w	r8, #0
323087ae:	9009      	str	r0, [sp, #36]	@ 0x24
323087b0:	f7ff bb97 	b.w	32307ee2 <_vfprintf_r+0x106a>
323087b4:	2c66      	cmp	r4, #102	@ 0x66
323087b6:	f43f af0c 	beq.w	323085d2 <_vfprintf_r+0x175a>
323087ba:	ab22      	add	r3, sp, #136	@ 0x88
323087bc:	eeb0 0b49 	vmov.f64	d0, d9
323087c0:	9301      	str	r3, [sp, #4]
323087c2:	2102      	movs	r1, #2
323087c4:	ab1d      	add	r3, sp, #116	@ 0x74
323087c6:	9a05      	ldr	r2, [sp, #20]
323087c8:	9300      	str	r3, [sp, #0]
323087ca:	4658      	mov	r0, fp
323087cc:	ab1b      	add	r3, sp, #108	@ 0x6c
323087ce:	f001 f99b 	bl	32309b08 <_dtoa_r>
323087d2:	9b02      	ldr	r3, [sp, #8]
323087d4:	4605      	mov	r5, r0
323087d6:	07d8      	lsls	r0, r3, #31
323087d8:	f100 826a 	bmi.w	32308cb0 <_vfprintf_r+0x1e38>
323087dc:	9b22      	ldr	r3, [sp, #136]	@ 0x88
323087de:	1b5b      	subs	r3, r3, r5
323087e0:	930f      	str	r3, [sp, #60]	@ 0x3c
323087e2:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
323087e4:	930c      	str	r3, [sp, #48]	@ 0x30
323087e6:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
323087e8:	9a05      	ldr	r2, [sp, #20]
323087ea:	4293      	cmp	r3, r2
323087ec:	bfd8      	it	le
323087ee:	2200      	movle	r2, #0
323087f0:	bfc8      	it	gt
323087f2:	2201      	movgt	r2, #1
323087f4:	1cd9      	adds	r1, r3, #3
323087f6:	bfa8      	it	ge
323087f8:	2300      	movge	r3, #0
323087fa:	bfb8      	it	lt
323087fc:	2301      	movlt	r3, #1
323087fe:	4313      	orrs	r3, r2
32308800:	d046      	beq.n	32308890 <_vfprintf_r+0x1a18>
32308802:	3c02      	subs	r4, #2
32308804:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32308806:	f88d 4078 	strb.w	r4, [sp, #120]	@ 0x78
3230880a:	3b01      	subs	r3, #1
3230880c:	931b      	str	r3, [sp, #108]	@ 0x6c
3230880e:	2b00      	cmp	r3, #0
32308810:	f2c0 82b5 	blt.w	32308d7e <_vfprintf_r+0x1f06>
32308814:	222b      	movs	r2, #43	@ 0x2b
32308816:	2b09      	cmp	r3, #9
32308818:	f88d 2079 	strb.w	r2, [sp, #121]	@ 0x79
3230881c:	f340 82b8 	ble.w	32308d90 <_vfprintf_r+0x1f18>
32308820:	9902      	ldr	r1, [sp, #8]
32308822:	2200      	movs	r2, #0
32308824:	9209      	str	r2, [sp, #36]	@ 0x24
32308826:	f10d 0e8f 	add.w	lr, sp, #143	@ 0x8f
3230882a:	f64c 4ccd 	movw	ip, #52429	@ 0xcccd
3230882e:	f6cc 4ccc 	movt	ip, #52428	@ 0xcccc
32308832:	4672      	mov	r2, lr
32308834:	f04f 0a0a 	mov.w	sl, #10
32308838:	9102      	str	r1, [sp, #8]
3230883a:	4610      	mov	r0, r2
3230883c:	fbac 1203 	umull	r1, r2, ip, r3
32308840:	461e      	mov	r6, r3
32308842:	2e63      	cmp	r6, #99	@ 0x63
32308844:	ea4f 02d2 	mov.w	r2, r2, lsr #3
32308848:	fb0a 3112 	mls	r1, sl, r2, r3
3230884c:	4613      	mov	r3, r2
3230884e:	f100 32ff 	add.w	r2, r0, #4294967295	@ 0xffffffff
32308852:	f101 0130 	add.w	r1, r1, #48	@ 0x30
32308856:	f800 1c01 	strb.w	r1, [r0, #-1]
3230885a:	dcee      	bgt.n	3230883a <_vfprintf_r+0x19c2>
3230885c:	3330      	adds	r3, #48	@ 0x30
3230885e:	f802 3c01 	strb.w	r3, [r2, #-1]
32308862:	1e83      	subs	r3, r0, #2
32308864:	9902      	ldr	r1, [sp, #8]
32308866:	4573      	cmp	r3, lr
32308868:	f080 83c7 	bcs.w	32308ffa <_vfprintf_r+0x2182>
3230886c:	f10d 0279 	add.w	r2, sp, #121	@ 0x79
32308870:	f813 6b01 	ldrb.w	r6, [r3], #1
32308874:	f802 6f01 	strb.w	r6, [r2, #1]!
32308878:	4573      	cmp	r3, lr
3230887a:	d1f9      	bne.n	32308870 <_vfprintf_r+0x19f8>
3230887c:	f503 73a0 	add.w	r3, r3, #320	@ 0x140
32308880:	aa1e      	add	r2, sp, #120	@ 0x78
32308882:	446b      	add	r3, sp
32308884:	3bc4      	subs	r3, #196	@ 0xc4
32308886:	1a1b      	subs	r3, r3, r0
32308888:	1a9b      	subs	r3, r3, r2
3230888a:	9314      	str	r3, [sp, #80]	@ 0x50
3230888c:	f7ff bba7 	b.w	32307fde <_vfprintf_r+0x1166>
32308890:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32308892:	9a0f      	ldr	r2, [sp, #60]	@ 0x3c
32308894:	4293      	cmp	r3, r2
32308896:	f2c0 81d4 	blt.w	32308c42 <_vfprintf_r+0x1dca>
3230889a:	9b02      	ldr	r3, [sp, #8]
3230889c:	f013 0f01 	tst.w	r3, #1
323088a0:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
323088a2:	f000 827f 	beq.w	32308da4 <_vfprintf_r+0x1f2c>
323088a6:	9a11      	ldr	r2, [sp, #68]	@ 0x44
323088a8:	4413      	add	r3, r2
323088aa:	930b      	str	r3, [sp, #44]	@ 0x2c
323088ac:	9b02      	ldr	r3, [sp, #8]
323088ae:	055b      	lsls	r3, r3, #21
323088b0:	d503      	bpl.n	323088ba <_vfprintf_r+0x1a42>
323088b2:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
323088b4:	2b00      	cmp	r3, #0
323088b6:	f300 82a7 	bgt.w	32308e08 <_vfprintf_r+0x1f90>
323088ba:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
323088bc:	2467      	movs	r4, #103	@ 0x67
323088be:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
323088c2:	9304      	str	r3, [sp, #16]
323088c4:	e6d2      	b.n	3230866c <_vfprintf_r+0x17f4>
323088c6:	232d      	movs	r3, #45	@ 0x2d
323088c8:	2c47      	cmp	r4, #71	@ 0x47
323088ca:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
323088ce:	f300 81ac 	bgt.w	32308c2a <_vfprintf_r+0x1db2>
323088d2:	f64b 253c 	movw	r5, #47676	@ 0xba3c
323088d6:	f2c3 2530 	movt	r5, #12848	@ 0x3230
323088da:	2300      	movs	r3, #0
323088dc:	9309      	str	r3, [sp, #36]	@ 0x24
323088de:	2203      	movs	r2, #3
323088e0:	9305      	str	r3, [sp, #20]
323088e2:	9310      	str	r3, [sp, #64]	@ 0x40
323088e4:	930e      	str	r3, [sp, #56]	@ 0x38
323088e6:	930c      	str	r3, [sp, #48]	@ 0x30
323088e8:	2304      	movs	r3, #4
323088ea:	920b      	str	r2, [sp, #44]	@ 0x2c
323088ec:	9304      	str	r3, [sp, #16]
323088ee:	f7fe bc50 	b.w	32307192 <_vfprintf_r+0x31a>
323088f2:	9b0e      	ldr	r3, [sp, #56]	@ 0x38
323088f4:	9810      	ldr	r0, [sp, #64]	@ 0x40
323088f6:	4303      	orrs	r3, r0
323088f8:	f000 83cb 	beq.w	32309092 <_vfprintf_r+0x221a>
323088fc:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
323088fe:	4649      	mov	r1, r9
32308900:	f64b 66b8 	movw	r6, #48824	@ 0xbeb8
32308904:	f2c3 2630 	movt	r6, #12848	@ 0x3230
32308908:	f8dd 905c 	ldr.w	r9, [sp, #92]	@ 0x5c
3230890c:	18eb      	adds	r3, r5, r3
3230890e:	4682      	mov	sl, r0
32308910:	9510      	str	r5, [sp, #64]	@ 0x40
32308912:	e031      	b.n	32308978 <_vfprintf_r+0x1b00>
32308914:	f10a 3aff 	add.w	sl, sl, #4294967295	@ 0xffffffff
32308918:	9815      	ldr	r0, [sp, #84]	@ 0x54
3230891a:	9c16      	ldr	r4, [sp, #88]	@ 0x58
3230891c:	4402      	add	r2, r0
3230891e:	e9c1 4000 	strd	r4, r0, [r1]
32308922:	9825      	ldr	r0, [sp, #148]	@ 0x94
32308924:	9226      	str	r2, [sp, #152]	@ 0x98
32308926:	3001      	adds	r0, #1
32308928:	9025      	str	r0, [sp, #148]	@ 0x94
3230892a:	2807      	cmp	r0, #7
3230892c:	bfd8      	it	le
3230892e:	3108      	addle	r1, #8
32308930:	dc4f      	bgt.n	323089d2 <_vfprintf_r+0x1b5a>
32308932:	f899 0000 	ldrb.w	r0, [r9]
32308936:	eba3 0408 	sub.w	r4, r3, r8
3230893a:	9305      	str	r3, [sp, #20]
3230893c:	4284      	cmp	r4, r0
3230893e:	bfa8      	it	ge
32308940:	4604      	movge	r4, r0
32308942:	2c00      	cmp	r4, #0
32308944:	dd0b      	ble.n	3230895e <_vfprintf_r+0x1ae6>
32308946:	9825      	ldr	r0, [sp, #148]	@ 0x94
32308948:	4422      	add	r2, r4
3230894a:	e9c1 8400 	strd	r8, r4, [r1]
3230894e:	3001      	adds	r0, #1
32308950:	9226      	str	r2, [sp, #152]	@ 0x98
32308952:	2807      	cmp	r0, #7
32308954:	9025      	str	r0, [sp, #148]	@ 0x94
32308956:	dc58      	bgt.n	32308a0a <_vfprintf_r+0x1b92>
32308958:	f899 0000 	ldrb.w	r0, [r9]
3230895c:	3108      	adds	r1, #8
3230895e:	ea24 74e4 	bic.w	r4, r4, r4, asr #31
32308962:	1b04      	subs	r4, r0, r4
32308964:	2c00      	cmp	r4, #0
32308966:	dc10      	bgt.n	3230898a <_vfprintf_r+0x1b12>
32308968:	9c0e      	ldr	r4, [sp, #56]	@ 0x38
3230896a:	4480      	add	r8, r0
3230896c:	4650      	mov	r0, sl
3230896e:	2c00      	cmp	r4, #0
32308970:	bfd8      	it	le
32308972:	2800      	cmple	r0, #0
32308974:	f340 82f7 	ble.w	32308f66 <_vfprintf_r+0x20ee>
32308978:	f1ba 0f00 	cmp.w	sl, #0
3230897c:	dcca      	bgt.n	32308914 <_vfprintf_r+0x1a9c>
3230897e:	980e      	ldr	r0, [sp, #56]	@ 0x38
32308980:	f109 39ff 	add.w	r9, r9, #4294967295	@ 0xffffffff
32308984:	3801      	subs	r0, #1
32308986:	900e      	str	r0, [sp, #56]	@ 0x38
32308988:	e7c6      	b.n	32308918 <_vfprintf_r+0x1aa0>
3230898a:	f64b 6cb8 	movw	ip, #48824	@ 0xbeb8
3230898e:	f2c3 2c30 	movt	ip, #12848	@ 0x3230
32308992:	9825      	ldr	r0, [sp, #148]	@ 0x94
32308994:	2c10      	cmp	r4, #16
32308996:	dd2b      	ble.n	323089f0 <_vfprintf_r+0x1b78>
32308998:	2510      	movs	r5, #16
3230899a:	e9cd 630b 	strd	r6, r3, [sp, #44]	@ 0x2c
3230899e:	e002      	b.n	323089a6 <_vfprintf_r+0x1b2e>
323089a0:	3c10      	subs	r4, #16
323089a2:	2c10      	cmp	r4, #16
323089a4:	dd22      	ble.n	323089ec <_vfprintf_r+0x1b74>
323089a6:	3001      	adds	r0, #1
323089a8:	3210      	adds	r2, #16
323089aa:	2807      	cmp	r0, #7
323089ac:	e9c1 6500 	strd	r6, r5, [r1]
323089b0:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
323089b4:	bfd8      	it	le
323089b6:	3108      	addle	r1, #8
323089b8:	ddf2      	ble.n	323089a0 <_vfprintf_r+0x1b28>
323089ba:	9903      	ldr	r1, [sp, #12]
323089bc:	aa24      	add	r2, sp, #144	@ 0x90
323089be:	4658      	mov	r0, fp
323089c0:	f7fa fd2a 	bl	32303418 <__sprint_r>
323089c4:	2800      	cmp	r0, #0
323089c6:	f47e aba9 	bne.w	3230711c <_vfprintf_r+0x2a4>
323089ca:	e9dd 0225 	ldrd	r0, r2, [sp, #148]	@ 0x94
323089ce:	a927      	add	r1, sp, #156	@ 0x9c
323089d0:	e7e6      	b.n	323089a0 <_vfprintf_r+0x1b28>
323089d2:	9903      	ldr	r1, [sp, #12]
323089d4:	aa24      	add	r2, sp, #144	@ 0x90
323089d6:	4658      	mov	r0, fp
323089d8:	9305      	str	r3, [sp, #20]
323089da:	f7fa fd1d 	bl	32303418 <__sprint_r>
323089de:	2800      	cmp	r0, #0
323089e0:	f47e ab9c 	bne.w	3230711c <_vfprintf_r+0x2a4>
323089e4:	9a26      	ldr	r2, [sp, #152]	@ 0x98
323089e6:	a927      	add	r1, sp, #156	@ 0x9c
323089e8:	9b05      	ldr	r3, [sp, #20]
323089ea:	e7a2      	b.n	32308932 <_vfprintf_r+0x1aba>
323089ec:	e9dd c30b 	ldrd	ip, r3, [sp, #44]	@ 0x2c
323089f0:	3001      	adds	r0, #1
323089f2:	4422      	add	r2, r4
323089f4:	2807      	cmp	r0, #7
323089f6:	f8c1 c000 	str.w	ip, [r1]
323089fa:	604c      	str	r4, [r1, #4]
323089fc:	e9cd 0225 	strd	r0, r2, [sp, #148]	@ 0x94
32308a00:	dc57      	bgt.n	32308ab2 <_vfprintf_r+0x1c3a>
32308a02:	f899 0000 	ldrb.w	r0, [r9]
32308a06:	3108      	adds	r1, #8
32308a08:	e7ae      	b.n	32308968 <_vfprintf_r+0x1af0>
32308a0a:	9903      	ldr	r1, [sp, #12]
32308a0c:	aa24      	add	r2, sp, #144	@ 0x90
32308a0e:	4658      	mov	r0, fp
32308a10:	930b      	str	r3, [sp, #44]	@ 0x2c
32308a12:	f7fa fd01 	bl	32303418 <__sprint_r>
32308a16:	2800      	cmp	r0, #0
32308a18:	f47e ab80 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308a1c:	f899 0000 	ldrb.w	r0, [r9]
32308a20:	a927      	add	r1, sp, #156	@ 0x9c
32308a22:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32308a24:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32308a26:	e79a      	b.n	3230895e <_vfprintf_r+0x1ae6>
32308a28:	2300      	movs	r3, #0
32308a2a:	aa1d      	add	r2, sp, #116	@ 0x74
32308a2c:	4619      	mov	r1, r3
32308a2e:	4658      	mov	r0, fp
32308a30:	f8cd a000 	str.w	sl, [sp]
32308a34:	f7fe f9f6 	bl	32306e24 <_wcsrtombs_r>
32308a38:	4603      	mov	r3, r0
32308a3a:	3301      	adds	r3, #1
32308a3c:	900b      	str	r0, [sp, #44]	@ 0x2c
32308a3e:	f000 817c 	beq.w	32308d3a <_vfprintf_r+0x1ec2>
32308a42:	951d      	str	r5, [sp, #116]	@ 0x74
32308a44:	e46a      	b.n	3230831c <_vfprintf_r+0x14a4>
32308a46:	9902      	ldr	r1, [sp, #8]
32308a48:	f421 6180 	bic.w	r1, r1, #1024	@ 0x400
32308a4c:	f041 0102 	orr.w	r1, r1, #2
32308a50:	9102      	str	r1, [sp, #8]
32308a52:	f7ff bbe4 	b.w	3230821e <_vfprintf_r+0x13a6>
32308a56:	930a      	str	r3, [sp, #40]	@ 0x28
32308a58:	f7fe bdc6 	b.w	323075e8 <_vfprintf_r+0x770>
32308a5c:	9903      	ldr	r1, [sp, #12]
32308a5e:	aa24      	add	r2, sp, #144	@ 0x90
32308a60:	4658      	mov	r0, fp
32308a62:	f7fa fcd9 	bl	32303418 <__sprint_r>
32308a66:	2800      	cmp	r0, #0
32308a68:	f47e ab58 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308a6c:	991b      	ldr	r1, [sp, #108]	@ 0x6c
32308a6e:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308a72:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32308a74:	f7ff b9cb 	b.w	32307e0e <_vfprintf_r+0xf96>
32308a78:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32308a7c:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
32308a80:	3b00      	subs	r3, #0
32308a82:	bf18      	it	ne
32308a84:	2301      	movne	r3, #1
32308a86:	9304      	str	r3, [sp, #16]
32308a88:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32308a8a:	9305      	str	r3, [sp, #20]
32308a8c:	9310      	str	r3, [sp, #64]	@ 0x40
32308a8e:	930e      	str	r3, [sp, #56]	@ 0x38
32308a90:	930c      	str	r3, [sp, #48]	@ 0x30
32308a92:	9309      	str	r3, [sp, #36]	@ 0x24
32308a94:	f7fe bb7d 	b.w	32307192 <_vfprintf_r+0x31a>
32308a98:	9903      	ldr	r1, [sp, #12]
32308a9a:	aa24      	add	r2, sp, #144	@ 0x90
32308a9c:	4658      	mov	r0, fp
32308a9e:	f7fa fcbb 	bl	32303418 <__sprint_r>
32308aa2:	2800      	cmp	r0, #0
32308aa4:	f47e ab3a 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308aa8:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32308aaa:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308aae:	f7ff b8b7 	b.w	32307c20 <_vfprintf_r+0xda8>
32308ab2:	9903      	ldr	r1, [sp, #12]
32308ab4:	aa24      	add	r2, sp, #144	@ 0x90
32308ab6:	4658      	mov	r0, fp
32308ab8:	930b      	str	r3, [sp, #44]	@ 0x2c
32308aba:	f7fa fcad 	bl	32303418 <__sprint_r>
32308abe:	2800      	cmp	r0, #0
32308ac0:	f47e ab2c 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308ac4:	f899 0000 	ldrb.w	r0, [r9]
32308ac8:	a927      	add	r1, sp, #156	@ 0x9c
32308aca:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32308acc:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
32308ace:	e74b      	b.n	32308968 <_vfprintf_r+0x1af0>
32308ad0:	9903      	ldr	r1, [sp, #12]
32308ad2:	aa24      	add	r2, sp, #144	@ 0x90
32308ad4:	4658      	mov	r0, fp
32308ad6:	f7fa fc9f 	bl	32303418 <__sprint_r>
32308ada:	2800      	cmp	r0, #0
32308adc:	f47e ab1e 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308ae0:	991b      	ldr	r1, [sp, #108]	@ 0x6c
32308ae2:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308ae6:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32308aea:	f7ff b9a2 	b.w	32307e32 <_vfprintf_r+0xfba>
32308aee:	9903      	ldr	r1, [sp, #12]
32308af0:	aa24      	add	r2, sp, #144	@ 0x90
32308af2:	4658      	mov	r0, fp
32308af4:	f7fa fc90 	bl	32303418 <__sprint_r>
32308af8:	2800      	cmp	r0, #0
32308afa:	f47e ab0f 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308afe:	9c1b      	ldr	r4, [sp, #108]	@ 0x6c
32308b00:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308b04:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32308b06:	f7ff b8af 	b.w	32307c68 <_vfprintf_r+0xdf0>
32308b0a:	9b02      	ldr	r3, [sp, #8]
32308b0c:	07dc      	lsls	r4, r3, #31
32308b0e:	f57e ab8b 	bpl.w	32307228 <_vfprintf_r+0x3b0>
32308b12:	9b11      	ldr	r3, [sp, #68]	@ 0x44
32308b14:	9912      	ldr	r1, [sp, #72]	@ 0x48
32308b16:	441a      	add	r2, r3
32308b18:	e9c9 1300 	strd	r1, r3, [r9]
32308b1c:	9b25      	ldr	r3, [sp, #148]	@ 0x94
32308b1e:	9226      	str	r2, [sp, #152]	@ 0x98
32308b20:	3301      	adds	r3, #1
32308b22:	9325      	str	r3, [sp, #148]	@ 0x94
32308b24:	2b07      	cmp	r3, #7
32308b26:	dcd3      	bgt.n	32308ad0 <_vfprintf_r+0x1c58>
32308b28:	f109 0908 	add.w	r9, r9, #8
32308b2c:	f7ff b984 	b.w	32307e38 <_vfprintf_r+0xfc0>
32308b30:	9a15      	ldr	r2, [sp, #84]	@ 0x54
32308b32:	9916      	ldr	r1, [sp, #88]	@ 0x58
32308b34:	eba9 0a02 	sub.w	sl, r9, r2
32308b38:	4650      	mov	r0, sl
32308b3a:	f7fb fae3 	bl	32304104 <strncpy>
32308b3e:	f89b 3001 	ldrb.w	r3, [fp, #1]
32308b42:	b10b      	cbz	r3, 32308b48 <_vfprintf_r+0x1cd0>
32308b44:	f10b 0b01 	add.w	fp, fp, #1
32308b48:	eb16 0308 	adds.w	r3, r6, r8
32308b4c:	f64c 42cd 	movw	r2, #52429	@ 0xcccd
32308b50:	f6cc 42cc 	movt	r2, #52428	@ 0xcccc
32308b54:	f143 0300 	adc.w	r3, r3, #0
32308b58:	f04f 31cc 	mov.w	r1, #3435973836	@ 0xcccccccc
32308b5c:	f04f 0e01 	mov.w	lr, #1
32308b60:	f10a 39ff 	add.w	r9, sl, #4294967295	@ 0xffffffff
32308b64:	fba2 0c03 	umull	r0, ip, r2, r3
32308b68:	f02c 0003 	bic.w	r0, ip, #3
32308b6c:	eb00 009c 	add.w	r0, r0, ip, lsr #2
32308b70:	1a1b      	subs	r3, r3, r0
32308b72:	1af3      	subs	r3, r6, r3
32308b74:	f168 0800 	sbc.w	r8, r8, #0
32308b78:	fb03 f101 	mul.w	r1, r3, r1
32308b7c:	fb02 1108 	mla	r1, r2, r8, r1
32308b80:	fba3 3002 	umull	r3, r0, r3, r2
32308b84:	4401      	add	r1, r0
32308b86:	fa23 f30e 	lsr.w	r3, r3, lr
32308b8a:	ea43 76c1 	orr.w	r6, r3, r1, lsl #31
32308b8e:	fa21 f80e 	lsr.w	r8, r1, lr
32308b92:	eb16 0308 	adds.w	r3, r6, r8
32308b96:	f143 0300 	adc.w	r3, r3, #0
32308b9a:	fba2 1003 	umull	r1, r0, r2, r3
32308b9e:	f020 0103 	bic.w	r1, r0, #3
32308ba2:	eb01 0190 	add.w	r1, r1, r0, lsr #2
32308ba6:	1a5b      	subs	r3, r3, r1
32308ba8:	1af3      	subs	r3, r6, r3
32308baa:	f168 0000 	sbc.w	r0, r8, #0
32308bae:	fba3 3102 	umull	r3, r1, r3, r2
32308bb2:	fa23 f30e 	lsr.w	r3, r3, lr
32308bb6:	fb02 1200 	mla	r2, r2, r0, r1
32308bba:	ea43 73c2 	orr.w	r3, r3, r2, lsl #31
32308bbe:	eb03 0383 	add.w	r3, r3, r3, lsl #2
32308bc2:	eba6 0343 	sub.w	r3, r6, r3, lsl #1
32308bc6:	3330      	adds	r3, #48	@ 0x30
32308bc8:	f80a 3c01 	strb.w	r3, [sl, #-1]
32308bcc:	e442      	b.n	32308454 <_vfprintf_r+0x15dc>
32308bce:	9b05      	ldr	r3, [sp, #20]
32308bd0:	2102      	movs	r1, #2
32308bd2:	3301      	adds	r3, #1
32308bd4:	930f      	str	r3, [sp, #60]	@ 0x3c
32308bd6:	e4ff      	b.n	323085d8 <_vfprintf_r+0x1760>
32308bd8:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32308bdc:	2b00      	cmp	r3, #0
32308bde:	f000 81cc 	beq.w	32308f7a <_vfprintf_r+0x2102>
32308be2:	9a04      	ldr	r2, [sp, #16]
32308be4:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
32308be8:	3201      	adds	r2, #1
32308bea:	f8cd a008 	str.w	sl, [sp, #8]
32308bee:	9204      	str	r2, [sp, #16]
32308bf0:	f8cd 8014 	str.w	r8, [sp, #20]
32308bf4:	f8cd 8040 	str.w	r8, [sp, #64]	@ 0x40
32308bf8:	f8cd 8038 	str.w	r8, [sp, #56]	@ 0x38
32308bfc:	f7fe bac9 	b.w	32307192 <_vfprintf_r+0x31a>
32308c00:	9903      	ldr	r1, [sp, #12]
32308c02:	aa24      	add	r2, sp, #144	@ 0x90
32308c04:	4658      	mov	r0, fp
32308c06:	f7fa fc07 	bl	32303418 <__sprint_r>
32308c0a:	2800      	cmp	r0, #0
32308c0c:	f47e aa86 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308c10:	9c1b      	ldr	r4, [sp, #108]	@ 0x6c
32308c12:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308c16:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32308c18:	9a26      	ldr	r2, [sp, #152]	@ 0x98
32308c1a:	1b1c      	subs	r4, r3, r4
32308c1c:	f7ff b83c 	b.w	32307c98 <_vfprintf_r+0xe20>
32308c20:	2300      	movs	r3, #0
32308c22:	4615      	mov	r5, r2
32308c24:	9305      	str	r3, [sp, #20]
32308c26:	f7fe b9a6 	b.w	32306f76 <_vfprintf_r+0xfe>
32308c2a:	2300      	movs	r3, #0
32308c2c:	f64b 2540 	movw	r5, #47680	@ 0xba40
32308c30:	f2c3 2530 	movt	r5, #12848	@ 0x3230
32308c34:	9309      	str	r3, [sp, #36]	@ 0x24
32308c36:	e652      	b.n	323088de <_vfprintf_r+0x1a66>
32308c38:	2300      	movs	r3, #0
32308c3a:	ad37      	add	r5, sp, #220	@ 0xdc
32308c3c:	9309      	str	r3, [sp, #36]	@ 0x24
32308c3e:	f7ff bb7d 	b.w	3230833c <_vfprintf_r+0x14c4>
32308c42:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32308c44:	9a11      	ldr	r2, [sp, #68]	@ 0x44
32308c46:	189a      	adds	r2, r3, r2
32308c48:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32308c4a:	920b      	str	r2, [sp, #44]	@ 0x2c
32308c4c:	2b00      	cmp	r3, #0
32308c4e:	bfc8      	it	gt
32308c50:	2467      	movgt	r4, #103	@ 0x67
32308c52:	f73f ad03 	bgt.w	3230865c <_vfprintf_r+0x17e4>
32308c56:	f1c3 0301 	rsb	r3, r3, #1
32308c5a:	2467      	movs	r4, #103	@ 0x67
32308c5c:	441a      	add	r2, r3
32308c5e:	920b      	str	r2, [sp, #44]	@ 0x2c
32308c60:	ea22 73e2 	bic.w	r3, r2, r2, asr #31
32308c64:	9304      	str	r3, [sp, #16]
32308c66:	e501      	b.n	3230866c <_vfprintf_r+0x17f4>
32308c68:	424c      	negs	r4, r1
32308c6a:	3110      	adds	r1, #16
32308c6c:	f64b 6ab8 	movw	sl, #48824	@ 0xbeb8
32308c70:	f2c3 2a30 	movt	sl, #12848	@ 0x3230
32308c74:	bfb8      	it	lt
32308c76:	2610      	movlt	r6, #16
32308c78:	db03      	blt.n	32308c82 <_vfprintf_r+0x1e0a>
32308c7a:	e037      	b.n	32308cec <_vfprintf_r+0x1e74>
32308c7c:	3c10      	subs	r4, #16
32308c7e:	2c10      	cmp	r4, #16
32308c80:	dd34      	ble.n	32308cec <_vfprintf_r+0x1e74>
32308c82:	3301      	adds	r3, #1
32308c84:	3210      	adds	r2, #16
32308c86:	e9c9 a600 	strd	sl, r6, [r9]
32308c8a:	2b07      	cmp	r3, #7
32308c8c:	f109 0908 	add.w	r9, r9, #8
32308c90:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32308c94:	ddf2      	ble.n	32308c7c <_vfprintf_r+0x1e04>
32308c96:	9903      	ldr	r1, [sp, #12]
32308c98:	aa24      	add	r2, sp, #144	@ 0x90
32308c9a:	4658      	mov	r0, fp
32308c9c:	f7fa fbbc 	bl	32303418 <__sprint_r>
32308ca0:	2800      	cmp	r0, #0
32308ca2:	f47e aa3b 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308ca6:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32308caa:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308cae:	e7e5      	b.n	32308c7c <_vfprintf_r+0x1e04>
32308cb0:	eeb5 9b40 	vcmp.f64	d9, #0.0
32308cb4:	9b05      	ldr	r3, [sp, #20]
32308cb6:	18e9      	adds	r1, r5, r3
32308cb8:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32308cbc:	f000 80ee 	beq.w	32308e9c <_vfprintf_r+0x2024>
32308cc0:	9b22      	ldr	r3, [sp, #136]	@ 0x88
32308cc2:	4299      	cmp	r1, r3
32308cc4:	f63f acaa 	bhi.w	3230861c <_vfprintf_r+0x17a4>
32308cc8:	e4af      	b.n	3230862a <_vfprintf_r+0x17b2>
32308cca:	9a04      	ldr	r2, [sp, #16]
32308ccc:	9305      	str	r3, [sp, #20]
32308cce:	3201      	adds	r2, #1
32308cd0:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
32308cd4:	9204      	str	r2, [sp, #16]
32308cd6:	9310      	str	r3, [sp, #64]	@ 0x40
32308cd8:	930e      	str	r3, [sp, #56]	@ 0x38
32308cda:	930c      	str	r3, [sp, #48]	@ 0x30
32308cdc:	f7fe ba59 	b.w	32307192 <_vfprintf_r+0x31a>
32308ce0:	f89d c067 	ldrb.w	ip, [sp, #103]	@ 0x67
32308ce4:	f8cd 8014 	str.w	r8, [sp, #20]
32308ce8:	f7fe bc97 	b.w	3230761a <_vfprintf_r+0x7a2>
32308cec:	3301      	adds	r3, #1
32308cee:	4422      	add	r2, r4
32308cf0:	2b07      	cmp	r3, #7
32308cf2:	f8c9 a000 	str.w	sl, [r9]
32308cf6:	f8c9 4004 	str.w	r4, [r9, #4]
32308cfa:	e9cd 3225 	strd	r3, r2, [sp, #148]	@ 0x94
32308cfe:	f77f af13 	ble.w	32308b28 <_vfprintf_r+0x1cb0>
32308d02:	9903      	ldr	r1, [sp, #12]
32308d04:	aa24      	add	r2, sp, #144	@ 0x90
32308d06:	4658      	mov	r0, fp
32308d08:	f7fa fb86 	bl	32303418 <__sprint_r>
32308d0c:	2800      	cmp	r0, #0
32308d0e:	f47e aa05 	bne.w	3230711c <_vfprintf_r+0x2a4>
32308d12:	e9dd 3225 	ldrd	r3, r2, [sp, #148]	@ 0x94
32308d16:	f10d 099c 	add.w	r9, sp, #156	@ 0x9c
32308d1a:	f7ff b88d 	b.w	32307e38 <_vfprintf_r+0xfc0>
32308d1e:	2300      	movs	r3, #0
32308d20:	eeb1 0b48 	vneg.f64	d0, d8
32308d24:	f04f 082d 	mov.w	r8, #45	@ 0x2d
32308d28:	ad37      	add	r5, sp, #220	@ 0xdc
32308d2a:	9309      	str	r3, [sp, #36]	@ 0x24
32308d2c:	f7ff b8d9 	b.w	32307ee2 <_vfprintf_r+0x106a>
32308d30:	07ca      	lsls	r2, r1, #31
32308d32:	f57f a95f 	bpl.w	32307ff4 <_vfprintf_r+0x117c>
32308d36:	f7ff b959 	b.w	32307fec <_vfprintf_r+0x1174>
32308d3a:	9b03      	ldr	r3, [sp, #12]
32308d3c:	2200      	movs	r2, #0
32308d3e:	9209      	str	r2, [sp, #36]	@ 0x24
32308d40:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
32308d44:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32308d48:	9a03      	ldr	r2, [sp, #12]
32308d4a:	8193      	strh	r3, [r2, #12]
32308d4c:	f7fe b9e6 	b.w	3230711c <_vfprintf_r+0x2a4>
32308d50:	9b05      	ldr	r3, [sp, #20]
32308d52:	f8dd 9010 	ldr.w	r9, [sp, #16]
32308d56:	f8dd 8024 	ldr.w	r8, [sp, #36]	@ 0x24
32308d5a:	930b      	str	r3, [sp, #44]	@ 0x2c
32308d5c:	f7ff bade 	b.w	3230831c <_vfprintf_r+0x14a4>
32308d60:	f8cd 8028 	str.w	r8, [sp, #40]	@ 0x28
32308d64:	2b00      	cmp	r3, #0
32308d66:	f000 811e 	beq.w	32308fa6 <_vfprintf_r+0x212e>
32308d6a:	9b05      	ldr	r3, [sp, #20]
32308d6c:	2473      	movs	r4, #115	@ 0x73
32308d6e:	930b      	str	r3, [sp, #44]	@ 0x2c
32308d70:	1c5a      	adds	r2, r3, #1
32308d72:	9005      	str	r0, [sp, #20]
32308d74:	9204      	str	r2, [sp, #16]
32308d76:	9010      	str	r0, [sp, #64]	@ 0x40
32308d78:	900e      	str	r0, [sp, #56]	@ 0x38
32308d7a:	f7fe ba0a 	b.w	32307192 <_vfprintf_r+0x31a>
32308d7e:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32308d80:	222d      	movs	r2, #45	@ 0x2d
32308d82:	f88d 2079 	strb.w	r2, [sp, #121]	@ 0x79
32308d86:	f1c3 0301 	rsb	r3, r3, #1
32308d8a:	2b09      	cmp	r3, #9
32308d8c:	f73f ad48 	bgt.w	32308820 <_vfprintf_r+0x19a8>
32308d90:	2230      	movs	r2, #48	@ 0x30
32308d92:	9902      	ldr	r1, [sp, #8]
32308d94:	f88d 207a 	strb.w	r2, [sp, #122]	@ 0x7a
32308d98:	2200      	movs	r2, #0
32308d9a:	9209      	str	r2, [sp, #36]	@ 0x24
32308d9c:	f10d 027b 	add.w	r2, sp, #123	@ 0x7b
32308da0:	f7ff b917 	b.w	32307fd2 <_vfprintf_r+0x115a>
32308da4:	930b      	str	r3, [sp, #44]	@ 0x2c
32308da6:	e581      	b.n	323088ac <_vfprintf_r+0x1a34>
32308da8:	4613      	mov	r3, r2
32308daa:	9a11      	ldr	r2, [sp, #68]	@ 0x44
32308dac:	2466      	movs	r4, #102	@ 0x66
32308dae:	4413      	add	r3, r2
32308db0:	440b      	add	r3, r1
32308db2:	930b      	str	r3, [sp, #44]	@ 0x2c
32308db4:	e452      	b.n	3230865c <_vfprintf_r+0x17e4>
32308db6:	9b02      	ldr	r3, [sp, #8]
32308db8:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
32308dbc:	9302      	str	r3, [sp, #8]
32308dbe:	ee18 3a90 	vmov	r3, s17
32308dc2:	f013 4300 	ands.w	r3, r3, #2147483648	@ 0x80000000
32308dc6:	930c      	str	r3, [sp, #48]	@ 0x30
32308dc8:	f000 80a1 	beq.w	32308f0e <_vfprintf_r+0x2096>
32308dcc:	232d      	movs	r3, #45	@ 0x2d
32308dce:	f64b 2548 	movw	r5, #47688	@ 0xba48
32308dd2:	f2c3 2530 	movt	r5, #12848	@ 0x3230
32308dd6:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32308dda:	2c47      	cmp	r4, #71	@ 0x47
32308ddc:	f04f 0300 	mov.w	r3, #0
32308de0:	9309      	str	r3, [sp, #36]	@ 0x24
32308de2:	f73f ad7c 	bgt.w	323088de <_vfprintf_r+0x1a66>
32308de6:	f64b 2544 	movw	r5, #47684	@ 0xba44
32308dea:	f2c3 2530 	movt	r5, #12848	@ 0x3230
32308dee:	e576      	b.n	323088de <_vfprintf_r+0x1a66>
32308df0:	2300      	movs	r3, #0
32308df2:	2203      	movs	r2, #3
32308df4:	9309      	str	r3, [sp, #36]	@ 0x24
32308df6:	920b      	str	r2, [sp, #44]	@ 0x2c
32308df8:	2204      	movs	r2, #4
32308dfa:	9305      	str	r3, [sp, #20]
32308dfc:	9204      	str	r2, [sp, #16]
32308dfe:	9310      	str	r3, [sp, #64]	@ 0x40
32308e00:	930e      	str	r3, [sp, #56]	@ 0x38
32308e02:	930c      	str	r3, [sp, #48]	@ 0x30
32308e04:	f7fe b9c5 	b.w	32307192 <_vfprintf_r+0x31a>
32308e08:	2467      	movs	r4, #103	@ 0x67
32308e0a:	9917      	ldr	r1, [sp, #92]	@ 0x5c
32308e0c:	780b      	ldrb	r3, [r1, #0]
32308e0e:	2bff      	cmp	r3, #255	@ 0xff
32308e10:	f000 8129 	beq.w	32309066 <_vfprintf_r+0x21ee>
32308e14:	2600      	movs	r6, #0
32308e16:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32308e18:	4630      	mov	r0, r6
32308e1a:	e003      	b.n	32308e24 <_vfprintf_r+0x1fac>
32308e1c:	3001      	adds	r0, #1
32308e1e:	3101      	adds	r1, #1
32308e20:	2bff      	cmp	r3, #255	@ 0xff
32308e22:	d008      	beq.n	32308e36 <_vfprintf_r+0x1fbe>
32308e24:	4293      	cmp	r3, r2
32308e26:	da06      	bge.n	32308e36 <_vfprintf_r+0x1fbe>
32308e28:	1ad2      	subs	r2, r2, r3
32308e2a:	784b      	ldrb	r3, [r1, #1]
32308e2c:	2b00      	cmp	r3, #0
32308e2e:	d1f5      	bne.n	32308e1c <_vfprintf_r+0x1fa4>
32308e30:	780b      	ldrb	r3, [r1, #0]
32308e32:	3601      	adds	r6, #1
32308e34:	e7f4      	b.n	32308e20 <_vfprintf_r+0x1fa8>
32308e36:	920c      	str	r2, [sp, #48]	@ 0x30
32308e38:	9117      	str	r1, [sp, #92]	@ 0x5c
32308e3a:	900e      	str	r0, [sp, #56]	@ 0x38
32308e3c:	9610      	str	r6, [sp, #64]	@ 0x40
32308e3e:	9a10      	ldr	r2, [sp, #64]	@ 0x40
32308e40:	9b0e      	ldr	r3, [sp, #56]	@ 0x38
32308e42:	9915      	ldr	r1, [sp, #84]	@ 0x54
32308e44:	4413      	add	r3, r2
32308e46:	9a0b      	ldr	r2, [sp, #44]	@ 0x2c
32308e48:	fb01 2303 	mla	r3, r1, r3, r2
32308e4c:	930b      	str	r3, [sp, #44]	@ 0x2c
32308e4e:	ea23 73e3 	bic.w	r3, r3, r3, asr #31
32308e52:	9304      	str	r3, [sp, #16]
32308e54:	f1b8 0f00 	cmp.w	r8, #0
32308e58:	d049      	beq.n	32308eee <_vfprintf_r+0x2076>
32308e5a:	9b04      	ldr	r3, [sp, #16]
32308e5c:	f8cd a008 	str.w	sl, [sp, #8]
32308e60:	3301      	adds	r3, #1
32308e62:	9304      	str	r3, [sp, #16]
32308e64:	2300      	movs	r3, #0
32308e66:	9309      	str	r3, [sp, #36]	@ 0x24
32308e68:	461a      	mov	r2, r3
32308e6a:	232d      	movs	r3, #45	@ 0x2d
32308e6c:	9205      	str	r2, [sp, #20]
32308e6e:	f88d 3067 	strb.w	r3, [sp, #103]	@ 0x67
32308e72:	f7fe b98e 	b.w	32307192 <_vfprintf_r+0x31a>
32308e76:	2a00      	cmp	r2, #0
32308e78:	bfa8      	it	ge
32308e7a:	1c50      	addge	r0, r2, #1
32308e7c:	bfa8      	it	ge
32308e7e:	4619      	movge	r1, r3
32308e80:	bfa8      	it	ge
32308e82:	18c0      	addge	r0, r0, r3
32308e84:	bfa8      	it	ge
32308e86:	2630      	movge	r6, #48	@ 0x30
32308e88:	f6ff a88c 	blt.w	32307fa4 <_vfprintf_r+0x112c>
32308e8c:	f801 6b01 	strb.w	r6, [r1], #1
32308e90:	4281      	cmp	r1, r0
32308e92:	d1fb      	bne.n	32308e8c <_vfprintf_r+0x2014>
32308e94:	441a      	add	r2, r3
32308e96:	1c53      	adds	r3, r2, #1
32308e98:	f7ff b884 	b.w	32307fa4 <_vfprintf_r+0x112c>
32308e9c:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32308e9e:	930c      	str	r3, [sp, #48]	@ 0x30
32308ea0:	9b05      	ldr	r3, [sp, #20]
32308ea2:	930f      	str	r3, [sp, #60]	@ 0x3c
32308ea4:	e49f      	b.n	323087e6 <_vfprintf_r+0x196e>
32308ea6:	eeb5 9b40 	vcmp.f64	d9, #0.0
32308eaa:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32308eae:	d005      	beq.n	32308ebc <_vfprintf_r+0x2044>
32308eb0:	9b22      	ldr	r3, [sp, #136]	@ 0x88
32308eb2:	4299      	cmp	r1, r3
32308eb4:	f63f abb2 	bhi.w	3230861c <_vfprintf_r+0x17a4>
32308eb8:	1b5b      	subs	r3, r3, r5
32308eba:	930f      	str	r3, [sp, #60]	@ 0x3c
32308ebc:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32308ebe:	2e47      	cmp	r6, #71	@ 0x47
32308ec0:	930c      	str	r3, [sp, #48]	@ 0x30
32308ec2:	f47f ac9f 	bne.w	32308804 <_vfprintf_r+0x198c>
32308ec6:	e48e      	b.n	323087e6 <_vfprintf_r+0x196e>
32308ec8:	1b4b      	subs	r3, r1, r5
32308eca:	930f      	str	r3, [sp, #60]	@ 0x3c
32308ecc:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32308ece:	930c      	str	r3, [sp, #48]	@ 0x30
32308ed0:	f7ff bbb5 	b.w	3230863e <_vfprintf_r+0x17c6>
32308ed4:	eeb5 9b40 	vcmp.f64	d9, #0.0
32308ed8:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32308edc:	f040 80bd 	bne.w	3230905a <_vfprintf_r+0x21e2>
32308ee0:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32308ee2:	930c      	str	r3, [sp, #48]	@ 0x30
32308ee4:	4419      	add	r1, r3
32308ee6:	1b4b      	subs	r3, r1, r5
32308ee8:	930f      	str	r3, [sp, #60]	@ 0x3c
32308eea:	f7ff bba8 	b.w	3230863e <_vfprintf_r+0x17c6>
32308eee:	f89d 3067 	ldrb.w	r3, [sp, #103]	@ 0x67
32308ef2:	2b00      	cmp	r3, #0
32308ef4:	f000 80e5 	beq.w	323090c2 <_vfprintf_r+0x224a>
32308ef8:	9b04      	ldr	r3, [sp, #16]
32308efa:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
32308efe:	3301      	adds	r3, #1
32308f00:	f8cd a008 	str.w	sl, [sp, #8]
32308f04:	9304      	str	r3, [sp, #16]
32308f06:	f8cd 8014 	str.w	r8, [sp, #20]
32308f0a:	f7fe b942 	b.w	32307192 <_vfprintf_r+0x31a>
32308f0e:	f89d 2067 	ldrb.w	r2, [sp, #103]	@ 0x67
32308f12:	f64b 2544 	movw	r5, #47684	@ 0xba44
32308f16:	f2c3 2530 	movt	r5, #12848	@ 0x3230
32308f1a:	f64b 2348 	movw	r3, #47688	@ 0xba48
32308f1e:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32308f22:	2c47      	cmp	r4, #71	@ 0x47
32308f24:	bfc8      	it	gt
32308f26:	461d      	movgt	r5, r3
32308f28:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
32308f2a:	9305      	str	r3, [sp, #20]
32308f2c:	2a00      	cmp	r2, #0
32308f2e:	f040 80a1 	bne.w	32309074 <_vfprintf_r+0x21fc>
32308f32:	2203      	movs	r2, #3
32308f34:	9310      	str	r3, [sp, #64]	@ 0x40
32308f36:	920b      	str	r2, [sp, #44]	@ 0x2c
32308f38:	930e      	str	r3, [sp, #56]	@ 0x38
32308f3a:	9309      	str	r3, [sp, #36]	@ 0x24
32308f3c:	9204      	str	r2, [sp, #16]
32308f3e:	f7fe b928 	b.w	32307192 <_vfprintf_r+0x31a>
32308f42:	2306      	movs	r3, #6
32308f44:	eeb1 9b48 	vneg.f64	d9, d8
32308f48:	f04f 082d 	mov.w	r8, #45	@ 0x2d
32308f4c:	9305      	str	r3, [sp, #20]
32308f4e:	f7ff bb35 	b.w	323085bc <_vfprintf_r+0x1744>
32308f52:	2b00      	cmp	r3, #0
32308f54:	db76      	blt.n	32309044 <_vfprintf_r+0x21cc>
32308f56:	2301      	movs	r3, #1
32308f58:	eeb0 9b48 	vmov.f64	d9, d8
32308f5c:	f04f 0800 	mov.w	r8, #0
32308f60:	9305      	str	r3, [sp, #20]
32308f62:	f7ff bb2b 	b.w	323085bc <_vfprintf_r+0x1744>
32308f66:	9b05      	ldr	r3, [sp, #20]
32308f68:	9d10      	ldr	r5, [sp, #64]	@ 0x40
32308f6a:	f8cd 905c 	str.w	r9, [sp, #92]	@ 0x5c
32308f6e:	4689      	mov	r9, r1
32308f70:	4598      	cmp	r8, r3
32308f72:	bf28      	it	cs
32308f74:	4698      	movcs	r8, r3
32308f76:	f7fe be61 	b.w	32307c3c <_vfprintf_r+0xdc4>
32308f7a:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
32308f7e:	f8cd a008 	str.w	sl, [sp, #8]
32308f82:	f8cd 8014 	str.w	r8, [sp, #20]
32308f86:	f8cd 8040 	str.w	r8, [sp, #64]	@ 0x40
32308f8a:	f8cd 8038 	str.w	r8, [sp, #56]	@ 0x38
32308f8e:	f7fe b900 	b.w	32307192 <_vfprintf_r+0x31a>
32308f92:	f1c2 0301 	rsb	r3, r2, #1
32308f96:	222d      	movs	r2, #45	@ 0x2d
32308f98:	2b09      	cmp	r3, #9
32308f9a:	f88d 2079 	strb.w	r2, [sp, #121]	@ 0x79
32308f9e:	f73f ac42 	bgt.w	32308826 <_vfprintf_r+0x19ae>
32308fa2:	f7ff b814 	b.w	32307fce <_vfprintf_r+0x1156>
32308fa6:	9b05      	ldr	r3, [sp, #20]
32308fa8:	2473      	movs	r4, #115	@ 0x73
32308faa:	930b      	str	r3, [sp, #44]	@ 0x2c
32308fac:	9304      	str	r3, [sp, #16]
32308fae:	9b09      	ldr	r3, [sp, #36]	@ 0x24
32308fb0:	9310      	str	r3, [sp, #64]	@ 0x40
32308fb2:	930e      	str	r3, [sp, #56]	@ 0x38
32308fb4:	9305      	str	r3, [sp, #20]
32308fb6:	f7fe b8ec 	b.w	32307192 <_vfprintf_r+0x31a>
32308fba:	eeb1 0b48 	vneg.f64	d0, d8
32308fbe:	f04f 082d 	mov.w	r8, #45	@ 0x2d
32308fc2:	9009      	str	r0, [sp, #36]	@ 0x24
32308fc4:	f7fe bf8d 	b.w	32307ee2 <_vfprintf_r+0x106a>
32308fc8:	9a03      	ldr	r2, [sp, #12]
32308fca:	6e53      	ldr	r3, [r2, #100]	@ 0x64
32308fcc:	07dd      	lsls	r5, r3, #31
32308fce:	f53e aaf2 	bmi.w	323075b6 <_vfprintf_r+0x73e>
32308fd2:	8993      	ldrh	r3, [r2, #12]
32308fd4:	059c      	lsls	r4, r3, #22
32308fd6:	f53e aaee 	bmi.w	323075b6 <_vfprintf_r+0x73e>
32308fda:	6d90      	ldr	r0, [r2, #88]	@ 0x58
32308fdc:	f7fb fe44 	bl	32304c68 <__retarget_lock_release_recursive>
32308fe0:	f7fe bae9 	b.w	323075b6 <_vfprintf_r+0x73e>
32308fe4:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32308fe6:	786c      	ldrb	r4, [r5, #1]
32308fe8:	4615      	mov	r5, r2
32308fea:	f853 2b04 	ldr.w	r2, [r3], #4
32308fee:	930a      	str	r3, [sp, #40]	@ 0x28
32308ff0:	ea42 73e2 	orr.w	r3, r2, r2, asr #31
32308ff4:	9305      	str	r3, [sp, #20]
32308ff6:	f7fd bfbd 	b.w	32306f74 <_vfprintf_r+0xfc>
32308ffa:	2302      	movs	r3, #2
32308ffc:	9314      	str	r3, [sp, #80]	@ 0x50
32308ffe:	f7fe bfee 	b.w	32307fde <_vfprintf_r+0x1166>
32309002:	b92b      	cbnz	r3, 32309010 <_vfprintf_r+0x2198>
32309004:	2301      	movs	r3, #1
32309006:	2466      	movs	r4, #102	@ 0x66
32309008:	9304      	str	r3, [sp, #16]
3230900a:	930b      	str	r3, [sp, #44]	@ 0x2c
3230900c:	f7ff bb2e 	b.w	3230866c <_vfprintf_r+0x17f4>
32309010:	9b11      	ldr	r3, [sp, #68]	@ 0x44
32309012:	2466      	movs	r4, #102	@ 0x66
32309014:	9a05      	ldr	r2, [sp, #20]
32309016:	3301      	adds	r3, #1
32309018:	441a      	add	r2, r3
3230901a:	920b      	str	r2, [sp, #44]	@ 0x2c
3230901c:	ea22 73e2 	bic.w	r3, r2, r2, asr #31
32309020:	9304      	str	r3, [sp, #16]
32309022:	f7ff bb23 	b.w	3230866c <_vfprintf_r+0x17f4>
32309026:	9803      	ldr	r0, [sp, #12]
32309028:	6e42      	ldr	r2, [r0, #100]	@ 0x64
3230902a:	f9b0 300c 	ldrsh.w	r3, [r0, #12]
3230902e:	f043 0140 	orr.w	r1, r3, #64	@ 0x40
32309032:	8181      	strh	r1, [r0, #12]
32309034:	07d0      	lsls	r0, r2, #31
32309036:	f53e aabe 	bmi.w	323075b6 <_vfprintf_r+0x73e>
3230903a:	0598      	lsls	r0, r3, #22
3230903c:	f53e aabb 	bmi.w	323075b6 <_vfprintf_r+0x73e>
32309040:	f7fe b949 	b.w	323072d6 <_vfprintf_r+0x45e>
32309044:	2301      	movs	r3, #1
32309046:	eeb1 9b48 	vneg.f64	d9, d8
3230904a:	f04f 082d 	mov.w	r8, #45	@ 0x2d
3230904e:	9305      	str	r3, [sp, #20]
32309050:	f7ff bab4 	b.w	323085bc <_vfprintf_r+0x1744>
32309054:	7a81      	ldrb	r1, [r0, #10]
32309056:	f7fe bfa3 	b.w	32307fa0 <_vfprintf_r+0x1128>
3230905a:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
3230905c:	f1c3 0301 	rsb	r3, r3, #1
32309060:	931b      	str	r3, [sp, #108]	@ 0x6c
32309062:	f7ff bad0 	b.w	32308606 <_vfprintf_r+0x178e>
32309066:	2300      	movs	r3, #0
32309068:	9310      	str	r3, [sp, #64]	@ 0x40
3230906a:	930e      	str	r3, [sp, #56]	@ 0x38
3230906c:	e6e7      	b.n	32308e3e <_vfprintf_r+0x1fc6>
3230906e:	9802      	ldr	r0, [sp, #8]
32309070:	f7fe bb7f 	b.w	32307772 <_vfprintf_r+0x8fa>
32309074:	2203      	movs	r2, #3
32309076:	9310      	str	r3, [sp, #64]	@ 0x40
32309078:	930e      	str	r3, [sp, #56]	@ 0x38
3230907a:	9309      	str	r3, [sp, #36]	@ 0x24
3230907c:	2304      	movs	r3, #4
3230907e:	920b      	str	r2, [sp, #44]	@ 0x2c
32309080:	9304      	str	r3, [sp, #16]
32309082:	f7fe b886 	b.w	32307192 <_vfprintf_r+0x31a>
32309086:	1b5b      	subs	r3, r3, r5
32309088:	930f      	str	r3, [sp, #60]	@ 0x3c
3230908a:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
3230908c:	930c      	str	r3, [sp, #48]	@ 0x30
3230908e:	f7ff bad6 	b.w	3230863e <_vfprintf_r+0x17c6>
32309092:	9b0f      	ldr	r3, [sp, #60]	@ 0x3c
32309094:	18eb      	adds	r3, r5, r3
32309096:	e76b      	b.n	32308f70 <_vfprintf_r+0x20f8>
32309098:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3230909a:	9310      	str	r3, [sp, #64]	@ 0x40
3230909c:	930e      	str	r3, [sp, #56]	@ 0x38
3230909e:	f7fe b878 	b.w	32307192 <_vfprintf_r+0x31a>
323090a2:	9b03      	ldr	r3, [sp, #12]
323090a4:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
323090a8:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
323090ac:	e64c      	b.n	32308d48 <_vfprintf_r+0x1ed0>
323090ae:	9b03      	ldr	r3, [sp, #12]
323090b0:	9009      	str	r0, [sp, #36]	@ 0x24
323090b2:	f9b3 300c 	ldrsh.w	r3, [r3, #12]
323090b6:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
323090ba:	e645      	b.n	32308d48 <_vfprintf_r+0x1ed0>
323090bc:	460a      	mov	r2, r1
323090be:	f7fe bbd1 	b.w	32307864 <_vfprintf_r+0x9ec>
323090c2:	f8cd 8024 	str.w	r8, [sp, #36]	@ 0x24
323090c6:	f8cd a008 	str.w	sl, [sp, #8]
323090ca:	f8cd 8014 	str.w	r8, [sp, #20]
323090ce:	f7fe b860 	b.w	32307192 <_vfprintf_r+0x31a>
323090d2:	bf00      	nop

323090d4 <vfprintf>:
323090d4:	f24c 2ca0 	movw	ip, #49824	@ 0xc2a0
323090d8:	f2c3 2c30 	movt	ip, #12848	@ 0x3230
323090dc:	b500      	push	{lr}
323090de:	468e      	mov	lr, r1
323090e0:	4613      	mov	r3, r2
323090e2:	4601      	mov	r1, r0
323090e4:	4672      	mov	r2, lr
323090e6:	f8dc 0000 	ldr.w	r0, [ip]
323090ea:	f85d eb04 	ldr.w	lr, [sp], #4
323090ee:	f7fd bec3 	b.w	32306e78 <_vfprintf_r>
323090f2:	bf00      	nop
323090f4:	0000      	movs	r0, r0
	...

323090f8 <__sbprintf>:
323090f8:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
323090fc:	4698      	mov	r8, r3
323090fe:	eddf 0b22 	vldr	d16, [pc, #136]	@ 32309188 <__sbprintf+0x90>
32309102:	f5ad 6d8d 	sub.w	sp, sp, #1128	@ 0x468
32309106:	4616      	mov	r6, r2
32309108:	ab05      	add	r3, sp, #20
3230910a:	4607      	mov	r7, r0
3230910c:	a816      	add	r0, sp, #88	@ 0x58
3230910e:	460d      	mov	r5, r1
32309110:	466c      	mov	r4, sp
32309112:	f943 078f 	vst1.32	{d16}, [r3]
32309116:	898b      	ldrh	r3, [r1, #12]
32309118:	f023 0302 	bic.w	r3, r3, #2
3230911c:	f8ad 300c 	strh.w	r3, [sp, #12]
32309120:	6e4b      	ldr	r3, [r1, #100]	@ 0x64
32309122:	9319      	str	r3, [sp, #100]	@ 0x64
32309124:	89cb      	ldrh	r3, [r1, #14]
32309126:	f8ad 300e 	strh.w	r3, [sp, #14]
3230912a:	69cb      	ldr	r3, [r1, #28]
3230912c:	9307      	str	r3, [sp, #28]
3230912e:	6a4b      	ldr	r3, [r1, #36]	@ 0x24
32309130:	9309      	str	r3, [sp, #36]	@ 0x24
32309132:	ab1a      	add	r3, sp, #104	@ 0x68
32309134:	9300      	str	r3, [sp, #0]
32309136:	9304      	str	r3, [sp, #16]
32309138:	f44f 6380 	mov.w	r3, #1024	@ 0x400
3230913c:	9302      	str	r3, [sp, #8]
3230913e:	f7fb fd83 	bl	32304c48 <__retarget_lock_init_recursive>
32309142:	4632      	mov	r2, r6
32309144:	4643      	mov	r3, r8
32309146:	4669      	mov	r1, sp
32309148:	4638      	mov	r0, r7
3230914a:	f7fd fe95 	bl	32306e78 <_vfprintf_r>
3230914e:	1e06      	subs	r6, r0, #0
32309150:	db08      	blt.n	32309164 <__sbprintf+0x6c>
32309152:	4669      	mov	r1, sp
32309154:	4638      	mov	r0, r7
32309156:	f7fa fa0b 	bl	32303570 <_fflush_r>
3230915a:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
3230915e:	2800      	cmp	r0, #0
32309160:	bf18      	it	ne
32309162:	461e      	movne	r6, r3
32309164:	89a3      	ldrh	r3, [r4, #12]
32309166:	065b      	lsls	r3, r3, #25
32309168:	d503      	bpl.n	32309172 <__sbprintf+0x7a>
3230916a:	89ab      	ldrh	r3, [r5, #12]
3230916c:	f043 0340 	orr.w	r3, r3, #64	@ 0x40
32309170:	81ab      	strh	r3, [r5, #12]
32309172:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32309174:	f7fb fd6c 	bl	32304c50 <__retarget_lock_close_recursive>
32309178:	4630      	mov	r0, r6
3230917a:	f50d 6d8d 	add.w	sp, sp, #1128	@ 0x468
3230917e:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
32309182:	bf00      	nop
32309184:	f3af 8000 	nop.w
32309188:	00000400 	.word	0x00000400
3230918c:	00000000 	.word	0x00000000

32309190 <_fclose_r>:
32309190:	b570      	push	{r4, r5, r6, lr}
32309192:	2900      	cmp	r1, #0
32309194:	d040      	beq.n	32309218 <_fclose_r+0x88>
32309196:	4606      	mov	r6, r0
32309198:	460c      	mov	r4, r1
3230919a:	b110      	cbz	r0, 323091a2 <_fclose_r+0x12>
3230919c:	6b43      	ldr	r3, [r0, #52]	@ 0x34
3230919e:	2b00      	cmp	r3, #0
323091a0:	d03d      	beq.n	3230921e <_fclose_r+0x8e>
323091a2:	6e63      	ldr	r3, [r4, #100]	@ 0x64
323091a4:	f9b4 200c 	ldrsh.w	r2, [r4, #12]
323091a8:	07dd      	lsls	r5, r3, #31
323091aa:	d433      	bmi.n	32309214 <_fclose_r+0x84>
323091ac:	0590      	lsls	r0, r2, #22
323091ae:	d539      	bpl.n	32309224 <_fclose_r+0x94>
323091b0:	4621      	mov	r1, r4
323091b2:	4630      	mov	r0, r6
323091b4:	f7fa f940 	bl	32303438 <__sflush_r>
323091b8:	6ae3      	ldr	r3, [r4, #44]	@ 0x2c
323091ba:	4605      	mov	r5, r0
323091bc:	b13b      	cbz	r3, 323091ce <_fclose_r+0x3e>
323091be:	69e1      	ldr	r1, [r4, #28]
323091c0:	4630      	mov	r0, r6
323091c2:	4798      	blx	r3
323091c4:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
323091c8:	2800      	cmp	r0, #0
323091ca:	bfb8      	it	lt
323091cc:	461d      	movlt	r5, r3
323091ce:	89a3      	ldrh	r3, [r4, #12]
323091d0:	061a      	lsls	r2, r3, #24
323091d2:	d439      	bmi.n	32309248 <_fclose_r+0xb8>
323091d4:	6b21      	ldr	r1, [r4, #48]	@ 0x30
323091d6:	b141      	cbz	r1, 323091ea <_fclose_r+0x5a>
323091d8:	f104 0340 	add.w	r3, r4, #64	@ 0x40
323091dc:	4299      	cmp	r1, r3
323091de:	d002      	beq.n	323091e6 <_fclose_r+0x56>
323091e0:	4630      	mov	r0, r6
323091e2:	f7fc fb01 	bl	323057e8 <_free_r>
323091e6:	2300      	movs	r3, #0
323091e8:	6323      	str	r3, [r4, #48]	@ 0x30
323091ea:	6c61      	ldr	r1, [r4, #68]	@ 0x44
323091ec:	b121      	cbz	r1, 323091f8 <_fclose_r+0x68>
323091ee:	4630      	mov	r0, r6
323091f0:	f7fc fafa 	bl	323057e8 <_free_r>
323091f4:	2300      	movs	r3, #0
323091f6:	6463      	str	r3, [r4, #68]	@ 0x44
323091f8:	f7fa fb98 	bl	3230392c <__sfp_lock_acquire>
323091fc:	6e63      	ldr	r3, [r4, #100]	@ 0x64
323091fe:	2200      	movs	r2, #0
32309200:	81a2      	strh	r2, [r4, #12]
32309202:	07db      	lsls	r3, r3, #31
32309204:	d51c      	bpl.n	32309240 <_fclose_r+0xb0>
32309206:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32309208:	f7fb fd22 	bl	32304c50 <__retarget_lock_close_recursive>
3230920c:	f7fa fb94 	bl	32303938 <__sfp_lock_release>
32309210:	4628      	mov	r0, r5
32309212:	bd70      	pop	{r4, r5, r6, pc}
32309214:	2a00      	cmp	r2, #0
32309216:	d1cb      	bne.n	323091b0 <_fclose_r+0x20>
32309218:	2500      	movs	r5, #0
3230921a:	4628      	mov	r0, r5
3230921c:	bd70      	pop	{r4, r5, r6, pc}
3230921e:	f7fa fb5d 	bl	323038dc <__sinit>
32309222:	e7be      	b.n	323091a2 <_fclose_r+0x12>
32309224:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32309226:	f7fb fd17 	bl	32304c58 <__retarget_lock_acquire_recursive>
3230922a:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
3230922e:	2b00      	cmp	r3, #0
32309230:	d1be      	bne.n	323091b0 <_fclose_r+0x20>
32309232:	6e63      	ldr	r3, [r4, #100]	@ 0x64
32309234:	07d9      	lsls	r1, r3, #31
32309236:	d4ef      	bmi.n	32309218 <_fclose_r+0x88>
32309238:	6da0      	ldr	r0, [r4, #88]	@ 0x58
3230923a:	f7fb fd15 	bl	32304c68 <__retarget_lock_release_recursive>
3230923e:	e7eb      	b.n	32309218 <_fclose_r+0x88>
32309240:	6da0      	ldr	r0, [r4, #88]	@ 0x58
32309242:	f7fb fd11 	bl	32304c68 <__retarget_lock_release_recursive>
32309246:	e7de      	b.n	32309206 <_fclose_r+0x76>
32309248:	6921      	ldr	r1, [r4, #16]
3230924a:	4630      	mov	r0, r6
3230924c:	f7fc facc 	bl	323057e8 <_free_r>
32309250:	e7c0      	b.n	323091d4 <_fclose_r+0x44>
32309252:	bf00      	nop

32309254 <fclose>:
32309254:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
32309258:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230925c:	4601      	mov	r1, r0
3230925e:	6818      	ldr	r0, [r3, #0]
32309260:	f7ff bf96 	b.w	32309190 <_fclose_r>

32309264 <__smakebuf_r>:
32309264:	f9b1 300c 	ldrsh.w	r3, [r1, #12]
32309268:	b570      	push	{r4, r5, r6, lr}
3230926a:	460c      	mov	r4, r1
3230926c:	b096      	sub	sp, #88	@ 0x58
3230926e:	0799      	lsls	r1, r3, #30
32309270:	d507      	bpl.n	32309282 <__smakebuf_r+0x1e>
32309272:	f104 0343 	add.w	r3, r4, #67	@ 0x43
32309276:	2201      	movs	r2, #1
32309278:	6023      	str	r3, [r4, #0]
3230927a:	e9c4 3204 	strd	r3, r2, [r4, #16]
3230927e:	b016      	add	sp, #88	@ 0x58
32309280:	bd70      	pop	{r4, r5, r6, pc}
32309282:	f9b4 100e 	ldrsh.w	r1, [r4, #14]
32309286:	4605      	mov	r5, r0
32309288:	2900      	cmp	r1, #0
3230928a:	db2b      	blt.n	323092e4 <__smakebuf_r+0x80>
3230928c:	466a      	mov	r2, sp
3230928e:	f000 fb01 	bl	32309894 <_fstat_r>
32309292:	2800      	cmp	r0, #0
32309294:	db24      	blt.n	323092e0 <__smakebuf_r+0x7c>
32309296:	f44f 6180 	mov.w	r1, #1024	@ 0x400
3230929a:	4628      	mov	r0, r5
3230929c:	9e01      	ldr	r6, [sp, #4]
3230929e:	f7fc fbf3 	bl	32305a88 <_malloc_r>
323092a2:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
323092a6:	b3a0      	cbz	r0, 32309312 <__smakebuf_r+0xae>
323092a8:	f406 4670 	and.w	r6, r6, #61440	@ 0xf000
323092ac:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
323092b0:	f44f 6280 	mov.w	r2, #1024	@ 0x400
323092b4:	f5b6 5f00 	cmp.w	r6, #8192	@ 0x2000
323092b8:	6020      	str	r0, [r4, #0]
323092ba:	81a3      	strh	r3, [r4, #12]
323092bc:	6120      	str	r0, [r4, #16]
323092be:	6162      	str	r2, [r4, #20]
323092c0:	d135      	bne.n	3230932e <__smakebuf_r+0xca>
323092c2:	f9b4 100e 	ldrsh.w	r1, [r4, #14]
323092c6:	4628      	mov	r0, r5
323092c8:	f000 fafa 	bl	323098c0 <_isatty_r>
323092cc:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
323092d0:	b368      	cbz	r0, 3230932e <__smakebuf_r+0xca>
323092d2:	f023 0303 	bic.w	r3, r3, #3
323092d6:	f44f 6200 	mov.w	r2, #2048	@ 0x800
323092da:	f043 0301 	orr.w	r3, r3, #1
323092de:	e014      	b.n	3230930a <__smakebuf_r+0xa6>
323092e0:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
323092e4:	f013 0f80 	tst.w	r3, #128	@ 0x80
323092e8:	4628      	mov	r0, r5
323092ea:	f44f 6580 	mov.w	r5, #1024	@ 0x400
323092ee:	bf18      	it	ne
323092f0:	2540      	movne	r5, #64	@ 0x40
323092f2:	4629      	mov	r1, r5
323092f4:	f7fc fbc8 	bl	32305a88 <_malloc_r>
323092f8:	f9b4 300c 	ldrsh.w	r3, [r4, #12]
323092fc:	b148      	cbz	r0, 32309312 <__smakebuf_r+0xae>
323092fe:	f043 0380 	orr.w	r3, r3, #128	@ 0x80
32309302:	2200      	movs	r2, #0
32309304:	6020      	str	r0, [r4, #0]
32309306:	e9c4 0504 	strd	r0, r5, [r4, #16]
3230930a:	4313      	orrs	r3, r2
3230930c:	81a3      	strh	r3, [r4, #12]
3230930e:	b016      	add	sp, #88	@ 0x58
32309310:	bd70      	pop	{r4, r5, r6, pc}
32309312:	059a      	lsls	r2, r3, #22
32309314:	d4b3      	bmi.n	3230927e <__smakebuf_r+0x1a>
32309316:	f023 0303 	bic.w	r3, r3, #3
3230931a:	f104 0243 	add.w	r2, r4, #67	@ 0x43
3230931e:	f043 0302 	orr.w	r3, r3, #2
32309322:	2101      	movs	r1, #1
32309324:	81a3      	strh	r3, [r4, #12]
32309326:	6022      	str	r2, [r4, #0]
32309328:	e9c4 2104 	strd	r2, r1, [r4, #16]
3230932c:	e7a7      	b.n	3230927e <__smakebuf_r+0x1a>
3230932e:	f44f 6200 	mov.w	r2, #2048	@ 0x800
32309332:	e7ea      	b.n	3230930a <__smakebuf_r+0xa6>

32309334 <__swhatbuf_r>:
32309334:	b570      	push	{r4, r5, r6, lr}
32309336:	460c      	mov	r4, r1
32309338:	f9b1 100e 	ldrsh.w	r1, [r1, #14]
3230933c:	b096      	sub	sp, #88	@ 0x58
3230933e:	4615      	mov	r5, r2
32309340:	461e      	mov	r6, r3
32309342:	2900      	cmp	r1, #0
32309344:	db14      	blt.n	32309370 <__swhatbuf_r+0x3c>
32309346:	466a      	mov	r2, sp
32309348:	f000 faa4 	bl	32309894 <_fstat_r>
3230934c:	2800      	cmp	r0, #0
3230934e:	db0f      	blt.n	32309370 <__swhatbuf_r+0x3c>
32309350:	9901      	ldr	r1, [sp, #4]
32309352:	f44f 6380 	mov.w	r3, #1024	@ 0x400
32309356:	f44f 6000 	mov.w	r0, #2048	@ 0x800
3230935a:	f401 4170 	and.w	r1, r1, #61440	@ 0xf000
3230935e:	f5a1 5100 	sub.w	r1, r1, #8192	@ 0x2000
32309362:	fab1 f181 	clz	r1, r1
32309366:	0949      	lsrs	r1, r1, #5
32309368:	6031      	str	r1, [r6, #0]
3230936a:	602b      	str	r3, [r5, #0]
3230936c:	b016      	add	sp, #88	@ 0x58
3230936e:	bd70      	pop	{r4, r5, r6, pc}
32309370:	89a1      	ldrh	r1, [r4, #12]
32309372:	f011 0180 	ands.w	r1, r1, #128	@ 0x80
32309376:	d006      	beq.n	32309386 <__swhatbuf_r+0x52>
32309378:	2100      	movs	r1, #0
3230937a:	2340      	movs	r3, #64	@ 0x40
3230937c:	4608      	mov	r0, r1
3230937e:	6031      	str	r1, [r6, #0]
32309380:	602b      	str	r3, [r5, #0]
32309382:	b016      	add	sp, #88	@ 0x58
32309384:	bd70      	pop	{r4, r5, r6, pc}
32309386:	f44f 6380 	mov.w	r3, #1024	@ 0x400
3230938a:	4608      	mov	r0, r1
3230938c:	6031      	str	r1, [r6, #0]
3230938e:	602b      	str	r3, [r5, #0]
32309390:	b016      	add	sp, #88	@ 0x58
32309392:	bd70      	pop	{r4, r5, r6, pc}

32309394 <strcasecmp>:
32309394:	b410      	push	{r4}
32309396:	4684      	mov	ip, r0
32309398:	4c10      	ldr	r4, [pc, #64]	@ (323093dc <strcasecmp+0x48>)
3230939a:	f81c 3b01 	ldrb.w	r3, [ip], #1
3230939e:	f811 0b01 	ldrb.w	r0, [r1], #1
323093a2:	5ce2      	ldrb	r2, [r4, r3]
323093a4:	f002 0203 	and.w	r2, r2, #3
323093a8:	2a01      	cmp	r2, #1
323093aa:	5c22      	ldrb	r2, [r4, r0]
323093ac:	bf08      	it	eq
323093ae:	3320      	addeq	r3, #32
323093b0:	f002 0203 	and.w	r2, r2, #3
323093b4:	2a01      	cmp	r2, #1
323093b6:	d006      	beq.n	323093c6 <strcasecmp+0x32>
323093b8:	1a1b      	subs	r3, r3, r0
323093ba:	d10a      	bne.n	323093d2 <strcasecmp+0x3e>
323093bc:	2800      	cmp	r0, #0
323093be:	d1ec      	bne.n	3230939a <strcasecmp+0x6>
323093c0:	f85d 4b04 	ldr.w	r4, [sp], #4
323093c4:	4770      	bx	lr
323093c6:	3020      	adds	r0, #32
323093c8:	1a18      	subs	r0, r3, r0
323093ca:	d0e6      	beq.n	3230939a <strcasecmp+0x6>
323093cc:	f85d 4b04 	ldr.w	r4, [sp], #4
323093d0:	4770      	bx	lr
323093d2:	4618      	mov	r0, r3
323093d4:	f85d 4b04 	ldr.w	r4, [sp], #4
323093d8:	4770      	bx	lr
323093da:	bf00      	nop
323093dc:	3230bdb1 	.word	0x3230bdb1

323093e0 <strcat>:
323093e0:	b510      	push	{r4, lr}
323093e2:	0783      	lsls	r3, r0, #30
323093e4:	4604      	mov	r4, r0
323093e6:	d111      	bne.n	3230940c <strcat+0x2c>
323093e8:	6822      	ldr	r2, [r4, #0]
323093ea:	4620      	mov	r0, r4
323093ec:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
323093f0:	ea23 0302 	bic.w	r3, r3, r2
323093f4:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
323093f8:	d108      	bne.n	3230940c <strcat+0x2c>
323093fa:	f850 2f04 	ldr.w	r2, [r0, #4]!
323093fe:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
32309402:	ea23 0302 	bic.w	r3, r3, r2
32309406:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
3230940a:	d0f6      	beq.n	323093fa <strcat+0x1a>
3230940c:	7803      	ldrb	r3, [r0, #0]
3230940e:	b11b      	cbz	r3, 32309418 <strcat+0x38>
32309410:	f810 3f01 	ldrb.w	r3, [r0, #1]!
32309414:	2b00      	cmp	r3, #0
32309416:	d1fb      	bne.n	32309410 <strcat+0x30>
32309418:	f7fb fda2 	bl	32304f60 <strcpy>
3230941c:	4620      	mov	r0, r4
3230941e:	bd10      	pop	{r4, pc}

32309420 <strchr>:
32309420:	4603      	mov	r3, r0
32309422:	f000 0203 	and.w	r2, r0, #3
32309426:	f011 01ff 	ands.w	r1, r1, #255	@ 0xff
3230942a:	d039      	beq.n	323094a0 <strchr+0x80>
3230942c:	bb8a      	cbnz	r2, 32309492 <strchr+0x72>
3230942e:	b510      	push	{r4, lr}
32309430:	f04f 3e01 	mov.w	lr, #16843009	@ 0x1010101
32309434:	6802      	ldr	r2, [r0, #0]
32309436:	fb0e fe01 	mul.w	lr, lr, r1
3230943a:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
3230943e:	ea23 0302 	bic.w	r3, r3, r2
32309442:	ea8e 0402 	eor.w	r4, lr, r2
32309446:	f1a4 3201 	sub.w	r2, r4, #16843009	@ 0x1010101
3230944a:	ea22 0204 	bic.w	r2, r2, r4
3230944e:	4313      	orrs	r3, r2
32309450:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
32309454:	d10f      	bne.n	32309476 <strchr+0x56>
32309456:	f850 4f04 	ldr.w	r4, [r0, #4]!
3230945a:	ea84 0c0e 	eor.w	ip, r4, lr
3230945e:	f1a4 3301 	sub.w	r3, r4, #16843009	@ 0x1010101
32309462:	f1ac 3201 	sub.w	r2, ip, #16843009	@ 0x1010101
32309466:	ea23 0304 	bic.w	r3, r3, r4
3230946a:	ea22 020c 	bic.w	r2, r2, ip
3230946e:	4313      	orrs	r3, r2
32309470:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
32309474:	d0ef      	beq.n	32309456 <strchr+0x36>
32309476:	7803      	ldrb	r3, [r0, #0]
32309478:	b923      	cbnz	r3, 32309484 <strchr+0x64>
3230947a:	e036      	b.n	323094ea <strchr+0xca>
3230947c:	f810 3f01 	ldrb.w	r3, [r0, #1]!
32309480:	2b00      	cmp	r3, #0
32309482:	d032      	beq.n	323094ea <strchr+0xca>
32309484:	4299      	cmp	r1, r3
32309486:	d1f9      	bne.n	3230947c <strchr+0x5c>
32309488:	bd10      	pop	{r4, pc}
3230948a:	428a      	cmp	r2, r1
3230948c:	d028      	beq.n	323094e0 <strchr+0xc0>
3230948e:	079a      	lsls	r2, r3, #30
32309490:	d029      	beq.n	323094e6 <strchr+0xc6>
32309492:	781a      	ldrb	r2, [r3, #0]
32309494:	4618      	mov	r0, r3
32309496:	3301      	adds	r3, #1
32309498:	2a00      	cmp	r2, #0
3230949a:	d1f6      	bne.n	3230948a <strchr+0x6a>
3230949c:	4610      	mov	r0, r2
3230949e:	4770      	bx	lr
323094a0:	b9ca      	cbnz	r2, 323094d6 <strchr+0xb6>
323094a2:	6802      	ldr	r2, [r0, #0]
323094a4:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
323094a8:	ea23 0302 	bic.w	r3, r3, r2
323094ac:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
323094b0:	d108      	bne.n	323094c4 <strchr+0xa4>
323094b2:	f850 2f04 	ldr.w	r2, [r0, #4]!
323094b6:	f1a2 3301 	sub.w	r3, r2, #16843009	@ 0x1010101
323094ba:	ea23 0302 	bic.w	r3, r3, r2
323094be:	f013 3f80 	tst.w	r3, #2155905152	@ 0x80808080
323094c2:	d0f6      	beq.n	323094b2 <strchr+0x92>
323094c4:	7803      	ldrb	r3, [r0, #0]
323094c6:	b15b      	cbz	r3, 323094e0 <strchr+0xc0>
323094c8:	f810 3f01 	ldrb.w	r3, [r0, #1]!
323094cc:	2b00      	cmp	r3, #0
323094ce:	d1fb      	bne.n	323094c8 <strchr+0xa8>
323094d0:	4770      	bx	lr
323094d2:	0799      	lsls	r1, r3, #30
323094d4:	d005      	beq.n	323094e2 <strchr+0xc2>
323094d6:	4618      	mov	r0, r3
323094d8:	f813 2b01 	ldrb.w	r2, [r3], #1
323094dc:	2a00      	cmp	r2, #0
323094de:	d1f8      	bne.n	323094d2 <strchr+0xb2>
323094e0:	4770      	bx	lr
323094e2:	4618      	mov	r0, r3
323094e4:	e7dd      	b.n	323094a2 <strchr+0x82>
323094e6:	4618      	mov	r0, r3
323094e8:	e7a1      	b.n	3230942e <strchr+0xe>
323094ea:	4618      	mov	r0, r3
323094ec:	bd10      	pop	{r4, pc}
323094ee:	bf00      	nop

323094f0 <strlcpy>:
323094f0:	460b      	mov	r3, r1
323094f2:	b932      	cbnz	r2, 32309502 <strlcpy+0x12>
323094f4:	f813 2b01 	ldrb.w	r2, [r3], #1
323094f8:	2a00      	cmp	r2, #0
323094fa:	d1fb      	bne.n	323094f4 <strlcpy+0x4>
323094fc:	1a58      	subs	r0, r3, r1
323094fe:	3801      	subs	r0, #1
32309500:	4770      	bx	lr
32309502:	3a01      	subs	r2, #1
32309504:	d018      	beq.n	32309538 <strlcpy+0x48>
32309506:	b410      	push	{r4}
32309508:	e001      	b.n	3230950e <strlcpy+0x1e>
3230950a:	3a01      	subs	r2, #1
3230950c:	d00a      	beq.n	32309524 <strlcpy+0x34>
3230950e:	f813 4b01 	ldrb.w	r4, [r3], #1
32309512:	f800 4b01 	strb.w	r4, [r0], #1
32309516:	2c00      	cmp	r4, #0
32309518:	d1f7      	bne.n	3230950a <strlcpy+0x1a>
3230951a:	1a58      	subs	r0, r3, r1
3230951c:	f85d 4b04 	ldr.w	r4, [sp], #4
32309520:	3801      	subs	r0, #1
32309522:	4770      	bx	lr
32309524:	7002      	strb	r2, [r0, #0]
32309526:	f813 2b01 	ldrb.w	r2, [r3], #1
3230952a:	2a00      	cmp	r2, #0
3230952c:	d1fb      	bne.n	32309526 <strlcpy+0x36>
3230952e:	1a58      	subs	r0, r3, r1
32309530:	f85d 4b04 	ldr.w	r4, [sp], #4
32309534:	3801      	subs	r0, #1
32309536:	4770      	bx	lr
32309538:	7002      	strb	r2, [r0, #0]
3230953a:	e7db      	b.n	323094f4 <strlcpy+0x4>

3230953c <strncasecmp>:
3230953c:	b322      	cbz	r2, 32309588 <strncasecmp+0x4c>
3230953e:	b510      	push	{r4, lr}
32309540:	4402      	add	r2, r0
32309542:	4c12      	ldr	r4, [pc, #72]	@ (3230958c <strncasecmp+0x50>)
32309544:	4686      	mov	lr, r0
32309546:	e004      	b.n	32309552 <strncasecmp+0x16>
32309548:	1a1b      	subs	r3, r3, r0
3230954a:	d11b      	bne.n	32309584 <strncasecmp+0x48>
3230954c:	b1b8      	cbz	r0, 3230957e <strncasecmp+0x42>
3230954e:	4596      	cmp	lr, r2
32309550:	d016      	beq.n	32309580 <strncasecmp+0x44>
32309552:	f81e 3b01 	ldrb.w	r3, [lr], #1
32309556:	f811 0b01 	ldrb.w	r0, [r1], #1
3230955a:	f814 c003 	ldrb.w	ip, [r4, r3]
3230955e:	f00c 0c03 	and.w	ip, ip, #3
32309562:	f1bc 0f01 	cmp.w	ip, #1
32309566:	f814 c000 	ldrb.w	ip, [r4, r0]
3230956a:	bf08      	it	eq
3230956c:	3320      	addeq	r3, #32
3230956e:	f00c 0c03 	and.w	ip, ip, #3
32309572:	f1bc 0f01 	cmp.w	ip, #1
32309576:	d1e7      	bne.n	32309548 <strncasecmp+0xc>
32309578:	3020      	adds	r0, #32
3230957a:	1a18      	subs	r0, r3, r0
3230957c:	d0e7      	beq.n	3230954e <strncasecmp+0x12>
3230957e:	bd10      	pop	{r4, pc}
32309580:	2000      	movs	r0, #0
32309582:	bd10      	pop	{r4, pc}
32309584:	4618      	mov	r0, r3
32309586:	bd10      	pop	{r4, pc}
32309588:	4610      	mov	r0, r2
3230958a:	4770      	bx	lr
3230958c:	3230bdb1 	.word	0x3230bdb1

32309590 <strncmp>:
32309590:	b392      	cbz	r2, 323095f8 <strncmp+0x68>
32309592:	b530      	push	{r4, r5, lr}
32309594:	ea40 0401 	orr.w	r4, r0, r1
32309598:	4686      	mov	lr, r0
3230959a:	460b      	mov	r3, r1
3230959c:	07a4      	lsls	r4, r4, #30
3230959e:	d117      	bne.n	323095d0 <strncmp+0x40>
323095a0:	2a03      	cmp	r2, #3
323095a2:	d807      	bhi.n	323095b4 <strncmp+0x24>
323095a4:	e014      	b.n	323095d0 <strncmp+0x40>
323095a6:	3a04      	subs	r2, #4
323095a8:	d024      	beq.n	323095f4 <strncmp+0x64>
323095aa:	f01c 3f80 	tst.w	ip, #2155905152	@ 0x80808080
323095ae:	d121      	bne.n	323095f4 <strncmp+0x64>
323095b0:	2a03      	cmp	r2, #3
323095b2:	d925      	bls.n	32309600 <strncmp+0x70>
323095b4:	f8de 4000 	ldr.w	r4, [lr]
323095b8:	4619      	mov	r1, r3
323095ba:	f853 5b04 	ldr.w	r5, [r3], #4
323095be:	4670      	mov	r0, lr
323095c0:	f1a4 3c01 	sub.w	ip, r4, #16843009	@ 0x1010101
323095c4:	f10e 0e04 	add.w	lr, lr, #4
323095c8:	ea2c 0c04 	bic.w	ip, ip, r4
323095cc:	42ac      	cmp	r4, r5
323095ce:	d0ea      	beq.n	323095a6 <strncmp+0x16>
323095d0:	7803      	ldrb	r3, [r0, #0]
323095d2:	3a01      	subs	r2, #1
323095d4:	780c      	ldrb	r4, [r1, #0]
323095d6:	42a3      	cmp	r3, r4
323095d8:	bf08      	it	eq
323095da:	1812      	addeq	r2, r2, r0
323095dc:	d006      	beq.n	323095ec <strncmp+0x5c>
323095de:	e00d      	b.n	323095fc <strncmp+0x6c>
323095e0:	f810 3f01 	ldrb.w	r3, [r0, #1]!
323095e4:	f811 4f01 	ldrb.w	r4, [r1, #1]!
323095e8:	42a3      	cmp	r3, r4
323095ea:	d107      	bne.n	323095fc <strncmp+0x6c>
323095ec:	4290      	cmp	r0, r2
323095ee:	bf18      	it	ne
323095f0:	2b00      	cmpne	r3, #0
323095f2:	d1f5      	bne.n	323095e0 <strncmp+0x50>
323095f4:	2000      	movs	r0, #0
323095f6:	bd30      	pop	{r4, r5, pc}
323095f8:	4610      	mov	r0, r2
323095fa:	4770      	bx	lr
323095fc:	1b18      	subs	r0, r3, r4
323095fe:	bd30      	pop	{r4, r5, pc}
32309600:	4670      	mov	r0, lr
32309602:	4619      	mov	r1, r3
32309604:	e7e4      	b.n	323095d0 <strncmp+0x40>
32309606:	bf00      	nop

32309608 <_init_signal_r>:
32309608:	f8d0 3138 	ldr.w	r3, [r0, #312]	@ 0x138
3230960c:	b10b      	cbz	r3, 32309612 <_init_signal_r+0xa>
3230960e:	2000      	movs	r0, #0
32309610:	4770      	bx	lr
32309612:	b510      	push	{r4, lr}
32309614:	4604      	mov	r4, r0
32309616:	2180      	movs	r1, #128	@ 0x80
32309618:	f7fc fa36 	bl	32305a88 <_malloc_r>
3230961c:	f8c4 0138 	str.w	r0, [r4, #312]	@ 0x138
32309620:	b148      	cbz	r0, 32309636 <_init_signal_r+0x2e>
32309622:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
32309626:	f100 0380 	add.w	r3, r0, #128	@ 0x80
3230962a:	f940 0a8d 	vst1.32	{d16-d17}, [r0]!
3230962e:	4283      	cmp	r3, r0
32309630:	d1fb      	bne.n	3230962a <_init_signal_r+0x22>
32309632:	2000      	movs	r0, #0
32309634:	bd10      	pop	{r4, pc}
32309636:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3230963a:	bd10      	pop	{r4, pc}

3230963c <_signal_r>:
3230963c:	b530      	push	{r4, r5, lr}
3230963e:	291f      	cmp	r1, #31
32309640:	4605      	mov	r5, r0
32309642:	b083      	sub	sp, #12
32309644:	d809      	bhi.n	3230965a <_signal_r+0x1e>
32309646:	f8d0 3138 	ldr.w	r3, [r0, #312]	@ 0x138
3230964a:	460c      	mov	r4, r1
3230964c:	b15b      	cbz	r3, 32309666 <_signal_r+0x2a>
3230964e:	f853 0024 	ldr.w	r0, [r3, r4, lsl #2]
32309652:	f843 2024 	str.w	r2, [r3, r4, lsl #2]
32309656:	b003      	add	sp, #12
32309658:	bd30      	pop	{r4, r5, pc}
3230965a:	2316      	movs	r3, #22
3230965c:	6003      	str	r3, [r0, #0]
3230965e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32309662:	b003      	add	sp, #12
32309664:	bd30      	pop	{r4, r5, pc}
32309666:	2180      	movs	r1, #128	@ 0x80
32309668:	9201      	str	r2, [sp, #4]
3230966a:	f7fc fa0d 	bl	32305a88 <_malloc_r>
3230966e:	9a01      	ldr	r2, [sp, #4]
32309670:	4603      	mov	r3, r0
32309672:	4601      	mov	r1, r0
32309674:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
32309678:	f8c5 0138 	str.w	r0, [r5, #312]	@ 0x138
3230967c:	3080      	adds	r0, #128	@ 0x80
3230967e:	2b00      	cmp	r3, #0
32309680:	d0ed      	beq.n	3230965e <_signal_r+0x22>
32309682:	f941 0a8d 	vst1.32	{d16-d17}, [r1]!
32309686:	4288      	cmp	r0, r1
32309688:	d1fb      	bne.n	32309682 <_signal_r+0x46>
3230968a:	e7e0      	b.n	3230964e <_signal_r+0x12>

3230968c <_raise_r>:
3230968c:	b538      	push	{r3, r4, r5, lr}
3230968e:	291f      	cmp	r1, #31
32309690:	4605      	mov	r5, r0
32309692:	d81f      	bhi.n	323096d4 <_raise_r+0x48>
32309694:	f8d0 2138 	ldr.w	r2, [r0, #312]	@ 0x138
32309698:	460c      	mov	r4, r1
3230969a:	b16a      	cbz	r2, 323096b8 <_raise_r+0x2c>
3230969c:	f852 3021 	ldr.w	r3, [r2, r1, lsl #2]
323096a0:	b153      	cbz	r3, 323096b8 <_raise_r+0x2c>
323096a2:	2b01      	cmp	r3, #1
323096a4:	d006      	beq.n	323096b4 <_raise_r+0x28>
323096a6:	1c59      	adds	r1, r3, #1
323096a8:	d010      	beq.n	323096cc <_raise_r+0x40>
323096aa:	2100      	movs	r1, #0
323096ac:	4620      	mov	r0, r4
323096ae:	f842 1024 	str.w	r1, [r2, r4, lsl #2]
323096b2:	4798      	blx	r3
323096b4:	2000      	movs	r0, #0
323096b6:	bd38      	pop	{r3, r4, r5, pc}
323096b8:	4628      	mov	r0, r5
323096ba:	f000 f92b 	bl	32309914 <_getpid_r>
323096be:	4622      	mov	r2, r4
323096c0:	4601      	mov	r1, r0
323096c2:	4628      	mov	r0, r5
323096c4:	e8bd 4038 	ldmia.w	sp!, {r3, r4, r5, lr}
323096c8:	f000 b90e 	b.w	323098e8 <_kill_r>
323096cc:	2316      	movs	r3, #22
323096ce:	2001      	movs	r0, #1
323096d0:	602b      	str	r3, [r5, #0]
323096d2:	bd38      	pop	{r3, r4, r5, pc}
323096d4:	2316      	movs	r3, #22
323096d6:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
323096da:	602b      	str	r3, [r5, #0]
323096dc:	bd38      	pop	{r3, r4, r5, pc}
323096de:	bf00      	nop

323096e0 <__sigtramp_r>:
323096e0:	291f      	cmp	r1, #31
323096e2:	d82c      	bhi.n	3230973e <__sigtramp_r+0x5e>
323096e4:	f8d0 2138 	ldr.w	r2, [r0, #312]	@ 0x138
323096e8:	b538      	push	{r3, r4, r5, lr}
323096ea:	460c      	mov	r4, r1
323096ec:	4605      	mov	r5, r0
323096ee:	b192      	cbz	r2, 32309716 <__sigtramp_r+0x36>
323096f0:	f852 3024 	ldr.w	r3, [r2, r4, lsl #2]
323096f4:	2001      	movs	r0, #1
323096f6:	b15b      	cbz	r3, 32309710 <__sigtramp_r+0x30>
323096f8:	1c59      	adds	r1, r3, #1
323096fa:	d00a      	beq.n	32309712 <__sigtramp_r+0x32>
323096fc:	2b01      	cmp	r3, #1
323096fe:	bf08      	it	eq
32309700:	2003      	moveq	r0, #3
32309702:	d005      	beq.n	32309710 <__sigtramp_r+0x30>
32309704:	2500      	movs	r5, #0
32309706:	4620      	mov	r0, r4
32309708:	f842 5024 	str.w	r5, [r2, r4, lsl #2]
3230970c:	4798      	blx	r3
3230970e:	4628      	mov	r0, r5
32309710:	bd38      	pop	{r3, r4, r5, pc}
32309712:	2002      	movs	r0, #2
32309714:	bd38      	pop	{r3, r4, r5, pc}
32309716:	2180      	movs	r1, #128	@ 0x80
32309718:	f7fc f9b6 	bl	32305a88 <_malloc_r>
3230971c:	4602      	mov	r2, r0
3230971e:	f8c5 0138 	str.w	r0, [r5, #312]	@ 0x138
32309722:	b148      	cbz	r0, 32309738 <__sigtramp_r+0x58>
32309724:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
32309728:	4603      	mov	r3, r0
3230972a:	f100 0180 	add.w	r1, r0, #128	@ 0x80
3230972e:	f943 0a8d 	vst1.32	{d16-d17}, [r3]!
32309732:	4299      	cmp	r1, r3
32309734:	d1fb      	bne.n	3230972e <__sigtramp_r+0x4e>
32309736:	e7db      	b.n	323096f0 <__sigtramp_r+0x10>
32309738:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3230973c:	bd38      	pop	{r3, r4, r5, pc}
3230973e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32309742:	4770      	bx	lr

32309744 <raise>:
32309744:	b538      	push	{r3, r4, r5, lr}
32309746:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
3230974a:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230974e:	281f      	cmp	r0, #31
32309750:	681d      	ldr	r5, [r3, #0]
32309752:	d81e      	bhi.n	32309792 <raise+0x4e>
32309754:	f8d5 2138 	ldr.w	r2, [r5, #312]	@ 0x138
32309758:	4604      	mov	r4, r0
3230975a:	b162      	cbz	r2, 32309776 <raise+0x32>
3230975c:	f852 3020 	ldr.w	r3, [r2, r0, lsl #2]
32309760:	b14b      	cbz	r3, 32309776 <raise+0x32>
32309762:	2b01      	cmp	r3, #1
32309764:	d005      	beq.n	32309772 <raise+0x2e>
32309766:	1c59      	adds	r1, r3, #1
32309768:	d00f      	beq.n	3230978a <raise+0x46>
3230976a:	2100      	movs	r1, #0
3230976c:	f842 1020 	str.w	r1, [r2, r0, lsl #2]
32309770:	4798      	blx	r3
32309772:	2000      	movs	r0, #0
32309774:	bd38      	pop	{r3, r4, r5, pc}
32309776:	4628      	mov	r0, r5
32309778:	f000 f8cc 	bl	32309914 <_getpid_r>
3230977c:	4622      	mov	r2, r4
3230977e:	4601      	mov	r1, r0
32309780:	4628      	mov	r0, r5
32309782:	e8bd 4038 	ldmia.w	sp!, {r3, r4, r5, lr}
32309786:	f000 b8af 	b.w	323098e8 <_kill_r>
3230978a:	2316      	movs	r3, #22
3230978c:	2001      	movs	r0, #1
3230978e:	602b      	str	r3, [r5, #0]
32309790:	bd38      	pop	{r3, r4, r5, pc}
32309792:	2316      	movs	r3, #22
32309794:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32309798:	602b      	str	r3, [r5, #0]
3230979a:	bd38      	pop	{r3, r4, r5, pc}

3230979c <signal>:
3230979c:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
323097a0:	f2c3 2330 	movt	r3, #12848	@ 0x3230
323097a4:	b570      	push	{r4, r5, r6, lr}
323097a6:	281f      	cmp	r0, #31
323097a8:	681e      	ldr	r6, [r3, #0]
323097aa:	d809      	bhi.n	323097c0 <signal+0x24>
323097ac:	f8d6 3138 	ldr.w	r3, [r6, #312]	@ 0x138
323097b0:	4604      	mov	r4, r0
323097b2:	460d      	mov	r5, r1
323097b4:	b14b      	cbz	r3, 323097ca <signal+0x2e>
323097b6:	f853 0024 	ldr.w	r0, [r3, r4, lsl #2]
323097ba:	f843 5024 	str.w	r5, [r3, r4, lsl #2]
323097be:	bd70      	pop	{r4, r5, r6, pc}
323097c0:	2316      	movs	r3, #22
323097c2:	6033      	str	r3, [r6, #0]
323097c4:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
323097c8:	bd70      	pop	{r4, r5, r6, pc}
323097ca:	2180      	movs	r1, #128	@ 0x80
323097cc:	4630      	mov	r0, r6
323097ce:	f7fc f95b 	bl	32305a88 <_malloc_r>
323097d2:	4603      	mov	r3, r0
323097d4:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
323097d8:	4602      	mov	r2, r0
323097da:	f100 0180 	add.w	r1, r0, #128	@ 0x80
323097de:	f8c6 0138 	str.w	r0, [r6, #312]	@ 0x138
323097e2:	2800      	cmp	r0, #0
323097e4:	d0ee      	beq.n	323097c4 <signal+0x28>
323097e6:	f942 0a8d 	vst1.32	{d16-d17}, [r2]!
323097ea:	4291      	cmp	r1, r2
323097ec:	d1fb      	bne.n	323097e6 <signal+0x4a>
323097ee:	e7e2      	b.n	323097b6 <signal+0x1a>

323097f0 <_init_signal>:
323097f0:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
323097f4:	f2c3 2330 	movt	r3, #12848	@ 0x3230
323097f8:	b510      	push	{r4, lr}
323097fa:	681c      	ldr	r4, [r3, #0]
323097fc:	f8d4 3138 	ldr.w	r3, [r4, #312]	@ 0x138
32309800:	b10b      	cbz	r3, 32309806 <_init_signal+0x16>
32309802:	2000      	movs	r0, #0
32309804:	bd10      	pop	{r4, pc}
32309806:	2180      	movs	r1, #128	@ 0x80
32309808:	4620      	mov	r0, r4
3230980a:	f7fc f93d 	bl	32305a88 <_malloc_r>
3230980e:	f8c4 0138 	str.w	r0, [r4, #312]	@ 0x138
32309812:	b140      	cbz	r0, 32309826 <_init_signal+0x36>
32309814:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
32309818:	f100 0380 	add.w	r3, r0, #128	@ 0x80
3230981c:	f940 0a8d 	vst1.32	{d16-d17}, [r0]!
32309820:	4298      	cmp	r0, r3
32309822:	d1fb      	bne.n	3230981c <_init_signal+0x2c>
32309824:	e7ed      	b.n	32309802 <_init_signal+0x12>
32309826:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3230982a:	bd10      	pop	{r4, pc}

3230982c <__sigtramp>:
3230982c:	b538      	push	{r3, r4, r5, lr}
3230982e:	f24c 23a0 	movw	r3, #49824	@ 0xc2a0
32309832:	f2c3 2330 	movt	r3, #12848	@ 0x3230
32309836:	281f      	cmp	r0, #31
32309838:	681d      	ldr	r5, [r3, #0]
3230983a:	d828      	bhi.n	3230988e <__sigtramp+0x62>
3230983c:	f8d5 2138 	ldr.w	r2, [r5, #312]	@ 0x138
32309840:	4604      	mov	r4, r0
32309842:	b192      	cbz	r2, 3230986a <__sigtramp+0x3e>
32309844:	f852 3024 	ldr.w	r3, [r2, r4, lsl #2]
32309848:	2001      	movs	r0, #1
3230984a:	b15b      	cbz	r3, 32309864 <__sigtramp+0x38>
3230984c:	1c59      	adds	r1, r3, #1
3230984e:	d00a      	beq.n	32309866 <__sigtramp+0x3a>
32309850:	2b01      	cmp	r3, #1
32309852:	bf08      	it	eq
32309854:	2003      	moveq	r0, #3
32309856:	d005      	beq.n	32309864 <__sigtramp+0x38>
32309858:	2500      	movs	r5, #0
3230985a:	4620      	mov	r0, r4
3230985c:	f842 5024 	str.w	r5, [r2, r4, lsl #2]
32309860:	4798      	blx	r3
32309862:	4628      	mov	r0, r5
32309864:	bd38      	pop	{r3, r4, r5, pc}
32309866:	2002      	movs	r0, #2
32309868:	bd38      	pop	{r3, r4, r5, pc}
3230986a:	2180      	movs	r1, #128	@ 0x80
3230986c:	4628      	mov	r0, r5
3230986e:	f7fc f90b 	bl	32305a88 <_malloc_r>
32309872:	4602      	mov	r2, r0
32309874:	f8c5 0138 	str.w	r0, [r5, #312]	@ 0x138
32309878:	b148      	cbz	r0, 3230988e <__sigtramp+0x62>
3230987a:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
3230987e:	4603      	mov	r3, r0
32309880:	f100 0180 	add.w	r1, r0, #128	@ 0x80
32309884:	f943 0a8d 	vst1.32	{d16-d17}, [r3]!
32309888:	4299      	cmp	r1, r3
3230988a:	d1fb      	bne.n	32309884 <__sigtramp+0x58>
3230988c:	e7da      	b.n	32309844 <__sigtramp+0x18>
3230988e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32309892:	bd38      	pop	{r3, r4, r5, pc}

32309894 <_fstat_r>:
32309894:	b538      	push	{r3, r4, r5, lr}
32309896:	f245 343c 	movw	r4, #21308	@ 0x533c
3230989a:	f2c3 2431 	movt	r4, #12849	@ 0x3231
3230989e:	460d      	mov	r5, r1
323098a0:	4603      	mov	r3, r0
323098a2:	4611      	mov	r1, r2
323098a4:	4628      	mov	r0, r5
323098a6:	2200      	movs	r2, #0
323098a8:	461d      	mov	r5, r3
323098aa:	6022      	str	r2, [r4, #0]
323098ac:	f7f6 ed44 	blx	32300338 <_fstat>
323098b0:	1c43      	adds	r3, r0, #1
323098b2:	d000      	beq.n	323098b6 <_fstat_r+0x22>
323098b4:	bd38      	pop	{r3, r4, r5, pc}
323098b6:	6823      	ldr	r3, [r4, #0]
323098b8:	2b00      	cmp	r3, #0
323098ba:	d0fb      	beq.n	323098b4 <_fstat_r+0x20>
323098bc:	602b      	str	r3, [r5, #0]
323098be:	bd38      	pop	{r3, r4, r5, pc}

323098c0 <_isatty_r>:
323098c0:	b538      	push	{r3, r4, r5, lr}
323098c2:	f245 343c 	movw	r4, #21308	@ 0x533c
323098c6:	f2c3 2431 	movt	r4, #12849	@ 0x3231
323098ca:	4605      	mov	r5, r0
323098cc:	4608      	mov	r0, r1
323098ce:	2200      	movs	r2, #0
323098d0:	6022      	str	r2, [r4, #0]
323098d2:	f7f6 ed3a 	blx	32300348 <_isatty>
323098d6:	1c43      	adds	r3, r0, #1
323098d8:	d000      	beq.n	323098dc <_isatty_r+0x1c>
323098da:	bd38      	pop	{r3, r4, r5, pc}
323098dc:	6823      	ldr	r3, [r4, #0]
323098de:	2b00      	cmp	r3, #0
323098e0:	d0fb      	beq.n	323098da <_isatty_r+0x1a>
323098e2:	602b      	str	r3, [r5, #0]
323098e4:	bd38      	pop	{r3, r4, r5, pc}
323098e6:	bf00      	nop

323098e8 <_kill_r>:
323098e8:	b538      	push	{r3, r4, r5, lr}
323098ea:	f245 343c 	movw	r4, #21308	@ 0x533c
323098ee:	f2c3 2431 	movt	r4, #12849	@ 0x3231
323098f2:	460d      	mov	r5, r1
323098f4:	4603      	mov	r3, r0
323098f6:	4611      	mov	r1, r2
323098f8:	4628      	mov	r0, r5
323098fa:	2200      	movs	r2, #0
323098fc:	461d      	mov	r5, r3
323098fe:	6022      	str	r2, [r4, #0]
32309900:	f7f6 ed48 	blx	32300394 <_kill>
32309904:	1c43      	adds	r3, r0, #1
32309906:	d000      	beq.n	3230990a <_kill_r+0x22>
32309908:	bd38      	pop	{r3, r4, r5, pc}
3230990a:	6823      	ldr	r3, [r4, #0]
3230990c:	2b00      	cmp	r3, #0
3230990e:	d0fb      	beq.n	32309908 <_kill_r+0x20>
32309910:	602b      	str	r3, [r5, #0]
32309912:	bd38      	pop	{r3, r4, r5, pc}

32309914 <_getpid_r>:
32309914:	f001 be54 	b.w	3230b5c0 <___getpid_from_thumb>

32309918 <_sbrk_r>:
32309918:	b538      	push	{r3, r4, r5, lr}
3230991a:	f245 343c 	movw	r4, #21308	@ 0x533c
3230991e:	f2c3 2431 	movt	r4, #12849	@ 0x3231
32309922:	4605      	mov	r5, r0
32309924:	4608      	mov	r0, r1
32309926:	2200      	movs	r2, #0
32309928:	6022      	str	r2, [r4, #0]
3230992a:	f7f6 ed1c 	blx	32300364 <_sbrk>
3230992e:	1c43      	adds	r3, r0, #1
32309930:	d000      	beq.n	32309934 <_sbrk_r+0x1c>
32309932:	bd38      	pop	{r3, r4, r5, pc}
32309934:	6823      	ldr	r3, [r4, #0]
32309936:	2b00      	cmp	r3, #0
32309938:	d0fb      	beq.n	32309932 <_sbrk_r+0x1a>
3230993a:	602b      	str	r3, [r5, #0]
3230993c:	bd38      	pop	{r3, r4, r5, pc}
3230993e:	bf00      	nop

32309940 <sysconf>:
32309940:	2808      	cmp	r0, #8
32309942:	d102      	bne.n	3230994a <sysconf+0xa>
32309944:	f44f 5080 	mov.w	r0, #4096	@ 0x1000
32309948:	4770      	bx	lr
3230994a:	b508      	push	{r3, lr}
3230994c:	f7fb f974 	bl	32304c38 <__errno>
32309950:	4603      	mov	r3, r0
32309952:	2216      	movs	r2, #22
32309954:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
32309958:	601a      	str	r2, [r3, #0]
3230995a:	bd08      	pop	{r3, pc}
3230995c:	0000      	movs	r0, r0
	...

32309960 <frexp>:
32309960:	b430      	push	{r4, r5}
32309962:	f64f 7cff 	movw	ip, #65535	@ 0xffff
32309966:	f6c7 7cef 	movt	ip, #32751	@ 0x7fef
3230996a:	b082      	sub	sp, #8
3230996c:	2100      	movs	r1, #0
3230996e:	6001      	str	r1, [r0, #0]
32309970:	ed8d 0b00 	vstr	d0, [sp]
32309974:	9a01      	ldr	r2, [sp, #4]
32309976:	f022 4300 	bic.w	r3, r2, #2147483648	@ 0x80000000
3230997a:	4563      	cmp	r3, ip
3230997c:	d821      	bhi.n	323099c2 <frexp+0x62>
3230997e:	9c00      	ldr	r4, [sp, #0]
32309980:	431c      	orrs	r4, r3
32309982:	d01e      	beq.n	323099c2 <frexp+0x62>
32309984:	460c      	mov	r4, r1
32309986:	f6c7 74f0 	movt	r4, #32752	@ 0x7ff0
3230998a:	4014      	ands	r4, r2
3230998c:	b954      	cbnz	r4, 323099a4 <frexp+0x44>
3230998e:	eddf 0b10 	vldr	d16, [pc, #64]	@ 323099d0 <frexp+0x70>
32309992:	f06f 0135 	mvn.w	r1, #53	@ 0x35
32309996:	ee60 0b20 	vmul.f64	d16, d0, d16
3230999a:	edcd 0b00 	vstr	d16, [sp]
3230999e:	9a01      	ldr	r2, [sp, #4]
323099a0:	f022 4300 	bic.w	r3, r2, #2147483648	@ 0x80000000
323099a4:	151b      	asrs	r3, r3, #20
323099a6:	f36f 521e 	bfc	r2, #20, #11
323099aa:	e9dd 4500 	ldrd	r4, r5, [sp]
323099ae:	f2a3 33fe 	subw	r3, r3, #1022	@ 0x3fe
323099b2:	f042 557f 	orr.w	r5, r2, #1069547520	@ 0x3fc00000
323099b6:	440b      	add	r3, r1
323099b8:	f445 1500 	orr.w	r5, r5, #2097152	@ 0x200000
323099bc:	6003      	str	r3, [r0, #0]
323099be:	e9cd 4500 	strd	r4, r5, [sp]
323099c2:	ed9d 0b00 	vldr	d0, [sp]
323099c6:	b002      	add	sp, #8
323099c8:	bc30      	pop	{r4, r5}
323099ca:	4770      	bx	lr
323099cc:	f3af 8000 	nop.w
323099d0:	00000000 	.word	0x00000000
323099d4:	43500000 	.word	0x43500000

323099d8 <quorem>:
323099d8:	6903      	ldr	r3, [r0, #16]
323099da:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
323099de:	690d      	ldr	r5, [r1, #16]
323099e0:	b085      	sub	sp, #20
323099e2:	42ab      	cmp	r3, r5
323099e4:	bfb8      	it	lt
323099e6:	2000      	movlt	r0, #0
323099e8:	f2c0 808b 	blt.w	32309b02 <quorem+0x12a>
323099ec:	3d01      	subs	r5, #1
323099ee:	f101 0414 	add.w	r4, r1, #20
323099f2:	f100 0814 	add.w	r8, r0, #20
323099f6:	4681      	mov	r9, r0
323099f8:	ea4f 0c85 	mov.w	ip, r5, lsl #2
323099fc:	f854 3025 	ldr.w	r3, [r4, r5, lsl #2]
32309a00:	eb04 070c 	add.w	r7, r4, ip
32309a04:	f858 2025 	ldr.w	r2, [r8, r5, lsl #2]
32309a08:	eb08 0b0c 	add.w	fp, r8, ip
32309a0c:	3301      	adds	r3, #1
32309a0e:	429a      	cmp	r2, r3
32309a10:	fbb2 f6f3 	udiv	r6, r2, r3
32309a14:	d341      	bcc.n	32309a9a <quorem+0xc2>
32309a16:	2000      	movs	r0, #0
32309a18:	46a2      	mov	sl, r4
32309a1a:	46c6      	mov	lr, r8
32309a1c:	e9cd c401 	strd	ip, r4, [sp, #4]
32309a20:	f8cd 800c 	str.w	r8, [sp, #12]
32309a24:	4603      	mov	r3, r0
32309a26:	4604      	mov	r4, r0
32309a28:	4688      	mov	r8, r1
32309a2a:	f85a 2b04 	ldr.w	r2, [sl], #4
32309a2e:	f8de 1000 	ldr.w	r1, [lr]
32309a32:	4557      	cmp	r7, sl
32309a34:	b290      	uxth	r0, r2
32309a36:	ea4f 4c12 	mov.w	ip, r2, lsr #16
32309a3a:	b28a      	uxth	r2, r1
32309a3c:	fb06 4000 	mla	r0, r6, r0, r4
32309a40:	ea4f 4410 	mov.w	r4, r0, lsr #16
32309a44:	b280      	uxth	r0, r0
32309a46:	eba2 0200 	sub.w	r2, r2, r0
32309a4a:	441a      	add	r2, r3
32309a4c:	fb06 440c 	mla	r4, r6, ip, r4
32309a50:	b2a3      	uxth	r3, r4
32309a52:	ea4f 4414 	mov.w	r4, r4, lsr #16
32309a56:	ebc3 4322 	rsb	r3, r3, r2, asr #16
32309a5a:	b292      	uxth	r2, r2
32309a5c:	eb03 4311 	add.w	r3, r3, r1, lsr #16
32309a60:	ea42 4203 	orr.w	r2, r2, r3, lsl #16
32309a64:	ea4f 4323 	mov.w	r3, r3, asr #16
32309a68:	f84e 2b04 	str.w	r2, [lr], #4
32309a6c:	d2dd      	bcs.n	32309a2a <quorem+0x52>
32309a6e:	e9dd c401 	ldrd	ip, r4, [sp, #4]
32309a72:	4641      	mov	r1, r8
32309a74:	f8dd 800c 	ldr.w	r8, [sp, #12]
32309a78:	f858 300c 	ldr.w	r3, [r8, ip]
32309a7c:	b96b      	cbnz	r3, 32309a9a <quorem+0xc2>
32309a7e:	f1ab 0b04 	sub.w	fp, fp, #4
32309a82:	45d8      	cmp	r8, fp
32309a84:	d303      	bcc.n	32309a8e <quorem+0xb6>
32309a86:	e006      	b.n	32309a96 <quorem+0xbe>
32309a88:	3d01      	subs	r5, #1
32309a8a:	45d8      	cmp	r8, fp
32309a8c:	d203      	bcs.n	32309a96 <quorem+0xbe>
32309a8e:	f85b 3904 	ldr.w	r3, [fp], #-4
32309a92:	2b00      	cmp	r3, #0
32309a94:	d0f8      	beq.n	32309a88 <quorem+0xb0>
32309a96:	f8c9 5010 	str.w	r5, [r9, #16]
32309a9a:	4648      	mov	r0, r9
32309a9c:	f001 fa46 	bl	3230af2c <__mcmp>
32309aa0:	2800      	cmp	r0, #0
32309aa2:	db2d      	blt.n	32309b00 <quorem+0x128>
32309aa4:	2200      	movs	r2, #0
32309aa6:	4641      	mov	r1, r8
32309aa8:	4694      	mov	ip, r2
32309aaa:	f854 0b04 	ldr.w	r0, [r4], #4
32309aae:	680b      	ldr	r3, [r1, #0]
32309ab0:	42a7      	cmp	r7, r4
32309ab2:	fa1f fe80 	uxth.w	lr, r0
32309ab6:	ea4f 4010 	mov.w	r0, r0, lsr #16
32309aba:	b29a      	uxth	r2, r3
32309abc:	eba2 020e 	sub.w	r2, r2, lr
32309ac0:	4462      	add	r2, ip
32309ac2:	ebc0 4022 	rsb	r0, r0, r2, asr #16
32309ac6:	b292      	uxth	r2, r2
32309ac8:	eb00 4013 	add.w	r0, r0, r3, lsr #16
32309acc:	ea42 4200 	orr.w	r2, r2, r0, lsl #16
32309ad0:	ea4f 4c20 	mov.w	ip, r0, asr #16
32309ad4:	f841 2b04 	str.w	r2, [r1], #4
32309ad8:	d2e7      	bcs.n	32309aaa <quorem+0xd2>
32309ada:	f858 2025 	ldr.w	r2, [r8, r5, lsl #2]
32309ade:	eb08 0385 	add.w	r3, r8, r5, lsl #2
32309ae2:	b962      	cbnz	r2, 32309afe <quorem+0x126>
32309ae4:	3b04      	subs	r3, #4
32309ae6:	4543      	cmp	r3, r8
32309ae8:	d803      	bhi.n	32309af2 <quorem+0x11a>
32309aea:	e006      	b.n	32309afa <quorem+0x122>
32309aec:	3d01      	subs	r5, #1
32309aee:	4598      	cmp	r8, r3
32309af0:	d203      	bcs.n	32309afa <quorem+0x122>
32309af2:	f853 2904 	ldr.w	r2, [r3], #-4
32309af6:	2a00      	cmp	r2, #0
32309af8:	d0f8      	beq.n	32309aec <quorem+0x114>
32309afa:	f8c9 5010 	str.w	r5, [r9, #16]
32309afe:	3601      	adds	r6, #1
32309b00:	4630      	mov	r0, r6
32309b02:	b005      	add	sp, #20
32309b04:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}

32309b08 <_dtoa_r>:
32309b08:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
32309b0c:	ec57 6b10 	vmov	r6, r7, d0
32309b10:	4604      	mov	r4, r0
32309b12:	ed2d 8b02 	vpush	{d8}
32309b16:	b08f      	sub	sp, #60	@ 0x3c
32309b18:	4692      	mov	sl, r2
32309b1a:	9101      	str	r1, [sp, #4]
32309b1c:	6b81      	ldr	r1, [r0, #56]	@ 0x38
32309b1e:	9d1a      	ldr	r5, [sp, #104]	@ 0x68
32309b20:	9306      	str	r3, [sp, #24]
32309b22:	ed8d 0b02 	vstr	d0, [sp, #8]
32309b26:	b141      	cbz	r1, 32309b3a <_dtoa_r+0x32>
32309b28:	6bc2      	ldr	r2, [r0, #60]	@ 0x3c
32309b2a:	2301      	movs	r3, #1
32309b2c:	604a      	str	r2, [r1, #4]
32309b2e:	4093      	lsls	r3, r2
32309b30:	608b      	str	r3, [r1, #8]
32309b32:	f000 fefd 	bl	3230a930 <_Bfree>
32309b36:	2300      	movs	r3, #0
32309b38:	63a3      	str	r3, [r4, #56]	@ 0x38
32309b3a:	f1b7 0800 	subs.w	r8, r7, #0
32309b3e:	bfa8      	it	ge
32309b40:	2300      	movge	r3, #0
32309b42:	da04      	bge.n	32309b4e <_dtoa_r+0x46>
32309b44:	2301      	movs	r3, #1
32309b46:	f028 4800 	bic.w	r8, r8, #2147483648	@ 0x80000000
32309b4a:	f8cd 800c 	str.w	r8, [sp, #12]
32309b4e:	602b      	str	r3, [r5, #0]
32309b50:	2300      	movs	r3, #0
32309b52:	f6c7 73f0 	movt	r3, #32752	@ 0x7ff0
32309b56:	ea33 0308 	bics.w	r3, r3, r8
32309b5a:	f000 8092 	beq.w	32309c82 <_dtoa_r+0x17a>
32309b5e:	ed9d 8b02 	vldr	d8, [sp, #8]
32309b62:	eeb5 8b40 	vcmp.f64	d8, #0.0
32309b66:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32309b6a:	d111      	bne.n	32309b90 <_dtoa_r+0x88>
32309b6c:	9a06      	ldr	r2, [sp, #24]
32309b6e:	2301      	movs	r3, #1
32309b70:	6013      	str	r3, [r2, #0]
32309b72:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32309b74:	b113      	cbz	r3, 32309b7c <_dtoa_r+0x74>
32309b76:	9a1b      	ldr	r2, [sp, #108]	@ 0x6c
32309b78:	4bc5      	ldr	r3, [pc, #788]	@ (32309e90 <_dtoa_r+0x388>)
32309b7a:	6013      	str	r3, [r2, #0]
32309b7c:	f64b 274c 	movw	r7, #47692	@ 0xba4c
32309b80:	f2c3 2730 	movt	r7, #12848	@ 0x3230
32309b84:	4638      	mov	r0, r7
32309b86:	b00f      	add	sp, #60	@ 0x3c
32309b88:	ecbd 8b02 	vpop	{d8}
32309b8c:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32309b90:	aa0c      	add	r2, sp, #48	@ 0x30
32309b92:	eeb0 0b48 	vmov.f64	d0, d8
32309b96:	a90d      	add	r1, sp, #52	@ 0x34
32309b98:	4620      	mov	r0, r4
32309b9a:	f001 fb3d 	bl	3230b218 <__d2b>
32309b9e:	9a0c      	ldr	r2, [sp, #48]	@ 0x30
32309ba0:	4681      	mov	r9, r0
32309ba2:	ea5f 5318 	movs.w	r3, r8, lsr #20
32309ba6:	f040 8086 	bne.w	32309cb6 <_dtoa_r+0x1ae>
32309baa:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32309bac:	4413      	add	r3, r2
32309bae:	f203 4132 	addw	r1, r3, #1074	@ 0x432
32309bb2:	2920      	cmp	r1, #32
32309bb4:	f340 8173 	ble.w	32309e9e <_dtoa_r+0x396>
32309bb8:	f1c1 0140 	rsb	r1, r1, #64	@ 0x40
32309bbc:	fa08 f801 	lsl.w	r8, r8, r1
32309bc0:	f203 4112 	addw	r1, r3, #1042	@ 0x412
32309bc4:	fa26 f101 	lsr.w	r1, r6, r1
32309bc8:	ea48 0101 	orr.w	r1, r8, r1
32309bcc:	ee07 1a10 	vmov	s14, r1
32309bd0:	eeb8 7b47 	vcvt.f64.u32	d7, s14
32309bd4:	3b01      	subs	r3, #1
32309bd6:	f04f 0801 	mov.w	r8, #1
32309bda:	ee17 1a90 	vmov	r1, s15
32309bde:	f1a1 71f8 	sub.w	r1, r1, #32505856	@ 0x1f00000
32309be2:	ee07 1a90 	vmov	s15, r1
32309be6:	eef7 4b08 	vmov.f64	d20, #120	@ 0x3fc00000  1.5
32309bea:	eddf 3ba3 	vldr	d19, [pc, #652]	@ 32309e78 <_dtoa_r+0x370>
32309bee:	ee06 3a90 	vmov	s13, r3
32309bf2:	ee37 7b64 	vsub.f64	d7, d7, d20
32309bf6:	eddf 0ba2 	vldr	d16, [pc, #648]	@ 32309e80 <_dtoa_r+0x378>
32309bfa:	eef8 2be6 	vcvt.f64.s32	d18, s13
32309bfe:	eddf 1ba2 	vldr	d17, [pc, #648]	@ 32309e88 <_dtoa_r+0x380>
32309c02:	eee7 0b23 	vfma.f64	d16, d7, d19
32309c06:	eee2 0ba1 	vfma.f64	d16, d18, d17
32309c0a:	eef5 0bc0 	vcmpe.f64	d16, #0.0
32309c0e:	eefd 7be0 	vcvt.s32.f64	s15, d16
32309c12:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32309c16:	edcd 7a04 	vstr	s15, [sp, #16]
32309c1a:	f100 811c 	bmi.w	32309e56 <_dtoa_r+0x34e>
32309c1e:	9904      	ldr	r1, [sp, #16]
32309c20:	1ad3      	subs	r3, r2, r3
32309c22:	1e5d      	subs	r5, r3, #1
32309c24:	2916      	cmp	r1, #22
32309c26:	f200 8104 	bhi.w	32309e32 <_dtoa_r+0x32a>
32309c2a:	f64b 7238 	movw	r2, #48952	@ 0xbf38
32309c2e:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32309c32:	eb02 02c1 	add.w	r2, r2, r1, lsl #3
32309c36:	edd2 0b00 	vldr	d16, [r2]
32309c3a:	eeb4 8be0 	vcmpe.f64	d8, d16
32309c3e:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32309c42:	f100 8133 	bmi.w	32309eac <_dtoa_r+0x3a4>
32309c46:	2b00      	cmp	r3, #0
32309c48:	f340 84d9 	ble.w	3230a5fe <_dtoa_r+0xaf6>
32309c4c:	440d      	add	r5, r1
32309c4e:	2300      	movs	r3, #0
32309c50:	e9cd 1309 	strd	r1, r3, [sp, #36]	@ 0x24
32309c54:	9307      	str	r3, [sp, #28]
32309c56:	2300      	movs	r3, #0
32309c58:	9308      	str	r3, [sp, #32]
32309c5a:	9b01      	ldr	r3, [sp, #4]
32309c5c:	2b09      	cmp	r3, #9
32309c5e:	d844      	bhi.n	32309cea <_dtoa_r+0x1e2>
32309c60:	2b05      	cmp	r3, #5
32309c62:	bfd8      	it	le
32309c64:	2601      	movle	r6, #1
32309c66:	dd02      	ble.n	32309c6e <_dtoa_r+0x166>
32309c68:	2600      	movs	r6, #0
32309c6a:	3b04      	subs	r3, #4
32309c6c:	9301      	str	r3, [sp, #4]
32309c6e:	9b01      	ldr	r3, [sp, #4]
32309c70:	3b02      	subs	r3, #2
32309c72:	2b03      	cmp	r3, #3
32309c74:	d83b      	bhi.n	32309cee <_dtoa_r+0x1e6>
32309c76:	e8df f013 	tbh	[pc, r3, lsl #1]
32309c7a:	0215      	.short	0x0215
32309c7c:	02070212 	.word	0x02070212
32309c80:	011f      	.short	0x011f
32309c82:	9a06      	ldr	r2, [sp, #24]
32309c84:	f3c8 0813 	ubfx	r8, r8, #0, #20
32309c88:	f242 730f 	movw	r3, #9999	@ 0x270f
32309c8c:	ea58 0806 	orrs.w	r8, r8, r6
32309c90:	6013      	str	r3, [r2, #0]
32309c92:	d01f      	beq.n	32309cd4 <_dtoa_r+0x1cc>
32309c94:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32309c96:	f64b 275c 	movw	r7, #47708	@ 0xba5c
32309c9a:	f2c3 2730 	movt	r7, #12848	@ 0x3230
32309c9e:	2b00      	cmp	r3, #0
32309ca0:	f43f af70 	beq.w	32309b84 <_dtoa_r+0x7c>
32309ca4:	1cfb      	adds	r3, r7, #3
32309ca6:	9a1b      	ldr	r2, [sp, #108]	@ 0x6c
32309ca8:	4638      	mov	r0, r7
32309caa:	6013      	str	r3, [r2, #0]
32309cac:	b00f      	add	sp, #60	@ 0x3c
32309cae:	ecbd 8b02 	vpop	{d8}
32309cb2:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
32309cb6:	ee18 1a90 	vmov	r1, s17
32309cba:	eeb0 7b48 	vmov.f64	d7, d8
32309cbe:	f2a3 33ff 	subw	r3, r3, #1023	@ 0x3ff
32309cc2:	f04f 0800 	mov.w	r8, #0
32309cc6:	f3c1 0113 	ubfx	r1, r1, #0, #20
32309cca:	f041 517f 	orr.w	r1, r1, #1069547520	@ 0x3fc00000
32309cce:	f441 1140 	orr.w	r1, r1, #3145728	@ 0x300000
32309cd2:	e786      	b.n	32309be2 <_dtoa_r+0xda>
32309cd4:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
32309cd6:	f64b 2750 	movw	r7, #47696	@ 0xba50
32309cda:	f2c3 2730 	movt	r7, #12848	@ 0x3230
32309cde:	2b00      	cmp	r3, #0
32309ce0:	f43f af50 	beq.w	32309b84 <_dtoa_r+0x7c>
32309ce4:	f107 0308 	add.w	r3, r7, #8
32309ce8:	e7dd      	b.n	32309ca6 <_dtoa_r+0x19e>
32309cea:	2300      	movs	r3, #0
32309cec:	9301      	str	r3, [sp, #4]
32309cee:	2100      	movs	r1, #0
32309cf0:	4620      	mov	r0, r4
32309cf2:	63e1      	str	r1, [r4, #60]	@ 0x3c
32309cf4:	f000 fdf2 	bl	3230a8dc <_Balloc>
32309cf8:	4607      	mov	r7, r0
32309cfa:	2800      	cmp	r0, #0
32309cfc:	f000 8584 	beq.w	3230a808 <_dtoa_r+0xd00>
32309d00:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
32309d02:	9904      	ldr	r1, [sp, #16]
32309d04:	43da      	mvns	r2, r3
32309d06:	63a7      	str	r7, [r4, #56]	@ 0x38
32309d08:	290e      	cmp	r1, #14
32309d0a:	ea4f 72d2 	mov.w	r2, r2, lsr #31
32309d0e:	bfc8      	it	gt
32309d10:	2200      	movgt	r2, #0
32309d12:	2a00      	cmp	r2, #0
32309d14:	f040 84dc 	bne.w	3230a6d0 <_dtoa_r+0xbc8>
32309d18:	4692      	mov	sl, r2
32309d1a:	f04f 3bff 	mov.w	fp, #4294967295	@ 0xffffffff
32309d1e:	f8cd b02c 	str.w	fp, [sp, #44]	@ 0x2c
32309d22:	f203 4333 	addw	r3, r3, #1075	@ 0x433
32309d26:	f1b8 0f00 	cmp.w	r8, #0
32309d2a:	f000 8217 	beq.w	3230a15c <_dtoa_r+0x654>
32309d2e:	9a07      	ldr	r2, [sp, #28]
32309d30:	441d      	add	r5, r3
32309d32:	4616      	mov	r6, r2
32309d34:	441a      	add	r2, r3
32309d36:	9b08      	ldr	r3, [sp, #32]
32309d38:	9207      	str	r2, [sp, #28]
32309d3a:	9305      	str	r3, [sp, #20]
32309d3c:	2101      	movs	r1, #1
32309d3e:	4620      	mov	r0, r4
32309d40:	f000 ff22 	bl	3230ab88 <__i2b>
32309d44:	2e00      	cmp	r6, #0
32309d46:	bf18      	it	ne
32309d48:	2d00      	cmpne	r5, #0
32309d4a:	4680      	mov	r8, r0
32309d4c:	f300 8465 	bgt.w	3230a61a <_dtoa_r+0xb12>
32309d50:	9b08      	ldr	r3, [sp, #32]
32309d52:	2b00      	cmp	r3, #0
32309d54:	f040 846e 	bne.w	3230a634 <_dtoa_r+0xb2c>
32309d58:	2301      	movs	r3, #1
32309d5a:	9308      	str	r3, [sp, #32]
32309d5c:	2101      	movs	r1, #1
32309d5e:	4620      	mov	r0, r4
32309d60:	f000 ff12 	bl	3230ab88 <__i2b>
32309d64:	9b09      	ldr	r3, [sp, #36]	@ 0x24
32309d66:	9005      	str	r0, [sp, #20]
32309d68:	2b00      	cmp	r3, #0
32309d6a:	f040 82a2 	bne.w	3230a2b2 <_dtoa_r+0x7aa>
32309d6e:	9b01      	ldr	r3, [sp, #4]
32309d70:	2b01      	cmp	r3, #1
32309d72:	f340 82d1 	ble.w	3230a318 <_dtoa_r+0x810>
32309d76:	2301      	movs	r3, #1
32309d78:	442b      	add	r3, r5
32309d7a:	f013 031f 	ands.w	r3, r3, #31
32309d7e:	f000 8241 	beq.w	3230a204 <_dtoa_r+0x6fc>
32309d82:	f1c3 0220 	rsb	r2, r3, #32
32309d86:	2a04      	cmp	r2, #4
32309d88:	f340 8414 	ble.w	3230a5b4 <_dtoa_r+0xaac>
32309d8c:	f1c3 031c 	rsb	r3, r3, #28
32309d90:	9a07      	ldr	r2, [sp, #28]
32309d92:	441e      	add	r6, r3
32309d94:	441d      	add	r5, r3
32309d96:	441a      	add	r2, r3
32309d98:	9207      	str	r2, [sp, #28]
32309d9a:	9b07      	ldr	r3, [sp, #28]
32309d9c:	2b00      	cmp	r3, #0
32309d9e:	dd05      	ble.n	32309dac <_dtoa_r+0x2a4>
32309da0:	4649      	mov	r1, r9
32309da2:	461a      	mov	r2, r3
32309da4:	4620      	mov	r0, r4
32309da6:	f001 f84d 	bl	3230ae44 <__lshift>
32309daa:	4681      	mov	r9, r0
32309dac:	2d00      	cmp	r5, #0
32309dae:	dd05      	ble.n	32309dbc <_dtoa_r+0x2b4>
32309db0:	9905      	ldr	r1, [sp, #20]
32309db2:	462a      	mov	r2, r5
32309db4:	4620      	mov	r0, r4
32309db6:	f001 f845 	bl	3230ae44 <__lshift>
32309dba:	9005      	str	r0, [sp, #20]
32309dbc:	9b01      	ldr	r3, [sp, #4]
32309dbe:	2b02      	cmp	r3, #2
32309dc0:	bfd8      	it	le
32309dc2:	2300      	movle	r3, #0
32309dc4:	bfc8      	it	gt
32309dc6:	2301      	movgt	r3, #1
32309dc8:	9307      	str	r3, [sp, #28]
32309dca:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32309dcc:	2b00      	cmp	r3, #0
32309dce:	f040 824d 	bne.w	3230a26c <_dtoa_r+0x764>
32309dd2:	9d07      	ldr	r5, [sp, #28]
32309dd4:	f1bb 0f00 	cmp.w	fp, #0
32309dd8:	f005 0501 	and.w	r5, r5, #1
32309ddc:	bfc8      	it	gt
32309dde:	2500      	movgt	r5, #0
32309de0:	2d00      	cmp	r5, #0
32309de2:	f000 8162 	beq.w	3230a0aa <_dtoa_r+0x5a2>
32309de6:	f1bb 0f00 	cmp.w	fp, #0
32309dea:	f040 8234 	bne.w	3230a256 <_dtoa_r+0x74e>
32309dee:	9905      	ldr	r1, [sp, #20]
32309df0:	465b      	mov	r3, fp
32309df2:	2205      	movs	r2, #5
32309df4:	4620      	mov	r0, r4
32309df6:	f000 fda5 	bl	3230a944 <__multadd>
32309dfa:	4601      	mov	r1, r0
32309dfc:	9005      	str	r0, [sp, #20]
32309dfe:	4648      	mov	r0, r9
32309e00:	f001 f894 	bl	3230af2c <__mcmp>
32309e04:	2800      	cmp	r0, #0
32309e06:	f340 8226 	ble.w	3230a256 <_dtoa_r+0x74e>
32309e0a:	9e04      	ldr	r6, [sp, #16]
32309e0c:	46bb      	mov	fp, r7
32309e0e:	2331      	movs	r3, #49	@ 0x31
32309e10:	3601      	adds	r6, #1
32309e12:	f80b 3b01 	strb.w	r3, [fp], #1
32309e16:	9905      	ldr	r1, [sp, #20]
32309e18:	4620      	mov	r0, r4
32309e1a:	3601      	adds	r6, #1
32309e1c:	f000 fd88 	bl	3230a930 <_Bfree>
32309e20:	f1b8 0f00 	cmp.w	r8, #0
32309e24:	f000 811b 	beq.w	3230a05e <_dtoa_r+0x556>
32309e28:	4641      	mov	r1, r8
32309e2a:	4620      	mov	r0, r4
32309e2c:	f000 fd80 	bl	3230a930 <_Bfree>
32309e30:	e115      	b.n	3230a05e <_dtoa_r+0x556>
32309e32:	2201      	movs	r2, #1
32309e34:	920a      	str	r2, [sp, #40]	@ 0x28
32309e36:	2d00      	cmp	r5, #0
32309e38:	db2c      	blt.n	32309e94 <_dtoa_r+0x38c>
32309e3a:	2300      	movs	r3, #0
32309e3c:	9307      	str	r3, [sp, #28]
32309e3e:	9b04      	ldr	r3, [sp, #16]
32309e40:	2b00      	cmp	r3, #0
32309e42:	da15      	bge.n	32309e70 <_dtoa_r+0x368>
32309e44:	9a07      	ldr	r2, [sp, #28]
32309e46:	9b04      	ldr	r3, [sp, #16]
32309e48:	1ad2      	subs	r2, r2, r3
32309e4a:	425b      	negs	r3, r3
32309e4c:	9207      	str	r2, [sp, #28]
32309e4e:	9308      	str	r3, [sp, #32]
32309e50:	2300      	movs	r3, #0
32309e52:	9309      	str	r3, [sp, #36]	@ 0x24
32309e54:	e701      	b.n	32309c5a <_dtoa_r+0x152>
32309e56:	eef8 1be7 	vcvt.f64.s32	d17, s15
32309e5a:	eef4 1b60 	vcmp.f64	d17, d16
32309e5e:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32309e62:	f43f aedc 	beq.w	32309c1e <_dtoa_r+0x116>
32309e66:	ee17 1a90 	vmov	r1, s15
32309e6a:	3901      	subs	r1, #1
32309e6c:	9104      	str	r1, [sp, #16]
32309e6e:	e6d6      	b.n	32309c1e <_dtoa_r+0x116>
32309e70:	441d      	add	r5, r3
32309e72:	9309      	str	r3, [sp, #36]	@ 0x24
32309e74:	e6ef      	b.n	32309c56 <_dtoa_r+0x14e>
32309e76:	bf00      	nop
32309e78:	636f4361 	.word	0x636f4361
32309e7c:	3fd287a7 	.word	0x3fd287a7
32309e80:	8b60c8b3 	.word	0x8b60c8b3
32309e84:	3fc68a28 	.word	0x3fc68a28
32309e88:	509f79fb 	.word	0x509f79fb
32309e8c:	3fd34413 	.word	0x3fd34413
32309e90:	3230ba4d 	.word	0x3230ba4d
32309e94:	f1c3 0301 	rsb	r3, r3, #1
32309e98:	2500      	movs	r5, #0
32309e9a:	9307      	str	r3, [sp, #28]
32309e9c:	e7cf      	b.n	32309e3e <_dtoa_r+0x336>
32309e9e:	f1c1 0120 	rsb	r1, r1, #32
32309ea2:	fa06 f101 	lsl.w	r1, r6, r1
32309ea6:	ee07 1a10 	vmov	s14, r1
32309eaa:	e691      	b.n	32309bd0 <_dtoa_r+0xc8>
32309eac:	9a04      	ldr	r2, [sp, #16]
32309eae:	3a01      	subs	r2, #1
32309eb0:	9204      	str	r2, [sp, #16]
32309eb2:	2200      	movs	r2, #0
32309eb4:	920a      	str	r2, [sp, #40]	@ 0x28
32309eb6:	e7be      	b.n	32309e36 <_dtoa_r+0x32e>
32309eb8:	2301      	movs	r3, #1
32309eba:	9305      	str	r3, [sp, #20]
32309ebc:	9b04      	ldr	r3, [sp, #16]
32309ebe:	4453      	add	r3, sl
32309ec0:	930b      	str	r3, [sp, #44]	@ 0x2c
32309ec2:	f103 0b01 	add.w	fp, r3, #1
32309ec6:	465f      	mov	r7, fp
32309ec8:	2f01      	cmp	r7, #1
32309eca:	bfb8      	it	lt
32309ecc:	2701      	movlt	r7, #1
32309ece:	2f17      	cmp	r7, #23
32309ed0:	bfc8      	it	gt
32309ed2:	2201      	movgt	r2, #1
32309ed4:	bfc8      	it	gt
32309ed6:	2304      	movgt	r3, #4
32309ed8:	f340 84e2 	ble.w	3230a8a0 <_dtoa_r+0xd98>
32309edc:	005b      	lsls	r3, r3, #1
32309ede:	4611      	mov	r1, r2
32309ee0:	f103 0014 	add.w	r0, r3, #20
32309ee4:	3201      	adds	r2, #1
32309ee6:	42b8      	cmp	r0, r7
32309ee8:	d9f8      	bls.n	32309edc <_dtoa_r+0x3d4>
32309eea:	63e1      	str	r1, [r4, #60]	@ 0x3c
32309eec:	4620      	mov	r0, r4
32309eee:	f000 fcf5 	bl	3230a8dc <_Balloc>
32309ef2:	4607      	mov	r7, r0
32309ef4:	2800      	cmp	r0, #0
32309ef6:	f000 8487 	beq.w	3230a808 <_dtoa_r+0xd00>
32309efa:	f1bb 0f0e 	cmp.w	fp, #14
32309efe:	f006 0601 	and.w	r6, r6, #1
32309f02:	63a0      	str	r0, [r4, #56]	@ 0x38
32309f04:	bf88      	it	hi
32309f06:	2600      	movhi	r6, #0
32309f08:	2e00      	cmp	r6, #0
32309f0a:	f000 8150 	beq.w	3230a1ae <_dtoa_r+0x6a6>
32309f0e:	9904      	ldr	r1, [sp, #16]
32309f10:	2900      	cmp	r1, #0
32309f12:	f340 8179 	ble.w	3230a208 <_dtoa_r+0x700>
32309f16:	f001 030f 	and.w	r3, r1, #15
32309f1a:	f64b 7238 	movw	r2, #48952	@ 0xbf38
32309f1e:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32309f22:	eb02 03c3 	add.w	r3, r2, r3, lsl #3
32309f26:	05ca      	lsls	r2, r1, #23
32309f28:	edd3 1b00 	vldr	d17, [r3]
32309f2c:	ea4f 1321 	mov.w	r3, r1, asr #4
32309f30:	f140 81d5 	bpl.w	3230a2de <_dtoa_r+0x7d6>
32309f34:	f64b 7210 	movw	r2, #48912	@ 0xbf10
32309f38:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32309f3c:	f003 030f 	and.w	r3, r3, #15
32309f40:	2103      	movs	r1, #3
32309f42:	edd2 0b08 	vldr	d16, [r2, #32]
32309f46:	eec8 2b20 	vdiv.f64	d18, d8, d16
32309f4a:	b16b      	cbz	r3, 32309f68 <_dtoa_r+0x460>
32309f4c:	f64b 7210 	movw	r2, #48912	@ 0xbf10
32309f50:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32309f54:	07de      	lsls	r6, r3, #31
32309f56:	f140 8105 	bpl.w	3230a164 <_dtoa_r+0x65c>
32309f5a:	ecf2 0b02 	vldmia	r2!, {d16}
32309f5e:	3101      	adds	r1, #1
32309f60:	105b      	asrs	r3, r3, #1
32309f62:	ee61 1ba0 	vmul.f64	d17, d17, d16
32309f66:	d1f5      	bne.n	32309f54 <_dtoa_r+0x44c>
32309f68:	eec2 0ba1 	vdiv.f64	d16, d18, d17
32309f6c:	9b0a      	ldr	r3, [sp, #40]	@ 0x28
32309f6e:	b13b      	cbz	r3, 32309f80 <_dtoa_r+0x478>
32309f70:	eef7 1b00 	vmov.f64	d17, #112	@ 0x3f800000  1.0
32309f74:	eef4 0be1 	vcmpe.f64	d16, d17
32309f78:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32309f7c:	f100 8320 	bmi.w	3230a5c0 <_dtoa_r+0xab8>
32309f80:	ee07 1a90 	vmov	s15, r1
32309f84:	eef8 1be7 	vcvt.f64.s32	d17, s15
32309f88:	eeb1 7b0c 	vmov.f64	d7, #28	@ 0x40e00000  7.0
32309f8c:	eea1 7ba0 	vfma.f64	d7, d17, d16
32309f90:	ee17 1a90 	vmov	r1, s15
32309f94:	ec53 2b17 	vmov	r2, r3, d7
32309f98:	f1a1 7350 	sub.w	r3, r1, #54525952	@ 0x3400000
32309f9c:	f1bb 0f00 	cmp.w	fp, #0
32309fa0:	f000 80f1 	beq.w	3230a186 <_dtoa_r+0x67e>
32309fa4:	f8dd e010 	ldr.w	lr, [sp, #16]
32309fa8:	465e      	mov	r6, fp
32309faa:	eefd 7be0 	vcvt.s32.f64	s15, d16
32309fae:	ec43 2b32 	vmov	d18, r2, r3
32309fb2:	9805      	ldr	r0, [sp, #20]
32309fb4:	f64b 7238 	movw	r2, #48952	@ 0xbf38
32309fb8:	f2c3 2230 	movt	r2, #12848	@ 0x3230
32309fbc:	eb02 03c6 	add.w	r3, r2, r6, lsl #3
32309fc0:	ee17 1a90 	vmov	r1, s15
32309fc4:	eef8 1be7 	vcvt.f64.s32	d17, s15
32309fc8:	ed53 3b02 	vldr	d19, [r3, #-8]
32309fcc:	1c7b      	adds	r3, r7, #1
32309fce:	3130      	adds	r1, #48	@ 0x30
32309fd0:	ee70 0be1 	vsub.f64	d16, d16, d17
32309fd4:	b2c9      	uxtb	r1, r1
32309fd6:	7039      	strb	r1, [r7, #0]
32309fd8:	2800      	cmp	r0, #0
32309fda:	f000 81be 	beq.w	3230a35a <_dtoa_r+0x852>
32309fde:	eef6 4b00 	vmov.f64	d20, #96	@ 0x3f000000  0.5
32309fe2:	eec4 1ba3 	vdiv.f64	d17, d20, d19
32309fe6:	ee71 1be2 	vsub.f64	d17, d17, d18
32309fea:	eef4 1be0 	vcmpe.f64	d17, d16
32309fee:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
32309ff2:	f300 838f 	bgt.w	3230a714 <_dtoa_r+0xc0c>
32309ff6:	2000      	movs	r0, #0
32309ff8:	eef7 4b00 	vmov.f64	d20, #112	@ 0x3f800000  1.0
32309ffc:	eef2 3b04 	vmov.f64	d19, #36	@ 0x41200000  10.0
3230a000:	e018      	b.n	3230a034 <_dtoa_r+0x52c>
3230a002:	3001      	adds	r0, #1
3230a004:	42b0      	cmp	r0, r6
3230a006:	f280 83a4 	bge.w	3230a752 <_dtoa_r+0xc4a>
3230a00a:	ee60 0ba3 	vmul.f64	d16, d16, d19
3230a00e:	ee61 1ba3 	vmul.f64	d17, d17, d19
3230a012:	eefd 7be0 	vcvt.s32.f64	s15, d16
3230a016:	eef8 2be7 	vcvt.f64.s32	d18, s15
3230a01a:	ee17 1a90 	vmov	r1, s15
3230a01e:	ee70 0be2 	vsub.f64	d16, d16, d18
3230a022:	3130      	adds	r1, #48	@ 0x30
3230a024:	f803 1b01 	strb.w	r1, [r3], #1
3230a028:	eef4 0be1 	vcmpe.f64	d16, d17
3230a02c:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a030:	f100 8370 	bmi.w	3230a714 <_dtoa_r+0xc0c>
3230a034:	ee74 2be0 	vsub.f64	d18, d20, d16
3230a038:	eef4 2be1 	vcmpe.f64	d18, d17
3230a03c:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a040:	d5df      	bpl.n	3230a002 <_dtoa_r+0x4fa>
3230a042:	e002      	b.n	3230a04a <_dtoa_r+0x542>
3230a044:	42bb      	cmp	r3, r7
3230a046:	f000 835f 	beq.w	3230a708 <_dtoa_r+0xc00>
3230a04a:	469b      	mov	fp, r3
3230a04c:	f813 1d01 	ldrb.w	r1, [r3, #-1]!
3230a050:	2939      	cmp	r1, #57	@ 0x39
3230a052:	d0f7      	beq.n	3230a044 <_dtoa_r+0x53c>
3230a054:	3101      	adds	r1, #1
3230a056:	b2c9      	uxtb	r1, r1
3230a058:	7019      	strb	r1, [r3, #0]
3230a05a:	f10e 0601 	add.w	r6, lr, #1
3230a05e:	4649      	mov	r1, r9
3230a060:	4620      	mov	r0, r4
3230a062:	f000 fc65 	bl	3230a930 <_Bfree>
3230a066:	2300      	movs	r3, #0
3230a068:	f88b 3000 	strb.w	r3, [fp]
3230a06c:	9b06      	ldr	r3, [sp, #24]
3230a06e:	601e      	str	r6, [r3, #0]
3230a070:	9b1b      	ldr	r3, [sp, #108]	@ 0x6c
3230a072:	2b00      	cmp	r3, #0
3230a074:	f43f ad86 	beq.w	32309b84 <_dtoa_r+0x7c>
3230a078:	4638      	mov	r0, r7
3230a07a:	f8c3 b000 	str.w	fp, [r3]
3230a07e:	b00f      	add	sp, #60	@ 0x3c
3230a080:	ecbd 8b02 	vpop	{d8}
3230a084:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230a088:	2301      	movs	r3, #1
3230a08a:	9305      	str	r3, [sp, #20]
3230a08c:	f1ba 0f00 	cmp.w	sl, #0
3230a090:	f340 80e5 	ble.w	3230a25e <_dtoa_r+0x756>
3230a094:	46d3      	mov	fp, sl
3230a096:	4657      	mov	r7, sl
3230a098:	f8cd a02c 	str.w	sl, [sp, #44]	@ 0x2c
3230a09c:	e717      	b.n	32309ece <_dtoa_r+0x3c6>
3230a09e:	2300      	movs	r3, #0
3230a0a0:	9305      	str	r3, [sp, #20]
3230a0a2:	e70b      	b.n	32309ebc <_dtoa_r+0x3b4>
3230a0a4:	2300      	movs	r3, #0
3230a0a6:	9305      	str	r3, [sp, #20]
3230a0a8:	e7f0      	b.n	3230a08c <_dtoa_r+0x584>
3230a0aa:	9b08      	ldr	r3, [sp, #32]
3230a0ac:	2b00      	cmp	r3, #0
3230a0ae:	f040 81d6 	bne.w	3230a45e <_dtoa_r+0x956>
3230a0b2:	9e04      	ldr	r6, [sp, #16]
3230a0b4:	3601      	adds	r6, #1
3230a0b6:	46ba      	mov	sl, r7
3230a0b8:	9601      	str	r6, [sp, #4]
3230a0ba:	464f      	mov	r7, r9
3230a0bc:	4626      	mov	r6, r4
3230a0be:	2501      	movs	r5, #1
3230a0c0:	9c05      	ldr	r4, [sp, #20]
3230a0c2:	46d1      	mov	r9, sl
3230a0c4:	e007      	b.n	3230a0d6 <_dtoa_r+0x5ce>
3230a0c6:	4639      	mov	r1, r7
3230a0c8:	2300      	movs	r3, #0
3230a0ca:	220a      	movs	r2, #10
3230a0cc:	4630      	mov	r0, r6
3230a0ce:	f000 fc39 	bl	3230a944 <__multadd>
3230a0d2:	3501      	adds	r5, #1
3230a0d4:	4607      	mov	r7, r0
3230a0d6:	4621      	mov	r1, r4
3230a0d8:	4638      	mov	r0, r7
3230a0da:	f7ff fc7d 	bl	323099d8 <quorem>
3230a0de:	455d      	cmp	r5, fp
3230a0e0:	f100 0330 	add.w	r3, r0, #48	@ 0x30
3230a0e4:	f80a 3b01 	strb.w	r3, [sl], #1
3230a0e8:	dbed      	blt.n	3230a0c6 <_dtoa_r+0x5be>
3230a0ea:	464a      	mov	r2, r9
3230a0ec:	f1bb 0f00 	cmp.w	fp, #0
3230a0f0:	f10b 35ff 	add.w	r5, fp, #4294967295	@ 0xffffffff
3230a0f4:	46b9      	mov	r9, r7
3230a0f6:	bfd8      	it	le
3230a0f8:	2500      	movle	r5, #0
3230a0fa:	4617      	mov	r7, r2
3230a0fc:	3201      	adds	r2, #1
3230a0fe:	4634      	mov	r4, r6
3230a100:	4415      	add	r5, r2
3230a102:	9e01      	ldr	r6, [sp, #4]
3230a104:	2200      	movs	r2, #0
3230a106:	9201      	str	r2, [sp, #4]
3230a108:	4649      	mov	r1, r9
3230a10a:	2201      	movs	r2, #1
3230a10c:	4620      	mov	r0, r4
3230a10e:	9304      	str	r3, [sp, #16]
3230a110:	f000 fe98 	bl	3230ae44 <__lshift>
3230a114:	9905      	ldr	r1, [sp, #20]
3230a116:	4681      	mov	r9, r0
3230a118:	f000 ff08 	bl	3230af2c <__mcmp>
3230a11c:	2800      	cmp	r0, #0
3230a11e:	dc03      	bgt.n	3230a128 <_dtoa_r+0x620>
3230a120:	e2e7      	b.n	3230a6f2 <_dtoa_r+0xbea>
3230a122:	42bd      	cmp	r5, r7
3230a124:	f000 82e1 	beq.w	3230a6ea <_dtoa_r+0xbe2>
3230a128:	46ab      	mov	fp, r5
3230a12a:	3d01      	subs	r5, #1
3230a12c:	f81b 3c01 	ldrb.w	r3, [fp, #-1]
3230a130:	2b39      	cmp	r3, #57	@ 0x39
3230a132:	d0f6      	beq.n	3230a122 <_dtoa_r+0x61a>
3230a134:	3301      	adds	r3, #1
3230a136:	702b      	strb	r3, [r5, #0]
3230a138:	9905      	ldr	r1, [sp, #20]
3230a13a:	4620      	mov	r0, r4
3230a13c:	f000 fbf8 	bl	3230a930 <_Bfree>
3230a140:	f1b8 0f00 	cmp.w	r8, #0
3230a144:	d08b      	beq.n	3230a05e <_dtoa_r+0x556>
3230a146:	9901      	ldr	r1, [sp, #4]
3230a148:	4643      	mov	r3, r8
3230a14a:	2900      	cmp	r1, #0
3230a14c:	bf18      	it	ne
3230a14e:	4299      	cmpne	r1, r3
3230a150:	f43f ae6a 	beq.w	32309e28 <_dtoa_r+0x320>
3230a154:	4620      	mov	r0, r4
3230a156:	f000 fbeb 	bl	3230a930 <_Bfree>
3230a15a:	e665      	b.n	32309e28 <_dtoa_r+0x320>
3230a15c:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
3230a15e:	f1c3 0336 	rsb	r3, r3, #54	@ 0x36
3230a162:	e5e4      	b.n	32309d2e <_dtoa_r+0x226>
3230a164:	105b      	asrs	r3, r3, #1
3230a166:	3208      	adds	r2, #8
3230a168:	e6f4      	b.n	32309f54 <_dtoa_r+0x44c>
3230a16a:	ee07 1a90 	vmov	s15, r1
3230a16e:	eef8 1be7 	vcvt.f64.s32	d17, s15
3230a172:	eeb1 7b0c 	vmov.f64	d7, #28	@ 0x40e00000  7.0
3230a176:	eea1 7ba0 	vfma.f64	d7, d17, d16
3230a17a:	ee17 1a90 	vmov	r1, s15
3230a17e:	ec53 2b17 	vmov	r2, r3, d7
3230a182:	f1a1 7350 	sub.w	r3, r1, #54525952	@ 0x3400000
3230a186:	eef1 2b04 	vmov.f64	d18, #20	@ 0x40a00000  5.0
3230a18a:	ec43 2b31 	vmov	d17, r2, r3
3230a18e:	ee70 0be2 	vsub.f64	d16, d16, d18
3230a192:	eef4 0be1 	vcmpe.f64	d16, d17
3230a196:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a19a:	f300 826c 	bgt.w	3230a676 <_dtoa_r+0xb6e>
3230a19e:	eef1 1b61 	vneg.f64	d17, d17
3230a1a2:	eef4 0be1 	vcmpe.f64	d16, d17
3230a1a6:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a1aa:	f100 80ce 	bmi.w	3230a34a <_dtoa_r+0x842>
3230a1ae:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
3230a1b0:	9904      	ldr	r1, [sp, #16]
3230a1b2:	43da      	mvns	r2, r3
3230a1b4:	290e      	cmp	r1, #14
3230a1b6:	ea4f 72d2 	mov.w	r2, r2, lsr #31
3230a1ba:	bfc8      	it	gt
3230a1bc:	2200      	movgt	r2, #0
3230a1be:	2a00      	cmp	r2, #0
3230a1c0:	f040 8337 	bne.w	3230a832 <_dtoa_r+0xd2a>
3230a1c4:	9a05      	ldr	r2, [sp, #20]
3230a1c6:	2a00      	cmp	r2, #0
3230a1c8:	f040 808d 	bne.w	3230a2e6 <_dtoa_r+0x7de>
3230a1cc:	9e07      	ldr	r6, [sp, #28]
3230a1ce:	2e00      	cmp	r6, #0
3230a1d0:	bf18      	it	ne
3230a1d2:	2d00      	cmpne	r5, #0
3230a1d4:	d007      	beq.n	3230a1e6 <_dtoa_r+0x6de>
3230a1d6:	9a07      	ldr	r2, [sp, #28]
3230a1d8:	42aa      	cmp	r2, r5
3230a1da:	4613      	mov	r3, r2
3230a1dc:	bfa8      	it	ge
3230a1de:	462b      	movge	r3, r5
3230a1e0:	1aed      	subs	r5, r5, r3
3230a1e2:	1ad6      	subs	r6, r2, r3
3230a1e4:	9607      	str	r6, [sp, #28]
3230a1e6:	9b08      	ldr	r3, [sp, #32]
3230a1e8:	b90b      	cbnz	r3, 3230a1ee <_dtoa_r+0x6e6>
3230a1ea:	4698      	mov	r8, r3
3230a1ec:	e5b6      	b.n	32309d5c <_dtoa_r+0x254>
3230a1ee:	4649      	mov	r1, r9
3230a1f0:	9a08      	ldr	r2, [sp, #32]
3230a1f2:	4620      	mov	r0, r4
3230a1f4:	f000 fdc2 	bl	3230ad7c <__pow5mult>
3230a1f8:	2300      	movs	r3, #0
3230a1fa:	9e07      	ldr	r6, [sp, #28]
3230a1fc:	4681      	mov	r9, r0
3230a1fe:	4698      	mov	r8, r3
3230a200:	9308      	str	r3, [sp, #32]
3230a202:	e5ab      	b.n	32309d5c <_dtoa_r+0x254>
3230a204:	231c      	movs	r3, #28
3230a206:	e5c3      	b.n	32309d90 <_dtoa_r+0x288>
3230a208:	f000 8203 	beq.w	3230a612 <_dtoa_r+0xb0a>
3230a20c:	9b04      	ldr	r3, [sp, #16]
3230a20e:	f64b 7238 	movw	r2, #48952	@ 0xbf38
3230a212:	f2c3 2230 	movt	r2, #12848	@ 0x3230
3230a216:	425b      	negs	r3, r3
3230a218:	f003 010f 	and.w	r1, r3, #15
3230a21c:	111b      	asrs	r3, r3, #4
3230a21e:	eb02 02c1 	add.w	r2, r2, r1, lsl #3
3230a222:	edd2 0b00 	vldr	d16, [r2]
3230a226:	ee68 0b20 	vmul.f64	d16, d8, d16
3230a22a:	f000 8330 	beq.w	3230a88e <_dtoa_r+0xd86>
3230a22e:	f64b 7210 	movw	r2, #48912	@ 0xbf10
3230a232:	f2c3 2230 	movt	r2, #12848	@ 0x3230
3230a236:	2102      	movs	r1, #2
3230a238:	07d8      	lsls	r0, r3, #31
3230a23a:	d509      	bpl.n	3230a250 <_dtoa_r+0x748>
3230a23c:	ecf2 1b02 	vldmia	r2!, {d17}
3230a240:	3101      	adds	r1, #1
3230a242:	105b      	asrs	r3, r3, #1
3230a244:	ee60 0ba1 	vmul.f64	d16, d16, d17
3230a248:	f43f ae90 	beq.w	32309f6c <_dtoa_r+0x464>
3230a24c:	07d8      	lsls	r0, r3, #31
3230a24e:	d4f5      	bmi.n	3230a23c <_dtoa_r+0x734>
3230a250:	105b      	asrs	r3, r3, #1
3230a252:	3208      	adds	r2, #8
3230a254:	e7f0      	b.n	3230a238 <_dtoa_r+0x730>
3230a256:	ea6f 060a 	mvn.w	r6, sl
3230a25a:	46bb      	mov	fp, r7
3230a25c:	e5db      	b.n	32309e16 <_dtoa_r+0x30e>
3230a25e:	2301      	movs	r3, #1
3230a260:	2100      	movs	r1, #0
3230a262:	469b      	mov	fp, r3
3230a264:	469a      	mov	sl, r3
3230a266:	63e1      	str	r1, [r4, #60]	@ 0x3c
3230a268:	930b      	str	r3, [sp, #44]	@ 0x2c
3230a26a:	e63f      	b.n	32309eec <_dtoa_r+0x3e4>
3230a26c:	9905      	ldr	r1, [sp, #20]
3230a26e:	4648      	mov	r0, r9
3230a270:	f000 fe5c 	bl	3230af2c <__mcmp>
3230a274:	2800      	cmp	r0, #0
3230a276:	f6bf adac 	bge.w	32309dd2 <_dtoa_r+0x2ca>
3230a27a:	4649      	mov	r1, r9
3230a27c:	2300      	movs	r3, #0
3230a27e:	220a      	movs	r2, #10
3230a280:	4620      	mov	r0, r4
3230a282:	9d04      	ldr	r5, [sp, #16]
3230a284:	f000 fb5e 	bl	3230a944 <__multadd>
3230a288:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
3230a28a:	4681      	mov	r9, r0
3230a28c:	f105 3bff 	add.w	fp, r5, #4294967295	@ 0xffffffff
3230a290:	9d07      	ldr	r5, [sp, #28]
3230a292:	2b00      	cmp	r3, #0
3230a294:	9b08      	ldr	r3, [sp, #32]
3230a296:	f005 0501 	and.w	r5, r5, #1
3230a29a:	bfc8      	it	gt
3230a29c:	2500      	movgt	r5, #0
3230a29e:	2b00      	cmp	r3, #0
3230a2a0:	f040 80cf 	bne.w	3230a442 <_dtoa_r+0x93a>
3230a2a4:	2d00      	cmp	r5, #0
3230a2a6:	f040 82ec 	bne.w	3230a882 <_dtoa_r+0xd7a>
3230a2aa:	9e04      	ldr	r6, [sp, #16]
3230a2ac:	f8dd b02c 	ldr.w	fp, [sp, #44]	@ 0x2c
3230a2b0:	e701      	b.n	3230a0b6 <_dtoa_r+0x5ae>
3230a2b2:	461a      	mov	r2, r3
3230a2b4:	4601      	mov	r1, r0
3230a2b6:	4620      	mov	r0, r4
3230a2b8:	f000 fd60 	bl	3230ad7c <__pow5mult>
3230a2bc:	9b01      	ldr	r3, [sp, #4]
3230a2be:	9005      	str	r0, [sp, #20]
3230a2c0:	2b01      	cmp	r3, #1
3230a2c2:	f340 81f8 	ble.w	3230a6b6 <_dtoa_r+0xbae>
3230a2c6:	2300      	movs	r3, #0
3230a2c8:	9309      	str	r3, [sp, #36]	@ 0x24
3230a2ca:	9a05      	ldr	r2, [sp, #20]
3230a2cc:	6913      	ldr	r3, [r2, #16]
3230a2ce:	eb02 0383 	add.w	r3, r2, r3, lsl #2
3230a2d2:	6918      	ldr	r0, [r3, #16]
3230a2d4:	f000 fbe8 	bl	3230aaa8 <__hi0bits>
3230a2d8:	f1c0 0320 	rsb	r3, r0, #32
3230a2dc:	e54c      	b.n	32309d78 <_dtoa_r+0x270>
3230a2de:	eef0 2b48 	vmov.f64	d18, d8
3230a2e2:	2102      	movs	r1, #2
3230a2e4:	e631      	b.n	32309f4a <_dtoa_r+0x442>
3230a2e6:	9a01      	ldr	r2, [sp, #4]
3230a2e8:	2a01      	cmp	r2, #1
3230a2ea:	f77f ad1a 	ble.w	32309d22 <_dtoa_r+0x21a>
3230a2ee:	9b08      	ldr	r3, [sp, #32]
3230a2f0:	f10b 32ff 	add.w	r2, fp, #4294967295	@ 0xffffffff
3230a2f4:	4293      	cmp	r3, r2
3230a2f6:	f2c0 81c9 	blt.w	3230a68c <_dtoa_r+0xb84>
3230a2fa:	1a9b      	subs	r3, r3, r2
3230a2fc:	9305      	str	r3, [sp, #20]
3230a2fe:	9b07      	ldr	r3, [sp, #28]
3230a300:	f1bb 0f00 	cmp.w	fp, #0
3230a304:	eba3 060b 	sub.w	r6, r3, fp
3230a308:	f6ff ad18 	blt.w	32309d3c <_dtoa_r+0x234>
3230a30c:	9b07      	ldr	r3, [sp, #28]
3230a30e:	445d      	add	r5, fp
3230a310:	461e      	mov	r6, r3
3230a312:	445b      	add	r3, fp
3230a314:	9307      	str	r3, [sp, #28]
3230a316:	e511      	b.n	32309d3c <_dtoa_r+0x234>
3230a318:	9b02      	ldr	r3, [sp, #8]
3230a31a:	2b00      	cmp	r3, #0
3230a31c:	f47f ad2b 	bne.w	32309d76 <_dtoa_r+0x26e>
3230a320:	9b03      	ldr	r3, [sp, #12]
3230a322:	f3c3 0313 	ubfx	r3, r3, #0, #20
3230a326:	2b00      	cmp	r3, #0
3230a328:	f47f ad25 	bne.w	32309d76 <_dtoa_r+0x26e>
3230a32c:	9b03      	ldr	r3, [sp, #12]
3230a32e:	f023 4300 	bic.w	r3, r3, #2147483648	@ 0x80000000
3230a332:	0d1b      	lsrs	r3, r3, #20
3230a334:	051b      	lsls	r3, r3, #20
3230a336:	2b00      	cmp	r3, #0
3230a338:	f43f ad1d 	beq.w	32309d76 <_dtoa_r+0x26e>
3230a33c:	9b07      	ldr	r3, [sp, #28]
3230a33e:	3501      	adds	r5, #1
3230a340:	3301      	adds	r3, #1
3230a342:	9307      	str	r3, [sp, #28]
3230a344:	2301      	movs	r3, #1
3230a346:	9309      	str	r3, [sp, #36]	@ 0x24
3230a348:	e516      	b.n	32309d78 <_dtoa_r+0x270>
3230a34a:	2100      	movs	r1, #0
3230a34c:	4620      	mov	r0, r4
3230a34e:	f1ca 0600 	rsb	r6, sl, #0
3230a352:	46bb      	mov	fp, r7
3230a354:	f000 faec 	bl	3230a930 <_Bfree>
3230a358:	e681      	b.n	3230a05e <_dtoa_r+0x556>
3230a35a:	ee62 3ba3 	vmul.f64	d19, d18, d19
3230a35e:	eb07 0c06 	add.w	ip, r7, r6
3230a362:	4618      	mov	r0, r3
3230a364:	2e01      	cmp	r6, #1
3230a366:	eef2 2b04 	vmov.f64	d18, #36	@ 0x41200000  10.0
3230a36a:	f000 8288 	beq.w	3230a87e <_dtoa_r+0xd76>
3230a36e:	ee60 0ba2 	vmul.f64	d16, d16, d18
3230a372:	eefd 7be0 	vcvt.s32.f64	s15, d16
3230a376:	ee17 1a90 	vmov	r1, s15
3230a37a:	eef8 1be7 	vcvt.f64.s32	d17, s15
3230a37e:	3130      	adds	r1, #48	@ 0x30
3230a380:	f800 1b01 	strb.w	r1, [r0], #1
3230a384:	ee70 0be1 	vsub.f64	d16, d16, d17
3230a388:	4584      	cmp	ip, r0
3230a38a:	d1f0      	bne.n	3230a36e <_dtoa_r+0x866>
3230a38c:	1e59      	subs	r1, r3, #1
3230a38e:	4431      	add	r1, r6
3230a390:	eef6 1b00 	vmov.f64	d17, #96	@ 0x3f000000  0.5
3230a394:	ee73 2ba1 	vadd.f64	d18, d19, d17
3230a398:	eef4 2be0 	vcmpe.f64	d18, d16
3230a39c:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a3a0:	f100 81bc 	bmi.w	3230a71c <_dtoa_r+0xc14>
3230a3a4:	ee71 1be3 	vsub.f64	d17, d17, d19
3230a3a8:	eef4 1be0 	vcmpe.f64	d17, d16
3230a3ac:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a3b0:	dc40      	bgt.n	3230a434 <_dtoa_r+0x92c>
3230a3b2:	990d      	ldr	r1, [sp, #52]	@ 0x34
3230a3b4:	9804      	ldr	r0, [sp, #16]
3230a3b6:	43c9      	mvns	r1, r1
3230a3b8:	280e      	cmp	r0, #14
3230a3ba:	ea4f 71d1 	mov.w	r1, r1, lsr #31
3230a3be:	bfc8      	it	gt
3230a3c0:	2100      	movgt	r1, #0
3230a3c2:	2900      	cmp	r1, #0
3230a3c4:	f43f af02 	beq.w	3230a1cc <_dtoa_r+0x6c4>
3230a3c8:	9904      	ldr	r1, [sp, #16]
3230a3ca:	eb02 02c1 	add.w	r2, r2, r1, lsl #3
3230a3ce:	edd2 1b00 	vldr	d17, [r2]
3230a3d2:	eec8 0b21 	vdiv.f64	d16, d8, d17
3230a3d6:	f1c3 0101 	rsb	r1, r3, #1
3230a3da:	f1bb 0f01 	cmp.w	fp, #1
3230a3de:	eef2 2b04 	vmov.f64	d18, #36	@ 0x41200000  10.0
3230a3e2:	eefd 7be0 	vcvt.s32.f64	s15, d16
3230a3e6:	eef8 0be7 	vcvt.f64.s32	d16, s15
3230a3ea:	ee17 2a90 	vmov	r2, s15
3230a3ee:	eea0 8be1 	vfms.f64	d8, d16, d17
3230a3f2:	f102 0230 	add.w	r2, r2, #48	@ 0x30
3230a3f6:	703a      	strb	r2, [r7, #0]
3230a3f8:	d111      	bne.n	3230a41e <_dtoa_r+0x916>
3230a3fa:	e1ee      	b.n	3230a7da <_dtoa_r+0xcd2>
3230a3fc:	eec8 0b21 	vdiv.f64	d16, d8, d17
3230a400:	eefd 7be0 	vcvt.s32.f64	s15, d16
3230a404:	ee17 2a90 	vmov	r2, s15
3230a408:	eef8 0be7 	vcvt.f64.s32	d16, s15
3230a40c:	3230      	adds	r2, #48	@ 0x30
3230a40e:	f803 2b01 	strb.w	r2, [r3], #1
3230a412:	eea0 8be1 	vfms.f64	d8, d16, d17
3230a416:	185a      	adds	r2, r3, r1
3230a418:	455a      	cmp	r2, fp
3230a41a:	f000 81de 	beq.w	3230a7da <_dtoa_r+0xcd2>
3230a41e:	ee28 8b22 	vmul.f64	d8, d8, d18
3230a422:	eeb5 8b40 	vcmp.f64	d8, #0.0
3230a426:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a42a:	d1e7      	bne.n	3230a3fc <_dtoa_r+0x8f4>
3230a42c:	9e04      	ldr	r6, [sp, #16]
3230a42e:	469b      	mov	fp, r3
3230a430:	3601      	adds	r6, #1
3230a432:	e614      	b.n	3230a05e <_dtoa_r+0x556>
3230a434:	468b      	mov	fp, r1
3230a436:	3901      	subs	r1, #1
3230a438:	f81b 3c01 	ldrb.w	r3, [fp, #-1]
3230a43c:	2b30      	cmp	r3, #48	@ 0x30
3230a43e:	d0f9      	beq.n	3230a434 <_dtoa_r+0x92c>
3230a440:	e60b      	b.n	3230a05a <_dtoa_r+0x552>
3230a442:	4641      	mov	r1, r8
3230a444:	2300      	movs	r3, #0
3230a446:	220a      	movs	r2, #10
3230a448:	4620      	mov	r0, r4
3230a44a:	f000 fa7b 	bl	3230a944 <__multadd>
3230a44e:	f8cd b010 	str.w	fp, [sp, #16]
3230a452:	4680      	mov	r8, r0
3230a454:	f8dd b02c 	ldr.w	fp, [sp, #44]	@ 0x2c
3230a458:	2d00      	cmp	r5, #0
3230a45a:	f47f acc4 	bne.w	32309de6 <_dtoa_r+0x2de>
3230a45e:	2e00      	cmp	r6, #0
3230a460:	dd05      	ble.n	3230a46e <_dtoa_r+0x966>
3230a462:	4641      	mov	r1, r8
3230a464:	4632      	mov	r2, r6
3230a466:	4620      	mov	r0, r4
3230a468:	f000 fcec 	bl	3230ae44 <__lshift>
3230a46c:	4680      	mov	r8, r0
3230a46e:	9b09      	ldr	r3, [sp, #36]	@ 0x24
3230a470:	46c2      	mov	sl, r8
3230a472:	2b00      	cmp	r3, #0
3230a474:	f040 8154 	bne.w	3230a720 <_dtoa_r+0xc18>
3230a478:	1e7b      	subs	r3, r7, #1
3230a47a:	463e      	mov	r6, r7
3230a47c:	445b      	add	r3, fp
3230a47e:	9308      	str	r3, [sp, #32]
3230a480:	9b02      	ldr	r3, [sp, #8]
3230a482:	f003 0301 	and.w	r3, r3, #1
3230a486:	e9cd 3709 	strd	r3, r7, [sp, #36]	@ 0x24
3230a48a:	9905      	ldr	r1, [sp, #20]
3230a48c:	4648      	mov	r0, r9
3230a48e:	f7ff faa3 	bl	323099d8 <quorem>
3230a492:	4641      	mov	r1, r8
3230a494:	4683      	mov	fp, r0
3230a496:	4648      	mov	r0, r9
3230a498:	f000 fd48 	bl	3230af2c <__mcmp>
3230a49c:	9905      	ldr	r1, [sp, #20]
3230a49e:	4605      	mov	r5, r0
3230a4a0:	4652      	mov	r2, sl
3230a4a2:	4620      	mov	r0, r4
3230a4a4:	f10b 0730 	add.w	r7, fp, #48	@ 0x30
3230a4a8:	f000 fd60 	bl	3230af6c <__mdiff>
3230a4ac:	68c3      	ldr	r3, [r0, #12]
3230a4ae:	4601      	mov	r1, r0
3230a4b0:	bb9b      	cbnz	r3, 3230a51a <_dtoa_r+0xa12>
3230a4b2:	9007      	str	r0, [sp, #28]
3230a4b4:	4648      	mov	r0, r9
3230a4b6:	f000 fd39 	bl	3230af2c <__mcmp>
3230a4ba:	9907      	ldr	r1, [sp, #28]
3230a4bc:	9007      	str	r0, [sp, #28]
3230a4be:	4620      	mov	r0, r4
3230a4c0:	f000 fa36 	bl	3230a930 <_Bfree>
3230a4c4:	9b01      	ldr	r3, [sp, #4]
3230a4c6:	9a07      	ldr	r2, [sp, #28]
3230a4c8:	4313      	orrs	r3, r2
3230a4ca:	d156      	bne.n	3230a57a <_dtoa_r+0xa72>
3230a4cc:	9b09      	ldr	r3, [sp, #36]	@ 0x24
3230a4ce:	2b00      	cmp	r3, #0
3230a4d0:	f000 81cc 	beq.w	3230a86c <_dtoa_r+0xd64>
3230a4d4:	2d00      	cmp	r5, #0
3230a4d6:	f2c0 81c6 	blt.w	3230a866 <_dtoa_r+0xd5e>
3230a4da:	4635      	mov	r5, r6
3230a4dc:	9b08      	ldr	r3, [sp, #32]
3230a4de:	42b3      	cmp	r3, r6
3230a4e0:	f805 7b01 	strb.w	r7, [r5], #1
3230a4e4:	f000 819d 	beq.w	3230a822 <_dtoa_r+0xd1a>
3230a4e8:	4649      	mov	r1, r9
3230a4ea:	2300      	movs	r3, #0
3230a4ec:	220a      	movs	r2, #10
3230a4ee:	4620      	mov	r0, r4
3230a4f0:	f000 fa28 	bl	3230a944 <__multadd>
3230a4f4:	4641      	mov	r1, r8
3230a4f6:	4681      	mov	r9, r0
3230a4f8:	2300      	movs	r3, #0
3230a4fa:	220a      	movs	r2, #10
3230a4fc:	4620      	mov	r0, r4
3230a4fe:	45d0      	cmp	r8, sl
3230a500:	d035      	beq.n	3230a56e <_dtoa_r+0xa66>
3230a502:	f000 fa1f 	bl	3230a944 <__multadd>
3230a506:	4651      	mov	r1, sl
3230a508:	4680      	mov	r8, r0
3230a50a:	2300      	movs	r3, #0
3230a50c:	220a      	movs	r2, #10
3230a50e:	4620      	mov	r0, r4
3230a510:	f000 fa18 	bl	3230a944 <__multadd>
3230a514:	462e      	mov	r6, r5
3230a516:	4682      	mov	sl, r0
3230a518:	e7b7      	b.n	3230a48a <_dtoa_r+0x982>
3230a51a:	4620      	mov	r0, r4
3230a51c:	9707      	str	r7, [sp, #28]
3230a51e:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3230a520:	f000 fa06 	bl	3230a930 <_Bfree>
3230a524:	9b07      	ldr	r3, [sp, #28]
3230a526:	2d00      	cmp	r5, #0
3230a528:	db06      	blt.n	3230a538 <_dtoa_r+0xa30>
3230a52a:	9a02      	ldr	r2, [sp, #8]
3230a52c:	9901      	ldr	r1, [sp, #4]
3230a52e:	f002 0201 	and.w	r2, r2, #1
3230a532:	430d      	orrs	r5, r1
3230a534:	432a      	orrs	r2, r5
3230a536:	d12d      	bne.n	3230a594 <_dtoa_r+0xa8c>
3230a538:	4649      	mov	r1, r9
3230a53a:	2201      	movs	r2, #1
3230a53c:	4620      	mov	r0, r4
3230a53e:	9301      	str	r3, [sp, #4]
3230a540:	f000 fc80 	bl	3230ae44 <__lshift>
3230a544:	9905      	ldr	r1, [sp, #20]
3230a546:	4681      	mov	r9, r0
3230a548:	f000 fcf0 	bl	3230af2c <__mcmp>
3230a54c:	9b01      	ldr	r3, [sp, #4]
3230a54e:	2800      	cmp	r0, #0
3230a550:	f340 81a0 	ble.w	3230a894 <_dtoa_r+0xd8c>
3230a554:	2b39      	cmp	r3, #57	@ 0x39
3230a556:	d023      	beq.n	3230a5a0 <_dtoa_r+0xa98>
3230a558:	f10b 0331 	add.w	r3, fp, #49	@ 0x31
3230a55c:	46b3      	mov	fp, r6
3230a55e:	9e04      	ldr	r6, [sp, #16]
3230a560:	f8cd 8004 	str.w	r8, [sp, #4]
3230a564:	46d0      	mov	r8, sl
3230a566:	3601      	adds	r6, #1
3230a568:	f80b 3b01 	strb.w	r3, [fp], #1
3230a56c:	e5e4      	b.n	3230a138 <_dtoa_r+0x630>
3230a56e:	f000 f9e9 	bl	3230a944 <__multadd>
3230a572:	462e      	mov	r6, r5
3230a574:	4680      	mov	r8, r0
3230a576:	4682      	mov	sl, r0
3230a578:	e787      	b.n	3230a48a <_dtoa_r+0x982>
3230a57a:	2d00      	cmp	r5, #0
3230a57c:	f2c0 815e 	blt.w	3230a83c <_dtoa_r+0xd34>
3230a580:	9b01      	ldr	r3, [sp, #4]
3230a582:	431d      	orrs	r5, r3
3230a584:	9b09      	ldr	r3, [sp, #36]	@ 0x24
3230a586:	431d      	orrs	r5, r3
3230a588:	f000 8158 	beq.w	3230a83c <_dtoa_r+0xd34>
3230a58c:	2a00      	cmp	r2, #0
3230a58e:	dda4      	ble.n	3230a4da <_dtoa_r+0x9d2>
3230a590:	463b      	mov	r3, r7
3230a592:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3230a594:	2b39      	cmp	r3, #57	@ 0x39
3230a596:	bf18      	it	ne
3230a598:	46b3      	movne	fp, r6
3230a59a:	bf18      	it	ne
3230a59c:	3301      	addne	r3, #1
3230a59e:	d1de      	bne.n	3230a55e <_dtoa_r+0xa56>
3230a5a0:	4635      	mov	r5, r6
3230a5a2:	9e04      	ldr	r6, [sp, #16]
3230a5a4:	2339      	movs	r3, #57	@ 0x39
3230a5a6:	f8cd 8004 	str.w	r8, [sp, #4]
3230a5aa:	3601      	adds	r6, #1
3230a5ac:	46d0      	mov	r8, sl
3230a5ae:	f805 3b01 	strb.w	r3, [r5], #1
3230a5b2:	e5b9      	b.n	3230a128 <_dtoa_r+0x620>
3230a5b4:	f43f abf1 	beq.w	32309d9a <_dtoa_r+0x292>
3230a5b8:	f1c3 033c 	rsb	r3, r3, #60	@ 0x3c
3230a5bc:	f7ff bbe8 	b.w	32309d90 <_dtoa_r+0x288>
3230a5c0:	f1bb 0f00 	cmp.w	fp, #0
3230a5c4:	f43f add1 	beq.w	3230a16a <_dtoa_r+0x662>
3230a5c8:	9e0b      	ldr	r6, [sp, #44]	@ 0x2c
3230a5ca:	2e00      	cmp	r6, #0
3230a5cc:	f77f adef 	ble.w	3230a1ae <_dtoa_r+0x6a6>
3230a5d0:	3101      	adds	r1, #1
3230a5d2:	eef2 2b04 	vmov.f64	d18, #36	@ 0x41200000  10.0
3230a5d6:	ee07 1a90 	vmov	s15, r1
3230a5da:	9b04      	ldr	r3, [sp, #16]
3230a5dc:	ee60 0ba2 	vmul.f64	d16, d16, d18
3230a5e0:	eef8 1be7 	vcvt.f64.s32	d17, s15
3230a5e4:	eeb1 7b0c 	vmov.f64	d7, #28	@ 0x40e00000  7.0
3230a5e8:	f103 3eff 	add.w	lr, r3, #4294967295	@ 0xffffffff
3230a5ec:	eea0 7ba1 	vfma.f64	d7, d16, d17
3230a5f0:	ee17 1a90 	vmov	r1, s15
3230a5f4:	ec53 2b17 	vmov	r2, r3, d7
3230a5f8:	f1a1 7350 	sub.w	r3, r1, #54525952	@ 0x3400000
3230a5fc:	e4d5      	b.n	32309faa <_dtoa_r+0x4a2>
3230a5fe:	f1c3 0301 	rsb	r3, r3, #1
3230a602:	9307      	str	r3, [sp, #28]
3230a604:	9b04      	ldr	r3, [sp, #16]
3230a606:	9309      	str	r3, [sp, #36]	@ 0x24
3230a608:	461d      	mov	r5, r3
3230a60a:	2300      	movs	r3, #0
3230a60c:	930a      	str	r3, [sp, #40]	@ 0x28
3230a60e:	f7ff bb22 	b.w	32309c56 <_dtoa_r+0x14e>
3230a612:	eef0 0b48 	vmov.f64	d16, d8
3230a616:	2102      	movs	r1, #2
3230a618:	e4a8      	b.n	32309f6c <_dtoa_r+0x464>
3230a61a:	42ae      	cmp	r6, r5
3230a61c:	9a07      	ldr	r2, [sp, #28]
3230a61e:	4633      	mov	r3, r6
3230a620:	bfa8      	it	ge
3230a622:	462b      	movge	r3, r5
3230a624:	1ad2      	subs	r2, r2, r3
3230a626:	1af6      	subs	r6, r6, r3
3230a628:	1aed      	subs	r5, r5, r3
3230a62a:	9b08      	ldr	r3, [sp, #32]
3230a62c:	9207      	str	r2, [sp, #28]
3230a62e:	2b00      	cmp	r3, #0
3230a630:	f43f ab92 	beq.w	32309d58 <_dtoa_r+0x250>
3230a634:	9b05      	ldr	r3, [sp, #20]
3230a636:	2b00      	cmp	r3, #0
3230a638:	d06a      	beq.n	3230a710 <_dtoa_r+0xc08>
3230a63a:	461a      	mov	r2, r3
3230a63c:	4641      	mov	r1, r8
3230a63e:	4620      	mov	r0, r4
3230a640:	f000 fb9c 	bl	3230ad7c <__pow5mult>
3230a644:	464a      	mov	r2, r9
3230a646:	4601      	mov	r1, r0
3230a648:	4680      	mov	r8, r0
3230a64a:	4620      	mov	r0, r4
3230a64c:	f000 fad8 	bl	3230ac00 <__multiply>
3230a650:	4649      	mov	r1, r9
3230a652:	4681      	mov	r9, r0
3230a654:	4620      	mov	r0, r4
3230a656:	f000 f96b 	bl	3230a930 <_Bfree>
3230a65a:	9908      	ldr	r1, [sp, #32]
3230a65c:	9b05      	ldr	r3, [sp, #20]
3230a65e:	1aca      	subs	r2, r1, r3
3230a660:	f43f ab7a 	beq.w	32309d58 <_dtoa_r+0x250>
3230a664:	4649      	mov	r1, r9
3230a666:	4620      	mov	r0, r4
3230a668:	f000 fb88 	bl	3230ad7c <__pow5mult>
3230a66c:	2301      	movs	r3, #1
3230a66e:	4681      	mov	r9, r0
3230a670:	9308      	str	r3, [sp, #32]
3230a672:	f7ff bb73 	b.w	32309d5c <_dtoa_r+0x254>
3230a676:	46bb      	mov	fp, r7
3230a678:	2331      	movs	r3, #49	@ 0x31
3230a67a:	2100      	movs	r1, #0
3230a67c:	4620      	mov	r0, r4
3230a67e:	f80b 3b01 	strb.w	r3, [fp], #1
3230a682:	f000 f955 	bl	3230a930 <_Bfree>
3230a686:	9e04      	ldr	r6, [sp, #16]
3230a688:	3602      	adds	r6, #2
3230a68a:	e4e8      	b.n	3230a05e <_dtoa_r+0x556>
3230a68c:	9b08      	ldr	r3, [sp, #32]
3230a68e:	2101      	movs	r1, #1
3230a690:	9205      	str	r2, [sp, #20]
3230a692:	4620      	mov	r0, r4
3230a694:	1ad3      	subs	r3, r2, r3
3230a696:	9a09      	ldr	r2, [sp, #36]	@ 0x24
3230a698:	445d      	add	r5, fp
3230a69a:	441a      	add	r2, r3
3230a69c:	9209      	str	r2, [sp, #36]	@ 0x24
3230a69e:	f000 fa73 	bl	3230ab88 <__i2b>
3230a6a2:	9b07      	ldr	r3, [sp, #28]
3230a6a4:	9a05      	ldr	r2, [sp, #20]
3230a6a6:	4680      	mov	r8, r0
3230a6a8:	2b00      	cmp	r3, #0
3230a6aa:	f040 808a 	bne.w	3230a7c2 <_dtoa_r+0xcba>
3230a6ae:	461e      	mov	r6, r3
3230a6b0:	f8cd b01c 	str.w	fp, [sp, #28]
3230a6b4:	e7d6      	b.n	3230a664 <_dtoa_r+0xb5c>
3230a6b6:	9b02      	ldr	r3, [sp, #8]
3230a6b8:	2b00      	cmp	r3, #0
3230a6ba:	f47f ae04 	bne.w	3230a2c6 <_dtoa_r+0x7be>
3230a6be:	e9dd 1202 	ldrd	r1, r2, [sp, #8]
3230a6c2:	f3c2 0313 	ubfx	r3, r2, #0, #20
3230a6c6:	2b00      	cmp	r3, #0
3230a6c8:	f000 80be 	beq.w	3230a848 <_dtoa_r+0xd40>
3230a6cc:	9109      	str	r1, [sp, #36]	@ 0x24
3230a6ce:	e5fc      	b.n	3230a2ca <_dtoa_r+0x7c2>
3230a6d0:	9a04      	ldr	r2, [sp, #16]
3230a6d2:	f64b 7338 	movw	r3, #48952	@ 0xbf38
3230a6d6:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230a6da:	f04f 3bff 	mov.w	fp, #4294967295	@ 0xffffffff
3230a6de:	eb03 03c2 	add.w	r3, r3, r2, lsl #3
3230a6e2:	edd3 1b00 	vldr	d17, [r3]
3230a6e6:	1c7b      	adds	r3, r7, #1
3230a6e8:	e673      	b.n	3230a3d2 <_dtoa_r+0x8ca>
3230a6ea:	2331      	movs	r3, #49	@ 0x31
3230a6ec:	3601      	adds	r6, #1
3230a6ee:	703b      	strb	r3, [r7, #0]
3230a6f0:	e522      	b.n	3230a138 <_dtoa_r+0x630>
3230a6f2:	d103      	bne.n	3230a6fc <_dtoa_r+0xbf4>
3230a6f4:	9b04      	ldr	r3, [sp, #16]
3230a6f6:	07db      	lsls	r3, r3, #31
3230a6f8:	f53f ad16 	bmi.w	3230a128 <_dtoa_r+0x620>
3230a6fc:	46ab      	mov	fp, r5
3230a6fe:	f815 3d01 	ldrb.w	r3, [r5, #-1]!
3230a702:	2b30      	cmp	r3, #48	@ 0x30
3230a704:	d0fa      	beq.n	3230a6fc <_dtoa_r+0xbf4>
3230a706:	e517      	b.n	3230a138 <_dtoa_r+0x630>
3230a708:	f10e 0e01 	add.w	lr, lr, #1
3230a70c:	2131      	movs	r1, #49	@ 0x31
3230a70e:	e4a3      	b.n	3230a058 <_dtoa_r+0x550>
3230a710:	9a08      	ldr	r2, [sp, #32]
3230a712:	e7a7      	b.n	3230a664 <_dtoa_r+0xb5c>
3230a714:	f10e 0601 	add.w	r6, lr, #1
3230a718:	469b      	mov	fp, r3
3230a71a:	e4a0      	b.n	3230a05e <_dtoa_r+0x556>
3230a71c:	460b      	mov	r3, r1
3230a71e:	e494      	b.n	3230a04a <_dtoa_r+0x542>
3230a720:	f8d8 1004 	ldr.w	r1, [r8, #4]
3230a724:	4620      	mov	r0, r4
3230a726:	f000 f8d9 	bl	3230a8dc <_Balloc>
3230a72a:	4605      	mov	r5, r0
3230a72c:	2800      	cmp	r0, #0
3230a72e:	f000 80bb 	beq.w	3230a8a8 <_dtoa_r+0xda0>
3230a732:	f8d8 3010 	ldr.w	r3, [r8, #16]
3230a736:	f108 010c 	add.w	r1, r8, #12
3230a73a:	300c      	adds	r0, #12
3230a73c:	3302      	adds	r3, #2
3230a73e:	009a      	lsls	r2, r3, #2
3230a740:	f7fa ecfe 	blx	32305140 <memcpy>
3230a744:	4629      	mov	r1, r5
3230a746:	2201      	movs	r2, #1
3230a748:	4620      	mov	r0, r4
3230a74a:	f000 fb7b 	bl	3230ae44 <__lshift>
3230a74e:	4682      	mov	sl, r0
3230a750:	e692      	b.n	3230a478 <_dtoa_r+0x970>
3230a752:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
3230a754:	9804      	ldr	r0, [sp, #16]
3230a756:	43d9      	mvns	r1, r3
3230a758:	280e      	cmp	r0, #14
3230a75a:	ea4f 71d1 	mov.w	r1, r1, lsr #31
3230a75e:	bfc8      	it	gt
3230a760:	2100      	movgt	r1, #0
3230a762:	2900      	cmp	r1, #0
3230a764:	f43f adbf 	beq.w	3230a2e6 <_dtoa_r+0x7de>
3230a768:	9b04      	ldr	r3, [sp, #16]
3230a76a:	f1bb 0f00 	cmp.w	fp, #0
3230a76e:	eb02 02c3 	add.w	r2, r2, r3, lsl #3
3230a772:	bfc8      	it	gt
3230a774:	2300      	movgt	r3, #0
3230a776:	bfd8      	it	le
3230a778:	2301      	movle	r3, #1
3230a77a:	ea13 73da 	ands.w	r3, r3, sl, lsr #31
3230a77e:	edd2 1b00 	vldr	d17, [r2]
3230a782:	d0b0      	beq.n	3230a6e6 <_dtoa_r+0xbde>
3230a784:	f1bb 0f00 	cmp.w	fp, #0
3230a788:	f47f addf 	bne.w	3230a34a <_dtoa_r+0x842>
3230a78c:	eef1 0b04 	vmov.f64	d16, #20	@ 0x40a00000  5.0
3230a790:	4659      	mov	r1, fp
3230a792:	ee61 1ba0 	vmul.f64	d17, d17, d16
3230a796:	eeb4 8be1 	vcmpe.f64	d8, d17
3230a79a:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a79e:	d806      	bhi.n	3230a7ae <_dtoa_r+0xca6>
3230a7a0:	4620      	mov	r0, r4
3230a7a2:	f1ca 0600 	rsb	r6, sl, #0
3230a7a6:	46bb      	mov	fp, r7
3230a7a8:	f000 f8c2 	bl	3230a930 <_Bfree>
3230a7ac:	e457      	b.n	3230a05e <_dtoa_r+0x556>
3230a7ae:	46bb      	mov	fp, r7
3230a7b0:	2331      	movs	r3, #49	@ 0x31
3230a7b2:	4620      	mov	r0, r4
3230a7b4:	f80b 3b01 	strb.w	r3, [fp], #1
3230a7b8:	f000 f8ba 	bl	3230a930 <_Bfree>
3230a7bc:	9e04      	ldr	r6, [sp, #16]
3230a7be:	3602      	adds	r6, #2
3230a7c0:	e44d      	b.n	3230a05e <_dtoa_r+0x556>
3230a7c2:	9807      	ldr	r0, [sp, #28]
3230a7c4:	42a8      	cmp	r0, r5
3230a7c6:	4603      	mov	r3, r0
3230a7c8:	eb00 010b 	add.w	r1, r0, fp
3230a7cc:	bfa8      	it	ge
3230a7ce:	462b      	movge	r3, r5
3230a7d0:	1aed      	subs	r5, r5, r3
3230a7d2:	1ac6      	subs	r6, r0, r3
3230a7d4:	1acb      	subs	r3, r1, r3
3230a7d6:	9307      	str	r3, [sp, #28]
3230a7d8:	e744      	b.n	3230a664 <_dtoa_r+0xb5c>
3230a7da:	ee38 8b08 	vadd.f64	d8, d8, d8
3230a7de:	9a04      	ldr	r2, [sp, #16]
3230a7e0:	1c56      	adds	r6, r2, #1
3230a7e2:	eeb4 8be1 	vcmpe.f64	d8, d17
3230a7e6:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a7ea:	dc08      	bgt.n	3230a7fe <_dtoa_r+0xcf6>
3230a7ec:	eeb4 8b61 	vcmp.f64	d8, d17
3230a7f0:	eef1 fa10 	vmrs	APSR_nzcv, fpscr
3230a7f4:	d106      	bne.n	3230a804 <_dtoa_r+0xcfc>
3230a7f6:	ee17 2a90 	vmov	r2, s15
3230a7fa:	07d1      	lsls	r1, r2, #31
3230a7fc:	d502      	bpl.n	3230a804 <_dtoa_r+0xcfc>
3230a7fe:	f8dd e010 	ldr.w	lr, [sp, #16]
3230a802:	e422      	b.n	3230a04a <_dtoa_r+0x542>
3230a804:	469b      	mov	fp, r3
3230a806:	e42a      	b.n	3230a05e <_dtoa_r+0x556>
3230a808:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230a80c:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230a810:	f64b 2074 	movw	r0, #47732	@ 0xba74
3230a814:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230a818:	2200      	movs	r2, #0
3230a81a:	f240 11af 	movw	r1, #431	@ 0x1af
3230a81e:	f7f7 fc45 	bl	323020ac <__assert_func>
3230a822:	9e04      	ldr	r6, [sp, #16]
3230a824:	463b      	mov	r3, r7
3230a826:	f8cd 8004 	str.w	r8, [sp, #4]
3230a82a:	46d0      	mov	r8, sl
3230a82c:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3230a82e:	3601      	adds	r6, #1
3230a830:	e46a      	b.n	3230a108 <_dtoa_r+0x600>
3230a832:	f64b 7238 	movw	r2, #48952	@ 0xbf38
3230a836:	f2c3 2230 	movt	r2, #12848	@ 0x3230
3230a83a:	e795      	b.n	3230a768 <_dtoa_r+0xc60>
3230a83c:	463b      	mov	r3, r7
3230a83e:	2a00      	cmp	r2, #0
3230a840:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3230a842:	f73f ae79 	bgt.w	3230a538 <_dtoa_r+0xa30>
3230a846:	e689      	b.n	3230a55c <_dtoa_r+0xa54>
3230a848:	9b03      	ldr	r3, [sp, #12]
3230a84a:	f023 4300 	bic.w	r3, r3, #2147483648	@ 0x80000000
3230a84e:	0d1b      	lsrs	r3, r3, #20
3230a850:	051b      	lsls	r3, r3, #20
3230a852:	2b00      	cmp	r3, #0
3230a854:	f43f ad38 	beq.w	3230a2c8 <_dtoa_r+0x7c0>
3230a858:	9b07      	ldr	r3, [sp, #28]
3230a85a:	3501      	adds	r5, #1
3230a85c:	3301      	adds	r3, #1
3230a85e:	9307      	str	r3, [sp, #28]
3230a860:	2301      	movs	r3, #1
3230a862:	9309      	str	r3, [sp, #36]	@ 0x24
3230a864:	e531      	b.n	3230a2ca <_dtoa_r+0x7c2>
3230a866:	463b      	mov	r3, r7
3230a868:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3230a86a:	e677      	b.n	3230a55c <_dtoa_r+0xa54>
3230a86c:	463b      	mov	r3, r7
3230a86e:	9f0a      	ldr	r7, [sp, #40]	@ 0x28
3230a870:	2b39      	cmp	r3, #57	@ 0x39
3230a872:	f43f ae95 	beq.w	3230a5a0 <_dtoa_r+0xa98>
3230a876:	2d00      	cmp	r5, #0
3230a878:	f73f ae6e 	bgt.w	3230a558 <_dtoa_r+0xa50>
3230a87c:	e66e      	b.n	3230a55c <_dtoa_r+0xa54>
3230a87e:	4619      	mov	r1, r3
3230a880:	e586      	b.n	3230a390 <_dtoa_r+0x888>
3230a882:	f8cd b010 	str.w	fp, [sp, #16]
3230a886:	f8dd b02c 	ldr.w	fp, [sp, #44]	@ 0x2c
3230a88a:	f7ff baac 	b.w	32309de6 <_dtoa_r+0x2de>
3230a88e:	2102      	movs	r1, #2
3230a890:	f7ff bb6c 	b.w	32309f6c <_dtoa_r+0x464>
3230a894:	f47f ae62 	bne.w	3230a55c <_dtoa_r+0xa54>
3230a898:	07da      	lsls	r2, r3, #31
3230a89a:	f57f ae5f 	bpl.w	3230a55c <_dtoa_r+0xa54>
3230a89e:	e659      	b.n	3230a554 <_dtoa_r+0xa4c>
3230a8a0:	2100      	movs	r1, #0
3230a8a2:	63e1      	str	r1, [r4, #60]	@ 0x3c
3230a8a4:	f7ff bb22 	b.w	32309eec <_dtoa_r+0x3e4>
3230a8a8:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230a8ac:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230a8b0:	f64b 2074 	movw	r0, #47732	@ 0xba74
3230a8b4:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230a8b8:	462a      	mov	r2, r5
3230a8ba:	f240 21ef 	movw	r1, #751	@ 0x2ef
3230a8be:	f7f7 fbf5 	bl	323020ac <__assert_func>
3230a8c2:	bf00      	nop

3230a8c4 <__env_lock>:
3230a8c4:	f245 304c 	movw	r0, #21324	@ 0x534c
3230a8c8:	f2c3 2031 	movt	r0, #12849	@ 0x3231
3230a8cc:	f7fa b9c4 	b.w	32304c58 <__retarget_lock_acquire_recursive>

3230a8d0 <__env_unlock>:
3230a8d0:	f245 304c 	movw	r0, #21324	@ 0x534c
3230a8d4:	f2c3 2031 	movt	r0, #12849	@ 0x3231
3230a8d8:	f7fa b9c6 	b.w	32304c68 <__retarget_lock_release_recursive>

3230a8dc <_Balloc>:
3230a8dc:	b538      	push	{r3, r4, r5, lr}
3230a8de:	4605      	mov	r5, r0
3230a8e0:	6c43      	ldr	r3, [r0, #68]	@ 0x44
3230a8e2:	460c      	mov	r4, r1
3230a8e4:	b163      	cbz	r3, 3230a900 <_Balloc+0x24>
3230a8e6:	f853 0024 	ldr.w	r0, [r3, r4, lsl #2]
3230a8ea:	b198      	cbz	r0, 3230a914 <_Balloc+0x38>
3230a8ec:	6802      	ldr	r2, [r0, #0]
3230a8ee:	f843 2024 	str.w	r2, [r3, r4, lsl #2]
3230a8f2:	efc0 0010 	vmov.i32	d16, #0	@ 0x00000000
3230a8f6:	f100 030c 	add.w	r3, r0, #12
3230a8fa:	f943 078f 	vst1.32	{d16}, [r3]
3230a8fe:	bd38      	pop	{r3, r4, r5, pc}
3230a900:	2221      	movs	r2, #33	@ 0x21
3230a902:	2104      	movs	r1, #4
3230a904:	f000 fe1e 	bl	3230b544 <_calloc_r>
3230a908:	4603      	mov	r3, r0
3230a90a:	6468      	str	r0, [r5, #68]	@ 0x44
3230a90c:	2800      	cmp	r0, #0
3230a90e:	d1ea      	bne.n	3230a8e6 <_Balloc+0xa>
3230a910:	2000      	movs	r0, #0
3230a912:	bd38      	pop	{r3, r4, r5, pc}
3230a914:	2101      	movs	r1, #1
3230a916:	4628      	mov	r0, r5
3230a918:	fa01 f504 	lsl.w	r5, r1, r4
3230a91c:	1d6a      	adds	r2, r5, #5
3230a91e:	0092      	lsls	r2, r2, #2
3230a920:	f000 fe10 	bl	3230b544 <_calloc_r>
3230a924:	2800      	cmp	r0, #0
3230a926:	d0f3      	beq.n	3230a910 <_Balloc+0x34>
3230a928:	e9c0 4501 	strd	r4, r5, [r0, #4]
3230a92c:	e7e1      	b.n	3230a8f2 <_Balloc+0x16>
3230a92e:	bf00      	nop

3230a930 <_Bfree>:
3230a930:	b131      	cbz	r1, 3230a940 <_Bfree+0x10>
3230a932:	6c43      	ldr	r3, [r0, #68]	@ 0x44
3230a934:	684a      	ldr	r2, [r1, #4]
3230a936:	f853 0022 	ldr.w	r0, [r3, r2, lsl #2]
3230a93a:	6008      	str	r0, [r1, #0]
3230a93c:	f843 1022 	str.w	r1, [r3, r2, lsl #2]
3230a940:	4770      	bx	lr
3230a942:	bf00      	nop

3230a944 <__multadd>:
3230a944:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
3230a948:	4607      	mov	r7, r0
3230a94a:	690d      	ldr	r5, [r1, #16]
3230a94c:	460e      	mov	r6, r1
3230a94e:	461c      	mov	r4, r3
3230a950:	f101 0e14 	add.w	lr, r1, #20
3230a954:	2000      	movs	r0, #0
3230a956:	f8de 1000 	ldr.w	r1, [lr]
3230a95a:	3001      	adds	r0, #1
3230a95c:	4285      	cmp	r5, r0
3230a95e:	b28b      	uxth	r3, r1
3230a960:	ea4f 4111 	mov.w	r1, r1, lsr #16
3230a964:	fb02 4303 	mla	r3, r2, r3, r4
3230a968:	ea4f 4c13 	mov.w	ip, r3, lsr #16
3230a96c:	b29b      	uxth	r3, r3
3230a96e:	fb02 cc01 	mla	ip, r2, r1, ip
3230a972:	eb03 430c 	add.w	r3, r3, ip, lsl #16
3230a976:	ea4f 441c 	mov.w	r4, ip, lsr #16
3230a97a:	f84e 3b04 	str.w	r3, [lr], #4
3230a97e:	dcea      	bgt.n	3230a956 <__multadd+0x12>
3230a980:	b13c      	cbz	r4, 3230a992 <__multadd+0x4e>
3230a982:	68b3      	ldr	r3, [r6, #8]
3230a984:	42ab      	cmp	r3, r5
3230a986:	dd07      	ble.n	3230a998 <__multadd+0x54>
3230a988:	eb06 0385 	add.w	r3, r6, r5, lsl #2
3230a98c:	3501      	adds	r5, #1
3230a98e:	615c      	str	r4, [r3, #20]
3230a990:	6135      	str	r5, [r6, #16]
3230a992:	4630      	mov	r0, r6
3230a994:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
3230a998:	6871      	ldr	r1, [r6, #4]
3230a99a:	4638      	mov	r0, r7
3230a99c:	3101      	adds	r1, #1
3230a99e:	f7ff ff9d 	bl	3230a8dc <_Balloc>
3230a9a2:	4680      	mov	r8, r0
3230a9a4:	b1a8      	cbz	r0, 3230a9d2 <__multadd+0x8e>
3230a9a6:	6932      	ldr	r2, [r6, #16]
3230a9a8:	f106 010c 	add.w	r1, r6, #12
3230a9ac:	300c      	adds	r0, #12
3230a9ae:	3202      	adds	r2, #2
3230a9b0:	0092      	lsls	r2, r2, #2
3230a9b2:	f7fa ebc6 	blx	32305140 <memcpy>
3230a9b6:	6c7b      	ldr	r3, [r7, #68]	@ 0x44
3230a9b8:	6872      	ldr	r2, [r6, #4]
3230a9ba:	f853 1022 	ldr.w	r1, [r3, r2, lsl #2]
3230a9be:	6031      	str	r1, [r6, #0]
3230a9c0:	f843 6022 	str.w	r6, [r3, r2, lsl #2]
3230a9c4:	4646      	mov	r6, r8
3230a9c6:	eb06 0385 	add.w	r3, r6, r5, lsl #2
3230a9ca:	3501      	adds	r5, #1
3230a9cc:	615c      	str	r4, [r3, #20]
3230a9ce:	6135      	str	r5, [r6, #16]
3230a9d0:	e7df      	b.n	3230a992 <__multadd+0x4e>
3230a9d2:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230a9d6:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230a9da:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230a9de:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230a9e2:	4642      	mov	r2, r8
3230a9e4:	21ba      	movs	r1, #186	@ 0xba
3230a9e6:	f7f7 fb61 	bl	323020ac <__assert_func>
3230a9ea:	bf00      	nop

3230a9ec <__s2b>:
3230a9ec:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
3230a9f0:	461e      	mov	r6, r3
3230a9f2:	4617      	mov	r7, r2
3230a9f4:	3308      	adds	r3, #8
3230a9f6:	f648 6239 	movw	r2, #36409	@ 0x8e39
3230a9fa:	f6c3 02e3 	movt	r2, #14563	@ 0x38e3
3230a9fe:	460c      	mov	r4, r1
3230aa00:	4605      	mov	r5, r0
3230aa02:	2e09      	cmp	r6, #9
3230aa04:	fb82 1203 	smull	r1, r2, r2, r3
3230aa08:	ea4f 73e3 	mov.w	r3, r3, asr #31
3230aa0c:	ebc3 0362 	rsb	r3, r3, r2, asr #1
3230aa10:	dd3b      	ble.n	3230aa8a <__s2b+0x9e>
3230aa12:	f04f 0c01 	mov.w	ip, #1
3230aa16:	2100      	movs	r1, #0
3230aa18:	ea4f 0c4c 	mov.w	ip, ip, lsl #1
3230aa1c:	3101      	adds	r1, #1
3230aa1e:	4563      	cmp	r3, ip
3230aa20:	dcfa      	bgt.n	3230aa18 <__s2b+0x2c>
3230aa22:	4628      	mov	r0, r5
3230aa24:	f7ff ff5a 	bl	3230a8dc <_Balloc>
3230aa28:	4601      	mov	r1, r0
3230aa2a:	b380      	cbz	r0, 3230aa8e <__s2b+0xa2>
3230aa2c:	9b08      	ldr	r3, [sp, #32]
3230aa2e:	2f09      	cmp	r7, #9
3230aa30:	6143      	str	r3, [r0, #20]
3230aa32:	bfd8      	it	le
3230aa34:	340a      	addle	r4, #10
3230aa36:	f04f 0301 	mov.w	r3, #1
3230aa3a:	bfd8      	it	le
3230aa3c:	2709      	movle	r7, #9
3230aa3e:	6103      	str	r3, [r0, #16]
3230aa40:	dc10      	bgt.n	3230aa64 <__s2b+0x78>
3230aa42:	42be      	cmp	r6, r7
3230aa44:	dd0b      	ble.n	3230aa5e <__s2b+0x72>
3230aa46:	1bf6      	subs	r6, r6, r7
3230aa48:	4426      	add	r6, r4
3230aa4a:	f814 3b01 	ldrb.w	r3, [r4], #1
3230aa4e:	220a      	movs	r2, #10
3230aa50:	4628      	mov	r0, r5
3230aa52:	3b30      	subs	r3, #48	@ 0x30
3230aa54:	f7ff ff76 	bl	3230a944 <__multadd>
3230aa58:	42b4      	cmp	r4, r6
3230aa5a:	4601      	mov	r1, r0
3230aa5c:	d1f5      	bne.n	3230aa4a <__s2b+0x5e>
3230aa5e:	4608      	mov	r0, r1
3230aa60:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
3230aa64:	f104 0809 	add.w	r8, r4, #9
3230aa68:	eb04 0907 	add.w	r9, r4, r7
3230aa6c:	4644      	mov	r4, r8
3230aa6e:	f814 3b01 	ldrb.w	r3, [r4], #1
3230aa72:	220a      	movs	r2, #10
3230aa74:	4628      	mov	r0, r5
3230aa76:	3b30      	subs	r3, #48	@ 0x30
3230aa78:	f7ff ff64 	bl	3230a944 <__multadd>
3230aa7c:	454c      	cmp	r4, r9
3230aa7e:	4601      	mov	r1, r0
3230aa80:	d1f5      	bne.n	3230aa6e <__s2b+0x82>
3230aa82:	44b8      	add	r8, r7
3230aa84:	f1a8 0408 	sub.w	r4, r8, #8
3230aa88:	e7db      	b.n	3230aa42 <__s2b+0x56>
3230aa8a:	2100      	movs	r1, #0
3230aa8c:	e7c9      	b.n	3230aa22 <__s2b+0x36>
3230aa8e:	460a      	mov	r2, r1
3230aa90:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230aa94:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230aa98:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230aa9c:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230aaa0:	21d3      	movs	r1, #211	@ 0xd3
3230aaa2:	f7f7 fb03 	bl	323020ac <__assert_func>
3230aaa6:	bf00      	nop

3230aaa8 <__hi0bits>:
3230aaa8:	f5b0 3f80 	cmp.w	r0, #65536	@ 0x10000
3230aaac:	4603      	mov	r3, r0
3230aaae:	bf38      	it	cc
3230aab0:	0403      	lslcc	r3, r0, #16
3230aab2:	bf28      	it	cs
3230aab4:	2000      	movcs	r0, #0
3230aab6:	bf38      	it	cc
3230aab8:	2010      	movcc	r0, #16
3230aaba:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
3230aabe:	d201      	bcs.n	3230aac4 <__hi0bits+0x1c>
3230aac0:	3008      	adds	r0, #8
3230aac2:	021b      	lsls	r3, r3, #8
3230aac4:	f1b3 5f80 	cmp.w	r3, #268435456	@ 0x10000000
3230aac8:	d306      	bcc.n	3230aad8 <__hi0bits+0x30>
3230aaca:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
3230aace:	d20f      	bcs.n	3230aaf0 <__hi0bits+0x48>
3230aad0:	009a      	lsls	r2, r3, #2
3230aad2:	d412      	bmi.n	3230aafa <__hi0bits+0x52>
3230aad4:	3003      	adds	r0, #3
3230aad6:	4770      	bx	lr
3230aad8:	011a      	lsls	r2, r3, #4
3230aada:	3004      	adds	r0, #4
3230aadc:	f1b2 4f80 	cmp.w	r2, #1073741824	@ 0x40000000
3230aae0:	d207      	bcs.n	3230aaf2 <__hi0bits+0x4a>
3230aae2:	019b      	lsls	r3, r3, #6
3230aae4:	d409      	bmi.n	3230aafa <__hi0bits+0x52>
3230aae6:	005b      	lsls	r3, r3, #1
3230aae8:	bf58      	it	pl
3230aaea:	2020      	movpl	r0, #32
3230aaec:	d4f2      	bmi.n	3230aad4 <__hi0bits+0x2c>
3230aaee:	4770      	bx	lr
3230aaf0:	461a      	mov	r2, r3
3230aaf2:	2a00      	cmp	r2, #0
3230aaf4:	dbfb      	blt.n	3230aaee <__hi0bits+0x46>
3230aaf6:	3001      	adds	r0, #1
3230aaf8:	4770      	bx	lr
3230aafa:	3002      	adds	r0, #2
3230aafc:	4770      	bx	lr
3230aafe:	bf00      	nop

3230ab00 <__lo0bits>:
3230ab00:	6803      	ldr	r3, [r0, #0]
3230ab02:	4602      	mov	r2, r0
3230ab04:	0759      	lsls	r1, r3, #29
3230ab06:	d007      	beq.n	3230ab18 <__lo0bits+0x18>
3230ab08:	07d8      	lsls	r0, r3, #31
3230ab0a:	d42e      	bmi.n	3230ab6a <__lo0bits+0x6a>
3230ab0c:	0799      	lsls	r1, r3, #30
3230ab0e:	d532      	bpl.n	3230ab76 <__lo0bits+0x76>
3230ab10:	085b      	lsrs	r3, r3, #1
3230ab12:	2001      	movs	r0, #1
3230ab14:	6013      	str	r3, [r2, #0]
3230ab16:	4770      	bx	lr
3230ab18:	b299      	uxth	r1, r3
3230ab1a:	b989      	cbnz	r1, 3230ab40 <__lo0bits+0x40>
3230ab1c:	0c1b      	lsrs	r3, r3, #16
3230ab1e:	2018      	movs	r0, #24
3230ab20:	b2d9      	uxtb	r1, r3
3230ab22:	bb21      	cbnz	r1, 3230ab6e <__lo0bits+0x6e>
3230ab24:	0a1b      	lsrs	r3, r3, #8
3230ab26:	0719      	lsls	r1, r3, #28
3230ab28:	bf08      	it	eq
3230ab2a:	3004      	addeq	r0, #4
3230ab2c:	d00d      	beq.n	3230ab4a <__lo0bits+0x4a>
3230ab2e:	0799      	lsls	r1, r3, #30
3230ab30:	d00e      	beq.n	3230ab50 <__lo0bits+0x50>
3230ab32:	07d9      	lsls	r1, r3, #31
3230ab34:	bf58      	it	pl
3230ab36:	3001      	addpl	r0, #1
3230ab38:	bf58      	it	pl
3230ab3a:	085b      	lsrpl	r3, r3, #1
3230ab3c:	6013      	str	r3, [r2, #0]
3230ab3e:	4770      	bx	lr
3230ab40:	b2d9      	uxtb	r1, r3
3230ab42:	b1b1      	cbz	r1, 3230ab72 <__lo0bits+0x72>
3230ab44:	0718      	lsls	r0, r3, #28
3230ab46:	d11a      	bne.n	3230ab7e <__lo0bits+0x7e>
3230ab48:	2004      	movs	r0, #4
3230ab4a:	091b      	lsrs	r3, r3, #4
3230ab4c:	0799      	lsls	r1, r3, #30
3230ab4e:	d1f0      	bne.n	3230ab32 <__lo0bits+0x32>
3230ab50:	f013 0f04 	tst.w	r3, #4
3230ab54:	ea4f 0193 	mov.w	r1, r3, lsr #2
3230ab58:	bf18      	it	ne
3230ab5a:	3002      	addne	r0, #2
3230ab5c:	bf18      	it	ne
3230ab5e:	460b      	movne	r3, r1
3230ab60:	d1ec      	bne.n	3230ab3c <__lo0bits+0x3c>
3230ab62:	08db      	lsrs	r3, r3, #3
3230ab64:	d10e      	bne.n	3230ab84 <__lo0bits+0x84>
3230ab66:	2020      	movs	r0, #32
3230ab68:	4770      	bx	lr
3230ab6a:	2000      	movs	r0, #0
3230ab6c:	4770      	bx	lr
3230ab6e:	2010      	movs	r0, #16
3230ab70:	e7d9      	b.n	3230ab26 <__lo0bits+0x26>
3230ab72:	2008      	movs	r0, #8
3230ab74:	e7d6      	b.n	3230ab24 <__lo0bits+0x24>
3230ab76:	089b      	lsrs	r3, r3, #2
3230ab78:	2002      	movs	r0, #2
3230ab7a:	6013      	str	r3, [r2, #0]
3230ab7c:	4770      	bx	lr
3230ab7e:	08db      	lsrs	r3, r3, #3
3230ab80:	2003      	movs	r0, #3
3230ab82:	e7db      	b.n	3230ab3c <__lo0bits+0x3c>
3230ab84:	3003      	adds	r0, #3
3230ab86:	e7d9      	b.n	3230ab3c <__lo0bits+0x3c>

3230ab88 <__i2b>:
3230ab88:	b538      	push	{r3, r4, r5, lr}
3230ab8a:	4604      	mov	r4, r0
3230ab8c:	6c43      	ldr	r3, [r0, #68]	@ 0x44
3230ab8e:	460d      	mov	r5, r1
3230ab90:	b15b      	cbz	r3, 3230abaa <__i2b+0x22>
3230ab92:	6858      	ldr	r0, [r3, #4]
3230ab94:	b1f0      	cbz	r0, 3230abd4 <__i2b+0x4c>
3230ab96:	6802      	ldr	r2, [r0, #0]
3230ab98:	605a      	str	r2, [r3, #4]
3230ab9a:	eddf 0b15 	vldr	d16, [pc, #84]	@ 3230abf0 <__i2b+0x68>
3230ab9e:	f100 030c 	add.w	r3, r0, #12
3230aba2:	6145      	str	r5, [r0, #20]
3230aba4:	f943 078f 	vst1.32	{d16}, [r3]
3230aba8:	bd38      	pop	{r3, r4, r5, pc}
3230abaa:	2221      	movs	r2, #33	@ 0x21
3230abac:	2104      	movs	r1, #4
3230abae:	f000 fcc9 	bl	3230b544 <_calloc_r>
3230abb2:	4603      	mov	r3, r0
3230abb4:	6460      	str	r0, [r4, #68]	@ 0x44
3230abb6:	2800      	cmp	r0, #0
3230abb8:	d1eb      	bne.n	3230ab92 <__i2b+0xa>
3230abba:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230abbe:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230abc2:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230abc6:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230abca:	2200      	movs	r2, #0
3230abcc:	f240 1145 	movw	r1, #325	@ 0x145
3230abd0:	f7f7 fa6c 	bl	323020ac <__assert_func>
3230abd4:	221c      	movs	r2, #28
3230abd6:	2101      	movs	r1, #1
3230abd8:	4620      	mov	r0, r4
3230abda:	f000 fcb3 	bl	3230b544 <_calloc_r>
3230abde:	2800      	cmp	r0, #0
3230abe0:	d0eb      	beq.n	3230abba <__i2b+0x32>
3230abe2:	eddf 0b05 	vldr	d16, [pc, #20]	@ 3230abf8 <__i2b+0x70>
3230abe6:	1d03      	adds	r3, r0, #4
3230abe8:	f943 078f 	vst1.32	{d16}, [r3]
3230abec:	e7d5      	b.n	3230ab9a <__i2b+0x12>
3230abee:	bf00      	nop
3230abf0:	00000000 	.word	0x00000000
3230abf4:	00000001 	.word	0x00000001
3230abf8:	00000001 	.word	0x00000001
3230abfc:	00000002 	.word	0x00000002

3230ac00 <__multiply>:
3230ac00:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
3230ac04:	4692      	mov	sl, r2
3230ac06:	690a      	ldr	r2, [r1, #16]
3230ac08:	460e      	mov	r6, r1
3230ac0a:	4651      	mov	r1, sl
3230ac0c:	f8da 3010 	ldr.w	r3, [sl, #16]
3230ac10:	b085      	sub	sp, #20
3230ac12:	429a      	cmp	r2, r3
3230ac14:	bfa8      	it	ge
3230ac16:	46b2      	movge	sl, r6
3230ac18:	bfb8      	it	lt
3230ac1a:	461d      	movlt	r5, r3
3230ac1c:	bfa8      	it	ge
3230ac1e:	4698      	movge	r8, r3
3230ac20:	bfa8      	it	ge
3230ac22:	460e      	movge	r6, r1
3230ac24:	bfa8      	it	ge
3230ac26:	4615      	movge	r5, r2
3230ac28:	bfb8      	it	lt
3230ac2a:	4690      	movlt	r8, r2
3230ac2c:	e9da 1301 	ldrd	r1, r3, [sl, #4]
3230ac30:	eb05 0408 	add.w	r4, r5, r8
3230ac34:	42a3      	cmp	r3, r4
3230ac36:	bfb8      	it	lt
3230ac38:	3101      	addlt	r1, #1
3230ac3a:	f7ff fe4f 	bl	3230a8dc <_Balloc>
3230ac3e:	4684      	mov	ip, r0
3230ac40:	2800      	cmp	r0, #0
3230ac42:	f000 808e 	beq.w	3230ad62 <__multiply+0x162>
3230ac46:	f100 0714 	add.w	r7, r0, #20
3230ac4a:	eb07 0e84 	add.w	lr, r7, r4, lsl #2
3230ac4e:	4577      	cmp	r7, lr
3230ac50:	bf38      	it	cc
3230ac52:	463b      	movcc	r3, r7
3230ac54:	bf38      	it	cc
3230ac56:	2200      	movcc	r2, #0
3230ac58:	d203      	bcs.n	3230ac62 <__multiply+0x62>
3230ac5a:	f843 2b04 	str.w	r2, [r3], #4
3230ac5e:	459e      	cmp	lr, r3
3230ac60:	d8fb      	bhi.n	3230ac5a <__multiply+0x5a>
3230ac62:	3614      	adds	r6, #20
3230ac64:	f10a 0914 	add.w	r9, sl, #20
3230ac68:	eb06 0888 	add.w	r8, r6, r8, lsl #2
3230ac6c:	eb09 0585 	add.w	r5, r9, r5, lsl #2
3230ac70:	4546      	cmp	r6, r8
3230ac72:	d267      	bcs.n	3230ad44 <__multiply+0x144>
3230ac74:	eba5 030a 	sub.w	r3, r5, sl
3230ac78:	f10a 0a15 	add.w	sl, sl, #21
3230ac7c:	3b15      	subs	r3, #21
3230ac7e:	f8cd e008 	str.w	lr, [sp, #8]
3230ac82:	f023 0303 	bic.w	r3, r3, #3
3230ac86:	46ae      	mov	lr, r5
3230ac88:	45aa      	cmp	sl, r5
3230ac8a:	bf88      	it	hi
3230ac8c:	2300      	movhi	r3, #0
3230ac8e:	9403      	str	r4, [sp, #12]
3230ac90:	469b      	mov	fp, r3
3230ac92:	46e2      	mov	sl, ip
3230ac94:	e004      	b.n	3230aca0 <__multiply+0xa0>
3230ac96:	0c09      	lsrs	r1, r1, #16
3230ac98:	d12c      	bne.n	3230acf4 <__multiply+0xf4>
3230ac9a:	3704      	adds	r7, #4
3230ac9c:	45b0      	cmp	r8, r6
3230ac9e:	d94e      	bls.n	3230ad3e <__multiply+0x13e>
3230aca0:	f856 1b04 	ldr.w	r1, [r6], #4
3230aca4:	b28d      	uxth	r5, r1
3230aca6:	2d00      	cmp	r5, #0
3230aca8:	d0f5      	beq.n	3230ac96 <__multiply+0x96>
3230acaa:	46cc      	mov	ip, r9
3230acac:	463c      	mov	r4, r7
3230acae:	2300      	movs	r3, #0
3230acb0:	9601      	str	r6, [sp, #4]
3230acb2:	f85c 0b04 	ldr.w	r0, [ip], #4
3230acb6:	6821      	ldr	r1, [r4, #0]
3230acb8:	45e6      	cmp	lr, ip
3230acba:	b286      	uxth	r6, r0
3230acbc:	ea4f 4010 	mov.w	r0, r0, lsr #16
3230acc0:	b28a      	uxth	r2, r1
3230acc2:	ea4f 4111 	mov.w	r1, r1, lsr #16
3230acc6:	fb05 2206 	mla	r2, r5, r6, r2
3230acca:	fb05 1100 	mla	r1, r5, r0, r1
3230acce:	441a      	add	r2, r3
3230acd0:	eb01 4112 	add.w	r1, r1, r2, lsr #16
3230acd4:	b292      	uxth	r2, r2
3230acd6:	ea42 4201 	orr.w	r2, r2, r1, lsl #16
3230acda:	ea4f 4311 	mov.w	r3, r1, lsr #16
3230acde:	f844 2b04 	str.w	r2, [r4], #4
3230ace2:	d8e6      	bhi.n	3230acb2 <__multiply+0xb2>
3230ace4:	eb07 020b 	add.w	r2, r7, fp
3230ace8:	9e01      	ldr	r6, [sp, #4]
3230acea:	6053      	str	r3, [r2, #4]
3230acec:	f856 1c04 	ldr.w	r1, [r6, #-4]
3230acf0:	0c09      	lsrs	r1, r1, #16
3230acf2:	d0d2      	beq.n	3230ac9a <__multiply+0x9a>
3230acf4:	683b      	ldr	r3, [r7, #0]
3230acf6:	2200      	movs	r2, #0
3230acf8:	4648      	mov	r0, r9
3230acfa:	463d      	mov	r5, r7
3230acfc:	461c      	mov	r4, r3
3230acfe:	4694      	mov	ip, r2
3230ad00:	8802      	ldrh	r2, [r0, #0]
3230ad02:	b29b      	uxth	r3, r3
3230ad04:	fb01 c202 	mla	r2, r1, r2, ip
3230ad08:	eb02 4214 	add.w	r2, r2, r4, lsr #16
3230ad0c:	ea43 4302 	orr.w	r3, r3, r2, lsl #16
3230ad10:	f845 3b04 	str.w	r3, [r5], #4
3230ad14:	f850 3b04 	ldr.w	r3, [r0], #4
3230ad18:	682c      	ldr	r4, [r5, #0]
3230ad1a:	4586      	cmp	lr, r0
3230ad1c:	ea4f 4c13 	mov.w	ip, r3, lsr #16
3230ad20:	b2a3      	uxth	r3, r4
3230ad22:	fb01 330c 	mla	r3, r1, ip, r3
3230ad26:	eb03 4312 	add.w	r3, r3, r2, lsr #16
3230ad2a:	ea4f 4c13 	mov.w	ip, r3, lsr #16
3230ad2e:	d8e7      	bhi.n	3230ad00 <__multiply+0x100>
3230ad30:	eb07 020b 	add.w	r2, r7, fp
3230ad34:	45b0      	cmp	r8, r6
3230ad36:	f107 0704 	add.w	r7, r7, #4
3230ad3a:	6053      	str	r3, [r2, #4]
3230ad3c:	d8b0      	bhi.n	3230aca0 <__multiply+0xa0>
3230ad3e:	e9dd e402 	ldrd	lr, r4, [sp, #8]
3230ad42:	46d4      	mov	ip, sl
3230ad44:	2c00      	cmp	r4, #0
3230ad46:	dc02      	bgt.n	3230ad4e <__multiply+0x14e>
3230ad48:	e005      	b.n	3230ad56 <__multiply+0x156>
3230ad4a:	3c01      	subs	r4, #1
3230ad4c:	d003      	beq.n	3230ad56 <__multiply+0x156>
3230ad4e:	f85e 3d04 	ldr.w	r3, [lr, #-4]!
3230ad52:	2b00      	cmp	r3, #0
3230ad54:	d0f9      	beq.n	3230ad4a <__multiply+0x14a>
3230ad56:	4660      	mov	r0, ip
3230ad58:	f8cc 4010 	str.w	r4, [ip, #16]
3230ad5c:	b005      	add	sp, #20
3230ad5e:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230ad62:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230ad66:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230ad6a:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230ad6e:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230ad72:	4662      	mov	r2, ip
3230ad74:	f44f 71b1 	mov.w	r1, #354	@ 0x162
3230ad78:	f7f7 f998 	bl	323020ac <__assert_func>

3230ad7c <__pow5mult>:
3230ad7c:	f012 0303 	ands.w	r3, r2, #3
3230ad80:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
3230ad84:	4614      	mov	r4, r2
3230ad86:	4607      	mov	r7, r0
3230ad88:	bf08      	it	eq
3230ad8a:	460e      	moveq	r6, r1
3230ad8c:	d131      	bne.n	3230adf2 <__pow5mult+0x76>
3230ad8e:	10a4      	asrs	r4, r4, #2
3230ad90:	d02c      	beq.n	3230adec <__pow5mult+0x70>
3230ad92:	6c3d      	ldr	r5, [r7, #64]	@ 0x40
3230ad94:	2d00      	cmp	r5, #0
3230ad96:	d038      	beq.n	3230ae0a <__pow5mult+0x8e>
3230ad98:	f004 0301 	and.w	r3, r4, #1
3230ad9c:	f04f 0800 	mov.w	r8, #0
3230ada0:	1064      	asrs	r4, r4, #1
3230ada2:	b93b      	cbnz	r3, 3230adb4 <__pow5mult+0x38>
3230ada4:	6828      	ldr	r0, [r5, #0]
3230ada6:	b1b8      	cbz	r0, 3230add8 <__pow5mult+0x5c>
3230ada8:	4605      	mov	r5, r0
3230adaa:	f004 0301 	and.w	r3, r4, #1
3230adae:	1064      	asrs	r4, r4, #1
3230adb0:	2b00      	cmp	r3, #0
3230adb2:	d0f7      	beq.n	3230ada4 <__pow5mult+0x28>
3230adb4:	462a      	mov	r2, r5
3230adb6:	4631      	mov	r1, r6
3230adb8:	4638      	mov	r0, r7
3230adba:	f7ff ff21 	bl	3230ac00 <__multiply>
3230adbe:	b136      	cbz	r6, 3230adce <__pow5mult+0x52>
3230adc0:	6c7b      	ldr	r3, [r7, #68]	@ 0x44
3230adc2:	6871      	ldr	r1, [r6, #4]
3230adc4:	f853 2021 	ldr.w	r2, [r3, r1, lsl #2]
3230adc8:	6032      	str	r2, [r6, #0]
3230adca:	f843 6021 	str.w	r6, [r3, r1, lsl #2]
3230adce:	b174      	cbz	r4, 3230adee <__pow5mult+0x72>
3230add0:	4606      	mov	r6, r0
3230add2:	6828      	ldr	r0, [r5, #0]
3230add4:	2800      	cmp	r0, #0
3230add6:	d1e7      	bne.n	3230ada8 <__pow5mult+0x2c>
3230add8:	462a      	mov	r2, r5
3230adda:	4629      	mov	r1, r5
3230addc:	4638      	mov	r0, r7
3230adde:	f7ff ff0f 	bl	3230ac00 <__multiply>
3230ade2:	6028      	str	r0, [r5, #0]
3230ade4:	4605      	mov	r5, r0
3230ade6:	f8c0 8000 	str.w	r8, [r0]
3230adea:	e7de      	b.n	3230adaa <__pow5mult+0x2e>
3230adec:	4630      	mov	r0, r6
3230adee:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
3230adf2:	3b01      	subs	r3, #1
3230adf4:	f64b 62d8 	movw	r2, #48856	@ 0xbed8
3230adf8:	f2c3 2230 	movt	r2, #12848	@ 0x3230
3230adfc:	f852 2023 	ldr.w	r2, [r2, r3, lsl #2]
3230ae00:	2300      	movs	r3, #0
3230ae02:	f7ff fd9f 	bl	3230a944 <__multadd>
3230ae06:	4606      	mov	r6, r0
3230ae08:	e7c1      	b.n	3230ad8e <__pow5mult+0x12>
3230ae0a:	2101      	movs	r1, #1
3230ae0c:	4638      	mov	r0, r7
3230ae0e:	f7ff fd65 	bl	3230a8dc <_Balloc>
3230ae12:	4605      	mov	r5, r0
3230ae14:	b140      	cbz	r0, 3230ae28 <__pow5mult+0xac>
3230ae16:	2301      	movs	r3, #1
3230ae18:	f240 2271 	movw	r2, #625	@ 0x271
3230ae1c:	e9c0 3204 	strd	r3, r2, [r0, #16]
3230ae20:	2300      	movs	r3, #0
3230ae22:	6438      	str	r0, [r7, #64]	@ 0x40
3230ae24:	6003      	str	r3, [r0, #0]
3230ae26:	e7b7      	b.n	3230ad98 <__pow5mult+0x1c>
3230ae28:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230ae2c:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230ae30:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230ae34:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230ae38:	462a      	mov	r2, r5
3230ae3a:	f240 1145 	movw	r1, #325	@ 0x145
3230ae3e:	f7f7 f935 	bl	323020ac <__assert_func>
3230ae42:	bf00      	nop

3230ae44 <__lshift>:
3230ae44:	e92d 47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
3230ae48:	460c      	mov	r4, r1
3230ae4a:	ea4f 1962 	mov.w	r9, r2, asr #5
3230ae4e:	6849      	ldr	r1, [r1, #4]
3230ae50:	4690      	mov	r8, r2
3230ae52:	6927      	ldr	r7, [r4, #16]
3230ae54:	4606      	mov	r6, r0
3230ae56:	68a3      	ldr	r3, [r4, #8]
3230ae58:	444f      	add	r7, r9
3230ae5a:	1c7d      	adds	r5, r7, #1
3230ae5c:	429d      	cmp	r5, r3
3230ae5e:	dd03      	ble.n	3230ae68 <__lshift+0x24>
3230ae60:	005b      	lsls	r3, r3, #1
3230ae62:	3101      	adds	r1, #1
3230ae64:	429d      	cmp	r5, r3
3230ae66:	dcfb      	bgt.n	3230ae60 <__lshift+0x1c>
3230ae68:	4630      	mov	r0, r6
3230ae6a:	f7ff fd37 	bl	3230a8dc <_Balloc>
3230ae6e:	4684      	mov	ip, r0
3230ae70:	2800      	cmp	r0, #0
3230ae72:	d04d      	beq.n	3230af10 <__lshift+0xcc>
3230ae74:	3014      	adds	r0, #20
3230ae76:	f1b9 0f00 	cmp.w	r9, #0
3230ae7a:	dd0b      	ble.n	3230ae94 <__lshift+0x50>
3230ae7c:	f109 0205 	add.w	r2, r9, #5
3230ae80:	4603      	mov	r3, r0
3230ae82:	2100      	movs	r1, #0
3230ae84:	eb0c 0282 	add.w	r2, ip, r2, lsl #2
3230ae88:	f843 1b04 	str.w	r1, [r3], #4
3230ae8c:	4293      	cmp	r3, r2
3230ae8e:	d1fb      	bne.n	3230ae88 <__lshift+0x44>
3230ae90:	eb00 0089 	add.w	r0, r0, r9, lsl #2
3230ae94:	6921      	ldr	r1, [r4, #16]
3230ae96:	f104 0314 	add.w	r3, r4, #20
3230ae9a:	f018 081f 	ands.w	r8, r8, #31
3230ae9e:	eb03 0181 	add.w	r1, r3, r1, lsl #2
3230aea2:	d02d      	beq.n	3230af00 <__lshift+0xbc>
3230aea4:	f1c8 0920 	rsb	r9, r8, #32
3230aea8:	4686      	mov	lr, r0
3230aeaa:	f04f 0a00 	mov.w	sl, #0
3230aeae:	681a      	ldr	r2, [r3, #0]
3230aeb0:	fa02 f208 	lsl.w	r2, r2, r8
3230aeb4:	ea42 020a 	orr.w	r2, r2, sl
3230aeb8:	f84e 2b04 	str.w	r2, [lr], #4
3230aebc:	f853 2b04 	ldr.w	r2, [r3], #4
3230aec0:	428b      	cmp	r3, r1
3230aec2:	fa22 fa09 	lsr.w	sl, r2, r9
3230aec6:	d3f2      	bcc.n	3230aeae <__lshift+0x6a>
3230aec8:	1b0b      	subs	r3, r1, r4
3230aeca:	f104 0215 	add.w	r2, r4, #21
3230aece:	3b15      	subs	r3, #21
3230aed0:	f023 0303 	bic.w	r3, r3, #3
3230aed4:	4291      	cmp	r1, r2
3230aed6:	bf38      	it	cc
3230aed8:	2300      	movcc	r3, #0
3230aeda:	3304      	adds	r3, #4
3230aedc:	f840 a003 	str.w	sl, [r0, r3]
3230aee0:	f1ba 0f00 	cmp.w	sl, #0
3230aee4:	d100      	bne.n	3230aee8 <__lshift+0xa4>
3230aee6:	463d      	mov	r5, r7
3230aee8:	6c73      	ldr	r3, [r6, #68]	@ 0x44
3230aeea:	4660      	mov	r0, ip
3230aeec:	6862      	ldr	r2, [r4, #4]
3230aeee:	f8cc 5010 	str.w	r5, [ip, #16]
3230aef2:	f853 1022 	ldr.w	r1, [r3, r2, lsl #2]
3230aef6:	6021      	str	r1, [r4, #0]
3230aef8:	f843 4022 	str.w	r4, [r3, r2, lsl #2]
3230aefc:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}
3230af00:	3804      	subs	r0, #4
3230af02:	f853 2b04 	ldr.w	r2, [r3], #4
3230af06:	f840 2f04 	str.w	r2, [r0, #4]!
3230af0a:	4299      	cmp	r1, r3
3230af0c:	d8f9      	bhi.n	3230af02 <__lshift+0xbe>
3230af0e:	e7ea      	b.n	3230aee6 <__lshift+0xa2>
3230af10:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230af14:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230af18:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230af1c:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230af20:	4662      	mov	r2, ip
3230af22:	f44f 71ef 	mov.w	r1, #478	@ 0x1de
3230af26:	f7f7 f8c1 	bl	323020ac <__assert_func>
3230af2a:	bf00      	nop

3230af2c <__mcmp>:
3230af2c:	690b      	ldr	r3, [r1, #16]
3230af2e:	4684      	mov	ip, r0
3230af30:	6900      	ldr	r0, [r0, #16]
3230af32:	1ac0      	subs	r0, r0, r3
3230af34:	d118      	bne.n	3230af68 <__mcmp+0x3c>
3230af36:	009b      	lsls	r3, r3, #2
3230af38:	f10c 0c14 	add.w	ip, ip, #20
3230af3c:	3114      	adds	r1, #20
3230af3e:	eb0c 0203 	add.w	r2, ip, r3
3230af42:	b410      	push	{r4}
3230af44:	440b      	add	r3, r1
3230af46:	e001      	b.n	3230af4c <__mcmp+0x20>
3230af48:	4594      	cmp	ip, r2
3230af4a:	d20a      	bcs.n	3230af62 <__mcmp+0x36>
3230af4c:	f852 4d04 	ldr.w	r4, [r2, #-4]!
3230af50:	f853 1d04 	ldr.w	r1, [r3, #-4]!
3230af54:	428c      	cmp	r4, r1
3230af56:	d0f7      	beq.n	3230af48 <__mcmp+0x1c>
3230af58:	bf28      	it	cs
3230af5a:	2001      	movcs	r0, #1
3230af5c:	d201      	bcs.n	3230af62 <__mcmp+0x36>
3230af5e:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
3230af62:	f85d 4b04 	ldr.w	r4, [sp], #4
3230af66:	4770      	bx	lr
3230af68:	4770      	bx	lr
3230af6a:	bf00      	nop

3230af6c <__mdiff>:
3230af6c:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
3230af70:	4689      	mov	r9, r1
3230af72:	690d      	ldr	r5, [r1, #16]
3230af74:	6913      	ldr	r3, [r2, #16]
3230af76:	b083      	sub	sp, #12
3230af78:	4614      	mov	r4, r2
3230af7a:	1aed      	subs	r5, r5, r3
3230af7c:	2d00      	cmp	r5, #0
3230af7e:	d113      	bne.n	3230afa8 <__mdiff+0x3c>
3230af80:	009b      	lsls	r3, r3, #2
3230af82:	f101 0714 	add.w	r7, r1, #20
3230af86:	f102 0114 	add.w	r1, r2, #20
3230af8a:	4419      	add	r1, r3
3230af8c:	443b      	add	r3, r7
3230af8e:	e001      	b.n	3230af94 <__mdiff+0x28>
3230af90:	429f      	cmp	r7, r3
3230af92:	d27e      	bcs.n	3230b092 <__mdiff+0x126>
3230af94:	f853 6d04 	ldr.w	r6, [r3, #-4]!
3230af98:	f851 2d04 	ldr.w	r2, [r1, #-4]!
3230af9c:	4296      	cmp	r6, r2
3230af9e:	d0f7      	beq.n	3230af90 <__mdiff+0x24>
3230afa0:	f080 8084 	bcs.w	3230b0ac <__mdiff+0x140>
3230afa4:	2501      	movs	r5, #1
3230afa6:	e003      	b.n	3230afb0 <__mdiff+0x44>
3230afa8:	dbfc      	blt.n	3230afa4 <__mdiff+0x38>
3230afaa:	2500      	movs	r5, #0
3230afac:	460c      	mov	r4, r1
3230afae:	4691      	mov	r9, r2
3230afb0:	6861      	ldr	r1, [r4, #4]
3230afb2:	f7ff fc93 	bl	3230a8dc <_Balloc>
3230afb6:	4601      	mov	r1, r0
3230afb8:	2800      	cmp	r0, #0
3230afba:	f000 808a 	beq.w	3230b0d2 <__mdiff+0x166>
3230afbe:	6927      	ldr	r7, [r4, #16]
3230afc0:	f104 0b14 	add.w	fp, r4, #20
3230afc4:	60c5      	str	r5, [r0, #12]
3230afc6:	f104 0210 	add.w	r2, r4, #16
3230afca:	f8d9 0010 	ldr.w	r0, [r9, #16]
3230afce:	f109 0514 	add.w	r5, r9, #20
3230afd2:	f101 0a14 	add.w	sl, r1, #20
3230afd6:	eb0b 0e87 	add.w	lr, fp, r7, lsl #2
3230afda:	46d0      	mov	r8, sl
3230afdc:	2300      	movs	r3, #0
3230afde:	eb05 0080 	add.w	r0, r5, r0, lsl #2
3230afe2:	4694      	mov	ip, r2
3230afe4:	f8cd b004 	str.w	fp, [sp, #4]
3230afe8:	f855 6b04 	ldr.w	r6, [r5], #4
3230afec:	f85c 2f04 	ldr.w	r2, [ip, #4]!
3230aff0:	42a8      	cmp	r0, r5
3230aff2:	fa1f fb86 	uxth.w	fp, r6
3230aff6:	b294      	uxth	r4, r2
3230aff8:	eba4 040b 	sub.w	r4, r4, fp
3230affc:	441c      	add	r4, r3
3230affe:	ea4f 4316 	mov.w	r3, r6, lsr #16
3230b002:	ebc3 4312 	rsb	r3, r3, r2, lsr #16
3230b006:	eb03 4324 	add.w	r3, r3, r4, asr #16
3230b00a:	b2a4      	uxth	r4, r4
3230b00c:	ea44 4403 	orr.w	r4, r4, r3, lsl #16
3230b010:	ea4f 4323 	mov.w	r3, r3, asr #16
3230b014:	f848 4b04 	str.w	r4, [r8], #4
3230b018:	d8e6      	bhi.n	3230afe8 <__mdiff+0x7c>
3230b01a:	eba0 0209 	sub.w	r2, r0, r9
3230b01e:	f8dd b004 	ldr.w	fp, [sp, #4]
3230b022:	3a15      	subs	r2, #21
3230b024:	f109 0915 	add.w	r9, r9, #21
3230b028:	f022 0203 	bic.w	r2, r2, #3
3230b02c:	4626      	mov	r6, r4
3230b02e:	4548      	cmp	r0, r9
3230b030:	bf38      	it	cc
3230b032:	2200      	movcc	r2, #0
3230b034:	eb0b 0402 	add.w	r4, fp, r2
3230b038:	4452      	add	r2, sl
3230b03a:	3404      	adds	r4, #4
3230b03c:	1d15      	adds	r5, r2, #4
3230b03e:	4620      	mov	r0, r4
3230b040:	45a6      	cmp	lr, r4
3230b042:	d937      	bls.n	3230b0b4 <__mdiff+0x148>
3230b044:	ebaa 0a0b 	sub.w	sl, sl, fp
3230b048:	eb00 0c0a 	add.w	ip, r0, sl
3230b04c:	f850 2b04 	ldr.w	r2, [r0], #4
3230b050:	18d6      	adds	r6, r2, r3
3230b052:	4586      	cmp	lr, r0
3230b054:	fa13 f382 	uxtah	r3, r3, r2
3230b058:	ea4f 4212 	mov.w	r2, r2, lsr #16
3230b05c:	b2b6      	uxth	r6, r6
3230b05e:	eb02 4223 	add.w	r2, r2, r3, asr #16
3230b062:	ea46 4602 	orr.w	r6, r6, r2, lsl #16
3230b066:	ea4f 4322 	mov.w	r3, r2, asr #16
3230b06a:	f8cc 6000 	str.w	r6, [ip]
3230b06e:	d8eb      	bhi.n	3230b048 <__mdiff+0xdc>
3230b070:	f10e 33ff 	add.w	r3, lr, #4294967295	@ 0xffffffff
3230b074:	1b1b      	subs	r3, r3, r4
3230b076:	f023 0303 	bic.w	r3, r3, #3
3230b07a:	442b      	add	r3, r5
3230b07c:	b926      	cbnz	r6, 3230b088 <__mdiff+0x11c>
3230b07e:	f853 2d04 	ldr.w	r2, [r3, #-4]!
3230b082:	3f01      	subs	r7, #1
3230b084:	2a00      	cmp	r2, #0
3230b086:	d0fa      	beq.n	3230b07e <__mdiff+0x112>
3230b088:	4608      	mov	r0, r1
3230b08a:	610f      	str	r7, [r1, #16]
3230b08c:	b003      	add	sp, #12
3230b08e:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230b092:	2100      	movs	r1, #0
3230b094:	f7ff fc22 	bl	3230a8dc <_Balloc>
3230b098:	4601      	mov	r1, r0
3230b09a:	b168      	cbz	r0, 3230b0b8 <__mdiff+0x14c>
3230b09c:	2201      	movs	r2, #1
3230b09e:	2300      	movs	r3, #0
3230b0a0:	e9c0 2304 	strd	r2, r3, [r0, #16]
3230b0a4:	4608      	mov	r0, r1
3230b0a6:	b003      	add	sp, #12
3230b0a8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230b0ac:	4623      	mov	r3, r4
3230b0ae:	464c      	mov	r4, r9
3230b0b0:	4699      	mov	r9, r3
3230b0b2:	e77d      	b.n	3230afb0 <__mdiff+0x44>
3230b0b4:	4613      	mov	r3, r2
3230b0b6:	e7e1      	b.n	3230b07c <__mdiff+0x110>
3230b0b8:	460a      	mov	r2, r1
3230b0ba:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230b0be:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230b0c2:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230b0c6:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230b0ca:	f240 2137 	movw	r1, #567	@ 0x237
3230b0ce:	f7f6 ffed 	bl	323020ac <__assert_func>
3230b0d2:	460a      	mov	r2, r1
3230b0d4:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230b0d8:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230b0dc:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230b0e0:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230b0e4:	f240 2145 	movw	r1, #581	@ 0x245
3230b0e8:	f7f6 ffe0 	bl	323020ac <__assert_func>

3230b0ec <__ulp>:
3230b0ec:	b082      	sub	sp, #8
3230b0ee:	2300      	movs	r3, #0
3230b0f0:	f6c7 73f0 	movt	r3, #32752	@ 0x7ff0
3230b0f4:	ed8d 0b00 	vstr	d0, [sp]
3230b0f8:	9a01      	ldr	r2, [sp, #4]
3230b0fa:	4013      	ands	r3, r2
3230b0fc:	f1a3 7350 	sub.w	r3, r3, #54525952	@ 0x3400000
3230b100:	2b00      	cmp	r3, #0
3230b102:	bfc8      	it	gt
3230b104:	2200      	movgt	r2, #0
3230b106:	dd05      	ble.n	3230b114 <__ulp+0x28>
3230b108:	4619      	mov	r1, r3
3230b10a:	4610      	mov	r0, r2
3230b10c:	ec41 0b10 	vmov	d0, r0, r1
3230b110:	b002      	add	sp, #8
3230b112:	4770      	bx	lr
3230b114:	425b      	negs	r3, r3
3230b116:	f1b3 7fa0 	cmp.w	r3, #20971520	@ 0x1400000
3230b11a:	ea4f 5123 	mov.w	r1, r3, asr #20
3230b11e:	da09      	bge.n	3230b134 <__ulp+0x48>
3230b120:	f44f 2300 	mov.w	r3, #524288	@ 0x80000
3230b124:	2200      	movs	r2, #0
3230b126:	4610      	mov	r0, r2
3230b128:	410b      	asrs	r3, r1
3230b12a:	4619      	mov	r1, r3
3230b12c:	ec41 0b10 	vmov	d0, r0, r1
3230b130:	b002      	add	sp, #8
3230b132:	4770      	bx	lr
3230b134:	3914      	subs	r1, #20
3230b136:	f04f 4200 	mov.w	r2, #2147483648	@ 0x80000000
3230b13a:	291e      	cmp	r1, #30
3230b13c:	f04f 0300 	mov.w	r3, #0
3230b140:	fa22 f201 	lsr.w	r2, r2, r1
3230b144:	bfc8      	it	gt
3230b146:	2201      	movgt	r2, #1
3230b148:	4619      	mov	r1, r3
3230b14a:	4610      	mov	r0, r2
3230b14c:	ec41 0b10 	vmov	d0, r0, r1
3230b150:	b002      	add	sp, #8
3230b152:	4770      	bx	lr

3230b154 <__b2d>:
3230b154:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
3230b156:	f100 0614 	add.w	r6, r0, #20
3230b15a:	6904      	ldr	r4, [r0, #16]
3230b15c:	eb06 0484 	add.w	r4, r6, r4, lsl #2
3230b160:	1f27      	subs	r7, r4, #4
3230b162:	f854 5c04 	ldr.w	r5, [r4, #-4]
3230b166:	4628      	mov	r0, r5
3230b168:	f7ff fc9e 	bl	3230aaa8 <__hi0bits>
3230b16c:	f1c0 0320 	rsb	r3, r0, #32
3230b170:	280a      	cmp	r0, #10
3230b172:	600b      	str	r3, [r1, #0]
3230b174:	dd2c      	ble.n	3230b1d0 <__b2d+0x7c>
3230b176:	f1a0 010b 	sub.w	r1, r0, #11
3230b17a:	42be      	cmp	r6, r7
3230b17c:	d21c      	bcs.n	3230b1b8 <__b2d+0x64>
3230b17e:	f854 0c08 	ldr.w	r0, [r4, #-8]
3230b182:	b1e9      	cbz	r1, 3230b1c0 <__b2d+0x6c>
3230b184:	f1c1 0c20 	rsb	ip, r1, #32
3230b188:	408d      	lsls	r5, r1
3230b18a:	f1a4 0708 	sub.w	r7, r4, #8
3230b18e:	fa20 f30c 	lsr.w	r3, r0, ip
3230b192:	42be      	cmp	r6, r7
3230b194:	ea45 0503 	orr.w	r5, r5, r3
3230b198:	fa00 f001 	lsl.w	r0, r0, r1
3230b19c:	f045 537f 	orr.w	r3, r5, #1069547520	@ 0x3fc00000
3230b1a0:	f443 1340 	orr.w	r3, r3, #3145728	@ 0x300000
3230b1a4:	d210      	bcs.n	3230b1c8 <__b2d+0x74>
3230b1a6:	f854 1c0c 	ldr.w	r1, [r4, #-12]
3230b1aa:	fa21 f10c 	lsr.w	r1, r1, ip
3230b1ae:	4308      	orrs	r0, r1
3230b1b0:	4602      	mov	r2, r0
3230b1b2:	ec43 2b10 	vmov	d0, r2, r3
3230b1b6:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3230b1b8:	280b      	cmp	r0, #11
3230b1ba:	bf08      	it	eq
3230b1bc:	2000      	moveq	r0, #0
3230b1be:	d11f      	bne.n	3230b200 <__b2d+0xac>
3230b1c0:	f045 537f 	orr.w	r3, r5, #1069547520	@ 0x3fc00000
3230b1c4:	f443 1340 	orr.w	r3, r3, #3145728	@ 0x300000
3230b1c8:	4602      	mov	r2, r0
3230b1ca:	ec43 2b10 	vmov	d0, r2, r3
3230b1ce:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3230b1d0:	f1c0 0c0b 	rsb	ip, r0, #11
3230b1d4:	42be      	cmp	r6, r7
3230b1d6:	fa25 f10c 	lsr.w	r1, r5, ip
3230b1da:	f041 537f 	orr.w	r3, r1, #1069547520	@ 0x3fc00000
3230b1de:	bf28      	it	cs
3230b1e0:	2100      	movcs	r1, #0
3230b1e2:	f443 1340 	orr.w	r3, r3, #3145728	@ 0x300000
3230b1e6:	d203      	bcs.n	3230b1f0 <__b2d+0x9c>
3230b1e8:	f854 1c08 	ldr.w	r1, [r4, #-8]
3230b1ec:	fa21 f10c 	lsr.w	r1, r1, ip
3230b1f0:	3015      	adds	r0, #21
3230b1f2:	fa05 f000 	lsl.w	r0, r5, r0
3230b1f6:	4308      	orrs	r0, r1
3230b1f8:	4602      	mov	r2, r0
3230b1fa:	ec43 2b10 	vmov	d0, r2, r3
3230b1fe:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3230b200:	fa05 f101 	lsl.w	r1, r5, r1
3230b204:	2000      	movs	r0, #0
3230b206:	f041 537f 	orr.w	r3, r1, #1069547520	@ 0x3fc00000
3230b20a:	4602      	mov	r2, r0
3230b20c:	f443 1340 	orr.w	r3, r3, #3145728	@ 0x300000
3230b210:	ec43 2b10 	vmov	d0, r2, r3
3230b214:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
3230b216:	bf00      	nop

3230b218 <__d2b>:
3230b218:	e92d 43f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, lr}
3230b21c:	460e      	mov	r6, r1
3230b21e:	2101      	movs	r1, #1
3230b220:	b083      	sub	sp, #12
3230b222:	ec59 8b10 	vmov	r8, r9, d0
3230b226:	4615      	mov	r5, r2
3230b228:	f7ff fb58 	bl	3230a8dc <_Balloc>
3230b22c:	4607      	mov	r7, r0
3230b22e:	2800      	cmp	r0, #0
3230b230:	d045      	beq.n	3230b2be <__d2b+0xa6>
3230b232:	f3c9 0313 	ubfx	r3, r9, #0, #20
3230b236:	f3c9 540a 	ubfx	r4, r9, #20, #11
3230b23a:	b10c      	cbz	r4, 3230b240 <__d2b+0x28>
3230b23c:	f443 1380 	orr.w	r3, r3, #1048576	@ 0x100000
3230b240:	9301      	str	r3, [sp, #4]
3230b242:	f1b8 0300 	subs.w	r3, r8, #0
3230b246:	d113      	bne.n	3230b270 <__d2b+0x58>
3230b248:	a801      	add	r0, sp, #4
3230b24a:	f7ff fc59 	bl	3230ab00 <__lo0bits>
3230b24e:	9b01      	ldr	r3, [sp, #4]
3230b250:	2101      	movs	r1, #1
3230b252:	3020      	adds	r0, #32
3230b254:	617b      	str	r3, [r7, #20]
3230b256:	6139      	str	r1, [r7, #16]
3230b258:	b314      	cbz	r4, 3230b2a0 <__d2b+0x88>
3230b25a:	f2a4 4433 	subw	r4, r4, #1075	@ 0x433
3230b25e:	4404      	add	r4, r0
3230b260:	f1c0 0035 	rsb	r0, r0, #53	@ 0x35
3230b264:	6034      	str	r4, [r6, #0]
3230b266:	6028      	str	r0, [r5, #0]
3230b268:	4638      	mov	r0, r7
3230b26a:	b003      	add	sp, #12
3230b26c:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
3230b270:	4668      	mov	r0, sp
3230b272:	9300      	str	r3, [sp, #0]
3230b274:	f7ff fc44 	bl	3230ab00 <__lo0bits>
3230b278:	e9dd 2300 	ldrd	r2, r3, [sp]
3230b27c:	b130      	cbz	r0, 3230b28c <__d2b+0x74>
3230b27e:	f1c0 0120 	rsb	r1, r0, #32
3230b282:	fa03 f101 	lsl.w	r1, r3, r1
3230b286:	430a      	orrs	r2, r1
3230b288:	40c3      	lsrs	r3, r0
3230b28a:	9301      	str	r3, [sp, #4]
3230b28c:	2b00      	cmp	r3, #0
3230b28e:	f04f 0101 	mov.w	r1, #1
3230b292:	617a      	str	r2, [r7, #20]
3230b294:	bf18      	it	ne
3230b296:	2102      	movne	r1, #2
3230b298:	61bb      	str	r3, [r7, #24]
3230b29a:	6139      	str	r1, [r7, #16]
3230b29c:	2c00      	cmp	r4, #0
3230b29e:	d1dc      	bne.n	3230b25a <__d2b+0x42>
3230b2a0:	eb07 0381 	add.w	r3, r7, r1, lsl #2
3230b2a4:	f2a0 4032 	subw	r0, r0, #1074	@ 0x432
3230b2a8:	6030      	str	r0, [r6, #0]
3230b2aa:	6918      	ldr	r0, [r3, #16]
3230b2ac:	f7ff fbfc 	bl	3230aaa8 <__hi0bits>
3230b2b0:	ebc0 1041 	rsb	r0, r0, r1, lsl #5
3230b2b4:	6028      	str	r0, [r5, #0]
3230b2b6:	4638      	mov	r0, r7
3230b2b8:	b003      	add	sp, #12
3230b2ba:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
3230b2be:	f64b 2360 	movw	r3, #47712	@ 0xba60
3230b2c2:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230b2c6:	f64b 20d0 	movw	r0, #47824	@ 0xbad0
3230b2ca:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230b2ce:	463a      	mov	r2, r7
3230b2d0:	f240 310f 	movw	r1, #783	@ 0x30f
3230b2d4:	f7f6 feea 	bl	323020ac <__assert_func>

3230b2d8 <__ratio>:
3230b2d8:	b5f0      	push	{r4, r5, r6, r7, lr}
3230b2da:	460e      	mov	r6, r1
3230b2dc:	4607      	mov	r7, r0
3230b2de:	b083      	sub	sp, #12
3230b2e0:	4669      	mov	r1, sp
3230b2e2:	f7ff ff37 	bl	3230b154 <__b2d>
3230b2e6:	a901      	add	r1, sp, #4
3230b2e8:	4630      	mov	r0, r6
3230b2ea:	eeb0 7b40 	vmov.f64	d7, d0
3230b2ee:	ec55 4b10 	vmov	r4, r5, d0
3230b2f2:	f7ff ff2f 	bl	3230b154 <__b2d>
3230b2f6:	6933      	ldr	r3, [r6, #16]
3230b2f8:	693a      	ldr	r2, [r7, #16]
3230b2fa:	1ad2      	subs	r2, r2, r3
3230b2fc:	e9dd 3100 	ldrd	r3, r1, [sp]
3230b300:	1a5b      	subs	r3, r3, r1
3230b302:	eb03 1342 	add.w	r3, r3, r2, lsl #5
3230b306:	2b00      	cmp	r3, #0
3230b308:	dd09      	ble.n	3230b31e <__ratio+0x46>
3230b30a:	ee17 2a90 	vmov	r2, s15
3230b30e:	eb02 5503 	add.w	r5, r2, r3, lsl #20
3230b312:	ec45 4b17 	vmov	d7, r4, r5
3230b316:	ee87 0b00 	vdiv.f64	d0, d7, d0
3230b31a:	b003      	add	sp, #12
3230b31c:	bdf0      	pop	{r4, r5, r6, r7, pc}
3230b31e:	ec51 0b10 	vmov	r0, r1, d0
3230b322:	ee10 2a90 	vmov	r2, s1
3230b326:	eba2 5103 	sub.w	r1, r2, r3, lsl #20
3230b32a:	ec41 0b10 	vmov	d0, r0, r1
3230b32e:	ee87 0b00 	vdiv.f64	d0, d7, d0
3230b332:	b003      	add	sp, #12
3230b334:	bdf0      	pop	{r4, r5, r6, r7, pc}
3230b336:	bf00      	nop

3230b338 <_mprec_log10>:
3230b338:	2817      	cmp	r0, #23
3230b33a:	eeb7 0b00 	vmov.f64	d0, #112	@ 0x3f800000  1.0
3230b33e:	eef2 0b04 	vmov.f64	d16, #36	@ 0x41200000  10.0
3230b342:	dd04      	ble.n	3230b34e <_mprec_log10+0x16>
3230b344:	ee20 0b20 	vmul.f64	d0, d0, d16
3230b348:	3801      	subs	r0, #1
3230b34a:	d1fb      	bne.n	3230b344 <_mprec_log10+0xc>
3230b34c:	4770      	bx	lr
3230b34e:	f64b 7338 	movw	r3, #48952	@ 0xbf38
3230b352:	f2c3 2330 	movt	r3, #12848	@ 0x3230
3230b356:	eb03 03c0 	add.w	r3, r3, r0, lsl #3
3230b35a:	ed93 0b00 	vldr	d0, [r3]
3230b35e:	4770      	bx	lr

3230b360 <__copybits>:
3230b360:	3901      	subs	r1, #1
3230b362:	f102 0314 	add.w	r3, r2, #20
3230b366:	ea4f 1c61 	mov.w	ip, r1, asr #5
3230b36a:	6911      	ldr	r1, [r2, #16]
3230b36c:	f10c 0c01 	add.w	ip, ip, #1
3230b370:	eb03 0181 	add.w	r1, r3, r1, lsl #2
3230b374:	eb00 0c8c 	add.w	ip, r0, ip, lsl #2
3230b378:	428b      	cmp	r3, r1
3230b37a:	d216      	bcs.n	3230b3aa <__copybits+0x4a>
3230b37c:	b510      	push	{r4, lr}
3230b37e:	f1a0 0e04 	sub.w	lr, r0, #4
3230b382:	f853 4b04 	ldr.w	r4, [r3], #4
3230b386:	f84e 4f04 	str.w	r4, [lr, #4]!
3230b38a:	4299      	cmp	r1, r3
3230b38c:	d8f9      	bhi.n	3230b382 <__copybits+0x22>
3230b38e:	1a89      	subs	r1, r1, r2
3230b390:	3004      	adds	r0, #4
3230b392:	3915      	subs	r1, #21
3230b394:	f021 0103 	bic.w	r1, r1, #3
3230b398:	4408      	add	r0, r1
3230b39a:	4584      	cmp	ip, r0
3230b39c:	d904      	bls.n	3230b3a8 <__copybits+0x48>
3230b39e:	2300      	movs	r3, #0
3230b3a0:	f840 3b04 	str.w	r3, [r0], #4
3230b3a4:	4584      	cmp	ip, r0
3230b3a6:	d8fb      	bhi.n	3230b3a0 <__copybits+0x40>
3230b3a8:	bd10      	pop	{r4, pc}
3230b3aa:	4584      	cmp	ip, r0
3230b3ac:	d905      	bls.n	3230b3ba <__copybits+0x5a>
3230b3ae:	2300      	movs	r3, #0
3230b3b0:	f840 3b04 	str.w	r3, [r0], #4
3230b3b4:	4584      	cmp	ip, r0
3230b3b6:	d8fb      	bhi.n	3230b3b0 <__copybits+0x50>
3230b3b8:	4770      	bx	lr
3230b3ba:	4770      	bx	lr

3230b3bc <__any_on>:
3230b3bc:	6903      	ldr	r3, [r0, #16]
3230b3be:	114a      	asrs	r2, r1, #5
3230b3c0:	f100 0c14 	add.w	ip, r0, #20
3230b3c4:	4293      	cmp	r3, r2
3230b3c6:	da09      	bge.n	3230b3dc <__any_on+0x20>
3230b3c8:	eb0c 0383 	add.w	r3, ip, r3, lsl #2
3230b3cc:	e002      	b.n	3230b3d4 <__any_on+0x18>
3230b3ce:	f853 2d04 	ldr.w	r2, [r3, #-4]!
3230b3d2:	b982      	cbnz	r2, 3230b3f6 <__any_on+0x3a>
3230b3d4:	4563      	cmp	r3, ip
3230b3d6:	d8fa      	bhi.n	3230b3ce <__any_on+0x12>
3230b3d8:	2000      	movs	r0, #0
3230b3da:	4770      	bx	lr
3230b3dc:	eb0c 0382 	add.w	r3, ip, r2, lsl #2
3230b3e0:	ddf8      	ble.n	3230b3d4 <__any_on+0x18>
3230b3e2:	f011 011f 	ands.w	r1, r1, #31
3230b3e6:	d0f5      	beq.n	3230b3d4 <__any_on+0x18>
3230b3e8:	f85c 0022 	ldr.w	r0, [ip, r2, lsl #2]
3230b3ec:	fa20 f201 	lsr.w	r2, r0, r1
3230b3f0:	408a      	lsls	r2, r1
3230b3f2:	4290      	cmp	r0, r2
3230b3f4:	d0ee      	beq.n	3230b3d4 <__any_on+0x18>
3230b3f6:	2001      	movs	r0, #1
3230b3f8:	4770      	bx	lr
3230b3fa:	bf00      	nop

3230b3fc <_wcsnrtombs_l>:
3230b3fc:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
3230b400:	461c      	mov	r4, r3
3230b402:	b08b      	sub	sp, #44	@ 0x2c
3230b404:	e9dd 8915 	ldrd	r8, r9, [sp, #84]	@ 0x54
3230b408:	9002      	str	r0, [sp, #8]
3230b40a:	9f14      	ldr	r7, [sp, #80]	@ 0x50
3230b40c:	f1b8 0f00 	cmp.w	r8, #0
3230b410:	d050      	beq.n	3230b4b4 <_wcsnrtombs_l+0xb8>
3230b412:	6816      	ldr	r6, [r2, #0]
3230b414:	2900      	cmp	r1, #0
3230b416:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
3230b41a:	46c3      	mov	fp, r8
3230b41c:	bf08      	it	eq
3230b41e:	461f      	moveq	r7, r3
3230b420:	2500      	movs	r5, #0
3230b422:	4692      	mov	sl, r2
3230b424:	4688      	mov	r8, r1
3230b426:	9601      	str	r6, [sp, #4]
3230b428:	9103      	str	r1, [sp, #12]
3230b42a:	e007      	b.n	3230b43c <_wcsnrtombs_l+0x40>
3230b42c:	9b01      	ldr	r3, [sp, #4]
3230b42e:	3c01      	subs	r4, #1
3230b430:	f853 0b04 	ldr.w	r0, [r3], #4
3230b434:	9301      	str	r3, [sp, #4]
3230b436:	2800      	cmp	r0, #0
3230b438:	d04a      	beq.n	3230b4d0 <_wcsnrtombs_l+0xd4>
3230b43a:	4665      	mov	r5, ip
3230b43c:	42af      	cmp	r7, r5
3230b43e:	d935      	bls.n	3230b4ac <_wcsnrtombs_l+0xb0>
3230b440:	2c00      	cmp	r4, #0
3230b442:	d033      	beq.n	3230b4ac <_wcsnrtombs_l+0xb0>
3230b444:	f8db 3000 	ldr.w	r3, [fp]
3230b448:	a906      	add	r1, sp, #24
3230b44a:	9304      	str	r3, [sp, #16]
3230b44c:	f8db 3004 	ldr.w	r3, [fp, #4]
3230b450:	9305      	str	r3, [sp, #20]
3230b452:	9b01      	ldr	r3, [sp, #4]
3230b454:	9802      	ldr	r0, [sp, #8]
3230b456:	f8d9 60e0 	ldr.w	r6, [r9, #224]	@ 0xe0
3230b45a:	681a      	ldr	r2, [r3, #0]
3230b45c:	465b      	mov	r3, fp
3230b45e:	47b0      	blx	r6
3230b460:	1c43      	adds	r3, r0, #1
3230b462:	d01c      	beq.n	3230b49e <_wcsnrtombs_l+0xa2>
3230b464:	eb00 0c05 	add.w	ip, r0, r5
3230b468:	45bc      	cmp	ip, r7
3230b46a:	d826      	bhi.n	3230b4ba <_wcsnrtombs_l+0xbe>
3230b46c:	9b03      	ldr	r3, [sp, #12]
3230b46e:	2b00      	cmp	r3, #0
3230b470:	d0dc      	beq.n	3230b42c <_wcsnrtombs_l+0x30>
3230b472:	2800      	cmp	r0, #0
3230b474:	dd0d      	ble.n	3230b492 <_wcsnrtombs_l+0x96>
3230b476:	f108 32ff 	add.w	r2, r8, #4294967295	@ 0xffffffff
3230b47a:	9e01      	ldr	r6, [sp, #4]
3230b47c:	a906      	add	r1, sp, #24
3230b47e:	eb02 0e00 	add.w	lr, r2, r0
3230b482:	f811 3b01 	ldrb.w	r3, [r1], #1
3230b486:	f802 3f01 	strb.w	r3, [r2, #1]!
3230b48a:	4572      	cmp	r2, lr
3230b48c:	d1f9      	bne.n	3230b482 <_wcsnrtombs_l+0x86>
3230b48e:	4480      	add	r8, r0
3230b490:	9601      	str	r6, [sp, #4]
3230b492:	f8da 2000 	ldr.w	r2, [sl]
3230b496:	3204      	adds	r2, #4
3230b498:	f8ca 2000 	str.w	r2, [sl]
3230b49c:	e7c6      	b.n	3230b42c <_wcsnrtombs_l+0x30>
3230b49e:	9b02      	ldr	r3, [sp, #8]
3230b4a0:	4605      	mov	r5, r0
3230b4a2:	218a      	movs	r1, #138	@ 0x8a
3230b4a4:	2200      	movs	r2, #0
3230b4a6:	6019      	str	r1, [r3, #0]
3230b4a8:	f8cb 2000 	str.w	r2, [fp]
3230b4ac:	4628      	mov	r0, r5
3230b4ae:	b00b      	add	sp, #44	@ 0x2c
3230b4b0:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230b4b4:	f500 7886 	add.w	r8, r0, #268	@ 0x10c
3230b4b8:	e7ab      	b.n	3230b412 <_wcsnrtombs_l+0x16>
3230b4ba:	46d8      	mov	r8, fp
3230b4bc:	f8dd a010 	ldr.w	sl, [sp, #16]
3230b4c0:	f8dd b014 	ldr.w	fp, [sp, #20]
3230b4c4:	4628      	mov	r0, r5
3230b4c6:	e9c8 ab00 	strd	sl, fp, [r8]
3230b4ca:	b00b      	add	sp, #44	@ 0x2c
3230b4cc:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
3230b4d0:	9903      	ldr	r1, [sp, #12]
3230b4d2:	46d8      	mov	r8, fp
3230b4d4:	b109      	cbz	r1, 3230b4da <_wcsnrtombs_l+0xde>
3230b4d6:	f8ca 0000 	str.w	r0, [sl]
3230b4da:	f10c 35ff 	add.w	r5, ip, #4294967295	@ 0xffffffff
3230b4de:	2200      	movs	r2, #0
3230b4e0:	4628      	mov	r0, r5
3230b4e2:	f8c8 2000 	str.w	r2, [r8]
3230b4e6:	b00b      	add	sp, #44	@ 0x2c
3230b4e8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}

3230b4ec <_wcsnrtombs_r>:
3230b4ec:	b510      	push	{r4, lr}
3230b4ee:	f24c 1410 	movw	r4, #49424	@ 0xc110
3230b4f2:	f2c3 2430 	movt	r4, #12848	@ 0x3230
3230b4f6:	b084      	sub	sp, #16
3230b4f8:	9806      	ldr	r0, [sp, #24]
3230b4fa:	9000      	str	r0, [sp, #0]
3230b4fc:	9807      	ldr	r0, [sp, #28]
3230b4fe:	9001      	str	r0, [sp, #4]
3230b500:	f24c 20a0 	movw	r0, #49824	@ 0xc2a0
3230b504:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230b508:	9402      	str	r4, [sp, #8]
3230b50a:	6800      	ldr	r0, [r0, #0]
3230b50c:	f7ff ff76 	bl	3230b3fc <_wcsnrtombs_l>
3230b510:	b004      	add	sp, #16
3230b512:	bd10      	pop	{r4, pc}

3230b514 <wcsnrtombs>:
3230b514:	b510      	push	{r4, lr}
3230b516:	4694      	mov	ip, r2
3230b518:	461c      	mov	r4, r3
3230b51a:	b084      	sub	sp, #16
3230b51c:	4663      	mov	r3, ip
3230b51e:	9a06      	ldr	r2, [sp, #24]
3230b520:	9201      	str	r2, [sp, #4]
3230b522:	460a      	mov	r2, r1
3230b524:	4601      	mov	r1, r0
3230b526:	f24c 20a0 	movw	r0, #49824	@ 0xc2a0
3230b52a:	f2c3 2030 	movt	r0, #12848	@ 0x3230
3230b52e:	9400      	str	r4, [sp, #0]
3230b530:	f24c 1410 	movw	r4, #49424	@ 0xc110
3230b534:	f2c3 2430 	movt	r4, #12848	@ 0x3230
3230b538:	9402      	str	r4, [sp, #8]
3230b53a:	6800      	ldr	r0, [r0, #0]
3230b53c:	f7ff ff5e 	bl	3230b3fc <_wcsnrtombs_l>
3230b540:	b004      	add	sp, #16
3230b542:	bd10      	pop	{r4, pc}

3230b544 <_calloc_r>:
3230b544:	b538      	push	{r3, r4, r5, lr}
3230b546:	fba1 1402 	umull	r1, r4, r1, r2
3230b54a:	bb4c      	cbnz	r4, 3230b5a0 <_calloc_r+0x5c>
3230b54c:	f7fa fa9c 	bl	32305a88 <_malloc_r>
3230b550:	4605      	mov	r5, r0
3230b552:	b348      	cbz	r0, 3230b5a8 <_calloc_r+0x64>
3230b554:	f850 2c04 	ldr.w	r2, [r0, #-4]
3230b558:	f022 0203 	bic.w	r2, r2, #3
3230b55c:	3a04      	subs	r2, #4
3230b55e:	2a24      	cmp	r2, #36	@ 0x24
3230b560:	d819      	bhi.n	3230b596 <_calloc_r+0x52>
3230b562:	2a13      	cmp	r2, #19
3230b564:	bf98      	it	ls
3230b566:	4603      	movls	r3, r0
3230b568:	d90d      	bls.n	3230b586 <_calloc_r+0x42>
3230b56a:	efc0 0010 	vmov.i32	d16, #0	@ 0x00000000
3230b56e:	f100 0308 	add.w	r3, r0, #8
3230b572:	2a1b      	cmp	r2, #27
3230b574:	f940 078f 	vst1.32	{d16}, [r0]
3230b578:	d905      	bls.n	3230b586 <_calloc_r+0x42>
3230b57a:	f943 078f 	vst1.32	{d16}, [r3]
3230b57e:	2a24      	cmp	r2, #36	@ 0x24
3230b580:	f100 0310 	add.w	r3, r0, #16
3230b584:	d013      	beq.n	3230b5ae <_calloc_r+0x6a>
3230b586:	efc0 0010 	vmov.i32	d16, #0	@ 0x00000000
3230b58a:	2200      	movs	r2, #0
3230b58c:	4628      	mov	r0, r5
3230b58e:	609a      	str	r2, [r3, #8]
3230b590:	f943 078f 	vst1.32	{d16}, [r3]
3230b594:	bd38      	pop	{r3, r4, r5, pc}
3230b596:	4621      	mov	r1, r4
3230b598:	f7f8 fd66 	bl	32304068 <memset>
3230b59c:	4628      	mov	r0, r5
3230b59e:	bd38      	pop	{r3, r4, r5, pc}
3230b5a0:	f7f9 fb4a 	bl	32304c38 <__errno>
3230b5a4:	230c      	movs	r3, #12
3230b5a6:	6003      	str	r3, [r0, #0]
3230b5a8:	2500      	movs	r5, #0
3230b5aa:	4628      	mov	r0, r5
3230b5ac:	bd38      	pop	{r3, r4, r5, pc}
3230b5ae:	f100 0210 	add.w	r2, r0, #16
3230b5b2:	f100 0318 	add.w	r3, r0, #24
3230b5b6:	f942 078f 	vst1.32	{d16}, [r2]
3230b5ba:	e7e4      	b.n	3230b586 <_calloc_r+0x42>
3230b5bc:	0000      	movs	r0, r0
	...

3230b5c0 <___getpid_from_thumb>:
3230b5c0:	4778      	bx	pc
3230b5c2:	e7fd      	b.n	3230b5c0 <___getpid_from_thumb>
3230b5c4:	eaffd370 	b	3230038c <_getpid>

3230b5c8 <__puts_from_arm>:
3230b5c8:	e51ff004 	ldr	pc, [pc, #-4]	@ 3230b5cc <__puts_from_arm+0x4>
3230b5cc:	32303dd9 	.word	0x32303dd9
