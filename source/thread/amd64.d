module nanoc.thread.amd64;

import nanoc.thread;

Thread* thread_self()
{
    Thread *self;
	asm {
        "mov %%fs:0,%0" : "=r" (self);
	};
	return self;
}

extern(C) int set_thread_area(void *pointer)
{
    import nanoc.os: syscall, SYS_arch_prctl;
    return cast(int) syscall(SYS_arch_prctl, 0x1002, pointer);
}
