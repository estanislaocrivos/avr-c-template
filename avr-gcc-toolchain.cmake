# AVR bare-metal toolchain file for CMake.
#
# Configure with:
#   cmake -DCMAKE_TOOLCHAIN_FILE=avr-gcc-toolchain.cmake \
#         -DMCU=atmega2560 -DF_CPU=16000000UL -DCMAKE_BUILD_TYPE=Release ..

set(CMAKE_SYSTEM_NAME      Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)

# The AVR target has no host runtime, so CMake's default try-compile (which
# links an executable) fails. Build a static library instead when probing.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ---------------------------------------------------------------------------
# Locate the AVR toolchain binaries. Failing here is much clearer than a
# cryptic error deep inside the generated Makefiles.
# ---------------------------------------------------------------------------
find_program(AVR_CC      avr-gcc     REQUIRED)
find_program(AVR_CXX     avr-g++     REQUIRED)
find_program(AVR_AR      avr-ar      REQUIRED)
find_program(AVR_OBJCOPY avr-objcopy REQUIRED)
find_program(AVR_OBJDUMP avr-objdump REQUIRED)
find_program(AVR_RANLIB  avr-ranlib  REQUIRED)
find_program(AVR_SIZE    avr-size    REQUIRED)

set(CMAKE_C_COMPILER   ${AVR_CC})
set(CMAKE_CXX_COMPILER ${AVR_CXX})
set(CMAKE_ASM_COMPILER ${AVR_CC})
set(CMAKE_AR           ${AVR_AR})
set(CMAKE_OBJCOPY      ${AVR_OBJCOPY})
set(CMAKE_OBJDUMP      ${AVR_OBJDUMP})
set(CMAKE_RANLIB       ${AVR_RANLIB})

# ---------------------------------------------------------------------------
# Target selection (overridable at configure time via -D).
# ---------------------------------------------------------------------------
if(NOT DEFINED MCU)
    set(MCU atmega2560 CACHE STRING "Target AVR microcontroller")
endif()

if(NOT DEFINED F_CPU)
    set(F_CPU 16000000UL CACHE STRING "Target CPU frequency in Hz (with UL suffix)")
endif()

# Default to Release; single-config generators need this before project().
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING
        "Build type: Debug | Release | MinSizeRel | RelWithDebInfo" FORCE)
endif()

# ---------------------------------------------------------------------------
# Compiler / linker flags. *_INIT variables seed the cache the first time
# CMake configures the project, so callers can still override on the CLI.
# ---------------------------------------------------------------------------
set(_avr_common
    "-mmcu=${MCU} -DF_CPU=${F_CPU} -Wall -Wextra -Wshadow -Wundef -Wdouble-promotion -Wformat=2 -ffunction-sections -fdata-sections -fno-common")

set(CMAKE_C_FLAGS_INIT   "${_avr_common}")
set(CMAKE_CXX_FLAGS_INIT "${_avr_common} -fno-exceptions -fno-rtti -fno-threadsafe-statics")
set(CMAKE_ASM_FLAGS_INIT "-mmcu=${MCU}")

set(CMAKE_C_FLAGS_RELEASE_INIT          "-Os -DNDEBUG -flto")
set(CMAKE_CXX_FLAGS_RELEASE_INIT        "-Os -DNDEBUG -flto")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT       "-Os -DNDEBUG -flto")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT     "-Os -DNDEBUG -flto")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT   "-Os -g -DNDEBUG -flto")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-Os -g -DNDEBUG -flto")
set(CMAKE_C_FLAGS_DEBUG_INIT            "-Og -g3")
set(CMAKE_CXX_FLAGS_DEBUG_INIT          "-Og -g3")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-mmcu=${MCU} -Wl,--gc-sections -flto -fuse-linker-plugin")
