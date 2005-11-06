/*
exceptions.cpp
igneus 6.11.2005
*/

#include "ruby.h"

/* Superclass of all the FreeVikings::Extensions exceptions.
   Its's a pitty I can't add it into the module (it would need some black
   SWIG hack and I don't like black hacks - they cause problems) */
VALUE FvExtError;

void init_exception_classes()
{
  FvExtError = rb_define_class("FVExtensionError", rb_eRuntimeError);
}
