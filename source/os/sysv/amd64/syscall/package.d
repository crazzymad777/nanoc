module nanoc.os.sysv.amd64.syscall;

// version (DigitalMars)
// {
//     public import nanoc.os.sysv.amd64.syscall.dmd: raw_syscall;
// }
//
// version (LDC)
// {
//     public import nanoc.os.sysv.amd64.syscall.ldc: raw_syscall;
// }
//
// version (GNU)
// {
//     public import nanoc.os.sysv.amd64.syscall.gdc: raw_syscall;
// }

extern (System) long raw_syscall(long fn, ...);

long syscall(T...)(T args)
{
    static if (args.length == 0)
    {
        static assert(false, "syscall: provided no arguments. At least syscall number required.");
    }
    return raw_syscall(args);
    //return let_do_it(args);
}
