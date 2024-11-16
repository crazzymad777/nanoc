module nanoc.os.sysv.amd64.syscall;

struct raw_result {
        long result;
        long raw; // -4095 means error
};

extern (System) raw_result raw_syscall(long fn, ...);

long syscall(T...)(T args)
{
    import nanoc.std.errno: errno;
    static if (args.length == 0)
    {
        static assert(false, "syscall: provided no arguments. At least syscall number required.");
    }

    raw_result return_code = raw_syscall(args);
    if (return_code.raw == -4095)
    {
        errno = cast(int) return_code.result;
    }
    return return_code.result;
}
