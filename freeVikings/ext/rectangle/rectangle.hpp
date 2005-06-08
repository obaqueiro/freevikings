/*
  rectangle.cpp
  igneus 7.5.2005

  FreeVikings::Extensions::Rectangle class declaration.
*/

class Rectangle
{
public:
  /* Data types: */
  typedef double Numeric;

  /* Constructors: */
  Rectangle();
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

  /* Collision detection: */
  bool collides(Rectangle &rect);

private:
  Numeric _left, _top, _width, _height;
};
