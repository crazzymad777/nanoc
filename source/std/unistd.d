module nanoc.std.unistd;

extern (C) int fork()
{
    import nanoc.os: syscall, SYS_fork;
    return cast(int) syscall(SYS_fork);
}

unittest {
    import nanoc.sys.wait: waitid, P_ALL, WEXITED;
    import nanoc.std.stdlib: exit;
    const number = 10;

    for (int i = 0; i < number; i++)
    {
        int pid = fork();
        if (pid == 0) exit(0); // children exit
        if (pid < 0)
        {
            assert(false, "fork failed");
        }
    }

    for (int i = 0; i < number; i++)
    {
        if (waitid(P_ALL, 0, null, WEXITED) < 0)
        {
            assert(false, "waitid failed");
        }
    }

    if (waitid(P_ALL, 0, null, WEXITED) == 0)
    {
        assert(false, "waitid failed");
    }
}

extern (C) int rmdir(const char* pathname)
{
    import nanoc.os: syscall, SYS_rmdir;
    return cast(int) syscall(SYS_rmdir, pathname);
}

extern (C) int unlink(const char* pathname)
{
    import nanoc.os: syscall, SYS_unlink;
    return cast(int) syscall(SYS_unlink, pathname);
}
