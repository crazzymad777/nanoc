module nanoc.os;

// NanoC runtime -> NanoC Portability layer -> Kernel interface

version (X86_64)
{
    version (linux)
    {
        public import nanoc.os.linux_amd64;
    }
}

struct Buffer
{
    const char* data;
    size_t length;

    void checkLength()
    {
        if (length == -1)
        {
            import nanoc.std.string: strlen;
            length = strlen(data);
        }
    }
}


/// Terminate a process with given Status
//noreturn exit(int status);

package(nanoc.os):
__gshared int sys_errno;
