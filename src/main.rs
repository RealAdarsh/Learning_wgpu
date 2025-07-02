use Learning_wgpu::run;

fn main() {
    // Initialize logging to see what's happening
    if env_logger::try_init().is_err() {
        // Logger already initialized, that's fine
    }
    
    // Run the DRM-based application
    if let Err(e) = run() {
        eprintln!("Application error: {}", e);
        std::process::exit(1);
    }
}
