Example: gl-glfw-mx
================


This is basic example showcasing `glad-gl` in combination with
[`glfw`](https://crates.io/crates/glfw). And multiple OpenGL contexts
in different windows.

To run the example use the following command:

```sh
./init.sh && cargo run
```

The `init.sh` script is just a small utility used to generate
the `glad-gl` crate into the `build/` directory. The `Cargo.toml`
references the dependency using:

```toml
[dependencies]
glad-gl = { path = "./build/glad-gl" }
```

This example is the basic example of the
[glfw crate](https://crates.io/crates/glfw) with some
OpenGL instructions added and just one additional line
to initialize `glad`:

```rust
    gl::load(|e| glfw.get_proc_address_raw(e) as *const std::os::raw::c_void);
```

That's all that is needed to initialize and use OpenGL using `glad`!

