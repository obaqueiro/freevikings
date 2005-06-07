/*
  rectangle.cpp
  igneus 7.5.2005

  Deklarace tridy FreeVikings::Extensions::Rectangle
*/

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
