{% import 'template_utils.rs' as template_utils with context %}

pub use self::types::*;
pub use self::enumerations::*;
pub use self::functions::*;

use std::os::raw;

pub struct FnPtr {
    ptr: *const raw::c_void,
    is_loaded: bool
}

impl FnPtr {
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
    #![allow(non_snake_case, unused_variables, dead_code)]

    use std;
    use std::mem;
    use super::storage;
    use super::types::*;

    {% for command in feature_set.commands %}
    {{ template_utils.protect(command) }} #[inline] pub unsafe fn {{ command.name|no_prefix }}({{ command|params }}) -> {{ command.proto.ret|type }} { mem::transmute::<_, extern "system" fn({{ command|params('types') }}) -> {{ command.proto.ret|type }}>(storage::{{ command.name|no_prefix }}.ptr)({{ command|params('names') }}) }
    {% endfor %}
}

mod storage {
    #![allow(non_snake_case, non_upper_case_globals)]

    use super::FnPtr;
    use std::os::raw;

    {% for command in feature_set.commands %}
    {{ template_utils.protect(command) }} pub static mut {{ command.name|no_prefix }}: FnPtr = FnPtr { ptr: FnPtr::not_initialized as *const raw::c_void, is_loaded: false };
    {% endfor %}
}

pub fn load<F>(mut loadfn: F) where F: FnMut(&'static str) -> *const raw::c_void {
    unsafe {
        {% for command in feature_set.commands %}
        {{ template_utils.protect(command) }} storage::{{ command.name | no_prefix }}.load(&mut loadfn, "{{ command.name }}");
        {% endfor %}

        {% for command, caliases in aliases|dictsort %}
        {% for alias in caliases|reject('equalto', command) %}
        {{ template_utils.protect(command) }} storage::{{ command|no_prefix }}.aliased(&storage::{{ alias|no_prefix }});
        {% endfor %}
        {% endfor %}
    }
}

