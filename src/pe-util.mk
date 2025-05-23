# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := pe-util
$(PKG)_WEBSITE  := https://github.com/gsauthof/pe-util
$(PKG)_DESCR    := List shared object dependencies of a portable executable (PE)
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := dc5dda5
$(PKG)_CHECKSUM := c3b926d8367154fb65a2d49f88cf1389e06a5ce0cc44c7b3526d901ecaba7e1d
$(PKG)_GH_CONF  := gsauthof/pe-util/branches/master
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc pe-parse $(BUILD)~$(PKG)
$(PKG)_DEPS_$(BUILD) := cmake pe-parse

define $(PKG)_PRE_CONFIGURE
    # expects pe-parse in source tree as git submodule
    $(call PREPARE_PKG_SOURCE,pe-parse,$(BUILD_DIR))
    rm -rf '$(SOURCE_DIR)/pe-parse'
    mv '$(BUILD_DIR)/$(pe-parse_SUBDIR)' '$(SOURCE_DIR)/pe-parse'
endef

define $(PKG)_BUILD
    $($(PKG)_PRE_CONFIGURE)
    # install peldd.exe - handy utility (even for static)
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # install prefixed wrapper with default paths
    $(if $(BUILD_SHARED),
        (echo '#!/bin/sh'; \
         echo 'exec "$(PREFIX)/$(BUILD)/bin/peldd" \
                    --clear-path \
                    --path "$(PREFIX)/$(TARGET)/bin" \
                    --path "$(PREFIX)/$(TARGET)/qt6/bin" \
                    --wlist uxtheme.dll \
                    --wlist opengl32.dll \
                    --wlist userenv.dll \
                    "$$@"') \
                 > '$(PREFIX)/bin/$(TARGET)-peldd'
        chmod 0755 '$(PREFIX)/bin/$(TARGET)-peldd'
    )
endef

define $(PKG)_BUILD_$(BUILD)
    $($(PKG)_PRE_CONFIGURE)
    # build and install the binary
    cd '$(BUILD_DIR)' && cmake '$(SOURCE_DIR)' \
        -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)' \
        -DBOOST_ROOT='$(PREFIX)/$(TARGET)' \
        -DBOOST_INCLUDEDIR='$(PREFIX)/$(TARGET)/include' \
        -DBOOST_LIBRARYDIR='$(PREFIX)/$(TARGET)/lib' \
        -DBoost_NO_SYSTEM_PATHS=ON \
        -DBoost_NO_BOOST_CMAKE=ON \
        -DCMAKE_CXX_FLAGS='-I$(PREFIX)/$(TARGET)/include'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
