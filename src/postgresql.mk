# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := postgresql
$(PKG)_WEBSITE  := https://www.postgresql.org/
$(PKG)_DESCR    := PostgreSQL
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 18.0
$(PKG)_CHECKSUM := 0d5b903b1e5fe361bca7aa9507519933773eb34266b1357c4e7780fdee6d6078
$(PKG)_SUBDIR   := postgresql-$($(PKG)_VERSION)
$(PKG)_FILE     := postgresql-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://ftp.postgresql.org/pub/source/v$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc pthreads readline zlib openssl libxml2 icu4c meson-conf

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://ftp.postgresql.org/pub/source/' | \
    $(SED) -n 's,.*href="v\(.*[^/]*\)/".*,\1,p' | \
    grep -v 'rc' | \
    grep -v 'beta' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD_$(BUILD)
    cd '$(SOURCE_DIR)' && meson \
        --prefix='$(PREFIX)/$(TARGET)' \
        --buildtype='$(MESON_BUILD_TYPE)' \
        --pkg-config-path='$(PREFIX)/$(TARGET)/bin/pkgconf' \
        --wrap-mode=nodownload \
        '$(BUILD_DIR)'
    cd '$(BUILD_DIR)' && ninja
    cd '$(BUILD_DIR)' && ninja install
endef

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && CFLAGS='-Wno-implicit-function-declaration -Wno-int-conversion' LDFLAGS='-liconv -ltermcap' '$(TARGET)-meson' --buildtype='$(MESON_BUILD_TYPE)' -Dlibedit_preferred=true '$(BUILD_DIR)'
    cd '$(BUILD_DIR)' && ninja
    cd '$(BUILD_DIR)' && ninja install
endef
