# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := dlfcn-win32
$(PKG)_WEBSITE  := https://github.com/dlfcn-win32/dlfcn-win32
$(PKG)_DESCR    := POSIX dlfcn wrapper for Windows
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.4.2
$(PKG)_CHECKSUM := f61a874bc9163ab488accb364fd681d109870c86e8071f4710cbcdcbaf9f2565
$(PKG)_GH_CONF  := dlfcn-win32/dlfcn-win32/releases/latest, v
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    '$(TARGET)-cmake' -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' \
        -DCMAKE_BUILD_TYPE='$(MXE_BUILD_TYPE)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DBUILD_STATIC_LIBS=$(CMAKE_STATIC_BOOL)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # create pkg-config file - mostly for psapi dependency
    mkdir -p '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $(PKG)'; \
     echo 'Libs: -ldl'; \
     echo 'Libs.private: -lpsapi'; \
    ) > '$(PREFIX)/$(TARGET)/lib/pkgconfig/dlfcn.pc'
endef
