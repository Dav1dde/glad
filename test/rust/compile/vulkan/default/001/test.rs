#![deny(warnings)]
/**
 * Full VK should compile
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan=" rust
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
