#!/bin/bash

# Test script for DRM-based wgpu application
# This script demonstrates how to run the application

echo "=== DRM-based wgpu Application Test ==="
echo ""

# Check if we have access to DRM devices
echo "Checking DRM device access..."
if ls /dev/dri/card* >/dev/null 2>&1; then
    echo "✅ DRM devices found:"
    ls -la /dev/dri/card*
else
    echo "❌ No DRM devices found. You may need to:"
    echo "   - Run as root"
    echo "   - Add user to 'video' group"
    echo "   - Check if graphics drivers are loaded"
fi

echo ""
echo "Checking framebuffer access..."
if [ -e /dev/fb0 ]; then
    echo "✅ Framebuffer device found:"
    ls -la /dev/fb0
else
    echo "⚠️  No framebuffer device found at /dev/fb0"
    echo "   The application will run but won't display pixels"
fi

echo ""
echo "Building application..."
if cargo build --release; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "Setting up environment..."
# Use a smaller resolution for testing
export SCREEN_WIDTH=800
export SCREEN_HEIGHT=600
export RUST_LOG=info

echo "Screen resolution: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo ""

echo "Running application..."
echo "This will render 300 frames (~5 seconds) then exit"
echo "Watch for frame progress messages..."

# Run the application
if cargo run --release; then
    echo "✅ Application completed successfully!"
else
    echo "❌ Application failed"
    exit 1
fi

echo ""
echo "Test completed!"
echo ""
echo "If you have a framebuffer device (/dev/fb0), you should have seen"
echo "rendered frames on your display. The application renders a rotating"
echo "textured triangle with a camera that moves around the scene."
