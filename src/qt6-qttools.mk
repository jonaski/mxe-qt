# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qt6-qttools
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt 6 Tools
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 6.9.1
$(PKG)_CHECKSUM := 90c4a562f4ccfd043fd99f34c600853e0b5ba9babc6ec616c0f306f2ce3f4b4c
$(PKG)_FILE     := qttools-everywhere-src-$($(PKG)_VERSION).tar.xz
$(PKG)_SUBDIR   := qttools-everywhere-src-$($(PKG)_VERSION)
$(PKG)_URL      := https://download.qt.io/official_releases/qt/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc qt6-qtbase $(BUILD)~$(PKG)
$(PKG)_DEPS_$(BUILD) := qt6-qtbase
$(PKG)_OO_DEPS_$(BUILD) += qt6-conf ninja

$(PKG)_UPDATE = $(qt6-qtbase_UPDATE)

define $(PKG)_BUILD
    $(QT6_CMAKE) --log-level="DEBUG" -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' \
        -DCMAKE_BUILD_TYPE='$(MXE_BUILD_TYPE)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DBUILD_STATIC_LIBS=$(CMAKE_STATIC_BOOL) \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF \
        -DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING=ON \
        -DFEATURE_assistant=OFF \
        -DFEATURE_designer=OFF \
        -DFEATURE_distancefieldgenerator=OFF \
        -DFEATURE_kmap2qmap=OFF \
        -DFEATURE_pixeltool=OFF \
        -DFEATURE_qdbus=OFF \
        -DFEATURE_qev=OFF \
        -DFEATURE_qtattributionsscanner=OFF \
        -DFEATURE_qtdiag=OFF \
        -DFEATURE_qtplugininfo=OFF \
        -DFEATURE_linguist=ON

    cmake --build '$(BUILD_DIR)' -j '$(JOBS)'
    cmake --install '$(BUILD_DIR)'

    $(INSTALL) -m755 '$(PREFIX)/$(BUILD)/qt6/bin/lrelease' '$(PREFIX)/$(TARGET)/qt6/bin/lrelease.exe'
    $(INSTALL) -m755 '$(PREFIX)/$(BUILD)/qt6/bin/lconvert' '$(PREFIX)/$(TARGET)/qt6/bin/lconvert.exe'

endef

define $(PKG)_BUILD_$(BUILD)
    $(QT6_CMAKE) --log-level="DEBUG" -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF \
        -DFEATURE_assistant=OFF \
        -DFEATURE_designer=OFF \
        -DFEATURE_distancefieldgenerator=OFF \
        -DFEATURE_kmap2qmap=OFF \
        -DFEATURE_pixeltool=OFF \
        -DFEATURE_qdbus=OFF \
        -DFEATURE_qev=OFF \
        -DFEATURE_qtattributionsscanner=OFF \
        -DFEATURE_qtdiag=OFF \
        -DFEATURE_qtplugininfo=OFF \
        -DFEATURE_linguist=ON
    cmake --build '$(BUILD_DIR)' -j '$(JOBS)'
    cmake --install '$(BUILD_DIR)'
endef
