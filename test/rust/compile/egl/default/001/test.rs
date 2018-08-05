#![deny(warnings)]
/**
 * Full EGL should compile
 *
 * GLAD: $GLAD --out-path=$tmp --api="egl=" rust
 * COMPILE: cp -r $test_dir/. $tmp && cd $tmp && cargo build
 * RUN: cargo run
 */
extern crate glad_egl;
use glad_egl::egl;

#[allow(path_statements)]
fn main() {
    egl::GetProcAddress;
    egl::SwapBuffersWithDamageEXT;
}
