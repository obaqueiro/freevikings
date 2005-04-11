/*
  smcontext.hpp
  igneus 11.4.2005

  SpriteManager Extension Context.
  ExtensionContext is a class which has only static (or, as a rubyist 
  would say, class) functions. This class works as a dispatcher.
  It maintains a 'hash' (a std::map actually) of all the SpriteManager 
  objects in use. Whenever it's method is called, a receiver is found in
  the vector and the function is delegated (Delegate! Dispatcher is a
  variant of the Delegate design pattern).
*/

#include <map>
#include "spritemanager.hpp"

using std::map;

class SMExtensionContext
{
public:
  static VALUE initialize_new_SpriteManager(VALUE manager_baby, VALUE location);
  static VALUE add_sprite(VALUE manager, VALUE sprite);
  static VALUE is_sprite_included(VALUE manager, VALUE sprite);
  /* static VALUE delete_sprite(VALUE manager, VALUE sprite); */


private:
  static map<VALUE, SpriteManager> __managers;
};
