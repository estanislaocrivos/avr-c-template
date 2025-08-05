set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)

set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)
set(CMAKE_AR avr-ar)
set(CMAKE_OBJCOPY avr-objcopy)
set(CMAKE_OBJDUMP avr-objdump)
set(CMAKE_RANLIB avr-ranlib)

if(NOT DEFINED MCU)
    set(MCU atmega2560) # Default MCU
endif()

if(NOT DEFINED F_CPU)
    set(F_CPU 16000000UL) # Default CPU frequency
endif()

set(COMMON_FLAGS "-Wall -Os -mmcu=${MCU} -DF_CPU=${F_CPU}") # Compiler flags for both C and C++

set(CMAKE_C_FLAGS "${COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS}")
