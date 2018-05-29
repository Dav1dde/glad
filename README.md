glad
====

GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.

Use the [webservice](http://glad.dav1d.de) to generate the files you need!


**IMPORTANT:** If you're experiencing errors like `identifier "GLintptr" is undefined`,
*update* to the latest glad version!

```c
#include <glad/glad.h>

int main(int argc, char **argv)
{
    // .. setup the context

    if(!gladLoadGL()) {
        printf("Something went wrong!\n");
        exit(-1);
    }
    printf("OpenGL %d.%d\n", GLVersion.major, GLVersion.minor);

    // .. render here ..
}
```

Examples: 
 * [simple.c](https://github.com/Dav1dde/glad/blob/master/example/c/simple.c)
 * [hellowindow2.cpp](https://github.com/Dav1dde/glad/blob/master/example/c%2B%2B/hellowindow2.cpp)
 using [GLFW](http://glfw.org):


## Usage ##


**If you don't want to install glad you can use the [webservice](http://glad.dav1d.de)**


Otherwise either install glad via pip:

    # Windows
    pip install glad

    # Linux
    pip install --user glad
    # Linux global (root)
    pip install glad

    glad --help

To install the most recent version from Github:

    pip install --upgrade git+https://github.com/dav1dde/glad.git#egg=glad

Or launch glad directly (after cloning the repository):

    python -m glad --help


Possible commandline options:

    usage: glad [-h] [--profile {core,compatibility}] --out-path OUT
                     [--api API] --generator {c,d,volt}
                     [--extensions EXTENSIONS] [--spec {gl,egl,glx,wgl}]
                     [--no-loader]
    
    Uses the official Khronos-XML specs to generate a GL/GLES/EGL/GLX/WGL Loader
    made for your needs. Glad currently supports the languages C, D and Volt.
    
    optional arguments:
      -h, --help            show this help message and exit
      --profile {core,compatibility}
                            OpenGL profile (defaults to compatibility)
      --out-path OUT        Output path for loader
      --api API             API type/version pairs, like "gl=3.2,gles=", no
                            version means latest
      --generator {c,c-debug,d,volt}
                            Language to generate the binding for
      --extensions EXTENSIONS
                            Path to extensions file or comma separated list of
                            extensions, if missing all extensions are included
      --spec {gl,egl,glx,wgl}
                            Name of the spec
      --no-loader
      --omit-khrplatform    Omits inclusion of the khrplatform.h file which is
                            often unnecessary. Only has an effect if used
                            together with c generators.
      --local-files         Forces every file directly into the output directory.
                            No src or include subdirectories are generated. Only
                            has an effect if used together with c generators.


To generate a loader for C with two extensions, it could look like this:

    python main.py --generator=c --extensions=GL_EXT_framebuffer_multisample,GL_EXT_texture_filter_anisotropic --out-path=GL

`--out-path` and `--generator` are required!
If the `--extensions` option is missing, glad adds support for all extensions found in the OpenGL spec.


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

On non-Windows platforms glad requires `libdl`, make sure to link with it (`-ldl` for gcc)!

Note, there are two kinds of extension/version symbols, e.g. `GL_VERSION_3_0` and
`GLAD_VERSION_3_0`. Latter is a runtime boolean (represented as integer), whereas
the first (not prefixed with `GLAD_`) is a compiletime-constant, indicating that this
header supports this version (the official headers define these symbols as well).
The runtime booleans are only valid *after* a succesful call to `gladLoadGL` or `gladLoadGLLoader`.


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


### D ###

Import `glad.gl` for OpenGL functions/extensions, import `glad.loader` to import
the functions needed to initialize glad and load the OpenGL functions.

```d
    enforce(gladLoadGL()); // optionally you can pass a loader to this function
    writefln("OpenGL Version %d.%d loaded", GLVersion.major, GLVersion.minor);
    
    if(GL_EXT_framebuffer_multisample) { 
        /* GL_EXT_framebuffer_multisample is supported */ 
    }
    
    if(GL_VERSION_3_0) {
        /* We support at least OpenGL version 3 */
    }
```

On non-Windows platforms glad requires `libdl`, make sure to link with it (`L-ldl` for dmd)!


## FAQ ##

### How do I build glad or how do I integrate glad?

Easiest way of using glad is through the [webservice](http://glad.dav1d.de).

Alternatively glad integrates with:

* `CMake` 
* [Conan](https://bintray.com/bincrafters/public-conan/glad%3Abincrafters)   
[![Download](https://api.bintray.com/packages/bincrafters/public-conan/glad%3Abincrafters/images/download.svg) ](https://bintray.com/bincrafters/public-conan/glad%3Abincrafters/_latestVersion)

Thanks for all the help and support maintaining those!

### glad includes windows.h which breaks my code! [#42](https://github.com/Dav1dde/glad/issues/42)

Defining `APIENTRY` before including `glad.h` solves this problem:

```c
#ifdef _WIN32
    #define APIENTRY __stdcall
#endif

#include <glad/glad.h>
```

But make sure you have the correct definition of `APIENTRY` for platforms which define `_WIN32` but don't use `__stdcall`

### What's the license of glad generated code? [#101](https://github.com/Dav1dde/glad/issues/101)

Any of Public Domain, WTFPL or CC0.


## Contribute ##

Contributing is easy! Found a bug? Message me or make a pull request! Added a new generator backend?
Make a pull request!

Special thanks for all the people who contributed and are going to contribute!
Also to these who helped me solve a problem when I simply could not think of a solution.
