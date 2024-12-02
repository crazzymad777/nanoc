module nanoc.std.stdlib;

import std.meta: AliasSeq;
alias SubModules = AliasSeq!("memory");

/* Page per allocation... */
/* Relese page when freed */
// version = NANOC_NAIVE_MEMORY_ALLOCATION;
version = NANOC_MEMORY_ALLOCATION;
// version = LIBC_MEMORY_ALLOCATION; // use OS libc

extern (C)
{
    /// Terminate a process
    noreturn exit(int status)
    {
        import nanoc.os: pexit;
        import nanoc.entry;
        __nanoc_fini();

        pexit(status);
    }

    __gshared char** environ = null;

    int system(const char* command)
    {
        if (command is null)
        {
            // TODO: return non-zero if sh exists
            return 1;
        }

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

        import nanoc.std.errno: errno;
        import nanoc.os: execve;
        const char*[4] args = ["/bin/sh", "-c", command, null];
        const char** argv = cast(char**) args;
        int status = execve(cast(char*)"/bin/sh", argv, environ);
        // Error occurs
        exit(127);
    }

    void* calloc(size_t nmemb, size_t size)
    {
        import nanoc.std.string: memset;
        void* ptr = _malloc(nmemb*size);
        if (ptr)
        {
            memset(ptr, 0, nmemb*size);
        }
        return ptr;
    }

    version (NANOC_MEMORY_ALLOCATION)
    {
        public import nanoc.std.stdlib.memory;
    }
    version (NANOC_NAIVE_MEMORY_ALLOCATION)
    {
        public import nanoc.std.stdlib.naive;
    }
    else version(LIBC_MEMORY_ALLOCATION)
    {
        public import nanoc.std.stdlib.libc;
    }
}
