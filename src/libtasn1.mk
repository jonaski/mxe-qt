# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libtasn1
$(PKG)_WEBSITE  := https://www.gnu.org/software/libtasn1/
$(PKG)_DESCR    := ASN.1 library
$(PKG)_VERSION  := 4.20.0
$(PKG)_CHECKSUM := 92e0e3bd4c02d4aeee76036b2ddd83f0c732ba4cda5cb71d583272b23587a76c
$(PKG)_SUBDIR   := libtasn1-$($(PKG)_VERSION)
$(PKG)_FILE     := libtasn1-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://ftp.gnu.org/gnu/libtasn1/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- https://ftp.gnu.org/gnu/libtasn1/ | \
    $(SED) -n 's,.*libtasn1-\([0-9]\+\.[0-9]\+\.*[0-9]*\)\..*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure $(MXE_CONFIGURE_OPTS) --disable-doc
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
endef
