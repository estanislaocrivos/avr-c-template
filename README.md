# Bare Metal AVR C/C++ Template 📟

A minimalistic template for developing bare metal applications on C/C++ for AVR microcontrollers using CMake as build system and avr-gcc as the compiler. This template is designed to help you get started quickly with AVR development without relying on any vendor-specific IDE.

## Features

- CMake-based build system
- Support for C and C++ languages
- Easy to customize for different AVR microcontrollers
- Simple test setup using Ceedling
- Automatic documentation generation with Doxygen
- Minimal dependencies

## Device support and standard library documentation

This template is designed to support various AVR microcontrollers. The `avr-libc` standard library documentation along with the full list of supported devices can be found in the [avr-libc documentation](https://avrdudes.github.io/avr-libc/avr-libc-user-manual/index.html).

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

#### Visual Studio Code paths configuration

This template includes a `.vscode` directory with a `c_cpp_properties.json` file that configures the C/C++ extension for Visual Studio Code. This file specifies the include paths and defines for the AVR microcontroller you are targeting. You may need to adjust the paths based on your AVR-GCC installation.

#### Project name

You may want to change the project name to something more meaningful for your application. The project name is defined in the following files:

- `CMakeLists.txt`: The project name is set using the `project()` command. The project name defined here also serves as the output binary name.
- `Doxyfile`: The project name is set using the `PROJECT_NAME` tag. This name is used in the generated documentation.
- `.vscode/c_cpp_properties.json`: The project name is used in the `name` field. This has no functional impact.
- `.github/workflows/ci.yaml`: The project name is used in the `name` field. This has no functional impact.

## Testing environment

A minimal test setup is provided using [Ceedling](https://www.throwtheswitch.org/ceedling) (v1.0.1 or later), which is a test framework for C that provides a simple way to write and run tests for your code. It runs on Ruby, so you need to have Ruby installed on your system. You can install Ruby using your package manager or follow the instructions on the [Ruby website](https://www.ruby-lang.org/en/documentation/installation/) (Ceedling v1.0.1 or later requires Ruby 3.0 or later). After installing Ruby, you can install Ceedling by running:

```bash
gem install ceedling
```

After adding the `ceedling` command to your PATH, you can run the tests by executing the following command in the `test` directory of the project:

```bash
ceedling test:all
```

You can also run the tests and generate a coverage report by running the provided `run-tests.sh` script:

```bash
./run-tests.sh
```

## Generating documentation

Doxygen is the default chosen tool for generating documentation from annotated source code. To install Doxygen, follow the instructions on the [Doxygen website](https://www.doxygen.nl/download.html) or use your package manager. For example, on Ubuntu:

```bash
sudo apt install doxygen
```

Once Doxygen is installed, you can generate the documentation by running the following command in the root directory of the project:

```bash
doxygen Doxyfile
```

Or you may use the provided `generate-docs.sh` script, which will run Doxygen and open the generated documentation in your web browser:

```bash
./generate-docs.sh
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
