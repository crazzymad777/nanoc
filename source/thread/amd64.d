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
