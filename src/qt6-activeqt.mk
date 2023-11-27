# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qt6-activeqt
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt 6 Active Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 6.6.1
$(PKG)_CHECKSUM := 9950f17041dce3977da80b4c65adad859952a800569799f25e7b395c1e04cfec
$(PKG)_SUBDIR   := qtactiveqt-everywhere-src-$($(PKG)_VERSION)
$(PKG)_FILE     := qtactiveqt-everywhere-src-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.qt.io/official_releases/qt/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_DEPS     := cc qt6-qtbase qt6-qttools
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)

$(PKG)_UPDATE = $(qt6-qtbase_UPDATE)

define $(PKG)_BUILD
    mv '$(PREFIX)/$(TARGET)/lib/pkgconfig/harfbuzz.pc' '$(PREFIX)/$(TARGET)/lib/pkgconfig/harfbuzz.pc_'
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
    mv '$(PREFIX)/$(TARGET)/lib/pkgconfig/harfbuzz.pc_' '$(PREFIX)/$(TARGET)/lib/pkgconfig/harfbuzz.pc'
    cmake --build '$(BUILD_DIR)' -j '$(JOBS)'
    cmake --install '$(BUILD_DIR)'
endef
