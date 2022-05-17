# MiniLibC

test case :  write1, alarm1, alarm2, alarm3, jmp1 and jmp2

```bash
$ make		# Makefile to generate `libmini.so`
$ yasm -f elf64 -DYASM -D__x86_64__ -DPIC start.asm -o start.o # generate start.o (_start, main)
$ ld -m elf_x86_64 --dynamic-linker /lib64/ld-linux-x86-64.so.2 -o <test case>  <test case>.o start.o -L. -L.. -lmini
$ LD_LIBRARY_PATH=. ./<test case>
```
