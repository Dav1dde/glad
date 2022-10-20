#include <iostream>

#include <glad/gl.h>
#include <GLFW/glfw3.h>


// Function prototypes
GLFWwindow* create_window(const char *name, int major, int minor);
GladGLContext* create_context(GLFWwindow *window);
void free_context(GladGLContext *context);
void draw(GLFWwindow *window, GladGLContext *context, float r, float g, float b);
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mode);

// Window dimensions
const GLuint WIDTH = 400, HEIGHT = 300;


int main()
{
    glfwInit();

    GLFWwindow *window1 = create_window("Window 1", 3, 3);
    GLFWwindow *window2 = create_window("Window 2", 3, 2);

    if (!window1 || !window2) {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    glfwSetKeyCallback(window1, key_callback);
    glfwSetKeyCallback(window2, key_callback);

    GladGLContext *context1 = create_context(window1);
    GladGLContext *context2 = create_context(window2);

    if (!context1 || !context2) {
        std::cout << "Failed to initialize GL contexts" << std::endl;
        free_context(context1);
        free_context(context2);
    }

    glfwMakeContextCurrent(window1);
    context1->Viewport(0, 0, WIDTH, HEIGHT);

    glfwMakeContextCurrent(window2);
    context2->Viewport(0, 0, WIDTH, HEIGHT);


    while (!glfwWindowShouldClose(window1) && !glfwWindowShouldClose(window2))
    {
        glfwPollEvents();

        draw(window1, context1, 0.5, 0.2, 0.6);
        draw(window2, context2, 0.0, 0.1, 0.8);
    }

    free_context(context1);
    free_context(context2);

    glfwTerminate();

    return 0;
}

GLFWwindow* create_window(const char *name, int major, int minor) {
    std::cout << "Creating Window, OpenGL " << major << "." << minor << ": " << name << std::endl;

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, major);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, minor);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, name, NULL, NULL);
    return window;
}

GladGLContext* create_context(GLFWwindow *window) {
    glfwMakeContextCurrent(window);

    GladGLContext* context = (GladGLContext*) calloc(1, sizeof(GladGLContext));
    if (!context) return NULL;

    int version = gladLoadGLContext(context, glfwGetProcAddress);
    std::cout << "Loaded OpenGL " << GLAD_VERSION_MAJOR(version) << "." << GLAD_VERSION_MINOR(version) << std::endl;

    return context;
}

void free_context(GladGLContext *context) {
    free(context);
}


void draw(GLFWwindow *window, GladGLContext *gl, float r, float g, float b) {
    glfwMakeContextCurrent(window);

    gl->ClearColor(r, g, b, 1.0f);
    gl->Clear(GL_COLOR_BUFFER_BIT);

    glfwSwapBuffers(window);
}

// Is called whenever a key is pressed/released via GLFW
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mode)
{
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
}
