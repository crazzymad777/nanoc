module nanoc.std.stdio.file;

public import nanoc.std.stdio.file.dynamic_memory: open_memstream;
public import nanoc.std.stdio.file.memory: fmemopen;
public import nanoc.std.stdio.file.raw_fd: fopen;
import nanoc.std.stdio.file.dynamic_memory;
import nanoc.std.stdio.file.cookie;
import nanoc.std.stdio.file.raw_fd;
import nanoc.std.stdio.file.memory;
import nanoc.std.stdio.common;

alias fpos_t = long;

/// Internal struct for File
struct FILE {
    /// Define implementation of File template interface (template FileInterface(alias A))
    enum Type {
        OS = 1,
        MEMORY_STREAM = 2,
        DYNAMIC_MEMORY_STREAM = 3,
        COOKIE = 4
    }

    /// Struct for memory streams
    struct Mem {
        /// pointer to buffer
        void* data_ptr;
        /// size of buffer
        size_t size;
        /// ftell
        long offset;
        /// indicates callee must free data_ptr
        bool callee_free;

        /// Only dynamic memory stream: for updating user point
        void** dynamic_data;
        /// Only dynamic memory stream: for updating user size
        size_t* dynamic_size;
    }

    /// Struct for Cookie interface with given user data
    struct Cookie
    {
        extern(C) int function(void* user_data, char*, int) readfn;
        extern(C) int function(void* user_data, const char*, int) writefn;
        extern(C) fpos_t function(void* user_data, fpos_t, int) seekfn;
        extern(C) int function(void* user_data) closefn;
        const void* user_data;
    }

    /// Type of file obviously
    Type type;

    // Generic fields, epilogue:
    /// mode of File
    int mode;
    /// File error
    int error;
    /// End-of-file indicator
    bool eof;
    /// Preallocated File struct (do not issue free)
    bool prealloc;

    /// Type-dependent fields:
    union {
        int raw_fd;
        Mem memory;
        Cookie cookie;
    }
};

/// Adorable alias
alias File = FILE;

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

extern (C) size_t fwrite(const void* ptr, size_t size, size_t nitems, FILE* stream)
{
    if (size == 0)
    {
        return 0;
    }

    size_t n = nitems;
    import std.traits;
    import std.meta;

    byte* data = cast(byte*) ptr;
    general: for (; n > 0; n--)
    {
        static foreach (x; EnumMembers!(File.Type))
        {
            if (stream.type == x)
            {
                int ret = FileInterface!(Alias!x)._write(stream, data, size);
                if (ret == size)
                {
                    data += size;
                }
                else
                {
                    break general;
                }
            }
        }
    }

    return nitems - n;
}

extern (C) size_t fread(void* ptr, size_t size, size_t nitems, FILE* stream)
{
    if (size == 0)
    {
        return 0;
    }

    size_t n = nitems;
    import std.traits;
    import std.meta;

    byte* data = cast(byte*) ptr;
    general: for (; n > 0; n--)
    {
        static foreach (x; EnumMembers!(File.Type))
        {
            if (stream.type == x)
            {
                int ret = FileInterface!(Alias!x)._read(stream, data, size);
                if (ret == size)
                {
                    data += size;
                }
                else
                {
                    break general;
                }
            }
        }
    }

    return nitems - n;
}

/// Returns strlen(s) on success
extern (C) int fputs(const char* s, FILE* stream)
{
    stream = checkStdHandler(stream);

    import nanoc.std.string: strlen;
    import nanoc.os;

    size_t size = strlen(s);
    long r = fwrite(cast(void*) s, 1, size, stream);

    if (r == 0 && size != 0)
    {
        return EOF;
    }

    if (r >= 0)
    {
        return cast(int) r;
    }
    // inherits error or EOF possibly
    return EOF;
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
            return FileInterface!(Alias!x)._seek(stream, 0, SEEK_CUR);
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
            return FileInterface!(Alias!x)._seek(stream, offset, whence) == -1 ? -1 : 0;
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
