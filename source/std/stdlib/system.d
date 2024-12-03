module nanoc.std.stdlib.system;

import nanoc.std.stdlib: SHELL, environ, exit;
import nanoc.meta: Omit;

extern (C) int system(const char* command)
{
    if (command is null)
    {
        return check();
    }

    return run(command);
}

@Omit int check()
{
    // return non-zero if sh exists
    return system("") == 0 ? 1 : 0;
}

@Omit int run(const char* command)
{
    import nanoc.sys.wait: P_PID, WEXITED, pid_t, waitid, siginfo_t;
    import nanoc.std.unistd: fork;

    pid_t pid = fork();
    if (pid < 0)
    {
        return -1;
    }

    if (pid > 0)
    {
        // what if waitid interrupted?
        siginfo_t siginfo;
        waitid(P_PID, pid, &siginfo, WEXITED);
        return siginfo.si_status;
    }

    execute(SHELL, command);
}

@Omit noreturn execute(const char* shell, const char* command)
{
    import nanoc.os: execve;
    const char*[4] argv = [shell, "-c", command, null];
    execve(cast(char*) shell, cast(char**) argv, environ);
    // Error occurs
    exit(127);
}
