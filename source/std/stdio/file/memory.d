module nanoc.std.stdio.file.memory;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

template FileInterface(alias A)
    if (A == File.Type.MEMORY_STREAM)
{
    int _fclose(File* f)
    {
        import nanoc.std.stdlib: _free;
        _free(f);
        return 0;
    }

    int _fputc(int c, FILE* stream)
    {
        FILE.Mem* memory = &stream.memory;
        long offset = memory.offset;
        char x = cast(char) c;
        if (offset < memory.size)
        {
            char[] buf = cast(char[]) memory.data;
            buf[offset] = x;
            memory.offset++;
            return x;
        }
        return EOF;
    }
}

extern(C) FILE* fmemopen(void[] buf, size_t size, const char* mode)
{
    import nanoc.std.stdlib: _malloc, _free;
    FILE* f = cast(FILE*) _malloc(FILE.sizeof);
    if (f)
    {
        f.type = FILE.Type.MEMORY_STREAM;
        f.memory.data = buf;
        f.memory.size = size;
        f.memory.mode = O_RDWR;
        f.memory.offset = 0;
        return f;
    }
    return null;
}
