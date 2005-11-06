# Makefile pro rozsireni Ruby napsana v C++ pro hru freeVikings.
# igneus 7.6.2005

CPP=g++

RUBY_HEADERS:=$(shell ruby -e "require 'rbconfig'; puts Config::CONFIG['archdir']")
SWIG_LIB=`swig -swiglib`

# The main target. On Windows it would be (maybe?) called Extensions.dll
EXT=Extensions.so

ALL_OBJECT_FILES=rectangle.o map.o exceptions.o extensions_wrap.o
ALL_HEADER_FILES=rectangle/rectangle.hpp map/map.hpp exceptions/exceptions.hpp
ALL_SWIG_FILES=extensions.i rectangle/rectangle.i map/map.i exceptions/exceptions.i

SUBDIR_INCLUDES=-I./rectangle -I./map -I./exceptions

all: $(EXT)

$(EXT): $(ALL_OBJECT_FILES)
	$(CPP) -shared -fPIC $(ALL_OBJECT_FILES) -o $(EXT) -lruby -lswigrb

extensions_wrap.o: extensions_wrap.cxx
	$(CPP) -c extensions_wrap.cxx -I$(RUBY_HEADERS) $(SUBDIR_INCLUDES)

extensions_wrap.cxx: $(ALL_SWIG_FILES) $(ALL_HEADER_FILES)
	swig -c++ -ruby extensions.i

# --- Rectangle
rectangle.o: rectangle/rectangle.cpp rectangle/rectangle.hpp
	$(CPP) -c rectangle/rectangle.cpp

# --- Map
map.o: map/map.cpp map/map.hpp exceptions/exceptions.hpp
	$(CPP) -c map/map.cpp -I$(RUBY_HEADERS) $(SUBDIR_INCLUDES)

# --- Exceptions
exceptions.o: exceptions/exceptions.hpp exceptions/exceptions.cpp
	$(CPP) -c exceptions/exceptions.cpp -I$(RUBY_HEADERS)

clean:
	rm *.so
	rm *.o
	rm extensions_wrap.cxx
