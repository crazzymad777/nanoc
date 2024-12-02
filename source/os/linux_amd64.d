module nanoc.os.linux_amd64;

import nanoc.os.sysv.amd64.syscall;
import nanoc.os.sysv.amd64.linux;

import nanoc.std.errno: errno;
import nanoc.os: sys_errno;


alias mode_t = int;
private
{
enum EOF = -1;
enum O_RDONLY = 0;
enum O_WRONLY = 1;
enum O_RDWR = 2;
enum O_CREAT = 64;
enum O_TRUNC = 512;
enum O_APPEND = 1024;
enum STDIN_FILENO = 0;
enum STDOUT_FILENO = 1;
enum STDERR_FILENO = 2;
enum F_DUPFD = 0;
}

enum OS_EOF = EOF;
enum OS_READ_ONLY = O_RDONLY;
enum OS_WRITE_ONLY = O_WRONLY;
enum OS_READ_AND_WRITE = O_RDWR;
enum OS_CREATE = O_CREAT;
enum OS_TRUNCATE = O_TRUNC;
enum OS_APPEND = O_APPEND;
enum OS_STDOUT_FILENO = STDOUT_FILENO;
enum OS_STDIN_FILENO = STDIN_FILENO;
enum OS_STDERR_FILENO = STDERR_FILENO;
enum OS_F_DUPFD = F_DUPFD;

alias off_t = long;
enum OS_PROT_READ = 1;
enum OS_PROT_WRITE = 2;
enum OS_MAP_SHARED = 0x0001;
enum OS_MAP_PRIVATE = 0x0002;
enum OS_MAP_ANONYMOUS = 0x0020;

// wait function
alias pid_t = int;
alias id_t = int;
alias idtype_t = int;
enum P_ALL = 0;
enum P_PID = 1;
enum WEXITED = 0x00000004;

noreturn pexit(int status)
{
    import nanoc.utils.noreturn: never_be_reached;

    syscall(SYS_exit, status);
    never_be_reached(); // supress D error
}

import nanoc.os: StringBuffer;
import nanoc.os: MemoryChunk;
/// open and possibly create a file
int fsopen(StringBuffer pathname, int flags, mode_t mode)
{
    int ret = cast(int) syscall(SYS_open, pathname.data, flags, mode);
    if (ret < 0)
    {
        errno = sys_errno;
    }
    return ret;
}

size_t swrite_sb(int fd, StringBuffer buffer)
{
    return swrite(fd, MemoryChunk(buffer.data, buffer.count()));
}

size_t swrite(int fd, const MemoryChunk chunk)
{
    size_t s = syscall(SYS_write, fd, chunk.data, chunk.len);
    if (s == -1)
    {
        errno = sys_errno;
    }
    return s;
}

size_t sread(int fd, MemoryChunk buffer)
{
    size_t s = syscall(SYS_read, fd, buffer.data, buffer.len);
    if (s == -1)
    {
        errno = sys_errno;
    }
    return s;
}

int sread_single(int fd)
{
    char x;
    size_t s = syscall(SYS_read, fd, &x, 1);
    if (s == -1)
    {
        errno = sys_errno;
        return OS_EOF;
    }
    return x;
}

int swrite_single(int fd, char x)
{
    size_t s = syscall(SYS_write, fd, &x, 1);
    if (s < 0)
    {
        errno = sys_errno;
        return OS_EOF;
    }
    return x;
}

/// close stream
int sclose(int fd)
{
    long s = syscall(SYS_close, fd);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

int fscntl(T...)(int fd, int op, T args)
{
    long s = syscall(SYS_fcntl, fd, op, args);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

int fssync(int fd)
{
    long s = syscall(SYS_fsync, fd);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

/// Fork process
int pfork()
{
    long pid = syscall(SYS_fork);
    if (pid < 0)
    {
         errno = sys_errno;
    }
    return cast(int) pid;
}

int fsrmdir(const char* pathname)
{
    long s = syscall(SYS_rmdir, pathname);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

int fsunlink(StringBuffer buf)
{
    long s = syscall(SYS_unlink, buf.data);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

long fsseek(int fd, long offset, int whence)
{
    long s = syscall(SYS_lseek, fd, offset, whence);
    if (s == -1)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

int pwait()
{
    return waitid(P_ALL, 0, null, WEXITED);
}

int pwait(pid_t pid)
{
    return waitid(P_PID, pid, null, WEXITED);
}

int waitid(idtype_t idtype, id_t id, void* infop, int options)
{
    return _syscall_wait_wrapper(idtype, id, infop, options, null);
}

private int _syscall_wait_wrapper(idtype_t idtype, id_t id, void* infop, int options, void* usage)
{
    long s = syscall(SYS_waitid, idtype, id, infop, options, usage);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

int fsmkdir(StringBuffer path, mode_t mode)
{
    long s = syscall(SYS_mkdir, path.data, mode);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
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

int tset_thread_area(void *pointer)
{
    long s = syscall(SYS_arch_prctl, 0x1002, pointer);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}

long time()
{
    long t = syscall(SYS_time, 0);
    return t;
}

struct rusage {
    timeval ru_utime;	/* user	time used */
    timeval ru_stime;	/* system time used */
    long ru_maxrss;		/* max resident	set size */
    long ru_ixrss;		/* integral shared text	memory size */
    long ru_idrss;		/* integral unshared data size */
    long ru_isrss;		/* integral unshared stack size	*/
    long ru_minflt;		/* page	reclaims */
    long ru_majflt;		/* page	faults */
    long ru_nswap;		/* swaps */
    long ru_inblock;		/* block input operations */
    long ru_oublock;		/* block output	operations */
    long ru_msgsnd;		/* messages sent */
    long ru_msgrcv;		/* messages received */
    long ru_nsignals;	/* signals received */
    long ru_nvcsw;		/* voluntary context switches */
    long ru_nivcsw;		/* involuntary context switches	*/
}

struct timeval
{
    long tv_sec; // type time_t
    ulong tv_usec;// type suseconds_t
}

int getrusage(int who, rusage* rusage)
{
    long s = syscall(SYS_getrusage, who, rusage);
    if (s < 0)
    {
        errno = sys_errno;
    }
    return cast(int) s;
}
