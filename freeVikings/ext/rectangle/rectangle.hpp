/*
  rectangle.cpp
  igneus 7.5.2005

  FreeVikings::Extensions::Rectangle class declaration.
*/

#define RECTANGLE_INCLUDED 1

class Rectangle
{
public:
  /* Data types: */
  typedef double Numeric;

  /* Constructors: */
  Rectangle();
  Rectangle(const Rectangle &rect);
  Rectangle(Numeric left, Numeric top, Numeric width, Numeric height);

  /* Attribute readers: */
  Numeric left();
  Numeric top();
  Numeric width();
  Numeric height();

  /* Pseudo-attribute-readers (utilities for better understanding) */
  Numeric right();
  Numeric bottom();

  /* Attribute writers: */
  Numeric set_left(Numeric x);
  Numeric set_top(Numeric y);
  Numeric set_height(Numeric h);
  Numeric set_width(Numeric w);

  /* Indexing: */
  Numeric at(Numeric index);

  /* Functions for compatibility with standard Ruby's class Array: */
  bool empty();
  Numeric size();

  /* Collision detection: */
  bool collides(Rectangle &rect);

  /* Comparison: */
  bool eql(Rectangle &rect);

private:
  Numeric _left, _top, _width, _height;
};
