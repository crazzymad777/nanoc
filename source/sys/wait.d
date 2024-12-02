module nanoc.sys.wait;

public import nanoc.os: pid_t, idtype_t, P_ALL, WEXITED, P_PID, siginfo_t;

extern(C) int wait()
{
    import nanoc.os: pwait;
    return pwait();
}

int waitid(idtype_t idtype, pid_t id, void* infop, int options)
{
    import nanoc.os: waitid;
    return waitid(idtype, id, infop, options);
}
