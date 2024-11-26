module nanoc.sys.wait;

// public import nanoc.os: waitid, P_ALL, WEXITED;

extern(C) int wait()
{
    import nanoc.os: pwait;
    return pwait();
}
