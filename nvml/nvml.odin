package nvml

import "core:c"
import "core:dynlib"
import "core:fmt"
import "core:strings"
import "core:sys/windows"


nvmlReturn_t :: distinct c.int

nvml_handle: dynlib.Library

// Function pointer types
nvmlInit_v2_t :: #type proc() -> nvmlReturn_t
nvmlShutdown_t :: #type proc() -> nvmlReturn_t
nvmlInitWithFlags_t :: #type proc(flags: c.uint) -> nvmlReturn_t
nvmlSystemGetCudaDriverVersion_t :: #type proc(cudaDriverVersion: ^c.int) -> nvmlReturn_t
nvmlSystemGetCudaDriverVersion_v2_t :: #type proc(cudaDriverVersion: [^]c.int) -> nvmlReturn_t
nvmlSystemGetDriverVersion_t :: #type proc(version: [^]c.char, length: c.uint) -> nvmlReturn_t

// Function pointers
nvmlInit_v2: nvmlInit_v2_t
nvmlShutdown: nvmlShutdown_t
nvmlInitWithFlags: nvmlInitWithFlags_t
nvmlSystemGetCudaDriverVersion: nvmlSystemGetCudaDriverVersion_t
nvmlSystemGetCudaDriverVersion_v2: nvmlSystemGetCudaDriverVersion_v2_t
nvmlSystemGetDriverVersion: nvmlSystemGetDriverVersion_t

load_nvml_lib :: proc() -> bool {
	if nvml_handle != nil {
		return true
	}

	lib_name: string
	when ODIN_OS == .Windows {
		lib_name = "nvml.dll"
	} else {
		lib_name = "libnvidia-ml.so.1"
	}

	fmt.println("lib_name: ", lib_name)
	handle, loaded := dynlib.load_library(lib_name)
	if !loaded {
		fmt.eprintln("Failed to load NVML: ", dynlib.last_error())
		return false
	}

	nvml_handle = handle
	return true
}

unload_nvml_lib :: proc() -> bool {
	if nvml_handle != nil {
		return false
	}
	return dynlib.unload_library(nvml_handle)
}

get_proc_address :: proc(name: cstring) -> rawptr {
	if nvml_handle == nil {
		return nil
	}

	ptr, found := dynlib.symbol_address(nvml_handle, string(name))

	if !found {
		fmt.eprintfln("Failed to find symbol {} : {}", string(name), dynlib.last_error())
		return nil
	}

	return ptr
}

init_function_pointers :: proc() -> bool {
	if !load_nvml_lib() {
		return false
	}

	nvmlInit_v2 = cast(nvmlInit_v2_t)get_proc_address("nvmlInit_v2")
	nvmlShutdown = cast(nvmlShutdown_t)get_proc_address("nvmlShutdown")
	nvmlInitWithFlags = cast(nvmlInitWithFlags_t)get_proc_address("nvmlInitWithFlags")
	nvmlSystemGetCudaDriverVersion =
	cast(nvmlSystemGetCudaDriverVersion_t)get_proc_address("nvmlSystemGetCudaDriverVersion")
	nvmlSystemGetCudaDriverVersion_v2 =
	cast(nvmlSystemGetCudaDriverVersion_v2_t)get_proc_address("nvmlSystemGetCudaDriverVersion_v2")
	nvmlSystemGetDriverVersion =
	cast(nvmlSystemGetDriverVersion_t)get_proc_address("nvmlSystemGetDriverVersion")

	return(
		nvmlInit_v2 != nil &&
		nvmlShutdown != nil &&
		nvmlInitWithFlags != nil &&
		nvmlSystemGetCudaDriverVersion != nil &&
		nvmlSystemGetCudaDriverVersion_v2 != nil &&
		nvmlSystemGetDriverVersion != nil \
	)

}

