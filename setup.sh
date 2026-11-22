#!/bin/sh
# Fetches the Atmos compiler and pico at fixed commits into deps/, and
# builds them, and the tool that writes a PDF. The result is
# deps/env-pico/atmos-pico and deps/png2pdf, which ./slides uses.
#
# Requires git, make, a C compiler, and the SDL2 packages:
#
#   sudo apt-get install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev \
#       libsdl2-ttf-dev libsdl2-gfx-dev
#
# The tests (tst/run.sh) also require xvfb-run.

set -e
cd "$(dirname "$(realpath "$0")")"

LANG_SHA=98e47876bcfb6f01d9b9893fbbfadba0fac65839
PICO_SHA=8a20c46483715938215de79fdfba4baedbe90c93

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

# the tool that joins the images of the slides in a PDF (./slides --pdf)
cc -O2 tools/png2pdf.c -o deps/png2pdf \
    $(sdl2-config --cflags --libs) -lSDL2_image -lz

echo "ok : deps/env-pico/atmos-pico, deps/png2pdf"
