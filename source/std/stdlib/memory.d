module nanoc.std.stdlib.memory;

public import nanoc.std.stdlib.naive: _realloc;

struct MemoryBlock
{
    enum MemoryBlockFlagsOffset
    {
        CLAIMED = 0,
        PRIMARY = 1,
        NANOC_MEMORY = 2,
        NEXT_HEAP_POINTER = 3,
        HEAD_BLOCK_POINTER = 4,
        HEAD = 5
    }
    enum
    {
        CLAIMED = 1,
        PRIMARY = 2,
        NANOC_MEMORY = 4,
        NEXT_HEAP_POINTER = 8,
        HEAD_BLOCK_POINTER = 16,
        HEAD = 32
    }
    alias TAIL = HEAD_BLOCK_POINTER;

    union {
		size_t size;
		void* head; // for tail, correspodent head
		void* next_super_heap; // for NextSuperHeap
	}
	long flags;
	byte[0] data;
}

__gshared MemoryBlock* superHeap;

extern(C)
MemoryBlock* _init_super_heap(size_t size)
{
    if (size < MemoryBlock.sizeof * 4)
    {
        return null;
    }

    int retries = 10;

    import nanoc.sys.mman: mmap, PROT_READ, PROT_WRITE, MAP_PRIVATE, MAP_ANONYMOUS;
    import nanoc.std.errno: errno;
    MemoryBlock* block = null;

    do
    {
        block = cast(MemoryBlock*) mmap(null, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        retries--;
    }
    while (block == null && errno == -11 && retries > 0);

    import nanoc.std.string: memset;
    memset(block, 0, size);

    if (block)
    {
        block.flags = MemoryBlock.CLAIMED | MemoryBlock.PRIMARY | MemoryBlock.NANOC_MEMORY;
        block.size = size;
        _init_nanoc_super_heap(block, size);
        return block;
    }
    return null;
}

extern (C)
void _init_nanoc_super_heap(MemoryBlock* superblock, size_t size)
{
    alias HEAD_BLOCK_POINTER = MemoryBlock.HEAD_BLOCK_POINTER;
    alias NEXT_HEAP_POINTER = MemoryBlock.NEXT_HEAP_POINTER;
    alias NANOC_MEMORY = MemoryBlock.NANOC_MEMORY;
    alias HEAD = MemoryBlock.HEAD;

    //block.flags |= NANOC_MEMORY;
    MemoryBlock* nextHeap = superblock + 1;
    nextHeap.flags = NEXT_HEAP_POINTER;
    nextHeap.next_super_heap = null;

    MemoryBlock* head = nextHeap + 1;
    head.flags = NANOC_MEMORY | HEAD;
    head.size = size - MemoryBlock.sizeof * 3;

    MemoryBlock* tail = cast(MemoryBlock*) (&superblock.data + size - MemoryBlock.sizeof*2);
    tail.flags = NANOC_MEMORY | MemoryBlock.TAIL;
    tail.head = head;
}

MemoryBlock* dedicate_memory_block(MemoryBlock* superblock, size_t size)
{
    import nanoc.std.errno: errno, EINVAL;
    if (superblock.flags & MemoryBlock.NANOC_MEMORY)
    {
        MemoryBlock* head = superblock + 2;
        auto new_block_size = size + MemoryBlock.sizeof;
        if (new_block_size < head.size)
        {
            head.size -= new_block_size;
            MemoryBlock* sublock = head + head.size/MemoryBlock.sizeof;
            sublock.size = new_block_size;
            return sublock;
        }
        return null;
    }
    errno = EINVAL;
    return null;
    //return _init_super_heap(size+MemoryBlock.sizeof*4);
}

void* _malloc(size_t size)
{
    if (superHeap is null)
    {
        superHeap = _init_super_heap(4096);//size+MemoryBlock.sizeof*4);
    }

    if (superHeap is null)
    {
        return null;
    }

    alias CLAIMED = MemoryBlock.CLAIMED;
    alias HEAD = MemoryBlock.HEAD;
    alias TAIL = MemoryBlock.TAIL;

    MemoryBlock* superblock = superHeap;

    // = _init_super_heap(2048);
    if (superblock is null)
    {
        superblock = _init_super_heap(size+MemoryBlock.sizeof*5);
    }

    MemoryBlock* block = dedicate_memory_block(superblock, size);

    if (block is null)
    {
        block = _init_super_heap(size+MemoryBlock.sizeof*4);
        if (block)
        {
            MemoryBlock* nextHeap = cast(MemoryBlock*) &block.data;
            MemoryBlock* head = nextHeap + 1;
            head.flags = CLAIMED | HEAD;
            MemoryBlock* tail = block+ size - 1;
            tail.flags = CLAIMED | TAIL;
            return cast(void*) (block + 3);
        }
    }

    if (block)
    {
        block.flags = CLAIMED;
        return cast(void*) (block + 1);
    }
    return null;
}

void unclaim_memory_block(MemoryBlock* block)
{
    alias CLAIMED = MemoryBlock.MemoryBlockFlagsOffset.CLAIMED;

    long flags = block.flags;
    block.flags = flags & ~(1uL << CLAIMED);
}

void _free(void *ptr)
{
    alias PRIMARY = MemoryBlock.PRIMARY;
    import nanoc.sys.mman: munmap;
    auto superblock = cast(MemoryBlock*) (ptr - 3);
    size_t size = superblock.size;

    if (superblock.flags & PRIMARY)
    {
        // called free on head subblock of primary MemoryBlock
        munmap(cast(void*) superblock, size);
    }
    else
    {
        auto parent = cast(MemoryBlock*) (ptr - 1);
        unclaim_memory_block(parent);
        // if between freed block and tail block there is no claimed block then we need to check blocks between head & free block
        // find tail block, unclaim it
        // If super block don't have claimed blocks then free superblock
    }
}
