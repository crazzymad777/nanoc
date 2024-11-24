module nanoc.std.stdio.file;

public import nanoc.std.stdio.file.memory: fmemopen;
public import nanoc.std.stdio.file.raw_fd: fopen;
import nanoc.std.stdio.file.raw_fd;
import nanoc.std.stdio.file.memory;
import nanoc.std.stdio.common;

struct FILE {
    enum Type {
        OS,
        MEMORY_STREAM,
        // DYNAMIC_MEMORY_STREAM,
        // COOKIE
    }
    struct Mem {
        void[] data;
        size_t size;
        int mode;

        long offset;
    };

    Type type;
    union {
        int raw_fd;
        Mem memory;
        // fmemopen / memory as stream
        // memory stream / dynamic memory buffer
        // cookie
    }
};

alias File = FILE;

extern (C) int fclose(FILE* f)
{
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
    return EOF;
}
