/*
  spritemanager.hpp
  igneus 11.4.2005

  SpriteManager class definition.
  SpriteManager cares of a list of active sprites which are present in 
  a location.
*/

#include <vector>

class SpriteManager
{
public:
  typedef std::vector<VALUE> valuevector;

  VALUE add(VALUE sprite);
  VALUE is_sprite_included(VALUE sprite);

private:
  VALUE _self;
  valuevector _sprites;
};
