glad
====

Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.

Check out the [webservice](http://glad.sh) to generate the files you need!


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