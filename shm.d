import core.sys.posix.sys.types : off_t;
import core.sys.posix.fcntl;
import core.sys.posix.sys.mman;
import core.sys.posix.time;
import core.sys.posix.unistd;

extern (C):

int create_shm_file(off_t size) {
    int fd = anonymous_shm_open();
    if (fd < 0) {
        return fd;
    }

    if (ftruncate(fd, size) < 0) {
        close(fd);
        return -1;
    }

    return fd;
}

/**
 * Boilerplate to create an in-memory shared file.
 *
 * Link with `-lrt`.
 */

static void randname(char *buf) {
    timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    long r = ts.tv_nsec;
    for (int i = 0; i < 6; ++i) {
        buf[i] = 'A'+(r&15)+(r&16)*2;
        r >>= 5;
    }
}

static int anonymous_shm_open() {
    import core.stdc.errno : errno, EEXIST;
    char[21] name = "/hello-wayland-XXXXXX";
    int retries = 100;

    do {
        randname(name.ptr + name.length - 6);

        --retries;
        // shm_open guarantees that O_CLOEXEC is set
        int fd = shm_open(name.ptr, O_RDWR | O_CREAT | O_EXCL, 0b110000000);
        if (fd >= 0) {
            shm_unlink(name.ptr);
            return fd;
        }
    } while (retries > 0 && errno == EEXIST);

    return -1;
}
