cmake_minimum_required(VERSION 3.13)
project(avr-c-template C CXX)

set(SOURCE_DIR "${CMAKE_SOURCE_DIR}/src") # Include src/ directory
set(INCLUDE_DIR "${CMAKE_SOURCE_DIR}/inc") # Include inc/ directory

file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.c" "${SOURCE_DIR}/*.cpp") # Recursively find all .c and .cpp files in src/ directory

add_executable(${PROJECT_NAME} ${SOURCES}) # Create the executable from the source files
target_include_directories(${PROJECT_NAME} PRIVATE ${INCLUDE_DIR}) # Include the inc/ directory

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex
    COMMAND avr-objcopy -O ihex -R .eeprom ${CMAKE_BINARY_DIR}/${PROJECT_NAME} ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex
    DEPENDS ${PROJECT_NAME}
    COMMENT "Generating HEX file"
) # Custom command to generate the HEX file from the compiled binary

add_custom_target(hex ALL DEPENDS ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex) # Custom target to ensure the HEX file is built when the project is built
