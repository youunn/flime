use std::{borrow::Cow, sync::Arc};
use wgpu::PresentMode;
use winit::{
    application::ApplicationHandler,
    error::EventLoopError,
    event::WindowEvent,
    event_loop::{ControlFlow, EventLoop},
    window::{Window, WindowAttributes},
};

use crate::{gpu::{GraphicsContext, GraphicsManager, GraphicsSurface}, render::Renderer};

#[derive(Default)]
pub struct App<'s> {
    context: GraphicsContext,
    renderers: Vec<Option<Renderer>>,
    window: AppWindow,
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

impl App {
    pub fn new(window_attributes: WindowAttributes) -> Self {
        Self {
            window_attributes,
            ..Default::default()
        }
    }
}

impl ApplicationHandler for App {
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
        self.renderers[surface.dev_id]
            .get_or_insert_with(|| create_vello_renderer(&self.context, &surface));

        self.state = AppWindow::Active(ActiveWindow {
            inner: window,
            surface,
        });

        event_loop.set_control_flow(ControlFlow::Wait);
    }

    fn suspended(&mut self, event_loop: &winit::event_loop::ActiveEventLoop) {
        if let AppWindow::Active(window) = &self.state {
            self.state = AppWindow::Suspended(Some(window.inner.clone()));
        }
        event_loop.set_control_flow(ControlFlow::Wait);
    }

    fn window_event(
        &mut self,
        event_loop: &winit::event_loop::ActiveEventLoop,
        window_id: winit::window::WindowId,
        event: WindowEvent,
    ) {
        todo!()
    }
}
