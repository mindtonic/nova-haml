#!/usr/bin/env bash
#
# build.sh — compile the HAML tree-sitter parser into a Nova-loadable dylib.
#
# Run this ON YOUR MAC, with Nova installed at /Applications/Nova.app.
# It does the one step I can't do for you: link against Nova's SyntaxKit
# framework and codesign the result.
#
# Produces a UNIVERSAL binary (arm64 + x86_64), as required by the Nova
# Extension Library.
#
# Usage:
#   ./build.sh [/path/to/Nova.app]
#
# Defaults to /Applications/Nova.app if no path is given.

set -euo pipefail

NOVA_APP="${1:-/Applications/Nova.app}"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARSER_SRC="$SRC_DIR/parser-src"          # pre-generated parser.c + scanner.c live here
OUT_BUNDLE="$SRC_DIR/HAML.novaextension"  # the extension bundle
NAME="haml"
ARCHS="-arch arm64 -arch x86_64"          # universal: Apple Silicon + Intel

echo "→ Nova app:        $NOVA_APP"
echo "→ Parser source:   $PARSER_SRC"
echo "→ Output bundle:   $OUT_BUNDLE"
echo "→ Architectures:   arm64 + x86_64 (universal)"
echo ""

# ── Sanity checks ─────────────────────────────────────────────
if [ ! -d "$NOVA_APP/Contents/Frameworks" ]; then
    echo "✗ Couldn't find $NOVA_APP/Contents/Frameworks"
    echo "  Pass the correct path: ./build.sh /Applications/Nova.app"
    exit 1
fi

if [ ! -f "$PARSER_SRC/parser.c" ]; then
    echo "✗ Missing $PARSER_SRC/parser.c"
    exit 1
fi

# ── Compile (both architectures) ──────────────────────────────
# parser.c needs the tree_sitter headers (shipped alongside it).
# scanner.c is the external scanner (HAML needs it for indentation).
echo "→ Compiling parser (universal)…"
cc $ARCHS -fPIC -c -I"$PARSER_SRC" "$PARSER_SRC/parser.c"  -o "$SRC_DIR/parser.o"
cc $ARCHS -fPIC -c -I"$PARSER_SRC" "$PARSER_SRC/scanner.c" -o "$SRC_DIR/scanner.o"

echo "→ Linking against SyntaxKit (universal)…"
cc $ARCHS -dynamiclib \
   "$SRC_DIR/parser.o" "$SRC_DIR/scanner.o" \
   -o "$SRC_DIR/libtree-sitter-${NAME}.dylib" \
   -F"$NOVA_APP/Contents/Frameworks" \
   -framework SyntaxKit \
   -rpath @loader_path/../Frameworks \
   -install_name "@rpath/libtree-sitter-${NAME}.dylib"

# ── Codesign (ad-hoc) ─────────────────────────────────────────
echo "→ Codesigning (ad-hoc)…"
codesign -s - "$SRC_DIR/libtree-sitter-${NAME}.dylib"

# ── Install into the bundle ───────────────────────────────────
mkdir -p "$OUT_BUNDLE/Syntaxes"
mv "$SRC_DIR/libtree-sitter-${NAME}.dylib" "$OUT_BUNDLE/Syntaxes/libtree-sitter-${NAME}.dylib"

# ── Cleanup ───────────────────────────────────────────────────
rm -f "$SRC_DIR/parser.o" "$SRC_DIR/scanner.o"

# ── Verify architectures ──────────────────────────────────────
echo ""
echo "✓ Built Syntaxes/libtree-sitter-${NAME}.dylib"
echo "  architectures: $(lipo -archs "$OUT_BUNDLE/Syntaxes/libtree-sitter-${NAME}.dylib")"
echo ""
echo "Next:"
echo "  1. Double-click HAML.novaextension to install (or open as a project)."
echo "  2. Open a .haml file. Check Extensions → Show Extension Console for errors."
