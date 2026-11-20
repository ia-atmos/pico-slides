#!/bin/sh
# Fetches the Atmos compiler and pico at fixed commits into deps/, and
# builds them. The result is deps/env-pico/atmos-pico, which ./slides
# uses.
#
# Requires git, make, a C compiler, and the SDL2 packages:
#
#   sudo apt-get install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev \
#       libsdl2-ttf-dev libsdl2-gfx-dev
#
# The tests (tst/run.sh) also require xvfb-run.

set -e
cd "$(dirname "$(realpath "$0")")"

LANG_SHA=105cb72d4093a92e8aad89818029e1e6679f9813
PICO_SHA=37196e4d7fe183ebd3f62aefbf229b6a8d1d88e4

fetch () {  # <dir> <url> <commit>
    if [ ! -d "deps/$1/.git" ]; then
        mkdir -p "deps/$1"
        git -C "deps/$1" init -q
        git -C "deps/$1" remote add origin "$2"
    fi
    git -C "deps/$1" fetch -q --depth 1 origin "$3"
    git -C "deps/$1" checkout -q FETCH_HEAD
}

fetch lang     https://github.com/ia-atmos/lang     "$LANG_SHA"
fetch env-pico https://github.com/ia-atmos/env-pico "$PICO_SHA"

make -C deps/lang
make -C deps/env-pico ATMOS="$PWD/deps/lang"

echo "ok : deps/env-pico/atmos-pico"
