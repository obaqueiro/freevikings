/*
  rectangle.cpp
  igneus 7.5.2005

  FreeVikings::Extensions::Rectangle class declaration.
*/

class Rectangle
{
public:
  /* Constructors: */
  Rectangle();
  Rectangle(int left, int top, int width, int height);

  /* Attribute readers: */
  int left();
  int top();
  int width();
  int height();

  /* Pseudo-attribute-readers (utilities for better understanding) */
  int right();
  int bottom();

  /* Attribute writers: */
  int set_left(int x);
  int set_top(int y);
  int set_height(int h);
  int set_width(int w);

  /* Indexing: */
  int at(int index);

  /* Collision detection: */
  bool collides(Rectangle &rect);

private:
  int _left, _top, _width, _height;
};
