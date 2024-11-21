.file "crti.s"
.section .text
.intel_syntax noprefix

.section .init
.global _init
_init:
   push RBP
   mov RBP, RSP

.section .fini
.global _fini
_fini:
   push RBP
   mov RBP, RSP
