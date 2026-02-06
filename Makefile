export BENCHMARKS_ROOT=$(realpath .)

# Setup baremetal-runtime build
bmrt_dir:=$(BENCHMARKS_ROOT)/src/baremetal-runtime
bench_helper_dir:=$(BENCHMARKS_ROOT)/src/plat-helpers
PLATFORM?=rh850-u2a16
GUEST1_ARGS ?=
GUEST2_ARGS ?=
NATIVE_ARGS ?=

-include $(BENCHMARKS_ROOT)/make-helpers/$(PLATFORM).mk

ctx-switch:
	make -C src/ctx-switch bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir) \
		PLATFORM=$(PLATFORM) \
		GUEST1_ARGS=$(GUEST1_ARGS) GUEST2_ARGS=$(GUEST2_ARGS)

ctx-switch-clean:
	make -C src/ctx-switch bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir) \
		PLATFORM=$(PLATFORM) \
		clean

irq-lat:
	make -C src/irq-lat bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir) \
		PLATFORM=$(PLATFORM) \
		GUEST1_ARGS=$(GUEST1_ARGS) NATIVE_ARGS=$(NATIVE_ARGS)

irq-lat-clean:
	make -C src/irq-lat bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir) \
		PLATFORM=$(PLATFORM) \
		clean

irq-lat-wce:
	make -C src/irq-lat-wce bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir) \
		PLATFORM=$(PLATFORM) \
		GUEST1_ARGS=$(GUEST1_ARGS) GUEST2_ARGS=$(GUEST2_ARGS)

irq-lat-wce-clean:
	make -C src/irq-lat-wce bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir) \
		PLATFORM=$(PLATFORM) \
		clean

clean: ctx-switch-clean irq-lat-clean irq-lat-wce-clean
	
