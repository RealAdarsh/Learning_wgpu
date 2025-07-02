#!/bin/bash

echo "=== Stopping Display Manager to Access Framebuffer ==="
echo ""
echo "WARNING: This will close your desktop session!"
echo "Make sure to save all your work before proceeding."
echo ""
echo "This script will:"
echo "1. Stop the display manager (GDM/LightDM/etc.)"
echo "2. Run the DRM application with framebuffer output"
echo "3. Restart the display manager when done"
echo ""

read -p "Are you sure you want to continue? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Detecting display manager..."

# Detect which display manager is running
if systemctl is-active --quiet gdm3; then
    DM="gdm3"
elif systemctl is-active --quiet gdm; then
    DM="gdm"
elif systemctl is-active --quiet lightdm; then
    DM="lightdm"
elif systemctl is-active --quiet sddm; then
    DM="sddm"
else
    echo "Could not detect display manager. You may need to stop it manually."
    echo "Common commands:"
    echo "  sudo systemctl stop gdm3"
    echo "  sudo systemctl stop lightdm"
    echo "  sudo systemctl stop sddm"
    exit 1
fi

echo "Found display manager: $DM"
echo ""

echo "Stopping display manager in 5 seconds..."
echo "Your desktop will close!"
for i in 5 4 3 2 1; do
    echo "$i..."
    sleep 1
done

# Stop the display manager
sudo systemctl stop $DM

# Wait a moment for it to stop
sleep 2

echo "Display manager stopped. Running DRM application..."
echo "Press Ctrl+C to stop the application."

# Run the application
sudo bash -c "
export SCREEN_WIDTH=800
export SCREEN_HEIGHT=600
export RUST_LOG=info
cd $(pwd)
./target/release/Learning_wgpu
"

echo ""
echo "Application finished. Restarting display manager..."
sudo systemctl start $DM

echo "Display manager restarted. Your desktop should return shortly."
