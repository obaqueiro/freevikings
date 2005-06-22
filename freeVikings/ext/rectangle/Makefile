# Makefile pro FreeVikings::Extensions
# igneus 7.6.2005

CPP=g++

RUBY_HEADERS=`ruby -e "require 'rbconfig'; puts Config::CONFIG['archdir']"`
SWIG_LIB=`swig -swiglib`

# The main target. On Windows it would be called Rectangle.dll
SHARED_OBJECT=Rectangle.so

all: $(SHARED_OBJECT)

$(SHARED_OBJECT): rectangle.o rectangle_wrap.o
	$(CPP) -shared -fPIC -o $(SHARED_OBJECT) rectangle.o rectangle_wrap.o -lruby

rectangle.o: rectangle.cpp rectangle.hpp
	$(CPP) -c rectangle.cpp

rectangle_wrap.o: rectangle_wrap.cxx
	$(CPP) -c rectangle_wrap.cxx -I$(RUBY_HEADERS)

rectangle_wrap.cxx: rectangle.i rectangle.cpp rectangle.hpp
	swig -c++ -ruby rectangle.i

clean:
	rm -f *.o $(SHARED_OBJECT) rectangle_wrap.cxx
