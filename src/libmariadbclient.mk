# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libmariadbclient
$(PKG)_WEBSITE  := https://mariadb.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.4.1
$(PKG)_CHECKSUM := 0a7f2522a44a7369c1dda89676e43485037596a7b1534898448175178aedeb4d
$(PKG)_SUBDIR   := mariadb-connector-c-$($(PKG)_VERSION)-src
$(PKG)_FILE     := $($(PKG)_SUBDIR).tar.gz
$(PKG)_URL      := https://archive.mariadb.org/connector-c-$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc openssl zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://archive.mariadb.org/' | \
    $(SED) -n 's,.*connector-c-\([0-9\.]\+\).*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' \
        -DINSTALL_LIB_DIR="$(PREFIX)/$(TARGET)/lib" \
        -DINSTALL_BIN_DIR="$(PREFIX)/$(TARGET)/bin" \
        -DWITH_SSL=ON \
        -DWITH_UNIT_TESTS=OFF \
        '$(1)'
    # def file created by cmake creates link errors
    $(if $(findstring i686-w64-mingw32.shared, $(TARGET)), cp '$(PWD)/src/mariadbclient.def' '$(BUILD_DIR)/libmariadb/mariadbclient.def')
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' install
    cp '$(PREFIX)/$(TARGET)/lib/mariadb/libmariadbclient.a' '$(PREFIX)/$(TARGET)/lib/'
    $(if $(BUILD_STATIC),rm -fv $(shell echo '$(PREFIX)/$(TARGET)/lib/mariadb/libmariadb.dll.a'),)
    $(if $(BUILD_STATIC),rm -fv $(shell echo '$(PREFIX)/$(TARGET)/lib/mariadb/libmariadb.dll'),)
    $(if $(BUILD_SHARED),cp -v '$(PREFIX)/$(TARGET)/lib/mariadb/libmariadb.dll.a' '$(PREFIX)/$(TARGET)/lib/')
    $(if $(BUILD_SHARED),mv -v '$(PREFIX)/$(TARGET)/lib/mariadb/libmariadb.dll' '$(PREFIX)/$(TARGET)/bin/')
endef
