# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := boost
$(PKG)_WEBSITE  := https://www.boost.org/
$(PKG)_DESCR    := Boost C++ Library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.85.0
$(PKG)_CHECKSUM := 7009fe1faa1697476bdc7027703a2badb84e849b7b0baad5086b087b971f8617
$(PKG)_SUBDIR   := boost_$(subst .,_,$($(PKG)_VERSION))
$(PKG)_FILE     := boost_$(subst .,_,$($(PKG)_VERSION)).tar.bz2
$(PKG)_URL      := https://archives.boost.io/release/$($(PKG)_VERSION)/source/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc bzip2 expat zlib xz
AWK             = $(shell which $(shell gawk --help >/dev/null 2>&1 && echo g)awk)

$(PKG)_DEPS_$(BUILD) := zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.boost.org/users/download/' | \
    $(SED) -n 's,.*/release/\([0-9][^"/]*\)/.*,\1,p' | \
    grep -v beta | \
    head -1
endef

define GCC_VERSION_MAJOR
$(shell echo $(gcc_VERSION) | cut -f1 -d.)
endef

define GCC_VERSION_MINOR
$(shell echo $(gcc_VERSION) | cut -f2 -d.)
endef

define $(PKG)_CXX_STD
$(shell [ $(1) -gt 6 -o \( $(1) -eq 6 -a $(2) -ge 1 \) ] && echo 14 || echo 11)
endef

$(PKG)_VERSION_MAJOR := $(shell echo $($(PKG)_VERSION) | cut -f1 -d.)
$(PKG)_VERSION_MINOR := $(shell echo $($(PKG)_VERSION) | cut -f2 -d.)

$(PKG)_ENABLE_CMAKE_SUPPORT := $(shell [ \( $($(PKG)_VERSION_MAJOR) -eq 1 -a $($(PKG)_VERSION_MINOR) -ge 72 \) -o $($(PKG)_VERSION_MAJOR) -ge 2 ] && echo true)

define $(PKG)_BUILD
    # old version appears to interfere
    rm -rf '$(PREFIX)/$(TARGET)/include/boost/'
    rm -f "$(PREFIX)/$(TARGET)/lib/libboost"*
    rm -f "$(PREFIX)/$(TARGET)/bin/libboost"*
    # create user-config
    echo 'using gcc : mxe : $(TARGET)-g++ : <rc>$(TARGET)-windres <archiver>$(TARGET)-ar <ranlib>$(TARGET)-ranlib ;' > '$(1)/user-config.jam'

    # compile boost build (b2)
    cd '$(1)/tools/build/' && ./bootstrap.sh

    # cross-build, see b2 options at:
    # https://www.boost.org/build/doc/html/bbv2/overview/invocation.html
    cd '$(1)' && ./tools/build/b2 \
        -a \
        -q \
        -j '$(JOBS)' \
        -d1 \
        --ignore-site-config \
        --user-config=user-config.jam \
        abi=ms \
        address-model=$(BITS) \
        architecture=x86 \
        binary-format=pe \
        link=$(if $(BUILD_STATIC),static,shared) \
        runtime-link=$(if $(BUILD_STATIC),static,shared) \
        target-os=windows \
        threadapi=$(if $(findstring posix,$(MXE_GCC_THREADS)),pthread,win32) \
        threading=multi \
        variant=release \
        toolset=gcc-mxe \
        cxxflags="-std=c++$(call $(PKG)_CXX_STD,$(GCC_VERSION_MAJOR),$(GCC_VERSION_MINOR))" \
        --layout=tagged \
        --disable-icu \
        --without-mpi \
        --without-python \
        --prefix='$(PREFIX)/$(TARGET)' \
        --exec-prefix='$(PREFIX)/$(TARGET)/bin' \
        --libdir='$(PREFIX)/$(TARGET)/lib' \
        --includedir='$(PREFIX)/$(TARGET)/include' \
        -sEXPAT_INCLUDE='$(PREFIX)/$(TARGET)/include' \
        -sEXPAT_LIBPATH='$(PREFIX)/$(TARGET)/lib' \
        -sPTW32_INCLUDE='$(PREFIX)/$(TARGET)/include' \
        -sPTW32_LIB='$(PREFIX)/$(TARGET)/lib' \
        define="BOOST_THREAD_VERSION=4" \
        define="BOOST_THREAD_DONT_USE_CHRONO" \
        define="BOOST_THREAD_USES_DATETIME" \
        define="BOOST_THREAD_DONT_PROVIDE_GENERIC_SHARED_MUTEX_ON_WIN" \
        define="BOOST_THREAD_PROVIDES_NESTED_LOCKS" \
        define="BOOST_THREAD_DONT_PROVIDE_ONCE_CXX11" \
        install
    for lib in `ls "$(PREFIX)/$(TARGET)/lib"/libboost_*.a | tr "\n" " "`; \
    do \
    newlib=`echo \`basename $${lib}\` | $(AWK) '{gsub(/-mt-x[0-9]{2}/,"-mt"); gsub(/_pthread/,"")}1'`; \
    if ! [ "$${lib}" = "$(PREFIX)/$(TARGET)/lib/$${newlib}" ]; then \
      echo ln -sf "$${lib}" "$(PREFIX)/$(TARGET)/lib/$${newlib}"; \
      ln -sf "$${lib}" "$(PREFIX)/$(TARGET)/lib/$${newlib}"; \
    fi; \
    done
    $(if $(BUILD_SHARED), mv -fv '$(PREFIX)/$(TARGET)/lib/'libboost_*.dll '$(PREFIX)/$(TARGET)/bin/')

    # setup cmake toolchain
    mkdir -p '$(CMAKE_TOOLCHAIN_DIR)'
    printf "set(Boost_THREADAPI "$(if $(findstring posix,$(MXE_GCC_THREADS)),pthread,win32)")\\n\
    set (Boost_USE_STATIC_LIBS $(if $(BUILD_SHARED),OFF,ON))\\n\
    set (Boost_USE_MULTITHREADED ON)\\n\
    set (Boost_NO_BOOST_CMAKE $(if $($(PKG)_ENABLE_CMAKE_SUPPORT),OFF,ON))\\n\
    set (Boost_USE_STATIC_RUNTIME $(if $(BUILD_SHARED),OFF,ON))\\n" > '$(CMAKE_TOOLCHAIN_DIR)/$(PKG).cmake'

    #'$(TARGET)-g++' \
    #    -W -Wall -Werror -ansi -U__STRICT_ANSI__ -pedantic \
    #    '$(PWD)/src/$(PKG)-test.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-boost.exe' \
    #    -std='c++$(call $(PKG)_CXX_STD,$(GCC_VERSION_MAJOR),$(GCC_VERSION_MINOR))' \
    #    -lboost_serialization-mt \
    #    -lboost_thread-mt \
    #    -lboost_system-mt \
    #    -lboost_chrono-mt \
    #    -lboost_context-mt \
    #    -L'$(PREFIX)/$(TARGET)/lib'

    # test cmake
    #mkdir '$(BUILD_DIR).test-cmake'
    #cd '$(BUILD_DIR).test-cmake' && '$(TARGET)-cmake' \
    #    -DPKG=$(PKG) \
    #    -DPKG_VERSION=$($(PKG)_VERSION) \
    #    '$(PWD)/src/cmake/test'
    #$(MAKE) -C '$(BUILD_DIR).test-cmake' -j 1 install
endef

define $(PKG)_BUILD_$(BUILD)
    # old version appears to interfere
    rm -rf '$(PREFIX)/$(TARGET)/include/boost/'
    rm -f "$(PREFIX)/$(TARGET)/lib/libboost"*

    # compile boost build (b2)
    cd '$(SOURCE_DIR)/tools/build/' && ./bootstrap.sh

    # minimal native build - for more features, replace:
    # --with-system \
    # --with-filesystem \
    #
    # with:
    # --without-mpi \
    # --without-python \

    cd '$(SOURCE_DIR)' && \
        $(if $(call seq,darwin,$(OS_SHORT_NAME)),PATH=/usr/bin:$$PATH) \
        ./tools/build/b2 \
            -a \
            -q \
            -j '$(JOBS)' \
            --ignore-site-config \
            variant=release \
            link=static \
            threading=multi \
            runtime-link=static \
            --disable-icu \
            --with-system \
            --with-filesystem \
            --build-dir='$(BUILD_DIR)' \
            --prefix='$(PREFIX)/$(TARGET)' \
            --exec-prefix='$(PREFIX)/$(TARGET)/bin' \
            --libdir='$(PREFIX)/$(TARGET)/lib' \
            --includedir='$(PREFIX)/$(TARGET)/include' \
            install
# setup cmake toolchain
    mkdir -p '$(CMAKE_TOOLCHAIN_DIR)'
    printf "set (Boost_USE_STATIC_LIBS ON)\\n\
    set (Boost_USE_MULTITHREADED ON)\\n\
    set (Boost_NO_BOOST_CMAKE $(if $($(PKG)_ENABLE_CMAKE_SUPPORT),OFF,ON))\\n\
    set (Boost_USE_STATIC_RUNTIME ON)\\n" > '$(CMAKE_TOOLCHAIN_DIR)/$(PKG).cmake'
endef
