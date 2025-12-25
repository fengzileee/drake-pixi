#!/bin/bash
# scripts/setup_xcode_env.sh

# Only run on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    
    # 1. Detect Xcode Path
    # We use xcode-select to find the active developer directory
    if command -v xcode-select >/dev/null; then
        export DEVELOPER_DIR="$(xcode-select -p)"
    fi

    # 2. Detect Xcode Version
    # We explicitly check the version and export the override variable.
    # This prevents Bazel from trying to run 'xcodebuild' inside the sandbox
    # (which is what caused your "got 'None'" crash).
    if command -v xcodebuild >/dev/null; then
        # Extracts "15.0" or similar from the output
        XCODE_VER=$(xcodebuild -version | grep "Xcode" | awk '{print $2}')
        
        if [ -n "$XCODE_VER" ]; then
            export XCODE_VERSION_OVERRIDE="$XCODE_VER"
        fi
    fi

    # 3. (Optional) Force Bazel to respect these in the repository fetching phase
    # This maps the shell variables to Bazel's internal flags automatically.
    # BAZEL_SH is sometimes needed if shell detection fails.
    export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
fi
