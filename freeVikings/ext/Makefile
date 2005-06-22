# Makefile pro rozsireni Ruby napsana v C++ pro hru freeVikings.
# igneus 7.6.2005

RECTANGLE_EXT=Rectangle.so

all: $(RECTANGLE_EXT)

$(RECTANGLE_EXT): rectangle/*
	cd rectangle && make
	cp rectangle/$(RECTANGLE_EXT) .
