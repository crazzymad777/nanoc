.file "raw_syscall.s"
.intel_syntax noprefix

.text

.globl raw_syscall
.type raw_syscall, @function

raw_syscall:
    push EBP
    push EBX
	push ESI
	push EDI

	mov EAX, [ESP+20]
    mov EBX, [ESP+24]
    mov ECX, [ESP+28]
    mov EDX, [ESP+32]
    mov EDX, [ESP+36]
    mov ESI, [ESP+40]
    mov EDI, [ESP+44]
    mov EBP, [ESP+48]

    int 0x80

    mov EDX, EAX
    cmp EAX, -4095 # check error
    jne _exit
    mov EAX, ECX
    _exit:
    pop EDI
    pop ESI
    pop EBX
    pop EBP
    ret
