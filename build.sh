#!/bin/sh
nasm -f elf64 -g -F dwarf topological-sort.asm -o topological-sort.o && \
gcc  -DASM_VER -g topological-sort.c topological-sort.o -no-pie -fno-pic -o t
