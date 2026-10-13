#!/bin/bash
# Baut build/NotchIsland.app (Apple Silicon) und signiert sie.
set -euo pipefail
cd "$(dirname "$0")"

APP="build/NotchIsland.app"
BUNDLE_ID="at.redl.NotchIsland"
IDENTITY="NotchIsland Local"

# Benötigt Swift 5.9+ (Xcode 15 / Command Line Tools 15) wegen des macOS-14-SDK.
SWIFT_VER="$(swift --version 2>/dev/null | sed -nE 's/.*Swift version ([0-9]+\.[0-9]+).*/\1/p' | head -1)"
if [ -z "$SWIFT_VER" ] || [ "$(printf '%s\n5.9\n' "$SWIFT_VER" | sort -V | head -1)" != "5.9" ]; then
    echo "Fehler: Swift ${SWIFT_VER:-?} gefunden, benötigt wird 5.9 oder neuer (macOS-14-SDK)."
    echo "Aktuelle Command Line Tools installieren – siehe README bzw. Anleitung im Chat."
    exit 1
fi

swift build -c release --arch arm64
BIN="$(swift build -c release --arch arm64 --show-bin-path)"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN/NotchIsland" "$APP/Contents/MacOS/NotchIsland"
cp Resources/Info.plist "$APP/Contents/Info.plist"

if [ -n "${CI:-}" ]; then
    SIGN="-"   # CI: nur ad-hoc, reicht zum Prüfen des Builds
else
    security find-certificate -c "$IDENTITY" >/dev/null 2>&1 || ./scripts/make-cert.sh
    SIGN="$IDENTITY"
fi

codesign --force --sign "$SIGN" --identifier "$BUNDLE_ID" "$APP"
codesign --verify --strict "$APP"
echo "Fertig: $APP"
