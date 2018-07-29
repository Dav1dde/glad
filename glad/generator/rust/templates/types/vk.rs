#![allow(dead_code, non_camel_case_types, non_snake_case)]

{% import 'template_utils.rs' as template_utils with context %}

use std;

#[macro_export]
macro_rules! VK_MAKE_VERSION {
    ($major:expr, $minor:expr, $patch:expr) => ((($major) << 22) | (($minor) << 12) | ($patch));
}

#[macro_export]
macro_rules! VK_VERSION_MAJOR { ($version:expr) => ($version >> 22); }
#[macro_export]
macro_rules! VK_VERSION_MINOR { ($version:expr) => (($version >> 12) & 0x3ff); }
#[macro_export]
macro_rules! VK_VERSION_PATCH { ($version:expr) => ($version & 0xfff); }

#[macro_export]
macro_rules! VK_DEFINE_NON_DISPATCHABLE_HANDLE {
    ($name:ident) => (
        #[repr(C)]
        #[derive(Copy, Clone)]
        pub struct $name(u64);
    );
}

#[macro_export]
macro_rules! VK_DEFINE_HANDLE {
    ($name:ident) => (
        #[repr(C)]
        #[derive(Copy, Clone)]
        pub struct $name(*const std::os::raw::c_void);
    );
}

{% for type in feature_set.types %}
{% if type.alias %}
pub type {{ type.name }} = {{ type.alias }};
{% elif type.category == 'basetype' %}
pub type {{ type.name }} = {{ type.type|type }};
{% elif type.category == 'handle' %}
{{ type.type }}!({{ type.name }});
{% elif type.category == 'enum' %}
{% set members = type.enums_for(feature_set) %}
{% if members %}
{{ template_utils.protect(type) }}
#[repr(i32)]
#[derive(Copy, Clone, Eq, PartialEq, Debug)]
pub enum {{ type.name }} {
{% for member in  members %}
{% if not member.alias %} {# Aliasing of enums is not allowed in Rust #}
    {{ member.name }} = {{ member.value }},
{% endif %}
{% endfor %}
}
{% endif %}
{% elif type.category in ('struct', 'union') %}
{{ template_utils.protect(type) }}
#[allow(non_snake_case)]
#[repr(C)]
#[derive(Copy, Clone)]
pub {{ type.category }} {{ type.name }} {
{% for member in type.members %}
    {{ member.name|identifier }}: {{ member.type|type }},
{% endfor %}
}
{% elif type.category == 'bitmask' %}
pub type {{ type.name }} = {{ type.type }};
{% elif type.category == 'funcpointer' %}
pub type {{ type.name }} = extern "system" fn(
{% for parameter in type.parameters %}
    {{ parameter.name }}: {{ parameter.type|type }},
{% endfor %}
) -> {{ type.ret|type }};
{% endif %}
{% endfor %}
