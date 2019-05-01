glad
====

Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specifications
for multiple languages, including C/C++/Rust/D/Nim/Volt/Pascal.

Check out the [webservice for glad2](https://glad.sh) to generate the files you need!


**NOTE:** The 2.0 branch is currently a beta version, the beta version number will
not be updated and refers to the git *HEAD*.

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
    * [GL GLFW Multiple Windows](example/c++/multiwin_mx/)
    * [GL SDL2](example/c/gl_sdl2.c)
    * [Vulkan GLFW](example/c/vulkan_tri_glfw/)
    * [GLX](example/c/glx.c)
    * [GLX Modern](example/c/glx_modern.c)
    * [WGL](example/c/wgl.c)
    * [EGL X11](example/c/egl_x11/)
* Rust
    * [GL GLFW](example/rust/gl-glfw/)


