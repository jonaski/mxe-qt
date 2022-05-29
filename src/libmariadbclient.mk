# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libmariadbclient
$(PKG)_WEBSITE  := https://mariadb.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.3.1
$(PKG)_CHECKSUM := 29993f4ae4c975662724978792d1a503b9ee760fbb194d321a754253cbe60aad
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
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' -DWITH_SSL=ON -DWITH_UNIT_TESTS=OFF '$(1)'
    # def file created by cmake creates link errors
    $(if $(findstring i686-w64-mingw32.shared, $(TARGET)), cp '$(PWD)/src/mariadbclient.def' '$(BUILD_DIR)/libmariadb/mariadbclient.def')
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' install
    cp '$(PREFIX)/$(TARGET)/lib/mariadb/libmariadbclient.a' '$(PREFIX)/$(TARGET)/lib/'
    cp '$(PREFIX)/$(TARGET)/lib/mariadb/libmariadb.dll.a' '$(PREFIX)/$(TARGET)/lib/'
endef
