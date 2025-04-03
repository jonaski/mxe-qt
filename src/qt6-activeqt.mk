# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qt6-activeqt
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt 6 Active Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 6.9.0
$(PKG)_CHECKSUM := 23314bd8740fc4911025028cf20bfcdffa799f0beb55a7799463c016f604853e
$(PKG)_SUBDIR   := qtactiveqt-everywhere-src-$($(PKG)_VERSION)
$(PKG)_FILE     := qtactiveqt-everywhere-src-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.qt.io/official_releases/qt/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS_$(BUILD) := qt6-qtbase qt6-qttools
$(PKG)_DEPS     := cc qt6-qtbase qt6-qttools $(BUILD)~$(PKG)

$(PKG)_UPDATE = $(qt6-qtbase_UPDATE)

define $(PKG)_BUILD
    $(QT6_CMAKE) --log-level="DEBUG" -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' \
        -DCMAKE_BUILD_TYPE='$(MXE_BUILD_TYPE)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DBUILD_STATIC_LIBS=$(CMAKE_STATIC_BOOL) \
        -DQT_BUILD_BENCHMARKS=OFF \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF \
        -DQT_BUILD_TESTS_BY_DEFAULT=OFF \
        -DQT_BUILD_TOOLS_BY_DEFAULT=OFF \
        -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF
    cmake --build '$(BUILD_DIR)' -j '$(JOBS)'
    cmake --install '$(BUILD_DIR)'
endef

define $(PKG)_BUILD_$(BUILD)
    $(QT6_CMAKE) --log-level="DEBUG" -G 'Ninja' -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' -DCMAKE_BUILD_TYPE='$(MXE_BUILD_TYPE)'
    cmake --build '$(BUILD_DIR)' -j '$(JOBS)'
    cmake --install '$(BUILD_DIR)'
endef

$(PKG)_BUILD_SHARED =
$(PKG)_BUILD_STATIC =