// Public API

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
	case 0:
		return .Success
	case 1:
		return .Uninitialized
	case 2:
		return .Invalid_Argument
	case 3:
		return .Not_Supported
	case 4:
		return .No_Permission
	case 5:
		return .Already_Initialized
	case 6:
		return .Not_Found
	case 7:
		return .Insufficient_Size
	case 8:
		return .Insufficient_Power
	case 9:
		return .Driver_Not_Loaded
	case 10:
		return .Timeout
	case 11:
		return .IRQ_Issue
	case 12:
		return .Library_Not_Found
	case 13:
		return .Function_Not_Found
	case 14:
		return .Corrupted_InfoROM
	case 15:
		return .GPU_Is_Lost
	case 16:
		return .Reset_Required
	case 17:
		return .Operating_System
	case 18:
		return .LIB_RM_Version_Mismatch
	case 20:
		return .Memory
	case 21:
		return .No_Data
	case 22:
		return .VGPU_ECC_Not_Supported
	case 23:
		return .Insufficient_Resources
	case 24:
		return .Freq_Not_Supported
	case 25:
		return .Argument_Version_Mismatch
	case 26:
		return .Deprecated
	case 27:
		return .Not_Ready
	case 28:
		return .GPU_Not_Found
	case 29:
		return .Invalid_State

	case:
		return .Unknown
	}
}

// Define flags
No_Attach_Flag :: 1
No_GPUS_Flag :: 2


// ---------------------- Initialization ----------------------

// Initialize NVML, but don't initialize any GPUs yet.
// TODO(Thomas): call load_nvml_lib here?
init :: proc() -> Nvml_Error {
	if !init_function_pointers() {
		return .Library_Not_Found
	}
	return to_error(nvmlInit_v2())
}

init_with_flags :: proc(flags: u32) -> Nvml_Error {
	if !init_function_pointers() {
		return .Library_Not_Found
	}
	return to_error(nvmlInitWithFlags(flags))
}

// Shut down NVML by releasing all GPU resources previously allocated with `init`.
// TODO(Thomas): call unload_load_nvml_lib here?
shutdown :: proc() -> Nvml_Error {
	if nvmlShutdown == nil {
		return .Library_Not_Found
	}
	return to_error(nvmlShutdown())
}

// ---------------------- System Queries ----------------------

// Retrieves the version of the CUDA driver
get_system_cuda_driver_version :: proc() -> (Cuda_Driver_Version, Nvml_Error) {
	version: c.int

	if nvmlSystemGetCudaDriverVersion == nil {
		return Cuda_Driver_Version{}, .Library_Not_Found
	}

	result := to_error(nvmlSystemGetCudaDriverVersion(&version))

	if result != .Success {
		return Cuda_Driver_Version{}, result
	}

	return format_driver_version(int(version)), .Success
}

// Retrieves the driver branch of the NVIDIA driver installed on the system.
get_system_driver_version :: proc() -> (version: string, err: Nvml_Error) {
	// Allocate buffer for the version string
	buffer: [SYSTEM_DRIVER_VERSION_BUFFER_SIZE]c.char

	if nvmlSystemGetDriverVersion == nil {
		return "", .Library_Not_Found
	}

	// Call NVML to get the driver version
	result := nvmlSystemGetDriverVersion(raw_data(buffer[:]), SYSTEM_DRIVER_VERSION_BUFFER_SIZE)

	if err = to_error(result); err != .Success {
		return "", err
	}

	// Count the actual string length until null terminator
	length := 0
	for c in buffer {
		if c == 0 {
			break
		}
		length += 1
	}

	// Create a persistent copy of the string
	if length > 0 {
		version = strings.clone(string(buffer[:length]))
	}

	return version, .Success
}

// ---------------------- Helper / Convenicence procedures and structures ----------------------
Cuda_Driver_Version :: struct {
	major: int,
	minor: int,
}

format_driver_version :: proc(version: int) -> Cuda_Driver_Version {
	major := version / 1000
	minor := (version % 1000) / 10
	cuda_version := Cuda_Driver_Version{major, minor}
	return cuda_version
}
