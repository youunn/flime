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
        let mut commands = Commands::default();
        commands.push(Command::Draw());
        self.run(device, queue, &commands);
        Ok(())
    }

    fn run(&mut self, device: &Device, queue: &Queue, commands: &Commands) {
        let mut encoder = device.create_command_encoder(&Default::default());

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

        queue.submit(Some(encoder.finish()));
    }
}

#[derive(Default)]
pub struct Commands(Vec<Command>);

pub enum Command {
    Draw(),
}

impl Commands {
    pub fn push(&mut self, command: Command) {
        self.0.push(command);
    }

    pub fn draw(&mut self) {
        self.push(Command::Draw());
    }
}

impl From<Commands> for Vec<Command> {
    fn from(value: Commands) -> Self {
        value.0
    }
}
