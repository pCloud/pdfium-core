#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR_INCLUDES="$DIR/libmodpdfium/src/main/jni/include"

echo $DIR

set -e

build() {
  local ARCH_PATH="$1"
  local ARCH="$2"
  echo "ARCH PARAM $ARCH"
  shift
  local OUT_DIR="out/$ARCH_PATH"
  local OUT="$DIR/libmodpdfium/src/main/jni/lib/$ARCH_PATH/libmodpdfium.so"
  [ -e "$OUT" ] && return
  echo "building $OUT"
  gn gen "$OUT_DIR" --args="target_os=\"android\" $ARCH is_debug=false pdf_is_standalone=true is_component_build=false pdf_enable_xfa=false pdf_enable_v8=false pdf_use_skia=false is_clang=true use_sysroot=true  use_custom_libcxx=false symbol_level=2 strip_debug_info=false "
  ninja -C "$OUT_DIR" modpdfium
  mkdir -p $(dirname "$OUT") && cp "$OUT_DIR"/libmodpdfium.so "$OUT"
  rm -rf out
}

build armeabi-v7a target_cpu=\"arm\" arm_version=7
build arm64-v8a target_cpu=\"arm64\"
build x86 target_cpu=\"x86\"
build x86_64 target_cpu=\"x64\"

mkdir -p $DIR_INCLUDES && cp public/*.h $DIR_INCLUDES
zip -r $DIR/libmodpdfium/libmodpdfium.zip $DIR/libmodpdfium/*
