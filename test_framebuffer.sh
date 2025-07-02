#!/bin/bash

echo "=== Quick Framebuffer Test ==="
echo ""
echo "This will write a simple pattern to the framebuffer"
echo "Switch to TTY3 (Ctrl+Alt+F3) to see the output"
echo ""

# Create a simple test pattern
sudo bash -c '
# Fill framebuffer with a gradient pattern
echo "Writing test pattern to framebuffer..."
dd if=/dev/zero of=/dev/fb0 bs=1M count=10 2>/dev/null
echo "Pattern written. Check TTY3 (Ctrl+Alt+F3) for output."
echo "Press Ctrl+Alt+F1 to return to desktop."
'

echo ""
echo "Test pattern sent to framebuffer!"
echo "Switch to TTY3 (Ctrl+Alt+F3) to see if it worked."
