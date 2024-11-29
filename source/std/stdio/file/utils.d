module nanoc.std.stdio.file.utils;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

package(nanoc.std.stdio.file):

int* parseMode(const char* mode, int* rmode)
{
    int imode = 0;
    // rwa+cemx
    bool read = false;
    bool write = false;
    bool extend = false; // +
    bool append = false;
    for (int i = 0; i < 8 && mode[i] != 0; i++)
    {
        if (mode[i] == 'r')
        {
            read = true;
        }
        if (mode[i] == 'w')
        {
            write = true;
        }
        if (mode[i] == 'a')
        {
            append = true;
        }
        if (mode[i] == '+')
        {
            extend = true;
        }
    }

    if (write && append)
    {
        // break
        //_free(f);
        return null;
    }

    if ((write || append) && read)
    {
        imode |= O_RDWR;
    }
    else if (write || append)
    {
        imode |= O_WRONLY;
    }

    if (extend)
    {
        imode = O_RDWR;
    }

    if (imode == O_WRONLY || imode == O_RDWR)
    {
        if (append)
        {
            imode |= O_CREAT | O_APPEND;
        }
        else if (!read)
        {
            imode |= O_CREAT | O_TRUNC;
        }
    }
    *rmode = imode;
    return rmode;
}

unittest
{
    int imode = 0;
    parseMode("r", &imode);
    assert(imode == O_RONLY);
    parseMode("w", &imode);
    assert(imode == (O_WRONLY | O_CREAT | O_TRUNC));
    parseMode("a", &imode);
    assert(imode == (O_WRONLY | O_CREAT | O_APPEND));
    parseMode("r+", &imode);
    assert(imode == (O_RDWR));
    parseMode("rw", &imode);
    assert(imode == (O_RDWR));
    parseMode("w+", &imode);
    assert(imode == (O_RDWR | O_CREAT | O_TRUNC));
    parseMode("a+", &imode);
    assert(imode == (O_RDWR | O_CREAT | O_APPEND));

    int* result = parseMode("wa", &imode); // what do you want ???
    assert(result is null);
}
