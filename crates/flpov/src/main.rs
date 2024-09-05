use winit::{dpi::LogicalSize, event_loop::EventLoop, window::Window};

type AnyResult = std::result::Result<(), Box<dyn std::error::Error>>;

fn main() -> AnyResult {
    let event_loop = EventLoop::new().unwrap();
    let window = event_loop.create_window(
        Window::default_attributes()
            .with_title("flpov")
            .with_inner_size(LogicalSize::new(128, 128)),
    )?;
    env_logger::init();
    pollster::block_on(flvis::run(event_loop, window));
    Ok(())
}
