/*
  smcontext.cpp
  igneus 11.4.2005

  SpriteManager Extension Context implementation.
  SMContext is a class which has only static (or, as a rubyist 
  would say, class) functions. This class works as a dispatcher.
  It maintains a 'hash' (a std::map actually) of all the SpriteManager 
  objects in use. Whenever it's method is called, a receiver is found in
  the vector and the function is delegated (Delegate! Dispatcher is a
  variant of the Delegate design pattern).
*/

#include "ruby.h"

#include "smcontext.hpp"

/**** Adds a Sprite into the manager specified by the first argument. */

VALUE SMExtensionContext::add_sprite(VALUE manager, VALUE sprite)
{

}

VALUE SMExtensionContext::is_sprite_included(VALUE manager, VALUE sprite)
{
  return Qnil;
}
