#![deny(warnings)]
/**
 * Full WGL should compile
 *
 * GLAD: $GLAD --out-path=$tmp --api="wgl=" rust
 * COMPILE: cp -r $test_dir/. $tmp && cd $tmp && cargo build
 * RUN: cargo run
 */
extern crate glad_wgl;
use glad_wgl::wgl;

#[allow(path_statements)]
fn main() {
    wgl::GetProcAddress;
    wgl::GetSwapIntervalEXT;
}
