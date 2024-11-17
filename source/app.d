//module nanoc;

extern (C) int main() {
    // import nanoc.std.unistd: fork;
    // import nanoc.std.stdlib: exit;
    // import nanoc.std.stdio: puts;
    // long r = fork();
    // if (r == 0) {
    //     puts("Child\n".ptr);
    // } else {
    //     puts("Parent\n".ptr);
    // }
    // exit(0);

    // import nanoc.std.string;
    // import nanoc.std.stdlib;
    // import nanoc.std.stdio;
    // int fd = open("my.txt", O_WRONLY | O_CREAT, 0);
    // if (fd < 0) {
    //     puts("Cann't open\n");
    //     exit(-25);
    // }
    // string greeting = "Привет, Юра!\n";
    // write(fd, greeting, strlen(greeting.ptr));
    // close(fd);
    // //return 0;
    // exit(0);
    import nanoc.std.stdlib;
    import nanoc.std.stdio;
    void *p = _malloc(10000);
    if (!p)
    {
        puts("Cann't allocate\n");
        exit(-25);
    }
    puts("Prepare to free\n");
    free(p);
    exit(0);
}
