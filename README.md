glad
====

Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specifications
for multiple languages.

Check out the [webservice for glad2](https://glad.sh) to generate the files you need!


**NOTE:** This is the 2.0 branch, which adds more functionality but changes the API.

Some languages are only available in the [glad1 generator](https://glad.dav1d.de).

## Examples

```c
#include <glad/gl.h>
// GLFW (include after glad)
#include <GLFW/glfw3.h>


int main() {
    // -- snip --

    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "LearnOpenGL", NULL, NULL);
    glfwMakeContextCurrent(window);

    int version = gladLoadGL(glfwGetProcAddress);
    if (version == 0) {
        printf("Failed to initialize OpenGL context\n");
        return -1;
    }

    // Successfully loaded OpenGL
    printf("Loaded OpenGL %d.%d\n", GLAD_VERSION_MAJOR(version), GLAD_VERSION_MINOR(version));

    // -- snip --
}
```

The full code: [hellowindow2.cpp](example/c++/hellowindow2.cpp)

More examples in the [examples directory](example/) of this repository.


## Documentation

The documentation can be found in the [wiki](https://github.com/Dav1dde/glad/wiki).


Examples can be found [in the example directory](/example). Some examples:

* C/C++
    * [GL GLFW](example/c/gl_glfw.c)
    * [GL GLFW On-Demand loading](example/c/gl_glfw_on_demand.c)
    * [GL GLFW Multiple Windows/Contexts](example/c++/multiwin_mx/)
    * [GL SDL2](example/c/gl_sdl2.c)
    * [Vulkan GLFW](example/c/vulkan_tri_glfw/)
    * [GLX](example/c/glx.c)
    * [GLX Modern](example/c/glx_modern.c)
    * [WGL](example/c/wgl.c)
    * [EGL X11](example/c/egl_x11/)
* Rust
    * [GL GLFW](example/rust/gl-glfw/)
    * [GL GLFW Multiple Windows/Contexts](example/rust/gl-glfw-mx/)



## License

For the source code and various Khronos files see [LICENSE](/LICENSE).

The generated code from glad is any of Public Domain, WTFPL or CC0.
Now Khronos has some of their specifications under Apache Version 2.0
license which may have an impact on the generated code,
[see this clarifying comment](https://github.com/KhronosGroup/OpenGL-Registry/issues/376#issuecomment-596187053)
on the Khronos / OpenGL-Specification issue tracker.
