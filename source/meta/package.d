module nanoc.meta;

import std.meta;

//version = DISABLE_METADATA;

struct SetKey
{
    string name;
}

enum Typedef;
enum Nake;
enum Omit;

version (DISABLE_METADATA)
{
    extern(C) int metadata_version()
    {
        return -1;
    }

    extern(C) void metadata_query(void* ptr)
    {

    }
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
        immutable ModuleDescriptor("nanoc.defs", "nanoc/defs.h"),
        immutable ModuleDescriptor("nanoc.meta.external", "nanoc/metadata.h"),
        immutable ModuleDescriptor("nanoc.std.string", "string.h"),
        immutable ModuleDescriptor("nanoc.std.stdlib", "stdlib.h"),
        immutable ModuleDescriptor("nanoc.std.stdio", "stdio.h"),
        immutable ModuleDescriptor("nanoc.std.unistd", "unistd.h"),
        immutable ModuleDescriptor("nanoc.sys.mman", "sys/mman.h"),
        immutable ModuleDescriptor("nanoc.sys.wait", "sys/wait.h"),
        immutable ModuleDescriptor("nanoc.std.ctype", "ctype.h"),
        immutable ModuleDescriptor("nanoc.std.errno", "errno.h"),
        immutable ModuleDescriptor("nanoc.sys.stat", "sys/stat.h"),
        immutable ModuleDescriptor("nanoc.misc.signal", "signal.h"),
        immutable ModuleDescriptor("nanoc.std.time", "time.h"),
    );

    void show()
    {
        import nanoc.std.stdio;
        import nanoc.meta.show;
        import std.traits;

        foreach(mod; descriptors)
        {
            show_meta_module!(mod.name, mod.header, mod.name)();
        }
    }

    void show_module(char* modulename)
    {
        import nanoc.std.string;
        import nanoc.std.stdio;
        import nanoc.meta.show;
        import std.traits;

        foreach(mod; descriptors)
        {
            if (strcmp(mod.name, modulename) == 0)
            {
                show_meta_module!(mod.name, mod.header, mod.name)();
            }
        }
    }

    void write_modules()
    {
        static import std.conv;
        import nanoc.std.stdio;
        import nanoc.meta.show;
        import nanoc.fcntl;
        import std.traits;

        import nanoc.sys.stat: mkdir;
        mkdir("includes", std.conv.octal!"0755");
        mkdir("includes/sys", std.conv.octal!"0755");
        mkdir("includes/nanoc", std.conv.octal!"0755");

        close(STDOUT_FILENO);
        foreach(mod; descriptors)
        {
            int fd = open( cast(const char*)("includes/" ~ mod.header).ptr, O_WRONLY | O_CREAT | O_TRUNC, std.conv.octal!"0644");
            fcntl(fd, F_DUPFD, STDOUT_FILENO);
            show_meta_module!(mod.name, mod.header, mod.name)();
            close(fd);
        }
    }
}

void footprint()
{
    Footprint!().write_modules();
}

void footprint_module(char* name)
{
    Footprint!().show_module(name);
}

void footprint_all()
{
    Footprint!().show();
}

}
