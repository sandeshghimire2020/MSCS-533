#!/bin/bash
# Builds the app and starts it in the iPhone simulator.
# Usage: ./run.sh

set -e
cd "$(dirname "$0")"

DEVICE_NAME="iPhone 17 Pro"
BUNDLE_ID="com.sandeshghimire.locationtracker"

# Find the simulator's ID by name.
UDID=$(xcrun simctl list devices available | grep "$DEVICE_NAME (" | head -1 | grep -oE '[0-9A-F-]{36}')
if [ -z "$UDID" ]; then
    echo "Could not find a simulator named '$DEVICE_NAME'."
    exit 1
fi

echo "Starting $DEVICE_NAME simulator..."
xcrun simctl boot "$UDID" 2>/dev/null || true   # already booted is fine
open -a Simulator
xcrun simctl bootstatus "$UDID" -b > /dev/null

# Pre-approve location access so no permission prompt appears.
xcrun simctl privacy "$UDID" grant location "$BUNDLE_ID" 2>/dev/null || true

echo "Building and launching the app (first build takes about a minute)..."
echo "Tip: in Simulator choose Features > Location > Freeway Drive, then tap Start."
dotnet build -f net10.0-ios -t:Run -p:_DeviceName=:v2:udid="$UDID"
