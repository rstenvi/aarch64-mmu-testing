CC := aarch64-none-elf-gcc
LD := aarch64-none-elf-ld

ASM_SOURCES = $(wildcard *.S)
OBJ = ${ASM_SOURCES:.S=.o}

C_SOURCES = $(wildcard *.c)
OBJC = ${C_SOURCES:.c=.o}

ASFLAGS += -mcpu=cortex-a72 -march=armv8-a -D vmm

all: idmap-4kb-1gb-32addr.elf highmem-4kb-1gb-32addr.elf

DEPS := $(OBJC:.o=.d)
-include $(DEPS)

idmap-4kb-1gb-32addr.elf: idmap-4kb-1gb-32addr.o idmap-4kb-1gb-32addr.ld kstart.o
	$(LD) -T idmap-4kb-1gb-32addr.ld idmap-4kb-1gb-32addr.o kstart.o -static -o idmap-4kb-1gb-32addr.elf

highmem-4kb-1gb-32addr.elf: highmem-4kb-1gb-32addr.o highmem-4kb-1gb-32addr.ld kstart.o
	$(LD) -T highmem-4kb-1gb-32addr.ld highmem-4kb-1gb-32addr.o kstart.o -static -o highmem-4kb-1gb-32addr.elf

run-%:
	qemu-system-aarch64 -nographic -M virt -cpu cortex-a53 -m 32 -kernel $*.elf

clean:
	-rm -f *.o *.d *.elf
