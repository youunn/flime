use std::collections::HashMap;
use wgpu::Buffer;

pub struct Renderer {
    pipelines: Vec<Pipeline>,
    resource: HashMap<usize, Vec<Buffer>>,
}

pub struct Pipeline {}

impl Renderer {
    fn run() {}
}