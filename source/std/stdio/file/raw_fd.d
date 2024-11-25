module nanoc.std.stdio.file.raw_fd;

import nanoc.std.stdio.file;

int _fclose(File.Type type)(File* f)
    if (type == File.Type.OS)
{
    import nanoc.std.stdlib: _free;
    import nanoc.std.stdio.common;
    int r = close(f.raw_fd);
    if (r < 0)
    {
        return EOF;
    }
    _free(f);
    return 0;
}
