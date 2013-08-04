module glad.loader;


private import glad.glfuncs;
private import glad.glext;
private import glad.glenums;
private import glad.gltypes;


struct GLVersion { int major; int minor; }

version(Windows) {
    private import std.c.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
    extern(System) private __gshared void* function(const(char)*) wglGetProcAddress;
} else {
    private __gshared void* libGL;
    extern(System) private __gshared void* function(const(char)*) glXGetProcAddress;
}

bool gladInit() {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll\0".ptr);
        if(libGL !is null) {
            wglGetProcAddress = cast(typeof(wglGetProcAddress))GetProcAddress(
                libGL, "wglGetProcAddress\0".ptr);
            return wglGetProcAddress !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL\0".ptr,
                "/Library/Frameworks/OpenGL.framework/OpenGL\0".ptr,
                "/System/Library/Frameworks/OpenGL.framework/OpenGL\0".ptr
            ];
        } else {
            enum NAMES = ["libGL.so.1\0".ptr, "libGL.so\0".ptr];
        }

        foreach(name; NAMES) {
            libGL = dlopen(name, RTLD_NOW | RTLD_GLOBAL);
            if(libGL !is null) {
                version(OSX) {
                    return true;
                } else {
                    glXGetProcAddress = cast(typeof(glXGetProcAddress))dlsym(libGL,
                        "glXGetProcAddressARB\0".ptr);
                    return glXGetProcAddress !is null;
                }
            }
        }

        return false;
    }
}

void gladTerminate() {
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

void* gladGetProcAddress(const(char)* namez) {
    if(libGL is null) return null;
    void* result;

    version(Windows) {
        if(wglGetProcAddress is null) return null;

        result = wglGetProcAddress(namez);
        if(result is null) {
            result = GetProcAddress(libGL, namez);
        }
    } else {
        if(glXGetProcAddress is null) return null;

        version(OSX) {} else {
            result = glXGetProcAddress(namez);
        }
        if(result is null) {
            result = dlsym(libGL, namez);
        }
    }

    return result;
}

GLVersion gladLoadGL() {
    return gladLoadGL(&gladGetProcAddress);
}


private extern(C) char* strstr(const(char)*, const(char)*);
private extern(C) int strcmp(const(char)*, const(char)*);
private bool has_ext(GLVersion glv, const(char)* extensions, const(char)* ext) {
    if(glv.major < 3) {
        return extensions !is null && ext !is null && strstr(extensions, ext) !is null;
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
GLVersion gladLoadGL(void* function(const(char)* name) load) {
	glGetString = cast(typeof(glGetString))load("glGetString\0".ptr);
	if(glGetString is null) { GLVersion glv; return glv; }

	GLVersion glv = find_core();
	load_gl_GL_VERSION_1_0(load);
	load_gl_GL_VERSION_1_1(load);
	load_gl_GL_VERSION_1_2(load);
	load_gl_GL_VERSION_1_3(load);
	load_gl_GL_VERSION_1_4(load);
	load_gl_GL_VERSION_1_5(load);
	load_gl_GL_VERSION_2_0(load);
	load_gl_GL_VERSION_2_1(load);
	load_gl_GL_VERSION_3_0(load);
	load_gl_GL_VERSION_3_1(load);
	load_gl_GL_VERSION_3_2(load);
	load_gl_GL_VERSION_3_3(load);
	load_gl_GL_VERSION_4_0(load);
	load_gl_GL_VERSION_4_1(load);
	load_gl_GL_VERSION_4_2(load);
	load_gl_GL_VERSION_4_3(load);
	load_gl_GL_VERSION_4_4(load);

	find_extensions(glv);
	load_gl_GL_NV_point_sprite(load);
	load_gl_GL_APPLE_element_array(load);
	load_gl_GL_AMD_multi_draw_indirect(load);
	load_gl_GL_SGIX_tag_sample_buffer(load);
	load_gl_GL_ATI_separate_stencil(load);
	load_gl_GL_EXT_texture_buffer_object(load);
	load_gl_GL_ARB_vertex_blend(load);
	load_gl_GL_ARB_program_interface_query(load);
	load_gl_GL_EXT_index_func(load);
	load_gl_GL_NV_shader_buffer_load(load);
	load_gl_GL_EXT_color_subtable(load);
	load_gl_GL_SUNX_constant_data(load);
	load_gl_GL_EXT_multi_draw_arrays(load);
	load_gl_GL_ARB_shader_atomic_counters(load);
	load_gl_GL_NV_conditional_render(load);
	load_gl_GL_MESA_resize_buffers(load);
	load_gl_GL_ARB_texture_view(load);
	load_gl_GL_ARB_map_buffer_range(load);
	load_gl_GL_EXT_convolution(load);
	load_gl_GL_NV_vertex_attrib_integer_64bit(load);
	load_gl_GL_EXT_paletted_texture(load);
	load_gl_GL_ARB_texture_buffer_object(load);
	load_gl_GL_ATI_pn_triangles(load);
	load_gl_GL_SGIX_flush_raster(load);
	load_gl_GL_EXT_light_texture(load);
	load_gl_GL_AMD_draw_buffers_blend(load);
	load_gl_GL_MESA_window_pos(load);
	load_gl_GL_NV_texture_barrier(load);
	load_gl_GL_ARB_vertex_type_2_10_10_10_rev(load);
	load_gl_GL_3DFX_tbuffer(load);
	load_gl_GL_GREMEDY_frame_terminator(load);
	load_gl_GL_ARB_blend_func_extended(load);
	load_gl_GL_EXT_separate_shader_objects(load);
	load_gl_GL_NV_texture_multisample(load);
	load_gl_GL_ARB_shader_objects(load);
	load_gl_GL_ARB_framebuffer_object(load);
	load_gl_GL_ATI_envmap_bumpmap(load);
	load_gl_GL_ATI_map_object_buffer(load);
	load_gl_GL_ARB_robustness(load);
	load_gl_GL_NV_pixel_data_range(load);
	load_gl_GL_EXT_framebuffer_blit(load);
	load_gl_GL_ARB_gpu_shader_fp64(load);
	load_gl_GL_EXT_vertex_weighting(load);
	load_gl_GL_GREMEDY_string_marker(load);
	load_gl_GL_EXT_subtexture(load);
	load_gl_GL_NV_evaluators(load);
	load_gl_GL_SGIS_texture_filter4(load);
	load_gl_GL_AMD_performance_monitor(load);
	load_gl_GL_EXT_stencil_clear_tag(load);
	load_gl_GL_NV_present_video(load);
	load_gl_GL_EXT_gpu_program_parameters(load);
	load_gl_GL_SGIX_list_priority(load);
	load_gl_GL_ARB_draw_elements_base_vertex(load);
	load_gl_GL_NV_transform_feedback(load);
	load_gl_GL_NV_fragment_program(load);
	load_gl_GL_AMD_stencil_operation_extended(load);
	load_gl_GL_ARB_instanced_arrays(load);
	load_gl_GL_EXT_polygon_offset(load);
	load_gl_GL_AMD_sparse_texture(load);
	load_gl_GL_NV_fence(load);
	load_gl_GL_ARB_texture_buffer_range(load);
	load_gl_GL_SUN_mesh_array(load);
	load_gl_GL_ARB_vertex_attrib_binding(load);
	load_gl_GL_ARB_framebuffer_no_attachments(load);
	load_gl_GL_ARB_cl_event(load);
	load_gl_GL_OES_single_precision(load);
	load_gl_GL_NV_primitive_restart(load);
	load_gl_GL_SUN_global_alpha(load);
	load_gl_GL_EXT_texture_object(load);
	load_gl_GL_AMD_name_gen_delete(load);
	load_gl_GL_ARB_buffer_storage(load);
	load_gl_GL_APPLE_vertex_program_evaluators(load);
	load_gl_GL_ARB_multi_bind(load);
	load_gl_GL_NV_vertex_buffer_unified_memory(load);
	load_gl_GL_NV_blend_equation_advanced(load);
	load_gl_GL_SGIS_sharpen_texture(load);
	load_gl_GL_ARB_vertex_program(load);
	load_gl_GL_ARB_vertex_buffer_object(load);
	load_gl_GL_NV_vertex_array_range(load);
	load_gl_GL_SGIX_fragment_lighting(load);
	load_gl_GL_NV_framebuffer_multisample_coverage(load);
	load_gl_GL_EXT_timer_query(load);
	load_gl_GL_NV_bindless_texture(load);
	load_gl_GL_KHR_debug(load);
	load_gl_GL_ATI_vertex_attrib_array_object(load);
	load_gl_GL_EXT_geometry_shader4(load);
	load_gl_GL_EXT_bindable_uniform(load);
	load_gl_GL_ATI_element_array(load);
	load_gl_GL_SGIX_reference_plane(load);
	load_gl_GL_EXT_stencil_two_side(load);
	load_gl_GL_NV_explicit_multisample(load);
	load_gl_GL_IBM_static_data(load);
	load_gl_GL_EXT_texture_perturb_normal(load);
	load_gl_GL_EXT_point_parameters(load);
	load_gl_GL_PGI_misc_hints(load);
	load_gl_GL_ARB_vertex_shader(load);
	load_gl_GL_ARB_tessellation_shader(load);
	load_gl_GL_EXT_draw_buffers2(load);
	load_gl_GL_ARB_vertex_attrib_64bit(load);
	load_gl_GL_AMD_interleaved_elements(load);
	load_gl_GL_ARB_fragment_program(load);
	load_gl_GL_ARB_texture_storage(load);
	load_gl_GL_ARB_copy_image(load);
	load_gl_GL_SGIS_pixel_texture(load);
	load_gl_GL_SGIX_instruments(load);
	load_gl_GL_ARB_shader_storage_buffer_object(load);
	load_gl_GL_EXT_blend_minmax(load);
	load_gl_GL_ARB_base_instance(load);
	load_gl_GL_EXT_texture_integer(load);
	load_gl_GL_ARB_texture_multisample(load);
	load_gl_GL_AMD_vertex_shader_tessellator(load);
	load_gl_GL_ARB_invalidate_subdata(load);
	load_gl_GL_EXT_index_material(load);
	load_gl_GL_INTEL_parallel_arrays(load);
	load_gl_GL_ATI_draw_buffers(load);
	load_gl_GL_SGIX_pixel_texture(load);
	load_gl_GL_ARB_timer_query(load);
	load_gl_GL_NV_parameter_buffer_object(load);
	load_gl_GL_ARB_uniform_buffer_object(load);
	load_gl_GL_NV_transform_feedback2(load);
	load_gl_GL_EXT_blend_color(load);
	load_gl_GL_EXT_histogram(load);
	load_gl_GL_SGIS_point_parameters(load);
	load_gl_GL_EXT_direct_state_access(load);
	load_gl_GL_AMD_sample_positions(load);
	load_gl_GL_NV_vertex_program(load);
	load_gl_GL_NVX_conditional_render(load);
	load_gl_GL_EXT_vertex_shader(load);
	load_gl_GL_EXT_blend_func_separate(load);
	load_gl_GL_APPLE_fence(load);
	load_gl_GL_OES_byte_coordinates(load);
	load_gl_GL_ARB_transpose_matrix(load);
	load_gl_GL_ARB_provoking_vertex(load);
	load_gl_GL_EXT_fog_coord(load);
	load_gl_GL_EXT_vertex_array(load);
	load_gl_GL_EXT_blend_equation_separate(load);
	load_gl_GL_ARB_multi_draw_indirect(load);
	load_gl_GL_NV_copy_image(load);
	load_gl_GL_ARB_transform_feedback2(load);
	load_gl_GL_ARB_transform_feedback3(load);
	load_gl_GL_EXT_pixel_transform(load);
	load_gl_GL_ATI_fragment_shader(load);
	load_gl_GL_ARB_vertex_array_object(load);
	load_gl_GL_SUN_triangle_list(load);
	load_gl_GL_ARB_transform_feedback_instanced(load);
	load_gl_GL_SGIX_async(load);
	load_gl_GL_NV_gpu_shader5(load);
	load_gl_GL_ARB_ES2_compatibility(load);
	load_gl_GL_ARB_indirect_parameters(load);
	load_gl_GL_NV_half_float(load);
	load_gl_GL_EXT_coordinate_frame(load);
	load_gl_GL_EXT_compiled_vertex_array(load);
	load_gl_GL_NV_depth_buffer_float(load);
	load_gl_GL_NV_occlusion_query(load);
	load_gl_GL_APPLE_flush_buffer_range(load);
	load_gl_GL_ARB_imaging(load);
	load_gl_GL_ARB_draw_buffers_blend(load);
	load_gl_GL_ARB_clear_buffer_object(load);
	load_gl_GL_ARB_multisample(load);
	load_gl_GL_ARB_sample_shading(load);
	load_gl_GL_INTEL_map_texture(load);
	load_gl_GL_ARB_compute_shader(load);
	load_gl_GL_IBM_vertex_array_lists(load);
	load_gl_GL_ARB_color_buffer_float(load);
	load_gl_GL_ARB_bindless_texture(load);
	load_gl_GL_ARB_window_pos(load);
	load_gl_GL_ARB_internalformat_query(load);
	load_gl_GL_EXT_shader_image_load_store(load);
	load_gl_GL_EXT_copy_texture(load);
	load_gl_GL_NV_register_combiners2(load);
	load_gl_GL_NV_draw_texture(load);
	load_gl_GL_EXT_draw_instanced(load);
	load_gl_GL_ARB_viewport_array(load);
	load_gl_GL_ARB_separate_shader_objects(load);
	load_gl_GL_EXT_depth_bounds_test(load);
	load_gl_GL_HP_image_transform(load);
	load_gl_GL_NV_video_capture(load);
	load_gl_GL_ARB_sampler_objects(load);
	load_gl_GL_ARB_matrix_palette(load);
	load_gl_GL_SGIS_texture_color_mask(load);
	load_gl_GL_ARB_texture_compression(load);
	load_gl_GL_ARB_shader_subroutine(load);
	load_gl_GL_ARB_texture_storage_multisample(load);
	load_gl_GL_EXT_vertex_attrib_64bit(load);
	load_gl_GL_OES_query_matrix(load);
	load_gl_GL_APPLE_texture_range(load);
	load_gl_GL_ARB_copy_buffer(load);
	load_gl_GL_APPLE_object_purgeable(load);
	load_gl_GL_ARB_occlusion_query(load);
	load_gl_GL_SGI_color_table(load);
	load_gl_GL_EXT_gpu_shader4(load);
	load_gl_GL_NV_geometry_program4(load);
	load_gl_GL_AMD_debug_output(load);
	load_gl_GL_ARB_multitexture(load);
	load_gl_GL_SGIX_polynomial_ffd(load);
	load_gl_GL_EXT_provoking_vertex(load);
	load_gl_GL_ARB_point_parameters(load);
	load_gl_GL_ARB_shader_image_load_store(load);
	load_gl_GL_SGIX_framezoom(load);
	load_gl_GL_NV_bindless_multi_draw_indirect(load);
	load_gl_GL_EXT_transform_feedback(load);
	load_gl_GL_NV_gpu_program4(load);
	load_gl_GL_NV_gpu_program5(load);
	load_gl_GL_ARB_geometry_shader4(load);
	load_gl_GL_SGIX_sprite(load);
	load_gl_GL_ARB_get_program_binary(load);
	load_gl_GL_SGIS_multisample(load);
	load_gl_GL_EXT_framebuffer_object(load);
	load_gl_GL_APPLE_vertex_array_range(load);
	load_gl_GL_NV_register_combiners(load);
	load_gl_GL_ARB_draw_buffers(load);
	load_gl_GL_ARB_clear_texture(load);
	load_gl_GL_ARB_debug_output(load);
	load_gl_GL_EXT_cull_vertex(load);
	load_gl_GL_IBM_multimode_draw_arrays(load);
	load_gl_GL_APPLE_vertex_array_object(load);
	load_gl_GL_SGIS_detail_texture(load);
	load_gl_GL_ARB_draw_instanced(load);
	load_gl_GL_ARB_shading_language_include(load);
	load_gl_GL_INGR_blend_func_separate(load);
	load_gl_GL_NV_path_rendering(load);
	load_gl_GL_ATI_vertex_streams(load);
	load_gl_GL_NV_vdpau_interop(load);
	load_gl_GL_ARB_internalformat_query2(load);
	load_gl_GL_SUN_vertex(load);
	load_gl_GL_SGIX_igloo_interface(load);
	load_gl_GL_ARB_draw_indirect(load);
	load_gl_GL_NV_vertex_program4(load);
	load_gl_GL_SGIS_fog_function(load);
	load_gl_GL_EXT_x11_sync_object(load);
	load_gl_GL_ARB_sync(load);
	load_gl_GL_ARB_compute_variable_group_size(load);
	load_gl_GL_OES_fixed_point(load);
	load_gl_GL_EXT_framebuffer_multisample(load);
	load_gl_GL_SGIS_texture4D(load);
	load_gl_GL_EXT_texture3D(load);
	load_gl_GL_EXT_multisample(load);
	load_gl_GL_EXT_secondary_color(load);
	load_gl_GL_ATI_vertex_array_object(load);
	load_gl_GL_ARB_sparse_texture(load);
	load_gl_GL_EXT_draw_range_elements(load);

	return glv;
}

private:

GLVersion find_core() {
	int major;
	int minor;
	const(char)* v = cast(const(char)*)glGetString(GL_VERSION);
	major = v[0] - '0';
	minor = v[2] - '0';
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
	GLVersion glv; glv.major = major; glv.minor = minor; return glv;
}

void find_extensions(GLVersion glv) {
	const(char)* extensions = cast(const(char)*)glGetString(GL_EXTENSIONS);

	GL_SGIX_pixel_tiles = has_ext(glv, extensions, "GL_SGIX_pixel_tiles\0".ptr);
	GL_NV_point_sprite = has_ext(glv, extensions, "GL_NV_point_sprite\0".ptr);
	GL_APPLE_element_array = has_ext(glv, extensions, "GL_APPLE_element_array\0".ptr);
	GL_AMD_multi_draw_indirect = has_ext(glv, extensions, "GL_AMD_multi_draw_indirect\0".ptr);
	GL_EXT_blend_subtract = has_ext(glv, extensions, "GL_EXT_blend_subtract\0".ptr);
	GL_SGIX_tag_sample_buffer = has_ext(glv, extensions, "GL_SGIX_tag_sample_buffer\0".ptr);
	GL_IBM_texture_mirrored_repeat = has_ext(glv, extensions, "GL_IBM_texture_mirrored_repeat\0".ptr);
	GL_APPLE_transform_hint = has_ext(glv, extensions, "GL_APPLE_transform_hint\0".ptr);
	GL_ATI_separate_stencil = has_ext(glv, extensions, "GL_ATI_separate_stencil\0".ptr);
	GL_NV_vertex_program2_option = has_ext(glv, extensions, "GL_NV_vertex_program2_option\0".ptr);
	GL_EXT_texture_buffer_object = has_ext(glv, extensions, "GL_EXT_texture_buffer_object\0".ptr);
	GL_ARB_vertex_blend = has_ext(glv, extensions, "GL_ARB_vertex_blend\0".ptr);
	GL_NV_vertex_program2 = has_ext(glv, extensions, "GL_NV_vertex_program2\0".ptr);
	GL_ARB_program_interface_query = has_ext(glv, extensions, "GL_ARB_program_interface_query\0".ptr);
	GL_EXT_misc_attribute = has_ext(glv, extensions, "GL_EXT_misc_attribute\0".ptr);
	GL_NV_multisample_coverage = has_ext(glv, extensions, "GL_NV_multisample_coverage\0".ptr);
	GL_ARB_shading_language_packing = has_ext(glv, extensions, "GL_ARB_shading_language_packing\0".ptr);
	GL_EXT_texture_cube_map = has_ext(glv, extensions, "GL_EXT_texture_cube_map\0".ptr);
	GL_ARB_texture_stencil8 = has_ext(glv, extensions, "GL_ARB_texture_stencil8\0".ptr);
	GL_EXT_index_func = has_ext(glv, extensions, "GL_EXT_index_func\0".ptr);
	GL_OES_compressed_paletted_texture = has_ext(glv, extensions, "GL_OES_compressed_paletted_texture\0".ptr);
	GL_NV_depth_clamp = has_ext(glv, extensions, "GL_NV_depth_clamp\0".ptr);
	GL_NV_shader_buffer_load = has_ext(glv, extensions, "GL_NV_shader_buffer_load\0".ptr);
	GL_EXT_color_subtable = has_ext(glv, extensions, "GL_EXT_color_subtable\0".ptr);
	GL_SUNX_constant_data = has_ext(glv, extensions, "GL_SUNX_constant_data\0".ptr);
	GL_EXT_multi_draw_arrays = has_ext(glv, extensions, "GL_EXT_multi_draw_arrays\0".ptr);
	GL_ARB_shader_atomic_counters = has_ext(glv, extensions, "GL_ARB_shader_atomic_counters\0".ptr);
	GL_ARB_arrays_of_arrays = has_ext(glv, extensions, "GL_ARB_arrays_of_arrays\0".ptr);
	GL_NV_conditional_render = has_ext(glv, extensions, "GL_NV_conditional_render\0".ptr);
	GL_EXT_texture_env_combine = has_ext(glv, extensions, "GL_EXT_texture_env_combine\0".ptr);
	GL_NV_fog_distance = has_ext(glv, extensions, "GL_NV_fog_distance\0".ptr);
	GL_SGIX_async_histogram = has_ext(glv, extensions, "GL_SGIX_async_histogram\0".ptr);
	GL_MESA_resize_buffers = has_ext(glv, extensions, "GL_MESA_resize_buffers\0".ptr);
	GL_NV_light_max_exponent = has_ext(glv, extensions, "GL_NV_light_max_exponent\0".ptr);
	GL_NV_texture_env_combine4 = has_ext(glv, extensions, "GL_NV_texture_env_combine4\0".ptr);
	GL_ARB_texture_view = has_ext(glv, extensions, "GL_ARB_texture_view\0".ptr);
	GL_ARB_texture_env_combine = has_ext(glv, extensions, "GL_ARB_texture_env_combine\0".ptr);
	GL_ARB_map_buffer_range = has_ext(glv, extensions, "GL_ARB_map_buffer_range\0".ptr);
	GL_EXT_convolution = has_ext(glv, extensions, "GL_EXT_convolution\0".ptr);
	GL_NV_compute_program5 = has_ext(glv, extensions, "GL_NV_compute_program5\0".ptr);
	GL_NV_vertex_attrib_integer_64bit = has_ext(glv, extensions, "GL_NV_vertex_attrib_integer_64bit\0".ptr);
	GL_EXT_paletted_texture = has_ext(glv, extensions, "GL_EXT_paletted_texture\0".ptr);
	GL_ARB_texture_buffer_object = has_ext(glv, extensions, "GL_ARB_texture_buffer_object\0".ptr);
	GL_ATI_pn_triangles = has_ext(glv, extensions, "GL_ATI_pn_triangles\0".ptr);
	GL_SGIX_resample = has_ext(glv, extensions, "GL_SGIX_resample\0".ptr);
	GL_SGIX_flush_raster = has_ext(glv, extensions, "GL_SGIX_flush_raster\0".ptr);
	GL_EXT_light_texture = has_ext(glv, extensions, "GL_EXT_light_texture\0".ptr);
	GL_ARB_point_sprite = has_ext(glv, extensions, "GL_ARB_point_sprite\0".ptr);
	GL_ARB_half_float_pixel = has_ext(glv, extensions, "GL_ARB_half_float_pixel\0".ptr);
	GL_NV_tessellation_program5 = has_ext(glv, extensions, "GL_NV_tessellation_program5\0".ptr);
	GL_REND_screen_coordinates = has_ext(glv, extensions, "GL_REND_screen_coordinates\0".ptr);
	GL_EXT_shared_texture_palette = has_ext(glv, extensions, "GL_EXT_shared_texture_palette\0".ptr);
	GL_EXT_packed_float = has_ext(glv, extensions, "GL_EXT_packed_float\0".ptr);
	GL_OML_subsample = has_ext(glv, extensions, "GL_OML_subsample\0".ptr);
	GL_SGIX_vertex_preclip = has_ext(glv, extensions, "GL_SGIX_vertex_preclip\0".ptr);
	GL_SGIX_texture_scale_bias = has_ext(glv, extensions, "GL_SGIX_texture_scale_bias\0".ptr);
	GL_AMD_draw_buffers_blend = has_ext(glv, extensions, "GL_AMD_draw_buffers_blend\0".ptr);
	GL_MESA_window_pos = has_ext(glv, extensions, "GL_MESA_window_pos\0".ptr);
	GL_EXT_texture_array = has_ext(glv, extensions, "GL_EXT_texture_array\0".ptr);
	GL_NV_texture_barrier = has_ext(glv, extensions, "GL_NV_texture_barrier\0".ptr);
	GL_ARB_texture_query_levels = has_ext(glv, extensions, "GL_ARB_texture_query_levels\0".ptr);
	GL_NV_texgen_emboss = has_ext(glv, extensions, "GL_NV_texgen_emboss\0".ptr);
	GL_EXT_texture_swizzle = has_ext(glv, extensions, "GL_EXT_texture_swizzle\0".ptr);
	GL_ARB_texture_rg = has_ext(glv, extensions, "GL_ARB_texture_rg\0".ptr);
	GL_ARB_vertex_type_2_10_10_10_rev = has_ext(glv, extensions, "GL_ARB_vertex_type_2_10_10_10_rev\0".ptr);
	GL_ARB_fragment_shader = has_ext(glv, extensions, "GL_ARB_fragment_shader\0".ptr);
	GL_3DFX_tbuffer = has_ext(glv, extensions, "GL_3DFX_tbuffer\0".ptr);
	GL_GREMEDY_frame_terminator = has_ext(glv, extensions, "GL_GREMEDY_frame_terminator\0".ptr);
	GL_ARB_blend_func_extended = has_ext(glv, extensions, "GL_ARB_blend_func_extended\0".ptr);
	GL_EXT_separate_shader_objects = has_ext(glv, extensions, "GL_EXT_separate_shader_objects\0".ptr);
	GL_NV_texture_multisample = has_ext(glv, extensions, "GL_NV_texture_multisample\0".ptr);
	GL_ARB_shader_objects = has_ext(glv, extensions, "GL_ARB_shader_objects\0".ptr);
	GL_ARB_framebuffer_object = has_ext(glv, extensions, "GL_ARB_framebuffer_object\0".ptr);
	GL_ATI_envmap_bumpmap = has_ext(glv, extensions, "GL_ATI_envmap_bumpmap\0".ptr);
	GL_ARB_robust_buffer_access_behavior = has_ext(glv, extensions, "GL_ARB_robust_buffer_access_behavior\0".ptr);
	GL_ARB_shader_stencil_export = has_ext(glv, extensions, "GL_ARB_shader_stencil_export\0".ptr);
	GL_NV_texture_rectangle = has_ext(glv, extensions, "GL_NV_texture_rectangle\0".ptr);
	GL_ARB_enhanced_layouts = has_ext(glv, extensions, "GL_ARB_enhanced_layouts\0".ptr);
	GL_ARB_texture_rectangle = has_ext(glv, extensions, "GL_ARB_texture_rectangle\0".ptr);
	GL_SGI_texture_color_table = has_ext(glv, extensions, "GL_SGI_texture_color_table\0".ptr);
	GL_ATI_map_object_buffer = has_ext(glv, extensions, "GL_ATI_map_object_buffer\0".ptr);
	GL_ARB_robustness = has_ext(glv, extensions, "GL_ARB_robustness\0".ptr);
	GL_NV_pixel_data_range = has_ext(glv, extensions, "GL_NV_pixel_data_range\0".ptr);
	GL_EXT_framebuffer_blit = has_ext(glv, extensions, "GL_EXT_framebuffer_blit\0".ptr);
	GL_ARB_gpu_shader_fp64 = has_ext(glv, extensions, "GL_ARB_gpu_shader_fp64\0".ptr);
	GL_SGIX_depth_texture = has_ext(glv, extensions, "GL_SGIX_depth_texture\0".ptr);
	GL_EXT_vertex_weighting = has_ext(glv, extensions, "GL_EXT_vertex_weighting\0".ptr);
	GL_GREMEDY_string_marker = has_ext(glv, extensions, "GL_GREMEDY_string_marker\0".ptr);
	GL_ARB_texture_compression_bptc = has_ext(glv, extensions, "GL_ARB_texture_compression_bptc\0".ptr);
	GL_EXT_subtexture = has_ext(glv, extensions, "GL_EXT_subtexture\0".ptr);
	GL_EXT_pixel_transform_color_table = has_ext(glv, extensions, "GL_EXT_pixel_transform_color_table\0".ptr);
	GL_EXT_texture_compression_rgtc = has_ext(glv, extensions, "GL_EXT_texture_compression_rgtc\0".ptr);
	GL_SGIX_depth_pass_instrument = has_ext(glv, extensions, "GL_SGIX_depth_pass_instrument\0".ptr);
	GL_ARB_shader_precision = has_ext(glv, extensions, "GL_ARB_shader_precision\0".ptr);
	GL_NV_evaluators = has_ext(glv, extensions, "GL_NV_evaluators\0".ptr);
	GL_SGIS_texture_filter4 = has_ext(glv, extensions, "GL_SGIS_texture_filter4\0".ptr);
	GL_AMD_performance_monitor = has_ext(glv, extensions, "GL_AMD_performance_monitor\0".ptr);
	GL_NV_geometry_shader4 = has_ext(glv, extensions, "GL_NV_geometry_shader4\0".ptr);
	GL_EXT_stencil_clear_tag = has_ext(glv, extensions, "GL_EXT_stencil_clear_tag\0".ptr);
	GL_NV_vertex_program1_1 = has_ext(glv, extensions, "GL_NV_vertex_program1_1\0".ptr);
	GL_NV_present_video = has_ext(glv, extensions, "GL_NV_present_video\0".ptr);
	GL_ARB_texture_compression_rgtc = has_ext(glv, extensions, "GL_ARB_texture_compression_rgtc\0".ptr);
	GL_HP_convolution_border_modes = has_ext(glv, extensions, "GL_HP_convolution_border_modes\0".ptr);
	GL_EXT_gpu_program_parameters = has_ext(glv, extensions, "GL_EXT_gpu_program_parameters\0".ptr);
	GL_SGIX_list_priority = has_ext(glv, extensions, "GL_SGIX_list_priority\0".ptr);
	GL_ARB_stencil_texturing = has_ext(glv, extensions, "GL_ARB_stencil_texturing\0".ptr);
	GL_SGIX_fog_offset = has_ext(glv, extensions, "GL_SGIX_fog_offset\0".ptr);
	GL_ARB_draw_elements_base_vertex = has_ext(glv, extensions, "GL_ARB_draw_elements_base_vertex\0".ptr);
	GL_INGR_interlace_read = has_ext(glv, extensions, "GL_INGR_interlace_read\0".ptr);
	GL_NV_transform_feedback = has_ext(glv, extensions, "GL_NV_transform_feedback\0".ptr);
	GL_NV_fragment_program = has_ext(glv, extensions, "GL_NV_fragment_program\0".ptr);
	GL_AMD_stencil_operation_extended = has_ext(glv, extensions, "GL_AMD_stencil_operation_extended\0".ptr);
	GL_ARB_seamless_cubemap_per_texture = has_ext(glv, extensions, "GL_ARB_seamless_cubemap_per_texture\0".ptr);
	GL_ARB_instanced_arrays = has_ext(glv, extensions, "GL_ARB_instanced_arrays\0".ptr);
	GL_EXT_polygon_offset = has_ext(glv, extensions, "GL_EXT_polygon_offset\0".ptr);
	GL_NV_vertex_array_range2 = has_ext(glv, extensions, "GL_NV_vertex_array_range2\0".ptr);
	GL_AMD_sparse_texture = has_ext(glv, extensions, "GL_AMD_sparse_texture\0".ptr);
	GL_NV_fence = has_ext(glv, extensions, "GL_NV_fence\0".ptr);
	GL_ARB_texture_buffer_range = has_ext(glv, extensions, "GL_ARB_texture_buffer_range\0".ptr);
	GL_SUN_mesh_array = has_ext(glv, extensions, "GL_SUN_mesh_array\0".ptr);
	GL_ARB_vertex_attrib_binding = has_ext(glv, extensions, "GL_ARB_vertex_attrib_binding\0".ptr);
	GL_ARB_framebuffer_no_attachments = has_ext(glv, extensions, "GL_ARB_framebuffer_no_attachments\0".ptr);
	GL_ARB_cl_event = has_ext(glv, extensions, "GL_ARB_cl_event\0".ptr);
	GL_NV_packed_depth_stencil = has_ext(glv, extensions, "GL_NV_packed_depth_stencil\0".ptr);
	GL_OES_single_precision = has_ext(glv, extensions, "GL_OES_single_precision\0".ptr);
	GL_NV_primitive_restart = has_ext(glv, extensions, "GL_NV_primitive_restart\0".ptr);
	GL_SUN_global_alpha = has_ext(glv, extensions, "GL_SUN_global_alpha\0".ptr);
	GL_EXT_texture_object = has_ext(glv, extensions, "GL_EXT_texture_object\0".ptr);
	GL_AMD_name_gen_delete = has_ext(glv, extensions, "GL_AMD_name_gen_delete\0".ptr);
	GL_NV_texture_compression_vtc = has_ext(glv, extensions, "GL_NV_texture_compression_vtc\0".ptr);
	GL_SGIX_ycrcb_subsample = has_ext(glv, extensions, "GL_SGIX_ycrcb_subsample\0".ptr);
	GL_NV_texture_shader3 = has_ext(glv, extensions, "GL_NV_texture_shader3\0".ptr);
	GL_NV_texture_shader2 = has_ext(glv, extensions, "GL_NV_texture_shader2\0".ptr);
	GL_EXT_texture = has_ext(glv, extensions, "GL_EXT_texture\0".ptr);
	GL_ARB_buffer_storage = has_ext(glv, extensions, "GL_ARB_buffer_storage\0".ptr);
	GL_AMD_shader_atomic_counter_ops = has_ext(glv, extensions, "GL_AMD_shader_atomic_counter_ops\0".ptr);
	GL_APPLE_vertex_program_evaluators = has_ext(glv, extensions, "GL_APPLE_vertex_program_evaluators\0".ptr);
	GL_ARB_multi_bind = has_ext(glv, extensions, "GL_ARB_multi_bind\0".ptr);
	GL_ARB_explicit_uniform_location = has_ext(glv, extensions, "GL_ARB_explicit_uniform_location\0".ptr);
	GL_ARB_depth_buffer_float = has_ext(glv, extensions, "GL_ARB_depth_buffer_float\0".ptr);
	GL_SGIX_shadow_ambient = has_ext(glv, extensions, "GL_SGIX_shadow_ambient\0".ptr);
	GL_ARB_texture_cube_map = has_ext(glv, extensions, "GL_ARB_texture_cube_map\0".ptr);
	GL_AMD_vertex_shader_viewport_index = has_ext(glv, extensions, "GL_AMD_vertex_shader_viewport_index\0".ptr);
	GL_NV_vertex_buffer_unified_memory = has_ext(glv, extensions, "GL_NV_vertex_buffer_unified_memory\0".ptr);
	GL_EXT_texture_env_dot3 = has_ext(glv, extensions, "GL_EXT_texture_env_dot3\0".ptr);
	GL_ATI_texture_env_combine3 = has_ext(glv, extensions, "GL_ATI_texture_env_combine3\0".ptr);
	GL_ARB_map_buffer_alignment = has_ext(glv, extensions, "GL_ARB_map_buffer_alignment\0".ptr);
	GL_NV_blend_equation_advanced = has_ext(glv, extensions, "GL_NV_blend_equation_advanced\0".ptr);
	GL_SGIS_sharpen_texture = has_ext(glv, extensions, "GL_SGIS_sharpen_texture\0".ptr);
	GL_ARB_vertex_program = has_ext(glv, extensions, "GL_ARB_vertex_program\0".ptr);
	GL_ARB_texture_rgb10_a2ui = has_ext(glv, extensions, "GL_ARB_texture_rgb10_a2ui\0".ptr);
	GL_OML_interlace = has_ext(glv, extensions, "GL_OML_interlace\0".ptr);
	GL_ATI_pixel_format_float = has_ext(glv, extensions, "GL_ATI_pixel_format_float\0".ptr);
	GL_ARB_vertex_buffer_object = has_ext(glv, extensions, "GL_ARB_vertex_buffer_object\0".ptr);
	GL_EXT_shadow_funcs = has_ext(glv, extensions, "GL_EXT_shadow_funcs\0".ptr);
	GL_ATI_text_fragment_shader = has_ext(glv, extensions, "GL_ATI_text_fragment_shader\0".ptr);
	GL_NV_vertex_array_range = has_ext(glv, extensions, "GL_NV_vertex_array_range\0".ptr);
	GL_SGIX_fragment_lighting = has_ext(glv, extensions, "GL_SGIX_fragment_lighting\0".ptr);
	GL_NV_texture_expand_normal = has_ext(glv, extensions, "GL_NV_texture_expand_normal\0".ptr);
	GL_NV_framebuffer_multisample_coverage = has_ext(glv, extensions, "GL_NV_framebuffer_multisample_coverage\0".ptr);
	GL_EXT_timer_query = has_ext(glv, extensions, "GL_EXT_timer_query\0".ptr);
	GL_EXT_vertex_array_bgra = has_ext(glv, extensions, "GL_EXT_vertex_array_bgra\0".ptr);
	GL_NV_bindless_texture = has_ext(glv, extensions, "GL_NV_bindless_texture\0".ptr);
	GL_KHR_debug = has_ext(glv, extensions, "GL_KHR_debug\0".ptr);
	GL_SGIS_texture_border_clamp = has_ext(glv, extensions, "GL_SGIS_texture_border_clamp\0".ptr);
	GL_ATI_vertex_attrib_array_object = has_ext(glv, extensions, "GL_ATI_vertex_attrib_array_object\0".ptr);
	GL_SGIX_clipmap = has_ext(glv, extensions, "GL_SGIX_clipmap\0".ptr);
	GL_EXT_geometry_shader4 = has_ext(glv, extensions, "GL_EXT_geometry_shader4\0".ptr);
	GL_MESA_ycbcr_texture = has_ext(glv, extensions, "GL_MESA_ycbcr_texture\0".ptr);
	GL_MESAX_texture_stack = has_ext(glv, extensions, "GL_MESAX_texture_stack\0".ptr);
	GL_AMD_seamless_cubemap_per_texture = has_ext(glv, extensions, "GL_AMD_seamless_cubemap_per_texture\0".ptr);
	GL_EXT_bindable_uniform = has_ext(glv, extensions, "GL_EXT_bindable_uniform\0".ptr);
	GL_ARB_fragment_program_shadow = has_ext(glv, extensions, "GL_ARB_fragment_program_shadow\0".ptr);
	GL_ATI_element_array = has_ext(glv, extensions, "GL_ATI_element_array\0".ptr);
	GL_AMD_texture_texture4 = has_ext(glv, extensions, "GL_AMD_texture_texture4\0".ptr);
	GL_SGIX_reference_plane = has_ext(glv, extensions, "GL_SGIX_reference_plane\0".ptr);
	GL_EXT_stencil_two_side = has_ext(glv, extensions, "GL_EXT_stencil_two_side\0".ptr);
	GL_SGIX_texture_lod_bias = has_ext(glv, extensions, "GL_SGIX_texture_lod_bias\0".ptr);
	GL_NV_explicit_multisample = has_ext(glv, extensions, "GL_NV_explicit_multisample\0".ptr);
	GL_IBM_static_data = has_ext(glv, extensions, "GL_IBM_static_data\0".ptr);
	GL_EXT_clip_volume_hint = has_ext(glv, extensions, "GL_EXT_clip_volume_hint\0".ptr);
	GL_EXT_texture_perturb_normal = has_ext(glv, extensions, "GL_EXT_texture_perturb_normal\0".ptr);
	GL_NV_fragment_program2 = has_ext(glv, extensions, "GL_NV_fragment_program2\0".ptr);
	GL_NV_fragment_program4 = has_ext(glv, extensions, "GL_NV_fragment_program4\0".ptr);
	GL_EXT_point_parameters = has_ext(glv, extensions, "GL_EXT_point_parameters\0".ptr);
	GL_PGI_misc_hints = has_ext(glv, extensions, "GL_PGI_misc_hints\0".ptr);
	GL_SGIX_subsample = has_ext(glv, extensions, "GL_SGIX_subsample\0".ptr);
	GL_AMD_shader_stencil_export = has_ext(glv, extensions, "GL_AMD_shader_stencil_export\0".ptr);
	GL_ARB_shader_texture_lod = has_ext(glv, extensions, "GL_ARB_shader_texture_lod\0".ptr);
	GL_ARB_vertex_shader = has_ext(glv, extensions, "GL_ARB_vertex_shader\0".ptr);
	GL_ARB_depth_clamp = has_ext(glv, extensions, "GL_ARB_depth_clamp\0".ptr);
	GL_SGIS_texture_select = has_ext(glv, extensions, "GL_SGIS_texture_select\0".ptr);
	GL_NV_texture_shader = has_ext(glv, extensions, "GL_NV_texture_shader\0".ptr);
	GL_ARB_tessellation_shader = has_ext(glv, extensions, "GL_ARB_tessellation_shader\0".ptr);
	GL_EXT_draw_buffers2 = has_ext(glv, extensions, "GL_EXT_draw_buffers2\0".ptr);
	GL_ARB_vertex_attrib_64bit = has_ext(glv, extensions, "GL_ARB_vertex_attrib_64bit\0".ptr);
	GL_WIN_specular_fog = has_ext(glv, extensions, "GL_WIN_specular_fog\0".ptr);
	GL_AMD_interleaved_elements = has_ext(glv, extensions, "GL_AMD_interleaved_elements\0".ptr);
	GL_ARB_fragment_program = has_ext(glv, extensions, "GL_ARB_fragment_program\0".ptr);
	GL_OML_resample = has_ext(glv, extensions, "GL_OML_resample\0".ptr);
	GL_APPLE_ycbcr_422 = has_ext(glv, extensions, "GL_APPLE_ycbcr_422\0".ptr);
	GL_SGIX_texture_add_env = has_ext(glv, extensions, "GL_SGIX_texture_add_env\0".ptr);
	GL_ARB_shadow_ambient = has_ext(glv, extensions, "GL_ARB_shadow_ambient\0".ptr);
	GL_ARB_texture_storage = has_ext(glv, extensions, "GL_ARB_texture_storage\0".ptr);
	GL_EXT_pixel_buffer_object = has_ext(glv, extensions, "GL_EXT_pixel_buffer_object\0".ptr);
	GL_ARB_copy_image = has_ext(glv, extensions, "GL_ARB_copy_image\0".ptr);
	GL_SGIS_pixel_texture = has_ext(glv, extensions, "GL_SGIS_pixel_texture\0".ptr);
	GL_SGIS_generate_mipmap = has_ext(glv, extensions, "GL_SGIS_generate_mipmap\0".ptr);
	GL_SGIX_instruments = has_ext(glv, extensions, "GL_SGIX_instruments\0".ptr);
	GL_HP_texture_lighting = has_ext(glv, extensions, "GL_HP_texture_lighting\0".ptr);
	GL_ARB_shader_storage_buffer_object = has_ext(glv, extensions, "GL_ARB_shader_storage_buffer_object\0".ptr);
	GL_EXT_blend_minmax = has_ext(glv, extensions, "GL_EXT_blend_minmax\0".ptr);
	GL_MESA_pack_invert = has_ext(glv, extensions, "GL_MESA_pack_invert\0".ptr);
	GL_ARB_base_instance = has_ext(glv, extensions, "GL_ARB_base_instance\0".ptr);
	GL_SGIX_convolution_accuracy = has_ext(glv, extensions, "GL_SGIX_convolution_accuracy\0".ptr);
	GL_PGI_vertex_hints = has_ext(glv, extensions, "GL_PGI_vertex_hints\0".ptr);
	GL_EXT_texture_integer = has_ext(glv, extensions, "GL_EXT_texture_integer\0".ptr);
	GL_ARB_texture_multisample = has_ext(glv, extensions, "GL_ARB_texture_multisample\0".ptr);
	GL_S3_s3tc = has_ext(glv, extensions, "GL_S3_s3tc\0".ptr);
	GL_ARB_query_buffer_object = has_ext(glv, extensions, "GL_ARB_query_buffer_object\0".ptr);
	GL_AMD_vertex_shader_tessellator = has_ext(glv, extensions, "GL_AMD_vertex_shader_tessellator\0".ptr);
	GL_ARB_invalidate_subdata = has_ext(glv, extensions, "GL_ARB_invalidate_subdata\0".ptr);
	GL_EXT_index_material = has_ext(glv, extensions, "GL_EXT_index_material\0".ptr);
	GL_NV_blend_equation_advanced_coherent = has_ext(glv, extensions, "GL_NV_blend_equation_advanced_coherent\0".ptr);
	GL_INTEL_parallel_arrays = has_ext(glv, extensions, "GL_INTEL_parallel_arrays\0".ptr);
	GL_ATI_draw_buffers = has_ext(glv, extensions, "GL_ATI_draw_buffers\0".ptr);
	GL_EXT_cmyka = has_ext(glv, extensions, "GL_EXT_cmyka\0".ptr);
	GL_SGIX_pixel_texture = has_ext(glv, extensions, "GL_SGIX_pixel_texture\0".ptr);
	GL_APPLE_specular_vector = has_ext(glv, extensions, "GL_APPLE_specular_vector\0".ptr);
	GL_ARB_compatibility = has_ext(glv, extensions, "GL_ARB_compatibility\0".ptr);
	GL_ARB_timer_query = has_ext(glv, extensions, "GL_ARB_timer_query\0".ptr);
	GL_SGIX_interlace = has_ext(glv, extensions, "GL_SGIX_interlace\0".ptr);
	GL_NV_parameter_buffer_object = has_ext(glv, extensions, "GL_NV_parameter_buffer_object\0".ptr);
	GL_AMD_shader_trinary_minmax = has_ext(glv, extensions, "GL_AMD_shader_trinary_minmax\0".ptr);
	GL_EXT_rescale_normal = has_ext(glv, extensions, "GL_EXT_rescale_normal\0".ptr);
	GL_ARB_pixel_buffer_object = has_ext(glv, extensions, "GL_ARB_pixel_buffer_object\0".ptr);
	GL_ARB_uniform_buffer_object = has_ext(glv, extensions, "GL_ARB_uniform_buffer_object\0".ptr);
	GL_ARB_vertex_type_10f_11f_11f_rev = has_ext(glv, extensions, "GL_ARB_vertex_type_10f_11f_11f_rev\0".ptr);
	GL_ARB_texture_swizzle = has_ext(glv, extensions, "GL_ARB_texture_swizzle\0".ptr);
	GL_NV_transform_feedback2 = has_ext(glv, extensions, "GL_NV_transform_feedback2\0".ptr);
	GL_SGIX_async_pixel = has_ext(glv, extensions, "GL_SGIX_async_pixel\0".ptr);
	GL_NV_fragment_program_option = has_ext(glv, extensions, "GL_NV_fragment_program_option\0".ptr);
	GL_ARB_explicit_attrib_location = has_ext(glv, extensions, "GL_ARB_explicit_attrib_location\0".ptr);
	GL_EXT_blend_color = has_ext(glv, extensions, "GL_EXT_blend_color\0".ptr);
	GL_EXT_stencil_wrap = has_ext(glv, extensions, "GL_EXT_stencil_wrap\0".ptr);
	GL_EXT_index_array_formats = has_ext(glv, extensions, "GL_EXT_index_array_formats\0".ptr);
	GL_EXT_histogram = has_ext(glv, extensions, "GL_EXT_histogram\0".ptr);
	GL_SGIS_point_parameters = has_ext(glv, extensions, "GL_SGIS_point_parameters\0".ptr);
	GL_EXT_direct_state_access = has_ext(glv, extensions, "GL_EXT_direct_state_access\0".ptr);
	GL_AMD_sample_positions = has_ext(glv, extensions, "GL_AMD_sample_positions\0".ptr);
	GL_NV_vertex_program = has_ext(glv, extensions, "GL_NV_vertex_program\0".ptr);
	GL_NVX_conditional_render = has_ext(glv, extensions, "GL_NVX_conditional_render\0".ptr);
	GL_EXT_vertex_shader = has_ext(glv, extensions, "GL_EXT_vertex_shader\0".ptr);
	GL_EXT_blend_func_separate = has_ext(glv, extensions, "GL_EXT_blend_func_separate\0".ptr);
	GL_APPLE_fence = has_ext(glv, extensions, "GL_APPLE_fence\0".ptr);
	GL_OES_byte_coordinates = has_ext(glv, extensions, "GL_OES_byte_coordinates\0".ptr);
	GL_ARB_transpose_matrix = has_ext(glv, extensions, "GL_ARB_transpose_matrix\0".ptr);
	GL_ARB_provoking_vertex = has_ext(glv, extensions, "GL_ARB_provoking_vertex\0".ptr);
	GL_EXT_fog_coord = has_ext(glv, extensions, "GL_EXT_fog_coord\0".ptr);
	GL_EXT_vertex_array = has_ext(glv, extensions, "GL_EXT_vertex_array\0".ptr);
	GL_ARB_half_float_vertex = has_ext(glv, extensions, "GL_ARB_half_float_vertex\0".ptr);
	GL_EXT_blend_equation_separate = has_ext(glv, extensions, "GL_EXT_blend_equation_separate\0".ptr);
	GL_ARB_multi_draw_indirect = has_ext(glv, extensions, "GL_ARB_multi_draw_indirect\0".ptr);
	GL_NV_copy_image = has_ext(glv, extensions, "GL_NV_copy_image\0".ptr);
	GL_ARB_fragment_layer_viewport = has_ext(glv, extensions, "GL_ARB_fragment_layer_viewport\0".ptr);
	GL_ARB_transform_feedback2 = has_ext(glv, extensions, "GL_ARB_transform_feedback2\0".ptr);
	GL_ARB_transform_feedback3 = has_ext(glv, extensions, "GL_ARB_transform_feedback3\0".ptr);
	GL_SGIX_ycrcba = has_ext(glv, extensions, "GL_SGIX_ycrcba\0".ptr);
	GL_EXT_bgra = has_ext(glv, extensions, "GL_EXT_bgra\0".ptr);
	GL_EXT_texture_compression_s3tc = has_ext(glv, extensions, "GL_EXT_texture_compression_s3tc\0".ptr);
	GL_EXT_pixel_transform = has_ext(glv, extensions, "GL_EXT_pixel_transform\0".ptr);
	GL_ARB_conservative_depth = has_ext(glv, extensions, "GL_ARB_conservative_depth\0".ptr);
	GL_ATI_fragment_shader = has_ext(glv, extensions, "GL_ATI_fragment_shader\0".ptr);
	GL_ARB_vertex_array_object = has_ext(glv, extensions, "GL_ARB_vertex_array_object\0".ptr);
	GL_SUN_triangle_list = has_ext(glv, extensions, "GL_SUN_triangle_list\0".ptr);
	GL_EXT_texture_env_add = has_ext(glv, extensions, "GL_EXT_texture_env_add\0".ptr);
	GL_EXT_packed_depth_stencil = has_ext(glv, extensions, "GL_EXT_packed_depth_stencil\0".ptr);
	GL_EXT_texture_mirror_clamp = has_ext(glv, extensions, "GL_EXT_texture_mirror_clamp\0".ptr);
	GL_NV_multisample_filter_hint = has_ext(glv, extensions, "GL_NV_multisample_filter_hint\0".ptr);
	GL_APPLE_float_pixels = has_ext(glv, extensions, "GL_APPLE_float_pixels\0".ptr);
	GL_ARB_transform_feedback_instanced = has_ext(glv, extensions, "GL_ARB_transform_feedback_instanced\0".ptr);
	GL_SGIX_async = has_ext(glv, extensions, "GL_SGIX_async\0".ptr);
	GL_EXT_texture_compression_latc = has_ext(glv, extensions, "GL_EXT_texture_compression_latc\0".ptr);
	GL_NV_shader_atomic_float = has_ext(glv, extensions, "GL_NV_shader_atomic_float\0".ptr);
	GL_ARB_shading_language_100 = has_ext(glv, extensions, "GL_ARB_shading_language_100\0".ptr);
	GL_ARB_texture_mirror_clamp_to_edge = has_ext(glv, extensions, "GL_ARB_texture_mirror_clamp_to_edge\0".ptr);
	GL_NV_gpu_shader5 = has_ext(glv, extensions, "GL_NV_gpu_shader5\0".ptr);
	GL_ARB_ES2_compatibility = has_ext(glv, extensions, "GL_ARB_ES2_compatibility\0".ptr);
	GL_ARB_indirect_parameters = has_ext(glv, extensions, "GL_ARB_indirect_parameters\0".ptr);
	GL_NV_half_float = has_ext(glv, extensions, "GL_NV_half_float\0".ptr);
	GL_EXT_coordinate_frame = has_ext(glv, extensions, "GL_EXT_coordinate_frame\0".ptr);
	GL_ATI_texture_mirror_once = has_ext(glv, extensions, "GL_ATI_texture_mirror_once\0".ptr);
	GL_IBM_rasterpos_clip = has_ext(glv, extensions, "GL_IBM_rasterpos_clip\0".ptr);
	GL_SGIX_shadow = has_ext(glv, extensions, "GL_SGIX_shadow\0".ptr);
	GL_NV_deep_texture3D = has_ext(glv, extensions, "GL_NV_deep_texture3D\0".ptr);
	GL_ARB_shader_draw_parameters = has_ext(glv, extensions, "GL_ARB_shader_draw_parameters\0".ptr);
	GL_SGIX_calligraphic_fragment = has_ext(glv, extensions, "GL_SGIX_calligraphic_fragment\0".ptr);
	GL_ARB_shader_bit_encoding = has_ext(glv, extensions, "GL_ARB_shader_bit_encoding\0".ptr);
	GL_EXT_compiled_vertex_array = has_ext(glv, extensions, "GL_EXT_compiled_vertex_array\0".ptr);
	GL_NV_depth_buffer_float = has_ext(glv, extensions, "GL_NV_depth_buffer_float\0".ptr);
	GL_NV_occlusion_query = has_ext(glv, extensions, "GL_NV_occlusion_query\0".ptr);
	GL_APPLE_flush_buffer_range = has_ext(glv, extensions, "GL_APPLE_flush_buffer_range\0".ptr);
	GL_ARB_imaging = has_ext(glv, extensions, "GL_ARB_imaging\0".ptr);
	GL_ARB_draw_buffers_blend = has_ext(glv, extensions, "GL_ARB_draw_buffers_blend\0".ptr);
	GL_NV_blend_square = has_ext(glv, extensions, "GL_NV_blend_square\0".ptr);
	GL_AMD_blend_minmax_factor = has_ext(glv, extensions, "GL_AMD_blend_minmax_factor\0".ptr);
	GL_EXT_texture_sRGB_decode = has_ext(glv, extensions, "GL_EXT_texture_sRGB_decode\0".ptr);
	GL_ARB_shading_language_420pack = has_ext(glv, extensions, "GL_ARB_shading_language_420pack\0".ptr);
	GL_ATI_meminfo = has_ext(glv, extensions, "GL_ATI_meminfo\0".ptr);
	GL_EXT_abgr = has_ext(glv, extensions, "GL_EXT_abgr\0".ptr);
	GL_AMD_pinned_memory = has_ext(glv, extensions, "GL_AMD_pinned_memory\0".ptr);
	GL_EXT_texture_snorm = has_ext(glv, extensions, "GL_EXT_texture_snorm\0".ptr);
	GL_SGIX_texture_coordinate_clamp = has_ext(glv, extensions, "GL_SGIX_texture_coordinate_clamp\0".ptr);
	GL_ARB_clear_buffer_object = has_ext(glv, extensions, "GL_ARB_clear_buffer_object\0".ptr);
	GL_ARB_multisample = has_ext(glv, extensions, "GL_ARB_multisample\0".ptr);
	GL_ARB_sample_shading = has_ext(glv, extensions, "GL_ARB_sample_shading\0".ptr);
	GL_INTEL_map_texture = has_ext(glv, extensions, "GL_INTEL_map_texture\0".ptr);
	GL_ARB_texture_env_crossbar = has_ext(glv, extensions, "GL_ARB_texture_env_crossbar\0".ptr);
	GL_EXT_422_pixels = has_ext(glv, extensions, "GL_EXT_422_pixels\0".ptr);
	GL_ARB_compute_shader = has_ext(glv, extensions, "GL_ARB_compute_shader\0".ptr);
	GL_EXT_blend_logic_op = has_ext(glv, extensions, "GL_EXT_blend_logic_op\0".ptr);
	GL_IBM_cull_vertex = has_ext(glv, extensions, "GL_IBM_cull_vertex\0".ptr);
	GL_IBM_vertex_array_lists = has_ext(glv, extensions, "GL_IBM_vertex_array_lists\0".ptr);
	GL_ARB_color_buffer_float = has_ext(glv, extensions, "GL_ARB_color_buffer_float\0".ptr);
	GL_ARB_bindless_texture = has_ext(glv, extensions, "GL_ARB_bindless_texture\0".ptr);
	GL_ARB_window_pos = has_ext(glv, extensions, "GL_ARB_window_pos\0".ptr);
	GL_ARB_internalformat_query = has_ext(glv, extensions, "GL_ARB_internalformat_query\0".ptr);
	GL_ARB_shadow = has_ext(glv, extensions, "GL_ARB_shadow\0".ptr);
	GL_ARB_texture_mirrored_repeat = has_ext(glv, extensions, "GL_ARB_texture_mirrored_repeat\0".ptr);
	GL_EXT_shader_image_load_store = has_ext(glv, extensions, "GL_EXT_shader_image_load_store\0".ptr);
	GL_EXT_copy_texture = has_ext(glv, extensions, "GL_EXT_copy_texture\0".ptr);
	GL_NV_register_combiners2 = has_ext(glv, extensions, "GL_NV_register_combiners2\0".ptr);
	GL_SGIX_ir_instrument1 = has_ext(glv, extensions, "GL_SGIX_ir_instrument1\0".ptr);
	GL_NV_draw_texture = has_ext(glv, extensions, "GL_NV_draw_texture\0".ptr);
	GL_EXT_texture_shared_exponent = has_ext(glv, extensions, "GL_EXT_texture_shared_exponent\0".ptr);
	GL_EXT_draw_instanced = has_ext(glv, extensions, "GL_EXT_draw_instanced\0".ptr);
	GL_NV_copy_depth_to_color = has_ext(glv, extensions, "GL_NV_copy_depth_to_color\0".ptr);
	GL_ARB_viewport_array = has_ext(glv, extensions, "GL_ARB_viewport_array\0".ptr);
	GL_ARB_separate_shader_objects = has_ext(glv, extensions, "GL_ARB_separate_shader_objects\0".ptr);
	GL_EXT_depth_bounds_test = has_ext(glv, extensions, "GL_EXT_depth_bounds_test\0".ptr);
	GL_HP_image_transform = has_ext(glv, extensions, "GL_HP_image_transform\0".ptr);
	GL_ARB_texture_env_add = has_ext(glv, extensions, "GL_ARB_texture_env_add\0".ptr);
	GL_NV_video_capture = has_ext(glv, extensions, "GL_NV_video_capture\0".ptr);
	GL_ARB_sampler_objects = has_ext(glv, extensions, "GL_ARB_sampler_objects\0".ptr);
	GL_ARB_matrix_palette = has_ext(glv, extensions, "GL_ARB_matrix_palette\0".ptr);
	GL_SGIS_texture_color_mask = has_ext(glv, extensions, "GL_SGIS_texture_color_mask\0".ptr);
	GL_EXT_packed_pixels = has_ext(glv, extensions, "GL_EXT_packed_pixels\0".ptr);
	GL_ARB_texture_compression = has_ext(glv, extensions, "GL_ARB_texture_compression\0".ptr);
	GL_APPLE_aux_depth_stencil = has_ext(glv, extensions, "GL_APPLE_aux_depth_stencil\0".ptr);
	GL_ARB_shader_subroutine = has_ext(glv, extensions, "GL_ARB_shader_subroutine\0".ptr);
	GL_EXT_framebuffer_sRGB = has_ext(glv, extensions, "GL_EXT_framebuffer_sRGB\0".ptr);
	GL_ARB_texture_storage_multisample = has_ext(glv, extensions, "GL_ARB_texture_storage_multisample\0".ptr);
	GL_EXT_vertex_attrib_64bit = has_ext(glv, extensions, "GL_EXT_vertex_attrib_64bit\0".ptr);
	GL_ARB_depth_texture = has_ext(glv, extensions, "GL_ARB_depth_texture\0".ptr);
	GL_NV_shader_buffer_store = has_ext(glv, extensions, "GL_NV_shader_buffer_store\0".ptr);
	GL_OES_query_matrix = has_ext(glv, extensions, "GL_OES_query_matrix\0".ptr);
	GL_APPLE_texture_range = has_ext(glv, extensions, "GL_APPLE_texture_range\0".ptr);
	GL_NV_shader_storage_buffer_object = has_ext(glv, extensions, "GL_NV_shader_storage_buffer_object\0".ptr);
	GL_ARB_texture_query_lod = has_ext(glv, extensions, "GL_ARB_texture_query_lod\0".ptr);
	GL_ARB_copy_buffer = has_ext(glv, extensions, "GL_ARB_copy_buffer\0".ptr);
	GL_ARB_shader_image_size = has_ext(glv, extensions, "GL_ARB_shader_image_size\0".ptr);
	GL_NV_shader_atomic_counters = has_ext(glv, extensions, "GL_NV_shader_atomic_counters\0".ptr);
	GL_APPLE_object_purgeable = has_ext(glv, extensions, "GL_APPLE_object_purgeable\0".ptr);
	GL_ARB_occlusion_query = has_ext(glv, extensions, "GL_ARB_occlusion_query\0".ptr);
	GL_INGR_color_clamp = has_ext(glv, extensions, "GL_INGR_color_clamp\0".ptr);
	GL_SGI_color_table = has_ext(glv, extensions, "GL_SGI_color_table\0".ptr);
	GL_NV_gpu_program5_mem_extended = has_ext(glv, extensions, "GL_NV_gpu_program5_mem_extended\0".ptr);
	GL_ARB_texture_cube_map_array = has_ext(glv, extensions, "GL_ARB_texture_cube_map_array\0".ptr);
	GL_SGIX_scalebias_hint = has_ext(glv, extensions, "GL_SGIX_scalebias_hint\0".ptr);
	GL_EXT_gpu_shader4 = has_ext(glv, extensions, "GL_EXT_gpu_shader4\0".ptr);
	GL_NV_geometry_program4 = has_ext(glv, extensions, "GL_NV_geometry_program4\0".ptr);
	GL_EXT_framebuffer_multisample_blit_scaled = has_ext(glv, extensions, "GL_EXT_framebuffer_multisample_blit_scaled\0".ptr);
	GL_AMD_debug_output = has_ext(glv, extensions, "GL_AMD_debug_output\0".ptr);
	GL_ARB_texture_border_clamp = has_ext(glv, extensions, "GL_ARB_texture_border_clamp\0".ptr);
	GL_ARB_fragment_coord_conventions = has_ext(glv, extensions, "GL_ARB_fragment_coord_conventions\0".ptr);
	GL_ARB_multitexture = has_ext(glv, extensions, "GL_ARB_multitexture\0".ptr);
	GL_SGIX_polynomial_ffd = has_ext(glv, extensions, "GL_SGIX_polynomial_ffd\0".ptr);
	GL_EXT_provoking_vertex = has_ext(glv, extensions, "GL_EXT_provoking_vertex\0".ptr);
	GL_ARB_point_parameters = has_ext(glv, extensions, "GL_ARB_point_parameters\0".ptr);
	GL_ARB_shader_image_load_store = has_ext(glv, extensions, "GL_ARB_shader_image_load_store\0".ptr);
	GL_HP_occlusion_test = has_ext(glv, extensions, "GL_HP_occlusion_test\0".ptr);
	GL_ARB_ES3_compatibility = has_ext(glv, extensions, "GL_ARB_ES3_compatibility\0".ptr);
	GL_SGIX_framezoom = has_ext(glv, extensions, "GL_SGIX_framezoom\0".ptr);
	GL_ARB_texture_buffer_object_rgb32 = has_ext(glv, extensions, "GL_ARB_texture_buffer_object_rgb32\0".ptr);
	GL_NV_bindless_multi_draw_indirect = has_ext(glv, extensions, "GL_NV_bindless_multi_draw_indirect\0".ptr);
	GL_SGIX_texture_multi_buffer = has_ext(glv, extensions, "GL_SGIX_texture_multi_buffer\0".ptr);
	GL_EXT_transform_feedback = has_ext(glv, extensions, "GL_EXT_transform_feedback\0".ptr);
	GL_KHR_texture_compression_astc_ldr = has_ext(glv, extensions, "GL_KHR_texture_compression_astc_ldr\0".ptr);
	GL_3DFX_multisample = has_ext(glv, extensions, "GL_3DFX_multisample\0".ptr);
	GL_ARB_texture_env_dot3 = has_ext(glv, extensions, "GL_ARB_texture_env_dot3\0".ptr);
	GL_NV_gpu_program4 = has_ext(glv, extensions, "GL_NV_gpu_program4\0".ptr);
	GL_NV_gpu_program5 = has_ext(glv, extensions, "GL_NV_gpu_program5\0".ptr);
	GL_NV_float_buffer = has_ext(glv, extensions, "GL_NV_float_buffer\0".ptr);
	GL_SGIS_texture_edge_clamp = has_ext(glv, extensions, "GL_SGIS_texture_edge_clamp\0".ptr);
	GL_ARB_framebuffer_sRGB = has_ext(glv, extensions, "GL_ARB_framebuffer_sRGB\0".ptr);
	GL_SUN_slice_accum = has_ext(glv, extensions, "GL_SUN_slice_accum\0".ptr);
	GL_EXT_index_texture = has_ext(glv, extensions, "GL_EXT_index_texture\0".ptr);
	GL_ARB_geometry_shader4 = has_ext(glv, extensions, "GL_ARB_geometry_shader4\0".ptr);
	GL_EXT_separate_specular_color = has_ext(glv, extensions, "GL_EXT_separate_specular_color\0".ptr);
	GL_AMD_depth_clamp_separate = has_ext(glv, extensions, "GL_AMD_depth_clamp_separate\0".ptr);
	GL_SUN_convolution_border_modes = has_ext(glv, extensions, "GL_SUN_convolution_border_modes\0".ptr);
	GL_SGIX_sprite = has_ext(glv, extensions, "GL_SGIX_sprite\0".ptr);
	GL_ARB_get_program_binary = has_ext(glv, extensions, "GL_ARB_get_program_binary\0".ptr);
	GL_SGIS_multisample = has_ext(glv, extensions, "GL_SGIS_multisample\0".ptr);
	GL_EXT_framebuffer_object = has_ext(glv, extensions, "GL_EXT_framebuffer_object\0".ptr);
	GL_ARB_robustness_isolation = has_ext(glv, extensions, "GL_ARB_robustness_isolation\0".ptr);
	GL_ARB_vertex_array_bgra = has_ext(glv, extensions, "GL_ARB_vertex_array_bgra\0".ptr);
	GL_APPLE_vertex_array_range = has_ext(glv, extensions, "GL_APPLE_vertex_array_range\0".ptr);
	GL_AMD_query_buffer_object = has_ext(glv, extensions, "GL_AMD_query_buffer_object\0".ptr);
	GL_NV_register_combiners = has_ext(glv, extensions, "GL_NV_register_combiners\0".ptr);
	GL_ARB_draw_buffers = has_ext(glv, extensions, "GL_ARB_draw_buffers\0".ptr);
	GL_ARB_clear_texture = has_ext(glv, extensions, "GL_ARB_clear_texture\0".ptr);
	GL_ARB_debug_output = has_ext(glv, extensions, "GL_ARB_debug_output\0".ptr);
	GL_SGI_color_matrix = has_ext(glv, extensions, "GL_SGI_color_matrix\0".ptr);
	GL_EXT_cull_vertex = has_ext(glv, extensions, "GL_EXT_cull_vertex\0".ptr);
	GL_EXT_texture_sRGB = has_ext(glv, extensions, "GL_EXT_texture_sRGB\0".ptr);
	GL_APPLE_row_bytes = has_ext(glv, extensions, "GL_APPLE_row_bytes\0".ptr);
	GL_NV_texgen_reflection = has_ext(glv, extensions, "GL_NV_texgen_reflection\0".ptr);
	GL_IBM_multimode_draw_arrays = has_ext(glv, extensions, "GL_IBM_multimode_draw_arrays\0".ptr);
	GL_APPLE_vertex_array_object = has_ext(glv, extensions, "GL_APPLE_vertex_array_object\0".ptr);
	GL_3DFX_texture_compression_FXT1 = has_ext(glv, extensions, "GL_3DFX_texture_compression_FXT1\0".ptr);
	GL_SGIX_ycrcb = has_ext(glv, extensions, "GL_SGIX_ycrcb\0".ptr);
	GL_AMD_conservative_depth = has_ext(glv, extensions, "GL_AMD_conservative_depth\0".ptr);
	GL_ARB_texture_float = has_ext(glv, extensions, "GL_ARB_texture_float\0".ptr);
	GL_ARB_compressed_texture_pixel_storage = has_ext(glv, extensions, "GL_ARB_compressed_texture_pixel_storage\0".ptr);
	GL_SGIS_detail_texture = has_ext(glv, extensions, "GL_SGIS_detail_texture\0".ptr);
	GL_ARB_draw_instanced = has_ext(glv, extensions, "GL_ARB_draw_instanced\0".ptr);
	GL_OES_read_format = has_ext(glv, extensions, "GL_OES_read_format\0".ptr);
	GL_ATI_texture_float = has_ext(glv, extensions, "GL_ATI_texture_float\0".ptr);
	GL_ARB_texture_gather = has_ext(glv, extensions, "GL_ARB_texture_gather\0".ptr);
	GL_AMD_vertex_shader_layer = has_ext(glv, extensions, "GL_AMD_vertex_shader_layer\0".ptr);
	GL_ARB_shading_language_include = has_ext(glv, extensions, "GL_ARB_shading_language_include\0".ptr);
	GL_APPLE_client_storage = has_ext(glv, extensions, "GL_APPLE_client_storage\0".ptr);
	GL_WIN_phong_shading = has_ext(glv, extensions, "GL_WIN_phong_shading\0".ptr);
	GL_INGR_blend_func_separate = has_ext(glv, extensions, "GL_INGR_blend_func_separate\0".ptr);
	GL_NV_path_rendering = has_ext(glv, extensions, "GL_NV_path_rendering\0".ptr);
	GL_ATI_vertex_streams = has_ext(glv, extensions, "GL_ATI_vertex_streams\0".ptr);
	GL_ARB_texture_non_power_of_two = has_ext(glv, extensions, "GL_ARB_texture_non_power_of_two\0".ptr);
	GL_APPLE_rgb_422 = has_ext(glv, extensions, "GL_APPLE_rgb_422\0".ptr);
	GL_EXT_texture_lod_bias = has_ext(glv, extensions, "GL_EXT_texture_lod_bias\0".ptr);
	GL_ARB_seamless_cube_map = has_ext(glv, extensions, "GL_ARB_seamless_cube_map\0".ptr);
	GL_ARB_shader_group_vote = has_ext(glv, extensions, "GL_ARB_shader_group_vote\0".ptr);
	GL_NV_vdpau_interop = has_ext(glv, extensions, "GL_NV_vdpau_interop\0".ptr);
	GL_ARB_occlusion_query2 = has_ext(glv, extensions, "GL_ARB_occlusion_query2\0".ptr);
	GL_ARB_internalformat_query2 = has_ext(glv, extensions, "GL_ARB_internalformat_query2\0".ptr);
	GL_EXT_texture_filter_anisotropic = has_ext(glv, extensions, "GL_EXT_texture_filter_anisotropic\0".ptr);
	GL_SUN_vertex = has_ext(glv, extensions, "GL_SUN_vertex\0".ptr);
	GL_SGIX_igloo_interface = has_ext(glv, extensions, "GL_SGIX_igloo_interface\0".ptr);
	GL_SGIS_texture_lod = has_ext(glv, extensions, "GL_SGIS_texture_lod\0".ptr);
	GL_NV_vertex_program3 = has_ext(glv, extensions, "GL_NV_vertex_program3\0".ptr);
	GL_ARB_draw_indirect = has_ext(glv, extensions, "GL_ARB_draw_indirect\0".ptr);
	GL_NV_vertex_program4 = has_ext(glv, extensions, "GL_NV_vertex_program4\0".ptr);
	GL_AMD_transform_feedback3_lines_triangles = has_ext(glv, extensions, "GL_AMD_transform_feedback3_lines_triangles\0".ptr);
	GL_SGIS_fog_function = has_ext(glv, extensions, "GL_SGIS_fog_function\0".ptr);
	GL_EXT_x11_sync_object = has_ext(glv, extensions, "GL_EXT_x11_sync_object\0".ptr);
	GL_ARB_sync = has_ext(glv, extensions, "GL_ARB_sync\0".ptr);
	GL_ARB_compute_variable_group_size = has_ext(glv, extensions, "GL_ARB_compute_variable_group_size\0".ptr);
	GL_OES_fixed_point = has_ext(glv, extensions, "GL_OES_fixed_point\0".ptr);
	GL_EXT_framebuffer_multisample = has_ext(glv, extensions, "GL_EXT_framebuffer_multisample\0".ptr);
	GL_ARB_gpu_shader5 = has_ext(glv, extensions, "GL_ARB_gpu_shader5\0".ptr);
	GL_SGIS_texture4D = has_ext(glv, extensions, "GL_SGIS_texture4D\0".ptr);
	GL_EXT_texture3D = has_ext(glv, extensions, "GL_EXT_texture3D\0".ptr);
	GL_EXT_multisample = has_ext(glv, extensions, "GL_EXT_multisample\0".ptr);
	GL_EXT_secondary_color = has_ext(glv, extensions, "GL_EXT_secondary_color\0".ptr);
	GL_NV_parameter_buffer_object2 = has_ext(glv, extensions, "GL_NV_parameter_buffer_object2\0".ptr);
	GL_ATI_vertex_array_object = has_ext(glv, extensions, "GL_ATI_vertex_array_object\0".ptr);
	GL_ARB_sparse_texture = has_ext(glv, extensions, "GL_ARB_sparse_texture\0".ptr);
	GL_SGIS_point_line_texgen = has_ext(glv, extensions, "GL_SGIS_point_line_texgen\0".ptr);
	GL_EXT_draw_range_elements = has_ext(glv, extensions, "GL_EXT_draw_range_elements\0".ptr);
	GL_SGIX_blend_alpha_minmax = has_ext(glv, extensions, "GL_SGIX_blend_alpha_minmax\0".ptr);
}

void load_gl_GL_VERSION_1_0(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_0) return;
	glCullFace = cast(typeof(glCullFace))load("glCullFace\0".ptr);
	glFrontFace = cast(typeof(glFrontFace))load("glFrontFace\0".ptr);
	glHint = cast(typeof(glHint))load("glHint\0".ptr);
	glLineWidth = cast(typeof(glLineWidth))load("glLineWidth\0".ptr);
	glPointSize = cast(typeof(glPointSize))load("glPointSize\0".ptr);
	glPolygonMode = cast(typeof(glPolygonMode))load("glPolygonMode\0".ptr);
	glScissor = cast(typeof(glScissor))load("glScissor\0".ptr);
	glTexParameterf = cast(typeof(glTexParameterf))load("glTexParameterf\0".ptr);
	glTexParameterfv = cast(typeof(glTexParameterfv))load("glTexParameterfv\0".ptr);
	glTexParameteri = cast(typeof(glTexParameteri))load("glTexParameteri\0".ptr);
	glTexParameteriv = cast(typeof(glTexParameteriv))load("glTexParameteriv\0".ptr);
	glTexImage1D = cast(typeof(glTexImage1D))load("glTexImage1D\0".ptr);
	glTexImage2D = cast(typeof(glTexImage2D))load("glTexImage2D\0".ptr);
	glDrawBuffer = cast(typeof(glDrawBuffer))load("glDrawBuffer\0".ptr);
	glClear = cast(typeof(glClear))load("glClear\0".ptr);
	glClearColor = cast(typeof(glClearColor))load("glClearColor\0".ptr);
	glClearStencil = cast(typeof(glClearStencil))load("glClearStencil\0".ptr);
	glClearDepth = cast(typeof(glClearDepth))load("glClearDepth\0".ptr);
	glStencilMask = cast(typeof(glStencilMask))load("glStencilMask\0".ptr);
	glColorMask = cast(typeof(glColorMask))load("glColorMask\0".ptr);
	glDepthMask = cast(typeof(glDepthMask))load("glDepthMask\0".ptr);
	glDisable = cast(typeof(glDisable))load("glDisable\0".ptr);
	glEnable = cast(typeof(glEnable))load("glEnable\0".ptr);
	glFinish = cast(typeof(glFinish))load("glFinish\0".ptr);
	glFlush = cast(typeof(glFlush))load("glFlush\0".ptr);
	glBlendFunc = cast(typeof(glBlendFunc))load("glBlendFunc\0".ptr);
	glLogicOp = cast(typeof(glLogicOp))load("glLogicOp\0".ptr);
	glStencilFunc = cast(typeof(glStencilFunc))load("glStencilFunc\0".ptr);
	glStencilOp = cast(typeof(glStencilOp))load("glStencilOp\0".ptr);
	glDepthFunc = cast(typeof(glDepthFunc))load("glDepthFunc\0".ptr);
	glPixelStoref = cast(typeof(glPixelStoref))load("glPixelStoref\0".ptr);
	glPixelStorei = cast(typeof(glPixelStorei))load("glPixelStorei\0".ptr);
	glReadBuffer = cast(typeof(glReadBuffer))load("glReadBuffer\0".ptr);
	glReadPixels = cast(typeof(glReadPixels))load("glReadPixels\0".ptr);
	glGetBooleanv = cast(typeof(glGetBooleanv))load("glGetBooleanv\0".ptr);
	glGetDoublev = cast(typeof(glGetDoublev))load("glGetDoublev\0".ptr);
	glGetError = cast(typeof(glGetError))load("glGetError\0".ptr);
	glGetFloatv = cast(typeof(glGetFloatv))load("glGetFloatv\0".ptr);
	glGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv\0".ptr);
	glGetString = cast(typeof(glGetString))load("glGetString\0".ptr);
	glGetTexImage = cast(typeof(glGetTexImage))load("glGetTexImage\0".ptr);
	glGetTexParameterfv = cast(typeof(glGetTexParameterfv))load("glGetTexParameterfv\0".ptr);
	glGetTexParameteriv = cast(typeof(glGetTexParameteriv))load("glGetTexParameteriv\0".ptr);
	glGetTexLevelParameterfv = cast(typeof(glGetTexLevelParameterfv))load("glGetTexLevelParameterfv\0".ptr);
	glGetTexLevelParameteriv = cast(typeof(glGetTexLevelParameteriv))load("glGetTexLevelParameteriv\0".ptr);
	glIsEnabled = cast(typeof(glIsEnabled))load("glIsEnabled\0".ptr);
	glDepthRange = cast(typeof(glDepthRange))load("glDepthRange\0".ptr);
	glViewport = cast(typeof(glViewport))load("glViewport\0".ptr);
	glNewList = cast(typeof(glNewList))load("glNewList\0".ptr);
	glEndList = cast(typeof(glEndList))load("glEndList\0".ptr);
	glCallList = cast(typeof(glCallList))load("glCallList\0".ptr);
	glCallLists = cast(typeof(glCallLists))load("glCallLists\0".ptr);
	glDeleteLists = cast(typeof(glDeleteLists))load("glDeleteLists\0".ptr);
	glGenLists = cast(typeof(glGenLists))load("glGenLists\0".ptr);
	glListBase = cast(typeof(glListBase))load("glListBase\0".ptr);
	glBegin = cast(typeof(glBegin))load("glBegin\0".ptr);
	glBitmap = cast(typeof(glBitmap))load("glBitmap\0".ptr);
	glColor3b = cast(typeof(glColor3b))load("glColor3b\0".ptr);
	glColor3bv = cast(typeof(glColor3bv))load("glColor3bv\0".ptr);
	glColor3d = cast(typeof(glColor3d))load("glColor3d\0".ptr);
	glColor3dv = cast(typeof(glColor3dv))load("glColor3dv\0".ptr);
	glColor3f = cast(typeof(glColor3f))load("glColor3f\0".ptr);
	glColor3fv = cast(typeof(glColor3fv))load("glColor3fv\0".ptr);
	glColor3i = cast(typeof(glColor3i))load("glColor3i\0".ptr);
	glColor3iv = cast(typeof(glColor3iv))load("glColor3iv\0".ptr);
	glColor3s = cast(typeof(glColor3s))load("glColor3s\0".ptr);
	glColor3sv = cast(typeof(glColor3sv))load("glColor3sv\0".ptr);
	glColor3ub = cast(typeof(glColor3ub))load("glColor3ub\0".ptr);
	glColor3ubv = cast(typeof(glColor3ubv))load("glColor3ubv\0".ptr);
	glColor3ui = cast(typeof(glColor3ui))load("glColor3ui\0".ptr);
	glColor3uiv = cast(typeof(glColor3uiv))load("glColor3uiv\0".ptr);
	glColor3us = cast(typeof(glColor3us))load("glColor3us\0".ptr);
	glColor3usv = cast(typeof(glColor3usv))load("glColor3usv\0".ptr);
	glColor4b = cast(typeof(glColor4b))load("glColor4b\0".ptr);
	glColor4bv = cast(typeof(glColor4bv))load("glColor4bv\0".ptr);
	glColor4d = cast(typeof(glColor4d))load("glColor4d\0".ptr);
	glColor4dv = cast(typeof(glColor4dv))load("glColor4dv\0".ptr);
	glColor4f = cast(typeof(glColor4f))load("glColor4f\0".ptr);
	glColor4fv = cast(typeof(glColor4fv))load("glColor4fv\0".ptr);
	glColor4i = cast(typeof(glColor4i))load("glColor4i\0".ptr);
	glColor4iv = cast(typeof(glColor4iv))load("glColor4iv\0".ptr);
	glColor4s = cast(typeof(glColor4s))load("glColor4s\0".ptr);
	glColor4sv = cast(typeof(glColor4sv))load("glColor4sv\0".ptr);
	glColor4ub = cast(typeof(glColor4ub))load("glColor4ub\0".ptr);
	glColor4ubv = cast(typeof(glColor4ubv))load("glColor4ubv\0".ptr);
	glColor4ui = cast(typeof(glColor4ui))load("glColor4ui\0".ptr);
	glColor4uiv = cast(typeof(glColor4uiv))load("glColor4uiv\0".ptr);
	glColor4us = cast(typeof(glColor4us))load("glColor4us\0".ptr);
	glColor4usv = cast(typeof(glColor4usv))load("glColor4usv\0".ptr);
	glEdgeFlag = cast(typeof(glEdgeFlag))load("glEdgeFlag\0".ptr);
	glEdgeFlagv = cast(typeof(glEdgeFlagv))load("glEdgeFlagv\0".ptr);
	glEnd = cast(typeof(glEnd))load("glEnd\0".ptr);
	glIndexd = cast(typeof(glIndexd))load("glIndexd\0".ptr);
	glIndexdv = cast(typeof(glIndexdv))load("glIndexdv\0".ptr);
	glIndexf = cast(typeof(glIndexf))load("glIndexf\0".ptr);
	glIndexfv = cast(typeof(glIndexfv))load("glIndexfv\0".ptr);
	glIndexi = cast(typeof(glIndexi))load("glIndexi\0".ptr);
	glIndexiv = cast(typeof(glIndexiv))load("glIndexiv\0".ptr);
	glIndexs = cast(typeof(glIndexs))load("glIndexs\0".ptr);
	glIndexsv = cast(typeof(glIndexsv))load("glIndexsv\0".ptr);
	glNormal3b = cast(typeof(glNormal3b))load("glNormal3b\0".ptr);
	glNormal3bv = cast(typeof(glNormal3bv))load("glNormal3bv\0".ptr);
	glNormal3d = cast(typeof(glNormal3d))load("glNormal3d\0".ptr);
	glNormal3dv = cast(typeof(glNormal3dv))load("glNormal3dv\0".ptr);
	glNormal3f = cast(typeof(glNormal3f))load("glNormal3f\0".ptr);
	glNormal3fv = cast(typeof(glNormal3fv))load("glNormal3fv\0".ptr);
	glNormal3i = cast(typeof(glNormal3i))load("glNormal3i\0".ptr);
	glNormal3iv = cast(typeof(glNormal3iv))load("glNormal3iv\0".ptr);
	glNormal3s = cast(typeof(glNormal3s))load("glNormal3s\0".ptr);
	glNormal3sv = cast(typeof(glNormal3sv))load("glNormal3sv\0".ptr);
	glRasterPos2d = cast(typeof(glRasterPos2d))load("glRasterPos2d\0".ptr);
	glRasterPos2dv = cast(typeof(glRasterPos2dv))load("glRasterPos2dv\0".ptr);
	glRasterPos2f = cast(typeof(glRasterPos2f))load("glRasterPos2f\0".ptr);
	glRasterPos2fv = cast(typeof(glRasterPos2fv))load("glRasterPos2fv\0".ptr);
	glRasterPos2i = cast(typeof(glRasterPos2i))load("glRasterPos2i\0".ptr);
	glRasterPos2iv = cast(typeof(glRasterPos2iv))load("glRasterPos2iv\0".ptr);
	glRasterPos2s = cast(typeof(glRasterPos2s))load("glRasterPos2s\0".ptr);
	glRasterPos2sv = cast(typeof(glRasterPos2sv))load("glRasterPos2sv\0".ptr);
	glRasterPos3d = cast(typeof(glRasterPos3d))load("glRasterPos3d\0".ptr);
	glRasterPos3dv = cast(typeof(glRasterPos3dv))load("glRasterPos3dv\0".ptr);
	glRasterPos3f = cast(typeof(glRasterPos3f))load("glRasterPos3f\0".ptr);
	glRasterPos3fv = cast(typeof(glRasterPos3fv))load("glRasterPos3fv\0".ptr);
	glRasterPos3i = cast(typeof(glRasterPos3i))load("glRasterPos3i\0".ptr);
	glRasterPos3iv = cast(typeof(glRasterPos3iv))load("glRasterPos3iv\0".ptr);
	glRasterPos3s = cast(typeof(glRasterPos3s))load("glRasterPos3s\0".ptr);
	glRasterPos3sv = cast(typeof(glRasterPos3sv))load("glRasterPos3sv\0".ptr);
	glRasterPos4d = cast(typeof(glRasterPos4d))load("glRasterPos4d\0".ptr);
	glRasterPos4dv = cast(typeof(glRasterPos4dv))load("glRasterPos4dv\0".ptr);
	glRasterPos4f = cast(typeof(glRasterPos4f))load("glRasterPos4f\0".ptr);
	glRasterPos4fv = cast(typeof(glRasterPos4fv))load("glRasterPos4fv\0".ptr);
	glRasterPos4i = cast(typeof(glRasterPos4i))load("glRasterPos4i\0".ptr);
	glRasterPos4iv = cast(typeof(glRasterPos4iv))load("glRasterPos4iv\0".ptr);
	glRasterPos4s = cast(typeof(glRasterPos4s))load("glRasterPos4s\0".ptr);
	glRasterPos4sv = cast(typeof(glRasterPos4sv))load("glRasterPos4sv\0".ptr);
	glRectd = cast(typeof(glRectd))load("glRectd\0".ptr);
	glRectdv = cast(typeof(glRectdv))load("glRectdv\0".ptr);
	glRectf = cast(typeof(glRectf))load("glRectf\0".ptr);
	glRectfv = cast(typeof(glRectfv))load("glRectfv\0".ptr);
	glRecti = cast(typeof(glRecti))load("glRecti\0".ptr);
	glRectiv = cast(typeof(glRectiv))load("glRectiv\0".ptr);
	glRects = cast(typeof(glRects))load("glRects\0".ptr);
	glRectsv = cast(typeof(glRectsv))load("glRectsv\0".ptr);
	glTexCoord1d = cast(typeof(glTexCoord1d))load("glTexCoord1d\0".ptr);
	glTexCoord1dv = cast(typeof(glTexCoord1dv))load("glTexCoord1dv\0".ptr);
	glTexCoord1f = cast(typeof(glTexCoord1f))load("glTexCoord1f\0".ptr);
	glTexCoord1fv = cast(typeof(glTexCoord1fv))load("glTexCoord1fv\0".ptr);
	glTexCoord1i = cast(typeof(glTexCoord1i))load("glTexCoord1i\0".ptr);
	glTexCoord1iv = cast(typeof(glTexCoord1iv))load("glTexCoord1iv\0".ptr);
	glTexCoord1s = cast(typeof(glTexCoord1s))load("glTexCoord1s\0".ptr);
	glTexCoord1sv = cast(typeof(glTexCoord1sv))load("glTexCoord1sv\0".ptr);
	glTexCoord2d = cast(typeof(glTexCoord2d))load("glTexCoord2d\0".ptr);
	glTexCoord2dv = cast(typeof(glTexCoord2dv))load("glTexCoord2dv\0".ptr);
	glTexCoord2f = cast(typeof(glTexCoord2f))load("glTexCoord2f\0".ptr);
	glTexCoord2fv = cast(typeof(glTexCoord2fv))load("glTexCoord2fv\0".ptr);
	glTexCoord2i = cast(typeof(glTexCoord2i))load("glTexCoord2i\0".ptr);
	glTexCoord2iv = cast(typeof(glTexCoord2iv))load("glTexCoord2iv\0".ptr);
	glTexCoord2s = cast(typeof(glTexCoord2s))load("glTexCoord2s\0".ptr);
	glTexCoord2sv = cast(typeof(glTexCoord2sv))load("glTexCoord2sv\0".ptr);
	glTexCoord3d = cast(typeof(glTexCoord3d))load("glTexCoord3d\0".ptr);
	glTexCoord3dv = cast(typeof(glTexCoord3dv))load("glTexCoord3dv\0".ptr);
	glTexCoord3f = cast(typeof(glTexCoord3f))load("glTexCoord3f\0".ptr);
	glTexCoord3fv = cast(typeof(glTexCoord3fv))load("glTexCoord3fv\0".ptr);
	glTexCoord3i = cast(typeof(glTexCoord3i))load("glTexCoord3i\0".ptr);
	glTexCoord3iv = cast(typeof(glTexCoord3iv))load("glTexCoord3iv\0".ptr);
	glTexCoord3s = cast(typeof(glTexCoord3s))load("glTexCoord3s\0".ptr);
	glTexCoord3sv = cast(typeof(glTexCoord3sv))load("glTexCoord3sv\0".ptr);
	glTexCoord4d = cast(typeof(glTexCoord4d))load("glTexCoord4d\0".ptr);
	glTexCoord4dv = cast(typeof(glTexCoord4dv))load("glTexCoord4dv\0".ptr);
	glTexCoord4f = cast(typeof(glTexCoord4f))load("glTexCoord4f\0".ptr);
	glTexCoord4fv = cast(typeof(glTexCoord4fv))load("glTexCoord4fv\0".ptr);
	glTexCoord4i = cast(typeof(glTexCoord4i))load("glTexCoord4i\0".ptr);
	glTexCoord4iv = cast(typeof(glTexCoord4iv))load("glTexCoord4iv\0".ptr);
	glTexCoord4s = cast(typeof(glTexCoord4s))load("glTexCoord4s\0".ptr);
	glTexCoord4sv = cast(typeof(glTexCoord4sv))load("glTexCoord4sv\0".ptr);
	glVertex2d = cast(typeof(glVertex2d))load("glVertex2d\0".ptr);
	glVertex2dv = cast(typeof(glVertex2dv))load("glVertex2dv\0".ptr);
	glVertex2f = cast(typeof(glVertex2f))load("glVertex2f\0".ptr);
	glVertex2fv = cast(typeof(glVertex2fv))load("glVertex2fv\0".ptr);
	glVertex2i = cast(typeof(glVertex2i))load("glVertex2i\0".ptr);
	glVertex2iv = cast(typeof(glVertex2iv))load("glVertex2iv\0".ptr);
	glVertex2s = cast(typeof(glVertex2s))load("glVertex2s\0".ptr);
	glVertex2sv = cast(typeof(glVertex2sv))load("glVertex2sv\0".ptr);
	glVertex3d = cast(typeof(glVertex3d))load("glVertex3d\0".ptr);
	glVertex3dv = cast(typeof(glVertex3dv))load("glVertex3dv\0".ptr);
	glVertex3f = cast(typeof(glVertex3f))load("glVertex3f\0".ptr);
	glVertex3fv = cast(typeof(glVertex3fv))load("glVertex3fv\0".ptr);
	glVertex3i = cast(typeof(glVertex3i))load("glVertex3i\0".ptr);
	glVertex3iv = cast(typeof(glVertex3iv))load("glVertex3iv\0".ptr);
	glVertex3s = cast(typeof(glVertex3s))load("glVertex3s\0".ptr);
	glVertex3sv = cast(typeof(glVertex3sv))load("glVertex3sv\0".ptr);
	glVertex4d = cast(typeof(glVertex4d))load("glVertex4d\0".ptr);
	glVertex4dv = cast(typeof(glVertex4dv))load("glVertex4dv\0".ptr);
	glVertex4f = cast(typeof(glVertex4f))load("glVertex4f\0".ptr);
	glVertex4fv = cast(typeof(glVertex4fv))load("glVertex4fv\0".ptr);
	glVertex4i = cast(typeof(glVertex4i))load("glVertex4i\0".ptr);
	glVertex4iv = cast(typeof(glVertex4iv))load("glVertex4iv\0".ptr);
	glVertex4s = cast(typeof(glVertex4s))load("glVertex4s\0".ptr);
	glVertex4sv = cast(typeof(glVertex4sv))load("glVertex4sv\0".ptr);
	glClipPlane = cast(typeof(glClipPlane))load("glClipPlane\0".ptr);
	glColorMaterial = cast(typeof(glColorMaterial))load("glColorMaterial\0".ptr);
	glFogf = cast(typeof(glFogf))load("glFogf\0".ptr);
	glFogfv = cast(typeof(glFogfv))load("glFogfv\0".ptr);
	glFogi = cast(typeof(glFogi))load("glFogi\0".ptr);
	glFogiv = cast(typeof(glFogiv))load("glFogiv\0".ptr);
	glLightf = cast(typeof(glLightf))load("glLightf\0".ptr);
	glLightfv = cast(typeof(glLightfv))load("glLightfv\0".ptr);
	glLighti = cast(typeof(glLighti))load("glLighti\0".ptr);
	glLightiv = cast(typeof(glLightiv))load("glLightiv\0".ptr);
	glLightModelf = cast(typeof(glLightModelf))load("glLightModelf\0".ptr);
	glLightModelfv = cast(typeof(glLightModelfv))load("glLightModelfv\0".ptr);
	glLightModeli = cast(typeof(glLightModeli))load("glLightModeli\0".ptr);
	glLightModeliv = cast(typeof(glLightModeliv))load("glLightModeliv\0".ptr);
	glLineStipple = cast(typeof(glLineStipple))load("glLineStipple\0".ptr);
	glMaterialf = cast(typeof(glMaterialf))load("glMaterialf\0".ptr);
	glMaterialfv = cast(typeof(glMaterialfv))load("glMaterialfv\0".ptr);
	glMateriali = cast(typeof(glMateriali))load("glMateriali\0".ptr);
	glMaterialiv = cast(typeof(glMaterialiv))load("glMaterialiv\0".ptr);
	glPolygonStipple = cast(typeof(glPolygonStipple))load("glPolygonStipple\0".ptr);
	glShadeModel = cast(typeof(glShadeModel))load("glShadeModel\0".ptr);
	glTexEnvf = cast(typeof(glTexEnvf))load("glTexEnvf\0".ptr);
	glTexEnvfv = cast(typeof(glTexEnvfv))load("glTexEnvfv\0".ptr);
	glTexEnvi = cast(typeof(glTexEnvi))load("glTexEnvi\0".ptr);
	glTexEnviv = cast(typeof(glTexEnviv))load("glTexEnviv\0".ptr);
	glTexGend = cast(typeof(glTexGend))load("glTexGend\0".ptr);
	glTexGendv = cast(typeof(glTexGendv))load("glTexGendv\0".ptr);
	glTexGenf = cast(typeof(glTexGenf))load("glTexGenf\0".ptr);
	glTexGenfv = cast(typeof(glTexGenfv))load("glTexGenfv\0".ptr);
	glTexGeni = cast(typeof(glTexGeni))load("glTexGeni\0".ptr);
	glTexGeniv = cast(typeof(glTexGeniv))load("glTexGeniv\0".ptr);
	glFeedbackBuffer = cast(typeof(glFeedbackBuffer))load("glFeedbackBuffer\0".ptr);
	glSelectBuffer = cast(typeof(glSelectBuffer))load("glSelectBuffer\0".ptr);
	glRenderMode = cast(typeof(glRenderMode))load("glRenderMode\0".ptr);
	glInitNames = cast(typeof(glInitNames))load("glInitNames\0".ptr);
	glLoadName = cast(typeof(glLoadName))load("glLoadName\0".ptr);
	glPassThrough = cast(typeof(glPassThrough))load("glPassThrough\0".ptr);
	glPopName = cast(typeof(glPopName))load("glPopName\0".ptr);
	glPushName = cast(typeof(glPushName))load("glPushName\0".ptr);
	glClearAccum = cast(typeof(glClearAccum))load("glClearAccum\0".ptr);
	glClearIndex = cast(typeof(glClearIndex))load("glClearIndex\0".ptr);
	glIndexMask = cast(typeof(glIndexMask))load("glIndexMask\0".ptr);
	glAccum = cast(typeof(glAccum))load("glAccum\0".ptr);
	glPopAttrib = cast(typeof(glPopAttrib))load("glPopAttrib\0".ptr);
	glPushAttrib = cast(typeof(glPushAttrib))load("glPushAttrib\0".ptr);
	glMap1d = cast(typeof(glMap1d))load("glMap1d\0".ptr);
	glMap1f = cast(typeof(glMap1f))load("glMap1f\0".ptr);
	glMap2d = cast(typeof(glMap2d))load("glMap2d\0".ptr);
	glMap2f = cast(typeof(glMap2f))load("glMap2f\0".ptr);
	glMapGrid1d = cast(typeof(glMapGrid1d))load("glMapGrid1d\0".ptr);
	glMapGrid1f = cast(typeof(glMapGrid1f))load("glMapGrid1f\0".ptr);
	glMapGrid2d = cast(typeof(glMapGrid2d))load("glMapGrid2d\0".ptr);
	glMapGrid2f = cast(typeof(glMapGrid2f))load("glMapGrid2f\0".ptr);
	glEvalCoord1d = cast(typeof(glEvalCoord1d))load("glEvalCoord1d\0".ptr);
	glEvalCoord1dv = cast(typeof(glEvalCoord1dv))load("glEvalCoord1dv\0".ptr);
	glEvalCoord1f = cast(typeof(glEvalCoord1f))load("glEvalCoord1f\0".ptr);
	glEvalCoord1fv = cast(typeof(glEvalCoord1fv))load("glEvalCoord1fv\0".ptr);
	glEvalCoord2d = cast(typeof(glEvalCoord2d))load("glEvalCoord2d\0".ptr);
	glEvalCoord2dv = cast(typeof(glEvalCoord2dv))load("glEvalCoord2dv\0".ptr);
	glEvalCoord2f = cast(typeof(glEvalCoord2f))load("glEvalCoord2f\0".ptr);
	glEvalCoord2fv = cast(typeof(glEvalCoord2fv))load("glEvalCoord2fv\0".ptr);
	glEvalMesh1 = cast(typeof(glEvalMesh1))load("glEvalMesh1\0".ptr);
	glEvalPoint1 = cast(typeof(glEvalPoint1))load("glEvalPoint1\0".ptr);
	glEvalMesh2 = cast(typeof(glEvalMesh2))load("glEvalMesh2\0".ptr);
	glEvalPoint2 = cast(typeof(glEvalPoint2))load("glEvalPoint2\0".ptr);
	glAlphaFunc = cast(typeof(glAlphaFunc))load("glAlphaFunc\0".ptr);
	glPixelZoom = cast(typeof(glPixelZoom))load("glPixelZoom\0".ptr);
	glPixelTransferf = cast(typeof(glPixelTransferf))load("glPixelTransferf\0".ptr);
	glPixelTransferi = cast(typeof(glPixelTransferi))load("glPixelTransferi\0".ptr);
	glPixelMapfv = cast(typeof(glPixelMapfv))load("glPixelMapfv\0".ptr);
	glPixelMapuiv = cast(typeof(glPixelMapuiv))load("glPixelMapuiv\0".ptr);
	glPixelMapusv = cast(typeof(glPixelMapusv))load("glPixelMapusv\0".ptr);
	glCopyPixels = cast(typeof(glCopyPixels))load("glCopyPixels\0".ptr);
	glDrawPixels = cast(typeof(glDrawPixels))load("glDrawPixels\0".ptr);
	glGetClipPlane = cast(typeof(glGetClipPlane))load("glGetClipPlane\0".ptr);
	glGetLightfv = cast(typeof(glGetLightfv))load("glGetLightfv\0".ptr);
	glGetLightiv = cast(typeof(glGetLightiv))load("glGetLightiv\0".ptr);
	glGetMapdv = cast(typeof(glGetMapdv))load("glGetMapdv\0".ptr);
	glGetMapfv = cast(typeof(glGetMapfv))load("glGetMapfv\0".ptr);
	glGetMapiv = cast(typeof(glGetMapiv))load("glGetMapiv\0".ptr);
	glGetMaterialfv = cast(typeof(glGetMaterialfv))load("glGetMaterialfv\0".ptr);
	glGetMaterialiv = cast(typeof(glGetMaterialiv))load("glGetMaterialiv\0".ptr);
	glGetPixelMapfv = cast(typeof(glGetPixelMapfv))load("glGetPixelMapfv\0".ptr);
	glGetPixelMapuiv = cast(typeof(glGetPixelMapuiv))load("glGetPixelMapuiv\0".ptr);
	glGetPixelMapusv = cast(typeof(glGetPixelMapusv))load("glGetPixelMapusv\0".ptr);
	glGetPolygonStipple = cast(typeof(glGetPolygonStipple))load("glGetPolygonStipple\0".ptr);
	glGetTexEnvfv = cast(typeof(glGetTexEnvfv))load("glGetTexEnvfv\0".ptr);
	glGetTexEnviv = cast(typeof(glGetTexEnviv))load("glGetTexEnviv\0".ptr);
	glGetTexGendv = cast(typeof(glGetTexGendv))load("glGetTexGendv\0".ptr);
	glGetTexGenfv = cast(typeof(glGetTexGenfv))load("glGetTexGenfv\0".ptr);
	glGetTexGeniv = cast(typeof(glGetTexGeniv))load("glGetTexGeniv\0".ptr);
	glIsList = cast(typeof(glIsList))load("glIsList\0".ptr);
	glFrustum = cast(typeof(glFrustum))load("glFrustum\0".ptr);
	glLoadIdentity = cast(typeof(glLoadIdentity))load("glLoadIdentity\0".ptr);
	glLoadMatrixf = cast(typeof(glLoadMatrixf))load("glLoadMatrixf\0".ptr);
	glLoadMatrixd = cast(typeof(glLoadMatrixd))load("glLoadMatrixd\0".ptr);
	glMatrixMode = cast(typeof(glMatrixMode))load("glMatrixMode\0".ptr);
	glMultMatrixf = cast(typeof(glMultMatrixf))load("glMultMatrixf\0".ptr);
	glMultMatrixd = cast(typeof(glMultMatrixd))load("glMultMatrixd\0".ptr);
	glOrtho = cast(typeof(glOrtho))load("glOrtho\0".ptr);
	glPopMatrix = cast(typeof(glPopMatrix))load("glPopMatrix\0".ptr);
	glPushMatrix = cast(typeof(glPushMatrix))load("glPushMatrix\0".ptr);
	glRotated = cast(typeof(glRotated))load("glRotated\0".ptr);
	glRotatef = cast(typeof(glRotatef))load("glRotatef\0".ptr);
	glScaled = cast(typeof(glScaled))load("glScaled\0".ptr);
	glScalef = cast(typeof(glScalef))load("glScalef\0".ptr);
	glTranslated = cast(typeof(glTranslated))load("glTranslated\0".ptr);
	glTranslatef = cast(typeof(glTranslatef))load("glTranslatef\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_1(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_1) return;
	glDrawArrays = cast(typeof(glDrawArrays))load("glDrawArrays\0".ptr);
	glDrawElements = cast(typeof(glDrawElements))load("glDrawElements\0".ptr);
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv\0".ptr);
	glPolygonOffset = cast(typeof(glPolygonOffset))load("glPolygonOffset\0".ptr);
	glCopyTexImage1D = cast(typeof(glCopyTexImage1D))load("glCopyTexImage1D\0".ptr);
	glCopyTexImage2D = cast(typeof(glCopyTexImage2D))load("glCopyTexImage2D\0".ptr);
	glCopyTexSubImage1D = cast(typeof(glCopyTexSubImage1D))load("glCopyTexSubImage1D\0".ptr);
	glCopyTexSubImage2D = cast(typeof(glCopyTexSubImage2D))load("glCopyTexSubImage2D\0".ptr);
	glTexSubImage1D = cast(typeof(glTexSubImage1D))load("glTexSubImage1D\0".ptr);
	glTexSubImage2D = cast(typeof(glTexSubImage2D))load("glTexSubImage2D\0".ptr);
	glBindTexture = cast(typeof(glBindTexture))load("glBindTexture\0".ptr);
	glDeleteTextures = cast(typeof(glDeleteTextures))load("glDeleteTextures\0".ptr);
	glGenTextures = cast(typeof(glGenTextures))load("glGenTextures\0".ptr);
	glIsTexture = cast(typeof(glIsTexture))load("glIsTexture\0".ptr);
	glArrayElement = cast(typeof(glArrayElement))load("glArrayElement\0".ptr);
	glColorPointer = cast(typeof(glColorPointer))load("glColorPointer\0".ptr);
	glDisableClientState = cast(typeof(glDisableClientState))load("glDisableClientState\0".ptr);
	glEdgeFlagPointer = cast(typeof(glEdgeFlagPointer))load("glEdgeFlagPointer\0".ptr);
	glEnableClientState = cast(typeof(glEnableClientState))load("glEnableClientState\0".ptr);
	glIndexPointer = cast(typeof(glIndexPointer))load("glIndexPointer\0".ptr);
	glInterleavedArrays = cast(typeof(glInterleavedArrays))load("glInterleavedArrays\0".ptr);
	glNormalPointer = cast(typeof(glNormalPointer))load("glNormalPointer\0".ptr);
	glTexCoordPointer = cast(typeof(glTexCoordPointer))load("glTexCoordPointer\0".ptr);
	glVertexPointer = cast(typeof(glVertexPointer))load("glVertexPointer\0".ptr);
	glAreTexturesResident = cast(typeof(glAreTexturesResident))load("glAreTexturesResident\0".ptr);
	glPrioritizeTextures = cast(typeof(glPrioritizeTextures))load("glPrioritizeTextures\0".ptr);
	glIndexub = cast(typeof(glIndexub))load("glIndexub\0".ptr);
	glIndexubv = cast(typeof(glIndexubv))load("glIndexubv\0".ptr);
	glPopClientAttrib = cast(typeof(glPopClientAttrib))load("glPopClientAttrib\0".ptr);
	glPushClientAttrib = cast(typeof(glPushClientAttrib))load("glPushClientAttrib\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_2(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_2) return;
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor\0".ptr);
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation\0".ptr);
	glDrawRangeElements = cast(typeof(glDrawRangeElements))load("glDrawRangeElements\0".ptr);
	glTexImage3D = cast(typeof(glTexImage3D))load("glTexImage3D\0".ptr);
	glTexSubImage3D = cast(typeof(glTexSubImage3D))load("glTexSubImage3D\0".ptr);
	glCopyTexSubImage3D = cast(typeof(glCopyTexSubImage3D))load("glCopyTexSubImage3D\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_3(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_3) return;
	glActiveTexture = cast(typeof(glActiveTexture))load("glActiveTexture\0".ptr);
	glSampleCoverage = cast(typeof(glSampleCoverage))load("glSampleCoverage\0".ptr);
	glCompressedTexImage3D = cast(typeof(glCompressedTexImage3D))load("glCompressedTexImage3D\0".ptr);
	glCompressedTexImage2D = cast(typeof(glCompressedTexImage2D))load("glCompressedTexImage2D\0".ptr);
	glCompressedTexImage1D = cast(typeof(glCompressedTexImage1D))load("glCompressedTexImage1D\0".ptr);
	glCompressedTexSubImage3D = cast(typeof(glCompressedTexSubImage3D))load("glCompressedTexSubImage3D\0".ptr);
	glCompressedTexSubImage2D = cast(typeof(glCompressedTexSubImage2D))load("glCompressedTexSubImage2D\0".ptr);
	glCompressedTexSubImage1D = cast(typeof(glCompressedTexSubImage1D))load("glCompressedTexSubImage1D\0".ptr);
	glGetCompressedTexImage = cast(typeof(glGetCompressedTexImage))load("glGetCompressedTexImage\0".ptr);
	glClientActiveTexture = cast(typeof(glClientActiveTexture))load("glClientActiveTexture\0".ptr);
	glMultiTexCoord1d = cast(typeof(glMultiTexCoord1d))load("glMultiTexCoord1d\0".ptr);
	glMultiTexCoord1dv = cast(typeof(glMultiTexCoord1dv))load("glMultiTexCoord1dv\0".ptr);
	glMultiTexCoord1f = cast(typeof(glMultiTexCoord1f))load("glMultiTexCoord1f\0".ptr);
	glMultiTexCoord1fv = cast(typeof(glMultiTexCoord1fv))load("glMultiTexCoord1fv\0".ptr);
	glMultiTexCoord1i = cast(typeof(glMultiTexCoord1i))load("glMultiTexCoord1i\0".ptr);
	glMultiTexCoord1iv = cast(typeof(glMultiTexCoord1iv))load("glMultiTexCoord1iv\0".ptr);
	glMultiTexCoord1s = cast(typeof(glMultiTexCoord1s))load("glMultiTexCoord1s\0".ptr);
	glMultiTexCoord1sv = cast(typeof(glMultiTexCoord1sv))load("glMultiTexCoord1sv\0".ptr);
	glMultiTexCoord2d = cast(typeof(glMultiTexCoord2d))load("glMultiTexCoord2d\0".ptr);
	glMultiTexCoord2dv = cast(typeof(glMultiTexCoord2dv))load("glMultiTexCoord2dv\0".ptr);
	glMultiTexCoord2f = cast(typeof(glMultiTexCoord2f))load("glMultiTexCoord2f\0".ptr);
	glMultiTexCoord2fv = cast(typeof(glMultiTexCoord2fv))load("glMultiTexCoord2fv\0".ptr);
	glMultiTexCoord2i = cast(typeof(glMultiTexCoord2i))load("glMultiTexCoord2i\0".ptr);
	glMultiTexCoord2iv = cast(typeof(glMultiTexCoord2iv))load("glMultiTexCoord2iv\0".ptr);
	glMultiTexCoord2s = cast(typeof(glMultiTexCoord2s))load("glMultiTexCoord2s\0".ptr);
	glMultiTexCoord2sv = cast(typeof(glMultiTexCoord2sv))load("glMultiTexCoord2sv\0".ptr);
	glMultiTexCoord3d = cast(typeof(glMultiTexCoord3d))load("glMultiTexCoord3d\0".ptr);
	glMultiTexCoord3dv = cast(typeof(glMultiTexCoord3dv))load("glMultiTexCoord3dv\0".ptr);
	glMultiTexCoord3f = cast(typeof(glMultiTexCoord3f))load("glMultiTexCoord3f\0".ptr);
	glMultiTexCoord3fv = cast(typeof(glMultiTexCoord3fv))load("glMultiTexCoord3fv\0".ptr);
	glMultiTexCoord3i = cast(typeof(glMultiTexCoord3i))load("glMultiTexCoord3i\0".ptr);
	glMultiTexCoord3iv = cast(typeof(glMultiTexCoord3iv))load("glMultiTexCoord3iv\0".ptr);
	glMultiTexCoord3s = cast(typeof(glMultiTexCoord3s))load("glMultiTexCoord3s\0".ptr);
	glMultiTexCoord3sv = cast(typeof(glMultiTexCoord3sv))load("glMultiTexCoord3sv\0".ptr);
	glMultiTexCoord4d = cast(typeof(glMultiTexCoord4d))load("glMultiTexCoord4d\0".ptr);
	glMultiTexCoord4dv = cast(typeof(glMultiTexCoord4dv))load("glMultiTexCoord4dv\0".ptr);
	glMultiTexCoord4f = cast(typeof(glMultiTexCoord4f))load("glMultiTexCoord4f\0".ptr);
	glMultiTexCoord4fv = cast(typeof(glMultiTexCoord4fv))load("glMultiTexCoord4fv\0".ptr);
	glMultiTexCoord4i = cast(typeof(glMultiTexCoord4i))load("glMultiTexCoord4i\0".ptr);
	glMultiTexCoord4iv = cast(typeof(glMultiTexCoord4iv))load("glMultiTexCoord4iv\0".ptr);
	glMultiTexCoord4s = cast(typeof(glMultiTexCoord4s))load("glMultiTexCoord4s\0".ptr);
	glMultiTexCoord4sv = cast(typeof(glMultiTexCoord4sv))load("glMultiTexCoord4sv\0".ptr);
	glLoadTransposeMatrixf = cast(typeof(glLoadTransposeMatrixf))load("glLoadTransposeMatrixf\0".ptr);
	glLoadTransposeMatrixd = cast(typeof(glLoadTransposeMatrixd))load("glLoadTransposeMatrixd\0".ptr);
	glMultTransposeMatrixf = cast(typeof(glMultTransposeMatrixf))load("glMultTransposeMatrixf\0".ptr);
	glMultTransposeMatrixd = cast(typeof(glMultTransposeMatrixd))load("glMultTransposeMatrixd\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_4(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_4) return;
	glBlendFuncSeparate = cast(typeof(glBlendFuncSeparate))load("glBlendFuncSeparate\0".ptr);
	glMultiDrawArrays = cast(typeof(glMultiDrawArrays))load("glMultiDrawArrays\0".ptr);
	glMultiDrawElements = cast(typeof(glMultiDrawElements))load("glMultiDrawElements\0".ptr);
	glPointParameterf = cast(typeof(glPointParameterf))load("glPointParameterf\0".ptr);
	glPointParameterfv = cast(typeof(glPointParameterfv))load("glPointParameterfv\0".ptr);
	glPointParameteri = cast(typeof(glPointParameteri))load("glPointParameteri\0".ptr);
	glPointParameteriv = cast(typeof(glPointParameteriv))load("glPointParameteriv\0".ptr);
	glFogCoordf = cast(typeof(glFogCoordf))load("glFogCoordf\0".ptr);
	glFogCoordfv = cast(typeof(glFogCoordfv))load("glFogCoordfv\0".ptr);
	glFogCoordd = cast(typeof(glFogCoordd))load("glFogCoordd\0".ptr);
	glFogCoorddv = cast(typeof(glFogCoorddv))load("glFogCoorddv\0".ptr);
	glFogCoordPointer = cast(typeof(glFogCoordPointer))load("glFogCoordPointer\0".ptr);
	glSecondaryColor3b = cast(typeof(glSecondaryColor3b))load("glSecondaryColor3b\0".ptr);
	glSecondaryColor3bv = cast(typeof(glSecondaryColor3bv))load("glSecondaryColor3bv\0".ptr);
	glSecondaryColor3d = cast(typeof(glSecondaryColor3d))load("glSecondaryColor3d\0".ptr);
	glSecondaryColor3dv = cast(typeof(glSecondaryColor3dv))load("glSecondaryColor3dv\0".ptr);
	glSecondaryColor3f = cast(typeof(glSecondaryColor3f))load("glSecondaryColor3f\0".ptr);
	glSecondaryColor3fv = cast(typeof(glSecondaryColor3fv))load("glSecondaryColor3fv\0".ptr);
	glSecondaryColor3i = cast(typeof(glSecondaryColor3i))load("glSecondaryColor3i\0".ptr);
	glSecondaryColor3iv = cast(typeof(glSecondaryColor3iv))load("glSecondaryColor3iv\0".ptr);
	glSecondaryColor3s = cast(typeof(glSecondaryColor3s))load("glSecondaryColor3s\0".ptr);
	glSecondaryColor3sv = cast(typeof(glSecondaryColor3sv))load("glSecondaryColor3sv\0".ptr);
	glSecondaryColor3ub = cast(typeof(glSecondaryColor3ub))load("glSecondaryColor3ub\0".ptr);
	glSecondaryColor3ubv = cast(typeof(glSecondaryColor3ubv))load("glSecondaryColor3ubv\0".ptr);
	glSecondaryColor3ui = cast(typeof(glSecondaryColor3ui))load("glSecondaryColor3ui\0".ptr);
	glSecondaryColor3uiv = cast(typeof(glSecondaryColor3uiv))load("glSecondaryColor3uiv\0".ptr);
	glSecondaryColor3us = cast(typeof(glSecondaryColor3us))load("glSecondaryColor3us\0".ptr);
	glSecondaryColor3usv = cast(typeof(glSecondaryColor3usv))load("glSecondaryColor3usv\0".ptr);
	glSecondaryColorPointer = cast(typeof(glSecondaryColorPointer))load("glSecondaryColorPointer\0".ptr);
	glWindowPos2d = cast(typeof(glWindowPos2d))load("glWindowPos2d\0".ptr);
	glWindowPos2dv = cast(typeof(glWindowPos2dv))load("glWindowPos2dv\0".ptr);
	glWindowPos2f = cast(typeof(glWindowPos2f))load("glWindowPos2f\0".ptr);
	glWindowPos2fv = cast(typeof(glWindowPos2fv))load("glWindowPos2fv\0".ptr);
	glWindowPos2i = cast(typeof(glWindowPos2i))load("glWindowPos2i\0".ptr);
	glWindowPos2iv = cast(typeof(glWindowPos2iv))load("glWindowPos2iv\0".ptr);
	glWindowPos2s = cast(typeof(glWindowPos2s))load("glWindowPos2s\0".ptr);
	glWindowPos2sv = cast(typeof(glWindowPos2sv))load("glWindowPos2sv\0".ptr);
	glWindowPos3d = cast(typeof(glWindowPos3d))load("glWindowPos3d\0".ptr);
	glWindowPos3dv = cast(typeof(glWindowPos3dv))load("glWindowPos3dv\0".ptr);
	glWindowPos3f = cast(typeof(glWindowPos3f))load("glWindowPos3f\0".ptr);
	glWindowPos3fv = cast(typeof(glWindowPos3fv))load("glWindowPos3fv\0".ptr);
	glWindowPos3i = cast(typeof(glWindowPos3i))load("glWindowPos3i\0".ptr);
	glWindowPos3iv = cast(typeof(glWindowPos3iv))load("glWindowPos3iv\0".ptr);
	glWindowPos3s = cast(typeof(glWindowPos3s))load("glWindowPos3s\0".ptr);
	glWindowPos3sv = cast(typeof(glWindowPos3sv))load("glWindowPos3sv\0".ptr);
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor\0".ptr);
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_5(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_5) return;
	glGenQueries = cast(typeof(glGenQueries))load("glGenQueries\0".ptr);
	glDeleteQueries = cast(typeof(glDeleteQueries))load("glDeleteQueries\0".ptr);
	glIsQuery = cast(typeof(glIsQuery))load("glIsQuery\0".ptr);
	glBeginQuery = cast(typeof(glBeginQuery))load("glBeginQuery\0".ptr);
	glEndQuery = cast(typeof(glEndQuery))load("glEndQuery\0".ptr);
	glGetQueryiv = cast(typeof(glGetQueryiv))load("glGetQueryiv\0".ptr);
	glGetQueryObjectiv = cast(typeof(glGetQueryObjectiv))load("glGetQueryObjectiv\0".ptr);
	glGetQueryObjectuiv = cast(typeof(glGetQueryObjectuiv))load("glGetQueryObjectuiv\0".ptr);
	glBindBuffer = cast(typeof(glBindBuffer))load("glBindBuffer\0".ptr);
	glDeleteBuffers = cast(typeof(glDeleteBuffers))load("glDeleteBuffers\0".ptr);
	glGenBuffers = cast(typeof(glGenBuffers))load("glGenBuffers\0".ptr);
	glIsBuffer = cast(typeof(glIsBuffer))load("glIsBuffer\0".ptr);
	glBufferData = cast(typeof(glBufferData))load("glBufferData\0".ptr);
	glBufferSubData = cast(typeof(glBufferSubData))load("glBufferSubData\0".ptr);
	glGetBufferSubData = cast(typeof(glGetBufferSubData))load("glGetBufferSubData\0".ptr);
	glMapBuffer = cast(typeof(glMapBuffer))load("glMapBuffer\0".ptr);
	glUnmapBuffer = cast(typeof(glUnmapBuffer))load("glUnmapBuffer\0".ptr);
	glGetBufferParameteriv = cast(typeof(glGetBufferParameteriv))load("glGetBufferParameteriv\0".ptr);
	glGetBufferPointerv = cast(typeof(glGetBufferPointerv))load("glGetBufferPointerv\0".ptr);
	return;
}

void load_gl_GL_VERSION_2_0(void* function(const(char)* name) load) {
	if(!GL_VERSION_2_0) return;
	glBlendEquationSeparate = cast(typeof(glBlendEquationSeparate))load("glBlendEquationSeparate\0".ptr);
	glDrawBuffers = cast(typeof(glDrawBuffers))load("glDrawBuffers\0".ptr);
	glStencilOpSeparate = cast(typeof(glStencilOpSeparate))load("glStencilOpSeparate\0".ptr);
	glStencilFuncSeparate = cast(typeof(glStencilFuncSeparate))load("glStencilFuncSeparate\0".ptr);
	glStencilMaskSeparate = cast(typeof(glStencilMaskSeparate))load("glStencilMaskSeparate\0".ptr);
	glAttachShader = cast(typeof(glAttachShader))load("glAttachShader\0".ptr);
	glBindAttribLocation = cast(typeof(glBindAttribLocation))load("glBindAttribLocation\0".ptr);
	glCompileShader = cast(typeof(glCompileShader))load("glCompileShader\0".ptr);
	glCreateProgram = cast(typeof(glCreateProgram))load("glCreateProgram\0".ptr);
	glCreateShader = cast(typeof(glCreateShader))load("glCreateShader\0".ptr);
	glDeleteProgram = cast(typeof(glDeleteProgram))load("glDeleteProgram\0".ptr);
	glDeleteShader = cast(typeof(glDeleteShader))load("glDeleteShader\0".ptr);
	glDetachShader = cast(typeof(glDetachShader))load("glDetachShader\0".ptr);
	glDisableVertexAttribArray = cast(typeof(glDisableVertexAttribArray))load("glDisableVertexAttribArray\0".ptr);
	glEnableVertexAttribArray = cast(typeof(glEnableVertexAttribArray))load("glEnableVertexAttribArray\0".ptr);
	glGetActiveAttrib = cast(typeof(glGetActiveAttrib))load("glGetActiveAttrib\0".ptr);
	glGetActiveUniform = cast(typeof(glGetActiveUniform))load("glGetActiveUniform\0".ptr);
	glGetAttachedShaders = cast(typeof(glGetAttachedShaders))load("glGetAttachedShaders\0".ptr);
	glGetAttribLocation = cast(typeof(glGetAttribLocation))load("glGetAttribLocation\0".ptr);
	glGetProgramiv = cast(typeof(glGetProgramiv))load("glGetProgramiv\0".ptr);
	glGetProgramInfoLog = cast(typeof(glGetProgramInfoLog))load("glGetProgramInfoLog\0".ptr);
	glGetShaderiv = cast(typeof(glGetShaderiv))load("glGetShaderiv\0".ptr);
	glGetShaderInfoLog = cast(typeof(glGetShaderInfoLog))load("glGetShaderInfoLog\0".ptr);
	glGetShaderSource = cast(typeof(glGetShaderSource))load("glGetShaderSource\0".ptr);
	glGetUniformLocation = cast(typeof(glGetUniformLocation))load("glGetUniformLocation\0".ptr);
	glGetUniformfv = cast(typeof(glGetUniformfv))load("glGetUniformfv\0".ptr);
	glGetUniformiv = cast(typeof(glGetUniformiv))load("glGetUniformiv\0".ptr);
	glGetVertexAttribdv = cast(typeof(glGetVertexAttribdv))load("glGetVertexAttribdv\0".ptr);
	glGetVertexAttribfv = cast(typeof(glGetVertexAttribfv))load("glGetVertexAttribfv\0".ptr);
	glGetVertexAttribiv = cast(typeof(glGetVertexAttribiv))load("glGetVertexAttribiv\0".ptr);
	glGetVertexAttribPointerv = cast(typeof(glGetVertexAttribPointerv))load("glGetVertexAttribPointerv\0".ptr);
	glIsProgram = cast(typeof(glIsProgram))load("glIsProgram\0".ptr);
	glIsShader = cast(typeof(glIsShader))load("glIsShader\0".ptr);
	glLinkProgram = cast(typeof(glLinkProgram))load("glLinkProgram\0".ptr);
	glShaderSource = cast(typeof(glShaderSource))load("glShaderSource\0".ptr);
	glUseProgram = cast(typeof(glUseProgram))load("glUseProgram\0".ptr);
	glUniform1f = cast(typeof(glUniform1f))load("glUniform1f\0".ptr);
	glUniform2f = cast(typeof(glUniform2f))load("glUniform2f\0".ptr);
	glUniform3f = cast(typeof(glUniform3f))load("glUniform3f\0".ptr);
	glUniform4f = cast(typeof(glUniform4f))load("glUniform4f\0".ptr);
	glUniform1i = cast(typeof(glUniform1i))load("glUniform1i\0".ptr);
	glUniform2i = cast(typeof(glUniform2i))load("glUniform2i\0".ptr);
	glUniform3i = cast(typeof(glUniform3i))load("glUniform3i\0".ptr);
	glUniform4i = cast(typeof(glUniform4i))load("glUniform4i\0".ptr);
	glUniform1fv = cast(typeof(glUniform1fv))load("glUniform1fv\0".ptr);
	glUniform2fv = cast(typeof(glUniform2fv))load("glUniform2fv\0".ptr);
	glUniform3fv = cast(typeof(glUniform3fv))load("glUniform3fv\0".ptr);
	glUniform4fv = cast(typeof(glUniform4fv))load("glUniform4fv\0".ptr);
	glUniform1iv = cast(typeof(glUniform1iv))load("glUniform1iv\0".ptr);
	glUniform2iv = cast(typeof(glUniform2iv))load("glUniform2iv\0".ptr);
	glUniform3iv = cast(typeof(glUniform3iv))load("glUniform3iv\0".ptr);
	glUniform4iv = cast(typeof(glUniform4iv))load("glUniform4iv\0".ptr);
	glUniformMatrix2fv = cast(typeof(glUniformMatrix2fv))load("glUniformMatrix2fv\0".ptr);
	glUniformMatrix3fv = cast(typeof(glUniformMatrix3fv))load("glUniformMatrix3fv\0".ptr);
	glUniformMatrix4fv = cast(typeof(glUniformMatrix4fv))load("glUniformMatrix4fv\0".ptr);
	glValidateProgram = cast(typeof(glValidateProgram))load("glValidateProgram\0".ptr);
	glVertexAttrib1d = cast(typeof(glVertexAttrib1d))load("glVertexAttrib1d\0".ptr);
	glVertexAttrib1dv = cast(typeof(glVertexAttrib1dv))load("glVertexAttrib1dv\0".ptr);
	glVertexAttrib1f = cast(typeof(glVertexAttrib1f))load("glVertexAttrib1f\0".ptr);
	glVertexAttrib1fv = cast(typeof(glVertexAttrib1fv))load("glVertexAttrib1fv\0".ptr);
	glVertexAttrib1s = cast(typeof(glVertexAttrib1s))load("glVertexAttrib1s\0".ptr);
	glVertexAttrib1sv = cast(typeof(glVertexAttrib1sv))load("glVertexAttrib1sv\0".ptr);
	glVertexAttrib2d = cast(typeof(glVertexAttrib2d))load("glVertexAttrib2d\0".ptr);
	glVertexAttrib2dv = cast(typeof(glVertexAttrib2dv))load("glVertexAttrib2dv\0".ptr);
	glVertexAttrib2f = cast(typeof(glVertexAttrib2f))load("glVertexAttrib2f\0".ptr);
	glVertexAttrib2fv = cast(typeof(glVertexAttrib2fv))load("glVertexAttrib2fv\0".ptr);
	glVertexAttrib2s = cast(typeof(glVertexAttrib2s))load("glVertexAttrib2s\0".ptr);
	glVertexAttrib2sv = cast(typeof(glVertexAttrib2sv))load("glVertexAttrib2sv\0".ptr);
	glVertexAttrib3d = cast(typeof(glVertexAttrib3d))load("glVertexAttrib3d\0".ptr);
	glVertexAttrib3dv = cast(typeof(glVertexAttrib3dv))load("glVertexAttrib3dv\0".ptr);
	glVertexAttrib3f = cast(typeof(glVertexAttrib3f))load("glVertexAttrib3f\0".ptr);
	glVertexAttrib3fv = cast(typeof(glVertexAttrib3fv))load("glVertexAttrib3fv\0".ptr);
	glVertexAttrib3s = cast(typeof(glVertexAttrib3s))load("glVertexAttrib3s\0".ptr);
	glVertexAttrib3sv = cast(typeof(glVertexAttrib3sv))load("glVertexAttrib3sv\0".ptr);
	glVertexAttrib4Nbv = cast(typeof(glVertexAttrib4Nbv))load("glVertexAttrib4Nbv\0".ptr);
	glVertexAttrib4Niv = cast(typeof(glVertexAttrib4Niv))load("glVertexAttrib4Niv\0".ptr);
	glVertexAttrib4Nsv = cast(typeof(glVertexAttrib4Nsv))load("glVertexAttrib4Nsv\0".ptr);
	glVertexAttrib4Nub = cast(typeof(glVertexAttrib4Nub))load("glVertexAttrib4Nub\0".ptr);
	glVertexAttrib4Nubv = cast(typeof(glVertexAttrib4Nubv))load("glVertexAttrib4Nubv\0".ptr);
	glVertexAttrib4Nuiv = cast(typeof(glVertexAttrib4Nuiv))load("glVertexAttrib4Nuiv\0".ptr);
	glVertexAttrib4Nusv = cast(typeof(glVertexAttrib4Nusv))load("glVertexAttrib4Nusv\0".ptr);
	glVertexAttrib4bv = cast(typeof(glVertexAttrib4bv))load("glVertexAttrib4bv\0".ptr);
	glVertexAttrib4d = cast(typeof(glVertexAttrib4d))load("glVertexAttrib4d\0".ptr);
	glVertexAttrib4dv = cast(typeof(glVertexAttrib4dv))load("glVertexAttrib4dv\0".ptr);
	glVertexAttrib4f = cast(typeof(glVertexAttrib4f))load("glVertexAttrib4f\0".ptr);
	glVertexAttrib4fv = cast(typeof(glVertexAttrib4fv))load("glVertexAttrib4fv\0".ptr);
	glVertexAttrib4iv = cast(typeof(glVertexAttrib4iv))load("glVertexAttrib4iv\0".ptr);
	glVertexAttrib4s = cast(typeof(glVertexAttrib4s))load("glVertexAttrib4s\0".ptr);
	glVertexAttrib4sv = cast(typeof(glVertexAttrib4sv))load("glVertexAttrib4sv\0".ptr);
	glVertexAttrib4ubv = cast(typeof(glVertexAttrib4ubv))load("glVertexAttrib4ubv\0".ptr);
	glVertexAttrib4uiv = cast(typeof(glVertexAttrib4uiv))load("glVertexAttrib4uiv\0".ptr);
	glVertexAttrib4usv = cast(typeof(glVertexAttrib4usv))load("glVertexAttrib4usv\0".ptr);
	glVertexAttribPointer = cast(typeof(glVertexAttribPointer))load("glVertexAttribPointer\0".ptr);
	return;
}

void load_gl_GL_VERSION_2_1(void* function(const(char)* name) load) {
	if(!GL_VERSION_2_1) return;
	glUniformMatrix2x3fv = cast(typeof(glUniformMatrix2x3fv))load("glUniformMatrix2x3fv\0".ptr);
	glUniformMatrix3x2fv = cast(typeof(glUniformMatrix3x2fv))load("glUniformMatrix3x2fv\0".ptr);
	glUniformMatrix2x4fv = cast(typeof(glUniformMatrix2x4fv))load("glUniformMatrix2x4fv\0".ptr);
	glUniformMatrix4x2fv = cast(typeof(glUniformMatrix4x2fv))load("glUniformMatrix4x2fv\0".ptr);
	glUniformMatrix3x4fv = cast(typeof(glUniformMatrix3x4fv))load("glUniformMatrix3x4fv\0".ptr);
	glUniformMatrix4x3fv = cast(typeof(glUniformMatrix4x3fv))load("glUniformMatrix4x3fv\0".ptr);
	return;
}

void load_gl_GL_VERSION_3_0(void* function(const(char)* name) load) {
	if(!GL_VERSION_3_0) return;
	glColorMaski = cast(typeof(glColorMaski))load("glColorMaski\0".ptr);
	glGetBooleani_v = cast(typeof(glGetBooleani_v))load("glGetBooleani_v\0".ptr);
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v\0".ptr);
	glEnablei = cast(typeof(glEnablei))load("glEnablei\0".ptr);
	glDisablei = cast(typeof(glDisablei))load("glDisablei\0".ptr);
	glIsEnabledi = cast(typeof(glIsEnabledi))load("glIsEnabledi\0".ptr);
	glBeginTransformFeedback = cast(typeof(glBeginTransformFeedback))load("glBeginTransformFeedback\0".ptr);
	glEndTransformFeedback = cast(typeof(glEndTransformFeedback))load("glEndTransformFeedback\0".ptr);
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange\0".ptr);
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase\0".ptr);
	glTransformFeedbackVaryings = cast(typeof(glTransformFeedbackVaryings))load("glTransformFeedbackVaryings\0".ptr);
	glGetTransformFeedbackVarying = cast(typeof(glGetTransformFeedbackVarying))load("glGetTransformFeedbackVarying\0".ptr);
	glClampColor = cast(typeof(glClampColor))load("glClampColor\0".ptr);
	glBeginConditionalRender = cast(typeof(glBeginConditionalRender))load("glBeginConditionalRender\0".ptr);
	glEndConditionalRender = cast(typeof(glEndConditionalRender))load("glEndConditionalRender\0".ptr);
	glVertexAttribIPointer = cast(typeof(glVertexAttribIPointer))load("glVertexAttribIPointer\0".ptr);
	glGetVertexAttribIiv = cast(typeof(glGetVertexAttribIiv))load("glGetVertexAttribIiv\0".ptr);
	glGetVertexAttribIuiv = cast(typeof(glGetVertexAttribIuiv))load("glGetVertexAttribIuiv\0".ptr);
	glVertexAttribI1i = cast(typeof(glVertexAttribI1i))load("glVertexAttribI1i\0".ptr);
	glVertexAttribI2i = cast(typeof(glVertexAttribI2i))load("glVertexAttribI2i\0".ptr);
	glVertexAttribI3i = cast(typeof(glVertexAttribI3i))load("glVertexAttribI3i\0".ptr);
	glVertexAttribI4i = cast(typeof(glVertexAttribI4i))load("glVertexAttribI4i\0".ptr);
	glVertexAttribI1ui = cast(typeof(glVertexAttribI1ui))load("glVertexAttribI1ui\0".ptr);
	glVertexAttribI2ui = cast(typeof(glVertexAttribI2ui))load("glVertexAttribI2ui\0".ptr);
	glVertexAttribI3ui = cast(typeof(glVertexAttribI3ui))load("glVertexAttribI3ui\0".ptr);
	glVertexAttribI4ui = cast(typeof(glVertexAttribI4ui))load("glVertexAttribI4ui\0".ptr);
	glVertexAttribI1iv = cast(typeof(glVertexAttribI1iv))load("glVertexAttribI1iv\0".ptr);
	glVertexAttribI2iv = cast(typeof(glVertexAttribI2iv))load("glVertexAttribI2iv\0".ptr);
	glVertexAttribI3iv = cast(typeof(glVertexAttribI3iv))load("glVertexAttribI3iv\0".ptr);
	glVertexAttribI4iv = cast(typeof(glVertexAttribI4iv))load("glVertexAttribI4iv\0".ptr);
	glVertexAttribI1uiv = cast(typeof(glVertexAttribI1uiv))load("glVertexAttribI1uiv\0".ptr);
	glVertexAttribI2uiv = cast(typeof(glVertexAttribI2uiv))load("glVertexAttribI2uiv\0".ptr);
	glVertexAttribI3uiv = cast(typeof(glVertexAttribI3uiv))load("glVertexAttribI3uiv\0".ptr);
	glVertexAttribI4uiv = cast(typeof(glVertexAttribI4uiv))load("glVertexAttribI4uiv\0".ptr);
	glVertexAttribI4bv = cast(typeof(glVertexAttribI4bv))load("glVertexAttribI4bv\0".ptr);
	glVertexAttribI4sv = cast(typeof(glVertexAttribI4sv))load("glVertexAttribI4sv\0".ptr);
	glVertexAttribI4ubv = cast(typeof(glVertexAttribI4ubv))load("glVertexAttribI4ubv\0".ptr);
	glVertexAttribI4usv = cast(typeof(glVertexAttribI4usv))load("glVertexAttribI4usv\0".ptr);
	glGetUniformuiv = cast(typeof(glGetUniformuiv))load("glGetUniformuiv\0".ptr);
	glBindFragDataLocation = cast(typeof(glBindFragDataLocation))load("glBindFragDataLocation\0".ptr);
	glGetFragDataLocation = cast(typeof(glGetFragDataLocation))load("glGetFragDataLocation\0".ptr);
	glUniform1ui = cast(typeof(glUniform1ui))load("glUniform1ui\0".ptr);
	glUniform2ui = cast(typeof(glUniform2ui))load("glUniform2ui\0".ptr);
	glUniform3ui = cast(typeof(glUniform3ui))load("glUniform3ui\0".ptr);
	glUniform4ui = cast(typeof(glUniform4ui))load("glUniform4ui\0".ptr);
	glUniform1uiv = cast(typeof(glUniform1uiv))load("glUniform1uiv\0".ptr);
	glUniform2uiv = cast(typeof(glUniform2uiv))load("glUniform2uiv\0".ptr);
	glUniform3uiv = cast(typeof(glUniform3uiv))load("glUniform3uiv\0".ptr);
	glUniform4uiv = cast(typeof(glUniform4uiv))load("glUniform4uiv\0".ptr);
	glTexParameterIiv = cast(typeof(glTexParameterIiv))load("glTexParameterIiv\0".ptr);
	glTexParameterIuiv = cast(typeof(glTexParameterIuiv))load("glTexParameterIuiv\0".ptr);
	glGetTexParameterIiv = cast(typeof(glGetTexParameterIiv))load("glGetTexParameterIiv\0".ptr);
	glGetTexParameterIuiv = cast(typeof(glGetTexParameterIuiv))load("glGetTexParameterIuiv\0".ptr);
	glClearBufferiv = cast(typeof(glClearBufferiv))load("glClearBufferiv\0".ptr);
	glClearBufferuiv = cast(typeof(glClearBufferuiv))load("glClearBufferuiv\0".ptr);
	glClearBufferfv = cast(typeof(glClearBufferfv))load("glClearBufferfv\0".ptr);
	glClearBufferfi = cast(typeof(glClearBufferfi))load("glClearBufferfi\0".ptr);
	glGetStringi = cast(typeof(glGetStringi))load("glGetStringi\0".ptr);
	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer\0".ptr);
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer\0".ptr);
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers\0".ptr);
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers\0".ptr);
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage\0".ptr);
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv\0".ptr);
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer\0".ptr);
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer\0".ptr);
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers\0".ptr);
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers\0".ptr);
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus\0".ptr);
	glFramebufferTexture1D = cast(typeof(glFramebufferTexture1D))load("glFramebufferTexture1D\0".ptr);
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D\0".ptr);
	glFramebufferTexture3D = cast(typeof(glFramebufferTexture3D))load("glFramebufferTexture3D\0".ptr);
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer\0".ptr);
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv\0".ptr);
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap\0".ptr);
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer\0".ptr);
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample\0".ptr);
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer\0".ptr);
	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange\0".ptr);
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange\0".ptr);
	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray\0".ptr);
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays\0".ptr);
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays\0".ptr);
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray\0".ptr);
	return;
}

void load_gl_GL_VERSION_3_1(void* function(const(char)* name) load) {
	if(!GL_VERSION_3_1) return;
	glDrawArraysInstanced = cast(typeof(glDrawArraysInstanced))load("glDrawArraysInstanced\0".ptr);
	glDrawElementsInstanced = cast(typeof(glDrawElementsInstanced))load("glDrawElementsInstanced\0".ptr);
	glTexBuffer = cast(typeof(glTexBuffer))load("glTexBuffer\0".ptr);
	glPrimitiveRestartIndex = cast(typeof(glPrimitiveRestartIndex))load("glPrimitiveRestartIndex\0".ptr);
	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData\0".ptr);
	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices\0".ptr);
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv\0".ptr);
	glGetActiveUniformName = cast(typeof(glGetActiveUniformName))load("glGetActiveUniformName\0".ptr);
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex\0".ptr);
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv\0".ptr);
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName\0".ptr);
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding\0".ptr);
	return;
}

void load_gl_GL_VERSION_3_2(void* function(const(char)* name) load) {
	if(!GL_VERSION_3_2) return;
	glDrawElementsBaseVertex = cast(typeof(glDrawElementsBaseVertex))load("glDrawElementsBaseVertex\0".ptr);
	glDrawRangeElementsBaseVertex = cast(typeof(glDrawRangeElementsBaseVertex))load("glDrawRangeElementsBaseVertex\0".ptr);
	glDrawElementsInstancedBaseVertex = cast(typeof(glDrawElementsInstancedBaseVertex))load("glDrawElementsInstancedBaseVertex\0".ptr);
	glMultiDrawElementsBaseVertex = cast(typeof(glMultiDrawElementsBaseVertex))load("glMultiDrawElementsBaseVertex\0".ptr);
	glProvokingVertex = cast(typeof(glProvokingVertex))load("glProvokingVertex\0".ptr);
	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync\0".ptr);
	glIsSync = cast(typeof(glIsSync))load("glIsSync\0".ptr);
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync\0".ptr);
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync\0".ptr);
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync\0".ptr);
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v\0".ptr);
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv\0".ptr);
	glGetInteger64i_v = cast(typeof(glGetInteger64i_v))load("glGetInteger64i_v\0".ptr);
	glGetBufferParameteri64v = cast(typeof(glGetBufferParameteri64v))load("glGetBufferParameteri64v\0".ptr);
	glFramebufferTexture = cast(typeof(glFramebufferTexture))load("glFramebufferTexture\0".ptr);
	glTexImage2DMultisample = cast(typeof(glTexImage2DMultisample))load("glTexImage2DMultisample\0".ptr);
	glTexImage3DMultisample = cast(typeof(glTexImage3DMultisample))load("glTexImage3DMultisample\0".ptr);
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv\0".ptr);
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski\0".ptr);
	return;
}

void load_gl_GL_VERSION_3_3(void* function(const(char)* name) load) {
	if(!GL_VERSION_3_3) return;
	glBindFragDataLocationIndexed = cast(typeof(glBindFragDataLocationIndexed))load("glBindFragDataLocationIndexed\0".ptr);
	glGetFragDataIndex = cast(typeof(glGetFragDataIndex))load("glGetFragDataIndex\0".ptr);
	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers\0".ptr);
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers\0".ptr);
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler\0".ptr);
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler\0".ptr);
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri\0".ptr);
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv\0".ptr);
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf\0".ptr);
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv\0".ptr);
	glSamplerParameterIiv = cast(typeof(glSamplerParameterIiv))load("glSamplerParameterIiv\0".ptr);
	glSamplerParameterIuiv = cast(typeof(glSamplerParameterIuiv))load("glSamplerParameterIuiv\0".ptr);
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv\0".ptr);
	glGetSamplerParameterIiv = cast(typeof(glGetSamplerParameterIiv))load("glGetSamplerParameterIiv\0".ptr);
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv\0".ptr);
	glGetSamplerParameterIuiv = cast(typeof(glGetSamplerParameterIuiv))load("glGetSamplerParameterIuiv\0".ptr);
	glQueryCounter = cast(typeof(glQueryCounter))load("glQueryCounter\0".ptr);
	glGetQueryObjecti64v = cast(typeof(glGetQueryObjecti64v))load("glGetQueryObjecti64v\0".ptr);
	glGetQueryObjectui64v = cast(typeof(glGetQueryObjectui64v))load("glGetQueryObjectui64v\0".ptr);
	glVertexAttribDivisor = cast(typeof(glVertexAttribDivisor))load("glVertexAttribDivisor\0".ptr);
	glVertexAttribP1ui = cast(typeof(glVertexAttribP1ui))load("glVertexAttribP1ui\0".ptr);
	glVertexAttribP1uiv = cast(typeof(glVertexAttribP1uiv))load("glVertexAttribP1uiv\0".ptr);
	glVertexAttribP2ui = cast(typeof(glVertexAttribP2ui))load("glVertexAttribP2ui\0".ptr);
	glVertexAttribP2uiv = cast(typeof(glVertexAttribP2uiv))load("glVertexAttribP2uiv\0".ptr);
	glVertexAttribP3ui = cast(typeof(glVertexAttribP3ui))load("glVertexAttribP3ui\0".ptr);
	glVertexAttribP3uiv = cast(typeof(glVertexAttribP3uiv))load("glVertexAttribP3uiv\0".ptr);
	glVertexAttribP4ui = cast(typeof(glVertexAttribP4ui))load("glVertexAttribP4ui\0".ptr);
	glVertexAttribP4uiv = cast(typeof(glVertexAttribP4uiv))load("glVertexAttribP4uiv\0".ptr);
	glVertexP2ui = cast(typeof(glVertexP2ui))load("glVertexP2ui\0".ptr);
	glVertexP2uiv = cast(typeof(glVertexP2uiv))load("glVertexP2uiv\0".ptr);
	glVertexP3ui = cast(typeof(glVertexP3ui))load("glVertexP3ui\0".ptr);
	glVertexP3uiv = cast(typeof(glVertexP3uiv))load("glVertexP3uiv\0".ptr);
	glVertexP4ui = cast(typeof(glVertexP4ui))load("glVertexP4ui\0".ptr);
	glVertexP4uiv = cast(typeof(glVertexP4uiv))load("glVertexP4uiv\0".ptr);
	glTexCoordP1ui = cast(typeof(glTexCoordP1ui))load("glTexCoordP1ui\0".ptr);
	glTexCoordP1uiv = cast(typeof(glTexCoordP1uiv))load("glTexCoordP1uiv\0".ptr);
	glTexCoordP2ui = cast(typeof(glTexCoordP2ui))load("glTexCoordP2ui\0".ptr);
	glTexCoordP2uiv = cast(typeof(glTexCoordP2uiv))load("glTexCoordP2uiv\0".ptr);
	glTexCoordP3ui = cast(typeof(glTexCoordP3ui))load("glTexCoordP3ui\0".ptr);
	glTexCoordP3uiv = cast(typeof(glTexCoordP3uiv))load("glTexCoordP3uiv\0".ptr);
	glTexCoordP4ui = cast(typeof(glTexCoordP4ui))load("glTexCoordP4ui\0".ptr);
	glTexCoordP4uiv = cast(typeof(glTexCoordP4uiv))load("glTexCoordP4uiv\0".ptr);
	glMultiTexCoordP1ui = cast(typeof(glMultiTexCoordP1ui))load("glMultiTexCoordP1ui\0".ptr);
	glMultiTexCoordP1uiv = cast(typeof(glMultiTexCoordP1uiv))load("glMultiTexCoordP1uiv\0".ptr);
	glMultiTexCoordP2ui = cast(typeof(glMultiTexCoordP2ui))load("glMultiTexCoordP2ui\0".ptr);
	glMultiTexCoordP2uiv = cast(typeof(glMultiTexCoordP2uiv))load("glMultiTexCoordP2uiv\0".ptr);
	glMultiTexCoordP3ui = cast(typeof(glMultiTexCoordP3ui))load("glMultiTexCoordP3ui\0".ptr);
	glMultiTexCoordP3uiv = cast(typeof(glMultiTexCoordP3uiv))load("glMultiTexCoordP3uiv\0".ptr);
	glMultiTexCoordP4ui = cast(typeof(glMultiTexCoordP4ui))load("glMultiTexCoordP4ui\0".ptr);
	glMultiTexCoordP4uiv = cast(typeof(glMultiTexCoordP4uiv))load("glMultiTexCoordP4uiv\0".ptr);
	glNormalP3ui = cast(typeof(glNormalP3ui))load("glNormalP3ui\0".ptr);
	glNormalP3uiv = cast(typeof(glNormalP3uiv))load("glNormalP3uiv\0".ptr);
	glColorP3ui = cast(typeof(glColorP3ui))load("glColorP3ui\0".ptr);
	glColorP3uiv = cast(typeof(glColorP3uiv))load("glColorP3uiv\0".ptr);
	glColorP4ui = cast(typeof(glColorP4ui))load("glColorP4ui\0".ptr);
	glColorP4uiv = cast(typeof(glColorP4uiv))load("glColorP4uiv\0".ptr);
	glSecondaryColorP3ui = cast(typeof(glSecondaryColorP3ui))load("glSecondaryColorP3ui\0".ptr);
	glSecondaryColorP3uiv = cast(typeof(glSecondaryColorP3uiv))load("glSecondaryColorP3uiv\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_0(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_0) return;
	glMinSampleShading = cast(typeof(glMinSampleShading))load("glMinSampleShading\0".ptr);
	glBlendEquationi = cast(typeof(glBlendEquationi))load("glBlendEquationi\0".ptr);
	glBlendEquationSeparatei = cast(typeof(glBlendEquationSeparatei))load("glBlendEquationSeparatei\0".ptr);
	glBlendFunci = cast(typeof(glBlendFunci))load("glBlendFunci\0".ptr);
	glBlendFuncSeparatei = cast(typeof(glBlendFuncSeparatei))load("glBlendFuncSeparatei\0".ptr);
	glDrawArraysIndirect = cast(typeof(glDrawArraysIndirect))load("glDrawArraysIndirect\0".ptr);
	glDrawElementsIndirect = cast(typeof(glDrawElementsIndirect))load("glDrawElementsIndirect\0".ptr);
	glUniform1d = cast(typeof(glUniform1d))load("glUniform1d\0".ptr);
	glUniform2d = cast(typeof(glUniform2d))load("glUniform2d\0".ptr);
	glUniform3d = cast(typeof(glUniform3d))load("glUniform3d\0".ptr);
	glUniform4d = cast(typeof(glUniform4d))load("glUniform4d\0".ptr);
	glUniform1dv = cast(typeof(glUniform1dv))load("glUniform1dv\0".ptr);
	glUniform2dv = cast(typeof(glUniform2dv))load("glUniform2dv\0".ptr);
	glUniform3dv = cast(typeof(glUniform3dv))load("glUniform3dv\0".ptr);
	glUniform4dv = cast(typeof(glUniform4dv))load("glUniform4dv\0".ptr);
	glUniformMatrix2dv = cast(typeof(glUniformMatrix2dv))load("glUniformMatrix2dv\0".ptr);
	glUniformMatrix3dv = cast(typeof(glUniformMatrix3dv))load("glUniformMatrix3dv\0".ptr);
	glUniformMatrix4dv = cast(typeof(glUniformMatrix4dv))load("glUniformMatrix4dv\0".ptr);
	glUniformMatrix2x3dv = cast(typeof(glUniformMatrix2x3dv))load("glUniformMatrix2x3dv\0".ptr);
	glUniformMatrix2x4dv = cast(typeof(glUniformMatrix2x4dv))load("glUniformMatrix2x4dv\0".ptr);
	glUniformMatrix3x2dv = cast(typeof(glUniformMatrix3x2dv))load("glUniformMatrix3x2dv\0".ptr);
	glUniformMatrix3x4dv = cast(typeof(glUniformMatrix3x4dv))load("glUniformMatrix3x4dv\0".ptr);
	glUniformMatrix4x2dv = cast(typeof(glUniformMatrix4x2dv))load("glUniformMatrix4x2dv\0".ptr);
	glUniformMatrix4x3dv = cast(typeof(glUniformMatrix4x3dv))load("glUniformMatrix4x3dv\0".ptr);
	glGetUniformdv = cast(typeof(glGetUniformdv))load("glGetUniformdv\0".ptr);
	glGetSubroutineUniformLocation = cast(typeof(glGetSubroutineUniformLocation))load("glGetSubroutineUniformLocation\0".ptr);
	glGetSubroutineIndex = cast(typeof(glGetSubroutineIndex))load("glGetSubroutineIndex\0".ptr);
	glGetActiveSubroutineUniformiv = cast(typeof(glGetActiveSubroutineUniformiv))load("glGetActiveSubroutineUniformiv\0".ptr);
	glGetActiveSubroutineUniformName = cast(typeof(glGetActiveSubroutineUniformName))load("glGetActiveSubroutineUniformName\0".ptr);
	glGetActiveSubroutineName = cast(typeof(glGetActiveSubroutineName))load("glGetActiveSubroutineName\0".ptr);
	glUniformSubroutinesuiv = cast(typeof(glUniformSubroutinesuiv))load("glUniformSubroutinesuiv\0".ptr);
	glGetUniformSubroutineuiv = cast(typeof(glGetUniformSubroutineuiv))load("glGetUniformSubroutineuiv\0".ptr);
	glGetProgramStageiv = cast(typeof(glGetProgramStageiv))load("glGetProgramStageiv\0".ptr);
	glPatchParameteri = cast(typeof(glPatchParameteri))load("glPatchParameteri\0".ptr);
	glPatchParameterfv = cast(typeof(glPatchParameterfv))load("glPatchParameterfv\0".ptr);
	glBindTransformFeedback = cast(typeof(glBindTransformFeedback))load("glBindTransformFeedback\0".ptr);
	glDeleteTransformFeedbacks = cast(typeof(glDeleteTransformFeedbacks))load("glDeleteTransformFeedbacks\0".ptr);
	glGenTransformFeedbacks = cast(typeof(glGenTransformFeedbacks))load("glGenTransformFeedbacks\0".ptr);
	glIsTransformFeedback = cast(typeof(glIsTransformFeedback))load("glIsTransformFeedback\0".ptr);
	glPauseTransformFeedback = cast(typeof(glPauseTransformFeedback))load("glPauseTransformFeedback\0".ptr);
	glResumeTransformFeedback = cast(typeof(glResumeTransformFeedback))load("glResumeTransformFeedback\0".ptr);
	glDrawTransformFeedback = cast(typeof(glDrawTransformFeedback))load("glDrawTransformFeedback\0".ptr);
	glDrawTransformFeedbackStream = cast(typeof(glDrawTransformFeedbackStream))load("glDrawTransformFeedbackStream\0".ptr);
	glBeginQueryIndexed = cast(typeof(glBeginQueryIndexed))load("glBeginQueryIndexed\0".ptr);
	glEndQueryIndexed = cast(typeof(glEndQueryIndexed))load("glEndQueryIndexed\0".ptr);
	glGetQueryIndexediv = cast(typeof(glGetQueryIndexediv))load("glGetQueryIndexediv\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_1(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_1) return;
	glReleaseShaderCompiler = cast(typeof(glReleaseShaderCompiler))load("glReleaseShaderCompiler\0".ptr);
	glShaderBinary = cast(typeof(glShaderBinary))load("glShaderBinary\0".ptr);
	glGetShaderPrecisionFormat = cast(typeof(glGetShaderPrecisionFormat))load("glGetShaderPrecisionFormat\0".ptr);
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef\0".ptr);
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf\0".ptr);
	glGetProgramBinary = cast(typeof(glGetProgramBinary))load("glGetProgramBinary\0".ptr);
	glProgramBinary = cast(typeof(glProgramBinary))load("glProgramBinary\0".ptr);
	glProgramParameteri = cast(typeof(glProgramParameteri))load("glProgramParameteri\0".ptr);
	glUseProgramStages = cast(typeof(glUseProgramStages))load("glUseProgramStages\0".ptr);
	glActiveShaderProgram = cast(typeof(glActiveShaderProgram))load("glActiveShaderProgram\0".ptr);
	glCreateShaderProgramv = cast(typeof(glCreateShaderProgramv))load("glCreateShaderProgramv\0".ptr);
	glBindProgramPipeline = cast(typeof(glBindProgramPipeline))load("glBindProgramPipeline\0".ptr);
	glDeleteProgramPipelines = cast(typeof(glDeleteProgramPipelines))load("glDeleteProgramPipelines\0".ptr);
	glGenProgramPipelines = cast(typeof(glGenProgramPipelines))load("glGenProgramPipelines\0".ptr);
	glIsProgramPipeline = cast(typeof(glIsProgramPipeline))load("glIsProgramPipeline\0".ptr);
	glGetProgramPipelineiv = cast(typeof(glGetProgramPipelineiv))load("glGetProgramPipelineiv\0".ptr);
	glProgramUniform1i = cast(typeof(glProgramUniform1i))load("glProgramUniform1i\0".ptr);
	glProgramUniform1iv = cast(typeof(glProgramUniform1iv))load("glProgramUniform1iv\0".ptr);
	glProgramUniform1f = cast(typeof(glProgramUniform1f))load("glProgramUniform1f\0".ptr);
	glProgramUniform1fv = cast(typeof(glProgramUniform1fv))load("glProgramUniform1fv\0".ptr);
	glProgramUniform1d = cast(typeof(glProgramUniform1d))load("glProgramUniform1d\0".ptr);
	glProgramUniform1dv = cast(typeof(glProgramUniform1dv))load("glProgramUniform1dv\0".ptr);
	glProgramUniform1ui = cast(typeof(glProgramUniform1ui))load("glProgramUniform1ui\0".ptr);
	glProgramUniform1uiv = cast(typeof(glProgramUniform1uiv))load("glProgramUniform1uiv\0".ptr);
	glProgramUniform2i = cast(typeof(glProgramUniform2i))load("glProgramUniform2i\0".ptr);
	glProgramUniform2iv = cast(typeof(glProgramUniform2iv))load("glProgramUniform2iv\0".ptr);
	glProgramUniform2f = cast(typeof(glProgramUniform2f))load("glProgramUniform2f\0".ptr);
	glProgramUniform2fv = cast(typeof(glProgramUniform2fv))load("glProgramUniform2fv\0".ptr);
	glProgramUniform2d = cast(typeof(glProgramUniform2d))load("glProgramUniform2d\0".ptr);
	glProgramUniform2dv = cast(typeof(glProgramUniform2dv))load("glProgramUniform2dv\0".ptr);
	glProgramUniform2ui = cast(typeof(glProgramUniform2ui))load("glProgramUniform2ui\0".ptr);
	glProgramUniform2uiv = cast(typeof(glProgramUniform2uiv))load("glProgramUniform2uiv\0".ptr);
	glProgramUniform3i = cast(typeof(glProgramUniform3i))load("glProgramUniform3i\0".ptr);
	glProgramUniform3iv = cast(typeof(glProgramUniform3iv))load("glProgramUniform3iv\0".ptr);
	glProgramUniform3f = cast(typeof(glProgramUniform3f))load("glProgramUniform3f\0".ptr);
	glProgramUniform3fv = cast(typeof(glProgramUniform3fv))load("glProgramUniform3fv\0".ptr);
	glProgramUniform3d = cast(typeof(glProgramUniform3d))load("glProgramUniform3d\0".ptr);
	glProgramUniform3dv = cast(typeof(glProgramUniform3dv))load("glProgramUniform3dv\0".ptr);
	glProgramUniform3ui = cast(typeof(glProgramUniform3ui))load("glProgramUniform3ui\0".ptr);
	glProgramUniform3uiv = cast(typeof(glProgramUniform3uiv))load("glProgramUniform3uiv\0".ptr);
	glProgramUniform4i = cast(typeof(glProgramUniform4i))load("glProgramUniform4i\0".ptr);
	glProgramUniform4iv = cast(typeof(glProgramUniform4iv))load("glProgramUniform4iv\0".ptr);
	glProgramUniform4f = cast(typeof(glProgramUniform4f))load("glProgramUniform4f\0".ptr);
	glProgramUniform4fv = cast(typeof(glProgramUniform4fv))load("glProgramUniform4fv\0".ptr);
	glProgramUniform4d = cast(typeof(glProgramUniform4d))load("glProgramUniform4d\0".ptr);
	glProgramUniform4dv = cast(typeof(glProgramUniform4dv))load("glProgramUniform4dv\0".ptr);
	glProgramUniform4ui = cast(typeof(glProgramUniform4ui))load("glProgramUniform4ui\0".ptr);
	glProgramUniform4uiv = cast(typeof(glProgramUniform4uiv))load("glProgramUniform4uiv\0".ptr);
	glProgramUniformMatrix2fv = cast(typeof(glProgramUniformMatrix2fv))load("glProgramUniformMatrix2fv\0".ptr);
	glProgramUniformMatrix3fv = cast(typeof(glProgramUniformMatrix3fv))load("glProgramUniformMatrix3fv\0".ptr);
	glProgramUniformMatrix4fv = cast(typeof(glProgramUniformMatrix4fv))load("glProgramUniformMatrix4fv\0".ptr);
	glProgramUniformMatrix2dv = cast(typeof(glProgramUniformMatrix2dv))load("glProgramUniformMatrix2dv\0".ptr);
	glProgramUniformMatrix3dv = cast(typeof(glProgramUniformMatrix3dv))load("glProgramUniformMatrix3dv\0".ptr);
	glProgramUniformMatrix4dv = cast(typeof(glProgramUniformMatrix4dv))load("glProgramUniformMatrix4dv\0".ptr);
	glProgramUniformMatrix2x3fv = cast(typeof(glProgramUniformMatrix2x3fv))load("glProgramUniformMatrix2x3fv\0".ptr);
	glProgramUniformMatrix3x2fv = cast(typeof(glProgramUniformMatrix3x2fv))load("glProgramUniformMatrix3x2fv\0".ptr);
	glProgramUniformMatrix2x4fv = cast(typeof(glProgramUniformMatrix2x4fv))load("glProgramUniformMatrix2x4fv\0".ptr);
	glProgramUniformMatrix4x2fv = cast(typeof(glProgramUniformMatrix4x2fv))load("glProgramUniformMatrix4x2fv\0".ptr);
	glProgramUniformMatrix3x4fv = cast(typeof(glProgramUniformMatrix3x4fv))load("glProgramUniformMatrix3x4fv\0".ptr);
	glProgramUniformMatrix4x3fv = cast(typeof(glProgramUniformMatrix4x3fv))load("glProgramUniformMatrix4x3fv\0".ptr);
	glProgramUniformMatrix2x3dv = cast(typeof(glProgramUniformMatrix2x3dv))load("glProgramUniformMatrix2x3dv\0".ptr);
	glProgramUniformMatrix3x2dv = cast(typeof(glProgramUniformMatrix3x2dv))load("glProgramUniformMatrix3x2dv\0".ptr);
	glProgramUniformMatrix2x4dv = cast(typeof(glProgramUniformMatrix2x4dv))load("glProgramUniformMatrix2x4dv\0".ptr);
	glProgramUniformMatrix4x2dv = cast(typeof(glProgramUniformMatrix4x2dv))load("glProgramUniformMatrix4x2dv\0".ptr);
	glProgramUniformMatrix3x4dv = cast(typeof(glProgramUniformMatrix3x4dv))load("glProgramUniformMatrix3x4dv\0".ptr);
	glProgramUniformMatrix4x3dv = cast(typeof(glProgramUniformMatrix4x3dv))load("glProgramUniformMatrix4x3dv\0".ptr);
	glValidateProgramPipeline = cast(typeof(glValidateProgramPipeline))load("glValidateProgramPipeline\0".ptr);
	glGetProgramPipelineInfoLog = cast(typeof(glGetProgramPipelineInfoLog))load("glGetProgramPipelineInfoLog\0".ptr);
	glVertexAttribL1d = cast(typeof(glVertexAttribL1d))load("glVertexAttribL1d\0".ptr);
	glVertexAttribL2d = cast(typeof(glVertexAttribL2d))load("glVertexAttribL2d\0".ptr);
	glVertexAttribL3d = cast(typeof(glVertexAttribL3d))load("glVertexAttribL3d\0".ptr);
	glVertexAttribL4d = cast(typeof(glVertexAttribL4d))load("glVertexAttribL4d\0".ptr);
	glVertexAttribL1dv = cast(typeof(glVertexAttribL1dv))load("glVertexAttribL1dv\0".ptr);
	glVertexAttribL2dv = cast(typeof(glVertexAttribL2dv))load("glVertexAttribL2dv\0".ptr);
	glVertexAttribL3dv = cast(typeof(glVertexAttribL3dv))load("glVertexAttribL3dv\0".ptr);
	glVertexAttribL4dv = cast(typeof(glVertexAttribL4dv))load("glVertexAttribL4dv\0".ptr);
	glVertexAttribLPointer = cast(typeof(glVertexAttribLPointer))load("glVertexAttribLPointer\0".ptr);
	glGetVertexAttribLdv = cast(typeof(glGetVertexAttribLdv))load("glGetVertexAttribLdv\0".ptr);
	glViewportArrayv = cast(typeof(glViewportArrayv))load("glViewportArrayv\0".ptr);
	glViewportIndexedf = cast(typeof(glViewportIndexedf))load("glViewportIndexedf\0".ptr);
	glViewportIndexedfv = cast(typeof(glViewportIndexedfv))load("glViewportIndexedfv\0".ptr);
	glScissorArrayv = cast(typeof(glScissorArrayv))load("glScissorArrayv\0".ptr);
	glScissorIndexed = cast(typeof(glScissorIndexed))load("glScissorIndexed\0".ptr);
	glScissorIndexedv = cast(typeof(glScissorIndexedv))load("glScissorIndexedv\0".ptr);
	glDepthRangeArrayv = cast(typeof(glDepthRangeArrayv))load("glDepthRangeArrayv\0".ptr);
	glDepthRangeIndexed = cast(typeof(glDepthRangeIndexed))load("glDepthRangeIndexed\0".ptr);
	glGetFloati_v = cast(typeof(glGetFloati_v))load("glGetFloati_v\0".ptr);
	glGetDoublei_v = cast(typeof(glGetDoublei_v))load("glGetDoublei_v\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_2(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_2) return;
	glDrawArraysInstancedBaseInstance = cast(typeof(glDrawArraysInstancedBaseInstance))load("glDrawArraysInstancedBaseInstance\0".ptr);
	glDrawElementsInstancedBaseInstance = cast(typeof(glDrawElementsInstancedBaseInstance))load("glDrawElementsInstancedBaseInstance\0".ptr);
	glDrawElementsInstancedBaseVertexBaseInstance = cast(typeof(glDrawElementsInstancedBaseVertexBaseInstance))load("glDrawElementsInstancedBaseVertexBaseInstance\0".ptr);
	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v\0".ptr);
	glGetActiveAtomicCounterBufferiv = cast(typeof(glGetActiveAtomicCounterBufferiv))load("glGetActiveAtomicCounterBufferiv\0".ptr);
	glBindImageTexture = cast(typeof(glBindImageTexture))load("glBindImageTexture\0".ptr);
	glMemoryBarrier = cast(typeof(glMemoryBarrier))load("glMemoryBarrier\0".ptr);
	glTexStorage1D = cast(typeof(glTexStorage1D))load("glTexStorage1D\0".ptr);
	glTexStorage2D = cast(typeof(glTexStorage2D))load("glTexStorage2D\0".ptr);
	glTexStorage3D = cast(typeof(glTexStorage3D))load("glTexStorage3D\0".ptr);
	glDrawTransformFeedbackInstanced = cast(typeof(glDrawTransformFeedbackInstanced))load("glDrawTransformFeedbackInstanced\0".ptr);
	glDrawTransformFeedbackStreamInstanced = cast(typeof(glDrawTransformFeedbackStreamInstanced))load("glDrawTransformFeedbackStreamInstanced\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_3(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_3) return;
	glClearBufferData = cast(typeof(glClearBufferData))load("glClearBufferData\0".ptr);
	glClearBufferSubData = cast(typeof(glClearBufferSubData))load("glClearBufferSubData\0".ptr);
	glDispatchCompute = cast(typeof(glDispatchCompute))load("glDispatchCompute\0".ptr);
	glDispatchComputeIndirect = cast(typeof(glDispatchComputeIndirect))load("glDispatchComputeIndirect\0".ptr);
	glCopyImageSubData = cast(typeof(glCopyImageSubData))load("glCopyImageSubData\0".ptr);
	glFramebufferParameteri = cast(typeof(glFramebufferParameteri))load("glFramebufferParameteri\0".ptr);
	glGetFramebufferParameteriv = cast(typeof(glGetFramebufferParameteriv))load("glGetFramebufferParameteriv\0".ptr);
	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v\0".ptr);
	glInvalidateTexSubImage = cast(typeof(glInvalidateTexSubImage))load("glInvalidateTexSubImage\0".ptr);
	glInvalidateTexImage = cast(typeof(glInvalidateTexImage))load("glInvalidateTexImage\0".ptr);
	glInvalidateBufferSubData = cast(typeof(glInvalidateBufferSubData))load("glInvalidateBufferSubData\0".ptr);
	glInvalidateBufferData = cast(typeof(glInvalidateBufferData))load("glInvalidateBufferData\0".ptr);
	glInvalidateFramebuffer = cast(typeof(glInvalidateFramebuffer))load("glInvalidateFramebuffer\0".ptr);
	glInvalidateSubFramebuffer = cast(typeof(glInvalidateSubFramebuffer))load("glInvalidateSubFramebuffer\0".ptr);
	glMultiDrawArraysIndirect = cast(typeof(glMultiDrawArraysIndirect))load("glMultiDrawArraysIndirect\0".ptr);
	glMultiDrawElementsIndirect = cast(typeof(glMultiDrawElementsIndirect))load("glMultiDrawElementsIndirect\0".ptr);
	glGetProgramInterfaceiv = cast(typeof(glGetProgramInterfaceiv))load("glGetProgramInterfaceiv\0".ptr);
	glGetProgramResourceIndex = cast(typeof(glGetProgramResourceIndex))load("glGetProgramResourceIndex\0".ptr);
	glGetProgramResourceName = cast(typeof(glGetProgramResourceName))load("glGetProgramResourceName\0".ptr);
	glGetProgramResourceiv = cast(typeof(glGetProgramResourceiv))load("glGetProgramResourceiv\0".ptr);
	glGetProgramResourceLocation = cast(typeof(glGetProgramResourceLocation))load("glGetProgramResourceLocation\0".ptr);
	glGetProgramResourceLocationIndex = cast(typeof(glGetProgramResourceLocationIndex))load("glGetProgramResourceLocationIndex\0".ptr);
	glShaderStorageBlockBinding = cast(typeof(glShaderStorageBlockBinding))load("glShaderStorageBlockBinding\0".ptr);
	glTexBufferRange = cast(typeof(glTexBufferRange))load("glTexBufferRange\0".ptr);
	glTexStorage2DMultisample = cast(typeof(glTexStorage2DMultisample))load("glTexStorage2DMultisample\0".ptr);
	glTexStorage3DMultisample = cast(typeof(glTexStorage3DMultisample))load("glTexStorage3DMultisample\0".ptr);
	glTextureView = cast(typeof(glTextureView))load("glTextureView\0".ptr);
	glBindVertexBuffer = cast(typeof(glBindVertexBuffer))load("glBindVertexBuffer\0".ptr);
	glVertexAttribFormat = cast(typeof(glVertexAttribFormat))load("glVertexAttribFormat\0".ptr);
	glVertexAttribIFormat = cast(typeof(glVertexAttribIFormat))load("glVertexAttribIFormat\0".ptr);
	glVertexAttribLFormat = cast(typeof(glVertexAttribLFormat))load("glVertexAttribLFormat\0".ptr);
	glVertexAttribBinding = cast(typeof(glVertexAttribBinding))load("glVertexAttribBinding\0".ptr);
	glVertexBindingDivisor = cast(typeof(glVertexBindingDivisor))load("glVertexBindingDivisor\0".ptr);
	glDebugMessageControl = cast(typeof(glDebugMessageControl))load("glDebugMessageControl\0".ptr);
	glDebugMessageInsert = cast(typeof(glDebugMessageInsert))load("glDebugMessageInsert\0".ptr);
	glDebugMessageCallback = cast(typeof(glDebugMessageCallback))load("glDebugMessageCallback\0".ptr);
	glGetDebugMessageLog = cast(typeof(glGetDebugMessageLog))load("glGetDebugMessageLog\0".ptr);
	glPushDebugGroup = cast(typeof(glPushDebugGroup))load("glPushDebugGroup\0".ptr);
	glPopDebugGroup = cast(typeof(glPopDebugGroup))load("glPopDebugGroup\0".ptr);
	glObjectLabel = cast(typeof(glObjectLabel))load("glObjectLabel\0".ptr);
	glGetObjectLabel = cast(typeof(glGetObjectLabel))load("glGetObjectLabel\0".ptr);
	glObjectPtrLabel = cast(typeof(glObjectPtrLabel))load("glObjectPtrLabel\0".ptr);
	glGetObjectPtrLabel = cast(typeof(glGetObjectPtrLabel))load("glGetObjectPtrLabel\0".ptr);
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv\0".ptr);
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_4(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_4) return;
	glBufferStorage = cast(typeof(glBufferStorage))load("glBufferStorage\0".ptr);
	glClearTexImage = cast(typeof(glClearTexImage))load("glClearTexImage\0".ptr);
	glClearTexSubImage = cast(typeof(glClearTexSubImage))load("glClearTexSubImage\0".ptr);
	glBindBuffersBase = cast(typeof(glBindBuffersBase))load("glBindBuffersBase\0".ptr);
	glBindBuffersRange = cast(typeof(glBindBuffersRange))load("glBindBuffersRange\0".ptr);
	glBindTextures = cast(typeof(glBindTextures))load("glBindTextures\0".ptr);
	glBindSamplers = cast(typeof(glBindSamplers))load("glBindSamplers\0".ptr);
	glBindImageTextures = cast(typeof(glBindImageTextures))load("glBindImageTextures\0".ptr);
	glBindVertexBuffers = cast(typeof(glBindVertexBuffers))load("glBindVertexBuffers\0".ptr);
	return;
}

bool load_gl_GL_NV_point_sprite(void* function(const(char)* name) load) {
	if(!GL_NV_point_sprite) return GL_NV_point_sprite;

	glPointParameteriNV = cast(typeof(glPointParameteriNV))load("glPointParameteriNV\0".ptr);
	glPointParameterivNV = cast(typeof(glPointParameterivNV))load("glPointParameterivNV\0".ptr);
	return GL_NV_point_sprite;
}


bool load_gl_GL_APPLE_element_array(void* function(const(char)* name) load) {
	if(!GL_APPLE_element_array) return GL_APPLE_element_array;

	glElementPointerAPPLE = cast(typeof(glElementPointerAPPLE))load("glElementPointerAPPLE\0".ptr);
	glDrawElementArrayAPPLE = cast(typeof(glDrawElementArrayAPPLE))load("glDrawElementArrayAPPLE\0".ptr);
	glDrawRangeElementArrayAPPLE = cast(typeof(glDrawRangeElementArrayAPPLE))load("glDrawRangeElementArrayAPPLE\0".ptr);
	glMultiDrawElementArrayAPPLE = cast(typeof(glMultiDrawElementArrayAPPLE))load("glMultiDrawElementArrayAPPLE\0".ptr);
	glMultiDrawRangeElementArrayAPPLE = cast(typeof(glMultiDrawRangeElementArrayAPPLE))load("glMultiDrawRangeElementArrayAPPLE\0".ptr);
	return GL_APPLE_element_array;
}


bool load_gl_GL_AMD_multi_draw_indirect(void* function(const(char)* name) load) {
	if(!GL_AMD_multi_draw_indirect) return GL_AMD_multi_draw_indirect;

	glMultiDrawArraysIndirectAMD = cast(typeof(glMultiDrawArraysIndirectAMD))load("glMultiDrawArraysIndirectAMD\0".ptr);
	glMultiDrawElementsIndirectAMD = cast(typeof(glMultiDrawElementsIndirectAMD))load("glMultiDrawElementsIndirectAMD\0".ptr);
	return GL_AMD_multi_draw_indirect;
}


bool load_gl_GL_SGIX_tag_sample_buffer(void* function(const(char)* name) load) {
	if(!GL_SGIX_tag_sample_buffer) return GL_SGIX_tag_sample_buffer;

	glTagSampleBufferSGIX = cast(typeof(glTagSampleBufferSGIX))load("glTagSampleBufferSGIX\0".ptr);
	return GL_SGIX_tag_sample_buffer;
}


bool load_gl_GL_ATI_separate_stencil(void* function(const(char)* name) load) {
	if(!GL_ATI_separate_stencil) return GL_ATI_separate_stencil;

	glStencilOpSeparateATI = cast(typeof(glStencilOpSeparateATI))load("glStencilOpSeparateATI\0".ptr);
	glStencilFuncSeparateATI = cast(typeof(glStencilFuncSeparateATI))load("glStencilFuncSeparateATI\0".ptr);
	return GL_ATI_separate_stencil;
}


bool load_gl_GL_EXT_texture_buffer_object(void* function(const(char)* name) load) {
	if(!GL_EXT_texture_buffer_object) return GL_EXT_texture_buffer_object;

	glTexBufferEXT = cast(typeof(glTexBufferEXT))load("glTexBufferEXT\0".ptr);
	return GL_EXT_texture_buffer_object;
}


bool load_gl_GL_ARB_vertex_blend(void* function(const(char)* name) load) {
	if(!GL_ARB_vertex_blend) return GL_ARB_vertex_blend;

	glWeightbvARB = cast(typeof(glWeightbvARB))load("glWeightbvARB\0".ptr);
	glWeightsvARB = cast(typeof(glWeightsvARB))load("glWeightsvARB\0".ptr);
	glWeightivARB = cast(typeof(glWeightivARB))load("glWeightivARB\0".ptr);
	glWeightfvARB = cast(typeof(glWeightfvARB))load("glWeightfvARB\0".ptr);
	glWeightdvARB = cast(typeof(glWeightdvARB))load("glWeightdvARB\0".ptr);
	glWeightubvARB = cast(typeof(glWeightubvARB))load("glWeightubvARB\0".ptr);
	glWeightusvARB = cast(typeof(glWeightusvARB))load("glWeightusvARB\0".ptr);
	glWeightuivARB = cast(typeof(glWeightuivARB))load("glWeightuivARB\0".ptr);
	glWeightPointerARB = cast(typeof(glWeightPointerARB))load("glWeightPointerARB\0".ptr);
	glVertexBlendARB = cast(typeof(glVertexBlendARB))load("glVertexBlendARB\0".ptr);
	return GL_ARB_vertex_blend;
}


bool load_gl_GL_ARB_program_interface_query(void* function(const(char)* name) load) {
	if(!GL_ARB_program_interface_query) return GL_ARB_program_interface_query;

	glGetProgramInterfaceiv = cast(typeof(glGetProgramInterfaceiv))load("glGetProgramInterfaceiv\0".ptr);
	glGetProgramResourceIndex = cast(typeof(glGetProgramResourceIndex))load("glGetProgramResourceIndex\0".ptr);
	glGetProgramResourceName = cast(typeof(glGetProgramResourceName))load("glGetProgramResourceName\0".ptr);
	glGetProgramResourceiv = cast(typeof(glGetProgramResourceiv))load("glGetProgramResourceiv\0".ptr);
	glGetProgramResourceLocation = cast(typeof(glGetProgramResourceLocation))load("glGetProgramResourceLocation\0".ptr);
	glGetProgramResourceLocationIndex = cast(typeof(glGetProgramResourceLocationIndex))load("glGetProgramResourceLocationIndex\0".ptr);
	return GL_ARB_program_interface_query;
}


bool load_gl_GL_EXT_index_func(void* function(const(char)* name) load) {
	if(!GL_EXT_index_func) return GL_EXT_index_func;

	glIndexFuncEXT = cast(typeof(glIndexFuncEXT))load("glIndexFuncEXT\0".ptr);
	return GL_EXT_index_func;
}


bool load_gl_GL_NV_shader_buffer_load(void* function(const(char)* name) load) {
	if(!GL_NV_shader_buffer_load) return GL_NV_shader_buffer_load;

	glMakeBufferResidentNV = cast(typeof(glMakeBufferResidentNV))load("glMakeBufferResidentNV\0".ptr);
	glMakeBufferNonResidentNV = cast(typeof(glMakeBufferNonResidentNV))load("glMakeBufferNonResidentNV\0".ptr);
	glIsBufferResidentNV = cast(typeof(glIsBufferResidentNV))load("glIsBufferResidentNV\0".ptr);
	glMakeNamedBufferResidentNV = cast(typeof(glMakeNamedBufferResidentNV))load("glMakeNamedBufferResidentNV\0".ptr);
	glMakeNamedBufferNonResidentNV = cast(typeof(glMakeNamedBufferNonResidentNV))load("glMakeNamedBufferNonResidentNV\0".ptr);
	glIsNamedBufferResidentNV = cast(typeof(glIsNamedBufferResidentNV))load("glIsNamedBufferResidentNV\0".ptr);
	glGetBufferParameterui64vNV = cast(typeof(glGetBufferParameterui64vNV))load("glGetBufferParameterui64vNV\0".ptr);
	glGetNamedBufferParameterui64vNV = cast(typeof(glGetNamedBufferParameterui64vNV))load("glGetNamedBufferParameterui64vNV\0".ptr);
	glGetIntegerui64vNV = cast(typeof(glGetIntegerui64vNV))load("glGetIntegerui64vNV\0".ptr);
	glUniformui64NV = cast(typeof(glUniformui64NV))load("glUniformui64NV\0".ptr);
	glUniformui64vNV = cast(typeof(glUniformui64vNV))load("glUniformui64vNV\0".ptr);
	glGetUniformui64vNV = cast(typeof(glGetUniformui64vNV))load("glGetUniformui64vNV\0".ptr);
	glProgramUniformui64NV = cast(typeof(glProgramUniformui64NV))load("glProgramUniformui64NV\0".ptr);
	glProgramUniformui64vNV = cast(typeof(glProgramUniformui64vNV))load("glProgramUniformui64vNV\0".ptr);
	return GL_NV_shader_buffer_load;
}


bool load_gl_GL_EXT_color_subtable(void* function(const(char)* name) load) {
	if(!GL_EXT_color_subtable) return GL_EXT_color_subtable;

	glColorSubTableEXT = cast(typeof(glColorSubTableEXT))load("glColorSubTableEXT\0".ptr);
	glCopyColorSubTableEXT = cast(typeof(glCopyColorSubTableEXT))load("glCopyColorSubTableEXT\0".ptr);
	return GL_EXT_color_subtable;
}


bool load_gl_GL_SUNX_constant_data(void* function(const(char)* name) load) {
	if(!GL_SUNX_constant_data) return GL_SUNX_constant_data;

	glFinishTextureSUNX = cast(typeof(glFinishTextureSUNX))load("glFinishTextureSUNX\0".ptr);
	return GL_SUNX_constant_data;
}


bool load_gl_GL_EXT_multi_draw_arrays(void* function(const(char)* name) load) {
	if(!GL_EXT_multi_draw_arrays) return GL_EXT_multi_draw_arrays;

	glMultiDrawArraysEXT = cast(typeof(glMultiDrawArraysEXT))load("glMultiDrawArraysEXT\0".ptr);
	glMultiDrawElementsEXT = cast(typeof(glMultiDrawElementsEXT))load("glMultiDrawElementsEXT\0".ptr);
	return GL_EXT_multi_draw_arrays;
}


bool load_gl_GL_ARB_shader_atomic_counters(void* function(const(char)* name) load) {
	if(!GL_ARB_shader_atomic_counters) return GL_ARB_shader_atomic_counters;

	glGetActiveAtomicCounterBufferiv = cast(typeof(glGetActiveAtomicCounterBufferiv))load("glGetActiveAtomicCounterBufferiv\0".ptr);
	return GL_ARB_shader_atomic_counters;
}


bool load_gl_GL_NV_conditional_render(void* function(const(char)* name) load) {
	if(!GL_NV_conditional_render) return GL_NV_conditional_render;

	glBeginConditionalRenderNV = cast(typeof(glBeginConditionalRenderNV))load("glBeginConditionalRenderNV\0".ptr);
	glEndConditionalRenderNV = cast(typeof(glEndConditionalRenderNV))load("glEndConditionalRenderNV\0".ptr);
	return GL_NV_conditional_render;
}


bool load_gl_GL_MESA_resize_buffers(void* function(const(char)* name) load) {
	if(!GL_MESA_resize_buffers) return GL_MESA_resize_buffers;

	glResizeBuffersMESA = cast(typeof(glResizeBuffersMESA))load("glResizeBuffersMESA\0".ptr);
	return GL_MESA_resize_buffers;
}


bool load_gl_GL_ARB_texture_view(void* function(const(char)* name) load) {
	if(!GL_ARB_texture_view) return GL_ARB_texture_view;

	glTextureView = cast(typeof(glTextureView))load("glTextureView\0".ptr);
	return GL_ARB_texture_view;
}


bool load_gl_GL_ARB_map_buffer_range(void* function(const(char)* name) load) {
	if(!GL_ARB_map_buffer_range) return GL_ARB_map_buffer_range;

	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange\0".ptr);
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange\0".ptr);
	return GL_ARB_map_buffer_range;
}


bool load_gl_GL_EXT_convolution(void* function(const(char)* name) load) {
	if(!GL_EXT_convolution) return GL_EXT_convolution;

	glConvolutionFilter1DEXT = cast(typeof(glConvolutionFilter1DEXT))load("glConvolutionFilter1DEXT\0".ptr);
	glConvolutionFilter2DEXT = cast(typeof(glConvolutionFilter2DEXT))load("glConvolutionFilter2DEXT\0".ptr);
	glConvolutionParameterfEXT = cast(typeof(glConvolutionParameterfEXT))load("glConvolutionParameterfEXT\0".ptr);
	glConvolutionParameterfvEXT = cast(typeof(glConvolutionParameterfvEXT))load("glConvolutionParameterfvEXT\0".ptr);
	glConvolutionParameteriEXT = cast(typeof(glConvolutionParameteriEXT))load("glConvolutionParameteriEXT\0".ptr);
	glConvolutionParameterivEXT = cast(typeof(glConvolutionParameterivEXT))load("glConvolutionParameterivEXT\0".ptr);
	glCopyConvolutionFilter1DEXT = cast(typeof(glCopyConvolutionFilter1DEXT))load("glCopyConvolutionFilter1DEXT\0".ptr);
	glCopyConvolutionFilter2DEXT = cast(typeof(glCopyConvolutionFilter2DEXT))load("glCopyConvolutionFilter2DEXT\0".ptr);
	glGetConvolutionFilterEXT = cast(typeof(glGetConvolutionFilterEXT))load("glGetConvolutionFilterEXT\0".ptr);
	glGetConvolutionParameterfvEXT = cast(typeof(glGetConvolutionParameterfvEXT))load("glGetConvolutionParameterfvEXT\0".ptr);
	glGetConvolutionParameterivEXT = cast(typeof(glGetConvolutionParameterivEXT))load("glGetConvolutionParameterivEXT\0".ptr);
	glGetSeparableFilterEXT = cast(typeof(glGetSeparableFilterEXT))load("glGetSeparableFilterEXT\0".ptr);
	glSeparableFilter2DEXT = cast(typeof(glSeparableFilter2DEXT))load("glSeparableFilter2DEXT\0".ptr);
	return GL_EXT_convolution;
}


bool load_gl_GL_NV_vertex_attrib_integer_64bit(void* function(const(char)* name) load) {
	if(!GL_NV_vertex_attrib_integer_64bit) return GL_NV_vertex_attrib_integer_64bit;

	glVertexAttribL1i64NV = cast(typeof(glVertexAttribL1i64NV))load("glVertexAttribL1i64NV\0".ptr);
	glVertexAttribL2i64NV = cast(typeof(glVertexAttribL2i64NV))load("glVertexAttribL2i64NV\0".ptr);
	glVertexAttribL3i64NV = cast(typeof(glVertexAttribL3i64NV))load("glVertexAttribL3i64NV\0".ptr);
	glVertexAttribL4i64NV = cast(typeof(glVertexAttribL4i64NV))load("glVertexAttribL4i64NV\0".ptr);
	glVertexAttribL1i64vNV = cast(typeof(glVertexAttribL1i64vNV))load("glVertexAttribL1i64vNV\0".ptr);
	glVertexAttribL2i64vNV = cast(typeof(glVertexAttribL2i64vNV))load("glVertexAttribL2i64vNV\0".ptr);
	glVertexAttribL3i64vNV = cast(typeof(glVertexAttribL3i64vNV))load("glVertexAttribL3i64vNV\0".ptr);
	glVertexAttribL4i64vNV = cast(typeof(glVertexAttribL4i64vNV))load("glVertexAttribL4i64vNV\0".ptr);
	glVertexAttribL1ui64NV = cast(typeof(glVertexAttribL1ui64NV))load("glVertexAttribL1ui64NV\0".ptr);
	glVertexAttribL2ui64NV = cast(typeof(glVertexAttribL2ui64NV))load("glVertexAttribL2ui64NV\0".ptr);
	glVertexAttribL3ui64NV = cast(typeof(glVertexAttribL3ui64NV))load("glVertexAttribL3ui64NV\0".ptr);
	glVertexAttribL4ui64NV = cast(typeof(glVertexAttribL4ui64NV))load("glVertexAttribL4ui64NV\0".ptr);
	glVertexAttribL1ui64vNV = cast(typeof(glVertexAttribL1ui64vNV))load("glVertexAttribL1ui64vNV\0".ptr);
	glVertexAttribL2ui64vNV = cast(typeof(glVertexAttribL2ui64vNV))load("glVertexAttribL2ui64vNV\0".ptr);
	glVertexAttribL3ui64vNV = cast(typeof(glVertexAttribL3ui64vNV))load("glVertexAttribL3ui64vNV\0".ptr);
	glVertexAttribL4ui64vNV = cast(typeof(glVertexAttribL4ui64vNV))load("glVertexAttribL4ui64vNV\0".ptr);
	glGetVertexAttribLi64vNV = cast(typeof(glGetVertexAttribLi64vNV))load("glGetVertexAttribLi64vNV\0".ptr);
	glGetVertexAttribLui64vNV = cast(typeof(glGetVertexAttribLui64vNV))load("glGetVertexAttribLui64vNV\0".ptr);
	glVertexAttribLFormatNV = cast(typeof(glVertexAttribLFormatNV))load("glVertexAttribLFormatNV\0".ptr);
	return GL_NV_vertex_attrib_integer_64bit;
}


bool load_gl_GL_EXT_paletted_texture(void* function(const(char)* name) load) {
	if(!GL_EXT_paletted_texture) return GL_EXT_paletted_texture;

	glColorTableEXT = cast(typeof(glColorTableEXT))load("glColorTableEXT\0".ptr);
	glGetColorTableEXT = cast(typeof(glGetColorTableEXT))load("glGetColorTableEXT\0".ptr);
	glGetColorTableParameterivEXT = cast(typeof(glGetColorTableParameterivEXT))load("glGetColorTableParameterivEXT\0".ptr);
	glGetColorTableParameterfvEXT = cast(typeof(glGetColorTableParameterfvEXT))load("glGetColorTableParameterfvEXT\0".ptr);
	return GL_EXT_paletted_texture;
}


bool load_gl_GL_ARB_texture_buffer_object(void* function(const(char)* name) load) {
	if(!GL_ARB_texture_buffer_object) return GL_ARB_texture_buffer_object;

	glTexBufferARB = cast(typeof(glTexBufferARB))load("glTexBufferARB\0".ptr);
	return GL_ARB_texture_buffer_object;
}


bool load_gl_GL_ATI_pn_triangles(void* function(const(char)* name) load) {
	if(!GL_ATI_pn_triangles) return GL_ATI_pn_triangles;

	glPNTrianglesiATI = cast(typeof(glPNTrianglesiATI))load("glPNTrianglesiATI\0".ptr);
	glPNTrianglesfATI = cast(typeof(glPNTrianglesfATI))load("glPNTrianglesfATI\0".ptr);
	return GL_ATI_pn_triangles;
}


bool load_gl_GL_SGIX_flush_raster(void* function(const(char)* name) load) {
	if(!GL_SGIX_flush_raster) return GL_SGIX_flush_raster;

	glFlushRasterSGIX = cast(typeof(glFlushRasterSGIX))load("glFlushRasterSGIX\0".ptr);
	return GL_SGIX_flush_raster;
}


bool load_gl_GL_EXT_light_texture(void* function(const(char)* name) load) {
	if(!GL_EXT_light_texture) return GL_EXT_light_texture;

	glApplyTextureEXT = cast(typeof(glApplyTextureEXT))load("glApplyTextureEXT\0".ptr);
	glTextureLightEXT = cast(typeof(glTextureLightEXT))load("glTextureLightEXT\0".ptr);
	glTextureMaterialEXT = cast(typeof(glTextureMaterialEXT))load("glTextureMaterialEXT\0".ptr);
	return GL_EXT_light_texture;
}


bool load_gl_GL_AMD_draw_buffers_blend(void* function(const(char)* name) load) {
	if(!GL_AMD_draw_buffers_blend) return GL_AMD_draw_buffers_blend;

	glBlendFuncIndexedAMD = cast(typeof(glBlendFuncIndexedAMD))load("glBlendFuncIndexedAMD\0".ptr);
	glBlendFuncSeparateIndexedAMD = cast(typeof(glBlendFuncSeparateIndexedAMD))load("glBlendFuncSeparateIndexedAMD\0".ptr);
	glBlendEquationIndexedAMD = cast(typeof(glBlendEquationIndexedAMD))load("glBlendEquationIndexedAMD\0".ptr);
	glBlendEquationSeparateIndexedAMD = cast(typeof(glBlendEquationSeparateIndexedAMD))load("glBlendEquationSeparateIndexedAMD\0".ptr);
	return GL_AMD_draw_buffers_blend;
}


bool load_gl_GL_MESA_window_pos(void* function(const(char)* name) load) {
	if(!GL_MESA_window_pos) return GL_MESA_window_pos;

	glWindowPos2dMESA = cast(typeof(glWindowPos2dMESA))load("glWindowPos2dMESA\0".ptr);
	glWindowPos2dvMESA = cast(typeof(glWindowPos2dvMESA))load("glWindowPos2dvMESA\0".ptr);
	glWindowPos2fMESA = cast(typeof(glWindowPos2fMESA))load("glWindowPos2fMESA\0".ptr);
	glWindowPos2fvMESA = cast(typeof(glWindowPos2fvMESA))load("glWindowPos2fvMESA\0".ptr);
	glWindowPos2iMESA = cast(typeof(glWindowPos2iMESA))load("glWindowPos2iMESA\0".ptr);
	glWindowPos2ivMESA = cast(typeof(glWindowPos2ivMESA))load("glWindowPos2ivMESA\0".ptr);
	glWindowPos2sMESA = cast(typeof(glWindowPos2sMESA))load("glWindowPos2sMESA\0".ptr);
	glWindowPos2svMESA = cast(typeof(glWindowPos2svMESA))load("glWindowPos2svMESA\0".ptr);
	glWindowPos3dMESA = cast(typeof(glWindowPos3dMESA))load("glWindowPos3dMESA\0".ptr);
	glWindowPos3dvMESA = cast(typeof(glWindowPos3dvMESA))load("glWindowPos3dvMESA\0".ptr);
	glWindowPos3fMESA = cast(typeof(glWindowPos3fMESA))load("glWindowPos3fMESA\0".ptr);
	glWindowPos3fvMESA = cast(typeof(glWindowPos3fvMESA))load("glWindowPos3fvMESA\0".ptr);
	glWindowPos3iMESA = cast(typeof(glWindowPos3iMESA))load("glWindowPos3iMESA\0".ptr);
	glWindowPos3ivMESA = cast(typeof(glWindowPos3ivMESA))load("glWindowPos3ivMESA\0".ptr);
	glWindowPos3sMESA = cast(typeof(glWindowPos3sMESA))load("glWindowPos3sMESA\0".ptr);
	glWindowPos3svMESA = cast(typeof(glWindowPos3svMESA))load("glWindowPos3svMESA\0".ptr);
	glWindowPos4dMESA = cast(typeof(glWindowPos4dMESA))load("glWindowPos4dMESA\0".ptr);
	glWindowPos4dvMESA = cast(typeof(glWindowPos4dvMESA))load("glWindowPos4dvMESA\0".ptr);
	glWindowPos4fMESA = cast(typeof(glWindowPos4fMESA))load("glWindowPos4fMESA\0".ptr);
	glWindowPos4fvMESA = cast(typeof(glWindowPos4fvMESA))load("glWindowPos4fvMESA\0".ptr);
	glWindowPos4iMESA = cast(typeof(glWindowPos4iMESA))load("glWindowPos4iMESA\0".ptr);
	glWindowPos4ivMESA = cast(typeof(glWindowPos4ivMESA))load("glWindowPos4ivMESA\0".ptr);
	glWindowPos4sMESA = cast(typeof(glWindowPos4sMESA))load("glWindowPos4sMESA\0".ptr);
	glWindowPos4svMESA = cast(typeof(glWindowPos4svMESA))load("glWindowPos4svMESA\0".ptr);
	return GL_MESA_window_pos;
}


bool load_gl_GL_NV_texture_barrier(void* function(const(char)* name) load) {
	if(!GL_NV_texture_barrier) return GL_NV_texture_barrier;

	glTextureBarrierNV = cast(typeof(glTextureBarrierNV))load("glTextureBarrierNV\0".ptr);
	return GL_NV_texture_barrier;
}


bool load_gl_GL_ARB_vertex_type_2_10_10_10_rev(void* function(const(char)* name) load) {
	if(!GL_ARB_vertex_type_2_10_10_10_rev) return GL_ARB_vertex_type_2_10_10_10_rev;

	glVertexAttribP1ui = cast(typeof(glVertexAttribP1ui))load("glVertexAttribP1ui\0".ptr);
	glVertexAttribP1uiv = cast(typeof(glVertexAttribP1uiv))load("glVertexAttribP1uiv\0".ptr);
	glVertexAttribP2ui = cast(typeof(glVertexAttribP2ui))load("glVertexAttribP2ui\0".ptr);
	glVertexAttribP2uiv = cast(typeof(glVertexAttribP2uiv))load("glVertexAttribP2uiv\0".ptr);
	glVertexAttribP3ui = cast(typeof(glVertexAttribP3ui))load("glVertexAttribP3ui\0".ptr);
	glVertexAttribP3uiv = cast(typeof(glVertexAttribP3uiv))load("glVertexAttribP3uiv\0".ptr);
	glVertexAttribP4ui = cast(typeof(glVertexAttribP4ui))load("glVertexAttribP4ui\0".ptr);
	glVertexAttribP4uiv = cast(typeof(glVertexAttribP4uiv))load("glVertexAttribP4uiv\0".ptr);
	glVertexP2ui = cast(typeof(glVertexP2ui))load("glVertexP2ui\0".ptr);
	glVertexP2uiv = cast(typeof(glVertexP2uiv))load("glVertexP2uiv\0".ptr);
	glVertexP3ui = cast(typeof(glVertexP3ui))load("glVertexP3ui\0".ptr);
	glVertexP3uiv = cast(typeof(glVertexP3uiv))load("glVertexP3uiv\0".ptr);
	glVertexP4ui = cast(typeof(glVertexP4ui))load("glVertexP4ui\0".ptr);
	glVertexP4uiv = cast(typeof(glVertexP4uiv))load("glVertexP4uiv\0".ptr);
	glTexCoordP1ui = cast(typeof(glTexCoordP1ui))load("glTexCoordP1ui\0".ptr);
	glTexCoordP1uiv = cast(typeof(glTexCoordP1uiv))load("glTexCoordP1uiv\0".ptr);
	glTexCoordP2ui = cast(typeof(glTexCoordP2ui))load("glTexCoordP2ui\0".ptr);
	glTexCoordP2uiv = cast(typeof(glTexCoordP2uiv))load("glTexCoordP2uiv\0".ptr);
	glTexCoordP3ui = cast(typeof(glTexCoordP3ui))load("glTexCoordP3ui\0".ptr);
	glTexCoordP3uiv = cast(typeof(glTexCoordP3uiv))load("glTexCoordP3uiv\0".ptr);
	glTexCoordP4ui = cast(typeof(glTexCoordP4ui))load("glTexCoordP4ui\0".ptr);
	glTexCoordP4uiv = cast(typeof(glTexCoordP4uiv))load("glTexCoordP4uiv\0".ptr);
	glMultiTexCoordP1ui = cast(typeof(glMultiTexCoordP1ui))load("glMultiTexCoordP1ui\0".ptr);
	glMultiTexCoordP1uiv = cast(typeof(glMultiTexCoordP1uiv))load("glMultiTexCoordP1uiv\0".ptr);
	glMultiTexCoordP2ui = cast(typeof(glMultiTexCoordP2ui))load("glMultiTexCoordP2ui\0".ptr);
	glMultiTexCoordP2uiv = cast(typeof(glMultiTexCoordP2uiv))load("glMultiTexCoordP2uiv\0".ptr);
	glMultiTexCoordP3ui = cast(typeof(glMultiTexCoordP3ui))load("glMultiTexCoordP3ui\0".ptr);
	glMultiTexCoordP3uiv = cast(typeof(glMultiTexCoordP3uiv))load("glMultiTexCoordP3uiv\0".ptr);
	glMultiTexCoordP4ui = cast(typeof(glMultiTexCoordP4ui))load("glMultiTexCoordP4ui\0".ptr);
	glMultiTexCoordP4uiv = cast(typeof(glMultiTexCoordP4uiv))load("glMultiTexCoordP4uiv\0".ptr);
	glNormalP3ui = cast(typeof(glNormalP3ui))load("glNormalP3ui\0".ptr);
	glNormalP3uiv = cast(typeof(glNormalP3uiv))load("glNormalP3uiv\0".ptr);
	glColorP3ui = cast(typeof(glColorP3ui))load("glColorP3ui\0".ptr);
	glColorP3uiv = cast(typeof(glColorP3uiv))load("glColorP3uiv\0".ptr);
	glColorP4ui = cast(typeof(glColorP4ui))load("glColorP4ui\0".ptr);
	glColorP4uiv = cast(typeof(glColorP4uiv))load("glColorP4uiv\0".ptr);
	glSecondaryColorP3ui = cast(typeof(glSecondaryColorP3ui))load("glSecondaryColorP3ui\0".ptr);
	glSecondaryColorP3uiv = cast(typeof(glSecondaryColorP3uiv))load("glSecondaryColorP3uiv\0".ptr);
	return GL_ARB_vertex_type_2_10_10_10_rev;
}


bool load_gl_GL_3DFX_tbuffer(void* function(const(char)* name) load) {
	if(!GL_3DFX_tbuffer) return GL_3DFX_tbuffer;

	glTbufferMask3DFX = cast(typeof(glTbufferMask3DFX))load("glTbufferMask3DFX\0".ptr);
	return GL_3DFX_tbuffer;
}


bool load_gl_GL_GREMEDY_frame_terminator(void* function(const(char)* name) load) {
	if(!GL_GREMEDY_frame_terminator) return GL_GREMEDY_frame_terminator;

	glFrameTerminatorGREMEDY = cast(typeof(glFrameTerminatorGREMEDY))load("glFrameTerminatorGREMEDY\0".ptr);
	return GL_GREMEDY_frame_terminator;
}


bool load_gl_GL_ARB_blend_func_extended(void* function(const(char)* name) load) {
	if(!GL_ARB_blend_func_extended) return GL_ARB_blend_func_extended;

	glBindFragDataLocationIndexed = cast(typeof(glBindFragDataLocationIndexed))load("glBindFragDataLocationIndexed\0".ptr);
	glGetFragDataIndex = cast(typeof(glGetFragDataIndex))load("glGetFragDataIndex\0".ptr);
	return GL_ARB_blend_func_extended;
}


bool load_gl_GL_EXT_separate_shader_objects(void* function(const(char)* name) load) {
	if(!GL_EXT_separate_shader_objects) return GL_EXT_separate_shader_objects;

	glUseShaderProgramEXT = cast(typeof(glUseShaderProgramEXT))load("glUseShaderProgramEXT\0".ptr);
	glActiveProgramEXT = cast(typeof(glActiveProgramEXT))load("glActiveProgramEXT\0".ptr);
	glCreateShaderProgramEXT = cast(typeof(glCreateShaderProgramEXT))load("glCreateShaderProgramEXT\0".ptr);
	glActiveShaderProgramEXT = cast(typeof(glActiveShaderProgramEXT))load("glActiveShaderProgramEXT\0".ptr);
	glBindProgramPipelineEXT = cast(typeof(glBindProgramPipelineEXT))load("glBindProgramPipelineEXT\0".ptr);
	glCreateShaderProgramvEXT = cast(typeof(glCreateShaderProgramvEXT))load("glCreateShaderProgramvEXT\0".ptr);
	glDeleteProgramPipelinesEXT = cast(typeof(glDeleteProgramPipelinesEXT))load("glDeleteProgramPipelinesEXT\0".ptr);
	glGenProgramPipelinesEXT = cast(typeof(glGenProgramPipelinesEXT))load("glGenProgramPipelinesEXT\0".ptr);
	glGetProgramPipelineInfoLogEXT = cast(typeof(glGetProgramPipelineInfoLogEXT))load("glGetProgramPipelineInfoLogEXT\0".ptr);
	glGetProgramPipelineivEXT = cast(typeof(glGetProgramPipelineivEXT))load("glGetProgramPipelineivEXT\0".ptr);
	glIsProgramPipelineEXT = cast(typeof(glIsProgramPipelineEXT))load("glIsProgramPipelineEXT\0".ptr);
	glProgramParameteriEXT = cast(typeof(glProgramParameteriEXT))load("glProgramParameteriEXT\0".ptr);
	glProgramUniform1fEXT = cast(typeof(glProgramUniform1fEXT))load("glProgramUniform1fEXT\0".ptr);
	glProgramUniform1fvEXT = cast(typeof(glProgramUniform1fvEXT))load("glProgramUniform1fvEXT\0".ptr);
	glProgramUniform1iEXT = cast(typeof(glProgramUniform1iEXT))load("glProgramUniform1iEXT\0".ptr);
	glProgramUniform1ivEXT = cast(typeof(glProgramUniform1ivEXT))load("glProgramUniform1ivEXT\0".ptr);
	glProgramUniform2fEXT = cast(typeof(glProgramUniform2fEXT))load("glProgramUniform2fEXT\0".ptr);
	glProgramUniform2fvEXT = cast(typeof(glProgramUniform2fvEXT))load("glProgramUniform2fvEXT\0".ptr);
	glProgramUniform2iEXT = cast(typeof(glProgramUniform2iEXT))load("glProgramUniform2iEXT\0".ptr);
	glProgramUniform2ivEXT = cast(typeof(glProgramUniform2ivEXT))load("glProgramUniform2ivEXT\0".ptr);
	glProgramUniform3fEXT = cast(typeof(glProgramUniform3fEXT))load("glProgramUniform3fEXT\0".ptr);
	glProgramUniform3fvEXT = cast(typeof(glProgramUniform3fvEXT))load("glProgramUniform3fvEXT\0".ptr);
	glProgramUniform3iEXT = cast(typeof(glProgramUniform3iEXT))load("glProgramUniform3iEXT\0".ptr);
	glProgramUniform3ivEXT = cast(typeof(glProgramUniform3ivEXT))load("glProgramUniform3ivEXT\0".ptr);
	glProgramUniform4fEXT = cast(typeof(glProgramUniform4fEXT))load("glProgramUniform4fEXT\0".ptr);
	glProgramUniform4fvEXT = cast(typeof(glProgramUniform4fvEXT))load("glProgramUniform4fvEXT\0".ptr);
	glProgramUniform4iEXT = cast(typeof(glProgramUniform4iEXT))load("glProgramUniform4iEXT\0".ptr);
	glProgramUniform4ivEXT = cast(typeof(glProgramUniform4ivEXT))load("glProgramUniform4ivEXT\0".ptr);
	glProgramUniformMatrix2fvEXT = cast(typeof(glProgramUniformMatrix2fvEXT))load("glProgramUniformMatrix2fvEXT\0".ptr);
	glProgramUniformMatrix3fvEXT = cast(typeof(glProgramUniformMatrix3fvEXT))load("glProgramUniformMatrix3fvEXT\0".ptr);
	glProgramUniformMatrix4fvEXT = cast(typeof(glProgramUniformMatrix4fvEXT))load("glProgramUniformMatrix4fvEXT\0".ptr);
	glUseProgramStagesEXT = cast(typeof(glUseProgramStagesEXT))load("glUseProgramStagesEXT\0".ptr);
	glValidateProgramPipelineEXT = cast(typeof(glValidateProgramPipelineEXT))load("glValidateProgramPipelineEXT\0".ptr);
	return GL_EXT_separate_shader_objects;
}


bool load_gl_GL_NV_texture_multisample(void* function(const(char)* name) load) {
	if(!GL_NV_texture_multisample) return GL_NV_texture_multisample;

	glTexImage2DMultisampleCoverageNV = cast(typeof(glTexImage2DMultisampleCoverageNV))load("glTexImage2DMultisampleCoverageNV\0".ptr);
	glTexImage3DMultisampleCoverageNV = cast(typeof(glTexImage3DMultisampleCoverageNV))load("glTexImage3DMultisampleCoverageNV\0".ptr);
	glTextureImage2DMultisampleNV = cast(typeof(glTextureImage2DMultisampleNV))load("glTextureImage2DMultisampleNV\0".ptr);
	glTextureImage3DMultisampleNV = cast(typeof(glTextureImage3DMultisampleNV))load("glTextureImage3DMultisampleNV\0".ptr);
	glTextureImage2DMultisampleCoverageNV = cast(typeof(glTextureImage2DMultisampleCoverageNV))load("glTextureImage2DMultisampleCoverageNV\0".ptr);
	glTextureImage3DMultisampleCoverageNV = cast(typeof(glTextureImage3DMultisampleCoverageNV))load("glTextureImage3DMultisampleCoverageNV\0".ptr);
	return GL_NV_texture_multisample;
}


bool load_gl_GL_ARB_shader_objects(void* function(const(char)* name) load) {
	if(!GL_ARB_shader_objects) return GL_ARB_shader_objects;

	glDeleteObjectARB = cast(typeof(glDeleteObjectARB))load("glDeleteObjectARB\0".ptr);
	glGetHandleARB = cast(typeof(glGetHandleARB))load("glGetHandleARB\0".ptr);
	glDetachObjectARB = cast(typeof(glDetachObjectARB))load("glDetachObjectARB\0".ptr);
	glCreateShaderObjectARB = cast(typeof(glCreateShaderObjectARB))load("glCreateShaderObjectARB\0".ptr);
	glShaderSourceARB = cast(typeof(glShaderSourceARB))load("glShaderSourceARB\0".ptr);
	glCompileShaderARB = cast(typeof(glCompileShaderARB))load("glCompileShaderARB\0".ptr);
	glCreateProgramObjectARB = cast(typeof(glCreateProgramObjectARB))load("glCreateProgramObjectARB\0".ptr);
	glAttachObjectARB = cast(typeof(glAttachObjectARB))load("glAttachObjectARB\0".ptr);
	glLinkProgramARB = cast(typeof(glLinkProgramARB))load("glLinkProgramARB\0".ptr);
	glUseProgramObjectARB = cast(typeof(glUseProgramObjectARB))load("glUseProgramObjectARB\0".ptr);
	glValidateProgramARB = cast(typeof(glValidateProgramARB))load("glValidateProgramARB\0".ptr);
	glUniform1fARB = cast(typeof(glUniform1fARB))load("glUniform1fARB\0".ptr);
	glUniform2fARB = cast(typeof(glUniform2fARB))load("glUniform2fARB\0".ptr);
	glUniform3fARB = cast(typeof(glUniform3fARB))load("glUniform3fARB\0".ptr);
	glUniform4fARB = cast(typeof(glUniform4fARB))load("glUniform4fARB\0".ptr);
	glUniform1iARB = cast(typeof(glUniform1iARB))load("glUniform1iARB\0".ptr);
	glUniform2iARB = cast(typeof(glUniform2iARB))load("glUniform2iARB\0".ptr);
	glUniform3iARB = cast(typeof(glUniform3iARB))load("glUniform3iARB\0".ptr);
	glUniform4iARB = cast(typeof(glUniform4iARB))load("glUniform4iARB\0".ptr);
	glUniform1fvARB = cast(typeof(glUniform1fvARB))load("glUniform1fvARB\0".ptr);
	glUniform2fvARB = cast(typeof(glUniform2fvARB))load("glUniform2fvARB\0".ptr);
	glUniform3fvARB = cast(typeof(glUniform3fvARB))load("glUniform3fvARB\0".ptr);
	glUniform4fvARB = cast(typeof(glUniform4fvARB))load("glUniform4fvARB\0".ptr);
	glUniform1ivARB = cast(typeof(glUniform1ivARB))load("glUniform1ivARB\0".ptr);
	glUniform2ivARB = cast(typeof(glUniform2ivARB))load("glUniform2ivARB\0".ptr);
	glUniform3ivARB = cast(typeof(glUniform3ivARB))load("glUniform3ivARB\0".ptr);
	glUniform4ivARB = cast(typeof(glUniform4ivARB))load("glUniform4ivARB\0".ptr);
	glUniformMatrix2fvARB = cast(typeof(glUniformMatrix2fvARB))load("glUniformMatrix2fvARB\0".ptr);
	glUniformMatrix3fvARB = cast(typeof(glUniformMatrix3fvARB))load("glUniformMatrix3fvARB\0".ptr);
	glUniformMatrix4fvARB = cast(typeof(glUniformMatrix4fvARB))load("glUniformMatrix4fvARB\0".ptr);
	glGetObjectParameterfvARB = cast(typeof(glGetObjectParameterfvARB))load("glGetObjectParameterfvARB\0".ptr);
	glGetObjectParameterivARB = cast(typeof(glGetObjectParameterivARB))load("glGetObjectParameterivARB\0".ptr);
	glGetInfoLogARB = cast(typeof(glGetInfoLogARB))load("glGetInfoLogARB\0".ptr);
	glGetAttachedObjectsARB = cast(typeof(glGetAttachedObjectsARB))load("glGetAttachedObjectsARB\0".ptr);
	glGetUniformLocationARB = cast(typeof(glGetUniformLocationARB))load("glGetUniformLocationARB\0".ptr);
	glGetActiveUniformARB = cast(typeof(glGetActiveUniformARB))load("glGetActiveUniformARB\0".ptr);
	glGetUniformfvARB = cast(typeof(glGetUniformfvARB))load("glGetUniformfvARB\0".ptr);
	glGetUniformivARB = cast(typeof(glGetUniformivARB))load("glGetUniformivARB\0".ptr);
	glGetShaderSourceARB = cast(typeof(glGetShaderSourceARB))load("glGetShaderSourceARB\0".ptr);
	return GL_ARB_shader_objects;
}


bool load_gl_GL_ARB_framebuffer_object(void* function(const(char)* name) load) {
	if(!GL_ARB_framebuffer_object) return GL_ARB_framebuffer_object;

	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer\0".ptr);
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer\0".ptr);
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers\0".ptr);
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers\0".ptr);
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage\0".ptr);
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv\0".ptr);
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer\0".ptr);
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer\0".ptr);
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers\0".ptr);
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers\0".ptr);
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus\0".ptr);
	glFramebufferTexture1D = cast(typeof(glFramebufferTexture1D))load("glFramebufferTexture1D\0".ptr);
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D\0".ptr);
	glFramebufferTexture3D = cast(typeof(glFramebufferTexture3D))load("glFramebufferTexture3D\0".ptr);
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer\0".ptr);
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv\0".ptr);
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap\0".ptr);
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer\0".ptr);
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample\0".ptr);
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer\0".ptr);
	return GL_ARB_framebuffer_object;
}


bool load_gl_GL_ATI_envmap_bumpmap(void* function(const(char)* name) load) {
	if(!GL_ATI_envmap_bumpmap) return GL_ATI_envmap_bumpmap;

	glTexBumpParameterivATI = cast(typeof(glTexBumpParameterivATI))load("glTexBumpParameterivATI\0".ptr);
	glTexBumpParameterfvATI = cast(typeof(glTexBumpParameterfvATI))load("glTexBumpParameterfvATI\0".ptr);
	glGetTexBumpParameterivATI = cast(typeof(glGetTexBumpParameterivATI))load("glGetTexBumpParameterivATI\0".ptr);
	glGetTexBumpParameterfvATI = cast(typeof(glGetTexBumpParameterfvATI))load("glGetTexBumpParameterfvATI\0".ptr);
	return GL_ATI_envmap_bumpmap;
}


bool load_gl_GL_ATI_map_object_buffer(void* function(const(char)* name) load) {
	if(!GL_ATI_map_object_buffer) return GL_ATI_map_object_buffer;

	glMapObjectBufferATI = cast(typeof(glMapObjectBufferATI))load("glMapObjectBufferATI\0".ptr);
	glUnmapObjectBufferATI = cast(typeof(glUnmapObjectBufferATI))load("glUnmapObjectBufferATI\0".ptr);
	return GL_ATI_map_object_buffer;
}


bool load_gl_GL_ARB_robustness(void* function(const(char)* name) load) {
	if(!GL_ARB_robustness) return GL_ARB_robustness;

	glGetGraphicsResetStatusARB = cast(typeof(glGetGraphicsResetStatusARB))load("glGetGraphicsResetStatusARB\0".ptr);
	glGetnTexImageARB = cast(typeof(glGetnTexImageARB))load("glGetnTexImageARB\0".ptr);
	glReadnPixelsARB = cast(typeof(glReadnPixelsARB))load("glReadnPixelsARB\0".ptr);
	glGetnCompressedTexImageARB = cast(typeof(glGetnCompressedTexImageARB))load("glGetnCompressedTexImageARB\0".ptr);
	glGetnUniformfvARB = cast(typeof(glGetnUniformfvARB))load("glGetnUniformfvARB\0".ptr);
	glGetnUniformivARB = cast(typeof(glGetnUniformivARB))load("glGetnUniformivARB\0".ptr);
	glGetnUniformuivARB = cast(typeof(glGetnUniformuivARB))load("glGetnUniformuivARB\0".ptr);
	glGetnUniformdvARB = cast(typeof(glGetnUniformdvARB))load("glGetnUniformdvARB\0".ptr);
	glGetnMapdvARB = cast(typeof(glGetnMapdvARB))load("glGetnMapdvARB\0".ptr);
	glGetnMapfvARB = cast(typeof(glGetnMapfvARB))load("glGetnMapfvARB\0".ptr);
	glGetnMapivARB = cast(typeof(glGetnMapivARB))load("glGetnMapivARB\0".ptr);
	glGetnPixelMapfvARB = cast(typeof(glGetnPixelMapfvARB))load("glGetnPixelMapfvARB\0".ptr);
	glGetnPixelMapuivARB = cast(typeof(glGetnPixelMapuivARB))load("glGetnPixelMapuivARB\0".ptr);
	glGetnPixelMapusvARB = cast(typeof(glGetnPixelMapusvARB))load("glGetnPixelMapusvARB\0".ptr);
	glGetnPolygonStippleARB = cast(typeof(glGetnPolygonStippleARB))load("glGetnPolygonStippleARB\0".ptr);
	glGetnColorTableARB = cast(typeof(glGetnColorTableARB))load("glGetnColorTableARB\0".ptr);
	glGetnConvolutionFilterARB = cast(typeof(glGetnConvolutionFilterARB))load("glGetnConvolutionFilterARB\0".ptr);
	glGetnSeparableFilterARB = cast(typeof(glGetnSeparableFilterARB))load("glGetnSeparableFilterARB\0".ptr);
	glGetnHistogramARB = cast(typeof(glGetnHistogramARB))load("glGetnHistogramARB\0".ptr);
	glGetnMinmaxARB = cast(typeof(glGetnMinmaxARB))load("glGetnMinmaxARB\0".ptr);
	return GL_ARB_robustness;
}


bool load_gl_GL_NV_pixel_data_range(void* function(const(char)* name) load) {
	if(!GL_NV_pixel_data_range) return GL_NV_pixel_data_range;

	glPixelDataRangeNV = cast(typeof(glPixelDataRangeNV))load("glPixelDataRangeNV\0".ptr);
	glFlushPixelDataRangeNV = cast(typeof(glFlushPixelDataRangeNV))load("glFlushPixelDataRangeNV\0".ptr);
	return GL_NV_pixel_data_range;
}


bool load_gl_GL_EXT_framebuffer_blit(void* function(const(char)* name) load) {
	if(!GL_EXT_framebuffer_blit) return GL_EXT_framebuffer_blit;

	glBlitFramebufferEXT = cast(typeof(glBlitFramebufferEXT))load("glBlitFramebufferEXT\0".ptr);
	return GL_EXT_framebuffer_blit;
}


bool load_gl_GL_ARB_gpu_shader_fp64(void* function(const(char)* name) load) {
	if(!GL_ARB_gpu_shader_fp64) return GL_ARB_gpu_shader_fp64;

	glUniform1d = cast(typeof(glUniform1d))load("glUniform1d\0".ptr);
	glUniform2d = cast(typeof(glUniform2d))load("glUniform2d\0".ptr);
	glUniform3d = cast(typeof(glUniform3d))load("glUniform3d\0".ptr);
	glUniform4d = cast(typeof(glUniform4d))load("glUniform4d\0".ptr);
	glUniform1dv = cast(typeof(glUniform1dv))load("glUniform1dv\0".ptr);
	glUniform2dv = cast(typeof(glUniform2dv))load("glUniform2dv\0".ptr);
	glUniform3dv = cast(typeof(glUniform3dv))load("glUniform3dv\0".ptr);
	glUniform4dv = cast(typeof(glUniform4dv))load("glUniform4dv\0".ptr);
	glUniformMatrix2dv = cast(typeof(glUniformMatrix2dv))load("glUniformMatrix2dv\0".ptr);
	glUniformMatrix3dv = cast(typeof(glUniformMatrix3dv))load("glUniformMatrix3dv\0".ptr);
	glUniformMatrix4dv = cast(typeof(glUniformMatrix4dv))load("glUniformMatrix4dv\0".ptr);
	glUniformMatrix2x3dv = cast(typeof(glUniformMatrix2x3dv))load("glUniformMatrix2x3dv\0".ptr);
	glUniformMatrix2x4dv = cast(typeof(glUniformMatrix2x4dv))load("glUniformMatrix2x4dv\0".ptr);
	glUniformMatrix3x2dv = cast(typeof(glUniformMatrix3x2dv))load("glUniformMatrix3x2dv\0".ptr);
	glUniformMatrix3x4dv = cast(typeof(glUniformMatrix3x4dv))load("glUniformMatrix3x4dv\0".ptr);
	glUniformMatrix4x2dv = cast(typeof(glUniformMatrix4x2dv))load("glUniformMatrix4x2dv\0".ptr);
	glUniformMatrix4x3dv = cast(typeof(glUniformMatrix4x3dv))load("glUniformMatrix4x3dv\0".ptr);
	glGetUniformdv = cast(typeof(glGetUniformdv))load("glGetUniformdv\0".ptr);
	return GL_ARB_gpu_shader_fp64;
}


bool load_gl_GL_EXT_vertex_weighting(void* function(const(char)* name) load) {
	if(!GL_EXT_vertex_weighting) return GL_EXT_vertex_weighting;

	glVertexWeightfEXT = cast(typeof(glVertexWeightfEXT))load("glVertexWeightfEXT\0".ptr);
	glVertexWeightfvEXT = cast(typeof(glVertexWeightfvEXT))load("glVertexWeightfvEXT\0".ptr);
	glVertexWeightPointerEXT = cast(typeof(glVertexWeightPointerEXT))load("glVertexWeightPointerEXT\0".ptr);
	return GL_EXT_vertex_weighting;
}


bool load_gl_GL_GREMEDY_string_marker(void* function(const(char)* name) load) {
	if(!GL_GREMEDY_string_marker) return GL_GREMEDY_string_marker;

	glStringMarkerGREMEDY = cast(typeof(glStringMarkerGREMEDY))load("glStringMarkerGREMEDY\0".ptr);
	return GL_GREMEDY_string_marker;
}


bool load_gl_GL_EXT_subtexture(void* function(const(char)* name) load) {
	if(!GL_EXT_subtexture) return GL_EXT_subtexture;

	glTexSubImage1DEXT = cast(typeof(glTexSubImage1DEXT))load("glTexSubImage1DEXT\0".ptr);
	glTexSubImage2DEXT = cast(typeof(glTexSubImage2DEXT))load("glTexSubImage2DEXT\0".ptr);
	return GL_EXT_subtexture;
}


bool load_gl_GL_NV_evaluators(void* function(const(char)* name) load) {
	if(!GL_NV_evaluators) return GL_NV_evaluators;

	glMapControlPointsNV = cast(typeof(glMapControlPointsNV))load("glMapControlPointsNV\0".ptr);
	glMapParameterivNV = cast(typeof(glMapParameterivNV))load("glMapParameterivNV\0".ptr);
	glMapParameterfvNV = cast(typeof(glMapParameterfvNV))load("glMapParameterfvNV\0".ptr);
	glGetMapControlPointsNV = cast(typeof(glGetMapControlPointsNV))load("glGetMapControlPointsNV\0".ptr);
	glGetMapParameterivNV = cast(typeof(glGetMapParameterivNV))load("glGetMapParameterivNV\0".ptr);
	glGetMapParameterfvNV = cast(typeof(glGetMapParameterfvNV))load("glGetMapParameterfvNV\0".ptr);
	glGetMapAttribParameterivNV = cast(typeof(glGetMapAttribParameterivNV))load("glGetMapAttribParameterivNV\0".ptr);
	glGetMapAttribParameterfvNV = cast(typeof(glGetMapAttribParameterfvNV))load("glGetMapAttribParameterfvNV\0".ptr);
	glEvalMapsNV = cast(typeof(glEvalMapsNV))load("glEvalMapsNV\0".ptr);
	return GL_NV_evaluators;
}


bool load_gl_GL_SGIS_texture_filter4(void* function(const(char)* name) load) {
	if(!GL_SGIS_texture_filter4) return GL_SGIS_texture_filter4;

	glGetTexFilterFuncSGIS = cast(typeof(glGetTexFilterFuncSGIS))load("glGetTexFilterFuncSGIS\0".ptr);
	glTexFilterFuncSGIS = cast(typeof(glTexFilterFuncSGIS))load("glTexFilterFuncSGIS\0".ptr);
	return GL_SGIS_texture_filter4;
}


bool load_gl_GL_AMD_performance_monitor(void* function(const(char)* name) load) {
	if(!GL_AMD_performance_monitor) return GL_AMD_performance_monitor;

	glGetPerfMonitorGroupsAMD = cast(typeof(glGetPerfMonitorGroupsAMD))load("glGetPerfMonitorGroupsAMD\0".ptr);
	glGetPerfMonitorCountersAMD = cast(typeof(glGetPerfMonitorCountersAMD))load("glGetPerfMonitorCountersAMD\0".ptr);
	glGetPerfMonitorGroupStringAMD = cast(typeof(glGetPerfMonitorGroupStringAMD))load("glGetPerfMonitorGroupStringAMD\0".ptr);
	glGetPerfMonitorCounterStringAMD = cast(typeof(glGetPerfMonitorCounterStringAMD))load("glGetPerfMonitorCounterStringAMD\0".ptr);
	glGetPerfMonitorCounterInfoAMD = cast(typeof(glGetPerfMonitorCounterInfoAMD))load("glGetPerfMonitorCounterInfoAMD\0".ptr);
	glGenPerfMonitorsAMD = cast(typeof(glGenPerfMonitorsAMD))load("glGenPerfMonitorsAMD\0".ptr);
	glDeletePerfMonitorsAMD = cast(typeof(glDeletePerfMonitorsAMD))load("glDeletePerfMonitorsAMD\0".ptr);
	glSelectPerfMonitorCountersAMD = cast(typeof(glSelectPerfMonitorCountersAMD))load("glSelectPerfMonitorCountersAMD\0".ptr);
	glBeginPerfMonitorAMD = cast(typeof(glBeginPerfMonitorAMD))load("glBeginPerfMonitorAMD\0".ptr);
	glEndPerfMonitorAMD = cast(typeof(glEndPerfMonitorAMD))load("glEndPerfMonitorAMD\0".ptr);
	glGetPerfMonitorCounterDataAMD = cast(typeof(glGetPerfMonitorCounterDataAMD))load("glGetPerfMonitorCounterDataAMD\0".ptr);
	return GL_AMD_performance_monitor;
}


bool load_gl_GL_EXT_stencil_clear_tag(void* function(const(char)* name) load) {
	if(!GL_EXT_stencil_clear_tag) return GL_EXT_stencil_clear_tag;

	glStencilClearTagEXT = cast(typeof(glStencilClearTagEXT))load("glStencilClearTagEXT\0".ptr);
	return GL_EXT_stencil_clear_tag;
}


bool load_gl_GL_NV_present_video(void* function(const(char)* name) load) {
	if(!GL_NV_present_video) return GL_NV_present_video;

	glPresentFrameKeyedNV = cast(typeof(glPresentFrameKeyedNV))load("glPresentFrameKeyedNV\0".ptr);
	glPresentFrameDualFillNV = cast(typeof(glPresentFrameDualFillNV))load("glPresentFrameDualFillNV\0".ptr);
	glGetVideoivNV = cast(typeof(glGetVideoivNV))load("glGetVideoivNV\0".ptr);
	glGetVideouivNV = cast(typeof(glGetVideouivNV))load("glGetVideouivNV\0".ptr);
	glGetVideoi64vNV = cast(typeof(glGetVideoi64vNV))load("glGetVideoi64vNV\0".ptr);
	glGetVideoui64vNV = cast(typeof(glGetVideoui64vNV))load("glGetVideoui64vNV\0".ptr);
	return GL_NV_present_video;
}


bool load_gl_GL_EXT_gpu_program_parameters(void* function(const(char)* name) load) {
	if(!GL_EXT_gpu_program_parameters) return GL_EXT_gpu_program_parameters;

	glProgramEnvParameters4fvEXT = cast(typeof(glProgramEnvParameters4fvEXT))load("glProgramEnvParameters4fvEXT\0".ptr);
	glProgramLocalParameters4fvEXT = cast(typeof(glProgramLocalParameters4fvEXT))load("glProgramLocalParameters4fvEXT\0".ptr);
	return GL_EXT_gpu_program_parameters;
}


bool load_gl_GL_SGIX_list_priority(void* function(const(char)* name) load) {
	if(!GL_SGIX_list_priority) return GL_SGIX_list_priority;

	glGetListParameterfvSGIX = cast(typeof(glGetListParameterfvSGIX))load("glGetListParameterfvSGIX\0".ptr);
	glGetListParameterivSGIX = cast(typeof(glGetListParameterivSGIX))load("glGetListParameterivSGIX\0".ptr);
	glListParameterfSGIX = cast(typeof(glListParameterfSGIX))load("glListParameterfSGIX\0".ptr);
	glListParameterfvSGIX = cast(typeof(glListParameterfvSGIX))load("glListParameterfvSGIX\0".ptr);
	glListParameteriSGIX = cast(typeof(glListParameteriSGIX))load("glListParameteriSGIX\0".ptr);
	glListParameterivSGIX = cast(typeof(glListParameterivSGIX))load("glListParameterivSGIX\0".ptr);
	return GL_SGIX_list_priority;
}


bool load_gl_GL_ARB_draw_elements_base_vertex(void* function(const(char)* name) load) {
	if(!GL_ARB_draw_elements_base_vertex) return GL_ARB_draw_elements_base_vertex;

	glDrawElementsBaseVertex = cast(typeof(glDrawElementsBaseVertex))load("glDrawElementsBaseVertex\0".ptr);
	glDrawRangeElementsBaseVertex = cast(typeof(glDrawRangeElementsBaseVertex))load("glDrawRangeElementsBaseVertex\0".ptr);
	glDrawElementsInstancedBaseVertex = cast(typeof(glDrawElementsInstancedBaseVertex))load("glDrawElementsInstancedBaseVertex\0".ptr);
	glMultiDrawElementsBaseVertex = cast(typeof(glMultiDrawElementsBaseVertex))load("glMultiDrawElementsBaseVertex\0".ptr);
	return GL_ARB_draw_elements_base_vertex;
}


bool load_gl_GL_NV_transform_feedback(void* function(const(char)* name) load) {
	if(!GL_NV_transform_feedback) return GL_NV_transform_feedback;

	glBeginTransformFeedbackNV = cast(typeof(glBeginTransformFeedbackNV))load("glBeginTransformFeedbackNV\0".ptr);
	glEndTransformFeedbackNV = cast(typeof(glEndTransformFeedbackNV))load("glEndTransformFeedbackNV\0".ptr);
	glTransformFeedbackAttribsNV = cast(typeof(glTransformFeedbackAttribsNV))load("glTransformFeedbackAttribsNV\0".ptr);
	glBindBufferRangeNV = cast(typeof(glBindBufferRangeNV))load("glBindBufferRangeNV\0".ptr);
	glBindBufferOffsetNV = cast(typeof(glBindBufferOffsetNV))load("glBindBufferOffsetNV\0".ptr);
	glBindBufferBaseNV = cast(typeof(glBindBufferBaseNV))load("glBindBufferBaseNV\0".ptr);
	glTransformFeedbackVaryingsNV = cast(typeof(glTransformFeedbackVaryingsNV))load("glTransformFeedbackVaryingsNV\0".ptr);
	glActiveVaryingNV = cast(typeof(glActiveVaryingNV))load("glActiveVaryingNV\0".ptr);
	glGetVaryingLocationNV = cast(typeof(glGetVaryingLocationNV))load("glGetVaryingLocationNV\0".ptr);
	glGetActiveVaryingNV = cast(typeof(glGetActiveVaryingNV))load("glGetActiveVaryingNV\0".ptr);
	glGetTransformFeedbackVaryingNV = cast(typeof(glGetTransformFeedbackVaryingNV))load("glGetTransformFeedbackVaryingNV\0".ptr);
	glTransformFeedbackStreamAttribsNV = cast(typeof(glTransformFeedbackStreamAttribsNV))load("glTransformFeedbackStreamAttribsNV\0".ptr);
	return GL_NV_transform_feedback;
}


bool load_gl_GL_NV_fragment_program(void* function(const(char)* name) load) {
	if(!GL_NV_fragment_program) return GL_NV_fragment_program;

	glProgramNamedParameter4fNV = cast(typeof(glProgramNamedParameter4fNV))load("glProgramNamedParameter4fNV\0".ptr);
	glProgramNamedParameter4fvNV = cast(typeof(glProgramNamedParameter4fvNV))load("glProgramNamedParameter4fvNV\0".ptr);
	glProgramNamedParameter4dNV = cast(typeof(glProgramNamedParameter4dNV))load("glProgramNamedParameter4dNV\0".ptr);
	glProgramNamedParameter4dvNV = cast(typeof(glProgramNamedParameter4dvNV))load("glProgramNamedParameter4dvNV\0".ptr);
	glGetProgramNamedParameterfvNV = cast(typeof(glGetProgramNamedParameterfvNV))load("glGetProgramNamedParameterfvNV\0".ptr);
	glGetProgramNamedParameterdvNV = cast(typeof(glGetProgramNamedParameterdvNV))load("glGetProgramNamedParameterdvNV\0".ptr);
	return GL_NV_fragment_program;
}


bool load_gl_GL_AMD_stencil_operation_extended(void* function(const(char)* name) load) {
	if(!GL_AMD_stencil_operation_extended) return GL_AMD_stencil_operation_extended;

	glStencilOpValueAMD = cast(typeof(glStencilOpValueAMD))load("glStencilOpValueAMD\0".ptr);
	return GL_AMD_stencil_operation_extended;
}


bool load_gl_GL_ARB_instanced_arrays(void* function(const(char)* name) load) {
	if(!GL_ARB_instanced_arrays) return GL_ARB_instanced_arrays;

	glVertexAttribDivisorARB = cast(typeof(glVertexAttribDivisorARB))load("glVertexAttribDivisorARB\0".ptr);
	return GL_ARB_instanced_arrays;
}


bool load_gl_GL_EXT_polygon_offset(void* function(const(char)* name) load) {
	if(!GL_EXT_polygon_offset) return GL_EXT_polygon_offset;

	glPolygonOffsetEXT = cast(typeof(glPolygonOffsetEXT))load("glPolygonOffsetEXT\0".ptr);
	return GL_EXT_polygon_offset;
}


bool load_gl_GL_AMD_sparse_texture(void* function(const(char)* name) load) {
	if(!GL_AMD_sparse_texture) return GL_AMD_sparse_texture;

	glTexStorageSparseAMD = cast(typeof(glTexStorageSparseAMD))load("glTexStorageSparseAMD\0".ptr);
	glTextureStorageSparseAMD = cast(typeof(glTextureStorageSparseAMD))load("glTextureStorageSparseAMD\0".ptr);
	return GL_AMD_sparse_texture;
}


bool load_gl_GL_NV_fence(void* function(const(char)* name) load) {
	if(!GL_NV_fence) return GL_NV_fence;

	glDeleteFencesNV = cast(typeof(glDeleteFencesNV))load("glDeleteFencesNV\0".ptr);
	glGenFencesNV = cast(typeof(glGenFencesNV))load("glGenFencesNV\0".ptr);
	glIsFenceNV = cast(typeof(glIsFenceNV))load("glIsFenceNV\0".ptr);
	glTestFenceNV = cast(typeof(glTestFenceNV))load("glTestFenceNV\0".ptr);
	glGetFenceivNV = cast(typeof(glGetFenceivNV))load("glGetFenceivNV\0".ptr);
	glFinishFenceNV = cast(typeof(glFinishFenceNV))load("glFinishFenceNV\0".ptr);
	glSetFenceNV = cast(typeof(glSetFenceNV))load("glSetFenceNV\0".ptr);
	return GL_NV_fence;
}


bool load_gl_GL_ARB_texture_buffer_range(void* function(const(char)* name) load) {
	if(!GL_ARB_texture_buffer_range) return GL_ARB_texture_buffer_range;

	glTexBufferRange = cast(typeof(glTexBufferRange))load("glTexBufferRange\0".ptr);
	return GL_ARB_texture_buffer_range;
}


bool load_gl_GL_SUN_mesh_array(void* function(const(char)* name) load) {
	if(!GL_SUN_mesh_array) return GL_SUN_mesh_array;

	glDrawMeshArraysSUN = cast(typeof(glDrawMeshArraysSUN))load("glDrawMeshArraysSUN\0".ptr);
	return GL_SUN_mesh_array;
}


bool load_gl_GL_ARB_vertex_attrib_binding(void* function(const(char)* name) load) {
	if(!GL_ARB_vertex_attrib_binding) return GL_ARB_vertex_attrib_binding;

	glBindVertexBuffer = cast(typeof(glBindVertexBuffer))load("glBindVertexBuffer\0".ptr);
	glVertexAttribFormat = cast(typeof(glVertexAttribFormat))load("glVertexAttribFormat\0".ptr);
	glVertexAttribIFormat = cast(typeof(glVertexAttribIFormat))load("glVertexAttribIFormat\0".ptr);
	glVertexAttribLFormat = cast(typeof(glVertexAttribLFormat))load("glVertexAttribLFormat\0".ptr);
	glVertexAttribBinding = cast(typeof(glVertexAttribBinding))load("glVertexAttribBinding\0".ptr);
	glVertexBindingDivisor = cast(typeof(glVertexBindingDivisor))load("glVertexBindingDivisor\0".ptr);
	return GL_ARB_vertex_attrib_binding;
}


bool load_gl_GL_ARB_framebuffer_no_attachments(void* function(const(char)* name) load) {
	if(!GL_ARB_framebuffer_no_attachments) return GL_ARB_framebuffer_no_attachments;

	glFramebufferParameteri = cast(typeof(glFramebufferParameteri))load("glFramebufferParameteri\0".ptr);
	glGetFramebufferParameteriv = cast(typeof(glGetFramebufferParameteriv))load("glGetFramebufferParameteriv\0".ptr);
	return GL_ARB_framebuffer_no_attachments;
}


bool load_gl_GL_ARB_cl_event(void* function(const(char)* name) load) {
	if(!GL_ARB_cl_event) return GL_ARB_cl_event;

	glCreateSyncFromCLeventARB = cast(typeof(glCreateSyncFromCLeventARB))load("glCreateSyncFromCLeventARB\0".ptr);
	return GL_ARB_cl_event;
}


bool load_gl_GL_OES_single_precision(void* function(const(char)* name) load) {
	if(!GL_OES_single_precision) return GL_OES_single_precision;

	glClearDepthfOES = cast(typeof(glClearDepthfOES))load("glClearDepthfOES\0".ptr);
	glClipPlanefOES = cast(typeof(glClipPlanefOES))load("glClipPlanefOES\0".ptr);
	glDepthRangefOES = cast(typeof(glDepthRangefOES))load("glDepthRangefOES\0".ptr);
	glFrustumfOES = cast(typeof(glFrustumfOES))load("glFrustumfOES\0".ptr);
	glGetClipPlanefOES = cast(typeof(glGetClipPlanefOES))load("glGetClipPlanefOES\0".ptr);
	glOrthofOES = cast(typeof(glOrthofOES))load("glOrthofOES\0".ptr);
	return GL_OES_single_precision;
}


bool load_gl_GL_NV_primitive_restart(void* function(const(char)* name) load) {
	if(!GL_NV_primitive_restart) return GL_NV_primitive_restart;

	glPrimitiveRestartNV = cast(typeof(glPrimitiveRestartNV))load("glPrimitiveRestartNV\0".ptr);
	glPrimitiveRestartIndexNV = cast(typeof(glPrimitiveRestartIndexNV))load("glPrimitiveRestartIndexNV\0".ptr);
	return GL_NV_primitive_restart;
}


bool load_gl_GL_SUN_global_alpha(void* function(const(char)* name) load) {
	if(!GL_SUN_global_alpha) return GL_SUN_global_alpha;

	glGlobalAlphaFactorbSUN = cast(typeof(glGlobalAlphaFactorbSUN))load("glGlobalAlphaFactorbSUN\0".ptr);
	glGlobalAlphaFactorsSUN = cast(typeof(glGlobalAlphaFactorsSUN))load("glGlobalAlphaFactorsSUN\0".ptr);
	glGlobalAlphaFactoriSUN = cast(typeof(glGlobalAlphaFactoriSUN))load("glGlobalAlphaFactoriSUN\0".ptr);
	glGlobalAlphaFactorfSUN = cast(typeof(glGlobalAlphaFactorfSUN))load("glGlobalAlphaFactorfSUN\0".ptr);
	glGlobalAlphaFactordSUN = cast(typeof(glGlobalAlphaFactordSUN))load("glGlobalAlphaFactordSUN\0".ptr);
	glGlobalAlphaFactorubSUN = cast(typeof(glGlobalAlphaFactorubSUN))load("glGlobalAlphaFactorubSUN\0".ptr);
	glGlobalAlphaFactorusSUN = cast(typeof(glGlobalAlphaFactorusSUN))load("glGlobalAlphaFactorusSUN\0".ptr);
	glGlobalAlphaFactoruiSUN = cast(typeof(glGlobalAlphaFactoruiSUN))load("glGlobalAlphaFactoruiSUN\0".ptr);
	return GL_SUN_global_alpha;
}


bool load_gl_GL_EXT_texture_object(void* function(const(char)* name) load) {
	if(!GL_EXT_texture_object) return GL_EXT_texture_object;

	glAreTexturesResidentEXT = cast(typeof(glAreTexturesResidentEXT))load("glAreTexturesResidentEXT\0".ptr);
	glBindTextureEXT = cast(typeof(glBindTextureEXT))load("glBindTextureEXT\0".ptr);
	glDeleteTexturesEXT = cast(typeof(glDeleteTexturesEXT))load("glDeleteTexturesEXT\0".ptr);
	glGenTexturesEXT = cast(typeof(glGenTexturesEXT))load("glGenTexturesEXT\0".ptr);
	glIsTextureEXT = cast(typeof(glIsTextureEXT))load("glIsTextureEXT\0".ptr);
	glPrioritizeTexturesEXT = cast(typeof(glPrioritizeTexturesEXT))load("glPrioritizeTexturesEXT\0".ptr);
	return GL_EXT_texture_object;
}


bool load_gl_GL_AMD_name_gen_delete(void* function(const(char)* name) load) {
	if(!GL_AMD_name_gen_delete) return GL_AMD_name_gen_delete;

	glGenNamesAMD = cast(typeof(glGenNamesAMD))load("glGenNamesAMD\0".ptr);
	glDeleteNamesAMD = cast(typeof(glDeleteNamesAMD))load("glDeleteNamesAMD\0".ptr);
	glIsNameAMD = cast(typeof(glIsNameAMD))load("glIsNameAMD\0".ptr);
	return GL_AMD_name_gen_delete;
}


bool load_gl_GL_ARB_buffer_storage(void* function(const(char)* name) load) {
	if(!GL_ARB_buffer_storage) return GL_ARB_buffer_storage;

	glBufferStorage = cast(typeof(glBufferStorage))load("glBufferStorage\0".ptr);
	return GL_ARB_buffer_storage;
}


bool load_gl_GL_APPLE_vertex_program_evaluators(void* function(const(char)* name) load) {
	if(!GL_APPLE_vertex_program_evaluators) return GL_APPLE_vertex_program_evaluators;

	glEnableVertexAttribAPPLE = cast(typeof(glEnableVertexAttribAPPLE))load("glEnableVertexAttribAPPLE\0".ptr);
	glDisableVertexAttribAPPLE = cast(typeof(glDisableVertexAttribAPPLE))load("glDisableVertexAttribAPPLE\0".ptr);
	glIsVertexAttribEnabledAPPLE = cast(typeof(glIsVertexAttribEnabledAPPLE))load("glIsVertexAttribEnabledAPPLE\0".ptr);
	glMapVertexAttrib1dAPPLE = cast(typeof(glMapVertexAttrib1dAPPLE))load("glMapVertexAttrib1dAPPLE\0".ptr);
	glMapVertexAttrib1fAPPLE = cast(typeof(glMapVertexAttrib1fAPPLE))load("glMapVertexAttrib1fAPPLE\0".ptr);
	glMapVertexAttrib2dAPPLE = cast(typeof(glMapVertexAttrib2dAPPLE))load("glMapVertexAttrib2dAPPLE\0".ptr);
	glMapVertexAttrib2fAPPLE = cast(typeof(glMapVertexAttrib2fAPPLE))load("glMapVertexAttrib2fAPPLE\0".ptr);
	return GL_APPLE_vertex_program_evaluators;
}


bool load_gl_GL_ARB_multi_bind(void* function(const(char)* name) load) {
	if(!GL_ARB_multi_bind) return GL_ARB_multi_bind;

	glBindBuffersBase = cast(typeof(glBindBuffersBase))load("glBindBuffersBase\0".ptr);
	glBindBuffersRange = cast(typeof(glBindBuffersRange))load("glBindBuffersRange\0".ptr);
	glBindTextures = cast(typeof(glBindTextures))load("glBindTextures\0".ptr);
	glBindSamplers = cast(typeof(glBindSamplers))load("glBindSamplers\0".ptr);
	glBindImageTextures = cast(typeof(glBindImageTextures))load("glBindImageTextures\0".ptr);
	glBindVertexBuffers = cast(typeof(glBindVertexBuffers))load("glBindVertexBuffers\0".ptr);
	return GL_ARB_multi_bind;
}


bool load_gl_GL_NV_vertex_buffer_unified_memory(void* function(const(char)* name) load) {
	if(!GL_NV_vertex_buffer_unified_memory) return GL_NV_vertex_buffer_unified_memory;

	glBufferAddressRangeNV = cast(typeof(glBufferAddressRangeNV))load("glBufferAddressRangeNV\0".ptr);
	glVertexFormatNV = cast(typeof(glVertexFormatNV))load("glVertexFormatNV\0".ptr);
	glNormalFormatNV = cast(typeof(glNormalFormatNV))load("glNormalFormatNV\0".ptr);
	glColorFormatNV = cast(typeof(glColorFormatNV))load("glColorFormatNV\0".ptr);
	glIndexFormatNV = cast(typeof(glIndexFormatNV))load("glIndexFormatNV\0".ptr);
	glTexCoordFormatNV = cast(typeof(glTexCoordFormatNV))load("glTexCoordFormatNV\0".ptr);
	glEdgeFlagFormatNV = cast(typeof(glEdgeFlagFormatNV))load("glEdgeFlagFormatNV\0".ptr);
	glSecondaryColorFormatNV = cast(typeof(glSecondaryColorFormatNV))load("glSecondaryColorFormatNV\0".ptr);
	glFogCoordFormatNV = cast(typeof(glFogCoordFormatNV))load("glFogCoordFormatNV\0".ptr);
	glVertexAttribFormatNV = cast(typeof(glVertexAttribFormatNV))load("glVertexAttribFormatNV\0".ptr);
	glVertexAttribIFormatNV = cast(typeof(glVertexAttribIFormatNV))load("glVertexAttribIFormatNV\0".ptr);
	glGetIntegerui64i_vNV = cast(typeof(glGetIntegerui64i_vNV))load("glGetIntegerui64i_vNV\0".ptr);
	return GL_NV_vertex_buffer_unified_memory;
}


bool load_gl_GL_NV_blend_equation_advanced(void* function(const(char)* name) load) {
	if(!GL_NV_blend_equation_advanced) return GL_NV_blend_equation_advanced;

	glBlendParameteriNV = cast(typeof(glBlendParameteriNV))load("glBlendParameteriNV\0".ptr);
	glBlendBarrierNV = cast(typeof(glBlendBarrierNV))load("glBlendBarrierNV\0".ptr);
	return GL_NV_blend_equation_advanced;
}


bool load_gl_GL_SGIS_sharpen_texture(void* function(const(char)* name) load) {
	if(!GL_SGIS_sharpen_texture) return GL_SGIS_sharpen_texture;

	glSharpenTexFuncSGIS = cast(typeof(glSharpenTexFuncSGIS))load("glSharpenTexFuncSGIS\0".ptr);
	glGetSharpenTexFuncSGIS = cast(typeof(glGetSharpenTexFuncSGIS))load("glGetSharpenTexFuncSGIS\0".ptr);
	return GL_SGIS_sharpen_texture;
}


bool load_gl_GL_ARB_vertex_program(void* function(const(char)* name) load) {
	if(!GL_ARB_vertex_program) return GL_ARB_vertex_program;

	glVertexAttrib1dARB = cast(typeof(glVertexAttrib1dARB))load("glVertexAttrib1dARB\0".ptr);
	glVertexAttrib1dvARB = cast(typeof(glVertexAttrib1dvARB))load("glVertexAttrib1dvARB\0".ptr);
	glVertexAttrib1fARB = cast(typeof(glVertexAttrib1fARB))load("glVertexAttrib1fARB\0".ptr);
	glVertexAttrib1fvARB = cast(typeof(glVertexAttrib1fvARB))load("glVertexAttrib1fvARB\0".ptr);
	glVertexAttrib1sARB = cast(typeof(glVertexAttrib1sARB))load("glVertexAttrib1sARB\0".ptr);
	glVertexAttrib1svARB = cast(typeof(glVertexAttrib1svARB))load("glVertexAttrib1svARB\0".ptr);
	glVertexAttrib2dARB = cast(typeof(glVertexAttrib2dARB))load("glVertexAttrib2dARB\0".ptr);
	glVertexAttrib2dvARB = cast(typeof(glVertexAttrib2dvARB))load("glVertexAttrib2dvARB\0".ptr);
	glVertexAttrib2fARB = cast(typeof(glVertexAttrib2fARB))load("glVertexAttrib2fARB\0".ptr);
	glVertexAttrib2fvARB = cast(typeof(glVertexAttrib2fvARB))load("glVertexAttrib2fvARB\0".ptr);
	glVertexAttrib2sARB = cast(typeof(glVertexAttrib2sARB))load("glVertexAttrib2sARB\0".ptr);
	glVertexAttrib2svARB = cast(typeof(glVertexAttrib2svARB))load("glVertexAttrib2svARB\0".ptr);
	glVertexAttrib3dARB = cast(typeof(glVertexAttrib3dARB))load("glVertexAttrib3dARB\0".ptr);
	glVertexAttrib3dvARB = cast(typeof(glVertexAttrib3dvARB))load("glVertexAttrib3dvARB\0".ptr);
	glVertexAttrib3fARB = cast(typeof(glVertexAttrib3fARB))load("glVertexAttrib3fARB\0".ptr);
	glVertexAttrib3fvARB = cast(typeof(glVertexAttrib3fvARB))load("glVertexAttrib3fvARB\0".ptr);
	glVertexAttrib3sARB = cast(typeof(glVertexAttrib3sARB))load("glVertexAttrib3sARB\0".ptr);
	glVertexAttrib3svARB = cast(typeof(glVertexAttrib3svARB))load("glVertexAttrib3svARB\0".ptr);
	glVertexAttrib4NbvARB = cast(typeof(glVertexAttrib4NbvARB))load("glVertexAttrib4NbvARB\0".ptr);
	glVertexAttrib4NivARB = cast(typeof(glVertexAttrib4NivARB))load("glVertexAttrib4NivARB\0".ptr);
	glVertexAttrib4NsvARB = cast(typeof(glVertexAttrib4NsvARB))load("glVertexAttrib4NsvARB\0".ptr);
	glVertexAttrib4NubARB = cast(typeof(glVertexAttrib4NubARB))load("glVertexAttrib4NubARB\0".ptr);
	glVertexAttrib4NubvARB = cast(typeof(glVertexAttrib4NubvARB))load("glVertexAttrib4NubvARB\0".ptr);
	glVertexAttrib4NuivARB = cast(typeof(glVertexAttrib4NuivARB))load("glVertexAttrib4NuivARB\0".ptr);
	glVertexAttrib4NusvARB = cast(typeof(glVertexAttrib4NusvARB))load("glVertexAttrib4NusvARB\0".ptr);
	glVertexAttrib4bvARB = cast(typeof(glVertexAttrib4bvARB))load("glVertexAttrib4bvARB\0".ptr);
	glVertexAttrib4dARB = cast(typeof(glVertexAttrib4dARB))load("glVertexAttrib4dARB\0".ptr);
	glVertexAttrib4dvARB = cast(typeof(glVertexAttrib4dvARB))load("glVertexAttrib4dvARB\0".ptr);
	glVertexAttrib4fARB = cast(typeof(glVertexAttrib4fARB))load("glVertexAttrib4fARB\0".ptr);
	glVertexAttrib4fvARB = cast(typeof(glVertexAttrib4fvARB))load("glVertexAttrib4fvARB\0".ptr);
	glVertexAttrib4ivARB = cast(typeof(glVertexAttrib4ivARB))load("glVertexAttrib4ivARB\0".ptr);
	glVertexAttrib4sARB = cast(typeof(glVertexAttrib4sARB))load("glVertexAttrib4sARB\0".ptr);
	glVertexAttrib4svARB = cast(typeof(glVertexAttrib4svARB))load("glVertexAttrib4svARB\0".ptr);
	glVertexAttrib4ubvARB = cast(typeof(glVertexAttrib4ubvARB))load("glVertexAttrib4ubvARB\0".ptr);
	glVertexAttrib4uivARB = cast(typeof(glVertexAttrib4uivARB))load("glVertexAttrib4uivARB\0".ptr);
	glVertexAttrib4usvARB = cast(typeof(glVertexAttrib4usvARB))load("glVertexAttrib4usvARB\0".ptr);
	glVertexAttribPointerARB = cast(typeof(glVertexAttribPointerARB))load("glVertexAttribPointerARB\0".ptr);
	glEnableVertexAttribArrayARB = cast(typeof(glEnableVertexAttribArrayARB))load("glEnableVertexAttribArrayARB\0".ptr);
	glDisableVertexAttribArrayARB = cast(typeof(glDisableVertexAttribArrayARB))load("glDisableVertexAttribArrayARB\0".ptr);
	glProgramStringARB = cast(typeof(glProgramStringARB))load("glProgramStringARB\0".ptr);
	glBindProgramARB = cast(typeof(glBindProgramARB))load("glBindProgramARB\0".ptr);
	glDeleteProgramsARB = cast(typeof(glDeleteProgramsARB))load("glDeleteProgramsARB\0".ptr);
	glGenProgramsARB = cast(typeof(glGenProgramsARB))load("glGenProgramsARB\0".ptr);
	glProgramEnvParameter4dARB = cast(typeof(glProgramEnvParameter4dARB))load("glProgramEnvParameter4dARB\0".ptr);
	glProgramEnvParameter4dvARB = cast(typeof(glProgramEnvParameter4dvARB))load("glProgramEnvParameter4dvARB\0".ptr);
	glProgramEnvParameter4fARB = cast(typeof(glProgramEnvParameter4fARB))load("glProgramEnvParameter4fARB\0".ptr);
	glProgramEnvParameter4fvARB = cast(typeof(glProgramEnvParameter4fvARB))load("glProgramEnvParameter4fvARB\0".ptr);
	glProgramLocalParameter4dARB = cast(typeof(glProgramLocalParameter4dARB))load("glProgramLocalParameter4dARB\0".ptr);
	glProgramLocalParameter4dvARB = cast(typeof(glProgramLocalParameter4dvARB))load("glProgramLocalParameter4dvARB\0".ptr);
	glProgramLocalParameter4fARB = cast(typeof(glProgramLocalParameter4fARB))load("glProgramLocalParameter4fARB\0".ptr);
	glProgramLocalParameter4fvARB = cast(typeof(glProgramLocalParameter4fvARB))load("glProgramLocalParameter4fvARB\0".ptr);
	glGetProgramEnvParameterdvARB = cast(typeof(glGetProgramEnvParameterdvARB))load("glGetProgramEnvParameterdvARB\0".ptr);
	glGetProgramEnvParameterfvARB = cast(typeof(glGetProgramEnvParameterfvARB))load("glGetProgramEnvParameterfvARB\0".ptr);
	glGetProgramLocalParameterdvARB = cast(typeof(glGetProgramLocalParameterdvARB))load("glGetProgramLocalParameterdvARB\0".ptr);
	glGetProgramLocalParameterfvARB = cast(typeof(glGetProgramLocalParameterfvARB))load("glGetProgramLocalParameterfvARB\0".ptr);
	glGetProgramivARB = cast(typeof(glGetProgramivARB))load("glGetProgramivARB\0".ptr);
	glGetProgramStringARB = cast(typeof(glGetProgramStringARB))load("glGetProgramStringARB\0".ptr);
	glGetVertexAttribdvARB = cast(typeof(glGetVertexAttribdvARB))load("glGetVertexAttribdvARB\0".ptr);
	glGetVertexAttribfvARB = cast(typeof(glGetVertexAttribfvARB))load("glGetVertexAttribfvARB\0".ptr);
	glGetVertexAttribivARB = cast(typeof(glGetVertexAttribivARB))load("glGetVertexAttribivARB\0".ptr);
	glGetVertexAttribPointervARB = cast(typeof(glGetVertexAttribPointervARB))load("glGetVertexAttribPointervARB\0".ptr);
	glIsProgramARB = cast(typeof(glIsProgramARB))load("glIsProgramARB\0".ptr);
	return GL_ARB_vertex_program;
}


bool load_gl_GL_ARB_vertex_buffer_object(void* function(const(char)* name) load) {
	if(!GL_ARB_vertex_buffer_object) return GL_ARB_vertex_buffer_object;

	glBindBufferARB = cast(typeof(glBindBufferARB))load("glBindBufferARB\0".ptr);
	glDeleteBuffersARB = cast(typeof(glDeleteBuffersARB))load("glDeleteBuffersARB\0".ptr);
	glGenBuffersARB = cast(typeof(glGenBuffersARB))load("glGenBuffersARB\0".ptr);
	glIsBufferARB = cast(typeof(glIsBufferARB))load("glIsBufferARB\0".ptr);
	glBufferDataARB = cast(typeof(glBufferDataARB))load("glBufferDataARB\0".ptr);
	glBufferSubDataARB = cast(typeof(glBufferSubDataARB))load("glBufferSubDataARB\0".ptr);
	glGetBufferSubDataARB = cast(typeof(glGetBufferSubDataARB))load("glGetBufferSubDataARB\0".ptr);
	glMapBufferARB = cast(typeof(glMapBufferARB))load("glMapBufferARB\0".ptr);
	glUnmapBufferARB = cast(typeof(glUnmapBufferARB))load("glUnmapBufferARB\0".ptr);
	glGetBufferParameterivARB = cast(typeof(glGetBufferParameterivARB))load("glGetBufferParameterivARB\0".ptr);
	glGetBufferPointervARB = cast(typeof(glGetBufferPointervARB))load("glGetBufferPointervARB\0".ptr);
	return GL_ARB_vertex_buffer_object;
}


bool load_gl_GL_NV_vertex_array_range(void* function(const(char)* name) load) {
	if(!GL_NV_vertex_array_range) return GL_NV_vertex_array_range;

	glFlushVertexArrayRangeNV = cast(typeof(glFlushVertexArrayRangeNV))load("glFlushVertexArrayRangeNV\0".ptr);
	glVertexArrayRangeNV = cast(typeof(glVertexArrayRangeNV))load("glVertexArrayRangeNV\0".ptr);
	return GL_NV_vertex_array_range;
}


bool load_gl_GL_SGIX_fragment_lighting(void* function(const(char)* name) load) {
	if(!GL_SGIX_fragment_lighting) return GL_SGIX_fragment_lighting;

	glFragmentColorMaterialSGIX = cast(typeof(glFragmentColorMaterialSGIX))load("glFragmentColorMaterialSGIX\0".ptr);
	glFragmentLightfSGIX = cast(typeof(glFragmentLightfSGIX))load("glFragmentLightfSGIX\0".ptr);
	glFragmentLightfvSGIX = cast(typeof(glFragmentLightfvSGIX))load("glFragmentLightfvSGIX\0".ptr);
	glFragmentLightiSGIX = cast(typeof(glFragmentLightiSGIX))load("glFragmentLightiSGIX\0".ptr);
	glFragmentLightivSGIX = cast(typeof(glFragmentLightivSGIX))load("glFragmentLightivSGIX\0".ptr);
	glFragmentLightModelfSGIX = cast(typeof(glFragmentLightModelfSGIX))load("glFragmentLightModelfSGIX\0".ptr);
	glFragmentLightModelfvSGIX = cast(typeof(glFragmentLightModelfvSGIX))load("glFragmentLightModelfvSGIX\0".ptr);
	glFragmentLightModeliSGIX = cast(typeof(glFragmentLightModeliSGIX))load("glFragmentLightModeliSGIX\0".ptr);
	glFragmentLightModelivSGIX = cast(typeof(glFragmentLightModelivSGIX))load("glFragmentLightModelivSGIX\0".ptr);
	glFragmentMaterialfSGIX = cast(typeof(glFragmentMaterialfSGIX))load("glFragmentMaterialfSGIX\0".ptr);
	glFragmentMaterialfvSGIX = cast(typeof(glFragmentMaterialfvSGIX))load("glFragmentMaterialfvSGIX\0".ptr);
	glFragmentMaterialiSGIX = cast(typeof(glFragmentMaterialiSGIX))load("glFragmentMaterialiSGIX\0".ptr);
	glFragmentMaterialivSGIX = cast(typeof(glFragmentMaterialivSGIX))load("glFragmentMaterialivSGIX\0".ptr);
	glGetFragmentLightfvSGIX = cast(typeof(glGetFragmentLightfvSGIX))load("glGetFragmentLightfvSGIX\0".ptr);
	glGetFragmentLightivSGIX = cast(typeof(glGetFragmentLightivSGIX))load("glGetFragmentLightivSGIX\0".ptr);
	glGetFragmentMaterialfvSGIX = cast(typeof(glGetFragmentMaterialfvSGIX))load("glGetFragmentMaterialfvSGIX\0".ptr);
	glGetFragmentMaterialivSGIX = cast(typeof(glGetFragmentMaterialivSGIX))load("glGetFragmentMaterialivSGIX\0".ptr);
	glLightEnviSGIX = cast(typeof(glLightEnviSGIX))load("glLightEnviSGIX\0".ptr);
	return GL_SGIX_fragment_lighting;
}


bool load_gl_GL_NV_framebuffer_multisample_coverage(void* function(const(char)* name) load) {
	if(!GL_NV_framebuffer_multisample_coverage) return GL_NV_framebuffer_multisample_coverage;

	glRenderbufferStorageMultisampleCoverageNV = cast(typeof(glRenderbufferStorageMultisampleCoverageNV))load("glRenderbufferStorageMultisampleCoverageNV\0".ptr);
	return GL_NV_framebuffer_multisample_coverage;
}


bool load_gl_GL_EXT_timer_query(void* function(const(char)* name) load) {
	if(!GL_EXT_timer_query) return GL_EXT_timer_query;

	glGetQueryObjecti64vEXT = cast(typeof(glGetQueryObjecti64vEXT))load("glGetQueryObjecti64vEXT\0".ptr);
	glGetQueryObjectui64vEXT = cast(typeof(glGetQueryObjectui64vEXT))load("glGetQueryObjectui64vEXT\0".ptr);
	return GL_EXT_timer_query;
}


bool load_gl_GL_NV_bindless_texture(void* function(const(char)* name) load) {
	if(!GL_NV_bindless_texture) return GL_NV_bindless_texture;

	glGetTextureHandleNV = cast(typeof(glGetTextureHandleNV))load("glGetTextureHandleNV\0".ptr);
	glGetTextureSamplerHandleNV = cast(typeof(glGetTextureSamplerHandleNV))load("glGetTextureSamplerHandleNV\0".ptr);
	glMakeTextureHandleResidentNV = cast(typeof(glMakeTextureHandleResidentNV))load("glMakeTextureHandleResidentNV\0".ptr);
	glMakeTextureHandleNonResidentNV = cast(typeof(glMakeTextureHandleNonResidentNV))load("glMakeTextureHandleNonResidentNV\0".ptr);
	glGetImageHandleNV = cast(typeof(glGetImageHandleNV))load("glGetImageHandleNV\0".ptr);
	glMakeImageHandleResidentNV = cast(typeof(glMakeImageHandleResidentNV))load("glMakeImageHandleResidentNV\0".ptr);
	glMakeImageHandleNonResidentNV = cast(typeof(glMakeImageHandleNonResidentNV))load("glMakeImageHandleNonResidentNV\0".ptr);
	glUniformHandleui64NV = cast(typeof(glUniformHandleui64NV))load("glUniformHandleui64NV\0".ptr);
	glUniformHandleui64vNV = cast(typeof(glUniformHandleui64vNV))load("glUniformHandleui64vNV\0".ptr);
	glProgramUniformHandleui64NV = cast(typeof(glProgramUniformHandleui64NV))load("glProgramUniformHandleui64NV\0".ptr);
	glProgramUniformHandleui64vNV = cast(typeof(glProgramUniformHandleui64vNV))load("glProgramUniformHandleui64vNV\0".ptr);
	glIsTextureHandleResidentNV = cast(typeof(glIsTextureHandleResidentNV))load("glIsTextureHandleResidentNV\0".ptr);
	glIsImageHandleResidentNV = cast(typeof(glIsImageHandleResidentNV))load("glIsImageHandleResidentNV\0".ptr);
	return GL_NV_bindless_texture;
}


bool load_gl_GL_KHR_debug(void* function(const(char)* name) load) {
	if(!GL_KHR_debug) return GL_KHR_debug;

	glDebugMessageControl = cast(typeof(glDebugMessageControl))load("glDebugMessageControl\0".ptr);
	glDebugMessageInsert = cast(typeof(glDebugMessageInsert))load("glDebugMessageInsert\0".ptr);
	glDebugMessageCallback = cast(typeof(glDebugMessageCallback))load("glDebugMessageCallback\0".ptr);
	glGetDebugMessageLog = cast(typeof(glGetDebugMessageLog))load("glGetDebugMessageLog\0".ptr);
	glPushDebugGroup = cast(typeof(glPushDebugGroup))load("glPushDebugGroup\0".ptr);
	glPopDebugGroup = cast(typeof(glPopDebugGroup))load("glPopDebugGroup\0".ptr);
	glObjectLabel = cast(typeof(glObjectLabel))load("glObjectLabel\0".ptr);
	glGetObjectLabel = cast(typeof(glGetObjectLabel))load("glGetObjectLabel\0".ptr);
	glObjectPtrLabel = cast(typeof(glObjectPtrLabel))load("glObjectPtrLabel\0".ptr);
	glGetObjectPtrLabel = cast(typeof(glGetObjectPtrLabel))load("glGetObjectPtrLabel\0".ptr);
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv\0".ptr);
	glDebugMessageControlKHR = cast(typeof(glDebugMessageControlKHR))load("glDebugMessageControlKHR\0".ptr);
	glDebugMessageInsertKHR = cast(typeof(glDebugMessageInsertKHR))load("glDebugMessageInsertKHR\0".ptr);
	glDebugMessageCallbackKHR = cast(typeof(glDebugMessageCallbackKHR))load("glDebugMessageCallbackKHR\0".ptr);
	glGetDebugMessageLogKHR = cast(typeof(glGetDebugMessageLogKHR))load("glGetDebugMessageLogKHR\0".ptr);
	glPushDebugGroupKHR = cast(typeof(glPushDebugGroupKHR))load("glPushDebugGroupKHR\0".ptr);
	glPopDebugGroupKHR = cast(typeof(glPopDebugGroupKHR))load("glPopDebugGroupKHR\0".ptr);
	glObjectLabelKHR = cast(typeof(glObjectLabelKHR))load("glObjectLabelKHR\0".ptr);
	glGetObjectLabelKHR = cast(typeof(glGetObjectLabelKHR))load("glGetObjectLabelKHR\0".ptr);
	glObjectPtrLabelKHR = cast(typeof(glObjectPtrLabelKHR))load("glObjectPtrLabelKHR\0".ptr);
	glGetObjectPtrLabelKHR = cast(typeof(glGetObjectPtrLabelKHR))load("glGetObjectPtrLabelKHR\0".ptr);
	glGetPointervKHR = cast(typeof(glGetPointervKHR))load("glGetPointervKHR\0".ptr);
	return GL_KHR_debug;
}


bool load_gl_GL_ATI_vertex_attrib_array_object(void* function(const(char)* name) load) {
	if(!GL_ATI_vertex_attrib_array_object) return GL_ATI_vertex_attrib_array_object;

	glVertexAttribArrayObjectATI = cast(typeof(glVertexAttribArrayObjectATI))load("glVertexAttribArrayObjectATI\0".ptr);
	glGetVertexAttribArrayObjectfvATI = cast(typeof(glGetVertexAttribArrayObjectfvATI))load("glGetVertexAttribArrayObjectfvATI\0".ptr);
	glGetVertexAttribArrayObjectivATI = cast(typeof(glGetVertexAttribArrayObjectivATI))load("glGetVertexAttribArrayObjectivATI\0".ptr);
	return GL_ATI_vertex_attrib_array_object;
}


bool load_gl_GL_EXT_geometry_shader4(void* function(const(char)* name) load) {
	if(!GL_EXT_geometry_shader4) return GL_EXT_geometry_shader4;

	glProgramParameteriEXT = cast(typeof(glProgramParameteriEXT))load("glProgramParameteriEXT\0".ptr);
	return GL_EXT_geometry_shader4;
}


bool load_gl_GL_EXT_bindable_uniform(void* function(const(char)* name) load) {
	if(!GL_EXT_bindable_uniform) return GL_EXT_bindable_uniform;

	glUniformBufferEXT = cast(typeof(glUniformBufferEXT))load("glUniformBufferEXT\0".ptr);
	glGetUniformBufferSizeEXT = cast(typeof(glGetUniformBufferSizeEXT))load("glGetUniformBufferSizeEXT\0".ptr);
	glGetUniformOffsetEXT = cast(typeof(glGetUniformOffsetEXT))load("glGetUniformOffsetEXT\0".ptr);
	return GL_EXT_bindable_uniform;
}


bool load_gl_GL_ATI_element_array(void* function(const(char)* name) load) {
	if(!GL_ATI_element_array) return GL_ATI_element_array;

	glElementPointerATI = cast(typeof(glElementPointerATI))load("glElementPointerATI\0".ptr);
	glDrawElementArrayATI = cast(typeof(glDrawElementArrayATI))load("glDrawElementArrayATI\0".ptr);
	glDrawRangeElementArrayATI = cast(typeof(glDrawRangeElementArrayATI))load("glDrawRangeElementArrayATI\0".ptr);
	return GL_ATI_element_array;
}


bool load_gl_GL_SGIX_reference_plane(void* function(const(char)* name) load) {
	if(!GL_SGIX_reference_plane) return GL_SGIX_reference_plane;

	glReferencePlaneSGIX = cast(typeof(glReferencePlaneSGIX))load("glReferencePlaneSGIX\0".ptr);
	return GL_SGIX_reference_plane;
}


bool load_gl_GL_EXT_stencil_two_side(void* function(const(char)* name) load) {
	if(!GL_EXT_stencil_two_side) return GL_EXT_stencil_two_side;

	glActiveStencilFaceEXT = cast(typeof(glActiveStencilFaceEXT))load("glActiveStencilFaceEXT\0".ptr);
	return GL_EXT_stencil_two_side;
}


bool load_gl_GL_NV_explicit_multisample(void* function(const(char)* name) load) {
	if(!GL_NV_explicit_multisample) return GL_NV_explicit_multisample;

	glGetMultisamplefvNV = cast(typeof(glGetMultisamplefvNV))load("glGetMultisamplefvNV\0".ptr);
	glSampleMaskIndexedNV = cast(typeof(glSampleMaskIndexedNV))load("glSampleMaskIndexedNV\0".ptr);
	glTexRenderbufferNV = cast(typeof(glTexRenderbufferNV))load("glTexRenderbufferNV\0".ptr);
	return GL_NV_explicit_multisample;
}


bool load_gl_GL_IBM_static_data(void* function(const(char)* name) load) {
	if(!GL_IBM_static_data) return GL_IBM_static_data;

	glFlushStaticDataIBM = cast(typeof(glFlushStaticDataIBM))load("glFlushStaticDataIBM\0".ptr);
	return GL_IBM_static_data;
}


bool load_gl_GL_EXT_texture_perturb_normal(void* function(const(char)* name) load) {
	if(!GL_EXT_texture_perturb_normal) return GL_EXT_texture_perturb_normal;

	glTextureNormalEXT = cast(typeof(glTextureNormalEXT))load("glTextureNormalEXT\0".ptr);
	return GL_EXT_texture_perturb_normal;
}


bool load_gl_GL_EXT_point_parameters(void* function(const(char)* name) load) {
	if(!GL_EXT_point_parameters) return GL_EXT_point_parameters;

	glPointParameterfEXT = cast(typeof(glPointParameterfEXT))load("glPointParameterfEXT\0".ptr);
	glPointParameterfvEXT = cast(typeof(glPointParameterfvEXT))load("glPointParameterfvEXT\0".ptr);
	return GL_EXT_point_parameters;
}


bool load_gl_GL_PGI_misc_hints(void* function(const(char)* name) load) {
	if(!GL_PGI_misc_hints) return GL_PGI_misc_hints;

	glHintPGI = cast(typeof(glHintPGI))load("glHintPGI\0".ptr);
	return GL_PGI_misc_hints;
}


bool load_gl_GL_ARB_vertex_shader(void* function(const(char)* name) load) {
	if(!GL_ARB_vertex_shader) return GL_ARB_vertex_shader;

	glBindAttribLocationARB = cast(typeof(glBindAttribLocationARB))load("glBindAttribLocationARB\0".ptr);
	glGetActiveAttribARB = cast(typeof(glGetActiveAttribARB))load("glGetActiveAttribARB\0".ptr);
	glGetAttribLocationARB = cast(typeof(glGetAttribLocationARB))load("glGetAttribLocationARB\0".ptr);
	return GL_ARB_vertex_shader;
}


bool load_gl_GL_ARB_tessellation_shader(void* function(const(char)* name) load) {
	if(!GL_ARB_tessellation_shader) return GL_ARB_tessellation_shader;

	glPatchParameteri = cast(typeof(glPatchParameteri))load("glPatchParameteri\0".ptr);
	glPatchParameterfv = cast(typeof(glPatchParameterfv))load("glPatchParameterfv\0".ptr);
	return GL_ARB_tessellation_shader;
}


bool load_gl_GL_EXT_draw_buffers2(void* function(const(char)* name) load) {
	if(!GL_EXT_draw_buffers2) return GL_EXT_draw_buffers2;

	glColorMaskIndexedEXT = cast(typeof(glColorMaskIndexedEXT))load("glColorMaskIndexedEXT\0".ptr);
	glGetBooleanIndexedvEXT = cast(typeof(glGetBooleanIndexedvEXT))load("glGetBooleanIndexedvEXT\0".ptr);
	glGetIntegerIndexedvEXT = cast(typeof(glGetIntegerIndexedvEXT))load("glGetIntegerIndexedvEXT\0".ptr);
	glEnableIndexedEXT = cast(typeof(glEnableIndexedEXT))load("glEnableIndexedEXT\0".ptr);
	glDisableIndexedEXT = cast(typeof(glDisableIndexedEXT))load("glDisableIndexedEXT\0".ptr);
	glIsEnabledIndexedEXT = cast(typeof(glIsEnabledIndexedEXT))load("glIsEnabledIndexedEXT\0".ptr);
	return GL_EXT_draw_buffers2;
}


bool load_gl_GL_ARB_vertex_attrib_64bit(void* function(const(char)* name) load) {
	if(!GL_ARB_vertex_attrib_64bit) return GL_ARB_vertex_attrib_64bit;

	glVertexAttribL1d = cast(typeof(glVertexAttribL1d))load("glVertexAttribL1d\0".ptr);
	glVertexAttribL2d = cast(typeof(glVertexAttribL2d))load("glVertexAttribL2d\0".ptr);
	glVertexAttribL3d = cast(typeof(glVertexAttribL3d))load("glVertexAttribL3d\0".ptr);
	glVertexAttribL4d = cast(typeof(glVertexAttribL4d))load("glVertexAttribL4d\0".ptr);
	glVertexAttribL1dv = cast(typeof(glVertexAttribL1dv))load("glVertexAttribL1dv\0".ptr);
	glVertexAttribL2dv = cast(typeof(glVertexAttribL2dv))load("glVertexAttribL2dv\0".ptr);
	glVertexAttribL3dv = cast(typeof(glVertexAttribL3dv))load("glVertexAttribL3dv\0".ptr);
	glVertexAttribL4dv = cast(typeof(glVertexAttribL4dv))load("glVertexAttribL4dv\0".ptr);
	glVertexAttribLPointer = cast(typeof(glVertexAttribLPointer))load("glVertexAttribLPointer\0".ptr);
	glGetVertexAttribLdv = cast(typeof(glGetVertexAttribLdv))load("glGetVertexAttribLdv\0".ptr);
	return GL_ARB_vertex_attrib_64bit;
}


bool load_gl_GL_AMD_interleaved_elements(void* function(const(char)* name) load) {
	if(!GL_AMD_interleaved_elements) return GL_AMD_interleaved_elements;

	glVertexAttribParameteriAMD = cast(typeof(glVertexAttribParameteriAMD))load("glVertexAttribParameteriAMD\0".ptr);
	return GL_AMD_interleaved_elements;
}


bool load_gl_GL_ARB_fragment_program(void* function(const(char)* name) load) {
	if(!GL_ARB_fragment_program) return GL_ARB_fragment_program;

	glProgramStringARB = cast(typeof(glProgramStringARB))load("glProgramStringARB\0".ptr);
	glBindProgramARB = cast(typeof(glBindProgramARB))load("glBindProgramARB\0".ptr);
	glDeleteProgramsARB = cast(typeof(glDeleteProgramsARB))load("glDeleteProgramsARB\0".ptr);
	glGenProgramsARB = cast(typeof(glGenProgramsARB))load("glGenProgramsARB\0".ptr);
	glProgramEnvParameter4dARB = cast(typeof(glProgramEnvParameter4dARB))load("glProgramEnvParameter4dARB\0".ptr);
	glProgramEnvParameter4dvARB = cast(typeof(glProgramEnvParameter4dvARB))load("glProgramEnvParameter4dvARB\0".ptr);
	glProgramEnvParameter4fARB = cast(typeof(glProgramEnvParameter4fARB))load("glProgramEnvParameter4fARB\0".ptr);
	glProgramEnvParameter4fvARB = cast(typeof(glProgramEnvParameter4fvARB))load("glProgramEnvParameter4fvARB\0".ptr);
	glProgramLocalParameter4dARB = cast(typeof(glProgramLocalParameter4dARB))load("glProgramLocalParameter4dARB\0".ptr);
	glProgramLocalParameter4dvARB = cast(typeof(glProgramLocalParameter4dvARB))load("glProgramLocalParameter4dvARB\0".ptr);
	glProgramLocalParameter4fARB = cast(typeof(glProgramLocalParameter4fARB))load("glProgramLocalParameter4fARB\0".ptr);
	glProgramLocalParameter4fvARB = cast(typeof(glProgramLocalParameter4fvARB))load("glProgramLocalParameter4fvARB\0".ptr);
	glGetProgramEnvParameterdvARB = cast(typeof(glGetProgramEnvParameterdvARB))load("glGetProgramEnvParameterdvARB\0".ptr);
	glGetProgramEnvParameterfvARB = cast(typeof(glGetProgramEnvParameterfvARB))load("glGetProgramEnvParameterfvARB\0".ptr);
	glGetProgramLocalParameterdvARB = cast(typeof(glGetProgramLocalParameterdvARB))load("glGetProgramLocalParameterdvARB\0".ptr);
	glGetProgramLocalParameterfvARB = cast(typeof(glGetProgramLocalParameterfvARB))load("glGetProgramLocalParameterfvARB\0".ptr);
	glGetProgramivARB = cast(typeof(glGetProgramivARB))load("glGetProgramivARB\0".ptr);
	glGetProgramStringARB = cast(typeof(glGetProgramStringARB))load("glGetProgramStringARB\0".ptr);
	glIsProgramARB = cast(typeof(glIsProgramARB))load("glIsProgramARB\0".ptr);
	return GL_ARB_fragment_program;
}


bool load_gl_GL_ARB_texture_storage(void* function(const(char)* name) load) {
	if(!GL_ARB_texture_storage) return GL_ARB_texture_storage;

	glTexStorage1D = cast(typeof(glTexStorage1D))load("glTexStorage1D\0".ptr);
	glTexStorage2D = cast(typeof(glTexStorage2D))load("glTexStorage2D\0".ptr);
	glTexStorage3D = cast(typeof(glTexStorage3D))load("glTexStorage3D\0".ptr);
	return GL_ARB_texture_storage;
}


bool load_gl_GL_ARB_copy_image(void* function(const(char)* name) load) {
	if(!GL_ARB_copy_image) return GL_ARB_copy_image;

	glCopyImageSubData = cast(typeof(glCopyImageSubData))load("glCopyImageSubData\0".ptr);
	return GL_ARB_copy_image;
}


bool load_gl_GL_SGIS_pixel_texture(void* function(const(char)* name) load) {
	if(!GL_SGIS_pixel_texture) return GL_SGIS_pixel_texture;

	glPixelTexGenParameteriSGIS = cast(typeof(glPixelTexGenParameteriSGIS))load("glPixelTexGenParameteriSGIS\0".ptr);
	glPixelTexGenParameterivSGIS = cast(typeof(glPixelTexGenParameterivSGIS))load("glPixelTexGenParameterivSGIS\0".ptr);
	glPixelTexGenParameterfSGIS = cast(typeof(glPixelTexGenParameterfSGIS))load("glPixelTexGenParameterfSGIS\0".ptr);
	glPixelTexGenParameterfvSGIS = cast(typeof(glPixelTexGenParameterfvSGIS))load("glPixelTexGenParameterfvSGIS\0".ptr);
	glGetPixelTexGenParameterivSGIS = cast(typeof(glGetPixelTexGenParameterivSGIS))load("glGetPixelTexGenParameterivSGIS\0".ptr);
	glGetPixelTexGenParameterfvSGIS = cast(typeof(glGetPixelTexGenParameterfvSGIS))load("glGetPixelTexGenParameterfvSGIS\0".ptr);
	return GL_SGIS_pixel_texture;
}


bool load_gl_GL_SGIX_instruments(void* function(const(char)* name) load) {
	if(!GL_SGIX_instruments) return GL_SGIX_instruments;

	glGetInstrumentsSGIX = cast(typeof(glGetInstrumentsSGIX))load("glGetInstrumentsSGIX\0".ptr);
	glInstrumentsBufferSGIX = cast(typeof(glInstrumentsBufferSGIX))load("glInstrumentsBufferSGIX\0".ptr);
	glPollInstrumentsSGIX = cast(typeof(glPollInstrumentsSGIX))load("glPollInstrumentsSGIX\0".ptr);
	glReadInstrumentsSGIX = cast(typeof(glReadInstrumentsSGIX))load("glReadInstrumentsSGIX\0".ptr);
	glStartInstrumentsSGIX = cast(typeof(glStartInstrumentsSGIX))load("glStartInstrumentsSGIX\0".ptr);
	glStopInstrumentsSGIX = cast(typeof(glStopInstrumentsSGIX))load("glStopInstrumentsSGIX\0".ptr);
	return GL_SGIX_instruments;
}


bool load_gl_GL_ARB_shader_storage_buffer_object(void* function(const(char)* name) load) {
	if(!GL_ARB_shader_storage_buffer_object) return GL_ARB_shader_storage_buffer_object;

	glShaderStorageBlockBinding = cast(typeof(glShaderStorageBlockBinding))load("glShaderStorageBlockBinding\0".ptr);
	return GL_ARB_shader_storage_buffer_object;
}


bool load_gl_GL_EXT_blend_minmax(void* function(const(char)* name) load) {
	if(!GL_EXT_blend_minmax) return GL_EXT_blend_minmax;

	glBlendEquationEXT = cast(typeof(glBlendEquationEXT))load("glBlendEquationEXT\0".ptr);
	return GL_EXT_blend_minmax;
}


bool load_gl_GL_ARB_base_instance(void* function(const(char)* name) load) {
	if(!GL_ARB_base_instance) return GL_ARB_base_instance;

	glDrawArraysInstancedBaseInstance = cast(typeof(glDrawArraysInstancedBaseInstance))load("glDrawArraysInstancedBaseInstance\0".ptr);
	glDrawElementsInstancedBaseInstance = cast(typeof(glDrawElementsInstancedBaseInstance))load("glDrawElementsInstancedBaseInstance\0".ptr);
	glDrawElementsInstancedBaseVertexBaseInstance = cast(typeof(glDrawElementsInstancedBaseVertexBaseInstance))load("glDrawElementsInstancedBaseVertexBaseInstance\0".ptr);
	return GL_ARB_base_instance;
}


bool load_gl_GL_EXT_texture_integer(void* function(const(char)* name) load) {
	if(!GL_EXT_texture_integer) return GL_EXT_texture_integer;

	glTexParameterIivEXT = cast(typeof(glTexParameterIivEXT))load("glTexParameterIivEXT\0".ptr);
	glTexParameterIuivEXT = cast(typeof(glTexParameterIuivEXT))load("glTexParameterIuivEXT\0".ptr);
	glGetTexParameterIivEXT = cast(typeof(glGetTexParameterIivEXT))load("glGetTexParameterIivEXT\0".ptr);
	glGetTexParameterIuivEXT = cast(typeof(glGetTexParameterIuivEXT))load("glGetTexParameterIuivEXT\0".ptr);
	glClearColorIiEXT = cast(typeof(glClearColorIiEXT))load("glClearColorIiEXT\0".ptr);
	glClearColorIuiEXT = cast(typeof(glClearColorIuiEXT))load("glClearColorIuiEXT\0".ptr);
	return GL_EXT_texture_integer;
}


bool load_gl_GL_ARB_texture_multisample(void* function(const(char)* name) load) {
	if(!GL_ARB_texture_multisample) return GL_ARB_texture_multisample;

	glTexImage2DMultisample = cast(typeof(glTexImage2DMultisample))load("glTexImage2DMultisample\0".ptr);
	glTexImage3DMultisample = cast(typeof(glTexImage3DMultisample))load("glTexImage3DMultisample\0".ptr);
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv\0".ptr);
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski\0".ptr);
	return GL_ARB_texture_multisample;
}


bool load_gl_GL_AMD_vertex_shader_tessellator(void* function(const(char)* name) load) {
	if(!GL_AMD_vertex_shader_tessellator) return GL_AMD_vertex_shader_tessellator;

	glTessellationFactorAMD = cast(typeof(glTessellationFactorAMD))load("glTessellationFactorAMD\0".ptr);
	glTessellationModeAMD = cast(typeof(glTessellationModeAMD))load("glTessellationModeAMD\0".ptr);
	return GL_AMD_vertex_shader_tessellator;
}


bool load_gl_GL_ARB_invalidate_subdata(void* function(const(char)* name) load) {
	if(!GL_ARB_invalidate_subdata) return GL_ARB_invalidate_subdata;

	glInvalidateTexSubImage = cast(typeof(glInvalidateTexSubImage))load("glInvalidateTexSubImage\0".ptr);
	glInvalidateTexImage = cast(typeof(glInvalidateTexImage))load("glInvalidateTexImage\0".ptr);
	glInvalidateBufferSubData = cast(typeof(glInvalidateBufferSubData))load("glInvalidateBufferSubData\0".ptr);
	glInvalidateBufferData = cast(typeof(glInvalidateBufferData))load("glInvalidateBufferData\0".ptr);
	glInvalidateFramebuffer = cast(typeof(glInvalidateFramebuffer))load("glInvalidateFramebuffer\0".ptr);
	glInvalidateSubFramebuffer = cast(typeof(glInvalidateSubFramebuffer))load("glInvalidateSubFramebuffer\0".ptr);
	return GL_ARB_invalidate_subdata;
}


bool load_gl_GL_EXT_index_material(void* function(const(char)* name) load) {
	if(!GL_EXT_index_material) return GL_EXT_index_material;

	glIndexMaterialEXT = cast(typeof(glIndexMaterialEXT))load("glIndexMaterialEXT\0".ptr);
	return GL_EXT_index_material;
}


bool load_gl_GL_INTEL_parallel_arrays(void* function(const(char)* name) load) {
	if(!GL_INTEL_parallel_arrays) return GL_INTEL_parallel_arrays;

	glVertexPointervINTEL = cast(typeof(glVertexPointervINTEL))load("glVertexPointervINTEL\0".ptr);
	glNormalPointervINTEL = cast(typeof(glNormalPointervINTEL))load("glNormalPointervINTEL\0".ptr);
	glColorPointervINTEL = cast(typeof(glColorPointervINTEL))load("glColorPointervINTEL\0".ptr);
	glTexCoordPointervINTEL = cast(typeof(glTexCoordPointervINTEL))load("glTexCoordPointervINTEL\0".ptr);
	return GL_INTEL_parallel_arrays;
}


bool load_gl_GL_ATI_draw_buffers(void* function(const(char)* name) load) {
	if(!GL_ATI_draw_buffers) return GL_ATI_draw_buffers;

	glDrawBuffersATI = cast(typeof(glDrawBuffersATI))load("glDrawBuffersATI\0".ptr);
	return GL_ATI_draw_buffers;
}


bool load_gl_GL_SGIX_pixel_texture(void* function(const(char)* name) load) {
	if(!GL_SGIX_pixel_texture) return GL_SGIX_pixel_texture;

	glPixelTexGenSGIX = cast(typeof(glPixelTexGenSGIX))load("glPixelTexGenSGIX\0".ptr);
	return GL_SGIX_pixel_texture;
}


bool load_gl_GL_ARB_timer_query(void* function(const(char)* name) load) {
	if(!GL_ARB_timer_query) return GL_ARB_timer_query;

	glQueryCounter = cast(typeof(glQueryCounter))load("glQueryCounter\0".ptr);
	glGetQueryObjecti64v = cast(typeof(glGetQueryObjecti64v))load("glGetQueryObjecti64v\0".ptr);
	glGetQueryObjectui64v = cast(typeof(glGetQueryObjectui64v))load("glGetQueryObjectui64v\0".ptr);
	return GL_ARB_timer_query;
}


bool load_gl_GL_NV_parameter_buffer_object(void* function(const(char)* name) load) {
	if(!GL_NV_parameter_buffer_object) return GL_NV_parameter_buffer_object;

	glProgramBufferParametersfvNV = cast(typeof(glProgramBufferParametersfvNV))load("glProgramBufferParametersfvNV\0".ptr);
	glProgramBufferParametersIivNV = cast(typeof(glProgramBufferParametersIivNV))load("glProgramBufferParametersIivNV\0".ptr);
	glProgramBufferParametersIuivNV = cast(typeof(glProgramBufferParametersIuivNV))load("glProgramBufferParametersIuivNV\0".ptr);
	return GL_NV_parameter_buffer_object;
}


bool load_gl_GL_ARB_uniform_buffer_object(void* function(const(char)* name) load) {
	if(!GL_ARB_uniform_buffer_object) return GL_ARB_uniform_buffer_object;

	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices\0".ptr);
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv\0".ptr);
	glGetActiveUniformName = cast(typeof(glGetActiveUniformName))load("glGetActiveUniformName\0".ptr);
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex\0".ptr);
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv\0".ptr);
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName\0".ptr);
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding\0".ptr);
	return GL_ARB_uniform_buffer_object;
}


bool load_gl_GL_NV_transform_feedback2(void* function(const(char)* name) load) {
	if(!GL_NV_transform_feedback2) return GL_NV_transform_feedback2;

	glBindTransformFeedbackNV = cast(typeof(glBindTransformFeedbackNV))load("glBindTransformFeedbackNV\0".ptr);
	glDeleteTransformFeedbacksNV = cast(typeof(glDeleteTransformFeedbacksNV))load("glDeleteTransformFeedbacksNV\0".ptr);
	glGenTransformFeedbacksNV = cast(typeof(glGenTransformFeedbacksNV))load("glGenTransformFeedbacksNV\0".ptr);
	glIsTransformFeedbackNV = cast(typeof(glIsTransformFeedbackNV))load("glIsTransformFeedbackNV\0".ptr);
	glPauseTransformFeedbackNV = cast(typeof(glPauseTransformFeedbackNV))load("glPauseTransformFeedbackNV\0".ptr);
	glResumeTransformFeedbackNV = cast(typeof(glResumeTransformFeedbackNV))load("glResumeTransformFeedbackNV\0".ptr);
	glDrawTransformFeedbackNV = cast(typeof(glDrawTransformFeedbackNV))load("glDrawTransformFeedbackNV\0".ptr);
	return GL_NV_transform_feedback2;
}


bool load_gl_GL_EXT_blend_color(void* function(const(char)* name) load) {
	if(!GL_EXT_blend_color) return GL_EXT_blend_color;

	glBlendColorEXT = cast(typeof(glBlendColorEXT))load("glBlendColorEXT\0".ptr);
	return GL_EXT_blend_color;
}


bool load_gl_GL_EXT_histogram(void* function(const(char)* name) load) {
	if(!GL_EXT_histogram) return GL_EXT_histogram;

	glGetHistogramEXT = cast(typeof(glGetHistogramEXT))load("glGetHistogramEXT\0".ptr);
	glGetHistogramParameterfvEXT = cast(typeof(glGetHistogramParameterfvEXT))load("glGetHistogramParameterfvEXT\0".ptr);
	glGetHistogramParameterivEXT = cast(typeof(glGetHistogramParameterivEXT))load("glGetHistogramParameterivEXT\0".ptr);
	glGetMinmaxEXT = cast(typeof(glGetMinmaxEXT))load("glGetMinmaxEXT\0".ptr);
	glGetMinmaxParameterfvEXT = cast(typeof(glGetMinmaxParameterfvEXT))load("glGetMinmaxParameterfvEXT\0".ptr);
	glGetMinmaxParameterivEXT = cast(typeof(glGetMinmaxParameterivEXT))load("glGetMinmaxParameterivEXT\0".ptr);
	glHistogramEXT = cast(typeof(glHistogramEXT))load("glHistogramEXT\0".ptr);
	glMinmaxEXT = cast(typeof(glMinmaxEXT))load("glMinmaxEXT\0".ptr);
	glResetHistogramEXT = cast(typeof(glResetHistogramEXT))load("glResetHistogramEXT\0".ptr);
	glResetMinmaxEXT = cast(typeof(glResetMinmaxEXT))load("glResetMinmaxEXT\0".ptr);
	return GL_EXT_histogram;
}


bool load_gl_GL_SGIS_point_parameters(void* function(const(char)* name) load) {
	if(!GL_SGIS_point_parameters) return GL_SGIS_point_parameters;

	glPointParameterfSGIS = cast(typeof(glPointParameterfSGIS))load("glPointParameterfSGIS\0".ptr);
	glPointParameterfvSGIS = cast(typeof(glPointParameterfvSGIS))load("glPointParameterfvSGIS\0".ptr);
	return GL_SGIS_point_parameters;
}


bool load_gl_GL_EXT_direct_state_access(void* function(const(char)* name) load) {
	if(!GL_EXT_direct_state_access) return GL_EXT_direct_state_access;

	glMatrixLoadfEXT = cast(typeof(glMatrixLoadfEXT))load("glMatrixLoadfEXT\0".ptr);
	glMatrixLoaddEXT = cast(typeof(glMatrixLoaddEXT))load("glMatrixLoaddEXT\0".ptr);
	glMatrixMultfEXT = cast(typeof(glMatrixMultfEXT))load("glMatrixMultfEXT\0".ptr);
	glMatrixMultdEXT = cast(typeof(glMatrixMultdEXT))load("glMatrixMultdEXT\0".ptr);
	glMatrixLoadIdentityEXT = cast(typeof(glMatrixLoadIdentityEXT))load("glMatrixLoadIdentityEXT\0".ptr);
	glMatrixRotatefEXT = cast(typeof(glMatrixRotatefEXT))load("glMatrixRotatefEXT\0".ptr);
	glMatrixRotatedEXT = cast(typeof(glMatrixRotatedEXT))load("glMatrixRotatedEXT\0".ptr);
	glMatrixScalefEXT = cast(typeof(glMatrixScalefEXT))load("glMatrixScalefEXT\0".ptr);
	glMatrixScaledEXT = cast(typeof(glMatrixScaledEXT))load("glMatrixScaledEXT\0".ptr);
	glMatrixTranslatefEXT = cast(typeof(glMatrixTranslatefEXT))load("glMatrixTranslatefEXT\0".ptr);
	glMatrixTranslatedEXT = cast(typeof(glMatrixTranslatedEXT))load("glMatrixTranslatedEXT\0".ptr);
	glMatrixFrustumEXT = cast(typeof(glMatrixFrustumEXT))load("glMatrixFrustumEXT\0".ptr);
	glMatrixOrthoEXT = cast(typeof(glMatrixOrthoEXT))load("glMatrixOrthoEXT\0".ptr);
	glMatrixPopEXT = cast(typeof(glMatrixPopEXT))load("glMatrixPopEXT\0".ptr);
	glMatrixPushEXT = cast(typeof(glMatrixPushEXT))load("glMatrixPushEXT\0".ptr);
	glClientAttribDefaultEXT = cast(typeof(glClientAttribDefaultEXT))load("glClientAttribDefaultEXT\0".ptr);
	glPushClientAttribDefaultEXT = cast(typeof(glPushClientAttribDefaultEXT))load("glPushClientAttribDefaultEXT\0".ptr);
	glTextureParameterfEXT = cast(typeof(glTextureParameterfEXT))load("glTextureParameterfEXT\0".ptr);
	glTextureParameterfvEXT = cast(typeof(glTextureParameterfvEXT))load("glTextureParameterfvEXT\0".ptr);
	glTextureParameteriEXT = cast(typeof(glTextureParameteriEXT))load("glTextureParameteriEXT\0".ptr);
	glTextureParameterivEXT = cast(typeof(glTextureParameterivEXT))load("glTextureParameterivEXT\0".ptr);
	glTextureImage1DEXT = cast(typeof(glTextureImage1DEXT))load("glTextureImage1DEXT\0".ptr);
	glTextureImage2DEXT = cast(typeof(glTextureImage2DEXT))load("glTextureImage2DEXT\0".ptr);
	glTextureSubImage1DEXT = cast(typeof(glTextureSubImage1DEXT))load("glTextureSubImage1DEXT\0".ptr);
	glTextureSubImage2DEXT = cast(typeof(glTextureSubImage2DEXT))load("glTextureSubImage2DEXT\0".ptr);
	glCopyTextureImage1DEXT = cast(typeof(glCopyTextureImage1DEXT))load("glCopyTextureImage1DEXT\0".ptr);
	glCopyTextureImage2DEXT = cast(typeof(glCopyTextureImage2DEXT))load("glCopyTextureImage2DEXT\0".ptr);
	glCopyTextureSubImage1DEXT = cast(typeof(glCopyTextureSubImage1DEXT))load("glCopyTextureSubImage1DEXT\0".ptr);
	glCopyTextureSubImage2DEXT = cast(typeof(glCopyTextureSubImage2DEXT))load("glCopyTextureSubImage2DEXT\0".ptr);
	glGetTextureImageEXT = cast(typeof(glGetTextureImageEXT))load("glGetTextureImageEXT\0".ptr);
	glGetTextureParameterfvEXT = cast(typeof(glGetTextureParameterfvEXT))load("glGetTextureParameterfvEXT\0".ptr);
	glGetTextureParameterivEXT = cast(typeof(glGetTextureParameterivEXT))load("glGetTextureParameterivEXT\0".ptr);
	glGetTextureLevelParameterfvEXT = cast(typeof(glGetTextureLevelParameterfvEXT))load("glGetTextureLevelParameterfvEXT\0".ptr);
	glGetTextureLevelParameterivEXT = cast(typeof(glGetTextureLevelParameterivEXT))load("glGetTextureLevelParameterivEXT\0".ptr);
	glTextureImage3DEXT = cast(typeof(glTextureImage3DEXT))load("glTextureImage3DEXT\0".ptr);
	glTextureSubImage3DEXT = cast(typeof(glTextureSubImage3DEXT))load("glTextureSubImage3DEXT\0".ptr);
	glCopyTextureSubImage3DEXT = cast(typeof(glCopyTextureSubImage3DEXT))load("glCopyTextureSubImage3DEXT\0".ptr);
	glBindMultiTextureEXT = cast(typeof(glBindMultiTextureEXT))load("glBindMultiTextureEXT\0".ptr);
	glMultiTexCoordPointerEXT = cast(typeof(glMultiTexCoordPointerEXT))load("glMultiTexCoordPointerEXT\0".ptr);
	glMultiTexEnvfEXT = cast(typeof(glMultiTexEnvfEXT))load("glMultiTexEnvfEXT\0".ptr);
	glMultiTexEnvfvEXT = cast(typeof(glMultiTexEnvfvEXT))load("glMultiTexEnvfvEXT\0".ptr);
	glMultiTexEnviEXT = cast(typeof(glMultiTexEnviEXT))load("glMultiTexEnviEXT\0".ptr);
	glMultiTexEnvivEXT = cast(typeof(glMultiTexEnvivEXT))load("glMultiTexEnvivEXT\0".ptr);
	glMultiTexGendEXT = cast(typeof(glMultiTexGendEXT))load("glMultiTexGendEXT\0".ptr);
	glMultiTexGendvEXT = cast(typeof(glMultiTexGendvEXT))load("glMultiTexGendvEXT\0".ptr);
	glMultiTexGenfEXT = cast(typeof(glMultiTexGenfEXT))load("glMultiTexGenfEXT\0".ptr);
	glMultiTexGenfvEXT = cast(typeof(glMultiTexGenfvEXT))load("glMultiTexGenfvEXT\0".ptr);
	glMultiTexGeniEXT = cast(typeof(glMultiTexGeniEXT))load("glMultiTexGeniEXT\0".ptr);
	glMultiTexGenivEXT = cast(typeof(glMultiTexGenivEXT))load("glMultiTexGenivEXT\0".ptr);
	glGetMultiTexEnvfvEXT = cast(typeof(glGetMultiTexEnvfvEXT))load("glGetMultiTexEnvfvEXT\0".ptr);
	glGetMultiTexEnvivEXT = cast(typeof(glGetMultiTexEnvivEXT))load("glGetMultiTexEnvivEXT\0".ptr);
	glGetMultiTexGendvEXT = cast(typeof(glGetMultiTexGendvEXT))load("glGetMultiTexGendvEXT\0".ptr);
	glGetMultiTexGenfvEXT = cast(typeof(glGetMultiTexGenfvEXT))load("glGetMultiTexGenfvEXT\0".ptr);
	glGetMultiTexGenivEXT = cast(typeof(glGetMultiTexGenivEXT))load("glGetMultiTexGenivEXT\0".ptr);
	glMultiTexParameteriEXT = cast(typeof(glMultiTexParameteriEXT))load("glMultiTexParameteriEXT\0".ptr);
	glMultiTexParameterivEXT = cast(typeof(glMultiTexParameterivEXT))load("glMultiTexParameterivEXT\0".ptr);
	glMultiTexParameterfEXT = cast(typeof(glMultiTexParameterfEXT))load("glMultiTexParameterfEXT\0".ptr);
	glMultiTexParameterfvEXT = cast(typeof(glMultiTexParameterfvEXT))load("glMultiTexParameterfvEXT\0".ptr);
	glMultiTexImage1DEXT = cast(typeof(glMultiTexImage1DEXT))load("glMultiTexImage1DEXT\0".ptr);
	glMultiTexImage2DEXT = cast(typeof(glMultiTexImage2DEXT))load("glMultiTexImage2DEXT\0".ptr);
	glMultiTexSubImage1DEXT = cast(typeof(glMultiTexSubImage1DEXT))load("glMultiTexSubImage1DEXT\0".ptr);
	glMultiTexSubImage2DEXT = cast(typeof(glMultiTexSubImage2DEXT))load("glMultiTexSubImage2DEXT\0".ptr);
	glCopyMultiTexImage1DEXT = cast(typeof(glCopyMultiTexImage1DEXT))load("glCopyMultiTexImage1DEXT\0".ptr);
	glCopyMultiTexImage2DEXT = cast(typeof(glCopyMultiTexImage2DEXT))load("glCopyMultiTexImage2DEXT\0".ptr);
	glCopyMultiTexSubImage1DEXT = cast(typeof(glCopyMultiTexSubImage1DEXT))load("glCopyMultiTexSubImage1DEXT\0".ptr);
	glCopyMultiTexSubImage2DEXT = cast(typeof(glCopyMultiTexSubImage2DEXT))load("glCopyMultiTexSubImage2DEXT\0".ptr);
	glGetMultiTexImageEXT = cast(typeof(glGetMultiTexImageEXT))load("glGetMultiTexImageEXT\0".ptr);
	glGetMultiTexParameterfvEXT = cast(typeof(glGetMultiTexParameterfvEXT))load("glGetMultiTexParameterfvEXT\0".ptr);
	glGetMultiTexParameterivEXT = cast(typeof(glGetMultiTexParameterivEXT))load("glGetMultiTexParameterivEXT\0".ptr);
	glGetMultiTexLevelParameterfvEXT = cast(typeof(glGetMultiTexLevelParameterfvEXT))load("glGetMultiTexLevelParameterfvEXT\0".ptr);
	glGetMultiTexLevelParameterivEXT = cast(typeof(glGetMultiTexLevelParameterivEXT))load("glGetMultiTexLevelParameterivEXT\0".ptr);
	glMultiTexImage3DEXT = cast(typeof(glMultiTexImage3DEXT))load("glMultiTexImage3DEXT\0".ptr);
	glMultiTexSubImage3DEXT = cast(typeof(glMultiTexSubImage3DEXT))load("glMultiTexSubImage3DEXT\0".ptr);
	glCopyMultiTexSubImage3DEXT = cast(typeof(glCopyMultiTexSubImage3DEXT))load("glCopyMultiTexSubImage3DEXT\0".ptr);
	glEnableClientStateIndexedEXT = cast(typeof(glEnableClientStateIndexedEXT))load("glEnableClientStateIndexedEXT\0".ptr);
	glDisableClientStateIndexedEXT = cast(typeof(glDisableClientStateIndexedEXT))load("glDisableClientStateIndexedEXT\0".ptr);
	glGetFloatIndexedvEXT = cast(typeof(glGetFloatIndexedvEXT))load("glGetFloatIndexedvEXT\0".ptr);
	glGetDoubleIndexedvEXT = cast(typeof(glGetDoubleIndexedvEXT))load("glGetDoubleIndexedvEXT\0".ptr);
	glGetPointerIndexedvEXT = cast(typeof(glGetPointerIndexedvEXT))load("glGetPointerIndexedvEXT\0".ptr);
	glEnableIndexedEXT = cast(typeof(glEnableIndexedEXT))load("glEnableIndexedEXT\0".ptr);
	glDisableIndexedEXT = cast(typeof(glDisableIndexedEXT))load("glDisableIndexedEXT\0".ptr);
	glIsEnabledIndexedEXT = cast(typeof(glIsEnabledIndexedEXT))load("glIsEnabledIndexedEXT\0".ptr);
	glGetIntegerIndexedvEXT = cast(typeof(glGetIntegerIndexedvEXT))load("glGetIntegerIndexedvEXT\0".ptr);
	glGetBooleanIndexedvEXT = cast(typeof(glGetBooleanIndexedvEXT))load("glGetBooleanIndexedvEXT\0".ptr);
	glCompressedTextureImage3DEXT = cast(typeof(glCompressedTextureImage3DEXT))load("glCompressedTextureImage3DEXT\0".ptr);
	glCompressedTextureImage2DEXT = cast(typeof(glCompressedTextureImage2DEXT))load("glCompressedTextureImage2DEXT\0".ptr);
	glCompressedTextureImage1DEXT = cast(typeof(glCompressedTextureImage1DEXT))load("glCompressedTextureImage1DEXT\0".ptr);
	glCompressedTextureSubImage3DEXT = cast(typeof(glCompressedTextureSubImage3DEXT))load("glCompressedTextureSubImage3DEXT\0".ptr);
	glCompressedTextureSubImage2DEXT = cast(typeof(glCompressedTextureSubImage2DEXT))load("glCompressedTextureSubImage2DEXT\0".ptr);
	glCompressedTextureSubImage1DEXT = cast(typeof(glCompressedTextureSubImage1DEXT))load("glCompressedTextureSubImage1DEXT\0".ptr);
	glGetCompressedTextureImageEXT = cast(typeof(glGetCompressedTextureImageEXT))load("glGetCompressedTextureImageEXT\0".ptr);
	glCompressedMultiTexImage3DEXT = cast(typeof(glCompressedMultiTexImage3DEXT))load("glCompressedMultiTexImage3DEXT\0".ptr);
	glCompressedMultiTexImage2DEXT = cast(typeof(glCompressedMultiTexImage2DEXT))load("glCompressedMultiTexImage2DEXT\0".ptr);
	glCompressedMultiTexImage1DEXT = cast(typeof(glCompressedMultiTexImage1DEXT))load("glCompressedMultiTexImage1DEXT\0".ptr);
	glCompressedMultiTexSubImage3DEXT = cast(typeof(glCompressedMultiTexSubImage3DEXT))load("glCompressedMultiTexSubImage3DEXT\0".ptr);
	glCompressedMultiTexSubImage2DEXT = cast(typeof(glCompressedMultiTexSubImage2DEXT))load("glCompressedMultiTexSubImage2DEXT\0".ptr);
	glCompressedMultiTexSubImage1DEXT = cast(typeof(glCompressedMultiTexSubImage1DEXT))load("glCompressedMultiTexSubImage1DEXT\0".ptr);
	glGetCompressedMultiTexImageEXT = cast(typeof(glGetCompressedMultiTexImageEXT))load("glGetCompressedMultiTexImageEXT\0".ptr);
	glMatrixLoadTransposefEXT = cast(typeof(glMatrixLoadTransposefEXT))load("glMatrixLoadTransposefEXT\0".ptr);
	glMatrixLoadTransposedEXT = cast(typeof(glMatrixLoadTransposedEXT))load("glMatrixLoadTransposedEXT\0".ptr);
	glMatrixMultTransposefEXT = cast(typeof(glMatrixMultTransposefEXT))load("glMatrixMultTransposefEXT\0".ptr);
	glMatrixMultTransposedEXT = cast(typeof(glMatrixMultTransposedEXT))load("glMatrixMultTransposedEXT\0".ptr);
	glNamedBufferDataEXT = cast(typeof(glNamedBufferDataEXT))load("glNamedBufferDataEXT\0".ptr);
	glNamedBufferSubDataEXT = cast(typeof(glNamedBufferSubDataEXT))load("glNamedBufferSubDataEXT\0".ptr);
	glMapNamedBufferEXT = cast(typeof(glMapNamedBufferEXT))load("glMapNamedBufferEXT\0".ptr);
	glUnmapNamedBufferEXT = cast(typeof(glUnmapNamedBufferEXT))load("glUnmapNamedBufferEXT\0".ptr);
	glGetNamedBufferParameterivEXT = cast(typeof(glGetNamedBufferParameterivEXT))load("glGetNamedBufferParameterivEXT\0".ptr);
	glGetNamedBufferPointervEXT = cast(typeof(glGetNamedBufferPointervEXT))load("glGetNamedBufferPointervEXT\0".ptr);
	glGetNamedBufferSubDataEXT = cast(typeof(glGetNamedBufferSubDataEXT))load("glGetNamedBufferSubDataEXT\0".ptr);
	glProgramUniform1fEXT = cast(typeof(glProgramUniform1fEXT))load("glProgramUniform1fEXT\0".ptr);
	glProgramUniform2fEXT = cast(typeof(glProgramUniform2fEXT))load("glProgramUniform2fEXT\0".ptr);
	glProgramUniform3fEXT = cast(typeof(glProgramUniform3fEXT))load("glProgramUniform3fEXT\0".ptr);
	glProgramUniform4fEXT = cast(typeof(glProgramUniform4fEXT))load("glProgramUniform4fEXT\0".ptr);
	glProgramUniform1iEXT = cast(typeof(glProgramUniform1iEXT))load("glProgramUniform1iEXT\0".ptr);
	glProgramUniform2iEXT = cast(typeof(glProgramUniform2iEXT))load("glProgramUniform2iEXT\0".ptr);
	glProgramUniform3iEXT = cast(typeof(glProgramUniform3iEXT))load("glProgramUniform3iEXT\0".ptr);
	glProgramUniform4iEXT = cast(typeof(glProgramUniform4iEXT))load("glProgramUniform4iEXT\0".ptr);
	glProgramUniform1fvEXT = cast(typeof(glProgramUniform1fvEXT))load("glProgramUniform1fvEXT\0".ptr);
	glProgramUniform2fvEXT = cast(typeof(glProgramUniform2fvEXT))load("glProgramUniform2fvEXT\0".ptr);
	glProgramUniform3fvEXT = cast(typeof(glProgramUniform3fvEXT))load("glProgramUniform3fvEXT\0".ptr);
	glProgramUniform4fvEXT = cast(typeof(glProgramUniform4fvEXT))load("glProgramUniform4fvEXT\0".ptr);
	glProgramUniform1ivEXT = cast(typeof(glProgramUniform1ivEXT))load("glProgramUniform1ivEXT\0".ptr);
	glProgramUniform2ivEXT = cast(typeof(glProgramUniform2ivEXT))load("glProgramUniform2ivEXT\0".ptr);
	glProgramUniform3ivEXT = cast(typeof(glProgramUniform3ivEXT))load("glProgramUniform3ivEXT\0".ptr);
	glProgramUniform4ivEXT = cast(typeof(glProgramUniform4ivEXT))load("glProgramUniform4ivEXT\0".ptr);
	glProgramUniformMatrix2fvEXT = cast(typeof(glProgramUniformMatrix2fvEXT))load("glProgramUniformMatrix2fvEXT\0".ptr);
	glProgramUniformMatrix3fvEXT = cast(typeof(glProgramUniformMatrix3fvEXT))load("glProgramUniformMatrix3fvEXT\0".ptr);
	glProgramUniformMatrix4fvEXT = cast(typeof(glProgramUniformMatrix4fvEXT))load("glProgramUniformMatrix4fvEXT\0".ptr);
	glProgramUniformMatrix2x3fvEXT = cast(typeof(glProgramUniformMatrix2x3fvEXT))load("glProgramUniformMatrix2x3fvEXT\0".ptr);
	glProgramUniformMatrix3x2fvEXT = cast(typeof(glProgramUniformMatrix3x2fvEXT))load("glProgramUniformMatrix3x2fvEXT\0".ptr);
	glProgramUniformMatrix2x4fvEXT = cast(typeof(glProgramUniformMatrix2x4fvEXT))load("glProgramUniformMatrix2x4fvEXT\0".ptr);
	glProgramUniformMatrix4x2fvEXT = cast(typeof(glProgramUniformMatrix4x2fvEXT))load("glProgramUniformMatrix4x2fvEXT\0".ptr);
	glProgramUniformMatrix3x4fvEXT = cast(typeof(glProgramUniformMatrix3x4fvEXT))load("glProgramUniformMatrix3x4fvEXT\0".ptr);
	glProgramUniformMatrix4x3fvEXT = cast(typeof(glProgramUniformMatrix4x3fvEXT))load("glProgramUniformMatrix4x3fvEXT\0".ptr);
	glTextureBufferEXT = cast(typeof(glTextureBufferEXT))load("glTextureBufferEXT\0".ptr);
	glMultiTexBufferEXT = cast(typeof(glMultiTexBufferEXT))load("glMultiTexBufferEXT\0".ptr);
	glTextureParameterIivEXT = cast(typeof(glTextureParameterIivEXT))load("glTextureParameterIivEXT\0".ptr);
	glTextureParameterIuivEXT = cast(typeof(glTextureParameterIuivEXT))load("glTextureParameterIuivEXT\0".ptr);
	glGetTextureParameterIivEXT = cast(typeof(glGetTextureParameterIivEXT))load("glGetTextureParameterIivEXT\0".ptr);
	glGetTextureParameterIuivEXT = cast(typeof(glGetTextureParameterIuivEXT))load("glGetTextureParameterIuivEXT\0".ptr);
	glMultiTexParameterIivEXT = cast(typeof(glMultiTexParameterIivEXT))load("glMultiTexParameterIivEXT\0".ptr);
	glMultiTexParameterIuivEXT = cast(typeof(glMultiTexParameterIuivEXT))load("glMultiTexParameterIuivEXT\0".ptr);
	glGetMultiTexParameterIivEXT = cast(typeof(glGetMultiTexParameterIivEXT))load("glGetMultiTexParameterIivEXT\0".ptr);
	glGetMultiTexParameterIuivEXT = cast(typeof(glGetMultiTexParameterIuivEXT))load("glGetMultiTexParameterIuivEXT\0".ptr);
	glProgramUniform1uiEXT = cast(typeof(glProgramUniform1uiEXT))load("glProgramUniform1uiEXT\0".ptr);
	glProgramUniform2uiEXT = cast(typeof(glProgramUniform2uiEXT))load("glProgramUniform2uiEXT\0".ptr);
	glProgramUniform3uiEXT = cast(typeof(glProgramUniform3uiEXT))load("glProgramUniform3uiEXT\0".ptr);
	glProgramUniform4uiEXT = cast(typeof(glProgramUniform4uiEXT))load("glProgramUniform4uiEXT\0".ptr);
	glProgramUniform1uivEXT = cast(typeof(glProgramUniform1uivEXT))load("glProgramUniform1uivEXT\0".ptr);
	glProgramUniform2uivEXT = cast(typeof(glProgramUniform2uivEXT))load("glProgramUniform2uivEXT\0".ptr);
	glProgramUniform3uivEXT = cast(typeof(glProgramUniform3uivEXT))load("glProgramUniform3uivEXT\0".ptr);
	glProgramUniform4uivEXT = cast(typeof(glProgramUniform4uivEXT))load("glProgramUniform4uivEXT\0".ptr);
	glNamedProgramLocalParameters4fvEXT = cast(typeof(glNamedProgramLocalParameters4fvEXT))load("glNamedProgramLocalParameters4fvEXT\0".ptr);
	glNamedProgramLocalParameterI4iEXT = cast(typeof(glNamedProgramLocalParameterI4iEXT))load("glNamedProgramLocalParameterI4iEXT\0".ptr);
	glNamedProgramLocalParameterI4ivEXT = cast(typeof(glNamedProgramLocalParameterI4ivEXT))load("glNamedProgramLocalParameterI4ivEXT\0".ptr);
	glNamedProgramLocalParametersI4ivEXT = cast(typeof(glNamedProgramLocalParametersI4ivEXT))load("glNamedProgramLocalParametersI4ivEXT\0".ptr);
	glNamedProgramLocalParameterI4uiEXT = cast(typeof(glNamedProgramLocalParameterI4uiEXT))load("glNamedProgramLocalParameterI4uiEXT\0".ptr);
	glNamedProgramLocalParameterI4uivEXT = cast(typeof(glNamedProgramLocalParameterI4uivEXT))load("glNamedProgramLocalParameterI4uivEXT\0".ptr);
	glNamedProgramLocalParametersI4uivEXT = cast(typeof(glNamedProgramLocalParametersI4uivEXT))load("glNamedProgramLocalParametersI4uivEXT\0".ptr);
	glGetNamedProgramLocalParameterIivEXT = cast(typeof(glGetNamedProgramLocalParameterIivEXT))load("glGetNamedProgramLocalParameterIivEXT\0".ptr);
	glGetNamedProgramLocalParameterIuivEXT = cast(typeof(glGetNamedProgramLocalParameterIuivEXT))load("glGetNamedProgramLocalParameterIuivEXT\0".ptr);
	glEnableClientStateiEXT = cast(typeof(glEnableClientStateiEXT))load("glEnableClientStateiEXT\0".ptr);
	glDisableClientStateiEXT = cast(typeof(glDisableClientStateiEXT))load("glDisableClientStateiEXT\0".ptr);
	glGetFloati_vEXT = cast(typeof(glGetFloati_vEXT))load("glGetFloati_vEXT\0".ptr);
	glGetDoublei_vEXT = cast(typeof(glGetDoublei_vEXT))load("glGetDoublei_vEXT\0".ptr);
	glGetPointeri_vEXT = cast(typeof(glGetPointeri_vEXT))load("glGetPointeri_vEXT\0".ptr);
	glNamedProgramStringEXT = cast(typeof(glNamedProgramStringEXT))load("glNamedProgramStringEXT\0".ptr);
	glNamedProgramLocalParameter4dEXT = cast(typeof(glNamedProgramLocalParameter4dEXT))load("glNamedProgramLocalParameter4dEXT\0".ptr);
	glNamedProgramLocalParameter4dvEXT = cast(typeof(glNamedProgramLocalParameter4dvEXT))load("glNamedProgramLocalParameter4dvEXT\0".ptr);
	glNamedProgramLocalParameter4fEXT = cast(typeof(glNamedProgramLocalParameter4fEXT))load("glNamedProgramLocalParameter4fEXT\0".ptr);
	glNamedProgramLocalParameter4fvEXT = cast(typeof(glNamedProgramLocalParameter4fvEXT))load("glNamedProgramLocalParameter4fvEXT\0".ptr);
	glGetNamedProgramLocalParameterdvEXT = cast(typeof(glGetNamedProgramLocalParameterdvEXT))load("glGetNamedProgramLocalParameterdvEXT\0".ptr);
	glGetNamedProgramLocalParameterfvEXT = cast(typeof(glGetNamedProgramLocalParameterfvEXT))load("glGetNamedProgramLocalParameterfvEXT\0".ptr);
	glGetNamedProgramivEXT = cast(typeof(glGetNamedProgramivEXT))load("glGetNamedProgramivEXT\0".ptr);
	glGetNamedProgramStringEXT = cast(typeof(glGetNamedProgramStringEXT))load("glGetNamedProgramStringEXT\0".ptr);
	glNamedRenderbufferStorageEXT = cast(typeof(glNamedRenderbufferStorageEXT))load("glNamedRenderbufferStorageEXT\0".ptr);
	glGetNamedRenderbufferParameterivEXT = cast(typeof(glGetNamedRenderbufferParameterivEXT))load("glGetNamedRenderbufferParameterivEXT\0".ptr);
	glNamedRenderbufferStorageMultisampleEXT = cast(typeof(glNamedRenderbufferStorageMultisampleEXT))load("glNamedRenderbufferStorageMultisampleEXT\0".ptr);
	glNamedRenderbufferStorageMultisampleCoverageEXT = cast(typeof(glNamedRenderbufferStorageMultisampleCoverageEXT))load("glNamedRenderbufferStorageMultisampleCoverageEXT\0".ptr);
	glCheckNamedFramebufferStatusEXT = cast(typeof(glCheckNamedFramebufferStatusEXT))load("glCheckNamedFramebufferStatusEXT\0".ptr);
	glNamedFramebufferTexture1DEXT = cast(typeof(glNamedFramebufferTexture1DEXT))load("glNamedFramebufferTexture1DEXT\0".ptr);
	glNamedFramebufferTexture2DEXT = cast(typeof(glNamedFramebufferTexture2DEXT))load("glNamedFramebufferTexture2DEXT\0".ptr);
	glNamedFramebufferTexture3DEXT = cast(typeof(glNamedFramebufferTexture3DEXT))load("glNamedFramebufferTexture3DEXT\0".ptr);
	glNamedFramebufferRenderbufferEXT = cast(typeof(glNamedFramebufferRenderbufferEXT))load("glNamedFramebufferRenderbufferEXT\0".ptr);
	glGetNamedFramebufferAttachmentParameterivEXT = cast(typeof(glGetNamedFramebufferAttachmentParameterivEXT))load("glGetNamedFramebufferAttachmentParameterivEXT\0".ptr);
	glGenerateTextureMipmapEXT = cast(typeof(glGenerateTextureMipmapEXT))load("glGenerateTextureMipmapEXT\0".ptr);
	glGenerateMultiTexMipmapEXT = cast(typeof(glGenerateMultiTexMipmapEXT))load("glGenerateMultiTexMipmapEXT\0".ptr);
	glFramebufferDrawBufferEXT = cast(typeof(glFramebufferDrawBufferEXT))load("glFramebufferDrawBufferEXT\0".ptr);
	glFramebufferDrawBuffersEXT = cast(typeof(glFramebufferDrawBuffersEXT))load("glFramebufferDrawBuffersEXT\0".ptr);
	glFramebufferReadBufferEXT = cast(typeof(glFramebufferReadBufferEXT))load("glFramebufferReadBufferEXT\0".ptr);
	glGetFramebufferParameterivEXT = cast(typeof(glGetFramebufferParameterivEXT))load("glGetFramebufferParameterivEXT\0".ptr);
	glNamedCopyBufferSubDataEXT = cast(typeof(glNamedCopyBufferSubDataEXT))load("glNamedCopyBufferSubDataEXT\0".ptr);
	glNamedFramebufferTextureEXT = cast(typeof(glNamedFramebufferTextureEXT))load("glNamedFramebufferTextureEXT\0".ptr);
	glNamedFramebufferTextureLayerEXT = cast(typeof(glNamedFramebufferTextureLayerEXT))load("glNamedFramebufferTextureLayerEXT\0".ptr);
	glNamedFramebufferTextureFaceEXT = cast(typeof(glNamedFramebufferTextureFaceEXT))load("glNamedFramebufferTextureFaceEXT\0".ptr);
	glTextureRenderbufferEXT = cast(typeof(glTextureRenderbufferEXT))load("glTextureRenderbufferEXT\0".ptr);
	glMultiTexRenderbufferEXT = cast(typeof(glMultiTexRenderbufferEXT))load("glMultiTexRenderbufferEXT\0".ptr);
	glVertexArrayVertexOffsetEXT = cast(typeof(glVertexArrayVertexOffsetEXT))load("glVertexArrayVertexOffsetEXT\0".ptr);
	glVertexArrayColorOffsetEXT = cast(typeof(glVertexArrayColorOffsetEXT))load("glVertexArrayColorOffsetEXT\0".ptr);
	glVertexArrayEdgeFlagOffsetEXT = cast(typeof(glVertexArrayEdgeFlagOffsetEXT))load("glVertexArrayEdgeFlagOffsetEXT\0".ptr);
	glVertexArrayIndexOffsetEXT = cast(typeof(glVertexArrayIndexOffsetEXT))load("glVertexArrayIndexOffsetEXT\0".ptr);
	glVertexArrayNormalOffsetEXT = cast(typeof(glVertexArrayNormalOffsetEXT))load("glVertexArrayNormalOffsetEXT\0".ptr);
	glVertexArrayTexCoordOffsetEXT = cast(typeof(glVertexArrayTexCoordOffsetEXT))load("glVertexArrayTexCoordOffsetEXT\0".ptr);
	glVertexArrayMultiTexCoordOffsetEXT = cast(typeof(glVertexArrayMultiTexCoordOffsetEXT))load("glVertexArrayMultiTexCoordOffsetEXT\0".ptr);
	glVertexArrayFogCoordOffsetEXT = cast(typeof(glVertexArrayFogCoordOffsetEXT))load("glVertexArrayFogCoordOffsetEXT\0".ptr);
	glVertexArraySecondaryColorOffsetEXT = cast(typeof(glVertexArraySecondaryColorOffsetEXT))load("glVertexArraySecondaryColorOffsetEXT\0".ptr);
	glVertexArrayVertexAttribOffsetEXT = cast(typeof(glVertexArrayVertexAttribOffsetEXT))load("glVertexArrayVertexAttribOffsetEXT\0".ptr);
	glVertexArrayVertexAttribIOffsetEXT = cast(typeof(glVertexArrayVertexAttribIOffsetEXT))load("glVertexArrayVertexAttribIOffsetEXT\0".ptr);
	glEnableVertexArrayEXT = cast(typeof(glEnableVertexArrayEXT))load("glEnableVertexArrayEXT\0".ptr);
	glDisableVertexArrayEXT = cast(typeof(glDisableVertexArrayEXT))load("glDisableVertexArrayEXT\0".ptr);
	glEnableVertexArrayAttribEXT = cast(typeof(glEnableVertexArrayAttribEXT))load("glEnableVertexArrayAttribEXT\0".ptr);
	glDisableVertexArrayAttribEXT = cast(typeof(glDisableVertexArrayAttribEXT))load("glDisableVertexArrayAttribEXT\0".ptr);
	glGetVertexArrayIntegervEXT = cast(typeof(glGetVertexArrayIntegervEXT))load("glGetVertexArrayIntegervEXT\0".ptr);
	glGetVertexArrayPointervEXT = cast(typeof(glGetVertexArrayPointervEXT))load("glGetVertexArrayPointervEXT\0".ptr);
	glGetVertexArrayIntegeri_vEXT = cast(typeof(glGetVertexArrayIntegeri_vEXT))load("glGetVertexArrayIntegeri_vEXT\0".ptr);
	glGetVertexArrayPointeri_vEXT = cast(typeof(glGetVertexArrayPointeri_vEXT))load("glGetVertexArrayPointeri_vEXT\0".ptr);
	glMapNamedBufferRangeEXT = cast(typeof(glMapNamedBufferRangeEXT))load("glMapNamedBufferRangeEXT\0".ptr);
	glFlushMappedNamedBufferRangeEXT = cast(typeof(glFlushMappedNamedBufferRangeEXT))load("glFlushMappedNamedBufferRangeEXT\0".ptr);
	glClearNamedBufferDataEXT = cast(typeof(glClearNamedBufferDataEXT))load("glClearNamedBufferDataEXT\0".ptr);
	glClearNamedBufferSubDataEXT = cast(typeof(glClearNamedBufferSubDataEXT))load("glClearNamedBufferSubDataEXT\0".ptr);
	glNamedFramebufferParameteriEXT = cast(typeof(glNamedFramebufferParameteriEXT))load("glNamedFramebufferParameteriEXT\0".ptr);
	glGetNamedFramebufferParameterivEXT = cast(typeof(glGetNamedFramebufferParameterivEXT))load("glGetNamedFramebufferParameterivEXT\0".ptr);
	glProgramUniform1dEXT = cast(typeof(glProgramUniform1dEXT))load("glProgramUniform1dEXT\0".ptr);
	glProgramUniform2dEXT = cast(typeof(glProgramUniform2dEXT))load("glProgramUniform2dEXT\0".ptr);
	glProgramUniform3dEXT = cast(typeof(glProgramUniform3dEXT))load("glProgramUniform3dEXT\0".ptr);
	glProgramUniform4dEXT = cast(typeof(glProgramUniform4dEXT))load("glProgramUniform4dEXT\0".ptr);
	glProgramUniform1dvEXT = cast(typeof(glProgramUniform1dvEXT))load("glProgramUniform1dvEXT\0".ptr);
	glProgramUniform2dvEXT = cast(typeof(glProgramUniform2dvEXT))load("glProgramUniform2dvEXT\0".ptr);
	glProgramUniform3dvEXT = cast(typeof(glProgramUniform3dvEXT))load("glProgramUniform3dvEXT\0".ptr);
	glProgramUniform4dvEXT = cast(typeof(glProgramUniform4dvEXT))load("glProgramUniform4dvEXT\0".ptr);
	glProgramUniformMatrix2dvEXT = cast(typeof(glProgramUniformMatrix2dvEXT))load("glProgramUniformMatrix2dvEXT\0".ptr);
	glProgramUniformMatrix3dvEXT = cast(typeof(glProgramUniformMatrix3dvEXT))load("glProgramUniformMatrix3dvEXT\0".ptr);
	glProgramUniformMatrix4dvEXT = cast(typeof(glProgramUniformMatrix4dvEXT))load("glProgramUniformMatrix4dvEXT\0".ptr);
	glProgramUniformMatrix2x3dvEXT = cast(typeof(glProgramUniformMatrix2x3dvEXT))load("glProgramUniformMatrix2x3dvEXT\0".ptr);
	glProgramUniformMatrix2x4dvEXT = cast(typeof(glProgramUniformMatrix2x4dvEXT))load("glProgramUniformMatrix2x4dvEXT\0".ptr);
	glProgramUniformMatrix3x2dvEXT = cast(typeof(glProgramUniformMatrix3x2dvEXT))load("glProgramUniformMatrix3x2dvEXT\0".ptr);
	glProgramUniformMatrix3x4dvEXT = cast(typeof(glProgramUniformMatrix3x4dvEXT))load("glProgramUniformMatrix3x4dvEXT\0".ptr);
	glProgramUniformMatrix4x2dvEXT = cast(typeof(glProgramUniformMatrix4x2dvEXT))load("glProgramUniformMatrix4x2dvEXT\0".ptr);
	glProgramUniformMatrix4x3dvEXT = cast(typeof(glProgramUniformMatrix4x3dvEXT))load("glProgramUniformMatrix4x3dvEXT\0".ptr);
	glTextureBufferRangeEXT = cast(typeof(glTextureBufferRangeEXT))load("glTextureBufferRangeEXT\0".ptr);
	glTextureStorage1DEXT = cast(typeof(glTextureStorage1DEXT))load("glTextureStorage1DEXT\0".ptr);
	glTextureStorage2DEXT = cast(typeof(glTextureStorage2DEXT))load("glTextureStorage2DEXT\0".ptr);
	glTextureStorage3DEXT = cast(typeof(glTextureStorage3DEXT))load("glTextureStorage3DEXT\0".ptr);
	glTextureStorage2DMultisampleEXT = cast(typeof(glTextureStorage2DMultisampleEXT))load("glTextureStorage2DMultisampleEXT\0".ptr);
	glTextureStorage3DMultisampleEXT = cast(typeof(glTextureStorage3DMultisampleEXT))load("glTextureStorage3DMultisampleEXT\0".ptr);
	glVertexArrayBindVertexBufferEXT = cast(typeof(glVertexArrayBindVertexBufferEXT))load("glVertexArrayBindVertexBufferEXT\0".ptr);
	glVertexArrayVertexAttribFormatEXT = cast(typeof(glVertexArrayVertexAttribFormatEXT))load("glVertexArrayVertexAttribFormatEXT\0".ptr);
	glVertexArrayVertexAttribIFormatEXT = cast(typeof(glVertexArrayVertexAttribIFormatEXT))load("glVertexArrayVertexAttribIFormatEXT\0".ptr);
	glVertexArrayVertexAttribLFormatEXT = cast(typeof(glVertexArrayVertexAttribLFormatEXT))load("glVertexArrayVertexAttribLFormatEXT\0".ptr);
	glVertexArrayVertexAttribBindingEXT = cast(typeof(glVertexArrayVertexAttribBindingEXT))load("glVertexArrayVertexAttribBindingEXT\0".ptr);
	glVertexArrayVertexBindingDivisorEXT = cast(typeof(glVertexArrayVertexBindingDivisorEXT))load("glVertexArrayVertexBindingDivisorEXT\0".ptr);
	glVertexArrayVertexAttribLOffsetEXT = cast(typeof(glVertexArrayVertexAttribLOffsetEXT))load("glVertexArrayVertexAttribLOffsetEXT\0".ptr);
	glTexturePageCommitmentEXT = cast(typeof(glTexturePageCommitmentEXT))load("glTexturePageCommitmentEXT\0".ptr);
	return GL_EXT_direct_state_access;
}


bool load_gl_GL_AMD_sample_positions(void* function(const(char)* name) load) {
	if(!GL_AMD_sample_positions) return GL_AMD_sample_positions;

	glSetMultisamplefvAMD = cast(typeof(glSetMultisamplefvAMD))load("glSetMultisamplefvAMD\0".ptr);
	return GL_AMD_sample_positions;
}


bool load_gl_GL_NV_vertex_program(void* function(const(char)* name) load) {
	if(!GL_NV_vertex_program) return GL_NV_vertex_program;

	glAreProgramsResidentNV = cast(typeof(glAreProgramsResidentNV))load("glAreProgramsResidentNV\0".ptr);
	glBindProgramNV = cast(typeof(glBindProgramNV))load("glBindProgramNV\0".ptr);
	glDeleteProgramsNV = cast(typeof(glDeleteProgramsNV))load("glDeleteProgramsNV\0".ptr);
	glExecuteProgramNV = cast(typeof(glExecuteProgramNV))load("glExecuteProgramNV\0".ptr);
	glGenProgramsNV = cast(typeof(glGenProgramsNV))load("glGenProgramsNV\0".ptr);
	glGetProgramParameterdvNV = cast(typeof(glGetProgramParameterdvNV))load("glGetProgramParameterdvNV\0".ptr);
	glGetProgramParameterfvNV = cast(typeof(glGetProgramParameterfvNV))load("glGetProgramParameterfvNV\0".ptr);
	glGetProgramivNV = cast(typeof(glGetProgramivNV))load("glGetProgramivNV\0".ptr);
	glGetProgramStringNV = cast(typeof(glGetProgramStringNV))load("glGetProgramStringNV\0".ptr);
	glGetTrackMatrixivNV = cast(typeof(glGetTrackMatrixivNV))load("glGetTrackMatrixivNV\0".ptr);
	glGetVertexAttribdvNV = cast(typeof(glGetVertexAttribdvNV))load("glGetVertexAttribdvNV\0".ptr);
	glGetVertexAttribfvNV = cast(typeof(glGetVertexAttribfvNV))load("glGetVertexAttribfvNV\0".ptr);
	glGetVertexAttribivNV = cast(typeof(glGetVertexAttribivNV))load("glGetVertexAttribivNV\0".ptr);
	glGetVertexAttribPointervNV = cast(typeof(glGetVertexAttribPointervNV))load("glGetVertexAttribPointervNV\0".ptr);
	glIsProgramNV = cast(typeof(glIsProgramNV))load("glIsProgramNV\0".ptr);
	glLoadProgramNV = cast(typeof(glLoadProgramNV))load("glLoadProgramNV\0".ptr);
	glProgramParameter4dNV = cast(typeof(glProgramParameter4dNV))load("glProgramParameter4dNV\0".ptr);
	glProgramParameter4dvNV = cast(typeof(glProgramParameter4dvNV))load("glProgramParameter4dvNV\0".ptr);
	glProgramParameter4fNV = cast(typeof(glProgramParameter4fNV))load("glProgramParameter4fNV\0".ptr);
	glProgramParameter4fvNV = cast(typeof(glProgramParameter4fvNV))load("glProgramParameter4fvNV\0".ptr);
	glProgramParameters4dvNV = cast(typeof(glProgramParameters4dvNV))load("glProgramParameters4dvNV\0".ptr);
	glProgramParameters4fvNV = cast(typeof(glProgramParameters4fvNV))load("glProgramParameters4fvNV\0".ptr);
	glRequestResidentProgramsNV = cast(typeof(glRequestResidentProgramsNV))load("glRequestResidentProgramsNV\0".ptr);
	glTrackMatrixNV = cast(typeof(glTrackMatrixNV))load("glTrackMatrixNV\0".ptr);
	glVertexAttribPointerNV = cast(typeof(glVertexAttribPointerNV))load("glVertexAttribPointerNV\0".ptr);
	glVertexAttrib1dNV = cast(typeof(glVertexAttrib1dNV))load("glVertexAttrib1dNV\0".ptr);
	glVertexAttrib1dvNV = cast(typeof(glVertexAttrib1dvNV))load("glVertexAttrib1dvNV\0".ptr);
	glVertexAttrib1fNV = cast(typeof(glVertexAttrib1fNV))load("glVertexAttrib1fNV\0".ptr);
	glVertexAttrib1fvNV = cast(typeof(glVertexAttrib1fvNV))load("glVertexAttrib1fvNV\0".ptr);
	glVertexAttrib1sNV = cast(typeof(glVertexAttrib1sNV))load("glVertexAttrib1sNV\0".ptr);
	glVertexAttrib1svNV = cast(typeof(glVertexAttrib1svNV))load("glVertexAttrib1svNV\0".ptr);
	glVertexAttrib2dNV = cast(typeof(glVertexAttrib2dNV))load("glVertexAttrib2dNV\0".ptr);
	glVertexAttrib2dvNV = cast(typeof(glVertexAttrib2dvNV))load("glVertexAttrib2dvNV\0".ptr);
	glVertexAttrib2fNV = cast(typeof(glVertexAttrib2fNV))load("glVertexAttrib2fNV\0".ptr);
	glVertexAttrib2fvNV = cast(typeof(glVertexAttrib2fvNV))load("glVertexAttrib2fvNV\0".ptr);
	glVertexAttrib2sNV = cast(typeof(glVertexAttrib2sNV))load("glVertexAttrib2sNV\0".ptr);
	glVertexAttrib2svNV = cast(typeof(glVertexAttrib2svNV))load("glVertexAttrib2svNV\0".ptr);
	glVertexAttrib3dNV = cast(typeof(glVertexAttrib3dNV))load("glVertexAttrib3dNV\0".ptr);
	glVertexAttrib3dvNV = cast(typeof(glVertexAttrib3dvNV))load("glVertexAttrib3dvNV\0".ptr);
	glVertexAttrib3fNV = cast(typeof(glVertexAttrib3fNV))load("glVertexAttrib3fNV\0".ptr);
	glVertexAttrib3fvNV = cast(typeof(glVertexAttrib3fvNV))load("glVertexAttrib3fvNV\0".ptr);
	glVertexAttrib3sNV = cast(typeof(glVertexAttrib3sNV))load("glVertexAttrib3sNV\0".ptr);
	glVertexAttrib3svNV = cast(typeof(glVertexAttrib3svNV))load("glVertexAttrib3svNV\0".ptr);
	glVertexAttrib4dNV = cast(typeof(glVertexAttrib4dNV))load("glVertexAttrib4dNV\0".ptr);
	glVertexAttrib4dvNV = cast(typeof(glVertexAttrib4dvNV))load("glVertexAttrib4dvNV\0".ptr);
	glVertexAttrib4fNV = cast(typeof(glVertexAttrib4fNV))load("glVertexAttrib4fNV\0".ptr);
	glVertexAttrib4fvNV = cast(typeof(glVertexAttrib4fvNV))load("glVertexAttrib4fvNV\0".ptr);
	glVertexAttrib4sNV = cast(typeof(glVertexAttrib4sNV))load("glVertexAttrib4sNV\0".ptr);
	glVertexAttrib4svNV = cast(typeof(glVertexAttrib4svNV))load("glVertexAttrib4svNV\0".ptr);
	glVertexAttrib4ubNV = cast(typeof(glVertexAttrib4ubNV))load("glVertexAttrib4ubNV\0".ptr);
	glVertexAttrib4ubvNV = cast(typeof(glVertexAttrib4ubvNV))load("glVertexAttrib4ubvNV\0".ptr);
	glVertexAttribs1dvNV = cast(typeof(glVertexAttribs1dvNV))load("glVertexAttribs1dvNV\0".ptr);
	glVertexAttribs1fvNV = cast(typeof(glVertexAttribs1fvNV))load("glVertexAttribs1fvNV\0".ptr);
	glVertexAttribs1svNV = cast(typeof(glVertexAttribs1svNV))load("glVertexAttribs1svNV\0".ptr);
	glVertexAttribs2dvNV = cast(typeof(glVertexAttribs2dvNV))load("glVertexAttribs2dvNV\0".ptr);
	glVertexAttribs2fvNV = cast(typeof(glVertexAttribs2fvNV))load("glVertexAttribs2fvNV\0".ptr);
	glVertexAttribs2svNV = cast(typeof(glVertexAttribs2svNV))load("glVertexAttribs2svNV\0".ptr);
	glVertexAttribs3dvNV = cast(typeof(glVertexAttribs3dvNV))load("glVertexAttribs3dvNV\0".ptr);
	glVertexAttribs3fvNV = cast(typeof(glVertexAttribs3fvNV))load("glVertexAttribs3fvNV\0".ptr);
	glVertexAttribs3svNV = cast(typeof(glVertexAttribs3svNV))load("glVertexAttribs3svNV\0".ptr);
	glVertexAttribs4dvNV = cast(typeof(glVertexAttribs4dvNV))load("glVertexAttribs4dvNV\0".ptr);
	glVertexAttribs4fvNV = cast(typeof(glVertexAttribs4fvNV))load("glVertexAttribs4fvNV\0".ptr);
	glVertexAttribs4svNV = cast(typeof(glVertexAttribs4svNV))load("glVertexAttribs4svNV\0".ptr);
	glVertexAttribs4ubvNV = cast(typeof(glVertexAttribs4ubvNV))load("glVertexAttribs4ubvNV\0".ptr);
	return GL_NV_vertex_program;
}


bool load_gl_GL_NVX_conditional_render(void* function(const(char)* name) load) {
	if(!GL_NVX_conditional_render) return GL_NVX_conditional_render;

	glBeginConditionalRenderNVX = cast(typeof(glBeginConditionalRenderNVX))load("glBeginConditionalRenderNVX\0".ptr);
	glEndConditionalRenderNVX = cast(typeof(glEndConditionalRenderNVX))load("glEndConditionalRenderNVX\0".ptr);
	return GL_NVX_conditional_render;
}


bool load_gl_GL_EXT_vertex_shader(void* function(const(char)* name) load) {
	if(!GL_EXT_vertex_shader) return GL_EXT_vertex_shader;

	glBeginVertexShaderEXT = cast(typeof(glBeginVertexShaderEXT))load("glBeginVertexShaderEXT\0".ptr);
	glEndVertexShaderEXT = cast(typeof(glEndVertexShaderEXT))load("glEndVertexShaderEXT\0".ptr);
	glBindVertexShaderEXT = cast(typeof(glBindVertexShaderEXT))load("glBindVertexShaderEXT\0".ptr);
	glGenVertexShadersEXT = cast(typeof(glGenVertexShadersEXT))load("glGenVertexShadersEXT\0".ptr);
	glDeleteVertexShaderEXT = cast(typeof(glDeleteVertexShaderEXT))load("glDeleteVertexShaderEXT\0".ptr);
	glShaderOp1EXT = cast(typeof(glShaderOp1EXT))load("glShaderOp1EXT\0".ptr);
	glShaderOp2EXT = cast(typeof(glShaderOp2EXT))load("glShaderOp2EXT\0".ptr);
	glShaderOp3EXT = cast(typeof(glShaderOp3EXT))load("glShaderOp3EXT\0".ptr);
	glSwizzleEXT = cast(typeof(glSwizzleEXT))load("glSwizzleEXT\0".ptr);
	glWriteMaskEXT = cast(typeof(glWriteMaskEXT))load("glWriteMaskEXT\0".ptr);
	glInsertComponentEXT = cast(typeof(glInsertComponentEXT))load("glInsertComponentEXT\0".ptr);
	glExtractComponentEXT = cast(typeof(glExtractComponentEXT))load("glExtractComponentEXT\0".ptr);
	glGenSymbolsEXT = cast(typeof(glGenSymbolsEXT))load("glGenSymbolsEXT\0".ptr);
	glSetInvariantEXT = cast(typeof(glSetInvariantEXT))load("glSetInvariantEXT\0".ptr);
	glSetLocalConstantEXT = cast(typeof(glSetLocalConstantEXT))load("glSetLocalConstantEXT\0".ptr);
	glVariantbvEXT = cast(typeof(glVariantbvEXT))load("glVariantbvEXT\0".ptr);
	glVariantsvEXT = cast(typeof(glVariantsvEXT))load("glVariantsvEXT\0".ptr);
	glVariantivEXT = cast(typeof(glVariantivEXT))load("glVariantivEXT\0".ptr);
	glVariantfvEXT = cast(typeof(glVariantfvEXT))load("glVariantfvEXT\0".ptr);
	glVariantdvEXT = cast(typeof(glVariantdvEXT))load("glVariantdvEXT\0".ptr);
	glVariantubvEXT = cast(typeof(glVariantubvEXT))load("glVariantubvEXT\0".ptr);
	glVariantusvEXT = cast(typeof(glVariantusvEXT))load("glVariantusvEXT\0".ptr);
	glVariantuivEXT = cast(typeof(glVariantuivEXT))load("glVariantuivEXT\0".ptr);
	glVariantPointerEXT = cast(typeof(glVariantPointerEXT))load("glVariantPointerEXT\0".ptr);
	glEnableVariantClientStateEXT = cast(typeof(glEnableVariantClientStateEXT))load("glEnableVariantClientStateEXT\0".ptr);
	glDisableVariantClientStateEXT = cast(typeof(glDisableVariantClientStateEXT))load("glDisableVariantClientStateEXT\0".ptr);
	glBindLightParameterEXT = cast(typeof(glBindLightParameterEXT))load("glBindLightParameterEXT\0".ptr);
	glBindMaterialParameterEXT = cast(typeof(glBindMaterialParameterEXT))load("glBindMaterialParameterEXT\0".ptr);
	glBindTexGenParameterEXT = cast(typeof(glBindTexGenParameterEXT))load("glBindTexGenParameterEXT\0".ptr);
	glBindTextureUnitParameterEXT = cast(typeof(glBindTextureUnitParameterEXT))load("glBindTextureUnitParameterEXT\0".ptr);
	glBindParameterEXT = cast(typeof(glBindParameterEXT))load("glBindParameterEXT\0".ptr);
	glIsVariantEnabledEXT = cast(typeof(glIsVariantEnabledEXT))load("glIsVariantEnabledEXT\0".ptr);
	glGetVariantBooleanvEXT = cast(typeof(glGetVariantBooleanvEXT))load("glGetVariantBooleanvEXT\0".ptr);
	glGetVariantIntegervEXT = cast(typeof(glGetVariantIntegervEXT))load("glGetVariantIntegervEXT\0".ptr);
	glGetVariantFloatvEXT = cast(typeof(glGetVariantFloatvEXT))load("glGetVariantFloatvEXT\0".ptr);
	glGetVariantPointervEXT = cast(typeof(glGetVariantPointervEXT))load("glGetVariantPointervEXT\0".ptr);
	glGetInvariantBooleanvEXT = cast(typeof(glGetInvariantBooleanvEXT))load("glGetInvariantBooleanvEXT\0".ptr);
	glGetInvariantIntegervEXT = cast(typeof(glGetInvariantIntegervEXT))load("glGetInvariantIntegervEXT\0".ptr);
	glGetInvariantFloatvEXT = cast(typeof(glGetInvariantFloatvEXT))load("glGetInvariantFloatvEXT\0".ptr);
	glGetLocalConstantBooleanvEXT = cast(typeof(glGetLocalConstantBooleanvEXT))load("glGetLocalConstantBooleanvEXT\0".ptr);
	glGetLocalConstantIntegervEXT = cast(typeof(glGetLocalConstantIntegervEXT))load("glGetLocalConstantIntegervEXT\0".ptr);
	glGetLocalConstantFloatvEXT = cast(typeof(glGetLocalConstantFloatvEXT))load("glGetLocalConstantFloatvEXT\0".ptr);
	return GL_EXT_vertex_shader;
}


bool load_gl_GL_EXT_blend_func_separate(void* function(const(char)* name) load) {
	if(!GL_EXT_blend_func_separate) return GL_EXT_blend_func_separate;

	glBlendFuncSeparateEXT = cast(typeof(glBlendFuncSeparateEXT))load("glBlendFuncSeparateEXT\0".ptr);
	return GL_EXT_blend_func_separate;
}


bool load_gl_GL_APPLE_fence(void* function(const(char)* name) load) {
	if(!GL_APPLE_fence) return GL_APPLE_fence;

	glGenFencesAPPLE = cast(typeof(glGenFencesAPPLE))load("glGenFencesAPPLE\0".ptr);
	glDeleteFencesAPPLE = cast(typeof(glDeleteFencesAPPLE))load("glDeleteFencesAPPLE\0".ptr);
	glSetFenceAPPLE = cast(typeof(glSetFenceAPPLE))load("glSetFenceAPPLE\0".ptr);
	glIsFenceAPPLE = cast(typeof(glIsFenceAPPLE))load("glIsFenceAPPLE\0".ptr);
	glTestFenceAPPLE = cast(typeof(glTestFenceAPPLE))load("glTestFenceAPPLE\0".ptr);
	glFinishFenceAPPLE = cast(typeof(glFinishFenceAPPLE))load("glFinishFenceAPPLE\0".ptr);
	glTestObjectAPPLE = cast(typeof(glTestObjectAPPLE))load("glTestObjectAPPLE\0".ptr);
	glFinishObjectAPPLE = cast(typeof(glFinishObjectAPPLE))load("glFinishObjectAPPLE\0".ptr);
	return GL_APPLE_fence;
}


bool load_gl_GL_OES_byte_coordinates(void* function(const(char)* name) load) {
	if(!GL_OES_byte_coordinates) return GL_OES_byte_coordinates;

	glMultiTexCoord1bOES = cast(typeof(glMultiTexCoord1bOES))load("glMultiTexCoord1bOES\0".ptr);
	glMultiTexCoord1bvOES = cast(typeof(glMultiTexCoord1bvOES))load("glMultiTexCoord1bvOES\0".ptr);
	glMultiTexCoord2bOES = cast(typeof(glMultiTexCoord2bOES))load("glMultiTexCoord2bOES\0".ptr);
	glMultiTexCoord2bvOES = cast(typeof(glMultiTexCoord2bvOES))load("glMultiTexCoord2bvOES\0".ptr);
	glMultiTexCoord3bOES = cast(typeof(glMultiTexCoord3bOES))load("glMultiTexCoord3bOES\0".ptr);
	glMultiTexCoord3bvOES = cast(typeof(glMultiTexCoord3bvOES))load("glMultiTexCoord3bvOES\0".ptr);
	glMultiTexCoord4bOES = cast(typeof(glMultiTexCoord4bOES))load("glMultiTexCoord4bOES\0".ptr);
	glMultiTexCoord4bvOES = cast(typeof(glMultiTexCoord4bvOES))load("glMultiTexCoord4bvOES\0".ptr);
	glTexCoord1bOES = cast(typeof(glTexCoord1bOES))load("glTexCoord1bOES\0".ptr);
	glTexCoord1bvOES = cast(typeof(glTexCoord1bvOES))load("glTexCoord1bvOES\0".ptr);
	glTexCoord2bOES = cast(typeof(glTexCoord2bOES))load("glTexCoord2bOES\0".ptr);
	glTexCoord2bvOES = cast(typeof(glTexCoord2bvOES))load("glTexCoord2bvOES\0".ptr);
	glTexCoord3bOES = cast(typeof(glTexCoord3bOES))load("glTexCoord3bOES\0".ptr);
	glTexCoord3bvOES = cast(typeof(glTexCoord3bvOES))load("glTexCoord3bvOES\0".ptr);
	glTexCoord4bOES = cast(typeof(glTexCoord4bOES))load("glTexCoord4bOES\0".ptr);
	glTexCoord4bvOES = cast(typeof(glTexCoord4bvOES))load("glTexCoord4bvOES\0".ptr);
	glVertex2bOES = cast(typeof(glVertex2bOES))load("glVertex2bOES\0".ptr);
	glVertex2bvOES = cast(typeof(glVertex2bvOES))load("glVertex2bvOES\0".ptr);
	glVertex3bOES = cast(typeof(glVertex3bOES))load("glVertex3bOES\0".ptr);
	glVertex3bvOES = cast(typeof(glVertex3bvOES))load("glVertex3bvOES\0".ptr);
	glVertex4bOES = cast(typeof(glVertex4bOES))load("glVertex4bOES\0".ptr);
	glVertex4bvOES = cast(typeof(glVertex4bvOES))load("glVertex4bvOES\0".ptr);
	return GL_OES_byte_coordinates;
}


bool load_gl_GL_ARB_transpose_matrix(void* function(const(char)* name) load) {
	if(!GL_ARB_transpose_matrix) return GL_ARB_transpose_matrix;

	glLoadTransposeMatrixfARB = cast(typeof(glLoadTransposeMatrixfARB))load("glLoadTransposeMatrixfARB\0".ptr);
	glLoadTransposeMatrixdARB = cast(typeof(glLoadTransposeMatrixdARB))load("glLoadTransposeMatrixdARB\0".ptr);
	glMultTransposeMatrixfARB = cast(typeof(glMultTransposeMatrixfARB))load("glMultTransposeMatrixfARB\0".ptr);
	glMultTransposeMatrixdARB = cast(typeof(glMultTransposeMatrixdARB))load("glMultTransposeMatrixdARB\0".ptr);
	return GL_ARB_transpose_matrix;
}


bool load_gl_GL_ARB_provoking_vertex(void* function(const(char)* name) load) {
	if(!GL_ARB_provoking_vertex) return GL_ARB_provoking_vertex;

	glProvokingVertex = cast(typeof(glProvokingVertex))load("glProvokingVertex\0".ptr);
	return GL_ARB_provoking_vertex;
}


bool load_gl_GL_EXT_fog_coord(void* function(const(char)* name) load) {
	if(!GL_EXT_fog_coord) return GL_EXT_fog_coord;

	glFogCoordfEXT = cast(typeof(glFogCoordfEXT))load("glFogCoordfEXT\0".ptr);
	glFogCoordfvEXT = cast(typeof(glFogCoordfvEXT))load("glFogCoordfvEXT\0".ptr);
	glFogCoorddEXT = cast(typeof(glFogCoorddEXT))load("glFogCoorddEXT\0".ptr);
	glFogCoorddvEXT = cast(typeof(glFogCoorddvEXT))load("glFogCoorddvEXT\0".ptr);
	glFogCoordPointerEXT = cast(typeof(glFogCoordPointerEXT))load("glFogCoordPointerEXT\0".ptr);
	return GL_EXT_fog_coord;
}


bool load_gl_GL_EXT_vertex_array(void* function(const(char)* name) load) {
	if(!GL_EXT_vertex_array) return GL_EXT_vertex_array;

	glArrayElementEXT = cast(typeof(glArrayElementEXT))load("glArrayElementEXT\0".ptr);
	glColorPointerEXT = cast(typeof(glColorPointerEXT))load("glColorPointerEXT\0".ptr);
	glDrawArraysEXT = cast(typeof(glDrawArraysEXT))load("glDrawArraysEXT\0".ptr);
	glEdgeFlagPointerEXT = cast(typeof(glEdgeFlagPointerEXT))load("glEdgeFlagPointerEXT\0".ptr);
	glGetPointervEXT = cast(typeof(glGetPointervEXT))load("glGetPointervEXT\0".ptr);
	glIndexPointerEXT = cast(typeof(glIndexPointerEXT))load("glIndexPointerEXT\0".ptr);
	glNormalPointerEXT = cast(typeof(glNormalPointerEXT))load("glNormalPointerEXT\0".ptr);
	glTexCoordPointerEXT = cast(typeof(glTexCoordPointerEXT))load("glTexCoordPointerEXT\0".ptr);
	glVertexPointerEXT = cast(typeof(glVertexPointerEXT))load("glVertexPointerEXT\0".ptr);
	return GL_EXT_vertex_array;
}


bool load_gl_GL_EXT_blend_equation_separate(void* function(const(char)* name) load) {
	if(!GL_EXT_blend_equation_separate) return GL_EXT_blend_equation_separate;

	glBlendEquationSeparateEXT = cast(typeof(glBlendEquationSeparateEXT))load("glBlendEquationSeparateEXT\0".ptr);
	return GL_EXT_blend_equation_separate;
}


bool load_gl_GL_ARB_multi_draw_indirect(void* function(const(char)* name) load) {
	if(!GL_ARB_multi_draw_indirect) return GL_ARB_multi_draw_indirect;

	glMultiDrawArraysIndirect = cast(typeof(glMultiDrawArraysIndirect))load("glMultiDrawArraysIndirect\0".ptr);
	glMultiDrawElementsIndirect = cast(typeof(glMultiDrawElementsIndirect))load("glMultiDrawElementsIndirect\0".ptr);
	return GL_ARB_multi_draw_indirect;
}


bool load_gl_GL_NV_copy_image(void* function(const(char)* name) load) {
	if(!GL_NV_copy_image) return GL_NV_copy_image;

	glCopyImageSubDataNV = cast(typeof(glCopyImageSubDataNV))load("glCopyImageSubDataNV\0".ptr);
	return GL_NV_copy_image;
}


bool load_gl_GL_ARB_transform_feedback2(void* function(const(char)* name) load) {
	if(!GL_ARB_transform_feedback2) return GL_ARB_transform_feedback2;

	glBindTransformFeedback = cast(typeof(glBindTransformFeedback))load("glBindTransformFeedback\0".ptr);
	glDeleteTransformFeedbacks = cast(typeof(glDeleteTransformFeedbacks))load("glDeleteTransformFeedbacks\0".ptr);
	glGenTransformFeedbacks = cast(typeof(glGenTransformFeedbacks))load("glGenTransformFeedbacks\0".ptr);
	glIsTransformFeedback = cast(typeof(glIsTransformFeedback))load("glIsTransformFeedback\0".ptr);
	glPauseTransformFeedback = cast(typeof(glPauseTransformFeedback))load("glPauseTransformFeedback\0".ptr);
	glResumeTransformFeedback = cast(typeof(glResumeTransformFeedback))load("glResumeTransformFeedback\0".ptr);
	glDrawTransformFeedback = cast(typeof(glDrawTransformFeedback))load("glDrawTransformFeedback\0".ptr);
	return GL_ARB_transform_feedback2;
}


bool load_gl_GL_ARB_transform_feedback3(void* function(const(char)* name) load) {
	if(!GL_ARB_transform_feedback3) return GL_ARB_transform_feedback3;

	glDrawTransformFeedbackStream = cast(typeof(glDrawTransformFeedbackStream))load("glDrawTransformFeedbackStream\0".ptr);
	glBeginQueryIndexed = cast(typeof(glBeginQueryIndexed))load("glBeginQueryIndexed\0".ptr);
	glEndQueryIndexed = cast(typeof(glEndQueryIndexed))load("glEndQueryIndexed\0".ptr);
	glGetQueryIndexediv = cast(typeof(glGetQueryIndexediv))load("glGetQueryIndexediv\0".ptr);
	return GL_ARB_transform_feedback3;
}


bool load_gl_GL_EXT_pixel_transform(void* function(const(char)* name) load) {
	if(!GL_EXT_pixel_transform) return GL_EXT_pixel_transform;

	glPixelTransformParameteriEXT = cast(typeof(glPixelTransformParameteriEXT))load("glPixelTransformParameteriEXT\0".ptr);
	glPixelTransformParameterfEXT = cast(typeof(glPixelTransformParameterfEXT))load("glPixelTransformParameterfEXT\0".ptr);
	glPixelTransformParameterivEXT = cast(typeof(glPixelTransformParameterivEXT))load("glPixelTransformParameterivEXT\0".ptr);
	glPixelTransformParameterfvEXT = cast(typeof(glPixelTransformParameterfvEXT))load("glPixelTransformParameterfvEXT\0".ptr);
	glGetPixelTransformParameterivEXT = cast(typeof(glGetPixelTransformParameterivEXT))load("glGetPixelTransformParameterivEXT\0".ptr);
	glGetPixelTransformParameterfvEXT = cast(typeof(glGetPixelTransformParameterfvEXT))load("glGetPixelTransformParameterfvEXT\0".ptr);
	return GL_EXT_pixel_transform;
}


bool load_gl_GL_ATI_fragment_shader(void* function(const(char)* name) load) {
	if(!GL_ATI_fragment_shader) return GL_ATI_fragment_shader;

	glGenFragmentShadersATI = cast(typeof(glGenFragmentShadersATI))load("glGenFragmentShadersATI\0".ptr);
	glBindFragmentShaderATI = cast(typeof(glBindFragmentShaderATI))load("glBindFragmentShaderATI\0".ptr);
	glDeleteFragmentShaderATI = cast(typeof(glDeleteFragmentShaderATI))load("glDeleteFragmentShaderATI\0".ptr);
	glBeginFragmentShaderATI = cast(typeof(glBeginFragmentShaderATI))load("glBeginFragmentShaderATI\0".ptr);
	glEndFragmentShaderATI = cast(typeof(glEndFragmentShaderATI))load("glEndFragmentShaderATI\0".ptr);
	glPassTexCoordATI = cast(typeof(glPassTexCoordATI))load("glPassTexCoordATI\0".ptr);
	glSampleMapATI = cast(typeof(glSampleMapATI))load("glSampleMapATI\0".ptr);
	glColorFragmentOp1ATI = cast(typeof(glColorFragmentOp1ATI))load("glColorFragmentOp1ATI\0".ptr);
	glColorFragmentOp2ATI = cast(typeof(glColorFragmentOp2ATI))load("glColorFragmentOp2ATI\0".ptr);
	glColorFragmentOp3ATI = cast(typeof(glColorFragmentOp3ATI))load("glColorFragmentOp3ATI\0".ptr);
	glAlphaFragmentOp1ATI = cast(typeof(glAlphaFragmentOp1ATI))load("glAlphaFragmentOp1ATI\0".ptr);
	glAlphaFragmentOp2ATI = cast(typeof(glAlphaFragmentOp2ATI))load("glAlphaFragmentOp2ATI\0".ptr);
	glAlphaFragmentOp3ATI = cast(typeof(glAlphaFragmentOp3ATI))load("glAlphaFragmentOp3ATI\0".ptr);
	glSetFragmentShaderConstantATI = cast(typeof(glSetFragmentShaderConstantATI))load("glSetFragmentShaderConstantATI\0".ptr);
	return GL_ATI_fragment_shader;
}


bool load_gl_GL_ARB_vertex_array_object(void* function(const(char)* name) load) {
	if(!GL_ARB_vertex_array_object) return GL_ARB_vertex_array_object;

	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray\0".ptr);
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays\0".ptr);
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays\0".ptr);
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray\0".ptr);
	return GL_ARB_vertex_array_object;
}


bool load_gl_GL_SUN_triangle_list(void* function(const(char)* name) load) {
	if(!GL_SUN_triangle_list) return GL_SUN_triangle_list;

	glReplacementCodeuiSUN = cast(typeof(glReplacementCodeuiSUN))load("glReplacementCodeuiSUN\0".ptr);
	glReplacementCodeusSUN = cast(typeof(glReplacementCodeusSUN))load("glReplacementCodeusSUN\0".ptr);
	glReplacementCodeubSUN = cast(typeof(glReplacementCodeubSUN))load("glReplacementCodeubSUN\0".ptr);
	glReplacementCodeuivSUN = cast(typeof(glReplacementCodeuivSUN))load("glReplacementCodeuivSUN\0".ptr);
	glReplacementCodeusvSUN = cast(typeof(glReplacementCodeusvSUN))load("glReplacementCodeusvSUN\0".ptr);
	glReplacementCodeubvSUN = cast(typeof(glReplacementCodeubvSUN))load("glReplacementCodeubvSUN\0".ptr);
	glReplacementCodePointerSUN = cast(typeof(glReplacementCodePointerSUN))load("glReplacementCodePointerSUN\0".ptr);
	return GL_SUN_triangle_list;
}


bool load_gl_GL_ARB_transform_feedback_instanced(void* function(const(char)* name) load) {
	if(!GL_ARB_transform_feedback_instanced) return GL_ARB_transform_feedback_instanced;

	glDrawTransformFeedbackInstanced = cast(typeof(glDrawTransformFeedbackInstanced))load("glDrawTransformFeedbackInstanced\0".ptr);
	glDrawTransformFeedbackStreamInstanced = cast(typeof(glDrawTransformFeedbackStreamInstanced))load("glDrawTransformFeedbackStreamInstanced\0".ptr);
	return GL_ARB_transform_feedback_instanced;
}


bool load_gl_GL_SGIX_async(void* function(const(char)* name) load) {
	if(!GL_SGIX_async) return GL_SGIX_async;

	glAsyncMarkerSGIX = cast(typeof(glAsyncMarkerSGIX))load("glAsyncMarkerSGIX\0".ptr);
	glFinishAsyncSGIX = cast(typeof(glFinishAsyncSGIX))load("glFinishAsyncSGIX\0".ptr);
	glPollAsyncSGIX = cast(typeof(glPollAsyncSGIX))load("glPollAsyncSGIX\0".ptr);
	glGenAsyncMarkersSGIX = cast(typeof(glGenAsyncMarkersSGIX))load("glGenAsyncMarkersSGIX\0".ptr);
	glDeleteAsyncMarkersSGIX = cast(typeof(glDeleteAsyncMarkersSGIX))load("glDeleteAsyncMarkersSGIX\0".ptr);
	glIsAsyncMarkerSGIX = cast(typeof(glIsAsyncMarkerSGIX))load("glIsAsyncMarkerSGIX\0".ptr);
	return GL_SGIX_async;
}


bool load_gl_GL_NV_gpu_shader5(void* function(const(char)* name) load) {
	if(!GL_NV_gpu_shader5) return GL_NV_gpu_shader5;

	glUniform1i64NV = cast(typeof(glUniform1i64NV))load("glUniform1i64NV\0".ptr);
	glUniform2i64NV = cast(typeof(glUniform2i64NV))load("glUniform2i64NV\0".ptr);
	glUniform3i64NV = cast(typeof(glUniform3i64NV))load("glUniform3i64NV\0".ptr);
	glUniform4i64NV = cast(typeof(glUniform4i64NV))load("glUniform4i64NV\0".ptr);
	glUniform1i64vNV = cast(typeof(glUniform1i64vNV))load("glUniform1i64vNV\0".ptr);
	glUniform2i64vNV = cast(typeof(glUniform2i64vNV))load("glUniform2i64vNV\0".ptr);
	glUniform3i64vNV = cast(typeof(glUniform3i64vNV))load("glUniform3i64vNV\0".ptr);
	glUniform4i64vNV = cast(typeof(glUniform4i64vNV))load("glUniform4i64vNV\0".ptr);
	glUniform1ui64NV = cast(typeof(glUniform1ui64NV))load("glUniform1ui64NV\0".ptr);
	glUniform2ui64NV = cast(typeof(glUniform2ui64NV))load("glUniform2ui64NV\0".ptr);
	glUniform3ui64NV = cast(typeof(glUniform3ui64NV))load("glUniform3ui64NV\0".ptr);
	glUniform4ui64NV = cast(typeof(glUniform4ui64NV))load("glUniform4ui64NV\0".ptr);
	glUniform1ui64vNV = cast(typeof(glUniform1ui64vNV))load("glUniform1ui64vNV\0".ptr);
	glUniform2ui64vNV = cast(typeof(glUniform2ui64vNV))load("glUniform2ui64vNV\0".ptr);
	glUniform3ui64vNV = cast(typeof(glUniform3ui64vNV))load("glUniform3ui64vNV\0".ptr);
	glUniform4ui64vNV = cast(typeof(glUniform4ui64vNV))load("glUniform4ui64vNV\0".ptr);
	glGetUniformi64vNV = cast(typeof(glGetUniformi64vNV))load("glGetUniformi64vNV\0".ptr);
	glProgramUniform1i64NV = cast(typeof(glProgramUniform1i64NV))load("glProgramUniform1i64NV\0".ptr);
	glProgramUniform2i64NV = cast(typeof(glProgramUniform2i64NV))load("glProgramUniform2i64NV\0".ptr);
	glProgramUniform3i64NV = cast(typeof(glProgramUniform3i64NV))load("glProgramUniform3i64NV\0".ptr);
	glProgramUniform4i64NV = cast(typeof(glProgramUniform4i64NV))load("glProgramUniform4i64NV\0".ptr);
	glProgramUniform1i64vNV = cast(typeof(glProgramUniform1i64vNV))load("glProgramUniform1i64vNV\0".ptr);
	glProgramUniform2i64vNV = cast(typeof(glProgramUniform2i64vNV))load("glProgramUniform2i64vNV\0".ptr);
	glProgramUniform3i64vNV = cast(typeof(glProgramUniform3i64vNV))load("glProgramUniform3i64vNV\0".ptr);
	glProgramUniform4i64vNV = cast(typeof(glProgramUniform4i64vNV))load("glProgramUniform4i64vNV\0".ptr);
	glProgramUniform1ui64NV = cast(typeof(glProgramUniform1ui64NV))load("glProgramUniform1ui64NV\0".ptr);
	glProgramUniform2ui64NV = cast(typeof(glProgramUniform2ui64NV))load("glProgramUniform2ui64NV\0".ptr);
	glProgramUniform3ui64NV = cast(typeof(glProgramUniform3ui64NV))load("glProgramUniform3ui64NV\0".ptr);
	glProgramUniform4ui64NV = cast(typeof(glProgramUniform4ui64NV))load("glProgramUniform4ui64NV\0".ptr);
	glProgramUniform1ui64vNV = cast(typeof(glProgramUniform1ui64vNV))load("glProgramUniform1ui64vNV\0".ptr);
	glProgramUniform2ui64vNV = cast(typeof(glProgramUniform2ui64vNV))load("glProgramUniform2ui64vNV\0".ptr);
	glProgramUniform3ui64vNV = cast(typeof(glProgramUniform3ui64vNV))load("glProgramUniform3ui64vNV\0".ptr);
	glProgramUniform4ui64vNV = cast(typeof(glProgramUniform4ui64vNV))load("glProgramUniform4ui64vNV\0".ptr);
	return GL_NV_gpu_shader5;
}


bool load_gl_GL_ARB_ES2_compatibility(void* function(const(char)* name) load) {
	if(!GL_ARB_ES2_compatibility) return GL_ARB_ES2_compatibility;

	glReleaseShaderCompiler = cast(typeof(glReleaseShaderCompiler))load("glReleaseShaderCompiler\0".ptr);
	glShaderBinary = cast(typeof(glShaderBinary))load("glShaderBinary\0".ptr);
	glGetShaderPrecisionFormat = cast(typeof(glGetShaderPrecisionFormat))load("glGetShaderPrecisionFormat\0".ptr);
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef\0".ptr);
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf\0".ptr);
	return GL_ARB_ES2_compatibility;
}


bool load_gl_GL_ARB_indirect_parameters(void* function(const(char)* name) load) {
	if(!GL_ARB_indirect_parameters) return GL_ARB_indirect_parameters;

	glMultiDrawArraysIndirectCountARB = cast(typeof(glMultiDrawArraysIndirectCountARB))load("glMultiDrawArraysIndirectCountARB\0".ptr);
	glMultiDrawElementsIndirectCountARB = cast(typeof(glMultiDrawElementsIndirectCountARB))load("glMultiDrawElementsIndirectCountARB\0".ptr);
	return GL_ARB_indirect_parameters;
}


bool load_gl_GL_NV_half_float(void* function(const(char)* name) load) {
	if(!GL_NV_half_float) return GL_NV_half_float;

	glVertex2hNV = cast(typeof(glVertex2hNV))load("glVertex2hNV\0".ptr);
	glVertex2hvNV = cast(typeof(glVertex2hvNV))load("glVertex2hvNV\0".ptr);
	glVertex3hNV = cast(typeof(glVertex3hNV))load("glVertex3hNV\0".ptr);
	glVertex3hvNV = cast(typeof(glVertex3hvNV))load("glVertex3hvNV\0".ptr);
	glVertex4hNV = cast(typeof(glVertex4hNV))load("glVertex4hNV\0".ptr);
	glVertex4hvNV = cast(typeof(glVertex4hvNV))load("glVertex4hvNV\0".ptr);
	glNormal3hNV = cast(typeof(glNormal3hNV))load("glNormal3hNV\0".ptr);
	glNormal3hvNV = cast(typeof(glNormal3hvNV))load("glNormal3hvNV\0".ptr);
	glColor3hNV = cast(typeof(glColor3hNV))load("glColor3hNV\0".ptr);
	glColor3hvNV = cast(typeof(glColor3hvNV))load("glColor3hvNV\0".ptr);
	glColor4hNV = cast(typeof(glColor4hNV))load("glColor4hNV\0".ptr);
	glColor4hvNV = cast(typeof(glColor4hvNV))load("glColor4hvNV\0".ptr);
	glTexCoord1hNV = cast(typeof(glTexCoord1hNV))load("glTexCoord1hNV\0".ptr);
	glTexCoord1hvNV = cast(typeof(glTexCoord1hvNV))load("glTexCoord1hvNV\0".ptr);
	glTexCoord2hNV = cast(typeof(glTexCoord2hNV))load("glTexCoord2hNV\0".ptr);
	glTexCoord2hvNV = cast(typeof(glTexCoord2hvNV))load("glTexCoord2hvNV\0".ptr);
	glTexCoord3hNV = cast(typeof(glTexCoord3hNV))load("glTexCoord3hNV\0".ptr);
	glTexCoord3hvNV = cast(typeof(glTexCoord3hvNV))load("glTexCoord3hvNV\0".ptr);
	glTexCoord4hNV = cast(typeof(glTexCoord4hNV))load("glTexCoord4hNV\0".ptr);
	glTexCoord4hvNV = cast(typeof(glTexCoord4hvNV))load("glTexCoord4hvNV\0".ptr);
	glMultiTexCoord1hNV = cast(typeof(glMultiTexCoord1hNV))load("glMultiTexCoord1hNV\0".ptr);
	glMultiTexCoord1hvNV = cast(typeof(glMultiTexCoord1hvNV))load("glMultiTexCoord1hvNV\0".ptr);
	glMultiTexCoord2hNV = cast(typeof(glMultiTexCoord2hNV))load("glMultiTexCoord2hNV\0".ptr);
	glMultiTexCoord2hvNV = cast(typeof(glMultiTexCoord2hvNV))load("glMultiTexCoord2hvNV\0".ptr);
	glMultiTexCoord3hNV = cast(typeof(glMultiTexCoord3hNV))load("glMultiTexCoord3hNV\0".ptr);
	glMultiTexCoord3hvNV = cast(typeof(glMultiTexCoord3hvNV))load("glMultiTexCoord3hvNV\0".ptr);
	glMultiTexCoord4hNV = cast(typeof(glMultiTexCoord4hNV))load("glMultiTexCoord4hNV\0".ptr);
	glMultiTexCoord4hvNV = cast(typeof(glMultiTexCoord4hvNV))load("glMultiTexCoord4hvNV\0".ptr);
	glFogCoordhNV = cast(typeof(glFogCoordhNV))load("glFogCoordhNV\0".ptr);
	glFogCoordhvNV = cast(typeof(glFogCoordhvNV))load("glFogCoordhvNV\0".ptr);
	glSecondaryColor3hNV = cast(typeof(glSecondaryColor3hNV))load("glSecondaryColor3hNV\0".ptr);
	glSecondaryColor3hvNV = cast(typeof(glSecondaryColor3hvNV))load("glSecondaryColor3hvNV\0".ptr);
	glVertexWeighthNV = cast(typeof(glVertexWeighthNV))load("glVertexWeighthNV\0".ptr);
	glVertexWeighthvNV = cast(typeof(glVertexWeighthvNV))load("glVertexWeighthvNV\0".ptr);
	glVertexAttrib1hNV = cast(typeof(glVertexAttrib1hNV))load("glVertexAttrib1hNV\0".ptr);
	glVertexAttrib1hvNV = cast(typeof(glVertexAttrib1hvNV))load("glVertexAttrib1hvNV\0".ptr);
	glVertexAttrib2hNV = cast(typeof(glVertexAttrib2hNV))load("glVertexAttrib2hNV\0".ptr);
	glVertexAttrib2hvNV = cast(typeof(glVertexAttrib2hvNV))load("glVertexAttrib2hvNV\0".ptr);
	glVertexAttrib3hNV = cast(typeof(glVertexAttrib3hNV))load("glVertexAttrib3hNV\0".ptr);
	glVertexAttrib3hvNV = cast(typeof(glVertexAttrib3hvNV))load("glVertexAttrib3hvNV\0".ptr);
	glVertexAttrib4hNV = cast(typeof(glVertexAttrib4hNV))load("glVertexAttrib4hNV\0".ptr);
	glVertexAttrib4hvNV = cast(typeof(glVertexAttrib4hvNV))load("glVertexAttrib4hvNV\0".ptr);
	glVertexAttribs1hvNV = cast(typeof(glVertexAttribs1hvNV))load("glVertexAttribs1hvNV\0".ptr);
	glVertexAttribs2hvNV = cast(typeof(glVertexAttribs2hvNV))load("glVertexAttribs2hvNV\0".ptr);
	glVertexAttribs3hvNV = cast(typeof(glVertexAttribs3hvNV))load("glVertexAttribs3hvNV\0".ptr);
	glVertexAttribs4hvNV = cast(typeof(glVertexAttribs4hvNV))load("glVertexAttribs4hvNV\0".ptr);
	return GL_NV_half_float;
}


bool load_gl_GL_EXT_coordinate_frame(void* function(const(char)* name) load) {
	if(!GL_EXT_coordinate_frame) return GL_EXT_coordinate_frame;

	glTangent3bEXT = cast(typeof(glTangent3bEXT))load("glTangent3bEXT\0".ptr);
	glTangent3bvEXT = cast(typeof(glTangent3bvEXT))load("glTangent3bvEXT\0".ptr);
	glTangent3dEXT = cast(typeof(glTangent3dEXT))load("glTangent3dEXT\0".ptr);
	glTangent3dvEXT = cast(typeof(glTangent3dvEXT))load("glTangent3dvEXT\0".ptr);
	glTangent3fEXT = cast(typeof(glTangent3fEXT))load("glTangent3fEXT\0".ptr);
	glTangent3fvEXT = cast(typeof(glTangent3fvEXT))load("glTangent3fvEXT\0".ptr);
	glTangent3iEXT = cast(typeof(glTangent3iEXT))load("glTangent3iEXT\0".ptr);
	glTangent3ivEXT = cast(typeof(glTangent3ivEXT))load("glTangent3ivEXT\0".ptr);
	glTangent3sEXT = cast(typeof(glTangent3sEXT))load("glTangent3sEXT\0".ptr);
	glTangent3svEXT = cast(typeof(glTangent3svEXT))load("glTangent3svEXT\0".ptr);
	glBinormal3bEXT = cast(typeof(glBinormal3bEXT))load("glBinormal3bEXT\0".ptr);
	glBinormal3bvEXT = cast(typeof(glBinormal3bvEXT))load("glBinormal3bvEXT\0".ptr);
	glBinormal3dEXT = cast(typeof(glBinormal3dEXT))load("glBinormal3dEXT\0".ptr);
	glBinormal3dvEXT = cast(typeof(glBinormal3dvEXT))load("glBinormal3dvEXT\0".ptr);
	glBinormal3fEXT = cast(typeof(glBinormal3fEXT))load("glBinormal3fEXT\0".ptr);
	glBinormal3fvEXT = cast(typeof(glBinormal3fvEXT))load("glBinormal3fvEXT\0".ptr);
	glBinormal3iEXT = cast(typeof(glBinormal3iEXT))load("glBinormal3iEXT\0".ptr);
	glBinormal3ivEXT = cast(typeof(glBinormal3ivEXT))load("glBinormal3ivEXT\0".ptr);
	glBinormal3sEXT = cast(typeof(glBinormal3sEXT))load("glBinormal3sEXT\0".ptr);
	glBinormal3svEXT = cast(typeof(glBinormal3svEXT))load("glBinormal3svEXT\0".ptr);
	glTangentPointerEXT = cast(typeof(glTangentPointerEXT))load("glTangentPointerEXT\0".ptr);
	glBinormalPointerEXT = cast(typeof(glBinormalPointerEXT))load("glBinormalPointerEXT\0".ptr);
	return GL_EXT_coordinate_frame;
}


bool load_gl_GL_EXT_compiled_vertex_array(void* function(const(char)* name) load) {
	if(!GL_EXT_compiled_vertex_array) return GL_EXT_compiled_vertex_array;

	glLockArraysEXT = cast(typeof(glLockArraysEXT))load("glLockArraysEXT\0".ptr);
	glUnlockArraysEXT = cast(typeof(glUnlockArraysEXT))load("glUnlockArraysEXT\0".ptr);
	return GL_EXT_compiled_vertex_array;
}


bool load_gl_GL_NV_depth_buffer_float(void* function(const(char)* name) load) {
	if(!GL_NV_depth_buffer_float) return GL_NV_depth_buffer_float;

	glDepthRangedNV = cast(typeof(glDepthRangedNV))load("glDepthRangedNV\0".ptr);
	glClearDepthdNV = cast(typeof(glClearDepthdNV))load("glClearDepthdNV\0".ptr);
	glDepthBoundsdNV = cast(typeof(glDepthBoundsdNV))load("glDepthBoundsdNV\0".ptr);
	return GL_NV_depth_buffer_float;
}


bool load_gl_GL_NV_occlusion_query(void* function(const(char)* name) load) {
	if(!GL_NV_occlusion_query) return GL_NV_occlusion_query;

	glGenOcclusionQueriesNV = cast(typeof(glGenOcclusionQueriesNV))load("glGenOcclusionQueriesNV\0".ptr);
	glDeleteOcclusionQueriesNV = cast(typeof(glDeleteOcclusionQueriesNV))load("glDeleteOcclusionQueriesNV\0".ptr);
	glIsOcclusionQueryNV = cast(typeof(glIsOcclusionQueryNV))load("glIsOcclusionQueryNV\0".ptr);
	glBeginOcclusionQueryNV = cast(typeof(glBeginOcclusionQueryNV))load("glBeginOcclusionQueryNV\0".ptr);
	glEndOcclusionQueryNV = cast(typeof(glEndOcclusionQueryNV))load("glEndOcclusionQueryNV\0".ptr);
	glGetOcclusionQueryivNV = cast(typeof(glGetOcclusionQueryivNV))load("glGetOcclusionQueryivNV\0".ptr);
	glGetOcclusionQueryuivNV = cast(typeof(glGetOcclusionQueryuivNV))load("glGetOcclusionQueryuivNV\0".ptr);
	return GL_NV_occlusion_query;
}


bool load_gl_GL_APPLE_flush_buffer_range(void* function(const(char)* name) load) {
	if(!GL_APPLE_flush_buffer_range) return GL_APPLE_flush_buffer_range;

	glBufferParameteriAPPLE = cast(typeof(glBufferParameteriAPPLE))load("glBufferParameteriAPPLE\0".ptr);
	glFlushMappedBufferRangeAPPLE = cast(typeof(glFlushMappedBufferRangeAPPLE))load("glFlushMappedBufferRangeAPPLE\0".ptr);
	return GL_APPLE_flush_buffer_range;
}


bool load_gl_GL_ARB_imaging(void* function(const(char)* name) load) {
	if(!GL_ARB_imaging) return GL_ARB_imaging;

	glColorTable = cast(typeof(glColorTable))load("glColorTable\0".ptr);
	glColorTableParameterfv = cast(typeof(glColorTableParameterfv))load("glColorTableParameterfv\0".ptr);
	glColorTableParameteriv = cast(typeof(glColorTableParameteriv))load("glColorTableParameteriv\0".ptr);
	glCopyColorTable = cast(typeof(glCopyColorTable))load("glCopyColorTable\0".ptr);
	glGetColorTable = cast(typeof(glGetColorTable))load("glGetColorTable\0".ptr);
	glGetColorTableParameterfv = cast(typeof(glGetColorTableParameterfv))load("glGetColorTableParameterfv\0".ptr);
	glGetColorTableParameteriv = cast(typeof(glGetColorTableParameteriv))load("glGetColorTableParameteriv\0".ptr);
	glColorSubTable = cast(typeof(glColorSubTable))load("glColorSubTable\0".ptr);
	glCopyColorSubTable = cast(typeof(glCopyColorSubTable))load("glCopyColorSubTable\0".ptr);
	glConvolutionFilter1D = cast(typeof(glConvolutionFilter1D))load("glConvolutionFilter1D\0".ptr);
	glConvolutionFilter2D = cast(typeof(glConvolutionFilter2D))load("glConvolutionFilter2D\0".ptr);
	glConvolutionParameterf = cast(typeof(glConvolutionParameterf))load("glConvolutionParameterf\0".ptr);
	glConvolutionParameterfv = cast(typeof(glConvolutionParameterfv))load("glConvolutionParameterfv\0".ptr);
	glConvolutionParameteri = cast(typeof(glConvolutionParameteri))load("glConvolutionParameteri\0".ptr);
	glConvolutionParameteriv = cast(typeof(glConvolutionParameteriv))load("glConvolutionParameteriv\0".ptr);
	glCopyConvolutionFilter1D = cast(typeof(glCopyConvolutionFilter1D))load("glCopyConvolutionFilter1D\0".ptr);
	glCopyConvolutionFilter2D = cast(typeof(glCopyConvolutionFilter2D))load("glCopyConvolutionFilter2D\0".ptr);
	glGetConvolutionFilter = cast(typeof(glGetConvolutionFilter))load("glGetConvolutionFilter\0".ptr);
	glGetConvolutionParameterfv = cast(typeof(glGetConvolutionParameterfv))load("glGetConvolutionParameterfv\0".ptr);
	glGetConvolutionParameteriv = cast(typeof(glGetConvolutionParameteriv))load("glGetConvolutionParameteriv\0".ptr);
	glGetSeparableFilter = cast(typeof(glGetSeparableFilter))load("glGetSeparableFilter\0".ptr);
	glSeparableFilter2D = cast(typeof(glSeparableFilter2D))load("glSeparableFilter2D\0".ptr);
	glGetHistogram = cast(typeof(glGetHistogram))load("glGetHistogram\0".ptr);
	glGetHistogramParameterfv = cast(typeof(glGetHistogramParameterfv))load("glGetHistogramParameterfv\0".ptr);
	glGetHistogramParameteriv = cast(typeof(glGetHistogramParameteriv))load("glGetHistogramParameteriv\0".ptr);
	glGetMinmax = cast(typeof(glGetMinmax))load("glGetMinmax\0".ptr);
	glGetMinmaxParameterfv = cast(typeof(glGetMinmaxParameterfv))load("glGetMinmaxParameterfv\0".ptr);
	glGetMinmaxParameteriv = cast(typeof(glGetMinmaxParameteriv))load("glGetMinmaxParameteriv\0".ptr);
	glHistogram = cast(typeof(glHistogram))load("glHistogram\0".ptr);
	glMinmax = cast(typeof(glMinmax))load("glMinmax\0".ptr);
	glResetHistogram = cast(typeof(glResetHistogram))load("glResetHistogram\0".ptr);
	glResetMinmax = cast(typeof(glResetMinmax))load("glResetMinmax\0".ptr);
	return GL_ARB_imaging;
}


bool load_gl_GL_ARB_draw_buffers_blend(void* function(const(char)* name) load) {
	if(!GL_ARB_draw_buffers_blend) return GL_ARB_draw_buffers_blend;

	glBlendEquationiARB = cast(typeof(glBlendEquationiARB))load("glBlendEquationiARB\0".ptr);
	glBlendEquationSeparateiARB = cast(typeof(glBlendEquationSeparateiARB))load("glBlendEquationSeparateiARB\0".ptr);
	glBlendFunciARB = cast(typeof(glBlendFunciARB))load("glBlendFunciARB\0".ptr);
	glBlendFuncSeparateiARB = cast(typeof(glBlendFuncSeparateiARB))load("glBlendFuncSeparateiARB\0".ptr);
	return GL_ARB_draw_buffers_blend;
}


bool load_gl_GL_ARB_clear_buffer_object(void* function(const(char)* name) load) {
	if(!GL_ARB_clear_buffer_object) return GL_ARB_clear_buffer_object;

	glClearBufferData = cast(typeof(glClearBufferData))load("glClearBufferData\0".ptr);
	glClearBufferSubData = cast(typeof(glClearBufferSubData))load("glClearBufferSubData\0".ptr);
	return GL_ARB_clear_buffer_object;
}


bool load_gl_GL_ARB_multisample(void* function(const(char)* name) load) {
	if(!GL_ARB_multisample) return GL_ARB_multisample;

	glSampleCoverageARB = cast(typeof(glSampleCoverageARB))load("glSampleCoverageARB\0".ptr);
	return GL_ARB_multisample;
}


bool load_gl_GL_ARB_sample_shading(void* function(const(char)* name) load) {
	if(!GL_ARB_sample_shading) return GL_ARB_sample_shading;

	glMinSampleShadingARB = cast(typeof(glMinSampleShadingARB))load("glMinSampleShadingARB\0".ptr);
	return GL_ARB_sample_shading;
}


bool load_gl_GL_INTEL_map_texture(void* function(const(char)* name) load) {
	if(!GL_INTEL_map_texture) return GL_INTEL_map_texture;

	glSyncTextureINTEL = cast(typeof(glSyncTextureINTEL))load("glSyncTextureINTEL\0".ptr);
	glUnmapTexture2DINTEL = cast(typeof(glUnmapTexture2DINTEL))load("glUnmapTexture2DINTEL\0".ptr);
	glMapTexture2DINTEL = cast(typeof(glMapTexture2DINTEL))load("glMapTexture2DINTEL\0".ptr);
	return GL_INTEL_map_texture;
}


bool load_gl_GL_ARB_compute_shader(void* function(const(char)* name) load) {
	if(!GL_ARB_compute_shader) return GL_ARB_compute_shader;

	glDispatchCompute = cast(typeof(glDispatchCompute))load("glDispatchCompute\0".ptr);
	glDispatchComputeIndirect = cast(typeof(glDispatchComputeIndirect))load("glDispatchComputeIndirect\0".ptr);
	return GL_ARB_compute_shader;
}


bool load_gl_GL_IBM_vertex_array_lists(void* function(const(char)* name) load) {
	if(!GL_IBM_vertex_array_lists) return GL_IBM_vertex_array_lists;

	glColorPointerListIBM = cast(typeof(glColorPointerListIBM))load("glColorPointerListIBM\0".ptr);
	glSecondaryColorPointerListIBM = cast(typeof(glSecondaryColorPointerListIBM))load("glSecondaryColorPointerListIBM\0".ptr);
	glEdgeFlagPointerListIBM = cast(typeof(glEdgeFlagPointerListIBM))load("glEdgeFlagPointerListIBM\0".ptr);
	glFogCoordPointerListIBM = cast(typeof(glFogCoordPointerListIBM))load("glFogCoordPointerListIBM\0".ptr);
	glIndexPointerListIBM = cast(typeof(glIndexPointerListIBM))load("glIndexPointerListIBM\0".ptr);
	glNormalPointerListIBM = cast(typeof(glNormalPointerListIBM))load("glNormalPointerListIBM\0".ptr);
	glTexCoordPointerListIBM = cast(typeof(glTexCoordPointerListIBM))load("glTexCoordPointerListIBM\0".ptr);
	glVertexPointerListIBM = cast(typeof(glVertexPointerListIBM))load("glVertexPointerListIBM\0".ptr);
	return GL_IBM_vertex_array_lists;
}


bool load_gl_GL_ARB_color_buffer_float(void* function(const(char)* name) load) {
	if(!GL_ARB_color_buffer_float) return GL_ARB_color_buffer_float;

	glClampColorARB = cast(typeof(glClampColorARB))load("glClampColorARB\0".ptr);
	return GL_ARB_color_buffer_float;
}


bool load_gl_GL_ARB_bindless_texture(void* function(const(char)* name) load) {
	if(!GL_ARB_bindless_texture) return GL_ARB_bindless_texture;

	glGetTextureHandleARB = cast(typeof(glGetTextureHandleARB))load("glGetTextureHandleARB\0".ptr);
	glGetTextureSamplerHandleARB = cast(typeof(glGetTextureSamplerHandleARB))load("glGetTextureSamplerHandleARB\0".ptr);
	glMakeTextureHandleResidentARB = cast(typeof(glMakeTextureHandleResidentARB))load("glMakeTextureHandleResidentARB\0".ptr);
	glMakeTextureHandleNonResidentARB = cast(typeof(glMakeTextureHandleNonResidentARB))load("glMakeTextureHandleNonResidentARB\0".ptr);
	glGetImageHandleARB = cast(typeof(glGetImageHandleARB))load("glGetImageHandleARB\0".ptr);
	glMakeImageHandleResidentARB = cast(typeof(glMakeImageHandleResidentARB))load("glMakeImageHandleResidentARB\0".ptr);
	glMakeImageHandleNonResidentARB = cast(typeof(glMakeImageHandleNonResidentARB))load("glMakeImageHandleNonResidentARB\0".ptr);
	glUniformHandleui64ARB = cast(typeof(glUniformHandleui64ARB))load("glUniformHandleui64ARB\0".ptr);
	glUniformHandleui64vARB = cast(typeof(glUniformHandleui64vARB))load("glUniformHandleui64vARB\0".ptr);
	glProgramUniformHandleui64ARB = cast(typeof(glProgramUniformHandleui64ARB))load("glProgramUniformHandleui64ARB\0".ptr);
	glProgramUniformHandleui64vARB = cast(typeof(glProgramUniformHandleui64vARB))load("glProgramUniformHandleui64vARB\0".ptr);
	glIsTextureHandleResidentARB = cast(typeof(glIsTextureHandleResidentARB))load("glIsTextureHandleResidentARB\0".ptr);
	glIsImageHandleResidentARB = cast(typeof(glIsImageHandleResidentARB))load("glIsImageHandleResidentARB\0".ptr);
	glVertexAttribL1ui64ARB = cast(typeof(glVertexAttribL1ui64ARB))load("glVertexAttribL1ui64ARB\0".ptr);
	glVertexAttribL1ui64vARB = cast(typeof(glVertexAttribL1ui64vARB))load("glVertexAttribL1ui64vARB\0".ptr);
	glGetVertexAttribLui64vARB = cast(typeof(glGetVertexAttribLui64vARB))load("glGetVertexAttribLui64vARB\0".ptr);
	return GL_ARB_bindless_texture;
}


bool load_gl_GL_ARB_window_pos(void* function(const(char)* name) load) {
	if(!GL_ARB_window_pos) return GL_ARB_window_pos;

	glWindowPos2dARB = cast(typeof(glWindowPos2dARB))load("glWindowPos2dARB\0".ptr);
	glWindowPos2dvARB = cast(typeof(glWindowPos2dvARB))load("glWindowPos2dvARB\0".ptr);
	glWindowPos2fARB = cast(typeof(glWindowPos2fARB))load("glWindowPos2fARB\0".ptr);
	glWindowPos2fvARB = cast(typeof(glWindowPos2fvARB))load("glWindowPos2fvARB\0".ptr);
	glWindowPos2iARB = cast(typeof(glWindowPos2iARB))load("glWindowPos2iARB\0".ptr);
	glWindowPos2ivARB = cast(typeof(glWindowPos2ivARB))load("glWindowPos2ivARB\0".ptr);
	glWindowPos2sARB = cast(typeof(glWindowPos2sARB))load("glWindowPos2sARB\0".ptr);
	glWindowPos2svARB = cast(typeof(glWindowPos2svARB))load("glWindowPos2svARB\0".ptr);
	glWindowPos3dARB = cast(typeof(glWindowPos3dARB))load("glWindowPos3dARB\0".ptr);
	glWindowPos3dvARB = cast(typeof(glWindowPos3dvARB))load("glWindowPos3dvARB\0".ptr);
	glWindowPos3fARB = cast(typeof(glWindowPos3fARB))load("glWindowPos3fARB\0".ptr);
	glWindowPos3fvARB = cast(typeof(glWindowPos3fvARB))load("glWindowPos3fvARB\0".ptr);
	glWindowPos3iARB = cast(typeof(glWindowPos3iARB))load("glWindowPos3iARB\0".ptr);
	glWindowPos3ivARB = cast(typeof(glWindowPos3ivARB))load("glWindowPos3ivARB\0".ptr);
	glWindowPos3sARB = cast(typeof(glWindowPos3sARB))load("glWindowPos3sARB\0".ptr);
	glWindowPos3svARB = cast(typeof(glWindowPos3svARB))load("glWindowPos3svARB\0".ptr);
	return GL_ARB_window_pos;
}


bool load_gl_GL_ARB_internalformat_query(void* function(const(char)* name) load) {
	if(!GL_ARB_internalformat_query) return GL_ARB_internalformat_query;

	glGetInternalformativ = cast(typeof(glGetInternalformativ))load("glGetInternalformativ\0".ptr);
	return GL_ARB_internalformat_query;
}


bool load_gl_GL_EXT_shader_image_load_store(void* function(const(char)* name) load) {
	if(!GL_EXT_shader_image_load_store) return GL_EXT_shader_image_load_store;

	glBindImageTextureEXT = cast(typeof(glBindImageTextureEXT))load("glBindImageTextureEXT\0".ptr);
	glMemoryBarrierEXT = cast(typeof(glMemoryBarrierEXT))load("glMemoryBarrierEXT\0".ptr);
	return GL_EXT_shader_image_load_store;
}


bool load_gl_GL_EXT_copy_texture(void* function(const(char)* name) load) {
	if(!GL_EXT_copy_texture) return GL_EXT_copy_texture;

	glCopyTexImage1DEXT = cast(typeof(glCopyTexImage1DEXT))load("glCopyTexImage1DEXT\0".ptr);
	glCopyTexImage2DEXT = cast(typeof(glCopyTexImage2DEXT))load("glCopyTexImage2DEXT\0".ptr);
	glCopyTexSubImage1DEXT = cast(typeof(glCopyTexSubImage1DEXT))load("glCopyTexSubImage1DEXT\0".ptr);
	glCopyTexSubImage2DEXT = cast(typeof(glCopyTexSubImage2DEXT))load("glCopyTexSubImage2DEXT\0".ptr);
	glCopyTexSubImage3DEXT = cast(typeof(glCopyTexSubImage3DEXT))load("glCopyTexSubImage3DEXT\0".ptr);
	return GL_EXT_copy_texture;
}


bool load_gl_GL_NV_register_combiners2(void* function(const(char)* name) load) {
	if(!GL_NV_register_combiners2) return GL_NV_register_combiners2;

	glCombinerStageParameterfvNV = cast(typeof(glCombinerStageParameterfvNV))load("glCombinerStageParameterfvNV\0".ptr);
	glGetCombinerStageParameterfvNV = cast(typeof(glGetCombinerStageParameterfvNV))load("glGetCombinerStageParameterfvNV\0".ptr);
	return GL_NV_register_combiners2;
}


bool load_gl_GL_NV_draw_texture(void* function(const(char)* name) load) {
	if(!GL_NV_draw_texture) return GL_NV_draw_texture;

	glDrawTextureNV = cast(typeof(glDrawTextureNV))load("glDrawTextureNV\0".ptr);
	return GL_NV_draw_texture;
}


bool load_gl_GL_EXT_draw_instanced(void* function(const(char)* name) load) {
	if(!GL_EXT_draw_instanced) return GL_EXT_draw_instanced;

	glDrawArraysInstancedEXT = cast(typeof(glDrawArraysInstancedEXT))load("glDrawArraysInstancedEXT\0".ptr);
	glDrawElementsInstancedEXT = cast(typeof(glDrawElementsInstancedEXT))load("glDrawElementsInstancedEXT\0".ptr);
	return GL_EXT_draw_instanced;
}


bool load_gl_GL_ARB_viewport_array(void* function(const(char)* name) load) {
	if(!GL_ARB_viewport_array) return GL_ARB_viewport_array;

	glViewportArrayv = cast(typeof(glViewportArrayv))load("glViewportArrayv\0".ptr);
	glViewportIndexedf = cast(typeof(glViewportIndexedf))load("glViewportIndexedf\0".ptr);
	glViewportIndexedfv = cast(typeof(glViewportIndexedfv))load("glViewportIndexedfv\0".ptr);
	glScissorArrayv = cast(typeof(glScissorArrayv))load("glScissorArrayv\0".ptr);
	glScissorIndexed = cast(typeof(glScissorIndexed))load("glScissorIndexed\0".ptr);
	glScissorIndexedv = cast(typeof(glScissorIndexedv))load("glScissorIndexedv\0".ptr);
	glDepthRangeArrayv = cast(typeof(glDepthRangeArrayv))load("glDepthRangeArrayv\0".ptr);
	glDepthRangeIndexed = cast(typeof(glDepthRangeIndexed))load("glDepthRangeIndexed\0".ptr);
	glGetFloati_v = cast(typeof(glGetFloati_v))load("glGetFloati_v\0".ptr);
	glGetDoublei_v = cast(typeof(glGetDoublei_v))load("glGetDoublei_v\0".ptr);
	return GL_ARB_viewport_array;
}


bool load_gl_GL_ARB_separate_shader_objects(void* function(const(char)* name) load) {
	if(!GL_ARB_separate_shader_objects) return GL_ARB_separate_shader_objects;

	glUseProgramStages = cast(typeof(glUseProgramStages))load("glUseProgramStages\0".ptr);
	glActiveShaderProgram = cast(typeof(glActiveShaderProgram))load("glActiveShaderProgram\0".ptr);
	glCreateShaderProgramv = cast(typeof(glCreateShaderProgramv))load("glCreateShaderProgramv\0".ptr);
	glBindProgramPipeline = cast(typeof(glBindProgramPipeline))load("glBindProgramPipeline\0".ptr);
	glDeleteProgramPipelines = cast(typeof(glDeleteProgramPipelines))load("glDeleteProgramPipelines\0".ptr);
	glGenProgramPipelines = cast(typeof(glGenProgramPipelines))load("glGenProgramPipelines\0".ptr);
	glIsProgramPipeline = cast(typeof(glIsProgramPipeline))load("glIsProgramPipeline\0".ptr);
	glGetProgramPipelineiv = cast(typeof(glGetProgramPipelineiv))load("glGetProgramPipelineiv\0".ptr);
	glProgramUniform1i = cast(typeof(glProgramUniform1i))load("glProgramUniform1i\0".ptr);
	glProgramUniform1iv = cast(typeof(glProgramUniform1iv))load("glProgramUniform1iv\0".ptr);
	glProgramUniform1f = cast(typeof(glProgramUniform1f))load("glProgramUniform1f\0".ptr);
	glProgramUniform1fv = cast(typeof(glProgramUniform1fv))load("glProgramUniform1fv\0".ptr);
	glProgramUniform1d = cast(typeof(glProgramUniform1d))load("glProgramUniform1d\0".ptr);
	glProgramUniform1dv = cast(typeof(glProgramUniform1dv))load("glProgramUniform1dv\0".ptr);
	glProgramUniform1ui = cast(typeof(glProgramUniform1ui))load("glProgramUniform1ui\0".ptr);
	glProgramUniform1uiv = cast(typeof(glProgramUniform1uiv))load("glProgramUniform1uiv\0".ptr);
	glProgramUniform2i = cast(typeof(glProgramUniform2i))load("glProgramUniform2i\0".ptr);
	glProgramUniform2iv = cast(typeof(glProgramUniform2iv))load("glProgramUniform2iv\0".ptr);
	glProgramUniform2f = cast(typeof(glProgramUniform2f))load("glProgramUniform2f\0".ptr);
	glProgramUniform2fv = cast(typeof(glProgramUniform2fv))load("glProgramUniform2fv\0".ptr);
	glProgramUniform2d = cast(typeof(glProgramUniform2d))load("glProgramUniform2d\0".ptr);
	glProgramUniform2dv = cast(typeof(glProgramUniform2dv))load("glProgramUniform2dv\0".ptr);
	glProgramUniform2ui = cast(typeof(glProgramUniform2ui))load("glProgramUniform2ui\0".ptr);
	glProgramUniform2uiv = cast(typeof(glProgramUniform2uiv))load("glProgramUniform2uiv\0".ptr);
	glProgramUniform3i = cast(typeof(glProgramUniform3i))load("glProgramUniform3i\0".ptr);
	glProgramUniform3iv = cast(typeof(glProgramUniform3iv))load("glProgramUniform3iv\0".ptr);
	glProgramUniform3f = cast(typeof(glProgramUniform3f))load("glProgramUniform3f\0".ptr);
	glProgramUniform3fv = cast(typeof(glProgramUniform3fv))load("glProgramUniform3fv\0".ptr);
	glProgramUniform3d = cast(typeof(glProgramUniform3d))load("glProgramUniform3d\0".ptr);
	glProgramUniform3dv = cast(typeof(glProgramUniform3dv))load("glProgramUniform3dv\0".ptr);
	glProgramUniform3ui = cast(typeof(glProgramUniform3ui))load("glProgramUniform3ui\0".ptr);
	glProgramUniform3uiv = cast(typeof(glProgramUniform3uiv))load("glProgramUniform3uiv\0".ptr);
	glProgramUniform4i = cast(typeof(glProgramUniform4i))load("glProgramUniform4i\0".ptr);
	glProgramUniform4iv = cast(typeof(glProgramUniform4iv))load("glProgramUniform4iv\0".ptr);
	glProgramUniform4f = cast(typeof(glProgramUniform4f))load("glProgramUniform4f\0".ptr);
	glProgramUniform4fv = cast(typeof(glProgramUniform4fv))load("glProgramUniform4fv\0".ptr);
	glProgramUniform4d = cast(typeof(glProgramUniform4d))load("glProgramUniform4d\0".ptr);
	glProgramUniform4dv = cast(typeof(glProgramUniform4dv))load("glProgramUniform4dv\0".ptr);
	glProgramUniform4ui = cast(typeof(glProgramUniform4ui))load("glProgramUniform4ui\0".ptr);
	glProgramUniform4uiv = cast(typeof(glProgramUniform4uiv))load("glProgramUniform4uiv\0".ptr);
	glProgramUniformMatrix2fv = cast(typeof(glProgramUniformMatrix2fv))load("glProgramUniformMatrix2fv\0".ptr);
	glProgramUniformMatrix3fv = cast(typeof(glProgramUniformMatrix3fv))load("glProgramUniformMatrix3fv\0".ptr);
	glProgramUniformMatrix4fv = cast(typeof(glProgramUniformMatrix4fv))load("glProgramUniformMatrix4fv\0".ptr);
	glProgramUniformMatrix2dv = cast(typeof(glProgramUniformMatrix2dv))load("glProgramUniformMatrix2dv\0".ptr);
	glProgramUniformMatrix3dv = cast(typeof(glProgramUniformMatrix3dv))load("glProgramUniformMatrix3dv\0".ptr);
	glProgramUniformMatrix4dv = cast(typeof(glProgramUniformMatrix4dv))load("glProgramUniformMatrix4dv\0".ptr);
	glProgramUniformMatrix2x3fv = cast(typeof(glProgramUniformMatrix2x3fv))load("glProgramUniformMatrix2x3fv\0".ptr);
	glProgramUniformMatrix3x2fv = cast(typeof(glProgramUniformMatrix3x2fv))load("glProgramUniformMatrix3x2fv\0".ptr);
	glProgramUniformMatrix2x4fv = cast(typeof(glProgramUniformMatrix2x4fv))load("glProgramUniformMatrix2x4fv\0".ptr);
	glProgramUniformMatrix4x2fv = cast(typeof(glProgramUniformMatrix4x2fv))load("glProgramUniformMatrix4x2fv\0".ptr);
	glProgramUniformMatrix3x4fv = cast(typeof(glProgramUniformMatrix3x4fv))load("glProgramUniformMatrix3x4fv\0".ptr);
	glProgramUniformMatrix4x3fv = cast(typeof(glProgramUniformMatrix4x3fv))load("glProgramUniformMatrix4x3fv\0".ptr);
	glProgramUniformMatrix2x3dv = cast(typeof(glProgramUniformMatrix2x3dv))load("glProgramUniformMatrix2x3dv\0".ptr);
	glProgramUniformMatrix3x2dv = cast(typeof(glProgramUniformMatrix3x2dv))load("glProgramUniformMatrix3x2dv\0".ptr);
	glProgramUniformMatrix2x4dv = cast(typeof(glProgramUniformMatrix2x4dv))load("glProgramUniformMatrix2x4dv\0".ptr);
	glProgramUniformMatrix4x2dv = cast(typeof(glProgramUniformMatrix4x2dv))load("glProgramUniformMatrix4x2dv\0".ptr);
	glProgramUniformMatrix3x4dv = cast(typeof(glProgramUniformMatrix3x4dv))load("glProgramUniformMatrix3x4dv\0".ptr);
	glProgramUniformMatrix4x3dv = cast(typeof(glProgramUniformMatrix4x3dv))load("glProgramUniformMatrix4x3dv\0".ptr);
	glValidateProgramPipeline = cast(typeof(glValidateProgramPipeline))load("glValidateProgramPipeline\0".ptr);
	glGetProgramPipelineInfoLog = cast(typeof(glGetProgramPipelineInfoLog))load("glGetProgramPipelineInfoLog\0".ptr);
	return GL_ARB_separate_shader_objects;
}


bool load_gl_GL_EXT_depth_bounds_test(void* function(const(char)* name) load) {
	if(!GL_EXT_depth_bounds_test) return GL_EXT_depth_bounds_test;

	glDepthBoundsEXT = cast(typeof(glDepthBoundsEXT))load("glDepthBoundsEXT\0".ptr);
	return GL_EXT_depth_bounds_test;
}


bool load_gl_GL_HP_image_transform(void* function(const(char)* name) load) {
	if(!GL_HP_image_transform) return GL_HP_image_transform;

	glImageTransformParameteriHP = cast(typeof(glImageTransformParameteriHP))load("glImageTransformParameteriHP\0".ptr);
	glImageTransformParameterfHP = cast(typeof(glImageTransformParameterfHP))load("glImageTransformParameterfHP\0".ptr);
	glImageTransformParameterivHP = cast(typeof(glImageTransformParameterivHP))load("glImageTransformParameterivHP\0".ptr);
	glImageTransformParameterfvHP = cast(typeof(glImageTransformParameterfvHP))load("glImageTransformParameterfvHP\0".ptr);
	glGetImageTransformParameterivHP = cast(typeof(glGetImageTransformParameterivHP))load("glGetImageTransformParameterivHP\0".ptr);
	glGetImageTransformParameterfvHP = cast(typeof(glGetImageTransformParameterfvHP))load("glGetImageTransformParameterfvHP\0".ptr);
	return GL_HP_image_transform;
}


bool load_gl_GL_NV_video_capture(void* function(const(char)* name) load) {
	if(!GL_NV_video_capture) return GL_NV_video_capture;

	glBeginVideoCaptureNV = cast(typeof(glBeginVideoCaptureNV))load("glBeginVideoCaptureNV\0".ptr);
	glBindVideoCaptureStreamBufferNV = cast(typeof(glBindVideoCaptureStreamBufferNV))load("glBindVideoCaptureStreamBufferNV\0".ptr);
	glBindVideoCaptureStreamTextureNV = cast(typeof(glBindVideoCaptureStreamTextureNV))load("glBindVideoCaptureStreamTextureNV\0".ptr);
	glEndVideoCaptureNV = cast(typeof(glEndVideoCaptureNV))load("glEndVideoCaptureNV\0".ptr);
	glGetVideoCaptureivNV = cast(typeof(glGetVideoCaptureivNV))load("glGetVideoCaptureivNV\0".ptr);
	glGetVideoCaptureStreamivNV = cast(typeof(glGetVideoCaptureStreamivNV))load("glGetVideoCaptureStreamivNV\0".ptr);
	glGetVideoCaptureStreamfvNV = cast(typeof(glGetVideoCaptureStreamfvNV))load("glGetVideoCaptureStreamfvNV\0".ptr);
	glGetVideoCaptureStreamdvNV = cast(typeof(glGetVideoCaptureStreamdvNV))load("glGetVideoCaptureStreamdvNV\0".ptr);
	glVideoCaptureNV = cast(typeof(glVideoCaptureNV))load("glVideoCaptureNV\0".ptr);
	glVideoCaptureStreamParameterivNV = cast(typeof(glVideoCaptureStreamParameterivNV))load("glVideoCaptureStreamParameterivNV\0".ptr);
	glVideoCaptureStreamParameterfvNV = cast(typeof(glVideoCaptureStreamParameterfvNV))load("glVideoCaptureStreamParameterfvNV\0".ptr);
	glVideoCaptureStreamParameterdvNV = cast(typeof(glVideoCaptureStreamParameterdvNV))load("glVideoCaptureStreamParameterdvNV\0".ptr);
	return GL_NV_video_capture;
}


bool load_gl_GL_ARB_sampler_objects(void* function(const(char)* name) load) {
	if(!GL_ARB_sampler_objects) return GL_ARB_sampler_objects;

	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers\0".ptr);
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers\0".ptr);
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler\0".ptr);
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler\0".ptr);
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri\0".ptr);
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv\0".ptr);
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf\0".ptr);
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv\0".ptr);
	glSamplerParameterIiv = cast(typeof(glSamplerParameterIiv))load("glSamplerParameterIiv\0".ptr);
	glSamplerParameterIuiv = cast(typeof(glSamplerParameterIuiv))load("glSamplerParameterIuiv\0".ptr);
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv\0".ptr);
	glGetSamplerParameterIiv = cast(typeof(glGetSamplerParameterIiv))load("glGetSamplerParameterIiv\0".ptr);
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv\0".ptr);
	glGetSamplerParameterIuiv = cast(typeof(glGetSamplerParameterIuiv))load("glGetSamplerParameterIuiv\0".ptr);
	return GL_ARB_sampler_objects;
}


bool load_gl_GL_ARB_matrix_palette(void* function(const(char)* name) load) {
	if(!GL_ARB_matrix_palette) return GL_ARB_matrix_palette;

	glCurrentPaletteMatrixARB = cast(typeof(glCurrentPaletteMatrixARB))load("glCurrentPaletteMatrixARB\0".ptr);
	glMatrixIndexubvARB = cast(typeof(glMatrixIndexubvARB))load("glMatrixIndexubvARB\0".ptr);
	glMatrixIndexusvARB = cast(typeof(glMatrixIndexusvARB))load("glMatrixIndexusvARB\0".ptr);
	glMatrixIndexuivARB = cast(typeof(glMatrixIndexuivARB))load("glMatrixIndexuivARB\0".ptr);
	glMatrixIndexPointerARB = cast(typeof(glMatrixIndexPointerARB))load("glMatrixIndexPointerARB\0".ptr);
	return GL_ARB_matrix_palette;
}


bool load_gl_GL_SGIS_texture_color_mask(void* function(const(char)* name) load) {
	if(!GL_SGIS_texture_color_mask) return GL_SGIS_texture_color_mask;

	glTextureColorMaskSGIS = cast(typeof(glTextureColorMaskSGIS))load("glTextureColorMaskSGIS\0".ptr);
	return GL_SGIS_texture_color_mask;
}


bool load_gl_GL_ARB_texture_compression(void* function(const(char)* name) load) {
	if(!GL_ARB_texture_compression) return GL_ARB_texture_compression;

	glCompressedTexImage3DARB = cast(typeof(glCompressedTexImage3DARB))load("glCompressedTexImage3DARB\0".ptr);
	glCompressedTexImage2DARB = cast(typeof(glCompressedTexImage2DARB))load("glCompressedTexImage2DARB\0".ptr);
	glCompressedTexImage1DARB = cast(typeof(glCompressedTexImage1DARB))load("glCompressedTexImage1DARB\0".ptr);
	glCompressedTexSubImage3DARB = cast(typeof(glCompressedTexSubImage3DARB))load("glCompressedTexSubImage3DARB\0".ptr);
	glCompressedTexSubImage2DARB = cast(typeof(glCompressedTexSubImage2DARB))load("glCompressedTexSubImage2DARB\0".ptr);
	glCompressedTexSubImage1DARB = cast(typeof(glCompressedTexSubImage1DARB))load("glCompressedTexSubImage1DARB\0".ptr);
	glGetCompressedTexImageARB = cast(typeof(glGetCompressedTexImageARB))load("glGetCompressedTexImageARB\0".ptr);
	return GL_ARB_texture_compression;
}


bool load_gl_GL_ARB_shader_subroutine(void* function(const(char)* name) load) {
	if(!GL_ARB_shader_subroutine) return GL_ARB_shader_subroutine;

	glGetSubroutineUniformLocation = cast(typeof(glGetSubroutineUniformLocation))load("glGetSubroutineUniformLocation\0".ptr);
	glGetSubroutineIndex = cast(typeof(glGetSubroutineIndex))load("glGetSubroutineIndex\0".ptr);
	glGetActiveSubroutineUniformiv = cast(typeof(glGetActiveSubroutineUniformiv))load("glGetActiveSubroutineUniformiv\0".ptr);
	glGetActiveSubroutineUniformName = cast(typeof(glGetActiveSubroutineUniformName))load("glGetActiveSubroutineUniformName\0".ptr);
	glGetActiveSubroutineName = cast(typeof(glGetActiveSubroutineName))load("glGetActiveSubroutineName\0".ptr);
	glUniformSubroutinesuiv = cast(typeof(glUniformSubroutinesuiv))load("glUniformSubroutinesuiv\0".ptr);
	glGetUniformSubroutineuiv = cast(typeof(glGetUniformSubroutineuiv))load("glGetUniformSubroutineuiv\0".ptr);
	glGetProgramStageiv = cast(typeof(glGetProgramStageiv))load("glGetProgramStageiv\0".ptr);
	return GL_ARB_shader_subroutine;
}


bool load_gl_GL_ARB_texture_storage_multisample(void* function(const(char)* name) load) {
	if(!GL_ARB_texture_storage_multisample) return GL_ARB_texture_storage_multisample;

	glTexStorage2DMultisample = cast(typeof(glTexStorage2DMultisample))load("glTexStorage2DMultisample\0".ptr);
	glTexStorage3DMultisample = cast(typeof(glTexStorage3DMultisample))load("glTexStorage3DMultisample\0".ptr);
	return GL_ARB_texture_storage_multisample;
}


bool load_gl_GL_EXT_vertex_attrib_64bit(void* function(const(char)* name) load) {
	if(!GL_EXT_vertex_attrib_64bit) return GL_EXT_vertex_attrib_64bit;

	glVertexAttribL1dEXT = cast(typeof(glVertexAttribL1dEXT))load("glVertexAttribL1dEXT\0".ptr);
	glVertexAttribL2dEXT = cast(typeof(glVertexAttribL2dEXT))load("glVertexAttribL2dEXT\0".ptr);
	glVertexAttribL3dEXT = cast(typeof(glVertexAttribL3dEXT))load("glVertexAttribL3dEXT\0".ptr);
	glVertexAttribL4dEXT = cast(typeof(glVertexAttribL4dEXT))load("glVertexAttribL4dEXT\0".ptr);
	glVertexAttribL1dvEXT = cast(typeof(glVertexAttribL1dvEXT))load("glVertexAttribL1dvEXT\0".ptr);
	glVertexAttribL2dvEXT = cast(typeof(glVertexAttribL2dvEXT))load("glVertexAttribL2dvEXT\0".ptr);
	glVertexAttribL3dvEXT = cast(typeof(glVertexAttribL3dvEXT))load("glVertexAttribL3dvEXT\0".ptr);
	glVertexAttribL4dvEXT = cast(typeof(glVertexAttribL4dvEXT))load("glVertexAttribL4dvEXT\0".ptr);
	glVertexAttribLPointerEXT = cast(typeof(glVertexAttribLPointerEXT))load("glVertexAttribLPointerEXT\0".ptr);
	glGetVertexAttribLdvEXT = cast(typeof(glGetVertexAttribLdvEXT))load("glGetVertexAttribLdvEXT\0".ptr);
	return GL_EXT_vertex_attrib_64bit;
}


bool load_gl_GL_OES_query_matrix(void* function(const(char)* name) load) {
	if(!GL_OES_query_matrix) return GL_OES_query_matrix;

	glQueryMatrixxOES = cast(typeof(glQueryMatrixxOES))load("glQueryMatrixxOES\0".ptr);
	return GL_OES_query_matrix;
}


bool load_gl_GL_APPLE_texture_range(void* function(const(char)* name) load) {
	if(!GL_APPLE_texture_range) return GL_APPLE_texture_range;

	glTextureRangeAPPLE = cast(typeof(glTextureRangeAPPLE))load("glTextureRangeAPPLE\0".ptr);
	glGetTexParameterPointervAPPLE = cast(typeof(glGetTexParameterPointervAPPLE))load("glGetTexParameterPointervAPPLE\0".ptr);
	return GL_APPLE_texture_range;
}


bool load_gl_GL_ARB_copy_buffer(void* function(const(char)* name) load) {
	if(!GL_ARB_copy_buffer) return GL_ARB_copy_buffer;

	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData\0".ptr);
	return GL_ARB_copy_buffer;
}


bool load_gl_GL_APPLE_object_purgeable(void* function(const(char)* name) load) {
	if(!GL_APPLE_object_purgeable) return GL_APPLE_object_purgeable;

	glObjectPurgeableAPPLE = cast(typeof(glObjectPurgeableAPPLE))load("glObjectPurgeableAPPLE\0".ptr);
	glObjectUnpurgeableAPPLE = cast(typeof(glObjectUnpurgeableAPPLE))load("glObjectUnpurgeableAPPLE\0".ptr);
	glGetObjectParameterivAPPLE = cast(typeof(glGetObjectParameterivAPPLE))load("glGetObjectParameterivAPPLE\0".ptr);
	return GL_APPLE_object_purgeable;
}


bool load_gl_GL_ARB_occlusion_query(void* function(const(char)* name) load) {
	if(!GL_ARB_occlusion_query) return GL_ARB_occlusion_query;

	glGenQueriesARB = cast(typeof(glGenQueriesARB))load("glGenQueriesARB\0".ptr);
	glDeleteQueriesARB = cast(typeof(glDeleteQueriesARB))load("glDeleteQueriesARB\0".ptr);
	glIsQueryARB = cast(typeof(glIsQueryARB))load("glIsQueryARB\0".ptr);
	glBeginQueryARB = cast(typeof(glBeginQueryARB))load("glBeginQueryARB\0".ptr);
	glEndQueryARB = cast(typeof(glEndQueryARB))load("glEndQueryARB\0".ptr);
	glGetQueryivARB = cast(typeof(glGetQueryivARB))load("glGetQueryivARB\0".ptr);
	glGetQueryObjectivARB = cast(typeof(glGetQueryObjectivARB))load("glGetQueryObjectivARB\0".ptr);
	glGetQueryObjectuivARB = cast(typeof(glGetQueryObjectuivARB))load("glGetQueryObjectuivARB\0".ptr);
	return GL_ARB_occlusion_query;
}


bool load_gl_GL_SGI_color_table(void* function(const(char)* name) load) {
	if(!GL_SGI_color_table) return GL_SGI_color_table;

	glColorTableSGI = cast(typeof(glColorTableSGI))load("glColorTableSGI\0".ptr);
	glColorTableParameterfvSGI = cast(typeof(glColorTableParameterfvSGI))load("glColorTableParameterfvSGI\0".ptr);
	glColorTableParameterivSGI = cast(typeof(glColorTableParameterivSGI))load("glColorTableParameterivSGI\0".ptr);
	glCopyColorTableSGI = cast(typeof(glCopyColorTableSGI))load("glCopyColorTableSGI\0".ptr);
	glGetColorTableSGI = cast(typeof(glGetColorTableSGI))load("glGetColorTableSGI\0".ptr);
	glGetColorTableParameterfvSGI = cast(typeof(glGetColorTableParameterfvSGI))load("glGetColorTableParameterfvSGI\0".ptr);
	glGetColorTableParameterivSGI = cast(typeof(glGetColorTableParameterivSGI))load("glGetColorTableParameterivSGI\0".ptr);
	return GL_SGI_color_table;
}


bool load_gl_GL_EXT_gpu_shader4(void* function(const(char)* name) load) {
	if(!GL_EXT_gpu_shader4) return GL_EXT_gpu_shader4;

	glGetUniformuivEXT = cast(typeof(glGetUniformuivEXT))load("glGetUniformuivEXT\0".ptr);
	glBindFragDataLocationEXT = cast(typeof(glBindFragDataLocationEXT))load("glBindFragDataLocationEXT\0".ptr);
	glGetFragDataLocationEXT = cast(typeof(glGetFragDataLocationEXT))load("glGetFragDataLocationEXT\0".ptr);
	glUniform1uiEXT = cast(typeof(glUniform1uiEXT))load("glUniform1uiEXT\0".ptr);
	glUniform2uiEXT = cast(typeof(glUniform2uiEXT))load("glUniform2uiEXT\0".ptr);
	glUniform3uiEXT = cast(typeof(glUniform3uiEXT))load("glUniform3uiEXT\0".ptr);
	glUniform4uiEXT = cast(typeof(glUniform4uiEXT))load("glUniform4uiEXT\0".ptr);
	glUniform1uivEXT = cast(typeof(glUniform1uivEXT))load("glUniform1uivEXT\0".ptr);
	glUniform2uivEXT = cast(typeof(glUniform2uivEXT))load("glUniform2uivEXT\0".ptr);
	glUniform3uivEXT = cast(typeof(glUniform3uivEXT))load("glUniform3uivEXT\0".ptr);
	glUniform4uivEXT = cast(typeof(glUniform4uivEXT))load("glUniform4uivEXT\0".ptr);
	return GL_EXT_gpu_shader4;
}


bool load_gl_GL_NV_geometry_program4(void* function(const(char)* name) load) {
	if(!GL_NV_geometry_program4) return GL_NV_geometry_program4;

	glProgramVertexLimitNV = cast(typeof(glProgramVertexLimitNV))load("glProgramVertexLimitNV\0".ptr);
	glFramebufferTextureEXT = cast(typeof(glFramebufferTextureEXT))load("glFramebufferTextureEXT\0".ptr);
	glFramebufferTextureLayerEXT = cast(typeof(glFramebufferTextureLayerEXT))load("glFramebufferTextureLayerEXT\0".ptr);
	glFramebufferTextureFaceEXT = cast(typeof(glFramebufferTextureFaceEXT))load("glFramebufferTextureFaceEXT\0".ptr);
	return GL_NV_geometry_program4;
}


bool load_gl_GL_AMD_debug_output(void* function(const(char)* name) load) {
	if(!GL_AMD_debug_output) return GL_AMD_debug_output;

	glDebugMessageEnableAMD = cast(typeof(glDebugMessageEnableAMD))load("glDebugMessageEnableAMD\0".ptr);
	glDebugMessageInsertAMD = cast(typeof(glDebugMessageInsertAMD))load("glDebugMessageInsertAMD\0".ptr);
	glDebugMessageCallbackAMD = cast(typeof(glDebugMessageCallbackAMD))load("glDebugMessageCallbackAMD\0".ptr);
	glGetDebugMessageLogAMD = cast(typeof(glGetDebugMessageLogAMD))load("glGetDebugMessageLogAMD\0".ptr);
	return GL_AMD_debug_output;
}


bool load_gl_GL_ARB_multitexture(void* function(const(char)* name) load) {
	if(!GL_ARB_multitexture) return GL_ARB_multitexture;

	glActiveTextureARB = cast(typeof(glActiveTextureARB))load("glActiveTextureARB\0".ptr);
	glClientActiveTextureARB = cast(typeof(glClientActiveTextureARB))load("glClientActiveTextureARB\0".ptr);
	glMultiTexCoord1dARB = cast(typeof(glMultiTexCoord1dARB))load("glMultiTexCoord1dARB\0".ptr);
	glMultiTexCoord1dvARB = cast(typeof(glMultiTexCoord1dvARB))load("glMultiTexCoord1dvARB\0".ptr);
	glMultiTexCoord1fARB = cast(typeof(glMultiTexCoord1fARB))load("glMultiTexCoord1fARB\0".ptr);
	glMultiTexCoord1fvARB = cast(typeof(glMultiTexCoord1fvARB))load("glMultiTexCoord1fvARB\0".ptr);
	glMultiTexCoord1iARB = cast(typeof(glMultiTexCoord1iARB))load("glMultiTexCoord1iARB\0".ptr);
	glMultiTexCoord1ivARB = cast(typeof(glMultiTexCoord1ivARB))load("glMultiTexCoord1ivARB\0".ptr);
	glMultiTexCoord1sARB = cast(typeof(glMultiTexCoord1sARB))load("glMultiTexCoord1sARB\0".ptr);
	glMultiTexCoord1svARB = cast(typeof(glMultiTexCoord1svARB))load("glMultiTexCoord1svARB\0".ptr);
	glMultiTexCoord2dARB = cast(typeof(glMultiTexCoord2dARB))load("glMultiTexCoord2dARB\0".ptr);
	glMultiTexCoord2dvARB = cast(typeof(glMultiTexCoord2dvARB))load("glMultiTexCoord2dvARB\0".ptr);
	glMultiTexCoord2fARB = cast(typeof(glMultiTexCoord2fARB))load("glMultiTexCoord2fARB\0".ptr);
	glMultiTexCoord2fvARB = cast(typeof(glMultiTexCoord2fvARB))load("glMultiTexCoord2fvARB\0".ptr);
	glMultiTexCoord2iARB = cast(typeof(glMultiTexCoord2iARB))load("glMultiTexCoord2iARB\0".ptr);
	glMultiTexCoord2ivARB = cast(typeof(glMultiTexCoord2ivARB))load("glMultiTexCoord2ivARB\0".ptr);
	glMultiTexCoord2sARB = cast(typeof(glMultiTexCoord2sARB))load("glMultiTexCoord2sARB\0".ptr);
	glMultiTexCoord2svARB = cast(typeof(glMultiTexCoord2svARB))load("glMultiTexCoord2svARB\0".ptr);
	glMultiTexCoord3dARB = cast(typeof(glMultiTexCoord3dARB))load("glMultiTexCoord3dARB\0".ptr);
	glMultiTexCoord3dvARB = cast(typeof(glMultiTexCoord3dvARB))load("glMultiTexCoord3dvARB\0".ptr);
	glMultiTexCoord3fARB = cast(typeof(glMultiTexCoord3fARB))load("glMultiTexCoord3fARB\0".ptr);
	glMultiTexCoord3fvARB = cast(typeof(glMultiTexCoord3fvARB))load("glMultiTexCoord3fvARB\0".ptr);
	glMultiTexCoord3iARB = cast(typeof(glMultiTexCoord3iARB))load("glMultiTexCoord3iARB\0".ptr);
	glMultiTexCoord3ivARB = cast(typeof(glMultiTexCoord3ivARB))load("glMultiTexCoord3ivARB\0".ptr);
	glMultiTexCoord3sARB = cast(typeof(glMultiTexCoord3sARB))load("glMultiTexCoord3sARB\0".ptr);
	glMultiTexCoord3svARB = cast(typeof(glMultiTexCoord3svARB))load("glMultiTexCoord3svARB\0".ptr);
	glMultiTexCoord4dARB = cast(typeof(glMultiTexCoord4dARB))load("glMultiTexCoord4dARB\0".ptr);
	glMultiTexCoord4dvARB = cast(typeof(glMultiTexCoord4dvARB))load("glMultiTexCoord4dvARB\0".ptr);
	glMultiTexCoord4fARB = cast(typeof(glMultiTexCoord4fARB))load("glMultiTexCoord4fARB\0".ptr);
	glMultiTexCoord4fvARB = cast(typeof(glMultiTexCoord4fvARB))load("glMultiTexCoord4fvARB\0".ptr);
	glMultiTexCoord4iARB = cast(typeof(glMultiTexCoord4iARB))load("glMultiTexCoord4iARB\0".ptr);
	glMultiTexCoord4ivARB = cast(typeof(glMultiTexCoord4ivARB))load("glMultiTexCoord4ivARB\0".ptr);
	glMultiTexCoord4sARB = cast(typeof(glMultiTexCoord4sARB))load("glMultiTexCoord4sARB\0".ptr);
	glMultiTexCoord4svARB = cast(typeof(glMultiTexCoord4svARB))load("glMultiTexCoord4svARB\0".ptr);
	return GL_ARB_multitexture;
}


bool load_gl_GL_SGIX_polynomial_ffd(void* function(const(char)* name) load) {
	if(!GL_SGIX_polynomial_ffd) return GL_SGIX_polynomial_ffd;

	glDeformationMap3dSGIX = cast(typeof(glDeformationMap3dSGIX))load("glDeformationMap3dSGIX\0".ptr);
	glDeformationMap3fSGIX = cast(typeof(glDeformationMap3fSGIX))load("glDeformationMap3fSGIX\0".ptr);
	glDeformSGIX = cast(typeof(glDeformSGIX))load("glDeformSGIX\0".ptr);
	glLoadIdentityDeformationMapSGIX = cast(typeof(glLoadIdentityDeformationMapSGIX))load("glLoadIdentityDeformationMapSGIX\0".ptr);
	return GL_SGIX_polynomial_ffd;
}


bool load_gl_GL_EXT_provoking_vertex(void* function(const(char)* name) load) {
	if(!GL_EXT_provoking_vertex) return GL_EXT_provoking_vertex;

	glProvokingVertexEXT = cast(typeof(glProvokingVertexEXT))load("glProvokingVertexEXT\0".ptr);
	return GL_EXT_provoking_vertex;
}


bool load_gl_GL_ARB_point_parameters(void* function(const(char)* name) load) {
	if(!GL_ARB_point_parameters) return GL_ARB_point_parameters;

	glPointParameterfARB = cast(typeof(glPointParameterfARB))load("glPointParameterfARB\0".ptr);
	glPointParameterfvARB = cast(typeof(glPointParameterfvARB))load("glPointParameterfvARB\0".ptr);
	return GL_ARB_point_parameters;
}


bool load_gl_GL_ARB_shader_image_load_store(void* function(const(char)* name) load) {
	if(!GL_ARB_shader_image_load_store) return GL_ARB_shader_image_load_store;

	glBindImageTexture = cast(typeof(glBindImageTexture))load("glBindImageTexture\0".ptr);
	glMemoryBarrier = cast(typeof(glMemoryBarrier))load("glMemoryBarrier\0".ptr);
	return GL_ARB_shader_image_load_store;
}


bool load_gl_GL_SGIX_framezoom(void* function(const(char)* name) load) {
	if(!GL_SGIX_framezoom) return GL_SGIX_framezoom;

	glFrameZoomSGIX = cast(typeof(glFrameZoomSGIX))load("glFrameZoomSGIX\0".ptr);
	return GL_SGIX_framezoom;
}


bool load_gl_GL_NV_bindless_multi_draw_indirect(void* function(const(char)* name) load) {
	if(!GL_NV_bindless_multi_draw_indirect) return GL_NV_bindless_multi_draw_indirect;

	glMultiDrawArraysIndirectBindlessNV = cast(typeof(glMultiDrawArraysIndirectBindlessNV))load("glMultiDrawArraysIndirectBindlessNV\0".ptr);
	glMultiDrawElementsIndirectBindlessNV = cast(typeof(glMultiDrawElementsIndirectBindlessNV))load("glMultiDrawElementsIndirectBindlessNV\0".ptr);
	return GL_NV_bindless_multi_draw_indirect;
}


bool load_gl_GL_EXT_transform_feedback(void* function(const(char)* name) load) {
	if(!GL_EXT_transform_feedback) return GL_EXT_transform_feedback;

	glBeginTransformFeedbackEXT = cast(typeof(glBeginTransformFeedbackEXT))load("glBeginTransformFeedbackEXT\0".ptr);
	glEndTransformFeedbackEXT = cast(typeof(glEndTransformFeedbackEXT))load("glEndTransformFeedbackEXT\0".ptr);
	glBindBufferRangeEXT = cast(typeof(glBindBufferRangeEXT))load("glBindBufferRangeEXT\0".ptr);
	glBindBufferOffsetEXT = cast(typeof(glBindBufferOffsetEXT))load("glBindBufferOffsetEXT\0".ptr);
	glBindBufferBaseEXT = cast(typeof(glBindBufferBaseEXT))load("glBindBufferBaseEXT\0".ptr);
	glTransformFeedbackVaryingsEXT = cast(typeof(glTransformFeedbackVaryingsEXT))load("glTransformFeedbackVaryingsEXT\0".ptr);
	glGetTransformFeedbackVaryingEXT = cast(typeof(glGetTransformFeedbackVaryingEXT))load("glGetTransformFeedbackVaryingEXT\0".ptr);
	return GL_EXT_transform_feedback;
}


bool load_gl_GL_NV_gpu_program4(void* function(const(char)* name) load) {
	if(!GL_NV_gpu_program4) return GL_NV_gpu_program4;

	glProgramLocalParameterI4iNV = cast(typeof(glProgramLocalParameterI4iNV))load("glProgramLocalParameterI4iNV\0".ptr);
	glProgramLocalParameterI4ivNV = cast(typeof(glProgramLocalParameterI4ivNV))load("glProgramLocalParameterI4ivNV\0".ptr);
	glProgramLocalParametersI4ivNV = cast(typeof(glProgramLocalParametersI4ivNV))load("glProgramLocalParametersI4ivNV\0".ptr);
	glProgramLocalParameterI4uiNV = cast(typeof(glProgramLocalParameterI4uiNV))load("glProgramLocalParameterI4uiNV\0".ptr);
	glProgramLocalParameterI4uivNV = cast(typeof(glProgramLocalParameterI4uivNV))load("glProgramLocalParameterI4uivNV\0".ptr);
	glProgramLocalParametersI4uivNV = cast(typeof(glProgramLocalParametersI4uivNV))load("glProgramLocalParametersI4uivNV\0".ptr);
	glProgramEnvParameterI4iNV = cast(typeof(glProgramEnvParameterI4iNV))load("glProgramEnvParameterI4iNV\0".ptr);
	glProgramEnvParameterI4ivNV = cast(typeof(glProgramEnvParameterI4ivNV))load("glProgramEnvParameterI4ivNV\0".ptr);
	glProgramEnvParametersI4ivNV = cast(typeof(glProgramEnvParametersI4ivNV))load("glProgramEnvParametersI4ivNV\0".ptr);
	glProgramEnvParameterI4uiNV = cast(typeof(glProgramEnvParameterI4uiNV))load("glProgramEnvParameterI4uiNV\0".ptr);
	glProgramEnvParameterI4uivNV = cast(typeof(glProgramEnvParameterI4uivNV))load("glProgramEnvParameterI4uivNV\0".ptr);
	glProgramEnvParametersI4uivNV = cast(typeof(glProgramEnvParametersI4uivNV))load("glProgramEnvParametersI4uivNV\0".ptr);
	glGetProgramLocalParameterIivNV = cast(typeof(glGetProgramLocalParameterIivNV))load("glGetProgramLocalParameterIivNV\0".ptr);
	glGetProgramLocalParameterIuivNV = cast(typeof(glGetProgramLocalParameterIuivNV))load("glGetProgramLocalParameterIuivNV\0".ptr);
	glGetProgramEnvParameterIivNV = cast(typeof(glGetProgramEnvParameterIivNV))load("glGetProgramEnvParameterIivNV\0".ptr);
	glGetProgramEnvParameterIuivNV = cast(typeof(glGetProgramEnvParameterIuivNV))load("glGetProgramEnvParameterIuivNV\0".ptr);
	return GL_NV_gpu_program4;
}


bool load_gl_GL_NV_gpu_program5(void* function(const(char)* name) load) {
	if(!GL_NV_gpu_program5) return GL_NV_gpu_program5;

	glProgramSubroutineParametersuivNV = cast(typeof(glProgramSubroutineParametersuivNV))load("glProgramSubroutineParametersuivNV\0".ptr);
	glGetProgramSubroutineParameteruivNV = cast(typeof(glGetProgramSubroutineParameteruivNV))load("glGetProgramSubroutineParameteruivNV\0".ptr);
	return GL_NV_gpu_program5;
}


bool load_gl_GL_ARB_geometry_shader4(void* function(const(char)* name) load) {
	if(!GL_ARB_geometry_shader4) return GL_ARB_geometry_shader4;

	glProgramParameteriARB = cast(typeof(glProgramParameteriARB))load("glProgramParameteriARB\0".ptr);
	glFramebufferTextureARB = cast(typeof(glFramebufferTextureARB))load("glFramebufferTextureARB\0".ptr);
	glFramebufferTextureLayerARB = cast(typeof(glFramebufferTextureLayerARB))load("glFramebufferTextureLayerARB\0".ptr);
	glFramebufferTextureFaceARB = cast(typeof(glFramebufferTextureFaceARB))load("glFramebufferTextureFaceARB\0".ptr);
	return GL_ARB_geometry_shader4;
}


bool load_gl_GL_SGIX_sprite(void* function(const(char)* name) load) {
	if(!GL_SGIX_sprite) return GL_SGIX_sprite;

	glSpriteParameterfSGIX = cast(typeof(glSpriteParameterfSGIX))load("glSpriteParameterfSGIX\0".ptr);
	glSpriteParameterfvSGIX = cast(typeof(glSpriteParameterfvSGIX))load("glSpriteParameterfvSGIX\0".ptr);
	glSpriteParameteriSGIX = cast(typeof(glSpriteParameteriSGIX))load("glSpriteParameteriSGIX\0".ptr);
	glSpriteParameterivSGIX = cast(typeof(glSpriteParameterivSGIX))load("glSpriteParameterivSGIX\0".ptr);
	return GL_SGIX_sprite;
}


bool load_gl_GL_ARB_get_program_binary(void* function(const(char)* name) load) {
	if(!GL_ARB_get_program_binary) return GL_ARB_get_program_binary;

	glGetProgramBinary = cast(typeof(glGetProgramBinary))load("glGetProgramBinary\0".ptr);
	glProgramBinary = cast(typeof(glProgramBinary))load("glProgramBinary\0".ptr);
	glProgramParameteri = cast(typeof(glProgramParameteri))load("glProgramParameteri\0".ptr);
	return GL_ARB_get_program_binary;
}


bool load_gl_GL_SGIS_multisample(void* function(const(char)* name) load) {
	if(!GL_SGIS_multisample) return GL_SGIS_multisample;

	glSampleMaskSGIS = cast(typeof(glSampleMaskSGIS))load("glSampleMaskSGIS\0".ptr);
	glSamplePatternSGIS = cast(typeof(glSamplePatternSGIS))load("glSamplePatternSGIS\0".ptr);
	return GL_SGIS_multisample;
}


bool load_gl_GL_EXT_framebuffer_object(void* function(const(char)* name) load) {
	if(!GL_EXT_framebuffer_object) return GL_EXT_framebuffer_object;

	glIsRenderbufferEXT = cast(typeof(glIsRenderbufferEXT))load("glIsRenderbufferEXT\0".ptr);
	glBindRenderbufferEXT = cast(typeof(glBindRenderbufferEXT))load("glBindRenderbufferEXT\0".ptr);
	glDeleteRenderbuffersEXT = cast(typeof(glDeleteRenderbuffersEXT))load("glDeleteRenderbuffersEXT\0".ptr);
	glGenRenderbuffersEXT = cast(typeof(glGenRenderbuffersEXT))load("glGenRenderbuffersEXT\0".ptr);
	glRenderbufferStorageEXT = cast(typeof(glRenderbufferStorageEXT))load("glRenderbufferStorageEXT\0".ptr);
	glGetRenderbufferParameterivEXT = cast(typeof(glGetRenderbufferParameterivEXT))load("glGetRenderbufferParameterivEXT\0".ptr);
	glIsFramebufferEXT = cast(typeof(glIsFramebufferEXT))load("glIsFramebufferEXT\0".ptr);
	glBindFramebufferEXT = cast(typeof(glBindFramebufferEXT))load("glBindFramebufferEXT\0".ptr);
	glDeleteFramebuffersEXT = cast(typeof(glDeleteFramebuffersEXT))load("glDeleteFramebuffersEXT\0".ptr);
	glGenFramebuffersEXT = cast(typeof(glGenFramebuffersEXT))load("glGenFramebuffersEXT\0".ptr);
	glCheckFramebufferStatusEXT = cast(typeof(glCheckFramebufferStatusEXT))load("glCheckFramebufferStatusEXT\0".ptr);
	glFramebufferTexture1DEXT = cast(typeof(glFramebufferTexture1DEXT))load("glFramebufferTexture1DEXT\0".ptr);
	glFramebufferTexture2DEXT = cast(typeof(glFramebufferTexture2DEXT))load("glFramebufferTexture2DEXT\0".ptr);
	glFramebufferTexture3DEXT = cast(typeof(glFramebufferTexture3DEXT))load("glFramebufferTexture3DEXT\0".ptr);
	glFramebufferRenderbufferEXT = cast(typeof(glFramebufferRenderbufferEXT))load("glFramebufferRenderbufferEXT\0".ptr);
	glGetFramebufferAttachmentParameterivEXT = cast(typeof(glGetFramebufferAttachmentParameterivEXT))load("glGetFramebufferAttachmentParameterivEXT\0".ptr);
	glGenerateMipmapEXT = cast(typeof(glGenerateMipmapEXT))load("glGenerateMipmapEXT\0".ptr);
	return GL_EXT_framebuffer_object;
}


bool load_gl_GL_APPLE_vertex_array_range(void* function(const(char)* name) load) {
	if(!GL_APPLE_vertex_array_range) return GL_APPLE_vertex_array_range;

	glVertexArrayRangeAPPLE = cast(typeof(glVertexArrayRangeAPPLE))load("glVertexArrayRangeAPPLE\0".ptr);
	glFlushVertexArrayRangeAPPLE = cast(typeof(glFlushVertexArrayRangeAPPLE))load("glFlushVertexArrayRangeAPPLE\0".ptr);
	glVertexArrayParameteriAPPLE = cast(typeof(glVertexArrayParameteriAPPLE))load("glVertexArrayParameteriAPPLE\0".ptr);
	return GL_APPLE_vertex_array_range;
}


bool load_gl_GL_NV_register_combiners(void* function(const(char)* name) load) {
	if(!GL_NV_register_combiners) return GL_NV_register_combiners;

	glCombinerParameterfvNV = cast(typeof(glCombinerParameterfvNV))load("glCombinerParameterfvNV\0".ptr);
	glCombinerParameterfNV = cast(typeof(glCombinerParameterfNV))load("glCombinerParameterfNV\0".ptr);
	glCombinerParameterivNV = cast(typeof(glCombinerParameterivNV))load("glCombinerParameterivNV\0".ptr);
	glCombinerParameteriNV = cast(typeof(glCombinerParameteriNV))load("glCombinerParameteriNV\0".ptr);
	glCombinerInputNV = cast(typeof(glCombinerInputNV))load("glCombinerInputNV\0".ptr);
	glCombinerOutputNV = cast(typeof(glCombinerOutputNV))load("glCombinerOutputNV\0".ptr);
	glFinalCombinerInputNV = cast(typeof(glFinalCombinerInputNV))load("glFinalCombinerInputNV\0".ptr);
	glGetCombinerInputParameterfvNV = cast(typeof(glGetCombinerInputParameterfvNV))load("glGetCombinerInputParameterfvNV\0".ptr);
	glGetCombinerInputParameterivNV = cast(typeof(glGetCombinerInputParameterivNV))load("glGetCombinerInputParameterivNV\0".ptr);
	glGetCombinerOutputParameterfvNV = cast(typeof(glGetCombinerOutputParameterfvNV))load("glGetCombinerOutputParameterfvNV\0".ptr);
	glGetCombinerOutputParameterivNV = cast(typeof(glGetCombinerOutputParameterivNV))load("glGetCombinerOutputParameterivNV\0".ptr);
	glGetFinalCombinerInputParameterfvNV = cast(typeof(glGetFinalCombinerInputParameterfvNV))load("glGetFinalCombinerInputParameterfvNV\0".ptr);
	glGetFinalCombinerInputParameterivNV = cast(typeof(glGetFinalCombinerInputParameterivNV))load("glGetFinalCombinerInputParameterivNV\0".ptr);
	return GL_NV_register_combiners;
}


bool load_gl_GL_ARB_draw_buffers(void* function(const(char)* name) load) {
	if(!GL_ARB_draw_buffers) return GL_ARB_draw_buffers;

	glDrawBuffersARB = cast(typeof(glDrawBuffersARB))load("glDrawBuffersARB\0".ptr);
	return GL_ARB_draw_buffers;
}


bool load_gl_GL_ARB_clear_texture(void* function(const(char)* name) load) {
	if(!GL_ARB_clear_texture) return GL_ARB_clear_texture;

	glClearTexImage = cast(typeof(glClearTexImage))load("glClearTexImage\0".ptr);
	glClearTexSubImage = cast(typeof(glClearTexSubImage))load("glClearTexSubImage\0".ptr);
	return GL_ARB_clear_texture;
}


bool load_gl_GL_ARB_debug_output(void* function(const(char)* name) load) {
	if(!GL_ARB_debug_output) return GL_ARB_debug_output;

	glDebugMessageControlARB = cast(typeof(glDebugMessageControlARB))load("glDebugMessageControlARB\0".ptr);
	glDebugMessageInsertARB = cast(typeof(glDebugMessageInsertARB))load("glDebugMessageInsertARB\0".ptr);
	glDebugMessageCallbackARB = cast(typeof(glDebugMessageCallbackARB))load("glDebugMessageCallbackARB\0".ptr);
	glGetDebugMessageLogARB = cast(typeof(glGetDebugMessageLogARB))load("glGetDebugMessageLogARB\0".ptr);
	return GL_ARB_debug_output;
}


bool load_gl_GL_EXT_cull_vertex(void* function(const(char)* name) load) {
	if(!GL_EXT_cull_vertex) return GL_EXT_cull_vertex;

	glCullParameterdvEXT = cast(typeof(glCullParameterdvEXT))load("glCullParameterdvEXT\0".ptr);
	glCullParameterfvEXT = cast(typeof(glCullParameterfvEXT))load("glCullParameterfvEXT\0".ptr);
	return GL_EXT_cull_vertex;
}


bool load_gl_GL_IBM_multimode_draw_arrays(void* function(const(char)* name) load) {
	if(!GL_IBM_multimode_draw_arrays) return GL_IBM_multimode_draw_arrays;

	glMultiModeDrawArraysIBM = cast(typeof(glMultiModeDrawArraysIBM))load("glMultiModeDrawArraysIBM\0".ptr);
	glMultiModeDrawElementsIBM = cast(typeof(glMultiModeDrawElementsIBM))load("glMultiModeDrawElementsIBM\0".ptr);
	return GL_IBM_multimode_draw_arrays;
}


bool load_gl_GL_APPLE_vertex_array_object(void* function(const(char)* name) load) {
	if(!GL_APPLE_vertex_array_object) return GL_APPLE_vertex_array_object;

	glBindVertexArrayAPPLE = cast(typeof(glBindVertexArrayAPPLE))load("glBindVertexArrayAPPLE\0".ptr);
	glDeleteVertexArraysAPPLE = cast(typeof(glDeleteVertexArraysAPPLE))load("glDeleteVertexArraysAPPLE\0".ptr);
	glGenVertexArraysAPPLE = cast(typeof(glGenVertexArraysAPPLE))load("glGenVertexArraysAPPLE\0".ptr);
	glIsVertexArrayAPPLE = cast(typeof(glIsVertexArrayAPPLE))load("glIsVertexArrayAPPLE\0".ptr);
	return GL_APPLE_vertex_array_object;
}


bool load_gl_GL_SGIS_detail_texture(void* function(const(char)* name) load) {
	if(!GL_SGIS_detail_texture) return GL_SGIS_detail_texture;

	glDetailTexFuncSGIS = cast(typeof(glDetailTexFuncSGIS))load("glDetailTexFuncSGIS\0".ptr);
	glGetDetailTexFuncSGIS = cast(typeof(glGetDetailTexFuncSGIS))load("glGetDetailTexFuncSGIS\0".ptr);
	return GL_SGIS_detail_texture;
}


bool load_gl_GL_ARB_draw_instanced(void* function(const(char)* name) load) {
	if(!GL_ARB_draw_instanced) return GL_ARB_draw_instanced;

	glDrawArraysInstancedARB = cast(typeof(glDrawArraysInstancedARB))load("glDrawArraysInstancedARB\0".ptr);
	glDrawElementsInstancedARB = cast(typeof(glDrawElementsInstancedARB))load("glDrawElementsInstancedARB\0".ptr);
	return GL_ARB_draw_instanced;
}


bool load_gl_GL_ARB_shading_language_include(void* function(const(char)* name) load) {
	if(!GL_ARB_shading_language_include) return GL_ARB_shading_language_include;

	glNamedStringARB = cast(typeof(glNamedStringARB))load("glNamedStringARB\0".ptr);
	glDeleteNamedStringARB = cast(typeof(glDeleteNamedStringARB))load("glDeleteNamedStringARB\0".ptr);
	glCompileShaderIncludeARB = cast(typeof(glCompileShaderIncludeARB))load("glCompileShaderIncludeARB\0".ptr);
	glIsNamedStringARB = cast(typeof(glIsNamedStringARB))load("glIsNamedStringARB\0".ptr);
	glGetNamedStringARB = cast(typeof(glGetNamedStringARB))load("glGetNamedStringARB\0".ptr);
	glGetNamedStringivARB = cast(typeof(glGetNamedStringivARB))load("glGetNamedStringivARB\0".ptr);
	return GL_ARB_shading_language_include;
}


bool load_gl_GL_INGR_blend_func_separate(void* function(const(char)* name) load) {
	if(!GL_INGR_blend_func_separate) return GL_INGR_blend_func_separate;

	glBlendFuncSeparateINGR = cast(typeof(glBlendFuncSeparateINGR))load("glBlendFuncSeparateINGR\0".ptr);
	return GL_INGR_blend_func_separate;
}


bool load_gl_GL_NV_path_rendering(void* function(const(char)* name) load) {
	if(!GL_NV_path_rendering) return GL_NV_path_rendering;

	glGenPathsNV = cast(typeof(glGenPathsNV))load("glGenPathsNV\0".ptr);
	glDeletePathsNV = cast(typeof(glDeletePathsNV))load("glDeletePathsNV\0".ptr);
	glIsPathNV = cast(typeof(glIsPathNV))load("glIsPathNV\0".ptr);
	glPathCommandsNV = cast(typeof(glPathCommandsNV))load("glPathCommandsNV\0".ptr);
	glPathCoordsNV = cast(typeof(glPathCoordsNV))load("glPathCoordsNV\0".ptr);
	glPathSubCommandsNV = cast(typeof(glPathSubCommandsNV))load("glPathSubCommandsNV\0".ptr);
	glPathSubCoordsNV = cast(typeof(glPathSubCoordsNV))load("glPathSubCoordsNV\0".ptr);
	glPathStringNV = cast(typeof(glPathStringNV))load("glPathStringNV\0".ptr);
	glPathGlyphsNV = cast(typeof(glPathGlyphsNV))load("glPathGlyphsNV\0".ptr);
	glPathGlyphRangeNV = cast(typeof(glPathGlyphRangeNV))load("glPathGlyphRangeNV\0".ptr);
	glWeightPathsNV = cast(typeof(glWeightPathsNV))load("glWeightPathsNV\0".ptr);
	glCopyPathNV = cast(typeof(glCopyPathNV))load("glCopyPathNV\0".ptr);
	glInterpolatePathsNV = cast(typeof(glInterpolatePathsNV))load("glInterpolatePathsNV\0".ptr);
	glTransformPathNV = cast(typeof(glTransformPathNV))load("glTransformPathNV\0".ptr);
	glPathParameterivNV = cast(typeof(glPathParameterivNV))load("glPathParameterivNV\0".ptr);
	glPathParameteriNV = cast(typeof(glPathParameteriNV))load("glPathParameteriNV\0".ptr);
	glPathParameterfvNV = cast(typeof(glPathParameterfvNV))load("glPathParameterfvNV\0".ptr);
	glPathParameterfNV = cast(typeof(glPathParameterfNV))load("glPathParameterfNV\0".ptr);
	glPathDashArrayNV = cast(typeof(glPathDashArrayNV))load("glPathDashArrayNV\0".ptr);
	glPathStencilFuncNV = cast(typeof(glPathStencilFuncNV))load("glPathStencilFuncNV\0".ptr);
	glPathStencilDepthOffsetNV = cast(typeof(glPathStencilDepthOffsetNV))load("glPathStencilDepthOffsetNV\0".ptr);
	glStencilFillPathNV = cast(typeof(glStencilFillPathNV))load("glStencilFillPathNV\0".ptr);
	glStencilStrokePathNV = cast(typeof(glStencilStrokePathNV))load("glStencilStrokePathNV\0".ptr);
	glStencilFillPathInstancedNV = cast(typeof(glStencilFillPathInstancedNV))load("glStencilFillPathInstancedNV\0".ptr);
	glStencilStrokePathInstancedNV = cast(typeof(glStencilStrokePathInstancedNV))load("glStencilStrokePathInstancedNV\0".ptr);
	glPathCoverDepthFuncNV = cast(typeof(glPathCoverDepthFuncNV))load("glPathCoverDepthFuncNV\0".ptr);
	glPathColorGenNV = cast(typeof(glPathColorGenNV))load("glPathColorGenNV\0".ptr);
	glPathTexGenNV = cast(typeof(glPathTexGenNV))load("glPathTexGenNV\0".ptr);
	glPathFogGenNV = cast(typeof(glPathFogGenNV))load("glPathFogGenNV\0".ptr);
	glCoverFillPathNV = cast(typeof(glCoverFillPathNV))load("glCoverFillPathNV\0".ptr);
	glCoverStrokePathNV = cast(typeof(glCoverStrokePathNV))load("glCoverStrokePathNV\0".ptr);
	glCoverFillPathInstancedNV = cast(typeof(glCoverFillPathInstancedNV))load("glCoverFillPathInstancedNV\0".ptr);
	glCoverStrokePathInstancedNV = cast(typeof(glCoverStrokePathInstancedNV))load("glCoverStrokePathInstancedNV\0".ptr);
	glGetPathParameterivNV = cast(typeof(glGetPathParameterivNV))load("glGetPathParameterivNV\0".ptr);
	glGetPathParameterfvNV = cast(typeof(glGetPathParameterfvNV))load("glGetPathParameterfvNV\0".ptr);
	glGetPathCommandsNV = cast(typeof(glGetPathCommandsNV))load("glGetPathCommandsNV\0".ptr);
	glGetPathCoordsNV = cast(typeof(glGetPathCoordsNV))load("glGetPathCoordsNV\0".ptr);
	glGetPathDashArrayNV = cast(typeof(glGetPathDashArrayNV))load("glGetPathDashArrayNV\0".ptr);
	glGetPathMetricsNV = cast(typeof(glGetPathMetricsNV))load("glGetPathMetricsNV\0".ptr);
	glGetPathMetricRangeNV = cast(typeof(glGetPathMetricRangeNV))load("glGetPathMetricRangeNV\0".ptr);
	glGetPathSpacingNV = cast(typeof(glGetPathSpacingNV))load("glGetPathSpacingNV\0".ptr);
	glGetPathColorGenivNV = cast(typeof(glGetPathColorGenivNV))load("glGetPathColorGenivNV\0".ptr);
	glGetPathColorGenfvNV = cast(typeof(glGetPathColorGenfvNV))load("glGetPathColorGenfvNV\0".ptr);
	glGetPathTexGenivNV = cast(typeof(glGetPathTexGenivNV))load("glGetPathTexGenivNV\0".ptr);
	glGetPathTexGenfvNV = cast(typeof(glGetPathTexGenfvNV))load("glGetPathTexGenfvNV\0".ptr);
	glIsPointInFillPathNV = cast(typeof(glIsPointInFillPathNV))load("glIsPointInFillPathNV\0".ptr);
	glIsPointInStrokePathNV = cast(typeof(glIsPointInStrokePathNV))load("glIsPointInStrokePathNV\0".ptr);
	glGetPathLengthNV = cast(typeof(glGetPathLengthNV))load("glGetPathLengthNV\0".ptr);
	glPointAlongPathNV = cast(typeof(glPointAlongPathNV))load("glPointAlongPathNV\0".ptr);
	return GL_NV_path_rendering;
}


bool load_gl_GL_ATI_vertex_streams(void* function(const(char)* name) load) {
	if(!GL_ATI_vertex_streams) return GL_ATI_vertex_streams;

	glVertexStream1sATI = cast(typeof(glVertexStream1sATI))load("glVertexStream1sATI\0".ptr);
	glVertexStream1svATI = cast(typeof(glVertexStream1svATI))load("glVertexStream1svATI\0".ptr);
	glVertexStream1iATI = cast(typeof(glVertexStream1iATI))load("glVertexStream1iATI\0".ptr);
	glVertexStream1ivATI = cast(typeof(glVertexStream1ivATI))load("glVertexStream1ivATI\0".ptr);
	glVertexStream1fATI = cast(typeof(glVertexStream1fATI))load("glVertexStream1fATI\0".ptr);
	glVertexStream1fvATI = cast(typeof(glVertexStream1fvATI))load("glVertexStream1fvATI\0".ptr);
	glVertexStream1dATI = cast(typeof(glVertexStream1dATI))load("glVertexStream1dATI\0".ptr);
	glVertexStream1dvATI = cast(typeof(glVertexStream1dvATI))load("glVertexStream1dvATI\0".ptr);
	glVertexStream2sATI = cast(typeof(glVertexStream2sATI))load("glVertexStream2sATI\0".ptr);
	glVertexStream2svATI = cast(typeof(glVertexStream2svATI))load("glVertexStream2svATI\0".ptr);
	glVertexStream2iATI = cast(typeof(glVertexStream2iATI))load("glVertexStream2iATI\0".ptr);
	glVertexStream2ivATI = cast(typeof(glVertexStream2ivATI))load("glVertexStream2ivATI\0".ptr);
	glVertexStream2fATI = cast(typeof(glVertexStream2fATI))load("glVertexStream2fATI\0".ptr);
	glVertexStream2fvATI = cast(typeof(glVertexStream2fvATI))load("glVertexStream2fvATI\0".ptr);
	glVertexStream2dATI = cast(typeof(glVertexStream2dATI))load("glVertexStream2dATI\0".ptr);
	glVertexStream2dvATI = cast(typeof(glVertexStream2dvATI))load("glVertexStream2dvATI\0".ptr);
	glVertexStream3sATI = cast(typeof(glVertexStream3sATI))load("glVertexStream3sATI\0".ptr);
	glVertexStream3svATI = cast(typeof(glVertexStream3svATI))load("glVertexStream3svATI\0".ptr);
	glVertexStream3iATI = cast(typeof(glVertexStream3iATI))load("glVertexStream3iATI\0".ptr);
	glVertexStream3ivATI = cast(typeof(glVertexStream3ivATI))load("glVertexStream3ivATI\0".ptr);
	glVertexStream3fATI = cast(typeof(glVertexStream3fATI))load("glVertexStream3fATI\0".ptr);
	glVertexStream3fvATI = cast(typeof(glVertexStream3fvATI))load("glVertexStream3fvATI\0".ptr);
	glVertexStream3dATI = cast(typeof(glVertexStream3dATI))load("glVertexStream3dATI\0".ptr);
	glVertexStream3dvATI = cast(typeof(glVertexStream3dvATI))load("glVertexStream3dvATI\0".ptr);
	glVertexStream4sATI = cast(typeof(glVertexStream4sATI))load("glVertexStream4sATI\0".ptr);
	glVertexStream4svATI = cast(typeof(glVertexStream4svATI))load("glVertexStream4svATI\0".ptr);
	glVertexStream4iATI = cast(typeof(glVertexStream4iATI))load("glVertexStream4iATI\0".ptr);
	glVertexStream4ivATI = cast(typeof(glVertexStream4ivATI))load("glVertexStream4ivATI\0".ptr);
	glVertexStream4fATI = cast(typeof(glVertexStream4fATI))load("glVertexStream4fATI\0".ptr);
	glVertexStream4fvATI = cast(typeof(glVertexStream4fvATI))load("glVertexStream4fvATI\0".ptr);
	glVertexStream4dATI = cast(typeof(glVertexStream4dATI))load("glVertexStream4dATI\0".ptr);
	glVertexStream4dvATI = cast(typeof(glVertexStream4dvATI))load("glVertexStream4dvATI\0".ptr);
	glNormalStream3bATI = cast(typeof(glNormalStream3bATI))load("glNormalStream3bATI\0".ptr);
	glNormalStream3bvATI = cast(typeof(glNormalStream3bvATI))load("glNormalStream3bvATI\0".ptr);
	glNormalStream3sATI = cast(typeof(glNormalStream3sATI))load("glNormalStream3sATI\0".ptr);
	glNormalStream3svATI = cast(typeof(glNormalStream3svATI))load("glNormalStream3svATI\0".ptr);
	glNormalStream3iATI = cast(typeof(glNormalStream3iATI))load("glNormalStream3iATI\0".ptr);
	glNormalStream3ivATI = cast(typeof(glNormalStream3ivATI))load("glNormalStream3ivATI\0".ptr);
	glNormalStream3fATI = cast(typeof(glNormalStream3fATI))load("glNormalStream3fATI\0".ptr);
	glNormalStream3fvATI = cast(typeof(glNormalStream3fvATI))load("glNormalStream3fvATI\0".ptr);
	glNormalStream3dATI = cast(typeof(glNormalStream3dATI))load("glNormalStream3dATI\0".ptr);
	glNormalStream3dvATI = cast(typeof(glNormalStream3dvATI))load("glNormalStream3dvATI\0".ptr);
	glClientActiveVertexStreamATI = cast(typeof(glClientActiveVertexStreamATI))load("glClientActiveVertexStreamATI\0".ptr);
	glVertexBlendEnviATI = cast(typeof(glVertexBlendEnviATI))load("glVertexBlendEnviATI\0".ptr);
	glVertexBlendEnvfATI = cast(typeof(glVertexBlendEnvfATI))load("glVertexBlendEnvfATI\0".ptr);
	return GL_ATI_vertex_streams;
}


bool load_gl_GL_NV_vdpau_interop(void* function(const(char)* name) load) {
	if(!GL_NV_vdpau_interop) return GL_NV_vdpau_interop;

	glVDPAUInitNV = cast(typeof(glVDPAUInitNV))load("glVDPAUInitNV\0".ptr);
	glVDPAUFiniNV = cast(typeof(glVDPAUFiniNV))load("glVDPAUFiniNV\0".ptr);
	glVDPAURegisterVideoSurfaceNV = cast(typeof(glVDPAURegisterVideoSurfaceNV))load("glVDPAURegisterVideoSurfaceNV\0".ptr);
	glVDPAURegisterOutputSurfaceNV = cast(typeof(glVDPAURegisterOutputSurfaceNV))load("glVDPAURegisterOutputSurfaceNV\0".ptr);
	glVDPAUIsSurfaceNV = cast(typeof(glVDPAUIsSurfaceNV))load("glVDPAUIsSurfaceNV\0".ptr);
	glVDPAUUnregisterSurfaceNV = cast(typeof(glVDPAUUnregisterSurfaceNV))load("glVDPAUUnregisterSurfaceNV\0".ptr);
	glVDPAUGetSurfaceivNV = cast(typeof(glVDPAUGetSurfaceivNV))load("glVDPAUGetSurfaceivNV\0".ptr);
	glVDPAUSurfaceAccessNV = cast(typeof(glVDPAUSurfaceAccessNV))load("glVDPAUSurfaceAccessNV\0".ptr);
	glVDPAUMapSurfacesNV = cast(typeof(glVDPAUMapSurfacesNV))load("glVDPAUMapSurfacesNV\0".ptr);
	glVDPAUUnmapSurfacesNV = cast(typeof(glVDPAUUnmapSurfacesNV))load("glVDPAUUnmapSurfacesNV\0".ptr);
	return GL_NV_vdpau_interop;
}


bool load_gl_GL_ARB_internalformat_query2(void* function(const(char)* name) load) {
	if(!GL_ARB_internalformat_query2) return GL_ARB_internalformat_query2;

	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v\0".ptr);
	return GL_ARB_internalformat_query2;
}


bool load_gl_GL_SUN_vertex(void* function(const(char)* name) load) {
	if(!GL_SUN_vertex) return GL_SUN_vertex;

	glColor4ubVertex2fSUN = cast(typeof(glColor4ubVertex2fSUN))load("glColor4ubVertex2fSUN\0".ptr);
	glColor4ubVertex2fvSUN = cast(typeof(glColor4ubVertex2fvSUN))load("glColor4ubVertex2fvSUN\0".ptr);
	glColor4ubVertex3fSUN = cast(typeof(glColor4ubVertex3fSUN))load("glColor4ubVertex3fSUN\0".ptr);
	glColor4ubVertex3fvSUN = cast(typeof(glColor4ubVertex3fvSUN))load("glColor4ubVertex3fvSUN\0".ptr);
	glColor3fVertex3fSUN = cast(typeof(glColor3fVertex3fSUN))load("glColor3fVertex3fSUN\0".ptr);
	glColor3fVertex3fvSUN = cast(typeof(glColor3fVertex3fvSUN))load("glColor3fVertex3fvSUN\0".ptr);
	glNormal3fVertex3fSUN = cast(typeof(glNormal3fVertex3fSUN))load("glNormal3fVertex3fSUN\0".ptr);
	glNormal3fVertex3fvSUN = cast(typeof(glNormal3fVertex3fvSUN))load("glNormal3fVertex3fvSUN\0".ptr);
	glColor4fNormal3fVertex3fSUN = cast(typeof(glColor4fNormal3fVertex3fSUN))load("glColor4fNormal3fVertex3fSUN\0".ptr);
	glColor4fNormal3fVertex3fvSUN = cast(typeof(glColor4fNormal3fVertex3fvSUN))load("glColor4fNormal3fVertex3fvSUN\0".ptr);
	glTexCoord2fVertex3fSUN = cast(typeof(glTexCoord2fVertex3fSUN))load("glTexCoord2fVertex3fSUN\0".ptr);
	glTexCoord2fVertex3fvSUN = cast(typeof(glTexCoord2fVertex3fvSUN))load("glTexCoord2fVertex3fvSUN\0".ptr);
	glTexCoord4fVertex4fSUN = cast(typeof(glTexCoord4fVertex4fSUN))load("glTexCoord4fVertex4fSUN\0".ptr);
	glTexCoord4fVertex4fvSUN = cast(typeof(glTexCoord4fVertex4fvSUN))load("glTexCoord4fVertex4fvSUN\0".ptr);
	glTexCoord2fColor4ubVertex3fSUN = cast(typeof(glTexCoord2fColor4ubVertex3fSUN))load("glTexCoord2fColor4ubVertex3fSUN\0".ptr);
	glTexCoord2fColor4ubVertex3fvSUN = cast(typeof(glTexCoord2fColor4ubVertex3fvSUN))load("glTexCoord2fColor4ubVertex3fvSUN\0".ptr);
	glTexCoord2fColor3fVertex3fSUN = cast(typeof(glTexCoord2fColor3fVertex3fSUN))load("glTexCoord2fColor3fVertex3fSUN\0".ptr);
	glTexCoord2fColor3fVertex3fvSUN = cast(typeof(glTexCoord2fColor3fVertex3fvSUN))load("glTexCoord2fColor3fVertex3fvSUN\0".ptr);
	glTexCoord2fNormal3fVertex3fSUN = cast(typeof(glTexCoord2fNormal3fVertex3fSUN))load("glTexCoord2fNormal3fVertex3fSUN\0".ptr);
	glTexCoord2fNormal3fVertex3fvSUN = cast(typeof(glTexCoord2fNormal3fVertex3fvSUN))load("glTexCoord2fNormal3fVertex3fvSUN\0".ptr);
	glTexCoord2fColor4fNormal3fVertex3fSUN = cast(typeof(glTexCoord2fColor4fNormal3fVertex3fSUN))load("glTexCoord2fColor4fNormal3fVertex3fSUN\0".ptr);
	glTexCoord2fColor4fNormal3fVertex3fvSUN = cast(typeof(glTexCoord2fColor4fNormal3fVertex3fvSUN))load("glTexCoord2fColor4fNormal3fVertex3fvSUN\0".ptr);
	glTexCoord4fColor4fNormal3fVertex4fSUN = cast(typeof(glTexCoord4fColor4fNormal3fVertex4fSUN))load("glTexCoord4fColor4fNormal3fVertex4fSUN\0".ptr);
	glTexCoord4fColor4fNormal3fVertex4fvSUN = cast(typeof(glTexCoord4fColor4fNormal3fVertex4fvSUN))load("glTexCoord4fColor4fNormal3fVertex4fvSUN\0".ptr);
	glReplacementCodeuiVertex3fSUN = cast(typeof(glReplacementCodeuiVertex3fSUN))load("glReplacementCodeuiVertex3fSUN\0".ptr);
	glReplacementCodeuiVertex3fvSUN = cast(typeof(glReplacementCodeuiVertex3fvSUN))load("glReplacementCodeuiVertex3fvSUN\0".ptr);
	glReplacementCodeuiColor4ubVertex3fSUN = cast(typeof(glReplacementCodeuiColor4ubVertex3fSUN))load("glReplacementCodeuiColor4ubVertex3fSUN\0".ptr);
	glReplacementCodeuiColor4ubVertex3fvSUN = cast(typeof(glReplacementCodeuiColor4ubVertex3fvSUN))load("glReplacementCodeuiColor4ubVertex3fvSUN\0".ptr);
	glReplacementCodeuiColor3fVertex3fSUN = cast(typeof(glReplacementCodeuiColor3fVertex3fSUN))load("glReplacementCodeuiColor3fVertex3fSUN\0".ptr);
	glReplacementCodeuiColor3fVertex3fvSUN = cast(typeof(glReplacementCodeuiColor3fVertex3fvSUN))load("glReplacementCodeuiColor3fVertex3fvSUN\0".ptr);
	glReplacementCodeuiNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiNormal3fVertex3fSUN))load("glReplacementCodeuiNormal3fVertex3fSUN\0".ptr);
	glReplacementCodeuiNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiNormal3fVertex3fvSUN))load("glReplacementCodeuiNormal3fVertex3fvSUN\0".ptr);
	glReplacementCodeuiColor4fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiColor4fNormal3fVertex3fSUN))load("glReplacementCodeuiColor4fNormal3fVertex3fSUN\0".ptr);
	glReplacementCodeuiColor4fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiColor4fNormal3fVertex3fvSUN))load("glReplacementCodeuiColor4fNormal3fVertex3fvSUN\0".ptr);
	glReplacementCodeuiTexCoord2fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fVertex3fSUN))load("glReplacementCodeuiTexCoord2fVertex3fSUN\0".ptr);
	glReplacementCodeuiTexCoord2fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fVertex3fvSUN\0".ptr);
	glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN))load("glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN\0".ptr);
	glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN\0".ptr);
	glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN))load("glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN\0".ptr);
	glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN\0".ptr);
	return GL_SUN_vertex;
}


bool load_gl_GL_SGIX_igloo_interface(void* function(const(char)* name) load) {
	if(!GL_SGIX_igloo_interface) return GL_SGIX_igloo_interface;

	glIglooInterfaceSGIX = cast(typeof(glIglooInterfaceSGIX))load("glIglooInterfaceSGIX\0".ptr);
	return GL_SGIX_igloo_interface;
}


bool load_gl_GL_ARB_draw_indirect(void* function(const(char)* name) load) {
	if(!GL_ARB_draw_indirect) return GL_ARB_draw_indirect;

	glDrawArraysIndirect = cast(typeof(glDrawArraysIndirect))load("glDrawArraysIndirect\0".ptr);
	glDrawElementsIndirect = cast(typeof(glDrawElementsIndirect))load("glDrawElementsIndirect\0".ptr);
	return GL_ARB_draw_indirect;
}


bool load_gl_GL_NV_vertex_program4(void* function(const(char)* name) load) {
	if(!GL_NV_vertex_program4) return GL_NV_vertex_program4;

	glVertexAttribI1iEXT = cast(typeof(glVertexAttribI1iEXT))load("glVertexAttribI1iEXT\0".ptr);
	glVertexAttribI2iEXT = cast(typeof(glVertexAttribI2iEXT))load("glVertexAttribI2iEXT\0".ptr);
	glVertexAttribI3iEXT = cast(typeof(glVertexAttribI3iEXT))load("glVertexAttribI3iEXT\0".ptr);
	glVertexAttribI4iEXT = cast(typeof(glVertexAttribI4iEXT))load("glVertexAttribI4iEXT\0".ptr);
	glVertexAttribI1uiEXT = cast(typeof(glVertexAttribI1uiEXT))load("glVertexAttribI1uiEXT\0".ptr);
	glVertexAttribI2uiEXT = cast(typeof(glVertexAttribI2uiEXT))load("glVertexAttribI2uiEXT\0".ptr);
	glVertexAttribI3uiEXT = cast(typeof(glVertexAttribI3uiEXT))load("glVertexAttribI3uiEXT\0".ptr);
	glVertexAttribI4uiEXT = cast(typeof(glVertexAttribI4uiEXT))load("glVertexAttribI4uiEXT\0".ptr);
	glVertexAttribI1ivEXT = cast(typeof(glVertexAttribI1ivEXT))load("glVertexAttribI1ivEXT\0".ptr);
	glVertexAttribI2ivEXT = cast(typeof(glVertexAttribI2ivEXT))load("glVertexAttribI2ivEXT\0".ptr);
	glVertexAttribI3ivEXT = cast(typeof(glVertexAttribI3ivEXT))load("glVertexAttribI3ivEXT\0".ptr);
	glVertexAttribI4ivEXT = cast(typeof(glVertexAttribI4ivEXT))load("glVertexAttribI4ivEXT\0".ptr);
	glVertexAttribI1uivEXT = cast(typeof(glVertexAttribI1uivEXT))load("glVertexAttribI1uivEXT\0".ptr);
	glVertexAttribI2uivEXT = cast(typeof(glVertexAttribI2uivEXT))load("glVertexAttribI2uivEXT\0".ptr);
	glVertexAttribI3uivEXT = cast(typeof(glVertexAttribI3uivEXT))load("glVertexAttribI3uivEXT\0".ptr);
	glVertexAttribI4uivEXT = cast(typeof(glVertexAttribI4uivEXT))load("glVertexAttribI4uivEXT\0".ptr);
	glVertexAttribI4bvEXT = cast(typeof(glVertexAttribI4bvEXT))load("glVertexAttribI4bvEXT\0".ptr);
	glVertexAttribI4svEXT = cast(typeof(glVertexAttribI4svEXT))load("glVertexAttribI4svEXT\0".ptr);
	glVertexAttribI4ubvEXT = cast(typeof(glVertexAttribI4ubvEXT))load("glVertexAttribI4ubvEXT\0".ptr);
	glVertexAttribI4usvEXT = cast(typeof(glVertexAttribI4usvEXT))load("glVertexAttribI4usvEXT\0".ptr);
	glVertexAttribIPointerEXT = cast(typeof(glVertexAttribIPointerEXT))load("glVertexAttribIPointerEXT\0".ptr);
	glGetVertexAttribIivEXT = cast(typeof(glGetVertexAttribIivEXT))load("glGetVertexAttribIivEXT\0".ptr);
	glGetVertexAttribIuivEXT = cast(typeof(glGetVertexAttribIuivEXT))load("glGetVertexAttribIuivEXT\0".ptr);
	return GL_NV_vertex_program4;
}


bool load_gl_GL_SGIS_fog_function(void* function(const(char)* name) load) {
	if(!GL_SGIS_fog_function) return GL_SGIS_fog_function;

	glFogFuncSGIS = cast(typeof(glFogFuncSGIS))load("glFogFuncSGIS\0".ptr);
	glGetFogFuncSGIS = cast(typeof(glGetFogFuncSGIS))load("glGetFogFuncSGIS\0".ptr);
	return GL_SGIS_fog_function;
}


bool load_gl_GL_EXT_x11_sync_object(void* function(const(char)* name) load) {
	if(!GL_EXT_x11_sync_object) return GL_EXT_x11_sync_object;

	glImportSyncEXT = cast(typeof(glImportSyncEXT))load("glImportSyncEXT\0".ptr);
	return GL_EXT_x11_sync_object;
}


bool load_gl_GL_ARB_sync(void* function(const(char)* name) load) {
	if(!GL_ARB_sync) return GL_ARB_sync;

	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync\0".ptr);
	glIsSync = cast(typeof(glIsSync))load("glIsSync\0".ptr);
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync\0".ptr);
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync\0".ptr);
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync\0".ptr);
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v\0".ptr);
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv\0".ptr);
	return GL_ARB_sync;
}


bool load_gl_GL_ARB_compute_variable_group_size(void* function(const(char)* name) load) {
	if(!GL_ARB_compute_variable_group_size) return GL_ARB_compute_variable_group_size;

	glDispatchComputeGroupSizeARB = cast(typeof(glDispatchComputeGroupSizeARB))load("glDispatchComputeGroupSizeARB\0".ptr);
	return GL_ARB_compute_variable_group_size;
}


bool load_gl_GL_OES_fixed_point(void* function(const(char)* name) load) {
	if(!GL_OES_fixed_point) return GL_OES_fixed_point;

	glAlphaFuncxOES = cast(typeof(glAlphaFuncxOES))load("glAlphaFuncxOES\0".ptr);
	glClearColorxOES = cast(typeof(glClearColorxOES))load("glClearColorxOES\0".ptr);
	glClearDepthxOES = cast(typeof(glClearDepthxOES))load("glClearDepthxOES\0".ptr);
	glClipPlanexOES = cast(typeof(glClipPlanexOES))load("glClipPlanexOES\0".ptr);
	glColor4xOES = cast(typeof(glColor4xOES))load("glColor4xOES\0".ptr);
	glDepthRangexOES = cast(typeof(glDepthRangexOES))load("glDepthRangexOES\0".ptr);
	glFogxOES = cast(typeof(glFogxOES))load("glFogxOES\0".ptr);
	glFogxvOES = cast(typeof(glFogxvOES))load("glFogxvOES\0".ptr);
	glFrustumxOES = cast(typeof(glFrustumxOES))load("glFrustumxOES\0".ptr);
	glGetClipPlanexOES = cast(typeof(glGetClipPlanexOES))load("glGetClipPlanexOES\0".ptr);
	glGetFixedvOES = cast(typeof(glGetFixedvOES))load("glGetFixedvOES\0".ptr);
	glGetTexEnvxvOES = cast(typeof(glGetTexEnvxvOES))load("glGetTexEnvxvOES\0".ptr);
	glGetTexParameterxvOES = cast(typeof(glGetTexParameterxvOES))load("glGetTexParameterxvOES\0".ptr);
	glLightModelxOES = cast(typeof(glLightModelxOES))load("glLightModelxOES\0".ptr);
	glLightModelxvOES = cast(typeof(glLightModelxvOES))load("glLightModelxvOES\0".ptr);
	glLightxOES = cast(typeof(glLightxOES))load("glLightxOES\0".ptr);
	glLightxvOES = cast(typeof(glLightxvOES))load("glLightxvOES\0".ptr);
	glLineWidthxOES = cast(typeof(glLineWidthxOES))load("glLineWidthxOES\0".ptr);
	glLoadMatrixxOES = cast(typeof(glLoadMatrixxOES))load("glLoadMatrixxOES\0".ptr);
	glMaterialxOES = cast(typeof(glMaterialxOES))load("glMaterialxOES\0".ptr);
	glMaterialxvOES = cast(typeof(glMaterialxvOES))load("glMaterialxvOES\0".ptr);
	glMultMatrixxOES = cast(typeof(glMultMatrixxOES))load("glMultMatrixxOES\0".ptr);
	glMultiTexCoord4xOES = cast(typeof(glMultiTexCoord4xOES))load("glMultiTexCoord4xOES\0".ptr);
	glNormal3xOES = cast(typeof(glNormal3xOES))load("glNormal3xOES\0".ptr);
	glOrthoxOES = cast(typeof(glOrthoxOES))load("glOrthoxOES\0".ptr);
	glPointParameterxvOES = cast(typeof(glPointParameterxvOES))load("glPointParameterxvOES\0".ptr);
	glPointSizexOES = cast(typeof(glPointSizexOES))load("glPointSizexOES\0".ptr);
	glPolygonOffsetxOES = cast(typeof(glPolygonOffsetxOES))load("glPolygonOffsetxOES\0".ptr);
	glRotatexOES = cast(typeof(glRotatexOES))load("glRotatexOES\0".ptr);
	glSampleCoverageOES = cast(typeof(glSampleCoverageOES))load("glSampleCoverageOES\0".ptr);
	glScalexOES = cast(typeof(glScalexOES))load("glScalexOES\0".ptr);
	glTexEnvxOES = cast(typeof(glTexEnvxOES))load("glTexEnvxOES\0".ptr);
	glTexEnvxvOES = cast(typeof(glTexEnvxvOES))load("glTexEnvxvOES\0".ptr);
	glTexParameterxOES = cast(typeof(glTexParameterxOES))load("glTexParameterxOES\0".ptr);
	glTexParameterxvOES = cast(typeof(glTexParameterxvOES))load("glTexParameterxvOES\0".ptr);
	glTranslatexOES = cast(typeof(glTranslatexOES))load("glTranslatexOES\0".ptr);
	glGetLightxvOES = cast(typeof(glGetLightxvOES))load("glGetLightxvOES\0".ptr);
	glGetMaterialxvOES = cast(typeof(glGetMaterialxvOES))load("glGetMaterialxvOES\0".ptr);
	glPointParameterxOES = cast(typeof(glPointParameterxOES))load("glPointParameterxOES\0".ptr);
	glSampleCoveragexOES = cast(typeof(glSampleCoveragexOES))load("glSampleCoveragexOES\0".ptr);
	glAccumxOES = cast(typeof(glAccumxOES))load("glAccumxOES\0".ptr);
	glBitmapxOES = cast(typeof(glBitmapxOES))load("glBitmapxOES\0".ptr);
	glBlendColorxOES = cast(typeof(glBlendColorxOES))load("glBlendColorxOES\0".ptr);
	glClearAccumxOES = cast(typeof(glClearAccumxOES))load("glClearAccumxOES\0".ptr);
	glColor3xOES = cast(typeof(glColor3xOES))load("glColor3xOES\0".ptr);
	glColor3xvOES = cast(typeof(glColor3xvOES))load("glColor3xvOES\0".ptr);
	glColor4xvOES = cast(typeof(glColor4xvOES))load("glColor4xvOES\0".ptr);
	glConvolutionParameterxOES = cast(typeof(glConvolutionParameterxOES))load("glConvolutionParameterxOES\0".ptr);
	glConvolutionParameterxvOES = cast(typeof(glConvolutionParameterxvOES))load("glConvolutionParameterxvOES\0".ptr);
	glEvalCoord1xOES = cast(typeof(glEvalCoord1xOES))load("glEvalCoord1xOES\0".ptr);
	glEvalCoord1xvOES = cast(typeof(glEvalCoord1xvOES))load("glEvalCoord1xvOES\0".ptr);
	glEvalCoord2xOES = cast(typeof(glEvalCoord2xOES))load("glEvalCoord2xOES\0".ptr);
	glEvalCoord2xvOES = cast(typeof(glEvalCoord2xvOES))load("glEvalCoord2xvOES\0".ptr);
	glFeedbackBufferxOES = cast(typeof(glFeedbackBufferxOES))load("glFeedbackBufferxOES\0".ptr);
	glGetConvolutionParameterxvOES = cast(typeof(glGetConvolutionParameterxvOES))load("glGetConvolutionParameterxvOES\0".ptr);
	glGetHistogramParameterxvOES = cast(typeof(glGetHistogramParameterxvOES))load("glGetHistogramParameterxvOES\0".ptr);
	glGetLightxOES = cast(typeof(glGetLightxOES))load("glGetLightxOES\0".ptr);
	glGetMapxvOES = cast(typeof(glGetMapxvOES))load("glGetMapxvOES\0".ptr);
	glGetMaterialxOES = cast(typeof(glGetMaterialxOES))load("glGetMaterialxOES\0".ptr);
	glGetPixelMapxv = cast(typeof(glGetPixelMapxv))load("glGetPixelMapxv\0".ptr);
	glGetTexGenxvOES = cast(typeof(glGetTexGenxvOES))load("glGetTexGenxvOES\0".ptr);
	glGetTexLevelParameterxvOES = cast(typeof(glGetTexLevelParameterxvOES))load("glGetTexLevelParameterxvOES\0".ptr);
	glIndexxOES = cast(typeof(glIndexxOES))load("glIndexxOES\0".ptr);
	glIndexxvOES = cast(typeof(glIndexxvOES))load("glIndexxvOES\0".ptr);
	glLoadTransposeMatrixxOES = cast(typeof(glLoadTransposeMatrixxOES))load("glLoadTransposeMatrixxOES\0".ptr);
	glMap1xOES = cast(typeof(glMap1xOES))load("glMap1xOES\0".ptr);
	glMap2xOES = cast(typeof(glMap2xOES))load("glMap2xOES\0".ptr);
	glMapGrid1xOES = cast(typeof(glMapGrid1xOES))load("glMapGrid1xOES\0".ptr);
	glMapGrid2xOES = cast(typeof(glMapGrid2xOES))load("glMapGrid2xOES\0".ptr);
	glMultTransposeMatrixxOES = cast(typeof(glMultTransposeMatrixxOES))load("glMultTransposeMatrixxOES\0".ptr);
	glMultiTexCoord1xOES = cast(typeof(glMultiTexCoord1xOES))load("glMultiTexCoord1xOES\0".ptr);
	glMultiTexCoord1xvOES = cast(typeof(glMultiTexCoord1xvOES))load("glMultiTexCoord1xvOES\0".ptr);
	glMultiTexCoord2xOES = cast(typeof(glMultiTexCoord2xOES))load("glMultiTexCoord2xOES\0".ptr);
	glMultiTexCoord2xvOES = cast(typeof(glMultiTexCoord2xvOES))load("glMultiTexCoord2xvOES\0".ptr);
	glMultiTexCoord3xOES = cast(typeof(glMultiTexCoord3xOES))load("glMultiTexCoord3xOES\0".ptr);
	glMultiTexCoord3xvOES = cast(typeof(glMultiTexCoord3xvOES))load("glMultiTexCoord3xvOES\0".ptr);
	glMultiTexCoord4xvOES = cast(typeof(glMultiTexCoord4xvOES))load("glMultiTexCoord4xvOES\0".ptr);
	glNormal3xvOES = cast(typeof(glNormal3xvOES))load("glNormal3xvOES\0".ptr);
	glPassThroughxOES = cast(typeof(glPassThroughxOES))load("glPassThroughxOES\0".ptr);
	glPixelMapx = cast(typeof(glPixelMapx))load("glPixelMapx\0".ptr);
	glPixelStorex = cast(typeof(glPixelStorex))load("glPixelStorex\0".ptr);
	glPixelTransferxOES = cast(typeof(glPixelTransferxOES))load("glPixelTransferxOES\0".ptr);
	glPixelZoomxOES = cast(typeof(glPixelZoomxOES))load("glPixelZoomxOES\0".ptr);
	glPrioritizeTexturesxOES = cast(typeof(glPrioritizeTexturesxOES))load("glPrioritizeTexturesxOES\0".ptr);
	glRasterPos2xOES = cast(typeof(glRasterPos2xOES))load("glRasterPos2xOES\0".ptr);
	glRasterPos2xvOES = cast(typeof(glRasterPos2xvOES))load("glRasterPos2xvOES\0".ptr);
	glRasterPos3xOES = cast(typeof(glRasterPos3xOES))load("glRasterPos3xOES\0".ptr);
	glRasterPos3xvOES = cast(typeof(glRasterPos3xvOES))load("glRasterPos3xvOES\0".ptr);
	glRasterPos4xOES = cast(typeof(glRasterPos4xOES))load("glRasterPos4xOES\0".ptr);
	glRasterPos4xvOES = cast(typeof(glRasterPos4xvOES))load("glRasterPos4xvOES\0".ptr);
	glRectxOES = cast(typeof(glRectxOES))load("glRectxOES\0".ptr);
	glRectxvOES = cast(typeof(glRectxvOES))load("glRectxvOES\0".ptr);
	glTexCoord1xOES = cast(typeof(glTexCoord1xOES))load("glTexCoord1xOES\0".ptr);
	glTexCoord1xvOES = cast(typeof(glTexCoord1xvOES))load("glTexCoord1xvOES\0".ptr);
	glTexCoord2xOES = cast(typeof(glTexCoord2xOES))load("glTexCoord2xOES\0".ptr);
	glTexCoord2xvOES = cast(typeof(glTexCoord2xvOES))load("glTexCoord2xvOES\0".ptr);
	glTexCoord3xOES = cast(typeof(glTexCoord3xOES))load("glTexCoord3xOES\0".ptr);
	glTexCoord3xvOES = cast(typeof(glTexCoord3xvOES))load("glTexCoord3xvOES\0".ptr);
	glTexCoord4xOES = cast(typeof(glTexCoord4xOES))load("glTexCoord4xOES\0".ptr);
	glTexCoord4xvOES = cast(typeof(glTexCoord4xvOES))load("glTexCoord4xvOES\0".ptr);
	glTexGenxOES = cast(typeof(glTexGenxOES))load("glTexGenxOES\0".ptr);
	glTexGenxvOES = cast(typeof(glTexGenxvOES))load("glTexGenxvOES\0".ptr);
	glVertex2xOES = cast(typeof(glVertex2xOES))load("glVertex2xOES\0".ptr);
	glVertex2xvOES = cast(typeof(glVertex2xvOES))load("glVertex2xvOES\0".ptr);
	glVertex3xOES = cast(typeof(glVertex3xOES))load("glVertex3xOES\0".ptr);
	glVertex3xvOES = cast(typeof(glVertex3xvOES))load("glVertex3xvOES\0".ptr);
	glVertex4xOES = cast(typeof(glVertex4xOES))load("glVertex4xOES\0".ptr);
	glVertex4xvOES = cast(typeof(glVertex4xvOES))load("glVertex4xvOES\0".ptr);
	return GL_OES_fixed_point;
}


bool load_gl_GL_EXT_framebuffer_multisample(void* function(const(char)* name) load) {
	if(!GL_EXT_framebuffer_multisample) return GL_EXT_framebuffer_multisample;

	glRenderbufferStorageMultisampleEXT = cast(typeof(glRenderbufferStorageMultisampleEXT))load("glRenderbufferStorageMultisampleEXT\0".ptr);
	return GL_EXT_framebuffer_multisample;
}


bool load_gl_GL_SGIS_texture4D(void* function(const(char)* name) load) {
	if(!GL_SGIS_texture4D) return GL_SGIS_texture4D;

	glTexImage4DSGIS = cast(typeof(glTexImage4DSGIS))load("glTexImage4DSGIS\0".ptr);
	glTexSubImage4DSGIS = cast(typeof(glTexSubImage4DSGIS))load("glTexSubImage4DSGIS\0".ptr);
	return GL_SGIS_texture4D;
}


bool load_gl_GL_EXT_texture3D(void* function(const(char)* name) load) {
	if(!GL_EXT_texture3D) return GL_EXT_texture3D;

	glTexImage3DEXT = cast(typeof(glTexImage3DEXT))load("glTexImage3DEXT\0".ptr);
	glTexSubImage3DEXT = cast(typeof(glTexSubImage3DEXT))load("glTexSubImage3DEXT\0".ptr);
	return GL_EXT_texture3D;
}


bool load_gl_GL_EXT_multisample(void* function(const(char)* name) load) {
	if(!GL_EXT_multisample) return GL_EXT_multisample;

	glSampleMaskEXT = cast(typeof(glSampleMaskEXT))load("glSampleMaskEXT\0".ptr);
	glSamplePatternEXT = cast(typeof(glSamplePatternEXT))load("glSamplePatternEXT\0".ptr);
	return GL_EXT_multisample;
}


bool load_gl_GL_EXT_secondary_color(void* function(const(char)* name) load) {
	if(!GL_EXT_secondary_color) return GL_EXT_secondary_color;

	glSecondaryColor3bEXT = cast(typeof(glSecondaryColor3bEXT))load("glSecondaryColor3bEXT\0".ptr);
	glSecondaryColor3bvEXT = cast(typeof(glSecondaryColor3bvEXT))load("glSecondaryColor3bvEXT\0".ptr);
	glSecondaryColor3dEXT = cast(typeof(glSecondaryColor3dEXT))load("glSecondaryColor3dEXT\0".ptr);
	glSecondaryColor3dvEXT = cast(typeof(glSecondaryColor3dvEXT))load("glSecondaryColor3dvEXT\0".ptr);
	glSecondaryColor3fEXT = cast(typeof(glSecondaryColor3fEXT))load("glSecondaryColor3fEXT\0".ptr);
	glSecondaryColor3fvEXT = cast(typeof(glSecondaryColor3fvEXT))load("glSecondaryColor3fvEXT\0".ptr);
	glSecondaryColor3iEXT = cast(typeof(glSecondaryColor3iEXT))load("glSecondaryColor3iEXT\0".ptr);
	glSecondaryColor3ivEXT = cast(typeof(glSecondaryColor3ivEXT))load("glSecondaryColor3ivEXT\0".ptr);
	glSecondaryColor3sEXT = cast(typeof(glSecondaryColor3sEXT))load("glSecondaryColor3sEXT\0".ptr);
	glSecondaryColor3svEXT = cast(typeof(glSecondaryColor3svEXT))load("glSecondaryColor3svEXT\0".ptr);
	glSecondaryColor3ubEXT = cast(typeof(glSecondaryColor3ubEXT))load("glSecondaryColor3ubEXT\0".ptr);
	glSecondaryColor3ubvEXT = cast(typeof(glSecondaryColor3ubvEXT))load("glSecondaryColor3ubvEXT\0".ptr);
	glSecondaryColor3uiEXT = cast(typeof(glSecondaryColor3uiEXT))load("glSecondaryColor3uiEXT\0".ptr);
	glSecondaryColor3uivEXT = cast(typeof(glSecondaryColor3uivEXT))load("glSecondaryColor3uivEXT\0".ptr);
	glSecondaryColor3usEXT = cast(typeof(glSecondaryColor3usEXT))load("glSecondaryColor3usEXT\0".ptr);
	glSecondaryColor3usvEXT = cast(typeof(glSecondaryColor3usvEXT))load("glSecondaryColor3usvEXT\0".ptr);
	glSecondaryColorPointerEXT = cast(typeof(glSecondaryColorPointerEXT))load("glSecondaryColorPointerEXT\0".ptr);
	return GL_EXT_secondary_color;
}


bool load_gl_GL_ATI_vertex_array_object(void* function(const(char)* name) load) {
	if(!GL_ATI_vertex_array_object) return GL_ATI_vertex_array_object;

	glNewObjectBufferATI = cast(typeof(glNewObjectBufferATI))load("glNewObjectBufferATI\0".ptr);
	glIsObjectBufferATI = cast(typeof(glIsObjectBufferATI))load("glIsObjectBufferATI\0".ptr);
	glUpdateObjectBufferATI = cast(typeof(glUpdateObjectBufferATI))load("glUpdateObjectBufferATI\0".ptr);
	glGetObjectBufferfvATI = cast(typeof(glGetObjectBufferfvATI))load("glGetObjectBufferfvATI\0".ptr);
	glGetObjectBufferivATI = cast(typeof(glGetObjectBufferivATI))load("glGetObjectBufferivATI\0".ptr);
	glFreeObjectBufferATI = cast(typeof(glFreeObjectBufferATI))load("glFreeObjectBufferATI\0".ptr);
	glArrayObjectATI = cast(typeof(glArrayObjectATI))load("glArrayObjectATI\0".ptr);
	glGetArrayObjectfvATI = cast(typeof(glGetArrayObjectfvATI))load("glGetArrayObjectfvATI\0".ptr);
	glGetArrayObjectivATI = cast(typeof(glGetArrayObjectivATI))load("glGetArrayObjectivATI\0".ptr);
	glVariantArrayObjectATI = cast(typeof(glVariantArrayObjectATI))load("glVariantArrayObjectATI\0".ptr);
	glGetVariantArrayObjectfvATI = cast(typeof(glGetVariantArrayObjectfvATI))load("glGetVariantArrayObjectfvATI\0".ptr);
	glGetVariantArrayObjectivATI = cast(typeof(glGetVariantArrayObjectivATI))load("glGetVariantArrayObjectivATI\0".ptr);
	return GL_ATI_vertex_array_object;
}


bool load_gl_GL_ARB_sparse_texture(void* function(const(char)* name) load) {
	if(!GL_ARB_sparse_texture) return GL_ARB_sparse_texture;

	glTexPageCommitmentARB = cast(typeof(glTexPageCommitmentARB))load("glTexPageCommitmentARB\0".ptr);
	return GL_ARB_sparse_texture;
}


bool load_gl_GL_EXT_draw_range_elements(void* function(const(char)* name) load) {
	if(!GL_EXT_draw_range_elements) return GL_EXT_draw_range_elements;

	glDrawRangeElementsEXT = cast(typeof(glDrawRangeElementsEXT))load("glDrawRangeElementsEXT\0".ptr);
	return GL_EXT_draw_range_elements;
}


