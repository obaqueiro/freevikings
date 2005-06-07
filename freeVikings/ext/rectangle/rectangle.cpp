/*
  rectangle.cpp
  igneus 7.5.2005

  Implementace tridy FreeVikings::Extensions::Rectangle
*/

#include "rectangle.hpp"

Rectangle::Rectangle()
{
  _left = _top = _width = _height = 0;
}

Rectangle::Rectangle(int left, int top, int width, int height)
{

}

int Rectangle::left()
{
  return _left;
}

int Rectangle::top()
{
  return _top;
}

int Rectangle::width()
{
  return _width;
}

int Rectangle::height()
{
  return _height;
}
