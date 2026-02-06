
all:
	make -C irq-lat-wce-guest1 bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir)  \
		PLATFORM=$(PLATFORM) \
		SINGLE_CORE=y \
		$(GUEST1_ARGS)
	make -C irq-lat-wce-guest2 bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir)  \
		PLATFORM=$(PLATFORM) \
		SINGLE_CORE=y \
		$(GUEST2_ARGS)

clean:
	make -C irq-lat-wce-guest1 bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir)  \
		PLATFORM=$(PLATFORM) \
		clean
	make -C irq-lat-wce-guest2 bmrt_dir=$(bmrt_dir) bench_helper_dir=$(bench_helper_dir)  \
		PLATFORM=$(PLATFORM) \
		clean


