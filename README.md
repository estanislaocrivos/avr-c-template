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

## Testing environment

A minimal test setup is provided using [Ceedling](https://www.throwtheswitch.org/ceedling) (v1.0.1 or later), which is a test framework for C that provides a simple way to write and run tests for your code. It runs on Ruby, so you need to have Ruby installed on your system. You can install Ruby using your package manager or follow the instructions on the [Ruby website](https://www.ruby-lang.org/en/documentation/installation/) (Ceedling v1.0.1 or later requires Ruby 3.0 or later). After installing Ruby, you can install Ceedling by running:

```bash
gem install ceedling
```

After adding the `ceedling` command to your PATH, you can run the tests by executing the following command in the `test` directory of the project:

```bash
ceedling test:all
```

## Building the binary

For compiling the project, you can use the provided `build.sh` script, which uses CMake to generate the Makefiles and build the project. The script sets the target MCU and clock frequency, which can be customized as needed:

```bash
./build.sh [<MCU>] [<F_CPU>]
```

If you prefer to build the project manually, you can create a `build` directory and run CMake with the appropriate toolchain file and options. Here is an example of how to do this:

```bash
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../avr-gcc-toolchain.cmake -DMCU=atmega328p -DF_CPU=16000000UL ..
make
```

Replace `atmega328p` and `16000000UL` with your target MCU and clock frequency as needed. The output binaries will be generated in the `build` directory.

## Flashing the target

To flash the generated binary to your AVR microcontroller, you can use `avrdude`. The command will depend on your specific programmer and target MCU. Here is an example command for flashing an ATmega2560 using an Arduino UNO as an ICSP programmer:

```bash
avrdude -C /etc/avrdude.conf -v -V -p atmega2560 -c stk500v1 -P /dev/ttyACM1 -b 19200 -U flash:w:avr-c-template.hex:i
```

You can find more information about `avrdude` and its options in the [AVRDUDE documentation](https://avrdudes.github.io/avrdude/).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
