.section .text
.intel_syntax noprefix

.global _start
_start:
	mov RBP, 0
	push RBP
	push RBP
	mov RBP, RSP

	call __nanoc_main

	mov EDI, EAX
	call exit
