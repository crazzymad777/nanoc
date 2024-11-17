module nanoc.std.stdlib;

/* Page per allocation... */
/* Relese page when freed */
version = NANOC_NAIVE_MEMORY_ALLOCATION;

//version = LIBC_MEMORY_ALLOCATION; // use OS libc

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

    version (NANOC_NAIVE_MEMORY_ALLOCATION)
    {
    // naive malloc
    void* _malloc(size_t size)
    {
        import nanoc.sys.mman: mmap, PROT_READ, PROT_WRITE, MAP_PRIVATE, MAP_ANONYMOUS;
        long* memory = cast(long*) mmap(null, size+8, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
        if (memory)
        {
            memory[0] = size+8;
            return cast(void*) (memory+8);
        }
        return null;
    }

    // naive free
    void _free(void *ptr)
    {
        import nanoc.sys.mman: munmap;
        long* memory = cast(long*) (ptr-8);
        size_t size = memory[0];
        munmap(cast(void*) memory, size);
    }

    // naive realloc
    void* _realloc(void *ptr, size_t size)
    {
        import nanoc.std.string: memcpy;
        void* q = _malloc(size);
        if (q)
        {
            memcpy(q, ptr, size);
            _free(ptr);
        }
        return q;
    }
    }
    else version(LIBC_MEMORY_ALLOCATION)
    {
        import core.stdc.stdlib;
        alias _malloc = malloc;
        alias _free = free;
        alias _realloc = realloc;
    }
}
