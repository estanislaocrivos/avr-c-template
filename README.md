# Bare Metal AVR C/C++ Template 📟

**Disclaimer:** Repository currently under development.

A minimalistic template for developing bare metal applications on C/C++ for AVR microcontrollers using CMake. This template is designed to help you get started quickly with AVR development without relying on any Vendor-specific framework or IDE.

## Features

- CMake-based build system
- Support for C and C++ languages
- Easy to customize for different AVR microcontrollers
- Simple test setup using Ceedling
- Minimal dependencies

## Prerequisites

### Install CMake

Follow the instructions on the [CMake website](https://cmake.org/download/) to install CMake for your platform. On Linux-based systems, you can install it using your package manager. For example, on Ubuntu:

```bash
sudo apt install cmake
```

### Install AVR-GCC

Follow the instructions on the [AVR-GCC website](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio/gcc-compilers) to install AVR-GCC for your platform. On Linux-based systems, you can install it using your package manager. For example, on Ubuntu:

```bash
sudo apt install gcc-avr binutils-avr avr-libc avrdude
```

After installation, ensure that the `avr-gcc` and `avr-g++` commands are on your system's PATH. You can verify this by running:

```bash
avr-gcc --version
avr-g++ --version
```

### Customize the template

You may change the project name in the `CMakeLists.txt` file, at line 2 (`project(avr-c-template C CXX)`). The default name is `avr-c-template`. Both the target MCU and clock frequency can be passed as arguments to the CMake command or set in the `build.sh` script.

## Testing

To run the tests, you can use the following command:

```bash
cmake --build build --target run_tests
```

## Building the binary

For compiling the project, simply run the following command in the root directory:

```bash
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../avr-gcc-toolchain.cmake -DMCU=atmega328p -DF_CPU=16000000UL ..
make
```

Replace `atmega328p` and `16000000UL` with your target MCU and clock frequency as needed. The binaries will be generated in the `build` directory.

## Flashing the target

To flash the generated binary to your AVR microcontroller, you can use `avrdude`. The command will depend on your specific programmer and target MCU. Here is an example command:

```bash
avrdude -C /etc/avrdude.conf -v -V -p atmega2560 -c stk500v1 -P /dev/ttyACM1 -b 19200 -U flash:w:avr-c-template.hex:i
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
