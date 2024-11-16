module nanoc.os.sysv.amd64.syscall.gdc;

extern (System) long raw_syscall(T...)(T args) // @system @nogc nothrow
{
    static if (args.length == 0)
    {
        static assert(false, "raw_syscall: provided no arguments. At least syscall number required.");
    }

    static if (args.length > 0)
    asm
    {
        "movq %rdi, %rax";
    }

    static if (args.length > 1)
    asm
    {
        "movq %rsi, %rdi";
    }

    static if (args.length > 2)
    asm
    {
        "movq %rdx, %rsi";
    }

    static if (args.length > 3)
    asm
    {
        "movq %rcx, %rdx";
    }

    static if (args.length > 4)
    asm
    {
        "movq %r8, %r10";
    }

    static if (args.length > 5)
    asm
    {
        "movq %r9, %r8";
    }

    static if (args.length > 6)
    asm
    {
        "movq 8(%rsp),%r9";
    }

    asm{"syscall";"leave";"ret";}

    return long.init;
}

