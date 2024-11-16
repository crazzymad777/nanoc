module nanoc.os.sysv.amd64.syscall;

extern (System) long raw_syscall(long fn, ...);

long syscall(T...)(T args)
{
    import nanoc.std.errno: errno;
    static if (args.length == 0)
    {
        static assert(false, "syscall: provided no arguments. At least syscall number required.");
    }
    long return_code = raw_syscall(args);
    if (return_code) {
        errno = cast(int) return_code;
    }
    return return_code;
}
