#ifndef __ARCH_BAO_H__
#define __ARCH_BAO_H__

#define BAO_YIELD_HYPCALL_ID  3
#define BAO_CACHE_FLUSH_HYPCALL_ID  4

static inline unsigned int bao_hypercall(unsigned long id)
{
    register unsigned long r6 asm("r6") = id;
    register unsigned long r10 asm("r10");
    __asm__ volatile ("hvtrap 0" : : "r"(r6));
    return r10;
}


#endif /* __ARCH_BAO_H__ */
