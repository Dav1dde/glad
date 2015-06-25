glad
====

GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.
Checkout the [experimental webservice](http://glad.dav1d.de)!


```c
// GLAD_DEBUG is only defined if the c-debug generator was used
#ifdef GLAD_DEBUG
// logs every gl call to the console
void pre_gl_call(const char *name, void *funcptr, int len_args, ...) {
    printf("Calling: %s (%d arguments)\n", name, len_args);
}
#endif


int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE);
    glutInitWindowSize(width, height);
    glutCreateWindow("cookie");

    glutReshapeFunc(reshape);
    glutDisplayFunc(display);

    if(!gladLoadGL()) {
        printf("Something went wrong!\n");
        exit(-1);
    }
    
#ifdef GLAD_DEBUG
    // before every opengl call call pre_gl_call
    glad_set_pre_callback(pre_gl_call);
    
    // post callback checks for glGetError by default
    
    // don't use the callback for glClear
    // (glClear could be replaced with your own function)
    glad_debug_glClear = glad_glClear;
#endif
    
    // gladLoadGLLoader(&glutGetProcAddress);
    printf("OpenGL %d.%d\n", GLVersion.major, GLVersion.minor);
    if (GLVersion.major < 2) {
        printf("Your system doesn't support OpenGL >= 2!\n");
        return -1;
    }

    printf("OpenGL %s, GLSL %s\n", glGetString(GL_VERSION),
           glGetString(GL_SHADING_LANGUAGE_VERSION));

    glutMainLoop();

    return 0;
}
```

Checkout the full example: [simple.c](https://github.com/Dav1dde/glad/blob/master/example/c/simple.c)

Or the C++ example using [GLFW](http://glfw.org):
[hellowindow2.cpp](https://github.com/Dav1dde/glad/blob/master/example/c%2B%2B/hellowindow2.cpp)


## Usage ##

Either install glad via pip (root might be required):

    pip install --upgrade git+https://github.com/dav1dde/glad.git#egg=glad
    glad --help

Or launch glad directly

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
void gladLoadGLLoader(GLADloadproc);
```

`glad.h` completely replaces any `gl.h` or `gl3.h` only include `glad.h`.

```c
    if(!gladLoadGL()) { exit(-1) };
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


## Contribute ##

Contributing is easy! Found a bug? Message me or make a pull request! Added a new generator backend?
Make a pull request!

Special thanks for all the people who contributed and are going to contribute!
Also to these who helped me solve a problem when I simply could not think of a solution.
