package nvml

// Buffer size guaranteed to be large enough for nvmlDeviceGetInforomVersion and nvmlDeviceGetInforomImageVersion
DEVICE_INFOROM_VERSION_BUFFER_SIZE :: 16

// Buffer size guaranteed to be large enough for storing GPU device names
DEVICE_NAME_BUFFER_SIZE :: 64

// Buffer size guaranteed to be large enough for nvmlDeviceGetName
DEVICE_NAME_V2_BUFFER_SIZE :: 96

// Buffer size guaranteed to be large enough for nvmlDeviceGetBoardPartNumber
DEVICE_PART_NUMBER_BUFFER_SIZE :: 80

// Buffer size guaranteed to be large enough for nvmlDeviceGetSerial
DEVICE_SERIAL_BUFFER_SIZE :: 30

// Buffer size guaranteed to be large enough for storing GPU identifiers
DEVICE_UUID_BUFFER_SIZE :: 80

// Buffer size guaranteed to be large enough for nvmlDeviceGetUUID
DEVICE_UUID_V2_BUFFER_SIZE :: 96

// Buffer size guaranteed to be large enough for nvmlDeviceGetVbiosVersion
DEVICE_VBIOS_VERSION_BUFFER_SIZE :: 32

// Buffer size guaranteed to be large enough for nvmlSystemGetDriverVersion
SYSTEM_DRIVER_VERSION_BUFFER_SIZE :: 80

// Buffer size guaranteed to be large enough for nvmlSystemGetNVMLVersion
SYSTEM_NVML_VERSION_BUFFER_SIZE :: 80

