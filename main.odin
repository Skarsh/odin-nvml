package main

import "core:fmt"

import "nvml"

main :: proc() {
	// Initialize NVML
	fmt.println("hellope")

	init_result := nvml.init()
	fmt.println("init_result: ", init_result)

	shutdown_result := nvml.shutdown()
	fmt.println("shutdown_result: ", shutdown_result)
}
