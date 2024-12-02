module nanoc.os.sysv.amd64.linux;

package(nanoc.os):

/// System read(fd, buffer, buffer size)
enum SYS_read = 0;

/// System write(fd, buffer, buffer size)
enum SYS_write = 1;

enum SYS_open = 2;
enum SYS_close = 3;
enum SYS_lseek = 8;
enum SYS_mmap = 9;
enum SYS_munmap = 11;
enum SYS_fork = 57;
enum SYS_execve = 59;
enum SYS_exit = 60;
enum SYS_fcntl = 72;
enum SYS_fsync = 74;
enum SYS_mkdir = 83;
enum SYS_rmdir = 84;
enum SYS_unlink = 87;

enum SYS_getrusage = 98;

/// arch_prctl: First argument: Subfunction int op, Second argument: unsigned long addr for set subfunctions, unsigned long* addr for get subfuctions
enum SYS_arch_prctl = 158;

enum SYS_time = 201;
enum SYS_set_tid_address = 218;
enum SYS_waitid = 247;
