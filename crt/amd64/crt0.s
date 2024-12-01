.file "crt0.s"
.section .text
.intel_syntax noprefix

.global _start
_start:
	# Setup a stack
	mov RBP, 0
	push RBP
	push RBP
	mov RBP, RSP

	push RDI # argc
	push RSI # argv
	push RDX # envp + aux
	call __nanoc_init # libc init
	call _init # program init

	# restore registers
	pop RDX
	pop RSI
	pop RDI

	# Give control to program
	call __nanoc_main

	# Terminate process
	mov EDI, EAX
	call exit
