all: mapped_email

CFLAGS += -Wall -g -fPIC -D_GNU_SOURCE

respondd: mapped_email.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(LDLIBS) -shared -o $@ $^
