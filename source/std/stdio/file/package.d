module nanoc.std.stdio.file;

public import nanoc.std.stdio.file.dynamic_memory: open_memstream;
public import nanoc.std.stdio.file.memory: fmemopen;
public import nanoc.std.stdio.file.raw_fd: fopen;
public import nanoc.std.stdio.file.core: FILE;
import nanoc.std.stdio.file.core;
import nanoc.std.stdio.common;

/// Adorable alias
alias File = FILE;
alias fpos_t = long;

__gshared File fstdin = {type: File.Type.OS, raw_fd: STDIN_FILENO, prealloc: true};
__gshared File fstdout = {type: File.Type.OS, raw_fd: STDOUT_FILENO, prealloc: true};
__gshared File fstderr = {type: File.Type.OS, raw_fd: STDERR_FILENO, prealloc: true};

/// Return preallocated File* if standard handler
File* checkStdHandler(File* f)
{
    if (f == cast(File*) STDERR_FILENO)
    {
        return &fstderr;
    }
    if (f == cast(File*) STDOUT_FILENO)
    {
        return &fstdout;
    }
    if (f == cast(File*) STDIN_FILENO)
    {
        return &fstdin;
    }
    return f;
}

/// Close stream
extern (C) int fclose(FILE* f)
{
    return nanoclose(checkStdHandler(f));
}

extern (C) int fputc(int c, FILE* stream)
{
    return nanoputc(c, checkStdHandler(stream));
}

extern (C) size_t fwrite(const void* ptr, size_t size, size_t nitems, FILE* stream)
{
    return nanowrite(ptr, size, nitems, checkStdHandler(stream));
}

extern (C) size_t fread(void* ptr, size_t size, size_t nitems, FILE* stream)
{
    return nanoread(ptr, size, nitems, checkStdHandler(stream));
}

/// Returns strlen(s) on success
extern (C) int fputs(const char* s, FILE* stream)
{
    return nanoputs(s, checkStdHandler(stream));
}

extern (C) int fgetc(FILE *stream)
{
    return nanogetc(checkStdHandler(stream));
}

extern(C) int remove(const char* pathname)
{
    import nanoc.std.unistd: unlink;
    return unlink(pathname);
}

extern(C) long ftell(FILE* stream)
{
    return nanotell(checkStdHandler(stream));
}

enum SEEK_CUR = 1;
enum SEEK_END = 2;
enum SEEK_SET = 0;

extern(C) int fseek(FILE *stream, long offset, int whence)
{
    return nanoseek(checkStdHandler(stream), offset, whence);
}

extern (C) int ferror(FILE* stream)
{
    return nanoerror(checkStdHandler(stream));
}

extern (C) void clearerr(FILE *stream)
{
    nanoclearerr(checkStdHandler(stream));
}

extern (C) void rewind(FILE *stream)
{
    nanorewind(checkStdHandler(stream));
}

extern (C) int feof(FILE* stream)
{
    return nanoeof(checkStdHandler(stream));
}
