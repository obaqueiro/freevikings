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

Rectangle::Rectangle(Rectangle::Numeric left, Rectangle::Numeric top, Rectangle::Numeric width, Rectangle::Numeric height)
{
  _left = left;
  _top = top;
  _width = width;
  _height = height;
}

Rectangle::Numeric Rectangle::left()
{
  return _left;
}

Rectangle::Numeric Rectangle::top()
{
  return _top;
}

Rectangle::Numeric Rectangle::width()
{
  return _width;
}

Rectangle::Numeric Rectangle::height()
{
  return _height;
}

Rectangle::Numeric Rectangle::right()
{
  return _left + _width;
}

Rectangle::Numeric Rectangle::bottom()
{
  return _top + _height;
}

Rectangle::Numeric Rectangle::set_left(Rectangle::Numeric x)
{
  return _left = x;
}

Rectangle::Numeric Rectangle::set_top(Rectangle::Numeric y)
{
  return _top = y;
}

Rectangle::Numeric Rectangle::set_height(Rectangle::Numeric h)
{
  return _height = h;
}

Rectangle::Numeric Rectangle::set_width(Rectangle::Numeric w)
{
  return _width = w;
}

/* Rectangle is very similar to Array. It can be indexed.
 Because SWIG doesn't support C++ operator functions, Rectangle#[] method
 is implemented as an alias of Rectangle#at. */

Rectangle::Numeric Rectangle::at(Rectangle::Numeric index)
{
  switch ((int) index) {
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
