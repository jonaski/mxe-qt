# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := sqlite
$(PKG)_WEBSITE  := https://www.sqlite.org/
$(PKG)_DESCR    := SQLite database engine
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3490200
$(PKG)_CHECKSUM := 5c6d8697e8a32a1512a9be5ad2b2e7a891241c334f56f8b0fb4fc6051e1652e8
$(PKG)_SUBDIR   := $(PKG)-autoconf-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-autoconf-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://www.sqlite.org/2025/$($(PKG)_FILE)
$(PKG)_DEPS     := cc dlfcn-win32

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.sqlite.org/download.html' | \
    $(SED) -n 's,.*sqlite-autoconf-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure $(MXE_CONFIGURE_OPTS) --disable-readline --enable-threadsafe --out-implib CFLAGS="-Os -DSQLITE_ENABLE_COLUMN_METADATA"
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
    #$(if $(BUILD_SHARED), mv -vf '$(PREFIX)/$(TARGET)/lib/libsqlite3.dll' '$(PREFIX)/$(TARGET)/bin/')
endef
