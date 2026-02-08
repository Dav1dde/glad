{% import 'template_utils.rs' as template_utils with context %}
pub use self::types::*;
pub use self::enumerations::*;
pub use self::functions::*;

use std::os::raw::c_void;

{% set ctx_name = feature_set.name | capitalize %}

#[derive(Copy, Clone)]
struct FnPtr {
    ptr: *const c_void,
    is_loaded: bool
}

#[allow(dead_code)]
impl FnPtr {
    fn new(ptr: *const c_void) -> FnPtr {
        if !ptr.is_null() {
            FnPtr { ptr, is_loaded: true }
        } else {
            FnPtr { ptr: FnPtr::not_initialized as *const c_void, is_loaded: false }
        }
    }

    fn set_ptr(&mut self, ptr: *const c_void) {
        *self = Self::new(ptr);
    }
    
    fn aliased(&mut self, other: *const FnPtr) {
        unsafe {
            if !self.is_loaded && (*other).is_loaded {
                *self = *other;
            }
        }
    }

    #[inline(never)]
    fn not_initialized() -> ! { panic!("{{ feature_set.name }}: function not initialized") }
}

unsafe impl Sync for FnPtr {}
unsafe impl Send for FnPtr {}

pub mod types {
    {% include 'types/' + spec.name + '.rs' ignore missing with context %}
}

pub mod enumerations {
    #![allow(dead_code, non_upper_case_globals, unused_imports)]

    use std::os::raw::*;
    use super::types::*;

    {% for enum in feature_set.enums %}
    pub const {{ enum.name|no_prefix }}: {{ enum|enum_type }} = {{ enum|enum_value }};
    {% endfor %}
}

pub mod functions {
    #![allow(non_snake_case, unused_variables, dead_code, unused_imports)]

    use std::mem::transmute;
    use std::os::raw::*;
    use super::*;
    use super::types::*;

    macro_rules! func {
        ($fun:ident, $ret:ty, $($name:ident: $typ:ty),*) => {
            #[inline] pub unsafe fn $fun({{ '&self, ' if options.mx }}$($name: $typ),*) -> $ret {
                transmute::<_, extern "system" fn($($typ),*) -> $ret>({{ 'self.' if options.mx else 'storage::' }}$fun.ptr)($($name),*)
            }
        }
    }

    {% if options.mx %}
    pub struct {{ ctx_name }} {
        {% for command in feature_set.commands %}
        {{ template_utils.protect(command) }} pub(super) {{ command.name|no_prefix }}: FnPtr,
        {% endfor %}
    }

    {% if not spec.name | capitalize == ctx_name %}
    pub type {{ spec.name | capitalize }} = {{ ctx_name }};
    {% endif %}

    impl {{ ctx_name }} {
    {% endif %}

    {% for command in feature_set.commands %}
    {{ template_utils.protect(command) }} func!({{ command.name|no_prefix }}, {{ command.proto.ret|type }}, {{ command|params }});
    {% endfor %}

    {{ '}' if options.mx }}
}

{% if not options.mx %}
mod storage {
    #![allow(non_snake_case, non_upper_case_globals)]

    use super::FnPtr;
    use std::os::raw::*;

    macro_rules! store {
        ($name:ident) => {
            pub(super) static mut $name: FnPtr = FnPtr { ptr: FnPtr::not_initialized as *const c_void, is_loaded: false };
        }
    }

    {% for command in feature_set.commands %}
    {{ template_utils.protect(command) }} store!({{ command.name|no_prefix }});
    {% endfor %}
}
{% endif %}

{% if options.mx %}
pub fn load<F>(mut loadfn: F) -> functions::{{ ctx_name }} where F: FnMut(&'static str) -> *const c_void {
    #[allow(unused_mut)]
    let mut ctx = {{ ctx_name }} {
        {% for command in feature_set.commands %}
        {{ template_utils.protect(command.name) }} {{ command.name|no_prefix }}: FnPtr::new(loadfn("{{ command.name }}")),
        {% endfor %}
    };

    {% for command, caliases in aliases|dictsort %}
    {% for alias in caliases|reject('equalto', command) %}
    {{ template_utils.protect(command) }} ctx.{{ command|no_prefix }}.aliased(std::ptr::addr_of!(ctx.{{ alias|no_prefix }}));
    {% endfor %}
    {% endfor %}

     ctx
}
{% else %}
pub fn load<F>(mut loadfn: F) where F: FnMut(&'static str) -> *const c_void {
    unsafe {
        {% for command in feature_set.commands %}
        {{ template_utils.protect(command) }} storage::{{ command.name | no_prefix }}.set_ptr(loadfn("{{ command.name }}"));
        {% endfor %}

        {% for command, caliases in aliases|dictsort %}
        {% for alias in caliases|reject('equalto', command) %}
        {{ template_utils.protect(command) }}{{ template_utils.protect(alias) }} storage::{{ command|no_prefix }}.aliased(std::ptr::addr_of!(storage::{{ alias|no_prefix }}));
        {% endfor %}
        {% endfor %}
    }
}
{% endif %}

