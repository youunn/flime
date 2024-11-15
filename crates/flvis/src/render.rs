use std::collections::HashMap;
use wgpu::{Buffer, Device, Queue, SurfaceTexture};

type AnyResult<T> = Result<T, Box<dyn std::error::Error>>;

pub struct Renderer {
    pipelines: Vec<Pipeline>,
    resource: HashMap<usize, Vec<Buffer>>,
}

pub struct Pipeline {}

impl Renderer {
    pub fn new(pipelines: Vec<Pipeline>, resource: HashMap<usize, Vec<Buffer>>) -> Self {
        Self {
            pipelines,
            resource,
        }
    }

    pub fn render(
        &mut self,
        device: &Device,
        queue: &Queue,
        surface: &SurfaceTexture,
        /* params */
    ) -> AnyResult<()> {
        // generate commands
        Ok(())
    }

    fn run(&mut self) {
        // let mut encoder = device_handler
        //     .device
        //     .create_command_encoder(&Default::default());
        
        // TODO: match command {
        // let view = frame.texture.create_view(&Default::default());
        // let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        //     color_attachments: &[Some(wgpu::RenderPassColorAttachment {
        //         view: &view,
        //         resolve_target: None,
        //         ops: wgpu::Operations {
        //             load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
        //             store: wgpu::StoreOp::Store,
        //         },
        //     })],
        //     ..Default::default()
        // });
        // rpass.set_pipeline(&device_handler.render_pipeline);
        // rpass.draw(0..3, 0..1);
        // drop(rpass);
        // }
        
        // device_handler.queue.submit(Some(encoder.finish()));
    }
}
