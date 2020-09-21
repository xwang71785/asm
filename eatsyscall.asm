; Executable name : EATSYSCALL
; Version : Assembly X86-32 NASM 2.14.02
; Author : Assembly Languange step by step
; Description : A simple assembly app demonstrating the 
; use of Linux INT 80H syscalls to display text.
; Build using these commands:
; nasm -f elf64 -g -F stabs eatsyscall.asm
; ld -o eatsyscall eatsyscall.o
;------------------------------------------------------------

			SECTION .data ; Section containing initialized data
MyByte:		db 0E3H			; 8 bits in size, db defines memory spaces
MyWord:		dw 0AF43H		; 16 bits in size
MyDouble:	dd 0BF87AD43H	; 32 bits in size

EatMsg: 	db "Eat at Joe’s!",10
EatLen: 	equ $-EatMsg	; equ defines variables
Dataset:	dw 3, 67, 34, 222, 4, 75, 54, 34, 44, 33, 22, 11, 66, 0

			SECTION .bss ; Section containing uninitialized data

			SECTION .text ; Section containing code
			global _start ; Linker needs this to find the entry point!
_start:
			nop ; This no-op keeps gdb happy (see text)
			xor eax, eax ; clear 32 bits of eax
			mov edi, 0 ; Specify sys_write syscall
			mov ax, word [Dataset+edi*2] ; Specify File Descriptor 1: Standard Output
			mov ebx, eax ; Pass offset of the message

_loop:		cmp eax, 0 ;mov edx,EatLen ; Pass the length of the message
			je _loopend ;int 80H ; Make syscall to output the text to stdout
			inc edi ;ov eax,1 ; Specify Exit syscall
			mov ax, word [Dataset+edi*2] 
			cmp eax, ebx
			jle _loop 
			mov ebx, eax
			jmp _loop

_loopend:	mov rax, 4
			mov rcx, EatMsg
			mov rbx, 1
			mov rdx, EatLen
			int 80H

_exit:		mov rax, 1 ; specify code of syscall for exit, return code stored in ebx, echo $?
			mov rbx, 0		
			int 80H ; Make syscall to terminate the program