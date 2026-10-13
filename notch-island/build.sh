#!/bin/bash
# Baut build/NotchIsland.app (Apple Silicon) und signiert sie.
set -euo pipefail
cd "$(dirname "$0")"

APP="build/NotchIsland.app"
BUNDLE_ID="at.redl.NotchIsland"
IDENTITY="NotchIsland Local"

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
