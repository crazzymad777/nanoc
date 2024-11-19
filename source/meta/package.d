module nanoc.meta;

import std.meta;

version = DISABLE_METADATA;


version (DISABLE_METADATA)
{
}
else
{

struct ModuleDescriptor
{
    this(string name, string header) immutable
    {
        this.name = name;
        this.header = header;
    }
    immutable string name;
    immutable string header;
}

template Footprint()
{
    alias descriptors = AliasSeq!(
        immutable ModuleDescriptor("nanoc.std.string", "string.h"),
        immutable ModuleDescriptor("nanoc.std.stdlib", "stdlib.h"),
        immutable ModuleDescriptor("nanoc.std.stdio", "stdio.h"),
        immutable ModuleDescriptor("nanoc.std.unistd", "unistd.h"),
        immutable ModuleDescriptor("nanoc.sys.mman", "sys/mman.h"),
        immutable ModuleDescriptor("nanoc.sys.wait", "sys/wait.h")
    );

    void build()
    {
        import nanoc.std.stdio;
        import nanoc.meta.mine;
        import std.traits;


        foreach(mod; descriptors)
        {
            MetaModule!(mod.name, mod.header).mine();
        }
    }

    void write_modules()
    {
        import nanoc.std.stdio;
        import nanoc.meta.mine;
        import std.traits;

        // import std.file;
        // mkdir!string("includes");
        // mkdir!string("includes/sys");

        foreach(mod; descriptors)
        {
            int fd = open( cast(const char*)("includes/" ~ mod.header).ptr, O_WRONLY | O_CREAT, 0);
            fcntl(fd, F_DUPFD, STDOUT_FILENO);
            MetaModule!(mod.name, mod.header).mine();
            close(fd);
        }
    }
}

void footprint()
{
    Footprint!().write_modules();;
    //
}

}
