#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
SRC=${1:-"$ROOT/decompiled-no-res"}
OUT=${2:-"$ROOT/dist/gold-a3ziz-unsigned.apk"}
APKTOOL_BIN=${APKTOOL_BIN:-"$ROOT/../bin/apktool"}
if [ ! -x "$APKTOOL_BIN" ]; then
  APKTOOL_BIN=$(command -v apktool || true)
fi
[ -n "$APKTOOL_BIN" ] || { echo "Apktool 2.11.1+ is required" >&2; exit 1; }

if [ ! -f "$SRC/apktool.yml" ]; then
  "$ROOT/recovered-source/extract-source.sh"
fi

# A previous run may have left the readable manifest in the no-resource tree.
# Restore the original binary input before making the baseline APK.
if [ -f "$SRC/original/AndroidManifest.xml" ] && head -c 5 "$SRC/AndroidManifest.xml" | grep -q '^<?xml'; then
  cp "$SRC/original/AndroidManifest.xml" "$SRC/AndroidManifest.xml"
fi

# The archive stores the manifest/resource table in binary form. Build once,
# decode with modern Apktool, apply the readable customizations, then copy the
# edited manifest/resources back onto the recovered Smali source tree.
WORK=$(mktemp -d "${TMPDIR:-/tmp}/gold-a3ziz.XXXXXX")
trap 'rm -rf "$WORK"' EXIT
rm -rf "$SRC/build"
"$APKTOOL_BIN" b -f "$SRC" -o "$WORK/baseline.apk"
"$APKTOOL_BIN" d -f -o "$WORK/editable" "$WORK/baseline.apk"
# The recovered layouts table stores opaque offsets rather than XML references.
# Keep every layout symbol for link compatibility, but use a harmless null
# reference so aapt2 can rebuild the edited resource table.
find "$WORK/editable/res" -type f -name "*.xml" -exec sed -E -i 's#(<item type="[^"]+" name="[^"]+">)[^<]*\|[^<]*(</item>)#\1@null\2#' {} +
"$ROOT/customize_gold_a3ziz.sh" "$WORK/editable"
# Apktool's no-resource project copies AndroidManifest.xml verbatim. Build the
# decoded customization once so the final source tree receives a valid binary
# Android XML manifest rather than plain text.
"$APKTOOL_BIN" b -f "$WORK/editable" -o "$WORK/editable.apk"
unzip -p "$WORK/editable.apk" AndroidManifest.xml > "$SRC/AndroidManifest.xml"
rm -rf "$SRC/res"
cp -a "$WORK/editable/res" "$SRC/res"

mkdir -p "$(dirname "$OUT")"
rm -rf "$SRC/build"
"$APKTOOL_BIN" b -f "$SRC" -o "$OUT"
echo "Built customized unsigned APK: $OUT"
