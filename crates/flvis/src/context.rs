use wgpu::{Adapter, Device, Instance, Queue};

#[derive(Default)]
pub struct GraphicsContext {
    instance: Instance,
    device: Option<GraphicsDevice>,
}

pub struct GraphicsDevice {
    adapter: Adapter,
    device: Device,
    queue: Queue,
}

impl GraphicsSurface {
    pub fn create_surface() {
    }
}
