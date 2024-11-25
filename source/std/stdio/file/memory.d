module nanoc.std.stdio.file.memory;

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
        import nanoc.std.stdio.common;
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
