module nanoc.std.stdio.file.memory;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

template FileInterface(alias A)
    if (A == File.Type.MEMORY_STREAM)
{
    int _fclose(File* f)
    {
        import nanoc.std.stdlib: _free;
        if (f.memory.nanoc)
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
        return EOF;
    }

    int _fgetc(FILE* stream)
    {
        FILE.Mem* memory = &stream.memory;
        long offset = memory.offset;
        if (offset < memory.size)
        {
            char* buf = cast(char*) memory.data_ptr;
            memory.offset += 1;
            return cast(int) buf[offset];
        }
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

        if (stream.memory.offset < 0 ||  stream.memory.offset >= stream.memory.size)
        {
            // because memory.size is CONST for given memory area
            return -1;
        }
        return cast(int) stream.memory.offset;
    }
}

extern(C) FILE* fmemopen(void* buf, size_t size, const char* mode)
{
    import nanoc.std.stdlib: _malloc, _free;
    FILE* f = cast(FILE*) _malloc(FILE.sizeof);
    if (f)
    {
        f.type = FILE.Type.MEMORY_STREAM;
        if (buf is null)
        {
            auto x = _malloc(size);
            if (buf is null)
            {
                _free(f);
                return null;
            }
            f.memory.data_ptr = x;
            f.memory.nanoc = true;
        }
        else
        {
            f.memory.data_ptr = buf;
        }
        f.memory.size = size;
        f.memory.mode = O_RDWR;
        f.memory.offset = 0;
        return f;
    }
    return null;
}

unittest
{
    char[10] buffer;
    auto f = fmemopen(cast(void*)&buffer, 10, "rw".ptr);
    fputc('a', f);
    fputc('b', f);
    fputc('c', f);
    fseek(f, 0, SEEK_SET);
    assert(fgetc(f) == 'a');
    assert(fgetc(f) == 'b');
    assert(fgetc(f) == 'c');
    fclose(f);
}


unittest
{
    char[10] buffer;
    auto f = fmemopen(cast(void*)&buffer, 10, "rw".ptr);
    assert(fseek(f, 0, SEEK_END) == -1);
    assert(fputc('a', f) == EOF);
    fclose(f);
}
