use app::App;

mod app;
mod gpu;
mod utils;
mod render;

#[derive(Default)]
struct RenderApp<'s> {
    context: RenderContext,
    state: RenderState<'s>,
    window_attributes: WindowAttributes,
}

impl RenderApp<'_> {
    fn new(window_attributes: WindowAttributes) -> Self {
        Self {
            window_attributes,
            ..Default::default()
        }
    }
}

#[derive(Default)]
struct RenderContext {
    instance: wgpu::Instance,
    device: Option<DeviceHandle>,
}

struct DeviceHandle {
    adapter: wgpu::Adapter,
    device: wgpu::Device,
    queue: wgpu::Queue,
    render_pipeline: wgpu::RenderPipeline,
}

enum RenderState<'s> {
    Active(ActiveRenderState<'s>),
    Suspended(Option<Arc<Window>>),
}

impl Default for RenderState<'_> {
    fn default() -> Self {
        Self::Suspended(None)
    }
}

struct ActiveRenderState<'s> {
    surface: wgpu::Surface<'s>,
    window: Arc<Window>,
}

impl ApplicationHandler for RenderApp<'_> {
    fn resumed(&mut self, event_loop: &winit::event_loop::ActiveEventLoop) {
        let RenderState::Suspended(window) = &mut self.state else {
            return;
        };

        // TODO: cfg for different platform
        let window = window.take().unwrap_or_else(|| {
            Arc::new(
                event_loop
                    .create_window(self.window_attributes.clone())
                    .expect("Failed to create window"),
            )
        });

        let surface = self
            .context
            .instance
            .create_surface(window.clone())
            .unwrap();

        let adapter = pollster::block_on(self.context.instance.request_adapter(
            &wgpu::RequestAdapterOptions {
                power_preference: wgpu::PowerPreference::default(),
                force_fallback_adapter: false,
                compatible_surface: Some(&surface),
            },
        ))
        .expect("Failed to find an appropriate adapter");

        let (device, queue) = pollster::block_on(adapter.request_device(
            &wgpu::DeviceDescriptor {
                label: None,
                required_features: wgpu::Features::empty(),
                required_limits:
                    wgpu::Limits::downlevel_webgl2_defaults().using_resolution(adapter.limits()),
                memory_hints: wgpu::MemoryHints::MemoryUsage,
            },
            None,
        ))
        .expect("Failed to create device");

        let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: None,
            source: wgpu::ShaderSource::Wgsl(Cow::Borrowed(include_str!("shader.wgsl"))),
        });
        let pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: None,
            bind_group_layouts: &[],
            push_constant_ranges: &[],
        });
        let swapchain_capabilities = surface.get_capabilities(&adapter);
        let swapchain_format = swapchain_capabilities.formats[0];
        let render_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: None,
            layout: Some(&pipeline_layout),
            vertex: wgpu::VertexState {
                module: &shader,
                entry_point: Some("vs_main"),
                buffers: &[],
                compilation_options: Default::default(),
            },
            fragment: Some(wgpu::FragmentState {
                module: &shader,
                entry_point: Some("fs_main"),
                compilation_options: Default::default(),
                targets: &[Some(swapchain_format.into())],
            }),
            primitive: Default::default(),
            depth_stencil: None,
            multisample: Default::default(),
            multiview: None,
            cache: None,
        });

        self.context.device = Some(DeviceHandle {
            adapter,
            device,
            queue,
            render_pipeline,
        });
        self.state = RenderState::Active(ActiveRenderState { surface, window });
        event_loop.set_control_flow(ControlFlow::Wait);
    }

    fn suspended(&mut self, event_loop: &winit::event_loop::ActiveEventLoop) {
        if let RenderState::Active(state) = &self.state {
            self.state = RenderState::Suspended(Some(state.window.clone()));
        }
        event_loop.set_control_flow(ControlFlow::Wait);
    }

    fn window_event(
        &mut self,
        event_loop: &winit::event_loop::ActiveEventLoop,
        window_id: winit::window::WindowId,
        event: WindowEvent,
    ) {
        let render_state = match &mut self.state {
            RenderState::Active(state) if state.window.id() == window_id => state,
            _ => return,
        };
        match event {
            WindowEvent::CloseRequested => {
                event_loop.exit();
            }
            WindowEvent::Resized(size) => {
                let Some(device_handler) = &self.context.device else {
                    render_state.window.request_redraw();
                    return;
                };
                let config = render_state
                    .surface
                    .get_default_config(&device_handler.adapter, size.width.max(1), size.height)
                    .expect("Failed to get surface config");
                render_state
                    .surface
                    .configure(&device_handler.device, &config);
                render_state.window.request_redraw();
            }
            WindowEvent::RedrawRequested => {
                let Some(device_handler) = &self.context.device else {
                    return;
                };
                let frame = render_state
                    .surface
                    .get_current_texture()
                    .expect("Failed to acquire next swap chain texture");
                let view = frame.texture.create_view(&Default::default());
                let mut encoder = device_handler
                    .device
                    .create_command_encoder(&Default::default());

                let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    ..Default::default()
                });
                rpass.set_pipeline(&device_handler.render_pipeline);
                rpass.draw(0..3, 0..1);
                drop(rpass);

                device_handler.queue.submit(Some(encoder.finish()));
                frame.present();
                device_handler.device.poll(wgpu::Maintain::Poll);
            }
            _ => {}
        }
    }
}

pub fn run(
    event_loop: EventLoop<()>,
    window_attributes: WindowAttributes,
) -> Result<(), EventLoopError> {
    let mut app = App::new(window_attributes);
    event_loop.run_app(&mut app)?;
    Ok(())
}
