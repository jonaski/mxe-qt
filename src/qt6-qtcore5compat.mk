# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qt6-qtcore5compat
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt 6 Core Qt 5 Compat
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 6.7.3
$(PKG)_CHECKSUM := 8b6a68a3dfaa7e9d10a0dafccee594c72e8de061bc573ae86b1c081b423a53f0
$(PKG)_FILE     := qt5compat-everywhere-src-$($(PKG)_VERSION).tar.xz
$(PKG)_SUBDIR   := qt5compat-everywhere-src-$($(PKG)_VERSION)
$(PKG)_URL      := https://download.qt.io/official_releases/qt/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc qt6-qtbase
$(PKG)_DEPS_$(BUILD) :=
$(PKG)_OO_DEPS_$(BUILD) += qt6-conf ninja

$(PKG)_UPDATE = $(qt6-qtbase_UPDATE)

define $(PKG)_BUILD
    $(QT6_CMAKE) --log-level="DEBUG" -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' -DCMAKE_BUILD_TYPE='$(MXE_BUILD_TYPE)'
    cmake --build '$(BUILD_DIR)' -j '$(JOBS)'
    cmake --install '$(BUILD_DIR)'
endef
