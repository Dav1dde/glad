module glad.gl.loader;


private import glad.gl.funcs;
private import glad.gl.ext;
private import glad.gl.enums;
private import glad.gl.types;
alias Loader = void* delegate(const(char)*);

version(Windows) {
    private import std.c.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
} else {
    private __gshared void* libGL;
}
extern(System) private alias gladGetProcAddressPtrType = void* function(const(char)*);
private __gshared gladGetProcAddressPtrType gladGetProcAddressPtr;

private
bool open_gl() {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll");
        if(libGL !is null) {
            gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))GetProcAddress(
                libGL, "wglGetProcAddress");
            return gladGetProcAddressPtr !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum const(char)*[] NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL",
                "/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
            ];
        } else {
            enum const(char)*[] NAMES = ["libGL.so.1", "libGL.so"];
        }

        foreach(name; NAMES) {
            libGL = dlopen(name, RTLD_NOW | RTLD_GLOBAL);
            if(libGL !is null) {
                version(OSX) {
                    return true;
                } else {
                    gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))dlsym(libGL,
                        "glXGetProcAddressARB");
                    return gladGetProcAddressPtr !is null;
                }
            }
        }

        return false;
    }
}

private
void* get_proc(const(char)* namez) {
    if(libGL is null) return null;
    void* result;

    if(gladGetProcAddressPtr !is null) {
        result = gladGetProcAddressPtr(namez);
    }
    if(result is null) {
        version(Windows) {
            result = GetProcAddress(libGL, namez);
        } else {
            result = dlsym(libGL, namez);
        }
    }

    return result;
}

private
void close_gl() {
    version(Windows) {
        if(libGL !is null) {
            FreeLibrary(libGL);
            libGL = null;
        }
    } else {
        if(libGL !is null) {
            dlclose(libGL);
            libGL = null;
        }
    }
}

bool gladLoadGL() {
    bool status = false;

    if(open_gl()) {
        status = gladLoadGL(x => get_proc(x));
        close_gl();
    }

    return status;
}

static struct GLVersion { static int major = 0; static int minor = 0; }
private extern(C) char* strstr(const(char)*, const(char)*);
private extern(C) int strcmp(const(char)*, const(char)*);
private extern(C) int strncmp(const(char)*, const(char)*, size_t);
private extern(C) size_t strlen(const(char)*);
private bool has_ext(const(char)* ext) {
    if(GLVersion.major < 3) {
        const(char)* extensions = cast(const(char)*)glGetString(GL_EXTENSIONS);
        const(char)* loc;
        const(char)* terminator;

        if(extensions is null || ext is null) {
            return false;
        }

        while(1) {
            loc = strstr(extensions, ext);
            if(loc is null) {
                return false;
            }

            terminator = loc + strlen(ext);
            if((loc is extensions || *(loc - 1) == ' ') &&
                (*terminator == ' ' || *terminator == '\0')) {
                return true;
            }
            extensions = terminator;
        }
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        for(uint i=0; i < cast(uint)num; i++) {
            if(strcmp(cast(const(char)*)glGetStringi(GL_EXTENSIONS, i), ext) == 0) {
                return true;
            }
        }
    }

    return false;
}
bool gladLoadGL(Loader load) {
	glGetString = cast(typeof(glGetString))load("glGetString");
	if(glGetString is null) { return false; }
	if(glGetString(GL_VERSION) is null) { return false; }

	find_coreGL();
	load_GL_VERSION_1_0(load);
	load_GL_VERSION_1_1(load);
	load_GL_VERSION_1_2(load);
	load_GL_VERSION_1_3(load);
	load_GL_VERSION_1_4(load);
	load_GL_VERSION_1_5(load);
	load_GL_VERSION_2_0(load);
	load_GL_VERSION_2_1(load);
	load_GL_VERSION_3_0(load);
	load_GL_VERSION_3_1(load);
	load_GL_VERSION_3_2(load);
	load_GL_VERSION_3_3(load);
	load_GL_VERSION_4_0(load);
	load_GL_VERSION_4_1(load);
	load_GL_VERSION_4_2(load);
	load_GL_VERSION_4_3(load);
	load_GL_VERSION_4_4(load);
	load_GL_VERSION_4_5(load);

	find_extensionsGL();
	load_GL_APPLE_element_array(load);
	load_GL_AMD_multi_draw_indirect(load);
	load_GL_SGIX_tag_sample_buffer(load);
	load_GL_NV_point_sprite(load);
	load_GL_ATI_separate_stencil(load);
	load_GL_EXT_texture_buffer_object(load);
	load_GL_ARB_vertex_blend(load);
	load_GL_OVR_multiview(load);
	load_GL_ARB_program_interface_query(load);
	load_GL_EXT_index_func(load);
	load_GL_NV_shader_buffer_load(load);
	load_GL_EXT_color_subtable(load);
	load_GL_SUNX_constant_data(load);
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_ARB_shader_atomic_counters(load);
	load_GL_NV_conditional_render(load);
	load_GL_MESA_resize_buffers(load);
	load_GL_ARB_texture_view(load);
	load_GL_ARB_map_buffer_range(load);
	load_GL_EXT_convolution(load);
	load_GL_NV_vertex_attrib_integer_64bit(load);
	load_GL_EXT_paletted_texture(load);
	load_GL_ARB_texture_buffer_object(load);
	load_GL_ATI_pn_triangles(load);
	load_GL_SGIX_flush_raster(load);
	load_GL_EXT_light_texture(load);
	load_GL_AMD_draw_buffers_blend(load);
	load_GL_APPLE_texture_range(load);
	load_GL_EXT_texture_array(load);
	load_GL_NV_texture_barrier(load);
	load_GL_ARB_vertex_type_2_10_10_10_rev(load);
	load_GL_3DFX_tbuffer(load);
	load_GL_GREMEDY_frame_terminator(load);
	load_GL_ARB_blend_func_extended(load);
	load_GL_EXT_separate_shader_objects(load);
	load_GL_NV_texture_multisample(load);
	load_GL_ARB_shader_objects(load);
	load_GL_ARB_framebuffer_object(load);
	load_GL_ATI_envmap_bumpmap(load);
	load_GL_ATI_map_object_buffer(load);
	load_GL_ARB_robustness(load);
	load_GL_NV_pixel_data_range(load);
	load_GL_EXT_framebuffer_blit(load);
	load_GL_ARB_gpu_shader_fp64(load);
	load_GL_NV_command_list(load);
	load_GL_EXT_vertex_weighting(load);
	load_GL_GREMEDY_string_marker(load);
	load_GL_EXT_subtexture(load);
	load_GL_EXT_gpu_program_parameters(load);
	load_GL_NV_evaluators(load);
	load_GL_SGIS_texture_filter4(load);
	load_GL_AMD_performance_monitor(load);
	load_GL_EXT_stencil_clear_tag(load);
	load_GL_NV_present_video(load);
	load_GL_SGIX_framezoom(load);
	load_GL_ARB_draw_elements_base_vertex(load);
	load_GL_NV_transform_feedback(load);
	load_GL_NV_fragment_program(load);
	load_GL_AMD_stencil_operation_extended(load);
	load_GL_ARB_instanced_arrays(load);
	load_GL_ARB_get_texture_sub_image(load);
	load_GL_KHR_robustness(load);
	load_GL_AMD_sparse_texture(load);
	load_GL_ARB_clip_control(load);
	load_GL_NV_fragment_coverage_to_color(load);
	load_GL_NV_fence(load);
	load_GL_ARB_texture_buffer_range(load);
	load_GL_SUN_mesh_array(load);
	load_GL_ARB_vertex_attrib_binding(load);
	load_GL_ARB_framebuffer_no_attachments(load);
	load_GL_ARB_cl_event(load);
	load_GL_OES_single_precision(load);
	load_GL_NV_primitive_restart(load);
	load_GL_SUN_global_alpha(load);
	load_GL_EXT_texture_object(load);
	load_GL_AMD_name_gen_delete(load);
	load_GL_ARB_buffer_storage(load);
	load_GL_APPLE_vertex_program_evaluators(load);
	load_GL_ARB_multi_bind(load);
	load_GL_SGIX_list_priority(load);
	load_GL_NV_vertex_buffer_unified_memory(load);
	load_GL_ARB_clear_texture(load);
	load_GL_NV_blend_equation_advanced(load);
	load_GL_SGIS_sharpen_texture(load);
	load_GL_ARB_vertex_program(load);
	load_GL_ARB_vertex_buffer_object(load);
	load_GL_NV_vertex_array_range(load);
	load_GL_SGIX_fragment_lighting(load);
	load_GL_NV_framebuffer_multisample_coverage(load);
	load_GL_EXT_timer_query(load);
	load_GL_NV_bindless_texture(load);
	load_GL_KHR_debug(load);
	load_GL_ATI_vertex_attrib_array_object(load);
	load_GL_EXT_geometry_shader4(load);
	load_GL_EXT_bindable_uniform(load);
	load_GL_KHR_blend_equation_advanced(load);
	load_GL_ATI_element_array(load);
	load_GL_SGIX_reference_plane(load);
	load_GL_EXT_stencil_two_side(load);
	load_GL_NV_explicit_multisample(load);
	load_GL_IBM_static_data(load);
	load_GL_EXT_texture_perturb_normal(load);
	load_GL_EXT_point_parameters(load);
	load_GL_PGI_misc_hints(load);
	load_GL_ARB_vertex_shader(load);
	load_GL_ARB_tessellation_shader(load);
	load_GL_EXT_draw_buffers2(load);
	load_GL_ARB_vertex_attrib_64bit(load);
	load_GL_EXT_texture_filter_minmax(load);
	load_GL_AMD_interleaved_elements(load);
	load_GL_ARB_fragment_program(load);
	load_GL_ARB_texture_storage(load);
	load_GL_ARB_copy_image(load);
	load_GL_SGIS_pixel_texture(load);
	load_GL_SGIX_instruments(load);
	load_GL_ARB_shader_storage_buffer_object(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_ARB_base_instance(load);
	load_GL_ARB_ES3_1_compatibility(load);
	load_GL_EXT_texture_integer(load);
	load_GL_ARB_texture_multisample(load);
	load_GL_AMD_gpu_shader_int64(load);
	load_GL_AMD_vertex_shader_tessellator(load);
	load_GL_ARB_invalidate_subdata(load);
	load_GL_EXT_index_material(load);
	load_GL_INTEL_parallel_arrays(load);
	load_GL_ATI_draw_buffers(load);
	load_GL_SGIX_pixel_texture(load);
	load_GL_ARB_timer_query(load);
	load_GL_NV_parameter_buffer_object(load);
	load_GL_ARB_direct_state_access(load);
	load_GL_ARB_uniform_buffer_object(load);
	load_GL_NV_transform_feedback2(load);
	load_GL_EXT_blend_color(load);
	load_GL_EXT_histogram(load);
	load_GL_EXT_polygon_offset(load);
	load_GL_SGIS_point_parameters(load);
	load_GL_EXT_direct_state_access(load);
	load_GL_AMD_sample_positions(load);
	load_GL_NV_vertex_program(load);
	load_GL_EXT_vertex_shader(load);
	load_GL_EXT_blend_func_separate(load);
	load_GL_APPLE_fence(load);
	load_GL_OES_byte_coordinates(load);
	load_GL_ARB_transpose_matrix(load);
	load_GL_ARB_provoking_vertex(load);
	load_GL_EXT_fog_coord(load);
	load_GL_EXT_vertex_array(load);
	load_GL_EXT_blend_equation_separate(load);
	load_GL_NV_framebuffer_mixed_samples(load);
	load_GL_NVX_conditional_render(load);
	load_GL_ARB_multi_draw_indirect(load);
	load_GL_EXT_raster_multisample(load);
	load_GL_NV_copy_image(load);
	load_GL_ARB_transform_feedback2(load);
	load_GL_ARB_transform_feedback3(load);
	load_GL_EXT_debug_marker(load);
	load_GL_EXT_pixel_transform(load);
	load_GL_ATI_fragment_shader(load);
	load_GL_ARB_vertex_array_object(load);
	load_GL_SUN_triangle_list(load);
	load_GL_ARB_transform_feedback_instanced(load);
	load_GL_SGIX_async(load);
	load_GL_INTEL_performance_query(load);
	load_GL_NV_gpu_shader5(load);
	load_GL_NV_bindless_multi_draw_indirect_count(load);
	load_GL_ARB_ES2_compatibility(load);
	load_GL_ARB_indirect_parameters(load);
	load_GL_NV_half_float(load);
	load_GL_EXT_coordinate_frame(load);
	load_GL_EXT_polygon_offset_clamp(load);
	load_GL_EXT_compiled_vertex_array(load);
	load_GL_NV_depth_buffer_float(load);
	load_GL_NV_occlusion_query(load);
	load_GL_APPLE_flush_buffer_range(load);
	load_GL_ARB_imaging(load);
	load_GL_ARB_draw_buffers_blend(load);
	load_GL_ARB_clear_buffer_object(load);
	load_GL_ARB_multisample(load);
	load_GL_EXT_debug_label(load);
	load_GL_ARB_sample_shading(load);
	load_GL_NV_internalformat_sample_query(load);
	load_GL_INTEL_map_texture(load);
	load_GL_ARB_compute_shader(load);
	load_GL_IBM_vertex_array_lists(load);
	load_GL_ARB_color_buffer_float(load);
	load_GL_ARB_bindless_texture(load);
	load_GL_ARB_window_pos(load);
	load_GL_ARB_internalformat_query(load);
	load_GL_EXT_shader_image_load_store(load);
	load_GL_EXT_copy_texture(load);
	load_GL_NV_register_combiners2(load);
	load_GL_NV_draw_texture(load);
	load_GL_EXT_draw_instanced(load);
	load_GL_ARB_viewport_array(load);
	load_GL_ARB_separate_shader_objects(load);
	load_GL_EXT_depth_bounds_test(load);
	load_GL_HP_image_transform(load);
	load_GL_NV_video_capture(load);
	load_GL_ARB_sampler_objects(load);
	load_GL_ARB_matrix_palette(load);
	load_GL_SGIS_texture_color_mask(load);
	load_GL_ARB_texture_compression(load);
	load_GL_ARB_shader_subroutine(load);
	load_GL_ARB_texture_storage_multisample(load);
	load_GL_EXT_vertex_attrib_64bit(load);
	load_GL_OES_query_matrix(load);
	load_GL_MESA_window_pos(load);
	load_GL_ARB_copy_buffer(load);
	load_GL_APPLE_object_purgeable(load);
	load_GL_ARB_occlusion_query(load);
	load_GL_SGI_color_table(load);
	load_GL_EXT_gpu_shader4(load);
	load_GL_NV_geometry_program4(load);
	load_GL_AMD_debug_output(load);
	load_GL_ARB_multitexture(load);
	load_GL_SGIX_polynomial_ffd(load);
	load_GL_EXT_provoking_vertex(load);
	load_GL_ARB_point_parameters(load);
	load_GL_ARB_shader_image_load_store(load);
	load_GL_ARB_texture_barrier(load);
	load_GL_NV_bindless_multi_draw_indirect(load);
	load_GL_EXT_transform_feedback(load);
	load_GL_NV_gpu_program4(load);
	load_GL_NV_gpu_program5(load);
	load_GL_ARB_geometry_shader4(load);
	load_GL_NV_conservative_raster(load);
	load_GL_SGIX_sprite(load);
	load_GL_ARB_get_program_binary(load);
	load_GL_AMD_occlusion_query_event(load);
	load_GL_SGIS_multisample(load);
	load_GL_EXT_framebuffer_object(load);
	load_GL_APPLE_vertex_array_range(load);
	load_GL_NV_register_combiners(load);
	load_GL_ARB_draw_buffers(load);
	load_GL_ARB_debug_output(load);
	load_GL_EXT_cull_vertex(load);
	load_GL_IBM_multimode_draw_arrays(load);
	load_GL_APPLE_vertex_array_object(load);
	load_GL_SGIS_detail_texture(load);
	load_GL_ARB_draw_instanced(load);
	load_GL_ARB_shading_language_include(load);
	load_GL_INGR_blend_func_separate(load);
	load_GL_NV_path_rendering(load);
	load_GL_ATI_vertex_streams(load);
	load_GL_NV_vdpau_interop(load);
	load_GL_ARB_internalformat_query2(load);
	load_GL_SUN_vertex(load);
	load_GL_SGIX_igloo_interface(load);
	load_GL_ARB_draw_indirect(load);
	load_GL_NV_vertex_program4(load);
	load_GL_SGIS_fog_function(load);
	load_GL_EXT_x11_sync_object(load);
	load_GL_ARB_sync(load);
	load_GL_NV_sample_locations(load);
	load_GL_ARB_compute_variable_group_size(load);
	load_GL_OES_fixed_point(load);
	load_GL_EXT_framebuffer_multisample(load);
	load_GL_SGIS_texture4D(load);
	load_GL_EXT_texture3D(load);
	load_GL_EXT_multisample(load);
	load_GL_EXT_secondary_color(load);
	load_GL_ATI_vertex_array_object(load);
	load_GL_ARB_sparse_texture(load);
	load_GL_ARB_sparse_buffer(load);
	load_GL_EXT_draw_range_elements(load);
	load_GL_NV_fragment_coverage_to_color(load);
	load_GL_NV_fence(load);
	load_GL_NV_sample_locations(load);
	load_GL_OVR_multiview(load);
	load_GL_KHR_robustness(load);
	load_GL_NV_conservative_raster(load);
	load_GL_NV_framebuffer_mixed_samples(load);
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_EXT_raster_multisample(load);
	load_GL_EXT_debug_marker(load);
	load_GL_INTEL_performance_query(load);
	load_GL_KHR_debug(load);
	load_GL_NV_bindless_texture(load);
	load_GL_KHR_blend_equation_advanced(load);
	load_GL_EXT_separate_shader_objects(load);
	load_GL_EXT_texture_filter_minmax(load);
	load_GL_NV_path_rendering(load);
	load_GL_NV_blend_equation_advanced(load);
	load_GL_EXT_debug_label(load);
	load_GL_NV_conditional_render(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_NV_internalformat_sample_query(load);
	load_GL_AMD_performance_monitor(load);
	load_GL_EXT_draw_instanced(load);
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_OES_single_precision(load);
	load_GL_NV_fence(load);
	load_GL_OES_fixed_point(load);
	load_GL_OES_query_matrix(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_OES_byte_coordinates(load);
	return GLVersion.major != 0 || GLVersion.minor != 0;
}

private:

void find_coreGL() {

    // Thank you @elmindreda
    // https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
    // https://github.com/glfw/glfw/blob/master/src/context.c#L36
    int i;
    const(char)* glversion;
    const(char)*[] prefixes = [
        "OpenGL ES-CM ".ptr,
        "OpenGL ES-CL ".ptr,
        "OpenGL ES ".ptr,
    ];

    glversion = cast(const(char)*)glGetString(GL_VERSION);
    if (glversion is null) return;

    foreach(prefix; prefixes) {
        size_t length = strlen(prefix);
        if (strncmp(glversion, prefix, length) == 0) {
            glversion += length;
            break;
        }
    }

    int major = glversion[0] - '0';
    int minor = glversion[2] - '0';
    GLVersion.major = major; GLVersion.minor = minor;
	GL_VERSION_1_0 = (major == 1 && minor >= 0) || major > 1;
	GL_VERSION_1_1 = (major == 1 && minor >= 1) || major > 1;
	GL_VERSION_1_2 = (major == 1 && minor >= 2) || major > 1;
	GL_VERSION_1_3 = (major == 1 && minor >= 3) || major > 1;
	GL_VERSION_1_4 = (major == 1 && minor >= 4) || major > 1;
	GL_VERSION_1_5 = (major == 1 && minor >= 5) || major > 1;
	GL_VERSION_2_0 = (major == 2 && minor >= 0) || major > 2;
	GL_VERSION_2_1 = (major == 2 && minor >= 1) || major > 2;
	GL_VERSION_3_0 = (major == 3 && minor >= 0) || major > 3;
	GL_VERSION_3_1 = (major == 3 && minor >= 1) || major > 3;
	GL_VERSION_3_2 = (major == 3 && minor >= 2) || major > 3;
	GL_VERSION_3_3 = (major == 3 && minor >= 3) || major > 3;
	GL_VERSION_4_0 = (major == 4 && minor >= 0) || major > 4;
	GL_VERSION_4_1 = (major == 4 && minor >= 1) || major > 4;
	GL_VERSION_4_2 = (major == 4 && minor >= 2) || major > 4;
	GL_VERSION_4_3 = (major == 4 && minor >= 3) || major > 4;
	GL_VERSION_4_4 = (major == 4 && minor >= 4) || major > 4;
	GL_VERSION_4_5 = (major == 4 && minor >= 5) || major > 4;
	return;
}

void find_extensionsGL() {
	GL_SGIX_pixel_tiles = has_ext("GL_SGIX_pixel_tiles");
	GL_EXT_post_depth_coverage = has_ext("GL_EXT_post_depth_coverage");
	GL_APPLE_element_array = has_ext("GL_APPLE_element_array");
	GL_AMD_multi_draw_indirect = has_ext("GL_AMD_multi_draw_indirect");
	GL_EXT_blend_subtract = has_ext("GL_EXT_blend_subtract");
	GL_SGIX_tag_sample_buffer = has_ext("GL_SGIX_tag_sample_buffer");
	GL_NV_point_sprite = has_ext("GL_NV_point_sprite");
	GL_IBM_texture_mirrored_repeat = has_ext("GL_IBM_texture_mirrored_repeat");
	GL_APPLE_transform_hint = has_ext("GL_APPLE_transform_hint");
	GL_ATI_separate_stencil = has_ext("GL_ATI_separate_stencil");
	GL_NV_shader_atomic_int64 = has_ext("GL_NV_shader_atomic_int64");
	GL_NV_vertex_program2_option = has_ext("GL_NV_vertex_program2_option");
	GL_EXT_texture_buffer_object = has_ext("GL_EXT_texture_buffer_object");
	GL_ARB_vertex_blend = has_ext("GL_ARB_vertex_blend");
	GL_OVR_multiview = has_ext("GL_OVR_multiview");
	GL_NV_vertex_program2 = has_ext("GL_NV_vertex_program2");
	GL_ARB_program_interface_query = has_ext("GL_ARB_program_interface_query");
	GL_EXT_misc_attribute = has_ext("GL_EXT_misc_attribute");
	GL_NV_multisample_coverage = has_ext("GL_NV_multisample_coverage");
	GL_ARB_shading_language_packing = has_ext("GL_ARB_shading_language_packing");
	GL_EXT_texture_cube_map = has_ext("GL_EXT_texture_cube_map");
	GL_NV_viewport_array2 = has_ext("GL_NV_viewport_array2");
	GL_ARB_texture_stencil8 = has_ext("GL_ARB_texture_stencil8");
	GL_EXT_index_func = has_ext("GL_EXT_index_func");
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_NV_depth_clamp = has_ext("GL_NV_depth_clamp");
	GL_NV_shader_buffer_load = has_ext("GL_NV_shader_buffer_load");
	GL_EXT_color_subtable = has_ext("GL_EXT_color_subtable");
	GL_SUNX_constant_data = has_ext("GL_SUNX_constant_data");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_ARB_shader_atomic_counters = has_ext("GL_ARB_shader_atomic_counters");
	GL_ARB_arrays_of_arrays = has_ext("GL_ARB_arrays_of_arrays");
	GL_NV_conditional_render = has_ext("GL_NV_conditional_render");
	GL_EXT_texture_env_combine = has_ext("GL_EXT_texture_env_combine");
	GL_NV_fog_distance = has_ext("GL_NV_fog_distance");
	GL_SGIX_async_histogram = has_ext("GL_SGIX_async_histogram");
	GL_MESA_resize_buffers = has_ext("GL_MESA_resize_buffers");
	GL_NV_light_max_exponent = has_ext("GL_NV_light_max_exponent");
	GL_NV_texture_env_combine4 = has_ext("GL_NV_texture_env_combine4");
	GL_ARB_texture_view = has_ext("GL_ARB_texture_view");
	GL_ARB_texture_env_combine = has_ext("GL_ARB_texture_env_combine");
	GL_ARB_map_buffer_range = has_ext("GL_ARB_map_buffer_range");
	GL_EXT_convolution = has_ext("GL_EXT_convolution");
	GL_NV_compute_program5 = has_ext("GL_NV_compute_program5");
	GL_NV_vertex_attrib_integer_64bit = has_ext("GL_NV_vertex_attrib_integer_64bit");
	GL_EXT_paletted_texture = has_ext("GL_EXT_paletted_texture");
	GL_ARB_texture_buffer_object = has_ext("GL_ARB_texture_buffer_object");
	GL_ATI_pn_triangles = has_ext("GL_ATI_pn_triangles");
	GL_SGIX_resample = has_ext("GL_SGIX_resample");
	GL_SGIX_flush_raster = has_ext("GL_SGIX_flush_raster");
	GL_EXT_light_texture = has_ext("GL_EXT_light_texture");
	GL_ARB_point_sprite = has_ext("GL_ARB_point_sprite");
	GL_ARB_half_float_pixel = has_ext("GL_ARB_half_float_pixel");
	GL_NV_tessellation_program5 = has_ext("GL_NV_tessellation_program5");
	GL_REND_screen_coordinates = has_ext("GL_REND_screen_coordinates");
	GL_EXT_shared_texture_palette = has_ext("GL_EXT_shared_texture_palette");
	GL_EXT_packed_float = has_ext("GL_EXT_packed_float");
	GL_OML_subsample = has_ext("GL_OML_subsample");
	GL_SGIX_vertex_preclip = has_ext("GL_SGIX_vertex_preclip");
	GL_SGIX_texture_scale_bias = has_ext("GL_SGIX_texture_scale_bias");
	GL_AMD_draw_buffers_blend = has_ext("GL_AMD_draw_buffers_blend");
	GL_APPLE_texture_range = has_ext("GL_APPLE_texture_range");
	GL_EXT_texture_array = has_ext("GL_EXT_texture_array");
	GL_NV_texture_barrier = has_ext("GL_NV_texture_barrier");
	GL_ARB_texture_query_levels = has_ext("GL_ARB_texture_query_levels");
	GL_NV_texgen_emboss = has_ext("GL_NV_texgen_emboss");
	GL_EXT_texture_swizzle = has_ext("GL_EXT_texture_swizzle");
	GL_ARB_texture_rg = has_ext("GL_ARB_texture_rg");
	GL_ARB_vertex_type_2_10_10_10_rev = has_ext("GL_ARB_vertex_type_2_10_10_10_rev");
	GL_ARB_fragment_shader = has_ext("GL_ARB_fragment_shader");
	GL_3DFX_tbuffer = has_ext("GL_3DFX_tbuffer");
	GL_GREMEDY_frame_terminator = has_ext("GL_GREMEDY_frame_terminator");
	GL_ARB_blend_func_extended = has_ext("GL_ARB_blend_func_extended");
	GL_EXT_separate_shader_objects = has_ext("GL_EXT_separate_shader_objects");
	GL_NV_texture_multisample = has_ext("GL_NV_texture_multisample");
	GL_ARB_shader_objects = has_ext("GL_ARB_shader_objects");
	GL_ARB_framebuffer_object = has_ext("GL_ARB_framebuffer_object");
	GL_ATI_envmap_bumpmap = has_ext("GL_ATI_envmap_bumpmap");
	GL_ARB_robust_buffer_access_behavior = has_ext("GL_ARB_robust_buffer_access_behavior");
	GL_ARB_shader_stencil_export = has_ext("GL_ARB_shader_stencil_export");
	GL_NV_texture_rectangle = has_ext("GL_NV_texture_rectangle");
	GL_ARB_enhanced_layouts = has_ext("GL_ARB_enhanced_layouts");
	GL_ARB_texture_rectangle = has_ext("GL_ARB_texture_rectangle");
	GL_SGI_texture_color_table = has_ext("GL_SGI_texture_color_table");
	GL_ATI_map_object_buffer = has_ext("GL_ATI_map_object_buffer");
	GL_ARB_robustness = has_ext("GL_ARB_robustness");
	GL_NV_pixel_data_range = has_ext("GL_NV_pixel_data_range");
	GL_EXT_framebuffer_blit = has_ext("GL_EXT_framebuffer_blit");
	GL_ARB_gpu_shader_fp64 = has_ext("GL_ARB_gpu_shader_fp64");
	GL_NV_command_list = has_ext("GL_NV_command_list");
	GL_SGIX_depth_texture = has_ext("GL_SGIX_depth_texture");
	GL_EXT_vertex_weighting = has_ext("GL_EXT_vertex_weighting");
	GL_GREMEDY_string_marker = has_ext("GL_GREMEDY_string_marker");
	GL_ARB_texture_compression_bptc = has_ext("GL_ARB_texture_compression_bptc");
	GL_EXT_subtexture = has_ext("GL_EXT_subtexture");
	GL_EXT_pixel_transform_color_table = has_ext("GL_EXT_pixel_transform_color_table");
	GL_EXT_texture_compression_rgtc = has_ext("GL_EXT_texture_compression_rgtc");
	GL_SGIX_depth_pass_instrument = has_ext("GL_SGIX_depth_pass_instrument");
	GL_EXT_gpu_program_parameters = has_ext("GL_EXT_gpu_program_parameters");
	GL_NV_evaluators = has_ext("GL_NV_evaluators");
	GL_SGIS_texture_filter4 = has_ext("GL_SGIS_texture_filter4");
	GL_AMD_performance_monitor = has_ext("GL_AMD_performance_monitor");
	GL_NV_geometry_shader4 = has_ext("GL_NV_geometry_shader4");
	GL_EXT_stencil_clear_tag = has_ext("GL_EXT_stencil_clear_tag");
	GL_NV_vertex_program1_1 = has_ext("GL_NV_vertex_program1_1");
	GL_NV_present_video = has_ext("GL_NV_present_video");
	GL_ARB_texture_compression_rgtc = has_ext("GL_ARB_texture_compression_rgtc");
	GL_HP_convolution_border_modes = has_ext("GL_HP_convolution_border_modes");
	GL_EXT_shader_integer_mix = has_ext("GL_EXT_shader_integer_mix");
	GL_SGIX_framezoom = has_ext("GL_SGIX_framezoom");
	GL_ARB_stencil_texturing = has_ext("GL_ARB_stencil_texturing");
	GL_NV_shader_atomic_fp16_vector = has_ext("GL_NV_shader_atomic_fp16_vector");
	GL_SGIX_fog_offset = has_ext("GL_SGIX_fog_offset");
	GL_ARB_draw_elements_base_vertex = has_ext("GL_ARB_draw_elements_base_vertex");
	GL_INGR_interlace_read = has_ext("GL_INGR_interlace_read");
	GL_NV_transform_feedback = has_ext("GL_NV_transform_feedback");
	GL_NV_fragment_program = has_ext("GL_NV_fragment_program");
	GL_AMD_stencil_operation_extended = has_ext("GL_AMD_stencil_operation_extended");
	GL_ARB_seamless_cubemap_per_texture = has_ext("GL_ARB_seamless_cubemap_per_texture");
	GL_ARB_instanced_arrays = has_ext("GL_ARB_instanced_arrays");
	GL_ARB_get_texture_sub_image = has_ext("GL_ARB_get_texture_sub_image");
	GL_NV_vertex_array_range2 = has_ext("GL_NV_vertex_array_range2");
	GL_KHR_robustness = has_ext("GL_KHR_robustness");
	GL_AMD_sparse_texture = has_ext("GL_AMD_sparse_texture");
	GL_ARB_clip_control = has_ext("GL_ARB_clip_control");
	GL_NV_fragment_coverage_to_color = has_ext("GL_NV_fragment_coverage_to_color");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_ARB_texture_buffer_range = has_ext("GL_ARB_texture_buffer_range");
	GL_SUN_mesh_array = has_ext("GL_SUN_mesh_array");
	GL_ARB_vertex_attrib_binding = has_ext("GL_ARB_vertex_attrib_binding");
	GL_ARB_framebuffer_no_attachments = has_ext("GL_ARB_framebuffer_no_attachments");
	GL_ARB_cl_event = has_ext("GL_ARB_cl_event");
	GL_ARB_derivative_control = has_ext("GL_ARB_derivative_control");
	GL_NV_packed_depth_stencil = has_ext("GL_NV_packed_depth_stencil");
	GL_OES_single_precision = has_ext("GL_OES_single_precision");
	GL_NV_primitive_restart = has_ext("GL_NV_primitive_restart");
	GL_SUN_global_alpha = has_ext("GL_SUN_global_alpha");
	GL_EXT_texture_object = has_ext("GL_EXT_texture_object");
	GL_AMD_name_gen_delete = has_ext("GL_AMD_name_gen_delete");
	GL_NV_texture_compression_vtc = has_ext("GL_NV_texture_compression_vtc");
	GL_NV_sample_mask_override_coverage = has_ext("GL_NV_sample_mask_override_coverage");
	GL_NV_texture_shader3 = has_ext("GL_NV_texture_shader3");
	GL_NV_texture_shader2 = has_ext("GL_NV_texture_shader2");
	GL_EXT_texture = has_ext("GL_EXT_texture");
	GL_ARB_buffer_storage = has_ext("GL_ARB_buffer_storage");
	GL_AMD_shader_atomic_counter_ops = has_ext("GL_AMD_shader_atomic_counter_ops");
	GL_APPLE_vertex_program_evaluators = has_ext("GL_APPLE_vertex_program_evaluators");
	GL_ARB_multi_bind = has_ext("GL_ARB_multi_bind");
	GL_ARB_explicit_uniform_location = has_ext("GL_ARB_explicit_uniform_location");
	GL_ARB_depth_buffer_float = has_ext("GL_ARB_depth_buffer_float");
	GL_NV_path_rendering_shared_edge = has_ext("GL_NV_path_rendering_shared_edge");
	GL_SGIX_shadow_ambient = has_ext("GL_SGIX_shadow_ambient");
	GL_ARB_texture_cube_map = has_ext("GL_ARB_texture_cube_map");
	GL_AMD_vertex_shader_viewport_index = has_ext("GL_AMD_vertex_shader_viewport_index");
	GL_SGIX_list_priority = has_ext("GL_SGIX_list_priority");
	GL_NV_vertex_buffer_unified_memory = has_ext("GL_NV_vertex_buffer_unified_memory");
	GL_NV_uniform_buffer_unified_memory = has_ext("GL_NV_uniform_buffer_unified_memory");
	GL_ARB_clear_texture = has_ext("GL_ARB_clear_texture");
	GL_ATI_texture_env_combine3 = has_ext("GL_ATI_texture_env_combine3");
	GL_ARB_map_buffer_alignment = has_ext("GL_ARB_map_buffer_alignment");
	GL_NV_blend_equation_advanced = has_ext("GL_NV_blend_equation_advanced");
	GL_SGIS_sharpen_texture = has_ext("GL_SGIS_sharpen_texture");
	GL_KHR_robust_buffer_access_behavior = has_ext("GL_KHR_robust_buffer_access_behavior");
	GL_ARB_pipeline_statistics_query = has_ext("GL_ARB_pipeline_statistics_query");
	GL_ARB_vertex_program = has_ext("GL_ARB_vertex_program");
	GL_ARB_texture_rgb10_a2ui = has_ext("GL_ARB_texture_rgb10_a2ui");
	GL_OML_interlace = has_ext("GL_OML_interlace");
	GL_ATI_pixel_format_float = has_ext("GL_ATI_pixel_format_float");
	GL_NV_geometry_shader_passthrough = has_ext("GL_NV_geometry_shader_passthrough");
	GL_ARB_vertex_buffer_object = has_ext("GL_ARB_vertex_buffer_object");
	GL_EXT_shadow_funcs = has_ext("GL_EXT_shadow_funcs");
	GL_ATI_text_fragment_shader = has_ext("GL_ATI_text_fragment_shader");
	GL_NV_vertex_array_range = has_ext("GL_NV_vertex_array_range");
	GL_SGIX_fragment_lighting = has_ext("GL_SGIX_fragment_lighting");
	GL_NV_texture_expand_normal = has_ext("GL_NV_texture_expand_normal");
	GL_NV_framebuffer_multisample_coverage = has_ext("GL_NV_framebuffer_multisample_coverage");
	GL_EXT_timer_query = has_ext("GL_EXT_timer_query");
	GL_EXT_vertex_array_bgra = has_ext("GL_EXT_vertex_array_bgra");
	GL_NV_bindless_texture = has_ext("GL_NV_bindless_texture");
	GL_KHR_debug = has_ext("GL_KHR_debug");
	GL_SGIS_texture_border_clamp = has_ext("GL_SGIS_texture_border_clamp");
	GL_ATI_vertex_attrib_array_object = has_ext("GL_ATI_vertex_attrib_array_object");
	GL_SGIX_clipmap = has_ext("GL_SGIX_clipmap");
	GL_EXT_geometry_shader4 = has_ext("GL_EXT_geometry_shader4");
	GL_ARB_shader_texture_image_samples = has_ext("GL_ARB_shader_texture_image_samples");
	GL_MESA_ycbcr_texture = has_ext("GL_MESA_ycbcr_texture");
	GL_MESAX_texture_stack = has_ext("GL_MESAX_texture_stack");
	GL_AMD_seamless_cubemap_per_texture = has_ext("GL_AMD_seamless_cubemap_per_texture");
	GL_EXT_bindable_uniform = has_ext("GL_EXT_bindable_uniform");
	GL_KHR_texture_compression_astc_hdr = has_ext("GL_KHR_texture_compression_astc_hdr");
	GL_KHR_blend_equation_advanced = has_ext("GL_KHR_blend_equation_advanced");
	GL_ARB_fragment_program_shadow = has_ext("GL_ARB_fragment_program_shadow");
	GL_ATI_element_array = has_ext("GL_ATI_element_array");
	GL_AMD_texture_texture4 = has_ext("GL_AMD_texture_texture4");
	GL_SGIX_reference_plane = has_ext("GL_SGIX_reference_plane");
	GL_EXT_stencil_two_side = has_ext("GL_EXT_stencil_two_side");
	GL_ARB_transform_feedback_overflow_query = has_ext("GL_ARB_transform_feedback_overflow_query");
	GL_SGIX_texture_lod_bias = has_ext("GL_SGIX_texture_lod_bias");
	GL_NV_explicit_multisample = has_ext("GL_NV_explicit_multisample");
	GL_IBM_static_data = has_ext("GL_IBM_static_data");
	GL_EXT_clip_volume_hint = has_ext("GL_EXT_clip_volume_hint");
	GL_EXT_texture_perturb_normal = has_ext("GL_EXT_texture_perturb_normal");
	GL_NV_fragment_program2 = has_ext("GL_NV_fragment_program2");
	GL_NV_fragment_program4 = has_ext("GL_NV_fragment_program4");
	GL_EXT_point_parameters = has_ext("GL_EXT_point_parameters");
	GL_PGI_misc_hints = has_ext("GL_PGI_misc_hints");
	GL_SGIX_subsample = has_ext("GL_SGIX_subsample");
	GL_AMD_shader_stencil_export = has_ext("GL_AMD_shader_stencil_export");
	GL_ARB_shader_texture_lod = has_ext("GL_ARB_shader_texture_lod");
	GL_ARB_vertex_shader = has_ext("GL_ARB_vertex_shader");
	GL_ARB_depth_clamp = has_ext("GL_ARB_depth_clamp");
	GL_SGIS_texture_select = has_ext("GL_SGIS_texture_select");
	GL_NV_texture_shader = has_ext("GL_NV_texture_shader");
	GL_ARB_tessellation_shader = has_ext("GL_ARB_tessellation_shader");
	GL_EXT_draw_buffers2 = has_ext("GL_EXT_draw_buffers2");
	GL_ARB_vertex_attrib_64bit = has_ext("GL_ARB_vertex_attrib_64bit");
	GL_EXT_texture_filter_minmax = has_ext("GL_EXT_texture_filter_minmax");
	GL_WIN_specular_fog = has_ext("GL_WIN_specular_fog");
	GL_AMD_interleaved_elements = has_ext("GL_AMD_interleaved_elements");
	GL_ARB_fragment_program = has_ext("GL_ARB_fragment_program");
	GL_OML_resample = has_ext("GL_OML_resample");
	GL_APPLE_ycbcr_422 = has_ext("GL_APPLE_ycbcr_422");
	GL_SGIX_texture_add_env = has_ext("GL_SGIX_texture_add_env");
	GL_ARB_shadow_ambient = has_ext("GL_ARB_shadow_ambient");
	GL_ARB_texture_storage = has_ext("GL_ARB_texture_storage");
	GL_EXT_pixel_buffer_object = has_ext("GL_EXT_pixel_buffer_object");
	GL_ARB_copy_image = has_ext("GL_ARB_copy_image");
	GL_SGIS_pixel_texture = has_ext("GL_SGIS_pixel_texture");
	GL_SGIS_generate_mipmap = has_ext("GL_SGIS_generate_mipmap");
	GL_SGIX_instruments = has_ext("GL_SGIX_instruments");
	GL_HP_texture_lighting = has_ext("GL_HP_texture_lighting");
	GL_ARB_shader_storage_buffer_object = has_ext("GL_ARB_shader_storage_buffer_object");
	GL_EXT_sparse_texture2 = has_ext("GL_EXT_sparse_texture2");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_MESA_pack_invert = has_ext("GL_MESA_pack_invert");
	GL_ARB_base_instance = has_ext("GL_ARB_base_instance");
	GL_SGIX_convolution_accuracy = has_ext("GL_SGIX_convolution_accuracy");
	GL_PGI_vertex_hints = has_ext("GL_PGI_vertex_hints");
	GL_AMD_transform_feedback4 = has_ext("GL_AMD_transform_feedback4");
	GL_ARB_ES3_1_compatibility = has_ext("GL_ARB_ES3_1_compatibility");
	GL_EXT_texture_integer = has_ext("GL_EXT_texture_integer");
	GL_ARB_texture_multisample = has_ext("GL_ARB_texture_multisample");
	GL_AMD_gpu_shader_int64 = has_ext("GL_AMD_gpu_shader_int64");
	GL_S3_s3tc = has_ext("GL_S3_s3tc");
	GL_ARB_query_buffer_object = has_ext("GL_ARB_query_buffer_object");
	GL_AMD_vertex_shader_tessellator = has_ext("GL_AMD_vertex_shader_tessellator");
	GL_ARB_invalidate_subdata = has_ext("GL_ARB_invalidate_subdata");
	GL_EXT_index_material = has_ext("GL_EXT_index_material");
	GL_NV_blend_equation_advanced_coherent = has_ext("GL_NV_blend_equation_advanced_coherent");
	GL_INTEL_parallel_arrays = has_ext("GL_INTEL_parallel_arrays");
	GL_ATI_draw_buffers = has_ext("GL_ATI_draw_buffers");
	GL_EXT_cmyka = has_ext("GL_EXT_cmyka");
	GL_SGIX_pixel_texture = has_ext("GL_SGIX_pixel_texture");
	GL_APPLE_specular_vector = has_ext("GL_APPLE_specular_vector");
	GL_ARB_compatibility = has_ext("GL_ARB_compatibility");
	GL_ARB_timer_query = has_ext("GL_ARB_timer_query");
	GL_SGIX_interlace = has_ext("GL_SGIX_interlace");
	GL_NV_parameter_buffer_object = has_ext("GL_NV_parameter_buffer_object");
	GL_AMD_shader_trinary_minmax = has_ext("GL_AMD_shader_trinary_minmax");
	GL_ARB_direct_state_access = has_ext("GL_ARB_direct_state_access");
	GL_EXT_rescale_normal = has_ext("GL_EXT_rescale_normal");
	GL_ARB_pixel_buffer_object = has_ext("GL_ARB_pixel_buffer_object");
	GL_ARB_uniform_buffer_object = has_ext("GL_ARB_uniform_buffer_object");
	GL_ARB_vertex_type_10f_11f_11f_rev = has_ext("GL_ARB_vertex_type_10f_11f_11f_rev");
	GL_ARB_texture_swizzle = has_ext("GL_ARB_texture_swizzle");
	GL_NV_transform_feedback2 = has_ext("GL_NV_transform_feedback2");
	GL_SGIX_async_pixel = has_ext("GL_SGIX_async_pixel");
	GL_NV_fragment_program_option = has_ext("GL_NV_fragment_program_option");
	GL_ARB_explicit_attrib_location = has_ext("GL_ARB_explicit_attrib_location");
	GL_EXT_blend_color = has_ext("GL_EXT_blend_color");
	GL_NV_shader_thread_group = has_ext("GL_NV_shader_thread_group");
	GL_EXT_stencil_wrap = has_ext("GL_EXT_stencil_wrap");
	GL_EXT_index_array_formats = has_ext("GL_EXT_index_array_formats");
	GL_OVR_multiview2 = has_ext("GL_OVR_multiview2");
	GL_EXT_histogram = has_ext("GL_EXT_histogram");
	GL_EXT_polygon_offset = has_ext("GL_EXT_polygon_offset");
	GL_SGIS_point_parameters = has_ext("GL_SGIS_point_parameters");
	GL_SGIX_ycrcb = has_ext("GL_SGIX_ycrcb");
	GL_EXT_direct_state_access = has_ext("GL_EXT_direct_state_access");
	GL_ARB_cull_distance = has_ext("GL_ARB_cull_distance");
	GL_AMD_sample_positions = has_ext("GL_AMD_sample_positions");
	GL_NV_vertex_program = has_ext("GL_NV_vertex_program");
	GL_NV_shader_thread_shuffle = has_ext("GL_NV_shader_thread_shuffle");
	GL_ARB_shader_precision = has_ext("GL_ARB_shader_precision");
	GL_EXT_vertex_shader = has_ext("GL_EXT_vertex_shader");
	GL_EXT_blend_func_separate = has_ext("GL_EXT_blend_func_separate");
	GL_APPLE_fence = has_ext("GL_APPLE_fence");
	GL_OES_byte_coordinates = has_ext("GL_OES_byte_coordinates");
	GL_ARB_transpose_matrix = has_ext("GL_ARB_transpose_matrix");
	GL_ARB_provoking_vertex = has_ext("GL_ARB_provoking_vertex");
	GL_EXT_fog_coord = has_ext("GL_EXT_fog_coord");
	GL_EXT_vertex_array = has_ext("GL_EXT_vertex_array");
	GL_ARB_half_float_vertex = has_ext("GL_ARB_half_float_vertex");
	GL_EXT_blend_equation_separate = has_ext("GL_EXT_blend_equation_separate");
	GL_NV_framebuffer_mixed_samples = has_ext("GL_NV_framebuffer_mixed_samples");
	GL_NVX_conditional_render = has_ext("GL_NVX_conditional_render");
	GL_ARB_multi_draw_indirect = has_ext("GL_ARB_multi_draw_indirect");
	GL_EXT_raster_multisample = has_ext("GL_EXT_raster_multisample");
	GL_NV_copy_image = has_ext("GL_NV_copy_image");
	GL_ARB_fragment_layer_viewport = has_ext("GL_ARB_fragment_layer_viewport");
	GL_ARB_transform_feedback2 = has_ext("GL_ARB_transform_feedback2");
	GL_ARB_transform_feedback3 = has_ext("GL_ARB_transform_feedback3");
	GL_SGIX_ycrcba = has_ext("GL_SGIX_ycrcba");
	GL_EXT_debug_marker = has_ext("GL_EXT_debug_marker");
	GL_EXT_bgra = has_ext("GL_EXT_bgra");
	GL_EXT_texture_compression_s3tc = has_ext("GL_EXT_texture_compression_s3tc");
	GL_EXT_pixel_transform = has_ext("GL_EXT_pixel_transform");
	GL_ARB_conservative_depth = has_ext("GL_ARB_conservative_depth");
	GL_ATI_fragment_shader = has_ext("GL_ATI_fragment_shader");
	GL_ARB_vertex_array_object = has_ext("GL_ARB_vertex_array_object");
	GL_SUN_triangle_list = has_ext("GL_SUN_triangle_list");
	GL_EXT_texture_env_add = has_ext("GL_EXT_texture_env_add");
	GL_EXT_packed_depth_stencil = has_ext("GL_EXT_packed_depth_stencil");
	GL_EXT_texture_mirror_clamp = has_ext("GL_EXT_texture_mirror_clamp");
	GL_NV_multisample_filter_hint = has_ext("GL_NV_multisample_filter_hint");
	GL_APPLE_float_pixels = has_ext("GL_APPLE_float_pixels");
	GL_ARB_transform_feedback_instanced = has_ext("GL_ARB_transform_feedback_instanced");
	GL_SGIX_async = has_ext("GL_SGIX_async");
	GL_EXT_texture_compression_latc = has_ext("GL_EXT_texture_compression_latc");
	GL_NV_shader_atomic_float = has_ext("GL_NV_shader_atomic_float");
	GL_ARB_shading_language_100 = has_ext("GL_ARB_shading_language_100");
	GL_INTEL_performance_query = has_ext("GL_INTEL_performance_query");
	GL_ARB_texture_mirror_clamp_to_edge = has_ext("GL_ARB_texture_mirror_clamp_to_edge");
	GL_NV_gpu_shader5 = has_ext("GL_NV_gpu_shader5");
	GL_NV_bindless_multi_draw_indirect_count = has_ext("GL_NV_bindless_multi_draw_indirect_count");
	GL_ARB_ES2_compatibility = has_ext("GL_ARB_ES2_compatibility");
	GL_ARB_indirect_parameters = has_ext("GL_ARB_indirect_parameters");
	GL_NV_half_float = has_ext("GL_NV_half_float");
	GL_EXT_coordinate_frame = has_ext("GL_EXT_coordinate_frame");
	GL_ATI_texture_mirror_once = has_ext("GL_ATI_texture_mirror_once");
	GL_IBM_rasterpos_clip = has_ext("GL_IBM_rasterpos_clip");
	GL_SGIX_shadow = has_ext("GL_SGIX_shadow");
	GL_EXT_polygon_offset_clamp = has_ext("GL_EXT_polygon_offset_clamp");
	GL_NV_deep_texture3D = has_ext("GL_NV_deep_texture3D");
	GL_ARB_shader_draw_parameters = has_ext("GL_ARB_shader_draw_parameters");
	GL_SGIX_calligraphic_fragment = has_ext("GL_SGIX_calligraphic_fragment");
	GL_ARB_shader_bit_encoding = has_ext("GL_ARB_shader_bit_encoding");
	GL_EXT_compiled_vertex_array = has_ext("GL_EXT_compiled_vertex_array");
	GL_NV_depth_buffer_float = has_ext("GL_NV_depth_buffer_float");
	GL_NV_occlusion_query = has_ext("GL_NV_occlusion_query");
	GL_APPLE_flush_buffer_range = has_ext("GL_APPLE_flush_buffer_range");
	GL_ARB_imaging = has_ext("GL_ARB_imaging");
	GL_ARB_draw_buffers_blend = has_ext("GL_ARB_draw_buffers_blend");
	GL_AMD_gcn_shader = has_ext("GL_AMD_gcn_shader");
	GL_AMD_blend_minmax_factor = has_ext("GL_AMD_blend_minmax_factor");
	GL_EXT_texture_sRGB_decode = has_ext("GL_EXT_texture_sRGB_decode");
	GL_ARB_shading_language_420pack = has_ext("GL_ARB_shading_language_420pack");
	GL_ATI_meminfo = has_ext("GL_ATI_meminfo");
	GL_EXT_abgr = has_ext("GL_EXT_abgr");
	GL_AMD_pinned_memory = has_ext("GL_AMD_pinned_memory");
	GL_EXT_texture_snorm = has_ext("GL_EXT_texture_snorm");
	GL_SGIX_texture_coordinate_clamp = has_ext("GL_SGIX_texture_coordinate_clamp");
	GL_ARB_clear_buffer_object = has_ext("GL_ARB_clear_buffer_object");
	GL_ARB_multisample = has_ext("GL_ARB_multisample");
	GL_EXT_debug_label = has_ext("GL_EXT_debug_label");
	GL_ARB_sample_shading = has_ext("GL_ARB_sample_shading");
	GL_NV_internalformat_sample_query = has_ext("GL_NV_internalformat_sample_query");
	GL_INTEL_map_texture = has_ext("GL_INTEL_map_texture");
	GL_ARB_texture_env_crossbar = has_ext("GL_ARB_texture_env_crossbar");
	GL_EXT_422_pixels = has_ext("GL_EXT_422_pixels");
	GL_ARB_compute_shader = has_ext("GL_ARB_compute_shader");
	GL_EXT_blend_logic_op = has_ext("GL_EXT_blend_logic_op");
	GL_IBM_cull_vertex = has_ext("GL_IBM_cull_vertex");
	GL_IBM_vertex_array_lists = has_ext("GL_IBM_vertex_array_lists");
	GL_ARB_color_buffer_float = has_ext("GL_ARB_color_buffer_float");
	GL_ARB_bindless_texture = has_ext("GL_ARB_bindless_texture");
	GL_ARB_window_pos = has_ext("GL_ARB_window_pos");
	GL_ARB_internalformat_query = has_ext("GL_ARB_internalformat_query");
	GL_ARB_shadow = has_ext("GL_ARB_shadow");
	GL_ARB_texture_mirrored_repeat = has_ext("GL_ARB_texture_mirrored_repeat");
	GL_EXT_shader_image_load_store = has_ext("GL_EXT_shader_image_load_store");
	GL_EXT_copy_texture = has_ext("GL_EXT_copy_texture");
	GL_NV_register_combiners2 = has_ext("GL_NV_register_combiners2");
	GL_SGIX_ycrcb_subsample = has_ext("GL_SGIX_ycrcb_subsample");
	GL_SGIX_ir_instrument1 = has_ext("GL_SGIX_ir_instrument1");
	GL_NV_draw_texture = has_ext("GL_NV_draw_texture");
	GL_EXT_texture_shared_exponent = has_ext("GL_EXT_texture_shared_exponent");
	GL_EXT_draw_instanced = has_ext("GL_EXT_draw_instanced");
	GL_NV_copy_depth_to_color = has_ext("GL_NV_copy_depth_to_color");
	GL_ARB_viewport_array = has_ext("GL_ARB_viewport_array");
	GL_ARB_separate_shader_objects = has_ext("GL_ARB_separate_shader_objects");
	GL_EXT_depth_bounds_test = has_ext("GL_EXT_depth_bounds_test");
	GL_HP_image_transform = has_ext("GL_HP_image_transform");
	GL_ARB_texture_env_add = has_ext("GL_ARB_texture_env_add");
	GL_NV_video_capture = has_ext("GL_NV_video_capture");
	GL_ARB_sampler_objects = has_ext("GL_ARB_sampler_objects");
	GL_ARB_matrix_palette = has_ext("GL_ARB_matrix_palette");
	GL_SGIS_texture_color_mask = has_ext("GL_SGIS_texture_color_mask");
	GL_EXT_packed_pixels = has_ext("GL_EXT_packed_pixels");
	GL_ARB_texture_compression = has_ext("GL_ARB_texture_compression");
	GL_APPLE_aux_depth_stencil = has_ext("GL_APPLE_aux_depth_stencil");
	GL_ARB_shader_subroutine = has_ext("GL_ARB_shader_subroutine");
	GL_EXT_framebuffer_sRGB = has_ext("GL_EXT_framebuffer_sRGB");
	GL_ARB_texture_storage_multisample = has_ext("GL_ARB_texture_storage_multisample");
	GL_KHR_blend_equation_advanced_coherent = has_ext("GL_KHR_blend_equation_advanced_coherent");
	GL_EXT_vertex_attrib_64bit = has_ext("GL_EXT_vertex_attrib_64bit");
	GL_ARB_depth_texture = has_ext("GL_ARB_depth_texture");
	GL_NV_shader_buffer_store = has_ext("GL_NV_shader_buffer_store");
	GL_OES_query_matrix = has_ext("GL_OES_query_matrix");
	GL_MESA_window_pos = has_ext("GL_MESA_window_pos");
	GL_NV_fill_rectangle = has_ext("GL_NV_fill_rectangle");
	GL_NV_shader_storage_buffer_object = has_ext("GL_NV_shader_storage_buffer_object");
	GL_ARB_texture_query_lod = has_ext("GL_ARB_texture_query_lod");
	GL_ARB_copy_buffer = has_ext("GL_ARB_copy_buffer");
	GL_ARB_shader_image_size = has_ext("GL_ARB_shader_image_size");
	GL_NV_shader_atomic_counters = has_ext("GL_NV_shader_atomic_counters");
	GL_APPLE_object_purgeable = has_ext("GL_APPLE_object_purgeable");
	GL_ARB_occlusion_query = has_ext("GL_ARB_occlusion_query");
	GL_INGR_color_clamp = has_ext("GL_INGR_color_clamp");
	GL_SGI_color_table = has_ext("GL_SGI_color_table");
	GL_NV_gpu_program5_mem_extended = has_ext("GL_NV_gpu_program5_mem_extended");
	GL_ARB_texture_cube_map_array = has_ext("GL_ARB_texture_cube_map_array");
	GL_SGIX_scalebias_hint = has_ext("GL_SGIX_scalebias_hint");
	GL_EXT_gpu_shader4 = has_ext("GL_EXT_gpu_shader4");
	GL_NV_geometry_program4 = has_ext("GL_NV_geometry_program4");
	GL_EXT_framebuffer_multisample_blit_scaled = has_ext("GL_EXT_framebuffer_multisample_blit_scaled");
	GL_AMD_debug_output = has_ext("GL_AMD_debug_output");
	GL_ARB_texture_border_clamp = has_ext("GL_ARB_texture_border_clamp");
	GL_ARB_fragment_coord_conventions = has_ext("GL_ARB_fragment_coord_conventions");
	GL_ARB_multitexture = has_ext("GL_ARB_multitexture");
	GL_SGIX_polynomial_ffd = has_ext("GL_SGIX_polynomial_ffd");
	GL_EXT_provoking_vertex = has_ext("GL_EXT_provoking_vertex");
	GL_ARB_point_parameters = has_ext("GL_ARB_point_parameters");
	GL_ARB_shader_image_load_store = has_ext("GL_ARB_shader_image_load_store");
	GL_ARB_conditional_render_inverted = has_ext("GL_ARB_conditional_render_inverted");
	GL_HP_occlusion_test = has_ext("GL_HP_occlusion_test");
	GL_ARB_ES3_compatibility = has_ext("GL_ARB_ES3_compatibility");
	GL_ARB_texture_barrier = has_ext("GL_ARB_texture_barrier");
	GL_ARB_texture_buffer_object_rgb32 = has_ext("GL_ARB_texture_buffer_object_rgb32");
	GL_NV_bindless_multi_draw_indirect = has_ext("GL_NV_bindless_multi_draw_indirect");
	GL_SGIX_texture_multi_buffer = has_ext("GL_SGIX_texture_multi_buffer");
	GL_EXT_transform_feedback = has_ext("GL_EXT_transform_feedback");
	GL_KHR_texture_compression_astc_ldr = has_ext("GL_KHR_texture_compression_astc_ldr");
	GL_3DFX_multisample = has_ext("GL_3DFX_multisample");
	GL_INTEL_fragment_shader_ordering = has_ext("GL_INTEL_fragment_shader_ordering");
	GL_ARB_texture_env_dot3 = has_ext("GL_ARB_texture_env_dot3");
	GL_NV_gpu_program4 = has_ext("GL_NV_gpu_program4");
	GL_NV_gpu_program5 = has_ext("GL_NV_gpu_program5");
	GL_NV_float_buffer = has_ext("GL_NV_float_buffer");
	GL_SGIS_texture_edge_clamp = has_ext("GL_SGIS_texture_edge_clamp");
	GL_ARB_framebuffer_sRGB = has_ext("GL_ARB_framebuffer_sRGB");
	GL_SUN_slice_accum = has_ext("GL_SUN_slice_accum");
	GL_EXT_index_texture = has_ext("GL_EXT_index_texture");
	GL_EXT_shader_image_load_formatted = has_ext("GL_EXT_shader_image_load_formatted");
	GL_ARB_geometry_shader4 = has_ext("GL_ARB_geometry_shader4");
	GL_EXT_separate_specular_color = has_ext("GL_EXT_separate_specular_color");
	GL_AMD_depth_clamp_separate = has_ext("GL_AMD_depth_clamp_separate");
	GL_NV_conservative_raster = has_ext("GL_NV_conservative_raster");
	GL_SUN_convolution_border_modes = has_ext("GL_SUN_convolution_border_modes");
	GL_SGIX_sprite = has_ext("GL_SGIX_sprite");
	GL_ARB_get_program_binary = has_ext("GL_ARB_get_program_binary");
	GL_AMD_occlusion_query_event = has_ext("GL_AMD_occlusion_query_event");
	GL_SGIS_multisample = has_ext("GL_SGIS_multisample");
	GL_EXT_framebuffer_object = has_ext("GL_EXT_framebuffer_object");
	GL_ARB_robustness_isolation = has_ext("GL_ARB_robustness_isolation");
	GL_ARB_vertex_array_bgra = has_ext("GL_ARB_vertex_array_bgra");
	GL_APPLE_vertex_array_range = has_ext("GL_APPLE_vertex_array_range");
	GL_AMD_query_buffer_object = has_ext("GL_AMD_query_buffer_object");
	GL_NV_register_combiners = has_ext("GL_NV_register_combiners");
	GL_ARB_draw_buffers = has_ext("GL_ARB_draw_buffers");
	GL_EXT_texture_env_dot3 = has_ext("GL_EXT_texture_env_dot3");
	GL_ARB_debug_output = has_ext("GL_ARB_debug_output");
	GL_SGI_color_matrix = has_ext("GL_SGI_color_matrix");
	GL_EXT_cull_vertex = has_ext("GL_EXT_cull_vertex");
	GL_EXT_texture_sRGB = has_ext("GL_EXT_texture_sRGB");
	GL_APPLE_row_bytes = has_ext("GL_APPLE_row_bytes");
	GL_NV_texgen_reflection = has_ext("GL_NV_texgen_reflection");
	GL_IBM_multimode_draw_arrays = has_ext("GL_IBM_multimode_draw_arrays");
	GL_APPLE_vertex_array_object = has_ext("GL_APPLE_vertex_array_object");
	GL_3DFX_texture_compression_FXT1 = has_ext("GL_3DFX_texture_compression_FXT1");
	GL_NV_fragment_shader_interlock = has_ext("GL_NV_fragment_shader_interlock");
	GL_AMD_conservative_depth = has_ext("GL_AMD_conservative_depth");
	GL_ARB_texture_float = has_ext("GL_ARB_texture_float");
	GL_ARB_compressed_texture_pixel_storage = has_ext("GL_ARB_compressed_texture_pixel_storage");
	GL_SGIS_detail_texture = has_ext("GL_SGIS_detail_texture");
	GL_ARB_draw_instanced = has_ext("GL_ARB_draw_instanced");
	GL_OES_read_format = has_ext("GL_OES_read_format");
	GL_ATI_texture_float = has_ext("GL_ATI_texture_float");
	GL_ARB_texture_gather = has_ext("GL_ARB_texture_gather");
	GL_AMD_vertex_shader_layer = has_ext("GL_AMD_vertex_shader_layer");
	GL_ARB_shading_language_include = has_ext("GL_ARB_shading_language_include");
	GL_APPLE_client_storage = has_ext("GL_APPLE_client_storage");
	GL_WIN_phong_shading = has_ext("GL_WIN_phong_shading");
	GL_INGR_blend_func_separate = has_ext("GL_INGR_blend_func_separate");
	GL_NV_path_rendering = has_ext("GL_NV_path_rendering");
	GL_ATI_vertex_streams = has_ext("GL_ATI_vertex_streams");
	GL_ARB_texture_non_power_of_two = has_ext("GL_ARB_texture_non_power_of_two");
	GL_APPLE_rgb_422 = has_ext("GL_APPLE_rgb_422");
	GL_EXT_texture_lod_bias = has_ext("GL_EXT_texture_lod_bias");
	GL_ARB_seamless_cube_map = has_ext("GL_ARB_seamless_cube_map");
	GL_ARB_shader_group_vote = has_ext("GL_ARB_shader_group_vote");
	GL_NV_vdpau_interop = has_ext("GL_NV_vdpau_interop");
	GL_ARB_occlusion_query2 = has_ext("GL_ARB_occlusion_query2");
	GL_ARB_internalformat_query2 = has_ext("GL_ARB_internalformat_query2");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_SUN_vertex = has_ext("GL_SUN_vertex");
	GL_SGIX_igloo_interface = has_ext("GL_SGIX_igloo_interface");
	GL_SGIS_texture_lod = has_ext("GL_SGIS_texture_lod");
	GL_NV_vertex_program3 = has_ext("GL_NV_vertex_program3");
	GL_ARB_draw_indirect = has_ext("GL_ARB_draw_indirect");
	GL_NV_vertex_program4 = has_ext("GL_NV_vertex_program4");
	GL_AMD_transform_feedback3_lines_triangles = has_ext("GL_AMD_transform_feedback3_lines_triangles");
	GL_SGIS_fog_function = has_ext("GL_SGIS_fog_function");
	GL_EXT_x11_sync_object = has_ext("GL_EXT_x11_sync_object");
	GL_ARB_sync = has_ext("GL_ARB_sync");
	GL_NV_sample_locations = has_ext("GL_NV_sample_locations");
	GL_ARB_compute_variable_group_size = has_ext("GL_ARB_compute_variable_group_size");
	GL_OES_fixed_point = has_ext("GL_OES_fixed_point");
	GL_NV_blend_square = has_ext("GL_NV_blend_square");
	GL_EXT_framebuffer_multisample = has_ext("GL_EXT_framebuffer_multisample");
	GL_ARB_gpu_shader5 = has_ext("GL_ARB_gpu_shader5");
	GL_SGIS_texture4D = has_ext("GL_SGIS_texture4D");
	GL_EXT_texture3D = has_ext("GL_EXT_texture3D");
	GL_EXT_multisample = has_ext("GL_EXT_multisample");
	GL_EXT_secondary_color = has_ext("GL_EXT_secondary_color");
	GL_NV_parameter_buffer_object2 = has_ext("GL_NV_parameter_buffer_object2");
	GL_ATI_vertex_array_object = has_ext("GL_ATI_vertex_array_object");
	GL_NVX_gpu_memory_info = has_ext("GL_NVX_gpu_memory_info");
	GL_ARB_sparse_texture = has_ext("GL_ARB_sparse_texture");
	GL_SGIS_point_line_texgen = has_ext("GL_SGIS_point_line_texgen");
	GL_ARB_sparse_buffer = has_ext("GL_ARB_sparse_buffer");
	GL_EXT_draw_range_elements = has_ext("GL_EXT_draw_range_elements");
	GL_SGIX_blend_alpha_minmax = has_ext("GL_SGIX_blend_alpha_minmax");
	GL_KHR_context_flush_control = has_ext("GL_KHR_context_flush_control");
	GL_KHR_blend_equation_advanced_coherent = has_ext("GL_KHR_blend_equation_advanced_coherent");
	GL_NV_fragment_coverage_to_color = has_ext("GL_NV_fragment_coverage_to_color");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_EXT_texture_compression_s3tc = has_ext("GL_EXT_texture_compression_s3tc");
	GL_NV_sample_locations = has_ext("GL_NV_sample_locations");
	GL_OVR_multiview = has_ext("GL_OVR_multiview");
	GL_NV_fill_rectangle = has_ext("GL_NV_fill_rectangle");
	GL_NV_sample_mask_override_coverage = has_ext("GL_NV_sample_mask_override_coverage");
	GL_NV_viewport_array2 = has_ext("GL_NV_viewport_array2");
	GL_KHR_robustness = has_ext("GL_KHR_robustness");
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_NV_conservative_raster = has_ext("GL_NV_conservative_raster");
	GL_NV_path_rendering_shared_edge = has_ext("GL_NV_path_rendering_shared_edge");
	GL_EXT_shader_integer_mix = has_ext("GL_EXT_shader_integer_mix");
	GL_NV_framebuffer_mixed_samples = has_ext("GL_NV_framebuffer_mixed_samples");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_EXT_raster_multisample = has_ext("GL_EXT_raster_multisample");
	GL_KHR_robust_buffer_access_behavior = has_ext("GL_KHR_robust_buffer_access_behavior");
	GL_KHR_texture_compression_astc_ldr = has_ext("GL_KHR_texture_compression_astc_ldr");
	GL_EXT_debug_marker = has_ext("GL_EXT_debug_marker");
	GL_NV_blend_equation_advanced_coherent = has_ext("GL_NV_blend_equation_advanced_coherent");
	GL_EXT_post_depth_coverage = has_ext("GL_EXT_post_depth_coverage");
	GL_NV_geometry_shader_passthrough = has_ext("GL_NV_geometry_shader_passthrough");
	GL_INTEL_performance_query = has_ext("GL_INTEL_performance_query");
	GL_KHR_debug = has_ext("GL_KHR_debug");
	GL_NV_bindless_texture = has_ext("GL_NV_bindless_texture");
	GL_KHR_texture_compression_astc_hdr = has_ext("GL_KHR_texture_compression_astc_hdr");
	GL_KHR_blend_equation_advanced = has_ext("GL_KHR_blend_equation_advanced");
	GL_NV_fragment_shader_interlock = has_ext("GL_NV_fragment_shader_interlock");
	GL_EXT_separate_shader_objects = has_ext("GL_EXT_separate_shader_objects");
	GL_EXT_texture_filter_minmax = has_ext("GL_EXT_texture_filter_minmax");
	GL_NV_path_rendering = has_ext("GL_NV_path_rendering");
	GL_APPLE_rgb_422 = has_ext("GL_APPLE_rgb_422");
	GL_NV_blend_equation_advanced = has_ext("GL_NV_blend_equation_advanced");
	GL_EXT_debug_label = has_ext("GL_EXT_debug_label");
	GL_NV_conditional_render = has_ext("GL_NV_conditional_render");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_NV_internalformat_sample_query = has_ext("GL_NV_internalformat_sample_query");
	GL_AMD_performance_monitor = has_ext("GL_AMD_performance_monitor");
	GL_OVR_multiview2 = has_ext("GL_OVR_multiview2");
	GL_EXT_draw_instanced = has_ext("GL_EXT_draw_instanced");
	GL_KHR_context_flush_control = has_ext("GL_KHR_context_flush_control");
	GL_EXT_texture_sRGB_decode = has_ext("GL_EXT_texture_sRGB_decode");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_OES_single_precision = has_ext("GL_OES_single_precision");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_OES_read_format = has_ext("GL_OES_read_format");
	GL_OES_fixed_point = has_ext("GL_OES_fixed_point");
	GL_OES_query_matrix = has_ext("GL_OES_query_matrix");
	GL_EXT_texture_lod_bias = has_ext("GL_EXT_texture_lod_bias");
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_OES_byte_coordinates = has_ext("GL_OES_byte_coordinates");
	return;
}

void load_GL_VERSION_1_0(Loader load) {
	if(!GL_VERSION_1_0) return;
	glCullFace = cast(typeof(glCullFace))load("glCullFace");
	glFrontFace = cast(typeof(glFrontFace))load("glFrontFace");
	glHint = cast(typeof(glHint))load("glHint");
	glLineWidth = cast(typeof(glLineWidth))load("glLineWidth");
	glPointSize = cast(typeof(glPointSize))load("glPointSize");
	glPolygonMode = cast(typeof(glPolygonMode))load("glPolygonMode");
	glScissor = cast(typeof(glScissor))load("glScissor");
	glTexParameterf = cast(typeof(glTexParameterf))load("glTexParameterf");
	glTexParameterfv = cast(typeof(glTexParameterfv))load("glTexParameterfv");
	glTexParameteri = cast(typeof(glTexParameteri))load("glTexParameteri");
	glTexParameteriv = cast(typeof(glTexParameteriv))load("glTexParameteriv");
	glTexImage1D = cast(typeof(glTexImage1D))load("glTexImage1D");
	glTexImage2D = cast(typeof(glTexImage2D))load("glTexImage2D");
	glDrawBuffer = cast(typeof(glDrawBuffer))load("glDrawBuffer");
	glClear = cast(typeof(glClear))load("glClear");
	glClearColor = cast(typeof(glClearColor))load("glClearColor");
	glClearStencil = cast(typeof(glClearStencil))load("glClearStencil");
	glClearDepth = cast(typeof(glClearDepth))load("glClearDepth");
	glStencilMask = cast(typeof(glStencilMask))load("glStencilMask");
	glColorMask = cast(typeof(glColorMask))load("glColorMask");
	glDepthMask = cast(typeof(glDepthMask))load("glDepthMask");
	glDisable = cast(typeof(glDisable))load("glDisable");
	glEnable = cast(typeof(glEnable))load("glEnable");
	glFinish = cast(typeof(glFinish))load("glFinish");
	glFlush = cast(typeof(glFlush))load("glFlush");
	glBlendFunc = cast(typeof(glBlendFunc))load("glBlendFunc");
	glLogicOp = cast(typeof(glLogicOp))load("glLogicOp");
	glStencilFunc = cast(typeof(glStencilFunc))load("glStencilFunc");
	glStencilOp = cast(typeof(glStencilOp))load("glStencilOp");
	glDepthFunc = cast(typeof(glDepthFunc))load("glDepthFunc");
	glPixelStoref = cast(typeof(glPixelStoref))load("glPixelStoref");
	glPixelStorei = cast(typeof(glPixelStorei))load("glPixelStorei");
	glReadBuffer = cast(typeof(glReadBuffer))load("glReadBuffer");
	glReadPixels = cast(typeof(glReadPixels))load("glReadPixels");
	glGetBooleanv = cast(typeof(glGetBooleanv))load("glGetBooleanv");
	glGetDoublev = cast(typeof(glGetDoublev))load("glGetDoublev");
	glGetError = cast(typeof(glGetError))load("glGetError");
	glGetFloatv = cast(typeof(glGetFloatv))load("glGetFloatv");
	glGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv");
	glGetString = cast(typeof(glGetString))load("glGetString");
	glGetTexImage = cast(typeof(glGetTexImage))load("glGetTexImage");
	glGetTexParameterfv = cast(typeof(glGetTexParameterfv))load("glGetTexParameterfv");
	glGetTexParameteriv = cast(typeof(glGetTexParameteriv))load("glGetTexParameteriv");
	glGetTexLevelParameterfv = cast(typeof(glGetTexLevelParameterfv))load("glGetTexLevelParameterfv");
	glGetTexLevelParameteriv = cast(typeof(glGetTexLevelParameteriv))load("glGetTexLevelParameteriv");
	glIsEnabled = cast(typeof(glIsEnabled))load("glIsEnabled");
	glDepthRange = cast(typeof(glDepthRange))load("glDepthRange");
	glViewport = cast(typeof(glViewport))load("glViewport");
	glNewList = cast(typeof(glNewList))load("glNewList");
	glEndList = cast(typeof(glEndList))load("glEndList");
	glCallList = cast(typeof(glCallList))load("glCallList");
	glCallLists = cast(typeof(glCallLists))load("glCallLists");
	glDeleteLists = cast(typeof(glDeleteLists))load("glDeleteLists");
	glGenLists = cast(typeof(glGenLists))load("glGenLists");
	glListBase = cast(typeof(glListBase))load("glListBase");
	glBegin = cast(typeof(glBegin))load("glBegin");
	glBitmap = cast(typeof(glBitmap))load("glBitmap");
	glColor3b = cast(typeof(glColor3b))load("glColor3b");
	glColor3bv = cast(typeof(glColor3bv))load("glColor3bv");
	glColor3d = cast(typeof(glColor3d))load("glColor3d");
	glColor3dv = cast(typeof(glColor3dv))load("glColor3dv");
	glColor3f = cast(typeof(glColor3f))load("glColor3f");
	glColor3fv = cast(typeof(glColor3fv))load("glColor3fv");
	glColor3i = cast(typeof(glColor3i))load("glColor3i");
	glColor3iv = cast(typeof(glColor3iv))load("glColor3iv");
	glColor3s = cast(typeof(glColor3s))load("glColor3s");
	glColor3sv = cast(typeof(glColor3sv))load("glColor3sv");
	glColor3ub = cast(typeof(glColor3ub))load("glColor3ub");
	glColor3ubv = cast(typeof(glColor3ubv))load("glColor3ubv");
	glColor3ui = cast(typeof(glColor3ui))load("glColor3ui");
	glColor3uiv = cast(typeof(glColor3uiv))load("glColor3uiv");
	glColor3us = cast(typeof(glColor3us))load("glColor3us");
	glColor3usv = cast(typeof(glColor3usv))load("glColor3usv");
	glColor4b = cast(typeof(glColor4b))load("glColor4b");
	glColor4bv = cast(typeof(glColor4bv))load("glColor4bv");
	glColor4d = cast(typeof(glColor4d))load("glColor4d");
	glColor4dv = cast(typeof(glColor4dv))load("glColor4dv");
	glColor4f = cast(typeof(glColor4f))load("glColor4f");
	glColor4fv = cast(typeof(glColor4fv))load("glColor4fv");
	glColor4i = cast(typeof(glColor4i))load("glColor4i");
	glColor4iv = cast(typeof(glColor4iv))load("glColor4iv");
	glColor4s = cast(typeof(glColor4s))load("glColor4s");
	glColor4sv = cast(typeof(glColor4sv))load("glColor4sv");
	glColor4ub = cast(typeof(glColor4ub))load("glColor4ub");
	glColor4ubv = cast(typeof(glColor4ubv))load("glColor4ubv");
	glColor4ui = cast(typeof(glColor4ui))load("glColor4ui");
	glColor4uiv = cast(typeof(glColor4uiv))load("glColor4uiv");
	glColor4us = cast(typeof(glColor4us))load("glColor4us");
	glColor4usv = cast(typeof(glColor4usv))load("glColor4usv");
	glEdgeFlag = cast(typeof(glEdgeFlag))load("glEdgeFlag");
	glEdgeFlagv = cast(typeof(glEdgeFlagv))load("glEdgeFlagv");
	glEnd = cast(typeof(glEnd))load("glEnd");
	glIndexd = cast(typeof(glIndexd))load("glIndexd");
	glIndexdv = cast(typeof(glIndexdv))load("glIndexdv");
	glIndexf = cast(typeof(glIndexf))load("glIndexf");
	glIndexfv = cast(typeof(glIndexfv))load("glIndexfv");
	glIndexi = cast(typeof(glIndexi))load("glIndexi");
	glIndexiv = cast(typeof(glIndexiv))load("glIndexiv");
	glIndexs = cast(typeof(glIndexs))load("glIndexs");
	glIndexsv = cast(typeof(glIndexsv))load("glIndexsv");
	glNormal3b = cast(typeof(glNormal3b))load("glNormal3b");
	glNormal3bv = cast(typeof(glNormal3bv))load("glNormal3bv");
	glNormal3d = cast(typeof(glNormal3d))load("glNormal3d");
	glNormal3dv = cast(typeof(glNormal3dv))load("glNormal3dv");
	glNormal3f = cast(typeof(glNormal3f))load("glNormal3f");
	glNormal3fv = cast(typeof(glNormal3fv))load("glNormal3fv");
	glNormal3i = cast(typeof(glNormal3i))load("glNormal3i");
	glNormal3iv = cast(typeof(glNormal3iv))load("glNormal3iv");
	glNormal3s = cast(typeof(glNormal3s))load("glNormal3s");
	glNormal3sv = cast(typeof(glNormal3sv))load("glNormal3sv");
	glRasterPos2d = cast(typeof(glRasterPos2d))load("glRasterPos2d");
	glRasterPos2dv = cast(typeof(glRasterPos2dv))load("glRasterPos2dv");
	glRasterPos2f = cast(typeof(glRasterPos2f))load("glRasterPos2f");
	glRasterPos2fv = cast(typeof(glRasterPos2fv))load("glRasterPos2fv");
	glRasterPos2i = cast(typeof(glRasterPos2i))load("glRasterPos2i");
	glRasterPos2iv = cast(typeof(glRasterPos2iv))load("glRasterPos2iv");
	glRasterPos2s = cast(typeof(glRasterPos2s))load("glRasterPos2s");
	glRasterPos2sv = cast(typeof(glRasterPos2sv))load("glRasterPos2sv");
	glRasterPos3d = cast(typeof(glRasterPos3d))load("glRasterPos3d");
	glRasterPos3dv = cast(typeof(glRasterPos3dv))load("glRasterPos3dv");
	glRasterPos3f = cast(typeof(glRasterPos3f))load("glRasterPos3f");
	glRasterPos3fv = cast(typeof(glRasterPos3fv))load("glRasterPos3fv");
	glRasterPos3i = cast(typeof(glRasterPos3i))load("glRasterPos3i");
	glRasterPos3iv = cast(typeof(glRasterPos3iv))load("glRasterPos3iv");
	glRasterPos3s = cast(typeof(glRasterPos3s))load("glRasterPos3s");
	glRasterPos3sv = cast(typeof(glRasterPos3sv))load("glRasterPos3sv");
	glRasterPos4d = cast(typeof(glRasterPos4d))load("glRasterPos4d");
	glRasterPos4dv = cast(typeof(glRasterPos4dv))load("glRasterPos4dv");
	glRasterPos4f = cast(typeof(glRasterPos4f))load("glRasterPos4f");
	glRasterPos4fv = cast(typeof(glRasterPos4fv))load("glRasterPos4fv");
	glRasterPos4i = cast(typeof(glRasterPos4i))load("glRasterPos4i");
	glRasterPos4iv = cast(typeof(glRasterPos4iv))load("glRasterPos4iv");
	glRasterPos4s = cast(typeof(glRasterPos4s))load("glRasterPos4s");
	glRasterPos4sv = cast(typeof(glRasterPos4sv))load("glRasterPos4sv");
	glRectd = cast(typeof(glRectd))load("glRectd");
	glRectdv = cast(typeof(glRectdv))load("glRectdv");
	glRectf = cast(typeof(glRectf))load("glRectf");
	glRectfv = cast(typeof(glRectfv))load("glRectfv");
	glRecti = cast(typeof(glRecti))load("glRecti");
	glRectiv = cast(typeof(glRectiv))load("glRectiv");
	glRects = cast(typeof(glRects))load("glRects");
	glRectsv = cast(typeof(glRectsv))load("glRectsv");
	glTexCoord1d = cast(typeof(glTexCoord1d))load("glTexCoord1d");
	glTexCoord1dv = cast(typeof(glTexCoord1dv))load("glTexCoord1dv");
	glTexCoord1f = cast(typeof(glTexCoord1f))load("glTexCoord1f");
	glTexCoord1fv = cast(typeof(glTexCoord1fv))load("glTexCoord1fv");
	glTexCoord1i = cast(typeof(glTexCoord1i))load("glTexCoord1i");
	glTexCoord1iv = cast(typeof(glTexCoord1iv))load("glTexCoord1iv");
	glTexCoord1s = cast(typeof(glTexCoord1s))load("glTexCoord1s");
	glTexCoord1sv = cast(typeof(glTexCoord1sv))load("glTexCoord1sv");
	glTexCoord2d = cast(typeof(glTexCoord2d))load("glTexCoord2d");
	glTexCoord2dv = cast(typeof(glTexCoord2dv))load("glTexCoord2dv");
	glTexCoord2f = cast(typeof(glTexCoord2f))load("glTexCoord2f");
	glTexCoord2fv = cast(typeof(glTexCoord2fv))load("glTexCoord2fv");
	glTexCoord2i = cast(typeof(glTexCoord2i))load("glTexCoord2i");
	glTexCoord2iv = cast(typeof(glTexCoord2iv))load("glTexCoord2iv");
	glTexCoord2s = cast(typeof(glTexCoord2s))load("glTexCoord2s");
	glTexCoord2sv = cast(typeof(glTexCoord2sv))load("glTexCoord2sv");
	glTexCoord3d = cast(typeof(glTexCoord3d))load("glTexCoord3d");
	glTexCoord3dv = cast(typeof(glTexCoord3dv))load("glTexCoord3dv");
	glTexCoord3f = cast(typeof(glTexCoord3f))load("glTexCoord3f");
	glTexCoord3fv = cast(typeof(glTexCoord3fv))load("glTexCoord3fv");
	glTexCoord3i = cast(typeof(glTexCoord3i))load("glTexCoord3i");
	glTexCoord3iv = cast(typeof(glTexCoord3iv))load("glTexCoord3iv");
	glTexCoord3s = cast(typeof(glTexCoord3s))load("glTexCoord3s");
	glTexCoord3sv = cast(typeof(glTexCoord3sv))load("glTexCoord3sv");
	glTexCoord4d = cast(typeof(glTexCoord4d))load("glTexCoord4d");
	glTexCoord4dv = cast(typeof(glTexCoord4dv))load("glTexCoord4dv");
	glTexCoord4f = cast(typeof(glTexCoord4f))load("glTexCoord4f");
	glTexCoord4fv = cast(typeof(glTexCoord4fv))load("glTexCoord4fv");
	glTexCoord4i = cast(typeof(glTexCoord4i))load("glTexCoord4i");
	glTexCoord4iv = cast(typeof(glTexCoord4iv))load("glTexCoord4iv");
	glTexCoord4s = cast(typeof(glTexCoord4s))load("glTexCoord4s");
	glTexCoord4sv = cast(typeof(glTexCoord4sv))load("glTexCoord4sv");
	glVertex2d = cast(typeof(glVertex2d))load("glVertex2d");
	glVertex2dv = cast(typeof(glVertex2dv))load("glVertex2dv");
	glVertex2f = cast(typeof(glVertex2f))load("glVertex2f");
	glVertex2fv = cast(typeof(glVertex2fv))load("glVertex2fv");
	glVertex2i = cast(typeof(glVertex2i))load("glVertex2i");
	glVertex2iv = cast(typeof(glVertex2iv))load("glVertex2iv");
	glVertex2s = cast(typeof(glVertex2s))load("glVertex2s");
	glVertex2sv = cast(typeof(glVertex2sv))load("glVertex2sv");
	glVertex3d = cast(typeof(glVertex3d))load("glVertex3d");
	glVertex3dv = cast(typeof(glVertex3dv))load("glVertex3dv");
	glVertex3f = cast(typeof(glVertex3f))load("glVertex3f");
	glVertex3fv = cast(typeof(glVertex3fv))load("glVertex3fv");
	glVertex3i = cast(typeof(glVertex3i))load("glVertex3i");
	glVertex3iv = cast(typeof(glVertex3iv))load("glVertex3iv");
	glVertex3s = cast(typeof(glVertex3s))load("glVertex3s");
	glVertex3sv = cast(typeof(glVertex3sv))load("glVertex3sv");
	glVertex4d = cast(typeof(glVertex4d))load("glVertex4d");
	glVertex4dv = cast(typeof(glVertex4dv))load("glVertex4dv");
	glVertex4f = cast(typeof(glVertex4f))load("glVertex4f");
	glVertex4fv = cast(typeof(glVertex4fv))load("glVertex4fv");
	glVertex4i = cast(typeof(glVertex4i))load("glVertex4i");
	glVertex4iv = cast(typeof(glVertex4iv))load("glVertex4iv");
	glVertex4s = cast(typeof(glVertex4s))load("glVertex4s");
	glVertex4sv = cast(typeof(glVertex4sv))load("glVertex4sv");
	glClipPlane = cast(typeof(glClipPlane))load("glClipPlane");
	glColorMaterial = cast(typeof(glColorMaterial))load("glColorMaterial");
	glFogf = cast(typeof(glFogf))load("glFogf");
	glFogfv = cast(typeof(glFogfv))load("glFogfv");
	glFogi = cast(typeof(glFogi))load("glFogi");
	glFogiv = cast(typeof(glFogiv))load("glFogiv");
	glLightf = cast(typeof(glLightf))load("glLightf");
	glLightfv = cast(typeof(glLightfv))load("glLightfv");
	glLighti = cast(typeof(glLighti))load("glLighti");
	glLightiv = cast(typeof(glLightiv))load("glLightiv");
	glLightModelf = cast(typeof(glLightModelf))load("glLightModelf");
	glLightModelfv = cast(typeof(glLightModelfv))load("glLightModelfv");
	glLightModeli = cast(typeof(glLightModeli))load("glLightModeli");
	glLightModeliv = cast(typeof(glLightModeliv))load("glLightModeliv");
	glLineStipple = cast(typeof(glLineStipple))load("glLineStipple");
	glMaterialf = cast(typeof(glMaterialf))load("glMaterialf");
	glMaterialfv = cast(typeof(glMaterialfv))load("glMaterialfv");
	glMateriali = cast(typeof(glMateriali))load("glMateriali");
	glMaterialiv = cast(typeof(glMaterialiv))load("glMaterialiv");
	glPolygonStipple = cast(typeof(glPolygonStipple))load("glPolygonStipple");
	glShadeModel = cast(typeof(glShadeModel))load("glShadeModel");
	glTexEnvf = cast(typeof(glTexEnvf))load("glTexEnvf");
	glTexEnvfv = cast(typeof(glTexEnvfv))load("glTexEnvfv");
	glTexEnvi = cast(typeof(glTexEnvi))load("glTexEnvi");
	glTexEnviv = cast(typeof(glTexEnviv))load("glTexEnviv");
	glTexGend = cast(typeof(glTexGend))load("glTexGend");
	glTexGendv = cast(typeof(glTexGendv))load("glTexGendv");
	glTexGenf = cast(typeof(glTexGenf))load("glTexGenf");
	glTexGenfv = cast(typeof(glTexGenfv))load("glTexGenfv");
	glTexGeni = cast(typeof(glTexGeni))load("glTexGeni");
	glTexGeniv = cast(typeof(glTexGeniv))load("glTexGeniv");
	glFeedbackBuffer = cast(typeof(glFeedbackBuffer))load("glFeedbackBuffer");
	glSelectBuffer = cast(typeof(glSelectBuffer))load("glSelectBuffer");
	glRenderMode = cast(typeof(glRenderMode))load("glRenderMode");
	glInitNames = cast(typeof(glInitNames))load("glInitNames");
	glLoadName = cast(typeof(glLoadName))load("glLoadName");
	glPassThrough = cast(typeof(glPassThrough))load("glPassThrough");
	glPopName = cast(typeof(glPopName))load("glPopName");
	glPushName = cast(typeof(glPushName))load("glPushName");
	glClearAccum = cast(typeof(glClearAccum))load("glClearAccum");
	glClearIndex = cast(typeof(glClearIndex))load("glClearIndex");
	glIndexMask = cast(typeof(glIndexMask))load("glIndexMask");
	glAccum = cast(typeof(glAccum))load("glAccum");
	glPopAttrib = cast(typeof(glPopAttrib))load("glPopAttrib");
	glPushAttrib = cast(typeof(glPushAttrib))load("glPushAttrib");
	glMap1d = cast(typeof(glMap1d))load("glMap1d");
	glMap1f = cast(typeof(glMap1f))load("glMap1f");
	glMap2d = cast(typeof(glMap2d))load("glMap2d");
	glMap2f = cast(typeof(glMap2f))load("glMap2f");
	glMapGrid1d = cast(typeof(glMapGrid1d))load("glMapGrid1d");
	glMapGrid1f = cast(typeof(glMapGrid1f))load("glMapGrid1f");
	glMapGrid2d = cast(typeof(glMapGrid2d))load("glMapGrid2d");
	glMapGrid2f = cast(typeof(glMapGrid2f))load("glMapGrid2f");
	glEvalCoord1d = cast(typeof(glEvalCoord1d))load("glEvalCoord1d");
	glEvalCoord1dv = cast(typeof(glEvalCoord1dv))load("glEvalCoord1dv");
	glEvalCoord1f = cast(typeof(glEvalCoord1f))load("glEvalCoord1f");
	glEvalCoord1fv = cast(typeof(glEvalCoord1fv))load("glEvalCoord1fv");
	glEvalCoord2d = cast(typeof(glEvalCoord2d))load("glEvalCoord2d");
	glEvalCoord2dv = cast(typeof(glEvalCoord2dv))load("glEvalCoord2dv");
	glEvalCoord2f = cast(typeof(glEvalCoord2f))load("glEvalCoord2f");
	glEvalCoord2fv = cast(typeof(glEvalCoord2fv))load("glEvalCoord2fv");
	glEvalMesh1 = cast(typeof(glEvalMesh1))load("glEvalMesh1");
	glEvalPoint1 = cast(typeof(glEvalPoint1))load("glEvalPoint1");
	glEvalMesh2 = cast(typeof(glEvalMesh2))load("glEvalMesh2");
	glEvalPoint2 = cast(typeof(glEvalPoint2))load("glEvalPoint2");
	glAlphaFunc = cast(typeof(glAlphaFunc))load("glAlphaFunc");
	glPixelZoom = cast(typeof(glPixelZoom))load("glPixelZoom");
	glPixelTransferf = cast(typeof(glPixelTransferf))load("glPixelTransferf");
	glPixelTransferi = cast(typeof(glPixelTransferi))load("glPixelTransferi");
	glPixelMapfv = cast(typeof(glPixelMapfv))load("glPixelMapfv");
	glPixelMapuiv = cast(typeof(glPixelMapuiv))load("glPixelMapuiv");
	glPixelMapusv = cast(typeof(glPixelMapusv))load("glPixelMapusv");
	glCopyPixels = cast(typeof(glCopyPixels))load("glCopyPixels");
	glDrawPixels = cast(typeof(glDrawPixels))load("glDrawPixels");
	glGetClipPlane = cast(typeof(glGetClipPlane))load("glGetClipPlane");
	glGetLightfv = cast(typeof(glGetLightfv))load("glGetLightfv");
	glGetLightiv = cast(typeof(glGetLightiv))load("glGetLightiv");
	glGetMapdv = cast(typeof(glGetMapdv))load("glGetMapdv");
	glGetMapfv = cast(typeof(glGetMapfv))load("glGetMapfv");
	glGetMapiv = cast(typeof(glGetMapiv))load("glGetMapiv");
	glGetMaterialfv = cast(typeof(glGetMaterialfv))load("glGetMaterialfv");
	glGetMaterialiv = cast(typeof(glGetMaterialiv))load("glGetMaterialiv");
	glGetPixelMapfv = cast(typeof(glGetPixelMapfv))load("glGetPixelMapfv");
	glGetPixelMapuiv = cast(typeof(glGetPixelMapuiv))load("glGetPixelMapuiv");
	glGetPixelMapusv = cast(typeof(glGetPixelMapusv))load("glGetPixelMapusv");
	glGetPolygonStipple = cast(typeof(glGetPolygonStipple))load("glGetPolygonStipple");
	glGetTexEnvfv = cast(typeof(glGetTexEnvfv))load("glGetTexEnvfv");
	glGetTexEnviv = cast(typeof(glGetTexEnviv))load("glGetTexEnviv");
	glGetTexGendv = cast(typeof(glGetTexGendv))load("glGetTexGendv");
	glGetTexGenfv = cast(typeof(glGetTexGenfv))load("glGetTexGenfv");
	glGetTexGeniv = cast(typeof(glGetTexGeniv))load("glGetTexGeniv");
	glIsList = cast(typeof(glIsList))load("glIsList");
	glFrustum = cast(typeof(glFrustum))load("glFrustum");
	glLoadIdentity = cast(typeof(glLoadIdentity))load("glLoadIdentity");
	glLoadMatrixf = cast(typeof(glLoadMatrixf))load("glLoadMatrixf");
	glLoadMatrixd = cast(typeof(glLoadMatrixd))load("glLoadMatrixd");
	glMatrixMode = cast(typeof(glMatrixMode))load("glMatrixMode");
	glMultMatrixf = cast(typeof(glMultMatrixf))load("glMultMatrixf");
	glMultMatrixd = cast(typeof(glMultMatrixd))load("glMultMatrixd");
	glOrtho = cast(typeof(glOrtho))load("glOrtho");
	glPopMatrix = cast(typeof(glPopMatrix))load("glPopMatrix");
	glPushMatrix = cast(typeof(glPushMatrix))load("glPushMatrix");
	glRotated = cast(typeof(glRotated))load("glRotated");
	glRotatef = cast(typeof(glRotatef))load("glRotatef");
	glScaled = cast(typeof(glScaled))load("glScaled");
	glScalef = cast(typeof(glScalef))load("glScalef");
	glTranslated = cast(typeof(glTranslated))load("glTranslated");
	glTranslatef = cast(typeof(glTranslatef))load("glTranslatef");
	return;
}

void load_GL_VERSION_1_1(Loader load) {
	if(!GL_VERSION_1_1) return;
	glDrawArrays = cast(typeof(glDrawArrays))load("glDrawArrays");
	glDrawElements = cast(typeof(glDrawElements))load("glDrawElements");
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv");
	glPolygonOffset = cast(typeof(glPolygonOffset))load("glPolygonOffset");
	glCopyTexImage1D = cast(typeof(glCopyTexImage1D))load("glCopyTexImage1D");
	glCopyTexImage2D = cast(typeof(glCopyTexImage2D))load("glCopyTexImage2D");
	glCopyTexSubImage1D = cast(typeof(glCopyTexSubImage1D))load("glCopyTexSubImage1D");
	glCopyTexSubImage2D = cast(typeof(glCopyTexSubImage2D))load("glCopyTexSubImage2D");
	glTexSubImage1D = cast(typeof(glTexSubImage1D))load("glTexSubImage1D");
	glTexSubImage2D = cast(typeof(glTexSubImage2D))load("glTexSubImage2D");
	glBindTexture = cast(typeof(glBindTexture))load("glBindTexture");
	glDeleteTextures = cast(typeof(glDeleteTextures))load("glDeleteTextures");
	glGenTextures = cast(typeof(glGenTextures))load("glGenTextures");
	glIsTexture = cast(typeof(glIsTexture))load("glIsTexture");
	glArrayElement = cast(typeof(glArrayElement))load("glArrayElement");
	glColorPointer = cast(typeof(glColorPointer))load("glColorPointer");
	glDisableClientState = cast(typeof(glDisableClientState))load("glDisableClientState");
	glEdgeFlagPointer = cast(typeof(glEdgeFlagPointer))load("glEdgeFlagPointer");
	glEnableClientState = cast(typeof(glEnableClientState))load("glEnableClientState");
	glIndexPointer = cast(typeof(glIndexPointer))load("glIndexPointer");
	glInterleavedArrays = cast(typeof(glInterleavedArrays))load("glInterleavedArrays");
	glNormalPointer = cast(typeof(glNormalPointer))load("glNormalPointer");
	glTexCoordPointer = cast(typeof(glTexCoordPointer))load("glTexCoordPointer");
	glVertexPointer = cast(typeof(glVertexPointer))load("glVertexPointer");
	glAreTexturesResident = cast(typeof(glAreTexturesResident))load("glAreTexturesResident");
	glPrioritizeTextures = cast(typeof(glPrioritizeTextures))load("glPrioritizeTextures");
	glIndexub = cast(typeof(glIndexub))load("glIndexub");
	glIndexubv = cast(typeof(glIndexubv))load("glIndexubv");
	glPopClientAttrib = cast(typeof(glPopClientAttrib))load("glPopClientAttrib");
	glPushClientAttrib = cast(typeof(glPushClientAttrib))load("glPushClientAttrib");
	return;
}

void load_GL_VERSION_1_2(Loader load) {
	if(!GL_VERSION_1_2) return;
	glDrawRangeElements = cast(typeof(glDrawRangeElements))load("glDrawRangeElements");
	glTexImage3D = cast(typeof(glTexImage3D))load("glTexImage3D");
	glTexSubImage3D = cast(typeof(glTexSubImage3D))load("glTexSubImage3D");
	glCopyTexSubImage3D = cast(typeof(glCopyTexSubImage3D))load("glCopyTexSubImage3D");
	return;
}

void load_GL_VERSION_1_3(Loader load) {
	if(!GL_VERSION_1_3) return;
	glActiveTexture = cast(typeof(glActiveTexture))load("glActiveTexture");
	glSampleCoverage = cast(typeof(glSampleCoverage))load("glSampleCoverage");
	glCompressedTexImage3D = cast(typeof(glCompressedTexImage3D))load("glCompressedTexImage3D");
	glCompressedTexImage2D = cast(typeof(glCompressedTexImage2D))load("glCompressedTexImage2D");
	glCompressedTexImage1D = cast(typeof(glCompressedTexImage1D))load("glCompressedTexImage1D");
	glCompressedTexSubImage3D = cast(typeof(glCompressedTexSubImage3D))load("glCompressedTexSubImage3D");
	glCompressedTexSubImage2D = cast(typeof(glCompressedTexSubImage2D))load("glCompressedTexSubImage2D");
	glCompressedTexSubImage1D = cast(typeof(glCompressedTexSubImage1D))load("glCompressedTexSubImage1D");
	glGetCompressedTexImage = cast(typeof(glGetCompressedTexImage))load("glGetCompressedTexImage");
	glClientActiveTexture = cast(typeof(glClientActiveTexture))load("glClientActiveTexture");
	glMultiTexCoord1d = cast(typeof(glMultiTexCoord1d))load("glMultiTexCoord1d");
	glMultiTexCoord1dv = cast(typeof(glMultiTexCoord1dv))load("glMultiTexCoord1dv");
	glMultiTexCoord1f = cast(typeof(glMultiTexCoord1f))load("glMultiTexCoord1f");
	glMultiTexCoord1fv = cast(typeof(glMultiTexCoord1fv))load("glMultiTexCoord1fv");
	glMultiTexCoord1i = cast(typeof(glMultiTexCoord1i))load("glMultiTexCoord1i");
	glMultiTexCoord1iv = cast(typeof(glMultiTexCoord1iv))load("glMultiTexCoord1iv");
	glMultiTexCoord1s = cast(typeof(glMultiTexCoord1s))load("glMultiTexCoord1s");
	glMultiTexCoord1sv = cast(typeof(glMultiTexCoord1sv))load("glMultiTexCoord1sv");
	glMultiTexCoord2d = cast(typeof(glMultiTexCoord2d))load("glMultiTexCoord2d");
	glMultiTexCoord2dv = cast(typeof(glMultiTexCoord2dv))load("glMultiTexCoord2dv");
	glMultiTexCoord2f = cast(typeof(glMultiTexCoord2f))load("glMultiTexCoord2f");
	glMultiTexCoord2fv = cast(typeof(glMultiTexCoord2fv))load("glMultiTexCoord2fv");
	glMultiTexCoord2i = cast(typeof(glMultiTexCoord2i))load("glMultiTexCoord2i");
	glMultiTexCoord2iv = cast(typeof(glMultiTexCoord2iv))load("glMultiTexCoord2iv");
	glMultiTexCoord2s = cast(typeof(glMultiTexCoord2s))load("glMultiTexCoord2s");
	glMultiTexCoord2sv = cast(typeof(glMultiTexCoord2sv))load("glMultiTexCoord2sv");
	glMultiTexCoord3d = cast(typeof(glMultiTexCoord3d))load("glMultiTexCoord3d");
	glMultiTexCoord3dv = cast(typeof(glMultiTexCoord3dv))load("glMultiTexCoord3dv");
	glMultiTexCoord3f = cast(typeof(glMultiTexCoord3f))load("glMultiTexCoord3f");
	glMultiTexCoord3fv = cast(typeof(glMultiTexCoord3fv))load("glMultiTexCoord3fv");
	glMultiTexCoord3i = cast(typeof(glMultiTexCoord3i))load("glMultiTexCoord3i");
	glMultiTexCoord3iv = cast(typeof(glMultiTexCoord3iv))load("glMultiTexCoord3iv");
	glMultiTexCoord3s = cast(typeof(glMultiTexCoord3s))load("glMultiTexCoord3s");
	glMultiTexCoord3sv = cast(typeof(glMultiTexCoord3sv))load("glMultiTexCoord3sv");
	glMultiTexCoord4d = cast(typeof(glMultiTexCoord4d))load("glMultiTexCoord4d");
	glMultiTexCoord4dv = cast(typeof(glMultiTexCoord4dv))load("glMultiTexCoord4dv");
	glMultiTexCoord4f = cast(typeof(glMultiTexCoord4f))load("glMultiTexCoord4f");
	glMultiTexCoord4fv = cast(typeof(glMultiTexCoord4fv))load("glMultiTexCoord4fv");
	glMultiTexCoord4i = cast(typeof(glMultiTexCoord4i))load("glMultiTexCoord4i");
	glMultiTexCoord4iv = cast(typeof(glMultiTexCoord4iv))load("glMultiTexCoord4iv");
	glMultiTexCoord4s = cast(typeof(glMultiTexCoord4s))load("glMultiTexCoord4s");
	glMultiTexCoord4sv = cast(typeof(glMultiTexCoord4sv))load("glMultiTexCoord4sv");
	glLoadTransposeMatrixf = cast(typeof(glLoadTransposeMatrixf))load("glLoadTransposeMatrixf");
	glLoadTransposeMatrixd = cast(typeof(glLoadTransposeMatrixd))load("glLoadTransposeMatrixd");
	glMultTransposeMatrixf = cast(typeof(glMultTransposeMatrixf))load("glMultTransposeMatrixf");
	glMultTransposeMatrixd = cast(typeof(glMultTransposeMatrixd))load("glMultTransposeMatrixd");
	return;
}

void load_GL_VERSION_1_4(Loader load) {
	if(!GL_VERSION_1_4) return;
	glBlendFuncSeparate = cast(typeof(glBlendFuncSeparate))load("glBlendFuncSeparate");
	glMultiDrawArrays = cast(typeof(glMultiDrawArrays))load("glMultiDrawArrays");
	glMultiDrawElements = cast(typeof(glMultiDrawElements))load("glMultiDrawElements");
	glPointParameterf = cast(typeof(glPointParameterf))load("glPointParameterf");
	glPointParameterfv = cast(typeof(glPointParameterfv))load("glPointParameterfv");
	glPointParameteri = cast(typeof(glPointParameteri))load("glPointParameteri");
	glPointParameteriv = cast(typeof(glPointParameteriv))load("glPointParameteriv");
	glFogCoordf = cast(typeof(glFogCoordf))load("glFogCoordf");
	glFogCoordfv = cast(typeof(glFogCoordfv))load("glFogCoordfv");
	glFogCoordd = cast(typeof(glFogCoordd))load("glFogCoordd");
	glFogCoorddv = cast(typeof(glFogCoorddv))load("glFogCoorddv");
	glFogCoordPointer = cast(typeof(glFogCoordPointer))load("glFogCoordPointer");
	glSecondaryColor3b = cast(typeof(glSecondaryColor3b))load("glSecondaryColor3b");
	glSecondaryColor3bv = cast(typeof(glSecondaryColor3bv))load("glSecondaryColor3bv");
	glSecondaryColor3d = cast(typeof(glSecondaryColor3d))load("glSecondaryColor3d");
	glSecondaryColor3dv = cast(typeof(glSecondaryColor3dv))load("glSecondaryColor3dv");
	glSecondaryColor3f = cast(typeof(glSecondaryColor3f))load("glSecondaryColor3f");
	glSecondaryColor3fv = cast(typeof(glSecondaryColor3fv))load("glSecondaryColor3fv");
	glSecondaryColor3i = cast(typeof(glSecondaryColor3i))load("glSecondaryColor3i");
	glSecondaryColor3iv = cast(typeof(glSecondaryColor3iv))load("glSecondaryColor3iv");
	glSecondaryColor3s = cast(typeof(glSecondaryColor3s))load("glSecondaryColor3s");
	glSecondaryColor3sv = cast(typeof(glSecondaryColor3sv))load("glSecondaryColor3sv");
	glSecondaryColor3ub = cast(typeof(glSecondaryColor3ub))load("glSecondaryColor3ub");
	glSecondaryColor3ubv = cast(typeof(glSecondaryColor3ubv))load("glSecondaryColor3ubv");
	glSecondaryColor3ui = cast(typeof(glSecondaryColor3ui))load("glSecondaryColor3ui");
	glSecondaryColor3uiv = cast(typeof(glSecondaryColor3uiv))load("glSecondaryColor3uiv");
	glSecondaryColor3us = cast(typeof(glSecondaryColor3us))load("glSecondaryColor3us");
	glSecondaryColor3usv = cast(typeof(glSecondaryColor3usv))load("glSecondaryColor3usv");
	glSecondaryColorPointer = cast(typeof(glSecondaryColorPointer))load("glSecondaryColorPointer");
	glWindowPos2d = cast(typeof(glWindowPos2d))load("glWindowPos2d");
	glWindowPos2dv = cast(typeof(glWindowPos2dv))load("glWindowPos2dv");
	glWindowPos2f = cast(typeof(glWindowPos2f))load("glWindowPos2f");
	glWindowPos2fv = cast(typeof(glWindowPos2fv))load("glWindowPos2fv");
	glWindowPos2i = cast(typeof(glWindowPos2i))load("glWindowPos2i");
	glWindowPos2iv = cast(typeof(glWindowPos2iv))load("glWindowPos2iv");
	glWindowPos2s = cast(typeof(glWindowPos2s))load("glWindowPos2s");
	glWindowPos2sv = cast(typeof(glWindowPos2sv))load("glWindowPos2sv");
	glWindowPos3d = cast(typeof(glWindowPos3d))load("glWindowPos3d");
	glWindowPos3dv = cast(typeof(glWindowPos3dv))load("glWindowPos3dv");
	glWindowPos3f = cast(typeof(glWindowPos3f))load("glWindowPos3f");
	glWindowPos3fv = cast(typeof(glWindowPos3fv))load("glWindowPos3fv");
	glWindowPos3i = cast(typeof(glWindowPos3i))load("glWindowPos3i");
	glWindowPos3iv = cast(typeof(glWindowPos3iv))load("glWindowPos3iv");
	glWindowPos3s = cast(typeof(glWindowPos3s))load("glWindowPos3s");
	glWindowPos3sv = cast(typeof(glWindowPos3sv))load("glWindowPos3sv");
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor");
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation");
	return;
}

void load_GL_VERSION_1_5(Loader load) {
	if(!GL_VERSION_1_5) return;
	glGenQueries = cast(typeof(glGenQueries))load("glGenQueries");
	glDeleteQueries = cast(typeof(glDeleteQueries))load("glDeleteQueries");
	glIsQuery = cast(typeof(glIsQuery))load("glIsQuery");
	glBeginQuery = cast(typeof(glBeginQuery))load("glBeginQuery");
	glEndQuery = cast(typeof(glEndQuery))load("glEndQuery");
	glGetQueryiv = cast(typeof(glGetQueryiv))load("glGetQueryiv");
	glGetQueryObjectiv = cast(typeof(glGetQueryObjectiv))load("glGetQueryObjectiv");
	glGetQueryObjectuiv = cast(typeof(glGetQueryObjectuiv))load("glGetQueryObjectuiv");
	glBindBuffer = cast(typeof(glBindBuffer))load("glBindBuffer");
	glDeleteBuffers = cast(typeof(glDeleteBuffers))load("glDeleteBuffers");
	glGenBuffers = cast(typeof(glGenBuffers))load("glGenBuffers");
	glIsBuffer = cast(typeof(glIsBuffer))load("glIsBuffer");
	glBufferData = cast(typeof(glBufferData))load("glBufferData");
	glBufferSubData = cast(typeof(glBufferSubData))load("glBufferSubData");
	glGetBufferSubData = cast(typeof(glGetBufferSubData))load("glGetBufferSubData");
	glMapBuffer = cast(typeof(glMapBuffer))load("glMapBuffer");
	glUnmapBuffer = cast(typeof(glUnmapBuffer))load("glUnmapBuffer");
	glGetBufferParameteriv = cast(typeof(glGetBufferParameteriv))load("glGetBufferParameteriv");
	glGetBufferPointerv = cast(typeof(glGetBufferPointerv))load("glGetBufferPointerv");
	return;
}

void load_GL_VERSION_2_0(Loader load) {
	if(!GL_VERSION_2_0) return;
	glBlendEquationSeparate = cast(typeof(glBlendEquationSeparate))load("glBlendEquationSeparate");
	glDrawBuffers = cast(typeof(glDrawBuffers))load("glDrawBuffers");
	glStencilOpSeparate = cast(typeof(glStencilOpSeparate))load("glStencilOpSeparate");
	glStencilFuncSeparate = cast(typeof(glStencilFuncSeparate))load("glStencilFuncSeparate");
	glStencilMaskSeparate = cast(typeof(glStencilMaskSeparate))load("glStencilMaskSeparate");
	glAttachShader = cast(typeof(glAttachShader))load("glAttachShader");
	glBindAttribLocation = cast(typeof(glBindAttribLocation))load("glBindAttribLocation");
	glCompileShader = cast(typeof(glCompileShader))load("glCompileShader");
	glCreateProgram = cast(typeof(glCreateProgram))load("glCreateProgram");
	glCreateShader = cast(typeof(glCreateShader))load("glCreateShader");
	glDeleteProgram = cast(typeof(glDeleteProgram))load("glDeleteProgram");
	glDeleteShader = cast(typeof(glDeleteShader))load("glDeleteShader");
	glDetachShader = cast(typeof(glDetachShader))load("glDetachShader");
	glDisableVertexAttribArray = cast(typeof(glDisableVertexAttribArray))load("glDisableVertexAttribArray");
	glEnableVertexAttribArray = cast(typeof(glEnableVertexAttribArray))load("glEnableVertexAttribArray");
	glGetActiveAttrib = cast(typeof(glGetActiveAttrib))load("glGetActiveAttrib");
	glGetActiveUniform = cast(typeof(glGetActiveUniform))load("glGetActiveUniform");
	glGetAttachedShaders = cast(typeof(glGetAttachedShaders))load("glGetAttachedShaders");
	glGetAttribLocation = cast(typeof(glGetAttribLocation))load("glGetAttribLocation");
	glGetProgramiv = cast(typeof(glGetProgramiv))load("glGetProgramiv");
	glGetProgramInfoLog = cast(typeof(glGetProgramInfoLog))load("glGetProgramInfoLog");
	glGetShaderiv = cast(typeof(glGetShaderiv))load("glGetShaderiv");
	glGetShaderInfoLog = cast(typeof(glGetShaderInfoLog))load("glGetShaderInfoLog");
	glGetShaderSource = cast(typeof(glGetShaderSource))load("glGetShaderSource");
	glGetUniformLocation = cast(typeof(glGetUniformLocation))load("glGetUniformLocation");
	glGetUniformfv = cast(typeof(glGetUniformfv))load("glGetUniformfv");
	glGetUniformiv = cast(typeof(glGetUniformiv))load("glGetUniformiv");
	glGetVertexAttribdv = cast(typeof(glGetVertexAttribdv))load("glGetVertexAttribdv");
	glGetVertexAttribfv = cast(typeof(glGetVertexAttribfv))load("glGetVertexAttribfv");
	glGetVertexAttribiv = cast(typeof(glGetVertexAttribiv))load("glGetVertexAttribiv");
	glGetVertexAttribPointerv = cast(typeof(glGetVertexAttribPointerv))load("glGetVertexAttribPointerv");
	glIsProgram = cast(typeof(glIsProgram))load("glIsProgram");
	glIsShader = cast(typeof(glIsShader))load("glIsShader");
	glLinkProgram = cast(typeof(glLinkProgram))load("glLinkProgram");
	glShaderSource = cast(typeof(glShaderSource))load("glShaderSource");
	glUseProgram = cast(typeof(glUseProgram))load("glUseProgram");
	glUniform1f = cast(typeof(glUniform1f))load("glUniform1f");
	glUniform2f = cast(typeof(glUniform2f))load("glUniform2f");
	glUniform3f = cast(typeof(glUniform3f))load("glUniform3f");
	glUniform4f = cast(typeof(glUniform4f))load("glUniform4f");
	glUniform1i = cast(typeof(glUniform1i))load("glUniform1i");
	glUniform2i = cast(typeof(glUniform2i))load("glUniform2i");
	glUniform3i = cast(typeof(glUniform3i))load("glUniform3i");
	glUniform4i = cast(typeof(glUniform4i))load("glUniform4i");
	glUniform1fv = cast(typeof(glUniform1fv))load("glUniform1fv");
	glUniform2fv = cast(typeof(glUniform2fv))load("glUniform2fv");
	glUniform3fv = cast(typeof(glUniform3fv))load("glUniform3fv");
	glUniform4fv = cast(typeof(glUniform4fv))load("glUniform4fv");
	glUniform1iv = cast(typeof(glUniform1iv))load("glUniform1iv");
	glUniform2iv = cast(typeof(glUniform2iv))load("glUniform2iv");
	glUniform3iv = cast(typeof(glUniform3iv))load("glUniform3iv");
	glUniform4iv = cast(typeof(glUniform4iv))load("glUniform4iv");
	glUniformMatrix2fv = cast(typeof(glUniformMatrix2fv))load("glUniformMatrix2fv");
	glUniformMatrix3fv = cast(typeof(glUniformMatrix3fv))load("glUniformMatrix3fv");
	glUniformMatrix4fv = cast(typeof(glUniformMatrix4fv))load("glUniformMatrix4fv");
	glValidateProgram = cast(typeof(glValidateProgram))load("glValidateProgram");
	glVertexAttrib1d = cast(typeof(glVertexAttrib1d))load("glVertexAttrib1d");
	glVertexAttrib1dv = cast(typeof(glVertexAttrib1dv))load("glVertexAttrib1dv");
	glVertexAttrib1f = cast(typeof(glVertexAttrib1f))load("glVertexAttrib1f");
	glVertexAttrib1fv = cast(typeof(glVertexAttrib1fv))load("glVertexAttrib1fv");
	glVertexAttrib1s = cast(typeof(glVertexAttrib1s))load("glVertexAttrib1s");
	glVertexAttrib1sv = cast(typeof(glVertexAttrib1sv))load("glVertexAttrib1sv");
	glVertexAttrib2d = cast(typeof(glVertexAttrib2d))load("glVertexAttrib2d");
	glVertexAttrib2dv = cast(typeof(glVertexAttrib2dv))load("glVertexAttrib2dv");
	glVertexAttrib2f = cast(typeof(glVertexAttrib2f))load("glVertexAttrib2f");
	glVertexAttrib2fv = cast(typeof(glVertexAttrib2fv))load("glVertexAttrib2fv");
	glVertexAttrib2s = cast(typeof(glVertexAttrib2s))load("glVertexAttrib2s");
	glVertexAttrib2sv = cast(typeof(glVertexAttrib2sv))load("glVertexAttrib2sv");
	glVertexAttrib3d = cast(typeof(glVertexAttrib3d))load("glVertexAttrib3d");
	glVertexAttrib3dv = cast(typeof(glVertexAttrib3dv))load("glVertexAttrib3dv");
	glVertexAttrib3f = cast(typeof(glVertexAttrib3f))load("glVertexAttrib3f");
	glVertexAttrib3fv = cast(typeof(glVertexAttrib3fv))load("glVertexAttrib3fv");
	glVertexAttrib3s = cast(typeof(glVertexAttrib3s))load("glVertexAttrib3s");
	glVertexAttrib3sv = cast(typeof(glVertexAttrib3sv))load("glVertexAttrib3sv");
	glVertexAttrib4Nbv = cast(typeof(glVertexAttrib4Nbv))load("glVertexAttrib4Nbv");
	glVertexAttrib4Niv = cast(typeof(glVertexAttrib4Niv))load("glVertexAttrib4Niv");
	glVertexAttrib4Nsv = cast(typeof(glVertexAttrib4Nsv))load("glVertexAttrib4Nsv");
	glVertexAttrib4Nub = cast(typeof(glVertexAttrib4Nub))load("glVertexAttrib4Nub");
	glVertexAttrib4Nubv = cast(typeof(glVertexAttrib4Nubv))load("glVertexAttrib4Nubv");
	glVertexAttrib4Nuiv = cast(typeof(glVertexAttrib4Nuiv))load("glVertexAttrib4Nuiv");
	glVertexAttrib4Nusv = cast(typeof(glVertexAttrib4Nusv))load("glVertexAttrib4Nusv");
	glVertexAttrib4bv = cast(typeof(glVertexAttrib4bv))load("glVertexAttrib4bv");
	glVertexAttrib4d = cast(typeof(glVertexAttrib4d))load("glVertexAttrib4d");
	glVertexAttrib4dv = cast(typeof(glVertexAttrib4dv))load("glVertexAttrib4dv");
	glVertexAttrib4f = cast(typeof(glVertexAttrib4f))load("glVertexAttrib4f");
	glVertexAttrib4fv = cast(typeof(glVertexAttrib4fv))load("glVertexAttrib4fv");
	glVertexAttrib4iv = cast(typeof(glVertexAttrib4iv))load("glVertexAttrib4iv");
	glVertexAttrib4s = cast(typeof(glVertexAttrib4s))load("glVertexAttrib4s");
	glVertexAttrib4sv = cast(typeof(glVertexAttrib4sv))load("glVertexAttrib4sv");
	glVertexAttrib4ubv = cast(typeof(glVertexAttrib4ubv))load("glVertexAttrib4ubv");
	glVertexAttrib4uiv = cast(typeof(glVertexAttrib4uiv))load("glVertexAttrib4uiv");
	glVertexAttrib4usv = cast(typeof(glVertexAttrib4usv))load("glVertexAttrib4usv");
	glVertexAttribPointer = cast(typeof(glVertexAttribPointer))load("glVertexAttribPointer");
	return;
}

void load_GL_VERSION_2_1(Loader load) {
	if(!GL_VERSION_2_1) return;
	glUniformMatrix2x3fv = cast(typeof(glUniformMatrix2x3fv))load("glUniformMatrix2x3fv");
	glUniformMatrix3x2fv = cast(typeof(glUniformMatrix3x2fv))load("glUniformMatrix3x2fv");
	glUniformMatrix2x4fv = cast(typeof(glUniformMatrix2x4fv))load("glUniformMatrix2x4fv");
	glUniformMatrix4x2fv = cast(typeof(glUniformMatrix4x2fv))load("glUniformMatrix4x2fv");
	glUniformMatrix3x4fv = cast(typeof(glUniformMatrix3x4fv))load("glUniformMatrix3x4fv");
	glUniformMatrix4x3fv = cast(typeof(glUniformMatrix4x3fv))load("glUniformMatrix4x3fv");
	return;
}

void load_GL_VERSION_3_0(Loader load) {
	if(!GL_VERSION_3_0) return;
	glColorMaski = cast(typeof(glColorMaski))load("glColorMaski");
	glGetBooleani_v = cast(typeof(glGetBooleani_v))load("glGetBooleani_v");
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v");
	glEnablei = cast(typeof(glEnablei))load("glEnablei");
	glDisablei = cast(typeof(glDisablei))load("glDisablei");
	glIsEnabledi = cast(typeof(glIsEnabledi))load("glIsEnabledi");
	glBeginTransformFeedback = cast(typeof(glBeginTransformFeedback))load("glBeginTransformFeedback");
	glEndTransformFeedback = cast(typeof(glEndTransformFeedback))load("glEndTransformFeedback");
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange");
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase");
	glTransformFeedbackVaryings = cast(typeof(glTransformFeedbackVaryings))load("glTransformFeedbackVaryings");
	glGetTransformFeedbackVarying = cast(typeof(glGetTransformFeedbackVarying))load("glGetTransformFeedbackVarying");
	glClampColor = cast(typeof(glClampColor))load("glClampColor");
	glBeginConditionalRender = cast(typeof(glBeginConditionalRender))load("glBeginConditionalRender");
	glEndConditionalRender = cast(typeof(glEndConditionalRender))load("glEndConditionalRender");
	glVertexAttribIPointer = cast(typeof(glVertexAttribIPointer))load("glVertexAttribIPointer");
	glGetVertexAttribIiv = cast(typeof(glGetVertexAttribIiv))load("glGetVertexAttribIiv");
	glGetVertexAttribIuiv = cast(typeof(glGetVertexAttribIuiv))load("glGetVertexAttribIuiv");
	glVertexAttribI1i = cast(typeof(glVertexAttribI1i))load("glVertexAttribI1i");
	glVertexAttribI2i = cast(typeof(glVertexAttribI2i))load("glVertexAttribI2i");
	glVertexAttribI3i = cast(typeof(glVertexAttribI3i))load("glVertexAttribI3i");
	glVertexAttribI4i = cast(typeof(glVertexAttribI4i))load("glVertexAttribI4i");
	glVertexAttribI1ui = cast(typeof(glVertexAttribI1ui))load("glVertexAttribI1ui");
	glVertexAttribI2ui = cast(typeof(glVertexAttribI2ui))load("glVertexAttribI2ui");
	glVertexAttribI3ui = cast(typeof(glVertexAttribI3ui))load("glVertexAttribI3ui");
	glVertexAttribI4ui = cast(typeof(glVertexAttribI4ui))load("glVertexAttribI4ui");
	glVertexAttribI1iv = cast(typeof(glVertexAttribI1iv))load("glVertexAttribI1iv");
	glVertexAttribI2iv = cast(typeof(glVertexAttribI2iv))load("glVertexAttribI2iv");
	glVertexAttribI3iv = cast(typeof(glVertexAttribI3iv))load("glVertexAttribI3iv");
	glVertexAttribI4iv = cast(typeof(glVertexAttribI4iv))load("glVertexAttribI4iv");
	glVertexAttribI1uiv = cast(typeof(glVertexAttribI1uiv))load("glVertexAttribI1uiv");
	glVertexAttribI2uiv = cast(typeof(glVertexAttribI2uiv))load("glVertexAttribI2uiv");
	glVertexAttribI3uiv = cast(typeof(glVertexAttribI3uiv))load("glVertexAttribI3uiv");
	glVertexAttribI4uiv = cast(typeof(glVertexAttribI4uiv))load("glVertexAttribI4uiv");
	glVertexAttribI4bv = cast(typeof(glVertexAttribI4bv))load("glVertexAttribI4bv");
	glVertexAttribI4sv = cast(typeof(glVertexAttribI4sv))load("glVertexAttribI4sv");
	glVertexAttribI4ubv = cast(typeof(glVertexAttribI4ubv))load("glVertexAttribI4ubv");
	glVertexAttribI4usv = cast(typeof(glVertexAttribI4usv))load("glVertexAttribI4usv");
	glGetUniformuiv = cast(typeof(glGetUniformuiv))load("glGetUniformuiv");
	glBindFragDataLocation = cast(typeof(glBindFragDataLocation))load("glBindFragDataLocation");
	glGetFragDataLocation = cast(typeof(glGetFragDataLocation))load("glGetFragDataLocation");
	glUniform1ui = cast(typeof(glUniform1ui))load("glUniform1ui");
	glUniform2ui = cast(typeof(glUniform2ui))load("glUniform2ui");
	glUniform3ui = cast(typeof(glUniform3ui))load("glUniform3ui");
	glUniform4ui = cast(typeof(glUniform4ui))load("glUniform4ui");
	glUniform1uiv = cast(typeof(glUniform1uiv))load("glUniform1uiv");
	glUniform2uiv = cast(typeof(glUniform2uiv))load("glUniform2uiv");
	glUniform3uiv = cast(typeof(glUniform3uiv))load("glUniform3uiv");
	glUniform4uiv = cast(typeof(glUniform4uiv))load("glUniform4uiv");
	glTexParameterIiv = cast(typeof(glTexParameterIiv))load("glTexParameterIiv");
	glTexParameterIuiv = cast(typeof(glTexParameterIuiv))load("glTexParameterIuiv");
	glGetTexParameterIiv = cast(typeof(glGetTexParameterIiv))load("glGetTexParameterIiv");
	glGetTexParameterIuiv = cast(typeof(glGetTexParameterIuiv))load("glGetTexParameterIuiv");
	glClearBufferiv = cast(typeof(glClearBufferiv))load("glClearBufferiv");
	glClearBufferuiv = cast(typeof(glClearBufferuiv))load("glClearBufferuiv");
	glClearBufferfv = cast(typeof(glClearBufferfv))load("glClearBufferfv");
	glClearBufferfi = cast(typeof(glClearBufferfi))load("glClearBufferfi");
	glGetStringi = cast(typeof(glGetStringi))load("glGetStringi");
	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer");
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer");
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers");
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers");
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage");
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv");
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer");
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer");
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers");
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers");
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus");
	glFramebufferTexture1D = cast(typeof(glFramebufferTexture1D))load("glFramebufferTexture1D");
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D");
	glFramebufferTexture3D = cast(typeof(glFramebufferTexture3D))load("glFramebufferTexture3D");
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer");
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv");
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap");
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer");
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample");
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer");
	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange");
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange");
	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray");
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays");
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays");
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray");
	return;
}

void load_GL_VERSION_3_1(Loader load) {
	if(!GL_VERSION_3_1) return;
	glDrawArraysInstanced = cast(typeof(glDrawArraysInstanced))load("glDrawArraysInstanced");
	glDrawElementsInstanced = cast(typeof(glDrawElementsInstanced))load("glDrawElementsInstanced");
	glTexBuffer = cast(typeof(glTexBuffer))load("glTexBuffer");
	glPrimitiveRestartIndex = cast(typeof(glPrimitiveRestartIndex))load("glPrimitiveRestartIndex");
	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData");
	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices");
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv");
	glGetActiveUniformName = cast(typeof(glGetActiveUniformName))load("glGetActiveUniformName");
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex");
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv");
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName");
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding");
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange");
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase");
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v");
	return;
}

void load_GL_VERSION_3_2(Loader load) {
	if(!GL_VERSION_3_2) return;
	glDrawElementsBaseVertex = cast(typeof(glDrawElementsBaseVertex))load("glDrawElementsBaseVertex");
	glDrawRangeElementsBaseVertex = cast(typeof(glDrawRangeElementsBaseVertex))load("glDrawRangeElementsBaseVertex");
	glDrawElementsInstancedBaseVertex = cast(typeof(glDrawElementsInstancedBaseVertex))load("glDrawElementsInstancedBaseVertex");
	glMultiDrawElementsBaseVertex = cast(typeof(glMultiDrawElementsBaseVertex))load("glMultiDrawElementsBaseVertex");
	glProvokingVertex = cast(typeof(glProvokingVertex))load("glProvokingVertex");
	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync");
	glIsSync = cast(typeof(glIsSync))load("glIsSync");
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync");
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync");
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync");
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v");
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv");
	glGetInteger64i_v = cast(typeof(glGetInteger64i_v))load("glGetInteger64i_v");
	glGetBufferParameteri64v = cast(typeof(glGetBufferParameteri64v))load("glGetBufferParameteri64v");
	glFramebufferTexture = cast(typeof(glFramebufferTexture))load("glFramebufferTexture");
	glTexImage2DMultisample = cast(typeof(glTexImage2DMultisample))load("glTexImage2DMultisample");
	glTexImage3DMultisample = cast(typeof(glTexImage3DMultisample))load("glTexImage3DMultisample");
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv");
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski");
	return;
}

void load_GL_VERSION_3_3(Loader load) {
	if(!GL_VERSION_3_3) return;
	glBindFragDataLocationIndexed = cast(typeof(glBindFragDataLocationIndexed))load("glBindFragDataLocationIndexed");
	glGetFragDataIndex = cast(typeof(glGetFragDataIndex))load("glGetFragDataIndex");
	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers");
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers");
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler");
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler");
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri");
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv");
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf");
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv");
	glSamplerParameterIiv = cast(typeof(glSamplerParameterIiv))load("glSamplerParameterIiv");
	glSamplerParameterIuiv = cast(typeof(glSamplerParameterIuiv))load("glSamplerParameterIuiv");
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv");
	glGetSamplerParameterIiv = cast(typeof(glGetSamplerParameterIiv))load("glGetSamplerParameterIiv");
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv");
	glGetSamplerParameterIuiv = cast(typeof(glGetSamplerParameterIuiv))load("glGetSamplerParameterIuiv");
	glQueryCounter = cast(typeof(glQueryCounter))load("glQueryCounter");
	glGetQueryObjecti64v = cast(typeof(glGetQueryObjecti64v))load("glGetQueryObjecti64v");
	glGetQueryObjectui64v = cast(typeof(glGetQueryObjectui64v))load("glGetQueryObjectui64v");
	glVertexAttribDivisor = cast(typeof(glVertexAttribDivisor))load("glVertexAttribDivisor");
	glVertexAttribP1ui = cast(typeof(glVertexAttribP1ui))load("glVertexAttribP1ui");
	glVertexAttribP1uiv = cast(typeof(glVertexAttribP1uiv))load("glVertexAttribP1uiv");
	glVertexAttribP2ui = cast(typeof(glVertexAttribP2ui))load("glVertexAttribP2ui");
	glVertexAttribP2uiv = cast(typeof(glVertexAttribP2uiv))load("glVertexAttribP2uiv");
	glVertexAttribP3ui = cast(typeof(glVertexAttribP3ui))load("glVertexAttribP3ui");
	glVertexAttribP3uiv = cast(typeof(glVertexAttribP3uiv))load("glVertexAttribP3uiv");
	glVertexAttribP4ui = cast(typeof(glVertexAttribP4ui))load("glVertexAttribP4ui");
	glVertexAttribP4uiv = cast(typeof(glVertexAttribP4uiv))load("glVertexAttribP4uiv");
	glVertexP2ui = cast(typeof(glVertexP2ui))load("glVertexP2ui");
	glVertexP2uiv = cast(typeof(glVertexP2uiv))load("glVertexP2uiv");
	glVertexP3ui = cast(typeof(glVertexP3ui))load("glVertexP3ui");
	glVertexP3uiv = cast(typeof(glVertexP3uiv))load("glVertexP3uiv");
	glVertexP4ui = cast(typeof(glVertexP4ui))load("glVertexP4ui");
	glVertexP4uiv = cast(typeof(glVertexP4uiv))load("glVertexP4uiv");
	glTexCoordP1ui = cast(typeof(glTexCoordP1ui))load("glTexCoordP1ui");
	glTexCoordP1uiv = cast(typeof(glTexCoordP1uiv))load("glTexCoordP1uiv");
	glTexCoordP2ui = cast(typeof(glTexCoordP2ui))load("glTexCoordP2ui");
	glTexCoordP2uiv = cast(typeof(glTexCoordP2uiv))load("glTexCoordP2uiv");
	glTexCoordP3ui = cast(typeof(glTexCoordP3ui))load("glTexCoordP3ui");
	glTexCoordP3uiv = cast(typeof(glTexCoordP3uiv))load("glTexCoordP3uiv");
	glTexCoordP4ui = cast(typeof(glTexCoordP4ui))load("glTexCoordP4ui");
	glTexCoordP4uiv = cast(typeof(glTexCoordP4uiv))load("glTexCoordP4uiv");
	glMultiTexCoordP1ui = cast(typeof(glMultiTexCoordP1ui))load("glMultiTexCoordP1ui");
	glMultiTexCoordP1uiv = cast(typeof(glMultiTexCoordP1uiv))load("glMultiTexCoordP1uiv");
	glMultiTexCoordP2ui = cast(typeof(glMultiTexCoordP2ui))load("glMultiTexCoordP2ui");
	glMultiTexCoordP2uiv = cast(typeof(glMultiTexCoordP2uiv))load("glMultiTexCoordP2uiv");
	glMultiTexCoordP3ui = cast(typeof(glMultiTexCoordP3ui))load("glMultiTexCoordP3ui");
	glMultiTexCoordP3uiv = cast(typeof(glMultiTexCoordP3uiv))load("glMultiTexCoordP3uiv");
	glMultiTexCoordP4ui = cast(typeof(glMultiTexCoordP4ui))load("glMultiTexCoordP4ui");
	glMultiTexCoordP4uiv = cast(typeof(glMultiTexCoordP4uiv))load("glMultiTexCoordP4uiv");
	glNormalP3ui = cast(typeof(glNormalP3ui))load("glNormalP3ui");
	glNormalP3uiv = cast(typeof(glNormalP3uiv))load("glNormalP3uiv");
	glColorP3ui = cast(typeof(glColorP3ui))load("glColorP3ui");
	glColorP3uiv = cast(typeof(glColorP3uiv))load("glColorP3uiv");
	glColorP4ui = cast(typeof(glColorP4ui))load("glColorP4ui");
	glColorP4uiv = cast(typeof(glColorP4uiv))load("glColorP4uiv");
	glSecondaryColorP3ui = cast(typeof(glSecondaryColorP3ui))load("glSecondaryColorP3ui");
	glSecondaryColorP3uiv = cast(typeof(glSecondaryColorP3uiv))load("glSecondaryColorP3uiv");
	return;
}

void load_GL_VERSION_4_0(Loader load) {
	if(!GL_VERSION_4_0) return;
	glMinSampleShading = cast(typeof(glMinSampleShading))load("glMinSampleShading");
	glBlendEquationi = cast(typeof(glBlendEquationi))load("glBlendEquationi");
	glBlendEquationSeparatei = cast(typeof(glBlendEquationSeparatei))load("glBlendEquationSeparatei");
	glBlendFunci = cast(typeof(glBlendFunci))load("glBlendFunci");
	glBlendFuncSeparatei = cast(typeof(glBlendFuncSeparatei))load("glBlendFuncSeparatei");
	glDrawArraysIndirect = cast(typeof(glDrawArraysIndirect))load("glDrawArraysIndirect");
	glDrawElementsIndirect = cast(typeof(glDrawElementsIndirect))load("glDrawElementsIndirect");
	glUniform1d = cast(typeof(glUniform1d))load("glUniform1d");
	glUniform2d = cast(typeof(glUniform2d))load("glUniform2d");
	glUniform3d = cast(typeof(glUniform3d))load("glUniform3d");
	glUniform4d = cast(typeof(glUniform4d))load("glUniform4d");
	glUniform1dv = cast(typeof(glUniform1dv))load("glUniform1dv");
	glUniform2dv = cast(typeof(glUniform2dv))load("glUniform2dv");
	glUniform3dv = cast(typeof(glUniform3dv))load("glUniform3dv");
	glUniform4dv = cast(typeof(glUniform4dv))load("glUniform4dv");
	glUniformMatrix2dv = cast(typeof(glUniformMatrix2dv))load("glUniformMatrix2dv");
	glUniformMatrix3dv = cast(typeof(glUniformMatrix3dv))load("glUniformMatrix3dv");
	glUniformMatrix4dv = cast(typeof(glUniformMatrix4dv))load("glUniformMatrix4dv");
	glUniformMatrix2x3dv = cast(typeof(glUniformMatrix2x3dv))load("glUniformMatrix2x3dv");
	glUniformMatrix2x4dv = cast(typeof(glUniformMatrix2x4dv))load("glUniformMatrix2x4dv");
	glUniformMatrix3x2dv = cast(typeof(glUniformMatrix3x2dv))load("glUniformMatrix3x2dv");
	glUniformMatrix3x4dv = cast(typeof(glUniformMatrix3x4dv))load("glUniformMatrix3x4dv");
	glUniformMatrix4x2dv = cast(typeof(glUniformMatrix4x2dv))load("glUniformMatrix4x2dv");
	glUniformMatrix4x3dv = cast(typeof(glUniformMatrix4x3dv))load("glUniformMatrix4x3dv");
	glGetUniformdv = cast(typeof(glGetUniformdv))load("glGetUniformdv");
	glGetSubroutineUniformLocation = cast(typeof(glGetSubroutineUniformLocation))load("glGetSubroutineUniformLocation");
	glGetSubroutineIndex = cast(typeof(glGetSubroutineIndex))load("glGetSubroutineIndex");
	glGetActiveSubroutineUniformiv = cast(typeof(glGetActiveSubroutineUniformiv))load("glGetActiveSubroutineUniformiv");
	glGetActiveSubroutineUniformName = cast(typeof(glGetActiveSubroutineUniformName))load("glGetActiveSubroutineUniformName");
	glGetActiveSubroutineName = cast(typeof(glGetActiveSubroutineName))load("glGetActiveSubroutineName");
	glUniformSubroutinesuiv = cast(typeof(glUniformSubroutinesuiv))load("glUniformSubroutinesuiv");
	glGetUniformSubroutineuiv = cast(typeof(glGetUniformSubroutineuiv))load("glGetUniformSubroutineuiv");
	glGetProgramStageiv = cast(typeof(glGetProgramStageiv))load("glGetProgramStageiv");
	glPatchParameteri = cast(typeof(glPatchParameteri))load("glPatchParameteri");
	glPatchParameterfv = cast(typeof(glPatchParameterfv))load("glPatchParameterfv");
	glBindTransformFeedback = cast(typeof(glBindTransformFeedback))load("glBindTransformFeedback");
	glDeleteTransformFeedbacks = cast(typeof(glDeleteTransformFeedbacks))load("glDeleteTransformFeedbacks");
	glGenTransformFeedbacks = cast(typeof(glGenTransformFeedbacks))load("glGenTransformFeedbacks");
	glIsTransformFeedback = cast(typeof(glIsTransformFeedback))load("glIsTransformFeedback");
	glPauseTransformFeedback = cast(typeof(glPauseTransformFeedback))load("glPauseTransformFeedback");
	glResumeTransformFeedback = cast(typeof(glResumeTransformFeedback))load("glResumeTransformFeedback");
	glDrawTransformFeedback = cast(typeof(glDrawTransformFeedback))load("glDrawTransformFeedback");
	glDrawTransformFeedbackStream = cast(typeof(glDrawTransformFeedbackStream))load("glDrawTransformFeedbackStream");
	glBeginQueryIndexed = cast(typeof(glBeginQueryIndexed))load("glBeginQueryIndexed");
	glEndQueryIndexed = cast(typeof(glEndQueryIndexed))load("glEndQueryIndexed");
	glGetQueryIndexediv = cast(typeof(glGetQueryIndexediv))load("glGetQueryIndexediv");
	return;
}

void load_GL_VERSION_4_1(Loader load) {
	if(!GL_VERSION_4_1) return;
	glReleaseShaderCompiler = cast(typeof(glReleaseShaderCompiler))load("glReleaseShaderCompiler");
	glShaderBinary = cast(typeof(glShaderBinary))load("glShaderBinary");
	glGetShaderPrecisionFormat = cast(typeof(glGetShaderPrecisionFormat))load("glGetShaderPrecisionFormat");
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef");
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf");
	glGetProgramBinary = cast(typeof(glGetProgramBinary))load("glGetProgramBinary");
	glProgramBinary = cast(typeof(glProgramBinary))load("glProgramBinary");
	glProgramParameteri = cast(typeof(glProgramParameteri))load("glProgramParameteri");
	glUseProgramStages = cast(typeof(glUseProgramStages))load("glUseProgramStages");
	glActiveShaderProgram = cast(typeof(glActiveShaderProgram))load("glActiveShaderProgram");
	glCreateShaderProgramv = cast(typeof(glCreateShaderProgramv))load("glCreateShaderProgramv");
	glBindProgramPipeline = cast(typeof(glBindProgramPipeline))load("glBindProgramPipeline");
	glDeleteProgramPipelines = cast(typeof(glDeleteProgramPipelines))load("glDeleteProgramPipelines");
	glGenProgramPipelines = cast(typeof(glGenProgramPipelines))load("glGenProgramPipelines");
	glIsProgramPipeline = cast(typeof(glIsProgramPipeline))load("glIsProgramPipeline");
	glGetProgramPipelineiv = cast(typeof(glGetProgramPipelineiv))load("glGetProgramPipelineiv");
	glProgramUniform1i = cast(typeof(glProgramUniform1i))load("glProgramUniform1i");
	glProgramUniform1iv = cast(typeof(glProgramUniform1iv))load("glProgramUniform1iv");
	glProgramUniform1f = cast(typeof(glProgramUniform1f))load("glProgramUniform1f");
	glProgramUniform1fv = cast(typeof(glProgramUniform1fv))load("glProgramUniform1fv");
	glProgramUniform1d = cast(typeof(glProgramUniform1d))load("glProgramUniform1d");
	glProgramUniform1dv = cast(typeof(glProgramUniform1dv))load("glProgramUniform1dv");
	glProgramUniform1ui = cast(typeof(glProgramUniform1ui))load("glProgramUniform1ui");
	glProgramUniform1uiv = cast(typeof(glProgramUniform1uiv))load("glProgramUniform1uiv");
	glProgramUniform2i = cast(typeof(glProgramUniform2i))load("glProgramUniform2i");
	glProgramUniform2iv = cast(typeof(glProgramUniform2iv))load("glProgramUniform2iv");
	glProgramUniform2f = cast(typeof(glProgramUniform2f))load("glProgramUniform2f");
	glProgramUniform2fv = cast(typeof(glProgramUniform2fv))load("glProgramUniform2fv");
	glProgramUniform2d = cast(typeof(glProgramUniform2d))load("glProgramUniform2d");
	glProgramUniform2dv = cast(typeof(glProgramUniform2dv))load("glProgramUniform2dv");
	glProgramUniform2ui = cast(typeof(glProgramUniform2ui))load("glProgramUniform2ui");
	glProgramUniform2uiv = cast(typeof(glProgramUniform2uiv))load("glProgramUniform2uiv");
	glProgramUniform3i = cast(typeof(glProgramUniform3i))load("glProgramUniform3i");
	glProgramUniform3iv = cast(typeof(glProgramUniform3iv))load("glProgramUniform3iv");
	glProgramUniform3f = cast(typeof(glProgramUniform3f))load("glProgramUniform3f");
	glProgramUniform3fv = cast(typeof(glProgramUniform3fv))load("glProgramUniform3fv");
	glProgramUniform3d = cast(typeof(glProgramUniform3d))load("glProgramUniform3d");
	glProgramUniform3dv = cast(typeof(glProgramUniform3dv))load("glProgramUniform3dv");
	glProgramUniform3ui = cast(typeof(glProgramUniform3ui))load("glProgramUniform3ui");
	glProgramUniform3uiv = cast(typeof(glProgramUniform3uiv))load("glProgramUniform3uiv");
	glProgramUniform4i = cast(typeof(glProgramUniform4i))load("glProgramUniform4i");
	glProgramUniform4iv = cast(typeof(glProgramUniform4iv))load("glProgramUniform4iv");
	glProgramUniform4f = cast(typeof(glProgramUniform4f))load("glProgramUniform4f");
	glProgramUniform4fv = cast(typeof(glProgramUniform4fv))load("glProgramUniform4fv");
	glProgramUniform4d = cast(typeof(glProgramUniform4d))load("glProgramUniform4d");
	glProgramUniform4dv = cast(typeof(glProgramUniform4dv))load("glProgramUniform4dv");
	glProgramUniform4ui = cast(typeof(glProgramUniform4ui))load("glProgramUniform4ui");
	glProgramUniform4uiv = cast(typeof(glProgramUniform4uiv))load("glProgramUniform4uiv");
	glProgramUniformMatrix2fv = cast(typeof(glProgramUniformMatrix2fv))load("glProgramUniformMatrix2fv");
	glProgramUniformMatrix3fv = cast(typeof(glProgramUniformMatrix3fv))load("glProgramUniformMatrix3fv");
	glProgramUniformMatrix4fv = cast(typeof(glProgramUniformMatrix4fv))load("glProgramUniformMatrix4fv");
	glProgramUniformMatrix2dv = cast(typeof(glProgramUniformMatrix2dv))load("glProgramUniformMatrix2dv");
	glProgramUniformMatrix3dv = cast(typeof(glProgramUniformMatrix3dv))load("glProgramUniformMatrix3dv");
	glProgramUniformMatrix4dv = cast(typeof(glProgramUniformMatrix4dv))load("glProgramUniformMatrix4dv");
	glProgramUniformMatrix2x3fv = cast(typeof(glProgramUniformMatrix2x3fv))load("glProgramUniformMatrix2x3fv");
	glProgramUniformMatrix3x2fv = cast(typeof(glProgramUniformMatrix3x2fv))load("glProgramUniformMatrix3x2fv");
	glProgramUniformMatrix2x4fv = cast(typeof(glProgramUniformMatrix2x4fv))load("glProgramUniformMatrix2x4fv");
	glProgramUniformMatrix4x2fv = cast(typeof(glProgramUniformMatrix4x2fv))load("glProgramUniformMatrix4x2fv");
	glProgramUniformMatrix3x4fv = cast(typeof(glProgramUniformMatrix3x4fv))load("glProgramUniformMatrix3x4fv");
	glProgramUniformMatrix4x3fv = cast(typeof(glProgramUniformMatrix4x3fv))load("glProgramUniformMatrix4x3fv");
	glProgramUniformMatrix2x3dv = cast(typeof(glProgramUniformMatrix2x3dv))load("glProgramUniformMatrix2x3dv");
	glProgramUniformMatrix3x2dv = cast(typeof(glProgramUniformMatrix3x2dv))load("glProgramUniformMatrix3x2dv");
	glProgramUniformMatrix2x4dv = cast(typeof(glProgramUniformMatrix2x4dv))load("glProgramUniformMatrix2x4dv");
	glProgramUniformMatrix4x2dv = cast(typeof(glProgramUniformMatrix4x2dv))load("glProgramUniformMatrix4x2dv");
	glProgramUniformMatrix3x4dv = cast(typeof(glProgramUniformMatrix3x4dv))load("glProgramUniformMatrix3x4dv");
	glProgramUniformMatrix4x3dv = cast(typeof(glProgramUniformMatrix4x3dv))load("glProgramUniformMatrix4x3dv");
	glValidateProgramPipeline = cast(typeof(glValidateProgramPipeline))load("glValidateProgramPipeline");
	glGetProgramPipelineInfoLog = cast(typeof(glGetProgramPipelineInfoLog))load("glGetProgramPipelineInfoLog");
	glVertexAttribL1d = cast(typeof(glVertexAttribL1d))load("glVertexAttribL1d");
	glVertexAttribL2d = cast(typeof(glVertexAttribL2d))load("glVertexAttribL2d");
	glVertexAttribL3d = cast(typeof(glVertexAttribL3d))load("glVertexAttribL3d");
	glVertexAttribL4d = cast(typeof(glVertexAttribL4d))load("glVertexAttribL4d");
	glVertexAttribL1dv = cast(typeof(glVertexAttribL1dv))load("glVertexAttribL1dv");
	glVertexAttribL2dv = cast(typeof(glVertexAttribL2dv))load("glVertexAttribL2dv");
	glVertexAttribL3dv = cast(typeof(glVertexAttribL3dv))load("glVertexAttribL3dv");
	glVertexAttribL4dv = cast(typeof(glVertexAttribL4dv))load("glVertexAttribL4dv");
	glVertexAttribLPointer = cast(typeof(glVertexAttribLPointer))load("glVertexAttribLPointer");
	glGetVertexAttribLdv = cast(typeof(glGetVertexAttribLdv))load("glGetVertexAttribLdv");
	glViewportArrayv = cast(typeof(glViewportArrayv))load("glViewportArrayv");
	glViewportIndexedf = cast(typeof(glViewportIndexedf))load("glViewportIndexedf");
	glViewportIndexedfv = cast(typeof(glViewportIndexedfv))load("glViewportIndexedfv");
	glScissorArrayv = cast(typeof(glScissorArrayv))load("glScissorArrayv");
	glScissorIndexed = cast(typeof(glScissorIndexed))load("glScissorIndexed");
	glScissorIndexedv = cast(typeof(glScissorIndexedv))load("glScissorIndexedv");
	glDepthRangeArrayv = cast(typeof(glDepthRangeArrayv))load("glDepthRangeArrayv");
	glDepthRangeIndexed = cast(typeof(glDepthRangeIndexed))load("glDepthRangeIndexed");
	glGetFloati_v = cast(typeof(glGetFloati_v))load("glGetFloati_v");
	glGetDoublei_v = cast(typeof(glGetDoublei_v))load("glGetDoublei_v");
	return;
}

void load_GL_VERSION_4_2(Loader load) {
	if(!GL_VERSION_4_2) return;
	glDrawArraysInstancedBaseInstance = cast(typeof(glDrawArraysInstancedBaseInstance))load("glDrawArraysInstancedBaseInstance");
	glDrawElementsInstancedBaseInstance = cast(typeof(glDrawElementsInstancedBaseInstance))load("glDrawElementsInstancedBaseInstance");
	glDrawElementsInstancedBaseVertexBaseInstance = cast(typeof(glDrawElementsInstancedBaseVertexBaseInstance))load("glDrawElementsInstancedBaseVertexBaseInstance");
	glGetInternalformativ = cast(typeof(glGetInternalformativ))load("glGetInternalformativ");
	glGetActiveAtomicCounterBufferiv = cast(typeof(glGetActiveAtomicCounterBufferiv))load("glGetActiveAtomicCounterBufferiv");
	glBindImageTexture = cast(typeof(glBindImageTexture))load("glBindImageTexture");
	glMemoryBarrier = cast(typeof(glMemoryBarrier))load("glMemoryBarrier");
	glTexStorage1D = cast(typeof(glTexStorage1D))load("glTexStorage1D");
	glTexStorage2D = cast(typeof(glTexStorage2D))load("glTexStorage2D");
	glTexStorage3D = cast(typeof(glTexStorage3D))load("glTexStorage3D");
	glDrawTransformFeedbackInstanced = cast(typeof(glDrawTransformFeedbackInstanced))load("glDrawTransformFeedbackInstanced");
	glDrawTransformFeedbackStreamInstanced = cast(typeof(glDrawTransformFeedbackStreamInstanced))load("glDrawTransformFeedbackStreamInstanced");
	return;
}

void load_GL_VERSION_4_3(Loader load) {
	if(!GL_VERSION_4_3) return;
	glClearBufferData = cast(typeof(glClearBufferData))load("glClearBufferData");
	glClearBufferSubData = cast(typeof(glClearBufferSubData))load("glClearBufferSubData");
	glDispatchCompute = cast(typeof(glDispatchCompute))load("glDispatchCompute");
	glDispatchComputeIndirect = cast(typeof(glDispatchComputeIndirect))load("glDispatchComputeIndirect");
	glCopyImageSubData = cast(typeof(glCopyImageSubData))load("glCopyImageSubData");
	glFramebufferParameteri = cast(typeof(glFramebufferParameteri))load("glFramebufferParameteri");
	glGetFramebufferParameteriv = cast(typeof(glGetFramebufferParameteriv))load("glGetFramebufferParameteriv");
	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v");
	glInvalidateTexSubImage = cast(typeof(glInvalidateTexSubImage))load("glInvalidateTexSubImage");
	glInvalidateTexImage = cast(typeof(glInvalidateTexImage))load("glInvalidateTexImage");
	glInvalidateBufferSubData = cast(typeof(glInvalidateBufferSubData))load("glInvalidateBufferSubData");
	glInvalidateBufferData = cast(typeof(glInvalidateBufferData))load("glInvalidateBufferData");
	glInvalidateFramebuffer = cast(typeof(glInvalidateFramebuffer))load("glInvalidateFramebuffer");
	glInvalidateSubFramebuffer = cast(typeof(glInvalidateSubFramebuffer))load("glInvalidateSubFramebuffer");
	glMultiDrawArraysIndirect = cast(typeof(glMultiDrawArraysIndirect))load("glMultiDrawArraysIndirect");
	glMultiDrawElementsIndirect = cast(typeof(glMultiDrawElementsIndirect))load("glMultiDrawElementsIndirect");
	glGetProgramInterfaceiv = cast(typeof(glGetProgramInterfaceiv))load("glGetProgramInterfaceiv");
	glGetProgramResourceIndex = cast(typeof(glGetProgramResourceIndex))load("glGetProgramResourceIndex");
	glGetProgramResourceName = cast(typeof(glGetProgramResourceName))load("glGetProgramResourceName");
	glGetProgramResourceiv = cast(typeof(glGetProgramResourceiv))load("glGetProgramResourceiv");
	glGetProgramResourceLocation = cast(typeof(glGetProgramResourceLocation))load("glGetProgramResourceLocation");
	glGetProgramResourceLocationIndex = cast(typeof(glGetProgramResourceLocationIndex))load("glGetProgramResourceLocationIndex");
	glShaderStorageBlockBinding = cast(typeof(glShaderStorageBlockBinding))load("glShaderStorageBlockBinding");
	glTexBufferRange = cast(typeof(glTexBufferRange))load("glTexBufferRange");
	glTexStorage2DMultisample = cast(typeof(glTexStorage2DMultisample))load("glTexStorage2DMultisample");
	glTexStorage3DMultisample = cast(typeof(glTexStorage3DMultisample))load("glTexStorage3DMultisample");
	glTextureView = cast(typeof(glTextureView))load("glTextureView");
	glBindVertexBuffer = cast(typeof(glBindVertexBuffer))load("glBindVertexBuffer");
	glVertexAttribFormat = cast(typeof(glVertexAttribFormat))load("glVertexAttribFormat");
	glVertexAttribIFormat = cast(typeof(glVertexAttribIFormat))load("glVertexAttribIFormat");
	glVertexAttribLFormat = cast(typeof(glVertexAttribLFormat))load("glVertexAttribLFormat");
	glVertexAttribBinding = cast(typeof(glVertexAttribBinding))load("glVertexAttribBinding");
	glVertexBindingDivisor = cast(typeof(glVertexBindingDivisor))load("glVertexBindingDivisor");
	glDebugMessageControl = cast(typeof(glDebugMessageControl))load("glDebugMessageControl");
	glDebugMessageInsert = cast(typeof(glDebugMessageInsert))load("glDebugMessageInsert");
	glDebugMessageCallback = cast(typeof(glDebugMessageCallback))load("glDebugMessageCallback");
	glGetDebugMessageLog = cast(typeof(glGetDebugMessageLog))load("glGetDebugMessageLog");
	glPushDebugGroup = cast(typeof(glPushDebugGroup))load("glPushDebugGroup");
	glPopDebugGroup = cast(typeof(glPopDebugGroup))load("glPopDebugGroup");
	glObjectLabel = cast(typeof(glObjectLabel))load("glObjectLabel");
	glGetObjectLabel = cast(typeof(glGetObjectLabel))load("glGetObjectLabel");
	glObjectPtrLabel = cast(typeof(glObjectPtrLabel))load("glObjectPtrLabel");
	glGetObjectPtrLabel = cast(typeof(glGetObjectPtrLabel))load("glGetObjectPtrLabel");
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv");
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv");
	return;
}

void load_GL_VERSION_4_4(Loader load) {
	if(!GL_VERSION_4_4) return;
	glBufferStorage = cast(typeof(glBufferStorage))load("glBufferStorage");
	glClearTexImage = cast(typeof(glClearTexImage))load("glClearTexImage");
	glClearTexSubImage = cast(typeof(glClearTexSubImage))load("glClearTexSubImage");
	glBindBuffersBase = cast(typeof(glBindBuffersBase))load("glBindBuffersBase");
	glBindBuffersRange = cast(typeof(glBindBuffersRange))load("glBindBuffersRange");
	glBindTextures = cast(typeof(glBindTextures))load("glBindTextures");
	glBindSamplers = cast(typeof(glBindSamplers))load("glBindSamplers");
	glBindImageTextures = cast(typeof(glBindImageTextures))load("glBindImageTextures");
	glBindVertexBuffers = cast(typeof(glBindVertexBuffers))load("glBindVertexBuffers");
	return;
}

void load_GL_VERSION_4_5(Loader load) {
	if(!GL_VERSION_4_5) return;
	glClipControl = cast(typeof(glClipControl))load("glClipControl");
	glCreateTransformFeedbacks = cast(typeof(glCreateTransformFeedbacks))load("glCreateTransformFeedbacks");
	glTransformFeedbackBufferBase = cast(typeof(glTransformFeedbackBufferBase))load("glTransformFeedbackBufferBase");
	glTransformFeedbackBufferRange = cast(typeof(glTransformFeedbackBufferRange))load("glTransformFeedbackBufferRange");
	glGetTransformFeedbackiv = cast(typeof(glGetTransformFeedbackiv))load("glGetTransformFeedbackiv");
	glGetTransformFeedbacki_v = cast(typeof(glGetTransformFeedbacki_v))load("glGetTransformFeedbacki_v");
	glGetTransformFeedbacki64_v = cast(typeof(glGetTransformFeedbacki64_v))load("glGetTransformFeedbacki64_v");
	glCreateBuffers = cast(typeof(glCreateBuffers))load("glCreateBuffers");
	glNamedBufferStorage = cast(typeof(glNamedBufferStorage))load("glNamedBufferStorage");
	glNamedBufferData = cast(typeof(glNamedBufferData))load("glNamedBufferData");
	glNamedBufferSubData = cast(typeof(glNamedBufferSubData))load("glNamedBufferSubData");
	glCopyNamedBufferSubData = cast(typeof(glCopyNamedBufferSubData))load("glCopyNamedBufferSubData");
	glClearNamedBufferData = cast(typeof(glClearNamedBufferData))load("glClearNamedBufferData");
	glClearNamedBufferSubData = cast(typeof(glClearNamedBufferSubData))load("glClearNamedBufferSubData");
	glMapNamedBuffer = cast(typeof(glMapNamedBuffer))load("glMapNamedBuffer");
	glMapNamedBufferRange = cast(typeof(glMapNamedBufferRange))load("glMapNamedBufferRange");
	glUnmapNamedBuffer = cast(typeof(glUnmapNamedBuffer))load("glUnmapNamedBuffer");
	glFlushMappedNamedBufferRange = cast(typeof(glFlushMappedNamedBufferRange))load("glFlushMappedNamedBufferRange");
	glGetNamedBufferParameteriv = cast(typeof(glGetNamedBufferParameteriv))load("glGetNamedBufferParameteriv");
	glGetNamedBufferParameteri64v = cast(typeof(glGetNamedBufferParameteri64v))load("glGetNamedBufferParameteri64v");
	glGetNamedBufferPointerv = cast(typeof(glGetNamedBufferPointerv))load("glGetNamedBufferPointerv");
	glGetNamedBufferSubData = cast(typeof(glGetNamedBufferSubData))load("glGetNamedBufferSubData");
	glCreateFramebuffers = cast(typeof(glCreateFramebuffers))load("glCreateFramebuffers");
	glNamedFramebufferRenderbuffer = cast(typeof(glNamedFramebufferRenderbuffer))load("glNamedFramebufferRenderbuffer");
	glNamedFramebufferParameteri = cast(typeof(glNamedFramebufferParameteri))load("glNamedFramebufferParameteri");
	glNamedFramebufferTexture = cast(typeof(glNamedFramebufferTexture))load("glNamedFramebufferTexture");
	glNamedFramebufferTextureLayer = cast(typeof(glNamedFramebufferTextureLayer))load("glNamedFramebufferTextureLayer");
	glNamedFramebufferDrawBuffer = cast(typeof(glNamedFramebufferDrawBuffer))load("glNamedFramebufferDrawBuffer");
	glNamedFramebufferDrawBuffers = cast(typeof(glNamedFramebufferDrawBuffers))load("glNamedFramebufferDrawBuffers");
	glNamedFramebufferReadBuffer = cast(typeof(glNamedFramebufferReadBuffer))load("glNamedFramebufferReadBuffer");
	glInvalidateNamedFramebufferData = cast(typeof(glInvalidateNamedFramebufferData))load("glInvalidateNamedFramebufferData");
	glInvalidateNamedFramebufferSubData = cast(typeof(glInvalidateNamedFramebufferSubData))load("glInvalidateNamedFramebufferSubData");
	glClearNamedFramebufferiv = cast(typeof(glClearNamedFramebufferiv))load("glClearNamedFramebufferiv");
	glClearNamedFramebufferuiv = cast(typeof(glClearNamedFramebufferuiv))load("glClearNamedFramebufferuiv");
	glClearNamedFramebufferfv = cast(typeof(glClearNamedFramebufferfv))load("glClearNamedFramebufferfv");
	glClearNamedFramebufferfi = cast(typeof(glClearNamedFramebufferfi))load("glClearNamedFramebufferfi");
	glBlitNamedFramebuffer = cast(typeof(glBlitNamedFramebuffer))load("glBlitNamedFramebuffer");
	glCheckNamedFramebufferStatus = cast(typeof(glCheckNamedFramebufferStatus))load("glCheckNamedFramebufferStatus");
	glGetNamedFramebufferParameteriv = cast(typeof(glGetNamedFramebufferParameteriv))load("glGetNamedFramebufferParameteriv");
	glGetNamedFramebufferAttachmentParameteriv = cast(typeof(glGetNamedFramebufferAttachmentParameteriv))load("glGetNamedFramebufferAttachmentParameteriv");
	glCreateRenderbuffers = cast(typeof(glCreateRenderbuffers))load("glCreateRenderbuffers");
	glNamedRenderbufferStorage = cast(typeof(glNamedRenderbufferStorage))load("glNamedRenderbufferStorage");
	glNamedRenderbufferStorageMultisample = cast(typeof(glNamedRenderbufferStorageMultisample))load("glNamedRenderbufferStorageMultisample");
	glGetNamedRenderbufferParameteriv = cast(typeof(glGetNamedRenderbufferParameteriv))load("glGetNamedRenderbufferParameteriv");
	glCreateTextures = cast(typeof(glCreateTextures))load("glCreateTextures");
	glTextureBuffer = cast(typeof(glTextureBuffer))load("glTextureBuffer");
	glTextureBufferRange = cast(typeof(glTextureBufferRange))load("glTextureBufferRange");
	glTextureStorage1D = cast(typeof(glTextureStorage1D))load("glTextureStorage1D");
	glTextureStorage2D = cast(typeof(glTextureStorage2D))load("glTextureStorage2D");
	glTextureStorage3D = cast(typeof(glTextureStorage3D))load("glTextureStorage3D");
	glTextureStorage2DMultisample = cast(typeof(glTextureStorage2DMultisample))load("glTextureStorage2DMultisample");
	glTextureStorage3DMultisample = cast(typeof(glTextureStorage3DMultisample))load("glTextureStorage3DMultisample");
	glTextureSubImage1D = cast(typeof(glTextureSubImage1D))load("glTextureSubImage1D");
	glTextureSubImage2D = cast(typeof(glTextureSubImage2D))load("glTextureSubImage2D");
	glTextureSubImage3D = cast(typeof(glTextureSubImage3D))load("glTextureSubImage3D");
	glCompressedTextureSubImage1D = cast(typeof(glCompressedTextureSubImage1D))load("glCompressedTextureSubImage1D");
	glCompressedTextureSubImage2D = cast(typeof(glCompressedTextureSubImage2D))load("glCompressedTextureSubImage2D");
	glCompressedTextureSubImage3D = cast(typeof(glCompressedTextureSubImage3D))load("glCompressedTextureSubImage3D");
	glCopyTextureSubImage1D = cast(typeof(glCopyTextureSubImage1D))load("glCopyTextureSubImage1D");
	glCopyTextureSubImage2D = cast(typeof(glCopyTextureSubImage2D))load("glCopyTextureSubImage2D");
	glCopyTextureSubImage3D = cast(typeof(glCopyTextureSubImage3D))load("glCopyTextureSubImage3D");
	glTextureParameterf = cast(typeof(glTextureParameterf))load("glTextureParameterf");
	glTextureParameterfv = cast(typeof(glTextureParameterfv))load("glTextureParameterfv");
	glTextureParameteri = cast(typeof(glTextureParameteri))load("glTextureParameteri");
	glTextureParameterIiv = cast(typeof(glTextureParameterIiv))load("glTextureParameterIiv");
	glTextureParameterIuiv = cast(typeof(glTextureParameterIuiv))load("glTextureParameterIuiv");
	glTextureParameteriv = cast(typeof(glTextureParameteriv))load("glTextureParameteriv");
	glGenerateTextureMipmap = cast(typeof(glGenerateTextureMipmap))load("glGenerateTextureMipmap");
	glBindTextureUnit = cast(typeof(glBindTextureUnit))load("glBindTextureUnit");
	glGetTextureImage = cast(typeof(glGetTextureImage))load("glGetTextureImage");
	glGetCompressedTextureImage = cast(typeof(glGetCompressedTextureImage))load("glGetCompressedTextureImage");
	glGetTextureLevelParameterfv = cast(typeof(glGetTextureLevelParameterfv))load("glGetTextureLevelParameterfv");
	glGetTextureLevelParameteriv = cast(typeof(glGetTextureLevelParameteriv))load("glGetTextureLevelParameteriv");
	glGetTextureParameterfv = cast(typeof(glGetTextureParameterfv))load("glGetTextureParameterfv");
	glGetTextureParameterIiv = cast(typeof(glGetTextureParameterIiv))load("glGetTextureParameterIiv");
	glGetTextureParameterIuiv = cast(typeof(glGetTextureParameterIuiv))load("glGetTextureParameterIuiv");
	glGetTextureParameteriv = cast(typeof(glGetTextureParameteriv))load("glGetTextureParameteriv");
	glCreateVertexArrays = cast(typeof(glCreateVertexArrays))load("glCreateVertexArrays");
	glDisableVertexArrayAttrib = cast(typeof(glDisableVertexArrayAttrib))load("glDisableVertexArrayAttrib");
	glEnableVertexArrayAttrib = cast(typeof(glEnableVertexArrayAttrib))load("glEnableVertexArrayAttrib");
	glVertexArrayElementBuffer = cast(typeof(glVertexArrayElementBuffer))load("glVertexArrayElementBuffer");
	glVertexArrayVertexBuffer = cast(typeof(glVertexArrayVertexBuffer))load("glVertexArrayVertexBuffer");
	glVertexArrayVertexBuffers = cast(typeof(glVertexArrayVertexBuffers))load("glVertexArrayVertexBuffers");
	glVertexArrayAttribBinding = cast(typeof(glVertexArrayAttribBinding))load("glVertexArrayAttribBinding");
	glVertexArrayAttribFormat = cast(typeof(glVertexArrayAttribFormat))load("glVertexArrayAttribFormat");
	glVertexArrayAttribIFormat = cast(typeof(glVertexArrayAttribIFormat))load("glVertexArrayAttribIFormat");
	glVertexArrayAttribLFormat = cast(typeof(glVertexArrayAttribLFormat))load("glVertexArrayAttribLFormat");
	glVertexArrayBindingDivisor = cast(typeof(glVertexArrayBindingDivisor))load("glVertexArrayBindingDivisor");
	glGetVertexArrayiv = cast(typeof(glGetVertexArrayiv))load("glGetVertexArrayiv");
	glGetVertexArrayIndexediv = cast(typeof(glGetVertexArrayIndexediv))load("glGetVertexArrayIndexediv");
	glGetVertexArrayIndexed64iv = cast(typeof(glGetVertexArrayIndexed64iv))load("glGetVertexArrayIndexed64iv");
	glCreateSamplers = cast(typeof(glCreateSamplers))load("glCreateSamplers");
	glCreateProgramPipelines = cast(typeof(glCreateProgramPipelines))load("glCreateProgramPipelines");
	glCreateQueries = cast(typeof(glCreateQueries))load("glCreateQueries");
	glGetQueryBufferObjecti64v = cast(typeof(glGetQueryBufferObjecti64v))load("glGetQueryBufferObjecti64v");
	glGetQueryBufferObjectiv = cast(typeof(glGetQueryBufferObjectiv))load("glGetQueryBufferObjectiv");
	glGetQueryBufferObjectui64v = cast(typeof(glGetQueryBufferObjectui64v))load("glGetQueryBufferObjectui64v");
	glGetQueryBufferObjectuiv = cast(typeof(glGetQueryBufferObjectuiv))load("glGetQueryBufferObjectuiv");
	glMemoryBarrierByRegion = cast(typeof(glMemoryBarrierByRegion))load("glMemoryBarrierByRegion");
	glGetTextureSubImage = cast(typeof(glGetTextureSubImage))load("glGetTextureSubImage");
	glGetCompressedTextureSubImage = cast(typeof(glGetCompressedTextureSubImage))load("glGetCompressedTextureSubImage");
	glGetGraphicsResetStatus = cast(typeof(glGetGraphicsResetStatus))load("glGetGraphicsResetStatus");
	glGetnCompressedTexImage = cast(typeof(glGetnCompressedTexImage))load("glGetnCompressedTexImage");
	glGetnTexImage = cast(typeof(glGetnTexImage))load("glGetnTexImage");
	glGetnUniformdv = cast(typeof(glGetnUniformdv))load("glGetnUniformdv");
	glGetnUniformfv = cast(typeof(glGetnUniformfv))load("glGetnUniformfv");
	glGetnUniformiv = cast(typeof(glGetnUniformiv))load("glGetnUniformiv");
	glGetnUniformuiv = cast(typeof(glGetnUniformuiv))load("glGetnUniformuiv");
	glReadnPixels = cast(typeof(glReadnPixels))load("glReadnPixels");
	glGetnMapdv = cast(typeof(glGetnMapdv))load("glGetnMapdv");
	glGetnMapfv = cast(typeof(glGetnMapfv))load("glGetnMapfv");
	glGetnMapiv = cast(typeof(glGetnMapiv))load("glGetnMapiv");
	glGetnPixelMapfv = cast(typeof(glGetnPixelMapfv))load("glGetnPixelMapfv");
	glGetnPixelMapuiv = cast(typeof(glGetnPixelMapuiv))load("glGetnPixelMapuiv");
	glGetnPixelMapusv = cast(typeof(glGetnPixelMapusv))load("glGetnPixelMapusv");
	glGetnPolygonStipple = cast(typeof(glGetnPolygonStipple))load("glGetnPolygonStipple");
	glGetnColorTable = cast(typeof(glGetnColorTable))load("glGetnColorTable");
	glGetnConvolutionFilter = cast(typeof(glGetnConvolutionFilter))load("glGetnConvolutionFilter");
	glGetnSeparableFilter = cast(typeof(glGetnSeparableFilter))load("glGetnSeparableFilter");
	glGetnHistogram = cast(typeof(glGetnHistogram))load("glGetnHistogram");
	glGetnMinmax = cast(typeof(glGetnMinmax))load("glGetnMinmax");
	glTextureBarrier = cast(typeof(glTextureBarrier))load("glTextureBarrier");
	return;
}

void load_GL_APPLE_element_array(Loader load) {
	if(!GL_APPLE_element_array) return;
	glElementPointerAPPLE = cast(typeof(glElementPointerAPPLE))load("glElementPointerAPPLE");
	glDrawElementArrayAPPLE = cast(typeof(glDrawElementArrayAPPLE))load("glDrawElementArrayAPPLE");
	glDrawRangeElementArrayAPPLE = cast(typeof(glDrawRangeElementArrayAPPLE))load("glDrawRangeElementArrayAPPLE");
	glMultiDrawElementArrayAPPLE = cast(typeof(glMultiDrawElementArrayAPPLE))load("glMultiDrawElementArrayAPPLE");
	glMultiDrawRangeElementArrayAPPLE = cast(typeof(glMultiDrawRangeElementArrayAPPLE))load("glMultiDrawRangeElementArrayAPPLE");
	return;
}
void load_GL_AMD_multi_draw_indirect(Loader load) {
	if(!GL_AMD_multi_draw_indirect) return;
	glMultiDrawArraysIndirectAMD = cast(typeof(glMultiDrawArraysIndirectAMD))load("glMultiDrawArraysIndirectAMD");
	glMultiDrawElementsIndirectAMD = cast(typeof(glMultiDrawElementsIndirectAMD))load("glMultiDrawElementsIndirectAMD");
	return;
}
void load_GL_SGIX_tag_sample_buffer(Loader load) {
	if(!GL_SGIX_tag_sample_buffer) return;
	glTagSampleBufferSGIX = cast(typeof(glTagSampleBufferSGIX))load("glTagSampleBufferSGIX");
	return;
}
void load_GL_NV_point_sprite(Loader load) {
	if(!GL_NV_point_sprite) return;
	glPointParameteriNV = cast(typeof(glPointParameteriNV))load("glPointParameteriNV");
	glPointParameterivNV = cast(typeof(glPointParameterivNV))load("glPointParameterivNV");
	return;
}
void load_GL_ATI_separate_stencil(Loader load) {
	if(!GL_ATI_separate_stencil) return;
	glStencilOpSeparateATI = cast(typeof(glStencilOpSeparateATI))load("glStencilOpSeparateATI");
	glStencilFuncSeparateATI = cast(typeof(glStencilFuncSeparateATI))load("glStencilFuncSeparateATI");
	return;
}
void load_GL_EXT_texture_buffer_object(Loader load) {
	if(!GL_EXT_texture_buffer_object) return;
	glTexBufferEXT = cast(typeof(glTexBufferEXT))load("glTexBufferEXT");
	return;
}
void load_GL_ARB_vertex_blend(Loader load) {
	if(!GL_ARB_vertex_blend) return;
	glWeightbvARB = cast(typeof(glWeightbvARB))load("glWeightbvARB");
	glWeightsvARB = cast(typeof(glWeightsvARB))load("glWeightsvARB");
	glWeightivARB = cast(typeof(glWeightivARB))load("glWeightivARB");
	glWeightfvARB = cast(typeof(glWeightfvARB))load("glWeightfvARB");
	glWeightdvARB = cast(typeof(glWeightdvARB))load("glWeightdvARB");
	glWeightubvARB = cast(typeof(glWeightubvARB))load("glWeightubvARB");
	glWeightusvARB = cast(typeof(glWeightusvARB))load("glWeightusvARB");
	glWeightuivARB = cast(typeof(glWeightuivARB))load("glWeightuivARB");
	glWeightPointerARB = cast(typeof(glWeightPointerARB))load("glWeightPointerARB");
	glVertexBlendARB = cast(typeof(glVertexBlendARB))load("glVertexBlendARB");
	return;
}
void load_GL_OVR_multiview(Loader load) {
	if(!GL_OVR_multiview) return;
	glFramebufferTextureMultiviewOVR = cast(typeof(glFramebufferTextureMultiviewOVR))load("glFramebufferTextureMultiviewOVR");
	return;
}
void load_GL_ARB_program_interface_query(Loader load) {
	if(!GL_ARB_program_interface_query) return;
	glGetProgramInterfaceiv = cast(typeof(glGetProgramInterfaceiv))load("glGetProgramInterfaceiv");
	glGetProgramResourceIndex = cast(typeof(glGetProgramResourceIndex))load("glGetProgramResourceIndex");
	glGetProgramResourceName = cast(typeof(glGetProgramResourceName))load("glGetProgramResourceName");
	glGetProgramResourceiv = cast(typeof(glGetProgramResourceiv))load("glGetProgramResourceiv");
	glGetProgramResourceLocation = cast(typeof(glGetProgramResourceLocation))load("glGetProgramResourceLocation");
	glGetProgramResourceLocationIndex = cast(typeof(glGetProgramResourceLocationIndex))load("glGetProgramResourceLocationIndex");
	return;
}
void load_GL_EXT_index_func(Loader load) {
	if(!GL_EXT_index_func) return;
	glIndexFuncEXT = cast(typeof(glIndexFuncEXT))load("glIndexFuncEXT");
	return;
}
void load_GL_NV_shader_buffer_load(Loader load) {
	if(!GL_NV_shader_buffer_load) return;
	glMakeBufferResidentNV = cast(typeof(glMakeBufferResidentNV))load("glMakeBufferResidentNV");
	glMakeBufferNonResidentNV = cast(typeof(glMakeBufferNonResidentNV))load("glMakeBufferNonResidentNV");
	glIsBufferResidentNV = cast(typeof(glIsBufferResidentNV))load("glIsBufferResidentNV");
	glMakeNamedBufferResidentNV = cast(typeof(glMakeNamedBufferResidentNV))load("glMakeNamedBufferResidentNV");
	glMakeNamedBufferNonResidentNV = cast(typeof(glMakeNamedBufferNonResidentNV))load("glMakeNamedBufferNonResidentNV");
	glIsNamedBufferResidentNV = cast(typeof(glIsNamedBufferResidentNV))load("glIsNamedBufferResidentNV");
	glGetBufferParameterui64vNV = cast(typeof(glGetBufferParameterui64vNV))load("glGetBufferParameterui64vNV");
	glGetNamedBufferParameterui64vNV = cast(typeof(glGetNamedBufferParameterui64vNV))load("glGetNamedBufferParameterui64vNV");
	glGetIntegerui64vNV = cast(typeof(glGetIntegerui64vNV))load("glGetIntegerui64vNV");
	glUniformui64NV = cast(typeof(glUniformui64NV))load("glUniformui64NV");
	glUniformui64vNV = cast(typeof(glUniformui64vNV))load("glUniformui64vNV");
	glGetUniformui64vNV = cast(typeof(glGetUniformui64vNV))load("glGetUniformui64vNV");
	glProgramUniformui64NV = cast(typeof(glProgramUniformui64NV))load("glProgramUniformui64NV");
	glProgramUniformui64vNV = cast(typeof(glProgramUniformui64vNV))load("glProgramUniformui64vNV");
	return;
}
void load_GL_EXT_color_subtable(Loader load) {
	if(!GL_EXT_color_subtable) return;
	glColorSubTableEXT = cast(typeof(glColorSubTableEXT))load("glColorSubTableEXT");
	glCopyColorSubTableEXT = cast(typeof(glCopyColorSubTableEXT))load("glCopyColorSubTableEXT");
	return;
}
void load_GL_SUNX_constant_data(Loader load) {
	if(!GL_SUNX_constant_data) return;
	glFinishTextureSUNX = cast(typeof(glFinishTextureSUNX))load("glFinishTextureSUNX");
	return;
}
void load_GL_EXT_multi_draw_arrays(Loader load) {
	if(!GL_EXT_multi_draw_arrays) return;
	glMultiDrawArraysEXT = cast(typeof(glMultiDrawArraysEXT))load("glMultiDrawArraysEXT");
	glMultiDrawElementsEXT = cast(typeof(glMultiDrawElementsEXT))load("glMultiDrawElementsEXT");
	return;
}
void load_GL_ARB_shader_atomic_counters(Loader load) {
	if(!GL_ARB_shader_atomic_counters) return;
	glGetActiveAtomicCounterBufferiv = cast(typeof(glGetActiveAtomicCounterBufferiv))load("glGetActiveAtomicCounterBufferiv");
	return;
}
void load_GL_NV_conditional_render(Loader load) {
	if(!GL_NV_conditional_render) return;
	glBeginConditionalRenderNV = cast(typeof(glBeginConditionalRenderNV))load("glBeginConditionalRenderNV");
	glEndConditionalRenderNV = cast(typeof(glEndConditionalRenderNV))load("glEndConditionalRenderNV");
	return;
}
void load_GL_MESA_resize_buffers(Loader load) {
	if(!GL_MESA_resize_buffers) return;
	glResizeBuffersMESA = cast(typeof(glResizeBuffersMESA))load("glResizeBuffersMESA");
	return;
}
void load_GL_ARB_texture_view(Loader load) {
	if(!GL_ARB_texture_view) return;
	glTextureView = cast(typeof(glTextureView))load("glTextureView");
	return;
}
void load_GL_ARB_map_buffer_range(Loader load) {
	if(!GL_ARB_map_buffer_range) return;
	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange");
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange");
	return;
}
void load_GL_EXT_convolution(Loader load) {
	if(!GL_EXT_convolution) return;
	glConvolutionFilter1DEXT = cast(typeof(glConvolutionFilter1DEXT))load("glConvolutionFilter1DEXT");
	glConvolutionFilter2DEXT = cast(typeof(glConvolutionFilter2DEXT))load("glConvolutionFilter2DEXT");
	glConvolutionParameterfEXT = cast(typeof(glConvolutionParameterfEXT))load("glConvolutionParameterfEXT");
	glConvolutionParameterfvEXT = cast(typeof(glConvolutionParameterfvEXT))load("glConvolutionParameterfvEXT");
	glConvolutionParameteriEXT = cast(typeof(glConvolutionParameteriEXT))load("glConvolutionParameteriEXT");
	glConvolutionParameterivEXT = cast(typeof(glConvolutionParameterivEXT))load("glConvolutionParameterivEXT");
	glCopyConvolutionFilter1DEXT = cast(typeof(glCopyConvolutionFilter1DEXT))load("glCopyConvolutionFilter1DEXT");
	glCopyConvolutionFilter2DEXT = cast(typeof(glCopyConvolutionFilter2DEXT))load("glCopyConvolutionFilter2DEXT");
	glGetConvolutionFilterEXT = cast(typeof(glGetConvolutionFilterEXT))load("glGetConvolutionFilterEXT");
	glGetConvolutionParameterfvEXT = cast(typeof(glGetConvolutionParameterfvEXT))load("glGetConvolutionParameterfvEXT");
	glGetConvolutionParameterivEXT = cast(typeof(glGetConvolutionParameterivEXT))load("glGetConvolutionParameterivEXT");
	glGetSeparableFilterEXT = cast(typeof(glGetSeparableFilterEXT))load("glGetSeparableFilterEXT");
	glSeparableFilter2DEXT = cast(typeof(glSeparableFilter2DEXT))load("glSeparableFilter2DEXT");
	return;
}
void load_GL_NV_vertex_attrib_integer_64bit(Loader load) {
	if(!GL_NV_vertex_attrib_integer_64bit) return;
	glVertexAttribL1i64NV = cast(typeof(glVertexAttribL1i64NV))load("glVertexAttribL1i64NV");
	glVertexAttribL2i64NV = cast(typeof(glVertexAttribL2i64NV))load("glVertexAttribL2i64NV");
	glVertexAttribL3i64NV = cast(typeof(glVertexAttribL3i64NV))load("glVertexAttribL3i64NV");
	glVertexAttribL4i64NV = cast(typeof(glVertexAttribL4i64NV))load("glVertexAttribL4i64NV");
	glVertexAttribL1i64vNV = cast(typeof(glVertexAttribL1i64vNV))load("glVertexAttribL1i64vNV");
	glVertexAttribL2i64vNV = cast(typeof(glVertexAttribL2i64vNV))load("glVertexAttribL2i64vNV");
	glVertexAttribL3i64vNV = cast(typeof(glVertexAttribL3i64vNV))load("glVertexAttribL3i64vNV");
	glVertexAttribL4i64vNV = cast(typeof(glVertexAttribL4i64vNV))load("glVertexAttribL4i64vNV");
	glVertexAttribL1ui64NV = cast(typeof(glVertexAttribL1ui64NV))load("glVertexAttribL1ui64NV");
	glVertexAttribL2ui64NV = cast(typeof(glVertexAttribL2ui64NV))load("glVertexAttribL2ui64NV");
	glVertexAttribL3ui64NV = cast(typeof(glVertexAttribL3ui64NV))load("glVertexAttribL3ui64NV");
	glVertexAttribL4ui64NV = cast(typeof(glVertexAttribL4ui64NV))load("glVertexAttribL4ui64NV");
	glVertexAttribL1ui64vNV = cast(typeof(glVertexAttribL1ui64vNV))load("glVertexAttribL1ui64vNV");
	glVertexAttribL2ui64vNV = cast(typeof(glVertexAttribL2ui64vNV))load("glVertexAttribL2ui64vNV");
	glVertexAttribL3ui64vNV = cast(typeof(glVertexAttribL3ui64vNV))load("glVertexAttribL3ui64vNV");
	glVertexAttribL4ui64vNV = cast(typeof(glVertexAttribL4ui64vNV))load("glVertexAttribL4ui64vNV");
	glGetVertexAttribLi64vNV = cast(typeof(glGetVertexAttribLi64vNV))load("glGetVertexAttribLi64vNV");
	glGetVertexAttribLui64vNV = cast(typeof(glGetVertexAttribLui64vNV))load("glGetVertexAttribLui64vNV");
	glVertexAttribLFormatNV = cast(typeof(glVertexAttribLFormatNV))load("glVertexAttribLFormatNV");
	return;
}
void load_GL_EXT_paletted_texture(Loader load) {
	if(!GL_EXT_paletted_texture) return;
	glColorTableEXT = cast(typeof(glColorTableEXT))load("glColorTableEXT");
	glGetColorTableEXT = cast(typeof(glGetColorTableEXT))load("glGetColorTableEXT");
	glGetColorTableParameterivEXT = cast(typeof(glGetColorTableParameterivEXT))load("glGetColorTableParameterivEXT");
	glGetColorTableParameterfvEXT = cast(typeof(glGetColorTableParameterfvEXT))load("glGetColorTableParameterfvEXT");
	return;
}
void load_GL_ARB_texture_buffer_object(Loader load) {
	if(!GL_ARB_texture_buffer_object) return;
	glTexBufferARB = cast(typeof(glTexBufferARB))load("glTexBufferARB");
	return;
}
void load_GL_ATI_pn_triangles(Loader load) {
	if(!GL_ATI_pn_triangles) return;
	glPNTrianglesiATI = cast(typeof(glPNTrianglesiATI))load("glPNTrianglesiATI");
	glPNTrianglesfATI = cast(typeof(glPNTrianglesfATI))load("glPNTrianglesfATI");
	return;
}
void load_GL_SGIX_flush_raster(Loader load) {
	if(!GL_SGIX_flush_raster) return;
	glFlushRasterSGIX = cast(typeof(glFlushRasterSGIX))load("glFlushRasterSGIX");
	return;
}
void load_GL_EXT_light_texture(Loader load) {
	if(!GL_EXT_light_texture) return;
	glApplyTextureEXT = cast(typeof(glApplyTextureEXT))load("glApplyTextureEXT");
	glTextureLightEXT = cast(typeof(glTextureLightEXT))load("glTextureLightEXT");
	glTextureMaterialEXT = cast(typeof(glTextureMaterialEXT))load("glTextureMaterialEXT");
	return;
}
void load_GL_AMD_draw_buffers_blend(Loader load) {
	if(!GL_AMD_draw_buffers_blend) return;
	glBlendFuncIndexedAMD = cast(typeof(glBlendFuncIndexedAMD))load("glBlendFuncIndexedAMD");
	glBlendFuncSeparateIndexedAMD = cast(typeof(glBlendFuncSeparateIndexedAMD))load("glBlendFuncSeparateIndexedAMD");
	glBlendEquationIndexedAMD = cast(typeof(glBlendEquationIndexedAMD))load("glBlendEquationIndexedAMD");
	glBlendEquationSeparateIndexedAMD = cast(typeof(glBlendEquationSeparateIndexedAMD))load("glBlendEquationSeparateIndexedAMD");
	return;
}
void load_GL_APPLE_texture_range(Loader load) {
	if(!GL_APPLE_texture_range) return;
	glTextureRangeAPPLE = cast(typeof(glTextureRangeAPPLE))load("glTextureRangeAPPLE");
	glGetTexParameterPointervAPPLE = cast(typeof(glGetTexParameterPointervAPPLE))load("glGetTexParameterPointervAPPLE");
	return;
}
void load_GL_EXT_texture_array(Loader load) {
	if(!GL_EXT_texture_array) return;
	glFramebufferTextureLayerEXT = cast(typeof(glFramebufferTextureLayerEXT))load("glFramebufferTextureLayerEXT");
	return;
}
void load_GL_NV_texture_barrier(Loader load) {
	if(!GL_NV_texture_barrier) return;
	glTextureBarrierNV = cast(typeof(glTextureBarrierNV))load("glTextureBarrierNV");
	return;
}
void load_GL_ARB_vertex_type_2_10_10_10_rev(Loader load) {
	if(!GL_ARB_vertex_type_2_10_10_10_rev) return;
	glVertexAttribP1ui = cast(typeof(glVertexAttribP1ui))load("glVertexAttribP1ui");
	glVertexAttribP1uiv = cast(typeof(glVertexAttribP1uiv))load("glVertexAttribP1uiv");
	glVertexAttribP2ui = cast(typeof(glVertexAttribP2ui))load("glVertexAttribP2ui");
	glVertexAttribP2uiv = cast(typeof(glVertexAttribP2uiv))load("glVertexAttribP2uiv");
	glVertexAttribP3ui = cast(typeof(glVertexAttribP3ui))load("glVertexAttribP3ui");
	glVertexAttribP3uiv = cast(typeof(glVertexAttribP3uiv))load("glVertexAttribP3uiv");
	glVertexAttribP4ui = cast(typeof(glVertexAttribP4ui))load("glVertexAttribP4ui");
	glVertexAttribP4uiv = cast(typeof(glVertexAttribP4uiv))load("glVertexAttribP4uiv");
	glVertexP2ui = cast(typeof(glVertexP2ui))load("glVertexP2ui");
	glVertexP2uiv = cast(typeof(glVertexP2uiv))load("glVertexP2uiv");
	glVertexP3ui = cast(typeof(glVertexP3ui))load("glVertexP3ui");
	glVertexP3uiv = cast(typeof(glVertexP3uiv))load("glVertexP3uiv");
	glVertexP4ui = cast(typeof(glVertexP4ui))load("glVertexP4ui");
	glVertexP4uiv = cast(typeof(glVertexP4uiv))load("glVertexP4uiv");
	glTexCoordP1ui = cast(typeof(glTexCoordP1ui))load("glTexCoordP1ui");
	glTexCoordP1uiv = cast(typeof(glTexCoordP1uiv))load("glTexCoordP1uiv");
	glTexCoordP2ui = cast(typeof(glTexCoordP2ui))load("glTexCoordP2ui");
	glTexCoordP2uiv = cast(typeof(glTexCoordP2uiv))load("glTexCoordP2uiv");
	glTexCoordP3ui = cast(typeof(glTexCoordP3ui))load("glTexCoordP3ui");
	glTexCoordP3uiv = cast(typeof(glTexCoordP3uiv))load("glTexCoordP3uiv");
	glTexCoordP4ui = cast(typeof(glTexCoordP4ui))load("glTexCoordP4ui");
	glTexCoordP4uiv = cast(typeof(glTexCoordP4uiv))load("glTexCoordP4uiv");
	glMultiTexCoordP1ui = cast(typeof(glMultiTexCoordP1ui))load("glMultiTexCoordP1ui");
	glMultiTexCoordP1uiv = cast(typeof(glMultiTexCoordP1uiv))load("glMultiTexCoordP1uiv");
	glMultiTexCoordP2ui = cast(typeof(glMultiTexCoordP2ui))load("glMultiTexCoordP2ui");
	glMultiTexCoordP2uiv = cast(typeof(glMultiTexCoordP2uiv))load("glMultiTexCoordP2uiv");
	glMultiTexCoordP3ui = cast(typeof(glMultiTexCoordP3ui))load("glMultiTexCoordP3ui");
	glMultiTexCoordP3uiv = cast(typeof(glMultiTexCoordP3uiv))load("glMultiTexCoordP3uiv");
	glMultiTexCoordP4ui = cast(typeof(glMultiTexCoordP4ui))load("glMultiTexCoordP4ui");
	glMultiTexCoordP4uiv = cast(typeof(glMultiTexCoordP4uiv))load("glMultiTexCoordP4uiv");
	glNormalP3ui = cast(typeof(glNormalP3ui))load("glNormalP3ui");
	glNormalP3uiv = cast(typeof(glNormalP3uiv))load("glNormalP3uiv");
	glColorP3ui = cast(typeof(glColorP3ui))load("glColorP3ui");
	glColorP3uiv = cast(typeof(glColorP3uiv))load("glColorP3uiv");
	glColorP4ui = cast(typeof(glColorP4ui))load("glColorP4ui");
	glColorP4uiv = cast(typeof(glColorP4uiv))load("glColorP4uiv");
	glSecondaryColorP3ui = cast(typeof(glSecondaryColorP3ui))load("glSecondaryColorP3ui");
	glSecondaryColorP3uiv = cast(typeof(glSecondaryColorP3uiv))load("glSecondaryColorP3uiv");
	return;
}
void load_GL_3DFX_tbuffer(Loader load) {
	if(!GL_3DFX_tbuffer) return;
	glTbufferMask3DFX = cast(typeof(glTbufferMask3DFX))load("glTbufferMask3DFX");
	return;
}
void load_GL_GREMEDY_frame_terminator(Loader load) {
	if(!GL_GREMEDY_frame_terminator) return;
	glFrameTerminatorGREMEDY = cast(typeof(glFrameTerminatorGREMEDY))load("glFrameTerminatorGREMEDY");
	return;
}
void load_GL_ARB_blend_func_extended(Loader load) {
	if(!GL_ARB_blend_func_extended) return;
	glBindFragDataLocationIndexed = cast(typeof(glBindFragDataLocationIndexed))load("glBindFragDataLocationIndexed");
	glGetFragDataIndex = cast(typeof(glGetFragDataIndex))load("glGetFragDataIndex");
	return;
}
void load_GL_EXT_separate_shader_objects(Loader load) {
	if(!GL_EXT_separate_shader_objects) return;
	glUseShaderProgramEXT = cast(typeof(glUseShaderProgramEXT))load("glUseShaderProgramEXT");
	glActiveProgramEXT = cast(typeof(glActiveProgramEXT))load("glActiveProgramEXT");
	glCreateShaderProgramEXT = cast(typeof(glCreateShaderProgramEXT))load("glCreateShaderProgramEXT");
	glActiveShaderProgramEXT = cast(typeof(glActiveShaderProgramEXT))load("glActiveShaderProgramEXT");
	glBindProgramPipelineEXT = cast(typeof(glBindProgramPipelineEXT))load("glBindProgramPipelineEXT");
	glCreateShaderProgramvEXT = cast(typeof(glCreateShaderProgramvEXT))load("glCreateShaderProgramvEXT");
	glDeleteProgramPipelinesEXT = cast(typeof(glDeleteProgramPipelinesEXT))load("glDeleteProgramPipelinesEXT");
	glGenProgramPipelinesEXT = cast(typeof(glGenProgramPipelinesEXT))load("glGenProgramPipelinesEXT");
	glGetProgramPipelineInfoLogEXT = cast(typeof(glGetProgramPipelineInfoLogEXT))load("glGetProgramPipelineInfoLogEXT");
	glGetProgramPipelineivEXT = cast(typeof(glGetProgramPipelineivEXT))load("glGetProgramPipelineivEXT");
	glIsProgramPipelineEXT = cast(typeof(glIsProgramPipelineEXT))load("glIsProgramPipelineEXT");
	glProgramParameteriEXT = cast(typeof(glProgramParameteriEXT))load("glProgramParameteriEXT");
	glProgramUniform1fEXT = cast(typeof(glProgramUniform1fEXT))load("glProgramUniform1fEXT");
	glProgramUniform1fvEXT = cast(typeof(glProgramUniform1fvEXT))load("glProgramUniform1fvEXT");
	glProgramUniform1iEXT = cast(typeof(glProgramUniform1iEXT))load("glProgramUniform1iEXT");
	glProgramUniform1ivEXT = cast(typeof(glProgramUniform1ivEXT))load("glProgramUniform1ivEXT");
	glProgramUniform2fEXT = cast(typeof(glProgramUniform2fEXT))load("glProgramUniform2fEXT");
	glProgramUniform2fvEXT = cast(typeof(glProgramUniform2fvEXT))load("glProgramUniform2fvEXT");
	glProgramUniform2iEXT = cast(typeof(glProgramUniform2iEXT))load("glProgramUniform2iEXT");
	glProgramUniform2ivEXT = cast(typeof(glProgramUniform2ivEXT))load("glProgramUniform2ivEXT");
	glProgramUniform3fEXT = cast(typeof(glProgramUniform3fEXT))load("glProgramUniform3fEXT");
	glProgramUniform3fvEXT = cast(typeof(glProgramUniform3fvEXT))load("glProgramUniform3fvEXT");
	glProgramUniform3iEXT = cast(typeof(glProgramUniform3iEXT))load("glProgramUniform3iEXT");
	glProgramUniform3ivEXT = cast(typeof(glProgramUniform3ivEXT))load("glProgramUniform3ivEXT");
	glProgramUniform4fEXT = cast(typeof(glProgramUniform4fEXT))load("glProgramUniform4fEXT");
	glProgramUniform4fvEXT = cast(typeof(glProgramUniform4fvEXT))load("glProgramUniform4fvEXT");
	glProgramUniform4iEXT = cast(typeof(glProgramUniform4iEXT))load("glProgramUniform4iEXT");
	glProgramUniform4ivEXT = cast(typeof(glProgramUniform4ivEXT))load("glProgramUniform4ivEXT");
	glProgramUniformMatrix2fvEXT = cast(typeof(glProgramUniformMatrix2fvEXT))load("glProgramUniformMatrix2fvEXT");
	glProgramUniformMatrix3fvEXT = cast(typeof(glProgramUniformMatrix3fvEXT))load("glProgramUniformMatrix3fvEXT");
	glProgramUniformMatrix4fvEXT = cast(typeof(glProgramUniformMatrix4fvEXT))load("glProgramUniformMatrix4fvEXT");
	glUseProgramStagesEXT = cast(typeof(glUseProgramStagesEXT))load("glUseProgramStagesEXT");
	glValidateProgramPipelineEXT = cast(typeof(glValidateProgramPipelineEXT))load("glValidateProgramPipelineEXT");
	glProgramUniform1uiEXT = cast(typeof(glProgramUniform1uiEXT))load("glProgramUniform1uiEXT");
	glProgramUniform2uiEXT = cast(typeof(glProgramUniform2uiEXT))load("glProgramUniform2uiEXT");
	glProgramUniform3uiEXT = cast(typeof(glProgramUniform3uiEXT))load("glProgramUniform3uiEXT");
	glProgramUniform4uiEXT = cast(typeof(glProgramUniform4uiEXT))load("glProgramUniform4uiEXT");
	glProgramUniform1uivEXT = cast(typeof(glProgramUniform1uivEXT))load("glProgramUniform1uivEXT");
	glProgramUniform2uivEXT = cast(typeof(glProgramUniform2uivEXT))load("glProgramUniform2uivEXT");
	glProgramUniform3uivEXT = cast(typeof(glProgramUniform3uivEXT))load("glProgramUniform3uivEXT");
	glProgramUniform4uivEXT = cast(typeof(glProgramUniform4uivEXT))load("glProgramUniform4uivEXT");
	glProgramUniformMatrix4fvEXT = cast(typeof(glProgramUniformMatrix4fvEXT))load("glProgramUniformMatrix4fvEXT");
	glProgramUniformMatrix2x3fvEXT = cast(typeof(glProgramUniformMatrix2x3fvEXT))load("glProgramUniformMatrix2x3fvEXT");
	glProgramUniformMatrix3x2fvEXT = cast(typeof(glProgramUniformMatrix3x2fvEXT))load("glProgramUniformMatrix3x2fvEXT");
	glProgramUniformMatrix2x4fvEXT = cast(typeof(glProgramUniformMatrix2x4fvEXT))load("glProgramUniformMatrix2x4fvEXT");
	glProgramUniformMatrix4x2fvEXT = cast(typeof(glProgramUniformMatrix4x2fvEXT))load("glProgramUniformMatrix4x2fvEXT");
	glProgramUniformMatrix3x4fvEXT = cast(typeof(glProgramUniformMatrix3x4fvEXT))load("glProgramUniformMatrix3x4fvEXT");
	glProgramUniformMatrix4x3fvEXT = cast(typeof(glProgramUniformMatrix4x3fvEXT))load("glProgramUniformMatrix4x3fvEXT");
	return;
}
void load_GL_NV_texture_multisample(Loader load) {
	if(!GL_NV_texture_multisample) return;
	glTexImage2DMultisampleCoverageNV = cast(typeof(glTexImage2DMultisampleCoverageNV))load("glTexImage2DMultisampleCoverageNV");
	glTexImage3DMultisampleCoverageNV = cast(typeof(glTexImage3DMultisampleCoverageNV))load("glTexImage3DMultisampleCoverageNV");
	glTextureImage2DMultisampleNV = cast(typeof(glTextureImage2DMultisampleNV))load("glTextureImage2DMultisampleNV");
	glTextureImage3DMultisampleNV = cast(typeof(glTextureImage3DMultisampleNV))load("glTextureImage3DMultisampleNV");
	glTextureImage2DMultisampleCoverageNV = cast(typeof(glTextureImage2DMultisampleCoverageNV))load("glTextureImage2DMultisampleCoverageNV");
	glTextureImage3DMultisampleCoverageNV = cast(typeof(glTextureImage3DMultisampleCoverageNV))load("glTextureImage3DMultisampleCoverageNV");
	return;
}
void load_GL_ARB_shader_objects(Loader load) {
	if(!GL_ARB_shader_objects) return;
	glDeleteObjectARB = cast(typeof(glDeleteObjectARB))load("glDeleteObjectARB");
	glGetHandleARB = cast(typeof(glGetHandleARB))load("glGetHandleARB");
	glDetachObjectARB = cast(typeof(glDetachObjectARB))load("glDetachObjectARB");
	glCreateShaderObjectARB = cast(typeof(glCreateShaderObjectARB))load("glCreateShaderObjectARB");
	glShaderSourceARB = cast(typeof(glShaderSourceARB))load("glShaderSourceARB");
	glCompileShaderARB = cast(typeof(glCompileShaderARB))load("glCompileShaderARB");
	glCreateProgramObjectARB = cast(typeof(glCreateProgramObjectARB))load("glCreateProgramObjectARB");
	glAttachObjectARB = cast(typeof(glAttachObjectARB))load("glAttachObjectARB");
	glLinkProgramARB = cast(typeof(glLinkProgramARB))load("glLinkProgramARB");
	glUseProgramObjectARB = cast(typeof(glUseProgramObjectARB))load("glUseProgramObjectARB");
	glValidateProgramARB = cast(typeof(glValidateProgramARB))load("glValidateProgramARB");
	glUniform1fARB = cast(typeof(glUniform1fARB))load("glUniform1fARB");
	glUniform2fARB = cast(typeof(glUniform2fARB))load("glUniform2fARB");
	glUniform3fARB = cast(typeof(glUniform3fARB))load("glUniform3fARB");
	glUniform4fARB = cast(typeof(glUniform4fARB))load("glUniform4fARB");
	glUniform1iARB = cast(typeof(glUniform1iARB))load("glUniform1iARB");
	glUniform2iARB = cast(typeof(glUniform2iARB))load("glUniform2iARB");
	glUniform3iARB = cast(typeof(glUniform3iARB))load("glUniform3iARB");
	glUniform4iARB = cast(typeof(glUniform4iARB))load("glUniform4iARB");
	glUniform1fvARB = cast(typeof(glUniform1fvARB))load("glUniform1fvARB");
	glUniform2fvARB = cast(typeof(glUniform2fvARB))load("glUniform2fvARB");
	glUniform3fvARB = cast(typeof(glUniform3fvARB))load("glUniform3fvARB");
	glUniform4fvARB = cast(typeof(glUniform4fvARB))load("glUniform4fvARB");
	glUniform1ivARB = cast(typeof(glUniform1ivARB))load("glUniform1ivARB");
	glUniform2ivARB = cast(typeof(glUniform2ivARB))load("glUniform2ivARB");
	glUniform3ivARB = cast(typeof(glUniform3ivARB))load("glUniform3ivARB");
	glUniform4ivARB = cast(typeof(glUniform4ivARB))load("glUniform4ivARB");
	glUniformMatrix2fvARB = cast(typeof(glUniformMatrix2fvARB))load("glUniformMatrix2fvARB");
	glUniformMatrix3fvARB = cast(typeof(glUniformMatrix3fvARB))load("glUniformMatrix3fvARB");
	glUniformMatrix4fvARB = cast(typeof(glUniformMatrix4fvARB))load("glUniformMatrix4fvARB");
	glGetObjectParameterfvARB = cast(typeof(glGetObjectParameterfvARB))load("glGetObjectParameterfvARB");
	glGetObjectParameterivARB = cast(typeof(glGetObjectParameterivARB))load("glGetObjectParameterivARB");
	glGetInfoLogARB = cast(typeof(glGetInfoLogARB))load("glGetInfoLogARB");
	glGetAttachedObjectsARB = cast(typeof(glGetAttachedObjectsARB))load("glGetAttachedObjectsARB");
	glGetUniformLocationARB = cast(typeof(glGetUniformLocationARB))load("glGetUniformLocationARB");
	glGetActiveUniformARB = cast(typeof(glGetActiveUniformARB))load("glGetActiveUniformARB");
	glGetUniformfvARB = cast(typeof(glGetUniformfvARB))load("glGetUniformfvARB");
	glGetUniformivARB = cast(typeof(glGetUniformivARB))load("glGetUniformivARB");
	glGetShaderSourceARB = cast(typeof(glGetShaderSourceARB))load("glGetShaderSourceARB");
	return;
}
void load_GL_ARB_framebuffer_object(Loader load) {
	if(!GL_ARB_framebuffer_object) return;
	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer");
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer");
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers");
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers");
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage");
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv");
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer");
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer");
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers");
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers");
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus");
	glFramebufferTexture1D = cast(typeof(glFramebufferTexture1D))load("glFramebufferTexture1D");
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D");
	glFramebufferTexture3D = cast(typeof(glFramebufferTexture3D))load("glFramebufferTexture3D");
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer");
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv");
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap");
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer");
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample");
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer");
	return;
}
void load_GL_ATI_envmap_bumpmap(Loader load) {
	if(!GL_ATI_envmap_bumpmap) return;
	glTexBumpParameterivATI = cast(typeof(glTexBumpParameterivATI))load("glTexBumpParameterivATI");
	glTexBumpParameterfvATI = cast(typeof(glTexBumpParameterfvATI))load("glTexBumpParameterfvATI");
	glGetTexBumpParameterivATI = cast(typeof(glGetTexBumpParameterivATI))load("glGetTexBumpParameterivATI");
	glGetTexBumpParameterfvATI = cast(typeof(glGetTexBumpParameterfvATI))load("glGetTexBumpParameterfvATI");
	return;
}
void load_GL_ATI_map_object_buffer(Loader load) {
	if(!GL_ATI_map_object_buffer) return;
	glMapObjectBufferATI = cast(typeof(glMapObjectBufferATI))load("glMapObjectBufferATI");
	glUnmapObjectBufferATI = cast(typeof(glUnmapObjectBufferATI))load("glUnmapObjectBufferATI");
	return;
}
void load_GL_ARB_robustness(Loader load) {
	if(!GL_ARB_robustness) return;
	glGetGraphicsResetStatusARB = cast(typeof(glGetGraphicsResetStatusARB))load("glGetGraphicsResetStatusARB");
	glGetnTexImageARB = cast(typeof(glGetnTexImageARB))load("glGetnTexImageARB");
	glReadnPixelsARB = cast(typeof(glReadnPixelsARB))load("glReadnPixelsARB");
	glGetnCompressedTexImageARB = cast(typeof(glGetnCompressedTexImageARB))load("glGetnCompressedTexImageARB");
	glGetnUniformfvARB = cast(typeof(glGetnUniformfvARB))load("glGetnUniformfvARB");
	glGetnUniformivARB = cast(typeof(glGetnUniformivARB))load("glGetnUniformivARB");
	glGetnUniformuivARB = cast(typeof(glGetnUniformuivARB))load("glGetnUniformuivARB");
	glGetnUniformdvARB = cast(typeof(glGetnUniformdvARB))load("glGetnUniformdvARB");
	glGetnMapdvARB = cast(typeof(glGetnMapdvARB))load("glGetnMapdvARB");
	glGetnMapfvARB = cast(typeof(glGetnMapfvARB))load("glGetnMapfvARB");
	glGetnMapivARB = cast(typeof(glGetnMapivARB))load("glGetnMapivARB");
	glGetnPixelMapfvARB = cast(typeof(glGetnPixelMapfvARB))load("glGetnPixelMapfvARB");
	glGetnPixelMapuivARB = cast(typeof(glGetnPixelMapuivARB))load("glGetnPixelMapuivARB");
	glGetnPixelMapusvARB = cast(typeof(glGetnPixelMapusvARB))load("glGetnPixelMapusvARB");
	glGetnPolygonStippleARB = cast(typeof(glGetnPolygonStippleARB))load("glGetnPolygonStippleARB");
	glGetnColorTableARB = cast(typeof(glGetnColorTableARB))load("glGetnColorTableARB");
	glGetnConvolutionFilterARB = cast(typeof(glGetnConvolutionFilterARB))load("glGetnConvolutionFilterARB");
	glGetnSeparableFilterARB = cast(typeof(glGetnSeparableFilterARB))load("glGetnSeparableFilterARB");
	glGetnHistogramARB = cast(typeof(glGetnHistogramARB))load("glGetnHistogramARB");
	glGetnMinmaxARB = cast(typeof(glGetnMinmaxARB))load("glGetnMinmaxARB");
	return;
}
void load_GL_NV_pixel_data_range(Loader load) {
	if(!GL_NV_pixel_data_range) return;
	glPixelDataRangeNV = cast(typeof(glPixelDataRangeNV))load("glPixelDataRangeNV");
	glFlushPixelDataRangeNV = cast(typeof(glFlushPixelDataRangeNV))load("glFlushPixelDataRangeNV");
	return;
}
void load_GL_EXT_framebuffer_blit(Loader load) {
	if(!GL_EXT_framebuffer_blit) return;
	glBlitFramebufferEXT = cast(typeof(glBlitFramebufferEXT))load("glBlitFramebufferEXT");
	return;
}
void load_GL_ARB_gpu_shader_fp64(Loader load) {
	if(!GL_ARB_gpu_shader_fp64) return;
	glUniform1d = cast(typeof(glUniform1d))load("glUniform1d");
	glUniform2d = cast(typeof(glUniform2d))load("glUniform2d");
	glUniform3d = cast(typeof(glUniform3d))load("glUniform3d");
	glUniform4d = cast(typeof(glUniform4d))load("glUniform4d");
	glUniform1dv = cast(typeof(glUniform1dv))load("glUniform1dv");
	glUniform2dv = cast(typeof(glUniform2dv))load("glUniform2dv");
	glUniform3dv = cast(typeof(glUniform3dv))load("glUniform3dv");
	glUniform4dv = cast(typeof(glUniform4dv))load("glUniform4dv");
	glUniformMatrix2dv = cast(typeof(glUniformMatrix2dv))load("glUniformMatrix2dv");
	glUniformMatrix3dv = cast(typeof(glUniformMatrix3dv))load("glUniformMatrix3dv");
	glUniformMatrix4dv = cast(typeof(glUniformMatrix4dv))load("glUniformMatrix4dv");
	glUniformMatrix2x3dv = cast(typeof(glUniformMatrix2x3dv))load("glUniformMatrix2x3dv");
	glUniformMatrix2x4dv = cast(typeof(glUniformMatrix2x4dv))load("glUniformMatrix2x4dv");
	glUniformMatrix3x2dv = cast(typeof(glUniformMatrix3x2dv))load("glUniformMatrix3x2dv");
	glUniformMatrix3x4dv = cast(typeof(glUniformMatrix3x4dv))load("glUniformMatrix3x4dv");
	glUniformMatrix4x2dv = cast(typeof(glUniformMatrix4x2dv))load("glUniformMatrix4x2dv");
	glUniformMatrix4x3dv = cast(typeof(glUniformMatrix4x3dv))load("glUniformMatrix4x3dv");
	glGetUniformdv = cast(typeof(glGetUniformdv))load("glGetUniformdv");
	return;
}
void load_GL_NV_command_list(Loader load) {
	if(!GL_NV_command_list) return;
	glCreateStatesNV = cast(typeof(glCreateStatesNV))load("glCreateStatesNV");
	glDeleteStatesNV = cast(typeof(glDeleteStatesNV))load("glDeleteStatesNV");
	glIsStateNV = cast(typeof(glIsStateNV))load("glIsStateNV");
	glStateCaptureNV = cast(typeof(glStateCaptureNV))load("glStateCaptureNV");
	glGetCommandHeaderNV = cast(typeof(glGetCommandHeaderNV))load("glGetCommandHeaderNV");
	glGetStageIndexNV = cast(typeof(glGetStageIndexNV))load("glGetStageIndexNV");
	glDrawCommandsNV = cast(typeof(glDrawCommandsNV))load("glDrawCommandsNV");
	glDrawCommandsAddressNV = cast(typeof(glDrawCommandsAddressNV))load("glDrawCommandsAddressNV");
	glDrawCommandsStatesNV = cast(typeof(glDrawCommandsStatesNV))load("glDrawCommandsStatesNV");
	glDrawCommandsStatesAddressNV = cast(typeof(glDrawCommandsStatesAddressNV))load("glDrawCommandsStatesAddressNV");
	glCreateCommandListsNV = cast(typeof(glCreateCommandListsNV))load("glCreateCommandListsNV");
	glDeleteCommandListsNV = cast(typeof(glDeleteCommandListsNV))load("glDeleteCommandListsNV");
	glIsCommandListNV = cast(typeof(glIsCommandListNV))load("glIsCommandListNV");
	glListDrawCommandsStatesClientNV = cast(typeof(glListDrawCommandsStatesClientNV))load("glListDrawCommandsStatesClientNV");
	glCommandListSegmentsNV = cast(typeof(glCommandListSegmentsNV))load("glCommandListSegmentsNV");
	glCompileCommandListNV = cast(typeof(glCompileCommandListNV))load("glCompileCommandListNV");
	glCallCommandListNV = cast(typeof(glCallCommandListNV))load("glCallCommandListNV");
	return;
}
void load_GL_EXT_vertex_weighting(Loader load) {
	if(!GL_EXT_vertex_weighting) return;
	glVertexWeightfEXT = cast(typeof(glVertexWeightfEXT))load("glVertexWeightfEXT");
	glVertexWeightfvEXT = cast(typeof(glVertexWeightfvEXT))load("glVertexWeightfvEXT");
	glVertexWeightPointerEXT = cast(typeof(glVertexWeightPointerEXT))load("glVertexWeightPointerEXT");
	return;
}
void load_GL_GREMEDY_string_marker(Loader load) {
	if(!GL_GREMEDY_string_marker) return;
	glStringMarkerGREMEDY = cast(typeof(glStringMarkerGREMEDY))load("glStringMarkerGREMEDY");
	return;
}
void load_GL_EXT_subtexture(Loader load) {
	if(!GL_EXT_subtexture) return;
	glTexSubImage1DEXT = cast(typeof(glTexSubImage1DEXT))load("glTexSubImage1DEXT");
	glTexSubImage2DEXT = cast(typeof(glTexSubImage2DEXT))load("glTexSubImage2DEXT");
	return;
}
void load_GL_EXT_gpu_program_parameters(Loader load) {
	if(!GL_EXT_gpu_program_parameters) return;
	glProgramEnvParameters4fvEXT = cast(typeof(glProgramEnvParameters4fvEXT))load("glProgramEnvParameters4fvEXT");
	glProgramLocalParameters4fvEXT = cast(typeof(glProgramLocalParameters4fvEXT))load("glProgramLocalParameters4fvEXT");
	return;
}
void load_GL_NV_evaluators(Loader load) {
	if(!GL_NV_evaluators) return;
	glMapControlPointsNV = cast(typeof(glMapControlPointsNV))load("glMapControlPointsNV");
	glMapParameterivNV = cast(typeof(glMapParameterivNV))load("glMapParameterivNV");
	glMapParameterfvNV = cast(typeof(glMapParameterfvNV))load("glMapParameterfvNV");
	glGetMapControlPointsNV = cast(typeof(glGetMapControlPointsNV))load("glGetMapControlPointsNV");
	glGetMapParameterivNV = cast(typeof(glGetMapParameterivNV))load("glGetMapParameterivNV");
	glGetMapParameterfvNV = cast(typeof(glGetMapParameterfvNV))load("glGetMapParameterfvNV");
	glGetMapAttribParameterivNV = cast(typeof(glGetMapAttribParameterivNV))load("glGetMapAttribParameterivNV");
	glGetMapAttribParameterfvNV = cast(typeof(glGetMapAttribParameterfvNV))load("glGetMapAttribParameterfvNV");
	glEvalMapsNV = cast(typeof(glEvalMapsNV))load("glEvalMapsNV");
	return;
}
void load_GL_SGIS_texture_filter4(Loader load) {
	if(!GL_SGIS_texture_filter4) return;
	glGetTexFilterFuncSGIS = cast(typeof(glGetTexFilterFuncSGIS))load("glGetTexFilterFuncSGIS");
	glTexFilterFuncSGIS = cast(typeof(glTexFilterFuncSGIS))load("glTexFilterFuncSGIS");
	return;
}
void load_GL_AMD_performance_monitor(Loader load) {
	if(!GL_AMD_performance_monitor) return;
	glGetPerfMonitorGroupsAMD = cast(typeof(glGetPerfMonitorGroupsAMD))load("glGetPerfMonitorGroupsAMD");
	glGetPerfMonitorCountersAMD = cast(typeof(glGetPerfMonitorCountersAMD))load("glGetPerfMonitorCountersAMD");
	glGetPerfMonitorGroupStringAMD = cast(typeof(glGetPerfMonitorGroupStringAMD))load("glGetPerfMonitorGroupStringAMD");
	glGetPerfMonitorCounterStringAMD = cast(typeof(glGetPerfMonitorCounterStringAMD))load("glGetPerfMonitorCounterStringAMD");
	glGetPerfMonitorCounterInfoAMD = cast(typeof(glGetPerfMonitorCounterInfoAMD))load("glGetPerfMonitorCounterInfoAMD");
	glGenPerfMonitorsAMD = cast(typeof(glGenPerfMonitorsAMD))load("glGenPerfMonitorsAMD");
	glDeletePerfMonitorsAMD = cast(typeof(glDeletePerfMonitorsAMD))load("glDeletePerfMonitorsAMD");
	glSelectPerfMonitorCountersAMD = cast(typeof(glSelectPerfMonitorCountersAMD))load("glSelectPerfMonitorCountersAMD");
	glBeginPerfMonitorAMD = cast(typeof(glBeginPerfMonitorAMD))load("glBeginPerfMonitorAMD");
	glEndPerfMonitorAMD = cast(typeof(glEndPerfMonitorAMD))load("glEndPerfMonitorAMD");
	glGetPerfMonitorCounterDataAMD = cast(typeof(glGetPerfMonitorCounterDataAMD))load("glGetPerfMonitorCounterDataAMD");
	return;
}
void load_GL_EXT_stencil_clear_tag(Loader load) {
	if(!GL_EXT_stencil_clear_tag) return;
	glStencilClearTagEXT = cast(typeof(glStencilClearTagEXT))load("glStencilClearTagEXT");
	return;
}
void load_GL_NV_present_video(Loader load) {
	if(!GL_NV_present_video) return;
	glPresentFrameKeyedNV = cast(typeof(glPresentFrameKeyedNV))load("glPresentFrameKeyedNV");
	glPresentFrameDualFillNV = cast(typeof(glPresentFrameDualFillNV))load("glPresentFrameDualFillNV");
	glGetVideoivNV = cast(typeof(glGetVideoivNV))load("glGetVideoivNV");
	glGetVideouivNV = cast(typeof(glGetVideouivNV))load("glGetVideouivNV");
	glGetVideoi64vNV = cast(typeof(glGetVideoi64vNV))load("glGetVideoi64vNV");
	glGetVideoui64vNV = cast(typeof(glGetVideoui64vNV))load("glGetVideoui64vNV");
	return;
}
void load_GL_SGIX_framezoom(Loader load) {
	if(!GL_SGIX_framezoom) return;
	glFrameZoomSGIX = cast(typeof(glFrameZoomSGIX))load("glFrameZoomSGIX");
	return;
}
void load_GL_ARB_draw_elements_base_vertex(Loader load) {
	if(!GL_ARB_draw_elements_base_vertex) return;
	glDrawElementsBaseVertex = cast(typeof(glDrawElementsBaseVertex))load("glDrawElementsBaseVertex");
	glDrawRangeElementsBaseVertex = cast(typeof(glDrawRangeElementsBaseVertex))load("glDrawRangeElementsBaseVertex");
	glDrawElementsInstancedBaseVertex = cast(typeof(glDrawElementsInstancedBaseVertex))load("glDrawElementsInstancedBaseVertex");
	glMultiDrawElementsBaseVertex = cast(typeof(glMultiDrawElementsBaseVertex))load("glMultiDrawElementsBaseVertex");
	return;
}
void load_GL_NV_transform_feedback(Loader load) {
	if(!GL_NV_transform_feedback) return;
	glBeginTransformFeedbackNV = cast(typeof(glBeginTransformFeedbackNV))load("glBeginTransformFeedbackNV");
	glEndTransformFeedbackNV = cast(typeof(glEndTransformFeedbackNV))load("glEndTransformFeedbackNV");
	glTransformFeedbackAttribsNV = cast(typeof(glTransformFeedbackAttribsNV))load("glTransformFeedbackAttribsNV");
	glBindBufferRangeNV = cast(typeof(glBindBufferRangeNV))load("glBindBufferRangeNV");
	glBindBufferOffsetNV = cast(typeof(glBindBufferOffsetNV))load("glBindBufferOffsetNV");
	glBindBufferBaseNV = cast(typeof(glBindBufferBaseNV))load("glBindBufferBaseNV");
	glTransformFeedbackVaryingsNV = cast(typeof(glTransformFeedbackVaryingsNV))load("glTransformFeedbackVaryingsNV");
	glActiveVaryingNV = cast(typeof(glActiveVaryingNV))load("glActiveVaryingNV");
	glGetVaryingLocationNV = cast(typeof(glGetVaryingLocationNV))load("glGetVaryingLocationNV");
	glGetActiveVaryingNV = cast(typeof(glGetActiveVaryingNV))load("glGetActiveVaryingNV");
	glGetTransformFeedbackVaryingNV = cast(typeof(glGetTransformFeedbackVaryingNV))load("glGetTransformFeedbackVaryingNV");
	glTransformFeedbackStreamAttribsNV = cast(typeof(glTransformFeedbackStreamAttribsNV))load("glTransformFeedbackStreamAttribsNV");
	return;
}
void load_GL_NV_fragment_program(Loader load) {
	if(!GL_NV_fragment_program) return;
	glProgramNamedParameter4fNV = cast(typeof(glProgramNamedParameter4fNV))load("glProgramNamedParameter4fNV");
	glProgramNamedParameter4fvNV = cast(typeof(glProgramNamedParameter4fvNV))load("glProgramNamedParameter4fvNV");
	glProgramNamedParameter4dNV = cast(typeof(glProgramNamedParameter4dNV))load("glProgramNamedParameter4dNV");
	glProgramNamedParameter4dvNV = cast(typeof(glProgramNamedParameter4dvNV))load("glProgramNamedParameter4dvNV");
	glGetProgramNamedParameterfvNV = cast(typeof(glGetProgramNamedParameterfvNV))load("glGetProgramNamedParameterfvNV");
	glGetProgramNamedParameterdvNV = cast(typeof(glGetProgramNamedParameterdvNV))load("glGetProgramNamedParameterdvNV");
	return;
}
void load_GL_AMD_stencil_operation_extended(Loader load) {
	if(!GL_AMD_stencil_operation_extended) return;
	glStencilOpValueAMD = cast(typeof(glStencilOpValueAMD))load("glStencilOpValueAMD");
	return;
}
void load_GL_ARB_instanced_arrays(Loader load) {
	if(!GL_ARB_instanced_arrays) return;
	glVertexAttribDivisorARB = cast(typeof(glVertexAttribDivisorARB))load("glVertexAttribDivisorARB");
	return;
}
void load_GL_ARB_get_texture_sub_image(Loader load) {
	if(!GL_ARB_get_texture_sub_image) return;
	glGetTextureSubImage = cast(typeof(glGetTextureSubImage))load("glGetTextureSubImage");
	glGetCompressedTextureSubImage = cast(typeof(glGetCompressedTextureSubImage))load("glGetCompressedTextureSubImage");
	return;
}
void load_GL_KHR_robustness(Loader load) {
	if(!GL_KHR_robustness) return;
	glGetGraphicsResetStatus = cast(typeof(glGetGraphicsResetStatus))load("glGetGraphicsResetStatus");
	glReadnPixels = cast(typeof(glReadnPixels))load("glReadnPixels");
	glGetnUniformfv = cast(typeof(glGetnUniformfv))load("glGetnUniformfv");
	glGetnUniformiv = cast(typeof(glGetnUniformiv))load("glGetnUniformiv");
	glGetnUniformuiv = cast(typeof(glGetnUniformuiv))load("glGetnUniformuiv");
	glGetGraphicsResetStatusKHR = cast(typeof(glGetGraphicsResetStatusKHR))load("glGetGraphicsResetStatusKHR");
	glReadnPixelsKHR = cast(typeof(glReadnPixelsKHR))load("glReadnPixelsKHR");
	glGetnUniformfvKHR = cast(typeof(glGetnUniformfvKHR))load("glGetnUniformfvKHR");
	glGetnUniformivKHR = cast(typeof(glGetnUniformivKHR))load("glGetnUniformivKHR");
	glGetnUniformuivKHR = cast(typeof(glGetnUniformuivKHR))load("glGetnUniformuivKHR");
	return;
}
void load_GL_AMD_sparse_texture(Loader load) {
	if(!GL_AMD_sparse_texture) return;
	glTexStorageSparseAMD = cast(typeof(glTexStorageSparseAMD))load("glTexStorageSparseAMD");
	glTextureStorageSparseAMD = cast(typeof(glTextureStorageSparseAMD))load("glTextureStorageSparseAMD");
	return;
}
void load_GL_ARB_clip_control(Loader load) {
	if(!GL_ARB_clip_control) return;
	glClipControl = cast(typeof(glClipControl))load("glClipControl");
	return;
}
void load_GL_NV_fragment_coverage_to_color(Loader load) {
	if(!GL_NV_fragment_coverage_to_color) return;
	glFragmentCoverageColorNV = cast(typeof(glFragmentCoverageColorNV))load("glFragmentCoverageColorNV");
	return;
}
void load_GL_NV_fence(Loader load) {
	if(!GL_NV_fence) return;
	glDeleteFencesNV = cast(typeof(glDeleteFencesNV))load("glDeleteFencesNV");
	glGenFencesNV = cast(typeof(glGenFencesNV))load("glGenFencesNV");
	glIsFenceNV = cast(typeof(glIsFenceNV))load("glIsFenceNV");
	glTestFenceNV = cast(typeof(glTestFenceNV))load("glTestFenceNV");
	glGetFenceivNV = cast(typeof(glGetFenceivNV))load("glGetFenceivNV");
	glFinishFenceNV = cast(typeof(glFinishFenceNV))load("glFinishFenceNV");
	glSetFenceNV = cast(typeof(glSetFenceNV))load("glSetFenceNV");
	return;
}
void load_GL_ARB_texture_buffer_range(Loader load) {
	if(!GL_ARB_texture_buffer_range) return;
	glTexBufferRange = cast(typeof(glTexBufferRange))load("glTexBufferRange");
	return;
}
void load_GL_SUN_mesh_array(Loader load) {
	if(!GL_SUN_mesh_array) return;
	glDrawMeshArraysSUN = cast(typeof(glDrawMeshArraysSUN))load("glDrawMeshArraysSUN");
	return;
}
void load_GL_ARB_vertex_attrib_binding(Loader load) {
	if(!GL_ARB_vertex_attrib_binding) return;
	glBindVertexBuffer = cast(typeof(glBindVertexBuffer))load("glBindVertexBuffer");
	glVertexAttribFormat = cast(typeof(glVertexAttribFormat))load("glVertexAttribFormat");
	glVertexAttribIFormat = cast(typeof(glVertexAttribIFormat))load("glVertexAttribIFormat");
	glVertexAttribLFormat = cast(typeof(glVertexAttribLFormat))load("glVertexAttribLFormat");
	glVertexAttribBinding = cast(typeof(glVertexAttribBinding))load("glVertexAttribBinding");
	glVertexBindingDivisor = cast(typeof(glVertexBindingDivisor))load("glVertexBindingDivisor");
	return;
}
void load_GL_ARB_framebuffer_no_attachments(Loader load) {
	if(!GL_ARB_framebuffer_no_attachments) return;
	glFramebufferParameteri = cast(typeof(glFramebufferParameteri))load("glFramebufferParameteri");
	glGetFramebufferParameteriv = cast(typeof(glGetFramebufferParameteriv))load("glGetFramebufferParameteriv");
	return;
}
void load_GL_ARB_cl_event(Loader load) {
	if(!GL_ARB_cl_event) return;
	glCreateSyncFromCLeventARB = cast(typeof(glCreateSyncFromCLeventARB))load("glCreateSyncFromCLeventARB");
	return;
}
void load_GL_OES_single_precision(Loader load) {
	if(!GL_OES_single_precision) return;
	glClearDepthfOES = cast(typeof(glClearDepthfOES))load("glClearDepthfOES");
	glClipPlanefOES = cast(typeof(glClipPlanefOES))load("glClipPlanefOES");
	glDepthRangefOES = cast(typeof(glDepthRangefOES))load("glDepthRangefOES");
	glFrustumfOES = cast(typeof(glFrustumfOES))load("glFrustumfOES");
	glGetClipPlanefOES = cast(typeof(glGetClipPlanefOES))load("glGetClipPlanefOES");
	glOrthofOES = cast(typeof(glOrthofOES))load("glOrthofOES");
	return;
}
void load_GL_NV_primitive_restart(Loader load) {
	if(!GL_NV_primitive_restart) return;
	glPrimitiveRestartNV = cast(typeof(glPrimitiveRestartNV))load("glPrimitiveRestartNV");
	glPrimitiveRestartIndexNV = cast(typeof(glPrimitiveRestartIndexNV))load("glPrimitiveRestartIndexNV");
	return;
}
void load_GL_SUN_global_alpha(Loader load) {
	if(!GL_SUN_global_alpha) return;
	glGlobalAlphaFactorbSUN = cast(typeof(glGlobalAlphaFactorbSUN))load("glGlobalAlphaFactorbSUN");
	glGlobalAlphaFactorsSUN = cast(typeof(glGlobalAlphaFactorsSUN))load("glGlobalAlphaFactorsSUN");
	glGlobalAlphaFactoriSUN = cast(typeof(glGlobalAlphaFactoriSUN))load("glGlobalAlphaFactoriSUN");
	glGlobalAlphaFactorfSUN = cast(typeof(glGlobalAlphaFactorfSUN))load("glGlobalAlphaFactorfSUN");
	glGlobalAlphaFactordSUN = cast(typeof(glGlobalAlphaFactordSUN))load("glGlobalAlphaFactordSUN");
	glGlobalAlphaFactorubSUN = cast(typeof(glGlobalAlphaFactorubSUN))load("glGlobalAlphaFactorubSUN");
	glGlobalAlphaFactorusSUN = cast(typeof(glGlobalAlphaFactorusSUN))load("glGlobalAlphaFactorusSUN");
	glGlobalAlphaFactoruiSUN = cast(typeof(glGlobalAlphaFactoruiSUN))load("glGlobalAlphaFactoruiSUN");
	return;
}
void load_GL_EXT_texture_object(Loader load) {
	if(!GL_EXT_texture_object) return;
	glAreTexturesResidentEXT = cast(typeof(glAreTexturesResidentEXT))load("glAreTexturesResidentEXT");
	glBindTextureEXT = cast(typeof(glBindTextureEXT))load("glBindTextureEXT");
	glDeleteTexturesEXT = cast(typeof(glDeleteTexturesEXT))load("glDeleteTexturesEXT");
	glGenTexturesEXT = cast(typeof(glGenTexturesEXT))load("glGenTexturesEXT");
	glIsTextureEXT = cast(typeof(glIsTextureEXT))load("glIsTextureEXT");
	glPrioritizeTexturesEXT = cast(typeof(glPrioritizeTexturesEXT))load("glPrioritizeTexturesEXT");
	return;
}
void load_GL_AMD_name_gen_delete(Loader load) {
	if(!GL_AMD_name_gen_delete) return;
	glGenNamesAMD = cast(typeof(glGenNamesAMD))load("glGenNamesAMD");
	glDeleteNamesAMD = cast(typeof(glDeleteNamesAMD))load("glDeleteNamesAMD");
	glIsNameAMD = cast(typeof(glIsNameAMD))load("glIsNameAMD");
	return;
}
void load_GL_ARB_buffer_storage(Loader load) {
	if(!GL_ARB_buffer_storage) return;
	glBufferStorage = cast(typeof(glBufferStorage))load("glBufferStorage");
	return;
}
void load_GL_APPLE_vertex_program_evaluators(Loader load) {
	if(!GL_APPLE_vertex_program_evaluators) return;
	glEnableVertexAttribAPPLE = cast(typeof(glEnableVertexAttribAPPLE))load("glEnableVertexAttribAPPLE");
	glDisableVertexAttribAPPLE = cast(typeof(glDisableVertexAttribAPPLE))load("glDisableVertexAttribAPPLE");
	glIsVertexAttribEnabledAPPLE = cast(typeof(glIsVertexAttribEnabledAPPLE))load("glIsVertexAttribEnabledAPPLE");
	glMapVertexAttrib1dAPPLE = cast(typeof(glMapVertexAttrib1dAPPLE))load("glMapVertexAttrib1dAPPLE");
	glMapVertexAttrib1fAPPLE = cast(typeof(glMapVertexAttrib1fAPPLE))load("glMapVertexAttrib1fAPPLE");
	glMapVertexAttrib2dAPPLE = cast(typeof(glMapVertexAttrib2dAPPLE))load("glMapVertexAttrib2dAPPLE");
	glMapVertexAttrib2fAPPLE = cast(typeof(glMapVertexAttrib2fAPPLE))load("glMapVertexAttrib2fAPPLE");
	return;
}
void load_GL_ARB_multi_bind(Loader load) {
	if(!GL_ARB_multi_bind) return;
	glBindBuffersBase = cast(typeof(glBindBuffersBase))load("glBindBuffersBase");
	glBindBuffersRange = cast(typeof(glBindBuffersRange))load("glBindBuffersRange");
	glBindTextures = cast(typeof(glBindTextures))load("glBindTextures");
	glBindSamplers = cast(typeof(glBindSamplers))load("glBindSamplers");
	glBindImageTextures = cast(typeof(glBindImageTextures))load("glBindImageTextures");
	glBindVertexBuffers = cast(typeof(glBindVertexBuffers))load("glBindVertexBuffers");
	return;
}
void load_GL_SGIX_list_priority(Loader load) {
	if(!GL_SGIX_list_priority) return;
	glGetListParameterfvSGIX = cast(typeof(glGetListParameterfvSGIX))load("glGetListParameterfvSGIX");
	glGetListParameterivSGIX = cast(typeof(glGetListParameterivSGIX))load("glGetListParameterivSGIX");
	glListParameterfSGIX = cast(typeof(glListParameterfSGIX))load("glListParameterfSGIX");
	glListParameterfvSGIX = cast(typeof(glListParameterfvSGIX))load("glListParameterfvSGIX");
	glListParameteriSGIX = cast(typeof(glListParameteriSGIX))load("glListParameteriSGIX");
	glListParameterivSGIX = cast(typeof(glListParameterivSGIX))load("glListParameterivSGIX");
	return;
}
void load_GL_NV_vertex_buffer_unified_memory(Loader load) {
	if(!GL_NV_vertex_buffer_unified_memory) return;
	glBufferAddressRangeNV = cast(typeof(glBufferAddressRangeNV))load("glBufferAddressRangeNV");
	glVertexFormatNV = cast(typeof(glVertexFormatNV))load("glVertexFormatNV");
	glNormalFormatNV = cast(typeof(glNormalFormatNV))load("glNormalFormatNV");
	glColorFormatNV = cast(typeof(glColorFormatNV))load("glColorFormatNV");
	glIndexFormatNV = cast(typeof(glIndexFormatNV))load("glIndexFormatNV");
	glTexCoordFormatNV = cast(typeof(glTexCoordFormatNV))load("glTexCoordFormatNV");
	glEdgeFlagFormatNV = cast(typeof(glEdgeFlagFormatNV))load("glEdgeFlagFormatNV");
	glSecondaryColorFormatNV = cast(typeof(glSecondaryColorFormatNV))load("glSecondaryColorFormatNV");
	glFogCoordFormatNV = cast(typeof(glFogCoordFormatNV))load("glFogCoordFormatNV");
	glVertexAttribFormatNV = cast(typeof(glVertexAttribFormatNV))load("glVertexAttribFormatNV");
	glVertexAttribIFormatNV = cast(typeof(glVertexAttribIFormatNV))load("glVertexAttribIFormatNV");
	glGetIntegerui64i_vNV = cast(typeof(glGetIntegerui64i_vNV))load("glGetIntegerui64i_vNV");
	return;
}
void load_GL_ARB_clear_texture(Loader load) {
	if(!GL_ARB_clear_texture) return;
	glClearTexImage = cast(typeof(glClearTexImage))load("glClearTexImage");
	glClearTexSubImage = cast(typeof(glClearTexSubImage))load("glClearTexSubImage");
	return;
}
void load_GL_NV_blend_equation_advanced(Loader load) {
	if(!GL_NV_blend_equation_advanced) return;
	glBlendParameteriNV = cast(typeof(glBlendParameteriNV))load("glBlendParameteriNV");
	glBlendBarrierNV = cast(typeof(glBlendBarrierNV))load("glBlendBarrierNV");
	return;
}
void load_GL_SGIS_sharpen_texture(Loader load) {
	if(!GL_SGIS_sharpen_texture) return;
	glSharpenTexFuncSGIS = cast(typeof(glSharpenTexFuncSGIS))load("glSharpenTexFuncSGIS");
	glGetSharpenTexFuncSGIS = cast(typeof(glGetSharpenTexFuncSGIS))load("glGetSharpenTexFuncSGIS");
	return;
}
void load_GL_ARB_vertex_program(Loader load) {
	if(!GL_ARB_vertex_program) return;
	glVertexAttrib1dARB = cast(typeof(glVertexAttrib1dARB))load("glVertexAttrib1dARB");
	glVertexAttrib1dvARB = cast(typeof(glVertexAttrib1dvARB))load("glVertexAttrib1dvARB");
	glVertexAttrib1fARB = cast(typeof(glVertexAttrib1fARB))load("glVertexAttrib1fARB");
	glVertexAttrib1fvARB = cast(typeof(glVertexAttrib1fvARB))load("glVertexAttrib1fvARB");
	glVertexAttrib1sARB = cast(typeof(glVertexAttrib1sARB))load("glVertexAttrib1sARB");
	glVertexAttrib1svARB = cast(typeof(glVertexAttrib1svARB))load("glVertexAttrib1svARB");
	glVertexAttrib2dARB = cast(typeof(glVertexAttrib2dARB))load("glVertexAttrib2dARB");
	glVertexAttrib2dvARB = cast(typeof(glVertexAttrib2dvARB))load("glVertexAttrib2dvARB");
	glVertexAttrib2fARB = cast(typeof(glVertexAttrib2fARB))load("glVertexAttrib2fARB");
	glVertexAttrib2fvARB = cast(typeof(glVertexAttrib2fvARB))load("glVertexAttrib2fvARB");
	glVertexAttrib2sARB = cast(typeof(glVertexAttrib2sARB))load("glVertexAttrib2sARB");
	glVertexAttrib2svARB = cast(typeof(glVertexAttrib2svARB))load("glVertexAttrib2svARB");
	glVertexAttrib3dARB = cast(typeof(glVertexAttrib3dARB))load("glVertexAttrib3dARB");
	glVertexAttrib3dvARB = cast(typeof(glVertexAttrib3dvARB))load("glVertexAttrib3dvARB");
	glVertexAttrib3fARB = cast(typeof(glVertexAttrib3fARB))load("glVertexAttrib3fARB");
	glVertexAttrib3fvARB = cast(typeof(glVertexAttrib3fvARB))load("glVertexAttrib3fvARB");
	glVertexAttrib3sARB = cast(typeof(glVertexAttrib3sARB))load("glVertexAttrib3sARB");
	glVertexAttrib3svARB = cast(typeof(glVertexAttrib3svARB))load("glVertexAttrib3svARB");
	glVertexAttrib4NbvARB = cast(typeof(glVertexAttrib4NbvARB))load("glVertexAttrib4NbvARB");
	glVertexAttrib4NivARB = cast(typeof(glVertexAttrib4NivARB))load("glVertexAttrib4NivARB");
	glVertexAttrib4NsvARB = cast(typeof(glVertexAttrib4NsvARB))load("glVertexAttrib4NsvARB");
	glVertexAttrib4NubARB = cast(typeof(glVertexAttrib4NubARB))load("glVertexAttrib4NubARB");
	glVertexAttrib4NubvARB = cast(typeof(glVertexAttrib4NubvARB))load("glVertexAttrib4NubvARB");
	glVertexAttrib4NuivARB = cast(typeof(glVertexAttrib4NuivARB))load("glVertexAttrib4NuivARB");
	glVertexAttrib4NusvARB = cast(typeof(glVertexAttrib4NusvARB))load("glVertexAttrib4NusvARB");
	glVertexAttrib4bvARB = cast(typeof(glVertexAttrib4bvARB))load("glVertexAttrib4bvARB");
	glVertexAttrib4dARB = cast(typeof(glVertexAttrib4dARB))load("glVertexAttrib4dARB");
	glVertexAttrib4dvARB = cast(typeof(glVertexAttrib4dvARB))load("glVertexAttrib4dvARB");
	glVertexAttrib4fARB = cast(typeof(glVertexAttrib4fARB))load("glVertexAttrib4fARB");
	glVertexAttrib4fvARB = cast(typeof(glVertexAttrib4fvARB))load("glVertexAttrib4fvARB");
	glVertexAttrib4ivARB = cast(typeof(glVertexAttrib4ivARB))load("glVertexAttrib4ivARB");
	glVertexAttrib4sARB = cast(typeof(glVertexAttrib4sARB))load("glVertexAttrib4sARB");
	glVertexAttrib4svARB = cast(typeof(glVertexAttrib4svARB))load("glVertexAttrib4svARB");
	glVertexAttrib4ubvARB = cast(typeof(glVertexAttrib4ubvARB))load("glVertexAttrib4ubvARB");
	glVertexAttrib4uivARB = cast(typeof(glVertexAttrib4uivARB))load("glVertexAttrib4uivARB");
	glVertexAttrib4usvARB = cast(typeof(glVertexAttrib4usvARB))load("glVertexAttrib4usvARB");
	glVertexAttribPointerARB = cast(typeof(glVertexAttribPointerARB))load("glVertexAttribPointerARB");
	glEnableVertexAttribArrayARB = cast(typeof(glEnableVertexAttribArrayARB))load("glEnableVertexAttribArrayARB");
	glDisableVertexAttribArrayARB = cast(typeof(glDisableVertexAttribArrayARB))load("glDisableVertexAttribArrayARB");
	glProgramStringARB = cast(typeof(glProgramStringARB))load("glProgramStringARB");
	glBindProgramARB = cast(typeof(glBindProgramARB))load("glBindProgramARB");
	glDeleteProgramsARB = cast(typeof(glDeleteProgramsARB))load("glDeleteProgramsARB");
	glGenProgramsARB = cast(typeof(glGenProgramsARB))load("glGenProgramsARB");
	glProgramEnvParameter4dARB = cast(typeof(glProgramEnvParameter4dARB))load("glProgramEnvParameter4dARB");
	glProgramEnvParameter4dvARB = cast(typeof(glProgramEnvParameter4dvARB))load("glProgramEnvParameter4dvARB");
	glProgramEnvParameter4fARB = cast(typeof(glProgramEnvParameter4fARB))load("glProgramEnvParameter4fARB");
	glProgramEnvParameter4fvARB = cast(typeof(glProgramEnvParameter4fvARB))load("glProgramEnvParameter4fvARB");
	glProgramLocalParameter4dARB = cast(typeof(glProgramLocalParameter4dARB))load("glProgramLocalParameter4dARB");
	glProgramLocalParameter4dvARB = cast(typeof(glProgramLocalParameter4dvARB))load("glProgramLocalParameter4dvARB");
	glProgramLocalParameter4fARB = cast(typeof(glProgramLocalParameter4fARB))load("glProgramLocalParameter4fARB");
	glProgramLocalParameter4fvARB = cast(typeof(glProgramLocalParameter4fvARB))load("glProgramLocalParameter4fvARB");
	glGetProgramEnvParameterdvARB = cast(typeof(glGetProgramEnvParameterdvARB))load("glGetProgramEnvParameterdvARB");
	glGetProgramEnvParameterfvARB = cast(typeof(glGetProgramEnvParameterfvARB))load("glGetProgramEnvParameterfvARB");
	glGetProgramLocalParameterdvARB = cast(typeof(glGetProgramLocalParameterdvARB))load("glGetProgramLocalParameterdvARB");
	glGetProgramLocalParameterfvARB = cast(typeof(glGetProgramLocalParameterfvARB))load("glGetProgramLocalParameterfvARB");
	glGetProgramivARB = cast(typeof(glGetProgramivARB))load("glGetProgramivARB");
	glGetProgramStringARB = cast(typeof(glGetProgramStringARB))load("glGetProgramStringARB");
	glGetVertexAttribdvARB = cast(typeof(glGetVertexAttribdvARB))load("glGetVertexAttribdvARB");
	glGetVertexAttribfvARB = cast(typeof(glGetVertexAttribfvARB))load("glGetVertexAttribfvARB");
	glGetVertexAttribivARB = cast(typeof(glGetVertexAttribivARB))load("glGetVertexAttribivARB");
	glGetVertexAttribPointervARB = cast(typeof(glGetVertexAttribPointervARB))load("glGetVertexAttribPointervARB");
	glIsProgramARB = cast(typeof(glIsProgramARB))load("glIsProgramARB");
	return;
}
void load_GL_ARB_vertex_buffer_object(Loader load) {
	if(!GL_ARB_vertex_buffer_object) return;
	glBindBufferARB = cast(typeof(glBindBufferARB))load("glBindBufferARB");
	glDeleteBuffersARB = cast(typeof(glDeleteBuffersARB))load("glDeleteBuffersARB");
	glGenBuffersARB = cast(typeof(glGenBuffersARB))load("glGenBuffersARB");
	glIsBufferARB = cast(typeof(glIsBufferARB))load("glIsBufferARB");
	glBufferDataARB = cast(typeof(glBufferDataARB))load("glBufferDataARB");
	glBufferSubDataARB = cast(typeof(glBufferSubDataARB))load("glBufferSubDataARB");
	glGetBufferSubDataARB = cast(typeof(glGetBufferSubDataARB))load("glGetBufferSubDataARB");
	glMapBufferARB = cast(typeof(glMapBufferARB))load("glMapBufferARB");
	glUnmapBufferARB = cast(typeof(glUnmapBufferARB))load("glUnmapBufferARB");
	glGetBufferParameterivARB = cast(typeof(glGetBufferParameterivARB))load("glGetBufferParameterivARB");
	glGetBufferPointervARB = cast(typeof(glGetBufferPointervARB))load("glGetBufferPointervARB");
	return;
}
void load_GL_NV_vertex_array_range(Loader load) {
	if(!GL_NV_vertex_array_range) return;
	glFlushVertexArrayRangeNV = cast(typeof(glFlushVertexArrayRangeNV))load("glFlushVertexArrayRangeNV");
	glVertexArrayRangeNV = cast(typeof(glVertexArrayRangeNV))load("glVertexArrayRangeNV");
	return;
}
void load_GL_SGIX_fragment_lighting(Loader load) {
	if(!GL_SGIX_fragment_lighting) return;
	glFragmentColorMaterialSGIX = cast(typeof(glFragmentColorMaterialSGIX))load("glFragmentColorMaterialSGIX");
	glFragmentLightfSGIX = cast(typeof(glFragmentLightfSGIX))load("glFragmentLightfSGIX");
	glFragmentLightfvSGIX = cast(typeof(glFragmentLightfvSGIX))load("glFragmentLightfvSGIX");
	glFragmentLightiSGIX = cast(typeof(glFragmentLightiSGIX))load("glFragmentLightiSGIX");
	glFragmentLightivSGIX = cast(typeof(glFragmentLightivSGIX))load("glFragmentLightivSGIX");
	glFragmentLightModelfSGIX = cast(typeof(glFragmentLightModelfSGIX))load("glFragmentLightModelfSGIX");
	glFragmentLightModelfvSGIX = cast(typeof(glFragmentLightModelfvSGIX))load("glFragmentLightModelfvSGIX");
	glFragmentLightModeliSGIX = cast(typeof(glFragmentLightModeliSGIX))load("glFragmentLightModeliSGIX");
	glFragmentLightModelivSGIX = cast(typeof(glFragmentLightModelivSGIX))load("glFragmentLightModelivSGIX");
	glFragmentMaterialfSGIX = cast(typeof(glFragmentMaterialfSGIX))load("glFragmentMaterialfSGIX");
	glFragmentMaterialfvSGIX = cast(typeof(glFragmentMaterialfvSGIX))load("glFragmentMaterialfvSGIX");
	glFragmentMaterialiSGIX = cast(typeof(glFragmentMaterialiSGIX))load("glFragmentMaterialiSGIX");
	glFragmentMaterialivSGIX = cast(typeof(glFragmentMaterialivSGIX))load("glFragmentMaterialivSGIX");
	glGetFragmentLightfvSGIX = cast(typeof(glGetFragmentLightfvSGIX))load("glGetFragmentLightfvSGIX");
	glGetFragmentLightivSGIX = cast(typeof(glGetFragmentLightivSGIX))load("glGetFragmentLightivSGIX");
	glGetFragmentMaterialfvSGIX = cast(typeof(glGetFragmentMaterialfvSGIX))load("glGetFragmentMaterialfvSGIX");
	glGetFragmentMaterialivSGIX = cast(typeof(glGetFragmentMaterialivSGIX))load("glGetFragmentMaterialivSGIX");
	glLightEnviSGIX = cast(typeof(glLightEnviSGIX))load("glLightEnviSGIX");
	return;
}
void load_GL_NV_framebuffer_multisample_coverage(Loader load) {
	if(!GL_NV_framebuffer_multisample_coverage) return;
	glRenderbufferStorageMultisampleCoverageNV = cast(typeof(glRenderbufferStorageMultisampleCoverageNV))load("glRenderbufferStorageMultisampleCoverageNV");
	return;
}
void load_GL_EXT_timer_query(Loader load) {
	if(!GL_EXT_timer_query) return;
	glGetQueryObjecti64vEXT = cast(typeof(glGetQueryObjecti64vEXT))load("glGetQueryObjecti64vEXT");
	glGetQueryObjectui64vEXT = cast(typeof(glGetQueryObjectui64vEXT))load("glGetQueryObjectui64vEXT");
	return;
}
void load_GL_NV_bindless_texture(Loader load) {
	if(!GL_NV_bindless_texture) return;
	glGetTextureHandleNV = cast(typeof(glGetTextureHandleNV))load("glGetTextureHandleNV");
	glGetTextureSamplerHandleNV = cast(typeof(glGetTextureSamplerHandleNV))load("glGetTextureSamplerHandleNV");
	glMakeTextureHandleResidentNV = cast(typeof(glMakeTextureHandleResidentNV))load("glMakeTextureHandleResidentNV");
	glMakeTextureHandleNonResidentNV = cast(typeof(glMakeTextureHandleNonResidentNV))load("glMakeTextureHandleNonResidentNV");
	glGetImageHandleNV = cast(typeof(glGetImageHandleNV))load("glGetImageHandleNV");
	glMakeImageHandleResidentNV = cast(typeof(glMakeImageHandleResidentNV))load("glMakeImageHandleResidentNV");
	glMakeImageHandleNonResidentNV = cast(typeof(glMakeImageHandleNonResidentNV))load("glMakeImageHandleNonResidentNV");
	glUniformHandleui64NV = cast(typeof(glUniformHandleui64NV))load("glUniformHandleui64NV");
	glUniformHandleui64vNV = cast(typeof(glUniformHandleui64vNV))load("glUniformHandleui64vNV");
	glProgramUniformHandleui64NV = cast(typeof(glProgramUniformHandleui64NV))load("glProgramUniformHandleui64NV");
	glProgramUniformHandleui64vNV = cast(typeof(glProgramUniformHandleui64vNV))load("glProgramUniformHandleui64vNV");
	glIsTextureHandleResidentNV = cast(typeof(glIsTextureHandleResidentNV))load("glIsTextureHandleResidentNV");
	glIsImageHandleResidentNV = cast(typeof(glIsImageHandleResidentNV))load("glIsImageHandleResidentNV");
	return;
}
void load_GL_KHR_debug(Loader load) {
	if(!GL_KHR_debug) return;
	glDebugMessageControl = cast(typeof(glDebugMessageControl))load("glDebugMessageControl");
	glDebugMessageInsert = cast(typeof(glDebugMessageInsert))load("glDebugMessageInsert");
	glDebugMessageCallback = cast(typeof(glDebugMessageCallback))load("glDebugMessageCallback");
	glGetDebugMessageLog = cast(typeof(glGetDebugMessageLog))load("glGetDebugMessageLog");
	glPushDebugGroup = cast(typeof(glPushDebugGroup))load("glPushDebugGroup");
	glPopDebugGroup = cast(typeof(glPopDebugGroup))load("glPopDebugGroup");
	glObjectLabel = cast(typeof(glObjectLabel))load("glObjectLabel");
	glGetObjectLabel = cast(typeof(glGetObjectLabel))load("glGetObjectLabel");
	glObjectPtrLabel = cast(typeof(glObjectPtrLabel))load("glObjectPtrLabel");
	glGetObjectPtrLabel = cast(typeof(glGetObjectPtrLabel))load("glGetObjectPtrLabel");
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv");
	glDebugMessageControlKHR = cast(typeof(glDebugMessageControlKHR))load("glDebugMessageControlKHR");
	glDebugMessageInsertKHR = cast(typeof(glDebugMessageInsertKHR))load("glDebugMessageInsertKHR");
	glDebugMessageCallbackKHR = cast(typeof(glDebugMessageCallbackKHR))load("glDebugMessageCallbackKHR");
	glGetDebugMessageLogKHR = cast(typeof(glGetDebugMessageLogKHR))load("glGetDebugMessageLogKHR");
	glPushDebugGroupKHR = cast(typeof(glPushDebugGroupKHR))load("glPushDebugGroupKHR");
	glPopDebugGroupKHR = cast(typeof(glPopDebugGroupKHR))load("glPopDebugGroupKHR");
	glObjectLabelKHR = cast(typeof(glObjectLabelKHR))load("glObjectLabelKHR");
	glGetObjectLabelKHR = cast(typeof(glGetObjectLabelKHR))load("glGetObjectLabelKHR");
	glObjectPtrLabelKHR = cast(typeof(glObjectPtrLabelKHR))load("glObjectPtrLabelKHR");
	glGetObjectPtrLabelKHR = cast(typeof(glGetObjectPtrLabelKHR))load("glGetObjectPtrLabelKHR");
	glGetPointervKHR = cast(typeof(glGetPointervKHR))load("glGetPointervKHR");
	return;
}
void load_GL_ATI_vertex_attrib_array_object(Loader load) {
	if(!GL_ATI_vertex_attrib_array_object) return;
	glVertexAttribArrayObjectATI = cast(typeof(glVertexAttribArrayObjectATI))load("glVertexAttribArrayObjectATI");
	glGetVertexAttribArrayObjectfvATI = cast(typeof(glGetVertexAttribArrayObjectfvATI))load("glGetVertexAttribArrayObjectfvATI");
	glGetVertexAttribArrayObjectivATI = cast(typeof(glGetVertexAttribArrayObjectivATI))load("glGetVertexAttribArrayObjectivATI");
	return;
}
void load_GL_EXT_geometry_shader4(Loader load) {
	if(!GL_EXT_geometry_shader4) return;
	glProgramParameteriEXT = cast(typeof(glProgramParameteriEXT))load("glProgramParameteriEXT");
	return;
}
void load_GL_EXT_bindable_uniform(Loader load) {
	if(!GL_EXT_bindable_uniform) return;
	glUniformBufferEXT = cast(typeof(glUniformBufferEXT))load("glUniformBufferEXT");
	glGetUniformBufferSizeEXT = cast(typeof(glGetUniformBufferSizeEXT))load("glGetUniformBufferSizeEXT");
	glGetUniformOffsetEXT = cast(typeof(glGetUniformOffsetEXT))load("glGetUniformOffsetEXT");
	return;
}
void load_GL_KHR_blend_equation_advanced(Loader load) {
	if(!GL_KHR_blend_equation_advanced) return;
	glBlendBarrierKHR = cast(typeof(glBlendBarrierKHR))load("glBlendBarrierKHR");
	return;
}
void load_GL_ATI_element_array(Loader load) {
	if(!GL_ATI_element_array) return;
	glElementPointerATI = cast(typeof(glElementPointerATI))load("glElementPointerATI");
	glDrawElementArrayATI = cast(typeof(glDrawElementArrayATI))load("glDrawElementArrayATI");
	glDrawRangeElementArrayATI = cast(typeof(glDrawRangeElementArrayATI))load("glDrawRangeElementArrayATI");
	return;
}
void load_GL_SGIX_reference_plane(Loader load) {
	if(!GL_SGIX_reference_plane) return;
	glReferencePlaneSGIX = cast(typeof(glReferencePlaneSGIX))load("glReferencePlaneSGIX");
	return;
}
void load_GL_EXT_stencil_two_side(Loader load) {
	if(!GL_EXT_stencil_two_side) return;
	glActiveStencilFaceEXT = cast(typeof(glActiveStencilFaceEXT))load("glActiveStencilFaceEXT");
	return;
}
void load_GL_NV_explicit_multisample(Loader load) {
	if(!GL_NV_explicit_multisample) return;
	glGetMultisamplefvNV = cast(typeof(glGetMultisamplefvNV))load("glGetMultisamplefvNV");
	glSampleMaskIndexedNV = cast(typeof(glSampleMaskIndexedNV))load("glSampleMaskIndexedNV");
	glTexRenderbufferNV = cast(typeof(glTexRenderbufferNV))load("glTexRenderbufferNV");
	return;
}
void load_GL_IBM_static_data(Loader load) {
	if(!GL_IBM_static_data) return;
	glFlushStaticDataIBM = cast(typeof(glFlushStaticDataIBM))load("glFlushStaticDataIBM");
	return;
}
void load_GL_EXT_texture_perturb_normal(Loader load) {
	if(!GL_EXT_texture_perturb_normal) return;
	glTextureNormalEXT = cast(typeof(glTextureNormalEXT))load("glTextureNormalEXT");
	return;
}
void load_GL_EXT_point_parameters(Loader load) {
	if(!GL_EXT_point_parameters) return;
	glPointParameterfEXT = cast(typeof(glPointParameterfEXT))load("glPointParameterfEXT");
	glPointParameterfvEXT = cast(typeof(glPointParameterfvEXT))load("glPointParameterfvEXT");
	return;
}
void load_GL_PGI_misc_hints(Loader load) {
	if(!GL_PGI_misc_hints) return;
	glHintPGI = cast(typeof(glHintPGI))load("glHintPGI");
	return;
}
void load_GL_ARB_vertex_shader(Loader load) {
	if(!GL_ARB_vertex_shader) return;
	glVertexAttrib1fARB = cast(typeof(glVertexAttrib1fARB))load("glVertexAttrib1fARB");
	glVertexAttrib1sARB = cast(typeof(glVertexAttrib1sARB))load("glVertexAttrib1sARB");
	glVertexAttrib1dARB = cast(typeof(glVertexAttrib1dARB))load("glVertexAttrib1dARB");
	glVertexAttrib2fARB = cast(typeof(glVertexAttrib2fARB))load("glVertexAttrib2fARB");
	glVertexAttrib2sARB = cast(typeof(glVertexAttrib2sARB))load("glVertexAttrib2sARB");
	glVertexAttrib2dARB = cast(typeof(glVertexAttrib2dARB))load("glVertexAttrib2dARB");
	glVertexAttrib3fARB = cast(typeof(glVertexAttrib3fARB))load("glVertexAttrib3fARB");
	glVertexAttrib3sARB = cast(typeof(glVertexAttrib3sARB))load("glVertexAttrib3sARB");
	glVertexAttrib3dARB = cast(typeof(glVertexAttrib3dARB))load("glVertexAttrib3dARB");
	glVertexAttrib4fARB = cast(typeof(glVertexAttrib4fARB))load("glVertexAttrib4fARB");
	glVertexAttrib4sARB = cast(typeof(glVertexAttrib4sARB))load("glVertexAttrib4sARB");
	glVertexAttrib4dARB = cast(typeof(glVertexAttrib4dARB))load("glVertexAttrib4dARB");
	glVertexAttrib4NubARB = cast(typeof(glVertexAttrib4NubARB))load("glVertexAttrib4NubARB");
	glVertexAttrib1fvARB = cast(typeof(glVertexAttrib1fvARB))load("glVertexAttrib1fvARB");
	glVertexAttrib1svARB = cast(typeof(glVertexAttrib1svARB))load("glVertexAttrib1svARB");
	glVertexAttrib1dvARB = cast(typeof(glVertexAttrib1dvARB))load("glVertexAttrib1dvARB");
	glVertexAttrib2fvARB = cast(typeof(glVertexAttrib2fvARB))load("glVertexAttrib2fvARB");
	glVertexAttrib2svARB = cast(typeof(glVertexAttrib2svARB))load("glVertexAttrib2svARB");
	glVertexAttrib2dvARB = cast(typeof(glVertexAttrib2dvARB))load("glVertexAttrib2dvARB");
	glVertexAttrib3fvARB = cast(typeof(glVertexAttrib3fvARB))load("glVertexAttrib3fvARB");
	glVertexAttrib3svARB = cast(typeof(glVertexAttrib3svARB))load("glVertexAttrib3svARB");
	glVertexAttrib3dvARB = cast(typeof(glVertexAttrib3dvARB))load("glVertexAttrib3dvARB");
	glVertexAttrib4fvARB = cast(typeof(glVertexAttrib4fvARB))load("glVertexAttrib4fvARB");
	glVertexAttrib4svARB = cast(typeof(glVertexAttrib4svARB))load("glVertexAttrib4svARB");
	glVertexAttrib4dvARB = cast(typeof(glVertexAttrib4dvARB))load("glVertexAttrib4dvARB");
	glVertexAttrib4ivARB = cast(typeof(glVertexAttrib4ivARB))load("glVertexAttrib4ivARB");
	glVertexAttrib4bvARB = cast(typeof(glVertexAttrib4bvARB))load("glVertexAttrib4bvARB");
	glVertexAttrib4ubvARB = cast(typeof(glVertexAttrib4ubvARB))load("glVertexAttrib4ubvARB");
	glVertexAttrib4usvARB = cast(typeof(glVertexAttrib4usvARB))load("glVertexAttrib4usvARB");
	glVertexAttrib4uivARB = cast(typeof(glVertexAttrib4uivARB))load("glVertexAttrib4uivARB");
	glVertexAttrib4NbvARB = cast(typeof(glVertexAttrib4NbvARB))load("glVertexAttrib4NbvARB");
	glVertexAttrib4NsvARB = cast(typeof(glVertexAttrib4NsvARB))load("glVertexAttrib4NsvARB");
	glVertexAttrib4NivARB = cast(typeof(glVertexAttrib4NivARB))load("glVertexAttrib4NivARB");
	glVertexAttrib4NubvARB = cast(typeof(glVertexAttrib4NubvARB))load("glVertexAttrib4NubvARB");
	glVertexAttrib4NusvARB = cast(typeof(glVertexAttrib4NusvARB))load("glVertexAttrib4NusvARB");
	glVertexAttrib4NuivARB = cast(typeof(glVertexAttrib4NuivARB))load("glVertexAttrib4NuivARB");
	glVertexAttribPointerARB = cast(typeof(glVertexAttribPointerARB))load("glVertexAttribPointerARB");
	glEnableVertexAttribArrayARB = cast(typeof(glEnableVertexAttribArrayARB))load("glEnableVertexAttribArrayARB");
	glDisableVertexAttribArrayARB = cast(typeof(glDisableVertexAttribArrayARB))load("glDisableVertexAttribArrayARB");
	glBindAttribLocationARB = cast(typeof(glBindAttribLocationARB))load("glBindAttribLocationARB");
	glGetActiveAttribARB = cast(typeof(glGetActiveAttribARB))load("glGetActiveAttribARB");
	glGetAttribLocationARB = cast(typeof(glGetAttribLocationARB))load("glGetAttribLocationARB");
	glGetVertexAttribdvARB = cast(typeof(glGetVertexAttribdvARB))load("glGetVertexAttribdvARB");
	glGetVertexAttribfvARB = cast(typeof(glGetVertexAttribfvARB))load("glGetVertexAttribfvARB");
	glGetVertexAttribivARB = cast(typeof(glGetVertexAttribivARB))load("glGetVertexAttribivARB");
	glGetVertexAttribPointervARB = cast(typeof(glGetVertexAttribPointervARB))load("glGetVertexAttribPointervARB");
	return;
}
void load_GL_ARB_tessellation_shader(Loader load) {
	if(!GL_ARB_tessellation_shader) return;
	glPatchParameteri = cast(typeof(glPatchParameteri))load("glPatchParameteri");
	glPatchParameterfv = cast(typeof(glPatchParameterfv))load("glPatchParameterfv");
	return;
}
void load_GL_EXT_draw_buffers2(Loader load) {
	if(!GL_EXT_draw_buffers2) return;
	glColorMaskIndexedEXT = cast(typeof(glColorMaskIndexedEXT))load("glColorMaskIndexedEXT");
	glGetBooleanIndexedvEXT = cast(typeof(glGetBooleanIndexedvEXT))load("glGetBooleanIndexedvEXT");
	glGetIntegerIndexedvEXT = cast(typeof(glGetIntegerIndexedvEXT))load("glGetIntegerIndexedvEXT");
	glEnableIndexedEXT = cast(typeof(glEnableIndexedEXT))load("glEnableIndexedEXT");
	glDisableIndexedEXT = cast(typeof(glDisableIndexedEXT))load("glDisableIndexedEXT");
	glIsEnabledIndexedEXT = cast(typeof(glIsEnabledIndexedEXT))load("glIsEnabledIndexedEXT");
	return;
}
void load_GL_ARB_vertex_attrib_64bit(Loader load) {
	if(!GL_ARB_vertex_attrib_64bit) return;
	glVertexAttribL1d = cast(typeof(glVertexAttribL1d))load("glVertexAttribL1d");
	glVertexAttribL2d = cast(typeof(glVertexAttribL2d))load("glVertexAttribL2d");
	glVertexAttribL3d = cast(typeof(glVertexAttribL3d))load("glVertexAttribL3d");
	glVertexAttribL4d = cast(typeof(glVertexAttribL4d))load("glVertexAttribL4d");
	glVertexAttribL1dv = cast(typeof(glVertexAttribL1dv))load("glVertexAttribL1dv");
	glVertexAttribL2dv = cast(typeof(glVertexAttribL2dv))load("glVertexAttribL2dv");
	glVertexAttribL3dv = cast(typeof(glVertexAttribL3dv))load("glVertexAttribL3dv");
	glVertexAttribL4dv = cast(typeof(glVertexAttribL4dv))load("glVertexAttribL4dv");
	glVertexAttribLPointer = cast(typeof(glVertexAttribLPointer))load("glVertexAttribLPointer");
	glGetVertexAttribLdv = cast(typeof(glGetVertexAttribLdv))load("glGetVertexAttribLdv");
	return;
}
void load_GL_EXT_texture_filter_minmax(Loader load) {
	if(!GL_EXT_texture_filter_minmax) return;
	glRasterSamplesEXT = cast(typeof(glRasterSamplesEXT))load("glRasterSamplesEXT");
	return;
}
void load_GL_AMD_interleaved_elements(Loader load) {
	if(!GL_AMD_interleaved_elements) return;
	glVertexAttribParameteriAMD = cast(typeof(glVertexAttribParameteriAMD))load("glVertexAttribParameteriAMD");
	return;
}
void load_GL_ARB_fragment_program(Loader load) {
	if(!GL_ARB_fragment_program) return;
	glProgramStringARB = cast(typeof(glProgramStringARB))load("glProgramStringARB");
	glBindProgramARB = cast(typeof(glBindProgramARB))load("glBindProgramARB");
	glDeleteProgramsARB = cast(typeof(glDeleteProgramsARB))load("glDeleteProgramsARB");
	glGenProgramsARB = cast(typeof(glGenProgramsARB))load("glGenProgramsARB");
	glProgramEnvParameter4dARB = cast(typeof(glProgramEnvParameter4dARB))load("glProgramEnvParameter4dARB");
	glProgramEnvParameter4dvARB = cast(typeof(glProgramEnvParameter4dvARB))load("glProgramEnvParameter4dvARB");
	glProgramEnvParameter4fARB = cast(typeof(glProgramEnvParameter4fARB))load("glProgramEnvParameter4fARB");
	glProgramEnvParameter4fvARB = cast(typeof(glProgramEnvParameter4fvARB))load("glProgramEnvParameter4fvARB");
	glProgramLocalParameter4dARB = cast(typeof(glProgramLocalParameter4dARB))load("glProgramLocalParameter4dARB");
	glProgramLocalParameter4dvARB = cast(typeof(glProgramLocalParameter4dvARB))load("glProgramLocalParameter4dvARB");
	glProgramLocalParameter4fARB = cast(typeof(glProgramLocalParameter4fARB))load("glProgramLocalParameter4fARB");
	glProgramLocalParameter4fvARB = cast(typeof(glProgramLocalParameter4fvARB))load("glProgramLocalParameter4fvARB");
	glGetProgramEnvParameterdvARB = cast(typeof(glGetProgramEnvParameterdvARB))load("glGetProgramEnvParameterdvARB");
	glGetProgramEnvParameterfvARB = cast(typeof(glGetProgramEnvParameterfvARB))load("glGetProgramEnvParameterfvARB");
	glGetProgramLocalParameterdvARB = cast(typeof(glGetProgramLocalParameterdvARB))load("glGetProgramLocalParameterdvARB");
	glGetProgramLocalParameterfvARB = cast(typeof(glGetProgramLocalParameterfvARB))load("glGetProgramLocalParameterfvARB");
	glGetProgramivARB = cast(typeof(glGetProgramivARB))load("glGetProgramivARB");
	glGetProgramStringARB = cast(typeof(glGetProgramStringARB))load("glGetProgramStringARB");
	glIsProgramARB = cast(typeof(glIsProgramARB))load("glIsProgramARB");
	return;
}
void load_GL_ARB_texture_storage(Loader load) {
	if(!GL_ARB_texture_storage) return;
	glTexStorage1D = cast(typeof(glTexStorage1D))load("glTexStorage1D");
	glTexStorage2D = cast(typeof(glTexStorage2D))load("glTexStorage2D");
	glTexStorage3D = cast(typeof(glTexStorage3D))load("glTexStorage3D");
	return;
}
void load_GL_ARB_copy_image(Loader load) {
	if(!GL_ARB_copy_image) return;
	glCopyImageSubData = cast(typeof(glCopyImageSubData))load("glCopyImageSubData");
	return;
}
void load_GL_SGIS_pixel_texture(Loader load) {
	if(!GL_SGIS_pixel_texture) return;
	glPixelTexGenParameteriSGIS = cast(typeof(glPixelTexGenParameteriSGIS))load("glPixelTexGenParameteriSGIS");
	glPixelTexGenParameterivSGIS = cast(typeof(glPixelTexGenParameterivSGIS))load("glPixelTexGenParameterivSGIS");
	glPixelTexGenParameterfSGIS = cast(typeof(glPixelTexGenParameterfSGIS))load("glPixelTexGenParameterfSGIS");
	glPixelTexGenParameterfvSGIS = cast(typeof(glPixelTexGenParameterfvSGIS))load("glPixelTexGenParameterfvSGIS");
	glGetPixelTexGenParameterivSGIS = cast(typeof(glGetPixelTexGenParameterivSGIS))load("glGetPixelTexGenParameterivSGIS");
	glGetPixelTexGenParameterfvSGIS = cast(typeof(glGetPixelTexGenParameterfvSGIS))load("glGetPixelTexGenParameterfvSGIS");
	return;
}
void load_GL_SGIX_instruments(Loader load) {
	if(!GL_SGIX_instruments) return;
	glGetInstrumentsSGIX = cast(typeof(glGetInstrumentsSGIX))load("glGetInstrumentsSGIX");
	glInstrumentsBufferSGIX = cast(typeof(glInstrumentsBufferSGIX))load("glInstrumentsBufferSGIX");
	glPollInstrumentsSGIX = cast(typeof(glPollInstrumentsSGIX))load("glPollInstrumentsSGIX");
	glReadInstrumentsSGIX = cast(typeof(glReadInstrumentsSGIX))load("glReadInstrumentsSGIX");
	glStartInstrumentsSGIX = cast(typeof(glStartInstrumentsSGIX))load("glStartInstrumentsSGIX");
	glStopInstrumentsSGIX = cast(typeof(glStopInstrumentsSGIX))load("glStopInstrumentsSGIX");
	return;
}
void load_GL_ARB_shader_storage_buffer_object(Loader load) {
	if(!GL_ARB_shader_storage_buffer_object) return;
	glShaderStorageBlockBinding = cast(typeof(glShaderStorageBlockBinding))load("glShaderStorageBlockBinding");
	return;
}
void load_GL_EXT_blend_minmax(Loader load) {
	if(!GL_EXT_blend_minmax) return;
	glBlendEquationEXT = cast(typeof(glBlendEquationEXT))load("glBlendEquationEXT");
	return;
}
void load_GL_ARB_base_instance(Loader load) {
	if(!GL_ARB_base_instance) return;
	glDrawArraysInstancedBaseInstance = cast(typeof(glDrawArraysInstancedBaseInstance))load("glDrawArraysInstancedBaseInstance");
	glDrawElementsInstancedBaseInstance = cast(typeof(glDrawElementsInstancedBaseInstance))load("glDrawElementsInstancedBaseInstance");
	glDrawElementsInstancedBaseVertexBaseInstance = cast(typeof(glDrawElementsInstancedBaseVertexBaseInstance))load("glDrawElementsInstancedBaseVertexBaseInstance");
	return;
}
void load_GL_ARB_ES3_1_compatibility(Loader load) {
	if(!GL_ARB_ES3_1_compatibility) return;
	glMemoryBarrierByRegion = cast(typeof(glMemoryBarrierByRegion))load("glMemoryBarrierByRegion");
	return;
}
void load_GL_EXT_texture_integer(Loader load) {
	if(!GL_EXT_texture_integer) return;
	glTexParameterIivEXT = cast(typeof(glTexParameterIivEXT))load("glTexParameterIivEXT");
	glTexParameterIuivEXT = cast(typeof(glTexParameterIuivEXT))load("glTexParameterIuivEXT");
	glGetTexParameterIivEXT = cast(typeof(glGetTexParameterIivEXT))load("glGetTexParameterIivEXT");
	glGetTexParameterIuivEXT = cast(typeof(glGetTexParameterIuivEXT))load("glGetTexParameterIuivEXT");
	glClearColorIiEXT = cast(typeof(glClearColorIiEXT))load("glClearColorIiEXT");
	glClearColorIuiEXT = cast(typeof(glClearColorIuiEXT))load("glClearColorIuiEXT");
	return;
}
void load_GL_ARB_texture_multisample(Loader load) {
	if(!GL_ARB_texture_multisample) return;
	glTexImage2DMultisample = cast(typeof(glTexImage2DMultisample))load("glTexImage2DMultisample");
	glTexImage3DMultisample = cast(typeof(glTexImage3DMultisample))load("glTexImage3DMultisample");
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv");
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski");
	return;
}
void load_GL_AMD_gpu_shader_int64(Loader load) {
	if(!GL_AMD_gpu_shader_int64) return;
	glUniform1i64NV = cast(typeof(glUniform1i64NV))load("glUniform1i64NV");
	glUniform2i64NV = cast(typeof(glUniform2i64NV))load("glUniform2i64NV");
	glUniform3i64NV = cast(typeof(glUniform3i64NV))load("glUniform3i64NV");
	glUniform4i64NV = cast(typeof(glUniform4i64NV))load("glUniform4i64NV");
	glUniform1i64vNV = cast(typeof(glUniform1i64vNV))load("glUniform1i64vNV");
	glUniform2i64vNV = cast(typeof(glUniform2i64vNV))load("glUniform2i64vNV");
	glUniform3i64vNV = cast(typeof(glUniform3i64vNV))load("glUniform3i64vNV");
	glUniform4i64vNV = cast(typeof(glUniform4i64vNV))load("glUniform4i64vNV");
	glUniform1ui64NV = cast(typeof(glUniform1ui64NV))load("glUniform1ui64NV");
	glUniform2ui64NV = cast(typeof(glUniform2ui64NV))load("glUniform2ui64NV");
	glUniform3ui64NV = cast(typeof(glUniform3ui64NV))load("glUniform3ui64NV");
	glUniform4ui64NV = cast(typeof(glUniform4ui64NV))load("glUniform4ui64NV");
	glUniform1ui64vNV = cast(typeof(glUniform1ui64vNV))load("glUniform1ui64vNV");
	glUniform2ui64vNV = cast(typeof(glUniform2ui64vNV))load("glUniform2ui64vNV");
	glUniform3ui64vNV = cast(typeof(glUniform3ui64vNV))load("glUniform3ui64vNV");
	glUniform4ui64vNV = cast(typeof(glUniform4ui64vNV))load("glUniform4ui64vNV");
	glGetUniformi64vNV = cast(typeof(glGetUniformi64vNV))load("glGetUniformi64vNV");
	glGetUniformui64vNV = cast(typeof(glGetUniformui64vNV))load("glGetUniformui64vNV");
	glProgramUniform1i64NV = cast(typeof(glProgramUniform1i64NV))load("glProgramUniform1i64NV");
	glProgramUniform2i64NV = cast(typeof(glProgramUniform2i64NV))load("glProgramUniform2i64NV");
	glProgramUniform3i64NV = cast(typeof(glProgramUniform3i64NV))load("glProgramUniform3i64NV");
	glProgramUniform4i64NV = cast(typeof(glProgramUniform4i64NV))load("glProgramUniform4i64NV");
	glProgramUniform1i64vNV = cast(typeof(glProgramUniform1i64vNV))load("glProgramUniform1i64vNV");
	glProgramUniform2i64vNV = cast(typeof(glProgramUniform2i64vNV))load("glProgramUniform2i64vNV");
	glProgramUniform3i64vNV = cast(typeof(glProgramUniform3i64vNV))load("glProgramUniform3i64vNV");
	glProgramUniform4i64vNV = cast(typeof(glProgramUniform4i64vNV))load("glProgramUniform4i64vNV");
	glProgramUniform1ui64NV = cast(typeof(glProgramUniform1ui64NV))load("glProgramUniform1ui64NV");
	glProgramUniform2ui64NV = cast(typeof(glProgramUniform2ui64NV))load("glProgramUniform2ui64NV");
	glProgramUniform3ui64NV = cast(typeof(glProgramUniform3ui64NV))load("glProgramUniform3ui64NV");
	glProgramUniform4ui64NV = cast(typeof(glProgramUniform4ui64NV))load("glProgramUniform4ui64NV");
	glProgramUniform1ui64vNV = cast(typeof(glProgramUniform1ui64vNV))load("glProgramUniform1ui64vNV");
	glProgramUniform2ui64vNV = cast(typeof(glProgramUniform2ui64vNV))load("glProgramUniform2ui64vNV");
	glProgramUniform3ui64vNV = cast(typeof(glProgramUniform3ui64vNV))load("glProgramUniform3ui64vNV");
	glProgramUniform4ui64vNV = cast(typeof(glProgramUniform4ui64vNV))load("glProgramUniform4ui64vNV");
	return;
}
void load_GL_AMD_vertex_shader_tessellator(Loader load) {
	if(!GL_AMD_vertex_shader_tessellator) return;
	glTessellationFactorAMD = cast(typeof(glTessellationFactorAMD))load("glTessellationFactorAMD");
	glTessellationModeAMD = cast(typeof(glTessellationModeAMD))load("glTessellationModeAMD");
	return;
}
void load_GL_ARB_invalidate_subdata(Loader load) {
	if(!GL_ARB_invalidate_subdata) return;
	glInvalidateTexSubImage = cast(typeof(glInvalidateTexSubImage))load("glInvalidateTexSubImage");
	glInvalidateTexImage = cast(typeof(glInvalidateTexImage))load("glInvalidateTexImage");
	glInvalidateBufferSubData = cast(typeof(glInvalidateBufferSubData))load("glInvalidateBufferSubData");
	glInvalidateBufferData = cast(typeof(glInvalidateBufferData))load("glInvalidateBufferData");
	glInvalidateFramebuffer = cast(typeof(glInvalidateFramebuffer))load("glInvalidateFramebuffer");
	glInvalidateSubFramebuffer = cast(typeof(glInvalidateSubFramebuffer))load("glInvalidateSubFramebuffer");
	return;
}
void load_GL_EXT_index_material(Loader load) {
	if(!GL_EXT_index_material) return;
	glIndexMaterialEXT = cast(typeof(glIndexMaterialEXT))load("glIndexMaterialEXT");
	return;
}
void load_GL_INTEL_parallel_arrays(Loader load) {
	if(!GL_INTEL_parallel_arrays) return;
	glVertexPointervINTEL = cast(typeof(glVertexPointervINTEL))load("glVertexPointervINTEL");
	glNormalPointervINTEL = cast(typeof(glNormalPointervINTEL))load("glNormalPointervINTEL");
	glColorPointervINTEL = cast(typeof(glColorPointervINTEL))load("glColorPointervINTEL");
	glTexCoordPointervINTEL = cast(typeof(glTexCoordPointervINTEL))load("glTexCoordPointervINTEL");
	return;
}
void load_GL_ATI_draw_buffers(Loader load) {
	if(!GL_ATI_draw_buffers) return;
	glDrawBuffersATI = cast(typeof(glDrawBuffersATI))load("glDrawBuffersATI");
	return;
}
void load_GL_SGIX_pixel_texture(Loader load) {
	if(!GL_SGIX_pixel_texture) return;
	glPixelTexGenSGIX = cast(typeof(glPixelTexGenSGIX))load("glPixelTexGenSGIX");
	return;
}
void load_GL_ARB_timer_query(Loader load) {
	if(!GL_ARB_timer_query) return;
	glQueryCounter = cast(typeof(glQueryCounter))load("glQueryCounter");
	glGetQueryObjecti64v = cast(typeof(glGetQueryObjecti64v))load("glGetQueryObjecti64v");
	glGetQueryObjectui64v = cast(typeof(glGetQueryObjectui64v))load("glGetQueryObjectui64v");
	return;
}
void load_GL_NV_parameter_buffer_object(Loader load) {
	if(!GL_NV_parameter_buffer_object) return;
	glProgramBufferParametersfvNV = cast(typeof(glProgramBufferParametersfvNV))load("glProgramBufferParametersfvNV");
	glProgramBufferParametersIivNV = cast(typeof(glProgramBufferParametersIivNV))load("glProgramBufferParametersIivNV");
	glProgramBufferParametersIuivNV = cast(typeof(glProgramBufferParametersIuivNV))load("glProgramBufferParametersIuivNV");
	return;
}
void load_GL_ARB_direct_state_access(Loader load) {
	if(!GL_ARB_direct_state_access) return;
	glCreateTransformFeedbacks = cast(typeof(glCreateTransformFeedbacks))load("glCreateTransformFeedbacks");
	glTransformFeedbackBufferBase = cast(typeof(glTransformFeedbackBufferBase))load("glTransformFeedbackBufferBase");
	glTransformFeedbackBufferRange = cast(typeof(glTransformFeedbackBufferRange))load("glTransformFeedbackBufferRange");
	glGetTransformFeedbackiv = cast(typeof(glGetTransformFeedbackiv))load("glGetTransformFeedbackiv");
	glGetTransformFeedbacki_v = cast(typeof(glGetTransformFeedbacki_v))load("glGetTransformFeedbacki_v");
	glGetTransformFeedbacki64_v = cast(typeof(glGetTransformFeedbacki64_v))load("glGetTransformFeedbacki64_v");
	glCreateBuffers = cast(typeof(glCreateBuffers))load("glCreateBuffers");
	glNamedBufferStorage = cast(typeof(glNamedBufferStorage))load("glNamedBufferStorage");
	glNamedBufferData = cast(typeof(glNamedBufferData))load("glNamedBufferData");
	glNamedBufferSubData = cast(typeof(glNamedBufferSubData))load("glNamedBufferSubData");
	glCopyNamedBufferSubData = cast(typeof(glCopyNamedBufferSubData))load("glCopyNamedBufferSubData");
	glClearNamedBufferData = cast(typeof(glClearNamedBufferData))load("glClearNamedBufferData");
	glClearNamedBufferSubData = cast(typeof(glClearNamedBufferSubData))load("glClearNamedBufferSubData");
	glMapNamedBuffer = cast(typeof(glMapNamedBuffer))load("glMapNamedBuffer");
	glMapNamedBufferRange = cast(typeof(glMapNamedBufferRange))load("glMapNamedBufferRange");
	glUnmapNamedBuffer = cast(typeof(glUnmapNamedBuffer))load("glUnmapNamedBuffer");
	glFlushMappedNamedBufferRange = cast(typeof(glFlushMappedNamedBufferRange))load("glFlushMappedNamedBufferRange");
	glGetNamedBufferParameteriv = cast(typeof(glGetNamedBufferParameteriv))load("glGetNamedBufferParameteriv");
	glGetNamedBufferParameteri64v = cast(typeof(glGetNamedBufferParameteri64v))load("glGetNamedBufferParameteri64v");
	glGetNamedBufferPointerv = cast(typeof(glGetNamedBufferPointerv))load("glGetNamedBufferPointerv");
	glGetNamedBufferSubData = cast(typeof(glGetNamedBufferSubData))load("glGetNamedBufferSubData");
	glCreateFramebuffers = cast(typeof(glCreateFramebuffers))load("glCreateFramebuffers");
	glNamedFramebufferRenderbuffer = cast(typeof(glNamedFramebufferRenderbuffer))load("glNamedFramebufferRenderbuffer");
	glNamedFramebufferParameteri = cast(typeof(glNamedFramebufferParameteri))load("glNamedFramebufferParameteri");
	glNamedFramebufferTexture = cast(typeof(glNamedFramebufferTexture))load("glNamedFramebufferTexture");
	glNamedFramebufferTextureLayer = cast(typeof(glNamedFramebufferTextureLayer))load("glNamedFramebufferTextureLayer");
	glNamedFramebufferDrawBuffer = cast(typeof(glNamedFramebufferDrawBuffer))load("glNamedFramebufferDrawBuffer");
	glNamedFramebufferDrawBuffers = cast(typeof(glNamedFramebufferDrawBuffers))load("glNamedFramebufferDrawBuffers");
	glNamedFramebufferReadBuffer = cast(typeof(glNamedFramebufferReadBuffer))load("glNamedFramebufferReadBuffer");
	glInvalidateNamedFramebufferData = cast(typeof(glInvalidateNamedFramebufferData))load("glInvalidateNamedFramebufferData");
	glInvalidateNamedFramebufferSubData = cast(typeof(glInvalidateNamedFramebufferSubData))load("glInvalidateNamedFramebufferSubData");
	glClearNamedFramebufferiv = cast(typeof(glClearNamedFramebufferiv))load("glClearNamedFramebufferiv");
	glClearNamedFramebufferuiv = cast(typeof(glClearNamedFramebufferuiv))load("glClearNamedFramebufferuiv");
	glClearNamedFramebufferfv = cast(typeof(glClearNamedFramebufferfv))load("glClearNamedFramebufferfv");
	glClearNamedFramebufferfi = cast(typeof(glClearNamedFramebufferfi))load("glClearNamedFramebufferfi");
	glBlitNamedFramebuffer = cast(typeof(glBlitNamedFramebuffer))load("glBlitNamedFramebuffer");
	glCheckNamedFramebufferStatus = cast(typeof(glCheckNamedFramebufferStatus))load("glCheckNamedFramebufferStatus");
	glGetNamedFramebufferParameteriv = cast(typeof(glGetNamedFramebufferParameteriv))load("glGetNamedFramebufferParameteriv");
	glGetNamedFramebufferAttachmentParameteriv = cast(typeof(glGetNamedFramebufferAttachmentParameteriv))load("glGetNamedFramebufferAttachmentParameteriv");
	glCreateRenderbuffers = cast(typeof(glCreateRenderbuffers))load("glCreateRenderbuffers");
	glNamedRenderbufferStorage = cast(typeof(glNamedRenderbufferStorage))load("glNamedRenderbufferStorage");
	glNamedRenderbufferStorageMultisample = cast(typeof(glNamedRenderbufferStorageMultisample))load("glNamedRenderbufferStorageMultisample");
	glGetNamedRenderbufferParameteriv = cast(typeof(glGetNamedRenderbufferParameteriv))load("glGetNamedRenderbufferParameteriv");
	glCreateTextures = cast(typeof(glCreateTextures))load("glCreateTextures");
	glTextureBuffer = cast(typeof(glTextureBuffer))load("glTextureBuffer");
	glTextureBufferRange = cast(typeof(glTextureBufferRange))load("glTextureBufferRange");
	glTextureStorage1D = cast(typeof(glTextureStorage1D))load("glTextureStorage1D");
	glTextureStorage2D = cast(typeof(glTextureStorage2D))load("glTextureStorage2D");
	glTextureStorage3D = cast(typeof(glTextureStorage3D))load("glTextureStorage3D");
	glTextureStorage2DMultisample = cast(typeof(glTextureStorage2DMultisample))load("glTextureStorage2DMultisample");
	glTextureStorage3DMultisample = cast(typeof(glTextureStorage3DMultisample))load("glTextureStorage3DMultisample");
	glTextureSubImage1D = cast(typeof(glTextureSubImage1D))load("glTextureSubImage1D");
	glTextureSubImage2D = cast(typeof(glTextureSubImage2D))load("glTextureSubImage2D");
	glTextureSubImage3D = cast(typeof(glTextureSubImage3D))load("glTextureSubImage3D");
	glCompressedTextureSubImage1D = cast(typeof(glCompressedTextureSubImage1D))load("glCompressedTextureSubImage1D");
	glCompressedTextureSubImage2D = cast(typeof(glCompressedTextureSubImage2D))load("glCompressedTextureSubImage2D");
	glCompressedTextureSubImage3D = cast(typeof(glCompressedTextureSubImage3D))load("glCompressedTextureSubImage3D");
	glCopyTextureSubImage1D = cast(typeof(glCopyTextureSubImage1D))load("glCopyTextureSubImage1D");
	glCopyTextureSubImage2D = cast(typeof(glCopyTextureSubImage2D))load("glCopyTextureSubImage2D");
	glCopyTextureSubImage3D = cast(typeof(glCopyTextureSubImage3D))load("glCopyTextureSubImage3D");
	glTextureParameterf = cast(typeof(glTextureParameterf))load("glTextureParameterf");
	glTextureParameterfv = cast(typeof(glTextureParameterfv))load("glTextureParameterfv");
	glTextureParameteri = cast(typeof(glTextureParameteri))load("glTextureParameteri");
	glTextureParameterIiv = cast(typeof(glTextureParameterIiv))load("glTextureParameterIiv");
	glTextureParameterIuiv = cast(typeof(glTextureParameterIuiv))load("glTextureParameterIuiv");
	glTextureParameteriv = cast(typeof(glTextureParameteriv))load("glTextureParameteriv");
	glGenerateTextureMipmap = cast(typeof(glGenerateTextureMipmap))load("glGenerateTextureMipmap");
	glBindTextureUnit = cast(typeof(glBindTextureUnit))load("glBindTextureUnit");
	glGetTextureImage = cast(typeof(glGetTextureImage))load("glGetTextureImage");
	glGetCompressedTextureImage = cast(typeof(glGetCompressedTextureImage))load("glGetCompressedTextureImage");
	glGetTextureLevelParameterfv = cast(typeof(glGetTextureLevelParameterfv))load("glGetTextureLevelParameterfv");
	glGetTextureLevelParameteriv = cast(typeof(glGetTextureLevelParameteriv))load("glGetTextureLevelParameteriv");
	glGetTextureParameterfv = cast(typeof(glGetTextureParameterfv))load("glGetTextureParameterfv");
	glGetTextureParameterIiv = cast(typeof(glGetTextureParameterIiv))load("glGetTextureParameterIiv");
	glGetTextureParameterIuiv = cast(typeof(glGetTextureParameterIuiv))load("glGetTextureParameterIuiv");
	glGetTextureParameteriv = cast(typeof(glGetTextureParameteriv))load("glGetTextureParameteriv");
	glCreateVertexArrays = cast(typeof(glCreateVertexArrays))load("glCreateVertexArrays");
	glDisableVertexArrayAttrib = cast(typeof(glDisableVertexArrayAttrib))load("glDisableVertexArrayAttrib");
	glEnableVertexArrayAttrib = cast(typeof(glEnableVertexArrayAttrib))load("glEnableVertexArrayAttrib");
	glVertexArrayElementBuffer = cast(typeof(glVertexArrayElementBuffer))load("glVertexArrayElementBuffer");
	glVertexArrayVertexBuffer = cast(typeof(glVertexArrayVertexBuffer))load("glVertexArrayVertexBuffer");
	glVertexArrayVertexBuffers = cast(typeof(glVertexArrayVertexBuffers))load("glVertexArrayVertexBuffers");
	glVertexArrayAttribBinding = cast(typeof(glVertexArrayAttribBinding))load("glVertexArrayAttribBinding");
	glVertexArrayAttribFormat = cast(typeof(glVertexArrayAttribFormat))load("glVertexArrayAttribFormat");
	glVertexArrayAttribIFormat = cast(typeof(glVertexArrayAttribIFormat))load("glVertexArrayAttribIFormat");
	glVertexArrayAttribLFormat = cast(typeof(glVertexArrayAttribLFormat))load("glVertexArrayAttribLFormat");
	glVertexArrayBindingDivisor = cast(typeof(glVertexArrayBindingDivisor))load("glVertexArrayBindingDivisor");
	glGetVertexArrayiv = cast(typeof(glGetVertexArrayiv))load("glGetVertexArrayiv");
	glGetVertexArrayIndexediv = cast(typeof(glGetVertexArrayIndexediv))load("glGetVertexArrayIndexediv");
	glGetVertexArrayIndexed64iv = cast(typeof(glGetVertexArrayIndexed64iv))load("glGetVertexArrayIndexed64iv");
	glCreateSamplers = cast(typeof(glCreateSamplers))load("glCreateSamplers");
	glCreateProgramPipelines = cast(typeof(glCreateProgramPipelines))load("glCreateProgramPipelines");
	glCreateQueries = cast(typeof(glCreateQueries))load("glCreateQueries");
	glGetQueryBufferObjecti64v = cast(typeof(glGetQueryBufferObjecti64v))load("glGetQueryBufferObjecti64v");
	glGetQueryBufferObjectiv = cast(typeof(glGetQueryBufferObjectiv))load("glGetQueryBufferObjectiv");
	glGetQueryBufferObjectui64v = cast(typeof(glGetQueryBufferObjectui64v))load("glGetQueryBufferObjectui64v");
	glGetQueryBufferObjectuiv = cast(typeof(glGetQueryBufferObjectuiv))load("glGetQueryBufferObjectuiv");
	return;
}
void load_GL_ARB_uniform_buffer_object(Loader load) {
	if(!GL_ARB_uniform_buffer_object) return;
	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices");
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv");
	glGetActiveUniformName = cast(typeof(glGetActiveUniformName))load("glGetActiveUniformName");
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex");
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv");
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName");
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding");
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange");
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase");
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v");
	return;
}
void load_GL_NV_transform_feedback2(Loader load) {
	if(!GL_NV_transform_feedback2) return;
	glBindTransformFeedbackNV = cast(typeof(glBindTransformFeedbackNV))load("glBindTransformFeedbackNV");
	glDeleteTransformFeedbacksNV = cast(typeof(glDeleteTransformFeedbacksNV))load("glDeleteTransformFeedbacksNV");
	glGenTransformFeedbacksNV = cast(typeof(glGenTransformFeedbacksNV))load("glGenTransformFeedbacksNV");
	glIsTransformFeedbackNV = cast(typeof(glIsTransformFeedbackNV))load("glIsTransformFeedbackNV");
	glPauseTransformFeedbackNV = cast(typeof(glPauseTransformFeedbackNV))load("glPauseTransformFeedbackNV");
	glResumeTransformFeedbackNV = cast(typeof(glResumeTransformFeedbackNV))load("glResumeTransformFeedbackNV");
	glDrawTransformFeedbackNV = cast(typeof(glDrawTransformFeedbackNV))load("glDrawTransformFeedbackNV");
	return;
}
void load_GL_EXT_blend_color(Loader load) {
	if(!GL_EXT_blend_color) return;
	glBlendColorEXT = cast(typeof(glBlendColorEXT))load("glBlendColorEXT");
	return;
}
void load_GL_EXT_histogram(Loader load) {
	if(!GL_EXT_histogram) return;
	glGetHistogramEXT = cast(typeof(glGetHistogramEXT))load("glGetHistogramEXT");
	glGetHistogramParameterfvEXT = cast(typeof(glGetHistogramParameterfvEXT))load("glGetHistogramParameterfvEXT");
	glGetHistogramParameterivEXT = cast(typeof(glGetHistogramParameterivEXT))load("glGetHistogramParameterivEXT");
	glGetMinmaxEXT = cast(typeof(glGetMinmaxEXT))load("glGetMinmaxEXT");
	glGetMinmaxParameterfvEXT = cast(typeof(glGetMinmaxParameterfvEXT))load("glGetMinmaxParameterfvEXT");
	glGetMinmaxParameterivEXT = cast(typeof(glGetMinmaxParameterivEXT))load("glGetMinmaxParameterivEXT");
	glHistogramEXT = cast(typeof(glHistogramEXT))load("glHistogramEXT");
	glMinmaxEXT = cast(typeof(glMinmaxEXT))load("glMinmaxEXT");
	glResetHistogramEXT = cast(typeof(glResetHistogramEXT))load("glResetHistogramEXT");
	glResetMinmaxEXT = cast(typeof(glResetMinmaxEXT))load("glResetMinmaxEXT");
	return;
}
void load_GL_EXT_polygon_offset(Loader load) {
	if(!GL_EXT_polygon_offset) return;
	glPolygonOffsetEXT = cast(typeof(glPolygonOffsetEXT))load("glPolygonOffsetEXT");
	return;
}
void load_GL_SGIS_point_parameters(Loader load) {
	if(!GL_SGIS_point_parameters) return;
	glPointParameterfSGIS = cast(typeof(glPointParameterfSGIS))load("glPointParameterfSGIS");
	glPointParameterfvSGIS = cast(typeof(glPointParameterfvSGIS))load("glPointParameterfvSGIS");
	return;
}
void load_GL_EXT_direct_state_access(Loader load) {
	if(!GL_EXT_direct_state_access) return;
	glMatrixLoadfEXT = cast(typeof(glMatrixLoadfEXT))load("glMatrixLoadfEXT");
	glMatrixLoaddEXT = cast(typeof(glMatrixLoaddEXT))load("glMatrixLoaddEXT");
	glMatrixMultfEXT = cast(typeof(glMatrixMultfEXT))load("glMatrixMultfEXT");
	glMatrixMultdEXT = cast(typeof(glMatrixMultdEXT))load("glMatrixMultdEXT");
	glMatrixLoadIdentityEXT = cast(typeof(glMatrixLoadIdentityEXT))load("glMatrixLoadIdentityEXT");
	glMatrixRotatefEXT = cast(typeof(glMatrixRotatefEXT))load("glMatrixRotatefEXT");
	glMatrixRotatedEXT = cast(typeof(glMatrixRotatedEXT))load("glMatrixRotatedEXT");
	glMatrixScalefEXT = cast(typeof(glMatrixScalefEXT))load("glMatrixScalefEXT");
	glMatrixScaledEXT = cast(typeof(glMatrixScaledEXT))load("glMatrixScaledEXT");
	glMatrixTranslatefEXT = cast(typeof(glMatrixTranslatefEXT))load("glMatrixTranslatefEXT");
	glMatrixTranslatedEXT = cast(typeof(glMatrixTranslatedEXT))load("glMatrixTranslatedEXT");
	glMatrixFrustumEXT = cast(typeof(glMatrixFrustumEXT))load("glMatrixFrustumEXT");
	glMatrixOrthoEXT = cast(typeof(glMatrixOrthoEXT))load("glMatrixOrthoEXT");
	glMatrixPopEXT = cast(typeof(glMatrixPopEXT))load("glMatrixPopEXT");
	glMatrixPushEXT = cast(typeof(glMatrixPushEXT))load("glMatrixPushEXT");
	glClientAttribDefaultEXT = cast(typeof(glClientAttribDefaultEXT))load("glClientAttribDefaultEXT");
	glPushClientAttribDefaultEXT = cast(typeof(glPushClientAttribDefaultEXT))load("glPushClientAttribDefaultEXT");
	glTextureParameterfEXT = cast(typeof(glTextureParameterfEXT))load("glTextureParameterfEXT");
	glTextureParameterfvEXT = cast(typeof(glTextureParameterfvEXT))load("glTextureParameterfvEXT");
	glTextureParameteriEXT = cast(typeof(glTextureParameteriEXT))load("glTextureParameteriEXT");
	glTextureParameterivEXT = cast(typeof(glTextureParameterivEXT))load("glTextureParameterivEXT");
	glTextureImage1DEXT = cast(typeof(glTextureImage1DEXT))load("glTextureImage1DEXT");
	glTextureImage2DEXT = cast(typeof(glTextureImage2DEXT))load("glTextureImage2DEXT");
	glTextureSubImage1DEXT = cast(typeof(glTextureSubImage1DEXT))load("glTextureSubImage1DEXT");
	glTextureSubImage2DEXT = cast(typeof(glTextureSubImage2DEXT))load("glTextureSubImage2DEXT");
	glCopyTextureImage1DEXT = cast(typeof(glCopyTextureImage1DEXT))load("glCopyTextureImage1DEXT");
	glCopyTextureImage2DEXT = cast(typeof(glCopyTextureImage2DEXT))load("glCopyTextureImage2DEXT");
	glCopyTextureSubImage1DEXT = cast(typeof(glCopyTextureSubImage1DEXT))load("glCopyTextureSubImage1DEXT");
	glCopyTextureSubImage2DEXT = cast(typeof(glCopyTextureSubImage2DEXT))load("glCopyTextureSubImage2DEXT");
	glGetTextureImageEXT = cast(typeof(glGetTextureImageEXT))load("glGetTextureImageEXT");
	glGetTextureParameterfvEXT = cast(typeof(glGetTextureParameterfvEXT))load("glGetTextureParameterfvEXT");
	glGetTextureParameterivEXT = cast(typeof(glGetTextureParameterivEXT))load("glGetTextureParameterivEXT");
	glGetTextureLevelParameterfvEXT = cast(typeof(glGetTextureLevelParameterfvEXT))load("glGetTextureLevelParameterfvEXT");
	glGetTextureLevelParameterivEXT = cast(typeof(glGetTextureLevelParameterivEXT))load("glGetTextureLevelParameterivEXT");
	glTextureImage3DEXT = cast(typeof(glTextureImage3DEXT))load("glTextureImage3DEXT");
	glTextureSubImage3DEXT = cast(typeof(glTextureSubImage3DEXT))load("glTextureSubImage3DEXT");
	glCopyTextureSubImage3DEXT = cast(typeof(glCopyTextureSubImage3DEXT))load("glCopyTextureSubImage3DEXT");
	glBindMultiTextureEXT = cast(typeof(glBindMultiTextureEXT))load("glBindMultiTextureEXT");
	glMultiTexCoordPointerEXT = cast(typeof(glMultiTexCoordPointerEXT))load("glMultiTexCoordPointerEXT");
	glMultiTexEnvfEXT = cast(typeof(glMultiTexEnvfEXT))load("glMultiTexEnvfEXT");
	glMultiTexEnvfvEXT = cast(typeof(glMultiTexEnvfvEXT))load("glMultiTexEnvfvEXT");
	glMultiTexEnviEXT = cast(typeof(glMultiTexEnviEXT))load("glMultiTexEnviEXT");
	glMultiTexEnvivEXT = cast(typeof(glMultiTexEnvivEXT))load("glMultiTexEnvivEXT");
	glMultiTexGendEXT = cast(typeof(glMultiTexGendEXT))load("glMultiTexGendEXT");
	glMultiTexGendvEXT = cast(typeof(glMultiTexGendvEXT))load("glMultiTexGendvEXT");
	glMultiTexGenfEXT = cast(typeof(glMultiTexGenfEXT))load("glMultiTexGenfEXT");
	glMultiTexGenfvEXT = cast(typeof(glMultiTexGenfvEXT))load("glMultiTexGenfvEXT");
	glMultiTexGeniEXT = cast(typeof(glMultiTexGeniEXT))load("glMultiTexGeniEXT");
	glMultiTexGenivEXT = cast(typeof(glMultiTexGenivEXT))load("glMultiTexGenivEXT");
	glGetMultiTexEnvfvEXT = cast(typeof(glGetMultiTexEnvfvEXT))load("glGetMultiTexEnvfvEXT");
	glGetMultiTexEnvivEXT = cast(typeof(glGetMultiTexEnvivEXT))load("glGetMultiTexEnvivEXT");
	glGetMultiTexGendvEXT = cast(typeof(glGetMultiTexGendvEXT))load("glGetMultiTexGendvEXT");
	glGetMultiTexGenfvEXT = cast(typeof(glGetMultiTexGenfvEXT))load("glGetMultiTexGenfvEXT");
	glGetMultiTexGenivEXT = cast(typeof(glGetMultiTexGenivEXT))load("glGetMultiTexGenivEXT");
	glMultiTexParameteriEXT = cast(typeof(glMultiTexParameteriEXT))load("glMultiTexParameteriEXT");
	glMultiTexParameterivEXT = cast(typeof(glMultiTexParameterivEXT))load("glMultiTexParameterivEXT");
	glMultiTexParameterfEXT = cast(typeof(glMultiTexParameterfEXT))load("glMultiTexParameterfEXT");
	glMultiTexParameterfvEXT = cast(typeof(glMultiTexParameterfvEXT))load("glMultiTexParameterfvEXT");
	glMultiTexImage1DEXT = cast(typeof(glMultiTexImage1DEXT))load("glMultiTexImage1DEXT");
	glMultiTexImage2DEXT = cast(typeof(glMultiTexImage2DEXT))load("glMultiTexImage2DEXT");
	glMultiTexSubImage1DEXT = cast(typeof(glMultiTexSubImage1DEXT))load("glMultiTexSubImage1DEXT");
	glMultiTexSubImage2DEXT = cast(typeof(glMultiTexSubImage2DEXT))load("glMultiTexSubImage2DEXT");
	glCopyMultiTexImage1DEXT = cast(typeof(glCopyMultiTexImage1DEXT))load("glCopyMultiTexImage1DEXT");
	glCopyMultiTexImage2DEXT = cast(typeof(glCopyMultiTexImage2DEXT))load("glCopyMultiTexImage2DEXT");
	glCopyMultiTexSubImage1DEXT = cast(typeof(glCopyMultiTexSubImage1DEXT))load("glCopyMultiTexSubImage1DEXT");
	glCopyMultiTexSubImage2DEXT = cast(typeof(glCopyMultiTexSubImage2DEXT))load("glCopyMultiTexSubImage2DEXT");
	glGetMultiTexImageEXT = cast(typeof(glGetMultiTexImageEXT))load("glGetMultiTexImageEXT");
	glGetMultiTexParameterfvEXT = cast(typeof(glGetMultiTexParameterfvEXT))load("glGetMultiTexParameterfvEXT");
	glGetMultiTexParameterivEXT = cast(typeof(glGetMultiTexParameterivEXT))load("glGetMultiTexParameterivEXT");
	glGetMultiTexLevelParameterfvEXT = cast(typeof(glGetMultiTexLevelParameterfvEXT))load("glGetMultiTexLevelParameterfvEXT");
	glGetMultiTexLevelParameterivEXT = cast(typeof(glGetMultiTexLevelParameterivEXT))load("glGetMultiTexLevelParameterivEXT");
	glMultiTexImage3DEXT = cast(typeof(glMultiTexImage3DEXT))load("glMultiTexImage3DEXT");
	glMultiTexSubImage3DEXT = cast(typeof(glMultiTexSubImage3DEXT))load("glMultiTexSubImage3DEXT");
	glCopyMultiTexSubImage3DEXT = cast(typeof(glCopyMultiTexSubImage3DEXT))load("glCopyMultiTexSubImage3DEXT");
	glEnableClientStateIndexedEXT = cast(typeof(glEnableClientStateIndexedEXT))load("glEnableClientStateIndexedEXT");
	glDisableClientStateIndexedEXT = cast(typeof(glDisableClientStateIndexedEXT))load("glDisableClientStateIndexedEXT");
	glGetFloatIndexedvEXT = cast(typeof(glGetFloatIndexedvEXT))load("glGetFloatIndexedvEXT");
	glGetDoubleIndexedvEXT = cast(typeof(glGetDoubleIndexedvEXT))load("glGetDoubleIndexedvEXT");
	glGetPointerIndexedvEXT = cast(typeof(glGetPointerIndexedvEXT))load("glGetPointerIndexedvEXT");
	glEnableIndexedEXT = cast(typeof(glEnableIndexedEXT))load("glEnableIndexedEXT");
	glDisableIndexedEXT = cast(typeof(glDisableIndexedEXT))load("glDisableIndexedEXT");
	glIsEnabledIndexedEXT = cast(typeof(glIsEnabledIndexedEXT))load("glIsEnabledIndexedEXT");
	glGetIntegerIndexedvEXT = cast(typeof(glGetIntegerIndexedvEXT))load("glGetIntegerIndexedvEXT");
	glGetBooleanIndexedvEXT = cast(typeof(glGetBooleanIndexedvEXT))load("glGetBooleanIndexedvEXT");
	glCompressedTextureImage3DEXT = cast(typeof(glCompressedTextureImage3DEXT))load("glCompressedTextureImage3DEXT");
	glCompressedTextureImage2DEXT = cast(typeof(glCompressedTextureImage2DEXT))load("glCompressedTextureImage2DEXT");
	glCompressedTextureImage1DEXT = cast(typeof(glCompressedTextureImage1DEXT))load("glCompressedTextureImage1DEXT");
	glCompressedTextureSubImage3DEXT = cast(typeof(glCompressedTextureSubImage3DEXT))load("glCompressedTextureSubImage3DEXT");
	glCompressedTextureSubImage2DEXT = cast(typeof(glCompressedTextureSubImage2DEXT))load("glCompressedTextureSubImage2DEXT");
	glCompressedTextureSubImage1DEXT = cast(typeof(glCompressedTextureSubImage1DEXT))load("glCompressedTextureSubImage1DEXT");
	glGetCompressedTextureImageEXT = cast(typeof(glGetCompressedTextureImageEXT))load("glGetCompressedTextureImageEXT");
	glCompressedMultiTexImage3DEXT = cast(typeof(glCompressedMultiTexImage3DEXT))load("glCompressedMultiTexImage3DEXT");
	glCompressedMultiTexImage2DEXT = cast(typeof(glCompressedMultiTexImage2DEXT))load("glCompressedMultiTexImage2DEXT");
	glCompressedMultiTexImage1DEXT = cast(typeof(glCompressedMultiTexImage1DEXT))load("glCompressedMultiTexImage1DEXT");
	glCompressedMultiTexSubImage3DEXT = cast(typeof(glCompressedMultiTexSubImage3DEXT))load("glCompressedMultiTexSubImage3DEXT");
	glCompressedMultiTexSubImage2DEXT = cast(typeof(glCompressedMultiTexSubImage2DEXT))load("glCompressedMultiTexSubImage2DEXT");
	glCompressedMultiTexSubImage1DEXT = cast(typeof(glCompressedMultiTexSubImage1DEXT))load("glCompressedMultiTexSubImage1DEXT");
	glGetCompressedMultiTexImageEXT = cast(typeof(glGetCompressedMultiTexImageEXT))load("glGetCompressedMultiTexImageEXT");
	glMatrixLoadTransposefEXT = cast(typeof(glMatrixLoadTransposefEXT))load("glMatrixLoadTransposefEXT");
	glMatrixLoadTransposedEXT = cast(typeof(glMatrixLoadTransposedEXT))load("glMatrixLoadTransposedEXT");
	glMatrixMultTransposefEXT = cast(typeof(glMatrixMultTransposefEXT))load("glMatrixMultTransposefEXT");
	glMatrixMultTransposedEXT = cast(typeof(glMatrixMultTransposedEXT))load("glMatrixMultTransposedEXT");
	glNamedBufferDataEXT = cast(typeof(glNamedBufferDataEXT))load("glNamedBufferDataEXT");
	glNamedBufferSubDataEXT = cast(typeof(glNamedBufferSubDataEXT))load("glNamedBufferSubDataEXT");
	glMapNamedBufferEXT = cast(typeof(glMapNamedBufferEXT))load("glMapNamedBufferEXT");
	glUnmapNamedBufferEXT = cast(typeof(glUnmapNamedBufferEXT))load("glUnmapNamedBufferEXT");
	glGetNamedBufferParameterivEXT = cast(typeof(glGetNamedBufferParameterivEXT))load("glGetNamedBufferParameterivEXT");
	glGetNamedBufferPointervEXT = cast(typeof(glGetNamedBufferPointervEXT))load("glGetNamedBufferPointervEXT");
	glGetNamedBufferSubDataEXT = cast(typeof(glGetNamedBufferSubDataEXT))load("glGetNamedBufferSubDataEXT");
	glProgramUniform1fEXT = cast(typeof(glProgramUniform1fEXT))load("glProgramUniform1fEXT");
	glProgramUniform2fEXT = cast(typeof(glProgramUniform2fEXT))load("glProgramUniform2fEXT");
	glProgramUniform3fEXT = cast(typeof(glProgramUniform3fEXT))load("glProgramUniform3fEXT");
	glProgramUniform4fEXT = cast(typeof(glProgramUniform4fEXT))load("glProgramUniform4fEXT");
	glProgramUniform1iEXT = cast(typeof(glProgramUniform1iEXT))load("glProgramUniform1iEXT");
	glProgramUniform2iEXT = cast(typeof(glProgramUniform2iEXT))load("glProgramUniform2iEXT");
	glProgramUniform3iEXT = cast(typeof(glProgramUniform3iEXT))load("glProgramUniform3iEXT");
	glProgramUniform4iEXT = cast(typeof(glProgramUniform4iEXT))load("glProgramUniform4iEXT");
	glProgramUniform1fvEXT = cast(typeof(glProgramUniform1fvEXT))load("glProgramUniform1fvEXT");
	glProgramUniform2fvEXT = cast(typeof(glProgramUniform2fvEXT))load("glProgramUniform2fvEXT");
	glProgramUniform3fvEXT = cast(typeof(glProgramUniform3fvEXT))load("glProgramUniform3fvEXT");
	glProgramUniform4fvEXT = cast(typeof(glProgramUniform4fvEXT))load("glProgramUniform4fvEXT");
	glProgramUniform1ivEXT = cast(typeof(glProgramUniform1ivEXT))load("glProgramUniform1ivEXT");
	glProgramUniform2ivEXT = cast(typeof(glProgramUniform2ivEXT))load("glProgramUniform2ivEXT");
	glProgramUniform3ivEXT = cast(typeof(glProgramUniform3ivEXT))load("glProgramUniform3ivEXT");
	glProgramUniform4ivEXT = cast(typeof(glProgramUniform4ivEXT))load("glProgramUniform4ivEXT");
	glProgramUniformMatrix2fvEXT = cast(typeof(glProgramUniformMatrix2fvEXT))load("glProgramUniformMatrix2fvEXT");
	glProgramUniformMatrix3fvEXT = cast(typeof(glProgramUniformMatrix3fvEXT))load("glProgramUniformMatrix3fvEXT");
	glProgramUniformMatrix4fvEXT = cast(typeof(glProgramUniformMatrix4fvEXT))load("glProgramUniformMatrix4fvEXT");
	glProgramUniformMatrix2x3fvEXT = cast(typeof(glProgramUniformMatrix2x3fvEXT))load("glProgramUniformMatrix2x3fvEXT");
	glProgramUniformMatrix3x2fvEXT = cast(typeof(glProgramUniformMatrix3x2fvEXT))load("glProgramUniformMatrix3x2fvEXT");
	glProgramUniformMatrix2x4fvEXT = cast(typeof(glProgramUniformMatrix2x4fvEXT))load("glProgramUniformMatrix2x4fvEXT");
	glProgramUniformMatrix4x2fvEXT = cast(typeof(glProgramUniformMatrix4x2fvEXT))load("glProgramUniformMatrix4x2fvEXT");
	glProgramUniformMatrix3x4fvEXT = cast(typeof(glProgramUniformMatrix3x4fvEXT))load("glProgramUniformMatrix3x4fvEXT");
	glProgramUniformMatrix4x3fvEXT = cast(typeof(glProgramUniformMatrix4x3fvEXT))load("glProgramUniformMatrix4x3fvEXT");
	glTextureBufferEXT = cast(typeof(glTextureBufferEXT))load("glTextureBufferEXT");
	glMultiTexBufferEXT = cast(typeof(glMultiTexBufferEXT))load("glMultiTexBufferEXT");
	glTextureParameterIivEXT = cast(typeof(glTextureParameterIivEXT))load("glTextureParameterIivEXT");
	glTextureParameterIuivEXT = cast(typeof(glTextureParameterIuivEXT))load("glTextureParameterIuivEXT");
	glGetTextureParameterIivEXT = cast(typeof(glGetTextureParameterIivEXT))load("glGetTextureParameterIivEXT");
	glGetTextureParameterIuivEXT = cast(typeof(glGetTextureParameterIuivEXT))load("glGetTextureParameterIuivEXT");
	glMultiTexParameterIivEXT = cast(typeof(glMultiTexParameterIivEXT))load("glMultiTexParameterIivEXT");
	glMultiTexParameterIuivEXT = cast(typeof(glMultiTexParameterIuivEXT))load("glMultiTexParameterIuivEXT");
	glGetMultiTexParameterIivEXT = cast(typeof(glGetMultiTexParameterIivEXT))load("glGetMultiTexParameterIivEXT");
	glGetMultiTexParameterIuivEXT = cast(typeof(glGetMultiTexParameterIuivEXT))load("glGetMultiTexParameterIuivEXT");
	glProgramUniform1uiEXT = cast(typeof(glProgramUniform1uiEXT))load("glProgramUniform1uiEXT");
	glProgramUniform2uiEXT = cast(typeof(glProgramUniform2uiEXT))load("glProgramUniform2uiEXT");
	glProgramUniform3uiEXT = cast(typeof(glProgramUniform3uiEXT))load("glProgramUniform3uiEXT");
	glProgramUniform4uiEXT = cast(typeof(glProgramUniform4uiEXT))load("glProgramUniform4uiEXT");
	glProgramUniform1uivEXT = cast(typeof(glProgramUniform1uivEXT))load("glProgramUniform1uivEXT");
	glProgramUniform2uivEXT = cast(typeof(glProgramUniform2uivEXT))load("glProgramUniform2uivEXT");
	glProgramUniform3uivEXT = cast(typeof(glProgramUniform3uivEXT))load("glProgramUniform3uivEXT");
	glProgramUniform4uivEXT = cast(typeof(glProgramUniform4uivEXT))load("glProgramUniform4uivEXT");
	glNamedProgramLocalParameters4fvEXT = cast(typeof(glNamedProgramLocalParameters4fvEXT))load("glNamedProgramLocalParameters4fvEXT");
	glNamedProgramLocalParameterI4iEXT = cast(typeof(glNamedProgramLocalParameterI4iEXT))load("glNamedProgramLocalParameterI4iEXT");
	glNamedProgramLocalParameterI4ivEXT = cast(typeof(glNamedProgramLocalParameterI4ivEXT))load("glNamedProgramLocalParameterI4ivEXT");
	glNamedProgramLocalParametersI4ivEXT = cast(typeof(glNamedProgramLocalParametersI4ivEXT))load("glNamedProgramLocalParametersI4ivEXT");
	glNamedProgramLocalParameterI4uiEXT = cast(typeof(glNamedProgramLocalParameterI4uiEXT))load("glNamedProgramLocalParameterI4uiEXT");
	glNamedProgramLocalParameterI4uivEXT = cast(typeof(glNamedProgramLocalParameterI4uivEXT))load("glNamedProgramLocalParameterI4uivEXT");
	glNamedProgramLocalParametersI4uivEXT = cast(typeof(glNamedProgramLocalParametersI4uivEXT))load("glNamedProgramLocalParametersI4uivEXT");
	glGetNamedProgramLocalParameterIivEXT = cast(typeof(glGetNamedProgramLocalParameterIivEXT))load("glGetNamedProgramLocalParameterIivEXT");
	glGetNamedProgramLocalParameterIuivEXT = cast(typeof(glGetNamedProgramLocalParameterIuivEXT))load("glGetNamedProgramLocalParameterIuivEXT");
	glEnableClientStateiEXT = cast(typeof(glEnableClientStateiEXT))load("glEnableClientStateiEXT");
	glDisableClientStateiEXT = cast(typeof(glDisableClientStateiEXT))load("glDisableClientStateiEXT");
	glGetFloati_vEXT = cast(typeof(glGetFloati_vEXT))load("glGetFloati_vEXT");
	glGetDoublei_vEXT = cast(typeof(glGetDoublei_vEXT))load("glGetDoublei_vEXT");
	glGetPointeri_vEXT = cast(typeof(glGetPointeri_vEXT))load("glGetPointeri_vEXT");
	glNamedProgramStringEXT = cast(typeof(glNamedProgramStringEXT))load("glNamedProgramStringEXT");
	glNamedProgramLocalParameter4dEXT = cast(typeof(glNamedProgramLocalParameter4dEXT))load("glNamedProgramLocalParameter4dEXT");
	glNamedProgramLocalParameter4dvEXT = cast(typeof(glNamedProgramLocalParameter4dvEXT))load("glNamedProgramLocalParameter4dvEXT");
	glNamedProgramLocalParameter4fEXT = cast(typeof(glNamedProgramLocalParameter4fEXT))load("glNamedProgramLocalParameter4fEXT");
	glNamedProgramLocalParameter4fvEXT = cast(typeof(glNamedProgramLocalParameter4fvEXT))load("glNamedProgramLocalParameter4fvEXT");
	glGetNamedProgramLocalParameterdvEXT = cast(typeof(glGetNamedProgramLocalParameterdvEXT))load("glGetNamedProgramLocalParameterdvEXT");
	glGetNamedProgramLocalParameterfvEXT = cast(typeof(glGetNamedProgramLocalParameterfvEXT))load("glGetNamedProgramLocalParameterfvEXT");
	glGetNamedProgramivEXT = cast(typeof(glGetNamedProgramivEXT))load("glGetNamedProgramivEXT");
	glGetNamedProgramStringEXT = cast(typeof(glGetNamedProgramStringEXT))load("glGetNamedProgramStringEXT");
	glNamedRenderbufferStorageEXT = cast(typeof(glNamedRenderbufferStorageEXT))load("glNamedRenderbufferStorageEXT");
	glGetNamedRenderbufferParameterivEXT = cast(typeof(glGetNamedRenderbufferParameterivEXT))load("glGetNamedRenderbufferParameterivEXT");
	glNamedRenderbufferStorageMultisampleEXT = cast(typeof(glNamedRenderbufferStorageMultisampleEXT))load("glNamedRenderbufferStorageMultisampleEXT");
	glNamedRenderbufferStorageMultisampleCoverageEXT = cast(typeof(glNamedRenderbufferStorageMultisampleCoverageEXT))load("glNamedRenderbufferStorageMultisampleCoverageEXT");
	glCheckNamedFramebufferStatusEXT = cast(typeof(glCheckNamedFramebufferStatusEXT))load("glCheckNamedFramebufferStatusEXT");
	glNamedFramebufferTexture1DEXT = cast(typeof(glNamedFramebufferTexture1DEXT))load("glNamedFramebufferTexture1DEXT");
	glNamedFramebufferTexture2DEXT = cast(typeof(glNamedFramebufferTexture2DEXT))load("glNamedFramebufferTexture2DEXT");
	glNamedFramebufferTexture3DEXT = cast(typeof(glNamedFramebufferTexture3DEXT))load("glNamedFramebufferTexture3DEXT");
	glNamedFramebufferRenderbufferEXT = cast(typeof(glNamedFramebufferRenderbufferEXT))load("glNamedFramebufferRenderbufferEXT");
	glGetNamedFramebufferAttachmentParameterivEXT = cast(typeof(glGetNamedFramebufferAttachmentParameterivEXT))load("glGetNamedFramebufferAttachmentParameterivEXT");
	glGenerateTextureMipmapEXT = cast(typeof(glGenerateTextureMipmapEXT))load("glGenerateTextureMipmapEXT");
	glGenerateMultiTexMipmapEXT = cast(typeof(glGenerateMultiTexMipmapEXT))load("glGenerateMultiTexMipmapEXT");
	glFramebufferDrawBufferEXT = cast(typeof(glFramebufferDrawBufferEXT))load("glFramebufferDrawBufferEXT");
	glFramebufferDrawBuffersEXT = cast(typeof(glFramebufferDrawBuffersEXT))load("glFramebufferDrawBuffersEXT");
	glFramebufferReadBufferEXT = cast(typeof(glFramebufferReadBufferEXT))load("glFramebufferReadBufferEXT");
	glGetFramebufferParameterivEXT = cast(typeof(glGetFramebufferParameterivEXT))load("glGetFramebufferParameterivEXT");
	glNamedCopyBufferSubDataEXT = cast(typeof(glNamedCopyBufferSubDataEXT))load("glNamedCopyBufferSubDataEXT");
	glNamedFramebufferTextureEXT = cast(typeof(glNamedFramebufferTextureEXT))load("glNamedFramebufferTextureEXT");
	glNamedFramebufferTextureLayerEXT = cast(typeof(glNamedFramebufferTextureLayerEXT))load("glNamedFramebufferTextureLayerEXT");
	glNamedFramebufferTextureFaceEXT = cast(typeof(glNamedFramebufferTextureFaceEXT))load("glNamedFramebufferTextureFaceEXT");
	glTextureRenderbufferEXT = cast(typeof(glTextureRenderbufferEXT))load("glTextureRenderbufferEXT");
	glMultiTexRenderbufferEXT = cast(typeof(glMultiTexRenderbufferEXT))load("glMultiTexRenderbufferEXT");
	glVertexArrayVertexOffsetEXT = cast(typeof(glVertexArrayVertexOffsetEXT))load("glVertexArrayVertexOffsetEXT");
	glVertexArrayColorOffsetEXT = cast(typeof(glVertexArrayColorOffsetEXT))load("glVertexArrayColorOffsetEXT");
	glVertexArrayEdgeFlagOffsetEXT = cast(typeof(glVertexArrayEdgeFlagOffsetEXT))load("glVertexArrayEdgeFlagOffsetEXT");
	glVertexArrayIndexOffsetEXT = cast(typeof(glVertexArrayIndexOffsetEXT))load("glVertexArrayIndexOffsetEXT");
	glVertexArrayNormalOffsetEXT = cast(typeof(glVertexArrayNormalOffsetEXT))load("glVertexArrayNormalOffsetEXT");
	glVertexArrayTexCoordOffsetEXT = cast(typeof(glVertexArrayTexCoordOffsetEXT))load("glVertexArrayTexCoordOffsetEXT");
	glVertexArrayMultiTexCoordOffsetEXT = cast(typeof(glVertexArrayMultiTexCoordOffsetEXT))load("glVertexArrayMultiTexCoordOffsetEXT");
	glVertexArrayFogCoordOffsetEXT = cast(typeof(glVertexArrayFogCoordOffsetEXT))load("glVertexArrayFogCoordOffsetEXT");
	glVertexArraySecondaryColorOffsetEXT = cast(typeof(glVertexArraySecondaryColorOffsetEXT))load("glVertexArraySecondaryColorOffsetEXT");
	glVertexArrayVertexAttribOffsetEXT = cast(typeof(glVertexArrayVertexAttribOffsetEXT))load("glVertexArrayVertexAttribOffsetEXT");
	glVertexArrayVertexAttribIOffsetEXT = cast(typeof(glVertexArrayVertexAttribIOffsetEXT))load("glVertexArrayVertexAttribIOffsetEXT");
	glEnableVertexArrayEXT = cast(typeof(glEnableVertexArrayEXT))load("glEnableVertexArrayEXT");
	glDisableVertexArrayEXT = cast(typeof(glDisableVertexArrayEXT))load("glDisableVertexArrayEXT");
	glEnableVertexArrayAttribEXT = cast(typeof(glEnableVertexArrayAttribEXT))load("glEnableVertexArrayAttribEXT");
	glDisableVertexArrayAttribEXT = cast(typeof(glDisableVertexArrayAttribEXT))load("glDisableVertexArrayAttribEXT");
	glGetVertexArrayIntegervEXT = cast(typeof(glGetVertexArrayIntegervEXT))load("glGetVertexArrayIntegervEXT");
	glGetVertexArrayPointervEXT = cast(typeof(glGetVertexArrayPointervEXT))load("glGetVertexArrayPointervEXT");
	glGetVertexArrayIntegeri_vEXT = cast(typeof(glGetVertexArrayIntegeri_vEXT))load("glGetVertexArrayIntegeri_vEXT");
	glGetVertexArrayPointeri_vEXT = cast(typeof(glGetVertexArrayPointeri_vEXT))load("glGetVertexArrayPointeri_vEXT");
	glMapNamedBufferRangeEXT = cast(typeof(glMapNamedBufferRangeEXT))load("glMapNamedBufferRangeEXT");
	glFlushMappedNamedBufferRangeEXT = cast(typeof(glFlushMappedNamedBufferRangeEXT))load("glFlushMappedNamedBufferRangeEXT");
	glNamedBufferStorageEXT = cast(typeof(glNamedBufferStorageEXT))load("glNamedBufferStorageEXT");
	glClearNamedBufferDataEXT = cast(typeof(glClearNamedBufferDataEXT))load("glClearNamedBufferDataEXT");
	glClearNamedBufferSubDataEXT = cast(typeof(glClearNamedBufferSubDataEXT))load("glClearNamedBufferSubDataEXT");
	glNamedFramebufferParameteriEXT = cast(typeof(glNamedFramebufferParameteriEXT))load("glNamedFramebufferParameteriEXT");
	glGetNamedFramebufferParameterivEXT = cast(typeof(glGetNamedFramebufferParameterivEXT))load("glGetNamedFramebufferParameterivEXT");
	glProgramUniform1dEXT = cast(typeof(glProgramUniform1dEXT))load("glProgramUniform1dEXT");
	glProgramUniform2dEXT = cast(typeof(glProgramUniform2dEXT))load("glProgramUniform2dEXT");
	glProgramUniform3dEXT = cast(typeof(glProgramUniform3dEXT))load("glProgramUniform3dEXT");
	glProgramUniform4dEXT = cast(typeof(glProgramUniform4dEXT))load("glProgramUniform4dEXT");
	glProgramUniform1dvEXT = cast(typeof(glProgramUniform1dvEXT))load("glProgramUniform1dvEXT");
	glProgramUniform2dvEXT = cast(typeof(glProgramUniform2dvEXT))load("glProgramUniform2dvEXT");
	glProgramUniform3dvEXT = cast(typeof(glProgramUniform3dvEXT))load("glProgramUniform3dvEXT");
	glProgramUniform4dvEXT = cast(typeof(glProgramUniform4dvEXT))load("glProgramUniform4dvEXT");
	glProgramUniformMatrix2dvEXT = cast(typeof(glProgramUniformMatrix2dvEXT))load("glProgramUniformMatrix2dvEXT");
	glProgramUniformMatrix3dvEXT = cast(typeof(glProgramUniformMatrix3dvEXT))load("glProgramUniformMatrix3dvEXT");
	glProgramUniformMatrix4dvEXT = cast(typeof(glProgramUniformMatrix4dvEXT))load("glProgramUniformMatrix4dvEXT");
	glProgramUniformMatrix2x3dvEXT = cast(typeof(glProgramUniformMatrix2x3dvEXT))load("glProgramUniformMatrix2x3dvEXT");
	glProgramUniformMatrix2x4dvEXT = cast(typeof(glProgramUniformMatrix2x4dvEXT))load("glProgramUniformMatrix2x4dvEXT");
	glProgramUniformMatrix3x2dvEXT = cast(typeof(glProgramUniformMatrix3x2dvEXT))load("glProgramUniformMatrix3x2dvEXT");
	glProgramUniformMatrix3x4dvEXT = cast(typeof(glProgramUniformMatrix3x4dvEXT))load("glProgramUniformMatrix3x4dvEXT");
	glProgramUniformMatrix4x2dvEXT = cast(typeof(glProgramUniformMatrix4x2dvEXT))load("glProgramUniformMatrix4x2dvEXT");
	glProgramUniformMatrix4x3dvEXT = cast(typeof(glProgramUniformMatrix4x3dvEXT))load("glProgramUniformMatrix4x3dvEXT");
	glTextureBufferRangeEXT = cast(typeof(glTextureBufferRangeEXT))load("glTextureBufferRangeEXT");
	glTextureStorage1DEXT = cast(typeof(glTextureStorage1DEXT))load("glTextureStorage1DEXT");
	glTextureStorage2DEXT = cast(typeof(glTextureStorage2DEXT))load("glTextureStorage2DEXT");
	glTextureStorage3DEXT = cast(typeof(glTextureStorage3DEXT))load("glTextureStorage3DEXT");
	glTextureStorage2DMultisampleEXT = cast(typeof(glTextureStorage2DMultisampleEXT))load("glTextureStorage2DMultisampleEXT");
	glTextureStorage3DMultisampleEXT = cast(typeof(glTextureStorage3DMultisampleEXT))load("glTextureStorage3DMultisampleEXT");
	glVertexArrayBindVertexBufferEXT = cast(typeof(glVertexArrayBindVertexBufferEXT))load("glVertexArrayBindVertexBufferEXT");
	glVertexArrayVertexAttribFormatEXT = cast(typeof(glVertexArrayVertexAttribFormatEXT))load("glVertexArrayVertexAttribFormatEXT");
	glVertexArrayVertexAttribIFormatEXT = cast(typeof(glVertexArrayVertexAttribIFormatEXT))load("glVertexArrayVertexAttribIFormatEXT");
	glVertexArrayVertexAttribLFormatEXT = cast(typeof(glVertexArrayVertexAttribLFormatEXT))load("glVertexArrayVertexAttribLFormatEXT");
	glVertexArrayVertexAttribBindingEXT = cast(typeof(glVertexArrayVertexAttribBindingEXT))load("glVertexArrayVertexAttribBindingEXT");
	glVertexArrayVertexBindingDivisorEXT = cast(typeof(glVertexArrayVertexBindingDivisorEXT))load("glVertexArrayVertexBindingDivisorEXT");
	glVertexArrayVertexAttribLOffsetEXT = cast(typeof(glVertexArrayVertexAttribLOffsetEXT))load("glVertexArrayVertexAttribLOffsetEXT");
	glTexturePageCommitmentEXT = cast(typeof(glTexturePageCommitmentEXT))load("glTexturePageCommitmentEXT");
	glVertexArrayVertexAttribDivisorEXT = cast(typeof(glVertexArrayVertexAttribDivisorEXT))load("glVertexArrayVertexAttribDivisorEXT");
	return;
}
void load_GL_AMD_sample_positions(Loader load) {
	if(!GL_AMD_sample_positions) return;
	glSetMultisamplefvAMD = cast(typeof(glSetMultisamplefvAMD))load("glSetMultisamplefvAMD");
	return;
}
void load_GL_NV_vertex_program(Loader load) {
	if(!GL_NV_vertex_program) return;
	glAreProgramsResidentNV = cast(typeof(glAreProgramsResidentNV))load("glAreProgramsResidentNV");
	glBindProgramNV = cast(typeof(glBindProgramNV))load("glBindProgramNV");
	glDeleteProgramsNV = cast(typeof(glDeleteProgramsNV))load("glDeleteProgramsNV");
	glExecuteProgramNV = cast(typeof(glExecuteProgramNV))load("glExecuteProgramNV");
	glGenProgramsNV = cast(typeof(glGenProgramsNV))load("glGenProgramsNV");
	glGetProgramParameterdvNV = cast(typeof(glGetProgramParameterdvNV))load("glGetProgramParameterdvNV");
	glGetProgramParameterfvNV = cast(typeof(glGetProgramParameterfvNV))load("glGetProgramParameterfvNV");
	glGetProgramivNV = cast(typeof(glGetProgramivNV))load("glGetProgramivNV");
	glGetProgramStringNV = cast(typeof(glGetProgramStringNV))load("glGetProgramStringNV");
	glGetTrackMatrixivNV = cast(typeof(glGetTrackMatrixivNV))load("glGetTrackMatrixivNV");
	glGetVertexAttribdvNV = cast(typeof(glGetVertexAttribdvNV))load("glGetVertexAttribdvNV");
	glGetVertexAttribfvNV = cast(typeof(glGetVertexAttribfvNV))load("glGetVertexAttribfvNV");
	glGetVertexAttribivNV = cast(typeof(glGetVertexAttribivNV))load("glGetVertexAttribivNV");
	glGetVertexAttribPointervNV = cast(typeof(glGetVertexAttribPointervNV))load("glGetVertexAttribPointervNV");
	glIsProgramNV = cast(typeof(glIsProgramNV))load("glIsProgramNV");
	glLoadProgramNV = cast(typeof(glLoadProgramNV))load("glLoadProgramNV");
	glProgramParameter4dNV = cast(typeof(glProgramParameter4dNV))load("glProgramParameter4dNV");
	glProgramParameter4dvNV = cast(typeof(glProgramParameter4dvNV))load("glProgramParameter4dvNV");
	glProgramParameter4fNV = cast(typeof(glProgramParameter4fNV))load("glProgramParameter4fNV");
	glProgramParameter4fvNV = cast(typeof(glProgramParameter4fvNV))load("glProgramParameter4fvNV");
	glProgramParameters4dvNV = cast(typeof(glProgramParameters4dvNV))load("glProgramParameters4dvNV");
	glProgramParameters4fvNV = cast(typeof(glProgramParameters4fvNV))load("glProgramParameters4fvNV");
	glRequestResidentProgramsNV = cast(typeof(glRequestResidentProgramsNV))load("glRequestResidentProgramsNV");
	glTrackMatrixNV = cast(typeof(glTrackMatrixNV))load("glTrackMatrixNV");
	glVertexAttribPointerNV = cast(typeof(glVertexAttribPointerNV))load("glVertexAttribPointerNV");
	glVertexAttrib1dNV = cast(typeof(glVertexAttrib1dNV))load("glVertexAttrib1dNV");
	glVertexAttrib1dvNV = cast(typeof(glVertexAttrib1dvNV))load("glVertexAttrib1dvNV");
	glVertexAttrib1fNV = cast(typeof(glVertexAttrib1fNV))load("glVertexAttrib1fNV");
	glVertexAttrib1fvNV = cast(typeof(glVertexAttrib1fvNV))load("glVertexAttrib1fvNV");
	glVertexAttrib1sNV = cast(typeof(glVertexAttrib1sNV))load("glVertexAttrib1sNV");
	glVertexAttrib1svNV = cast(typeof(glVertexAttrib1svNV))load("glVertexAttrib1svNV");
	glVertexAttrib2dNV = cast(typeof(glVertexAttrib2dNV))load("glVertexAttrib2dNV");
	glVertexAttrib2dvNV = cast(typeof(glVertexAttrib2dvNV))load("glVertexAttrib2dvNV");
	glVertexAttrib2fNV = cast(typeof(glVertexAttrib2fNV))load("glVertexAttrib2fNV");
	glVertexAttrib2fvNV = cast(typeof(glVertexAttrib2fvNV))load("glVertexAttrib2fvNV");
	glVertexAttrib2sNV = cast(typeof(glVertexAttrib2sNV))load("glVertexAttrib2sNV");
	glVertexAttrib2svNV = cast(typeof(glVertexAttrib2svNV))load("glVertexAttrib2svNV");
	glVertexAttrib3dNV = cast(typeof(glVertexAttrib3dNV))load("glVertexAttrib3dNV");
	glVertexAttrib3dvNV = cast(typeof(glVertexAttrib3dvNV))load("glVertexAttrib3dvNV");
	glVertexAttrib3fNV = cast(typeof(glVertexAttrib3fNV))load("glVertexAttrib3fNV");
	glVertexAttrib3fvNV = cast(typeof(glVertexAttrib3fvNV))load("glVertexAttrib3fvNV");
	glVertexAttrib3sNV = cast(typeof(glVertexAttrib3sNV))load("glVertexAttrib3sNV");
	glVertexAttrib3svNV = cast(typeof(glVertexAttrib3svNV))load("glVertexAttrib3svNV");
	glVertexAttrib4dNV = cast(typeof(glVertexAttrib4dNV))load("glVertexAttrib4dNV");
	glVertexAttrib4dvNV = cast(typeof(glVertexAttrib4dvNV))load("glVertexAttrib4dvNV");
	glVertexAttrib4fNV = cast(typeof(glVertexAttrib4fNV))load("glVertexAttrib4fNV");
	glVertexAttrib4fvNV = cast(typeof(glVertexAttrib4fvNV))load("glVertexAttrib4fvNV");
	glVertexAttrib4sNV = cast(typeof(glVertexAttrib4sNV))load("glVertexAttrib4sNV");
	glVertexAttrib4svNV = cast(typeof(glVertexAttrib4svNV))load("glVertexAttrib4svNV");
	glVertexAttrib4ubNV = cast(typeof(glVertexAttrib4ubNV))load("glVertexAttrib4ubNV");
	glVertexAttrib4ubvNV = cast(typeof(glVertexAttrib4ubvNV))load("glVertexAttrib4ubvNV");
	glVertexAttribs1dvNV = cast(typeof(glVertexAttribs1dvNV))load("glVertexAttribs1dvNV");
	glVertexAttribs1fvNV = cast(typeof(glVertexAttribs1fvNV))load("glVertexAttribs1fvNV");
	glVertexAttribs1svNV = cast(typeof(glVertexAttribs1svNV))load("glVertexAttribs1svNV");
	glVertexAttribs2dvNV = cast(typeof(glVertexAttribs2dvNV))load("glVertexAttribs2dvNV");
	glVertexAttribs2fvNV = cast(typeof(glVertexAttribs2fvNV))load("glVertexAttribs2fvNV");
	glVertexAttribs2svNV = cast(typeof(glVertexAttribs2svNV))load("glVertexAttribs2svNV");
	glVertexAttribs3dvNV = cast(typeof(glVertexAttribs3dvNV))load("glVertexAttribs3dvNV");
	glVertexAttribs3fvNV = cast(typeof(glVertexAttribs3fvNV))load("glVertexAttribs3fvNV");
	glVertexAttribs3svNV = cast(typeof(glVertexAttribs3svNV))load("glVertexAttribs3svNV");
	glVertexAttribs4dvNV = cast(typeof(glVertexAttribs4dvNV))load("glVertexAttribs4dvNV");
	glVertexAttribs4fvNV = cast(typeof(glVertexAttribs4fvNV))load("glVertexAttribs4fvNV");
	glVertexAttribs4svNV = cast(typeof(glVertexAttribs4svNV))load("glVertexAttribs4svNV");
	glVertexAttribs4ubvNV = cast(typeof(glVertexAttribs4ubvNV))load("glVertexAttribs4ubvNV");
	return;
}
void load_GL_EXT_vertex_shader(Loader load) {
	if(!GL_EXT_vertex_shader) return;
	glBeginVertexShaderEXT = cast(typeof(glBeginVertexShaderEXT))load("glBeginVertexShaderEXT");
	glEndVertexShaderEXT = cast(typeof(glEndVertexShaderEXT))load("glEndVertexShaderEXT");
	glBindVertexShaderEXT = cast(typeof(glBindVertexShaderEXT))load("glBindVertexShaderEXT");
	glGenVertexShadersEXT = cast(typeof(glGenVertexShadersEXT))load("glGenVertexShadersEXT");
	glDeleteVertexShaderEXT = cast(typeof(glDeleteVertexShaderEXT))load("glDeleteVertexShaderEXT");
	glShaderOp1EXT = cast(typeof(glShaderOp1EXT))load("glShaderOp1EXT");
	glShaderOp2EXT = cast(typeof(glShaderOp2EXT))load("glShaderOp2EXT");
	glShaderOp3EXT = cast(typeof(glShaderOp3EXT))load("glShaderOp3EXT");
	glSwizzleEXT = cast(typeof(glSwizzleEXT))load("glSwizzleEXT");
	glWriteMaskEXT = cast(typeof(glWriteMaskEXT))load("glWriteMaskEXT");
	glInsertComponentEXT = cast(typeof(glInsertComponentEXT))load("glInsertComponentEXT");
	glExtractComponentEXT = cast(typeof(glExtractComponentEXT))load("glExtractComponentEXT");
	glGenSymbolsEXT = cast(typeof(glGenSymbolsEXT))load("glGenSymbolsEXT");
	glSetInvariantEXT = cast(typeof(glSetInvariantEXT))load("glSetInvariantEXT");
	glSetLocalConstantEXT = cast(typeof(glSetLocalConstantEXT))load("glSetLocalConstantEXT");
	glVariantbvEXT = cast(typeof(glVariantbvEXT))load("glVariantbvEXT");
	glVariantsvEXT = cast(typeof(glVariantsvEXT))load("glVariantsvEXT");
	glVariantivEXT = cast(typeof(glVariantivEXT))load("glVariantivEXT");
	glVariantfvEXT = cast(typeof(glVariantfvEXT))load("glVariantfvEXT");
	glVariantdvEXT = cast(typeof(glVariantdvEXT))load("glVariantdvEXT");
	glVariantubvEXT = cast(typeof(glVariantubvEXT))load("glVariantubvEXT");
	glVariantusvEXT = cast(typeof(glVariantusvEXT))load("glVariantusvEXT");
	glVariantuivEXT = cast(typeof(glVariantuivEXT))load("glVariantuivEXT");
	glVariantPointerEXT = cast(typeof(glVariantPointerEXT))load("glVariantPointerEXT");
	glEnableVariantClientStateEXT = cast(typeof(glEnableVariantClientStateEXT))load("glEnableVariantClientStateEXT");
	glDisableVariantClientStateEXT = cast(typeof(glDisableVariantClientStateEXT))load("glDisableVariantClientStateEXT");
	glBindLightParameterEXT = cast(typeof(glBindLightParameterEXT))load("glBindLightParameterEXT");
	glBindMaterialParameterEXT = cast(typeof(glBindMaterialParameterEXT))load("glBindMaterialParameterEXT");
	glBindTexGenParameterEXT = cast(typeof(glBindTexGenParameterEXT))load("glBindTexGenParameterEXT");
	glBindTextureUnitParameterEXT = cast(typeof(glBindTextureUnitParameterEXT))load("glBindTextureUnitParameterEXT");
	glBindParameterEXT = cast(typeof(glBindParameterEXT))load("glBindParameterEXT");
	glIsVariantEnabledEXT = cast(typeof(glIsVariantEnabledEXT))load("glIsVariantEnabledEXT");
	glGetVariantBooleanvEXT = cast(typeof(glGetVariantBooleanvEXT))load("glGetVariantBooleanvEXT");
	glGetVariantIntegervEXT = cast(typeof(glGetVariantIntegervEXT))load("glGetVariantIntegervEXT");
	glGetVariantFloatvEXT = cast(typeof(glGetVariantFloatvEXT))load("glGetVariantFloatvEXT");
	glGetVariantPointervEXT = cast(typeof(glGetVariantPointervEXT))load("glGetVariantPointervEXT");
	glGetInvariantBooleanvEXT = cast(typeof(glGetInvariantBooleanvEXT))load("glGetInvariantBooleanvEXT");
	glGetInvariantIntegervEXT = cast(typeof(glGetInvariantIntegervEXT))load("glGetInvariantIntegervEXT");
	glGetInvariantFloatvEXT = cast(typeof(glGetInvariantFloatvEXT))load("glGetInvariantFloatvEXT");
	glGetLocalConstantBooleanvEXT = cast(typeof(glGetLocalConstantBooleanvEXT))load("glGetLocalConstantBooleanvEXT");
	glGetLocalConstantIntegervEXT = cast(typeof(glGetLocalConstantIntegervEXT))load("glGetLocalConstantIntegervEXT");
	glGetLocalConstantFloatvEXT = cast(typeof(glGetLocalConstantFloatvEXT))load("glGetLocalConstantFloatvEXT");
	return;
}
void load_GL_EXT_blend_func_separate(Loader load) {
	if(!GL_EXT_blend_func_separate) return;
	glBlendFuncSeparateEXT = cast(typeof(glBlendFuncSeparateEXT))load("glBlendFuncSeparateEXT");
	return;
}
void load_GL_APPLE_fence(Loader load) {
	if(!GL_APPLE_fence) return;
	glGenFencesAPPLE = cast(typeof(glGenFencesAPPLE))load("glGenFencesAPPLE");
	glDeleteFencesAPPLE = cast(typeof(glDeleteFencesAPPLE))load("glDeleteFencesAPPLE");
	glSetFenceAPPLE = cast(typeof(glSetFenceAPPLE))load("glSetFenceAPPLE");
	glIsFenceAPPLE = cast(typeof(glIsFenceAPPLE))load("glIsFenceAPPLE");
	glTestFenceAPPLE = cast(typeof(glTestFenceAPPLE))load("glTestFenceAPPLE");
	glFinishFenceAPPLE = cast(typeof(glFinishFenceAPPLE))load("glFinishFenceAPPLE");
	glTestObjectAPPLE = cast(typeof(glTestObjectAPPLE))load("glTestObjectAPPLE");
	glFinishObjectAPPLE = cast(typeof(glFinishObjectAPPLE))load("glFinishObjectAPPLE");
	return;
}
void load_GL_OES_byte_coordinates(Loader load) {
	if(!GL_OES_byte_coordinates) return;
	glMultiTexCoord1bOES = cast(typeof(glMultiTexCoord1bOES))load("glMultiTexCoord1bOES");
	glMultiTexCoord1bvOES = cast(typeof(glMultiTexCoord1bvOES))load("glMultiTexCoord1bvOES");
	glMultiTexCoord2bOES = cast(typeof(glMultiTexCoord2bOES))load("glMultiTexCoord2bOES");
	glMultiTexCoord2bvOES = cast(typeof(glMultiTexCoord2bvOES))load("glMultiTexCoord2bvOES");
	glMultiTexCoord3bOES = cast(typeof(glMultiTexCoord3bOES))load("glMultiTexCoord3bOES");
	glMultiTexCoord3bvOES = cast(typeof(glMultiTexCoord3bvOES))load("glMultiTexCoord3bvOES");
	glMultiTexCoord4bOES = cast(typeof(glMultiTexCoord4bOES))load("glMultiTexCoord4bOES");
	glMultiTexCoord4bvOES = cast(typeof(glMultiTexCoord4bvOES))load("glMultiTexCoord4bvOES");
	glTexCoord1bOES = cast(typeof(glTexCoord1bOES))load("glTexCoord1bOES");
	glTexCoord1bvOES = cast(typeof(glTexCoord1bvOES))load("glTexCoord1bvOES");
	glTexCoord2bOES = cast(typeof(glTexCoord2bOES))load("glTexCoord2bOES");
	glTexCoord2bvOES = cast(typeof(glTexCoord2bvOES))load("glTexCoord2bvOES");
	glTexCoord3bOES = cast(typeof(glTexCoord3bOES))load("glTexCoord3bOES");
	glTexCoord3bvOES = cast(typeof(glTexCoord3bvOES))load("glTexCoord3bvOES");
	glTexCoord4bOES = cast(typeof(glTexCoord4bOES))load("glTexCoord4bOES");
	glTexCoord4bvOES = cast(typeof(glTexCoord4bvOES))load("glTexCoord4bvOES");
	glVertex2bOES = cast(typeof(glVertex2bOES))load("glVertex2bOES");
	glVertex2bvOES = cast(typeof(glVertex2bvOES))load("glVertex2bvOES");
	glVertex3bOES = cast(typeof(glVertex3bOES))load("glVertex3bOES");
	glVertex3bvOES = cast(typeof(glVertex3bvOES))load("glVertex3bvOES");
	glVertex4bOES = cast(typeof(glVertex4bOES))load("glVertex4bOES");
	glVertex4bvOES = cast(typeof(glVertex4bvOES))load("glVertex4bvOES");
	return;
}
void load_GL_ARB_transpose_matrix(Loader load) {
	if(!GL_ARB_transpose_matrix) return;
	glLoadTransposeMatrixfARB = cast(typeof(glLoadTransposeMatrixfARB))load("glLoadTransposeMatrixfARB");
	glLoadTransposeMatrixdARB = cast(typeof(glLoadTransposeMatrixdARB))load("glLoadTransposeMatrixdARB");
	glMultTransposeMatrixfARB = cast(typeof(glMultTransposeMatrixfARB))load("glMultTransposeMatrixfARB");
	glMultTransposeMatrixdARB = cast(typeof(glMultTransposeMatrixdARB))load("glMultTransposeMatrixdARB");
	return;
}
void load_GL_ARB_provoking_vertex(Loader load) {
	if(!GL_ARB_provoking_vertex) return;
	glProvokingVertex = cast(typeof(glProvokingVertex))load("glProvokingVertex");
	return;
}
void load_GL_EXT_fog_coord(Loader load) {
	if(!GL_EXT_fog_coord) return;
	glFogCoordfEXT = cast(typeof(glFogCoordfEXT))load("glFogCoordfEXT");
	glFogCoordfvEXT = cast(typeof(glFogCoordfvEXT))load("glFogCoordfvEXT");
	glFogCoorddEXT = cast(typeof(glFogCoorddEXT))load("glFogCoorddEXT");
	glFogCoorddvEXT = cast(typeof(glFogCoorddvEXT))load("glFogCoorddvEXT");
	glFogCoordPointerEXT = cast(typeof(glFogCoordPointerEXT))load("glFogCoordPointerEXT");
	return;
}
void load_GL_EXT_vertex_array(Loader load) {
	if(!GL_EXT_vertex_array) return;
	glArrayElementEXT = cast(typeof(glArrayElementEXT))load("glArrayElementEXT");
	glColorPointerEXT = cast(typeof(glColorPointerEXT))load("glColorPointerEXT");
	glDrawArraysEXT = cast(typeof(glDrawArraysEXT))load("glDrawArraysEXT");
	glEdgeFlagPointerEXT = cast(typeof(glEdgeFlagPointerEXT))load("glEdgeFlagPointerEXT");
	glGetPointervEXT = cast(typeof(glGetPointervEXT))load("glGetPointervEXT");
	glIndexPointerEXT = cast(typeof(glIndexPointerEXT))load("glIndexPointerEXT");
	glNormalPointerEXT = cast(typeof(glNormalPointerEXT))load("glNormalPointerEXT");
	glTexCoordPointerEXT = cast(typeof(glTexCoordPointerEXT))load("glTexCoordPointerEXT");
	glVertexPointerEXT = cast(typeof(glVertexPointerEXT))load("glVertexPointerEXT");
	return;
}
void load_GL_EXT_blend_equation_separate(Loader load) {
	if(!GL_EXT_blend_equation_separate) return;
	glBlendEquationSeparateEXT = cast(typeof(glBlendEquationSeparateEXT))load("glBlendEquationSeparateEXT");
	return;
}
void load_GL_NV_framebuffer_mixed_samples(Loader load) {
	if(!GL_NV_framebuffer_mixed_samples) return;
	glRasterSamplesEXT = cast(typeof(glRasterSamplesEXT))load("glRasterSamplesEXT");
	glCoverageModulationTableNV = cast(typeof(glCoverageModulationTableNV))load("glCoverageModulationTableNV");
	glGetCoverageModulationTableNV = cast(typeof(glGetCoverageModulationTableNV))load("glGetCoverageModulationTableNV");
	glCoverageModulationNV = cast(typeof(glCoverageModulationNV))load("glCoverageModulationNV");
	return;
}
void load_GL_NVX_conditional_render(Loader load) {
	if(!GL_NVX_conditional_render) return;
	glBeginConditionalRenderNVX = cast(typeof(glBeginConditionalRenderNVX))load("glBeginConditionalRenderNVX");
	glEndConditionalRenderNVX = cast(typeof(glEndConditionalRenderNVX))load("glEndConditionalRenderNVX");
	return;
}
void load_GL_ARB_multi_draw_indirect(Loader load) {
	if(!GL_ARB_multi_draw_indirect) return;
	glMultiDrawArraysIndirect = cast(typeof(glMultiDrawArraysIndirect))load("glMultiDrawArraysIndirect");
	glMultiDrawElementsIndirect = cast(typeof(glMultiDrawElementsIndirect))load("glMultiDrawElementsIndirect");
	return;
}
void load_GL_EXT_raster_multisample(Loader load) {
	if(!GL_EXT_raster_multisample) return;
	glRasterSamplesEXT = cast(typeof(glRasterSamplesEXT))load("glRasterSamplesEXT");
	return;
}
void load_GL_NV_copy_image(Loader load) {
	if(!GL_NV_copy_image) return;
	glCopyImageSubDataNV = cast(typeof(glCopyImageSubDataNV))load("glCopyImageSubDataNV");
	return;
}
void load_GL_ARB_transform_feedback2(Loader load) {
	if(!GL_ARB_transform_feedback2) return;
	glBindTransformFeedback = cast(typeof(glBindTransformFeedback))load("glBindTransformFeedback");
	glDeleteTransformFeedbacks = cast(typeof(glDeleteTransformFeedbacks))load("glDeleteTransformFeedbacks");
	glGenTransformFeedbacks = cast(typeof(glGenTransformFeedbacks))load("glGenTransformFeedbacks");
	glIsTransformFeedback = cast(typeof(glIsTransformFeedback))load("glIsTransformFeedback");
	glPauseTransformFeedback = cast(typeof(glPauseTransformFeedback))load("glPauseTransformFeedback");
	glResumeTransformFeedback = cast(typeof(glResumeTransformFeedback))load("glResumeTransformFeedback");
	glDrawTransformFeedback = cast(typeof(glDrawTransformFeedback))load("glDrawTransformFeedback");
	return;
}
void load_GL_ARB_transform_feedback3(Loader load) {
	if(!GL_ARB_transform_feedback3) return;
	glDrawTransformFeedbackStream = cast(typeof(glDrawTransformFeedbackStream))load("glDrawTransformFeedbackStream");
	glBeginQueryIndexed = cast(typeof(glBeginQueryIndexed))load("glBeginQueryIndexed");
	glEndQueryIndexed = cast(typeof(glEndQueryIndexed))load("glEndQueryIndexed");
	glGetQueryIndexediv = cast(typeof(glGetQueryIndexediv))load("glGetQueryIndexediv");
	return;
}
void load_GL_EXT_debug_marker(Loader load) {
	if(!GL_EXT_debug_marker) return;
	glInsertEventMarkerEXT = cast(typeof(glInsertEventMarkerEXT))load("glInsertEventMarkerEXT");
	glPushGroupMarkerEXT = cast(typeof(glPushGroupMarkerEXT))load("glPushGroupMarkerEXT");
	glPopGroupMarkerEXT = cast(typeof(glPopGroupMarkerEXT))load("glPopGroupMarkerEXT");
	return;
}
void load_GL_EXT_pixel_transform(Loader load) {
	if(!GL_EXT_pixel_transform) return;
	glPixelTransformParameteriEXT = cast(typeof(glPixelTransformParameteriEXT))load("glPixelTransformParameteriEXT");
	glPixelTransformParameterfEXT = cast(typeof(glPixelTransformParameterfEXT))load("glPixelTransformParameterfEXT");
	glPixelTransformParameterivEXT = cast(typeof(glPixelTransformParameterivEXT))load("glPixelTransformParameterivEXT");
	glPixelTransformParameterfvEXT = cast(typeof(glPixelTransformParameterfvEXT))load("glPixelTransformParameterfvEXT");
	glGetPixelTransformParameterivEXT = cast(typeof(glGetPixelTransformParameterivEXT))load("glGetPixelTransformParameterivEXT");
	glGetPixelTransformParameterfvEXT = cast(typeof(glGetPixelTransformParameterfvEXT))load("glGetPixelTransformParameterfvEXT");
	return;
}
void load_GL_ATI_fragment_shader(Loader load) {
	if(!GL_ATI_fragment_shader) return;
	glGenFragmentShadersATI = cast(typeof(glGenFragmentShadersATI))load("glGenFragmentShadersATI");
	glBindFragmentShaderATI = cast(typeof(glBindFragmentShaderATI))load("glBindFragmentShaderATI");
	glDeleteFragmentShaderATI = cast(typeof(glDeleteFragmentShaderATI))load("glDeleteFragmentShaderATI");
	glBeginFragmentShaderATI = cast(typeof(glBeginFragmentShaderATI))load("glBeginFragmentShaderATI");
	glEndFragmentShaderATI = cast(typeof(glEndFragmentShaderATI))load("glEndFragmentShaderATI");
	glPassTexCoordATI = cast(typeof(glPassTexCoordATI))load("glPassTexCoordATI");
	glSampleMapATI = cast(typeof(glSampleMapATI))load("glSampleMapATI");
	glColorFragmentOp1ATI = cast(typeof(glColorFragmentOp1ATI))load("glColorFragmentOp1ATI");
	glColorFragmentOp2ATI = cast(typeof(glColorFragmentOp2ATI))load("glColorFragmentOp2ATI");
	glColorFragmentOp3ATI = cast(typeof(glColorFragmentOp3ATI))load("glColorFragmentOp3ATI");
	glAlphaFragmentOp1ATI = cast(typeof(glAlphaFragmentOp1ATI))load("glAlphaFragmentOp1ATI");
	glAlphaFragmentOp2ATI = cast(typeof(glAlphaFragmentOp2ATI))load("glAlphaFragmentOp2ATI");
	glAlphaFragmentOp3ATI = cast(typeof(glAlphaFragmentOp3ATI))load("glAlphaFragmentOp3ATI");
	glSetFragmentShaderConstantATI = cast(typeof(glSetFragmentShaderConstantATI))load("glSetFragmentShaderConstantATI");
	return;
}
void load_GL_ARB_vertex_array_object(Loader load) {
	if(!GL_ARB_vertex_array_object) return;
	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray");
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays");
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays");
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray");
	return;
}
void load_GL_SUN_triangle_list(Loader load) {
	if(!GL_SUN_triangle_list) return;
	glReplacementCodeuiSUN = cast(typeof(glReplacementCodeuiSUN))load("glReplacementCodeuiSUN");
	glReplacementCodeusSUN = cast(typeof(glReplacementCodeusSUN))load("glReplacementCodeusSUN");
	glReplacementCodeubSUN = cast(typeof(glReplacementCodeubSUN))load("glReplacementCodeubSUN");
	glReplacementCodeuivSUN = cast(typeof(glReplacementCodeuivSUN))load("glReplacementCodeuivSUN");
	glReplacementCodeusvSUN = cast(typeof(glReplacementCodeusvSUN))load("glReplacementCodeusvSUN");
	glReplacementCodeubvSUN = cast(typeof(glReplacementCodeubvSUN))load("glReplacementCodeubvSUN");
	glReplacementCodePointerSUN = cast(typeof(glReplacementCodePointerSUN))load("glReplacementCodePointerSUN");
	return;
}
void load_GL_ARB_transform_feedback_instanced(Loader load) {
	if(!GL_ARB_transform_feedback_instanced) return;
	glDrawTransformFeedbackInstanced = cast(typeof(glDrawTransformFeedbackInstanced))load("glDrawTransformFeedbackInstanced");
	glDrawTransformFeedbackStreamInstanced = cast(typeof(glDrawTransformFeedbackStreamInstanced))load("glDrawTransformFeedbackStreamInstanced");
	return;
}
void load_GL_SGIX_async(Loader load) {
	if(!GL_SGIX_async) return;
	glAsyncMarkerSGIX = cast(typeof(glAsyncMarkerSGIX))load("glAsyncMarkerSGIX");
	glFinishAsyncSGIX = cast(typeof(glFinishAsyncSGIX))load("glFinishAsyncSGIX");
	glPollAsyncSGIX = cast(typeof(glPollAsyncSGIX))load("glPollAsyncSGIX");
	glGenAsyncMarkersSGIX = cast(typeof(glGenAsyncMarkersSGIX))load("glGenAsyncMarkersSGIX");
	glDeleteAsyncMarkersSGIX = cast(typeof(glDeleteAsyncMarkersSGIX))load("glDeleteAsyncMarkersSGIX");
	glIsAsyncMarkerSGIX = cast(typeof(glIsAsyncMarkerSGIX))load("glIsAsyncMarkerSGIX");
	return;
}
void load_GL_INTEL_performance_query(Loader load) {
	if(!GL_INTEL_performance_query) return;
	glBeginPerfQueryINTEL = cast(typeof(glBeginPerfQueryINTEL))load("glBeginPerfQueryINTEL");
	glCreatePerfQueryINTEL = cast(typeof(glCreatePerfQueryINTEL))load("glCreatePerfQueryINTEL");
	glDeletePerfQueryINTEL = cast(typeof(glDeletePerfQueryINTEL))load("glDeletePerfQueryINTEL");
	glEndPerfQueryINTEL = cast(typeof(glEndPerfQueryINTEL))load("glEndPerfQueryINTEL");
	glGetFirstPerfQueryIdINTEL = cast(typeof(glGetFirstPerfQueryIdINTEL))load("glGetFirstPerfQueryIdINTEL");
	glGetNextPerfQueryIdINTEL = cast(typeof(glGetNextPerfQueryIdINTEL))load("glGetNextPerfQueryIdINTEL");
	glGetPerfCounterInfoINTEL = cast(typeof(glGetPerfCounterInfoINTEL))load("glGetPerfCounterInfoINTEL");
	glGetPerfQueryDataINTEL = cast(typeof(glGetPerfQueryDataINTEL))load("glGetPerfQueryDataINTEL");
	glGetPerfQueryIdByNameINTEL = cast(typeof(glGetPerfQueryIdByNameINTEL))load("glGetPerfQueryIdByNameINTEL");
	glGetPerfQueryInfoINTEL = cast(typeof(glGetPerfQueryInfoINTEL))load("glGetPerfQueryInfoINTEL");
	return;
}
void load_GL_NV_gpu_shader5(Loader load) {
	if(!GL_NV_gpu_shader5) return;
	glUniform1i64NV = cast(typeof(glUniform1i64NV))load("glUniform1i64NV");
	glUniform2i64NV = cast(typeof(glUniform2i64NV))load("glUniform2i64NV");
	glUniform3i64NV = cast(typeof(glUniform3i64NV))load("glUniform3i64NV");
	glUniform4i64NV = cast(typeof(glUniform4i64NV))load("glUniform4i64NV");
	glUniform1i64vNV = cast(typeof(glUniform1i64vNV))load("glUniform1i64vNV");
	glUniform2i64vNV = cast(typeof(glUniform2i64vNV))load("glUniform2i64vNV");
	glUniform3i64vNV = cast(typeof(glUniform3i64vNV))load("glUniform3i64vNV");
	glUniform4i64vNV = cast(typeof(glUniform4i64vNV))load("glUniform4i64vNV");
	glUniform1ui64NV = cast(typeof(glUniform1ui64NV))load("glUniform1ui64NV");
	glUniform2ui64NV = cast(typeof(glUniform2ui64NV))load("glUniform2ui64NV");
	glUniform3ui64NV = cast(typeof(glUniform3ui64NV))load("glUniform3ui64NV");
	glUniform4ui64NV = cast(typeof(glUniform4ui64NV))load("glUniform4ui64NV");
	glUniform1ui64vNV = cast(typeof(glUniform1ui64vNV))load("glUniform1ui64vNV");
	glUniform2ui64vNV = cast(typeof(glUniform2ui64vNV))load("glUniform2ui64vNV");
	glUniform3ui64vNV = cast(typeof(glUniform3ui64vNV))load("glUniform3ui64vNV");
	glUniform4ui64vNV = cast(typeof(glUniform4ui64vNV))load("glUniform4ui64vNV");
	glGetUniformi64vNV = cast(typeof(glGetUniformi64vNV))load("glGetUniformi64vNV");
	glProgramUniform1i64NV = cast(typeof(glProgramUniform1i64NV))load("glProgramUniform1i64NV");
	glProgramUniform2i64NV = cast(typeof(glProgramUniform2i64NV))load("glProgramUniform2i64NV");
	glProgramUniform3i64NV = cast(typeof(glProgramUniform3i64NV))load("glProgramUniform3i64NV");
	glProgramUniform4i64NV = cast(typeof(glProgramUniform4i64NV))load("glProgramUniform4i64NV");
	glProgramUniform1i64vNV = cast(typeof(glProgramUniform1i64vNV))load("glProgramUniform1i64vNV");
	glProgramUniform2i64vNV = cast(typeof(glProgramUniform2i64vNV))load("glProgramUniform2i64vNV");
	glProgramUniform3i64vNV = cast(typeof(glProgramUniform3i64vNV))load("glProgramUniform3i64vNV");
	glProgramUniform4i64vNV = cast(typeof(glProgramUniform4i64vNV))load("glProgramUniform4i64vNV");
	glProgramUniform1ui64NV = cast(typeof(glProgramUniform1ui64NV))load("glProgramUniform1ui64NV");
	glProgramUniform2ui64NV = cast(typeof(glProgramUniform2ui64NV))load("glProgramUniform2ui64NV");
	glProgramUniform3ui64NV = cast(typeof(glProgramUniform3ui64NV))load("glProgramUniform3ui64NV");
	glProgramUniform4ui64NV = cast(typeof(glProgramUniform4ui64NV))load("glProgramUniform4ui64NV");
	glProgramUniform1ui64vNV = cast(typeof(glProgramUniform1ui64vNV))load("glProgramUniform1ui64vNV");
	glProgramUniform2ui64vNV = cast(typeof(glProgramUniform2ui64vNV))load("glProgramUniform2ui64vNV");
	glProgramUniform3ui64vNV = cast(typeof(glProgramUniform3ui64vNV))load("glProgramUniform3ui64vNV");
	glProgramUniform4ui64vNV = cast(typeof(glProgramUniform4ui64vNV))load("glProgramUniform4ui64vNV");
	return;
}
void load_GL_NV_bindless_multi_draw_indirect_count(Loader load) {
	if(!GL_NV_bindless_multi_draw_indirect_count) return;
	glMultiDrawArraysIndirectBindlessCountNV = cast(typeof(glMultiDrawArraysIndirectBindlessCountNV))load("glMultiDrawArraysIndirectBindlessCountNV");
	glMultiDrawElementsIndirectBindlessCountNV = cast(typeof(glMultiDrawElementsIndirectBindlessCountNV))load("glMultiDrawElementsIndirectBindlessCountNV");
	return;
}
void load_GL_ARB_ES2_compatibility(Loader load) {
	if(!GL_ARB_ES2_compatibility) return;
	glReleaseShaderCompiler = cast(typeof(glReleaseShaderCompiler))load("glReleaseShaderCompiler");
	glShaderBinary = cast(typeof(glShaderBinary))load("glShaderBinary");
	glGetShaderPrecisionFormat = cast(typeof(glGetShaderPrecisionFormat))load("glGetShaderPrecisionFormat");
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef");
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf");
	return;
}
void load_GL_ARB_indirect_parameters(Loader load) {
	if(!GL_ARB_indirect_parameters) return;
	glMultiDrawArraysIndirectCountARB = cast(typeof(glMultiDrawArraysIndirectCountARB))load("glMultiDrawArraysIndirectCountARB");
	glMultiDrawElementsIndirectCountARB = cast(typeof(glMultiDrawElementsIndirectCountARB))load("glMultiDrawElementsIndirectCountARB");
	return;
}
void load_GL_NV_half_float(Loader load) {
	if(!GL_NV_half_float) return;
	glVertex2hNV = cast(typeof(glVertex2hNV))load("glVertex2hNV");
	glVertex2hvNV = cast(typeof(glVertex2hvNV))load("glVertex2hvNV");
	glVertex3hNV = cast(typeof(glVertex3hNV))load("glVertex3hNV");
	glVertex3hvNV = cast(typeof(glVertex3hvNV))load("glVertex3hvNV");
	glVertex4hNV = cast(typeof(glVertex4hNV))load("glVertex4hNV");
	glVertex4hvNV = cast(typeof(glVertex4hvNV))load("glVertex4hvNV");
	glNormal3hNV = cast(typeof(glNormal3hNV))load("glNormal3hNV");
	glNormal3hvNV = cast(typeof(glNormal3hvNV))load("glNormal3hvNV");
	glColor3hNV = cast(typeof(glColor3hNV))load("glColor3hNV");
	glColor3hvNV = cast(typeof(glColor3hvNV))load("glColor3hvNV");
	glColor4hNV = cast(typeof(glColor4hNV))load("glColor4hNV");
	glColor4hvNV = cast(typeof(glColor4hvNV))load("glColor4hvNV");
	glTexCoord1hNV = cast(typeof(glTexCoord1hNV))load("glTexCoord1hNV");
	glTexCoord1hvNV = cast(typeof(glTexCoord1hvNV))load("glTexCoord1hvNV");
	glTexCoord2hNV = cast(typeof(glTexCoord2hNV))load("glTexCoord2hNV");
	glTexCoord2hvNV = cast(typeof(glTexCoord2hvNV))load("glTexCoord2hvNV");
	glTexCoord3hNV = cast(typeof(glTexCoord3hNV))load("glTexCoord3hNV");
	glTexCoord3hvNV = cast(typeof(glTexCoord3hvNV))load("glTexCoord3hvNV");
	glTexCoord4hNV = cast(typeof(glTexCoord4hNV))load("glTexCoord4hNV");
	glTexCoord4hvNV = cast(typeof(glTexCoord4hvNV))load("glTexCoord4hvNV");
	glMultiTexCoord1hNV = cast(typeof(glMultiTexCoord1hNV))load("glMultiTexCoord1hNV");
	glMultiTexCoord1hvNV = cast(typeof(glMultiTexCoord1hvNV))load("glMultiTexCoord1hvNV");
	glMultiTexCoord2hNV = cast(typeof(glMultiTexCoord2hNV))load("glMultiTexCoord2hNV");
	glMultiTexCoord2hvNV = cast(typeof(glMultiTexCoord2hvNV))load("glMultiTexCoord2hvNV");
	glMultiTexCoord3hNV = cast(typeof(glMultiTexCoord3hNV))load("glMultiTexCoord3hNV");
	glMultiTexCoord3hvNV = cast(typeof(glMultiTexCoord3hvNV))load("glMultiTexCoord3hvNV");
	glMultiTexCoord4hNV = cast(typeof(glMultiTexCoord4hNV))load("glMultiTexCoord4hNV");
	glMultiTexCoord4hvNV = cast(typeof(glMultiTexCoord4hvNV))load("glMultiTexCoord4hvNV");
	glFogCoordhNV = cast(typeof(glFogCoordhNV))load("glFogCoordhNV");
	glFogCoordhvNV = cast(typeof(glFogCoordhvNV))load("glFogCoordhvNV");
	glSecondaryColor3hNV = cast(typeof(glSecondaryColor3hNV))load("glSecondaryColor3hNV");
	glSecondaryColor3hvNV = cast(typeof(glSecondaryColor3hvNV))load("glSecondaryColor3hvNV");
	glVertexWeighthNV = cast(typeof(glVertexWeighthNV))load("glVertexWeighthNV");
	glVertexWeighthvNV = cast(typeof(glVertexWeighthvNV))load("glVertexWeighthvNV");
	glVertexAttrib1hNV = cast(typeof(glVertexAttrib1hNV))load("glVertexAttrib1hNV");
	glVertexAttrib1hvNV = cast(typeof(glVertexAttrib1hvNV))load("glVertexAttrib1hvNV");
	glVertexAttrib2hNV = cast(typeof(glVertexAttrib2hNV))load("glVertexAttrib2hNV");
	glVertexAttrib2hvNV = cast(typeof(glVertexAttrib2hvNV))load("glVertexAttrib2hvNV");
	glVertexAttrib3hNV = cast(typeof(glVertexAttrib3hNV))load("glVertexAttrib3hNV");
	glVertexAttrib3hvNV = cast(typeof(glVertexAttrib3hvNV))load("glVertexAttrib3hvNV");
	glVertexAttrib4hNV = cast(typeof(glVertexAttrib4hNV))load("glVertexAttrib4hNV");
	glVertexAttrib4hvNV = cast(typeof(glVertexAttrib4hvNV))load("glVertexAttrib4hvNV");
	glVertexAttribs1hvNV = cast(typeof(glVertexAttribs1hvNV))load("glVertexAttribs1hvNV");
	glVertexAttribs2hvNV = cast(typeof(glVertexAttribs2hvNV))load("glVertexAttribs2hvNV");
	glVertexAttribs3hvNV = cast(typeof(glVertexAttribs3hvNV))load("glVertexAttribs3hvNV");
	glVertexAttribs4hvNV = cast(typeof(glVertexAttribs4hvNV))load("glVertexAttribs4hvNV");
	return;
}
void load_GL_EXT_coordinate_frame(Loader load) {
	if(!GL_EXT_coordinate_frame) return;
	glTangent3bEXT = cast(typeof(glTangent3bEXT))load("glTangent3bEXT");
	glTangent3bvEXT = cast(typeof(glTangent3bvEXT))load("glTangent3bvEXT");
	glTangent3dEXT = cast(typeof(glTangent3dEXT))load("glTangent3dEXT");
	glTangent3dvEXT = cast(typeof(glTangent3dvEXT))load("glTangent3dvEXT");
	glTangent3fEXT = cast(typeof(glTangent3fEXT))load("glTangent3fEXT");
	glTangent3fvEXT = cast(typeof(glTangent3fvEXT))load("glTangent3fvEXT");
	glTangent3iEXT = cast(typeof(glTangent3iEXT))load("glTangent3iEXT");
	glTangent3ivEXT = cast(typeof(glTangent3ivEXT))load("glTangent3ivEXT");
	glTangent3sEXT = cast(typeof(glTangent3sEXT))load("glTangent3sEXT");
	glTangent3svEXT = cast(typeof(glTangent3svEXT))load("glTangent3svEXT");
	glBinormal3bEXT = cast(typeof(glBinormal3bEXT))load("glBinormal3bEXT");
	glBinormal3bvEXT = cast(typeof(glBinormal3bvEXT))load("glBinormal3bvEXT");
	glBinormal3dEXT = cast(typeof(glBinormal3dEXT))load("glBinormal3dEXT");
	glBinormal3dvEXT = cast(typeof(glBinormal3dvEXT))load("glBinormal3dvEXT");
	glBinormal3fEXT = cast(typeof(glBinormal3fEXT))load("glBinormal3fEXT");
	glBinormal3fvEXT = cast(typeof(glBinormal3fvEXT))load("glBinormal3fvEXT");
	glBinormal3iEXT = cast(typeof(glBinormal3iEXT))load("glBinormal3iEXT");
	glBinormal3ivEXT = cast(typeof(glBinormal3ivEXT))load("glBinormal3ivEXT");
	glBinormal3sEXT = cast(typeof(glBinormal3sEXT))load("glBinormal3sEXT");
	glBinormal3svEXT = cast(typeof(glBinormal3svEXT))load("glBinormal3svEXT");
	glTangentPointerEXT = cast(typeof(glTangentPointerEXT))load("glTangentPointerEXT");
	glBinormalPointerEXT = cast(typeof(glBinormalPointerEXT))load("glBinormalPointerEXT");
	return;
}
void load_GL_EXT_polygon_offset_clamp(Loader load) {
	if(!GL_EXT_polygon_offset_clamp) return;
	glPolygonOffsetClampEXT = cast(typeof(glPolygonOffsetClampEXT))load("glPolygonOffsetClampEXT");
	return;
}
void load_GL_EXT_compiled_vertex_array(Loader load) {
	if(!GL_EXT_compiled_vertex_array) return;
	glLockArraysEXT = cast(typeof(glLockArraysEXT))load("glLockArraysEXT");
	glUnlockArraysEXT = cast(typeof(glUnlockArraysEXT))load("glUnlockArraysEXT");
	return;
}
void load_GL_NV_depth_buffer_float(Loader load) {
	if(!GL_NV_depth_buffer_float) return;
	glDepthRangedNV = cast(typeof(glDepthRangedNV))load("glDepthRangedNV");
	glClearDepthdNV = cast(typeof(glClearDepthdNV))load("glClearDepthdNV");
	glDepthBoundsdNV = cast(typeof(glDepthBoundsdNV))load("glDepthBoundsdNV");
	return;
}
void load_GL_NV_occlusion_query(Loader load) {
	if(!GL_NV_occlusion_query) return;
	glGenOcclusionQueriesNV = cast(typeof(glGenOcclusionQueriesNV))load("glGenOcclusionQueriesNV");
	glDeleteOcclusionQueriesNV = cast(typeof(glDeleteOcclusionQueriesNV))load("glDeleteOcclusionQueriesNV");
	glIsOcclusionQueryNV = cast(typeof(glIsOcclusionQueryNV))load("glIsOcclusionQueryNV");
	glBeginOcclusionQueryNV = cast(typeof(glBeginOcclusionQueryNV))load("glBeginOcclusionQueryNV");
	glEndOcclusionQueryNV = cast(typeof(glEndOcclusionQueryNV))load("glEndOcclusionQueryNV");
	glGetOcclusionQueryivNV = cast(typeof(glGetOcclusionQueryivNV))load("glGetOcclusionQueryivNV");
	glGetOcclusionQueryuivNV = cast(typeof(glGetOcclusionQueryuivNV))load("glGetOcclusionQueryuivNV");
	return;
}
void load_GL_APPLE_flush_buffer_range(Loader load) {
	if(!GL_APPLE_flush_buffer_range) return;
	glBufferParameteriAPPLE = cast(typeof(glBufferParameteriAPPLE))load("glBufferParameteriAPPLE");
	glFlushMappedBufferRangeAPPLE = cast(typeof(glFlushMappedBufferRangeAPPLE))load("glFlushMappedBufferRangeAPPLE");
	return;
}
void load_GL_ARB_imaging(Loader load) {
	if(!GL_ARB_imaging) return;
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor");
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation");
	glColorTable = cast(typeof(glColorTable))load("glColorTable");
	glColorTableParameterfv = cast(typeof(glColorTableParameterfv))load("glColorTableParameterfv");
	glColorTableParameteriv = cast(typeof(glColorTableParameteriv))load("glColorTableParameteriv");
	glCopyColorTable = cast(typeof(glCopyColorTable))load("glCopyColorTable");
	glGetColorTable = cast(typeof(glGetColorTable))load("glGetColorTable");
	glGetColorTableParameterfv = cast(typeof(glGetColorTableParameterfv))load("glGetColorTableParameterfv");
	glGetColorTableParameteriv = cast(typeof(glGetColorTableParameteriv))load("glGetColorTableParameteriv");
	glColorSubTable = cast(typeof(glColorSubTable))load("glColorSubTable");
	glCopyColorSubTable = cast(typeof(glCopyColorSubTable))load("glCopyColorSubTable");
	glConvolutionFilter1D = cast(typeof(glConvolutionFilter1D))load("glConvolutionFilter1D");
	glConvolutionFilter2D = cast(typeof(glConvolutionFilter2D))load("glConvolutionFilter2D");
	glConvolutionParameterf = cast(typeof(glConvolutionParameterf))load("glConvolutionParameterf");
	glConvolutionParameterfv = cast(typeof(glConvolutionParameterfv))load("glConvolutionParameterfv");
	glConvolutionParameteri = cast(typeof(glConvolutionParameteri))load("glConvolutionParameteri");
	glConvolutionParameteriv = cast(typeof(glConvolutionParameteriv))load("glConvolutionParameteriv");
	glCopyConvolutionFilter1D = cast(typeof(glCopyConvolutionFilter1D))load("glCopyConvolutionFilter1D");
	glCopyConvolutionFilter2D = cast(typeof(glCopyConvolutionFilter2D))load("glCopyConvolutionFilter2D");
	glGetConvolutionFilter = cast(typeof(glGetConvolutionFilter))load("glGetConvolutionFilter");
	glGetConvolutionParameterfv = cast(typeof(glGetConvolutionParameterfv))load("glGetConvolutionParameterfv");
	glGetConvolutionParameteriv = cast(typeof(glGetConvolutionParameteriv))load("glGetConvolutionParameteriv");
	glGetSeparableFilter = cast(typeof(glGetSeparableFilter))load("glGetSeparableFilter");
	glSeparableFilter2D = cast(typeof(glSeparableFilter2D))load("glSeparableFilter2D");
	glGetHistogram = cast(typeof(glGetHistogram))load("glGetHistogram");
	glGetHistogramParameterfv = cast(typeof(glGetHistogramParameterfv))load("glGetHistogramParameterfv");
	glGetHistogramParameteriv = cast(typeof(glGetHistogramParameteriv))load("glGetHistogramParameteriv");
	glGetMinmax = cast(typeof(glGetMinmax))load("glGetMinmax");
	glGetMinmaxParameterfv = cast(typeof(glGetMinmaxParameterfv))load("glGetMinmaxParameterfv");
	glGetMinmaxParameteriv = cast(typeof(glGetMinmaxParameteriv))load("glGetMinmaxParameteriv");
	glHistogram = cast(typeof(glHistogram))load("glHistogram");
	glMinmax = cast(typeof(glMinmax))load("glMinmax");
	glResetHistogram = cast(typeof(glResetHistogram))load("glResetHistogram");
	glResetMinmax = cast(typeof(glResetMinmax))load("glResetMinmax");
	return;
}
void load_GL_ARB_draw_buffers_blend(Loader load) {
	if(!GL_ARB_draw_buffers_blend) return;
	glBlendEquationiARB = cast(typeof(glBlendEquationiARB))load("glBlendEquationiARB");
	glBlendEquationSeparateiARB = cast(typeof(glBlendEquationSeparateiARB))load("glBlendEquationSeparateiARB");
	glBlendFunciARB = cast(typeof(glBlendFunciARB))load("glBlendFunciARB");
	glBlendFuncSeparateiARB = cast(typeof(glBlendFuncSeparateiARB))load("glBlendFuncSeparateiARB");
	return;
}
void load_GL_ARB_clear_buffer_object(Loader load) {
	if(!GL_ARB_clear_buffer_object) return;
	glClearBufferData = cast(typeof(glClearBufferData))load("glClearBufferData");
	glClearBufferSubData = cast(typeof(glClearBufferSubData))load("glClearBufferSubData");
	return;
}
void load_GL_ARB_multisample(Loader load) {
	if(!GL_ARB_multisample) return;
	glSampleCoverageARB = cast(typeof(glSampleCoverageARB))load("glSampleCoverageARB");
	return;
}
void load_GL_EXT_debug_label(Loader load) {
	if(!GL_EXT_debug_label) return;
	glLabelObjectEXT = cast(typeof(glLabelObjectEXT))load("glLabelObjectEXT");
	glGetObjectLabelEXT = cast(typeof(glGetObjectLabelEXT))load("glGetObjectLabelEXT");
	return;
}
void load_GL_ARB_sample_shading(Loader load) {
	if(!GL_ARB_sample_shading) return;
	glMinSampleShadingARB = cast(typeof(glMinSampleShadingARB))load("glMinSampleShadingARB");
	return;
}
void load_GL_NV_internalformat_sample_query(Loader load) {
	if(!GL_NV_internalformat_sample_query) return;
	glGetInternalformatSampleivNV = cast(typeof(glGetInternalformatSampleivNV))load("glGetInternalformatSampleivNV");
	return;
}
void load_GL_INTEL_map_texture(Loader load) {
	if(!GL_INTEL_map_texture) return;
	glSyncTextureINTEL = cast(typeof(glSyncTextureINTEL))load("glSyncTextureINTEL");
	glUnmapTexture2DINTEL = cast(typeof(glUnmapTexture2DINTEL))load("glUnmapTexture2DINTEL");
	glMapTexture2DINTEL = cast(typeof(glMapTexture2DINTEL))load("glMapTexture2DINTEL");
	return;
}
void load_GL_ARB_compute_shader(Loader load) {
	if(!GL_ARB_compute_shader) return;
	glDispatchCompute = cast(typeof(glDispatchCompute))load("glDispatchCompute");
	glDispatchComputeIndirect = cast(typeof(glDispatchComputeIndirect))load("glDispatchComputeIndirect");
	return;
}
void load_GL_IBM_vertex_array_lists(Loader load) {
	if(!GL_IBM_vertex_array_lists) return;
	glColorPointerListIBM = cast(typeof(glColorPointerListIBM))load("glColorPointerListIBM");
	glSecondaryColorPointerListIBM = cast(typeof(glSecondaryColorPointerListIBM))load("glSecondaryColorPointerListIBM");
	glEdgeFlagPointerListIBM = cast(typeof(glEdgeFlagPointerListIBM))load("glEdgeFlagPointerListIBM");
	glFogCoordPointerListIBM = cast(typeof(glFogCoordPointerListIBM))load("glFogCoordPointerListIBM");
	glIndexPointerListIBM = cast(typeof(glIndexPointerListIBM))load("glIndexPointerListIBM");
	glNormalPointerListIBM = cast(typeof(glNormalPointerListIBM))load("glNormalPointerListIBM");
	glTexCoordPointerListIBM = cast(typeof(glTexCoordPointerListIBM))load("glTexCoordPointerListIBM");
	glVertexPointerListIBM = cast(typeof(glVertexPointerListIBM))load("glVertexPointerListIBM");
	return;
}
void load_GL_ARB_color_buffer_float(Loader load) {
	if(!GL_ARB_color_buffer_float) return;
	glClampColorARB = cast(typeof(glClampColorARB))load("glClampColorARB");
	return;
}
void load_GL_ARB_bindless_texture(Loader load) {
	if(!GL_ARB_bindless_texture) return;
	glGetTextureHandleARB = cast(typeof(glGetTextureHandleARB))load("glGetTextureHandleARB");
	glGetTextureSamplerHandleARB = cast(typeof(glGetTextureSamplerHandleARB))load("glGetTextureSamplerHandleARB");
	glMakeTextureHandleResidentARB = cast(typeof(glMakeTextureHandleResidentARB))load("glMakeTextureHandleResidentARB");
	glMakeTextureHandleNonResidentARB = cast(typeof(glMakeTextureHandleNonResidentARB))load("glMakeTextureHandleNonResidentARB");
	glGetImageHandleARB = cast(typeof(glGetImageHandleARB))load("glGetImageHandleARB");
	glMakeImageHandleResidentARB = cast(typeof(glMakeImageHandleResidentARB))load("glMakeImageHandleResidentARB");
	glMakeImageHandleNonResidentARB = cast(typeof(glMakeImageHandleNonResidentARB))load("glMakeImageHandleNonResidentARB");
	glUniformHandleui64ARB = cast(typeof(glUniformHandleui64ARB))load("glUniformHandleui64ARB");
	glUniformHandleui64vARB = cast(typeof(glUniformHandleui64vARB))load("glUniformHandleui64vARB");
	glProgramUniformHandleui64ARB = cast(typeof(glProgramUniformHandleui64ARB))load("glProgramUniformHandleui64ARB");
	glProgramUniformHandleui64vARB = cast(typeof(glProgramUniformHandleui64vARB))load("glProgramUniformHandleui64vARB");
	glIsTextureHandleResidentARB = cast(typeof(glIsTextureHandleResidentARB))load("glIsTextureHandleResidentARB");
	glIsImageHandleResidentARB = cast(typeof(glIsImageHandleResidentARB))load("glIsImageHandleResidentARB");
	glVertexAttribL1ui64ARB = cast(typeof(glVertexAttribL1ui64ARB))load("glVertexAttribL1ui64ARB");
	glVertexAttribL1ui64vARB = cast(typeof(glVertexAttribL1ui64vARB))load("glVertexAttribL1ui64vARB");
	glGetVertexAttribLui64vARB = cast(typeof(glGetVertexAttribLui64vARB))load("glGetVertexAttribLui64vARB");
	return;
}
void load_GL_ARB_window_pos(Loader load) {
	if(!GL_ARB_window_pos) return;
	glWindowPos2dARB = cast(typeof(glWindowPos2dARB))load("glWindowPos2dARB");
	glWindowPos2dvARB = cast(typeof(glWindowPos2dvARB))load("glWindowPos2dvARB");
	glWindowPos2fARB = cast(typeof(glWindowPos2fARB))load("glWindowPos2fARB");
	glWindowPos2fvARB = cast(typeof(glWindowPos2fvARB))load("glWindowPos2fvARB");
	glWindowPos2iARB = cast(typeof(glWindowPos2iARB))load("glWindowPos2iARB");
	glWindowPos2ivARB = cast(typeof(glWindowPos2ivARB))load("glWindowPos2ivARB");
	glWindowPos2sARB = cast(typeof(glWindowPos2sARB))load("glWindowPos2sARB");
	glWindowPos2svARB = cast(typeof(glWindowPos2svARB))load("glWindowPos2svARB");
	glWindowPos3dARB = cast(typeof(glWindowPos3dARB))load("glWindowPos3dARB");
	glWindowPos3dvARB = cast(typeof(glWindowPos3dvARB))load("glWindowPos3dvARB");
	glWindowPos3fARB = cast(typeof(glWindowPos3fARB))load("glWindowPos3fARB");
	glWindowPos3fvARB = cast(typeof(glWindowPos3fvARB))load("glWindowPos3fvARB");
	glWindowPos3iARB = cast(typeof(glWindowPos3iARB))load("glWindowPos3iARB");
	glWindowPos3ivARB = cast(typeof(glWindowPos3ivARB))load("glWindowPos3ivARB");
	glWindowPos3sARB = cast(typeof(glWindowPos3sARB))load("glWindowPos3sARB");
	glWindowPos3svARB = cast(typeof(glWindowPos3svARB))load("glWindowPos3svARB");
	return;
}
void load_GL_ARB_internalformat_query(Loader load) {
	if(!GL_ARB_internalformat_query) return;
	glGetInternalformativ = cast(typeof(glGetInternalformativ))load("glGetInternalformativ");
	return;
}
void load_GL_EXT_shader_image_load_store(Loader load) {
	if(!GL_EXT_shader_image_load_store) return;
	glBindImageTextureEXT = cast(typeof(glBindImageTextureEXT))load("glBindImageTextureEXT");
	glMemoryBarrierEXT = cast(typeof(glMemoryBarrierEXT))load("glMemoryBarrierEXT");
	return;
}
void load_GL_EXT_copy_texture(Loader load) {
	if(!GL_EXT_copy_texture) return;
	glCopyTexImage1DEXT = cast(typeof(glCopyTexImage1DEXT))load("glCopyTexImage1DEXT");
	glCopyTexImage2DEXT = cast(typeof(glCopyTexImage2DEXT))load("glCopyTexImage2DEXT");
	glCopyTexSubImage1DEXT = cast(typeof(glCopyTexSubImage1DEXT))load("glCopyTexSubImage1DEXT");
	glCopyTexSubImage2DEXT = cast(typeof(glCopyTexSubImage2DEXT))load("glCopyTexSubImage2DEXT");
	glCopyTexSubImage3DEXT = cast(typeof(glCopyTexSubImage3DEXT))load("glCopyTexSubImage3DEXT");
	return;
}
void load_GL_NV_register_combiners2(Loader load) {
	if(!GL_NV_register_combiners2) return;
	glCombinerStageParameterfvNV = cast(typeof(glCombinerStageParameterfvNV))load("glCombinerStageParameterfvNV");
	glGetCombinerStageParameterfvNV = cast(typeof(glGetCombinerStageParameterfvNV))load("glGetCombinerStageParameterfvNV");
	return;
}
void load_GL_NV_draw_texture(Loader load) {
	if(!GL_NV_draw_texture) return;
	glDrawTextureNV = cast(typeof(glDrawTextureNV))load("glDrawTextureNV");
	return;
}
void load_GL_EXT_draw_instanced(Loader load) {
	if(!GL_EXT_draw_instanced) return;
	glDrawArraysInstancedEXT = cast(typeof(glDrawArraysInstancedEXT))load("glDrawArraysInstancedEXT");
	glDrawElementsInstancedEXT = cast(typeof(glDrawElementsInstancedEXT))load("glDrawElementsInstancedEXT");
	return;
}
void load_GL_ARB_viewport_array(Loader load) {
	if(!GL_ARB_viewport_array) return;
	glViewportArrayv = cast(typeof(glViewportArrayv))load("glViewportArrayv");
	glViewportIndexedf = cast(typeof(glViewportIndexedf))load("glViewportIndexedf");
	glViewportIndexedfv = cast(typeof(glViewportIndexedfv))load("glViewportIndexedfv");
	glScissorArrayv = cast(typeof(glScissorArrayv))load("glScissorArrayv");
	glScissorIndexed = cast(typeof(glScissorIndexed))load("glScissorIndexed");
	glScissorIndexedv = cast(typeof(glScissorIndexedv))load("glScissorIndexedv");
	glDepthRangeArrayv = cast(typeof(glDepthRangeArrayv))load("glDepthRangeArrayv");
	glDepthRangeIndexed = cast(typeof(glDepthRangeIndexed))load("glDepthRangeIndexed");
	glGetFloati_v = cast(typeof(glGetFloati_v))load("glGetFloati_v");
	glGetDoublei_v = cast(typeof(glGetDoublei_v))load("glGetDoublei_v");
	return;
}
void load_GL_ARB_separate_shader_objects(Loader load) {
	if(!GL_ARB_separate_shader_objects) return;
	glUseProgramStages = cast(typeof(glUseProgramStages))load("glUseProgramStages");
	glActiveShaderProgram = cast(typeof(glActiveShaderProgram))load("glActiveShaderProgram");
	glCreateShaderProgramv = cast(typeof(glCreateShaderProgramv))load("glCreateShaderProgramv");
	glBindProgramPipeline = cast(typeof(glBindProgramPipeline))load("glBindProgramPipeline");
	glDeleteProgramPipelines = cast(typeof(glDeleteProgramPipelines))load("glDeleteProgramPipelines");
	glGenProgramPipelines = cast(typeof(glGenProgramPipelines))load("glGenProgramPipelines");
	glIsProgramPipeline = cast(typeof(glIsProgramPipeline))load("glIsProgramPipeline");
	glGetProgramPipelineiv = cast(typeof(glGetProgramPipelineiv))load("glGetProgramPipelineiv");
	glProgramUniform1i = cast(typeof(glProgramUniform1i))load("glProgramUniform1i");
	glProgramUniform1iv = cast(typeof(glProgramUniform1iv))load("glProgramUniform1iv");
	glProgramUniform1f = cast(typeof(glProgramUniform1f))load("glProgramUniform1f");
	glProgramUniform1fv = cast(typeof(glProgramUniform1fv))load("glProgramUniform1fv");
	glProgramUniform1d = cast(typeof(glProgramUniform1d))load("glProgramUniform1d");
	glProgramUniform1dv = cast(typeof(glProgramUniform1dv))load("glProgramUniform1dv");
	glProgramUniform1ui = cast(typeof(glProgramUniform1ui))load("glProgramUniform1ui");
	glProgramUniform1uiv = cast(typeof(glProgramUniform1uiv))load("glProgramUniform1uiv");
	glProgramUniform2i = cast(typeof(glProgramUniform2i))load("glProgramUniform2i");
	glProgramUniform2iv = cast(typeof(glProgramUniform2iv))load("glProgramUniform2iv");
	glProgramUniform2f = cast(typeof(glProgramUniform2f))load("glProgramUniform2f");
	glProgramUniform2fv = cast(typeof(glProgramUniform2fv))load("glProgramUniform2fv");
	glProgramUniform2d = cast(typeof(glProgramUniform2d))load("glProgramUniform2d");
	glProgramUniform2dv = cast(typeof(glProgramUniform2dv))load("glProgramUniform2dv");
	glProgramUniform2ui = cast(typeof(glProgramUniform2ui))load("glProgramUniform2ui");
	glProgramUniform2uiv = cast(typeof(glProgramUniform2uiv))load("glProgramUniform2uiv");
	glProgramUniform3i = cast(typeof(glProgramUniform3i))load("glProgramUniform3i");
	glProgramUniform3iv = cast(typeof(glProgramUniform3iv))load("glProgramUniform3iv");
	glProgramUniform3f = cast(typeof(glProgramUniform3f))load("glProgramUniform3f");
	glProgramUniform3fv = cast(typeof(glProgramUniform3fv))load("glProgramUniform3fv");
	glProgramUniform3d = cast(typeof(glProgramUniform3d))load("glProgramUniform3d");
	glProgramUniform3dv = cast(typeof(glProgramUniform3dv))load("glProgramUniform3dv");
	glProgramUniform3ui = cast(typeof(glProgramUniform3ui))load("glProgramUniform3ui");
	glProgramUniform3uiv = cast(typeof(glProgramUniform3uiv))load("glProgramUniform3uiv");
	glProgramUniform4i = cast(typeof(glProgramUniform4i))load("glProgramUniform4i");
	glProgramUniform4iv = cast(typeof(glProgramUniform4iv))load("glProgramUniform4iv");
	glProgramUniform4f = cast(typeof(glProgramUniform4f))load("glProgramUniform4f");
	glProgramUniform4fv = cast(typeof(glProgramUniform4fv))load("glProgramUniform4fv");
	glProgramUniform4d = cast(typeof(glProgramUniform4d))load("glProgramUniform4d");
	glProgramUniform4dv = cast(typeof(glProgramUniform4dv))load("glProgramUniform4dv");
	glProgramUniform4ui = cast(typeof(glProgramUniform4ui))load("glProgramUniform4ui");
	glProgramUniform4uiv = cast(typeof(glProgramUniform4uiv))load("glProgramUniform4uiv");
	glProgramUniformMatrix2fv = cast(typeof(glProgramUniformMatrix2fv))load("glProgramUniformMatrix2fv");
	glProgramUniformMatrix3fv = cast(typeof(glProgramUniformMatrix3fv))load("glProgramUniformMatrix3fv");
	glProgramUniformMatrix4fv = cast(typeof(glProgramUniformMatrix4fv))load("glProgramUniformMatrix4fv");
	glProgramUniformMatrix2dv = cast(typeof(glProgramUniformMatrix2dv))load("glProgramUniformMatrix2dv");
	glProgramUniformMatrix3dv = cast(typeof(glProgramUniformMatrix3dv))load("glProgramUniformMatrix3dv");
	glProgramUniformMatrix4dv = cast(typeof(glProgramUniformMatrix4dv))load("glProgramUniformMatrix4dv");
	glProgramUniformMatrix2x3fv = cast(typeof(glProgramUniformMatrix2x3fv))load("glProgramUniformMatrix2x3fv");
	glProgramUniformMatrix3x2fv = cast(typeof(glProgramUniformMatrix3x2fv))load("glProgramUniformMatrix3x2fv");
	glProgramUniformMatrix2x4fv = cast(typeof(glProgramUniformMatrix2x4fv))load("glProgramUniformMatrix2x4fv");
	glProgramUniformMatrix4x2fv = cast(typeof(glProgramUniformMatrix4x2fv))load("glProgramUniformMatrix4x2fv");
	glProgramUniformMatrix3x4fv = cast(typeof(glProgramUniformMatrix3x4fv))load("glProgramUniformMatrix3x4fv");
	glProgramUniformMatrix4x3fv = cast(typeof(glProgramUniformMatrix4x3fv))load("glProgramUniformMatrix4x3fv");
	glProgramUniformMatrix2x3dv = cast(typeof(glProgramUniformMatrix2x3dv))load("glProgramUniformMatrix2x3dv");
	glProgramUniformMatrix3x2dv = cast(typeof(glProgramUniformMatrix3x2dv))load("glProgramUniformMatrix3x2dv");
	glProgramUniformMatrix2x4dv = cast(typeof(glProgramUniformMatrix2x4dv))load("glProgramUniformMatrix2x4dv");
	glProgramUniformMatrix4x2dv = cast(typeof(glProgramUniformMatrix4x2dv))load("glProgramUniformMatrix4x2dv");
	glProgramUniformMatrix3x4dv = cast(typeof(glProgramUniformMatrix3x4dv))load("glProgramUniformMatrix3x4dv");
	glProgramUniformMatrix4x3dv = cast(typeof(glProgramUniformMatrix4x3dv))load("glProgramUniformMatrix4x3dv");
	glValidateProgramPipeline = cast(typeof(glValidateProgramPipeline))load("glValidateProgramPipeline");
	glGetProgramPipelineInfoLog = cast(typeof(glGetProgramPipelineInfoLog))load("glGetProgramPipelineInfoLog");
	return;
}
void load_GL_EXT_depth_bounds_test(Loader load) {
	if(!GL_EXT_depth_bounds_test) return;
	glDepthBoundsEXT = cast(typeof(glDepthBoundsEXT))load("glDepthBoundsEXT");
	return;
}
void load_GL_HP_image_transform(Loader load) {
	if(!GL_HP_image_transform) return;
	glImageTransformParameteriHP = cast(typeof(glImageTransformParameteriHP))load("glImageTransformParameteriHP");
	glImageTransformParameterfHP = cast(typeof(glImageTransformParameterfHP))load("glImageTransformParameterfHP");
	glImageTransformParameterivHP = cast(typeof(glImageTransformParameterivHP))load("glImageTransformParameterivHP");
	glImageTransformParameterfvHP = cast(typeof(glImageTransformParameterfvHP))load("glImageTransformParameterfvHP");
	glGetImageTransformParameterivHP = cast(typeof(glGetImageTransformParameterivHP))load("glGetImageTransformParameterivHP");
	glGetImageTransformParameterfvHP = cast(typeof(glGetImageTransformParameterfvHP))load("glGetImageTransformParameterfvHP");
	return;
}
void load_GL_NV_video_capture(Loader load) {
	if(!GL_NV_video_capture) return;
	glBeginVideoCaptureNV = cast(typeof(glBeginVideoCaptureNV))load("glBeginVideoCaptureNV");
	glBindVideoCaptureStreamBufferNV = cast(typeof(glBindVideoCaptureStreamBufferNV))load("glBindVideoCaptureStreamBufferNV");
	glBindVideoCaptureStreamTextureNV = cast(typeof(glBindVideoCaptureStreamTextureNV))load("glBindVideoCaptureStreamTextureNV");
	glEndVideoCaptureNV = cast(typeof(glEndVideoCaptureNV))load("glEndVideoCaptureNV");
	glGetVideoCaptureivNV = cast(typeof(glGetVideoCaptureivNV))load("glGetVideoCaptureivNV");
	glGetVideoCaptureStreamivNV = cast(typeof(glGetVideoCaptureStreamivNV))load("glGetVideoCaptureStreamivNV");
	glGetVideoCaptureStreamfvNV = cast(typeof(glGetVideoCaptureStreamfvNV))load("glGetVideoCaptureStreamfvNV");
	glGetVideoCaptureStreamdvNV = cast(typeof(glGetVideoCaptureStreamdvNV))load("glGetVideoCaptureStreamdvNV");
	glVideoCaptureNV = cast(typeof(glVideoCaptureNV))load("glVideoCaptureNV");
	glVideoCaptureStreamParameterivNV = cast(typeof(glVideoCaptureStreamParameterivNV))load("glVideoCaptureStreamParameterivNV");
	glVideoCaptureStreamParameterfvNV = cast(typeof(glVideoCaptureStreamParameterfvNV))load("glVideoCaptureStreamParameterfvNV");
	glVideoCaptureStreamParameterdvNV = cast(typeof(glVideoCaptureStreamParameterdvNV))load("glVideoCaptureStreamParameterdvNV");
	return;
}
void load_GL_ARB_sampler_objects(Loader load) {
	if(!GL_ARB_sampler_objects) return;
	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers");
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers");
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler");
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler");
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri");
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv");
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf");
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv");
	glSamplerParameterIiv = cast(typeof(glSamplerParameterIiv))load("glSamplerParameterIiv");
	glSamplerParameterIuiv = cast(typeof(glSamplerParameterIuiv))load("glSamplerParameterIuiv");
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv");
	glGetSamplerParameterIiv = cast(typeof(glGetSamplerParameterIiv))load("glGetSamplerParameterIiv");
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv");
	glGetSamplerParameterIuiv = cast(typeof(glGetSamplerParameterIuiv))load("glGetSamplerParameterIuiv");
	return;
}
void load_GL_ARB_matrix_palette(Loader load) {
	if(!GL_ARB_matrix_palette) return;
	glCurrentPaletteMatrixARB = cast(typeof(glCurrentPaletteMatrixARB))load("glCurrentPaletteMatrixARB");
	glMatrixIndexubvARB = cast(typeof(glMatrixIndexubvARB))load("glMatrixIndexubvARB");
	glMatrixIndexusvARB = cast(typeof(glMatrixIndexusvARB))load("glMatrixIndexusvARB");
	glMatrixIndexuivARB = cast(typeof(glMatrixIndexuivARB))load("glMatrixIndexuivARB");
	glMatrixIndexPointerARB = cast(typeof(glMatrixIndexPointerARB))load("glMatrixIndexPointerARB");
	return;
}
void load_GL_SGIS_texture_color_mask(Loader load) {
	if(!GL_SGIS_texture_color_mask) return;
	glTextureColorMaskSGIS = cast(typeof(glTextureColorMaskSGIS))load("glTextureColorMaskSGIS");
	return;
}
void load_GL_ARB_texture_compression(Loader load) {
	if(!GL_ARB_texture_compression) return;
	glCompressedTexImage3DARB = cast(typeof(glCompressedTexImage3DARB))load("glCompressedTexImage3DARB");
	glCompressedTexImage2DARB = cast(typeof(glCompressedTexImage2DARB))load("glCompressedTexImage2DARB");
	glCompressedTexImage1DARB = cast(typeof(glCompressedTexImage1DARB))load("glCompressedTexImage1DARB");
	glCompressedTexSubImage3DARB = cast(typeof(glCompressedTexSubImage3DARB))load("glCompressedTexSubImage3DARB");
	glCompressedTexSubImage2DARB = cast(typeof(glCompressedTexSubImage2DARB))load("glCompressedTexSubImage2DARB");
	glCompressedTexSubImage1DARB = cast(typeof(glCompressedTexSubImage1DARB))load("glCompressedTexSubImage1DARB");
	glGetCompressedTexImageARB = cast(typeof(glGetCompressedTexImageARB))load("glGetCompressedTexImageARB");
	return;
}
void load_GL_ARB_shader_subroutine(Loader load) {
	if(!GL_ARB_shader_subroutine) return;
	glGetSubroutineUniformLocation = cast(typeof(glGetSubroutineUniformLocation))load("glGetSubroutineUniformLocation");
	glGetSubroutineIndex = cast(typeof(glGetSubroutineIndex))load("glGetSubroutineIndex");
	glGetActiveSubroutineUniformiv = cast(typeof(glGetActiveSubroutineUniformiv))load("glGetActiveSubroutineUniformiv");
	glGetActiveSubroutineUniformName = cast(typeof(glGetActiveSubroutineUniformName))load("glGetActiveSubroutineUniformName");
	glGetActiveSubroutineName = cast(typeof(glGetActiveSubroutineName))load("glGetActiveSubroutineName");
	glUniformSubroutinesuiv = cast(typeof(glUniformSubroutinesuiv))load("glUniformSubroutinesuiv");
	glGetUniformSubroutineuiv = cast(typeof(glGetUniformSubroutineuiv))load("glGetUniformSubroutineuiv");
	glGetProgramStageiv = cast(typeof(glGetProgramStageiv))load("glGetProgramStageiv");
	return;
}
void load_GL_ARB_texture_storage_multisample(Loader load) {
	if(!GL_ARB_texture_storage_multisample) return;
	glTexStorage2DMultisample = cast(typeof(glTexStorage2DMultisample))load("glTexStorage2DMultisample");
	glTexStorage3DMultisample = cast(typeof(glTexStorage3DMultisample))load("glTexStorage3DMultisample");
	return;
}
void load_GL_EXT_vertex_attrib_64bit(Loader load) {
	if(!GL_EXT_vertex_attrib_64bit) return;
	glVertexAttribL1dEXT = cast(typeof(glVertexAttribL1dEXT))load("glVertexAttribL1dEXT");
	glVertexAttribL2dEXT = cast(typeof(glVertexAttribL2dEXT))load("glVertexAttribL2dEXT");
	glVertexAttribL3dEXT = cast(typeof(glVertexAttribL3dEXT))load("glVertexAttribL3dEXT");
	glVertexAttribL4dEXT = cast(typeof(glVertexAttribL4dEXT))load("glVertexAttribL4dEXT");
	glVertexAttribL1dvEXT = cast(typeof(glVertexAttribL1dvEXT))load("glVertexAttribL1dvEXT");
	glVertexAttribL2dvEXT = cast(typeof(glVertexAttribL2dvEXT))load("glVertexAttribL2dvEXT");
	glVertexAttribL3dvEXT = cast(typeof(glVertexAttribL3dvEXT))load("glVertexAttribL3dvEXT");
	glVertexAttribL4dvEXT = cast(typeof(glVertexAttribL4dvEXT))load("glVertexAttribL4dvEXT");
	glVertexAttribLPointerEXT = cast(typeof(glVertexAttribLPointerEXT))load("glVertexAttribLPointerEXT");
	glGetVertexAttribLdvEXT = cast(typeof(glGetVertexAttribLdvEXT))load("glGetVertexAttribLdvEXT");
	return;
}
void load_GL_OES_query_matrix(Loader load) {
	if(!GL_OES_query_matrix) return;
	glQueryMatrixxOES = cast(typeof(glQueryMatrixxOES))load("glQueryMatrixxOES");
	return;
}
void load_GL_MESA_window_pos(Loader load) {
	if(!GL_MESA_window_pos) return;
	glWindowPos2dMESA = cast(typeof(glWindowPos2dMESA))load("glWindowPos2dMESA");
	glWindowPos2dvMESA = cast(typeof(glWindowPos2dvMESA))load("glWindowPos2dvMESA");
	glWindowPos2fMESA = cast(typeof(glWindowPos2fMESA))load("glWindowPos2fMESA");
	glWindowPos2fvMESA = cast(typeof(glWindowPos2fvMESA))load("glWindowPos2fvMESA");
	glWindowPos2iMESA = cast(typeof(glWindowPos2iMESA))load("glWindowPos2iMESA");
	glWindowPos2ivMESA = cast(typeof(glWindowPos2ivMESA))load("glWindowPos2ivMESA");
	glWindowPos2sMESA = cast(typeof(glWindowPos2sMESA))load("glWindowPos2sMESA");
	glWindowPos2svMESA = cast(typeof(glWindowPos2svMESA))load("glWindowPos2svMESA");
	glWindowPos3dMESA = cast(typeof(glWindowPos3dMESA))load("glWindowPos3dMESA");
	glWindowPos3dvMESA = cast(typeof(glWindowPos3dvMESA))load("glWindowPos3dvMESA");
	glWindowPos3fMESA = cast(typeof(glWindowPos3fMESA))load("glWindowPos3fMESA");
	glWindowPos3fvMESA = cast(typeof(glWindowPos3fvMESA))load("glWindowPos3fvMESA");
	glWindowPos3iMESA = cast(typeof(glWindowPos3iMESA))load("glWindowPos3iMESA");
	glWindowPos3ivMESA = cast(typeof(glWindowPos3ivMESA))load("glWindowPos3ivMESA");
	glWindowPos3sMESA = cast(typeof(glWindowPos3sMESA))load("glWindowPos3sMESA");
	glWindowPos3svMESA = cast(typeof(glWindowPos3svMESA))load("glWindowPos3svMESA");
	glWindowPos4dMESA = cast(typeof(glWindowPos4dMESA))load("glWindowPos4dMESA");
	glWindowPos4dvMESA = cast(typeof(glWindowPos4dvMESA))load("glWindowPos4dvMESA");
	glWindowPos4fMESA = cast(typeof(glWindowPos4fMESA))load("glWindowPos4fMESA");
	glWindowPos4fvMESA = cast(typeof(glWindowPos4fvMESA))load("glWindowPos4fvMESA");
	glWindowPos4iMESA = cast(typeof(glWindowPos4iMESA))load("glWindowPos4iMESA");
	glWindowPos4ivMESA = cast(typeof(glWindowPos4ivMESA))load("glWindowPos4ivMESA");
	glWindowPos4sMESA = cast(typeof(glWindowPos4sMESA))load("glWindowPos4sMESA");
	glWindowPos4svMESA = cast(typeof(glWindowPos4svMESA))load("glWindowPos4svMESA");
	return;
}
void load_GL_ARB_copy_buffer(Loader load) {
	if(!GL_ARB_copy_buffer) return;
	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData");
	return;
}
void load_GL_APPLE_object_purgeable(Loader load) {
	if(!GL_APPLE_object_purgeable) return;
	glObjectPurgeableAPPLE = cast(typeof(glObjectPurgeableAPPLE))load("glObjectPurgeableAPPLE");
	glObjectUnpurgeableAPPLE = cast(typeof(glObjectUnpurgeableAPPLE))load("glObjectUnpurgeableAPPLE");
	glGetObjectParameterivAPPLE = cast(typeof(glGetObjectParameterivAPPLE))load("glGetObjectParameterivAPPLE");
	return;
}
void load_GL_ARB_occlusion_query(Loader load) {
	if(!GL_ARB_occlusion_query) return;
	glGenQueriesARB = cast(typeof(glGenQueriesARB))load("glGenQueriesARB");
	glDeleteQueriesARB = cast(typeof(glDeleteQueriesARB))load("glDeleteQueriesARB");
	glIsQueryARB = cast(typeof(glIsQueryARB))load("glIsQueryARB");
	glBeginQueryARB = cast(typeof(glBeginQueryARB))load("glBeginQueryARB");
	glEndQueryARB = cast(typeof(glEndQueryARB))load("glEndQueryARB");
	glGetQueryivARB = cast(typeof(glGetQueryivARB))load("glGetQueryivARB");
	glGetQueryObjectivARB = cast(typeof(glGetQueryObjectivARB))load("glGetQueryObjectivARB");
	glGetQueryObjectuivARB = cast(typeof(glGetQueryObjectuivARB))load("glGetQueryObjectuivARB");
	return;
}
void load_GL_SGI_color_table(Loader load) {
	if(!GL_SGI_color_table) return;
	glColorTableSGI = cast(typeof(glColorTableSGI))load("glColorTableSGI");
	glColorTableParameterfvSGI = cast(typeof(glColorTableParameterfvSGI))load("glColorTableParameterfvSGI");
	glColorTableParameterivSGI = cast(typeof(glColorTableParameterivSGI))load("glColorTableParameterivSGI");
	glCopyColorTableSGI = cast(typeof(glCopyColorTableSGI))load("glCopyColorTableSGI");
	glGetColorTableSGI = cast(typeof(glGetColorTableSGI))load("glGetColorTableSGI");
	glGetColorTableParameterfvSGI = cast(typeof(glGetColorTableParameterfvSGI))load("glGetColorTableParameterfvSGI");
	glGetColorTableParameterivSGI = cast(typeof(glGetColorTableParameterivSGI))load("glGetColorTableParameterivSGI");
	return;
}
void load_GL_EXT_gpu_shader4(Loader load) {
	if(!GL_EXT_gpu_shader4) return;
	glGetUniformuivEXT = cast(typeof(glGetUniformuivEXT))load("glGetUniformuivEXT");
	glBindFragDataLocationEXT = cast(typeof(glBindFragDataLocationEXT))load("glBindFragDataLocationEXT");
	glGetFragDataLocationEXT = cast(typeof(glGetFragDataLocationEXT))load("glGetFragDataLocationEXT");
	glUniform1uiEXT = cast(typeof(glUniform1uiEXT))load("glUniform1uiEXT");
	glUniform2uiEXT = cast(typeof(glUniform2uiEXT))load("glUniform2uiEXT");
	glUniform3uiEXT = cast(typeof(glUniform3uiEXT))load("glUniform3uiEXT");
	glUniform4uiEXT = cast(typeof(glUniform4uiEXT))load("glUniform4uiEXT");
	glUniform1uivEXT = cast(typeof(glUniform1uivEXT))load("glUniform1uivEXT");
	glUniform2uivEXT = cast(typeof(glUniform2uivEXT))load("glUniform2uivEXT");
	glUniform3uivEXT = cast(typeof(glUniform3uivEXT))load("glUniform3uivEXT");
	glUniform4uivEXT = cast(typeof(glUniform4uivEXT))load("glUniform4uivEXT");
	return;
}
void load_GL_NV_geometry_program4(Loader load) {
	if(!GL_NV_geometry_program4) return;
	glProgramVertexLimitNV = cast(typeof(glProgramVertexLimitNV))load("glProgramVertexLimitNV");
	glFramebufferTextureEXT = cast(typeof(glFramebufferTextureEXT))load("glFramebufferTextureEXT");
	glFramebufferTextureLayerEXT = cast(typeof(glFramebufferTextureLayerEXT))load("glFramebufferTextureLayerEXT");
	glFramebufferTextureFaceEXT = cast(typeof(glFramebufferTextureFaceEXT))load("glFramebufferTextureFaceEXT");
	return;
}
void load_GL_AMD_debug_output(Loader load) {
	if(!GL_AMD_debug_output) return;
	glDebugMessageEnableAMD = cast(typeof(glDebugMessageEnableAMD))load("glDebugMessageEnableAMD");
	glDebugMessageInsertAMD = cast(typeof(glDebugMessageInsertAMD))load("glDebugMessageInsertAMD");
	glDebugMessageCallbackAMD = cast(typeof(glDebugMessageCallbackAMD))load("glDebugMessageCallbackAMD");
	glGetDebugMessageLogAMD = cast(typeof(glGetDebugMessageLogAMD))load("glGetDebugMessageLogAMD");
	return;
}
void load_GL_ARB_multitexture(Loader load) {
	if(!GL_ARB_multitexture) return;
	glActiveTextureARB = cast(typeof(glActiveTextureARB))load("glActiveTextureARB");
	glClientActiveTextureARB = cast(typeof(glClientActiveTextureARB))load("glClientActiveTextureARB");
	glMultiTexCoord1dARB = cast(typeof(glMultiTexCoord1dARB))load("glMultiTexCoord1dARB");
	glMultiTexCoord1dvARB = cast(typeof(glMultiTexCoord1dvARB))load("glMultiTexCoord1dvARB");
	glMultiTexCoord1fARB = cast(typeof(glMultiTexCoord1fARB))load("glMultiTexCoord1fARB");
	glMultiTexCoord1fvARB = cast(typeof(glMultiTexCoord1fvARB))load("glMultiTexCoord1fvARB");
	glMultiTexCoord1iARB = cast(typeof(glMultiTexCoord1iARB))load("glMultiTexCoord1iARB");
	glMultiTexCoord1ivARB = cast(typeof(glMultiTexCoord1ivARB))load("glMultiTexCoord1ivARB");
	glMultiTexCoord1sARB = cast(typeof(glMultiTexCoord1sARB))load("glMultiTexCoord1sARB");
	glMultiTexCoord1svARB = cast(typeof(glMultiTexCoord1svARB))load("glMultiTexCoord1svARB");
	glMultiTexCoord2dARB = cast(typeof(glMultiTexCoord2dARB))load("glMultiTexCoord2dARB");
	glMultiTexCoord2dvARB = cast(typeof(glMultiTexCoord2dvARB))load("glMultiTexCoord2dvARB");
	glMultiTexCoord2fARB = cast(typeof(glMultiTexCoord2fARB))load("glMultiTexCoord2fARB");
	glMultiTexCoord2fvARB = cast(typeof(glMultiTexCoord2fvARB))load("glMultiTexCoord2fvARB");
	glMultiTexCoord2iARB = cast(typeof(glMultiTexCoord2iARB))load("glMultiTexCoord2iARB");
	glMultiTexCoord2ivARB = cast(typeof(glMultiTexCoord2ivARB))load("glMultiTexCoord2ivARB");
	glMultiTexCoord2sARB = cast(typeof(glMultiTexCoord2sARB))load("glMultiTexCoord2sARB");
	glMultiTexCoord2svARB = cast(typeof(glMultiTexCoord2svARB))load("glMultiTexCoord2svARB");
	glMultiTexCoord3dARB = cast(typeof(glMultiTexCoord3dARB))load("glMultiTexCoord3dARB");
	glMultiTexCoord3dvARB = cast(typeof(glMultiTexCoord3dvARB))load("glMultiTexCoord3dvARB");
	glMultiTexCoord3fARB = cast(typeof(glMultiTexCoord3fARB))load("glMultiTexCoord3fARB");
	glMultiTexCoord3fvARB = cast(typeof(glMultiTexCoord3fvARB))load("glMultiTexCoord3fvARB");
	glMultiTexCoord3iARB = cast(typeof(glMultiTexCoord3iARB))load("glMultiTexCoord3iARB");
	glMultiTexCoord3ivARB = cast(typeof(glMultiTexCoord3ivARB))load("glMultiTexCoord3ivARB");
	glMultiTexCoord3sARB = cast(typeof(glMultiTexCoord3sARB))load("glMultiTexCoord3sARB");
	glMultiTexCoord3svARB = cast(typeof(glMultiTexCoord3svARB))load("glMultiTexCoord3svARB");
	glMultiTexCoord4dARB = cast(typeof(glMultiTexCoord4dARB))load("glMultiTexCoord4dARB");
	glMultiTexCoord4dvARB = cast(typeof(glMultiTexCoord4dvARB))load("glMultiTexCoord4dvARB");
	glMultiTexCoord4fARB = cast(typeof(glMultiTexCoord4fARB))load("glMultiTexCoord4fARB");
	glMultiTexCoord4fvARB = cast(typeof(glMultiTexCoord4fvARB))load("glMultiTexCoord4fvARB");
	glMultiTexCoord4iARB = cast(typeof(glMultiTexCoord4iARB))load("glMultiTexCoord4iARB");
	glMultiTexCoord4ivARB = cast(typeof(glMultiTexCoord4ivARB))load("glMultiTexCoord4ivARB");
	glMultiTexCoord4sARB = cast(typeof(glMultiTexCoord4sARB))load("glMultiTexCoord4sARB");
	glMultiTexCoord4svARB = cast(typeof(glMultiTexCoord4svARB))load("glMultiTexCoord4svARB");
	return;
}
void load_GL_SGIX_polynomial_ffd(Loader load) {
	if(!GL_SGIX_polynomial_ffd) return;
	glDeformationMap3dSGIX = cast(typeof(glDeformationMap3dSGIX))load("glDeformationMap3dSGIX");
	glDeformationMap3fSGIX = cast(typeof(glDeformationMap3fSGIX))load("glDeformationMap3fSGIX");
	glDeformSGIX = cast(typeof(glDeformSGIX))load("glDeformSGIX");
	glLoadIdentityDeformationMapSGIX = cast(typeof(glLoadIdentityDeformationMapSGIX))load("glLoadIdentityDeformationMapSGIX");
	return;
}
void load_GL_EXT_provoking_vertex(Loader load) {
	if(!GL_EXT_provoking_vertex) return;
	glProvokingVertexEXT = cast(typeof(glProvokingVertexEXT))load("glProvokingVertexEXT");
	return;
}
void load_GL_ARB_point_parameters(Loader load) {
	if(!GL_ARB_point_parameters) return;
	glPointParameterfARB = cast(typeof(glPointParameterfARB))load("glPointParameterfARB");
	glPointParameterfvARB = cast(typeof(glPointParameterfvARB))load("glPointParameterfvARB");
	return;
}
void load_GL_ARB_shader_image_load_store(Loader load) {
	if(!GL_ARB_shader_image_load_store) return;
	glBindImageTexture = cast(typeof(glBindImageTexture))load("glBindImageTexture");
	glMemoryBarrier = cast(typeof(glMemoryBarrier))load("glMemoryBarrier");
	return;
}
void load_GL_ARB_texture_barrier(Loader load) {
	if(!GL_ARB_texture_barrier) return;
	glTextureBarrier = cast(typeof(glTextureBarrier))load("glTextureBarrier");
	return;
}
void load_GL_NV_bindless_multi_draw_indirect(Loader load) {
	if(!GL_NV_bindless_multi_draw_indirect) return;
	glMultiDrawArraysIndirectBindlessNV = cast(typeof(glMultiDrawArraysIndirectBindlessNV))load("glMultiDrawArraysIndirectBindlessNV");
	glMultiDrawElementsIndirectBindlessNV = cast(typeof(glMultiDrawElementsIndirectBindlessNV))load("glMultiDrawElementsIndirectBindlessNV");
	return;
}
void load_GL_EXT_transform_feedback(Loader load) {
	if(!GL_EXT_transform_feedback) return;
	glBeginTransformFeedbackEXT = cast(typeof(glBeginTransformFeedbackEXT))load("glBeginTransformFeedbackEXT");
	glEndTransformFeedbackEXT = cast(typeof(glEndTransformFeedbackEXT))load("glEndTransformFeedbackEXT");
	glBindBufferRangeEXT = cast(typeof(glBindBufferRangeEXT))load("glBindBufferRangeEXT");
	glBindBufferOffsetEXT = cast(typeof(glBindBufferOffsetEXT))load("glBindBufferOffsetEXT");
	glBindBufferBaseEXT = cast(typeof(glBindBufferBaseEXT))load("glBindBufferBaseEXT");
	glTransformFeedbackVaryingsEXT = cast(typeof(glTransformFeedbackVaryingsEXT))load("glTransformFeedbackVaryingsEXT");
	glGetTransformFeedbackVaryingEXT = cast(typeof(glGetTransformFeedbackVaryingEXT))load("glGetTransformFeedbackVaryingEXT");
	return;
}
void load_GL_NV_gpu_program4(Loader load) {
	if(!GL_NV_gpu_program4) return;
	glProgramLocalParameterI4iNV = cast(typeof(glProgramLocalParameterI4iNV))load("glProgramLocalParameterI4iNV");
	glProgramLocalParameterI4ivNV = cast(typeof(glProgramLocalParameterI4ivNV))load("glProgramLocalParameterI4ivNV");
	glProgramLocalParametersI4ivNV = cast(typeof(glProgramLocalParametersI4ivNV))load("glProgramLocalParametersI4ivNV");
	glProgramLocalParameterI4uiNV = cast(typeof(glProgramLocalParameterI4uiNV))load("glProgramLocalParameterI4uiNV");
	glProgramLocalParameterI4uivNV = cast(typeof(glProgramLocalParameterI4uivNV))load("glProgramLocalParameterI4uivNV");
	glProgramLocalParametersI4uivNV = cast(typeof(glProgramLocalParametersI4uivNV))load("glProgramLocalParametersI4uivNV");
	glProgramEnvParameterI4iNV = cast(typeof(glProgramEnvParameterI4iNV))load("glProgramEnvParameterI4iNV");
	glProgramEnvParameterI4ivNV = cast(typeof(glProgramEnvParameterI4ivNV))load("glProgramEnvParameterI4ivNV");
	glProgramEnvParametersI4ivNV = cast(typeof(glProgramEnvParametersI4ivNV))load("glProgramEnvParametersI4ivNV");
	glProgramEnvParameterI4uiNV = cast(typeof(glProgramEnvParameterI4uiNV))load("glProgramEnvParameterI4uiNV");
	glProgramEnvParameterI4uivNV = cast(typeof(glProgramEnvParameterI4uivNV))load("glProgramEnvParameterI4uivNV");
	glProgramEnvParametersI4uivNV = cast(typeof(glProgramEnvParametersI4uivNV))load("glProgramEnvParametersI4uivNV");
	glGetProgramLocalParameterIivNV = cast(typeof(glGetProgramLocalParameterIivNV))load("glGetProgramLocalParameterIivNV");
	glGetProgramLocalParameterIuivNV = cast(typeof(glGetProgramLocalParameterIuivNV))load("glGetProgramLocalParameterIuivNV");
	glGetProgramEnvParameterIivNV = cast(typeof(glGetProgramEnvParameterIivNV))load("glGetProgramEnvParameterIivNV");
	glGetProgramEnvParameterIuivNV = cast(typeof(glGetProgramEnvParameterIuivNV))load("glGetProgramEnvParameterIuivNV");
	return;
}
void load_GL_NV_gpu_program5(Loader load) {
	if(!GL_NV_gpu_program5) return;
	glProgramSubroutineParametersuivNV = cast(typeof(glProgramSubroutineParametersuivNV))load("glProgramSubroutineParametersuivNV");
	glGetProgramSubroutineParameteruivNV = cast(typeof(glGetProgramSubroutineParameteruivNV))load("glGetProgramSubroutineParameteruivNV");
	return;
}
void load_GL_ARB_geometry_shader4(Loader load) {
	if(!GL_ARB_geometry_shader4) return;
	glProgramParameteriARB = cast(typeof(glProgramParameteriARB))load("glProgramParameteriARB");
	glFramebufferTextureARB = cast(typeof(glFramebufferTextureARB))load("glFramebufferTextureARB");
	glFramebufferTextureLayerARB = cast(typeof(glFramebufferTextureLayerARB))load("glFramebufferTextureLayerARB");
	glFramebufferTextureFaceARB = cast(typeof(glFramebufferTextureFaceARB))load("glFramebufferTextureFaceARB");
	return;
}
void load_GL_NV_conservative_raster(Loader load) {
	if(!GL_NV_conservative_raster) return;
	glSubpixelPrecisionBiasNV = cast(typeof(glSubpixelPrecisionBiasNV))load("glSubpixelPrecisionBiasNV");
	return;
}
void load_GL_SGIX_sprite(Loader load) {
	if(!GL_SGIX_sprite) return;
	glSpriteParameterfSGIX = cast(typeof(glSpriteParameterfSGIX))load("glSpriteParameterfSGIX");
	glSpriteParameterfvSGIX = cast(typeof(glSpriteParameterfvSGIX))load("glSpriteParameterfvSGIX");
	glSpriteParameteriSGIX = cast(typeof(glSpriteParameteriSGIX))load("glSpriteParameteriSGIX");
	glSpriteParameterivSGIX = cast(typeof(glSpriteParameterivSGIX))load("glSpriteParameterivSGIX");
	return;
}
void load_GL_ARB_get_program_binary(Loader load) {
	if(!GL_ARB_get_program_binary) return;
	glGetProgramBinary = cast(typeof(glGetProgramBinary))load("glGetProgramBinary");
	glProgramBinary = cast(typeof(glProgramBinary))load("glProgramBinary");
	glProgramParameteri = cast(typeof(glProgramParameteri))load("glProgramParameteri");
	return;
}
void load_GL_AMD_occlusion_query_event(Loader load) {
	if(!GL_AMD_occlusion_query_event) return;
	glQueryObjectParameteruiAMD = cast(typeof(glQueryObjectParameteruiAMD))load("glQueryObjectParameteruiAMD");
	return;
}
void load_GL_SGIS_multisample(Loader load) {
	if(!GL_SGIS_multisample) return;
	glSampleMaskSGIS = cast(typeof(glSampleMaskSGIS))load("glSampleMaskSGIS");
	glSamplePatternSGIS = cast(typeof(glSamplePatternSGIS))load("glSamplePatternSGIS");
	return;
}
void load_GL_EXT_framebuffer_object(Loader load) {
	if(!GL_EXT_framebuffer_object) return;
	glIsRenderbufferEXT = cast(typeof(glIsRenderbufferEXT))load("glIsRenderbufferEXT");
	glBindRenderbufferEXT = cast(typeof(glBindRenderbufferEXT))load("glBindRenderbufferEXT");
	glDeleteRenderbuffersEXT = cast(typeof(glDeleteRenderbuffersEXT))load("glDeleteRenderbuffersEXT");
	glGenRenderbuffersEXT = cast(typeof(glGenRenderbuffersEXT))load("glGenRenderbuffersEXT");
	glRenderbufferStorageEXT = cast(typeof(glRenderbufferStorageEXT))load("glRenderbufferStorageEXT");
	glGetRenderbufferParameterivEXT = cast(typeof(glGetRenderbufferParameterivEXT))load("glGetRenderbufferParameterivEXT");
	glIsFramebufferEXT = cast(typeof(glIsFramebufferEXT))load("glIsFramebufferEXT");
	glBindFramebufferEXT = cast(typeof(glBindFramebufferEXT))load("glBindFramebufferEXT");
	glDeleteFramebuffersEXT = cast(typeof(glDeleteFramebuffersEXT))load("glDeleteFramebuffersEXT");
	glGenFramebuffersEXT = cast(typeof(glGenFramebuffersEXT))load("glGenFramebuffersEXT");
	glCheckFramebufferStatusEXT = cast(typeof(glCheckFramebufferStatusEXT))load("glCheckFramebufferStatusEXT");
	glFramebufferTexture1DEXT = cast(typeof(glFramebufferTexture1DEXT))load("glFramebufferTexture1DEXT");
	glFramebufferTexture2DEXT = cast(typeof(glFramebufferTexture2DEXT))load("glFramebufferTexture2DEXT");
	glFramebufferTexture3DEXT = cast(typeof(glFramebufferTexture3DEXT))load("glFramebufferTexture3DEXT");
	glFramebufferRenderbufferEXT = cast(typeof(glFramebufferRenderbufferEXT))load("glFramebufferRenderbufferEXT");
	glGetFramebufferAttachmentParameterivEXT = cast(typeof(glGetFramebufferAttachmentParameterivEXT))load("glGetFramebufferAttachmentParameterivEXT");
	glGenerateMipmapEXT = cast(typeof(glGenerateMipmapEXT))load("glGenerateMipmapEXT");
	return;
}
void load_GL_APPLE_vertex_array_range(Loader load) {
	if(!GL_APPLE_vertex_array_range) return;
	glVertexArrayRangeAPPLE = cast(typeof(glVertexArrayRangeAPPLE))load("glVertexArrayRangeAPPLE");
	glFlushVertexArrayRangeAPPLE = cast(typeof(glFlushVertexArrayRangeAPPLE))load("glFlushVertexArrayRangeAPPLE");
	glVertexArrayParameteriAPPLE = cast(typeof(glVertexArrayParameteriAPPLE))load("glVertexArrayParameteriAPPLE");
	return;
}
void load_GL_NV_register_combiners(Loader load) {
	if(!GL_NV_register_combiners) return;
	glCombinerParameterfvNV = cast(typeof(glCombinerParameterfvNV))load("glCombinerParameterfvNV");
	glCombinerParameterfNV = cast(typeof(glCombinerParameterfNV))load("glCombinerParameterfNV");
	glCombinerParameterivNV = cast(typeof(glCombinerParameterivNV))load("glCombinerParameterivNV");
	glCombinerParameteriNV = cast(typeof(glCombinerParameteriNV))load("glCombinerParameteriNV");
	glCombinerInputNV = cast(typeof(glCombinerInputNV))load("glCombinerInputNV");
	glCombinerOutputNV = cast(typeof(glCombinerOutputNV))load("glCombinerOutputNV");
	glFinalCombinerInputNV = cast(typeof(glFinalCombinerInputNV))load("glFinalCombinerInputNV");
	glGetCombinerInputParameterfvNV = cast(typeof(glGetCombinerInputParameterfvNV))load("glGetCombinerInputParameterfvNV");
	glGetCombinerInputParameterivNV = cast(typeof(glGetCombinerInputParameterivNV))load("glGetCombinerInputParameterivNV");
	glGetCombinerOutputParameterfvNV = cast(typeof(glGetCombinerOutputParameterfvNV))load("glGetCombinerOutputParameterfvNV");
	glGetCombinerOutputParameterivNV = cast(typeof(glGetCombinerOutputParameterivNV))load("glGetCombinerOutputParameterivNV");
	glGetFinalCombinerInputParameterfvNV = cast(typeof(glGetFinalCombinerInputParameterfvNV))load("glGetFinalCombinerInputParameterfvNV");
	glGetFinalCombinerInputParameterivNV = cast(typeof(glGetFinalCombinerInputParameterivNV))load("glGetFinalCombinerInputParameterivNV");
	return;
}
void load_GL_ARB_draw_buffers(Loader load) {
	if(!GL_ARB_draw_buffers) return;
	glDrawBuffersARB = cast(typeof(glDrawBuffersARB))load("glDrawBuffersARB");
	return;
}
void load_GL_ARB_debug_output(Loader load) {
	if(!GL_ARB_debug_output) return;
	glDebugMessageControlARB = cast(typeof(glDebugMessageControlARB))load("glDebugMessageControlARB");
	glDebugMessageInsertARB = cast(typeof(glDebugMessageInsertARB))load("glDebugMessageInsertARB");
	glDebugMessageCallbackARB = cast(typeof(glDebugMessageCallbackARB))load("glDebugMessageCallbackARB");
	glGetDebugMessageLogARB = cast(typeof(glGetDebugMessageLogARB))load("glGetDebugMessageLogARB");
	return;
}
void load_GL_EXT_cull_vertex(Loader load) {
	if(!GL_EXT_cull_vertex) return;
	glCullParameterdvEXT = cast(typeof(glCullParameterdvEXT))load("glCullParameterdvEXT");
	glCullParameterfvEXT = cast(typeof(glCullParameterfvEXT))load("glCullParameterfvEXT");
	return;
}
void load_GL_IBM_multimode_draw_arrays(Loader load) {
	if(!GL_IBM_multimode_draw_arrays) return;
	glMultiModeDrawArraysIBM = cast(typeof(glMultiModeDrawArraysIBM))load("glMultiModeDrawArraysIBM");
	glMultiModeDrawElementsIBM = cast(typeof(glMultiModeDrawElementsIBM))load("glMultiModeDrawElementsIBM");
	return;
}
void load_GL_APPLE_vertex_array_object(Loader load) {
	if(!GL_APPLE_vertex_array_object) return;
	glBindVertexArrayAPPLE = cast(typeof(glBindVertexArrayAPPLE))load("glBindVertexArrayAPPLE");
	glDeleteVertexArraysAPPLE = cast(typeof(glDeleteVertexArraysAPPLE))load("glDeleteVertexArraysAPPLE");
	glGenVertexArraysAPPLE = cast(typeof(glGenVertexArraysAPPLE))load("glGenVertexArraysAPPLE");
	glIsVertexArrayAPPLE = cast(typeof(glIsVertexArrayAPPLE))load("glIsVertexArrayAPPLE");
	return;
}
void load_GL_SGIS_detail_texture(Loader load) {
	if(!GL_SGIS_detail_texture) return;
	glDetailTexFuncSGIS = cast(typeof(glDetailTexFuncSGIS))load("glDetailTexFuncSGIS");
	glGetDetailTexFuncSGIS = cast(typeof(glGetDetailTexFuncSGIS))load("glGetDetailTexFuncSGIS");
	return;
}
void load_GL_ARB_draw_instanced(Loader load) {
	if(!GL_ARB_draw_instanced) return;
	glDrawArraysInstancedARB = cast(typeof(glDrawArraysInstancedARB))load("glDrawArraysInstancedARB");
	glDrawElementsInstancedARB = cast(typeof(glDrawElementsInstancedARB))load("glDrawElementsInstancedARB");
	return;
}
void load_GL_ARB_shading_language_include(Loader load) {
	if(!GL_ARB_shading_language_include) return;
	glNamedStringARB = cast(typeof(glNamedStringARB))load("glNamedStringARB");
	glDeleteNamedStringARB = cast(typeof(glDeleteNamedStringARB))load("glDeleteNamedStringARB");
	glCompileShaderIncludeARB = cast(typeof(glCompileShaderIncludeARB))load("glCompileShaderIncludeARB");
	glIsNamedStringARB = cast(typeof(glIsNamedStringARB))load("glIsNamedStringARB");
	glGetNamedStringARB = cast(typeof(glGetNamedStringARB))load("glGetNamedStringARB");
	glGetNamedStringivARB = cast(typeof(glGetNamedStringivARB))load("glGetNamedStringivARB");
	return;
}
void load_GL_INGR_blend_func_separate(Loader load) {
	if(!GL_INGR_blend_func_separate) return;
	glBlendFuncSeparateINGR = cast(typeof(glBlendFuncSeparateINGR))load("glBlendFuncSeparateINGR");
	return;
}
void load_GL_NV_path_rendering(Loader load) {
	if(!GL_NV_path_rendering) return;
	glGenPathsNV = cast(typeof(glGenPathsNV))load("glGenPathsNV");
	glDeletePathsNV = cast(typeof(glDeletePathsNV))load("glDeletePathsNV");
	glIsPathNV = cast(typeof(glIsPathNV))load("glIsPathNV");
	glPathCommandsNV = cast(typeof(glPathCommandsNV))load("glPathCommandsNV");
	glPathCoordsNV = cast(typeof(glPathCoordsNV))load("glPathCoordsNV");
	glPathSubCommandsNV = cast(typeof(glPathSubCommandsNV))load("glPathSubCommandsNV");
	glPathSubCoordsNV = cast(typeof(glPathSubCoordsNV))load("glPathSubCoordsNV");
	glPathStringNV = cast(typeof(glPathStringNV))load("glPathStringNV");
	glPathGlyphsNV = cast(typeof(glPathGlyphsNV))load("glPathGlyphsNV");
	glPathGlyphRangeNV = cast(typeof(glPathGlyphRangeNV))load("glPathGlyphRangeNV");
	glWeightPathsNV = cast(typeof(glWeightPathsNV))load("glWeightPathsNV");
	glCopyPathNV = cast(typeof(glCopyPathNV))load("glCopyPathNV");
	glInterpolatePathsNV = cast(typeof(glInterpolatePathsNV))load("glInterpolatePathsNV");
	glTransformPathNV = cast(typeof(glTransformPathNV))load("glTransformPathNV");
	glPathParameterivNV = cast(typeof(glPathParameterivNV))load("glPathParameterivNV");
	glPathParameteriNV = cast(typeof(glPathParameteriNV))load("glPathParameteriNV");
	glPathParameterfvNV = cast(typeof(glPathParameterfvNV))load("glPathParameterfvNV");
	glPathParameterfNV = cast(typeof(glPathParameterfNV))load("glPathParameterfNV");
	glPathDashArrayNV = cast(typeof(glPathDashArrayNV))load("glPathDashArrayNV");
	glPathStencilFuncNV = cast(typeof(glPathStencilFuncNV))load("glPathStencilFuncNV");
	glPathStencilDepthOffsetNV = cast(typeof(glPathStencilDepthOffsetNV))load("glPathStencilDepthOffsetNV");
	glStencilFillPathNV = cast(typeof(glStencilFillPathNV))load("glStencilFillPathNV");
	glStencilStrokePathNV = cast(typeof(glStencilStrokePathNV))load("glStencilStrokePathNV");
	glStencilFillPathInstancedNV = cast(typeof(glStencilFillPathInstancedNV))load("glStencilFillPathInstancedNV");
	glStencilStrokePathInstancedNV = cast(typeof(glStencilStrokePathInstancedNV))load("glStencilStrokePathInstancedNV");
	glPathCoverDepthFuncNV = cast(typeof(glPathCoverDepthFuncNV))load("glPathCoverDepthFuncNV");
	glCoverFillPathNV = cast(typeof(glCoverFillPathNV))load("glCoverFillPathNV");
	glCoverStrokePathNV = cast(typeof(glCoverStrokePathNV))load("glCoverStrokePathNV");
	glCoverFillPathInstancedNV = cast(typeof(glCoverFillPathInstancedNV))load("glCoverFillPathInstancedNV");
	glCoverStrokePathInstancedNV = cast(typeof(glCoverStrokePathInstancedNV))load("glCoverStrokePathInstancedNV");
	glGetPathParameterivNV = cast(typeof(glGetPathParameterivNV))load("glGetPathParameterivNV");
	glGetPathParameterfvNV = cast(typeof(glGetPathParameterfvNV))load("glGetPathParameterfvNV");
	glGetPathCommandsNV = cast(typeof(glGetPathCommandsNV))load("glGetPathCommandsNV");
	glGetPathCoordsNV = cast(typeof(glGetPathCoordsNV))load("glGetPathCoordsNV");
	glGetPathDashArrayNV = cast(typeof(glGetPathDashArrayNV))load("glGetPathDashArrayNV");
	glGetPathMetricsNV = cast(typeof(glGetPathMetricsNV))load("glGetPathMetricsNV");
	glGetPathMetricRangeNV = cast(typeof(glGetPathMetricRangeNV))load("glGetPathMetricRangeNV");
	glGetPathSpacingNV = cast(typeof(glGetPathSpacingNV))load("glGetPathSpacingNV");
	glIsPointInFillPathNV = cast(typeof(glIsPointInFillPathNV))load("glIsPointInFillPathNV");
	glIsPointInStrokePathNV = cast(typeof(glIsPointInStrokePathNV))load("glIsPointInStrokePathNV");
	glGetPathLengthNV = cast(typeof(glGetPathLengthNV))load("glGetPathLengthNV");
	glPointAlongPathNV = cast(typeof(glPointAlongPathNV))load("glPointAlongPathNV");
	glMatrixLoad3x2fNV = cast(typeof(glMatrixLoad3x2fNV))load("glMatrixLoad3x2fNV");
	glMatrixLoad3x3fNV = cast(typeof(glMatrixLoad3x3fNV))load("glMatrixLoad3x3fNV");
	glMatrixLoadTranspose3x3fNV = cast(typeof(glMatrixLoadTranspose3x3fNV))load("glMatrixLoadTranspose3x3fNV");
	glMatrixMult3x2fNV = cast(typeof(glMatrixMult3x2fNV))load("glMatrixMult3x2fNV");
	glMatrixMult3x3fNV = cast(typeof(glMatrixMult3x3fNV))load("glMatrixMult3x3fNV");
	glMatrixMultTranspose3x3fNV = cast(typeof(glMatrixMultTranspose3x3fNV))load("glMatrixMultTranspose3x3fNV");
	glStencilThenCoverFillPathNV = cast(typeof(glStencilThenCoverFillPathNV))load("glStencilThenCoverFillPathNV");
	glStencilThenCoverStrokePathNV = cast(typeof(glStencilThenCoverStrokePathNV))load("glStencilThenCoverStrokePathNV");
	glStencilThenCoverFillPathInstancedNV = cast(typeof(glStencilThenCoverFillPathInstancedNV))load("glStencilThenCoverFillPathInstancedNV");
	glStencilThenCoverStrokePathInstancedNV = cast(typeof(glStencilThenCoverStrokePathInstancedNV))load("glStencilThenCoverStrokePathInstancedNV");
	glPathGlyphIndexRangeNV = cast(typeof(glPathGlyphIndexRangeNV))load("glPathGlyphIndexRangeNV");
	glPathGlyphIndexArrayNV = cast(typeof(glPathGlyphIndexArrayNV))load("glPathGlyphIndexArrayNV");
	glPathMemoryGlyphIndexArrayNV = cast(typeof(glPathMemoryGlyphIndexArrayNV))load("glPathMemoryGlyphIndexArrayNV");
	glProgramPathFragmentInputGenNV = cast(typeof(glProgramPathFragmentInputGenNV))load("glProgramPathFragmentInputGenNV");
	glGetProgramResourcefvNV = cast(typeof(glGetProgramResourcefvNV))load("glGetProgramResourcefvNV");
	glPathColorGenNV = cast(typeof(glPathColorGenNV))load("glPathColorGenNV");
	glPathTexGenNV = cast(typeof(glPathTexGenNV))load("glPathTexGenNV");
	glPathFogGenNV = cast(typeof(glPathFogGenNV))load("glPathFogGenNV");
	glGetPathColorGenivNV = cast(typeof(glGetPathColorGenivNV))load("glGetPathColorGenivNV");
	glGetPathColorGenfvNV = cast(typeof(glGetPathColorGenfvNV))load("glGetPathColorGenfvNV");
	glGetPathTexGenivNV = cast(typeof(glGetPathTexGenivNV))load("glGetPathTexGenivNV");
	glGetPathTexGenfvNV = cast(typeof(glGetPathTexGenfvNV))load("glGetPathTexGenfvNV");
	return;
}
void load_GL_ATI_vertex_streams(Loader load) {
	if(!GL_ATI_vertex_streams) return;
	glVertexStream1sATI = cast(typeof(glVertexStream1sATI))load("glVertexStream1sATI");
	glVertexStream1svATI = cast(typeof(glVertexStream1svATI))load("glVertexStream1svATI");
	glVertexStream1iATI = cast(typeof(glVertexStream1iATI))load("glVertexStream1iATI");
	glVertexStream1ivATI = cast(typeof(glVertexStream1ivATI))load("glVertexStream1ivATI");
	glVertexStream1fATI = cast(typeof(glVertexStream1fATI))load("glVertexStream1fATI");
	glVertexStream1fvATI = cast(typeof(glVertexStream1fvATI))load("glVertexStream1fvATI");
	glVertexStream1dATI = cast(typeof(glVertexStream1dATI))load("glVertexStream1dATI");
	glVertexStream1dvATI = cast(typeof(glVertexStream1dvATI))load("glVertexStream1dvATI");
	glVertexStream2sATI = cast(typeof(glVertexStream2sATI))load("glVertexStream2sATI");
	glVertexStream2svATI = cast(typeof(glVertexStream2svATI))load("glVertexStream2svATI");
	glVertexStream2iATI = cast(typeof(glVertexStream2iATI))load("glVertexStream2iATI");
	glVertexStream2ivATI = cast(typeof(glVertexStream2ivATI))load("glVertexStream2ivATI");
	glVertexStream2fATI = cast(typeof(glVertexStream2fATI))load("glVertexStream2fATI");
	glVertexStream2fvATI = cast(typeof(glVertexStream2fvATI))load("glVertexStream2fvATI");
	glVertexStream2dATI = cast(typeof(glVertexStream2dATI))load("glVertexStream2dATI");
	glVertexStream2dvATI = cast(typeof(glVertexStream2dvATI))load("glVertexStream2dvATI");
	glVertexStream3sATI = cast(typeof(glVertexStream3sATI))load("glVertexStream3sATI");
	glVertexStream3svATI = cast(typeof(glVertexStream3svATI))load("glVertexStream3svATI");
	glVertexStream3iATI = cast(typeof(glVertexStream3iATI))load("glVertexStream3iATI");
	glVertexStream3ivATI = cast(typeof(glVertexStream3ivATI))load("glVertexStream3ivATI");
	glVertexStream3fATI = cast(typeof(glVertexStream3fATI))load("glVertexStream3fATI");
	glVertexStream3fvATI = cast(typeof(glVertexStream3fvATI))load("glVertexStream3fvATI");
	glVertexStream3dATI = cast(typeof(glVertexStream3dATI))load("glVertexStream3dATI");
	glVertexStream3dvATI = cast(typeof(glVertexStream3dvATI))load("glVertexStream3dvATI");
	glVertexStream4sATI = cast(typeof(glVertexStream4sATI))load("glVertexStream4sATI");
	glVertexStream4svATI = cast(typeof(glVertexStream4svATI))load("glVertexStream4svATI");
	glVertexStream4iATI = cast(typeof(glVertexStream4iATI))load("glVertexStream4iATI");
	glVertexStream4ivATI = cast(typeof(glVertexStream4ivATI))load("glVertexStream4ivATI");
	glVertexStream4fATI = cast(typeof(glVertexStream4fATI))load("glVertexStream4fATI");
	glVertexStream4fvATI = cast(typeof(glVertexStream4fvATI))load("glVertexStream4fvATI");
	glVertexStream4dATI = cast(typeof(glVertexStream4dATI))load("glVertexStream4dATI");
	glVertexStream4dvATI = cast(typeof(glVertexStream4dvATI))load("glVertexStream4dvATI");
	glNormalStream3bATI = cast(typeof(glNormalStream3bATI))load("glNormalStream3bATI");
	glNormalStream3bvATI = cast(typeof(glNormalStream3bvATI))load("glNormalStream3bvATI");
	glNormalStream3sATI = cast(typeof(glNormalStream3sATI))load("glNormalStream3sATI");
	glNormalStream3svATI = cast(typeof(glNormalStream3svATI))load("glNormalStream3svATI");
	glNormalStream3iATI = cast(typeof(glNormalStream3iATI))load("glNormalStream3iATI");
	glNormalStream3ivATI = cast(typeof(glNormalStream3ivATI))load("glNormalStream3ivATI");
	glNormalStream3fATI = cast(typeof(glNormalStream3fATI))load("glNormalStream3fATI");
	glNormalStream3fvATI = cast(typeof(glNormalStream3fvATI))load("glNormalStream3fvATI");
	glNormalStream3dATI = cast(typeof(glNormalStream3dATI))load("glNormalStream3dATI");
	glNormalStream3dvATI = cast(typeof(glNormalStream3dvATI))load("glNormalStream3dvATI");
	glClientActiveVertexStreamATI = cast(typeof(glClientActiveVertexStreamATI))load("glClientActiveVertexStreamATI");
	glVertexBlendEnviATI = cast(typeof(glVertexBlendEnviATI))load("glVertexBlendEnviATI");
	glVertexBlendEnvfATI = cast(typeof(glVertexBlendEnvfATI))load("glVertexBlendEnvfATI");
	return;
}
void load_GL_NV_vdpau_interop(Loader load) {
	if(!GL_NV_vdpau_interop) return;
	glVDPAUInitNV = cast(typeof(glVDPAUInitNV))load("glVDPAUInitNV");
	glVDPAUFiniNV = cast(typeof(glVDPAUFiniNV))load("glVDPAUFiniNV");
	glVDPAURegisterVideoSurfaceNV = cast(typeof(glVDPAURegisterVideoSurfaceNV))load("glVDPAURegisterVideoSurfaceNV");
	glVDPAURegisterOutputSurfaceNV = cast(typeof(glVDPAURegisterOutputSurfaceNV))load("glVDPAURegisterOutputSurfaceNV");
	glVDPAUIsSurfaceNV = cast(typeof(glVDPAUIsSurfaceNV))load("glVDPAUIsSurfaceNV");
	glVDPAUUnregisterSurfaceNV = cast(typeof(glVDPAUUnregisterSurfaceNV))load("glVDPAUUnregisterSurfaceNV");
	glVDPAUGetSurfaceivNV = cast(typeof(glVDPAUGetSurfaceivNV))load("glVDPAUGetSurfaceivNV");
	glVDPAUSurfaceAccessNV = cast(typeof(glVDPAUSurfaceAccessNV))load("glVDPAUSurfaceAccessNV");
	glVDPAUMapSurfacesNV = cast(typeof(glVDPAUMapSurfacesNV))load("glVDPAUMapSurfacesNV");
	glVDPAUUnmapSurfacesNV = cast(typeof(glVDPAUUnmapSurfacesNV))load("glVDPAUUnmapSurfacesNV");
	return;
}
void load_GL_ARB_internalformat_query2(Loader load) {
	if(!GL_ARB_internalformat_query2) return;
	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v");
	return;
}
void load_GL_SUN_vertex(Loader load) {
	if(!GL_SUN_vertex) return;
	glColor4ubVertex2fSUN = cast(typeof(glColor4ubVertex2fSUN))load("glColor4ubVertex2fSUN");
	glColor4ubVertex2fvSUN = cast(typeof(glColor4ubVertex2fvSUN))load("glColor4ubVertex2fvSUN");
	glColor4ubVertex3fSUN = cast(typeof(glColor4ubVertex3fSUN))load("glColor4ubVertex3fSUN");
	glColor4ubVertex3fvSUN = cast(typeof(glColor4ubVertex3fvSUN))load("glColor4ubVertex3fvSUN");
	glColor3fVertex3fSUN = cast(typeof(glColor3fVertex3fSUN))load("glColor3fVertex3fSUN");
	glColor3fVertex3fvSUN = cast(typeof(glColor3fVertex3fvSUN))load("glColor3fVertex3fvSUN");
	glNormal3fVertex3fSUN = cast(typeof(glNormal3fVertex3fSUN))load("glNormal3fVertex3fSUN");
	glNormal3fVertex3fvSUN = cast(typeof(glNormal3fVertex3fvSUN))load("glNormal3fVertex3fvSUN");
	glColor4fNormal3fVertex3fSUN = cast(typeof(glColor4fNormal3fVertex3fSUN))load("glColor4fNormal3fVertex3fSUN");
	glColor4fNormal3fVertex3fvSUN = cast(typeof(glColor4fNormal3fVertex3fvSUN))load("glColor4fNormal3fVertex3fvSUN");
	glTexCoord2fVertex3fSUN = cast(typeof(glTexCoord2fVertex3fSUN))load("glTexCoord2fVertex3fSUN");
	glTexCoord2fVertex3fvSUN = cast(typeof(glTexCoord2fVertex3fvSUN))load("glTexCoord2fVertex3fvSUN");
	glTexCoord4fVertex4fSUN = cast(typeof(glTexCoord4fVertex4fSUN))load("glTexCoord4fVertex4fSUN");
	glTexCoord4fVertex4fvSUN = cast(typeof(glTexCoord4fVertex4fvSUN))load("glTexCoord4fVertex4fvSUN");
	glTexCoord2fColor4ubVertex3fSUN = cast(typeof(glTexCoord2fColor4ubVertex3fSUN))load("glTexCoord2fColor4ubVertex3fSUN");
	glTexCoord2fColor4ubVertex3fvSUN = cast(typeof(glTexCoord2fColor4ubVertex3fvSUN))load("glTexCoord2fColor4ubVertex3fvSUN");
	glTexCoord2fColor3fVertex3fSUN = cast(typeof(glTexCoord2fColor3fVertex3fSUN))load("glTexCoord2fColor3fVertex3fSUN");
	glTexCoord2fColor3fVertex3fvSUN = cast(typeof(glTexCoord2fColor3fVertex3fvSUN))load("glTexCoord2fColor3fVertex3fvSUN");
	glTexCoord2fNormal3fVertex3fSUN = cast(typeof(glTexCoord2fNormal3fVertex3fSUN))load("glTexCoord2fNormal3fVertex3fSUN");
	glTexCoord2fNormal3fVertex3fvSUN = cast(typeof(glTexCoord2fNormal3fVertex3fvSUN))load("glTexCoord2fNormal3fVertex3fvSUN");
	glTexCoord2fColor4fNormal3fVertex3fSUN = cast(typeof(glTexCoord2fColor4fNormal3fVertex3fSUN))load("glTexCoord2fColor4fNormal3fVertex3fSUN");
	glTexCoord2fColor4fNormal3fVertex3fvSUN = cast(typeof(glTexCoord2fColor4fNormal3fVertex3fvSUN))load("glTexCoord2fColor4fNormal3fVertex3fvSUN");
	glTexCoord4fColor4fNormal3fVertex4fSUN = cast(typeof(glTexCoord4fColor4fNormal3fVertex4fSUN))load("glTexCoord4fColor4fNormal3fVertex4fSUN");
	glTexCoord4fColor4fNormal3fVertex4fvSUN = cast(typeof(glTexCoord4fColor4fNormal3fVertex4fvSUN))load("glTexCoord4fColor4fNormal3fVertex4fvSUN");
	glReplacementCodeuiVertex3fSUN = cast(typeof(glReplacementCodeuiVertex3fSUN))load("glReplacementCodeuiVertex3fSUN");
	glReplacementCodeuiVertex3fvSUN = cast(typeof(glReplacementCodeuiVertex3fvSUN))load("glReplacementCodeuiVertex3fvSUN");
	glReplacementCodeuiColor4ubVertex3fSUN = cast(typeof(glReplacementCodeuiColor4ubVertex3fSUN))load("glReplacementCodeuiColor4ubVertex3fSUN");
	glReplacementCodeuiColor4ubVertex3fvSUN = cast(typeof(glReplacementCodeuiColor4ubVertex3fvSUN))load("glReplacementCodeuiColor4ubVertex3fvSUN");
	glReplacementCodeuiColor3fVertex3fSUN = cast(typeof(glReplacementCodeuiColor3fVertex3fSUN))load("glReplacementCodeuiColor3fVertex3fSUN");
	glReplacementCodeuiColor3fVertex3fvSUN = cast(typeof(glReplacementCodeuiColor3fVertex3fvSUN))load("glReplacementCodeuiColor3fVertex3fvSUN");
	glReplacementCodeuiNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiNormal3fVertex3fSUN))load("glReplacementCodeuiNormal3fVertex3fSUN");
	glReplacementCodeuiNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiNormal3fVertex3fvSUN))load("glReplacementCodeuiNormal3fVertex3fvSUN");
	glReplacementCodeuiColor4fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiColor4fNormal3fVertex3fSUN))load("glReplacementCodeuiColor4fNormal3fVertex3fSUN");
	glReplacementCodeuiColor4fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiColor4fNormal3fVertex3fvSUN))load("glReplacementCodeuiColor4fNormal3fVertex3fvSUN");
	glReplacementCodeuiTexCoord2fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fVertex3fSUN))load("glReplacementCodeuiTexCoord2fVertex3fSUN");
	glReplacementCodeuiTexCoord2fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fVertex3fvSUN");
	glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN))load("glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN");
	glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN");
	glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN))load("glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN");
	glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN");
	return;
}
void load_GL_SGIX_igloo_interface(Loader load) {
	if(!GL_SGIX_igloo_interface) return;
	glIglooInterfaceSGIX = cast(typeof(glIglooInterfaceSGIX))load("glIglooInterfaceSGIX");
	return;
}
void load_GL_ARB_draw_indirect(Loader load) {
	if(!GL_ARB_draw_indirect) return;
	glDrawArraysIndirect = cast(typeof(glDrawArraysIndirect))load("glDrawArraysIndirect");
	glDrawElementsIndirect = cast(typeof(glDrawElementsIndirect))load("glDrawElementsIndirect");
	return;
}
void load_GL_NV_vertex_program4(Loader load) {
	if(!GL_NV_vertex_program4) return;
	glVertexAttribI1iEXT = cast(typeof(glVertexAttribI1iEXT))load("glVertexAttribI1iEXT");
	glVertexAttribI2iEXT = cast(typeof(glVertexAttribI2iEXT))load("glVertexAttribI2iEXT");
	glVertexAttribI3iEXT = cast(typeof(glVertexAttribI3iEXT))load("glVertexAttribI3iEXT");
	glVertexAttribI4iEXT = cast(typeof(glVertexAttribI4iEXT))load("glVertexAttribI4iEXT");
	glVertexAttribI1uiEXT = cast(typeof(glVertexAttribI1uiEXT))load("glVertexAttribI1uiEXT");
	glVertexAttribI2uiEXT = cast(typeof(glVertexAttribI2uiEXT))load("glVertexAttribI2uiEXT");
	glVertexAttribI3uiEXT = cast(typeof(glVertexAttribI3uiEXT))load("glVertexAttribI3uiEXT");
	glVertexAttribI4uiEXT = cast(typeof(glVertexAttribI4uiEXT))load("glVertexAttribI4uiEXT");
	glVertexAttribI1ivEXT = cast(typeof(glVertexAttribI1ivEXT))load("glVertexAttribI1ivEXT");
	glVertexAttribI2ivEXT = cast(typeof(glVertexAttribI2ivEXT))load("glVertexAttribI2ivEXT");
	glVertexAttribI3ivEXT = cast(typeof(glVertexAttribI3ivEXT))load("glVertexAttribI3ivEXT");
	glVertexAttribI4ivEXT = cast(typeof(glVertexAttribI4ivEXT))load("glVertexAttribI4ivEXT");
	glVertexAttribI1uivEXT = cast(typeof(glVertexAttribI1uivEXT))load("glVertexAttribI1uivEXT");
	glVertexAttribI2uivEXT = cast(typeof(glVertexAttribI2uivEXT))load("glVertexAttribI2uivEXT");
	glVertexAttribI3uivEXT = cast(typeof(glVertexAttribI3uivEXT))load("glVertexAttribI3uivEXT");
	glVertexAttribI4uivEXT = cast(typeof(glVertexAttribI4uivEXT))load("glVertexAttribI4uivEXT");
	glVertexAttribI4bvEXT = cast(typeof(glVertexAttribI4bvEXT))load("glVertexAttribI4bvEXT");
	glVertexAttribI4svEXT = cast(typeof(glVertexAttribI4svEXT))load("glVertexAttribI4svEXT");
	glVertexAttribI4ubvEXT = cast(typeof(glVertexAttribI4ubvEXT))load("glVertexAttribI4ubvEXT");
	glVertexAttribI4usvEXT = cast(typeof(glVertexAttribI4usvEXT))load("glVertexAttribI4usvEXT");
	glVertexAttribIPointerEXT = cast(typeof(glVertexAttribIPointerEXT))load("glVertexAttribIPointerEXT");
	glGetVertexAttribIivEXT = cast(typeof(glGetVertexAttribIivEXT))load("glGetVertexAttribIivEXT");
	glGetVertexAttribIuivEXT = cast(typeof(glGetVertexAttribIuivEXT))load("glGetVertexAttribIuivEXT");
	return;
}
void load_GL_SGIS_fog_function(Loader load) {
	if(!GL_SGIS_fog_function) return;
	glFogFuncSGIS = cast(typeof(glFogFuncSGIS))load("glFogFuncSGIS");
	glGetFogFuncSGIS = cast(typeof(glGetFogFuncSGIS))load("glGetFogFuncSGIS");
	return;
}
void load_GL_EXT_x11_sync_object(Loader load) {
	if(!GL_EXT_x11_sync_object) return;
	glImportSyncEXT = cast(typeof(glImportSyncEXT))load("glImportSyncEXT");
	return;
}
void load_GL_ARB_sync(Loader load) {
	if(!GL_ARB_sync) return;
	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync");
	glIsSync = cast(typeof(glIsSync))load("glIsSync");
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync");
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync");
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync");
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v");
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv");
	return;
}
void load_GL_NV_sample_locations(Loader load) {
	if(!GL_NV_sample_locations) return;
	glFramebufferSampleLocationsfvNV = cast(typeof(glFramebufferSampleLocationsfvNV))load("glFramebufferSampleLocationsfvNV");
	glNamedFramebufferSampleLocationsfvNV = cast(typeof(glNamedFramebufferSampleLocationsfvNV))load("glNamedFramebufferSampleLocationsfvNV");
	glResolveDepthValuesNV = cast(typeof(glResolveDepthValuesNV))load("glResolveDepthValuesNV");
	return;
}
void load_GL_ARB_compute_variable_group_size(Loader load) {
	if(!GL_ARB_compute_variable_group_size) return;
	glDispatchComputeGroupSizeARB = cast(typeof(glDispatchComputeGroupSizeARB))load("glDispatchComputeGroupSizeARB");
	return;
}
void load_GL_OES_fixed_point(Loader load) {
	if(!GL_OES_fixed_point) return;
	glAlphaFuncxOES = cast(typeof(glAlphaFuncxOES))load("glAlphaFuncxOES");
	glClearColorxOES = cast(typeof(glClearColorxOES))load("glClearColorxOES");
	glClearDepthxOES = cast(typeof(glClearDepthxOES))load("glClearDepthxOES");
	glClipPlanexOES = cast(typeof(glClipPlanexOES))load("glClipPlanexOES");
	glColor4xOES = cast(typeof(glColor4xOES))load("glColor4xOES");
	glDepthRangexOES = cast(typeof(glDepthRangexOES))load("glDepthRangexOES");
	glFogxOES = cast(typeof(glFogxOES))load("glFogxOES");
	glFogxvOES = cast(typeof(glFogxvOES))load("glFogxvOES");
	glFrustumxOES = cast(typeof(glFrustumxOES))load("glFrustumxOES");
	glGetClipPlanexOES = cast(typeof(glGetClipPlanexOES))load("glGetClipPlanexOES");
	glGetFixedvOES = cast(typeof(glGetFixedvOES))load("glGetFixedvOES");
	glGetTexEnvxvOES = cast(typeof(glGetTexEnvxvOES))load("glGetTexEnvxvOES");
	glGetTexParameterxvOES = cast(typeof(glGetTexParameterxvOES))load("glGetTexParameterxvOES");
	glLightModelxOES = cast(typeof(glLightModelxOES))load("glLightModelxOES");
	glLightModelxvOES = cast(typeof(glLightModelxvOES))load("glLightModelxvOES");
	glLightxOES = cast(typeof(glLightxOES))load("glLightxOES");
	glLightxvOES = cast(typeof(glLightxvOES))load("glLightxvOES");
	glLineWidthxOES = cast(typeof(glLineWidthxOES))load("glLineWidthxOES");
	glLoadMatrixxOES = cast(typeof(glLoadMatrixxOES))load("glLoadMatrixxOES");
	glMaterialxOES = cast(typeof(glMaterialxOES))load("glMaterialxOES");
	glMaterialxvOES = cast(typeof(glMaterialxvOES))load("glMaterialxvOES");
	glMultMatrixxOES = cast(typeof(glMultMatrixxOES))load("glMultMatrixxOES");
	glMultiTexCoord4xOES = cast(typeof(glMultiTexCoord4xOES))load("glMultiTexCoord4xOES");
	glNormal3xOES = cast(typeof(glNormal3xOES))load("glNormal3xOES");
	glOrthoxOES = cast(typeof(glOrthoxOES))load("glOrthoxOES");
	glPointParameterxvOES = cast(typeof(glPointParameterxvOES))load("glPointParameterxvOES");
	glPointSizexOES = cast(typeof(glPointSizexOES))load("glPointSizexOES");
	glPolygonOffsetxOES = cast(typeof(glPolygonOffsetxOES))load("glPolygonOffsetxOES");
	glRotatexOES = cast(typeof(glRotatexOES))load("glRotatexOES");
	glScalexOES = cast(typeof(glScalexOES))load("glScalexOES");
	glTexEnvxOES = cast(typeof(glTexEnvxOES))load("glTexEnvxOES");
	glTexEnvxvOES = cast(typeof(glTexEnvxvOES))load("glTexEnvxvOES");
	glTexParameterxOES = cast(typeof(glTexParameterxOES))load("glTexParameterxOES");
	glTexParameterxvOES = cast(typeof(glTexParameterxvOES))load("glTexParameterxvOES");
	glTranslatexOES = cast(typeof(glTranslatexOES))load("glTranslatexOES");
	glGetLightxvOES = cast(typeof(glGetLightxvOES))load("glGetLightxvOES");
	glGetMaterialxvOES = cast(typeof(glGetMaterialxvOES))load("glGetMaterialxvOES");
	glPointParameterxOES = cast(typeof(glPointParameterxOES))load("glPointParameterxOES");
	glSampleCoveragexOES = cast(typeof(glSampleCoveragexOES))load("glSampleCoveragexOES");
	glAccumxOES = cast(typeof(glAccumxOES))load("glAccumxOES");
	glBitmapxOES = cast(typeof(glBitmapxOES))load("glBitmapxOES");
	glBlendColorxOES = cast(typeof(glBlendColorxOES))load("glBlendColorxOES");
	glClearAccumxOES = cast(typeof(glClearAccumxOES))load("glClearAccumxOES");
	glColor3xOES = cast(typeof(glColor3xOES))load("glColor3xOES");
	glColor3xvOES = cast(typeof(glColor3xvOES))load("glColor3xvOES");
	glColor4xvOES = cast(typeof(glColor4xvOES))load("glColor4xvOES");
	glConvolutionParameterxOES = cast(typeof(glConvolutionParameterxOES))load("glConvolutionParameterxOES");
	glConvolutionParameterxvOES = cast(typeof(glConvolutionParameterxvOES))load("glConvolutionParameterxvOES");
	glEvalCoord1xOES = cast(typeof(glEvalCoord1xOES))load("glEvalCoord1xOES");
	glEvalCoord1xvOES = cast(typeof(glEvalCoord1xvOES))load("glEvalCoord1xvOES");
	glEvalCoord2xOES = cast(typeof(glEvalCoord2xOES))load("glEvalCoord2xOES");
	glEvalCoord2xvOES = cast(typeof(glEvalCoord2xvOES))load("glEvalCoord2xvOES");
	glFeedbackBufferxOES = cast(typeof(glFeedbackBufferxOES))load("glFeedbackBufferxOES");
	glGetConvolutionParameterxvOES = cast(typeof(glGetConvolutionParameterxvOES))load("glGetConvolutionParameterxvOES");
	glGetHistogramParameterxvOES = cast(typeof(glGetHistogramParameterxvOES))load("glGetHistogramParameterxvOES");
	glGetLightxOES = cast(typeof(glGetLightxOES))load("glGetLightxOES");
	glGetMapxvOES = cast(typeof(glGetMapxvOES))load("glGetMapxvOES");
	glGetMaterialxOES = cast(typeof(glGetMaterialxOES))load("glGetMaterialxOES");
	glGetPixelMapxv = cast(typeof(glGetPixelMapxv))load("glGetPixelMapxv");
	glGetTexGenxvOES = cast(typeof(glGetTexGenxvOES))load("glGetTexGenxvOES");
	glGetTexLevelParameterxvOES = cast(typeof(glGetTexLevelParameterxvOES))load("glGetTexLevelParameterxvOES");
	glIndexxOES = cast(typeof(glIndexxOES))load("glIndexxOES");
	glIndexxvOES = cast(typeof(glIndexxvOES))load("glIndexxvOES");
	glLoadTransposeMatrixxOES = cast(typeof(glLoadTransposeMatrixxOES))load("glLoadTransposeMatrixxOES");
	glMap1xOES = cast(typeof(glMap1xOES))load("glMap1xOES");
	glMap2xOES = cast(typeof(glMap2xOES))load("glMap2xOES");
	glMapGrid1xOES = cast(typeof(glMapGrid1xOES))load("glMapGrid1xOES");
	glMapGrid2xOES = cast(typeof(glMapGrid2xOES))load("glMapGrid2xOES");
	glMultTransposeMatrixxOES = cast(typeof(glMultTransposeMatrixxOES))load("glMultTransposeMatrixxOES");
	glMultiTexCoord1xOES = cast(typeof(glMultiTexCoord1xOES))load("glMultiTexCoord1xOES");
	glMultiTexCoord1xvOES = cast(typeof(glMultiTexCoord1xvOES))load("glMultiTexCoord1xvOES");
	glMultiTexCoord2xOES = cast(typeof(glMultiTexCoord2xOES))load("glMultiTexCoord2xOES");
	glMultiTexCoord2xvOES = cast(typeof(glMultiTexCoord2xvOES))load("glMultiTexCoord2xvOES");
	glMultiTexCoord3xOES = cast(typeof(glMultiTexCoord3xOES))load("glMultiTexCoord3xOES");
	glMultiTexCoord3xvOES = cast(typeof(glMultiTexCoord3xvOES))load("glMultiTexCoord3xvOES");
	glMultiTexCoord4xvOES = cast(typeof(glMultiTexCoord4xvOES))load("glMultiTexCoord4xvOES");
	glNormal3xvOES = cast(typeof(glNormal3xvOES))load("glNormal3xvOES");
	glPassThroughxOES = cast(typeof(glPassThroughxOES))load("glPassThroughxOES");
	glPixelMapx = cast(typeof(glPixelMapx))load("glPixelMapx");
	glPixelStorex = cast(typeof(glPixelStorex))load("glPixelStorex");
	glPixelTransferxOES = cast(typeof(glPixelTransferxOES))load("glPixelTransferxOES");
	glPixelZoomxOES = cast(typeof(glPixelZoomxOES))load("glPixelZoomxOES");
	glPrioritizeTexturesxOES = cast(typeof(glPrioritizeTexturesxOES))load("glPrioritizeTexturesxOES");
	glRasterPos2xOES = cast(typeof(glRasterPos2xOES))load("glRasterPos2xOES");
	glRasterPos2xvOES = cast(typeof(glRasterPos2xvOES))load("glRasterPos2xvOES");
	glRasterPos3xOES = cast(typeof(glRasterPos3xOES))load("glRasterPos3xOES");
	glRasterPos3xvOES = cast(typeof(glRasterPos3xvOES))load("glRasterPos3xvOES");
	glRasterPos4xOES = cast(typeof(glRasterPos4xOES))load("glRasterPos4xOES");
	glRasterPos4xvOES = cast(typeof(glRasterPos4xvOES))load("glRasterPos4xvOES");
	glRectxOES = cast(typeof(glRectxOES))load("glRectxOES");
	glRectxvOES = cast(typeof(glRectxvOES))load("glRectxvOES");
	glTexCoord1xOES = cast(typeof(glTexCoord1xOES))load("glTexCoord1xOES");
	glTexCoord1xvOES = cast(typeof(glTexCoord1xvOES))load("glTexCoord1xvOES");
	glTexCoord2xOES = cast(typeof(glTexCoord2xOES))load("glTexCoord2xOES");
	glTexCoord2xvOES = cast(typeof(glTexCoord2xvOES))load("glTexCoord2xvOES");
	glTexCoord3xOES = cast(typeof(glTexCoord3xOES))load("glTexCoord3xOES");
	glTexCoord3xvOES = cast(typeof(glTexCoord3xvOES))load("glTexCoord3xvOES");
	glTexCoord4xOES = cast(typeof(glTexCoord4xOES))load("glTexCoord4xOES");
	glTexCoord4xvOES = cast(typeof(glTexCoord4xvOES))load("glTexCoord4xvOES");
	glTexGenxOES = cast(typeof(glTexGenxOES))load("glTexGenxOES");
	glTexGenxvOES = cast(typeof(glTexGenxvOES))load("glTexGenxvOES");
	glVertex2xOES = cast(typeof(glVertex2xOES))load("glVertex2xOES");
	glVertex2xvOES = cast(typeof(glVertex2xvOES))load("glVertex2xvOES");
	glVertex3xOES = cast(typeof(glVertex3xOES))load("glVertex3xOES");
	glVertex3xvOES = cast(typeof(glVertex3xvOES))load("glVertex3xvOES");
	glVertex4xOES = cast(typeof(glVertex4xOES))load("glVertex4xOES");
	glVertex4xvOES = cast(typeof(glVertex4xvOES))load("glVertex4xvOES");
	return;
}
void load_GL_EXT_framebuffer_multisample(Loader load) {
	if(!GL_EXT_framebuffer_multisample) return;
	glRenderbufferStorageMultisampleEXT = cast(typeof(glRenderbufferStorageMultisampleEXT))load("glRenderbufferStorageMultisampleEXT");
	return;
}
void load_GL_SGIS_texture4D(Loader load) {
	if(!GL_SGIS_texture4D) return;
	glTexImage4DSGIS = cast(typeof(glTexImage4DSGIS))load("glTexImage4DSGIS");
	glTexSubImage4DSGIS = cast(typeof(glTexSubImage4DSGIS))load("glTexSubImage4DSGIS");
	return;
}
void load_GL_EXT_texture3D(Loader load) {
	if(!GL_EXT_texture3D) return;
	glTexImage3DEXT = cast(typeof(glTexImage3DEXT))load("glTexImage3DEXT");
	glTexSubImage3DEXT = cast(typeof(glTexSubImage3DEXT))load("glTexSubImage3DEXT");
	return;
}
void load_GL_EXT_multisample(Loader load) {
	if(!GL_EXT_multisample) return;
	glSampleMaskEXT = cast(typeof(glSampleMaskEXT))load("glSampleMaskEXT");
	glSamplePatternEXT = cast(typeof(glSamplePatternEXT))load("glSamplePatternEXT");
	return;
}
void load_GL_EXT_secondary_color(Loader load) {
	if(!GL_EXT_secondary_color) return;
	glSecondaryColor3bEXT = cast(typeof(glSecondaryColor3bEXT))load("glSecondaryColor3bEXT");
	glSecondaryColor3bvEXT = cast(typeof(glSecondaryColor3bvEXT))load("glSecondaryColor3bvEXT");
	glSecondaryColor3dEXT = cast(typeof(glSecondaryColor3dEXT))load("glSecondaryColor3dEXT");
	glSecondaryColor3dvEXT = cast(typeof(glSecondaryColor3dvEXT))load("glSecondaryColor3dvEXT");
	glSecondaryColor3fEXT = cast(typeof(glSecondaryColor3fEXT))load("glSecondaryColor3fEXT");
	glSecondaryColor3fvEXT = cast(typeof(glSecondaryColor3fvEXT))load("glSecondaryColor3fvEXT");
	glSecondaryColor3iEXT = cast(typeof(glSecondaryColor3iEXT))load("glSecondaryColor3iEXT");
	glSecondaryColor3ivEXT = cast(typeof(glSecondaryColor3ivEXT))load("glSecondaryColor3ivEXT");
	glSecondaryColor3sEXT = cast(typeof(glSecondaryColor3sEXT))load("glSecondaryColor3sEXT");
	glSecondaryColor3svEXT = cast(typeof(glSecondaryColor3svEXT))load("glSecondaryColor3svEXT");
	glSecondaryColor3ubEXT = cast(typeof(glSecondaryColor3ubEXT))load("glSecondaryColor3ubEXT");
	glSecondaryColor3ubvEXT = cast(typeof(glSecondaryColor3ubvEXT))load("glSecondaryColor3ubvEXT");
	glSecondaryColor3uiEXT = cast(typeof(glSecondaryColor3uiEXT))load("glSecondaryColor3uiEXT");
	glSecondaryColor3uivEXT = cast(typeof(glSecondaryColor3uivEXT))load("glSecondaryColor3uivEXT");
	glSecondaryColor3usEXT = cast(typeof(glSecondaryColor3usEXT))load("glSecondaryColor3usEXT");
	glSecondaryColor3usvEXT = cast(typeof(glSecondaryColor3usvEXT))load("glSecondaryColor3usvEXT");
	glSecondaryColorPointerEXT = cast(typeof(glSecondaryColorPointerEXT))load("glSecondaryColorPointerEXT");
	return;
}
void load_GL_ATI_vertex_array_object(Loader load) {
	if(!GL_ATI_vertex_array_object) return;
	glNewObjectBufferATI = cast(typeof(glNewObjectBufferATI))load("glNewObjectBufferATI");
	glIsObjectBufferATI = cast(typeof(glIsObjectBufferATI))load("glIsObjectBufferATI");
	glUpdateObjectBufferATI = cast(typeof(glUpdateObjectBufferATI))load("glUpdateObjectBufferATI");
	glGetObjectBufferfvATI = cast(typeof(glGetObjectBufferfvATI))load("glGetObjectBufferfvATI");
	glGetObjectBufferivATI = cast(typeof(glGetObjectBufferivATI))load("glGetObjectBufferivATI");
	glFreeObjectBufferATI = cast(typeof(glFreeObjectBufferATI))load("glFreeObjectBufferATI");
	glArrayObjectATI = cast(typeof(glArrayObjectATI))load("glArrayObjectATI");
	glGetArrayObjectfvATI = cast(typeof(glGetArrayObjectfvATI))load("glGetArrayObjectfvATI");
	glGetArrayObjectivATI = cast(typeof(glGetArrayObjectivATI))load("glGetArrayObjectivATI");
	glVariantArrayObjectATI = cast(typeof(glVariantArrayObjectATI))load("glVariantArrayObjectATI");
	glGetVariantArrayObjectfvATI = cast(typeof(glGetVariantArrayObjectfvATI))load("glGetVariantArrayObjectfvATI");
	glGetVariantArrayObjectivATI = cast(typeof(glGetVariantArrayObjectivATI))load("glGetVariantArrayObjectivATI");
	return;
}
void load_GL_ARB_sparse_texture(Loader load) {
	if(!GL_ARB_sparse_texture) return;
	glTexPageCommitmentARB = cast(typeof(glTexPageCommitmentARB))load("glTexPageCommitmentARB");
	return;
}
void load_GL_ARB_sparse_buffer(Loader load) {
	if(!GL_ARB_sparse_buffer) return;
	glBufferPageCommitmentARB = cast(typeof(glBufferPageCommitmentARB))load("glBufferPageCommitmentARB");
	glNamedBufferPageCommitmentEXT = cast(typeof(glNamedBufferPageCommitmentEXT))load("glNamedBufferPageCommitmentEXT");
	glNamedBufferPageCommitmentARB = cast(typeof(glNamedBufferPageCommitmentARB))load("glNamedBufferPageCommitmentARB");
	return;
}
void load_GL_EXT_draw_range_elements(Loader load) {
	if(!GL_EXT_draw_range_elements) return;
	glDrawRangeElementsEXT = cast(typeof(glDrawRangeElementsEXT))load("glDrawRangeElementsEXT");
	return;
}
bool gladLoadGLES2(Loader load) {
	glGetString = cast(typeof(glGetString))load("glGetString");
	if(glGetString is null) { return false; }
	if(glGetString(GL_VERSION) is null) { return false; }

	find_coreGLES2();
	load_GL_ES_VERSION_2_0(load);
	load_GL_ES_VERSION_3_0(load);
	load_GL_ES_VERSION_3_1(load);

	find_extensionsGLES2();
	load_GL_OVR_multiview(load);
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_NV_conditional_render(load);
	load_GL_EXT_separate_shader_objects(load);
	load_GL_AMD_performance_monitor(load);
	load_GL_KHR_robustness(load);
	load_GL_NV_fragment_coverage_to_color(load);
	load_GL_NV_fence(load);
	load_GL_NV_blend_equation_advanced(load);
	load_GL_NV_bindless_texture(load);
	load_GL_KHR_debug(load);
	load_GL_KHR_blend_equation_advanced(load);
	load_GL_EXT_texture_filter_minmax(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_NV_framebuffer_mixed_samples(load);
	load_GL_EXT_raster_multisample(load);
	load_GL_EXT_debug_marker(load);
	load_GL_INTEL_performance_query(load);
	load_GL_EXT_debug_label(load);
	load_GL_NV_internalformat_sample_query(load);
	load_GL_EXT_draw_instanced(load);
	load_GL_NV_conservative_raster(load);
	load_GL_NV_path_rendering(load);
	load_GL_NV_sample_locations(load);
	load_GL_NV_non_square_matrices(load);
	load_GL_EXT_sparse_texture(load);
	load_GL_NV_draw_instanced(load);
	load_GL_NV_fragment_coverage_to_color(load);
	load_GL_NV_fence(load);
	load_GL_NV_sample_locations(load);
	load_GL_EXT_base_instance(load);
	load_GL_EXT_instanced_arrays(load);
	load_GL_EXT_draw_buffers_indexed(load);
	load_GL_OVR_multiview(load);
	load_GL_ANGLE_translated_shader_source(load);
	load_GL_NV_coverage_sample(load);
	load_GL_ANGLE_framebuffer_multisample(load);
	load_GL_OES_vertex_array_object(load);
	load_GL_QCOM_tiled_rendering(load);
	load_GL_EXT_robustness(load);
	load_GL_KHR_robustness(load);
	load_GL_EXT_disjoint_timer_query(load);
	load_GL_NV_conservative_raster(load);
	load_GL_EXT_primitive_bounding_box(load);
	load_GL_NV_framebuffer_mixed_samples(load);
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_EXT_raster_multisample(load);
	load_GL_QCOM_driver_control(load);
	load_GL_EXT_debug_marker(load);
	load_GL_OES_geometry_shader(load);
	load_GL_OES_tessellation_shader(load);
	load_GL_OES_texture_view(load);
	load_GL_EXT_multisampled_render_to_texture(load);
	load_GL_EXT_buffer_storage(load);
	load_GL_OES_texture_buffer(load);
	load_GL_OES_get_program_binary(load);
	load_GL_APPLE_framebuffer_multisample(load);
	load_GL_NV_copy_buffer(load);
	load_GL_EXT_texture_view(load);
	load_GL_NV_framebuffer_blit(load);
	load_GL_QCOM_alpha_test(load);
	load_GL_INTEL_performance_query(load);
	load_GL_KHR_debug(load);
	load_GL_OES_texture_border_clamp(load);
	load_GL_EXT_occlusion_query_boolean(load);
	load_GL_NV_bindless_texture(load);
	load_GL_EXT_multi_draw_indirect(load);
	load_GL_KHR_blend_equation_advanced(load);
	load_GL_APPLE_sync(load);
	load_GL_OES_copy_image(load);
	load_GL_QCOM_extended_get2(load);
	load_GL_EXT_draw_elements_base_vertex(load);
	load_GL_EXT_separate_shader_objects(load);
	load_GL_NV_framebuffer_multisample(load);
	load_GL_EXT_texture_filter_minmax(load);
	load_GL_NV_path_rendering(load);
	load_GL_OES_texture_storage_multisample_2d_array(load);
	load_GL_OES_draw_buffers_indexed(load);
	load_GL_OES_EGL_image(load);
	load_GL_NV_draw_buffers(load);
	load_GL_NV_blend_equation_advanced(load);
	load_GL_EXT_draw_buffers(load);
	load_GL_EXT_debug_label(load);
	load_GL_NV_conditional_render(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_NV_internalformat_sample_query(load);
	load_GL_NV_instanced_arrays(load);
	load_GL_EXT_texture_storage(load);
	load_GL_EXT_copy_image(load);
	load_GL_OES_sample_shading(load);
	load_GL_NV_viewport_array(load);
	load_GL_EXT_map_buffer_range(load);
	load_GL_OES_mapbuffer(load);
	load_GL_NV_polygon_mode(load);
	load_GL_AMD_performance_monitor(load);
	load_GL_IMG_multisampled_render_to_texture(load);
	load_GL_OES_draw_elements_base_vertex(load);
	load_GL_APPLE_copy_texture_levels(load);
	load_GL_EXT_multiview_draw_buffers(load);
	load_GL_QCOM_extended_get(load);
	load_GL_EXT_geometry_shader(load);
	load_GL_EXT_texture_border_clamp(load);
	load_GL_ANGLE_framebuffer_blit(load);
	load_GL_EXT_draw_instanced(load);
	load_GL_OES_texture_3D(load);
	load_GL_EXT_tessellation_shader(load);
	load_GL_OES_primitive_bounding_box(load);
	load_GL_NV_read_buffer(load);
	load_GL_ANGLE_instanced_arrays(load);
	load_GL_EXT_discard_framebuffer(load);
	load_GL_EXT_texture_buffer(load);
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_NV_fence(load);
	load_GL_EXT_map_buffer_range(load);
	load_GL_QCOM_extended_get2(load);
	load_GL_EXT_multisampled_render_to_texture(load);
	load_GL_EXT_discard_framebuffer(load);
	load_GL_OES_mapbuffer(load);
	load_GL_IMG_multisampled_render_to_texture(load);
	load_GL_APPLE_framebuffer_multisample(load);
	load_GL_APPLE_copy_texture_levels(load);
	load_GL_OES_EGL_image(load);
	load_GL_QCOM_extended_get(load);
	load_GL_QCOM_tiled_rendering(load);
	load_GL_EXT_robustness(load);
	load_GL_OES_vertex_array_object(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_APPLE_sync(load);
	load_GL_EXT_texture_storage(load);
	load_GL_QCOM_driver_control(load);
	return GLVersion.major != 0 || GLVersion.minor != 0;
}

private:

void find_coreGLES2() {

    // Thank you @elmindreda
    // https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
    // https://github.com/glfw/glfw/blob/master/src/context.c#L36
    int i;
    const(char)* glversion;
    const(char)*[] prefixes = [
        "OpenGL ES-CM ".ptr,
        "OpenGL ES-CL ".ptr,
        "OpenGL ES ".ptr,
    ];

    glversion = cast(const(char)*)glGetString(GL_VERSION);
    if (glversion is null) return;

    foreach(prefix; prefixes) {
        size_t length = strlen(prefix);
        if (strncmp(glversion, prefix, length) == 0) {
            glversion += length;
            break;
        }
    }

    int major = glversion[0] - '0';
    int minor = glversion[2] - '0';
    GLVersion.major = major; GLVersion.minor = minor;
	GL_ES_VERSION_2_0 = (major == 2 && minor >= 0) || major > 2;
	GL_ES_VERSION_3_0 = (major == 3 && minor >= 0) || major > 3;
	GL_ES_VERSION_3_1 = (major == 3 && minor >= 1) || major > 3;
	return;
}

void find_extensionsGLES2() {
	GL_EXT_post_depth_coverage = has_ext("GL_EXT_post_depth_coverage");
	GL_OVR_multiview = has_ext("GL_OVR_multiview");
	GL_NV_viewport_array2 = has_ext("GL_NV_viewport_array2");
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_NV_conditional_render = has_ext("GL_NV_conditional_render");
	GL_EXT_separate_shader_objects = has_ext("GL_EXT_separate_shader_objects");
	GL_AMD_performance_monitor = has_ext("GL_AMD_performance_monitor");
	GL_EXT_shader_integer_mix = has_ext("GL_EXT_shader_integer_mix");
	GL_KHR_robustness = has_ext("GL_KHR_robustness");
	GL_NV_fragment_coverage_to_color = has_ext("GL_NV_fragment_coverage_to_color");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_NV_sample_mask_override_coverage = has_ext("GL_NV_sample_mask_override_coverage");
	GL_NV_path_rendering_shared_edge = has_ext("GL_NV_path_rendering_shared_edge");
	GL_NV_blend_equation_advanced = has_ext("GL_NV_blend_equation_advanced");
	GL_KHR_robust_buffer_access_behavior = has_ext("GL_KHR_robust_buffer_access_behavior");
	GL_NV_geometry_shader_passthrough = has_ext("GL_NV_geometry_shader_passthrough");
	GL_NV_bindless_texture = has_ext("GL_NV_bindless_texture");
	GL_KHR_debug = has_ext("GL_KHR_debug");
	GL_KHR_texture_compression_astc_hdr = has_ext("GL_KHR_texture_compression_astc_hdr");
	GL_KHR_blend_equation_advanced = has_ext("GL_KHR_blend_equation_advanced");
	GL_EXT_texture_filter_minmax = has_ext("GL_EXT_texture_filter_minmax");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_NV_blend_equation_advanced_coherent = has_ext("GL_NV_blend_equation_advanced_coherent");
	GL_OVR_multiview2 = has_ext("GL_OVR_multiview2");
	GL_NV_framebuffer_mixed_samples = has_ext("GL_NV_framebuffer_mixed_samples");
	GL_EXT_raster_multisample = has_ext("GL_EXT_raster_multisample");
	GL_EXT_debug_marker = has_ext("GL_EXT_debug_marker");
	GL_EXT_texture_compression_s3tc = has_ext("GL_EXT_texture_compression_s3tc");
	GL_INTEL_performance_query = has_ext("GL_INTEL_performance_query");
	GL_EXT_texture_sRGB_decode = has_ext("GL_EXT_texture_sRGB_decode");
	GL_EXT_debug_label = has_ext("GL_EXT_debug_label");
	GL_NV_internalformat_sample_query = has_ext("GL_NV_internalformat_sample_query");
	GL_EXT_draw_instanced = has_ext("GL_EXT_draw_instanced");
	GL_KHR_blend_equation_advanced_coherent = has_ext("GL_KHR_blend_equation_advanced_coherent");
	GL_NV_fill_rectangle = has_ext("GL_NV_fill_rectangle");
	GL_KHR_texture_compression_astc_ldr = has_ext("GL_KHR_texture_compression_astc_ldr");
	GL_NV_conservative_raster = has_ext("GL_NV_conservative_raster");
	GL_NV_fragment_shader_interlock = has_ext("GL_NV_fragment_shader_interlock");
	GL_NV_path_rendering = has_ext("GL_NV_path_rendering");
	GL_APPLE_rgb_422 = has_ext("GL_APPLE_rgb_422");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_NV_sample_locations = has_ext("GL_NV_sample_locations");
	GL_KHR_context_flush_control = has_ext("GL_KHR_context_flush_control");
	GL_NV_non_square_matrices = has_ext("GL_NV_non_square_matrices");
	GL_OES_packed_depth_stencil = has_ext("GL_OES_packed_depth_stencil");
	GL_QCOM_perfmon_global_mode = has_ext("GL_QCOM_perfmon_global_mode");
	GL_EXT_sparse_texture = has_ext("GL_EXT_sparse_texture");
	GL_NV_draw_instanced = has_ext("GL_NV_draw_instanced");
	GL_OES_texture_half_float_linear = has_ext("GL_OES_texture_half_float_linear");
	GL_KHR_blend_equation_advanced_coherent = has_ext("GL_KHR_blend_equation_advanced_coherent");
	GL_NV_fragment_coverage_to_color = has_ext("GL_NV_fragment_coverage_to_color");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_NV_texture_border_clamp = has_ext("GL_NV_texture_border_clamp");
	GL_IMG_texture_compression_pvrtc = has_ext("GL_IMG_texture_compression_pvrtc");
	GL_NV_sRGB_formats = has_ext("GL_NV_sRGB_formats");
	GL_EXT_texture_compression_s3tc = has_ext("GL_EXT_texture_compression_s3tc");
	GL_NV_sample_locations = has_ext("GL_NV_sample_locations");
	GL_EXT_base_instance = has_ext("GL_EXT_base_instance");
	GL_EXT_instanced_arrays = has_ext("GL_EXT_instanced_arrays");
	GL_QCOM_writeonly_rendering = has_ext("GL_QCOM_writeonly_rendering");
	GL_DMP_program_binary = has_ext("GL_DMP_program_binary");
	GL_EXT_draw_buffers_indexed = has_ext("GL_EXT_draw_buffers_indexed");
	GL_NV_read_depth_stencil = has_ext("GL_NV_read_depth_stencil");
	GL_OVR_multiview = has_ext("GL_OVR_multiview");
	GL_ANGLE_translated_shader_source = has_ext("GL_ANGLE_translated_shader_source");
	GL_NV_fill_rectangle = has_ext("GL_NV_fill_rectangle");
	GL_NV_coverage_sample = has_ext("GL_NV_coverage_sample");
	GL_OES_texture_cube_map_array = has_ext("GL_OES_texture_cube_map_array");
	GL_ANGLE_framebuffer_multisample = has_ext("GL_ANGLE_framebuffer_multisample");
	GL_OES_vertex_array_object = has_ext("GL_OES_vertex_array_object");
	GL_QCOM_tiled_rendering = has_ext("GL_QCOM_tiled_rendering");
	GL_NV_sample_mask_override_coverage = has_ext("GL_NV_sample_mask_override_coverage");
	GL_AMD_program_binary_Z400 = has_ext("GL_AMD_program_binary_Z400");
	GL_APPLE_color_buffer_packed_float = has_ext("GL_APPLE_color_buffer_packed_float");
	GL_EXT_robustness = has_ext("GL_EXT_robustness");
	GL_OES_fbo_render_mipmap = has_ext("GL_OES_fbo_render_mipmap");
	GL_NV_viewport_array2 = has_ext("GL_NV_viewport_array2");
	GL_KHR_robustness = has_ext("GL_KHR_robustness");
	GL_OES_compressed_ETC1_RGB8_sub_texture = has_ext("GL_OES_compressed_ETC1_RGB8_sub_texture");
	GL_ANGLE_texture_usage = has_ext("GL_ANGLE_texture_usage");
	GL_EXT_gpu_shader5 = has_ext("GL_EXT_gpu_shader5");
	GL_OES_shader_io_blocks = has_ext("GL_OES_shader_io_blocks");
	GL_FJ_shader_binary_GCCSO = has_ext("GL_FJ_shader_binary_GCCSO");
	GL_EXT_disjoint_timer_query = has_ext("GL_EXT_disjoint_timer_query");
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_EXT_shader_texture_lod = has_ext("GL_EXT_shader_texture_lod");
	GL_NV_read_buffer_front = has_ext("GL_NV_read_buffer_front");
	GL_OES_texture_float = has_ext("GL_OES_texture_float");
	GL_NV_conservative_raster = has_ext("GL_NV_conservative_raster");
	GL_NV_path_rendering_shared_edge = has_ext("GL_NV_path_rendering_shared_edge");
	GL_NV_fbo_color_attachments = has_ext("GL_NV_fbo_color_attachments");
	GL_EXT_primitive_bounding_box = has_ext("GL_EXT_primitive_bounding_box");
	GL_IMG_read_format = has_ext("GL_IMG_read_format");
	GL_EXT_shader_integer_mix = has_ext("GL_EXT_shader_integer_mix");
	GL_ANDROID_extension_pack_es31a = has_ext("GL_ANDROID_extension_pack_es31a");
	GL_NV_framebuffer_mixed_samples = has_ext("GL_NV_framebuffer_mixed_samples");
	GL_NV_texture_compression_s3tc_update = has_ext("GL_NV_texture_compression_s3tc_update");
	GL_OES_texture_float_linear = has_ext("GL_OES_texture_float_linear");
	GL_OES_fragment_precision_high = has_ext("GL_OES_fragment_precision_high");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_EXT_raster_multisample = has_ext("GL_EXT_raster_multisample");
	GL_EXT_texture_compression_dxt1 = has_ext("GL_EXT_texture_compression_dxt1");
	GL_EXT_texture_sRGB_RG8 = has_ext("GL_EXT_texture_sRGB_RG8");
	GL_APPLE_clip_distance = has_ext("GL_APPLE_clip_distance");
	GL_QCOM_driver_control = has_ext("GL_QCOM_driver_control");
	GL_ANGLE_depth_texture = has_ext("GL_ANGLE_depth_texture");
	GL_KHR_robust_buffer_access_behavior = has_ext("GL_KHR_robust_buffer_access_behavior");
	GL_EXT_render_snorm = has_ext("GL_EXT_render_snorm");
	GL_KHR_texture_compression_astc_ldr = has_ext("GL_KHR_texture_compression_astc_ldr");
	GL_EXT_debug_marker = has_ext("GL_EXT_debug_marker");
	GL_OES_geometry_shader = has_ext("GL_OES_geometry_shader");
	GL_OES_tessellation_shader = has_ext("GL_OES_tessellation_shader");
	GL_OES_texture_view = has_ext("GL_OES_texture_view");
	GL_EXT_multisampled_render_to_texture = has_ext("GL_EXT_multisampled_render_to_texture");
	GL_EXT_buffer_storage = has_ext("GL_EXT_buffer_storage");
	GL_OES_texture_buffer = has_ext("GL_OES_texture_buffer");
	GL_NV_blend_equation_advanced_coherent = has_ext("GL_NV_blend_equation_advanced_coherent");
	GL_EXT_post_depth_coverage = has_ext("GL_EXT_post_depth_coverage");
	GL_NV_geometry_shader_passthrough = has_ext("GL_NV_geometry_shader_passthrough");
	GL_EXT_tessellation_point_size = has_ext("GL_EXT_tessellation_point_size");
	GL_EXT_color_buffer_half_float = has_ext("GL_EXT_color_buffer_half_float");
	GL_OES_get_program_binary = has_ext("GL_OES_get_program_binary");
	GL_OES_geometry_point_size = has_ext("GL_OES_geometry_point_size");
	GL_APPLE_framebuffer_multisample = has_ext("GL_APPLE_framebuffer_multisample");
	GL_OES_stencil4 = has_ext("GL_OES_stencil4");
	GL_NV_copy_buffer = has_ext("GL_NV_copy_buffer");
	GL_OES_texture_half_float = has_ext("GL_OES_texture_half_float");
	GL_EXT_texture_view = has_ext("GL_EXT_texture_view");
	GL_OES_vertex_half_float = has_ext("GL_OES_vertex_half_float");
	GL_NV_framebuffer_blit = has_ext("GL_NV_framebuffer_blit");
	GL_OES_stencil1 = has_ext("GL_OES_stencil1");
	GL_QCOM_alpha_test = has_ext("GL_QCOM_alpha_test");
	GL_EXT_shader_implicit_conversions = has_ext("GL_EXT_shader_implicit_conversions");
	GL_INTEL_performance_query = has_ext("GL_INTEL_performance_query");
	GL_KHR_debug = has_ext("GL_KHR_debug");
	GL_EXT_sRGB = has_ext("GL_EXT_sRGB");
	GL_OES_texture_border_clamp = has_ext("GL_OES_texture_border_clamp");
	GL_ANGLE_pack_reverse_row_order = has_ext("GL_ANGLE_pack_reverse_row_order");
	GL_EXT_occlusion_query_boolean = has_ext("GL_EXT_occlusion_query_boolean");
	GL_NV_bindless_texture = has_ext("GL_NV_bindless_texture");
	GL_EXT_multi_draw_indirect = has_ext("GL_EXT_multi_draw_indirect");
	GL_OES_tessellation_point_size = has_ext("GL_OES_tessellation_point_size");
	GL_OES_depth_texture = has_ext("GL_OES_depth_texture");
	GL_QCOM_binning_control = has_ext("GL_QCOM_binning_control");
	GL_KHR_texture_compression_astc_hdr = has_ext("GL_KHR_texture_compression_astc_hdr");
	GL_KHR_blend_equation_advanced = has_ext("GL_KHR_blend_equation_advanced");
	GL_OES_surfaceless_context = has_ext("GL_OES_surfaceless_context");
	GL_APPLE_sync = has_ext("GL_APPLE_sync");
	GL_IMG_program_binary = has_ext("GL_IMG_program_binary");
	GL_EXT_geometry_point_size = has_ext("GL_EXT_geometry_point_size");
	GL_EXT_shader_framebuffer_fetch = has_ext("GL_EXT_shader_framebuffer_fetch");
	GL_ANGLE_program_binary = has_ext("GL_ANGLE_program_binary");
	GL_EXT_unpack_subimage = has_ext("GL_EXT_unpack_subimage");
	GL_ANGLE_texture_compression_dxt3 = has_ext("GL_ANGLE_texture_compression_dxt3");
	GL_ANGLE_texture_compression_dxt5 = has_ext("GL_ANGLE_texture_compression_dxt5");
	GL_OES_texture_npot = has_ext("GL_OES_texture_npot");
	GL_EXT_read_format_bgra = has_ext("GL_EXT_read_format_bgra");
	GL_OES_compressed_ETC1_RGB8_texture = has_ext("GL_OES_compressed_ETC1_RGB8_texture");
	GL_OES_copy_image = has_ext("GL_OES_copy_image");
	GL_EXT_pvrtc_sRGB = has_ext("GL_EXT_pvrtc_sRGB");
	GL_QCOM_extended_get2 = has_ext("GL_QCOM_extended_get2");
	GL_EXT_shader_pixel_local_storage = has_ext("GL_EXT_shader_pixel_local_storage");
	GL_NV_shadow_samplers_cube = has_ext("GL_NV_shadow_samplers_cube");
	GL_OES_texture_compression_astc = has_ext("GL_OES_texture_compression_astc");
	GL_OES_depth32 = has_ext("GL_OES_depth32");
	GL_APPLE_texture_max_level = has_ext("GL_APPLE_texture_max_level");
	GL_OES_shader_multisample_interpolation = has_ext("GL_OES_shader_multisample_interpolation");
	GL_EXT_shadow_samplers = has_ext("GL_EXT_shadow_samplers");
	GL_IMG_shader_binary = has_ext("GL_IMG_shader_binary");
	GL_EXT_draw_elements_base_vertex = has_ext("GL_EXT_draw_elements_base_vertex");
	GL_NV_fragment_shader_interlock = has_ext("GL_NV_fragment_shader_interlock");
	GL_EXT_separate_shader_objects = has_ext("GL_EXT_separate_shader_objects");
	GL_EXT_shader_io_blocks = has_ext("GL_EXT_shader_io_blocks");
	GL_NV_framebuffer_multisample = has_ext("GL_NV_framebuffer_multisample");
	GL_EXT_texture_filter_minmax = has_ext("GL_EXT_texture_filter_minmax");
	GL_ARM_shader_framebuffer_fetch = has_ext("GL_ARM_shader_framebuffer_fetch");
	GL_NV_path_rendering = has_ext("GL_NV_path_rendering");
	GL_OES_texture_storage_multisample_2d_array = has_ext("GL_OES_texture_storage_multisample_2d_array");
	GL_OES_draw_buffers_indexed = has_ext("GL_OES_draw_buffers_indexed");
	GL_OES_EGL_image = has_ext("GL_OES_EGL_image");
	GL_NV_draw_buffers = has_ext("GL_NV_draw_buffers");
	GL_OES_vertex_type_10_10_10_2 = has_ext("GL_OES_vertex_type_10_10_10_2");
	GL_APPLE_rgb_422 = has_ext("GL_APPLE_rgb_422");
	GL_DMP_shader_binary = has_ext("GL_DMP_shader_binary");
	GL_NV_texture_npot_2D_mipmap = has_ext("GL_NV_texture_npot_2D_mipmap");
	GL_OES_sample_variables = has_ext("GL_OES_sample_variables");
	GL_NV_explicit_attrib_location = has_ext("GL_NV_explicit_attrib_location");
	GL_NV_blend_equation_advanced = has_ext("GL_NV_blend_equation_advanced");
	GL_EXT_draw_buffers = has_ext("GL_EXT_draw_buffers");
	GL_EXT_debug_label = has_ext("GL_EXT_debug_label");
	GL_NV_read_stencil = has_ext("GL_NV_read_stencil");
	GL_NV_conditional_render = has_ext("GL_NV_conditional_render");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_NV_internalformat_sample_query = has_ext("GL_NV_internalformat_sample_query");
	GL_OES_depth24 = has_ext("GL_OES_depth24");
	GL_NV_instanced_arrays = has_ext("GL_NV_instanced_arrays");
	GL_EXT_texture_storage = has_ext("GL_EXT_texture_storage");
	GL_OES_gpu_shader5 = has_ext("GL_OES_gpu_shader5");
	GL_OES_required_internalformat = has_ext("GL_OES_required_internalformat");
	GL_EXT_sRGB_write_control = has_ext("GL_EXT_sRGB_write_control");
	GL_EXT_copy_image = has_ext("GL_EXT_copy_image");
	GL_AMD_compressed_3DC_texture = has_ext("GL_AMD_compressed_3DC_texture");
	GL_OES_element_index_uint = has_ext("GL_OES_element_index_uint");
	GL_OES_sample_shading = has_ext("GL_OES_sample_shading");
	GL_IMG_texture_compression_pvrtc2 = has_ext("GL_IMG_texture_compression_pvrtc2");
	GL_NV_viewport_array = has_ext("GL_NV_viewport_array");
	GL_OES_rgb8_rgba8 = has_ext("GL_OES_rgb8_rgba8");
	GL_EXT_map_buffer_range = has_ext("GL_EXT_map_buffer_range");
	GL_OES_mapbuffer = has_ext("GL_OES_mapbuffer");
	GL_EXT_float_blend = has_ext("GL_EXT_float_blend");
	GL_NV_polygon_mode = has_ext("GL_NV_polygon_mode");
	GL_ARM_shader_framebuffer_fetch_depth_stencil = has_ext("GL_ARM_shader_framebuffer_fetch_depth_stencil");
	GL_NV_image_formats = has_ext("GL_NV_image_formats");
	GL_OES_EGL_image_external = has_ext("GL_OES_EGL_image_external");
	GL_APPLE_texture_format_BGRA8888 = has_ext("GL_APPLE_texture_format_BGRA8888");
	GL_AMD_performance_monitor = has_ext("GL_AMD_performance_monitor");
	GL_VIV_shader_binary = has_ext("GL_VIV_shader_binary");
	GL_NV_shadow_samplers_array = has_ext("GL_NV_shadow_samplers_array");
	GL_OVR_multiview2 = has_ext("GL_OVR_multiview2");
	GL_IMG_multisampled_render_to_texture = has_ext("GL_IMG_multisampled_render_to_texture");
	GL_NV_depth_nonlinear = has_ext("GL_NV_depth_nonlinear");
	GL_OES_draw_elements_base_vertex = has_ext("GL_OES_draw_elements_base_vertex");
	GL_NV_shader_noperspective_interpolation = has_ext("GL_NV_shader_noperspective_interpolation");
	GL_EXT_texture_format_BGRA8888 = has_ext("GL_EXT_texture_format_BGRA8888");
	GL_EXT_YUV_target = has_ext("GL_EXT_YUV_target");
	GL_APPLE_copy_texture_levels = has_ext("GL_APPLE_copy_texture_levels");
	GL_ARM_mali_shader_binary = has_ext("GL_ARM_mali_shader_binary");
	GL_EXT_multiview_draw_buffers = has_ext("GL_EXT_multiview_draw_buffers");
	GL_OES_texture_stencil8 = has_ext("GL_OES_texture_stencil8");
	GL_QCOM_extended_get = has_ext("GL_QCOM_extended_get");
	GL_EXT_geometry_shader = has_ext("GL_EXT_geometry_shader");
	GL_EXT_texture_norm16 = has_ext("GL_EXT_texture_norm16");
	GL_EXT_texture_rg = has_ext("GL_EXT_texture_rg");
	GL_OES_standard_derivatives = has_ext("GL_OES_standard_derivatives");
	GL_EXT_texture_border_clamp = has_ext("GL_EXT_texture_border_clamp");
	GL_OES_shader_image_atomic = has_ext("GL_OES_shader_image_atomic");
	GL_ANGLE_framebuffer_blit = has_ext("GL_ANGLE_framebuffer_blit");
	GL_EXT_draw_instanced = has_ext("GL_EXT_draw_instanced");
	GL_OES_texture_3D = has_ext("GL_OES_texture_3D");
	GL_ARM_rgba8 = has_ext("GL_ARM_rgba8");
	GL_EXT_tessellation_shader = has_ext("GL_EXT_tessellation_shader");
	GL_OES_primitive_bounding_box = has_ext("GL_OES_primitive_bounding_box");
	GL_EXT_texture_sRGB_R8 = has_ext("GL_EXT_texture_sRGB_R8");
	GL_NV_read_buffer = has_ext("GL_NV_read_buffer");
	GL_NV_generate_mipmap_sRGB = has_ext("GL_NV_generate_mipmap_sRGB");
	GL_EXT_texture_cube_map_array = has_ext("GL_EXT_texture_cube_map_array");
	GL_OES_EGL_image_external_essl3 = has_ext("GL_OES_EGL_image_external_essl3");
	GL_KHR_context_flush_control = has_ext("GL_KHR_context_flush_control");
	GL_EXT_texture_type_2_10_10_10_REV = has_ext("GL_EXT_texture_type_2_10_10_10_REV");
	GL_ANGLE_instanced_arrays = has_ext("GL_ANGLE_instanced_arrays");
	GL_EXT_discard_framebuffer = has_ext("GL_EXT_discard_framebuffer");
	GL_EXT_texture_sRGB_decode = has_ext("GL_EXT_texture_sRGB_decode");
	GL_NV_read_depth = has_ext("GL_NV_read_depth");
	GL_ARM_mali_program_binary = has_ext("GL_ARM_mali_program_binary");
	GL_AMD_compressed_ATC_texture = has_ext("GL_AMD_compressed_ATC_texture");
	GL_APPLE_texture_packed_float = has_ext("GL_APPLE_texture_packed_float");
	GL_EXT_texture_buffer = has_ext("GL_EXT_texture_buffer");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_AMD_compressed_3DC_texture = has_ext("GL_AMD_compressed_3DC_texture");
	GL_EXT_texture_compression_dxt1 = has_ext("GL_EXT_texture_compression_dxt1");
	GL_OES_element_index_uint = has_ext("GL_OES_element_index_uint");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_EXT_map_buffer_range = has_ext("GL_EXT_map_buffer_range");
	GL_EXT_read_format_bgra = has_ext("GL_EXT_read_format_bgra");
	GL_OES_compressed_ETC1_RGB8_texture = has_ext("GL_OES_compressed_ETC1_RGB8_texture");
	GL_QCOM_extended_get2 = has_ext("GL_QCOM_extended_get2");
	GL_OES_EGL_image_external = has_ext("GL_OES_EGL_image_external");
	GL_OES_required_internalformat = has_ext("GL_OES_required_internalformat");
	GL_APPLE_texture_max_level = has_ext("GL_APPLE_texture_max_level");
	GL_EXT_multisampled_render_to_texture = has_ext("GL_EXT_multisampled_render_to_texture");
	GL_QCOM_writeonly_rendering = has_ext("GL_QCOM_writeonly_rendering");
	GL_OES_packed_depth_stencil = has_ext("GL_OES_packed_depth_stencil");
	GL_APPLE_texture_format_BGRA8888 = has_ext("GL_APPLE_texture_format_BGRA8888");
	GL_EXT_discard_framebuffer = has_ext("GL_EXT_discard_framebuffer");
	GL_QCOM_perfmon_global_mode = has_ext("GL_QCOM_perfmon_global_mode");
	GL_OES_mapbuffer = has_ext("GL_OES_mapbuffer");
	GL_IMG_multisampled_render_to_texture = has_ext("GL_IMG_multisampled_render_to_texture");
	GL_OES_depth32 = has_ext("GL_OES_depth32");
	GL_APPLE_framebuffer_multisample = has_ext("GL_APPLE_framebuffer_multisample");
	GL_APPLE_copy_texture_levels = has_ext("GL_APPLE_copy_texture_levels");
	GL_EXT_texture_format_BGRA8888 = has_ext("GL_EXT_texture_format_BGRA8888");
	GL_OES_EGL_image = has_ext("GL_OES_EGL_image");
	GL_QCOM_extended_get = has_ext("GL_QCOM_extended_get");
	GL_QCOM_tiled_rendering = has_ext("GL_QCOM_tiled_rendering");
	GL_OES_stencil4 = has_ext("GL_OES_stencil4");
	GL_OES_stencil1 = has_ext("GL_OES_stencil1");
	GL_ARM_rgba8 = has_ext("GL_ARM_rgba8");
	GL_EXT_robustness = has_ext("GL_EXT_robustness");
	GL_EXT_sRGB = has_ext("GL_EXT_sRGB");
	GL_OES_compressed_ETC1_RGB8_sub_texture = has_ext("GL_OES_compressed_ETC1_RGB8_sub_texture");
	GL_OES_rgb8_rgba8 = has_ext("GL_OES_rgb8_rgba8");
	GL_OES_fbo_render_mipmap = has_ext("GL_OES_fbo_render_mipmap");
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_OES_vertex_array_object = has_ext("GL_OES_vertex_array_object");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_IMG_read_format = has_ext("GL_IMG_read_format");
	GL_OES_depth24 = has_ext("GL_OES_depth24");
	GL_APPLE_sync = has_ext("GL_APPLE_sync");
	GL_EXT_texture_storage = has_ext("GL_EXT_texture_storage");
	GL_AMD_compressed_ATC_texture = has_ext("GL_AMD_compressed_ATC_texture");
	GL_QCOM_driver_control = has_ext("GL_QCOM_driver_control");
	GL_IMG_texture_compression_pvrtc = has_ext("GL_IMG_texture_compression_pvrtc");
	return;
}

void load_GL_ES_VERSION_2_0(Loader load) {
	if(!GL_ES_VERSION_2_0) return;
	glActiveTexture = cast(typeof(glActiveTexture))load("glActiveTexture");
	glAttachShader = cast(typeof(glAttachShader))load("glAttachShader");
	glBindAttribLocation = cast(typeof(glBindAttribLocation))load("glBindAttribLocation");
	glBindBuffer = cast(typeof(glBindBuffer))load("glBindBuffer");
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer");
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer");
	glBindTexture = cast(typeof(glBindTexture))load("glBindTexture");
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor");
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation");
	glBlendEquationSeparate = cast(typeof(glBlendEquationSeparate))load("glBlendEquationSeparate");
	glBlendFunc = cast(typeof(glBlendFunc))load("glBlendFunc");
	glBlendFuncSeparate = cast(typeof(glBlendFuncSeparate))load("glBlendFuncSeparate");
	glBufferData = cast(typeof(glBufferData))load("glBufferData");
	glBufferSubData = cast(typeof(glBufferSubData))load("glBufferSubData");
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus");
	glClear = cast(typeof(glClear))load("glClear");
	glClearColor = cast(typeof(glClearColor))load("glClearColor");
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf");
	glClearStencil = cast(typeof(glClearStencil))load("glClearStencil");
	glColorMask = cast(typeof(glColorMask))load("glColorMask");
	glCompileShader = cast(typeof(glCompileShader))load("glCompileShader");
	glCompressedTexImage2D = cast(typeof(glCompressedTexImage2D))load("glCompressedTexImage2D");
	glCompressedTexSubImage2D = cast(typeof(glCompressedTexSubImage2D))load("glCompressedTexSubImage2D");
	glCopyTexImage2D = cast(typeof(glCopyTexImage2D))load("glCopyTexImage2D");
	glCopyTexSubImage2D = cast(typeof(glCopyTexSubImage2D))load("glCopyTexSubImage2D");
	glCreateProgram = cast(typeof(glCreateProgram))load("glCreateProgram");
	glCreateShader = cast(typeof(glCreateShader))load("glCreateShader");
	glCullFace = cast(typeof(glCullFace))load("glCullFace");
	glDeleteBuffers = cast(typeof(glDeleteBuffers))load("glDeleteBuffers");
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers");
	glDeleteProgram = cast(typeof(glDeleteProgram))load("glDeleteProgram");
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers");
	glDeleteShader = cast(typeof(glDeleteShader))load("glDeleteShader");
	glDeleteTextures = cast(typeof(glDeleteTextures))load("glDeleteTextures");
	glDepthFunc = cast(typeof(glDepthFunc))load("glDepthFunc");
	glDepthMask = cast(typeof(glDepthMask))load("glDepthMask");
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef");
	glDetachShader = cast(typeof(glDetachShader))load("glDetachShader");
	glDisable = cast(typeof(glDisable))load("glDisable");
	glDisableVertexAttribArray = cast(typeof(glDisableVertexAttribArray))load("glDisableVertexAttribArray");
	glDrawArrays = cast(typeof(glDrawArrays))load("glDrawArrays");
	glDrawElements = cast(typeof(glDrawElements))load("glDrawElements");
	glEnable = cast(typeof(glEnable))load("glEnable");
	glEnableVertexAttribArray = cast(typeof(glEnableVertexAttribArray))load("glEnableVertexAttribArray");
	glFinish = cast(typeof(glFinish))load("glFinish");
	glFlush = cast(typeof(glFlush))load("glFlush");
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer");
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D");
	glFrontFace = cast(typeof(glFrontFace))load("glFrontFace");
	glGenBuffers = cast(typeof(glGenBuffers))load("glGenBuffers");
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap");
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers");
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers");
	glGenTextures = cast(typeof(glGenTextures))load("glGenTextures");
	glGetActiveAttrib = cast(typeof(glGetActiveAttrib))load("glGetActiveAttrib");
	glGetActiveUniform = cast(typeof(glGetActiveUniform))load("glGetActiveUniform");
	glGetAttachedShaders = cast(typeof(glGetAttachedShaders))load("glGetAttachedShaders");
	glGetAttribLocation = cast(typeof(glGetAttribLocation))load("glGetAttribLocation");
	glGetBooleanv = cast(typeof(glGetBooleanv))load("glGetBooleanv");
	glGetBufferParameteriv = cast(typeof(glGetBufferParameteriv))load("glGetBufferParameteriv");
	glGetError = cast(typeof(glGetError))load("glGetError");
	glGetFloatv = cast(typeof(glGetFloatv))load("glGetFloatv");
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv");
	glGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv");
	glGetProgramiv = cast(typeof(glGetProgramiv))load("glGetProgramiv");
	glGetProgramInfoLog = cast(typeof(glGetProgramInfoLog))load("glGetProgramInfoLog");
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv");
	glGetShaderiv = cast(typeof(glGetShaderiv))load("glGetShaderiv");
	glGetShaderInfoLog = cast(typeof(glGetShaderInfoLog))load("glGetShaderInfoLog");
	glGetShaderPrecisionFormat = cast(typeof(glGetShaderPrecisionFormat))load("glGetShaderPrecisionFormat");
	glGetShaderSource = cast(typeof(glGetShaderSource))load("glGetShaderSource");
	glGetString = cast(typeof(glGetString))load("glGetString");
	glGetTexParameterfv = cast(typeof(glGetTexParameterfv))load("glGetTexParameterfv");
	glGetTexParameteriv = cast(typeof(glGetTexParameteriv))load("glGetTexParameteriv");
	glGetUniformfv = cast(typeof(glGetUniformfv))load("glGetUniformfv");
	glGetUniformiv = cast(typeof(glGetUniformiv))load("glGetUniformiv");
	glGetUniformLocation = cast(typeof(glGetUniformLocation))load("glGetUniformLocation");
	glGetVertexAttribfv = cast(typeof(glGetVertexAttribfv))load("glGetVertexAttribfv");
	glGetVertexAttribiv = cast(typeof(glGetVertexAttribiv))load("glGetVertexAttribiv");
	glGetVertexAttribPointerv = cast(typeof(glGetVertexAttribPointerv))load("glGetVertexAttribPointerv");
	glHint = cast(typeof(glHint))load("glHint");
	glIsBuffer = cast(typeof(glIsBuffer))load("glIsBuffer");
	glIsEnabled = cast(typeof(glIsEnabled))load("glIsEnabled");
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer");
	glIsProgram = cast(typeof(glIsProgram))load("glIsProgram");
	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer");
	glIsShader = cast(typeof(glIsShader))load("glIsShader");
	glIsTexture = cast(typeof(glIsTexture))load("glIsTexture");
	glLineWidth = cast(typeof(glLineWidth))load("glLineWidth");
	glLinkProgram = cast(typeof(glLinkProgram))load("glLinkProgram");
	glPixelStorei = cast(typeof(glPixelStorei))load("glPixelStorei");
	glPolygonOffset = cast(typeof(glPolygonOffset))load("glPolygonOffset");
	glReadPixels = cast(typeof(glReadPixels))load("glReadPixels");
	glReleaseShaderCompiler = cast(typeof(glReleaseShaderCompiler))load("glReleaseShaderCompiler");
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage");
	glSampleCoverage = cast(typeof(glSampleCoverage))load("glSampleCoverage");
	glScissor = cast(typeof(glScissor))load("glScissor");
	glShaderBinary = cast(typeof(glShaderBinary))load("glShaderBinary");
	glShaderSource = cast(typeof(glShaderSource))load("glShaderSource");
	glStencilFunc = cast(typeof(glStencilFunc))load("glStencilFunc");
	glStencilFuncSeparate = cast(typeof(glStencilFuncSeparate))load("glStencilFuncSeparate");
	glStencilMask = cast(typeof(glStencilMask))load("glStencilMask");
	glStencilMaskSeparate = cast(typeof(glStencilMaskSeparate))load("glStencilMaskSeparate");
	glStencilOp = cast(typeof(glStencilOp))load("glStencilOp");
	glStencilOpSeparate = cast(typeof(glStencilOpSeparate))load("glStencilOpSeparate");
	glTexImage2D = cast(typeof(glTexImage2D))load("glTexImage2D");
	glTexParameterf = cast(typeof(glTexParameterf))load("glTexParameterf");
	glTexParameterfv = cast(typeof(glTexParameterfv))load("glTexParameterfv");
	glTexParameteri = cast(typeof(glTexParameteri))load("glTexParameteri");
	glTexParameteriv = cast(typeof(glTexParameteriv))load("glTexParameteriv");
	glTexSubImage2D = cast(typeof(glTexSubImage2D))load("glTexSubImage2D");
	glUniform1f = cast(typeof(glUniform1f))load("glUniform1f");
	glUniform1fv = cast(typeof(glUniform1fv))load("glUniform1fv");
	glUniform1i = cast(typeof(glUniform1i))load("glUniform1i");
	glUniform1iv = cast(typeof(glUniform1iv))load("glUniform1iv");
	glUniform2f = cast(typeof(glUniform2f))load("glUniform2f");
	glUniform2fv = cast(typeof(glUniform2fv))load("glUniform2fv");
	glUniform2i = cast(typeof(glUniform2i))load("glUniform2i");
	glUniform2iv = cast(typeof(glUniform2iv))load("glUniform2iv");
	glUniform3f = cast(typeof(glUniform3f))load("glUniform3f");
	glUniform3fv = cast(typeof(glUniform3fv))load("glUniform3fv");
	glUniform3i = cast(typeof(glUniform3i))load("glUniform3i");
	glUniform3iv = cast(typeof(glUniform3iv))load("glUniform3iv");
	glUniform4f = cast(typeof(glUniform4f))load("glUniform4f");
	glUniform4fv = cast(typeof(glUniform4fv))load("glUniform4fv");
	glUniform4i = cast(typeof(glUniform4i))load("glUniform4i");
	glUniform4iv = cast(typeof(glUniform4iv))load("glUniform4iv");
	glUniformMatrix2fv = cast(typeof(glUniformMatrix2fv))load("glUniformMatrix2fv");
	glUniformMatrix3fv = cast(typeof(glUniformMatrix3fv))load("glUniformMatrix3fv");
	glUniformMatrix4fv = cast(typeof(glUniformMatrix4fv))load("glUniformMatrix4fv");
	glUseProgram = cast(typeof(glUseProgram))load("glUseProgram");
	glValidateProgram = cast(typeof(glValidateProgram))load("glValidateProgram");
	glVertexAttrib1f = cast(typeof(glVertexAttrib1f))load("glVertexAttrib1f");
	glVertexAttrib1fv = cast(typeof(glVertexAttrib1fv))load("glVertexAttrib1fv");
	glVertexAttrib2f = cast(typeof(glVertexAttrib2f))load("glVertexAttrib2f");
	glVertexAttrib2fv = cast(typeof(glVertexAttrib2fv))load("glVertexAttrib2fv");
	glVertexAttrib3f = cast(typeof(glVertexAttrib3f))load("glVertexAttrib3f");
	glVertexAttrib3fv = cast(typeof(glVertexAttrib3fv))load("glVertexAttrib3fv");
	glVertexAttrib4f = cast(typeof(glVertexAttrib4f))load("glVertexAttrib4f");
	glVertexAttrib4fv = cast(typeof(glVertexAttrib4fv))load("glVertexAttrib4fv");
	glVertexAttribPointer = cast(typeof(glVertexAttribPointer))load("glVertexAttribPointer");
	glViewport = cast(typeof(glViewport))load("glViewport");
	return;
}

void load_GL_ES_VERSION_3_0(Loader load) {
	if(!GL_ES_VERSION_3_0) return;
	glReadBuffer = cast(typeof(glReadBuffer))load("glReadBuffer");
	glDrawRangeElements = cast(typeof(glDrawRangeElements))load("glDrawRangeElements");
	glTexImage3D = cast(typeof(glTexImage3D))load("glTexImage3D");
	glTexSubImage3D = cast(typeof(glTexSubImage3D))load("glTexSubImage3D");
	glCopyTexSubImage3D = cast(typeof(glCopyTexSubImage3D))load("glCopyTexSubImage3D");
	glCompressedTexImage3D = cast(typeof(glCompressedTexImage3D))load("glCompressedTexImage3D");
	glCompressedTexSubImage3D = cast(typeof(glCompressedTexSubImage3D))load("glCompressedTexSubImage3D");
	glGenQueries = cast(typeof(glGenQueries))load("glGenQueries");
	glDeleteQueries = cast(typeof(glDeleteQueries))load("glDeleteQueries");
	glIsQuery = cast(typeof(glIsQuery))load("glIsQuery");
	glBeginQuery = cast(typeof(glBeginQuery))load("glBeginQuery");
	glEndQuery = cast(typeof(glEndQuery))load("glEndQuery");
	glGetQueryiv = cast(typeof(glGetQueryiv))load("glGetQueryiv");
	glGetQueryObjectuiv = cast(typeof(glGetQueryObjectuiv))load("glGetQueryObjectuiv");
	glUnmapBuffer = cast(typeof(glUnmapBuffer))load("glUnmapBuffer");
	glGetBufferPointerv = cast(typeof(glGetBufferPointerv))load("glGetBufferPointerv");
	glDrawBuffers = cast(typeof(glDrawBuffers))load("glDrawBuffers");
	glUniformMatrix2x3fv = cast(typeof(glUniformMatrix2x3fv))load("glUniformMatrix2x3fv");
	glUniformMatrix3x2fv = cast(typeof(glUniformMatrix3x2fv))load("glUniformMatrix3x2fv");
	glUniformMatrix2x4fv = cast(typeof(glUniformMatrix2x4fv))load("glUniformMatrix2x4fv");
	glUniformMatrix4x2fv = cast(typeof(glUniformMatrix4x2fv))load("glUniformMatrix4x2fv");
	glUniformMatrix3x4fv = cast(typeof(glUniformMatrix3x4fv))load("glUniformMatrix3x4fv");
	glUniformMatrix4x3fv = cast(typeof(glUniformMatrix4x3fv))load("glUniformMatrix4x3fv");
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer");
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample");
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer");
	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange");
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange");
	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray");
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays");
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays");
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray");
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v");
	glBeginTransformFeedback = cast(typeof(glBeginTransformFeedback))load("glBeginTransformFeedback");
	glEndTransformFeedback = cast(typeof(glEndTransformFeedback))load("glEndTransformFeedback");
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange");
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase");
	glTransformFeedbackVaryings = cast(typeof(glTransformFeedbackVaryings))load("glTransformFeedbackVaryings");
	glGetTransformFeedbackVarying = cast(typeof(glGetTransformFeedbackVarying))load("glGetTransformFeedbackVarying");
	glVertexAttribIPointer = cast(typeof(glVertexAttribIPointer))load("glVertexAttribIPointer");
	glGetVertexAttribIiv = cast(typeof(glGetVertexAttribIiv))load("glGetVertexAttribIiv");
	glGetVertexAttribIuiv = cast(typeof(glGetVertexAttribIuiv))load("glGetVertexAttribIuiv");
	glVertexAttribI4i = cast(typeof(glVertexAttribI4i))load("glVertexAttribI4i");
	glVertexAttribI4ui = cast(typeof(glVertexAttribI4ui))load("glVertexAttribI4ui");
	glVertexAttribI4iv = cast(typeof(glVertexAttribI4iv))load("glVertexAttribI4iv");
	glVertexAttribI4uiv = cast(typeof(glVertexAttribI4uiv))load("glVertexAttribI4uiv");
	glGetUniformuiv = cast(typeof(glGetUniformuiv))load("glGetUniformuiv");
	glGetFragDataLocation = cast(typeof(glGetFragDataLocation))load("glGetFragDataLocation");
	glUniform1ui = cast(typeof(glUniform1ui))load("glUniform1ui");
	glUniform2ui = cast(typeof(glUniform2ui))load("glUniform2ui");
	glUniform3ui = cast(typeof(glUniform3ui))load("glUniform3ui");
	glUniform4ui = cast(typeof(glUniform4ui))load("glUniform4ui");
	glUniform1uiv = cast(typeof(glUniform1uiv))load("glUniform1uiv");
	glUniform2uiv = cast(typeof(glUniform2uiv))load("glUniform2uiv");
	glUniform3uiv = cast(typeof(glUniform3uiv))load("glUniform3uiv");
	glUniform4uiv = cast(typeof(glUniform4uiv))load("glUniform4uiv");
	glClearBufferiv = cast(typeof(glClearBufferiv))load("glClearBufferiv");
	glClearBufferuiv = cast(typeof(glClearBufferuiv))load("glClearBufferuiv");
	glClearBufferfv = cast(typeof(glClearBufferfv))load("glClearBufferfv");
	glClearBufferfi = cast(typeof(glClearBufferfi))load("glClearBufferfi");
	glGetStringi = cast(typeof(glGetStringi))load("glGetStringi");
	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData");
	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices");
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv");
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex");
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv");
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName");
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding");
	glDrawArraysInstanced = cast(typeof(glDrawArraysInstanced))load("glDrawArraysInstanced");
	glDrawElementsInstanced = cast(typeof(glDrawElementsInstanced))load("glDrawElementsInstanced");
	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync");
	glIsSync = cast(typeof(glIsSync))load("glIsSync");
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync");
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync");
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync");
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v");
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv");
	glGetInteger64i_v = cast(typeof(glGetInteger64i_v))load("glGetInteger64i_v");
	glGetBufferParameteri64v = cast(typeof(glGetBufferParameteri64v))load("glGetBufferParameteri64v");
	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers");
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers");
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler");
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler");
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri");
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv");
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf");
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv");
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv");
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv");
	glVertexAttribDivisor = cast(typeof(glVertexAttribDivisor))load("glVertexAttribDivisor");
	glBindTransformFeedback = cast(typeof(glBindTransformFeedback))load("glBindTransformFeedback");
	glDeleteTransformFeedbacks = cast(typeof(glDeleteTransformFeedbacks))load("glDeleteTransformFeedbacks");
	glGenTransformFeedbacks = cast(typeof(glGenTransformFeedbacks))load("glGenTransformFeedbacks");
	glIsTransformFeedback = cast(typeof(glIsTransformFeedback))load("glIsTransformFeedback");
	glPauseTransformFeedback = cast(typeof(glPauseTransformFeedback))load("glPauseTransformFeedback");
	glResumeTransformFeedback = cast(typeof(glResumeTransformFeedback))load("glResumeTransformFeedback");
	glGetProgramBinary = cast(typeof(glGetProgramBinary))load("glGetProgramBinary");
	glProgramBinary = cast(typeof(glProgramBinary))load("glProgramBinary");
	glProgramParameteri = cast(typeof(glProgramParameteri))load("glProgramParameteri");
	glInvalidateFramebuffer = cast(typeof(glInvalidateFramebuffer))load("glInvalidateFramebuffer");
	glInvalidateSubFramebuffer = cast(typeof(glInvalidateSubFramebuffer))load("glInvalidateSubFramebuffer");
	glTexStorage2D = cast(typeof(glTexStorage2D))load("glTexStorage2D");
	glTexStorage3D = cast(typeof(glTexStorage3D))load("glTexStorage3D");
	glGetInternalformativ = cast(typeof(glGetInternalformativ))load("glGetInternalformativ");
	return;
}

void load_GL_ES_VERSION_3_1(Loader load) {
	if(!GL_ES_VERSION_3_1) return;
	glDispatchCompute = cast(typeof(glDispatchCompute))load("glDispatchCompute");
	glDispatchComputeIndirect = cast(typeof(glDispatchComputeIndirect))load("glDispatchComputeIndirect");
	glDrawArraysIndirect = cast(typeof(glDrawArraysIndirect))load("glDrawArraysIndirect");
	glDrawElementsIndirect = cast(typeof(glDrawElementsIndirect))load("glDrawElementsIndirect");
	glFramebufferParameteri = cast(typeof(glFramebufferParameteri))load("glFramebufferParameteri");
	glGetFramebufferParameteriv = cast(typeof(glGetFramebufferParameteriv))load("glGetFramebufferParameteriv");
	glGetProgramInterfaceiv = cast(typeof(glGetProgramInterfaceiv))load("glGetProgramInterfaceiv");
	glGetProgramResourceIndex = cast(typeof(glGetProgramResourceIndex))load("glGetProgramResourceIndex");
	glGetProgramResourceName = cast(typeof(glGetProgramResourceName))load("glGetProgramResourceName");
	glGetProgramResourceiv = cast(typeof(glGetProgramResourceiv))load("glGetProgramResourceiv");
	glGetProgramResourceLocation = cast(typeof(glGetProgramResourceLocation))load("glGetProgramResourceLocation");
	glUseProgramStages = cast(typeof(glUseProgramStages))load("glUseProgramStages");
	glActiveShaderProgram = cast(typeof(glActiveShaderProgram))load("glActiveShaderProgram");
	glCreateShaderProgramv = cast(typeof(glCreateShaderProgramv))load("glCreateShaderProgramv");
	glBindProgramPipeline = cast(typeof(glBindProgramPipeline))load("glBindProgramPipeline");
	glDeleteProgramPipelines = cast(typeof(glDeleteProgramPipelines))load("glDeleteProgramPipelines");
	glGenProgramPipelines = cast(typeof(glGenProgramPipelines))load("glGenProgramPipelines");
	glIsProgramPipeline = cast(typeof(glIsProgramPipeline))load("glIsProgramPipeline");
	glGetProgramPipelineiv = cast(typeof(glGetProgramPipelineiv))load("glGetProgramPipelineiv");
	glProgramUniform1i = cast(typeof(glProgramUniform1i))load("glProgramUniform1i");
	glProgramUniform2i = cast(typeof(glProgramUniform2i))load("glProgramUniform2i");
	glProgramUniform3i = cast(typeof(glProgramUniform3i))load("glProgramUniform3i");
	glProgramUniform4i = cast(typeof(glProgramUniform4i))load("glProgramUniform4i");
	glProgramUniform1ui = cast(typeof(glProgramUniform1ui))load("glProgramUniform1ui");
	glProgramUniform2ui = cast(typeof(glProgramUniform2ui))load("glProgramUniform2ui");
	glProgramUniform3ui = cast(typeof(glProgramUniform3ui))load("glProgramUniform3ui");
	glProgramUniform4ui = cast(typeof(glProgramUniform4ui))load("glProgramUniform4ui");
	glProgramUniform1f = cast(typeof(glProgramUniform1f))load("glProgramUniform1f");
	glProgramUniform2f = cast(typeof(glProgramUniform2f))load("glProgramUniform2f");
	glProgramUniform3f = cast(typeof(glProgramUniform3f))load("glProgramUniform3f");
	glProgramUniform4f = cast(typeof(glProgramUniform4f))load("glProgramUniform4f");
	glProgramUniform1iv = cast(typeof(glProgramUniform1iv))load("glProgramUniform1iv");
	glProgramUniform2iv = cast(typeof(glProgramUniform2iv))load("glProgramUniform2iv");
	glProgramUniform3iv = cast(typeof(glProgramUniform3iv))load("glProgramUniform3iv");
	glProgramUniform4iv = cast(typeof(glProgramUniform4iv))load("glProgramUniform4iv");
	glProgramUniform1uiv = cast(typeof(glProgramUniform1uiv))load("glProgramUniform1uiv");
	glProgramUniform2uiv = cast(typeof(glProgramUniform2uiv))load("glProgramUniform2uiv");
	glProgramUniform3uiv = cast(typeof(glProgramUniform3uiv))load("glProgramUniform3uiv");
	glProgramUniform4uiv = cast(typeof(glProgramUniform4uiv))load("glProgramUniform4uiv");
	glProgramUniform1fv = cast(typeof(glProgramUniform1fv))load("glProgramUniform1fv");
	glProgramUniform2fv = cast(typeof(glProgramUniform2fv))load("glProgramUniform2fv");
	glProgramUniform3fv = cast(typeof(glProgramUniform3fv))load("glProgramUniform3fv");
	glProgramUniform4fv = cast(typeof(glProgramUniform4fv))load("glProgramUniform4fv");
	glProgramUniformMatrix2fv = cast(typeof(glProgramUniformMatrix2fv))load("glProgramUniformMatrix2fv");
	glProgramUniformMatrix3fv = cast(typeof(glProgramUniformMatrix3fv))load("glProgramUniformMatrix3fv");
	glProgramUniformMatrix4fv = cast(typeof(glProgramUniformMatrix4fv))load("glProgramUniformMatrix4fv");
	glProgramUniformMatrix2x3fv = cast(typeof(glProgramUniformMatrix2x3fv))load("glProgramUniformMatrix2x3fv");
	glProgramUniformMatrix3x2fv = cast(typeof(glProgramUniformMatrix3x2fv))load("glProgramUniformMatrix3x2fv");
	glProgramUniformMatrix2x4fv = cast(typeof(glProgramUniformMatrix2x4fv))load("glProgramUniformMatrix2x4fv");
	glProgramUniformMatrix4x2fv = cast(typeof(glProgramUniformMatrix4x2fv))load("glProgramUniformMatrix4x2fv");
	glProgramUniformMatrix3x4fv = cast(typeof(glProgramUniformMatrix3x4fv))load("glProgramUniformMatrix3x4fv");
	glProgramUniformMatrix4x3fv = cast(typeof(glProgramUniformMatrix4x3fv))load("glProgramUniformMatrix4x3fv");
	glValidateProgramPipeline = cast(typeof(glValidateProgramPipeline))load("glValidateProgramPipeline");
	glGetProgramPipelineInfoLog = cast(typeof(glGetProgramPipelineInfoLog))load("glGetProgramPipelineInfoLog");
	glBindImageTexture = cast(typeof(glBindImageTexture))load("glBindImageTexture");
	glGetBooleani_v = cast(typeof(glGetBooleani_v))load("glGetBooleani_v");
	glMemoryBarrier = cast(typeof(glMemoryBarrier))load("glMemoryBarrier");
	glMemoryBarrierByRegion = cast(typeof(glMemoryBarrierByRegion))load("glMemoryBarrierByRegion");
	glTexStorage2DMultisample = cast(typeof(glTexStorage2DMultisample))load("glTexStorage2DMultisample");
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv");
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski");
	glGetTexLevelParameteriv = cast(typeof(glGetTexLevelParameteriv))load("glGetTexLevelParameteriv");
	glGetTexLevelParameterfv = cast(typeof(glGetTexLevelParameterfv))load("glGetTexLevelParameterfv");
	glBindVertexBuffer = cast(typeof(glBindVertexBuffer))load("glBindVertexBuffer");
	glVertexAttribFormat = cast(typeof(glVertexAttribFormat))load("glVertexAttribFormat");
	glVertexAttribIFormat = cast(typeof(glVertexAttribIFormat))load("glVertexAttribIFormat");
	glVertexAttribBinding = cast(typeof(glVertexAttribBinding))load("glVertexAttribBinding");
	glVertexBindingDivisor = cast(typeof(glVertexBindingDivisor))load("glVertexBindingDivisor");
	return;
}

void load_GL_NV_non_square_matrices(Loader load) {
	if(!GL_NV_non_square_matrices) return;
	glUniformMatrix2x3fvNV = cast(typeof(glUniformMatrix2x3fvNV))load("glUniformMatrix2x3fvNV");
	glUniformMatrix3x2fvNV = cast(typeof(glUniformMatrix3x2fvNV))load("glUniformMatrix3x2fvNV");
	glUniformMatrix2x4fvNV = cast(typeof(glUniformMatrix2x4fvNV))load("glUniformMatrix2x4fvNV");
	glUniformMatrix4x2fvNV = cast(typeof(glUniformMatrix4x2fvNV))load("glUniformMatrix4x2fvNV");
	glUniformMatrix3x4fvNV = cast(typeof(glUniformMatrix3x4fvNV))load("glUniformMatrix3x4fvNV");
	glUniformMatrix4x3fvNV = cast(typeof(glUniformMatrix4x3fvNV))load("glUniformMatrix4x3fvNV");
	return;
}
void load_GL_EXT_sparse_texture(Loader load) {
	if(!GL_EXT_sparse_texture) return;
	glTexPageCommitmentARB = cast(typeof(glTexPageCommitmentARB))load("glTexPageCommitmentARB");
	return;
}
void load_GL_NV_draw_instanced(Loader load) {
	if(!GL_NV_draw_instanced) return;
	glDrawArraysInstancedNV = cast(typeof(glDrawArraysInstancedNV))load("glDrawArraysInstancedNV");
	glDrawElementsInstancedNV = cast(typeof(glDrawElementsInstancedNV))load("glDrawElementsInstancedNV");
	return;
}
void load_GL_EXT_base_instance(Loader load) {
	if(!GL_EXT_base_instance) return;
	glDrawArraysInstancedBaseInstanceEXT = cast(typeof(glDrawArraysInstancedBaseInstanceEXT))load("glDrawArraysInstancedBaseInstanceEXT");
	glDrawElementsInstancedBaseInstanceEXT = cast(typeof(glDrawElementsInstancedBaseInstanceEXT))load("glDrawElementsInstancedBaseInstanceEXT");
	glDrawElementsInstancedBaseVertexBaseInstanceEXT = cast(typeof(glDrawElementsInstancedBaseVertexBaseInstanceEXT))load("glDrawElementsInstancedBaseVertexBaseInstanceEXT");
	return;
}
void load_GL_EXT_instanced_arrays(Loader load) {
	if(!GL_EXT_instanced_arrays) return;
	glDrawArraysInstancedEXT = cast(typeof(glDrawArraysInstancedEXT))load("glDrawArraysInstancedEXT");
	glDrawElementsInstancedEXT = cast(typeof(glDrawElementsInstancedEXT))load("glDrawElementsInstancedEXT");
	glVertexAttribDivisorEXT = cast(typeof(glVertexAttribDivisorEXT))load("glVertexAttribDivisorEXT");
	return;
}
void load_GL_EXT_draw_buffers_indexed(Loader load) {
	if(!GL_EXT_draw_buffers_indexed) return;
	glEnableiEXT = cast(typeof(glEnableiEXT))load("glEnableiEXT");
	glDisableiEXT = cast(typeof(glDisableiEXT))load("glDisableiEXT");
	glBlendEquationiEXT = cast(typeof(glBlendEquationiEXT))load("glBlendEquationiEXT");
	glBlendEquationSeparateiEXT = cast(typeof(glBlendEquationSeparateiEXT))load("glBlendEquationSeparateiEXT");
	glBlendFunciEXT = cast(typeof(glBlendFunciEXT))load("glBlendFunciEXT");
	glBlendFuncSeparateiEXT = cast(typeof(glBlendFuncSeparateiEXT))load("glBlendFuncSeparateiEXT");
	glColorMaskiEXT = cast(typeof(glColorMaskiEXT))load("glColorMaskiEXT");
	glIsEnablediEXT = cast(typeof(glIsEnablediEXT))load("glIsEnablediEXT");
	return;
}
void load_GL_ANGLE_translated_shader_source(Loader load) {
	if(!GL_ANGLE_translated_shader_source) return;
	glGetTranslatedShaderSourceANGLE = cast(typeof(glGetTranslatedShaderSourceANGLE))load("glGetTranslatedShaderSourceANGLE");
	return;
}
void load_GL_NV_coverage_sample(Loader load) {
	if(!GL_NV_coverage_sample) return;
	glCoverageMaskNV = cast(typeof(glCoverageMaskNV))load("glCoverageMaskNV");
	glCoverageOperationNV = cast(typeof(glCoverageOperationNV))load("glCoverageOperationNV");
	return;
}
void load_GL_ANGLE_framebuffer_multisample(Loader load) {
	if(!GL_ANGLE_framebuffer_multisample) return;
	glRenderbufferStorageMultisampleANGLE = cast(typeof(glRenderbufferStorageMultisampleANGLE))load("glRenderbufferStorageMultisampleANGLE");
	return;
}
void load_GL_OES_vertex_array_object(Loader load) {
	if(!GL_OES_vertex_array_object) return;
	glBindVertexArrayOES = cast(typeof(glBindVertexArrayOES))load("glBindVertexArrayOES");
	glDeleteVertexArraysOES = cast(typeof(glDeleteVertexArraysOES))load("glDeleteVertexArraysOES");
	glGenVertexArraysOES = cast(typeof(glGenVertexArraysOES))load("glGenVertexArraysOES");
	glIsVertexArrayOES = cast(typeof(glIsVertexArrayOES))load("glIsVertexArrayOES");
	return;
}
void load_GL_QCOM_tiled_rendering(Loader load) {
	if(!GL_QCOM_tiled_rendering) return;
	glStartTilingQCOM = cast(typeof(glStartTilingQCOM))load("glStartTilingQCOM");
	glEndTilingQCOM = cast(typeof(glEndTilingQCOM))load("glEndTilingQCOM");
	return;
}
void load_GL_EXT_robustness(Loader load) {
	if(!GL_EXT_robustness) return;
	glGetGraphicsResetStatusEXT = cast(typeof(glGetGraphicsResetStatusEXT))load("glGetGraphicsResetStatusEXT");
	glReadnPixelsEXT = cast(typeof(glReadnPixelsEXT))load("glReadnPixelsEXT");
	glGetnUniformfvEXT = cast(typeof(glGetnUniformfvEXT))load("glGetnUniformfvEXT");
	glGetnUniformivEXT = cast(typeof(glGetnUniformivEXT))load("glGetnUniformivEXT");
	return;
}
void load_GL_EXT_disjoint_timer_query(Loader load) {
	if(!GL_EXT_disjoint_timer_query) return;
	glGenQueriesEXT = cast(typeof(glGenQueriesEXT))load("glGenQueriesEXT");
	glDeleteQueriesEXT = cast(typeof(glDeleteQueriesEXT))load("glDeleteQueriesEXT");
	glIsQueryEXT = cast(typeof(glIsQueryEXT))load("glIsQueryEXT");
	glBeginQueryEXT = cast(typeof(glBeginQueryEXT))load("glBeginQueryEXT");
	glEndQueryEXT = cast(typeof(glEndQueryEXT))load("glEndQueryEXT");
	glQueryCounterEXT = cast(typeof(glQueryCounterEXT))load("glQueryCounterEXT");
	glGetQueryivEXT = cast(typeof(glGetQueryivEXT))load("glGetQueryivEXT");
	glGetQueryObjectivEXT = cast(typeof(glGetQueryObjectivEXT))load("glGetQueryObjectivEXT");
	glGetQueryObjectuivEXT = cast(typeof(glGetQueryObjectuivEXT))load("glGetQueryObjectuivEXT");
	glGetQueryObjecti64vEXT = cast(typeof(glGetQueryObjecti64vEXT))load("glGetQueryObjecti64vEXT");
	glGetQueryObjectui64vEXT = cast(typeof(glGetQueryObjectui64vEXT))load("glGetQueryObjectui64vEXT");
	return;
}
void load_GL_EXT_primitive_bounding_box(Loader load) {
	if(!GL_EXT_primitive_bounding_box) return;
	glPrimitiveBoundingBoxEXT = cast(typeof(glPrimitiveBoundingBoxEXT))load("glPrimitiveBoundingBoxEXT");
	return;
}
void load_GL_QCOM_driver_control(Loader load) {
	if(!GL_QCOM_driver_control) return;
	glGetDriverControlsQCOM = cast(typeof(glGetDriverControlsQCOM))load("glGetDriverControlsQCOM");
	glGetDriverControlStringQCOM = cast(typeof(glGetDriverControlStringQCOM))load("glGetDriverControlStringQCOM");
	glEnableDriverControlQCOM = cast(typeof(glEnableDriverControlQCOM))load("glEnableDriverControlQCOM");
	glDisableDriverControlQCOM = cast(typeof(glDisableDriverControlQCOM))load("glDisableDriverControlQCOM");
	return;
}
void load_GL_OES_geometry_shader(Loader load) {
	if(!GL_OES_geometry_shader) return;
	glFramebufferTextureOES = cast(typeof(glFramebufferTextureOES))load("glFramebufferTextureOES");
	return;
}
void load_GL_OES_tessellation_shader(Loader load) {
	if(!GL_OES_tessellation_shader) return;
	glPatchParameteriOES = cast(typeof(glPatchParameteriOES))load("glPatchParameteriOES");
	return;
}
void load_GL_OES_texture_view(Loader load) {
	if(!GL_OES_texture_view) return;
	glTextureViewOES = cast(typeof(glTextureViewOES))load("glTextureViewOES");
	return;
}
void load_GL_EXT_multisampled_render_to_texture(Loader load) {
	if(!GL_EXT_multisampled_render_to_texture) return;
	glRenderbufferStorageMultisampleEXT = cast(typeof(glRenderbufferStorageMultisampleEXT))load("glRenderbufferStorageMultisampleEXT");
	glFramebufferTexture2DMultisampleEXT = cast(typeof(glFramebufferTexture2DMultisampleEXT))load("glFramebufferTexture2DMultisampleEXT");
	return;
}
void load_GL_EXT_buffer_storage(Loader load) {
	if(!GL_EXT_buffer_storage) return;
	glBufferStorageEXT = cast(typeof(glBufferStorageEXT))load("glBufferStorageEXT");
	return;
}
void load_GL_OES_texture_buffer(Loader load) {
	if(!GL_OES_texture_buffer) return;
	glTexBufferOES = cast(typeof(glTexBufferOES))load("glTexBufferOES");
	glTexBufferRangeOES = cast(typeof(glTexBufferRangeOES))load("glTexBufferRangeOES");
	return;
}
void load_GL_OES_get_program_binary(Loader load) {
	if(!GL_OES_get_program_binary) return;
	glGetProgramBinaryOES = cast(typeof(glGetProgramBinaryOES))load("glGetProgramBinaryOES");
	glProgramBinaryOES = cast(typeof(glProgramBinaryOES))load("glProgramBinaryOES");
	return;
}
void load_GL_APPLE_framebuffer_multisample(Loader load) {
	if(!GL_APPLE_framebuffer_multisample) return;
	glRenderbufferStorageMultisampleAPPLE = cast(typeof(glRenderbufferStorageMultisampleAPPLE))load("glRenderbufferStorageMultisampleAPPLE");
	glResolveMultisampleFramebufferAPPLE = cast(typeof(glResolveMultisampleFramebufferAPPLE))load("glResolveMultisampleFramebufferAPPLE");
	return;
}
void load_GL_NV_copy_buffer(Loader load) {
	if(!GL_NV_copy_buffer) return;
	glCopyBufferSubDataNV = cast(typeof(glCopyBufferSubDataNV))load("glCopyBufferSubDataNV");
	return;
}
void load_GL_EXT_texture_view(Loader load) {
	if(!GL_EXT_texture_view) return;
	glTextureViewEXT = cast(typeof(glTextureViewEXT))load("glTextureViewEXT");
	return;
}
void load_GL_NV_framebuffer_blit(Loader load) {
	if(!GL_NV_framebuffer_blit) return;
	glBlitFramebufferNV = cast(typeof(glBlitFramebufferNV))load("glBlitFramebufferNV");
	return;
}
void load_GL_QCOM_alpha_test(Loader load) {
	if(!GL_QCOM_alpha_test) return;
	glAlphaFuncQCOM = cast(typeof(glAlphaFuncQCOM))load("glAlphaFuncQCOM");
	return;
}
void load_GL_OES_texture_border_clamp(Loader load) {
	if(!GL_OES_texture_border_clamp) return;
	glTexParameterIivOES = cast(typeof(glTexParameterIivOES))load("glTexParameterIivOES");
	glTexParameterIuivOES = cast(typeof(glTexParameterIuivOES))load("glTexParameterIuivOES");
	glGetTexParameterIivOES = cast(typeof(glGetTexParameterIivOES))load("glGetTexParameterIivOES");
	glGetTexParameterIuivOES = cast(typeof(glGetTexParameterIuivOES))load("glGetTexParameterIuivOES");
	glSamplerParameterIivOES = cast(typeof(glSamplerParameterIivOES))load("glSamplerParameterIivOES");
	glSamplerParameterIuivOES = cast(typeof(glSamplerParameterIuivOES))load("glSamplerParameterIuivOES");
	glGetSamplerParameterIivOES = cast(typeof(glGetSamplerParameterIivOES))load("glGetSamplerParameterIivOES");
	glGetSamplerParameterIuivOES = cast(typeof(glGetSamplerParameterIuivOES))load("glGetSamplerParameterIuivOES");
	return;
}
void load_GL_EXT_occlusion_query_boolean(Loader load) {
	if(!GL_EXT_occlusion_query_boolean) return;
	glGenQueriesEXT = cast(typeof(glGenQueriesEXT))load("glGenQueriesEXT");
	glDeleteQueriesEXT = cast(typeof(glDeleteQueriesEXT))load("glDeleteQueriesEXT");
	glIsQueryEXT = cast(typeof(glIsQueryEXT))load("glIsQueryEXT");
	glBeginQueryEXT = cast(typeof(glBeginQueryEXT))load("glBeginQueryEXT");
	glEndQueryEXT = cast(typeof(glEndQueryEXT))load("glEndQueryEXT");
	glGetQueryivEXT = cast(typeof(glGetQueryivEXT))load("glGetQueryivEXT");
	glGetQueryObjectuivEXT = cast(typeof(glGetQueryObjectuivEXT))load("glGetQueryObjectuivEXT");
	return;
}
void load_GL_EXT_multi_draw_indirect(Loader load) {
	if(!GL_EXT_multi_draw_indirect) return;
	glMultiDrawArraysIndirectEXT = cast(typeof(glMultiDrawArraysIndirectEXT))load("glMultiDrawArraysIndirectEXT");
	glMultiDrawElementsIndirectEXT = cast(typeof(glMultiDrawElementsIndirectEXT))load("glMultiDrawElementsIndirectEXT");
	return;
}
void load_GL_APPLE_sync(Loader load) {
	if(!GL_APPLE_sync) return;
	glFenceSyncAPPLE = cast(typeof(glFenceSyncAPPLE))load("glFenceSyncAPPLE");
	glIsSyncAPPLE = cast(typeof(glIsSyncAPPLE))load("glIsSyncAPPLE");
	glDeleteSyncAPPLE = cast(typeof(glDeleteSyncAPPLE))load("glDeleteSyncAPPLE");
	glClientWaitSyncAPPLE = cast(typeof(glClientWaitSyncAPPLE))load("glClientWaitSyncAPPLE");
	glWaitSyncAPPLE = cast(typeof(glWaitSyncAPPLE))load("glWaitSyncAPPLE");
	glGetInteger64vAPPLE = cast(typeof(glGetInteger64vAPPLE))load("glGetInteger64vAPPLE");
	glGetSyncivAPPLE = cast(typeof(glGetSyncivAPPLE))load("glGetSyncivAPPLE");
	return;
}
void load_GL_OES_copy_image(Loader load) {
	if(!GL_OES_copy_image) return;
	glCopyImageSubDataOES = cast(typeof(glCopyImageSubDataOES))load("glCopyImageSubDataOES");
	return;
}
void load_GL_QCOM_extended_get2(Loader load) {
	if(!GL_QCOM_extended_get2) return;
	glExtGetShadersQCOM = cast(typeof(glExtGetShadersQCOM))load("glExtGetShadersQCOM");
	glExtGetProgramsQCOM = cast(typeof(glExtGetProgramsQCOM))load("glExtGetProgramsQCOM");
	glExtIsProgramBinaryQCOM = cast(typeof(glExtIsProgramBinaryQCOM))load("glExtIsProgramBinaryQCOM");
	glExtGetProgramBinarySourceQCOM = cast(typeof(glExtGetProgramBinarySourceQCOM))load("glExtGetProgramBinarySourceQCOM");
	return;
}
void load_GL_EXT_draw_elements_base_vertex(Loader load) {
	if(!GL_EXT_draw_elements_base_vertex) return;
	glDrawElementsBaseVertexEXT = cast(typeof(glDrawElementsBaseVertexEXT))load("glDrawElementsBaseVertexEXT");
	glDrawRangeElementsBaseVertexEXT = cast(typeof(glDrawRangeElementsBaseVertexEXT))load("glDrawRangeElementsBaseVertexEXT");
	glDrawElementsInstancedBaseVertexEXT = cast(typeof(glDrawElementsInstancedBaseVertexEXT))load("glDrawElementsInstancedBaseVertexEXT");
	glMultiDrawElementsBaseVertexEXT = cast(typeof(glMultiDrawElementsBaseVertexEXT))load("glMultiDrawElementsBaseVertexEXT");
	return;
}
void load_GL_NV_framebuffer_multisample(Loader load) {
	if(!GL_NV_framebuffer_multisample) return;
	glRenderbufferStorageMultisampleNV = cast(typeof(glRenderbufferStorageMultisampleNV))load("glRenderbufferStorageMultisampleNV");
	return;
}
void load_GL_OES_texture_storage_multisample_2d_array(Loader load) {
	if(!GL_OES_texture_storage_multisample_2d_array) return;
	glTexStorage3DMultisampleOES = cast(typeof(glTexStorage3DMultisampleOES))load("glTexStorage3DMultisampleOES");
	return;
}
void load_GL_OES_draw_buffers_indexed(Loader load) {
	if(!GL_OES_draw_buffers_indexed) return;
	glEnableiOES = cast(typeof(glEnableiOES))load("glEnableiOES");
	glDisableiOES = cast(typeof(glDisableiOES))load("glDisableiOES");
	glBlendEquationiOES = cast(typeof(glBlendEquationiOES))load("glBlendEquationiOES");
	glBlendEquationSeparateiOES = cast(typeof(glBlendEquationSeparateiOES))load("glBlendEquationSeparateiOES");
	glBlendFunciOES = cast(typeof(glBlendFunciOES))load("glBlendFunciOES");
	glBlendFuncSeparateiOES = cast(typeof(glBlendFuncSeparateiOES))load("glBlendFuncSeparateiOES");
	glColorMaskiOES = cast(typeof(glColorMaskiOES))load("glColorMaskiOES");
	glIsEnablediOES = cast(typeof(glIsEnablediOES))load("glIsEnablediOES");
	return;
}
void load_GL_OES_EGL_image(Loader load) {
	if(!GL_OES_EGL_image) return;
	glEGLImageTargetTexture2DOES = cast(typeof(glEGLImageTargetTexture2DOES))load("glEGLImageTargetTexture2DOES");
	glEGLImageTargetRenderbufferStorageOES = cast(typeof(glEGLImageTargetRenderbufferStorageOES))load("glEGLImageTargetRenderbufferStorageOES");
	return;
}
void load_GL_NV_draw_buffers(Loader load) {
	if(!GL_NV_draw_buffers) return;
	glDrawBuffersNV = cast(typeof(glDrawBuffersNV))load("glDrawBuffersNV");
	return;
}
void load_GL_EXT_draw_buffers(Loader load) {
	if(!GL_EXT_draw_buffers) return;
	glDrawBuffersEXT = cast(typeof(glDrawBuffersEXT))load("glDrawBuffersEXT");
	return;
}
void load_GL_NV_instanced_arrays(Loader load) {
	if(!GL_NV_instanced_arrays) return;
	glVertexAttribDivisorNV = cast(typeof(glVertexAttribDivisorNV))load("glVertexAttribDivisorNV");
	return;
}
void load_GL_EXT_texture_storage(Loader load) {
	if(!GL_EXT_texture_storage) return;
	glTexStorage1DEXT = cast(typeof(glTexStorage1DEXT))load("glTexStorage1DEXT");
	glTexStorage2DEXT = cast(typeof(glTexStorage2DEXT))load("glTexStorage2DEXT");
	glTexStorage3DEXT = cast(typeof(glTexStorage3DEXT))load("glTexStorage3DEXT");
	glTextureStorage1DEXT = cast(typeof(glTextureStorage1DEXT))load("glTextureStorage1DEXT");
	glTextureStorage2DEXT = cast(typeof(glTextureStorage2DEXT))load("glTextureStorage2DEXT");
	glTextureStorage3DEXT = cast(typeof(glTextureStorage3DEXT))load("glTextureStorage3DEXT");
	return;
}
void load_GL_EXT_copy_image(Loader load) {
	if(!GL_EXT_copy_image) return;
	glCopyImageSubDataEXT = cast(typeof(glCopyImageSubDataEXT))load("glCopyImageSubDataEXT");
	return;
}
void load_GL_OES_sample_shading(Loader load) {
	if(!GL_OES_sample_shading) return;
	glMinSampleShadingOES = cast(typeof(glMinSampleShadingOES))load("glMinSampleShadingOES");
	return;
}
void load_GL_NV_viewport_array(Loader load) {
	if(!GL_NV_viewport_array) return;
	glViewportArrayvNV = cast(typeof(glViewportArrayvNV))load("glViewportArrayvNV");
	glViewportIndexedfNV = cast(typeof(glViewportIndexedfNV))load("glViewportIndexedfNV");
	glViewportIndexedfvNV = cast(typeof(glViewportIndexedfvNV))load("glViewportIndexedfvNV");
	glScissorArrayvNV = cast(typeof(glScissorArrayvNV))load("glScissorArrayvNV");
	glScissorIndexedNV = cast(typeof(glScissorIndexedNV))load("glScissorIndexedNV");
	glScissorIndexedvNV = cast(typeof(glScissorIndexedvNV))load("glScissorIndexedvNV");
	glDepthRangeArrayfvNV = cast(typeof(glDepthRangeArrayfvNV))load("glDepthRangeArrayfvNV");
	glDepthRangeIndexedfNV = cast(typeof(glDepthRangeIndexedfNV))load("glDepthRangeIndexedfNV");
	glGetFloati_vNV = cast(typeof(glGetFloati_vNV))load("glGetFloati_vNV");
	glEnableiNV = cast(typeof(glEnableiNV))load("glEnableiNV");
	glDisableiNV = cast(typeof(glDisableiNV))load("glDisableiNV");
	glIsEnablediNV = cast(typeof(glIsEnablediNV))load("glIsEnablediNV");
	return;
}
void load_GL_EXT_map_buffer_range(Loader load) {
	if(!GL_EXT_map_buffer_range) return;
	glMapBufferRangeEXT = cast(typeof(glMapBufferRangeEXT))load("glMapBufferRangeEXT");
	glFlushMappedBufferRangeEXT = cast(typeof(glFlushMappedBufferRangeEXT))load("glFlushMappedBufferRangeEXT");
	return;
}
void load_GL_OES_mapbuffer(Loader load) {
	if(!GL_OES_mapbuffer) return;
	glMapBufferOES = cast(typeof(glMapBufferOES))load("glMapBufferOES");
	glUnmapBufferOES = cast(typeof(glUnmapBufferOES))load("glUnmapBufferOES");
	glGetBufferPointervOES = cast(typeof(glGetBufferPointervOES))load("glGetBufferPointervOES");
	return;
}
void load_GL_NV_polygon_mode(Loader load) {
	if(!GL_NV_polygon_mode) return;
	glPolygonModeNV = cast(typeof(glPolygonModeNV))load("glPolygonModeNV");
	return;
}
void load_GL_IMG_multisampled_render_to_texture(Loader load) {
	if(!GL_IMG_multisampled_render_to_texture) return;
	glRenderbufferStorageMultisampleIMG = cast(typeof(glRenderbufferStorageMultisampleIMG))load("glRenderbufferStorageMultisampleIMG");
	glFramebufferTexture2DMultisampleIMG = cast(typeof(glFramebufferTexture2DMultisampleIMG))load("glFramebufferTexture2DMultisampleIMG");
	return;
}
void load_GL_OES_draw_elements_base_vertex(Loader load) {
	if(!GL_OES_draw_elements_base_vertex) return;
	glDrawElementsBaseVertexOES = cast(typeof(glDrawElementsBaseVertexOES))load("glDrawElementsBaseVertexOES");
	glDrawRangeElementsBaseVertexOES = cast(typeof(glDrawRangeElementsBaseVertexOES))load("glDrawRangeElementsBaseVertexOES");
	glDrawElementsInstancedBaseVertexOES = cast(typeof(glDrawElementsInstancedBaseVertexOES))load("glDrawElementsInstancedBaseVertexOES");
	glMultiDrawElementsBaseVertexOES = cast(typeof(glMultiDrawElementsBaseVertexOES))load("glMultiDrawElementsBaseVertexOES");
	return;
}
void load_GL_APPLE_copy_texture_levels(Loader load) {
	if(!GL_APPLE_copy_texture_levels) return;
	glCopyTextureLevelsAPPLE = cast(typeof(glCopyTextureLevelsAPPLE))load("glCopyTextureLevelsAPPLE");
	return;
}
void load_GL_EXT_multiview_draw_buffers(Loader load) {
	if(!GL_EXT_multiview_draw_buffers) return;
	glReadBufferIndexedEXT = cast(typeof(glReadBufferIndexedEXT))load("glReadBufferIndexedEXT");
	glDrawBuffersIndexedEXT = cast(typeof(glDrawBuffersIndexedEXT))load("glDrawBuffersIndexedEXT");
	glGetIntegeri_vEXT = cast(typeof(glGetIntegeri_vEXT))load("glGetIntegeri_vEXT");
	return;
}
void load_GL_QCOM_extended_get(Loader load) {
	if(!GL_QCOM_extended_get) return;
	glExtGetTexturesQCOM = cast(typeof(glExtGetTexturesQCOM))load("glExtGetTexturesQCOM");
	glExtGetBuffersQCOM = cast(typeof(glExtGetBuffersQCOM))load("glExtGetBuffersQCOM");
	glExtGetRenderbuffersQCOM = cast(typeof(glExtGetRenderbuffersQCOM))load("glExtGetRenderbuffersQCOM");
	glExtGetFramebuffersQCOM = cast(typeof(glExtGetFramebuffersQCOM))load("glExtGetFramebuffersQCOM");
	glExtGetTexLevelParameterivQCOM = cast(typeof(glExtGetTexLevelParameterivQCOM))load("glExtGetTexLevelParameterivQCOM");
	glExtTexObjectStateOverrideiQCOM = cast(typeof(glExtTexObjectStateOverrideiQCOM))load("glExtTexObjectStateOverrideiQCOM");
	glExtGetTexSubImageQCOM = cast(typeof(glExtGetTexSubImageQCOM))load("glExtGetTexSubImageQCOM");
	glExtGetBufferPointervQCOM = cast(typeof(glExtGetBufferPointervQCOM))load("glExtGetBufferPointervQCOM");
	return;
}
void load_GL_EXT_geometry_shader(Loader load) {
	if(!GL_EXT_geometry_shader) return;
	glFramebufferTextureEXT = cast(typeof(glFramebufferTextureEXT))load("glFramebufferTextureEXT");
	return;
}
void load_GL_EXT_texture_border_clamp(Loader load) {
	if(!GL_EXT_texture_border_clamp) return;
	glTexParameterIivEXT = cast(typeof(glTexParameterIivEXT))load("glTexParameterIivEXT");
	glTexParameterIuivEXT = cast(typeof(glTexParameterIuivEXT))load("glTexParameterIuivEXT");
	glGetTexParameterIivEXT = cast(typeof(glGetTexParameterIivEXT))load("glGetTexParameterIivEXT");
	glGetTexParameterIuivEXT = cast(typeof(glGetTexParameterIuivEXT))load("glGetTexParameterIuivEXT");
	glSamplerParameterIivEXT = cast(typeof(glSamplerParameterIivEXT))load("glSamplerParameterIivEXT");
	glSamplerParameterIuivEXT = cast(typeof(glSamplerParameterIuivEXT))load("glSamplerParameterIuivEXT");
	glGetSamplerParameterIivEXT = cast(typeof(glGetSamplerParameterIivEXT))load("glGetSamplerParameterIivEXT");
	glGetSamplerParameterIuivEXT = cast(typeof(glGetSamplerParameterIuivEXT))load("glGetSamplerParameterIuivEXT");
	return;
}
void load_GL_ANGLE_framebuffer_blit(Loader load) {
	if(!GL_ANGLE_framebuffer_blit) return;
	glBlitFramebufferANGLE = cast(typeof(glBlitFramebufferANGLE))load("glBlitFramebufferANGLE");
	return;
}
void load_GL_OES_texture_3D(Loader load) {
	if(!GL_OES_texture_3D) return;
	glTexImage3DOES = cast(typeof(glTexImage3DOES))load("glTexImage3DOES");
	glTexSubImage3DOES = cast(typeof(glTexSubImage3DOES))load("glTexSubImage3DOES");
	glCopyTexSubImage3DOES = cast(typeof(glCopyTexSubImage3DOES))load("glCopyTexSubImage3DOES");
	glCompressedTexImage3DOES = cast(typeof(glCompressedTexImage3DOES))load("glCompressedTexImage3DOES");
	glCompressedTexSubImage3DOES = cast(typeof(glCompressedTexSubImage3DOES))load("glCompressedTexSubImage3DOES");
	glFramebufferTexture3DOES = cast(typeof(glFramebufferTexture3DOES))load("glFramebufferTexture3DOES");
	return;
}
void load_GL_EXT_tessellation_shader(Loader load) {
	if(!GL_EXT_tessellation_shader) return;
	glPatchParameteriEXT = cast(typeof(glPatchParameteriEXT))load("glPatchParameteriEXT");
	return;
}
void load_GL_OES_primitive_bounding_box(Loader load) {
	if(!GL_OES_primitive_bounding_box) return;
	glPrimitiveBoundingBoxOES = cast(typeof(glPrimitiveBoundingBoxOES))load("glPrimitiveBoundingBoxOES");
	return;
}
void load_GL_NV_read_buffer(Loader load) {
	if(!GL_NV_read_buffer) return;
	glReadBufferNV = cast(typeof(glReadBufferNV))load("glReadBufferNV");
	return;
}
void load_GL_ANGLE_instanced_arrays(Loader load) {
	if(!GL_ANGLE_instanced_arrays) return;
	glDrawArraysInstancedANGLE = cast(typeof(glDrawArraysInstancedANGLE))load("glDrawArraysInstancedANGLE");
	glDrawElementsInstancedANGLE = cast(typeof(glDrawElementsInstancedANGLE))load("glDrawElementsInstancedANGLE");
	glVertexAttribDivisorANGLE = cast(typeof(glVertexAttribDivisorANGLE))load("glVertexAttribDivisorANGLE");
	return;
}
void load_GL_EXT_discard_framebuffer(Loader load) {
	if(!GL_EXT_discard_framebuffer) return;
	glDiscardFramebufferEXT = cast(typeof(glDiscardFramebufferEXT))load("glDiscardFramebufferEXT");
	return;
}
void load_GL_EXT_texture_buffer(Loader load) {
	if(!GL_EXT_texture_buffer) return;
	glTexBufferEXT = cast(typeof(glTexBufferEXT))load("glTexBufferEXT");
	glTexBufferRangeEXT = cast(typeof(glTexBufferRangeEXT))load("glTexBufferRangeEXT");
	return;
}
bool gladLoadGLES1(Loader load) {
	glGetString = cast(typeof(glGetString))load("glGetString");
	if(glGetString is null) { return false; }
	if(glGetString(GL_VERSION) is null) { return false; }

	find_coreGLES1();
	load_GL_VERSION_ES_CM_1_0(load);

	find_extensionsGLES1();
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_NV_fence(load);
	load_GL_OES_single_precision(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_OES_byte_coordinates(load);
	load_GL_OES_query_matrix(load);
	load_GL_OES_fixed_point(load);
	load_GL_NV_fence(load);
	load_GL_OES_vertex_array_object(load);
	load_GL_QCOM_tiled_rendering(load);
	load_GL_EXT_robustness(load);
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_QCOM_driver_control(load);
	load_GL_EXT_multisampled_render_to_texture(load);
	load_GL_APPLE_framebuffer_multisample(load);
	load_GL_APPLE_sync(load);
	load_GL_QCOM_extended_get2(load);
	load_GL_OES_EGL_image(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_EXT_texture_storage(load);
	load_GL_EXT_map_buffer_range(load);
	load_GL_OES_mapbuffer(load);
	load_GL_IMG_multisampled_render_to_texture(load);
	load_GL_APPLE_copy_texture_levels(load);
	load_GL_QCOM_extended_get(load);
	load_GL_EXT_discard_framebuffer(load);
	load_GL_EXT_multi_draw_arrays(load);
	load_GL_OES_single_precision(load);
	load_GL_OES_point_size_array(load);
	load_GL_OES_texture_cube_map(load);
	load_GL_IMG_user_clip_plane(load);
	load_GL_NV_fence(load);
	load_GL_EXT_map_buffer_range(load);
	load_GL_OES_blend_subtract(load);
	load_GL_QCOM_extended_get2(load);
	load_GL_EXT_multisampled_render_to_texture(load);
	load_GL_EXT_discard_framebuffer(load);
	load_GL_OES_fixed_point(load);
	load_GL_OES_matrix_palette(load);
	load_GL_OES_mapbuffer(load);
	load_GL_IMG_multisampled_render_to_texture(load);
	load_GL_APPLE_framebuffer_multisample(load);
	load_GL_APPLE_copy_texture_levels(load);
	load_GL_OES_EGL_image(load);
	load_GL_QCOM_extended_get(load);
	load_GL_OES_query_matrix(load);
	load_GL_QCOM_tiled_rendering(load);
	load_GL_OES_blend_equation_separate(load);
	load_GL_OES_framebuffer_object(load);
	load_GL_EXT_robustness(load);
	load_GL_OES_draw_texture(load);
	load_GL_OES_blend_func_separate(load);
	load_GL_OES_vertex_array_object(load);
	load_GL_EXT_blend_minmax(load);
	load_GL_OES_byte_coordinates(load);
	load_GL_APPLE_sync(load);
	load_GL_EXT_texture_storage(load);
	load_GL_QCOM_driver_control(load);
	return GLVersion.major != 0 || GLVersion.minor != 0;
}

private:

void find_coreGLES1() {

    // Thank you @elmindreda
    // https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
    // https://github.com/glfw/glfw/blob/master/src/context.c#L36
    int i;
    const(char)* glversion;
    const(char)*[] prefixes = [
        "OpenGL ES-CM ".ptr,
        "OpenGL ES-CL ".ptr,
        "OpenGL ES ".ptr,
    ];

    glversion = cast(const(char)*)glGetString(GL_VERSION);
    if (glversion is null) return;

    foreach(prefix; prefixes) {
        size_t length = strlen(prefix);
        if (strncmp(glversion, prefix, length) == 0) {
            glversion += length;
            break;
        }
    }

    int major = glversion[0] - '0';
    int minor = glversion[2] - '0';
    GLVersion.major = major; GLVersion.minor = minor;
	GL_VERSION_ES_CM_1_0 = (major == 1 && minor >= 0) || major > 1;
	return;
}

void find_extensionsGLES1() {
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_OES_single_precision = has_ext("GL_OES_single_precision");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_OES_byte_coordinates = has_ext("GL_OES_byte_coordinates");
	GL_OES_query_matrix = has_ext("GL_OES_query_matrix");
	GL_OES_read_format = has_ext("GL_OES_read_format");
	GL_EXT_texture_lod_bias = has_ext("GL_EXT_texture_lod_bias");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_OES_fixed_point = has_ext("GL_OES_fixed_point");
	GL_OES_packed_depth_stencil = has_ext("GL_OES_packed_depth_stencil");
	GL_QCOM_perfmon_global_mode = has_ext("GL_QCOM_perfmon_global_mode");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_IMG_texture_compression_pvrtc = has_ext("GL_IMG_texture_compression_pvrtc");
	GL_QCOM_writeonly_rendering = has_ext("GL_QCOM_writeonly_rendering");
	GL_OES_vertex_array_object = has_ext("GL_OES_vertex_array_object");
	GL_QCOM_tiled_rendering = has_ext("GL_QCOM_tiled_rendering");
	GL_EXT_robustness = has_ext("GL_EXT_robustness");
	GL_OES_fbo_render_mipmap = has_ext("GL_OES_fbo_render_mipmap");
	GL_OES_compressed_ETC1_RGB8_sub_texture = has_ext("GL_OES_compressed_ETC1_RGB8_sub_texture");
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_IMG_read_format = has_ext("GL_IMG_read_format");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_EXT_texture_compression_dxt1 = has_ext("GL_EXT_texture_compression_dxt1");
	GL_QCOM_driver_control = has_ext("GL_QCOM_driver_control");
	GL_EXT_multisampled_render_to_texture = has_ext("GL_EXT_multisampled_render_to_texture");
	GL_APPLE_framebuffer_multisample = has_ext("GL_APPLE_framebuffer_multisample");
	GL_OES_stencil4 = has_ext("GL_OES_stencil4");
	GL_OES_stencil1 = has_ext("GL_OES_stencil1");
	GL_EXT_sRGB = has_ext("GL_EXT_sRGB");
	GL_APPLE_sync = has_ext("GL_APPLE_sync");
	GL_EXT_read_format_bgra = has_ext("GL_EXT_read_format_bgra");
	GL_OES_compressed_ETC1_RGB8_texture = has_ext("GL_OES_compressed_ETC1_RGB8_texture");
	GL_QCOM_extended_get2 = has_ext("GL_QCOM_extended_get2");
	GL_OES_depth32 = has_ext("GL_OES_depth32");
	GL_APPLE_texture_max_level = has_ext("GL_APPLE_texture_max_level");
	GL_OES_EGL_image = has_ext("GL_OES_EGL_image");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_OES_depth24 = has_ext("GL_OES_depth24");
	GL_EXT_texture_storage = has_ext("GL_EXT_texture_storage");
	GL_OES_required_internalformat = has_ext("GL_OES_required_internalformat");
	GL_AMD_compressed_3DC_texture = has_ext("GL_AMD_compressed_3DC_texture");
	GL_OES_element_index_uint = has_ext("GL_OES_element_index_uint");
	GL_OES_rgb8_rgba8 = has_ext("GL_OES_rgb8_rgba8");
	GL_EXT_map_buffer_range = has_ext("GL_EXT_map_buffer_range");
	GL_OES_mapbuffer = has_ext("GL_OES_mapbuffer");
	GL_OES_EGL_image_external = has_ext("GL_OES_EGL_image_external");
	GL_APPLE_texture_format_BGRA8888 = has_ext("GL_APPLE_texture_format_BGRA8888");
	GL_IMG_multisampled_render_to_texture = has_ext("GL_IMG_multisampled_render_to_texture");
	GL_EXT_texture_format_BGRA8888 = has_ext("GL_EXT_texture_format_BGRA8888");
	GL_APPLE_copy_texture_levels = has_ext("GL_APPLE_copy_texture_levels");
	GL_QCOM_extended_get = has_ext("GL_QCOM_extended_get");
	GL_ARM_rgba8 = has_ext("GL_ARM_rgba8");
	GL_EXT_discard_framebuffer = has_ext("GL_EXT_discard_framebuffer");
	GL_AMD_compressed_ATC_texture = has_ext("GL_AMD_compressed_ATC_texture");
	GL_OES_texture_mirrored_repeat = has_ext("GL_OES_texture_mirrored_repeat");
	GL_EXT_multi_draw_arrays = has_ext("GL_EXT_multi_draw_arrays");
	GL_AMD_compressed_3DC_texture = has_ext("GL_AMD_compressed_3DC_texture");
	GL_EXT_texture_compression_dxt1 = has_ext("GL_EXT_texture_compression_dxt1");
	GL_OES_single_precision = has_ext("GL_OES_single_precision");
	GL_OES_point_size_array = has_ext("GL_OES_point_size_array");
	GL_OES_element_index_uint = has_ext("GL_OES_element_index_uint");
	GL_OES_texture_cube_map = has_ext("GL_OES_texture_cube_map");
	GL_IMG_user_clip_plane = has_ext("GL_IMG_user_clip_plane");
	GL_NV_fence = has_ext("GL_NV_fence");
	GL_EXT_map_buffer_range = has_ext("GL_EXT_map_buffer_range");
	GL_OES_blend_subtract = has_ext("GL_OES_blend_subtract");
	GL_EXT_read_format_bgra = has_ext("GL_EXT_read_format_bgra");
	GL_OES_read_format = has_ext("GL_OES_read_format");
	GL_OES_compressed_ETC1_RGB8_texture = has_ext("GL_OES_compressed_ETC1_RGB8_texture");
	GL_QCOM_extended_get2 = has_ext("GL_QCOM_extended_get2");
	GL_OES_EGL_image_external = has_ext("GL_OES_EGL_image_external");
	GL_OES_required_internalformat = has_ext("GL_OES_required_internalformat");
	GL_OES_extended_matrix_palette = has_ext("GL_OES_extended_matrix_palette");
	GL_APPLE_texture_max_level = has_ext("GL_APPLE_texture_max_level");
	GL_EXT_multisampled_render_to_texture = has_ext("GL_EXT_multisampled_render_to_texture");
	GL_QCOM_writeonly_rendering = has_ext("GL_QCOM_writeonly_rendering");
	GL_OES_packed_depth_stencil = has_ext("GL_OES_packed_depth_stencil");
	GL_IMG_texture_env_enhanced_fixed_function = has_ext("GL_IMG_texture_env_enhanced_fixed_function");
	GL_APPLE_texture_format_BGRA8888 = has_ext("GL_APPLE_texture_format_BGRA8888");
	GL_EXT_discard_framebuffer = has_ext("GL_EXT_discard_framebuffer");
	GL_OES_fixed_point = has_ext("GL_OES_fixed_point");
	GL_QCOM_perfmon_global_mode = has_ext("GL_QCOM_perfmon_global_mode");
	GL_OES_matrix_palette = has_ext("GL_OES_matrix_palette");
	GL_OES_mapbuffer = has_ext("GL_OES_mapbuffer");
	GL_IMG_multisampled_render_to_texture = has_ext("GL_IMG_multisampled_render_to_texture");
	GL_OES_depth32 = has_ext("GL_OES_depth32");
	GL_APPLE_framebuffer_multisample = has_ext("GL_APPLE_framebuffer_multisample");
	GL_APPLE_copy_texture_levels = has_ext("GL_APPLE_copy_texture_levels");
	GL_EXT_texture_format_BGRA8888 = has_ext("GL_EXT_texture_format_BGRA8888");
	GL_APPLE_texture_2D_limited_npot = has_ext("GL_APPLE_texture_2D_limited_npot");
	GL_OES_EGL_image = has_ext("GL_OES_EGL_image");
	GL_QCOM_extended_get = has_ext("GL_QCOM_extended_get");
	GL_OES_query_matrix = has_ext("GL_OES_query_matrix");
	GL_OES_point_sprite = has_ext("GL_OES_point_sprite");
	GL_QCOM_tiled_rendering = has_ext("GL_QCOM_tiled_rendering");
	GL_OES_stencil8 = has_ext("GL_OES_stencil8");
	GL_OES_blend_equation_separate = has_ext("GL_OES_blend_equation_separate");
	GL_OES_stencil4 = has_ext("GL_OES_stencil4");
	GL_OES_framebuffer_object = has_ext("GL_OES_framebuffer_object");
	GL_OES_stencil1 = has_ext("GL_OES_stencil1");
	GL_ARM_rgba8 = has_ext("GL_ARM_rgba8");
	GL_EXT_robustness = has_ext("GL_EXT_robustness");
	GL_EXT_sRGB = has_ext("GL_EXT_sRGB");
	GL_EXT_texture_lod_bias = has_ext("GL_EXT_texture_lod_bias");
	GL_OES_compressed_ETC1_RGB8_sub_texture = has_ext("GL_OES_compressed_ETC1_RGB8_sub_texture");
	GL_OES_draw_texture = has_ext("GL_OES_draw_texture");
	GL_OES_blend_func_separate = has_ext("GL_OES_blend_func_separate");
	GL_OES_texture_env_crossbar = has_ext("GL_OES_texture_env_crossbar");
	GL_OES_rgb8_rgba8 = has_ext("GL_OES_rgb8_rgba8");
	GL_OES_fbo_render_mipmap = has_ext("GL_OES_fbo_render_mipmap");
	GL_OES_compressed_paletted_texture = has_ext("GL_OES_compressed_paletted_texture");
	GL_OES_vertex_array_object = has_ext("GL_OES_vertex_array_object");
	GL_OES_matrix_get = has_ext("GL_OES_matrix_get");
	GL_EXT_texture_filter_anisotropic = has_ext("GL_EXT_texture_filter_anisotropic");
	GL_EXT_blend_minmax = has_ext("GL_EXT_blend_minmax");
	GL_OES_byte_coordinates = has_ext("GL_OES_byte_coordinates");
	GL_IMG_read_format = has_ext("GL_IMG_read_format");
	GL_OES_depth24 = has_ext("GL_OES_depth24");
	GL_OES_stencil_wrap = has_ext("GL_OES_stencil_wrap");
	GL_APPLE_sync = has_ext("GL_APPLE_sync");
	GL_EXT_texture_storage = has_ext("GL_EXT_texture_storage");
	GL_AMD_compressed_ATC_texture = has_ext("GL_AMD_compressed_ATC_texture");
	GL_QCOM_driver_control = has_ext("GL_QCOM_driver_control");
	GL_IMG_texture_compression_pvrtc = has_ext("GL_IMG_texture_compression_pvrtc");
	return;
}

void load_GL_VERSION_ES_CM_1_0(Loader load) {
	if(!GL_VERSION_ES_CM_1_0) return;
	glAlphaFunc = cast(typeof(glAlphaFunc))load("glAlphaFunc");
	glClearColor = cast(typeof(glClearColor))load("glClearColor");
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf");
	glClipPlanef = cast(typeof(glClipPlanef))load("glClipPlanef");
	glColor4f = cast(typeof(glColor4f))load("glColor4f");
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef");
	glFogf = cast(typeof(glFogf))load("glFogf");
	glFogfv = cast(typeof(glFogfv))load("glFogfv");
	glFrustumf = cast(typeof(glFrustumf))load("glFrustumf");
	glGetClipPlanef = cast(typeof(glGetClipPlanef))load("glGetClipPlanef");
	glGetFloatv = cast(typeof(glGetFloatv))load("glGetFloatv");
	glGetLightfv = cast(typeof(glGetLightfv))load("glGetLightfv");
	glGetMaterialfv = cast(typeof(glGetMaterialfv))load("glGetMaterialfv");
	glGetTexEnvfv = cast(typeof(glGetTexEnvfv))load("glGetTexEnvfv");
	glGetTexParameterfv = cast(typeof(glGetTexParameterfv))load("glGetTexParameterfv");
	glLightModelf = cast(typeof(glLightModelf))load("glLightModelf");
	glLightModelfv = cast(typeof(glLightModelfv))load("glLightModelfv");
	glLightf = cast(typeof(glLightf))load("glLightf");
	glLightfv = cast(typeof(glLightfv))load("glLightfv");
	glLineWidth = cast(typeof(glLineWidth))load("glLineWidth");
	glLoadMatrixf = cast(typeof(glLoadMatrixf))load("glLoadMatrixf");
	glMaterialf = cast(typeof(glMaterialf))load("glMaterialf");
	glMaterialfv = cast(typeof(glMaterialfv))load("glMaterialfv");
	glMultMatrixf = cast(typeof(glMultMatrixf))load("glMultMatrixf");
	glMultiTexCoord4f = cast(typeof(glMultiTexCoord4f))load("glMultiTexCoord4f");
	glNormal3f = cast(typeof(glNormal3f))load("glNormal3f");
	glOrthof = cast(typeof(glOrthof))load("glOrthof");
	glPointParameterf = cast(typeof(glPointParameterf))load("glPointParameterf");
	glPointParameterfv = cast(typeof(glPointParameterfv))load("glPointParameterfv");
	glPointSize = cast(typeof(glPointSize))load("glPointSize");
	glPolygonOffset = cast(typeof(glPolygonOffset))load("glPolygonOffset");
	glRotatef = cast(typeof(glRotatef))load("glRotatef");
	glScalef = cast(typeof(glScalef))load("glScalef");
	glTexEnvf = cast(typeof(glTexEnvf))load("glTexEnvf");
	glTexEnvfv = cast(typeof(glTexEnvfv))load("glTexEnvfv");
	glTexParameterf = cast(typeof(glTexParameterf))load("glTexParameterf");
	glTexParameterfv = cast(typeof(glTexParameterfv))load("glTexParameterfv");
	glTranslatef = cast(typeof(glTranslatef))load("glTranslatef");
	glActiveTexture = cast(typeof(glActiveTexture))load("glActiveTexture");
	glAlphaFuncx = cast(typeof(glAlphaFuncx))load("glAlphaFuncx");
	glBindBuffer = cast(typeof(glBindBuffer))load("glBindBuffer");
	glBindTexture = cast(typeof(glBindTexture))load("glBindTexture");
	glBlendFunc = cast(typeof(glBlendFunc))load("glBlendFunc");
	glBufferData = cast(typeof(glBufferData))load("glBufferData");
	glBufferSubData = cast(typeof(glBufferSubData))load("glBufferSubData");
	glClear = cast(typeof(glClear))load("glClear");
	glClearColorx = cast(typeof(glClearColorx))load("glClearColorx");
	glClearDepthx = cast(typeof(glClearDepthx))load("glClearDepthx");
	glClearStencil = cast(typeof(glClearStencil))load("glClearStencil");
	glClientActiveTexture = cast(typeof(glClientActiveTexture))load("glClientActiveTexture");
	glClipPlanex = cast(typeof(glClipPlanex))load("glClipPlanex");
	glColor4ub = cast(typeof(glColor4ub))load("glColor4ub");
	glColor4x = cast(typeof(glColor4x))load("glColor4x");
	glColorMask = cast(typeof(glColorMask))load("glColorMask");
	glColorPointer = cast(typeof(glColorPointer))load("glColorPointer");
	glCompressedTexImage2D = cast(typeof(glCompressedTexImage2D))load("glCompressedTexImage2D");
	glCompressedTexSubImage2D = cast(typeof(glCompressedTexSubImage2D))load("glCompressedTexSubImage2D");
	glCopyTexImage2D = cast(typeof(glCopyTexImage2D))load("glCopyTexImage2D");
	glCopyTexSubImage2D = cast(typeof(glCopyTexSubImage2D))load("glCopyTexSubImage2D");
	glCullFace = cast(typeof(glCullFace))load("glCullFace");
	glDeleteBuffers = cast(typeof(glDeleteBuffers))load("glDeleteBuffers");
	glDeleteTextures = cast(typeof(glDeleteTextures))load("glDeleteTextures");
	glDepthFunc = cast(typeof(glDepthFunc))load("glDepthFunc");
	glDepthMask = cast(typeof(glDepthMask))load("glDepthMask");
	glDepthRangex = cast(typeof(glDepthRangex))load("glDepthRangex");
	glDisable = cast(typeof(glDisable))load("glDisable");
	glDisableClientState = cast(typeof(glDisableClientState))load("glDisableClientState");
	glDrawArrays = cast(typeof(glDrawArrays))load("glDrawArrays");
	glDrawElements = cast(typeof(glDrawElements))load("glDrawElements");
	glEnable = cast(typeof(glEnable))load("glEnable");
	glEnableClientState = cast(typeof(glEnableClientState))load("glEnableClientState");
	glFinish = cast(typeof(glFinish))load("glFinish");
	glFlush = cast(typeof(glFlush))load("glFlush");
	glFogx = cast(typeof(glFogx))load("glFogx");
	glFogxv = cast(typeof(glFogxv))load("glFogxv");
	glFrontFace = cast(typeof(glFrontFace))load("glFrontFace");
	glFrustumx = cast(typeof(glFrustumx))load("glFrustumx");
	glGetBooleanv = cast(typeof(glGetBooleanv))load("glGetBooleanv");
	glGetBufferParameteriv = cast(typeof(glGetBufferParameteriv))load("glGetBufferParameteriv");
	glGetClipPlanex = cast(typeof(glGetClipPlanex))load("glGetClipPlanex");
	glGenBuffers = cast(typeof(glGenBuffers))load("glGenBuffers");
	glGenTextures = cast(typeof(glGenTextures))load("glGenTextures");
	glGetError = cast(typeof(glGetError))load("glGetError");
	glGetFixedv = cast(typeof(glGetFixedv))load("glGetFixedv");
	glGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv");
	glGetLightxv = cast(typeof(glGetLightxv))load("glGetLightxv");
	glGetMaterialxv = cast(typeof(glGetMaterialxv))load("glGetMaterialxv");
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv");
	glGetString = cast(typeof(glGetString))load("glGetString");
	glGetTexEnviv = cast(typeof(glGetTexEnviv))load("glGetTexEnviv");
	glGetTexEnvxv = cast(typeof(glGetTexEnvxv))load("glGetTexEnvxv");
	glGetTexParameteriv = cast(typeof(glGetTexParameteriv))load("glGetTexParameteriv");
	glGetTexParameterxv = cast(typeof(glGetTexParameterxv))load("glGetTexParameterxv");
	glHint = cast(typeof(glHint))load("glHint");
	glIsBuffer = cast(typeof(glIsBuffer))load("glIsBuffer");
	glIsEnabled = cast(typeof(glIsEnabled))load("glIsEnabled");
	glIsTexture = cast(typeof(glIsTexture))load("glIsTexture");
	glLightModelx = cast(typeof(glLightModelx))load("glLightModelx");
	glLightModelxv = cast(typeof(glLightModelxv))load("glLightModelxv");
	glLightx = cast(typeof(glLightx))load("glLightx");
	glLightxv = cast(typeof(glLightxv))load("glLightxv");
	glLineWidthx = cast(typeof(glLineWidthx))load("glLineWidthx");
	glLoadIdentity = cast(typeof(glLoadIdentity))load("glLoadIdentity");
	glLoadMatrixx = cast(typeof(glLoadMatrixx))load("glLoadMatrixx");
	glLogicOp = cast(typeof(glLogicOp))load("glLogicOp");
	glMaterialx = cast(typeof(glMaterialx))load("glMaterialx");
	glMaterialxv = cast(typeof(glMaterialxv))load("glMaterialxv");
	glMatrixMode = cast(typeof(glMatrixMode))load("glMatrixMode");
	glMultMatrixx = cast(typeof(glMultMatrixx))load("glMultMatrixx");
	glMultiTexCoord4x = cast(typeof(glMultiTexCoord4x))load("glMultiTexCoord4x");
	glNormal3x = cast(typeof(glNormal3x))load("glNormal3x");
	glNormalPointer = cast(typeof(glNormalPointer))load("glNormalPointer");
	glOrthox = cast(typeof(glOrthox))load("glOrthox");
	glPixelStorei = cast(typeof(glPixelStorei))load("glPixelStorei");
	glPointParameterx = cast(typeof(glPointParameterx))load("glPointParameterx");
	glPointParameterxv = cast(typeof(glPointParameterxv))load("glPointParameterxv");
	glPointSizex = cast(typeof(glPointSizex))load("glPointSizex");
	glPolygonOffsetx = cast(typeof(glPolygonOffsetx))load("glPolygonOffsetx");
	glPopMatrix = cast(typeof(glPopMatrix))load("glPopMatrix");
	glPushMatrix = cast(typeof(glPushMatrix))load("glPushMatrix");
	glReadPixels = cast(typeof(glReadPixels))load("glReadPixels");
	glRotatex = cast(typeof(glRotatex))load("glRotatex");
	glSampleCoverage = cast(typeof(glSampleCoverage))load("glSampleCoverage");
	glSampleCoveragex = cast(typeof(glSampleCoveragex))load("glSampleCoveragex");
	glScalex = cast(typeof(glScalex))load("glScalex");
	glScissor = cast(typeof(glScissor))load("glScissor");
	glShadeModel = cast(typeof(glShadeModel))load("glShadeModel");
	glStencilFunc = cast(typeof(glStencilFunc))load("glStencilFunc");
	glStencilMask = cast(typeof(glStencilMask))load("glStencilMask");
	glStencilOp = cast(typeof(glStencilOp))load("glStencilOp");
	glTexCoordPointer = cast(typeof(glTexCoordPointer))load("glTexCoordPointer");
	glTexEnvi = cast(typeof(glTexEnvi))load("glTexEnvi");
	glTexEnvx = cast(typeof(glTexEnvx))load("glTexEnvx");
	glTexEnviv = cast(typeof(glTexEnviv))load("glTexEnviv");
	glTexEnvxv = cast(typeof(glTexEnvxv))load("glTexEnvxv");
	glTexImage2D = cast(typeof(glTexImage2D))load("glTexImage2D");
	glTexParameteri = cast(typeof(glTexParameteri))load("glTexParameteri");
	glTexParameterx = cast(typeof(glTexParameterx))load("glTexParameterx");
	glTexParameteriv = cast(typeof(glTexParameteriv))load("glTexParameteriv");
	glTexParameterxv = cast(typeof(glTexParameterxv))load("glTexParameterxv");
	glTexSubImage2D = cast(typeof(glTexSubImage2D))load("glTexSubImage2D");
	glTranslatex = cast(typeof(glTranslatex))load("glTranslatex");
	glVertexPointer = cast(typeof(glVertexPointer))load("glVertexPointer");
	glViewport = cast(typeof(glViewport))load("glViewport");
	return;
}

void load_GL_OES_point_size_array(Loader load) {
	if(!GL_OES_point_size_array) return;
	glPointSizePointerOES = cast(typeof(glPointSizePointerOES))load("glPointSizePointerOES");
	return;
}
void load_GL_OES_texture_cube_map(Loader load) {
	if(!GL_OES_texture_cube_map) return;
	glTexGenfOES = cast(typeof(glTexGenfOES))load("glTexGenfOES");
	glTexGenfvOES = cast(typeof(glTexGenfvOES))load("glTexGenfvOES");
	glTexGeniOES = cast(typeof(glTexGeniOES))load("glTexGeniOES");
	glTexGenivOES = cast(typeof(glTexGenivOES))load("glTexGenivOES");
	glTexGenxOES = cast(typeof(glTexGenxOES))load("glTexGenxOES");
	glTexGenxvOES = cast(typeof(glTexGenxvOES))load("glTexGenxvOES");
	glGetTexGenfvOES = cast(typeof(glGetTexGenfvOES))load("glGetTexGenfvOES");
	glGetTexGenivOES = cast(typeof(glGetTexGenivOES))load("glGetTexGenivOES");
	glGetTexGenxvOES = cast(typeof(glGetTexGenxvOES))load("glGetTexGenxvOES");
	return;
}
void load_GL_IMG_user_clip_plane(Loader load) {
	if(!GL_IMG_user_clip_plane) return;
	glClipPlanefIMG = cast(typeof(glClipPlanefIMG))load("glClipPlanefIMG");
	glClipPlanexIMG = cast(typeof(glClipPlanexIMG))load("glClipPlanexIMG");
	return;
}
void load_GL_OES_blend_subtract(Loader load) {
	if(!GL_OES_blend_subtract) return;
	glBlendEquationOES = cast(typeof(glBlendEquationOES))load("glBlendEquationOES");
	return;
}
void load_GL_OES_matrix_palette(Loader load) {
	if(!GL_OES_matrix_palette) return;
	glCurrentPaletteMatrixOES = cast(typeof(glCurrentPaletteMatrixOES))load("glCurrentPaletteMatrixOES");
	glLoadPaletteFromModelViewMatrixOES = cast(typeof(glLoadPaletteFromModelViewMatrixOES))load("glLoadPaletteFromModelViewMatrixOES");
	glMatrixIndexPointerOES = cast(typeof(glMatrixIndexPointerOES))load("glMatrixIndexPointerOES");
	glWeightPointerOES = cast(typeof(glWeightPointerOES))load("glWeightPointerOES");
	return;
}
void load_GL_OES_blend_equation_separate(Loader load) {
	if(!GL_OES_blend_equation_separate) return;
	glBlendEquationSeparateOES = cast(typeof(glBlendEquationSeparateOES))load("glBlendEquationSeparateOES");
	return;
}
void load_GL_OES_framebuffer_object(Loader load) {
	if(!GL_OES_framebuffer_object) return;
	glIsRenderbufferOES = cast(typeof(glIsRenderbufferOES))load("glIsRenderbufferOES");
	glBindRenderbufferOES = cast(typeof(glBindRenderbufferOES))load("glBindRenderbufferOES");
	glDeleteRenderbuffersOES = cast(typeof(glDeleteRenderbuffersOES))load("glDeleteRenderbuffersOES");
	glGenRenderbuffersOES = cast(typeof(glGenRenderbuffersOES))load("glGenRenderbuffersOES");
	glRenderbufferStorageOES = cast(typeof(glRenderbufferStorageOES))load("glRenderbufferStorageOES");
	glGetRenderbufferParameterivOES = cast(typeof(glGetRenderbufferParameterivOES))load("glGetRenderbufferParameterivOES");
	glIsFramebufferOES = cast(typeof(glIsFramebufferOES))load("glIsFramebufferOES");
	glBindFramebufferOES = cast(typeof(glBindFramebufferOES))load("glBindFramebufferOES");
	glDeleteFramebuffersOES = cast(typeof(glDeleteFramebuffersOES))load("glDeleteFramebuffersOES");
	glGenFramebuffersOES = cast(typeof(glGenFramebuffersOES))load("glGenFramebuffersOES");
	glCheckFramebufferStatusOES = cast(typeof(glCheckFramebufferStatusOES))load("glCheckFramebufferStatusOES");
	glFramebufferRenderbufferOES = cast(typeof(glFramebufferRenderbufferOES))load("glFramebufferRenderbufferOES");
	glFramebufferTexture2DOES = cast(typeof(glFramebufferTexture2DOES))load("glFramebufferTexture2DOES");
	glGetFramebufferAttachmentParameterivOES = cast(typeof(glGetFramebufferAttachmentParameterivOES))load("glGetFramebufferAttachmentParameterivOES");
	glGenerateMipmapOES = cast(typeof(glGenerateMipmapOES))load("glGenerateMipmapOES");
	return;
}
void load_GL_OES_draw_texture(Loader load) {
	if(!GL_OES_draw_texture) return;
	glDrawTexsOES = cast(typeof(glDrawTexsOES))load("glDrawTexsOES");
	glDrawTexiOES = cast(typeof(glDrawTexiOES))load("glDrawTexiOES");
	glDrawTexxOES = cast(typeof(glDrawTexxOES))load("glDrawTexxOES");
	glDrawTexsvOES = cast(typeof(glDrawTexsvOES))load("glDrawTexsvOES");
	glDrawTexivOES = cast(typeof(glDrawTexivOES))load("glDrawTexivOES");
	glDrawTexxvOES = cast(typeof(glDrawTexxvOES))load("glDrawTexxvOES");
	glDrawTexfOES = cast(typeof(glDrawTexfOES))load("glDrawTexfOES");
	glDrawTexfvOES = cast(typeof(glDrawTexfvOES))load("glDrawTexfvOES");
	return;
}
void load_GL_OES_blend_func_separate(Loader load) {
	if(!GL_OES_blend_func_separate) return;
	glBlendFuncSeparateOES = cast(typeof(glBlendFuncSeparateOES))load("glBlendFuncSeparateOES");
	return;
}
