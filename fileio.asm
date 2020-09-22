; Executable name : fileio
; Version : Assembly X86-64 NASM 2.14.02
; Author : Assembly Languange programming with Ubuntu
; Description : A simple assembly app demonstrating the 
; use of Linux INT 80H syscalls to display text.
; Build using these commands:
; nasm -f elf64 -g -F stabs fileio.asm
; ld -o fileio fileio.o
;-------------------------------------------------------
			section .data
LF 			equ 10 		; line feed
NULL 		equ 0 		; end of string
TRUE 		equ 1
FALSE 		equ 0
SUCCESS 	equ 0 		; success code
STDIN 		equ 0 		; standard input
STDOUT 		equ 1 		; standard output
STDERR 		equ 2 		; standard error

SYS_read 	equ 0 		; read
SYS_write 	equ 1 		; write
SYS_open 	equ 2 		; file open
SYS_close 	equ 3 		; file clos

SYS_socket	equ 41		; create socket rdi=2, rsi=1, rdx=0, return socket descriptor in rax
SYS_connect	equ 42
SYS_accept	equ 43
SYS_bind	equ 49		; bind socket rdi=socket_fd, rsi=socket address, rdx=length of socket address
SYS_listen	equ 50		; listen on the socket after bind succeeded, rsi=1

SYS_fork 	equ 57 		; fork
SYS_exit 	equ 60 		; terminate
SYS_creat 	equ 85 		; file open/create
SYS_time 	equ 201 	; get time
O_CREATE 	equ 0x40
O_TRUNC 	equ 0x200
O_APPEND 	equ 0x400
O_RDONLY 	equ 000000q ; read only
O_WRONLY 	equ 000001q ; write only
O_RDWR 		equ 000002q ; read and write
S_IRUSR 	equ 00400q
S_IWUSR 	equ 00200q
S_IXUSR 	equ 00100q
; 
;Variables/constants for main.
BUFF_SIZE 	equ 255
newLine 	db LF, NULL
header 		db LF, "File Read Example."
			db LF, LF, NULL
fileName 	db "url.txt", NULL
url 		db "http://www.google.com"
			db LF, NULL
len 		dq $-url-1
writeDone 	db "Write Completed.", LF, NULL
fileDescriptor dq 0
errMsgOpen 	db "Error opening the file.", LF, NULL
errMsgRead 	db "Error reading from the file.", LF, NULL
errMsgWrite db "Error writing to file.", LF, NULL
;
			section .bss
readBuffer 	resb BUFF_SIZE

			section .text
			global _start
_start:		mov rdi, header
			call printStr
; The file descriptor points to the File Control Block (FCB).
createFile:	mov rax, SYS_create ; file open/create
			mov rdi, fileName ; file name strin
			mov rsi, S_IRUSR | S_IWUSR ; allow read/write
			syscall ; call the kernel
			cmp rax, 0 ; check for success
			jl errOpen
			mov qword [fileDescriptor], rax ; save descriptor
; Write to file.
; In this example, the characters to write are in a
; predefined string containing a URL.
; System Service write
; rax = SYS_write
; rdi = file descriptor
; rsi = address of characters to write
; rdx = count of characters to write
; Returns:
; if error > rax < 0
; if success > rax = count of characters actually read
			mov rax, SYS_write
			mov rdi, qword [fileDescriptor]
			mov rsi, url
			mov rdx, qword [len]
			syscall
			cmp rax, 0
			jl errWrite

			mov rdi, writeDone
			call printStr
			jmp exit
; Attempt to open file.
; Use system service for file open
; System Service Open
; rax = SYS_open
; rdi = address of file name string
; rsi = attributes (i.e., read only, etc.)
; Returns:
; if error > eax < 0
; if success > eax = file descriptor number
; The file descriptor points to the File Control Block (FCB).
; The FCB is maintained by the OS.
; The file descriptor is used for all subsequent file
; operations (read, write, close).
openFile:	mov rax, SYS_open ; file open
			mov rdi, fileName ; file name string
			mov rsi, O_RDONLY ; read only access
			syscall ; call the kernel
			cmp rax, 0 ; check for success
			jl errOpen
			mov qword [fileDescriptor], rax ; save descriptor
; Read from file.
; In this example, we know that the file has exactly 1 line.
; System Service Read
; rax = SYS_read
; rdi = file descriptor
; rsi = address of where to place data
; rdx = count of characters to read
; Returns:
; if error > rax < 0
; if success > rax = count of characters actually read
			mov rax, SYS_read
			mov rdi, qword [fileDescriptor]
			mov rsi, readBuffer
			mov rdx, BUFF_SIZE
			syscall
			cmp rax, 0
			jl errRead
; Print the buffer.
; add the NULL for the print string
			mov rsi, readBuffer
			mov byte [rsi+rax], NULL
			mov rdi, readBuffer
			call printStr
; printNewLine
; Close the file.
; System Service close
; rax = SYS_close
; rdi = file descriptor
			mov rax, SYS_close
			mov rdi, qword [fileDescriptor]
			syscall
			jmp exit
;Error on write.
; note, eax contains an error code which is not used
; for this example.
errWrite:	mov rdi, errMsgWrite
			call printStr
			jmp exit
; Error on open.
; note, eax contains an error code which is not used
; for this example.
errOpen:	mov rdi, errMsgOpen
			call printStr
			jmp exit
; Error on read.
; note, eax contains an error code which is not used
; for this example.
errRead:	mov rdi, errMsgRead
			call printStr
			jmp exit
; Example program done.
exit:		mov rax, SYS_exit
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
			mov rbx, rdi
			mov rdx, 0
CountLoop:	cmp byte [rbx], NULL
			je CountDone
			inc rdx ; number of bytes to be printed
			inc rbx
			jmp CountLoop
CountDone:	cmp rdx, 0
			je prtDone

			mov eax, SYS_write ; code for write()
			mov rsi, rdi ; addr of characters
			mov rdi, STDOUT ; file descriptor
			syscall ; system call

prtDone:	pop rbx
			pop rbp
			ret