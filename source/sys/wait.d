module nanoc.sys.wait;

alias pid_t = int;
alias id_t = int;

alias idtype_t = int;
enum P_ALL = 0;

enum WEXITED = 0x00000004;

// int waitid(idtype_t idtype, id_t id, siginfo_t *infop, int options)
// fifrh arguments: struct rusage *


extern (C)
int waitid(idtype_t idtype, id_t id, void* infop, int options)
{
    return _syscall_wait_wrapper(idtype, id, infop, options, null);
}

// fifrh arguments: struct rusage *
int _syscall_wait_wrapper(idtype_t idtype, id_t id, void* infop, int options, void* usage)
{
    import nanoc.os: syscall, SYS_waitid;
    return cast(int) syscall(SYS_waitid, idtype, id, infop, options, usage);
}
