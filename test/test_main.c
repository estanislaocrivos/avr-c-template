#include "../build/vendor/unity/src/unity.h"

#include "../inc/lib.h"

void test(void)
{
    TEST_ASSERT_EQUAL(-1, lib_function(0));
    TEST_ASSERT_EQUAL(4, lib_function(2));
    TEST_ASSERT_EQUAL(1, 1);
}
