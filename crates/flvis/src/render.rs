use std::collections::HashMap;
use wgpu::{
    BindGroupLayout, Buffer, ComputePipeline, Device, Queue, RenderPipeline, SurfaceTexture,
    TextureView,
};

type AnyResult<T> = Result<T, Box<dyn std::error::Error>>;

#[derive(Default)]
pub struct Renderer {
    pipelines: Vec<Pipeline>,
    resource: HashMap<usize, Vec<Buffer>>,
}

struct Pipeline {
    inner: GeneralPipeline,
    layout: BindGroupLayout,
}

enum GeneralPipeline {
    Compute(ComputePipeline),
    Render(RenderPipeline),
}

impl Renderer {
    pub fn render(
        &mut self,
        device: &Device,
        queue: &Queue,
        frame: &SurfaceTexture,
        /* params */
    ) -> AnyResult<()> {
        // generate commands
        let mut commands = Commands::default();
        commands.push(Command::Draw());
        let view = frame.texture.create_view(&Default::default());
        self.run(device, queue, &commands, &view);
        Ok(())
    }

    fn run(&mut self, device: &Device, queue: &Queue, view: &TextureView, commands: &Commands) {
        let mut encoder = device.create_command_encoder(&Default::default());

        for command in commands.0 {
            match command {
                Command::Draw() => {
                    let pipeline = &self.pipelines[id];
                    let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                            view,
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
                }
            }
        }

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
