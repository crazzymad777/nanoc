module nanoc.os.sysv.amd64.syscall;

private
struct SyscallResponse {
        long result;
        long raw; // -4095 means failure
};

/++
    Actual system caller implemented in ASM (raw_syscall.s)
+/
extern (System) SyscallResponse raw_syscall(long fn, ...);

/++
    D Wrapper for raw_syscall
    sets nanoc errno
+/
extern (System) long syscall(T...)(T args)
{
    import nanoc.std.errno: errno;
    static if (args.length == 0)
    {
        static assert(false, "syscall: provided no arguments. At least syscall number required.");
    }

    auto return_code = raw_syscall(args);
    if (return_code.raw >= -4095 && return_code.raw < 0)
    {
        errno = cast(int) return_code.result;
    }
    return return_code.result;
}
