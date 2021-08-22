extern crate glfw;
extern crate glad_gl;
use std::sync::mpsc::Receiver;
use glfw::{Action, Context, Key};
use glad_gl::gl;


struct Window {
    source: glfw::Window,
    events: Receiver<(f64, glfw::WindowEvent)>,
    gl: gl::Gl
}

fn main() {
    let mut glfw = glfw::init(glfw::FAIL_ON_ERRORS).unwrap();

    let mut w1 = create_window(&mut glfw);
    let mut w2 = create_window(&mut glfw);

    while !w1.source.should_close() && !w2.source.should_close() {
        glfw.poll_events();

        draw(&mut w1);
        draw(&mut w2);
    }
}

fn create_window(glfw: &mut glfw::Glfw) -> Window {
    let (mut window, events) = glfw
        .create_window(300, 300, "[glad] Rust - OpenGL with GLFW", glfw::WindowMode::Windowed)
        .expect("Failed to create GLFW window.");

    window.set_key_polling(true);
    window.make_current();

    let gl = gl::load(|e| glfw.get_proc_address_raw(e) as *const std::os::raw::c_void);

    Window {
        source: window, events, gl
    }
}

fn draw(window: &mut Window) {
    for (_, event) in glfw::flush_messages(&window.events) {
        handle_window_event(&mut window.source, event);
    }

    window.source.make_current();
    unsafe {
        window.gl.ClearColor(0.7, 0.9, 0.1, 1.0);
        window.gl.Clear(gl::COLOR_BUFFER_BIT);
    }
    window.source.swap_buffers();
}

fn handle_window_event(window: &mut glfw::Window, event: glfw::WindowEvent) {
    match event {
        glfw::WindowEvent::Key(Key::Escape, _, Action::Press, _) => {
            window.set_should_close(true)
        }
        _ => {}
    }
}
