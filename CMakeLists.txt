cmake_minimum_required(VERSION 3.13)
project(avr-c-template C)

# Configuración de directorios
set(SOURCE_DIR "${CMAKE_SOURCE_DIR}/src")
set(INCLUDE_DIR "${CMAKE_SOURCE_DIR}/inc")
file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.c")

# Configuración del compilador y flags
set(CMAKE_C_COMPILER "avr-gcc")
set(MCU "atmega2560")
set(F_CPU "16000000UL")
set(CMAKE_C_FLAGS "-Wall -Os -DF_CPU=${F_CPU} -mmcu=${MCU} -I${INCLUDE_DIR}")

# Generar el archivo ELF
add_executable(avr-c-template ${SOURCES})
target_include_directories(avr-c-template PRIVATE ${INCLUDE_DIR})

# Generar el archivo HEX a partir del ELF
add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/avr-c-template.hex
    COMMAND avr-objcopy -O ihex -R .eeprom ${CMAKE_BINARY_DIR}/avr-c-template ${CMAKE_BINARY_DIR}/avr-c-template.hex
    DEPENDS avr-c-template
    COMMENT "Generating HEX file"
)

add_custom_target(hex ALL DEPENDS ${CMAKE_BINARY_DIR}/avr-c-template.hex)

# Subir el archivo HEX al microcontrolador con avrdude
add_custom_target(upload
    COMMAND /Users/estanislaocrivosgandini/Library/Arduino15/packages/arduino/tools/avrdude/6.3.0-arduino17/bin/avrdude
    -C/Users/estanislaocrivosgandini/Library/Arduino15/packages/arduino/tools/avrdude/6.3.0-arduino17/etc/avrdude.conf
    -v -V -p ${MCU} -c stk500v1 -P /dev/cu.usbmodem* -b 19200 -U flash:w:${CMAKE_BINARY_DIR}/avr-c-template.hex:i
    DEPENDS hex
    COMMENT "Uploading HEX file to the microcontroller"
)
