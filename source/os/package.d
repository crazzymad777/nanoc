module nanoc.os;

version (X86_64) {
    version (linux) {
        public import nanoc.os.sysv.amd64.syscall;
        public import nanoc.os.sysv.amd64.linux;
    }
}
