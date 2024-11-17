module nanoc.std.stdlib.memory;

public import nanoc.std.stdlib.naive: _realloc;

struct SuperMemoryBlock
{
    MemoryBlock entry;
    MemoryBlock next_field;
    MemoryBlock head;
    byte[0] data;
}

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

__gshared SuperMemoryBlock* superHeap;

extern(C)
SuperMemoryBlock* _init_super_heap(size_t size)
{
    if (size < MemoryBlock.sizeof * 4)
    {
        return null;
    }

    import nanoc.sys.mman: mmap, PROT_READ, PROT_WRITE, MAP_PRIVATE, MAP_ANONYMOUS;
    import nanoc.std.errno: errno;
    SuperMemoryBlock* block = cast(SuperMemoryBlock*) mmap(null, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (block)
    {
        block.entry.flags = MemoryBlock.CLAIMED | MemoryBlock.PRIMARY | MemoryBlock.NANOC_MEMORY;
        block.entry.size = size;
        _init_nanoc_super_heap(block, size);
        return block;
    }
    return null;
}

extern (C)
void _init_nanoc_super_heap(SuperMemoryBlock* superblock, size_t size)
{
    alias HEAD_BLOCK_POINTER = MemoryBlock.HEAD_BLOCK_POINTER;
    alias NEXT_HEAP_POINTER = MemoryBlock.NEXT_HEAP_POINTER;
    alias NANOC_MEMORY = MemoryBlock.NANOC_MEMORY;
    alias HEAD = MemoryBlock.HEAD;

    superblock.next_field.flags = NEXT_HEAP_POINTER;
    superblock.next_field.next_super_heap = null;

    superblock.head.flags = NANOC_MEMORY | HEAD;
    superblock.head.size = size - MemoryBlock.sizeof * 3;

    MemoryBlock* tail = cast(MemoryBlock*) (&superblock.entry.data + size - MemoryBlock.sizeof*2);
    tail.flags = NANOC_MEMORY | MemoryBlock.TAIL;
    tail.head = &superblock.head;
}

MemoryBlock* dedicate_memory_block(SuperMemoryBlock* superblock, size_t size)
{
    if (superblock is null) return null;

    import nanoc.std.errno: errno, EINVAL;
    if (superblock.entry.flags & MemoryBlock.NANOC_MEMORY)
    {
        auto new_block_size = size + MemoryBlock.sizeof;
        if (new_block_size < superblock.head.size)
        {
            superblock.head.size -= new_block_size;
            MemoryBlock* subblock = &superblock.head + superblock.head.size/MemoryBlock.sizeof;
            subblock.size = new_block_size;
            return subblock;
        }
        return null;
    }
    errno = EINVAL;
    return null;
}

void* _malloc(size_t size)
{
    if (superHeap is null)
    {
        superHeap = _init_super_heap(4096); // size + MemoryBlock.sizeof*4);
    }

    alias CLAIMED = MemoryBlock.CLAIMED;
    alias HEAD = MemoryBlock.HEAD;
    alias TAIL = MemoryBlock.TAIL;

    auto superblock = superHeap;
    MemoryBlock* block = dedicate_memory_block(superblock, size);

    // if (block is null)
    // {
    //     block = _init_super_heap(size+MemoryBlock.sizeof*4);
    //     if (block)
    //     {
    //         MemoryBlock* nextHeap = cast(MemoryBlock*) &block.data;
    //         MemoryBlock* head = nextHeap + 1;
    //         head.flags = CLAIMED | HEAD;
    //         MemoryBlock* tail = block+ size - 1;
    //         tail.flags = CLAIMED | TAIL;
    //         return cast(void*) (block + 3);
    //     }
    // }

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
