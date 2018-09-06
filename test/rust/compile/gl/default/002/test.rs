#![deny(warnings)]
/**
 * Full compatibility GL, should compile
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility=" rust
 * COMPILE: cp -r $test_dir/. $tmp && cd $tmp && cargo build
 * RUN: cargo run
 */
extern crate glad_gl;
use glad_gl::gl;

#[allow(path_statements)]
fn main() {
    gl::Begin;
    gl::Clear;
    gl::MultiDrawElementsEXT;
}
