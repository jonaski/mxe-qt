# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libmysqlclient
$(PKG)_WEBSITE  := https://dev.mysql.com/downloads/mysql/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 8.0.19
$(PKG)_CHECKSUM := a62786d67b5e267eef928003967b4ccfe362d604b80f4523578e0688f5b9f834
$(PKG)_SUBDIR   := mysql-$($(PKG)_VERSION)
$(PKG)_FILE     := mysql-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://dev.mysql.com/get/Downloads/MySQL-8.0/$($(PKG)_FILE)
$(PKG)_DEPS     := cc boost openssl zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://dev.mysql.com/downloads/mysql/' | \
    $(SED) -n 's,.*mysql-\([0-9\.]\+\)-win.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    # native build for tool comp_err
    # See https://bugs.mysql.com/bug.php?id=61340
    mkdir '$(1).native'
    cd '$(1).native' && cmake -DWITHOUT_SERVER=ON -DDOWNLOAD_BOOST=OFF '$(1)'
    $(MAKE) -C '$(1).native' -j '$(JOBS)' VERBOSE=1
    # cross-compilation
    mkdir '$(1).build'
    cd '$(1).build' && '$(TARGET)-cmake' \
        -DIMPORT_COMP_ERR='$(1).native/ImportCompErr.cmake' \
        -DIMPORT_COMP_CLIENT_ERR='$(1).native/ImportCompClientErr.cmake' \
        -DIMPORT_COMP_SQL='$(1).native/ImportCompSQL.cmake' \
        -DIMPORT_UCA9DUMP='$(1).native/Importuca9dump.cmake' \
        -DHAVE_GCC_ATOMIC_BUILTINS=1 \
        -DDISABLE_SHARED=$(CMAKE_STATIC_BOOL) \
        -DENABLE_DTRACE=OFF \
        -DWITH_ZLIB=system \
        -DWITHOUT_SERVER=ON \
        -DDOWNLOAD_BOOST=OFF \
        -DFORCE_UNSUPPORTED_COMPILER=ON \
        -DSTACK_DIRECTION=1 \
        '$(1)'

    # def file created by cmake creates link errors
    #$(if $(findstring i686-w64-mingw32.shared,$(TARGET)),
    #    cp '$(PWD)/src/$(PKG).def' '$(1).build/libmysql/libmysql_exports.def')

    $(MAKE) -C '$(1).build' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(1).build' -j 1 install VERBOSE=1

    # no easy way to configure location of dll
    -mv '$(PREFIX)/$(TARGET)/lib/libmysqlclient.dll' '$(PREFIX)/$(TARGET)/bin/'

    # install mysql_config
    $(INSTALL) -m744 '$(1).native/scripts/mysql_config' '$(PREFIX)/$(TARGET)/bin'

    # missing headers
    $(INSTALL) -m644 '$(1)/include/'thr_* '$(1)/include/'my_thr* '$(PREFIX)/$(TARGET)/include'

    # build test with mysql_config
    #'$(TARGET)-g++' -W -Wall -Werror -ansi -pedantic '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' `'$(PREFIX)/$(TARGET)/bin/mysql_config' --cflags --libs`

endef
