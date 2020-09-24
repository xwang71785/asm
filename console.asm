; Executable name : console
; Version : Assembly X86-64 NASM 2.14.02
; Author : Assembly Languange programming with Ubuntu
; Description : A simple assembly app demonstrating the 
; use of Linux 
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

			mov rbx, inLine			; 内存指针，指向预留字符串空间
			mov r12, 0				; 已读字符个数计数器置零
readChr:	mov rax, SYS_read
			mov rdi, STDIN
			lea rsi, [chr]
			mov rdx, 1				; 每次读入一个字符
			syscall

			mov al, byte [chr]
			cmp al, LF 				; 判断是否达到字符串尾
			je readDone

			inc r12
			cmp r12, STRLEN 		; 如果读取的字符串长度超过预设的长度
			jge readChr 			; 直接读取下一个字符，不存入内存

			mov byte [rbx], al		; 读取的字符存入指定内存
			inc rbx
			jmp readChr 

readDone:	mov rdi, inLine			; calling function to print string with pointed by rdi
			call printStr
			mov rdi, newLine 
			call printStr

exit:		mov rax, SYS_exit
			mov rdi, SUCCESS
			syscall

; ******************************************************
; Generic procedure to display a string to the screen.
; String must be NULL terminated.
; Arguments:
; 1) address, string in rdi
; Returns:
; nothing
			global printStr 		; before calling, store address of string to rdi
printStr:	push rbp				; 实现功能前用栈保护当前寄存器环境
			mov rbp, rsp			; 压入rbp，再把rbp指向被压入的rbp
			push rbx				; Callee中要用到rbx，先把rbx压入栈中

			mov rbx, rdi			; rbx point to address of head of string
			mov rdx, 0
countLoop:	cmp byte [rbx], NULL
			je countDone
			inc rdx					; rdx count to write
			inc rbx					; moving rbx point along the string
			jmp countLoop
countDone:	cmp rdx, 0				; 停止计数后，判断字符串长度是否为0
			je prtDone 				; 如果为0，则跳过输出，结束

			mov rax, SYS_write 		; system code for write
			mov rsi, rdi			; address of chars to write
			mov rdi, STDOUT 		; output to screen
			syscall 

prtDone:	pop rbx					; 恢复rbx
			pop rbp					; 恢复rbp
			ret
