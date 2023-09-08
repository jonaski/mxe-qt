# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := harfbuzz
$(PKG)_WEBSITE  := https://wiki.freedesktop.org/www/Software/HarfBuzz/
$(PKG)_DESCR    := HarfBuzz is a text shaping engine
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 8.2.0
$(PKG)_CHECKSUM := ca9d6c49b0eb100d343a984abeb3aa332443df48aa2ae0f2c78cf2e72c01ef78
$(PKG)_GH_CONF  := harfbuzz/harfbuzz/releases
$(PKG)_DEPS     := cc freetype-bootstrap glib icu4c cairo libiconv

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && LDFLAGS='$(LDFLAGS) -liconv' '$(TARGET)-meson' \
        --buildtype='$(MESON_BUILD_TYPE)' \
        -Dtests=disabled \
        -Ddocs=disabled \
        -Dglib=enabled \
        -Dgobject=enabled \
        -Dcairo=enabled \
        -Dcoretext=enabled \
        -Dfreetype=enabled \
        -Dicu=enabled \
        '$(BUILD_DIR)'
   cd '$(BUILD_DIR)' && ninja
   cd '$(BUILD_DIR)' && ninja install
endef
