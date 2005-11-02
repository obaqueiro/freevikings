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
#include "rectangle.hpp"

class Map
{
private:
  typedef std::vector<std::vector<VALUE>> TilesGrid;

  bool _initialized = false;
  TilesGrid _blocks;

public:

  /* Methods of the old good FreeVikings::Map class */
  Rectangle rect();
  bool is_area_free(Rectangle area);

  /* Methods which support the map loading process.
     They are declared public because SWIG doesn't make interface
     for private and protected methods, but they should only be used
     from inside of Map. */
  void start_loading();
  void add_tile(VALUE tile);
  void new_tiles_line();
  void end_loading();
};
