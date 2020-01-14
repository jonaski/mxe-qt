# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := singleapplication
$(PKG)_WEBSITE  := https://github.com/itay-grudev/SingleApplication
$(PKG)_DESCR    := SingleApplication
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 33a2617
$(PKG)_CHECKSUM := 381523846b4659e5ca8b9ebd36258fea69c96c2a6952078e848b4d92488952a1
$(PKG)_GH_CONF  := itay-grudev/SingleApplication/branches/master
$(PKG)_DEPS     := cc qtbase

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' -DQAPPLICATION_CLASS="QApplication"
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
