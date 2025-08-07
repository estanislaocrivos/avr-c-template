#ifndef MYCLASS_HPP
#define MYCLASS_HPP

/* ============================================================================================== */

#include <stdint.h>

/* ============================================================================================== */

/**
 * @brief MyClass constructor
 * This class is an example of a simple C++ class that can be used in an AVR C project. It
 * demonstrates how to encapsulate data and provide a method to access it.
 * @param value The initial value to set in the class.
 * @return void
 */
class MyClass
{
   public:
    MyClass(uint8_t value);
    int getValue() const;

   private:
    int value_;
};

/* ============================================================================================== */

#endif  // MYCLASS_HPP
