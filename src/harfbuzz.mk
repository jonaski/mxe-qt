# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := harfbuzz
$(PKG)_WEBSITE  := https://wiki.freedesktop.org/www/Software/HarfBuzz/
$(PKG)_DESCR    := HarfBuzz is a text shaping engine
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.3.0
$(PKG)_CHECKSUM := 94712b8cdae68f0b585ec8e3cd8c5160fdc241218119572236497a62dae770de
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
