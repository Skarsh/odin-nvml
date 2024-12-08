package main

import "core:fmt"

import "nvml"

main :: proc() {
	// Initialize NVML
	fmt.println("hellope")

	lib_loaded := nvml.load_nvml_lib()
	if !lib_loaded {
		fmt.eprintln("NVML library not loaded, cannot proceed!")
		return
	}

	init_result := nvml.init()
	fmt.println("init_result: ", init_result)

	cuda_driver_version, cuda_driver_err := nvml.get_system_cuda_driver_version()
	fmt.println("cuda_driver_version: ", cuda_driver_version)
	if cuda_driver_err != .Success {
		fmt.eprintln("CUDA driver_err: ", cuda_driver_err)
	}

	graphics_driver_version, driver_err := nvml.get_system_driver_version()
	if driver_err != .Success {
		fmt.eprintln("NVIDIA driver_err: ", driver_err)
	}
	fmt.println("graphics_driver_version: ", graphics_driver_version)

	nvml_version, nvml_version_err := nvml.get_system_nvml_version()
	if nvml_version_err != .Success {
		fmt.eprintln("NVML version err: ", nvml_version_err)
	}

	fmt.println("NVML version: ", nvml_version)


	//process_name, process_name_err := nvml.get_system_process_name()
	//if process_name_err != .Success {
	//	fmt.eprintln("System process name err: ", process_name_err)
	//}

	//fmt.println("System process name: ", process_name)


	shutdown_result := nvml.shutdown()
	fmt.println("shutdown_result: ", shutdown_result)
}
