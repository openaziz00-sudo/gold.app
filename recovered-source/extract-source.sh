#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-"$ROOT/../decompiled-no-res"}
ARCHIVE=$(mktemp "${TMPDIR:-/tmp}/decompiled-no-res.XXXXXX.tar.gz")
trap 'rm -f "$ARCHIVE"' EXIT
cat "$ROOT"/decompiled-no-res.tar.gz.part-* > "$ARCHIVE"
mkdir -p "$(dirname "$OUT")"
tar -xzf "$ARCHIVE" -C "$(dirname "$OUT")"
if [ "$(dirname "$OUT")" != "$ROOT/.." ] || [ "$(basename "$OUT")" != decompiled-no-res ]; then
  mv "$ROOT/../decompiled-no-res" "$OUT"
fi
echo "Extracted recovered source to $OUT"
