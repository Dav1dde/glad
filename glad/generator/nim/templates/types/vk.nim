{.experimental: "codeReordering".}


type
# types required for: xcb
  xcb_connection_t* = pointer
  xcb_window_t* = uint32
  xcb_visualid_t* = uint32
# types required for: xlib(_xrandr)
  Display* = pointer
  RROutput* = uint
  Window* = uint
  VisualID* = uint
# types required for: win32
  BOOL* = cint
  DWORD* = uint
  LPVOID* = pointer
  HANDLE* = pointer
  HMONITOR* = pointer
  WCHAR* = uint16
  LPCWSTR* = ptr uint16
  HINSTANCE* = pointer
  HWND* = pointer
  SECURITY_ATTRIBUTES* = object
    nLength: DWORD
    lpSecurityDescriptor: LPVOID
    bInheritHandle: BOOL
# types required for: wayland
  wl_display* = pointer
  wl_surface* = pointer
# types required for: mir
  MirConnection* = pointer
  MirSurface* = pointer
# types required for: ggp
  GgpFrameToken* = pointer
  GgpStreamDescriptor* = pointer
# types required for: directfb
  IDirectFB* = pointer
  IDirectFBSurface* = pointer
# types required for: fuchsia
  zx_handle_t* = pointer


template VK_MAKE_VERSION*(major, minor, patch: int): int = (major shl 22) or (minor shl 12) or patch
template VK_VERSION_MAJOR*(version: int): int = ((version shr 22))
template VK_VERSION_MINOR*(version: int): int = ((version shr 12) and 0x3ff)
template VK_VERSION_PATCH*(version: int): int = (version and 0xfff)

type
{% for type in feature_set.types %}
{% if type.alias %}
  {{ type.name }}* = {{ type.alias }}

{% elif type.category == 'basetype' %}
  {{ type.name }}* = distinct {{ type.type|type }}

{% elif type.category == 'handle' %}
  {{ type.name }}* = distinct pointer

{% elif type.category == 'enum' %}
{% set members = type.enums_for(feature_set) %}
{% if members %}
  {{ type.name }}* {.size: int32.sizeof} = enum
{% for member in members|rejectattr("alias")|val_sort %}
    {{ member.name }} = {{ member.value }}
{% endfor %}

{% endif %}
{% elif type.category in ('struct', 'union') %}
  {{ type.name }}* {{ '{.union.}' if type.category == 'union' }} = object
{% for member in type.members %}
    {{ member.name|identifier }}*: {{ member.type|type }}
{% endfor %}

{% elif type.category == 'bitmask' %}
  {{ type.name }}* = distinct {{ type.type }}

{% elif type.category == 'funcpointer' %}
  {{ type.name }}* = proc(
{% for parameter in type.parameters %}
    {{ parameter.name|identifier }}: {{ parameter.type|type }},
{% endfor %}
   ): {{ type.ret|type }} {.cdecl.}

{% endif %}
{% endfor %}

{% for type in feature_set.types|rejectattr("alias") %}
{% if type.category == 'struct' %}
proc mk{{ type.name }}*(
{% for member in type.members %}
  {{ member.name|identifier }}: {{ member.type|type }} {{ '= ' + member.type.default_value if member.type.default_value }}{{ member.type|zero if member.type.optional or member.name == 'pNext'}},
{% endfor %}
  ) : {{ type.name }} =
{% for member in type.members %}
  result.{{ member.name|identifier }} = {{ member.name|identifier }}
{% endfor %}

{% endif %}
{% endfor %}

# Loader
var loadProc*: proc(inst: VkInstance, procName: cstring): pointer

when not defined(vkCustomLoader):
  import dynlib

  when defined(windows):
    const vkDLL = "vulkan-1.dll"
  elif defined(macosx):
    const vkDLL = "libMoltenVK.dylib"
  else:
    const vkDLL = "libvulkan.so.1"

  let vkHandleDLL = loadLib(vkDLL)
  if isNil(vkHandleDLL):
    quit("could not load: " & vkDLL)

  let vkGetProcAddress = cast[proc(inst: VkInstance, s: cstring): pointer {.stdcall.}](symAddr(vkHandleDLL, "vkGetInstanceProcAddr"))
  if vkGetProcAddress == nil:
    quit("failed to load `vkGetInstanceProcAddr` from " & vkDLL)

  loadProc = proc(inst: VkInstance, procName: cstring): pointer =
    result = vkGetProcAddress(inst, procName)
    if result != nil:
      return
    result = symAddr(vkHandleDLL, procName)

proc loadProcs*(inst: VkInstance) =
  {% for command in feature_set.commands|rejectattr('alias') %}
  {{ command.name }} = cast[proc ({{ command|params }}): {{ command.proto.ret|type }} {.stdcall.}](loadProc(inst, "{{ command.name }}"))
  {% endfor %}
