#!/bin/bash
set -euo pipefail

fn_git_clean() {
  git clean -xdf
  git checkout .
}

OUT_DIR="$PWD/out"
ROOT="$PWD"
EMCC_FLAGS_DEBUG="-Os -g3"
EMCC_FLAGS_RELEASE="-Oz"

export CPPFLAGS="-I$OUT_DIR/include -I$EMSDK/upstream/emscripten/cache/sysroot/include"
export LDFLAGS="-L$OUT_DIR/lib"
export PKG_CONFIG_PATH="$OUT_DIR/lib/pkgconfig"
export EM_PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
export CFLAGS="$EMCC_FLAGS_RELEASE"
export CXXFLAGS="$CFLAGS"

cd "$ROOT/lib/console"
fn_git_clean
patch -p1 < ../../patches/console.patch

cd "$ROOT/lib/grex"
fn_git_clean
patch -p1 < ../../patches/grex.patch

cd "$ROOT/lib/iana-time-zone"
fn_git_clean
patch -p1 < ../../patches/iana-time-zone.patch

cd "$ROOT/lib/instant"
fn_git_clean
patch -p1 < ../../patches/instant.patch

cd "$ROOT/lib/qsv"
fn_git_clean
patch -p1 < ../../patches/qsv.patch

mkdir -p "$ROOT/dist"
cd "$ROOT/lib/qsv"
export RUSTFLAGS=\
"-C target-feature=+atomics,+bulk-memory,+mutable-globals "\
"-Clink-arg=--pre-js=$ROOT/js/pre.js "\
"-Clink-arg=--post-js=$ROOT/js/post.js "\
"-Clink-arg=--closure=1 "\
"-Clink-arg=-sWASM_BIGINT=1 "\
"-Clink-arg=-sALLOW_MEMORY_GROWTH=1 "\
"-Clink-arg=-pthread "\
"-Clink-arg=-sPROXY_TO_PTHREAD=1 "\
"-Clink-arg=-sEXPORTED_RUNTIME_METHODS=['callMain','FS','NODEFS','WORKERFS','ENV'] "\
"-Clink-arg=-sINCOMING_MODULE_JS_API=['noInitialRun','noFSInit','locateFile','preRun','instantiateWasm','quit'] "\
"-Clink-arg=-sMODULARIZE=1 "\
"-Clink-arg=-sEXPORT_NAME=createModule "\
"-Clink-arg=-o$ROOT/dist/qsv.js "\
"-Clink-arg=-lnodefs.js "\
"-Clink-arg=-lworkerfs.js "\
"-Clink-arg=-L$OUT_DIR/lib "
cargo build --bin qsv --target wasm32-unknown-emscripten -Z build-std=std,panic_abort --release --no-default-features --features apply,generate,foreach,feature_capable
