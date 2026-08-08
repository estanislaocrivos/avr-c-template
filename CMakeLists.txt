cmake_minimum_required(VERSION 3.13)
project(avr-c-template C CXX ASM)

# ---------------------------------------------------------------------------
# Sources
# ---------------------------------------------------------------------------
set(SOURCE_DIR  "${CMAKE_SOURCE_DIR}/src")
set(INCLUDE_DIR "${CMAKE_SOURCE_DIR}/inc")

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
    "${SOURCE_DIR}/*.c"
    "${SOURCE_DIR}/*.cpp"
    "${SOURCE_DIR}/*.cc"
    "${SOURCE_DIR}/*.S"
)

if(NOT SOURCES)
    message(FATAL_ERROR "No source files found under ${SOURCE_DIR}")
endif()

# ---------------------------------------------------------------------------
# ELF target — the real build product; .hex and friends are derived from it.
# ---------------------------------------------------------------------------
set(ELF_TARGET ${PROJECT_NAME}.elf)

add_executable(${ELF_TARGET} ${SOURCES})
target_include_directories(${ELF_TARGET} PRIVATE ${INCLUDE_DIR})

set_target_properties(${ELF_TARGET} PROPERTIES
    C_STANDARD            11
    C_STANDARD_REQUIRED   YES
    CXX_STANDARD          17
    CXX_STANDARD_REQUIRED YES
)

# Emit a linker map so the flash/RAM footprint of every symbol is inspectable.
target_link_options(${ELF_TARGET} PRIVATE
    "LINKER:-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map"
)

# ---------------------------------------------------------------------------
# Post-build: derive .hex (flash image), .lst (disassembly), print size.
# ---------------------------------------------------------------------------
set(HEX_FILE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex")
set(LST_FILE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.lst")

add_custom_command(TARGET ${ELF_TARGET} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex -R .eeprom
            $<TARGET_FILE:${ELF_TARGET}> ${HEX_FILE}
    COMMAND ${CMAKE_OBJDUMP} -h -S
            $<TARGET_FILE:${ELF_TARGET}> > ${LST_FILE}
    COMMAND ${AVR_SIZE} --mcu=${MCU} --format=avr
            $<TARGET_FILE:${ELF_TARGET}>
    BYPRODUCTS ${HEX_FILE} ${LST_FILE}
    COMMENT "Generating ${PROJECT_NAME}.hex, .lst and printing size for ${MCU}"
    VERBATIM
)

# Aggregate target so `cmake --build . --target firmware` builds everything.
add_custom_target(firmware ALL DEPENDS ${ELF_TARGET})
