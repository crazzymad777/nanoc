module nanoc.std.unistd;

/// Create child process
extern (C) int fork()
{
    static import nanoc.os;
    return fork();
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

public import nanoc.os;
