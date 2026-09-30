#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
SRC=${1:-"$ROOT/decompiled-no-res"}
OUT=${2:-"$ROOT/dist/rebuilt-unsigned.apk"}
if [ ! -f "$SRC/apktool.yml" ]; then
  "$ROOT/recovered-source/extract-source.sh" "$SRC"
fi
mkdir -p "$(dirname "$OUT")"
apktool b -f "$SRC" -o "$OUT"
echo "Built $OUT"
