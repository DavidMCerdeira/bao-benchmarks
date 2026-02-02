
all:
	make -C irq-lat-guest bmrt_dir=$(bmrt_dir) PLATFORM=$(PLATFORM) \
		SINGLE_CORE=y \
		$(GUEST1_ARGS)
	make -C irq-lat-native bmrt_dir=$(bmrt_dir) PLATFORM=$(PLATFORM) \
		SINGLE_CORE=y \
		$(NATIVE_ARGS)

clean:
	make -C irq-lat-guest bmrt_dir=$(bmrt_dir) PLATFORM=$(PLATFORM) \
		clean
	make -C irq-lat-native bmrt_dir=$(bmrt_dir) PLATFORM=$(PLATFORM) \
		clean
