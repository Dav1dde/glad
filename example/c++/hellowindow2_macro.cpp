#include <iostream>

// GLAD
#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>

// GLFW
#include <GLFW/glfw3.h>


// This example is taken from http://learnopengl.com/
// http://learnopengl.com/code_viewer.php?code=getting-started/hellowindow2
// The code originally used GLEW, I replaced it with Glad

// Compile:
// g++ example/c++/hellowindow2.cpp -Ibuild/include build/src/glad.c -lglfw -ldl


// Function prototypes
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mode);

// Window dimensions
const GLuint WIDTH = 800, HEIGHT = 600;


#ifdef GLAD_OPTION_GL_DEBUG
// Define a custom callback for demonstration purposes
void pre_gl_call(const char *name, void *funcptr, int len_args, ...) {
#ifdef GLAD_OPTION_GL_MX
    printf("Current GL Context: %p -> ", gladGetGLContext());
#endif
    printf("Calling: %s at %p (%d arguments)\n", name, funcptr, len_args);
}
#endif


// The MAIN function, from here we start the application and run the game loop
int main()
{
    std::cout << "Starting GLFW context, OpenGL 3.3" << std::endl;
    // Init GLFW
    glfwInit();
    // Set all the required options for GLFW
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

    // Create a GLFWwindow object that we can use for GLFW's functions
    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "LearnOpenGL", NULL, NULL);
    glfwMakeContextCurrent(window);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    // Set the required callback functions
    glfwSetKeyCallback(window, key_callback);

#ifdef GLAD_OPTION_GL_LOADER
    printf("Using internal loader.\n");
#endif

#ifdef GLAD_OPTION_GL_MX
    GladGLContext context = {};
  #ifdef GLAD_OPTION_GL_LOADER
    int version = gladLoaderLoadGLContext(&context);
  #else
    int version = gladLoadGLContext(&context, glfwGetProcAddress);
  #endif
#else
  #ifdef GLAD_OPTION_GL_LOADER
    int version = gladLoaderLoadGL();
  #else
    int version = gladLoadGL(glfwGetProcAddress);
  #endif
#endif

    if (version == 0)
    {
        std::cout << "Failed to initialize OpenGL context" << std::endl;
        return -1;
    }

    std::cout << "Loaded OpenGL " << GLAD_VERSION_MAJOR(version) << "." << GLAD_VERSION_MINOR(version) << std::endl;

#ifdef GLAD_OPTION_GL_DEBUG
    // before every opengl call call pre_gl_call
    glad_set_gl_pre_callback(pre_gl_call);
    // don't use the callbacks for glClear and glClearColor
  #ifdef GLAD_OPTION_GL_MX_GLOBAL
    glad_debug_glClear = gladGetGLContext()->Clear;
    glad_debug_glClearColor = gladGetGLContext()->ClearColor;
  #else
    glad_debug_glClear = glad_glClear;
    glad_debug_glClearColor = glad_glClearColor;
  #endif
#endif

    // Define the viewport dimensions
    glViewport(0, 0, WIDTH, HEIGHT);

    // Game loop
    while (!glfwWindowShouldClose(window))
    {
        // Check if any events have been activated (key pressed, mouse moved etc.) and call corresponding response functions
        glfwPollEvents();

        // Render
        // Clear the colorbuffer
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // Swap the screen buffers
        glfwSwapBuffers(window);
    }

    // Terminates GLFW, clearing any resources allocated by GLFW.
    glfwTerminate();
    return 0;
}

// Is called whenever a key is pressed/released via GLFW
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mode)
{
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
}
