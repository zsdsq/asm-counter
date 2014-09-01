run: link
	./main main.asm

main: main.asm
	nasm -f elf main.asm

putchar: putchar.asm
	nasm -f elf putchar.asm

printint: printint.asm
	nasm -f elf printint.asm

link: main printint putchar
	ld -m elf_i386 -s -o main main.o printint.o putchar.o
