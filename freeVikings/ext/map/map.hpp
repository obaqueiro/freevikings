/*
  map.hpp
  igneus 2.11.2005

  class FreeVikings::Extensions::Map declaration
  (FreeVikings::Extensions::Map is a replacement for standard
  pure-Ruby-written class FreeVikings::Map which is a bottle-neck
  of freeVikings;

  Only critic methods are rewritten in C++, the rest must be added
  in the Ruby code.)
*/

#include <vector>
#include "ruby.h"

#ifndef RECTANGLE_INCLUDED
#include "rectangle.hpp"
#endif

class Map
{
public:
  // typedef std::vector<std::vector<VALUE>> TilesGrid;

private:
  bool _initialized;

  int _columns;

  std::vector<std::vector<VALUE> > _blocks;

public:

  static const int TILE_SIZE = 40;

  Map();

  /* Methods of the old good FreeVikings::Map class */
  Rectangle * rect();
  bool is_area_free(Rectangle area);

  /* Methods inspecting the map. They are used in the tests. */
  int tiles_columns(); // number of colums
  int tiles_rows();    // number of rows
  VALUE get_at(int column, int row); // returns the specified tile or nil

  /* Methods which support the map loading process.
     They are declared public because SWIG doesn't make interface
     for private and protected methods, but they should only be used
     from inside of Map. */
  void add_tile(VALUE tile);
  void new_tiles_line();
  void end_loading();
};
