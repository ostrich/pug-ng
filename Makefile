PREFIX ?= /usr
BINDIR ?= $(DESTDIR)$(PREFIX)/bin
HOOKDIR ?= $(DESTDIR)$(PREFIX)/share/libalpm/hooks
CONFIGDIR ?= $(DESTDIR)/etc/pug-ng

.PHONY: install uninstall

install:
	install -d "$(BINDIR)" "$(HOOKDIR)" "$(CONFIGDIR)"
	install -m 755 src/pug-ng "$(BINDIR)/pug-ng"
	install -m 644 src/pug-ng.hook "$(HOOKDIR)/pug-ng.hook"
	if [ ! -e "$(CONFIGDIR)/config" ]; then install -m 644 src/pug-ng.conf "$(CONFIGDIR)/config"; fi

uninstall:
	rm -f "$(BINDIR)/pug-ng"
	rm -f "$(HOOKDIR)/pug-ng.hook"
