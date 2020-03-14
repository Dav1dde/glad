{% import 'template_utils.rs' as template_utils with context %}
{{ '#![allow(non_snake_case)]' if options.mx }}
pub use self::types::*;
pub use self::enumerations::*;
pub use self::functions::*;

use std::os::raw;

pub struct FnPtr {
    ptr: *const raw::c_void,
    is_loaded: bool
}

impl FnPtr {
    {% if options.mx %}
    pub fn new<F>(loadfn: &mut F, name: &'static str) -> FnPtr where F: FnMut(&'static str) -> *const raw::c_void {
        let loaded = loadfn(name);
        if !loaded.is_null() {
            FnPtr { ptr: loaded, is_loaded: true }
        } else {
            FnPtr { ptr: FnPtr::not_initialized as *const raw::c_void, is_loaded: false }
        }
    }
    {% else %}
    pub fn empty() -> FnPtr {
        FnPtr { ptr: FnPtr::not_initialized as *const raw::c_void, is_loaded: false }
    }

    pub fn load<F>(&mut self, loadfn: &mut F, name: &'static str) where F: FnMut(&'static str) -> *const raw::c_void {
        let loaded = loadfn(name);
        if !loaded.is_null() {
            self.ptr = loaded;
            self.is_loaded = true;
        } else {
            self.ptr = FnPtr::not_initialized as *const raw::c_void;
            self.is_loaded = false;
        };
    }
    
    {% endif %}
    pub fn aliased(&mut self, other: &FnPtr) {
        if !self.is_loaded && other.is_loaded {
            self.ptr = other.ptr;
            self.is_loaded = other.is_loaded;
        }
    }

    #[inline(never)]
    fn not_initialized() -> ! { panic!("{{ feature_set.name }}: function not initialized") }
}

pub mod types {
    {% include 'types/' + spec.name + '.rs' ignore missing with context %}
}

pub mod enumerations {
    #![allow(dead_code, non_upper_case_globals, unused_imports)]

    use std;
    use super::types::*;

    {% for enum in feature_set.enums %}
    pub const {{ enum.name }}: {{ enum|enum_type }} = {{ enum|enum_value }};
    {% endfor %}
}

pub mod functions {
    #![allow({{ 'non_snake_case, ' if not options.mx }}unused_variables, dead_code)]

    use std;
    use std::mem;
    {{ 'use super::FnPtr;' if options.mx else 'use super::storage;' }}
    use super::types::*;

    {{ 'pub struct Gl {' if options.mx }}
    {% if options.mx %}
    {% for command in feature_set.commands %}
    {{ '    ' }}{{ template_utils.protect(command) }} pub(super) _{{ command.name|no_prefix }}: FnPtr,
    {% endfor %}
    }

    impl Gl {
    {% endif %}
    {% for command in feature_set.commands %}
    {{ template_utils.protect(command) }}{{ '    ' if options.mx }} #[inline] pub unsafe fn {{ command.name|no_prefix }}({{ '&self, ' if options.mx }}{{ command|params }}) -> {{ command.proto.ret|type }} { mem::transmute::<_, extern "system" fn({{ command|params('types') }}) -> {{ command.proto.ret|type }}>({{ 'self._' if options.mx else 'storage::' }}{{ command.name|no_prefix }}.ptr)({{ command|params('names') }}) }
    {% endfor %}
    {{ '}' if options.mx }}
}

{% if not options.mx %}
mod storage {
    #![allow({{ 'non_snake_case, ' if not options.mx }}non_upper_case_globals)]

    use super::FnPtr;
    use std::os::raw;

    {% for command in feature_set.commands %}
    {{ template_utils.protect(command) }} pub static mut {{ command.name|no_prefix }}: FnPtr = FnPtr { ptr: FnPtr::not_initialized as *const raw::c_void, is_loaded: false };
    {% endfor %}
}
{% endif %}

pub fn load<F>(mut loadfn: F) {{ '-> functions::Gl' if options.mx }} where F: FnMut(&'static str) -> *const raw::c_void {
    {% if options.mx %}
    let mut gl = Gl {
    {% for command in feature_set.commands %}
    {{ '    ' }}{{ template_utils.protect(command.name) }} _{{ command.name|no_prefix }}: FnPtr::new(&mut loadfn, "{{ command.name }}"),
    {% endfor %}
    };
    {% else %}
    unsafe {
        {% for command in feature_set.commands %}
        {{ template_utils.protect(command) }} storage::{{ command.name | no_prefix }}.load(&mut loadfn, "{{ command.name }}");
        {% endfor %}
    }
    {% endif %}

    {% for command, caliases in aliases|dictsort %}
    {% for alias in caliases|reject('equalto', command) %}
    {{ template_utils.protect(command) }} {{ 'gl._' if options.mx else 'storage::' }}{{ command|no_prefix }}.aliased(&{{ 'gl._' if options.mx else 'storage::' }}{{ alias|no_prefix }});
    {% endfor %}
    {% endfor %}
    {% if options.mx %}
     
     gl
    {% endif %}
}

