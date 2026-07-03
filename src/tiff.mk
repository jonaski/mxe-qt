# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := tiff
$(PKG)_WEBSITE  := http://www.simplesystems.org/libtiff/
$(PKG)_DESCR    := TIFF Library and Utilities
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.7.2
$(PKG)_CHECKSUM := 672bd7d10aee4606171afb864f3570b83340f6a33e2c186dc0512f7145ffdf6a
$(PKG)_SUBDIR   := tiff-$($(PKG)_VERSION)
$(PKG)_FILE     := tiff-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://download.osgeo.org/libtiff/$($(PKG)_FILE)
$(PKG)_DEPS     := cc jpeg libwebp xz zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.simplesystems.org/libtiff/' | \
    $(SED) -n 's,.*>v\([0-9][^<]*\)<.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure $(MXE_CONFIGURE_OPTS) --disable-rpath --without-x
    $(MAKE) -C '$(1)' -j '$(JOBS)' $(MXE_DISABLE_CRUFT)
    $(MAKE) -C '$(1)' -j 1 install $(MXE_DISABLE_CRUFT)
endef
