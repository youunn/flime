use winit::{dpi::LogicalSize, event_loop::EventLoop, window::Window};

type AnyResult<T> = Result<T, Box<dyn std::error::Error>>;

fn main() -> AnyResult<()> {
    let event_loop = EventLoop::new().unwrap();
    let window_attributes = Window::default_attributes()
        .with_title("flpov")
        .with_inner_size(LogicalSize::new(800, 600));
    env_logger::init();
    flvis::run(event_loop, window_attributes)?;
    Ok(())
}
