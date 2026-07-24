module nanoc.std.stdlib.memory;

public import nanoc.std.stdlib.naive: realloc;

import nanoc.meta: Omit;

struct PageHeader
{
    size_t size;
    long flags;
    long allocation_bitmap;
    long hold_bitmap;
    Page* next_page;
    byte[24] pad;
}

const uint CELLS_NUMBER = 63;

struct Page
{
    union
    {
        byte[0] begin;
        PageHeader header;
    }
    enum
    {
        PROTECTED = 1 // user can't deallocate page
    }
    long[8][CELLS_NUMBER] cells;
}

unittest
{
    // import nanoc.std.stdio;
    // printf("%d\n", cast(int) PageHeader.sizeof);
    assert(Page.sizeof == 4096);
}

// @Omit
// __gshared Page* pages = null;

@Omit
__gshared Page* main_page = null;

@Omit
void* memory_allocate(Page* page, size_t size)
{
    if (size > 4096-PageHeader.sizeof)
    {
        import nanoc.std.stdio;
        return null;
    }

    // int k = 1;
    int j = 1;
    long list = page.header.hold_bitmap;
    int i = 0;
    for (; i < CELLS_NUMBER; i++)
    {
        if ((list & 1) == 0)
        {
            if (j * long[8].sizeof >= size)
            {
                break;
            }
            else
            {
                j++;
            }
        }
        else
        {
            j = 1;
        }

        list = list >> 1;
    }

    if (i == CELLS_NUMBER)
    {
        import nanoc.std.stdio;
        if (page.header.next_page is null)
        {
            page.header.next_page = create_page();
            if (page.header.next_page is null)
            {
                return null;
            }
        }
        return memory_allocate(page.header.next_page, size);
    }

    long allocation = page.header.allocation_bitmap;
    page.header.allocation_bitmap = allocation | (1uL << i);

    int index = i;
    long hold = page.header.hold_bitmap;
    while (i >= 0)
    {
        hold |= (1uL << i);
        i--;
    }
    page.header.hold_bitmap |= hold;

    return cast (void*) &page.cells[index];
}

@Omit
void memory_deallocate(Page* page, void* ptr)
{
    size_t bytes = cast(size_t) page;
    if (bytes <= cast(size_t) ptr && bytes+4096 > cast(size_t) ptr)
    {
        long index = cast(long[8]*) ptr - &page.cells[0];

        long allocation = 1uL << index;
        long hold = 1uL << index;
        index++;
        for (; index < CELLS_NUMBER; index++)
        {
            if (page.header.allocation_bitmap & (1uL << index))
            {
                break;
            }
            allocation |= 1uL << index;
            hold |= 1uL << index;
        }
        page.header.allocation_bitmap &= ~allocation;
        page.header.hold_bitmap &= ~hold;
        return;
    }
}

@Omit
Page* create_page()
{
    import nanoc.sys.mman: mmap, PROT_READ, PROT_WRITE, MAP_PRIVATE, MAP_ANONYMOUS;
    Page* page = cast(Page*) mmap(null, 4096, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
    if (page is null)
    {
        return null;
    }
    page.header.flags = Page.PROTECTED;
    page.header.size = 4096;
    page.header.allocation_bitmap = 0;
    page.header.hold_bitmap = 0;
    page.header.next_page = null;
    return page;
}

/// Dynamic memory allocation
extern (C) void* malloc(size_t size)
{
    import nanoc.sys.mman: mmap, PROT_READ, PROT_WRITE, MAP_PRIVATE, MAP_ANONYMOUS;
    if (size > 4096-PageHeader.sizeof)
    {
        Page* page = cast(Page*) mmap(null, size + 16, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
        page.header.flags = 0;
        page.header.size = size + 16;
        return cast(void*) &page.header.allocation_bitmap;
    }

    if (main_page == null)
    {
        Page* page = create_page();
        if (page is null)
        {
            return null;
        }
        main_page = page;
    }
    return memory_allocate(main_page, size);
}

/// Free dynamic memory
extern (C) void free(void *ptr)
{
    size_t bytes = cast(size_t) ptr;
    bytes = (bytes / 4096) * 4096;
    Page* page = cast(Page*) bytes;

    if (page.header.flags & Page.PROTECTED)
    {
        memory_deallocate(page, ptr);
        return;
    }

    import nanoc.sys.mman: munmap;
    long* memory = cast(long*) (ptr-2);
    size_t size = memory[0];
    if (memory == ptr)
    {
        munmap(cast(void*) memory, size);
    }
    return;
}

alias _malloc = malloc;
alias _free = free;
