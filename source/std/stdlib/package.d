module nanoc.std.stdlib;

import std.meta: AliasSeq;
alias SubModules = AliasSeq!("memory", "system");

/* Page per allocation... */
/* Relese page when freed */
// version = NANOC_NAIVE_MEMORY_ALLOCATION;
version = NANOC_MEMORY_ALLOCATION;
// version = LIBC_MEMORY_ALLOCATION; // use OS libc

const char* SHELL = "/bin/sh";

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

    noreturn abort()
    {
        import nanoc.misc.signal: raise;
        import nanoc.os: SIGABRT;
        raise(SIGABRT);
        exit(127);
    }

    __gshared char** environ = null;

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
