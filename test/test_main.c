#include "support/unity.h"

#include "../inc/lib.h"  // Include the header file for the library being tested

TEST_SOURCE_FILE("../src/lib.c")  // Include the source file for testing

void test(void)
{
    /* Test macros are defined on the unity.h file. More information can be found in the Unity
     * documentation */
    TEST_ASSERT_EQUAL(-1, lib_function(0));
    TEST_ASSERT_EQUAL(4, lib_function(2));
}
