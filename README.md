glad
====

GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.

**Use the [webservice](https://glad.dav1d.de) to generate the files you need!**


```c
#include <glad/glad.h>

int main()
{
    // -- snip --

    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "LearnOpenGL", NULL, NULL);
    glfwMakeContextCurrent(window);

    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        std::cout << "Failed to initialize OpenGL context" << std::endl;
        return -1;
    }

    glViewport(0, 0, WIDTH, HEIGHT);

    // -- snip --
```

The full code: [hellowindow2.cpp](https://github.com/Dav1dde/glad/blob/master/example/c%2B%2B/hellowindow2.cpp).

### Glad 2

Glad 2 is becoming mature and is pretty stable now, consider using the
[glad2 branch](https://github.com/Dav1dde/glad/tree/glad2) or its [webservice](https://glad.sh).

**There is no need to switch, if you don't want to. I will support both versions.**

Glad2 brings several improvements and new features:

* Better EGL, GLX, WGL support
* **Vulkan** Support
* Rust Support
* More Generator Features (e.g. header only)
* Better XML-Specification parsing
* Better Web-Generator
* Better Cmake support
* Better Examples
* Better CLI
* Better Loader
* Better API

If you're using glad for more than GL, I highly recommend checking out glad2.

## Usage ##


**If you don't want to install glad you can use the [webservice](https://glad.dav1d.de)**


Otherwise either install glad via pip:

    # Windows
    pip install glad

    # Linux
    pip install --user glad
    # Linux global (root)
    pip install glad

To install the most recent version from Github:

    pip install --upgrade git+https://github.com/dav1dde/glad.git#egg=glad

Or launch glad directly (after cloning the repository):

    python -m glad --help

Installing and building glad via vcpkg

You can download and install glad using the [vcpkg](https://github.com/Microsoft/vcpkg) dependency manager:

    git clone https://github.com/Microsoft/vcpkg.git
    cd vcpkg
    ./bootstrap-vcpkg.sh
    ./vcpkg integrate install
    vcpkg install glad

The glad port in vcpkg is kept up to date by Microsoft team members and community contributors. If the version is out of date, please [create an issue or pull request](https://github.com/Microsoft/vcpkg) on the vcpkg repository.

When integrating glad into your build system the `--reproducible` option is highly recommended.

## Generators ##

### C/C++ ###

```c
struct gladGLversionStruct {
    int major;
    int minor;
};

extern struct gladGLversionStruct GLVersion;

typedef void* (* GLADloadproc)(const char *name);

/*
 * Load OpenGL using the internal loader.
 * Returns the true/1 if loading succeeded.
 *
 */
int gladLoadGL(void);

/*
 * Load OpenGL using an external loader like SDL_GL_GetProcAddress.
 *
 * Substitute GL with the API you generated
 *
 */
int gladLoadGLLoader(GLADloadproc);

/**
 * WGL and GLX have an unload function to free the module handle.
 * Call the unload function after your last GLX or WGL API call.
 */
void gladUnloadGLX(void);
void gladUnloadWGL(void);
```

`glad.h` completely replaces any `gl.h` or `gl3.h` only include `glad.h`.

```c
    if(!gladLoadGL()) { exit(-1); }
    printf("OpenGL Version %d.%d loaded", GLVersion.major, GLVersion.minor);

    if(GLAD_GL_EXT_framebuffer_multisample) {
        /* GL_EXT_framebuffer_multisample is supported */
    }

    if(GLAD_GL_VERSION_3_0) {
        /* We support at least OpenGL version 3 */
    }
```

On non-Windows platforms glad requires `libdl`, make sure to link with it (`-ldl`).

Note, there are two kinds of extension/version symbols, e.g. `GL_VERSION_3_0` and
`GLAD_VERSION_3_0`. Latter is a runtime boolean (represented as integer), whereas
the first (not prefixed with `GLAD_`) is a compiletime-constant, indicating that this
header supports this version (the official headers define these symbols as well).
The runtime booleans are only valid *after* a successful call to `gladLoadGL` or `gladLoadGLLoader`.


### C/C++ Debug ###

The C-Debug generator extends the API by these two functions:

```c
// this symbol only exists if generated with the c-debug generator
#define GLAD_DEBUG
typedef void (* GLADcallback)(const char *name, void *funcptr, int len_args, ...);

/*
 * Sets a callback which will be called before every function call
 * to a function loaded by glad.
 *
 */
GLAPI void glad_set_pre_callback(GLADcallback cb);

/*
 * Sets a callback which will be called after every function call
 * to a function loaded by glad.
 *
 */
GLAPI void glad_set_post_callback(GLADcallback cb);
```

To call a function like `glGetError` in a callback prefix it with `glad_`, e.g.
the default post callback looks like this:

```c
void _post_call_callback_default(const char *name, void *funcptr, int len_args, ...) {
    GLenum error_code;
    error_code = glad_glGetError();

    if (error_code != GL_NO_ERROR) {
        fprintf(stderr, "ERROR %d in %s\n", error_code, name);
    }
}
```

You can also submit own implementations for every call made by overwriting
the function pointer with the name of the function prefixed by `glad_debug_`.

E.g. you could disable the callbacks for glClear with `glad_debug_glClear = glad_glClear`, where
`glad_glClear` is the function pointer loaded by glad.

The `glClear` macro is defined as `#define glClear glad_debug_glClear`,
`glad_debug_glClear` is initialized with a default implementation, which calls
the two callbacks and the real function, in this case `glad_glClear`.


## FAQ ##

### How do I build glad or how do I integrate glad?

Easiest way of using glad is through the [webservice](https://glad.dav1d.de).

Alternatively glad integrates with:

* `CMake`
* [Conan](https://conan.io/center/glad)
* [VCPKG](https://github.com/Microsoft/vcpkg)

Thanks for all the help and support maintaining those!

### glad includes windows.h [#42](https://github.com/Dav1dde/glad/issues/42)

**Since 0.1.30:** glad does not include `windows.h` anymore.

**Before 0.1.30:**
Defining `APIENTRY` before including `glad.h` solves this problem:

```c
#ifdef _WIN32
    #define APIENTRY __stdcall
#endif

#include <glad/glad.h>
```

But make sure you have the correct definition of `APIENTRY` for platforms which define `_WIN32` but don't use `__stdcall`

### What's the license of glad generated code?
[#101](https://github.com/Dav1dde/glad/issues/101)
[#253](https://github.com/Dav1dde/glad/issues/253)

The glad generated code itself is any of Public Domain, WTFPL or CC0,
the source files for the generated code are under various licenses
from Khronos.

* EGL: See [egl.xml](https://github.com/KhronosGroup/EGL-Registry/blob/main/api/egl.xml#L4)
* GL: Apache Version 2.0
* GLX: Apache Version 2.0
* WGL: Apache Version 2.0
* Vulkan: Apache Version 2.0 [with exceptions for generated code](https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/main/xml/vk.xml)

Now the Apache License may apply to the generated code (not a lawyer),
but see [this clarifying comment](https://github.com/KhronosGroup/OpenGL-Registry/issues/376#issuecomment-596187053).

Glad also adds header files form Khronos,
these have separated licenses in their header.

## Contribute ##

Contributing is easy! Found a bug? Message me or make a pull request! Added a new generator backend?
Make a pull request!

Special thanks for all the people who contributed and are going to contribute!
Also to these who helped me solve a problem when I simply could not think of a solution.
