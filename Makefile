WAYLAND_FLAGS = $(shell pkg-config wayland-client --cflags --libs)
WAYLAND_PROTOCOLS_DIR = $(shell pkg-config wayland-protocols --variable=pkgdatadir)
WAYLAND_SCANNER = $(shell pkg-config --variable=wayland_scanner wayland-scanner)
CFLAGS ?= -std=c11 -Wall -Wextra -Werror -Wno-unused-parameter -g

XDG_SHELL_PROTOCOL = $(WAYLAND_PROTOCOLS_DIR)/stable/xdg-shell/xdg-shell.xml

XDG_SHELL_FILES=xdg-shell-client-protocol.h xdg-shell-protocol.c
SHM_FILES=shm.c shm.h

all: hello-wayland

hello-wayland: main.c cat.h $(XDG_SHELL_FILES) shm.o
	$(CC) $(CFLAGS) -o $@ $^ -lrt $(WAYLAND_FLAGS)

xdg-shell-client-protocol.h:
	$(WAYLAND_SCANNER) client-header $(XDG_SHELL_PROTOCOL) xdg-shell-client-protocol.h

xdg-shell-protocol.c:
	$(WAYLAND_SCANNER) private-code $(XDG_SHELL_PROTOCOL) xdg-shell-protocol.c

cat.h: cat.png
	convert cat.png -define h:format=bgra -depth 8 cat.h

cat.d: cat.h
	cat cat.h \
	| sed 's/static const unsigned char/static immutable ubyte[] MagickImage = [/g;1,3d;5,6d;s/\s*}\;/]\;/g' \
	> cat.d

shm.o:
	dmd -c -betterC shm.d

.PHONY: clean
clean:
	$(RM) hello-wayland cat.h $(XDG_SHELL_FILES) shm.o cat.d
