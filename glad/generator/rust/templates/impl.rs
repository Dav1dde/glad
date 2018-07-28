pub use self::types::*;
pub use self::enumerations::*;
pub use self::functions::*;

use std::os::raw;

pub struct FnPtr {
    ptr: *const raw::c_void,
}

impl FnPtr {
    pub fn empty() -> FnPtr {
        FnPtr { ptr: FnPtr::not_initialized as *const raw::c_void }
    }

    pub fn load<F>(&mut self, loadfn: &mut F, name: &'static str) where F: FnMut(&'static str) -> *const raw::c_void {
        let loaded = loadfn(name);
        if !loaded.is_null() {
            self.ptr = loaded;
        };
    }

    #[inline(never)]
    fn not_initialized() -> ! { panic!("{{ feature_set.name }}: function not initialized") }
}

pub mod types {
    {% include 'types/' + spec.name + '.rs' %}
}

pub mod enumerations {
    #![allow(dead_code, non_upper_case_globals)]

    use super::types::*;

    {% for enum in feature_set.enums %}
    pub const {{ enum.name }}: {{ enum | enum_type }} = {{ enum.value }};
    {% endfor %}
}

pub mod functions {
    #![allow(non_snake_case, unused_variables, dead_code)]

    use std::mem;
    use super::storage;
    use super::types::*;

    {% for command in feature_set.commands %}
    #[inline] pub unsafe fn {{ command.name|no_prefix }}({{ command|params }}) -> {{ command.proto.ret|type }} { mem::transmute::<_, extern "system" fn({{ command|params('types') }}) -> {{ command.proto.ret|type }}>(storage::{{ command.name|no_prefix }}.ptr)({{ command|params('names') }}) }
    {% endfor %}
}

mod storage {
    #![allow(non_snake_case, non_upper_case_globals)]

    use super::FnPtr;
    use std::os::raw;

    {% for command in feature_set.commands %}
    pub static mut {{ command.name|no_prefix }}: FnPtr = FnPtr { ptr: FnPtr::not_initialized as *const raw::c_void };
    {% endfor %}
}

pub fn load<F>(mut loadfn: F) where F: FnMut(&'static str) -> *const raw::c_void {
    unsafe {
        {% for command in feature_set.commands %}
        storage::{{ command.name | no_prefix }}.load(&mut loadfn, "{{ command.name }}");
        {% endfor %}
    }
}
