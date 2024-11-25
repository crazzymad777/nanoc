module nanoc.os.sysv.amd64.syscall;

package(nanoc.os):

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
    import nanoc.os: sys_errno;
    sys_errno = 0;
    static if (args.length == 0)
    {
        static assert(false, "syscall: provided no arguments. At least syscall number required.");
    }

    auto return_code = raw_syscall(args);
    if (return_code.raw >= -4095 && return_code.raw < 0)
    {
        sys_errno = cast(int) (-1 * return_code.result);
    }
    return return_code.result;
}
