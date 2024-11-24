module nanoc.thread;

import nanoc.elf;

version (X86_64)
{
    import nanoc.thread.amd64;
}

// User-space Thread
struct Thread
{
    Thread* self;
    void** dtv;
    void* ptr1;
    void* ptr2;
    void* ptr3;
    ulong tid;

    byte[0] data;
}

// Argument for __tls_get_addr
struct ThreadLocalStorageIndex
{
    size_t module_;
    size_t offset;
}

struct StaticThreadLocalStorage
{
    void* image;
    size_t pad;
    size_t memory;
    size_t size;

    void* fake;
}

// Trigger ld
extern(C) pragma(mangle, "__tls_get_addr@@GLIBC_2.3") void* __tls_get_addr(ThreadLocalStorageIndex vector);
