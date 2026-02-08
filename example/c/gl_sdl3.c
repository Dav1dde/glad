// gcc $(pkg-config --cflags --libs sdl3) -I${GLAD_PATH}/include example/c/gl_sdl3.c ${GLAD_PATH}/src/gl.c
#include <stdlib.h>
#include <stdio.h>

#include <glad/gl.h>
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

const GLuint WIDTH = 800, HEIGHT = 600;

int main(void) {
    // code without checking for errors
    SDL_Init(SDL_INIT_VIDEO);

    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    SDL_Window *window;
    SDL_Renderer *renderer;

    SDL_CreateWindowAndRenderer(
        "[glad] GL with SDL3",
        WIDTH, HEIGHT,
        SDL_WINDOW_OPENGL,
        &window, &renderer
    );

    SDL_GLContext context = SDL_GL_CreateContext(window);

    int version = gladLoadGL((GLADloadfunc) SDL_GL_GetProcAddress);
    printf("GL %d.%d\n", GLAD_VERSION_MAJOR(version), GLAD_VERSION_MINOR(version));

    int exit = 0;
    while(!exit) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch(event.type) {
                case SDL_EVENT_WINDOW_CLOSE_REQUESTED:
                    /* fallthrough */
                case SDL_EVENT_QUIT:
                    exit = 1;
                    break;
                case SDL_EVENT_KEY_DOWN:
                    if (event.key.key == SDLK_ESCAPE) {
                        exit = 1;
                    }
                    break;
                default:
                    break;
            }
        }

        glClearColor(0.7f, 0.9f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        SDL_GL_SwapWindow(window);
        SDL_Delay(1);
    }

    SDL_GL_DestroyContext(context);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
