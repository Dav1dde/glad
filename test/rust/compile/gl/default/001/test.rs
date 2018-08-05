#![deny(warnings)]
/**
 * Full core GL, should compile
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core=" rust
 * COMPILE: cp -r $test_dir/. $tmp && cd $tmp && cargo build
 * RUN: cargo run
 */
extern crate glad_gl;
use glad_gl::gl;

#[allow(path_statements)]
fn main() {
    gl::Clear;
    gl::MultiDrawElementsEXT;
}
