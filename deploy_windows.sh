#!/bin/bash
# Windows Deployment Script
# This script copies all necessary DLLs for a self-contained Windows release

set -e

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <exe_path> <output_dir>"
    exit 1
fi

EXE_PATH="$1"
OUTPUT_DIR="$2"

echo "Deploying Windows application..."
echo "Executable: $EXE_PATH"
echo "Output directory: $OUTPUT_DIR"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Copy the executable
cp "$EXE_PATH" "$OUTPUT_DIR/"
EXE_NAME=$(basename "$EXE_PATH")

# Try to run windeployqt
if command -v windeployqt &> /dev/null; then
    echo "Running windeployqt..."
    windeployqt --release --no-translations --no-system-d3d-compiler --no-opengl-sw "$OUTPUT_DIR/$EXE_NAME" || {
        echo "Warning: windeployqt failed, will manually copy DLLs"
    }
else
    echo "Warning: windeployqt not found, will manually copy DLLs"
fi

# Find Qt bin directory
if [ -n "$Qt6_DIR" ]; then
    # Try to resolve Qt bin directory from Qt6_DIR more robustly
    # Common patterns: Qt6_DIR/lib/cmake/Qt6 -> need to go up 3 levels then down to bin
    QT_BIN_DIR=""
    for rel_path in "../../../bin" "../../bin" "../../../../bin"; do
        TEST_DIR="$Qt6_DIR/$rel_path"
        if [ -d "$TEST_DIR" ] && [ -f "$TEST_DIR/qmake" -o -f "$TEST_DIR/qmake.exe" ]; then
            QT_BIN_DIR="$TEST_DIR"
            break
        fi
    done
    if [ -z "$QT_BIN_DIR" ]; then
        echo "Warning: Could not find Qt bin directory from Qt6_DIR=$Qt6_DIR"
    fi
elif [ -n "$QTDIR" ]; then
    QT_BIN_DIR="$QTDIR/bin"
elif command -v qmake &> /dev/null; then
    QMAKE_PATH=$(command -v qmake)
    QT_BIN_DIR=$(dirname "$QMAKE_PATH")
else
    echo "Warning: Cannot find Qt installation directory"
    QT_BIN_DIR=""
fi

# Normalize Qt bin directory path
if [ -n "$QT_BIN_DIR" ]; then
    QT_BIN_DIR=$(cd "$QT_BIN_DIR" && pwd)
    echo "Qt bin directory: $QT_BIN_DIR"
fi

# List of MinGW runtime DLLs that need to be copied
MINGW_DLLS=(
    "libgcc_s_seh-1.dll"
    "libstdc++-6.dll"
    "libwinpthread-1.dll"
)

# List of essential Qt DLLs to ensure they are present
QT_DLLS=(
    "Qt6Core.dll"
    "Qt6Gui.dll"
    "Qt6Widgets.dll"
    "Qt6Network.dll"
)

# Copy MinGW runtime DLLs
echo "Copying MinGW runtime DLLs..."
for dll in "${MINGW_DLLS[@]}"; do
    if [ -f "$QT_BIN_DIR/$dll" ]; then
        cp "$QT_BIN_DIR/$dll" "$OUTPUT_DIR/" && echo "  ✓ Copied $dll"
    else
        echo "  ⚠ Warning: $dll not found in $QT_BIN_DIR"
        # Try to find it in common MinGW locations
        FOUND=false
        # Search in common paths
        for search_path in "/mingw64/bin" "$(dirname "$(which gcc)" 2>/dev/null)"; do
            if [ -n "$search_path" ] && [ -f "$search_path/$dll" ]; then
                cp "$search_path/$dll" "$OUTPUT_DIR/" && echo "  ✓ Copied $dll from $search_path" && FOUND=true
                break
            fi
        done
        # Also search for Qt Tools mingw directory
        if [ "$FOUND" = false ]; then
            for mingw_dir in /c/Qt/Tools/mingw*/bin; do
                if [ -d "$mingw_dir" ] && [ -f "$mingw_dir/$dll" ]; then
                    cp "$mingw_dir/$dll" "$OUTPUT_DIR/" && echo "  ✓ Copied $dll from $mingw_dir" && FOUND=true
                    break
                fi
            done
        fi
        if [ "$FOUND" = false ]; then
            echo "  ✗ Error: Could not find $dll in any known location"
        fi
    fi
done

# Verify Qt DLLs are present (windeployqt should have copied them)
echo "Verifying Qt DLLs..."
for dll in "${QT_DLLS[@]}"; do
    if [ -f "$OUTPUT_DIR/$dll" ]; then
        echo "  ✓ $dll present"
    else
        echo "  ⚠ Warning: $dll not found, attempting to copy..."
        if [ -f "$QT_BIN_DIR/$dll" ]; then
            cp "$QT_BIN_DIR/$dll" "$OUTPUT_DIR/" && echo "  ✓ Copied $dll"
        else
            echo "  ✗ Error: $dll not found in $QT_BIN_DIR"
        fi
    fi
done

# Copy Qt platform plugins if not already present
if [ ! -d "$OUTPUT_DIR/platforms" ] && [ -d "$QT_BIN_DIR/../plugins/platforms" ]; then
    echo "Copying Qt platform plugins..."
    mkdir -p "$OUTPUT_DIR/platforms"
    cp "$QT_BIN_DIR/../plugins/platforms/qwindows.dll" "$OUTPUT_DIR/platforms/" && echo "  ✓ Copied qwindows.dll"
fi

# List all DLLs in output directory
echo ""
echo "Deployment complete! Files in output directory:"
ls -lh "$OUTPUT_DIR"/*.dll 2>/dev/null || true
if [ -d "$OUTPUT_DIR/platforms" ]; then
    echo ""
    echo "Platform plugins:"
    ls -lh "$OUTPUT_DIR/platforms"/*.dll 2>/dev/null || true
fi

echo ""
echo "Deployment successful!"
