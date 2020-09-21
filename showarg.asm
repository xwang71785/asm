; Executable name : SHOWARGS1
; Version : Assembly X86-32 NASM 2.14.02
; Author : Assembly Languange step by step
; Description : This program handles up to MAXARGS command-line arguments.
; Build using these commands:
; nasm -f elf -g -F stabs showargs1.asm
; ld -o showargs1 showargs1.o
; -----------------------------------------------------------------------------
			SECTION .data ; Section containing initialized data
ErrMsg 		db "Terminated with error.", 10
ERRLEN 		equ $-ErrMsg
			SECTION .bss ; Section containing uninitialized data
; 
; In essence we store pointers to the arguments in a 0-based array, with the
; first arg pointer at array element 0, the second at array element 1, etc.
; Ditto the arg lengths. Access the args and their lengths this way:
; Arg strings: [ArgPtrs + <index reg>*4]
; Arg string lengths: [ArgLens + <index reg>*4]
; Note that when the argument lengths are calculated, an EOL char (10h) is
; stored into each string where the terminating null was originally. This
; makes it easy to print out an argument using sys_write. This is not
; essential, and if you prefer to retain the 0-termination in the arguments,
; you can comment out that line, keeping in mind that the arguments will not
; display correctly without EOL characters at their ends.
MAXARGS 	equ 10 ; Maximum # of args we support
ArgCount: 	resq 1 ; # of arguments passed to program
ArgPtrs: 	resq MAXARGS ; Table of pointers to arguments
ArgLens: 	resq MAXARGS ; Table of argument lengths

			SECTION .text ; Section containing code
			global _start ; Linker needs this to find the entry point!
_start:		nop ; This no-op keeps gdb happy...
; Get the command line argument count off the stack and validate it:
			pop rcx ; TOS contains the argument count, since the architecture is 64-bit
			cmp rcx, MAXARGS ; See if the arg count exceeds MAXARGS
			ja Error ; If so, exit with an error message
			mov qword [ArgCount], rcx ; Save arg count in memory variable

; Once we know how many args we have, a loop will pop them into ArgPtrs:
			xor rdx, rdx ; Zero a loop counter
SaveArgs:	pop qword [ArgPtrs + rdx*8] ; Pop an arg addr into the memory table
			inc rdx ; Bump the counter to the next arg addr
			cmp rdx, rcx ; Is the counter = the argument count?
			jb SaveArgs ; If not, loop back and do another

; in order to use SCASB(SCAn String by Byte) instruction, following setup are required:
; CLD to clear DF(Direction Flag)
; the address of the first byte of the string is stored in EDI
; the value to be searched stored in AX
; the maximum count is placed in ECX
; as a result, EDI will points to the position where the value is found
; With the argument pointers stored in ArgPtrs, we calculate their lengths:
			xor rax, rax ; Searching for 0, so clear AL to 0
			xor rbx, rbx ; Pointer table offset starts at 0
ScanOne:	mov ecx, 0000ffffh ; Limit search to 65535 bytes max
			mov rdi, qword [ArgPtrs+ebx*8] ; Put address of string to search in EDI
			mov rdx, rdi ; Copy starting address into EDX
			cld ; Set search direction to up-memory
			repne scasb ; Search for null (0 char) in string at edi
			jnz Error ; REPNE SCASB ended without finding AL
			mov byte [rdi-1], 10 ; Store an EOL where the null used to be
			sub rdi, rdx ; Subtract position of 0 from start address
			mov qword [ArgLens+ebx*8], rdi ; Put length of arg into table
			inc rbx ; Add 1 to argument counter
			cmp rbx, [ArgCount] ; See if arg counter exceeds argument count
			jb ScanOne ; If not, loop back and do another one

; Display all arguments to stdout:
			xor esi, esi ; Start (for table addressing reasons) at 0
Showem:		mov rax, 4 ; Specify sys_write call
			mov rbx, 1 ; Specify File Descriptor 1: Standard Output
			mov rcx, qword [ArgPtrs+esi*8] ; Pass offset of the message
			mov rdx, qword [ArgLens+esi*8] ; Pass the length of the message
			int 80H ; Make kernel call
			inc esi ; Increment the argument counter
			cmp esi, [ArgCount] ; See if we’ve displayed all the arguments
			jb Showem ; If not, loop back and do another
			jmp Exit ; We’re done! Let’s pack it in!

Error: 		mov eax, 4 ; Specify sys_write call
			mov ebx, 1 ; Specify File Descriptor 2: Standard Error
			mov ecx, ErrMsg ; Pass offset of the error message
			mov edx, ERRLEN ; Pass the length of the message
			int 80H ; Make kernel call

Exit: 		mov eax, 1 ; Code for Exit Syscall
			mov ebx, 0 ; Return a code of zero
			int 80H ; Make kernel call