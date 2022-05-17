
CC	= gcc
CXX	= g++
ASM32	= yasm -f elf32 -DYASM
ASM64	= yasm -f elf64 -DYASM -D__x86_64__ -DPIC

CFLAGS	= -g -Wall -masm=intel -fno-stack-protector
CFLAGS_TEST	= -c -g -Wall -fno-stack-protector -nostdlib -I. -I.. -DUSEMINI

PROGS = libmini64.a libmini.so start.o sleep1.o write1.o alarm1.o alarm2.o alarm3.o jmp1.o jmp2.o

all: $(PROGS)

%.o: %.asm
	$(ASM64) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS_TEST) $<

libmini64.a: libmini64.asm libmini.c
	$(CC) -c $(CFLAGS) -fPIC -nostdlib libmini.c
	$(ASM64) $< -o libmini64.o
	ar rc libmini64.a libmini64.o libmini.o

libmini.so: libmini64.a
	ld -shared libmini64.o libmini.o -o libmini.so

start.o: start.asm
	$(ASM64)  $< -o $@

clean:
	rm -f a.out *.o $(PROGS) peda-*