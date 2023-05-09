# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := harfbuzz
$(PKG)_WEBSITE  := https://wiki.freedesktop.org/www/Software/HarfBuzz/
$(PKG)_DESCR    := HarfBuzz is a text shaping engine
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 7.3.0
$(PKG)_CHECKSUM := 7cefc6cc161e9d5c88210dafc43bc733ca3e383fd3dd4f1e6178f81bd41cfaae
$(PKG)_GH_CONF  := harfbuzz/harfbuzz/releases
$(PKG)_DEPS     := cc cairo freetype-bootstrap glib icu4c

define $(PKG)_BUILD
    # mman-win32 is only a partial implementation
    cd '$(1)' && ./autogen.sh
    cd '$(1)' && ./configure $(MXE_CONFIGURE_OPTS) \
        --with-glib=yes \
        --with-icu=yes \
        --with-freetype=yes \
        --with-cairo=yes \
        ac_cv_header_sys_mman_h=no
    $(MAKE) -C '$(1)'
    $(MAKE) -C '$(1)' install
endef
