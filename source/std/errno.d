module nanoc.std.errno;

/// Invalid argument
enum EINVAL = 22;

/// C error number
extern(C) static int errno;
