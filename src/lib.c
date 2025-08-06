#include "../inc/lib.h"

int8_t lib_function(int8_t arg)
{
    if (arg == 0)
    {
        return -1;  // Error case
    }
    else
    {
        return arg * 2;  // Example operation
    }
}
