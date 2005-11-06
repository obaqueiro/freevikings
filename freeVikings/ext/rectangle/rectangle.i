/*
rectangle.i
igneus 7.6.2005

!!!! This interface file isn't standalone! It belongs to extensions.i !!!!
*/

%{
#include "rectangle.hpp"
%}



/* Aliases (I don't know why, but they must be defined before the class
definition): */
%alias Rectangle::at "[]";
%alias Rectangle::width "w";
%alias Rectangle::height "h";

/* Rename accessors according to the Rubish conventions: */
%rename("collides?") Rectangle::collides;
%rename("left=") Rectangle::set_left;
%rename("top=") Rectangle::set_top;
%rename("h=") Rectangle::set_height;
%rename("w=") Rectangle::set_width;
%rename("empty?") Rectangle::empty;
%rename("eql?") Rectangle::eql;

/* Typemaps */
%typemap(out) bool Rectangle::collides 
	"$result = ($1 != false) ? Qtrue : Qfalse;";

%typemap(out) bool Rectangle::empty
	"$result = ($1 != false) ? Qtrue : Qfalse;";

%typemap(out) bool Rectangle::eql 
	"$result = ($1 != false) ? Qtrue : Qfalse;";


/* Load the class definition: */
%include "rectangle.hpp";

