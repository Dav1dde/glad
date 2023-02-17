#![deny(warnings)]
/**
 * Full VK should compile
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan=" --extensions="VK_KHR_swapchain,VK_NV_external_memory_win32,VK_MVK_macos_surface,VK_KHR_wayland_surface,VK_NN_vi_surface,VK_MVK_ios_surface,VK_EXT_acquire_xlib_display,VK_KHR_xcb_surface,VK_ANDROID_external_memory_android_hardware_buffer" rust
 * COMPILE: cp -r $test_dir/. $tmp && cd $tmp && cargo build
 * RUN: cargo run
 */
extern crate glad_vulkan;
use glad_vulkan::vk;

#[allow(path_statements)]
fn main() {
    vk::GetDeviceProcAddr;
    vk::GetSwapchainImagesKHR;

    vk::GetMemoryWin32HandleNV;
    vk::CreateMacOSSurfaceMVK;
    vk::CreateWaylandSurfaceKHR;
    vk::CreateViSurfaceNN;
    vk::CreateIOSSurfaceMVK;
    vk::GetRandROutputDisplayEXT;
    vk::GetPhysicalDeviceXcbPresentationSupportKHR;
    vk::GetMemoryAndroidHardwareBufferANDROID;
}
