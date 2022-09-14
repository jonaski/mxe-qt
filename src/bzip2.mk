# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := bzip2
$(PKG)_WEBSITE  := https://www.sourceware.org/bzip2/
$(PKG)_DESCR    := freely available, patent free, high-quality data compressor
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.8
$(PKG)_CHECKSUM := ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269
$(PKG)_SUBDIR   := bzip2-$($(PKG)_VERSION)
$(PKG)_FILE     := bzip2-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://sourceware.org/pub/bzip2/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://sourceware.org/pub/bzip2/' | \
    grep 'bzip2-' | \
    $(SED) -n 's,.*bzip2-\([0-9][^>]*\)\.tar.*,\1,p' | \
    sort -V | \
    tail -1
endef

define $(PKG)_BUILD_COMMON
    $(MAKE) -C '$(1)' -j '$(JOBS)' libbz2.a PREFIX='$(PREFIX)/$(TARGET)' CC='$(TARGET)-gcc' AR='$(TARGET)-ar' RANLIB='$(TARGET)-ranlib'
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib'
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/include'
    $(INSTALL) -m644 '$(1)/bzlib.h' '$(PREFIX)/$(TARGET)/include/'

    # create pkg-config file
    mkdir -p '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $(PKG)'; \
     echo 'Libs: -lbz2'; \
    ) > '$(PREFIX)/$(TARGET)/lib/pkgconfig/bzip2.pc'
endef

define $(PKG)_BUILD
    $($(PKG)_BUILD_COMMON)
    $(INSTALL) -m644 '$(1)/libbz2.a' '$(PREFIX)/$(TARGET)/lib/'
endef

define $(PKG)_BUILD_SHARED
    $($(PKG)_BUILD_COMMON)
    '$(TARGET)-gcc' '$(1)'/*.o -shared -o '$(PREFIX)/$(TARGET)/bin/libbz2.dll' -Xlinker --out-implib -Xlinker '$(PREFIX)/$(TARGET)/lib/libbz2.dll.a'
endef
