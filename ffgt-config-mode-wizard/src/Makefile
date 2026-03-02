all: mapped_email

CFLAGS += -Wall -g -fPIC -D_GNU_SOURCE

mapped_mail: mapped_mail.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CFLAGS_JSONC) $(LDFLAGS) $(LDLIBS) $(LDFLAGS_JSONC) -o $@ $^
