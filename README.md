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

Use the `build.sh` script, which drives CMake with the AVR toolchain file and prints a size report after linking:

```bash
./build.sh                                 # atmega2560 @ 16 MHz, Release
./build.sh -m atmega328p -f 8000000UL      # different target
./build.sh -t Debug -v                     # Debug build, verbose output
./build.sh --clean                         # wipe build/ and rebuild
./build.sh --help                          # full option list
```

Supported build types are `Debug`, `Release` (default), `MinSizeRel` and `RelWithDebInfo`. Every build produces the following artifacts under `build/`:

| File                      | Purpose                                     |
| ------------------------- | ------------------------------------------- |
| `<project>.elf`           | Linked ELF (source-of-truth build product)  |
| `<project>.hex`           | Intel HEX image ready to flash              |
| `<project>.lst`           | Full disassembly listing                    |
| `<project>.map`           | Linker map with per-symbol flash/RAM usage  |

If you prefer to invoke CMake directly:

```bash
cmake -S . -B build \
      -DCMAKE_TOOLCHAIN_FILE=avr-gcc-toolchain.cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DMCU=atmega2560 -DF_CPU=16000000UL
cmake --build build --parallel
```

## Flashing the target

The `flash.sh` script wraps `avrdude` and supports two flashing paths:

- **`direct`** — the target board exposes its own USB serial and runs a bootloader (e.g. an Arduino Mega 2560 with the stock Optiboot/STK500v2 bootloader). Uses programmer `wiring` @ 115200 baud.
- **`isp`** — the target ATmega is programmed via ICSP through a secondary Arduino running the "Arduino as ISP" sketch. Uses programmer `stk500v1` @ 19200 baud.

```bash
./flash.sh                                 # direct-flash newest build/*.hex
./flash.sh -m isp                          # flash via Arduino-as-ISP over ICSP
./flash.sh -m direct -p /dev/tty.usbmodem14201
./flash.sh -H build/avr-c-template.hex -- -e   # forward extra args to avrdude
./flash.sh --dry-run                       # print the avrdude command and exit
./flash.sh --help                          # full option list
```

The serial port is auto-detected from `/dev/tty.usbmodem*`, `/dev/tty.usbserial-*`, `/dev/ttyACM*` and `/dev/ttyUSB*`; pass `-p/--port` to override. The HEX file defaults to the newest `*.hex` in `build/`; pass `-H/--hex` to override.

See the [AVRDUDE documentation](https://avrdudes.github.io/avrdude/) for the full programmer/option reference.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
