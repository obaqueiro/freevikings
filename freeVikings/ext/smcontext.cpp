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

#include <utility>

#include "ruby.h"

#include "smcontext.hpp"

/* Initialization of the static SMExtensionContext attributes: 
   It's strange to me, I'm spoilt by comfortable programming in Ruby.
   But in C++ the static class attributes have to be initialized
   out of the class definition. */
SpriteManager SMExtensionContext::__manager = SpriteManager();
SMExtensionContext::value_to_manager_map SMExtensionContext::__managers = value_to_manager_map();


/**** 'initialize' method is in Ruby called after the object's creation
      during the 'new' method execution.
      When Ruby calls this function during it's C API, we make a new
      C++ SpriteManager object.
      Whenever Ruby will send us a method call for an object with VALUE
      new_manager, we'll delegate it onto that SpriteManager object. */

VALUE SMExtensionContext::initialize_new_SpriteManager(VALUE new_manager_v, VALUE location)
{
  SpriteManager *manager_object = new SpriteManager;
  std::pair<VALUE, SpriteManager*> p = std::pair<VALUE, SpriteManager*>(new_manager_v, manager_object);

  __managers.insert(p);
}

/**** Adds a Sprite into the manager specified by the first argument. */

VALUE SMExtensionContext::add_sprite(VALUE manager, VALUE sprite)
{
  SpriteManager *m = get_manager(manager);

  return m->add(sprite);
}

/**** Says if the sprite is included in the specified manager. */

VALUE SMExtensionContext::is_sprite_included(VALUE manager, VALUE sprite)
{
  SpriteManager *m = get_manager(manager);

  return m->is_sprite_included(sprite);
}

/**** Returns the C++ SpriteManager object binded with the VALUE manager or
      raises a Ruby interpreter exception through the Ruby API. */

SpriteManager* SMExtensionContext::get_manager(VALUE manager)
{
  SMExtensionContext::value_to_manager_map::iterator found = __managers.find(manager);
  if (found != __managers.end()) {
    return found->second;
  } else {
    rb_raise(rb_eRuntimeError, "SpriteManager C++ object was not found for the value %l", manager);
    return NULL;
  }
}
