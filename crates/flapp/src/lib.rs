#[cfg(target_os = "android")]
use winit::platform::android::activity::AndroidApp;

#[allow(dead_code)]
#[cfg(target_os = "android")]
#[unsafe(no_mangle)]
fn android_main(app: AndroidApp) {
    use winit::{
        event_loop::EventLoop, platform::android::EventLoopBuilderExtAndroid, window::Window,
    };
    android_logger::init_once(
        android_logger::Config::default().with_max_level(log::LevelFilter::Info),
    );
    let event_loop = EventLoop::builder().with_android_app(app).build().unwrap();
    flvis::run(event_loop, Window::default_attributes()).unwrap();
}
