module nanoc.std.errno;

/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */

extern (C):

enum EPERM = 1; /* Operation not permitted */
enum ENOENT = 2; /* No such file or directory */
enum ESRCH = 3; /* No such process */
enum EINTR = 4; /* Interrupted system call */
enum EIO = 5; /* I/O error */
enum ENXIO = 6; /* No such device or address */
enum E2BIG = 7; /* Argument list too long */
enum ENOEXEC = 8; /* Exec format error */
enum EBADF = 9; /* Bad file number */
enum ECHILD = 10; /* No child processes */
enum EAGAIN = 11; /* Try again */
enum ENOMEM = 12; /* Out of memory */
enum EACCES = 13; /* Permission denied */
enum EFAULT = 14; /* Bad address */
enum ENOTBLK = 15; /* Block device required */
enum EBUSY = 16; /* Device or resource busy */
enum EEXIST = 17; /* File exists */
enum EXDEV = 18; /* Cross-device link */
enum ENODEV = 19; /* No such device */
enum ENOTDIR = 20; /* Not a directory */
enum EISDIR = 21; /* Is a directory */
enum EINVAL = 22; /* Invalid argument */
enum ENFILE = 23; /* File table overflow */
enum EMFILE = 24; /* Too many open files */
enum ENOTTY = 25; /* Not a typewriter */
enum ETXTBSY = 26; /* Text file busy */
enum EFBIG = 27; /* File too large */
enum ENOSPC = 28; /* No space left on device */
enum ESPIPE = 29; /* Illegal seek */
enum EROFS = 30; /* Read-only file system */
enum EMLINK = 31; /* Too many links */
enum EPIPE = 32; /* Broken pipe */
enum EDOM = 33; /* Math argument out of domain of func */
enum ERANGE = 34; /* Math result not representable */

enum NANOC_ENOSYS = 38; /* Function not implemented */

/// C error number
extern(C) __gshared int errno;
