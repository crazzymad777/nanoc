module nanoc.std.stdio.file.dynamic_memory;

import nanoc.std.stdio.file.memory;
import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

import std.meta;

alias ParentInterface = nanoc.std.stdio.file.memory.FileInterface!(Alias!File.Type.MEMORY_STREAM);

template FileInterface(alias A)
    if (A == File.Type.DYNAMIC_MEMORY_STREAM)
{
    int _fclose(File* f)
    {
        ParentInterface._fclose(f);
        return 0;
    }

    int _fputc(int c, FILE* stream)
    {
        FILE.Mem* memory = &stream.memory;
        long offset = memory.offset;
        char x = cast(char) c;
        if (offset >= memory.size)
        {
            if (!realloc_dynamic_stream_buffer(stream, offset))
            {
                stream.eof = true;
                return EOF;
            }
        }

        return ParentInterface._fputc(c, stream);
    }

    int _fgetc(FILE* stream)
    {
        return ParentInterface._fgetc(stream);
    }

    fpos_t _seek(FILE *stream, fpos_t offset, int whence)
    {
        // Try seek regular memory stream
        fpos_t result = ParentInterface._seek(stream, offset, whence);

        if (result >= 0)
        {
            // Everything fine
            return result;
        }

        if (stream.memory.offset < 0)
        {
            stream.eof = true;
            return -1;
        }

        if (realloc_dynamic_stream_buffer(stream, stream.memory.offset))
        {
            return stream.memory.offset;
        }

        stream.eof = true;
        return -1;
    }

    int _write(FILE* stream, const void* data, size_t size)
    {
        auto offset = stream.memory.offset; // preserve prior offset
        stream.memory.offset += size;
        if (!realloc_dynamic_stream_buffer(stream, offset))
        {
            return EOF;
        }

        return ParentInterface._write(stream, data, size);
    }

    int _read(FILE* stream, void* data, size_t size)
    {
        return ParentInterface._read(stream, data, size);
    }
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

private bool realloc_dynamic_stream_buffer(FILE* stream, fpos_t setOffset)
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
        stream.memory.offset = setOffset;
        return true;
    }
    stream.memory.offset = setOffset;
    return false;
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
    assert(fseek(f, 64, SEEK_SET) == 0);
    assert(fputc('a', f) == 'a');
    assert(fputc('b', f) == 'b');
    assert(fputc('c', f) == 'c');
    assert(fseek(f, 64, SEEK_SET) == 0);
    assert(fgetc(f) == 'a');
    assert(fgetc(f) == 'b');
    assert(fgetc(f) == 'c');
    fclose(f);
}

