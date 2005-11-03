# Makefile pro rozsireni Ruby napsana v C++ pro hru freeVikings.
# igneus 7.6.2005

CPP=g++

RUBY_HEADERS:=$(shell ruby -e "require 'rbconfig'; puts Config::CONFIG['archdir']")
SWIG_LIB=`swig -swiglib`

# Targets
RECTANGLE_O=rectangle.o rectangle_wrap.o
MAP_O=map.o map_wrap.o

# The main target. On Windows it would be (maybe?) called Extensions.dll
EXT=Extensions.so

all: $(EXT)

$(EXT): $(RECTANGLE_O) $(MAP_O)
	$(CPP) -shared -fPIC $(RECTANGLE_O) $(MAP_O) -o $(EXT) -lruby -lswigrb

# --- Rectangle
rectangle.o: rectangle/rectangle.cpp rectangle/rectangle.hpp
	$(CPP) -c rectangle/rectangle.cpp

rectangle_wrap.o: rectangle/rectangle_wrap.cxx
	$(CPP) -c rectangle/rectangle_wrap.cxx -I$(RUBY_HEADERS)

rectangle/rectangle_wrap.cxx: rectangle/rectangle.i rectangle/rectangle.cpp rectangle/rectangle.hpp
	swig -c -c++ -ruby rectangle/rectangle.i

# --- Map
map.o: map/map.cpp map/map.hpp
	$(CPP) -c map/map.cpp -I./rectangle -I$(RUBY_HEADERS)

map_wrap.o: map/map_wrap.cxx
	$(CPP) -c map/map_wrap.cxx -I./rectangle -I$(RUBY_HEADERS)

map/map_wrap.cxx: map/map.i map/map.cpp map/map.hpp
	swig -c -c++ -ruby map/map.i
