#!/bin/bash
# Islamic App APK Builder for Arch Linux
# Skips Flutter version check (avoids git fetch over slow connection)

set -e

export PATH="/home/ngl/flutter/bin:$PATH"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
# Prevent Flutter from auto-updating
export FLUTTER_SUPPRESS_ANALYTICS=true

PROJECT_DIR="/home/ngl/Projects/MYP/Islamic-app"
APK_DIR="$PROJECT_DIR/build/app/outputs/flutter-apk"
APK_FILE="$APK_DIR/app-release.apk"
HTTP_PORT=8081

echo "=== Islamic App APK Builder ==="
echo "Start time: $(date)"

# Step 1: Verify Flutter SDK exists
if [ ! -f "/home/ngl/flutter/bin/flutter" ]; then
    echo "[✗] Flutter SDK not found at /home/ngl/flutter/"
    echo "    Run the download first."
    exit 1
fi
echo "[✓] Flutter SDK found"

# Step 2: Update the app (pull latest)
cd "$PROJECT_DIR"
echo "[...] Pulling latest code..."
git pull origin main --no-tags 2>/dev/null || echo "[!] git pull failed, continuing with current code"
echo "[✓] Code ready"

# Step 3: Build APK (skip flutter --version to avoid git fetch)
echo "[...] Building APK..."
flutter build apk --release --no-version-check 2>&1 | tail -5
echo ""

# Step 4: Check APK
if [ -f "$APK_FILE" ]; then
    APK_SIZE=$(stat -c%s "$APK_FILE")
    echo "[✓] APK built! Size: $APK_SIZE bytes"
    echo ""
    echo "=========================================="
    echo "  APK location: $APK_FILE"
    echo "=========================================="
else
    echo "[✗] APK not found at $APK_FILE"
    echo "    Check build output above for errors."
    exit 1
fi
