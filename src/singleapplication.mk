# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := singleapplication
$(PKG)_WEBSITE  := https://github.com/itay-grudev/SingleApplication
$(PKG)_DESCR    := SingleApplication
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 473dfae
$(PKG)_CHECKSUM := 32921043fa928e83a3b69093df9b3d626775149e879ae2aa60b3f594842d47cc
$(PKG)_GH_CONF  := itay-grudev/SingleApplication/branches/master
$(PKG)_DEPS     := cc qtbase

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' -DQAPPLICATION_CLASS="QApplication"
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
