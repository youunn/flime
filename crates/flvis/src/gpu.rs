use wgpu::{
    util::initialize_adapter_from_env_or_default, Adapter, CompositeAlphaMode, Device, Instance, Limits, PresentMode, Queue, Surface, SurfaceConfiguration, SurfaceTarget, TextureFormat, TextureUsages
};

type AnyResult<T> = Result<T, Box<dyn std::error::Error>>;

#[derive(Default)]
pub struct GraphicsContext {
    instance: Instance,
    pub devices: Vec<GraphicsDevice>,
}

pub struct GraphicsDevice {
    adapter: Adapter,
    pub device: Device,
    queue: Queue,
}

pub struct GraphicsSurface<'s> {
    pub surface: Surface<'s>,
    pub config: SurfaceConfiguration,
    pub device: usize,
    pub format: TextureFormat,
}

impl GraphicsContext {
    pub async fn create_surface<'w>(
        &mut self,
        window: impl Into<SurfaceTarget<'w>>,
        width: u32,
        height: u32,
        present_mode: PresentMode,
    ) -> AnyResult<GraphicsSurface<'w>> {
        let surface = self.instance.create_surface(window.into())?;
        
        let dev_id = self
            .device(Some(&surface))
            .await
            .ok_or("no compatible device")?;
        let device_handle = &self.devices[dev_id];
        let capabilities = surface.get_capabilities(&device_handle.adapter);
        let format = capabilities
            .formats
            .into_iter()
            .find(|it| matches!(it, TextureFormat::Rgba8Unorm | TextureFormat::Bgra8Unorm))
            .ok_or("unsupported surface format")?;

        let config = SurfaceConfiguration {
            usage: TextureUsages::RENDER_ATTACHMENT,
            format,
            width,
            height,
            present_mode,
            desired_maximum_frame_latency: 2,
            alpha_mode: CompositeAlphaMode::Auto,
            view_formats: vec![],
        };
        let surface = GraphicsSurface {
            surface,
            config,
            device: dev_id,
            format,
        };
        self.configure_surface(&surface);
        Ok(surface)
    }

    pub fn resize_surface(&self, surface: &mut GraphicsSurface, width: u32, height: u32) {
        surface.config.width = width;
        surface.config.height = height;
        self.configure_surface(surface);
    }

    pub fn set_present_mode(&self, surface: &mut GraphicsSurface, present_mode: PresentMode) {
        surface.config.present_mode = present_mode;
        self.configure_surface(surface);
    }

    fn configure_surface(&self, surface: &GraphicsSurface) {
        let device = &self.devices[surface.device].device;
        surface.surface.configure(device, &surface.config);
    }

    pub async fn device(&mut self, compatible_surface: Option<&Surface<'_>>) -> Option<usize> {
        let compatible = match compatible_surface {
            Some(s) => self
                .devices
                .iter()
                .enumerate()
                .find(|(_, d)| d.adapter.is_surface_supported(s))
                .map(|(i, _)| i),
            None => (!self.devices.is_empty()).then_some(0),
        };
        if compatible.is_none() {
            return self.new_device(compatible_surface).await;
        }
        compatible
    }

    async fn new_device(&mut self, compatible_surface: Option<&Surface<'_>>) -> Option<usize> {
        let adapter =
            initialize_adapter_from_env_or_default(&self.instance, compatible_surface).await?;
        let features = adapter.features();
        let limits = Limits::default();
        let (device, queue) = adapter
            .request_device(
                &wgpu::DeviceDescriptor {
                    label: None,
                    required_features: features & wgpu::Features::CLEAR_TEXTURE,
                    required_limits: limits,
                    memory_hints: Default::default(),
                },
                None,
            )
            .await
            .ok()?;
        let device_handle = GraphicsDevice {
            adapter,
            device,
            queue,
        };
        self.devices.push(device_handle);
        Some(self.devices.len() - 1)
    }
}
