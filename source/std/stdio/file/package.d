module nanoc.std.stdio.file;

public import nanoc.std.stdio.file.memory: fmemopen, open_memstream;
public import nanoc.std.stdio.file.raw_fd: fopen;
import nanoc.std.stdio.file.cookie;
import nanoc.std.stdio.file.raw_fd;
import nanoc.std.stdio.file.memory;
import nanoc.std.stdio.common;

alias fpos_t = long;

struct FILE {
    enum Type {
        OS = 1,
        MEMORY_STREAM = 2,
        DYNAMIC_MEMORY_STREAM = 3,
        COOKIE = 4
    }
    struct Mem {
        union {
            void* data_ptr;
        }
        size_t size;

        long offset;
        bool nanoc;
        // bool dynamic;
        void** dynamic_data;
        size_t* dynamic_size;
    };

    struct Cookie
    {
        extern(C) int function(void*, char*, int) readfn;
        extern(C) int function(void*, const char*, int) writefn;
        extern(C) fpos_t function(void*, fpos_t, int) seekfn;
        extern(C) int function(void*) closefn;
        const void* user_data;
    }

    Type type;
    union {
        int raw_fd;
        Mem memory;
        Cookie cookie;
        // fmemopen / memory as stream
        // memory stream / dynamic memory buffer
        // cookie
    }
    int mode;
    int error;
    bool eof;
    bool prealloc;
};

alias File = FILE;

__gshared File fstdin = {type: File.Type.OS, raw_fd: STDIN_FILENO, prealloc: true};
__gshared File fstdout = {type: File.Type.OS, raw_fd: STDOUT_FILENO, prealloc: true};
__gshared File fstderr = {type: File.Type.OS, raw_fd: STDERR_FILENO, prealloc: true};

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

extern (C) int fclose(FILE* f)
{
    f = checkStdHandler(f);
    import std.traits;
    import std.meta;

    static foreach (x; EnumMembers!(File.Type))
    {
        if (f.type == x)
        {
            return FileInterface!(Alias!x)._fclose(f);
        }
    }
    return EOF;
}

extern (C) int fputc(int c, FILE* stream)
{
    stream = checkStdHandler(stream);
    import std.traits;
    import std.meta;

    static foreach (x; EnumMembers!(File.Type))
    {
        if (stream.type == x)
        {
            return FileInterface!(Alias!x)._fputc(c, stream);
        }
    }
    return EOF;
}

extern (C) int fputs(const char* s, FILE* stream)
{
    stream = checkStdHandler(stream);

    if (stream.type == File.Type.OS)
    {
        import std.meta;
        return FileInterface!(Alias!File.Type.OS)._fputs(s, stream);
    }

    // Generic implementation
    int i = 0;
    while (s[i] != '\0')
    {
        int r = fputc(s[i], stream);
        if (r == EOF)
        {
            return EOF;
        }
        i++;
    }
    return i;
}

extern (C) int fgetc(FILE *stream)
{
    stream = checkStdHandler(stream);
    import std.traits;
    import std.meta;

    static foreach (x; EnumMembers!(File.Type))
    {
        if (stream.type == x)
        {
            return FileInterface!(Alias!x)._fgetc(stream);
        }
    }
    return EOF;
}

extern(C) int remove(const char* pathname)
{
    import nanoc.std.unistd: unlink;
    return unlink(pathname);
}

extern(C) long ftell(FILE* stream)
{
    stream = checkStdHandler(stream);
    import std.traits;
    import std.meta;

    static foreach (x; EnumMembers!(File.Type))
    {
        if (stream.type == x)
        {
            return FileInterface!(Alias!x)._ftell(stream);
        }
    }
    return -1;
}

enum SEEK_CUR = 1;
enum SEEK_END = 2;
enum SEEK_SET = 0;

extern(C) int fseek(FILE *stream, long offset, int whence)
{
    stream = checkStdHandler(stream);
    import std.traits;
    import std.meta;

    static foreach (x; EnumMembers!(File.Type))
    {
        if (stream.type == x)
        {
            return FileInterface!(Alias!x)._fseek(stream, offset, whence);
        }
    }
    return -1;
}

extern (C) int ferror(FILE* stream)
{
    stream = checkStdHandler(stream);
    return stream.error;
}

extern (C) void clearerr(FILE *stream)
{
    stream = checkStdHandler(stream);
    stream.error = 0;
    stream.eof = false;
}

extern (C) void rewind(FILE *stream)
{
    stream = checkStdHandler(stream);
    clearerr(stream);
    fseek(stream, 0, SEEK_SET);
}

extern (C) int feof(FILE* stream)
{
    stream = checkStdHandler(stream);
    return stream.eof;
}
