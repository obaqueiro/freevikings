/*
  rectangle.cpp
  igneus 7.5.2005

  FreeVikings::Extensions::Rectangle::Rectangle class implementation.
*/

#include "rectangle.hpp"

Rectangle::Rectangle()
{
  _left = _top = _width = _height = 0;
}

Rectangle::Rectangle(int left, int top, int width, int height)
{
  _left = left;
  _top = top;
  _width = width;
  _height = height;
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

int Rectangle::right()
{
  return _left + _width;
}

int Rectangle::bottom()
{
  return _top + _height;
}

int Rectangle::set_left(int x)
{
  return _left = x;
}

int Rectangle::set_top(int y)
{
  return _top = y;
}

int Rectangle::set_height(int h)
{
  return _height = h;
}

int Rectangle::set_width(int w)
{
  return _width = w;
}

/* Rectangle is very similar to Array. It can be indexed.
 Because SWIG doesn't support C++ operator functions, Rectangle#[] method
 is implemented as an alias of Rectangle#at. */

int Rectangle::at(int index)
{
  switch (index) {
  case 0:
    return _left;
    break;
  case 1:
    return _top;
    break;
  case 2:
    return _width;
    break;
  case 3:
    return _height;
    break;
  default:
    throw "Index out of bounds.";
  }
}

bool Rectangle::collides(Rectangle &rect)
{
  if (this->left() <= rect.right() && rect.left() <= this->right() &&
      this->top() <= rect.bottom() && rect.top() <= this->bottom()) {
    return true;
  } else {
    return false;
  }
}
