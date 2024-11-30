module nanoc.std.stdio.file.core;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

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

import nanoc.std.stdio.file.dynamic_memory;
import nanoc.std.stdio.file.cookie;
import nanoc.std.stdio.file.raw_fd;
import nanoc.std.stdio.file.memory;

import std.traits;
import std.meta;

/// Close stream
int nanoclose(FILE* f)
{
    static foreach (x; EnumMembers!(File.Type))
    {
        if (f.type == x)
        {
            return FileInterface!(Alias!x).close(f);
        }
    }
    return EOF;
}

int nanoputc(int c, FILE* stream)
{
    static foreach (x; EnumMembers!(File.Type))
    {
        if (stream.type == x)
        {
            return FileInterface!(Alias!x).put(c, stream);
        }
    }
    return EOF;
}

size_t nanowrite(const void* ptr, size_t size, size_t nitems, FILE* stream)
{
    if (size == 0)
    {
        return 0;
    }

    byte* data = cast(byte*) ptr;
    size_t n = nitems;
    general: for (; n > 0; n--)
    {
        static foreach (x; EnumMembers!(File.Type))
        {
            if (stream.type == x)
            {
                int ret = FileInterface!(Alias!x).write(stream, data, size);
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

size_t nanoread(void* ptr, size_t size, size_t nitems, FILE* stream)
{
    if (size == 0)
    {
        return 0;
    }

    byte* data = cast(byte*) ptr;
    size_t n = nitems;
    general: for (; n > 0; n--)
    {
        static foreach (x; EnumMembers!(File.Type))
        {
            if (stream.type == x)
            {
                int ret = FileInterface!(Alias!x).read(stream, data, size);
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
int nanoputs(const char* s, FILE* stream)
{
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

int nanogetc(FILE *stream)
{
    static foreach (x; EnumMembers!(File.Type))
    {
        if (stream.type == x)
        {
            return FileInterface!(Alias!x).get(stream);
        }
    }
    return EOF;
}

long nanotell(FILE* stream)
{
    static foreach (x; EnumMembers!(File.Type))
    {
        if (stream.type == x)
        {
            return FileInterface!(Alias!x).seek(stream, 0, SEEK_CUR);
        }
    }
    return -1;
}

int nanoseek(FILE *stream, long offset, int whence)
{
    static foreach (x; EnumMembers!(File.Type))
    {
        if (stream.type == x)
        {
            return FileInterface!(Alias!x).seek(stream, offset, whence) == -1 ? -1 : 0;
        }
    }
    return -1;
}

int nanoerror(FILE* stream)
{
    return stream.error;
}

void nanoclearerr(FILE *stream)
{
    stream.error = 0;
    stream.eof = false;
}

void nanorewind(FILE *stream)
{
    nanoclearerr(stream);
    nanoseek(stream, 0, SEEK_SET);
}

int nanoeof(FILE* stream)
{
    return stream.eof;
}
