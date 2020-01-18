# aarch64-mmu-testing

Some testing with how to set up the Memory Management Unit on Aarch64. Targets
should run on Qemu.

## Build

To build you need to have a cross-compiler, specified with target
`aarch64-none-elf` in Makefile. Then build targets with:

~~~
make
~~~

## Run

Below is an example of running the highmem target.

~~~
$ make run-highmem-4kb-1gb-32addr
qemu-system-aarch64 -nographic -M virt -cpu cortex-a53 -m 32 -kernel highmem-4kb-1gb-32addr.elf
ABCX
~~~
