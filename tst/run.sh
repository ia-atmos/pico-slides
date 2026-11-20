#!/bin/sh
# Runs the tests, headless.
#
#   tst/run.sh [-u] [name ...]
#
# A visual test plays a document under scripted keys, saves the window
# at some frames to tst/out/, and compares each file with its reference
# in tst/asr/. An error test (tst/err/) checks the message of a document
# that must be refused.
#
# With -u, the references are updated from the output instead of
# compared: look at the images before committing them.
#
# Requires ../slides (see ../setup.sh) and xvfb-run.

cd "$(dirname "$(realpath "$0")")" || exit 1

update=0
if [ "$1" = "-u" ]; then
    update=1
    shift
fi
only="$*"

PICO="${ATMOS_PICO:-$(dirname "$PWD")/deps/env-pico/atmos-pico}"

mkdir -p out
fail=0

want () {
    [ -z "$only" ] && return 0
    for n in $only; do
        [ "$n" = "$1" ] && return 0
    done
    return 1
}

# shots <name> <file> <width> <height> <frames> <keys> <frame> ...
#   file: a document (.slides), or a program (.atm), which sets its own
#         window and ignores the width and height
#   keys: f:dn:Key,... or "-" for none
#   each <frame> is saved as out/<name>-<frame>.png
shots () {
    name=$1; file=$2; w=$3; h=$4; frames=$5; keys=$6
    shift 6
    want "$name" || return 0
    list=""
    for f in "$@"; do
        list="$list${list:+,}$f:$PWD/out/$name-$f.png"
        rm -f "out/$name-$f.png"
    done
    [ "$keys" = "-" ] && keys=""
    case "$file" in
        *.atm)
            ( cd "$(dirname "$file")" &&
              PICO_ATM_FRAMES=$frames:20 PICO_ATM_KEYS="$keys" \
              PICO_ATM_SHOT="$list" SDL_AUDIODRIVER=dummy \
              xvfb-run -a "$PICO" "$(basename "$file")" ) > "out/$name.log" 2>&1
            ;;
        *)
            PICO_ATM_FRAMES=$frames:20 PICO_ATM_KEYS="$keys" \
                PICO_ATM_SHOT="$list" SDL_AUDIODRIVER=dummy \
                xvfb-run -a ../slides "$file" "$w" "$h" > "out/$name.log" 2>&1
            ;;
    esac
    ok=1
    for f in "$@"; do
        if [ ! -f "out/$name-$f.png" ]; then
            ok=0
        elif [ $update -eq 1 ]; then
            cp "out/$name-$f.png" "asr/$name-$f.png"
        elif ! cmp -s "out/$name-$f.png" "asr/$name-$f.png"; then
            ok=0
        fi
    done
    if [ $ok -eq 1 ]; then
        echo "OK   $name"
    else
        echo "FAIL $name    (see tst/out/$name.log and tst/out/$name-*.png)"
        fail=1
    fi
}

# refuse <name> <message>
#   err/<name>.slides must fail with a message that contains <message>
refuse () {
    name=$1; msg=$2
    want "$name" || return 0
    if PICO_ATM_FRAMES=2:20 SDL_AUDIODRIVER=dummy \
        xvfb-run -a ../slides "err/$name.slides" 640 360 > "out/$name.log" 2>&1
    then
        echo "FAIL $name    (the document was accepted)"
        fail=1
    elif grep -qF -- "$msg" "out/$name.log"; then
        echo "OK   $name"
    else
        echo "FAIL $name    (see tst/out/$name.log)"
        fail=1
    fi
}

. ./cases.sh

if [ $fail -eq 0 ]; then
    echo "All tests passed!"
fi
exit $fail
