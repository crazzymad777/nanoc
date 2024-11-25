.file "crt0.s"
.section .text
.intel_syntax noprefix

.global _start
_start:
	mov RBP, 0
	push RBP
	push RBP
	mov RBP, RSP

	push RSI
	push RDI
	call __nanoc_init
	call _init

	pop RDI
	pop RSI
	call __nanoc_main

	mov EDI, EAX
	call exit
