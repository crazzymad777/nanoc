module spring.backend.linux.amd64.ldc;

extern (System) long raw_syscall(T...)(T args) // @system @nogc nothrow
{
    static if (args.length > 0)
    asm
    {
        mov RAX, RDI;
    }

    static if (args.length > 1)
    asm
    {
        mov RDI, RSI;
    }

    static if (args.length > 2)
    asm
    {
        mov RSI, RDX;
    }

    static if (args.length > 3)
    asm
    {
        mov RDX, RCX;
    }

    static if (args.length > 4)
    asm
    {
        mov R10, R8;
    }

    static if (args.length > 5)
    asm
    {
        mov R8, R9;
    }

    static if (args.length > 6)
    asm
    {
        mov R9, [RSP+8];
    }

    asm{syscall;leave;ret;}

    return long.init;
}

