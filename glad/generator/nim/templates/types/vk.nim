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

  Reserved* = enum
    RESERVED_FLAG

template MAKE_VERSION*(major, minor, patch: int): int = (major shl 22) or (minor shl 12) or patch
template VERSION_MAJOR*(version: int): int = ((version shr 22))
template VERSION_MINOR*(version: int): int = ((version shr 12) and 0x3ff)
template VERSION_PATCH*(version: int): int = (version and 0xfff)

type
{% for type in feature_set.types %}
{% if type.category == 'basetype' %}
  {{ type.name|no_prefix }}* = distinct {{ type.type|type }}
{% elif type.category == 'handle' %}
  {{ type.name|no_prefix }}* = distinct pointer
{% elif type.category == 'enum' %}
 {% set members = type.enums_for(feature_set) %}
 {% if members %}
  {% if "FlagBits" in type.name %}
  {{ type.name|no_prefix }}* {.size: 4.} = enum
   {% for member in members|rejectattr("alias")|val_sort %}
    {% if member.bitpos != None %}
    {{ member.name|no_prefix }} = {{ member.value }}
    {% endif %}
   {% endfor %}
   {% if members|are_bits %}
  {{ type.name.replace("FlagBits", "Flag")|no_prefix }}* {.size: 4.} = enum
   {% for member in members|rejectattr("alias")|val_sort %}
    {% if member.bitpos != None %}
    {{ member.name.replace("_BIT","")|no_prefix }} = {{ member.bitpos }}
    {% endif %}
   {% endfor %}
   {% endif %}
  {% else %}
  {{ type.name|no_prefix }}* {.size: 4.} = enum
   {% for member in members|rejectattr("alias")|val_sort %}
    {{ member.name|no_prefix }} = {{ member.value }}
   {% endfor %}
  {% endif %}
 {% else %}
  {{ type.name|no_prefix }}* = enum
    {{ type.name|no_prefix }}Reserved
 {% endif %}
{% elif type.alias %}
  {{ type.name|no_prefix }}* = {{ type.alias|no_prefix }}
{% elif type.category in ('struct', 'union') %}
  {{ type.name|no_prefix }}* {{ '{.union.}' if type.category == 'union' }} = object
{% for member in type.members %}
    {{ member.name|identifier }}*: {{ member.type|type|no_prefix }}
{% endfor %}
{% elif type.category == 'bitmask' %}
 {% if feature_set.valid_enum(type.name.replace("Flags", "FlagBits")) %}
  {{ type.name|no_prefix }}* {.size:4} = set[{{ type.name.replace("Flags", "Flag")|no_prefix }}]
 {% else %}
  {{ type.name|no_prefix }}* {.size:4} = set[Reserved]
 {% endif %}
{% elif type.category == 'funcpointer' %}
  {{ type.name|no_prefix }}* = proc(
  {% for parameter in type.parameters %}
    {{ parameter.name|identifier }}: {{ parameter.type|type|no_prefix }},
  {% endfor %}
   ): {{ type.ret|type|no_prefix }} {.cdecl.}
{% endif %}
{% endfor %}

{% for type in feature_set.types|rejectattr("alias") %}
{% if type.category == 'struct' %}
proc mk{{ type.name|no_prefix }}*(
{% for member in type.members %}
  {{ member.name|identifier }}: {{ member.type|type }} {{ '= ' + member.type.default_value|no_prefix if member.type.default_value }}{{ member.type|zero if member.type.optional or member.name == 'pNext'}},
{% endfor %}
  ) : {{ type.name|no_prefix }} =
{% for member in type.members %}
  result.{{ member.name|identifier }} = {{ member.name|identifier }}
{% endfor %}

{% endif %}
{% endfor %}

# Helpers
converter toDeviceSize*(x: int): DeviceSize = x.DeviceSize
func ulen*[N,T](x: array[N,T]): uint32 = x.len.uint32
func ulen*[T](x: seq[T]): uint32 = x.len.uint32

# Loader
var loadProc*: proc(inst: Instance, procName: cstring): pointer

when not defined(vkCustomLoader):
  import dynlib

  when defined(windows):
    const dll = "vulkan-1.dll"
  elif defined(macosx):
    const dll = "libMoltenVK.dylib"
  else:
    const dll = "libvulkan.so.1"

  let handle = loadLib(dll)
  if isNil(handle):
    quit("could not load: " & dll)

  let getProcAddress = cast[proc(inst: Instance, s: cstring): pointer {.stdcall.}](symAddr(handle, "vkGetInstanceProcAddr"))
  if getProcAddress == nil:
    quit("failed to load `vkGetInstanceProcAddr` from " & dll)

  loadProc = proc(inst: Instance, procName: cstring): pointer =
    result = getProcAddress(inst, procName)
    if result != nil:
      return
    result = symAddr(handle, procName)

proc loadProcs*(inst: Instance) =
  {% for command in feature_set.commands|rejectattr('alias') %}
  {{ command.name|no_prefix }} = cast[proc ({{ command|params }}): {{ command.proto.ret|type }} {.stdcall.}](loadProc(inst, "{{ command.name }}"))
  {% endfor %}
