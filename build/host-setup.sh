#!/bin/sh
#
# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#  A shell script used to configure the host-specific parts of the NDK
#  build system. This will create out/host/config-host.make based on
#  your host system and additionnal command-line options.
#

# include common function and variable definitions
source `dirname $0`/core/ndk-common.sh

OUT_DIR=out
HOST_CONFIG=$OUT_DIR/host/config.mk

## Build configuration file support
## you must define $config_mk before calling this function
##
create_config_mk ()
{
    # create the directory if needed
    local  config_dir
    config_mk=${config_mk:-$HOST_CONFIG}
    config_dir=`dirname $config_mk`
    mkdir -p $config_dir 2> $TMPL
    if [ $? != 0 ] ; then
        echo "Can't create directory for host config file: $config_dir"
        exit 1
    fi

    # re-create the start of the configuration file
    log "Generate   : $config_mk"

    echo "# This file was autogenerated by $PROGNAME. Do not edit !" > $config_mk
}

add_config ()
{
    echo "$1" >> $config_mk
}

echo "Detecting host toolchain."
echo ""

setup_toolchain

create_config_mk

add_config "HOST_OS       := $HOST_OS"
add_config "HOST_ARCH     := $HOST_ARCH"
add_config "HOST_TAG      := $HOST_TAG"
add_config "HOST_CC       := $CC"
add_config "HOST_CFLAGS   := $CFLAGS"
add_config "HOST_CXX      := $CXX"
add_config "HOST_CXXFLAGS := $CXXFLAGS"
add_config "HOST_LD       := $LD"
add_config "HOST_LDFLAGS  := $LDFLAGS"
add_config "HOST_AR       := $AR"
add_config "HOST_ARFLAGS  := $ARFLAGS"

## Check that the toolchains we need are installed
## Otherwise, instruct the user to download them from the web site

TOOLCHAINS=arm-eabi-4.2.1

EXT=""
[ "Windows_NT" == "$OS" ] && EXT=".exe"

for tc in $TOOLCHAINS; do
    echo "Toolchain  : Checking for $tc prebuilt binaries"
    COMPILER_PATTERN=$ANDROID_NDK_ROOT/build/prebuilt/$HOST_TAG/$tc/bin/*-gcc${EXT}
    COMPILERS=`ls $COMPILER_PATTERN 2> /dev/null`
    if [ -z $COMPILERS ] ; then
        echo ""
        echo "ERROR:"
        echo "It seems you do not have the correct $tc toolchain binaries."
        echo "Please go to the official Android NDK web site and download the"
        echo "appropriate NDK package for your platform ($HOST_TAG)."
        echo "See http://developer.android.com/sdk/index.html"
        echo ""
        echo "ABORTING."
        echo ""
        exit 1
    fi
done

echo ""
echo "Host setup complete. Please read docs/OVERVIEW.TXT if you don't know what to do."
echo ""
