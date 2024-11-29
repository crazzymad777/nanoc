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
        else
        {
            imode |= O_CREAT | O_TRUNC;
        }
    }
    *rmode = imode;
    return rmode;
}
