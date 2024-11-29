module nanoc.std.stdio.file.memory;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

template FileInterface(alias A)
    if (A == File.Type.MEMORY_STREAM || A == File.Type.DYNAMIC_MEMORY_STREAM)
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

        // Dynamic size
        static if (A == File.Type.DYNAMIC_MEMORY_STREAM)
        {
            auto result = _fseek(stream, 0, SEEK_CUR);
            if (result >= 0)
            {
                char* buf = cast(char*) memory.data_ptr;
                buf[offset] = x;
                memory.offset++;
                return x;
            }
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

    int _fseek(FILE *stream, long offset, int whence)
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

        if (stream.memory.offset < 0)
        {
            stream.eof = true;
            return -1;
        }

        if (stream.memory.offset >= stream.memory.size)
        {
            // because memory.size is CONST for given memory area

            // Dynamic size, fill nulls
            static if (A == File.Type.DYNAMIC_MEMORY_STREAM)
            {
                import nanoc.std.stdlib: realloc;
                import nanoc.std.string: memset;
                auto surplus = stream.memory.offset+1-stream.memory.size;
                byte* ptr = cast(byte*) realloc(stream.memory.data_ptr, stream.memory.size + surplus);
                if (ptr !is null)
                {
                    byte* end = ptr + stream.memory.size;
                    memset(end, 0, surplus);

                    stream.memory.data_ptr = ptr;
                    stream.memory.size = stream.memory.size + surplus;
                    *(stream.memory.dynamic_data) = cast(void**) stream.memory.data_ptr;
                    *(stream.memory.dynamic_size) = stream.memory.size;
                    return 0;
                }
            }

            stream.eof = true;
            return -1;
        }
        return 0;
    }

    long _ftell(FILE* stream)
    {
        if (stream.memory.offset < 0 ||  stream.memory.offset >= stream.memory.size)
        {
            stream.eof = true;
            return -1;
        }
        return stream.memory.offset;
    }

    int _write(FILE* stream, const void* data, size_t size)
    {
        auto offset = stream.memory.offset;
        auto result = _fseek(stream, size, SEEK_CUR);
        byte* start = cast(byte*) stream.memory.data_ptr;
        if (result == 0 || (result == EOF && stream.memory.size == stream.memory.offset))
        {
            import nanoc.std.string: memcpy;
            memcpy(start + offset, data, size);
            return cast(int) size;
        }
        _fseek(stream, -size, SEEK_CUR);
        return EOF;
    }

    int _read(FILE* stream, void* data, size_t size)
    {
        auto offset = stream.memory.offset;
        auto result = _fseek(stream, size, SEEK_CUR);
        byte* start = cast(byte*) stream.memory.data_ptr;
        if (result == 0 || (result == EOF && stream.memory.size == stream.memory.offset))
        {
            import nanoc.std.string: memcpy;
            memcpy(data, start + offset, size);
            return cast(int) size;
        }
        _fseek(stream, -size, SEEK_CUR);
        return EOF;
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

extern (C) FILE *open_memstream(char **ptr, size_t *sizeloc)
{
    import nanoc.std.stdlib: _malloc;
    FILE* f = cast(FILE*) _malloc(FILE.sizeof);
    if (f)
    {
        f.type = FILE.Type.DYNAMIC_MEMORY_STREAM;
        f.memory.data_ptr = *ptr;
        f.memory.size = *sizeloc;
        f.mode = O_RDWR;
        f.memory.offset = 0;
        f.memory.callee_free = false;
        f.memory.dynamic_data = cast(void**) ptr;
        f.memory.dynamic_size = sizeloc;
        return f;
    }
    return null;
}

unittest
{
    import nanoc.std.stdlib: malloc;
    char* buffer = cast(char*) malloc(32);
    char** buffer_ptr = &buffer;
    size_t sizeloc = 32;
    assert(buffer !is null);
    FILE* f = open_memstream(buffer_ptr, &sizeloc);
    assert(f !is null);
    assert(fseek(f, 32, SEEK_SET) == 0);
    assert(fputc('a', f) == 'a');
    assert(fputc('b', f) == 'b');
    assert(fputc('c', f) == 'c');
    assert(fseek(f, 32, SEEK_SET) == 0);
    assert(fgetc(f) == 'a');
    assert(fgetc(f) == 'b');
    assert(fgetc(f) == 'c');
    fclose(f);
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
