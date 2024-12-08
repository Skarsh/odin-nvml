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

	cuda_driver_version, err := nvml.get_cuda_driver_version()
	fmt.println("cuda_driver_version: ", cuda_driver_version)


	shutdown_result := nvml.shutdown()
	fmt.println("shutdown_result: ", shutdown_result)


}
