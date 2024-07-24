# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libxml2
$(PKG)_WEBSITE  := http://www.xmlsoft.org/
$(PKG)_DESCR    := The XML C parser and toolkit of Gnome
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.13.3
$(PKG)_CHECKSUM := 0805d7c180cf09caad71666c7a458a74f041561a532902454da5047d83948138
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.gnome.org/sources/$(PKG)/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := cc zlib xz libiconv icu4c

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gitlab.gnome.org/GNOME/libxml2/tags' | \
    $(SED) -n "s,.*<a [^>]\+>v\([0-9,\.]\+\)<.*,\\1,p" | \
    head -1
endef

define $(PKG)_BUILD
    '$(TARGET)-cmake' -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' \
        -DCMAKE_BUILD_TYPE='$(MXE_BUILD_TYPE)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DBUILD_STATIC_LIBS=$(CMAKE_STATIC_BOOL) \
        -DLIBXML2_WITH_PYTHON=OFF \
        -DLIBXML2_WITH_ZLIB=ON \
        -DLIBXML2_WITH_LZMA=ON \
        -DLIBXML2_WITH_ICONV=ON \
        -DLIBXML2_WITH_ICU=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
