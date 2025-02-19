module nanoc.std.stdlib.memory;

public import nanoc.std.stdlib.naive: realloc;

import nanoc.meta: Omit;

// Super memory block must have field, head & tail
// Super memory block contains other memory blocks
struct SuperMemoryBlock
{
    union {
        byte[0] begin;
        MemoryBlock entry;
    }
    MemoryBlock field;
    MemoryBlock head;
    byte[0] data;
}

// Memory block must have size and flags
struct MemoryBlock
{
    enum MemoryBlockFlagsOffset
    {
        CLAIMED = 0,
        PRIMARY = 1,
        NANOC_MEMORY = 2,
        NEXT_HEAP_POINTER = 3,
        HEAD_BLOCK_POINTER = 4,
        HEAD = 5,
        SUPERBLOCK = 6
    }
    enum
    {
        CLAIMED = 1, // in use
        PRIMARY = 2, // Allocated with mmap
        NANOC_MEMORY = 4, // belongs to nano C
        NEXT_HEAP_POINTER = 8, // link
        HEAD_BLOCK_POINTER = 16, // tail
        HEAD = 32, // head
        SUPERBLOCK = 64 // superblock
    }
    alias TAIL = HEAD_BLOCK_POINTER;

    union {
		size_t size;
		MemoryBlock* head; // for tail, correspodent head
		SuperMemoryBlock* next_super_heap; // for NextSuperHeap
	}
	long flags;
	byte[0] data;
}

@Omit
__gshared SuperMemoryBlock* beginSuperBlock = null;

