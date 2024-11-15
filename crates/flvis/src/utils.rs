use wgpu::Device;

struct NullWake;

impl std::task::Wake for NullWake {
    fn wake(self: std::sync::Arc<Self>) {}
}

pub fn block_on_wgpu<F: Future>(device: &Device, mut future: F) -> F::Output {
    let waker = std::task::Waker::from(std::sync::Arc::new(NullWake));
    let mut context = std::task::Context::from_waker(&waker);
    let mut future = std::pin::pin!(future);
    loop {
        match future.as_mut().poll(&mut context) {
            std::task::Poll::Pending => {
                device.poll(wgpu::Maintain::Wait);
            }
            std::task::Poll::Ready(item) => break item,
        }
    }
}