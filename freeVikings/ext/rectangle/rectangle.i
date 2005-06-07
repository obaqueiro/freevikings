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

class Rectangle
{
public:
  Rectangle();
  Rectangle(int left, int top, int width, int height);

  int left();
  int top();
  int width();
  int height();

private:
  int _left, _top, _width, _height;
};
