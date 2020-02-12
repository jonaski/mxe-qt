# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := singlecoreapplication
$(PKG)_WEBSITE  := https://github.com/itay-grudev/SingleApplication
$(PKG)_DESCR    := SingleCoreApplication
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0f6695e
$(PKG)_CHECKSUM := 28a9ad89f6e3046df1f39004a30219681b9f1daa89301531a60bd674e76739e8
$(PKG)_GH_CONF  := itay-grudev/SingleApplication/branches/master
$(PKG)_DEPS     := cc qtbase

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' -DQAPPLICATION_CLASS="QCoreApplication"
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
