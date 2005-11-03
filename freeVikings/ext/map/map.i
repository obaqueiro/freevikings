%module "FreeVikings::Extensions"

/*
map.i
igneus 3.11.2005

SWIG Interface file for C++ class Map and Ruby.
*/

%{
#include "map.hpp"
%}

/* Aliases: */
%alias Map::is_area_free "area_free?";
%alias Map::add_tile "<<";

/* Typemaps: */
%typemap(out) bool Map::is_area_free
	"$result = ($1 != false) ? Qtrue : Qfalse;";

/* Load the class declaration (this must be done after aliases etc. 
   declarations and I don't know why...): */
%include "map.hpp";
