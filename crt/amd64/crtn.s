.file "crtn.s"
.intel_syntax noprefix
.section .init
   pop RBP
   ret

.section .fini
   pop RBP
   ret
