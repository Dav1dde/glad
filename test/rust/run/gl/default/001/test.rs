#![deny(warnings)]
/**
 * Full core GL, should compile
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core=" rust
 * COMPILE: cp -r $test_dir/. $tmp && cd $tmp && cargo build
 * RUN: cargo run
 */
extern crate glad_gl;
extern crate glfw;

use glad_gl::gl;
use glfw::Context;

fn main() {
    let mut glfw = glfw::init(glfw::LOG_ERRORS).unwrap();

    let (mut window, _events) =
        glfw.create_window(300, 300, "[glad] Rust - OpenGL with GLFW", glfw::WindowMode::Windowed)
            .expect("Failed to create GLFW window.");

    window.set_key_polling(true);
    window.make_current();

    gl::load(|e| glfw.get_proc_address_raw(e) as *const std::os::raw::c_void);

    glfw.poll_events();

    unsafe {
        gl::Viewport(0, 0, 300, 300);
        gl::ClearColor(0.7, 0.9, 0.1, 1.0);
        gl::Clear(gl::COLOR_BUFFER_BIT);
    }

    window.swap_buffers();
}
