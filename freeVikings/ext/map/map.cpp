/*
  map.cpp
  igneus 3.11.2005

  class FreeVikings::Extensions::Map implementation
  (FreeVikings::Extensions::Map is a replacement for standard
  pure-Ruby-written class FreeVikings::Map which is a bottle-neck
  of freeVikings;
*/

#include "exceptions.hpp"
#include "map.hpp"
// some #includes are in map.hpp - look there before #including here!


Map::Map()
{
  _columns = 0;
}

/* 
 * Traditional Map methods.
 */

Rectangle * Map::rect()
{
  return new Rectangle();
}

bool Map::is_area_free(Rectangle area)
{
  return false;
}

/*
 * Inspecting methods.
 */

int Map::tiles_columns()
{
  return _columns;
}

int Map::tiles_rows()
{
  return _blocks.size();
}


/*
 * Loading methods.
 */

void Map::add_tile(VALUE tile)
{
  if (_blocks.size() == 0) {
    rb_raise(rb_eRuntimeError, "No map row created. Tiles can't be inserted. Call 'new_tiles_line' first.");
  }

  std::vector<std::vector<VALUE> >::iterator current_row = (_blocks.end() - 1);

  /* All the tile-rows must be of same length. When the first one is being
     loaded, _columns is set to the length which must be same for all.
     This length is then used in checks of the other lines. */
  if (_blocks.size() == 1) {
    _columns += 1;
  } else {
    if (current_row->size() >= _columns) {
      // Current row will be longer than the first row after addition of the 
      // new tile.
      rb_raise(rb_eRuntimeError, "Row too long.");
    }
  }

  current_row->push_back(tile);
}

void Map::new_tiles_line()
{
  std::vector<VALUE> *line = new std::vector<VALUE>();
  _blocks.push_back(*line);
}
 
void Map::end_loading()
{
}
