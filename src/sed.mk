# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := sed
$(PKG)_WEBSITE  := https://www.gnu.org/software/sed/
$(PKG)_DESCR    := sed (stream editor) is a non-interactive command-line text editor.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.4
$(PKG)_CHECKSUM := cbd6ebc5aaf080ed60d0162d7f6aeae58211a1ee9ba9bb25623daa6cd942683b
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://ftp.gnu.org/gnu/$(PKG)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure $(MXE_CONFIGURE_OPTS) --disable-docs --disable-rpath
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
