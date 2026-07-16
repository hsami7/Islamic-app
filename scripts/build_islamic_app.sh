#!/bin/bash
# Islamic App APK Builder for Arch Linux
# This script downloads Flutter SDK, builds the APK, and serves it.

set -e

FLUTTER_FILE="/home/ngl/flutter_linux.tar.xz"
FLUTTER_URL="http://100.79.237.30:8080/flutter_linux.tar.xz"
EXPECTED_SIZE=1542730828
PROJECT_DIR="/home/ngl/Projects/MYP/Islamic-app"
APK_DIR="$PROJECT_DIR/build/app/outputs/flutter-apk"
HTTP_PORT=8081

echo "=== Islamic App APK Builder ==="
echo "Start time: $(date)"

# Step 1: Check if Flutter SDK already extracted
if [ -d "/home/ngl/flutter/bin" ] && [ -f "/home/ngl/flutter/bin/flutter" ]; then
    echo "[✓] Flutter SDK already extracted"
else
    # Step 2: Download Flutter SDK with resume
    if [ -f "$FLUTTER_FILE" ]; then
        CURRENT_SIZE=$(stat -c%s "$FLUTTER_FILE" 2>/dev/null || echo 0)
        echo "[...] Resuming download from $CURRENT_SIZE bytes"
    else
        CURRENT_SIZE=0
        echo "[...] Starting download..."
    fi

    while [ "$CURRENT_SIZE" -lt "$EXPECTED_SIZE" ]; do
        curl -L -C - -o "$FLUTTER_FILE" "$FLUTTER_URL" --connect-timeout 10 --max-time 300 2>/dev/null || true
        CURRENT_SIZE=$(stat -c%s "$FLUTTER_FILE" 2>/dev/null || echo 0)
        echo "  Downloaded: $CURRENT_SIZE / $EXPECTED_SIZE bytes"
        if [ "$CURRENT_SIZE" -lt "$EXPECTED_SIZE" ]; then
            echo "  Connection dropped? Retrying in 30s..."
            sleep 30
        fi
    done

    echo "[✓] Download complete! Extracting..."
    cd /home/ngl
    tar xf flutter_linux.tar.xz
    rm -f "$FLUTTER_FILE"
    echo "[✓] Flutter SDK extracted"
fi

# Step 3: Verify Flutter
export PATH="/home/ngl/flutter/bin:$PATH"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
flutter --version

# Step 4: Update the app
cd "$PROJECT_DIR"
echo "[...] Pulling latest code..."
git pull origin main
echo "[✓] Code updated"

# Step 5: Build APK
echo "[...] Building APK (this takes a few minutes)..."
flutter build apk --release
echo "[✓] APK built successfully!"

# Step 6: Serve the APK
APK_FILE="$APK_DIR/app-release.apk"
if [ -f "$APK_FILE" ]; then
    APK_SIZE=$(stat -c%s "$APK_FILE")
    echo "[✓] APK size: $APK_SIZE bytes"
    echo "[✓] Starting HTTP server on port $HTTP_PORT"
    echo ""
    echo "=========================================="
    echo "  Download your APK at:"
    echo "  http://100.81.0.54:8081/app-release.apk"
    echo "=========================================="
    cd "$APK_DIR"
    python3 -m http.server $HTTP_PORT
else
    echo "[✗] APK not found at $APK_FILE"
    exit 1
fi
