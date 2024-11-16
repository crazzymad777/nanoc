.file "raw_syscall.s"
.intel_syntax noprefix
.globl raw_syscall
.type raw_syscall, @function

raw_syscall:
    mov RAX, RDI
    mov RDI, RSI
    mov RSI, RDX
    mov RDX, RCX
    mov R10, R8
    mov R8, R9
    mov R9, [RSP+8]
    syscall
    leave
    ret
