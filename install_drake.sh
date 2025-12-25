#!/bin/bash
set -e

# 1. Validation: Ensure we are in the Pixi environment
if [ -z "$CONDA_PREFIX" ]; then
    echo "Error: You are not in a Pixi environment. Run 'pixi shell' first."
    exit 1
fi

echo "=== Building Drake from Source (Pixi Environment) ==="
echo "Install Prefix: $CONDA_PREFIX"

# 2. PREREQUISITE FIX: python-config symlink
# Drake's Bazel rules specifically look for 'python-config'.
# Pixi/Conda provides 'python3-config'. We bridge the gap.
PYTHON_CONFIG="$CONDA_PREFIX/bin/python-config"
if [ ! -f "$PYTHON_CONFIG" ]; then
    echo " -> Creating symlink: python3-config -> python-config"
    ln -sf "$CONDA_PREFIX/bin/python3-config" "$PYTHON_CONFIG"
fi

# 3. PREREQUISITE FIX: Patch .bazelversion
# This forces Drake to accept your installed bazel version.
BAZEL_BIN=$(which bazel)
if [ -z "$BAZEL_BIN" ]; then
    echo "Error: 'bazel' not found. Please add it to pixi.toml."
    exit 1
fi
INSTALLED_VER=$($BAZEL_BIN --version | awk '{print $2}')
echo " -> Detected Bazel version: $INSTALLED_VER"
echo " -> Patching drake/.bazelversion to match..."
echo "$INSTALLED_VER" > drake/.bazelversion

# 4. PREPARE BUILD DIRECTORY
# Standard CMake out-of-source build practice
BUILD_DIR="build_local"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 5. CONFIGURE CMAKE
# Stick to official Drake instructions logic:
# - CMAKE_INSTALL_PREFIX: Where to put the files (your pixi env)
# - WITH_PYTHON: Enable pydrake
# - WITH_MOSEK/SNOPT: Explicitly OFF (unless you have licenses, this prevents search errors)
# - CMAKE_BUILD_TYPE: Release is critical for performance
echo "=== Configuring CMake ==="
cmake ../drake \
    -DCMAKE_INSTALL_PREFIX="$CONDA_PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_PYTHON=ON \
    -DWITH_MOSEK=OFF \
    -DWITH_SNOPT=OFF \
    -DBAZEL_EXECUTABLE="$BAZEL_BIN" \
    -DPython_EXECUTABLE=$(which python) \
    -G Ninja

# 6. BUILD AND INSTALL
echo "=== Building and Installing ==="
ninja install

echo "=== Success ==="
echo "Drake installed to: $CONDA_PREFIX"
echo "Verify with: python -c 'import pydrake; print(pydrake.__file__)'"
