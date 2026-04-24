#!/bin/bash
# Build and deploy MagicPrefs
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
DERIVED_DATA=$(xcodebuild -project "$PROJECT_DIR/MagicPrefs.xcodeproj" -scheme MagicPrefs -showBuildSettings 2>/dev/null | grep "BUILT_PRODUCTS_DIR" | head -1 | awk '{print $3}')

echo "Building..."
xcodebuild -scheme MagicPrefs -configuration Release -project "$PROJECT_DIR/MagicPrefs.xcodeproj" 2>&1 | grep -E "error:|BUILD"

APP_SRC="$DERIVED_DATA/MagicPrefs.app"
APP_DST="$HOME/Downloads/MagicPrefs.app"

echo "Deploying to $APP_DST ..."
pkill MagicPrefs 2>/dev/null || true
sleep 1
rm -rf "$APP_DST"
cp -R "$APP_SRC" "$APP_DST"

echo "Ad-hoc signing..."
codesign --deep --force --sign - "$APP_DST"

echo "Removing quarantine..."
xattr -cr "$APP_DST" 2>/dev/null || true

echo "Done. App at: $APP_DST"
echo ""
echo "NOTE: Go to System Settings > Privacy & Security > Accessibility"
echo "      and make sure MagicPrefs is enabled."
