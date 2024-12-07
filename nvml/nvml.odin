package nvml

import "core:c"
import "core:fmt"

when ODIN_OS == .Linux {
	foreign import nvml "system:libnvidia-ml.so"
}

nvmlReturn_t :: distinct c.int

Nvml_Error :: enum {
    // The operation was successful
    Success,
    // NVML was not first initialized with nvmlInit().
    Uninitialized,
    // A supplied argument is invalid.
    Invalid_Argument,
    // The requested operation is not available on target device.
    Not_Supported,
    // The current user does not have permission for operation.
    No_Permission,
    // Deprecated: Multiple initializations are now allowed through ref counting.
    Already_Initialized,
    // A query to find an object was unsuccessful.
    Not_Found,
    // An input argument is not large enough.
    Insufficient_Size,
    // A device's external power cables are not properly attached.
    Insufficient_Power,
    // NVIDIA driver is not loaded.
    Driver_Not_Loaded,
    // User provided timeout passed.
    Timeout,
    // NVIDIA Kernel detected an interrupt issue with a GPU. 
    IRQ_Issue,
    // NVML Shared Library couldn't be found or loaded. 
    Library_Not_Found,
    // Local version of NVML doesn't implement this function.
    Function_Not_Found,
    // infoROM is corrupted 
    Corrupted_InfoROM,
    // The GPU has fallen off the bus or has otherwise become inaccessible. 
    GPU_Is_Lost,
    //The GPU requires a reset before it can be used again. 
    Reset_Required,
    // The GPU control device has been blocked by the operating system/cgroups. 
    Operating_System,
    // RM detects a driver/library version mismatch. 
    LIB_RM_Version_Mismatch,
    // An operation cannot be performed because the GPU is currently in use. 
    In_Use,
    // Insufficient memory. 
    Memory,
    // No data.
    No_Data,
    // The requested vgpu operation is not available on target device, becasue ECC is enabled. 
    VGPU_ECC_Not_Supported,
    // Ran out of critical resources, other than memory. 
    Insufficient_Resources,
    // Ran out of critical resources, other than memory. 
    Freq_Not_Supported,
    // The provided version is invalid/unsupported.
    Argument_Version_Mismatch,
    // The requested functionality has been deprecated. 
    Deprecated,
    // The system is not ready for the request. 
    Not_Ready,
    // No GPUs were found. 
    GPU_Not_Found,
    // Resource not in correct state to perform requested operation. 
    Invalid_State,
    // An internal driver error occurred. 
    Unknown,
}


to_error :: proc(code: nvmlReturn_t) -> Nvml_Error {
    switch code {
    case 0: return .Success
    case 1: return .Uninitialized
    case 2: return .Invalid_Argument
    case 3: return .Not_Supported
    case 4: return .No_Permission
    case 5: return .Already_Initialized
    case 6: return .Not_Found
    case 7: return .Insufficient_Size
    case 8: return .Insufficient_Power
    case 9: return .Driver_Not_Loaded
    case 10: return .Timeout
    case 11: return .IRQ_Issue
    case 12: return .Library_Not_Found
    case 13: return .Function_Not_Found
    case 14: return .Corrupted_InfoROM
    case 15: return .GPU_Is_Lost
    case 16: return .Reset_Required
    case 17: return .Operating_System
    case 18: return .LIB_RM_Version_Mismatch
    case 20: return .Memory
    case 21: return .No_Data
    case 22: return .VGPU_ECC_Not_Supported
    case 23: return .Insufficient_Resources
    case 24: return .Freq_Not_Supported
    case 25: return .Argument_Version_Mismatch
    case 26: return .Deprecated
    case 27: return .Not_Ready
    case 28: return .GPU_Not_Found
    case 29: return .Invalid_State

    case: return .Unknown
    }
}

// Define flags
No_Attach_Flag ::  1
No_GPUS_Flag :: 2

@(default_calling_convention="c")
foreign nvml {
    // Init
    nvmlInit_v2 :: proc() -> nvmlReturn_t ---
    nvmlShutdown :: proc() -> nvmlReturn_t ---  
    nvmlInitWithFlags :: proc(flags: c.uint) -> nvmlReturn_t ---

    // System - Cuda
    nvmlSystemGetCudaDriverVersion :: proc(cudaDriverVersion: ^c.int) -> nvmlReturn_t ---
    nvmlSystemGetCudaDriverVersion_v2 :: proc(cudaDriverVersion: [^]c.int) -> nvmlReturn_t ---

    // System - Graphics
    nvmlSystemGetDriverVersion :: proc(version: [^]c.char, length: c.uint) -> nvmlReturn_t ---


}

// ---------------------- Initialization ----------------------

// Initialize NVML, but don't initialize any GPUs yet.
init :: proc() -> Nvml_Error {
    return to_error(nvmlInit_v2())
}

init_with_flags :: proc(flags: u32) -> Nvml_Error {
    return to_error(nvmlInitWithFlags(flags))
}

// Shut down NVML by releasing all GPU resources previously allocated with `init`.
shutdown :: proc() -> Nvml_Error {
    return to_error(nvmlShutdown())
}



// ---------------------- System Queries ----------------------

// Retrieves the version of the CUDA driver
get_cuda_driver_version :: proc() -> (Cuda_Driver_Version, Nvml_Error) {
    version : c.int
    result := to_error(nvmlSystemGetCudaDriverVersion(&version))

    if result != .Success {
        return Cuda_Driver_Version{}, result
    }
    
    driver_version := format_driver_version(int(version))

    return driver_version, result
}

// ---------------------- Helper / Convenicence procedures and structures ----------------------
Cuda_Driver_Version :: struct {
    major: int,
    minor: int
}

format_driver_version :: proc(version: int) -> Cuda_Driver_Version {
    major := version / 1000
    minor := (version % 1000) / 10
    cuda_version := Cuda_Driver_Version{major, minor }
    return cuda_version
}