extern(C)
@("mmap_wrapper")
@Omit
MemoryBlock* _allocate_primary_memory_block(size_t size)
{
    import nanoc.sys.mman: mmap, PROT_READ, PROT_WRITE, MAP_PRIVATE, MAP_ANONYMOUS;
    // raw memory block
    if (size < MemoryBlock.sizeof)
    {
        return null;
    }

    MemoryBlock* raw_block = cast(MemoryBlock*) mmap(null, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (raw_block)
    {
        raw_block.flags = MemoryBlock.CLAIMED | MemoryBlock.PRIMARY;
        raw_block.size = size;
        return raw_block;
    }
    return null;
}

extern(C)
@("mmap_wrapper")
@Omit
SuperMemoryBlock* _init_super_block(size_t size)
{
    import nanoc.sys.mman: mmap, PROT_READ, PROT_WRITE, MAP_PRIVATE, MAP_ANONYMOUS;
    if (size < MemoryBlock.sizeof * 4)
    {
        return null;
    }

    import core.stdc.stdlib;
    SuperMemoryBlock* block = cast(SuperMemoryBlock*) _allocate_primary_memory_block(size);
    if (block)
    {
        block.entry.flags = MemoryBlock.CLAIMED | MemoryBlock.PRIMARY | MemoryBlock.NANOC_MEMORY | MemoryBlock.SUPERBLOCK;
        block.entry.size = size;
        _init_nanoc_super_heap(block, size);
        return block;
    }
    return null;
}

@Omit
void _init_nanoc_super_heap(SuperMemoryBlock* superblock, size_t size)
{
    alias HEAD_BLOCK_POINTER = MemoryBlock.HEAD_BLOCK_POINTER;
    alias NEXT_HEAP_POINTER = MemoryBlock.NEXT_HEAP_POINTER;
    alias NANOC_MEMORY = MemoryBlock.NANOC_MEMORY;
    alias HEAD = MemoryBlock.HEAD;

    superblock.field.flags = NEXT_HEAP_POINTER;
    superblock.field.next_super_heap = null;

    superblock.head.flags = NANOC_MEMORY | HEAD;
    superblock.head.size = size - MemoryBlock.sizeof * 4;

    byte* tail_in_bytes = cast(byte*)&superblock.begin + size;
    MemoryBlock* tail = cast(MemoryBlock*) tail_in_bytes - 1;
    tail.flags = NANOC_MEMORY | MemoryBlock.TAIL;
    tail.head = &superblock.head;
}

@Omit
MemoryBlock* dedicate_memory_block(SuperMemoryBlock* superblock, size_t size)
{
    if (superblock is null) return null;
    if (size > 4096-MemoryBlock.sizeof*4)
    {
        return null;
    }

    import nanoc.std.errno: errno, EINVAL;
    if (superblock.entry.flags & MemoryBlock.NANOC_MEMORY)
    {
        size_t new_block_size = size + MemoryBlock.sizeof;
        if (new_block_size % 2 == 1)
        {
            new_block_size += 1;
        }

        if (new_block_size < superblock.head.size)
        {
            superblock.head.size -= new_block_size;
            byte* pointer = cast(byte*) &superblock.head.data + superblock.head.size;
            MemoryBlock* subblock = cast(MemoryBlock*) pointer;
            subblock.size = new_block_size;
            subblock.flags = 0;
            return subblock;
        }

        if (!(superblock.head.flags & MemoryBlock.CLAIMED))
        {
            if (new_block_size - MemoryBlock.sizeof <= superblock.head.size)
            {
                // use head block
                superblock.head.flags |= MemoryBlock.CLAIMED;
                return &superblock.head;
            }
        }

        if (superblock.field.next_super_heap is null)
        {
            superblock.field.next_super_heap = _init_super_block(4096);
            if (superblock.field.next_super_heap is null)
            {
                return null;
            }
        }

        return dedicate_memory_block(superblock.field.next_super_heap, size);
    }
    errno = EINVAL;
    return null;
}

/// Dynamic memory allocation
extern (C) void* malloc(size_t size)
{
    if (beginSuperBlock is null)
    {
        beginSuperBlock = _init_super_block(4096); // size + MemoryBlock.sizeof*4);
    }

    alias CLAIMED = MemoryBlock.CLAIMED;
    alias HEAD = MemoryBlock.HEAD;
    alias TAIL = MemoryBlock.TAIL;

    auto superblock = beginSuperBlock;
    MemoryBlock* block = dedicate_memory_block(superblock, size);

    if (block is null)
    {
        block = _allocate_primary_memory_block(size + MemoryBlock.sizeof);
    }

    if (block)
    {
        block.flags |= CLAIMED;
        return cast(void*) (block + 1);
    }
    return null;
}

@Omit
void unclaim_single_memory_block(MemoryBlock* single_block)
{
    alias CLAIMED = MemoryBlock.MemoryBlockFlagsOffset.CLAIMED;
    long flags = single_block.flags;
    single_block.flags = flags & ~(1uL << CLAIMED);
}

@Omit
size_t unclaim_memory_block(MemoryBlock* entry_block, MemoryBlock* block)
{
    unclaim_single_memory_block(block);
    // MemoryBlock* next = cast(MemoryBlock*) (&block.data + block.size);
    // if (next.flags & MemoryBlock.TAIL || next.flags & MemoryBlock.CLAIMED)
    // {
    //     return block.size;
    // }
    // return block.size + unclaim_memory_block(entry_block, next);
    return block.size;
}


/// Free dynamic memory
extern (C) void free(void *ptr)
{
    alias SUPERBLOCK = MemoryBlock.SUPERBLOCK;
    alias PRIMARY = MemoryBlock.PRIMARY;
    import nanoc.sys.mman: munmap;
    auto freed_block = cast(MemoryBlock*) (ptr - 1);

    if (freed_block.flags & PRIMARY)
    {
        if (freed_block.flags & SUPERBLOCK)
        {
            // Primary Superblock detected
            // It should be removed from primary superblock list
            unclaim_single_memory_block(freed_block);
            // Now at least unclaim it
        }
        else
        {
            // called free on PRIMARY memory block
            size_t size = freed_block.size;
            munmap(cast(void*) freed_block, size);
        }
    }
    else
    {
        unclaim_memory_block(freed_block, freed_block);
        // if between freed block and tail block there is no claimed block then we need to check blocks between head & free block
        // find tail block, unclaim it
        // If super block don't have claimed blocks then free superblock
    }
}

alias _malloc = malloc;
alias _free = free;
