use std::sync::Arc;
use wgpu::PresentMode;
use winit::{
    application::ApplicationHandler,
    event::WindowEvent,
    event_loop::ControlFlow,
    window::{Window, WindowAttributes},
};

use crate::{
    gpu::{GraphicsContext, GraphicsSurface},
    render::Renderer,
};

#[derive(Default)]
pub struct App<'s> {
    context: GraphicsContext,
    renderers: Vec<Option<Renderer>>,
    window: AppWindow<'s>,
    window_attributes: WindowAttributes,
}

enum AppWindow<'s> {
    Active(ActiveWindow<'s>),
    Suspended(Option<Arc<Window>>),
}

struct ActiveWindow<'s> {
    surface: GraphicsSurface<'s>,
    inner: Arc<Window>,
}

impl Default for AppWindow<'_> {
    fn default() -> Self {
        Self::Suspended(None)
    }
}

impl App<'_> {
    pub fn new(window_attributes: WindowAttributes) -> Self {
        Self {
            window_attributes,
            ..Default::default()
        }
    }
}

impl ApplicationHandler for App<'_> {
    fn resumed(&mut self, event_loop: &winit::event_loop::ActiveEventLoop) {
        let AppWindow::Suspended(window) = &mut self.window else {
            return;
        };

        let window = window.take().unwrap_or_else(|| {
            Arc::new(
                event_loop
                    .create_window(self.window_attributes.clone())
                    .expect("Failed to create window"),
            )
        });

        let size = window.inner_size();
        let surface_future = self.context.create_surface(
            window.clone(),
            size.width,
            size.height,
            PresentMode::AutoVsync,
        );
        let surface = pollster::block_on(surface_future).expect("Failed to creating surface");

        self.renderers
            .resize_with(self.context.devices.len(), || None);
        self.renderers[surface.device]
            .get_or_insert_with(|| Renderer::new(Default::default(), Default::default()));

        self.window = AppWindow::Active(ActiveWindow {
            inner: window,
            surface,
        });

        event_loop.set_control_flow(ControlFlow::Wait);
    }

    fn suspended(&mut self, event_loop: &winit::event_loop::ActiveEventLoop) {
        if let AppWindow::Active(window) = &self.window {
            self.window = AppWindow::Suspended(Some(window.inner.clone()));
        }
        event_loop.set_control_flow(ControlFlow::Wait);
    }

    fn window_event(
        &mut self,
        event_loop: &winit::event_loop::ActiveEventLoop,
        window_id: winit::window::WindowId,
        event: WindowEvent,
    ) {
        let window = match &mut self.window {
            AppWindow::Active(window) if window.inner.id() == window_id => window,
            _ => return,
        };
        match event {
            WindowEvent::CloseRequested => {
                event_loop.exit();
            }
            WindowEvent::Resized(size) => {
                self.context
                    .resize_surface(&mut window.surface, size.width, size.height);
                window.inner.request_redraw();
            }
            WindowEvent::RedrawRequested => {
                let frame = window
                    .surface
                    .surface
                    .get_current_texture()
                    .expect("Failed to acquire next swap chain texture");
                let device = &self.context.devices[window.surface.device];

                let x = self
                    .renderers
                    .get(window.surface.device)
                    .expect("failed to get device")
                    .as_mut()
                    .expect("failed to get device")
                    .render();

                frame.present();
                device.device.poll(wgpu::Maintain::Poll);
            }
            _ => {}
        }
    }
}
