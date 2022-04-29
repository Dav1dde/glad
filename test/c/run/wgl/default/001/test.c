/*
 * Full WGL, see examples/c/wgl.c for more information
 *
 * GLAD: $GLAD --out-path=$tmp --api="wgl,gl:core" c --loader --alias
 * COMPILE: $MINGW_GCC -Wno-pedantic $test -o $tmp/test.exe -I$tmp/include $tmp/src/wgl.c $tmp/src/gl.c -lgdi32 -lopengl32
 * RUN: $WINE $tmp/test.exe
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <tchar.h>

#include <glad/wgl.h>
#include <glad/gl.h>


#define ASSERT(expression, message, args...) if(!(expression)) { fprintf(stderr, "%s(%d): " message "\n", __FILE__, __LINE__, ##args); exit(1); }


int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    WNDCLASSEX wcex = { };
    wcex.cbSize = sizeof(WNDCLASSEX);
    wcex.style = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc = DefWindowProc;
    wcex.hInstance = hInstance;
    wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
    wcex.hbrBackground = (HBRUSH) (COLOR_WINDOW + 1);
    wcex.lpszClassName = _T("<test>");

    ATOM wndclass = RegisterClassEx(&wcex);

    HWND hWnd = CreateWindow(MAKEINTATOM(wndclass), _T("<test>"),
                             WS_OVERLAPPEDWINDOW,
                             0, 0,
                             50, 50,
                             NULL, NULL, hInstance, NULL);
    ASSERT(hWnd != NULL, "window creation failed");

    HDC hdc = GetDC(hWnd);
    ASSERT(hdc != NULL, "failed to get window's device context");

    PIXELFORMATDESCRIPTOR pfd = { };
    pfd.nSize = sizeof(pfd);
    pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.dwFlags = PFD_DOUBLEBUFFER | PFD_SUPPORT_OPENGL | PFD_DRAW_TO_WINDOW;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 32;
    pfd.cDepthBits = 32;
    pfd.iLayerType = PFD_MAIN_PLANE;
    int format = ChoosePixelFormat(hdc, &pfd);
    ASSERT(format != 0 && SetPixelFormat(hdc, format, &pfd) != FALSE, "failed to set pixel format");

    HGLRC temp_context = wglCreateContext(hdc);
    ASSERT(temp_context != NULL, "failed to create initial rendering context");

    wglMakeCurrent(hdc, temp_context);

    int wgl_version = gladLoaderLoadWGL(hdc);
    ASSERT(wgl_version >= 1000, "failed to load WGL");
    ASSERT(GLAD_VERSION_MAJOR(wgl_version) >= 1, "wgl major version %d < 1", GLAD_VERSION_MAJOR(wgl_version));
    ASSERT(GLAD_VERSION_MINOR(wgl_version) >= 0, "wgl minor version %d < 0", GLAD_VERSION_MINOR(wgl_version));

    int attributes[] = {
        WGL_CONTEXT_MAJOR_VERSION_ARB, 3,
        WGL_CONTEXT_MINOR_VERSION_ARB, 2,
        WGL_CONTEXT_FLAGS_ARB,
        WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB,
        0
    };

    HGLRC opengl_context = wglCreateContextAttribsARB(hdc, NULL, attributes);
    ASSERT(opengl_context != NULL, "failed to create final rendering context");

    wglMakeCurrent(NULL, NULL);
    wglDeleteContext(temp_context);
    wglMakeCurrent(hdc, opengl_context);

    int version = gladLoaderLoadGL();
    ASSERT(version >= 3002, "glad version %d < 32", version);
    ASSERT(GLAD_VERSION_MAJOR(version) >= 3, "gl major version %d < 3", GLAD_VERSION_MAJOR(version));
    ASSERT(GLAD_VERSION_MAJOR(version) > 3 || GLAD_VERSION_MINOR(version) >= 2, "gl minor version too small %d < 2", GLAD_VERSION_MINOR(version));

    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);

    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    SwapBuffers(hdc);

    wglDeleteContext(opengl_context);
    ReleaseDC(hWnd, hdc);
    DestroyWindow(hWnd);

    return 0;
}
