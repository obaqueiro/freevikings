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

/* local methods: */
static bool is_tile_solid(VALUE tile);


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
  // Get indexes of the tiles on the edges of area:
  int leftmost_tile_index = area.left() / Map::TILE_SIZE;
  int rightmost_tile_index = area.right() / Map::TILE_SIZE;

  int top_row_index = area.top() / Map::TILE_SIZE;
  int bottom_row_index = area.bottom() / Map::TILE_SIZE;

  // check the values
  if ((leftmost_tile_index < 0) || (rightmost_tile_index >= _columns) ||
      (top_row_index < 0) || (bottom_row_index >= _blocks.size())) {
    rb_raise(rb_eArgError, "Area out of map.");
  }

  // iterate over the tiles from area until one which is solid
  // is found or end reached.
  for (int r = top_row_index; r <= bottom_row_index; r++) {
    for (int c = leftmost_tile_index; c <= rightmost_tile_index; c++) {
      if (is_tile_solid(_blocks[r][c])) {
	return false;
      }
    }
  }

  return true;
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

VALUE Map::get_at(int column, int row)
{
  if ((_blocks.size() <= row) || (_columns <= column))
    return Qnil;

  return _blocks[row][column];
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

/*
 * Helpful non-Map-member static methods.
 */

// Checks if tile is solid.
// Does the important Ruby type checks.
static bool is_tile_solid(VALUE tile)
{
  ID method_solid = rb_intern("solid?"); // Ruby symbol of method solid?

  if (! rb_respond_to(tile, method_solid)) {
    rb_raise(rb_eTypeError, "Found tile which does not respond to 'solid?'.");
  }

  VALUE solid_value = rb_funcall(tile, method_solid, 0);

  if (TYPE(solid_value) == T_TRUE)
    return true;
  else
    return false;
}
