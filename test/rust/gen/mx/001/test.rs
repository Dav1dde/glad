#![deny(warnings)]
/**
 * Make sure the generated context struct is Send + Sync
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core=" rust --mx
 * COMPILE: cp -r $test_dir/. $tmp && cd $tmp && cargo build
 * RUN: cargo run
 */
extern crate glad_gl;
use glad_gl::gl;
use std::mem::MaybeUninit;

fn requires_sync<T: Sync>(_x: &T) {}
fn requires_send<T: Send>(_x: &T) {}

#[allow(path_statements)]
fn main() {
    #[allow(invalid_value)]
    let gl: gl::Gl = unsafe { MaybeUninit::uninit().assume_init() };

    requires_send(&gl);
    requires_sync(&gl);
}
