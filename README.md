glad
====

OpenGL Loader based on the official XML-Specs.
Supporting OpenGL and with still experimental GLES support.


Advantages:

 * Always up to date
 * Supports every OpenGL extension
 * Easy to maintain and extend (supporting multiple languages at once)
 * Allows you to use your own loader or e.g. SDL_GL_GetProcAddress instead of the builtin
 * Easy way to check if an extension is loaded `if(GL_EXT_Cg_shader) { /* Exists */ }`
 * Can generate a loader which fits exactly your needs, only the extensions and version you need

What a D code using glad (and SDL) could look like:

    import glad.gl; // imports all constants and functions, including extensions
    import glad.loader : gladLoadGL;
    void main() {
        /* setup OpenGL context with SDL */
        gladLoadGL(&SDL_GL_GetProcAddress);
        enforce(GLVersion.major >= 3 && GLVersion.minor >= 2);
        /* done, use OpenGL here */
    }

Of course you don't need to use SDL, glad provides its own OpenGL loder:

    void main() {
        /* setup OpenGL context with e.g. glfw */
        enforce(gladLoadGL());
        enforce(GLVersion.major == 3 && GLVersion.minor == 2);
        enforce(GL_EXT_texture_filter_anisotropic, "Extension not supported!");
        /* done, use OpenGL here */
    }

You're not familiar with D, here is a C example:
[https://github.com/Dav1dde/glad/blob/master/example/c/simple.c](https://github.com/Dav1dde/glad/blob/master/example/c/simple.c)


If you don't want to generate your own loader or just wanna check out the generated code:

 * C loader: https://github.com/Dav1dde/glad/tree/c
 * D loader: https://github.com/Dav1dde/glad/tree/d
 * Volt bindings: https://github.com/Dav1dde/glad/tree/volt


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

### API ###

The glad loader API follows this convention (if backend generates a loader, this is not the case
for Volt but any other language (C and D) have a loader)

```c
struct {
    int major;
    int minor;
} GLVersion;

typedef void* (* LOADER)(const char *name);

/*
 * Load OpenGL using the internal loader.
 * Returns the true/1 if loading succeeded.
 *
 */
int gladLoadGL(void);
/*
 * Load OpenGL using an external loader like SDL_GL_GetProcAddress.
 *
 * Note: in D this function is an overload of gladLoadGL:
 * GLVersion gladLoadGL(void* function(const(char)* name));
 *
 */
void gladLoadGLLoader(LOADER);
```


#### C ####

`glad.h` completly replaces any `gl.h` or `gl3.h` only include `glad.h`.

    if(!gladLoadGL()) { exit(-1) };
    printf("OpenGL Version %d.%d loaded", GLVersion.major, GLVersion.minor);
    if(GL_EXT_gpu_shader4) { /* GL_EXT_gpu_shader4 is supported */ }
    if(GL_VERSION_3_0) { /* We support at least OpenGL version 3 */ }

On non-Windows platforms `glad` requires `libdl`, make sure to link with it (`-ldl` for gcc)!


#### D ####

Import `glad.gl` for OpenGL functions/extensions, import `glad.loader` to import
the functions needed to initialize `glad` and load the OpenGL functions.

    enforce(gladLoadGL());
    writefln("OpenGL Version %d.%d loaded", GLVersion.major, GLVersion.minor);
    if(GL_EXT_gpu_shader4) { /* GL_EXT_gpu_shader4 is supported */ }
    if(GL_VERSION_3_0) { /* We support at least OpenGL version 3 */ }

On non-Windows platforms `glad` requires `libdl`, make sure to link with it (`L-ldl` for dmd)!
