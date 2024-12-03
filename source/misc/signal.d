module nanoc.misc.signal;

import nanoc.os: pid_t;

extern(C) int kill(pid_t pid, int sig)
{
    import nanoc.os: psignal;
    return psignal(pid, sig);
}

extern(C) int raise(int sig)
{
    import nanoc.std.unistd: getpid;
    return kill(getpid(), sig);
}
