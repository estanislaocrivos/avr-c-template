set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)

# Especifica el compilador y las herramientas
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)
set(CMAKE_AR avr-ar)
set(CMAKE_OBJCOPY avr-objcopy)
set(CMAKE_OBJDUMP avr-objdump)
set(CMAKE_RANLIB avr-ranlib)

# Opciones específicas para AVR
set(CMAKE_C_FLAGS "-Wall -Os -DF_CPU=16000000UL -mmcu=atmega2560 -I../inc")
set(CMAKE_CXX_FLAGS "-Wall -Os -DF_CPU=16000000UL -mmcu=atmega2560 -I../inc")