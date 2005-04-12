/*
  smmain.cpp
  igneus 11.4.2005
  Ruby API methods for the SpriteManager extension.
*/

#include "ruby.h"

#include "smcontext.hpp"

static VALUE freeVikings_module;
static VALUE extensions_module;
static VALUE sprite_manager_klass;


static void define_modules(void);
static void define_SM_class(void);

/**** Function is used by the Ruby API, which supports C function-names
 (both C and C++ compilers change the function names, but in different ways),
 so it must be defined as 'extern "C"'.

 The Ruby interpreter calls it when the module is loaded. */

extern "C"
void Init_extspritemanager(void)
{
  define_modules();
  define_SM_class();
}

/**** Defines the FreeVikings and FreeVikings::Extensions namespace modules 
      through the Ruby API methods. */

static void define_modules(void)
{
  freeVikings_module = rb_define_module("FreeVikings");
  extensions_module = rb_define_module_under(freeVikings_module, "Extensions");
}

/**** Defines the FreeVikings::Extensions::SpriteManager class through
      the Ruby API methods.
      Binds the SMContext member functions with the SpriteManager methods. */

static void define_SM_class(void)
{
  sprite_manager_klass = rb_define_class_under(extensions_module, "SpriteManager", rb_cObject);

  // SpriteManager#initialize
  rb_define_method(sprite_manager_klass, "initialize", (VALUE (*)(...)) SMExtensionContext::initialize_new_SpriteManager, 1);
  // SpriteManager#add
  rb_define_method(sprite_manager_klass, "add", (VALUE (*)(...)) SMExtensionContext::add_sprite, 1);
  // SpriteManager#include?
  rb_define_method(sprite_manager_klass, "include?", (VALUE (*)(...)) SMExtensionContext::is_sprite_included, 1);
}
