(*
  Generate GLAD:   python -m glad --out-path=build --api="gl=2.1" --extensions="" --generator="pascal"
  FPC build:  fpc -B -Fu../../build/glad/ -Fu../../../Pascal-SDL-2-Headers/ sdl_glad.pas
  Delphi build:  dcc64 -B -NSSystem -NSWinApi -U../../build/glad/ -U../../../Pascal-SDL-2-Headers/ sdl_glad.pas
*)  

program sdl_glad;
{$IF Defined(FPC)}
{$MODE Delphi}
{$ENDIF}
  uses SysUtils, SDL2, glad_gl;

var
  window: PSDL_Window;
  renderer: PSDL_Renderer;
  event: PSDL_Event;
  running: Boolean;
  gl_context: TSDL_GLContext;
  
begin  

  if SDL_Init(SDL_INIT_VIDEO) <> 0 then
  begin
    WriteLn(Format('SDL2 video subsystem couldn''t be initialized. Error: %d', [SDL_GetError()]));
    Halt(1);
  end;

  window := SDL_CreateWindow('SDL & Glad Sample',
    SDL_WINDOWPOS_CENTERED,
    SDL_WINDOWPOS_CENTERED,
    800, 600, SDL_WINDOW_SHOWN or SDL_WINDOW_OPENGL);

  renderer := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
  if not Assigned(renderer) then
  begin
    WriteLn(Format('SDL2 Renderer couldn''t be created. Error: %d', [SDL_GetError()]));
    Halt(1);
  end;

  (* Create a OpenGL context on SDL2 *)
  gl_context := SDL_GL_CreateContext(window);

  (* Load GL extensions using glad *)
  if gladLoadGL(@SDL_GL_GetProcAddress) = False then
  begin
    WriteLn('Failed to initialize the OpenGL context.');
    Halt(1);
  end;

  (* Loaded OpenGL successfully. *)
  WriteLn(Format('OpenGL version loaded: %d.%d', [glVersionMajor, glVersionMinor]));
  (* Create an event handler *)
  New(event);
  (* Loop condition *)
  running := True;
    
  while running = True do
  begin

    SDL_PollEvent(event);

    case event.type_ of
      SDL_QUITEV:
        running := false;

      SDL_KEYDOWN:
        case event.key.keysym.sym of 
          SDLK_ESCAPE:
            running := false;
        end;
    end;

    glClearColor(0, 0, 0, 1);

    (* You'd want to use modern OpenGL here *)
    glColor3d(0, 1, 0);
    glBegin(GL_TRIANGLES);
    glVertex2f(0.2, 0);
    glVertex2f(0.01, 0.2);
    glVertex2f(-0.2, 0);
    glEnd();

    SDL_GL_SwapWindow(window);
  end;

  (* Destroy everything to not leak memory. *)
  Dispose(event);
  SDL_GL_DeleteContext(gl_context);
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();
end.
