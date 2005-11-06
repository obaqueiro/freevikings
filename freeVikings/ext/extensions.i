%module "FreeVikings::Extensions"

/*
extensions.i
igneus 6.11.2005

SWIG interface file which gives all the classes into one module
(FreeVikings::Extensions) sothey can be compiled together into one shared 
library.
*/

%include "rectangle/rectangle.i"
%include "map/map.i"
