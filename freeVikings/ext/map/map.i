/*
map.i
igneus 3.11.2005

SWIG Interface file for C++ class Map and Ruby.
!!!! This interface file isn't standalone! It belongs to extensions.i !!!!
*/

%{
#include "map.hpp"
%}

/* Aliases: */
%alias Map::is_area_free "area_free?";
%alias Map::add_tile "<<";

/* Typemaps: */
%typemap(out) bool {
  $result = ($1 != false) ? Qtrue : Qfalse;
}

%typemap(in) Rectangle (Rectangle rect) {
  /* Make a Rectangle from VALUE */
  int x, y, w, h;
  ID x_method, y_method, w_method, h_method;

  // get symbols:
  x_method = rb_intern("x");
  y_method = rb_intern("y");
  w_method = rb_intern("w");
  h_method = rb_intern("h");

  x = NUM2INT(rb_funcall($input, x_method, 0));
  y = NUM2INT(rb_funcall($input, y_method, 0));
  w = NUM2INT(rb_funcall($input, w_method, 0));
  h = NUM2INT(rb_funcall($input, h_method, 0));

  rect = Rectangle(x, y, w, h);
  $1 = rect;
}

/* Load the class declaration (this must be done after aliases etc. 
   declarations and I don't know why...): */
%include "map.hpp";
