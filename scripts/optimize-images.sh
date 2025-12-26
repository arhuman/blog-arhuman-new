#!/bin/bash

# Script to optimize images without quality loss
# Usage: ./scripts/optimize-images.sh [directory]
# Default directory: static/img

set -e

# Configuration
TARGET_DIR="${1:-static/img}"
TEMP_SUFFIX=".opt.tmp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory $TARGET_DIR does not exist${NC}"
    exit 1
fi

echo "=== Image Optimization Script ==="
echo "Target directory: $TARGET_DIR"
echo ""

# Get initial size
INITIAL_SIZE=$(du -sh "$TARGET_DIR" | awk '{print $1}')
echo "Initial size: $INITIAL_SIZE"
echo ""

# Check for required tools
HAS_JPEGTRAN=false
HAS_GIFSICLE=false
HAS_SIPS=false

if command -v jpegtran &> /dev/null; then
    HAS_JPEGTRAN=true
    echo -e "${GREEN}✓${NC} jpegtran found (for JPEG optimization)"
else
    echo -e "${YELLOW}⚠${NC} jpegtran not found - JPEG optimization will be skipped"
fi

if command -v gifsicle &> /dev/null; then
    HAS_GIFSICLE=true
    echo -e "${GREEN}✓${NC} gifsicle found (for GIF optimization)"
else
    echo -e "${YELLOW}⚠${NC} gifsicle not found - GIF optimization will be skipped"
    echo -e "${YELLOW}  ${NC} Install with: brew install gifsicle"
fi

if command -v sips &> /dev/null; then
    HAS_SIPS=true
    echo -e "${GREEN}✓${NC} sips found (for PNG optimization)"
else
    echo -e "${YELLOW}⚠${NC} sips not found - PNG optimization will be skipped"
fi

echo ""

# Optimize JPEGs
if [ "$HAS_JPEGTRAN" = true ]; then
    echo "=== Optimizing JPEG files ==="
    JPEG_COUNT=0
    while IFS= read -r -d '' img; do
        if jpegtran -copy none -optimize -outfile "${img}${TEMP_SUFFIX}" "$img" 2>/dev/null; then
            mv "${img}${TEMP_SUFFIX}" "$img"
            echo -e "${GREEN}✓${NC} Optimized: $img"
            ((JPEG_COUNT++))
        else
            echo -e "${RED}✗${NC} Failed: $img"
            rm -f "${img}${TEMP_SUFFIX}"
        fi
    done < <(find "$TARGET_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0)
    echo "Optimized $JPEG_COUNT JPEG files"
    echo ""
fi

# Optimize GIFs (preserves animation)
if [ "$HAS_GIFSICLE" = true ]; then
    echo "=== Optimizing GIF files ==="
    GIF_COUNT=0
    while IFS= read -r -d '' img; do
        # Use gifsicle with -O3 for maximum optimization while preserving animation
        # -b = batch mode (modifies in place)
        # -O3 = maximum optimization
        if gifsicle -b -O3 "$img" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Optimized: $img"
            ((GIF_COUNT++))
        else
            echo -e "${YELLOW}⚠${NC} Skipped: $img"
        fi
    done < <(find "$TARGET_DIR" -type f -iname "*.gif" -print0)
    echo "Optimized $GIF_COUNT GIF files"
    echo ""
fi

# Optimize PNGs with sips if available
if [ "$HAS_SIPS" = true ]; then
    echo "=== Optimizing PNG files ==="
    PNG_COUNT=0
    while IFS= read -r -d '' img; do
        # sips can optimize PNGs
        if sips -Z 2048 "$img" --out "$img" &>/dev/null; then
            echo -e "${GREEN}✓${NC} Optimized: $img"
            ((PNG_COUNT++))
        else
            echo -e "${YELLOW}⚠${NC} Skipped: $img"
        fi
    done < <(find "$TARGET_DIR" -type f -iname "*.png" -print0)
    echo "Optimized $PNG_COUNT PNG files"
    echo ""
fi

# Get final size
FINAL_SIZE=$(du -sh "$TARGET_DIR" | awk '{print $1}')

echo "=== Optimization Complete ==="
echo "Initial size: $INITIAL_SIZE"
echo "Final size:   $FINAL_SIZE"
echo ""
echo -e "${GREEN}Done!${NC}"
