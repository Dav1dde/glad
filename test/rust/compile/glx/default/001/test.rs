#![deny(warnings)]
/**
 * Full GLX, should compile
 *
 * GLAD: $GLAD --out-path=$tmp --api="glx=" rust
 * COMPILE: cp -r $test_dir/. $tmp && cd $tmp && cargo build
 * RUN: cargo run
 */
extern crate glad_glx;
use glad_glx::glx;

#[allow(path_statements)]
fn main() {
    glx::GetProcAddress;
    glx::FreeContextEXT;
}
