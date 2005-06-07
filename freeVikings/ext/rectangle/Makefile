# Makefile pro FreeVikings::Extensions
# igneus 7.6.2005

RUBY_HEADERS="/usr/lib/ruby/1.8/i386-linux-gnu"
SWIG_LIB=`swig -swiglib`

all: Rectangle.so

Rectangle.so: rectangle.o rectangle_wrap.o
	g++ -shared -fPIC -o Rectangle.so rectangle.o rectangle_wrap.o -lruby

rectangle.o: rectangle.cpp rectangle.hpp
	g++ -c rectangle.cpp

rectangle_wrap.o: rectangle_wrap.cxx
	g++ -c rectangle_wrap.cxx -I$(RUBY_HEADERS)

rectangle_wrap.cxx: rectangle.i
	swig -c++ -ruby rectangle.i
