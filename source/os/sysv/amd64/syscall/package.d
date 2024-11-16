module nanoc.os.sysv.amd64.syscall;

struct syscall_response {
        long result;
        long raw; // -4095 means failure
};

extern (System) syscall_response raw_syscall(long fn, ...);

long syscall(T...)(T args)
{
    import nanoc.std.errno: errno;
    static if (args.length == 0)
    {
        static assert(false, "syscall: provided no arguments. At least syscall number required.");
    }

    auto return_code = raw_syscall(args);
    if (return_code.raw == -4095)
    {
        errno = cast(int) return_code.result;
    }
    return return_code.result;
}
