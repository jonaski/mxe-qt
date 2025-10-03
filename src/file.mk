# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := file
$(PKG)_WEBSITE  := https://www.darwinsys.com/file/
$(PKG)_DESCR    := Free File Command and Magic Library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.46
$(PKG)_CHECKSUM := c9cc77c7c560c543135edc555af609d5619dbef011997e988ce40a3d75d86088
$(PKG)_SUBDIR   := file-$($(PKG)_VERSION)
$(PKG)_FILE     := file-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://astron.com/pub/file/$($(PKG)_FILE)
$(PKG)_URL_2    := https://distfiles.macports.org/file/$($(PKG)_FILE)
$(PKG)_DEPS     := cc libgnurx bzip2

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://astron.com/pub/file/' | \
    grep 'file-' | \
    $(SED) -n 's,.*file-\([0-9][^>]*\)\.tar.*,\1,p' | \
    tail -1
endef

define $(PKG)_BUILD

    # "file" needs a runnable version of the "file" utility
    # itself. This must match the source code regarding its
    # version. Therefore we build a native one ourselves first.

    cp -Rp '$(1)' '$(1).native'
    cd '$(1).native' && ./configure --disable-libseccomp
    cd '$(1).native' && $(MAKE) -j '$(JOBS)'

    cd '$(1)' && ./configure $(MXE_CONFIGURE_OPTS) --disable-libseccomp CFLAGS='-DHAVE_PREAD -Wno-implicit-function-declaration -Wno-incompatible-pointer-types'
    $(MAKE) -C '$(1)' -j '$(JOBS)' FILE_COMPILE='$(1).native/src/file'
    $(MAKE) -C '$(1)' -j 1 install

    '$(TARGET)-gcc' -W -Wall -Werror -ansi -pedantic '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-file.exe' -lmagic -lgnurx -lshlwapi
endef
