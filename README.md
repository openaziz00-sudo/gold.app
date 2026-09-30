# Conservative APK Reconstruction

This repository contains a **binary-preserving, conservative reconstruction** of the supplied Android APK. The goal is to maximize behavioral fidelity rather than claim recovery of the original upstream source tree.

## APK metadata

- Package: `com.instagold.android`
- Version name: `439.0.0.37.89`
- Version code: `2147483647`
- Minimum SDK: 28
- Target SDK: 36
- Original SHA-256: `6cc9a4c558246ae30ad57e4881f2bbac665951db443f40f0f0180f35610c33c1`

## Contents

- `recovered-source/`: split compressed archive containing the complete Apktool no-resource decode, including Smali, decoded resources, assets, native libraries, and metadata.
- `rebuild.sh`: extracts the source archive when needed and rebuilds an unsigned APK with Apktool.
- `WORKLOG.md`: commands, observations, decisions, and validation results.

The archive is split into parts below 100 MiB to comply with GitHub's individual-file limit. It is not a proprietary key or signing artifact.

## Rebuild

Requirements: Java, Apktool 2.11.1 or a compatible recent Apktool.

```bash
./rebuild.sh
```

The output is `dist/rebuilt-unsigned.apk`. It is unsigned. The original signing key was not present in the supplied APK and is intentionally not included in this repository.

To extract manually:

```bash
./recovered-source/extract-source.sh
```

## Fidelity notes

The APK was rebuilt from recovered Smali. The rebuilt archive contains the same 21 DEX slots and 15 ARM64 native libraries as the input, and `aapt dump badging` reports the same package, version, and SDK metadata. DEX byte hashes differ because Smali was assembled again; archive compression and signing also necessarily differ.

This is not a claim that comments, original symbol names, build scripts, or the original private signing key were recovered. No application behavior was intentionally removed or changed.
