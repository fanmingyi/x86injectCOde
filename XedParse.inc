ifndef _XEDPARSE_H
_XEDPARSE_H equ 0

include windows.inc



XEDPARSE_MAXBUFSIZE equ 256
XEDPARSE_MAXASMSIZE equ 16


XEDPARSE_ERROR equ 0
XEDPARSE_OK equ 1



XEDPARSE struc 8

     x64 dd 0; // use 64-bit instructions
     cip dq 0; //instruction pointer (for relative addressing)
     dest_size dd 0; //destination size (returned by XEDParse)
     cbUnknown dd 0; //unknown operand callback
     dest db XEDPARSE_MAXASMSIZE dup(0); //destination buffer
     instr_ db XEDPARSE_MAXBUFSIZE dup(0); //instruction text
     error db XEDPARSE_MAXBUFSIZE dup(0); //error text (in case of an error)

XEDPARSE ends




XEDParseAssemble proto C  XEDParse:DWORD

includelib XEDParse_x86.lib
endif