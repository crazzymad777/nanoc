module nanoc.os.sysv.x86.linux;

/// System read(fd, buffer, buffer size)
enum SYS_read = 3;

/// System write(fd, buffer, buffer size)
enum SYS_write = 4;

enum SYS_open = 5;
enum SYS_close = 6;
enum SYS_mmap = 90;
enum SYS_munmap = 91;
enum SYS_fork = 2;
enum SYS_exit = 1;
enum SYS_fcntl = 55;
enum SYS_fsync = 118;
enum SYS_mkdir = 39;
enum SYS_rmdir = 40;
enum SYS_unlink = 10;

/// arch_prctl: First argument: Subfunction int op, Second argument: unsigned long addr for set subfunctions, unsigned long* addr for get subfuctions
enum SYS_arch_prctl = 384;

enum SYS_set_tid_address = 258;
enum SYS_waitid = 284;
