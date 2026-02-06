#include <init_platform.h>
#include <platform.h>
#include <bao.h>

#define RH850_MMIO_BASE (0xFF000000)
/* #define RH850_MMIO_END  (0xFFFFFFFF) */
/* #define RH850_MMIO_SIZE (RH850_MMIO_END - RH850_MMIO_END) */

void platform_custom_init(void);

void platform_config_init(void)
{
    if (cpu_is_master()) {
        vaddr_t rh850_u2a16_mmio = mem_alloc_map_dev(&cpu()->as,
                SEC_HYP_PRIVATE, RH850_MMIO_BASE, RH850_MMIO_BASE,
                0x40000);

        platform_custom_init();
        mem_unmap(&cpu()->as, rh850_u2a16_mmio, 0x40000, true);
    }

    cpu_sync_and_clear_msgs(&cpu_glb_sync);
}
