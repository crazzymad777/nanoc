module nanoc.sys.mman;

public import nanoc.os: off_t, OS_PROT_READ, OS_PROT_WRITE, OS_MAP_SHARED, OS_MAP_PRIVATE, OS_MAP_ANONYMOUS;

enum PROT_READ = OS_PROT_READ;
enum PROT_WRITE = OS_PROT_WRITE;
enum MAP_SHARED = OS_MAP_SHARED;
enum MAP_PRIVATE = OS_MAP_PRIVATE;
enum MAP_ANONYMOUS = OS_MAP_ANONYMOUS;

extern (C) void* mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset)
{
    static import nanoc.os;
    return nanoc.os.mmap(addr, length, prot, flags, fd, offset);
}

extern (C) int munmap(void* addr, size_t length)
{
    static import nanoc.os;
    return nanoc.os.munmap(addr, length);
}

unittest
{
    void* ptr = mmap(null, 4096, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    assert(ptr !is null);
    assert(munmap(ptr, 4096) == 0);
}
