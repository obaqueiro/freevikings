/*
  spritemanager.cpp
  igneus 11.4.2005

  SpriteManager class implementation.
*/

#include <vector>
#include <algorithm>

#include "ruby.h"

#include "spritemanager.hpp"

/**** Adds the sprite into the SpriteManager's internal sprites list. */

VALUE SpriteManager::add(VALUE sprite)
{
  _sprites.push_back(sprite);
}

/**** Says if the sprite is registered in the SpriteManager's sprites list. */

VALUE SpriteManager::is_sprite_included(VALUE sprite)
{
  valuevector::const_iterator found = find(_sprites.begin(), _sprites.end(), sprite);

  if (found == _sprites.end()) 
    return Qnil;
  else
    return Qtrue;
}
