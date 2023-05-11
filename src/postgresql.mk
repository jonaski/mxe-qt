# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := postgresql
$(PKG)_WEBSITE  := https://www.postgresql.org/
$(PKG)_DESCR    := PostgreSQL
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 15.3
$(PKG)_CHECKSUM := ffc7d4891f00ffbf5c3f4eab7fbbced8460b8c0ee63c5a5167133b9e6599d932
$(PKG)_SUBDIR   := postgresql-$($(PKG)_VERSION)
$(PKG)_FILE     := postgresql-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://ftp.postgresql.org/pub/source/v$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc pthreads readline zlib openssl libxml2 icu4c

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://ftp.postgresql.org/pub/source/' | \
    $(SED) -n 's,.*href="v\(.*[^/]*\)/".*,\1,p' | \
    grep -v 'rc' | \
    grep -v 'beta' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    cp -Rp '$(1)' '$(1).native'
    # Since we build only client library, use bogus tzdata to satisfy configure.
    # pthreads is needed in both LIBS and PTHREAD_LIBS
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-rpath \
        --without-tcl \
        --without-perl \
        --without-python \
        --without-gssapi \
        --without-krb5 \
        --without-pam \
        --without-ldap \
        --without-bonjour \
        --without-readline \
        --without-ossp-uuid \
        --without-libxml \
        --without-libxslt \
        --with-openssl \
        --with-zlib \
        --with-system-tzdata=/dev/null \
        CFLAGS="-DSSL_library_init=OPENSSL_init_ssl" \
        LIBS="-lsecur32 `'$(TARGET)-pkg-config' openssl pthreads --libs`" \
        ac_cv_func_getaddrinfo=no

    # enable_thread_safety means "build internal pthreads" on windows
    # disable it and link mingw-w64 pthreads to and avoid name conflicts
    $(MAKE) -C '$(1)'/src/interfaces/libpq -j '$(JOBS)' install enable_thread_safety=no PTHREAD_LIBS="`'$(TARGET)-pkg-config' pthreads --libs`"
    $(MAKE) -C '$(1)'/src/port             -j '$(JOBS)'
    $(MAKE) -C '$(1)'/src/bin/psql         -j '$(JOBS)' install
    $(INSTALL) -m644 '$(1)/src/include/pg_config.h'     '$(PREFIX)/$(TARGET)/include/'
    $(INSTALL) -m644 '$(1)/src/include/pg_config_ext.h' '$(PREFIX)/$(TARGET)/include/'
    $(INSTALL) -m644 '$(1)/src/include/postgres_ext.h'  '$(PREFIX)/$(TARGET)/include/'
    $(INSTALL) -d    '$(PREFIX)/$(TARGET)/include/libpq'
    $(INSTALL) -m644 '$(1)'/src/include/libpq/*         '$(PREFIX)/$(TARGET)/include/libpq/'

    # Build a native pg_config.
    $(SED) -i 's,-DVAL_,-D_DISABLED_VAL_,g' '$(1).native'/src/bin/pg_config/Makefile
    cd '$(1).native' && ./configure \
        --prefix='$(PREFIX)/$(TARGET)' \
        --disable-shared \
        --disable-rpath \
        --with-openssl \
        --without-tcl \
        --without-perl \
        --without-python \
        --without-gssapi \
        --without-krb5 \
        --without-pam \
        --without-ldap \
        --without-bonjour \
        --without-readline \
        --without-ossp-uuid \
        --without-libxml \
        --without-libxslt \
        --without-zlib \
        --with-system-tzdata=/dev/null
    $(MAKE) -C '$(1).native'/src/port          -j '$(JOBS)'
    $(MAKE) -C '$(1).native'/src/bin/pg_config -j '$(JOBS)' install
    ln -sf '$(PREFIX)/$(TARGET)/bin/pg_config' '$(PREFIX)/bin/$(TARGET)-pg_config'
endef

# Static build is currently broken.
$(PKG)_BUILD_STATIC =
