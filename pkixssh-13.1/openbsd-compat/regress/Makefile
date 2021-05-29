sysconfdir=${prefix}/etc
piddir=/var/run
srcdir=.
top_srcdir=../..


CC=gcc
LD=gcc
CFLAGS=-g -O2 -pipe -Wno-error=format-truncation -Wall -Wextra -Wpointer-arith -Wuninitialized -Wsign-compare -Wformat-security -Wsizeof-pointer-memaccess -Wno-pointer-sign -Wno-unused-result -fno-strict-aliasing -D_FORTIFY_SOURCE=2 -fno-builtin-memset -fstack-protector-strong  
CPPFLAGS=-I../.. -I$(srcdir)/../..  -D_XOPEN_SOURCE=600 -D_BSD_SOURCE -D_DEFAULT_SOURCE -DHAVE_CONFIG_H
EXEEXT=
LIBCOMPAT=../libopenbsd-compat.a
LIBS=-ldl -lcrypto  -lutil -lz  -lcrypt -lresolv
LDFLAGS= -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -fstack-protector-strong  $(LIBCOMPAT)

TESTPROGS=closefromtest$(EXEEXT) snprintftest$(EXEEXT) strduptest$(EXEEXT) \
	strtonumtest$(EXEEXT) opensslvertest$(EXEEXT) utimensattest$(EXEEXT)

all:	t-exec ${OTHERTESTS}

%$(EXEEXT):	%.c $(LIBCOMPAT)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $@ $< $(LIBCOMPAT) $(LIBS)

t-exec:	$(TESTPROGS)
	@echo running compat regress tests
	@for TEST in ""$?; do \
		echo "run test $${TEST}" ... 1>&2; \
		./$${TEST}$(EXEEXT) || exit $$? ; \
	done
	@echo finished compat regress tests

clean:
	rm -f *.o *.a core $(TESTPROGS) valid.out

distclean: clean
	rm -f Makefile *~
