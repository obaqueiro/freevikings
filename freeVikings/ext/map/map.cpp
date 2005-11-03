/*
  map.cpp
  igneus 3.11.2005

  class FreeVikings::Extensions::Map implementation
  (FreeVikings::Extensions::Map is a replacement for standard
  pure-Ruby-written class FreeVikings::Map which is a bottle-neck
  of freeVikings;
*/

#include "map.hpp"
// some #includes are in map.hpp - look there before #including here!

Rectangle * Map::rect()
{
  return new Rectangle();
}

bool Map::is_area_free(Rectangle area)
{
  return false;
}

void Map::start_loading()
{
}

void Map::add_tile(VALUE tile)
{
}

void Map::new_tiles_line()
{
}
 
void Map::end_loading()
{
}
