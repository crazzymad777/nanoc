module nanoc.std.stdio.file.memory;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

template FileInterface(alias A)
    if (A == File.Type.MEMORY_STREAM)
{
    int _fclose(File* f)
    {
        import nanoc.std.stdlib: _free;
        if (f.memory.callee_free)
        {
            _free(f.memory.data_ptr);
        }
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
            char* buf = cast(char*) memory.data_ptr;
            buf[offset] = x;
            memory.offset++;
            return x;
        }

        stream.eof = true;
        return EOF;
    }

    int _fgetc(FILE* stream)
    {
        FILE.Mem* memory = &stream.memory;
        long offset = memory.offset;
        if (offset < memory.size)
        {
            char* buf = cast(char*) memory.data_ptr;
            char x = buf[offset];
            memory.offset += 1;
            return cast(int) x;
        }
        stream.eof = true;
        return EOF;
    }

    fpos_t _seek(FILE *stream, fpos_t offset, int whence)
    {
        if (whence == SEEK_CUR)
        {
            stream.memory.offset += offset;
        }
        else if (whence == SEEK_END)
        {
            stream.memory.offset = stream.memory.size + offset;
        }
        else if (whence == SEEK_SET)
        {
            stream.memory.offset = offset;
        }

        if (stream.memory.offset < 0 || stream.memory.offset >= stream.memory.size)
        {
            stream.eof = true;
            return -1;
        }

        return stream.memory.offset;
    }

    int _write(FILE* stream, const void* data, size_t size)
    {
        if (stream.memory.offset + size > stream.memory.size)
        {
            return EOF;
        }

        auto offset = stream.memory.offset;
        byte* start = cast(byte*) stream.memory.data_ptr;
        import nanoc.std.string: memcpy;
        memcpy(start + offset, data, size);
        return cast(int) size;
    }

    int _read(FILE* stream, void* data, size_t size)
    {
        if (stream.memory.offset + size > stream.memory.size)
        {
            return EOF;
        }

        auto offset = stream.memory.offset;
        byte* start = cast(byte*) stream.memory.data_ptr;
        import nanoc.std.string: memcpy;
        memcpy(data, start + offset, size);
        return cast(int) size;
    }
}

unittest
{
    import nanoc.std.stdio.format.print;
    char[32] memory;
    char[32] buffer;
    File* f = fmemopen(cast(void*) memory, 32, "w");
    assert(f !is null);
    size_t r = fwrite(cast(void*) buffer, 4, 8, f);
    assert(r == 8);
    fclose(f);
}

extern(C) FILE* fmemopen(void* buf, size_t size, const char* mode)
{
    import nanoc.std.stdio.file.utils: parseMode;
    int imode = 0;
    if (parseMode(mode, &imode) is null)
    {
        import nanoc.std.errno: errno;
        errno = -22; // EINVAL
        return null;
    }

    import nanoc.std.stdlib: _malloc, _free;
    FILE* f = cast(FILE*) _malloc(FILE.sizeof);
    if (f)
    {
        f.type = FILE.Type.MEMORY_STREAM;
        if (buf is null)
        {
            auto x = _malloc(size);
            if (x is null)
            {
                _free(f);
                return null;
            }
            f.memory.data_ptr = x;
            f.memory.callee_free = true;
        }
        else
        {
            f.memory.data_ptr = buf;
        }
        f.memory.size = size;
        f.mode = O_RDWR;
        f.memory.offset = 0;
        return f;
    }
    return null;
}

unittest
{
    char[10] buffer;
    auto f = fmemopen(cast(void*)&buffer, 10, "r+".ptr);
    assert(f !is null);
    assert(fputc('a', f) == 'a');
    assert(fputc('b', f) == 'b');
    assert(fputc('c', f) == 'c');
    assert(fseek(f, 0, SEEK_SET) == 0);
    assert(fgetc(f) == 'a');
    assert(fgetc(f) == 'b');
    assert(fgetc(f) == 'c');
    fclose(f);
}

unittest
{
    char[10] buffer;
    auto f = fmemopen(cast(void*)&buffer, 10, "r+".ptr);
    assert(fseek(f, 0, SEEK_END) == -1);
    assert(fputc('a', f) == EOF);
    fclose(f);
}

unittest
{
    auto f = fmemopen(null, 10, "r+".ptr);
    assert(f !is null);
    fclose(f);
}

unittest
{
    char[1] buffer;
    auto f = fmemopen(cast(void*)&buffer, 1, "r+".ptr);
    assert(fputc('a', f) == 'a');
    assert(feof(f) == 0);
    assert(fputc('a', f) == EOF);
    assert(feof(f) == 1);
    fclose(f);
}
