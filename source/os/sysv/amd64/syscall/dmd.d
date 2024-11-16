module nanoc.os.sysv.amd64.syscall.dmd;

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
        mov R9, args[6]; // [RSP+8] bad because dmd subtracts RSP
    }

    asm{syscall;leave;ret;}

    return long.init;
}

