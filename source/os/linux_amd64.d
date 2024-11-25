module nanoc.os.linux_amd64;

import nanoc.os.sysv.amd64.syscall;
import nanoc.os.sysv.amd64.linux;

import nanoc.std.errno: errno;
import nanoc.os: sys_errno;

noreturn exit(int status)
{
    import nanoc.utils.noreturn: never_be_reached;

    syscall(SYS_exit, status);
    never_be_reached(); // supress D error
}

alias mode_t = int;
enum EOF = -1;
enum O_RDONLY = 0;
enum O_WRONLY = 1;
enum O_RDWR = 2;
enum O_CREAT = 64;
enum O_TRUNC = 512;
enum O_APPEND = 1024;

enum STDOUT_FILENO = 1;
enum F_DUPFD = 0;

extern(C) int puts(const char *str)
{
    import nanoc.std.string: strlen;
    if (syscall(SYS_write, 1, str, strlen(str)) >= 0)
    {
        return 0;
    }
    errno = sys_errno;
    return EOF;
}

extern(C) int putchar(int octet)
{
    char x = cast(char) octet;
    if (syscall(SYS_write, 1, &x, 1) >= 0)
    {
        return cast(int) x;
    }
    errno = sys_errno;
    return EOF;
}

extern(C) int getchar()
{
    char x;
    int ret = cast(int) syscall(SYS_read, 0, &x, 1);
    if (ret >= 0)
    {
        return x;
    }
    errno = sys_errno;
    return EOF;
}

/// open and possibly create a file
extern(C) int open(const char *pathname, int flags, mode_t mode)
{
    int ret = cast(int) syscall(SYS_open, cast(void*) pathname, flags, mode);
    if (ret < 0)
    {
        errno = sys_errno;
    }
    return ret;
}

extern(C) size_t write(int fd, const void* buf, size_t count)
{
    size_t s = syscall(SYS_write, fd, buf, count);
    if (s == -1)
    {
        errno = sys_errno;
    }
    return s;
}

extern(C) size_t read(int fd, void* buf, size_t count)
{
    size_t s = syscall(SYS_read, fd, buf, count);
    if (s == -1)
    {
        errno = sys_errno;
    }
    return s;
}

/// close a file descriptor
extern(C) int close(int fd)
{
    long s = syscall(SYS_close, fd);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

extern(C) int fcntl(T...)(int fd, int op, T args)
{
    long s = syscall(SYS_fcntl, fd, op, args);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

extern(C) int fsync(int fd)
{
    long s = syscall(SYS_fsync, fd);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

/// Fork process
int fork()
{
    long pid = syscall(SYS_fork);
    if (pid < 0)
    {
         errno = sys_errno;
    }
    return cast(int) pid;
}

version = NANOC_FORK_IMPLEMENTED;

extern (C) int rmdir(const char* pathname)
{
    long s = syscall(SYS_rmdir, pathname);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

extern (C) int unlink(const char* pathname)
{
    long s = syscall(SYS_unlink, pathname);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

long lseek(int fd, long offset, int whence)
{
    long s = syscall(SYS_lseek, fd, offset, whence);
    if (s == -1)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}


alias pid_t = int;
alias id_t = int;

alias idtype_t = int;
enum P_ALL = 0;

enum WEXITED = 0x00000004;

// int waitid(idtype_t idtype, id_t id, siginfo_t *infop, int options)
// fifrh arguments: struct rusage *


extern (C)
int waitid(idtype_t idtype, id_t id, void* infop, int options)
{
    return _syscall_wait_wrapper(idtype, id, infop, options, null);
}

// fifrh arguments: struct rusage *
@("metaomit")
int _syscall_wait_wrapper(idtype_t idtype, id_t id, void* infop, int options, void* usage)
{
    long s = syscall(SYS_waitid, idtype, id, infop, options, usage);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}


extern(C) int mkdir(const char* pathname, mode_t mode)
{
    long s = syscall(SYS_mkdir, pathname, mode);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

alias off_t = long;
enum PROT_READ = 1;
enum PROT_WRITE = 2;
enum MAP_SHARED = 0x0001;
enum MAP_PRIVATE = 0x0002;
enum MAP_ANONYMOUS = 0x0020;

void* allocate_memory_chunk(size_t length)
{
    return mmap(null, length, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
}

import nanoc.os: MemoryChunk;
int deallocate_memory_chunk(MemoryChunk chunk)
{
    return munmap(cast(void*)chunk.data, chunk.len);
}

void* mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset)
{
    void* ptr = cast(void*) syscall(SYS_mmap, addr, length, prot, flags, fd, offset);
    if (ptr is null)
    {
        errno = sys_errno;
    }
    return ptr;
}

int munmap(void* addr, size_t length)
{
    long s = syscall(SYS_munmap, addr, length);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

version = NANOC_MMAP_IMPLEMENTED;
version = NANOC_MUNMAP_IMPLEMENTED;

extern(C) int set_thread_area(void *pointer)
{
    long s = syscall(SYS_arch_prctl, 0x1002, pointer);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}
