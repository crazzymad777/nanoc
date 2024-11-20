module nanoc.sys.mman;

alias off_t = long;
enum PROT_READ = 1;
enum PROT_WRITE = 2;
enum MAP_SHARED = 0x0001;
enum MAP_PRIVATE = 0x0002;
enum MAP_ANONYMOUS = 0x0020;

extern (C)
void* mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset)
{
    import nanoc.os: syscall, SYS_mmap;
    return cast(void*) syscall(SYS_mmap, addr, length, prot, flags, fd, offset);
}

extern (C)
int munmap(void* addr, size_t length)
{
    import nanoc.os: syscall, SYS_munmap;
    return cast(int) syscall(SYS_munmap, addr, length);
}
