FILES= ./build/kernel.asm.o ./build/kernel.o
FLAGS= -g -ffreestanding -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

all:
	mkdir -p ./bin ./build
	nasm -f bin ./src/Boot.asm -o ./bin/boot.bin
	nasm -f elf -g ./src/Kernel.asm -o ./build/kernel.asm.o
	i686-elf-gcc -I./src $(FLAGS) -std=gnu99 -c ./src/Kernel.c -o ./build/kernel.o
	i686-elf-ld -g -relocatable $(FILES) -o ./build/completeKernel.o
	i686-elf-gcc $(FLAGS) -T ./src/linkerScript.ld -o ./build/kernel.elf ./build/completeKernel.o
	i686-elf-objcopy -O binary ./build/kernel.elf ./bin/kernel.bin
	rm -f ./bin/os.bin
	cat ./bin/boot.bin ./bin/kernel.bin > ./bin/os.bin
	dd if=/dev/zero bs=512 count=8 >> ./bin/os.bin

clean:
	rm -f ./bin/boot.bin
	rm -f ./bin/kernel.bin
	rm -f ./bin/os.bin
	rm -f ./build/kernel.asm.o
	rm -f ./build/kernel.o
	rm -f ./build/completeKernel.o
	rm -f ./build/kernel.elf	
