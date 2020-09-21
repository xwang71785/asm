; Executable name : console
; Version : Assembly X86-64 NASM 2.14.02
; Author : Assembly Languange programming with Ubuntu
; Description : A simple assembly app demonstrating the 
; use of Linux INT 80H syscalls to display text.
; Build using these commands:
; nasm -f elf64 -g -F stabs console.asm
; ld -o console console.o
;------------------------------------------------------------

			section .bss
chr 		resb 1
inLine		resb 52

			section .data
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
SYS_close 	equ 3 ; file close
SYS_exit 	equ 60 ; terminate
SYS_create 	equ 85 ; file open/create

STRLEN		equ 50
pmpt		db	"Enter Tesxt: ", NULL
newLine		db	LF, NULL

			section .text
			global _start
_start:		nop
			mov rdi, pmpt 
			call printStr

			mov rbx, inLine
			mov r12, 0
readChr:	mov rax, SYS_read
			mov rdi, STDIN
			lea rsi, [chr]
			mov rdx, 1
			syscall

			mov al, byte [chr]
			cmp al, LF 
			je readDone

			inc r12
			cmp r12, STRLEN 
			jge readChr 

			mov byte [rbx], al
			inc rbx
			jmp readChr 

readDone:	mov rdi, inLine			; calling function to print string with pointed by rdi
			call printStr
			mov rdi, newLine 
			call printStr

exit:		mov rax, SYS_exit
			mov rdi, SUCCESS
			syscall

			global printStr 		; before calling, store address of string to rdi
printStr:	push rbp
			mov rbp, rsp
			push rbx
			mov rbx, rdi			; rbx point to address of head of string
			mov rdx, 0
countLoop:	cmp byte [rbx], NULL
			je countDone
			inc rdx					; rdx count to write
			inc rbx					; moving rbx point along the string
			jmp countLoop
countDone:	cmp rdx, 0
			je prtDone

			mov rax, SYS_write 		; system code for write
			mov rsi, rdi			; address of chars to write
			mov rdi, STDOUT 		; output to screen
			syscall 

prtDone:	pop rbx
			pop rbp
			ret
