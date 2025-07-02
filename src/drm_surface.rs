use std::{
    fs::{File, OpenOptions},
    io::{Seek, Write, SeekFrom},
    time::Duration,
};

use anyhow::{anyhow, Result};

pub struct DrmSurface {
    framebuffer_file: Option<File>,
    width: u32,
    height: u32,
    current_fb: usize,
}

impl DrmSurface {
    pub fn new() -> Result<Self> {
        // First try to open DRM devices to verify access
        let mut drm_found = false;
        for i in 0..10 {
            let path = format!("/dev/dri/card{}", i);
            if OpenOptions::new().read(true).write(true).open(&path).is_ok() {
                log::info!("Found DRM device: {}", path);
                drm_found = true;
                break;
            }
        }

        if !drm_found {
            log::warn!("No DRM device found, but continuing anyway");
        }

        // Try to open framebuffer device for direct pixel writing
        let framebuffer_file = OpenOptions::new()
            .read(true)
            .write(true)
            .open("/dev/fb0")
            .map_err(|e| log::warn!("Could not open /dev/fb0: {}", e))
            .ok();

        if framebuffer_file.is_some() {
            log::info!("Opened framebuffer device: /dev/fb0");
        } else {
            log::warn!("Could not open framebuffer device - will run without display output");
        }

        // Try to get screen resolution from environment or use default
        let (width, height) = if let (Ok(w), Ok(h)) = (
            std::env::var("SCREEN_WIDTH").and_then(|s| s.parse().map_err(|_| std::env::VarError::NotPresent)),
            std::env::var("SCREEN_HEIGHT").and_then(|s| s.parse().map_err(|_| std::env::VarError::NotPresent))
        ) {
            (w, h)
        } else {
            // Default resolution
            (1920, 1080)
        };

        log::info!("Using resolution: {}x{}", width, height);

        Ok(Self {
            framebuffer_file,
            width,
            height,
            current_fb: 0,
        })
    }

    pub fn get_size(&self) -> (u32, u32) {
        (self.width, self.height)
    }

    pub fn write_frame(&mut self, pixels: &[u8]) -> Result<()> {
        if let Some(ref mut fb) = self.framebuffer_file {
            // Seek to beginning of framebuffer
            fb.seek(SeekFrom::Start(0))?;
            
            // Write pixel data
            fb.write_all(pixels)?;
            fb.flush()?;
            
            log::debug!("Wrote {} bytes to framebuffer", pixels.len());
        } else {
            log::debug!("No framebuffer device available - frame not displayed");
        }
        Ok(())
    }

    pub fn swap_buffers(&mut self) -> Result<()> {
        // For framebuffer, we don't need to swap buffers - writing is immediate
        self.current_fb = (self.current_fb + 1) % 2;
        Ok(())
    }

    pub fn wait_for_vblank(&self) -> Result<()> {
        // Simple wait to simulate vblank timing (~60 FPS)
        std::thread::sleep(Duration::from_millis(16));
        Ok(())
    }
}

impl Drop for DrmSurface {
    fn drop(&mut self) {
        log::info!("Dropping DRM surface");
    }
}
