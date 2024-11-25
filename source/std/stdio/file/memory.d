module nanoc.std.stdio.file.memory;

import nanoc.std.stdio.file;

int _fclose(File.Type type)(File* f)
    if (type == File.Type.MEMORY_STREAM)
{
    import nanoc.std.stdlib: _free;
    _free(f);
    return 0;
}
