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

# Copy qt.conf (critical configuration file for Qt plugin paths)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/qt.conf" ]; then
    echo "Copying qt.conf..."
    cp "$SCRIPT_DIR/qt.conf" "$OUTPUT_DIR/"
    echo "  ✓ Copied qt.conf"
else
    echo "  ✗ Error: qt.conf not found at $SCRIPT_DIR/qt.conf"
    echo "         This is a critical configuration file required for Qt to find plugins."
    echo "         Deployment cannot continue without it."
    exit 1
fi

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
        if [ -d "$TEST_DIR" ] && { [ -f "$TEST_DIR/qmake" ] || [ -f "$TEST_DIR/qmake.exe" ]; }; then
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
else
    echo "Warning: Qt bin directory not found. Will attempt to find DLLs in alternative locations."
fi

# Exit early if we can't find Qt and basic tools
if [ -z "$QT_BIN_DIR" ] && ! command -v windeployqt &> /dev/null; then
    echo "Warning: Cannot find Qt installation and windeployqt is not available."
    echo "Deployment may be incomplete. Will attempt to find DLLs in alternative locations."
    # Don't exit - try to continue with alternative search paths
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
    FOUND=false
    
    # Try Qt bin directory first if available
    if [ -n "$QT_BIN_DIR" ] && [ -f "$QT_BIN_DIR/$dll" ]; then
        cp "$QT_BIN_DIR/$dll" "$OUTPUT_DIR/" && echo "  ✓ Copied $dll" && FOUND=true
    fi
    
    # If not found, try common MinGW locations
    if [ "$FOUND" = false ]; then
        echo "  ⚠ Warning: $dll not found in Qt bin directory"
        # Search in common paths
        GCC_PATH=$(which gcc 2>/dev/null)
        GCC_BIN_DIR=""
        if [ -n "$GCC_PATH" ]; then
            GCC_BIN_DIR=$(dirname "$GCC_PATH")
        fi
        
        for search_path in "/mingw64/bin" "$GCC_BIN_DIR"; do
            if [ -n "$search_path" ] && [ -d "$search_path" ] && [ -f "$search_path/$dll" ]; then
                cp "$search_path/$dll" "$OUTPUT_DIR/" && echo "  ✓ Copied $dll from $search_path" && FOUND=true
                break
            fi
        done
    fi
    
    # Also search for Qt Tools mingw directory (only if not found yet)
    # This path is specific to Windows Qt installation
    if [ "$FOUND" = false ] && [ -d "/c/Qt/Tools" ]; then
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
done

# Verify Qt DLLs are present (windeployqt should have copied them)
echo "Verifying Qt DLLs..."
if [ -n "$QT_BIN_DIR" ]; then
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
else
    echo "  ⚠ Warning: Qt bin directory not available, skipping Qt DLL verification"
fi

# Copy Qt platform plugins if not already present
if [ ! -d "$OUTPUT_DIR/platforms" ] && [ -n "$QT_BIN_DIR" ] && [ -d "$QT_BIN_DIR/../plugins/platforms" ]; then
    echo "Copying Qt platform plugins..."
    mkdir -p "$OUTPUT_DIR/platforms"
    cp "$QT_BIN_DIR/../plugins/platforms/qwindows.dll" "$OUTPUT_DIR/platforms/" && echo "  ✓ Copied qwindows.dll"
elif [ -d "$OUTPUT_DIR/platforms" ]; then
    echo "  ✓ Platform plugins already present"
else
    echo "  ⚠ Warning: Could not find Qt platform plugins directory"
fi

# Final verification - check that all essential files are present
echo ""
echo "=== Final Verification ==="
MISSING_FILES=()
CRITICAL_DLLS=(
    "Qt6Core.dll"
    "Qt6Gui.dll"
    "Qt6Widgets.dll"
    "Qt6Network.dll"
    "libgcc_s_seh-1.dll"
    "libstdc++-6.dll"
    "libwinpthread-1.dll"
)

for dll in "${CRITICAL_DLLS[@]}"; do
    if [ -f "$OUTPUT_DIR/$dll" ]; then
        echo "  ✓ $dll present"
    else
        echo "  ✗ MISSING: $dll"
        MISSING_FILES+=("$dll")
    fi
done

# Check platform plugin
if [ -f "$OUTPUT_DIR/platforms/qwindows.dll" ]; then
    echo "  ✓ platforms/qwindows.dll present"
else
    echo "  ✗ MISSING: platforms/qwindows.dll"
    MISSING_FILES+=("platforms/qwindows.dll")
fi

# Check qt.conf (critical for Qt plugin discovery)
if [ -f "$OUTPUT_DIR/qt.conf" ]; then
    echo "  ✓ qt.conf present"
else
    echo "  ✗ MISSING: qt.conf"
    MISSING_FILES+=("qt.conf")
fi

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo ""
    echo "⚠⚠⚠ WARNING: Some critical files are missing! ⚠⚠⚠"
    echo "The following files could not be found:"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "The application may not run correctly without these files."
    echo "DO NOT copy DLLs from other applications (like Wireshark)!"
    echo "This will cause ABI incompatibility and entry point errors."
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
