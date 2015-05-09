glad
====

GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.
Also with an experimental webservice: http://glad.dav1d.de


Advantages:

 * Always up to date
 * Supports every Extension (GL/EGL/GLX/WGL)
 * Easy to maintain and extend (supporting multiple languages at once)
 * Allows you to use your own loader or e.g. SDL_GL_GetProcAddress instead of the builtin
 * Easy way to check if an extension is loaded `if(GL_EXT_framebuffer_multisample) { /* Exists */ }`
 * Can generate a loader which fits exactly your needs, only the extensions and version you need


Example using glut and glad:

```c
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

Or the C++ example (using [GLFW](http://glfw.org), which I recommend you to use):
[hellowindow2.cpp](https://github.com/Dav1dde/glad/blob/master/example/c%2B%2B/hellowindow2.cpp)


## Usage ##


### Generator ###

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
      --generator {c,d,volt}
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


### API ###

The glad loader API follows this convention (if backend generates a loader, this is not the case
for Volt but any other language (C and D) have a loader)

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
 * Note: in D this function is an overload of gladLoadGL:
 * GLVersion gladLoadGL(void* function(const(char)* name));
 *
 */
void gladLoadGLLoader(GLADloadproc);
```


#### C/C++ ####

`glad.h` completely replaces any `gl.h` or `gl3.h` only include `glad.h`.

```c
    if(!gladLoadGL()) { exit(-1) };
    printf("OpenGL Version %d.%d loaded", GLVersion.major, GLVersion.minor);
    if(GLAD_GL_EXT_framebuffer_multisample) { /* GL_EXT_framebuffer_multisample is supported */ }
    if(GLAD_GL_VERSION_3_0) { /* We support at least OpenGL version 3 */ }
```

On non-Windows platforms `glad` requires `libdl`, make sure to link with it (`-ldl` for gcc)!

Note, there are two kinds of extension/version symbols, e.g. `GL_VERSION_3_0` and
`GLAD_VERSION_3_0`. Latter is a runtime boolean (represented as integer), whereas
the first (not prefixed with `GLAD_`) is a compiletime-constant, indicating that this
header supports this version (as the official headers define these symbols).
The runtime booleans are only valid *after* a succesful call to `gladLoadGL` or `gladLoadGLLoader`.


#### D ####

Import `glad.gl` for OpenGL functions/extensions, import `glad.loader` to import
the functions needed to initialize `glad` and load the OpenGL functions.

```d
    enforce(gladLoadGL());
    writefln("OpenGL Version %d.%d loaded", GLVersion.major, GLVersion.minor);
    if(GL_EXT_framebuffer_multisample) { /* GL_EXT_framebuffer_multisample is supported */ }
    if(GL_VERSION_3_0) { /* We support at least OpenGL version 3 */ }
```

On non-Windows platforms `glad` requires `libdl`, make sure to link with it (`L-ldl` for dmd)!


## Contribute ##

Contributing is easy! Found a bug? Message me or make a pull request! Added a new generator backend?
Make a pull request!

Special thanks for all the people who contributed and are going to contribute!
Also to these who helped me solve a problem when I simply could not think of a solution.
