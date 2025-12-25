#!/bin/bash
set -e

# 1. Validation: Ensure we are in the Pixi environment
if [ -z "$CONDA_PREFIX" ]; then
    echo "Error: You are not in a Pixi environment. Run 'pixi shell' first."
    exit 1
fi

echo "=== Building Drake from Source (Pixi Environment) ==="

# 2. VALIDATION: Check for Drake directory
# Since we are not cloning, we must fail if the directory is missing.
if [ ! -d "drake" ]; then
    echo "Error: 'drake' directory not found."
    echo "       Please clone it first or move this script to the parent folder."
    exit 1
fi

# 3. PREREQUISITE: Bazel Version Patch
BAZEL_BIN=$(which bazel)
INSTALLED_VER=$($BAZEL_BIN --version | awk '{print $2}')
echo " -> Detected Bazel version: $INSTALLED_VER"
echo "$INSTALLED_VER" > drake/.bazelversion

# 4. PREPARE BUILD DIRECTORY
BUILD_DIR="build_local"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 5. CONFIGURE CMAKE
echo "=== Configuring CMake ==="
cmake ../drake \
    -DCMAKE_INSTALL_PREFIX="$CONDA_PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_MOSEK=OFF \
    -DWITH_SNOPT=OFF \
    -DPython_EXECUTABLE=$(which python) \
    -G Ninja

# 6. BUILD
echo "=== Building ==="
ninja install

echo "=== Success ==="
echo "Drake installed to: $CONDA_PREFIX"
