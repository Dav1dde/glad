glad
====

OpenGL Loader based on the official XML-Specs.
If you're looking only for a loader:

 * C loader: https://github.com/Dav1dde/glad/tree/c
 * D loader: https://github.com/Dav1dde/glad/tree/d
 * Volt loader: https://github.com/Dav1dde/glad/tree/volt


## Usage ##


### Generator ###

To generate the loader for your language execute `main.py` with a Python 2
interpreter.

Possible commandline options:

    -h, --help            show this help message and exit
    --profile {core,compatability}
                          OpenGL profile (defaults to compatability)
    --out-path OUT        Output path for loader
    --api {gl,gles1,gles2}
                          OpenGL API type (defaults to gl)
    --version VERSION     OpenGL version (defaults to latest)
    --generator {c,d,volt}
                          Language (defaults to d)
    --extensions EXTENSIONS
                          Path to extensions file or comma separated list of
                          extensions
    --spec SPEC           Path to gl.xml, if none specified, downloaded from
                          khronos.org

By default a loader for the D programming language will be generated. To generate
a loader for C with two extensions, it could look like that:

    python main.py --generator=c --extensions=GL_EXT_framebuffer_multisample,GL_EXT_Cg_shader --out-path=GL

`--out-path` is the only required option. If the `--extensions` option is missing,
glad adds support for all extensions found in the OpenGL spec.

### Loader ###

#### C ####

`glad.h` completly replaces any `gl.h` or `gl3.h` only include `glad.h`.

Call `gladInit(void)` once on startup, after a context was created call `gladLoadGL(void)`,
if you want to use your own loader to load the OpenGL prototypes you can use
`gladLoadGLLoader(LOADER loader)` instead (`LOADER` is defined as
`typedef void* (* LOADER)(const char *name);` in `glad.h`). `glad` provides its own
loader function called `void* gladGetProcAddress(const char *name)` which will be used by
`gladLoadGL(void)`. Once you terminate, it is recommended to call `gladTerminate(void)`
to free the OpenGL Libraray-handle acquired by `glad`.

Furthermore `glad` provides a boolean (represented as integer) for every extension
and OpenGL version, after `gladLoadGL` was called, a successfully loaded
extension/version evaluates to true:

    GLVersion glv = gladLoadGL();
    printf("OpenGL Version %d.%d loaded", glv.major, glv.minor);
    if(GL_EXT_gpu_shader4) { /* GL_EXT_gpu_shader4 is supported */ }
    if(GL_VERSION_3_0) { /* We support at least OpenGL version 3 */ }


#### D ####

Import `glad.gl` for OpenGL functions/extensions, import `glad.loader` to import
the functions needed to initialize `glad` and load the OpenGL functions.

Call `gladInit()` once on startup, after context creation call `gladLoadGL()`
to load all OpenGL functions. To terminate `glad` call `gladTerminate()`.

Furthermore `glad` provides a boolean (represented as integer) for every extension
and OpenGL version, after `gladLoadGL` was called, a successfully loaded
extension/version evaluates to true:

    GLVersion glv = gladLoadGL();
    writefln("OpenGL Version %d.%d loaded", glv.major, glv.minor);
    if(GL_EXT_gpu_shader4) { /* GL_EXT_gpu_shader4 is supported */ }
    if(GL_VERSION_3_0) { /* We support at least OpenGL version 3 */ }
