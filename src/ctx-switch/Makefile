
all:
	make -C ctx-switch-guest1 bmrt_dir=$(bmrt_dir) PLATFORM=$(PLATFORM) \
		SINGLE_CORE=y $(GUEST1_ARGS)
	make -C ctx-switch-guest2 bmrt_dir=$(bmrt_dir) PLATFORM=$(PLATFORM) \
		SINGLE_CORE=y $(GUEST2_ARGS)

clean:
	make -C ctx-switch-guest1 bmrt_dir=$(bmrt_dir) PLATFORM=$(PLATFORM) \
		SINGLE_CORE=y \
		clean
	make -C ctx-switch-guest2 bmrt_dir=$(bmrt_dir) PLATFORM=$(PLATFORM) \
		SINGLE_CORE=y \
		clean
