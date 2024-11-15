use app::App;
use winit::{error::EventLoopError, event_loop::EventLoop, window::WindowAttributes};

mod app;
mod gpu;
mod render;
mod utils;

pub fn run(
    event_loop: EventLoop<()>,
    window_attributes: WindowAttributes,
) -> Result<(), EventLoopError> {
    let mut app = App::new(window_attributes);
    event_loop.run_app(&mut app)?;
    Ok(())
}
