module nanoc.std.unistd;

/// Create child process
extern (C) int fork()
{
    import nanoc.os: pfork;
    return pfork();
}

unittest {
    import nanoc.std.stdlib: exit;
    import nanoc.sys.wait: wait;
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
        if (wait() < 0)
        {
            assert(false, "waitid failed");
        }
    }

    if (wait() == 0)
    {
        assert(false, "waitid failed");
    }
}

public import nanoc.os;
