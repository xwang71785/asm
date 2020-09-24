; Executable name : cmdline
; Version : Assembly X86-64 NASM 2.14.02
; Author : Assembly Languange programming with Ubuntu
; Description : A simple assembly app demonstrating the 
; use of Linux INT 80H syscalls to display text.
; Build using these commands:
; nasm -f elf64 -g -F stabs cmdline.asm
; ld -o cmdline cmdline.o
; ------------------------------------------------------
			section .data
; Define standard constants.
LF 			equ 10 ; line feed
NULL 		equ 0 ; end of string
TRUE 		equ 1
FALSE 		equ 0
SUCCESS 	equ 0 ; success code
STDIN 		equ 0 ; standard input
STDOUT 		equ 1 ; standard output
STDERR 		equ 2 ; standard error
SYS_read 	equ 0 ; read
SYS_write 	equ 1 ; write
SYS_open 	equ 2 ; file open
SYS_close 	equ 3 ; file clos
SYS_exit 	equ 60 ; terminate
SYS_create	equ 85 ; file open/create

; Variables for main.
newLine 	db LF, NULL

			section .text
			global _start
_start:
; 
; Get command line arguments and echo to screen.
; Based on the standard calling convention,
; if the program begins with "main" then
; rdi = argc (argument count)
; rsi = argv (starting address of argument vector)
; if the program begins with "_start" then
; rsp = argc
; rsp+8 = argv
			mov r12, rdi ; save for later use...
			mov r13, rsi ; 
			pop r12 
			mov r13, rsp ; for _start
; Simple loop to display each argument to the screen.
; Each argument is a NULL terminated string, so can just
; print directly.
			mov rbx, 0
printLoop:	mov rdi, qword [r13+rbx*8]
			call printStr
			mov rdi, newLine
			call printStr
			inc rbx
			cmp rbx, r12
			jl printLoop
; Example program done.
Done:		mov rax, SYS_exit
			mov rbx, SUCCESS
			syscall
; **********************************************************
; Generic procedure to display a string to the screen.
; String must be NULL terminated.
; Algorithm:
; Count characters in string (excluding NULL)
; Use syscall to output characters
; Arguments:
; 1) address, string
; Returns:
; nothing
			global printStr
printStr:	push rbp
			mov rbp, rsp
			push rbx
; Count characters in string.
			mov rbx, rdi
			mov rdx, 0
CountLoop:	cmp byte [rbx], NULL
			je CountDone
			inc rdx
			inc rbx
			jmp CountLoop
CountDone:	cmp rdx, 0
			je prtDone
; Call OS to output string.
			mov eax, SYS_write ; code for write()
			mov rsi, rdi ; addr of characters
			mov edi, STDOUT ; file descriptor
; count set above

			syscall ; system call
; String printed, return to calling routine.
prtDone:	pop rbx
			pop rbp
			ret