module nanoc.std.stdlib;

/* Page per allocation... */
/* Relese page when freed */
// version = NANOC_NAIVE_MEMORY_ALLOCATION;
version = NANOC_MEMORY_ALLOCATION;
// version = LIBC_MEMORY_ALLOCATION; // use OS libc

extern (C)
{
    noreturn exit(int status)
    {
        import nanoc.utils.noreturn: never_be_reached;
        import nanoc.os: syscall, SYS_exit;
        syscall(SYS_exit, status);
        never_be_reached(); // supress D warning
    }

    void* _calloc(size_t nmemb, size_t size)
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
