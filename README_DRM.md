# DRM-based wgpu Application

This is a modified version of the original wgpu learning project that renders directly to the DRM framebuffer instead of using winit for window management. This allows the application to run without X11 or Wayland.

## Key Changes

1. **Removed winit dependency**: The application no longer depends on winit for window management.

2. **Added DRM surface**: Created a `DrmSurface` struct that manages DRM device access (simplified implementation).

3. **Offscreen rendering**: The application renders to an offscreen texture and then copies the data to the DRM framebuffer.

4. **Direct framebuffer access**: Instead of presenting to a window, the application writes directly to the display framebuffer.

## Architecture

- `drm_surface.rs`: Manages DRM device access and framebuffer operations
- `lib.rs`: Main application logic with offscreen rendering
- `main.rs`: Entry point that initializes logging and runs the application

## Current Implementation Status

This is a simplified proof-of-concept implementation. The current version:

- ✅ Compiles successfully
- ✅ Uses offscreen rendering with wgpu
- ✅ Has basic DRM device detection
- ⚠️ Uses simulated buffer swapping (not actual DRM page flipping)
- ⚠️ Uses hardcoded resolution (1920x1080)
- ⚠️ Doesn't actually copy rendered frames to DRM framebuffer yet

## To Complete the Implementation

For a fully functional DRM-based renderer, you would need to:

1. **Add proper DRM integration**:
   - Use the `drm` crate properly with device traits
   - Implement actual mode setting and connector detection
   - Add real framebuffer creation and management

2. **Add GBM integration**:
   - Use GBM (Generic Buffer Manager) for buffer allocation
   - Create proper DMA-BUF sharing between wgpu and DRM

3. **Copy rendered frames**:
   - Map the wgpu texture data to CPU memory
   - Copy the pixel data to the DRM framebuffer
   - Handle format conversion if needed

4. **Add proper synchronization**:
   - Implement real vblank waiting
   - Add page flipping for smooth updates

## Running

```bash
# Build the project
cargo build

# Run (you'll need DRM permissions, typically requires running as root or being in the video group)
cargo run
```

## Notes

- This implementation demonstrates the structure needed for DRM-based rendering
- For production use, you'd want to implement proper DRM/KMS integration
- The application should be run with appropriate permissions to access `/dev/dri/card*` devices
- Consider using libraries like `drm-rs` and `gbm` for proper hardware integration

## Alternative Approaches

Instead of copying CPU-side, you could also:
- Use DMA-BUF to share buffers directly between wgpu and DRM
- Use Vulkan's WSI (Window System Integration) with DRM
- Implement proper EGL/DRM integration for hardware-accelerated path
