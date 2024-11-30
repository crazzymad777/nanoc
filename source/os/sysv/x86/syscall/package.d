module nanoc.os.sysv.x86.syscall;

private
struct SyscallResponse {
        size_t result;
        size_t raw; // -4095 means failure
};

/++
    Actual system caller implemented in ASM (raw_syscall.s)
+/
extern (System) SyscallResponse raw_syscall(size_t fn, ...);

/++
    D Wrapper for raw_syscall
    sets nanoc errno
+/
extern (System) size_t syscall(T...)(T args)
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
