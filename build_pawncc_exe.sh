#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
WORK_DIR="$ROOT_DIR/.work"
OUT_DIR="$ROOT_DIR/out"
SRC_DIR="$WORK_DIR/compiler/source"
VERSION=3.10.10

rm -rf "$WORK_DIR" "$OUT_DIR"
mkdir -p "$WORK_DIR" "$OUT_DIR"
git clone --quiet --depth 1 --branch "v$VERSION" https://github.com/pawn-lang/compiler.git "$WORK_DIR/compiler"

sed -e "s/@VERSION_STR@/$VERSION/" \
    -e 's/@VERSION_INT@/778/' \
    -e 's/@VERSION_MAJOR@/3/' \
    -e 's/@VERSION_MINOR@/10/' \
    -e 's/@VERSION_BUILD@/10/' \
    "$SRC_DIR/compiler/version.h.in" > "$OUT_DIR/version.h"

SOURCES="source/compiler/hashtable/wrap_hashtable.c source/compiler/lstring.c source/compiler/memfile.c source/compiler/sc1.c source/compiler/sc2.c source/compiler/sc3.c source/compiler/sc4.c source/compiler/sc5.c source/compiler/sc6.c source/compiler/sc7.c source/compiler/sci18n.c source/compiler/sclist.c source/compiler/scmemfil.c source/compiler/scstate.c source/compiler/scvars.c"

# Cross-compile the distributable 32-bit Windows executable.
# -static links the MinGW runtime statically; Windows system DLLs remain normal imports.
# shellcheck disable=SC2086
(cd "$WORK_DIR/compiler" && i686-w64-mingw32-gcc -O2 -s -static \
  -DHAVE_STDINT_H -DHAVE_INTTYPES_H \
  -Isource/compiler -Isource/amx -I"$OUT_DIR" $SOURCES -o "$OUT_DIR/pawncc.exe")

# Build and exercise a native Linux copy as a smoke test of the compiler source.
# shellcheck disable=SC2086
(cd "$WORK_DIR/compiler" && gcc -O2 -Dstricmp=strcasecmp -include strings.h -include unistd.h \
  -DHAVE_STDINT_H -DHAVE_INTTYPES_H \
  -Isource/compiler -Isource/amx -I"$OUT_DIR" $SOURCES -o "$OUT_DIR/pawncc-native")
cat > "$OUT_DIR/smoke.p" <<'EOF'
main()
{
    new value = 2 + 3;
    return value;
}
EOF
"$OUT_DIR/pawncc-native" "$OUT_DIR/smoke.p" -o"$OUT_DIR/smoke.amx"
test -s "$OUT_DIR/smoke.amx"
printf 'Built Windows compiler: %s bytes\n' "$(wc -c < "$OUT_DIR/pawncc.exe")"
printf 'Native smoke test passed; generated smoke.amx.\n'
