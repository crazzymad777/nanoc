module nanoc.thread;

import nanoc.elf;

version (X86_64)
{
    import nanoc.thread.amd64;
}

// User-space Thread
struct Thread
{
    Thread* self;
    void** dtv;
    void* ptr1;
    void* ptr2;
    void* ptr3;
    ulong tid;

    byte[0] data;
}

// Argument for __tls_get_addr
struct ThreadLocalStorageIndex
{
    size_t module_;
    size_t offset;
}

struct StaticThreadLocalStorage
{
    void* image;
    size_t pad;
    size_t memory;
    size_t size;

    void* fake;
}

__gshared StaticThreadLocalStorage static_tls;

extern(C) void* __tls_get_addr(ThreadLocalStorageIndex vector)
{
    Thread* self = thread_self();

    // return self.dtv[vector[0]] + cast(byte*)self.dtv[vector[1]];
    byte* pointer = cast(byte*) self.dtv[vector.module_] + vector.offset;
    return cast(void*) pointer;
}

void init_thread_local_storage(ulong[NANOC_AT_MAX] aux)
{
    import nanoc.sys.mman: mmap, PROT_READ, PROT_WRITE, MAP_PRIVATE, MAP_ANONYMOUS;
    void* memory = null;
    byte* pointer = cast(byte*) aux[AT_PHDR];
    byte* end = pointer + aux[AT_PHNUM] * aux[AT_PHENT];
    size_t module_base = 0;

    Elf64_Phdr* phdr;
    Elf64_Phdr* tls;

    while (pointer != end) {
		phdr = cast (Elf64_Phdr*) pointer;
		if (phdr.p_type == PT_PHDR)
            module_base = aux[AT_PHDR] - phdr.p_vaddr;
		if (phdr.p_type == PT_TLS)
			tls = phdr;

		pointer += aux[AT_PHENT];
	}

	if (tls !is null)
	{
        byte* image = cast(byte*) tls.p_vaddr + module_base;
        static_tls.image = cast(void*) image;
		static_tls.size = tls.p_filesz;
		static_tls.memory = tls.p_memsz;
		static_tls.pad = tls.p_align;
	}

	static_tls.memory += (cast(byte*)-static_tls.memory - cast(byte*)static_tls.image) & (static_tls.pad - 1);
	if (static_tls.pad < 4 * size_t.sizeof) static_tls.pad = 4 * size_t.sizeof;

	size_t tls_size = 2*(void*).sizeof + static_tls.memory + static_tls.pad + Thread.sizeof;

	if (tls_size < Thread.sizeof+64)
	{
        tls_size = Thread.sizeof+64;
	}

    memory = cast(void*) mmap(null, tls_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    Thread* t = cast(Thread*) memory;
    t.self = t;

    t.dtv[1] = memory;

    set_thread_area(memory);

    import nanoc.os: syscall, SYS_set_tid_address;
    syscall(SYS_set_tid_address, &t.tid);
}

