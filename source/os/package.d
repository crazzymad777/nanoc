module nanoc.os;

// NanoC runtime -> NanoC Portability layer -> Kernel interface

version (X86_64)
{
    version (linux)
    {
        public import nanoc.os.linux_amd64;
    }
}

struct Buffer(bool nullable = false, bool autocount = false)
{
    this(const char* data, size_t length)
    {
        static if (nullable == false)
        {
            assert(data !is null);
        }

        static if (autocount)
        {
            if (length == -1)
            {
                static if (nullable)
                {
                    if (data is null)
                    {
                        length = 0;
                        return;
                    }
                }
                import nanoc.std.string: strlen;
                length = strlen(data);
            }
        }

        this.data = data;
        this.len = length;
    }
    const char* data;
    size_t len;
}

// Nullable, Autocount = NullableString
// Autocount = StringBuffer
// Nullable = NullableBuffer
// _ = MemoryChunk

alias MemoryChunk = Buffer!(false, false);
alias NullableBuffer = Buffer!(true, false);
alias StringBuffer = Buffer!(false, true);
alias NullableString = Buffer!(true, true);

/// Terminate a process with given Status
//noreturn exit(int status);

package(nanoc.os):
__gshared int sys_errno;
