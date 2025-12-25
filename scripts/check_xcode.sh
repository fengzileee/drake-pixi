#!/bin/sh

# Only run checks on macOS
if [ "$(uname)" = "Darwin" ]; then
    # 1. Define standard paths
    XCODE_APP_PATH="/Applications/Xcode.app"
    EXPECTED_DEV_PATH="$XCODE_APP_PATH/Contents/Developer"
    CURRENT_PATH=$(xcode-select -p)

    # 2. Case A: Xcode is not installed at all
    if [ ! -d "$XCODE_APP_PATH" ]; then
        echo "------------------------------------------------------------"
        echo "❌  CRITICAL MISSING DEPENDENCY: Xcode"
        echo ""
        echo "    Bazel requires the full Xcode application to build,"
        echo "    but it was not found at: $XCODE_APP_PATH"
        echo ""
        echo "    opening Mac App Store to download Xcode..."
        echo "------------------------------------------------------------"
        
        # This command opens the Xcode page in the App Store
        open "macappstore://apps.apple.com/app/xcode/id497799835"
        
        # Fail the build/shell activation so the user knows to stop
        exit 1
    fi

    # 3. Case B: Xcode is installed, but xcode-select points to Command Line Tools
    if echo "$CURRENT_PATH" | grep -q "/Library/Developer/CommandLineTools"; then
        echo "------------------------------------------------------------"
        echo "❌  CRITICAL CONFIGURATION ERROR: Wrong Xcode Path"
        echo ""
        echo "    'xcode-select' is pointing to lightweight tools:"
        echo "    $CURRENT_PATH"
        echo ""
        echo "    It needs to point to the full Xcode app you have installed."
        echo "    Run this command to fix it:"
        echo ""
        echo "    sudo xcode-select -s $EXPECTED_DEV_PATH"
        echo "------------------------------------------------------------"
        exit 1
    fi
fi
