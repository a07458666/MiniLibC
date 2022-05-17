
CC	= gcc
CXX	= g++
ASM32	= yasm -f elf32 -DYASM
ASM64	= yasm -f elf64 -DYASM -D__x86_64__ -DPIC

CFLAGS	= -g -Wall -masm=intel -fno-stack-protector
CFLAGS_TEST	= -c -g -Wall -fno-stack-protector -nostdlib -I. -I.. -DUSEMINI

PROGS = libmini64.a libmini.so start.o 
TASK_CASE = sleep1 write1 alarm1 alarm2 alarm3 jmp1 jmp2
all: $(PROGS) $(TASK_CASE)

%.o: %.asm
	$(ASM64) $< -o $@

%: %.c
	$(CC) -c $(CFLAGS_TEST) $<
	ld -m elf_x86_64 --dynamic-linker /lib64/ld-linux-x86-64.so.2 -o $@ $@.o start.o -L. -L.. -lmini
	rm $@.o

libmini64.a: libmini64.asm libmini.c
	$(CC) -c $(CFLAGS) -fPIC -nostdlib libmini.c
	$(ASM64) $< -o libmini64.o
	ar rc libmini64.a libmini64.o libmini.o

libmini.so: libmini64.a
	ld -shared libmini64.o libmini.o -o libmini.so

start.o: start.asm
	$(ASM64)  $< -o $@

clean:
	rm -f *.o $(PROGS) $(TASK_CASE) peda-*