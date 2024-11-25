module nanoc.std.stdlib.naive;

// naive malloc
void* _malloc(size_t size)
{
    import nanoc.os: allocate_memory_chunk;
    long* memory = cast(long*) allocate_memory_chunk(size + 8);
    if (memory)
    {
        memory[0] = size+8;
        return cast(void*) (memory+1);
    }
    return null;
}

// naive free
void _free(void *ptr)
{
    import nanoc.os: deallocate_memory_chunk;
    import nanoc.os: MemoryChunk;
    long* memory = cast(long*) (ptr-1);
    size_t size = memory[0];
    deallocate_memory_chunk(MemoryChunk(cast(char*) memory, size));
}

// naive realloc
extern(C)
void* realloc(void *ptr, size_t size)
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

alias malloc = _malloc;
alias free = _free;
