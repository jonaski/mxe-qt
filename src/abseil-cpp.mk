# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := abseil-cpp
$(PKG)_DESC     := Abseil Common Libraries (C++)
$(PKG)_WEBSITE  := https://github.com/abseil/abseil-cpp
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 20260526.0
$(PKG)_CHECKSUM := 6e1aee535473414164bf83e4ebc40240dec71a4701f8a642d906e95bea1aea0c
$(PKG)_GH_CONF  := abseil/abseil-cpp/releases/latest
$(PKG)_DEPS     := cc
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)

define $(PKG)_BUILD
    '$(TARGET)-cmake' -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' \
        -DCMAKE_BUILD_TYPE='$(MXE_BUILD_TYPE)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DBUILD_STATIC_LIBS=$(CMAKE_STATIC_BOOL) \
        -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)'
    '$(TARGET)-cmake' --build '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
