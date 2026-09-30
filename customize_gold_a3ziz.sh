#!/usr/bin/env bash
set -euo pipefail

SRC=${1:?usage: customize_gold_a3ziz.sh <decoded-apktool-dir>}
RES="$SRC/res"

[ -d "$RES" ] || { echo "Missing decoded resources: $RES" >&2; exit 1; }

python3 - "$RES" <<'PY'
import re, sys
from pathlib import Path
res = Path(sys.argv[1])

# The launcher label resource is shared by all activities. Set it in every
# locale so the new product name is stable regardless of device language.
for p in res.glob('values*/strings.xml'):
    text = p.read_text(encoding='utf-8')
    text2 = re.sub(
        r'(<string\s+name="string_0x7f130009"[^>]*>)(.*?)(</string>)',
        r'\1gold.a3ziz\3', text, flags=re.S,
    )
    # The existing About screen exposes this value as the developer field.
    text2 = re.sub(
        r'(<string\s+name="gold_about_developer_name"[^>]*>)(.*?)(</string>)',
        r'\1openaziz00@gmail.com\3', text2, flags=re.S,
    )
    if text2 != text:
        p.write_text(text2, encoding='utf-8')

special = res / 'xml' / 'gold_settings_special.xml'
if special.exists():
    text = special.read_text(encoding='utf-8')
    text = re.sub(
        r'(<SwitchPref[^>]*android:key="disable_ads"[^>]*android:defaultValue=")false("\s*/>)',
        r'\1true\2', text,
    )
    if 'android:key="disable_ads"' in text and 'android:defaultValue="true"' not in text.split('android:key="disable_ads"', 1)[1].split('/>', 1)[0]:
        text = text.replace('android:key="disable_ads"', 'android:key="disable_ads" android:defaultValue="true"', 1)
    special.write_text(text, encoding='utf-8')
PY

mkdir -p "$RES/mipmap-anydpi"
cat > "$RES/mipmap-anydpi/instagold_package_icon.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#101828" android:pathData="M10,0 L98,0 Q108,0 108,10 L108,98 Q108,108 98,108 L10,108 Q0,108 0,98 L0,10 Q0,0 10,0Z" />
    <path android:fillColor="#D4AF37" android:pathData="M54,13 A41,41 0,1 0,54 95 A41,41 0,1 0,54 13" />
    <path android:fillColor="#101828" android:pathData="M54,26 A28,28 0,1 0,54 82 A28,28 0,1 0,54 26 M54,38 A16,16 0,1 1,54 70 A16,16 0,1 1,54 38" />
    <path android:fillColor="#D4AF37" android:pathData="M54,43 A11,11 0,1 0,54 65 A11,11 0,1 0,54 43" />
    <path android:strokeColor="#FFFFFF" android:strokeWidth="5" android:strokeLineCap="round" android:fillColor="@android:color/transparent" android:pathData="M37,70 L37,52 M37,52 Q37,42 47,42 Q57,42 57,52 L57,70 M37,60 L57,60" />
    <path android:strokeColor="#FFFFFF" android:strokeWidth="5" android:strokeLineCap="round" android:fillColor="@android:color/transparent" android:pathData="M66,44 Q77,38 82,46 Q85,51 77,55 Q86,58 82,66 Q77,73 66,68" />
</vector>
XML
cp "$RES/mipmap-anydpi/instagold_package_icon.xml" "$RES/mipmap-anydpi/internal_icon.xml"

echo "Customized $SRC for gold.a3ziz"
