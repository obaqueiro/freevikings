/*
  spritemanager.hpp
  igneus 11.4.2005

  SpriteManager class definition.
  SpriteManager cares of a list of active sprites which are present in 
  a location.
*/

#include <vector>
#include "ruby.h"

using std::vector;


class SpriteManager
{
public:
  VALUE add(VALUE sprite);

private:
  VALUE _self;
  vector<VALUE> _sprites;
};
