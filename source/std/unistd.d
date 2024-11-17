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
        int r = waitid(P_ALL, 0, null, WEXITED);
        if (r < 0)
        {
            if (r == -11)
            {
                // do it i do it again
                i--;
                continue;
            }
            // if (r == -14)
            // {
            //     // null pointer exception from linux kernel?
            //     // EFAULT 14 Неправильный адрес
            //     // beacuse waitid syscall have fifth argument
            //     continue;
            // }
            assert(false, "waitid failed");
        }
    }

    int r;

    do {
        r = waitid(P_ALL, 0, null, WEXITED);
        if (r == 0)
        {
            assert(false, "waitid failed");
        }
    } while(r == -11);
}
