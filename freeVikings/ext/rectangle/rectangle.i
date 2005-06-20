%module "FreeVikings::Extensions::Rectangle"

/*
  rectangle.i
  igneus 7.6.2005

  Soubor rozhrani pro zpracovani generatorem SWIG.
  Slouzi pro zpristupneni tridy Rectangle zapsane v C++ pro Ruby.
*/

%{
#include "rectangle.hpp"
%}



/* Aliasy (musi byt kdoviproc zavedeny pred deklaraci tridy): */
%alias Rectangle::at "[]";
%alias Rectangle::width "w";
%alias Rectangle::height "h";

/* Funkce pojmenovane jak je zvykem v C++ prejmenujeme dle rubyistickych 
   zvyklosti: */
%rename("collides?") Rectangle::collides;
%rename("left=") Rectangle::set_left;
%rename("top=") Rectangle::set_top;
%rename("h=") Rectangle::set_height;
%rename("w=") Rectangle::set_width;
%rename("empty?") Rectangle::empty;
%rename("eql?") Rectangle::eql;

/* Mapa typovych konversi pro metodu Rectangle#collides? */
%typemap(out) bool Rectangle::collides 
	"$result = ($1 != false) ? Qtrue : Qfalse;";

%typemap(out) bool Rectangle::empty
	"$result = ($1 != false) ? Qtrue : Qfalse;";

%typemap(out) bool Rectangle::eql 
	"$result = ($1 != false) ? Qtrue : Qfalse;";


/* Nahrajeme deklaraci tridy: */
%include "rectangle.hpp";

