# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := quazip-qt6
$(PKG)_WEBSITE  := https://github.com/stachenov/quazip
$(PKG)_DESCR    := QuaZip Qt 6
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.7.2
$(PKG)_CHECKSUM := 5240f4a3475648773ba10af8b0ebe549cbfc5d6de00470a517330a80068a4f78
$(PKG)_GH_CONF  := stachenov/quazip/releases/latest, v
$(PKG)_DEPS     := cc zlib qt6-qtbase qt6-qttools qt6-qtcore5compat

define $(PKG)_BUILD
    '$(TARGET)-cmake' -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' \
        -DCMAKE_BUILD_TYPE='$(MXE_BUILD_TYPE)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DBUILD_STATIC_LIBS=$(CMAKE_STATIC_BOOL) \
        -DCMAKE_PREFIX_PATH=$(PREFIX)/$(TARGET)/qt6/lib/cmake \
        -DQUAZIP_QT_MAJOR_VERSION=6

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
